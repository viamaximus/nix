{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
  hostName = osConfig.networking.hostName or "";
  hl = import ./lua.nix {inherit lib;};
  inherit (hl) mod bind bindel bindm exec focus move swap;

  panelBrightnessDevice =
    if builtins.elem hostName ["zephyrus" "asus-zephyrus"]
    then "amdgpu_bl2"
    else null;

  brightnessctlCmd =
    if panelBrightnessDevice != null
    then "${pkgs.brightnessctl}/bin/brightnessctl -d ${panelBrightnessDevice}"
    else "${pkgs.brightnessctl}/bin/brightnessctl";

  # When Noctalia is the shell, action keybinds are routed through its IPC
  # (launcher, clipboard, lock, screenshot, control center, OSD, etc.) instead
  # of wofi/hyprlock/swayosd. Window-management and app-launch binds are shared.
  noctalia = config.features.desktop.noctalia.enable;
  ipc = "noctalia msg";

  actionBinds =
    if noctalia
    then [
      (bind "${mod} + space" (exec "${ipc} panel-toggle launcher"))
      (bind "${mod} + V" (exec "${ipc} panel-toggle clipboard"))
      (bind "${mod} + C" (exec "${ipc} panel-toggle control-center"))
      (bind "${mod} + X" (exec "${ipc} panel-toggle session"))
      (bind "${mod} + A" (exec "${ipc} panel-open control-center audio"))
      (bind "${mod} + SHIFT + A" (exec "${ipc} panel-open control-center audio"))
      (bind "${mod} + SHIFT + L" (exec "${ipc} session lock"))
      (bind "${mod} + SHIFT + N" (exec "${ipc} nightlight-toggle"))
      (bind "${mod} + SHIFT + s" (exec "${ipc} screenshot-region"))
      (bind "XF86AudioMute" (exec "${ipc} volume-mute"))
    ]
    else [
      (bind "${mod} + A" (exec "audio-switcher"))
      (bind "${mod} + SHIFT + A" (exec "mic-switcher"))
      (bind "${mod} + space" (exec "wofi --show drun"))
      (bind "${mod} + SHIFT + L" (exec "hyprlock"))
      (bind "${mod} + SHIFT + s" (exec "grim -g \"$(slurp -d)\" - | wl-copy"))
      (bind "XF86AudioMute" (exec "${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle"))
    ];

  bindelBinds =
    if noctalia
    then [
      (bindel "XF86MonBrightnessUp" (exec "${ipc} brightness-up"))
      (bindel "XF86MonBrightnessDown" (exec "${ipc} brightness-down"))
      (bindel "XF86AudioLowerVolume" (exec "${ipc} volume-down"))
      (bindel "XF86AudioRaiseVolume" (exec "${ipc} volume-up"))
    ]
    else [
      (bindel "XF86MonBrightnessUp" (exec "${brightnessctlCmd} set +10%"))
      (bindel "XF86MonBrightnessDown" (exec "${brightnessctlCmd} set 10%-"))
      (bindel "XF86AudioLowerVolume" (exec "${pkgs.swayosd}/bin/swayosd-client --output-volume lower"))
      (bindel "XF86AudioRaiseVolume" (exec "${pkgs.swayosd}/bin/swayosd-client --output-volume raise"))
    ];

  # Blur for Noctalia layer surfaces. Excludes the wallpaper layer so it isn't
  # blurred.
  layerRules = optionals noctalia [
    {
      name = "noctalia-blur";
      match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
      blur = true;
      ignore_alpha = 0.5;
    }
  ];

  stylixCursor = osConfig ? stylix && osConfig.stylix ? cursor && osConfig.stylix.cursor != null;

  noctaliaTheme = config.programs.noctalia.settings.theme or {};
  noctaliaPalette = config.programs.noctalia.customPalettes.${noctaliaTheme.custom_palette or ""}.dark or null;
  rgb = hex: "rgb(${removePrefix "#" hex})";

  workspaces = range 1 9;
in {
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      settings = {
        config = {
          xwayland.force_zero_scaling = true;

          input = {
            kb_layout = "us";
            follow_mouse = 1;
            touchpad.natural_scroll = true;
            sensitivity = 0;
          };

          general = {
            col = mkIf (noctalia && noctaliaPalette != null) {
              active_border = rgb noctaliaPalette.mPrimary;
              inactive_border = rgb noctaliaPalette.mOutline;
            };
            gaps_in = 3;
            gaps_out = 3;
            border_size = 1;
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

          animations.enabled = true;

          dwindle = {
            preserve_split = true;
            smart_split = true;
          };

          misc = {
            disable_splash_rendering = true;
            disable_hyprland_logo = true;
            vrr = mkDefault 0;
          };
        };

        curve = {
          _args = [
            "myBezier"
            {
              type = "bezier";
              points = [[0.05 0.9] [0.1 1.05]];
            }
          ];
        };

        animation = [
          {
            leaf = "windows";
            enabled = true;
            speed = 7;
            bezier = "myBezier";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 7;
            bezier = "default";
            style = "popin 80%";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "borderangle";
            enabled = true;
            speed = 8;
            bezier = "default";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 7;
            bezier = "default";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 6;
            bezier = "default";
          }
        ];

        gesture = {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        };

        env =
          [(hl.env "NIXOS_OZONE_WL" "1")]
          ++ optional (stylixCursor && osConfig.stylix.cursor ? name)
          (hl.env "XCURSOR_THEME" osConfig.stylix.cursor.name)
          ++ optional (stylixCursor && osConfig.stylix.cursor ? size)
          (hl.env "XCURSOR_SIZE" (toString osConfig.stylix.cursor.size));

        on = [
          (hl.onStart (
            optional (!noctalia) "waybar"
            ++ [
              "hyprpaper"
              "hypridle"
              "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
            ]
          ))
        ];

        window_rule = [
          {
            name = "fix-xwayland-drags";
            match = {
              class = "^$";
              title = "^$";
              xwayland = true;
              float = true;
              fullscreen = false;
              pin = false;
            };
            no_focus = true;
          }
          {
            name = "pip";
            match.title = "^(Picture-in-Picture)$";
            float = true;
            pin = true;
            keep_aspect_ratio = true;
          }
          {
            name = "idle-inhibit-fullscreen";
            match.class = ".*";
            idle_inhibit = "fullscreen";
          }
          {
            name = "suppress-maximize-events";
            match.class = ".*";
            suppress_event = "maximize";
          }
          {
            name = "ksa-monitor";
            match.title = "^(Kitten Space Agency)";
            monitor = "DP-3";
            fullscreen = false;
          }
          {
            name = "unity-opaque";
            match.class = "^([Uu]nity.*)$";
            opacity = "1.0 override 1.0 override 1.0 override";
            opaque = true;
          }
        ];

        layer_rule = layerRules;

        bind =
          [
            (bind "${mod} + return" (exec "kitty"))
            (bind "${mod} + B" (exec "zen-beta"))
            (bind "${mod} + E" (exec "nautilus"))
            (bind "${mod} + Q" hl.close)
            (bind "${mod} + D" (exec "vesktop"))
            (bind "${mod} + S" (exec "spot"))
            (bind "${mod} + CTRL + A" (exec "pavucontrol"))

            (bind "${mod} + F" hl.fullscreen)
            (bind "${mod} + V" hl.toggleFloat)
            (bind "${mod} + T" "hl.dsp.layout(\"togglesplit\")")
            (bind "${mod} + mouse_up" (focus {workspace = "e-1";}))
            (bind "${mod} + mouse_down" (focus {workspace = "e+1";}))

            (bind "${mod} + CTRL + h" (swap {direction = "left";}))
            (bind "${mod} + CTRL + h" (move {x = -50; y = 0; relative = true;}))
            (bind "${mod} + CTRL + l" (swap {direction = "right";}))
            (bind "${mod} + CTRL + l" (move {x = 50; y = 0; relative = true;}))
            (bind "${mod} + CTRL + k" (swap {direction = "up";}))
            (bind "${mod} + CTRL + k" (move {x = 0; y = -50; relative = true;}))
            (bind "${mod} + CTRL + j" (swap {direction = "down";}))
            (bind "${mod} + CTRL + j" (move {x = 0; y = 50; relative = true;}))

            (bind "${mod} + h" (focus {direction = "left";}))
            (bind "${mod} + j" (focus {direction = "down";}))
            (bind "${mod} + k" (focus {direction = "up";}))
            (bind "${mod} + l" (focus {direction = "right";}))

            (bind "XF86LaunchA" (exec "brightnessctl --device='kbd_backlight' set 5%-"))
            (bind "XF86Search" (exec "brightnessctl --device='kbd_backlight' set 5%+"))
          ]
          ++ map (i: bind "${mod} + ${toString i}" (focus {workspace = i;})) workspaces
          ++ map (i: bind "${mod} + SHIFT + ${toString i}" (move {workspace = i;})) workspaces
          ++ actionBinds
          ++ bindelBinds
          ++ [
            (bindm "${mod} + mouse:272" hl.drag)
            (bindm "${mod} + mouse:273" hl.resize)
            (bindm "ALT + mouse:272" hl.resize)
          ];
      };
    };
  };
}
