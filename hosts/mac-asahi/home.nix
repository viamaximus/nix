{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../homeManagerModules

    # Programs that were previously auto-imported
    ../../homeManagerModules/programs/rendering.nix
    ../../homeManagerModules/programs/media-tools.nix
    ../../homeManagerModules/programs/docker.nix
    ../../homeManagerModules/programs/communication.nix
    ../../homeManagerModules/programs/hardware-dev.nix
    ../../homeManagerModules/programs/homelab.nix
    ../../homeManagerModules/programs/reverse-engineering.nix
    ../../homeManagerModules/programs/desktop-apps.nix
    ../../homeManagerModules/programs/c-dev.nix
    ../../homeManagerModules/programs/ghidra.nix
    ../../homeManagerModules/programs/godot.nix
    ../../homeManagerModules/programs/rfstuffs.nix
    ../../homeManagerModules/programs/kicad.nix
    ../../homeManagerModules/programs/wallpaper-switch.nix
    ../../homeManagerModules/programs/vesktop.nix
    ../../homeManagerModules/programs/spotify.nix
    ../../homeManagerModules/programs/spotify-config.nix
    ../../homeManagerModules/programs/3dprint.nix
    ../../homeManagerModules/programs/vm.nix
    ../../homeManagerModules/programs/pwndbg.nix
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
