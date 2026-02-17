{ config, pkgs, lib, ... }:

let
  powermenu = pkgs.writeShellScriptBin "powermenu" ''
    #!/usr/bin/env bash

    choice=$(
      printf "Lock\nSleep\nReboot\nShutdown" | wofi \
        --dmenu \
        --location top_right \
        --width 220 \
        --height 160 \
        --xoffset 10 \
        --yoffset 10 \
        --hide-search \
        --allow-click-outside \
        --dismiss-on-unfocus \
        --prompt ""
    )

    if [ -z "$choice" ]; then
      exit 0
    fi

    case "$choice" in
      "Lock")
        if command -v hyprlock >/dev/null 2>&1; then
          hyprlock
        else
          loginctl lock-session
        fi
        ;;
      "Sleep")
        systemctl suspend
        ;;
      "Reboot")
        systemctl reboot
        ;;
      "Shutdown")
        systemctl poweroff
        ;;
      *)
        exit 0
        ;;
    esac
  '';
in {
  config = lib.mkIf config.features.desktop.hyprland.enable {
    home.packages = [
      powermenu
    ];
  };
}

