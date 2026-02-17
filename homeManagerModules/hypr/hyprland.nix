{
  config,
  lib,
  osConfig,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
in {
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        xwayland = {
          force_zero_scaling = true;
        };

        monitor = [];

        exec-once = [
          "waybar"
          "hyprpaper"
          "hypridle"
          "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
        ];
        env =
          [
            "WLR_NO_HARDWARE_CURSORS,1"
          ]
          ++ lib.optionals (osConfig ? stylix && osConfig.stylix ? cursor && osConfig.stylix.cursor != null && osConfig.stylix.cursor ? name) [
            "XCURSOR_THEME,${osConfig.stylix.cursor.name}"
          ]
          ++ lib.optionals (osConfig ? stylix && osConfig.stylix ? cursor && osConfig.stylix.cursor != null && osConfig.stylix.cursor ? size) [
            "XCURSOR_SIZE,${toString osConfig.stylix.cursor.size}"
          ];

        input = {
          kb_layout = "us";
          follow_mouse = 1;

          touchpad = {
            natural_scroll = true;
          };
          sensitivity = 0;
        };

        general = {
          gaps_in = 3;
          gaps_out = 3;
          border_size = 1;
          # "col.active_border" = "rgba(9742b5ee) rgba(9742b5ee) 45deg";
          # "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
          };
          active_opacity = 0.99;
          inactive_opacity = 0.85;
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {};

        misc = {
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
          vrr = 0;
        };

        windowrule = [];

        gestures = {
          # enabled = true;
          gesture = "3, horizontal, workspace";
        };

        "$mainMod" = "SUPER";
        bind = [
          #programs, general stuffs
          "$mainMod, return, exec, kitty"
          "$mainMod, B, exec, zen"
          "$mainMod, E, exec, nautilus"
          "$mainMod, Q, killactive"
          "$mainMod, D, exec, sh -c 'if [ \"$(uname -m)\" = \"x86_64\" ]; then discord; else vesktop; fi'"
          "$mainMod, S, exec, spot"
          "$mainMod, space, exec, wofi --show drun"
          "$mainMod SHIFT, L, exec, hyprlock"
          "$mainMod SHIFT, s, exec, grim -g \"$(slurp -d)\" - | wl-copy"

          "bind = $mainMod, F, fullscreen"
          "bind = $mainMod, V, togglefloating"
          "bind = $mainMod, mouse_up, workspace, e-1"
          "bind = $mainMod, mouse_down, workspace, e+1"

          "bind = $mainMod CTRL, h, swapwindow, l"
          "bind = $mainMod CTRL, h, moveactive, -50 0"
          "bind = $mainMod CTRL, l, swapwindow, r"
          "bind = $mainMod CTRL, l, moveactive, 50 0"
          "bind = $mainMod CTRL, k, swapwindow, u"
          "bind = $mainMod CTRL, k, moveactive, 0 -50"
          "bind = $mainMod CTRL, j, swapwindow, d"
          "bind = $mainMod CTRL, j, moveactive, 0 50"

          "bind = $mainMod, h, movefocus, l" #move focus left
          "bind = $mainMod, j, movefocus, d" #move focus down
          "bind = $mainMod, k, movefocus, u" #move focus up
          "bind = $mainMod, l, movefocus, r" #move focus right

          #move to workspace with mainMod + #
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          #move active window to workspace
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"

          ",XF86MonBrightnessUp, exec, brightnessctl set +10%"
          ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"
          ",XF86LaunchA, exec, brightnessctl --device='kbd_backlight' set 5%-"
          ",XF86Search, exec, brightnessctl --device='kbd_backlight' set 5%+"
          ",XF86AudioMute, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 0%"
        ];

        binde = [
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
          "ALT, mouse:272, resizeWindow"
        ];
      };
    };
  };
}
