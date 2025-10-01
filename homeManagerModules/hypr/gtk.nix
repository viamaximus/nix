{ config, pkgs, lib, ... }:
let
  # Your requested cursor
  cursorPkg  = pkgs.catppuccin-cursors.macchiatoLight;
  cursorName = "Catppuccin-Macchiato-Light";   # If it doesn't apply, see note below
  cursorSize = 24;
in
{
  # Ensure the theme is present in your profile
  home.packages = [ cursorPkg ];

  gtk = {
    enable = true;
    cursorTheme = {
      package = cursorPkg;
      name    = cursorName;
      size    = cursorSize;
    };
  };

  # Writes ~/.icons/default and GTK settings (Wayland toolkits read these too)
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package    = cursorPkg;
    name       = cursorName;
    size       = cursorSize;
  };

  # For DMs that don't pass user env to the Hyprland session:
  # set env *inside* Hyprland and also force-apply the theme on startup.
  wayland.windowManager.hyprland.settings = {
    env = [
      "XCURSOR_THEME,${cursorName}"
      "XCURSOR_SIZE,${toString cursorSize}"

      # Force Hyprland to prefer XCursor over a random hyprcursor default:
      # empty HYPRCURSOR_THEME makes Hyprland fall back to XCURSOR_THEME.
      "HYPRCURSOR_THEME," 
      "HYPRCURSOR_SIZE,${toString cursorSize}"
    ];
  };

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    # Apply at compositor start; no need to relogin for changes
    exec-once = hyprctl setcursor "${cursorName}" ${toString cursorSize}
  '';

  # Optional: also export in the user session for apps launched outside Hyprland
  home.sessionVariables = {
    XCURSOR_THEME = cursorName;
    XCURSOR_SIZE  = toString cursorSize;
  };
}

