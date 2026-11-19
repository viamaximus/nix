{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.features.backup;
  hostName = config.networking.hostName;
  home = "/home/${cfg.user}";

  # Repository password. Managed by agenix-rekey once the secret exists; until
  # then features.backup.passwordFile can point at a path outside the store.
  secretFile = ../secrets/secrets/restic-password.age;
  haveSecret = builtins.pathExists secretFile;
  passwordFile =
    if haveSecret
    then config.age.secrets.restic-password.path
    else cfg.passwordFile;

  # The SSH key is generated on the host and never leaves it; only its public
  # half goes into the NAS account's authorized_keys.
  stateDir = "/var/lib/restic";
  sshKey = "${stateDir}/id_ed25519";

  sshFlags = lib.concatStringsSep " " [
    "-i ${sshKey}"
    "-o IdentitiesOnly=yes"
    "-o BatchMode=yes"
    "-o ConnectTimeout=15"
    "-o UserKnownHostsFile=${stateDir}/known_hosts"
    "-o StrictHostKeyChecking=accept-new"
  ];

  nasTarget = "${cfg.nas.user}@${cfg.nas.host}";
  sftpCommand = "ssh ${sshFlags} ${nasTarget} -s sftp";
  repository = "sftp:${nasTarget}:${cfg.nas.repoRoot}/${hostName}";

  # Caches, re-downloadable blobs and build output. Anything matched without a
  # leading slash is matched against the basename at any depth.
  defaultExclude = [
    "${home}/Downloads"
    "${home}/.cache"
    "${home}/.steam"
    "${home}/.wine"
    "${home}/.npm"
    "${home}/.npm-global"
    "${home}/.rustup"
    "${home}/.gradle"
    "${home}/.m2"
    "${home}/.platformio"
    "${home}/.hermes"
    "${home}/Unity"
    "${home}/.cargo/registry"
    "${home}/.cargo/git"
    "${home}/go/pkg"
    "${home}/.var/app/*/cache"
    "${home}/.local/share/Steam"
    "${home}/.local/share/Trash"
    "${home}/.local/share/CKAN"
    "${home}/.local/share/containers"
    "${home}/.local/share/DaVinciResolve"
    "node_modules"
    "__pycache__"
    ".venv"
    ".direnv"
    ".mypy_cache"
    ".pytest_cache"
    "result"
    "result-[0-9]*"
    "*.gguf"
    "*.safetensors"
    "*.qcow2"
    "*.vdi"
  ];

  archiveUnitFor = path: let
    name = baseNameOf path;
    dest = "${cfg.nas.archiveRoot}/${hostName}/${name}";
    excludeFlags =
      lib.concatMapStringsSep " " (p: "--exclude=${lib.escapeShellArg p}") cfg.archive.exclude;
  in ''
    ${pkgs.rsync}/bin/rsync \
      --archive \
      --human-readable \
      --info=stats2 \
      --partial \
      ${lib.optionalString cfg.archive.delete "--delete"} \
      ${excludeFlags} \
      --rsync-path=${lib.escapeShellArg "mkdir -p ${dest} && rsync"} \
      -e ${lib.escapeShellArg "ssh ${sshFlags}"} \
      ${lib.escapeShellArg "${path}/"} \
      ${lib.escapeShellArg "${nasTarget}:${dest}/"}
  '';
in {
  options.features.backup = {
    enable = mkEnableOption "restic backups of user data to the TrueNAS";

    user = mkOption {
      type = types.str;
      default = "max";
      description = "Owner of the home directory that gets backed up.";
    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [home];
      defaultText = lib.literalExpression ''["/home/''${config.features.backup.user}"]'';
      description = "Paths handed to restic.";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = defaultExclude;
      description = ''
        Exclude patterns. Replaces the built-in list; use extraExclude to add to
        it instead.
      '';
    };

    extraExclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Host-specific exclude patterns, appended to exclude.";
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Repository password, when not using the agenix-managed secret at
        secrets/secrets/restic-password.age.
      '';
    };

    retention = mkOption {
      type = types.listOf types.str;
      default = [
        "--keep-last 3"
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
        "--keep-yearly 3"
      ];
      description = "restic forget policy applied by the weekly maintenance run.";
    };

    schedule = mkOption {
      type = types.str;
      default = "daily";
      description = "OnCalendar expression for the backup run.";
    };

    maintenanceSchedule = mkOption {
      type = types.str;
      default = "Sun 04:00";
      description = ''
        OnCalendar expression for forget/prune/check. Kept off the daily path
        because pruning over SFTP is slow.
      '';
    };

    nas = {
      host = mkOption {
        type = types.str;
        default = "192.168.1.101";
        description = ''
          TrueNAS address. Switch this to the tailnet name once TrueNAS joins
          the tailnet, so the laptops back up off-LAN too.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "restic";
        description = "TrueNAS account the hosts log in as.";
      };

      repoRoot = mkOption {
        type = types.str;
        default = "/mnt/terashare/backups";
        description = ''
          Server-side path holding one restic repository per host. This is the
          dataset path on TrueNAS, which includes the pool name
          (e.g. /mnt/tank/terashare/backups), not the SMB share name.
        '';
      };

      archiveRoot = mkOption {
        type = types.str;
        default = "/mnt/terashare/archive";
        description = "Server-side path for the plain rsync archive.";
      };
    };

    archive = {
      enable = mkEnableOption "one-way rsync of bulk directories, outside restic";

      paths = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Directories mirrored to the NAS as plain files. No history and no
          dedup, so keep anything that needs versioning in restic instead.
        '';
      };

      delete = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Propagate local deletions to the NAS copy. Off by default so the
          archive only ever grows.
        '';
      };

      exclude = mkOption {
        type = types.listOf types.str;
        default = [
          "Library/"
          "Temp/"
          "Obj/"
          "obj/"
          "Logs/"
          "UserSettings/"
          ".vs/"
        ];
        description = "rsync exclude patterns, applied to every archived path.";
      };

      schedule = mkOption {
        type = types.str;
        default = "weekly";
        description = "OnCalendar expression for the archive sync.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = haveSecret || cfg.passwordFile != null;
        message = ''
          features.backup needs a repository password. Either create the
          agenix secret:

            nix run .#agenix-rekey.${pkgs.stdenv.hostPlatform.system}.edit-view -- -e secrets/secrets/restic-password.age

          or set features.backup.passwordFile to a path outside the Nix store.
        '';
      }
      {
        assertion = cfg.archive.enable -> cfg.archive.paths != [];
        message = "features.backup.archive.enable is set but archive.paths is empty.";
      }
    ];

    age.secrets = lib.optionalAttrs haveSecret {
      restic-password.rekeyFile = secretFile;
    };

    environment.systemPackages = [pkgs.restic pkgs.rsync];

    systemd.tmpfiles.rules = ["d ${stateDir} 0700 root root -"];

    systemd.services.restic-ssh-key = {
      description = "SSH key used to reach ${cfg.nas.host}";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        install -d -m 0700 ${stateDir}
        if [ ! -f ${sshKey} ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -C "restic@${hostName}" -f ${sshKey}
        fi
        echo "Add this key to ${nasTarget}:~/.ssh/authorized_keys"
        cat ${sshKey}.pub
      '';
    };

    services.restic.backups.${hostName} = {
      inherit repository passwordFile;
      initialize = true;
      paths = cfg.paths;
      exclude = cfg.exclude ++ cfg.extraExclude;
      extraOptions = ["sftp.command='${sftpCommand}'"];
      extraBackupArgs = [
        "--exclude-caches"
        "--one-file-system"
        "--verbose"
      ];
      inhibitsSleep = true;
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };

    systemd.services."restic-backups-${hostName}" = {
      after = ["restic-ssh-key.service"];
      requires = ["restic-ssh-key.service"];
    };

    systemd.services.restic-maintenance = {
      description = "restic forget/prune/check for ${hostName}";
      after = ["network-online.target" "restic-ssh-key.service"];
      wants = ["network-online.target"];
      requires = ["restic-ssh-key.service"];
      environment = {
        RESTIC_REPOSITORY = repository;
        RESTIC_PASSWORD_FILE = toString passwordFile;
        RESTIC_CACHE_DIR = "/var/cache/restic-backups-${hostName}";
      };
      serviceConfig = {
        Type = "oneshot";
        CacheDirectory = "restic-backups-${hostName}";
        CacheDirectoryMode = "0700";
      };
      path = [config.programs.ssh.package];
      script = let
        restic = "${pkgs.restic}/bin/restic -o ${lib.escapeShellArg "sftp.command=${sftpCommand}"}";
      in ''
        ${restic} unlock
        ${restic} forget --prune ${lib.concatStringsSep " " cfg.retention}
        ${restic} check --read-data-subset=2%
      '';
    };

    systemd.timers.restic-maintenance = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.maintenanceSchedule;
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };

    systemd.services.backup-archive = mkIf cfg.archive.enable {
      description = "rsync bulk directories to ${cfg.nas.host}";
      after = ["network-online.target" "restic-ssh-key.service"];
      wants = ["network-online.target"];
      requires = ["restic-ssh-key.service"];
      serviceConfig = {
        Type = "oneshot";
        Nice = 10;
        IOSchedulingClass = "idle";
      };
      path = [config.programs.ssh.package];
      script = lib.concatMapStringsSep "\n" archiveUnitFor cfg.archive.paths;
    };

    systemd.timers.backup-archive = mkIf cfg.archive.enable {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.archive.schedule;
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };
}
