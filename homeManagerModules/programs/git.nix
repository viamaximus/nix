{ config, lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "max";
    userEmail = "ianawestlake@gmail.com";
    extraConfig = {
      credential.helper = "manager";
      credential."https://github.com".username = "viamaximus";
      credential.credentialStore = "cache";
    };
  };
  home.packages = with pkgs; [
    git-credential-manager # Or similar package name from the NUR
  ];
}
