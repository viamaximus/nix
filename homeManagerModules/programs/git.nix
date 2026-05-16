{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "viamaximus";
      user.email = "70414866+viamaximus@users.noreply.github.com";

      # Prefer SSH for GitHub so hardware-backed SSH keys are the default auth path.
      url."git@github.com:".insteadOf = "https://github.com/";
      credential."https://github.com".username = "viamaximus";
      credential."https://github.com".helper = "!${lib.getExe pkgs.gh} auth git-credential";

      # Delta integration
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
