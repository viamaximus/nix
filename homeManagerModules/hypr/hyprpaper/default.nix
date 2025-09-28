{ config, lib, pkgs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  wp = ./plasmawaves.png;
in
{
  config = lib.mkIf (isLinux && config.my.hyprland.enable) {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";      # enable IPC (hyprctl hyprpaper …)
        splash = false;  # hide the random splash text
        preload = [ "${wp}" ];
        wallpaper = [ ", ${wp}" ];  # apply to all monitors without an explicit rule
      };
    };
  };
}

