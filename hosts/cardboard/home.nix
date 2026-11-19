{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../homeManagerModules
    ../../homeManagerModules/programs/profiles/workstation.nix
  ];

  features.desktop.hyprland.enable = true;
  features.desktop.noctalia.enable = true;

  # This host rotates between multiple yubikeys: sign with whatever key is in
  # the ssh-agent, and auth to GitHub through git-credential-manager (browser).
  features.git = {
    agentSigning = true;
    browserAuth = true;
    userName = "weatheredian";
    userEmail = "ian@weatheredsecurity.com";
    githubUser = null;
  };

  home.username = "nix";
  home.homeDirectory = "/home/nix";

  home.packages = with pkgs; [
    hello
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    #put .rc files here
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
