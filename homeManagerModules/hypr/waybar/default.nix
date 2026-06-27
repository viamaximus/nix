{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./powermenu.nix
  ];

  options.features.desktop.hyprland.waybarHeight = lib.mkOption {
    type = lib.types.int;
    default = 20;
    description = "Waybar height in pixels (set to 64 on MacBooks to clear the notch)";
  };

  config = lib.mkIf config.features.desktop.hyprland.enable {
    programs.waybar = {
      enable = true;
      style = builtins.readFile ./style.css;
      settings = [
        {
          layer = "top";
          position = "top";
          mod = "dock";
          exclusive = true;
          passtrough = false;
          gtk-layer-shell = true;
          height = config.features.desktop.hyprland.waybarHeight;

          modules-left = [
            "hyprland/workspaces"
            "custom/divider"
            "hyprland/window"
          ];

          modules-center = [];

          modules-right = [
            "tray"
            "custom/divider"
            "custom/spotify"
            "custom/divider"
            "custom/weather"
            "custom/divider"
            "network"
            "custom/divider"
            "pulseaudio"
            "custom/divider"
            "battery"
            "custom/divider"
            "clock"
            "custom/divider"
            "custom/powermenu"
          ];

          "hyprland/window" = {
            format = "{}";
          };

          "wlr/workspaces" = {
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
            all-outputs = true;
            on-click = "activate";
          };

          cpu = {
            interval = 10;
            format = "󰻠  {}%";
            max-length = 10;
            on-click = "";
          };

          memory = {
            interval = 30;
            format = "   {}%";
            format-alt = " {used:0.1f}G";
            max-length = 10;
          };

          backlight = {
            format = "󰖨 {}";
            device = "acpi_video0";
          };

          tray = {
            icon-size = 13;
            tooltip = false;
            spacing = 10;
          };

          network = {
            format = "󰖩 {essid}";
            format-disconnected = "󰖪 disconnected";
          };

          clock = {
            format = " {:%I:%M %p   %m/%d} ";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };

          pulseaudio = {
            format = "{icon}  {volume}%";
            tooltip = false;
            format-muted = " Muted";
            on-click = "${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle";
            on-click-right = "pavucontrol";
            on-click-middle = "audio-switcher";
            on-scroll-up = "${pkgs.swayosd}/bin/swayosd-client --output-volume raise";
            on-scroll-down = "${pkgs.swayosd}/bin/swayosd-client --output-volume lower";
            scroll-step = 5;
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
          };

          "pulseaudio#microphone" = {
            format = "{format_source}";
            tooltip = false;
            format-source = " {volume}%";
            format-source-muted = " Muted";
            on-click = "${pkgs.swayosd}/bin/swayosd-client --input-volume mute-toggle";
            on-click-right = "pavucontrol";
            on-click-middle = "mic-switcher";
            on-scroll-up = "${pkgs.swayosd}/bin/swayosd-client --input-volume raise";
            on-scroll-down = "${pkgs.swayosd}/bin/swayosd-client --input-volume lower";
            scroll-step = 5;
          };

          battery = {
            states = {
              warning = 15;
              critical = 5;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󰂄 {capacity}%";
            format-icons = ["󰂎" "󰁺" "󰁼" "󰁾" "󰂀" "󰁹"];
            tooltip = false;
          };

          "custom/divider" = {
            format = " | ";
            interval = "once";
            tooltip = false;
          };

          "custom/endright" = {
            format = "_";
            interval = "once";
            tooltip = false;
          };

          "custom/spotify" = {
            format = "  {}";
            max-length = 40;
            interval = 2;
            return-type = "text";
            exec = "sh -c '${pkgs.playerctl}/bin/playerctl metadata --format \"{{ artist }} - {{ title }}\" 2>/dev/null || true'";
            exec-if = "sh -c '${pkgs.playerctl}/bin/playerctl -l >/dev/null 2>&1'";
            on-click = "${pkgs.playerctl}/bin/playerctl play-pause 2>/dev/null || true";
            on-scroll-up = "${pkgs.playerctl}/bin/playerctl next 2>/dev/null || true";
            on-scroll-down = "${pkgs.playerctl}/bin/playerctl previous 2>/dev/null || true";
          };

          "custom/weather" = {
            format = "{}";
            interval = 1800;
            exec = "${pkgs.curl}/bin/curl -s 'wttr.in/?format=%c+%t'";
            on-click = "${pkgs.kitty}/bin/kitty --hold ${pkgs.curl}/bin/curl wttr.in";
          };

          "custom/powermenu" = {
            format = "⏻";
            tooltip = true;
            tooltip-format = "Power menu";
            on-click = "powermenu";
          };
        }
      ];
    };
  };
}
