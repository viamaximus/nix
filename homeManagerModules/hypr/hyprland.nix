{ config, lib, pkgs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  exe = lib.getExe;
  cfg = config.my.hyprland;
in
{
  options.my.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland configuration (Home-Manager)";

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      default = pkgs.hyprland;
      description = "Hyprland package placed on PATH; set to null if using distro Hyprland.";
    };

    terminalPkg = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kitty;  # default everywhere; host can override to pkgs.foot
      description = "Terminal package used by binds and exec-once.";
    };
  };

  config = lib.mkIf (isLinux && cfg.enable) {
    wayland.windowManager.hyprland = {
      enable = true;
      package = lib.mkDefault cfg.package;
      systemd.enable = true;
      xwayland.enable = true;

      settings = {
        input = {
          kb_layout  = "us";
          touchpad = { natural_scroll = true; };
        };

        # helpful env
        env = [
          "XCURSOR_SIZE,32"
          "WLR_NO_HARDWARE_CURSORS,1"
        ];
        
	gestures = {
	  workspace_swipe = true;
	  workspace_swipe_fingers = 3;
	};

        "$mainMod" = "SUPER";

        # Keybinds (terminal comes from cfg.terminalPkg)
        bind = [
          "$mainMod, Return, exec, ${exe cfg.terminalPkg}"
          "$mainMod, Enter,  exec, ${exe cfg.terminalPkg}"

          "$mainMod, B, exec, firefox"
          "$mainMod, Q, killactive"
          "$mainMod, space, exec, wofi --show drun"
          "$mainMod, L, exec, ${exe pkgs.hyprlock}"

          # Screenshot selection → clipboard
          "$mainMod SHIFT, S, exec, ${exe pkgs.grim} -g \"$(${exe pkgs.slurp} -d)\" - | ${exe pkgs.wl-clipboard}"

          # Brightness / volume
          ",XF86MonBrightnessUp,   exec, ${exe pkgs.brightnessctl} set +10%"
          ",XF86MonBrightnessDown, exec, ${exe pkgs.brightnessctl} set 10%-"
          ",XF86AudioMute,         exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 0%"
        ];

        binde = [
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
          "ALT,     mouse:272, resizewindow"
        ];

        # Example visuals (keep yours as you had them)
        xwayland.force_zero_scaling = true;

        general = {
          gaps_in = 5;
          gaps_out = 5;
          border_size = 1;
          "col.active_border"   = "rgba(9742b5ee) rgba(9742b5ee) 45deg";
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

        dwindle = { pseudotile = true; preserve_split = true; };

        misc = {
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
        };
      };

      # Autostart (terminal chosen per host via cfg.terminalPkg)
      extraConfig = ''
        exec-once = ${pkgs.bash}/bin/bash -lc '${pkgs.coreutils}/bin/sleep 0.4; ${exe cfg.terminalPkg}'
        exec-once = ${exe pkgs.waybar}
        exec-once = ${exe pkgs.hyprpaper}
        exec-once = ${exe pkgs.hypridle}
        exec-once = ${exe pkgs.wl-clipboard} -p -t text --watch ${exe pkgs.clipman} store -P --histpath="${config.xdg.dataHome}/clipman-primary.json"
      '';
    };

    # Wayland QoL env
    home.sessionVariables = {
      NIXOS_OZONE_WL   = "1";
      MOZ_ENABLE_WAYLAND = "1";
      GTK_USE_PORTAL   = "1";
    };
  };
}

