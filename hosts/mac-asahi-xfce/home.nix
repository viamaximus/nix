{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../homeManagerModules
  ];

  features.desktop.hyprland.enable = false;
  features.desktop.xfce.enable = true;

  home.username = "max";
  home.homeDirectory = "/home/max";

  home.packages = with pkgs; [
    hello
  ];

  xresources.properties = {
    "Xft.dpi" = 192;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
