{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}: let
  cfg = config.features.git;
  home = config.home.homeDirectory;
  isTower = (osConfig.networking.hostName or "") == "tower";
  # tower has the 5C Nano fixed in place, so it signs by default there;
  # every other host defaults to the 5C, with both always reachable via alias.
  defaultSigningKey =
    if isTower
    then "${home}/.ssh/id_ed25519_sk_yk5cnano.pub"
    else "${home}/.ssh/id_ed25519_sk_yk5c.pub";

  # gpg.ssh.defaultKeyCommand: print the first key in the ssh-agent, in the
  # "key::<pubkey>" form git expects.
  agentSigningKey = pkgs.writeShellScript "git-agent-signing-key" ''
    key="$(${pkgs.openssh}/bin/ssh-add -L 2>/dev/null | ${pkgs.gnugrep}/bin/grep -m1 '^\(sk-\)\?ssh-')" || {
      echo "git-agent-signing-key: no keys in ssh-agent (try 'ssh-add -K')" >&2
      exit 1
    }
    echo "key::$key"
  '';
in {
  options.features.git = {
    agentSigning = lib.mkEnableOption "signing commits with whichever key is loaded in the ssh-agent";
    browserAuth = lib.mkEnableOption "GitHub auth through git-credential-manager (browser flow)";
    userName = lib.mkOption {
      type = lib.types.str;
      default = "viamaximus";
      description = "git user.name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "70414866+viamaximus@users.noreply.github.com";
      description = "git user.email";
    };
    githubUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "viamaximus";
      description = "GitHub username pinned for https://github.com credentials; null to not pin one.";
    };
  };

  config = {
    programs.git = {
      enable = true;
      settings = lib.mkMerge [
        {
          user.name = cfg.userName;
          user.email = cfg.userEmail;

          gpg.format = "ssh";
          commit.gpgsign = true;
          tag.gpgSign = true;
          gpg.ssh.allowedSignersFile = "${home}/.ssh/allowed_signers";

          # url."git@github.com:".insteadOf = "https://github.com/";
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";
        }

        (lib.mkIf (cfg.githubUser != null) {
          credential."https://github.com".username = cfg.githubUser;
        })

        (lib.mkIf cfg.agentSigning {
          # No fixed user.signingkey: git asks the agent instead, so any
          # yubikey works once loaded (`ssh-add -K` for resident keys).
          gpg.ssh.defaultKeyCommand = "${agentSigningKey}";
        })

        (lib.mkIf (!cfg.agentSigning) {
          user.signingkey = defaultSigningKey;
          alias = {
            commit-yk5c = "!git -c user.signingkey=${home}/.ssh/id_ed25519_sk_yk5c.pub commit";
            commit-yk5cnano = "!git -c user.signingkey=${home}/.ssh/id_ed25519_sk_yk5cnano.pub commit";
          };
        })

        (lib.mkIf cfg.browserAuth {
          credential.helper = lib.getExe pkgs.git-credential-manager;
          # GCM on Linux needs an explicit token store; secretservice is
          # backed by gnome-keyring (enabled in the host's configuration.nix).
          credential.credentialStore = "secretservice";
        })

        (lib.mkIf (!cfg.browserAuth) {
          credential."https://github.com".helper = "!${lib.getExe pkgs.gh} auth git-credential";
        })
      ];
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "base16";
      };
    };
  };
}
