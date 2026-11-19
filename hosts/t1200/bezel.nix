{
  lib,
  pkgs,
  ...
}: let
  hl = import ../../homeManagerModules/hypr/lua.nix {inherit lib;};
  output = "DP-4";
  width = 60;

  python = pkgs.python3.withPackages (ps: [ps.pygobject3]);

  bezelMask = pkgs.writeShellScriptBin "bezel-mask" ''
    export GI_TYPELIB_PATH=${lib.makeSearchPath "lib/girepository-1.0" (map (p: p.out) [
      pkgs.gtk3
      pkgs.gtk-layer-shell
      pkgs.glib
      pkgs.gobject-introspection
      pkgs.pango
      pkgs.gdk-pixbuf
      pkgs.harfbuzz
      pkgs.atk
    ])}
    exec ${python}/bin/python3 ${pkgs.writeText "bezel-mask.py" ''
      import gi
      gi.require_version("Gtk", "3.0")
      gi.require_version("GtkLayerShell", "0.1")
      from gi.repository import Gtk, Gdk, GtkLayerShell

      css = Gtk.CssProvider()
      css.load_from_data(b"window { background-color: #000000; }")
      Gtk.StyleContext.add_provider_for_screen(
          Gdk.Screen.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
      )

      for edge in (GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT):
          win = Gtk.Window()
          GtkLayerShell.init_for_window(win)
          GtkLayerShell.set_namespace(win, "bezel-mask")
          GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)
          GtkLayerShell.set_exclusive_zone(win, -1)
          GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.NONE)
          for a in (edge, GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM):
              GtkLayerShell.set_anchor(win, a, True)
          win.set_size_request(${toString width}, -1)
          win.show_all()

      Gtk.main()
    ''}
  '';
in {
  home.packages = [bezelMask];

  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        inherit output;
        mode = "preferred";
        position = "auto";
        scale = "1";
        reserved = {
          top = 0;
          right = width;
          bottom = 0;
          left = width;
        };
      }
    ];
    on = [(hl.onStart ["bezel-mask"])];
    workspace_rule = [
      {
        workspace = "f[1]";
        gaps_in = 0;
        gaps_out = 0;
      }
    ];
    window_rule = [
      {
        name = "bezel-fullscreen-no-border";
        match.fullscreen_state_internal = 1;
        border_size = 0;
        rounding = 0;
      }
    ];
  };

  # Super+F (maximize while telling the client it's fullscreen, so windows stay
  # inside the bezel) now lives with the rest of the keymap in retro/hyprland.nix.
}
