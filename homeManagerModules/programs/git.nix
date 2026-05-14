{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "viamaximus";  # Your GitHub username
      user.email = "70414866+viamaximus@users.noreply.github.com";  # GitHub noreply email
      credential."https://github.com".username = "viamaximus";
      credential."https://github.com".helper = "!${lib.getExe pkgs.gh} auth git-credential";
    };
  };
}
