{ config, lib, pkgs, ... }:
let
  cfg = config.my.hyprland;
  isLinux = pkgs.stdenv.isLinux;
in
{
  options.my.hyprland.enable =
    lib.mkEnableOption "Enable Hyprland configuration (Home-Manager)";

  # Optional: make the Hyprland package overridable at the host level
  options.my.hyprland.package = lib.mkOption {
    type = with lib.types; nullOr package;
    default = pkgs.hyprland;  # hosts can mkForce null to use distro Hyprland
    description = "Hyprland package to place on PATH.";
  };

  config = lib.mkIf (isLinux && cfg.enable) {
    wayland.windowManager.hyprland = {
      enable = true;
      package = lib.mkDefault cfg.package;
      systemd.enable = true;
      xwayland.enable = true;

      settings = {
        xwayland = { force_zero_scaling = true; };

        "exec-once" = [
          "waybar"
          "hyprpaper"
          "hypridle"
          # If you keep this, ensure pkgs.clipman is installed somewhere:
          "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
        ];

        env = [
          "XCURSOR_SIZE,32"
          "WLR_NO_HARDWARE_CURSORS,1"
        ];

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = { natural_scroll = true; };
          sensitivity = 0;
        };

        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 1;
          "col.active_border" = "rgba(9742b5ee) rgba(9742b5ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 8;
          blur = { enabled = true; size = 3; passes = 3; };
          active_opacity = 0.9;
          inactive_opacity = 0.5;
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

        misc = {
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
        };

        windowrule = [ ];

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
        };

        "$mainMod" = "SUPER";

        bind = [
          # programs / general
          "$mainMod, Return, exec, kitty"
          "$mainMod, B, exec, firefox"
          "$mainMod, Q, killactive"
          "$mainMod, D, exec, discord"
          "$mainMod, space, exec, wofi --show drun"
          "$mainMod, L, exec, hyprlock"
          "$mainMod SHIFT, S, exec, grim -g \"$(slurp -d)\" - | wl-copy"

          # workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"

          # move active window
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"

          # brightness / mute
          ",XF86MonBrightnessUp, exec, brightnessctl set +10%"
          ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"
          ",XF86AudioMute, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 0%"
        ];

        binde = [
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
          "ALT, mouse:272, resizewindow"
        ];
      };
    };

    # Wayland QoL env (safe here too)
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      GTK_USE_PORTAL = "1";
    };
  };
}

