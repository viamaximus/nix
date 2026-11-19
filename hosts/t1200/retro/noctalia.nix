# Noctalia on the t1200: retro palettes, bare-minimum bar, square everything,
# and user templates so a palette switch in Noctalia's settings recolours the
# terminal side too (tmux, cool-retro-term, kitty, btop, zathura, Helium).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.t1200.retro;
  scheme = cfg.palettes.${cfg.scheme};
  tpl = "${config.xdg.configHome}/noctalia/templates/t1200";
  upstreamTpl = "${inputs.noctalia}/assets/templates";
  pkill = "${pkgs.procps}/bin/pkill";
in {
  # All four palettes, selectable live (Settings -> Theme -> Custom palette).
  programs.noctalia.customPalettes = lib.mapAttrs' (name: p:
    lib.nameValuePair "t1200-${name}" (removeAttrs p ["mode"]))
  cfg.palettes;

  programs.noctalia.settings = {
    theme = {
      custom_palette = lib.mkForce "t1200-${cfg.scheme}";
      mode = lib.mkForce scheme.mode;
      templates = {
        builtin_ids = lib.mkForce ["gtk3" "gtk4" "qt"];
        community_ids = lib.mkForce ["discord" "neovim" "zen-browser"];

        # Hooks use absolute paths: the noctalia service has a minimal PATH.
        user = {
          t1200_tmux = {
            input_path = "${tpl}/tmux.conf";
            output_path = "$XDG_CONFIG_HOME/tmux/noctalia.conf";
            post_hook = "${pkgs.tmux}/bin/tmux source-file -q ${config.xdg.configHome}/tmux/noctalia.conf 2>/dev/null || true";
          };
          t1200_crt = {
            input_path = "${tpl}/crt-colors.json";
            output_path = "$XDG_CACHE_HOME/noctalia/t1200/crt-colors.json";
            post_hook = "${config.t1200.retro.crtApply}/bin/crt-apply && ${config.t1200.retro.crtReload}/bin/crt-reload";
          };
          t1200_kitty = {
            input_path = "${upstreamTpl}/kitty/kitty.conf";
            output_path = "$XDG_CONFIG_HOME/kitty/themes/noctalia.conf";
            post_hook = "${pkill} -USR1 -x kitty || true";
          };
          t1200_btop = {
            input_path = "${upstreamTpl}/btop/btop.theme";
            output_path = "$XDG_CONFIG_HOME/btop/themes/noctalia.theme";
            post_hook = "${pkill} -USR2 -x btop || true";
          };
          t1200_zathura = {
            input_path = "${tpl}/zathurarc";
            output_path = "$XDG_CONFIG_HOME/zathura/noctaliarc";
          };
          # Helium reads /etc/chromium/policies/managed; configuration.nix makes
          # this one file user-writable. Applies on next Helium start.
          t1200_helium = {
            input_path = "${tpl}/helium-policy.json";
            output_path = "/etc/chromium/policies/managed/noctalia-color.json";
          };
        };
      };
    };

    shell = {
      corner_radius_scale = 0;
      font_family = cfg.font;
      animation.enabled = false;
      panel.transparency_mode = "solid";
      circular_avatar = false;
    };

    # time, network, sound, battery, session menu (+ workspaces). Hidden while the workspace
    # has windows; Super+` toggles it (hyprland.nix).
    bar.main = {
      start = lib.mkForce ["workspaces"];
      center = lib.mkForce ["clock"];
      end = lib.mkForce ["network" "volume" "battery" "session"];
      capsule = lib.mkForce false;
      thickness = lib.mkForce 24;
      smart_auto_hide = true;
      reserve_space = false;
      compositor_blur = false;
      background_opacity = 1.0;
    };

    widget.workspaces = {
      show_labels = false;
      style = "focus_hint";
    };

    dock.enabled = false;
    plugins.enabled = lib.mkForce [];

    lockscreen = {
      blurred_desktop = lib.mkForce false;
      transition = ["crt"];
      # one duration for both lock and unlock (no separate unlock setting);
      # default 1500ms felt slow on unlock
      transition_duration = 600;
    };

    # Compact login box: one square password row centred on the usable area,
    # no media / weather / session buttons / eye / login button.
    lockscreen_widgets = {
      schema_version = 2;
      widget_order = ["lockscreen-login-box@DP-4"];
      widget."lockscreen-login-box@DP-4" = {
        type = "login_box";
        output = "DP-4";
        cx = 960.0;
        cy = 360.0;
        box_width = 420.0;
        box_height = 64.0;
        rotation = 0.0;
        placement_width = 1920.0;
        placement_height = 720.0;
        settings = {
          layout = "compact";
          show_session_buttons = false;
          show_media = false;
          show_media_controls = false;
          show_weather = false;
          show_login_button = false;
          show_password_reveal = false;
          show_keyboard_layout = false;
          show_unlock_hint = false; # no "Type your password..."; errors + caps lock still show
          show_caps_lock = true;
          center_password_text = true;
          background_color = "surface";
          background_opacity = 1.0;
          background_radius = 0.0;
          input_opacity = 1.0;
          input_radius = 0.0;
        };
      };
    };

    wallpaper.default.path = lib.mkForce "${config.home.homeDirectory}/Pictures/Wallpapers/t1200-crt.png";
  };

  home.file."Pictures/Wallpapers/t1200-crt.png".source = ./wallpaper.png;

  # Template inputs (rendered by Noctalia with the active palette).
  xdg.configFile = {
    "noctalia/templates/t1200/tmux.conf".text = ''
      set -g status-style "bg={{colors.surface.default.hex}},fg={{colors.on_surface_variant.default.hex}}"
      set -g status-left "#[bg={{colors.primary.default.hex}},fg={{colors.on_primary.default.hex}},bold] #S #[default] "
      set -g status-right "#[fg={{colors.on_surface_variant.default.hex}}]%H:%M "
      set -g window-status-format " #I:#W "
      set -g window-status-current-format "#[fg={{colors.primary.default.hex}},bold,reverse] #I:#W "
      set -g pane-border-style "fg={{colors.outline.default.hex}}"
      set -g pane-active-border-style "fg={{colors.primary.default.hex}}"
      set -g message-style "bg={{colors.primary.default.hex}},fg={{colors.on_primary.default.hex}}"
      set -g mode-style "bg={{colors.primary.default.hex}},fg={{colors.on_primary.default.hex}}"
      set -g clock-mode-colour "{{colors.primary.default.hex}}"
    '';

    "noctalia/templates/t1200/crt-colors.json".text = ''
      {"fontColor": "{{colors.terminal_foreground.default.hex}}", "backgroundColor": "{{colors.terminal_background.default.hex}}"}
    '';

    "noctalia/templates/t1200/zathurarc".text = ''
      set default-bg "{{colors.surface.default.hex}}"
      set default-fg "{{colors.on_surface.default.hex}}"
      set statusbar-bg "{{colors.surface_variant.default.hex}}"
      set statusbar-fg "{{colors.on_surface.default.hex}}"
      set inputbar-bg "{{colors.surface.default.hex}}"
      set inputbar-fg "{{colors.primary.default.hex}}"
      set notification-bg "{{colors.surface.default.hex}}"
      set notification-fg "{{colors.primary.default.hex}}"
      set notification-error-bg "{{colors.surface.default.hex}}"
      set notification-error-fg "{{colors.error.default.hex}}"
      set highlight-color "{{colors.primary.default.hex}}"
      set highlight-active-color "{{colors.tertiary.default.hex}}"
      set completion-bg "{{colors.surface_variant.default.hex}}"
      set completion-fg "{{colors.on_surface.default.hex}}"
      set completion-highlight-bg "{{colors.primary.default.hex}}"
      set completion-highlight-fg "{{colors.on_primary.default.hex}}"
      set recolor-lightcolor "{{colors.surface.default.hex}}"
      set recolor-darkcolor "{{colors.on_surface.default.hex}}"
      set index-bg "{{colors.surface.default.hex}}"
      set index-fg "{{colors.on_surface.default.hex}}"
      set index-active-bg "{{colors.primary.default.hex}}"
      set index-active-fg "{{colors.on_primary.default.hex}}"
    '';

    "noctalia/templates/t1200/helium-policy.json".text = ''
      {"BrowserThemeColor": "{{colors.primary.default.hex}}"}
    '';
  };
}
