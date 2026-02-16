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
    ../../homeManagerModules/gaming.nix
  ];

  features.desktop.hyprland.enable = true;

  home.username = "max";
  home.homeDirectory = "/home/max";

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
