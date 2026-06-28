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
      "$mainMod, space, exec, ${ipc} panel-toggle launcher"
      "$mainMod, V, exec, ${ipc} panel-toggle clipboard"
      "$mainMod, C, exec, ${ipc} panel-toggle control-center"
      "$mainMod, X, exec, ${ipc} panel-toggle session"
      "$mainMod, A, exec, ${ipc} panel-open control-center audio"
      "$mainMod SHIFT, A, exec, ${ipc} panel-open control-center audio"
      "$mainMod SHIFT, L, exec, ${ipc} session lock"
      "$mainMod SHIFT, N, exec, ${ipc} nightlight-toggle"
      "$mainMod SHIFT, s, exec, ${ipc} screenshot-region"
      ",XF86AudioMute, exec, ${ipc} volume-mute"
    ]
    else [
      "$mainMod, A, exec, audio-switcher"
      "$mainMod SHIFT, A, exec, mic-switcher"
      "$mainMod, space, exec, wofi --show drun"
      "$mainMod SHIFT, L, exec, hyprlock"
      "$mainMod SHIFT, s, exec, grim -g \"$(slurp -d)\" - | wl-copy"
      ",XF86AudioMute, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle"
    ];

  bindelBinds =
    if noctalia
    then [
      ",XF86MonBrightnessUp, exec, ${ipc} brightness-up"
      ",XF86MonBrightnessDown, exec, ${ipc} brightness-down"
      ",XF86AudioLowerVolume, exec, ${ipc} volume-down"
      ",XF86AudioRaiseVolume, exec, ${ipc} volume-up"
    ]
    else [
      ",XF86MonBrightnessUp, exec, ${brightnessctlCmd} set +10%"
      ",XF86MonBrightnessDown, exec, ${brightnessctlCmd} set 10%-"
      ",XF86AudioLowerVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume lower"
      ",XF86AudioRaiseVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume raise"
    ];

  # Blur for Noctalia layer surfaces (Hyprland-specific wiring). Hyprland 0.52+
  # rule syntax: `RULE value, ..., match:namespace <regex>`. Excludes the
  # wallpaper layer so it isn't blurred.
  layerRules = optionals noctalia [
    "blur on, ignore_alpha 0.5, match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$"
  ];
in {
  options.features.desktop.hyprland.enable = mkEnableOption "hyprland config";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      # NOTE: home-manager's default flips to "lua" at stateVersion 26.05.
      # The lua schema is NOT compatible with the hyprlang `settings` below
      # (different option names, dispatchers, monitor format), so pin hyprlang
      # explicitly until a deliberate migration is done.
      configType = "hyprlang";
      settings = {
        xwayland = {
          force_zero_scaling = true;
        };

        monitor = [];

        exec-once =
          lib.optional (!config.features.desktop.noctalia.enable) "waybar"
          ++ [
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
          kb_layout = "us,jp";
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
          preserve_split = true;
        };

        master = {};

        misc = {
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
          vrr = 0;
        };

        windowrule = [
          "monitor DP-3, match:title ^(Kitten Space Agency)"
          "fullscreen 0, match:title ^(Kitten Space Agency)"
        ];

        layerrule = layerRules;

        gestures = {
          gesture = "3, horizontal, workspace";
        };

        "$mainMod" = "SUPER";

        bind = [
          "$mainMod, return, exec, kitty"
          "$mainMod, B, exec, zen-beta"
          "$mainMod, E, exec, nautilus"
          "$mainMod, Q, killactive"
          "$mainMod, D, exec, vesktop"
          "$mainMod, S, exec, spot"
          "$mainMod CTRL, A, exec, pavucontrol"

          "$mainMod, F, fullscreen"
          "$mainMod, V, togglefloating"
          "$mainMod, mouse_up, workspace, e-1"
          "$mainMod, mouse_down, workspace, e+1"

          "$mainMod CTRL, h, swapwindow, l"
          "$mainMod CTRL, h, moveactive, -50 0"
          "$mainMod CTRL, l, swapwindow, r"
          "$mainMod CTRL, l, moveactive, 50 0"
          "$mainMod CTRL, k, swapwindow, u"
          "$mainMod CTRL, k, moveactive, 0 -50"
          "$mainMod CTRL, j, swapwindow, d"
          "$mainMod CTRL, j, moveactive, 0 50"

          "$mainMod, h, movefocus, l"
          "$mainMod, j, movefocus, d"
          "$mainMod, k, movefocus, u"
          "$mainMod, l, movefocus, r"

          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"

          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"

          ",XF86LaunchA, exec, brightnessctl --device='kbd_backlight' set 5%-"
          ",XF86Search, exec, brightnessctl --device='kbd_backlight' set 5%+"
        ]
        ++ actionBinds;

        bindel = bindelBinds;

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
          "ALT, mouse:272, resizeWindow"
        ];
      };
    };
  };
}
