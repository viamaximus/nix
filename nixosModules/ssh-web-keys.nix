{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.viamaximus.sshWebKeys;
  normalUsers = lib.filterAttrs (_: user: user.isNormalUser or false) config.users.users;
  userNames = builtins.attrNames normalUsers;
  quotedUsers = lib.concatStringsSep " " (map lib.escapeShellArg userNames);
in {
  options.viamaximus.sshWebKeys = {
    enable = lib.mkEnableOption "fetch SSH authorized keys from a remote URL";

    url = lib.mkOption {
      type = lib.types.str;
      default = "https://viamaximus.com/keys";
      description = "my webpage containing public kye";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = userNames != [];
        message = "viamaximus.sshWebKeys.enable requires at least one normal user.";
      }
    ];

    services.openssh.authorizedKeysFiles = ["/etc/ssh/authorized_keys.d/%u"];

    systemd.services.refresh-ssh-web-keys = {
      description = "Refresh SSH authorized keys from ${cfg.url}";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        set -eu

        install -d -m 0755 /etc/ssh/authorized_keys.d

        tmp="$(mktemp)"
        trap 'rm -f "$tmp"' EXIT

        ${pkgs.curl}/bin/curl \
          --fail \
          --silent \
          --show-error \
          --location \
          ${lib.escapeShellArg cfg.url} \
          > "$tmp"

        if [ ! -s "$tmp" ]; then
          echo "remote key file is empty" >&2
          exit 1
        fi

        for user in ${quotedUsers}; do
          install -m 0644 "$tmp" "/etc/ssh/authorized_keys.d/$user"
        done
      '';
    };
  };
}
