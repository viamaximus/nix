# homeManagerModules/programs/hyprland.nix
{ config, lib, pkgs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  cfg = config.my.hyprland;  # shared toggle; set per host
in
{
  options.my.hyprland.enable = lib.mkEnableOption "Enable Hyprland (user config)";

  config = lib.mkIf (cfg.enable && isLinux) {
    # Hyprland user config
    wayland.windowManager.hyprland = {
      enable = true;
      package = lib.mkDefault pkgs.hyprland;
      systemd.enable = true;
      xwayland.enable = true;

      # Small, sane defaults – replace with your own later
      settings = {
        "$mod" = "SUPER";

        monitor = [ " ,preferred,auto,1" ];
        input = { kb_layout = "us"; };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          allow_tearing = false;
        };

        decoration = {
          rounding = 8;
          blur = { enabled = true; size = 6; passes = 2; };
        };

        animations = { enabled = true; };

        # Example binds
        bind = [
          "$mod, Return, exec, kitty"
          "$mod, Q, killactive,"
          "$mod, E, exec, thunar"
          "$mod, D, exec, wofi --show drun"
          "$mod SHIFT, E, exit,"
          "$mod, L, exec, hyprlock"
          "$mod, P, exec, grim -g \"$(slurp)\" - | swappy -f -"
        ];
      };

      # Add extra raw config as you migrate old confs
      extraConfig = ''
        # put any quick tweaks here while migrating
      '';
    };

    # Panel, launcher, notifications, lock/sleep, wallpapers, utils
    programs.waybar.enable = true;
    programs.kitty.enable = true;
    programs.wofi.enable = true;
    services.mako.enable = true;

    home.packages = with pkgs; [
      hyprpaper hypridle hyprlock
      wl-clipboard cliphist
      grim slurp swappy
      brightnessctl pavucontrol
      nwg-look
    ];

    # Example: hypridle snippet (feel free to expand)
    xdg.configFile."hypr/hypridle.conf".text = ''
      general {
        lock_cmd = hyprlock
        before_sleep_cmd = hyprlock
        after_sleep_cmd = hyprctl dispatch dpms on
      }
      listener {
        timeout = 600
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }
    '';
  };
}

