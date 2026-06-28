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
  features.desktop.noctalia.enable = true;

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
  wayland.windowManager.hyprland.extraConfig = ''
    # Japanese IME (fcitx5 + mozc); toggle with Ctrl+Space.
    exec-once = fcitx5 -d -r

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
      vrr = 2
    }
    debug {
      vfr = true
    }

    # make games always open on center monitor
    windowrule = match:class steam_app_[0-9]+, monitor DP-3
    windowrule = match:class gamescope, monitor DP-3
    windowrule = match:class steam_app_[0-9]+, workspace 2
  '';

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
