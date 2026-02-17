{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../../homeManagerModules
  ];

  features.desktop.hyprland.enable = true;
  stylix.targets.firefox.profileNames = [ "default" ];

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
