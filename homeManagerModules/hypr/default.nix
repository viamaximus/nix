{ config, pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  cfg = config.my.hyprland;
in
{
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper
    ./waybar
    ./gtk.nix
  ];

  # Only add Wayland/Hyprland user packages on Linux AND when Hyprland is enabled
  config = lib.mkIf (isLinux && cfg.enable) {
    home.packages = with pkgs; [
      # core hypr companions
      hyprpaper
      hyprcursor
      hyprlock
      hypridle

      # terminal is conditional: kitty by default, foot on mac-asahi
      cfg.terminalPkg

      # utilities / deps your config uses
      libnotify
      mako
      qt5.qtwayland
      qt6.qtwayland
      swayidle
      swaylock-effects
      wlogout
      wl-clipboard
      wofi
      waybar
      brightnessctl
      grim
      slurp

      # used by Waybar actions and clipboard watcher
      pamixer
      clipman
    ];
  };
}

