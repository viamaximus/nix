{ config, lib, ...}:

with lib; let
  cfg = config.features.desktop.hyprland;
in {
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";
  config = {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        xwayland = {
	  force_zero_scaling = true;
	};

	exec-once = [
	  "waybar"
	  "hyprpaper"
	  "hypridle"
	  "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
	];
	env = [
	  "XCURSOR_SIZE,32"
	  "WLR_NO_HARDWARE_CURSORS,1"
	];
	
	input = {
	  kb_layout = "us";
	  follow_mouse = 1;

	  touchpad = {
	    natural_scroll = false;
	  };
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
	  blur = {
	    enabled = true;
	    size = 3;
	    passes = 3;
	  };
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

	master = {};

	misc = {
	  disable_splash_rendering = true;
          disable_hyprland_logo = true;
	};

	windowrule = [];

	gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
        };

	"$mainMod" = "SUPER";
	bind = [
	  #programs, general stuffs
	  "$mainMod, return, exec, kitty"
	  "$mainMod, B, exec, firefox"
	  "$mainMod, Q, killactive"
	  "$mainMod, D, exec, discord"
	  "$mainMod, space, exec, wofi --show drun"
	  "$mainMod, L, exec, hyprlock"
	  "$mainMod SHIFT, s, exec, grim -g \"$(slurp -d)\" - | wl-copy"
	  
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
	  #move active window to workspace with mainMod + shift + #

          ",XF86MonBrightnessUp, exec, brightnessctl set +10%"
          ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"
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
