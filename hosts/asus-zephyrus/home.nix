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
    ../../homeManagerModules/programs/profiles/workstation.nix
  ];

  features.desktop.hyprland.enable = true;

  wayland.windowManager.hyprland.settings.monitor = [
    {
      output = "eDP-1";
      mode = "2880x1800@120.00";
      position = "0x0";
      scale = "1.6";
    }
  ];
  stylix.targets.firefox.profileNames = [ "default" ];

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
