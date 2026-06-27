{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../homeManagerModules
    ../../homeManagerModules/gaming.nix
    ../../homeManagerModules/programs/profiles/workstation.nix
  ];

  features.desktop.hyprland.enable = true;
  stylix.targets.firefox.profileNames = ["default"];

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

  #   wayland.windowManager.hyprland.extraConfig = ''
  #     # monitor def
  #     #
  #     # Layout:
  #     # - DP-3 / Dell 32" 4K is the center anchor
  #     # - DP-1 / Samsung 1080p is left, vertically centered to DP-3
  #     # - HDMI-A-1 / Acer 1440p is above, horizontally centered to DP-3
  #     # - DP-2 / Acer 1080p is right portrait, bottom-aligned to DP-3
  #
  #     # UP: Acer XV271U M3, 2560x1440
  #     # hyprctl shows 143.91Hz as the highest exposed mode on HDMI-A-1.
  #     monitor = HDMI-A-1,2560x1440@143.91,2560x0,1
  #
  #     # LEFT: Samsung C27F390, 1920x1080 @ 60Hz
  #     monitor = DP-1,1920x1080@60,0x1980,1
  #
  #     # MIDDLE: Dell S3225QS, 3840x2160 @ 120Hz
  #     monitor = DP-3,3840x2160@120,1920x1440,1
  #
  #     # RIGHT: Acer XFA240, 1920x1080 @ 144Hz, portrait
  #     monitor = DP-2,1920x1080@144,5760x1680,1,transform,1
  #
  #     workspace = 1, monitor:DP-1
  #     workspace = 2, monitor:DP-3
  #     workspace = 3, monitor:DP-2
  #     workspace = 4, monitor:HDMI-A-1
  #
  #     # make games always open on center monitor
  #     windowrule = match:class steam_app_[0-9]+, monitor DP-3
  #     windowrule = match:class gamescope, monitor DP-3
  #     windowrule = match:class steam_app_[0-9]+, workspace 2
  #   '';

  wayland.windowManager.hyprland.extraConfig = ''
    # Monitor layout:
    #
    #                 [ HDMI-A-1 / Acer XV271U M3 2560x1440 ]
    #
    # [ DP-1 / Samsung ] [ DP-3 / Dell 4K scaled 1.25 ] [ DP-2 / Acer portrait ]

    # UP: Acer XV271U M3, 2560x1440
    # hyprctl currently exposes 143.91Hz on HDMI-A-1, not 180Hz.
    monitor = HDMI-A-1,2560x1440@143.91,2176x0,1

    # LEFT: Samsung C27F390, 1920x1080 @ 60Hz
    monitor = DP-1,1920x1080@60,0x1764,1

    # MIDDLE: Dell S3225QS, 3840x2160 @ 120Hz, scaled
    monitor = DP-3,3840x2160@120,1920x1440,1.25

    # RIGHT: Acer XFA240, 1920x1080 @ 144Hz, portrait
    monitor = DP-2,1920x1080@144,4992x1248,1,transform,1

    workspace = 1, monitor:DP-1
    workspace = 2, monitor:DP-3
    workspace = 3, monitor:DP-2
    workspace = 4, monitor:HDMI-A-1

    # VRR: fullscreen only. Best default for games.
    misc {
      vfr = true
      vrr = 2
    }

    # make games always open on center monitor
    windowrule = match:class steam_app_[0-9]+, monitor DP-3
    windowrule = match:class gamescope, monitor DP-3
    windowrule = match:class steam_app_[0-9]+, workspace 2
  '';

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
