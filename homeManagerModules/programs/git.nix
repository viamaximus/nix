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
      credential.helper = "manager";
      credential."https://github.com".username = "viamaximus";
      credential.credentialStore = "cache";
    };
  };
  home.packages = with pkgs; [
    git-credential-manager # Or similar package name from the NUR
  ];
}
