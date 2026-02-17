{
  config,
  pkgs,
  lib,
  chicago95-src ? null,
  ...
}: let
  cfg = config.features.desktop.xfce;
  c95 = chicago95-src;
in {
  options.features.desktop.xfce.enable = lib.mkEnableOption "xfce config with Chicago95 theme";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Chicago95 theme (GTK, icons, cursors, sounds)
      chicago95

      # Dependencies
      gtk-engine-murrine # GTK2 pixbuf engine
      xfce4-panel-profiles

      # Core XFCE extras
      xfce4-whiskermenu-plugin
      xfce4-pulseaudio-plugin
      xfce4-notifyd
      xfce4-clipman-plugin
      thunar-volman

      # Utilities
      brightnessctl
      grim
      slurp
      wl-clipboard
      libnotify
      playerctl
    ];

    # GTK theming
    gtk = {
      enable = true;
      theme = {
        name = lib.mkForce "Chicago95";
        package = lib.mkForce pkgs.chicago95;
      };
      iconTheme = {
        name = lib.mkForce "Chicago95";
        package = lib.mkForce pkgs.chicago95;
      };
      cursorTheme = {
        name = lib.mkForce "Chicago95 Standard Cursors";
        package = lib.mkForce pkgs.chicago95;
      };
      font = {
        name = lib.mkForce "Sans";
        size = lib.mkForce 8;
      };
    };

    # Register fonts from home.packages with fontconfig
    fonts.fontconfig.enable = true;

    # Fontconfig — MS Sans Serif aliasing and hinting
    xdg.configFile."fontconfig/conf.d/99-ms-sans-serif.conf".source =
      "${c95}/Extras/99-ms-sans-serif.conf";
    xdg.configFile."fontconfig/conf.d/99-ms-sans-serif-bold.conf".source =
      "${c95}/Extras/99-ms-sans-serif-bold.conf";


    # Apply Chicago95 xfconf settings during activation.
    # Uses xfconf-query which works when a dbus session is running (i.e. logged in).
    # On first boot/fresh login, XFCE creates defaults — this overrides them on next rebuild.
    home.activation.applyChicago95Xfconf = lib.hm.dag.entryAfter ["writeBoundary"] ''
      _xfset() {
        # Reset then create with correct type — handles both existing and new properties
        xfconf-query -c "$1" -p "$2" --reset 2>/dev/null || true
        xfconf-query -c "$1" -p "$2" -n -t "$3" -s "$4" || true
      }
      _apply_xfconf() {
        if ! command -v xfconf-query &>/dev/null; then
          return
        fi

        # Ensure we can reach the user's dbus session (needed when run via sudo nixos-rebuild)
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
        if ! dbus-send --session --dest=org.freedesktop.DBus --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames &>/dev/null; then
          return
        fi

        # xsettings (appearance)
        _xfset xsettings /Net/ThemeName string "Chicago95"
        _xfset xsettings /Net/IconThemeName string "Chicago95"
        _xfset xsettings /Net/SoundThemeName string "Chicago95"
        _xfset xsettings /Gtk/CursorThemeName string "Chicago95 Standard Cursors"
        _xfset xsettings /Gtk/FontName string "Sans 8"
        _xfset xsettings /Gtk/DialogsUseHeader bool false

        # Font rendering — crisp text at 2x scaling
        _xfset xsettings /Xft/Antialias int 1
        _xfset xsettings /Xft/Hinting int 1
        _xfset xsettings /Xft/HintStyle string "hintfull"
        _xfset xsettings /Xft/RGBA string "rgb"
        _xfset xsettings /Xft/DPI int 192

        # xfwm4 (window manager)
        _xfset xfwm4 /general/theme string "Chicago95"
        _xfset xfwm4 /general/title_font string "Sans Bold 8"
        _xfset xfwm4 /general/show_dock_shadow bool false
        _xfset xfwm4 /general/show_popup_shadow bool false
        _xfset xfwm4 /general/show_frame_shadow bool false

        # notifications
        _xfset xfce4-notifyd /theme string "Chicago95"

        # desktop — teal background (#008080), no wallpaper image
        _xfset xfce4-desktop /desktop-icons/icon-size int 48

        # panel — size 32, bottom, full width
        _xfset xfce4-panel /panels/panel-1/size int 32
        _xfset xfce4-panel /panels/panel-1/icon-size int 16
        _xfset xfce4-panel /panels/panel-1/length int 100

        # Replace applicationsmenu (plugin-1) with whiskermenu
        _xfset xfce4-panel /plugins/plugin-1 string "whiskermenu"

        # Whisker Menu settings (2.x uses xfconf, not rc files)
        _xfset xfce4-panel /plugins/plugin-1/button-title string "Start"
        _xfset xfce4-panel /plugins/plugin-1/button-icon string "${c95}/Theme/Chicago95/misc/windows_32x32px.png"
        _xfset xfce4-panel /plugins/plugin-1/show-button-title bool true
        _xfset xfce4-panel /plugins/plugin-1/show-button-icon bool true
        _xfset xfce4-panel /plugins/plugin-1/launcher-show-name bool true
        _xfset xfce4-panel /plugins/plugin-1/launcher-show-description bool false
        _xfset xfce4-panel /plugins/plugin-1/category-icon-size int 0
        _xfset xfce4-panel /plugins/plugin-1/item-icon-size int 1
        _xfset xfce4-panel /plugins/plugin-1/view-mode int 2
        _xfset xfce4-panel /plugins/plugin-1/menu-width int 416
        _xfset xfce4-panel /plugins/plugin-1/menu-height int 383
        _xfset xfce4-panel /plugins/plugin-1/menu-opacity int 100

        # Panel position — bottom of screen
        _xfset xfce4-panel /panels/panel-1/position string "p=10;x=0;y=0"
        _xfset xfce4-panel /panels/panel-1/position-locked bool true

        # Remove panel-2 (dock) — single taskbar only
        xfconf-query -c xfce4-panel -p /panels/panel-2 -r -R 2>/dev/null || true
        xfconf-query -c xfce4-panel -p /panels -s 1 --force-array -t int 2>/dev/null \
          || xfconf-query -c xfce4-panel -p /panels --reset 2>/dev/null || true
        xfconf-query -c xfce4-panel -p /panels -n -t int -s 1 --force-array 2>/dev/null || true

        # Desktop background — teal (#008080), no wallpaper
        if command -v xrandr &>/dev/null; then
          for mon in $(xrandr --listmonitors 2>/dev/null | awk 'NR>1 {print $NF}'); do
            local base="/backdrop/screen0/monitor''${mon}/workspace0"
            _xfset xfce4-desktop "''${base}/color-style" int 0
            _xfset xfce4-desktop "''${base}/image-style" int 0
            xfconf-query -c xfce4-desktop -p "''${base}/rgba1" --reset 2>/dev/null || true
            xfconf-query -c xfce4-desktop -p "''${base}/rgba1" -n \
              -t double -s 0.0 -t double -s 0.502 -t double -s 0.502 -t double -s 1.0 || true
          done
        fi

        # Restart panel to pick up changes
        xfce4-panel -r &>/dev/null &
      }
      _apply_xfconf
    '';

    # Separate activation for file copies (not dependent on xfconf/dbus)
    home.activation.applyChicago95Files = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.config/xfce4/terminal"
      install -m 644 "${c95}/Extras/terminalrc" "$HOME/.config/xfce4/terminal/terminalrc" || true
    '';

    # QT apps should use GTK2 theming
    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = lib.mkForce "gtk2";
    };
  };
}
