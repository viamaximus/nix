{
  config,
  lib,
  ...
}:
lib.mkIf config.features.desktop.noctalia.enable {
  # Fixed to the same Cutie Pro palette as kitty/neovim (shell/kitty.nix).
  # For a wallpaper-driven palette instead: source = "wallpaper"; wallpaper_scheme = "vibrant";
  programs.noctalia.settings.theme = {
    mode = "dark";
    source = "custom";
    custom_palette = "cutie-pro";

    # Render the palette into app configs (replaces Stylix). Each template
    # writes a color file; app-side wiring lives in apptheming.nix (kitty
    # include) and the GTK template's apply hook (gtk.css @import).
    templates = {
      enable_builtin_templates = true;
      # kitty excluded: pinned to a static Cutie Pro theme instead (shell/kitty.nix).
      builtin_ids = ["gtk3" "gtk4" "qt"];
      enable_community_templates = true;
      community_ids = ["discord" "zen-browser" "neovim" "steam"];
    };
  };

  # Cutie Pro (https://github.com/mbadolato/iTerm2-Color-Schemes) as a
  # noctalia custom palette; M3 roles picked from the same accent set as kitty/neovim.
  programs.noctalia.customPalettes.cutie-pro = {
    dark = {
      mPrimary = "#efc4cd";
      mOnPrimary = "#181818";
      mSecondary = "#bec975";
      mOnSecondary = "#181818";
      mTertiary = "#42d9c5";
      mOnTertiary = "#181818";
      mError = "#f56e7f";
      mOnError = "#181818";
      mSurface = "#181818";
      mOnSurface = "#d5d0c9";
      mSurfaceVariant = "#232323";
      mOnSurfaceVariant = "#88847f";
      mOutline = "#88847f";
      mShadow = "#000000";
      mHover = "#42d9c5";
      mOnHover = "#181818";

      terminal = {
        normal = {
          black = "#000000";
          red = "#f56e7f";
          green = "#bec975";
          yellow = "#f58669";
          blue = "#42d9c5";
          magenta = "#d286b7";
          cyan = "#37cb8a";
          white = "#d5c3c3";
        };
        bright = {
          black = "#88847f";
          red = "#e5a1a3";
          green = "#e8d6a7";
          yellow = "#f1bb79";
          blue = "#80c5de";
          magenta = "#b294bb";
          cyan = "#9dccbb";
          white = "#ffffff";
        };
        foreground = "#d5d0c9";
        background = "#181818";
        cursor = "#efc4cd";
        cursorText = "#181818";
        selectionFg = "#181818";
        selectionBg = "#d5d0c9";
      };
    };
  };
}
