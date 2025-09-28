{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (pkgs.stdenv.isLinux && config.my.hyprland.enable) {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
	  before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };
        listener = [
          { timeout = 900;  on-timeout = "hyprlock"; }
          { timeout = 1200; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
        ];
      };
    };
  };
}

