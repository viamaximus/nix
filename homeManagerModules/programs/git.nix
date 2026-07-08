{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}: let
  home = config.home.homeDirectory;
  isTower = (osConfig.networking.hostName or "") == "tower";
  # tower has the 5C Nano fixed in place, so it signs by default there;
  # every other host defaults to the 5C, with both always reachable via alias.
  defaultSigningKey =
    if isTower
    then "${home}/.ssh/id_ed25519_sk_yk5cnano.pub"
    else "${home}/.ssh/id_ed25519_sk_yk5c.pub";
in {
  programs.git = {
    enable = true;
    settings = {
      user.name = "viamaximus";
      user.email = "70414866+viamaximus@users.noreply.github.com";

      gpg.format = "ssh";
      user.signingkey = defaultSigningKey;
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
