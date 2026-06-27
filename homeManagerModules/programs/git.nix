{
  config,
  lib,
  pkgs,
  ...
}: let
  home = config.home.homeDirectory;
in {
  programs.git = {
    enable = true;
    settings = {
      user.name = "viamaximus";
      user.email = "70414866+viamaximus@users.noreply.github.com";

      gpg.format = "ssh";
      user.signingkey = "${home}/.ssh/id_ed25519_sk_yk5cnano.pub";
      commit.gpgsign = true;
      tag.gpgSign = true;
      gpg.ssh.allowedSignersFile = "${home}/.ssh/allowed_signers";

      alias = {
        commit-yk5c = "!git -c user.signingkey=${home}/.ssh/id_ed25519_sk_yk5c.pub commit";
        commit-yk5cnano = "!git -c user.signingkey=${home}/.ssh/id_ed25519_sk_yk5cnano.pub commit";
      };

      # url."git@github.com:".insteadOf = "https://github.com/";
      credential."https://github.com".username = "viamaximus";
      credential."https://github.com".helper = "!${lib.getExe pkgs.gh} auth git-credential";

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
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
}
