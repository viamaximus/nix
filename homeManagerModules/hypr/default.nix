{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.features.desktop.hyprland;
in {
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper
    ./waybar
    ./wofi.nix
    ./gtk.nix
    ./mako.nix
    ./clipboard.nix
    ./nightlight.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
      hyprcursor
      hyprlock
      hypridle
      kitty
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
    ];
  };
}
