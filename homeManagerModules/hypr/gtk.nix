{ config, lib, pkgs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
in
{
  # Only apply on Linux and when Hyprland is enabled (adjust if you want it always-on)
  config = lib.mkIf (isLinux && config.my.hyprland.enable) {
    gtk = {
      enable = true;

      cursorTheme = {
        name = "Catppuccin-Macchiato-Light";         # adjust if GTK can’t find it
        package = pkgs.catppuccin-cursors.macchiatoLight;
      };

      theme = {
        # If GTK can’t find this, try ...Blue-Dark (uppercase D)
        name = "Catppuccin-Macchiato-Compact-Blue-dark";
        package = pkgs.catppuccin-gtk.override {
          size = "compact";
          accents = [ "blue" ];
          variant = "macchiato";
        };
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      # HM writes [Settings] for you; supply key/values
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };
}

