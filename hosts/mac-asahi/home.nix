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

  features.desktop.hyprland.enable = true;
  features.desktop.hyprland.waybarHeight = 32;
  stylix.targets.firefox.profileNames = ["default"];

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1,2560x1600@60,0x0,1.6"
  ];

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
