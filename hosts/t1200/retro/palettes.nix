# Retro palettes for the t1200. Each one becomes a Noctalia custom palette
# (t1200-<name>), so all four can be switched live in Noctalia
# Settings -> Theme -> Custom palette. Noctalia then re-renders GTK/Qt/Vesktop/
# Neovim plus the user templates in noctalia.nix (tmux, cool-retro-term, kitty,
# yazi, btop, zathura, fzf, Helium).
#
# Colour is deliberately limited: the ANSI slots are desaturated variations of
# the phosphor hue, with only red/green kept distinct enough for diffs.
let
  # Noctalia M3 roles + terminal block from a compact description.
  mk = c: {
    mPrimary = c.fg;
    mOnPrimary = c.bg;
    mSecondary = c.secondary;
    mOnSecondary = c.bg;
    mTertiary = c.tertiary;
    mOnTertiary = c.bg;
    mError = c.error;
    mOnError = c.bg;
    mSurface = c.bg;
    mOnSurface = c.fg;
    mSurfaceVariant = c.bgAlt;
    mOnSurfaceVariant = c.dim;
    mOutline = c.outline;
    mShadow = "#000000";
    mHover = c.tertiary;
    mOnHover = c.bg;

    terminal = {
      inherit (c) normal bright;
      foreground = c.fg;
      background = c.bg;
      cursor = c.fg;
      cursorText = c.bg;
      selectionFg = c.bg;
      selectionBg = c.fg;
    };
  };
in {
  # P3 amber phosphor (IBM 5151 / Wyse style).
  amber = {
    mode = "dark";
    dark = mk {
      bg = "#0c0800";
      bgAlt = "#1c1300";
      fg = "#ffb000";
      dim = "#b07a00";
      outline = "#6b4a00";
      secondary = "#d08c00";
      tertiary = "#ffcc66";
      error = "#ff6a3d";
      normal = {
        black = "#1c1300";
        red = "#e8643c";
        green = "#c9b23a";
        yellow = "#ffb000";
        blue = "#a8783a";
        magenta = "#d98a5f";
        cyan = "#e0b070";
        white = "#f0c878";
      };
      bright = {
        black = "#6b4a00";
        red = "#ff8a5c";
        green = "#e6d070";
        yellow = "#ffc94d";
        blue = "#c89a5c";
        magenta = "#f0a880";
        cyan = "#f5d29a";
        white = "#ffe6b3";
      };
    };
  };

  # P1 green phosphor (Apple II / VT100 style).
  green = {
    mode = "dark";
    dark = mk {
      bg = "#020a03";
      bgAlt = "#0a1f0e";
      fg = "#33ff66";
      dim = "#20a845";
      outline = "#145c25";
      secondary = "#22c04c";
      tertiary = "#9dffb5";
      error = "#ff6a4d";
      normal = {
        black = "#0a1f0e";
        red = "#e0704a";
        green = "#33ff66";
        yellow = "#c4f060";
        blue = "#3aa878";
        magenta = "#88c898";
        cyan = "#4ae8b0";
        white = "#b0f5c0";
      };
      bright = {
        black = "#145c25";
        red = "#ff9070";
        green = "#80ff9e";
        yellow = "#e0ff90";
        blue = "#66cc99";
        magenta = "#b0e8c0";
        cyan = "#90ffd8";
        white = "#e6ffec";
      };
    };
  };

  # Toshiba T3100 gas-plasma: orange-red on black.
  plasma = {
    mode = "dark";
    dark = mk {
      bg = "#0a0200";
      bgAlt = "#1f0800";
      fg = "#ff5a1f";
      dim = "#b8400f";
      outline = "#6b2306";
      secondary = "#d0450f";
      tertiary = "#ff9a6b";
      error = "#ffd23d"; # yellow, so errors still stand out on an all-red screen
      normal = {
        black = "#1f0800";
        red = "#ff3818";
        green = "#d08a2a";
        yellow = "#ff8a30";
        blue = "#a8442a";
        magenta = "#e05a50";
        cyan = "#f08f60";
        white = "#ffb08a";
      };
      bright = {
        black = "#6b2306";
        red = "#ff6a48";
        green = "#f0b050";
        yellow = "#ffb060";
        blue = "#c86848";
        magenta = "#ff8a78";
        cyan = "#ffb894";
        white = "#ffd9c8";
      };
    };
  };

  # Toshiba T1200 STN LCD. Light = the real unlit panel (navy on blue-grey);
  # dark = the backlit/inverted look. Selecting this scheme switches Noctalia
  # to light mode.
  lcd = {
    mode = "light";
    light = mk {
      bg = "#b8c4c8";
      bgAlt = "#a8b4ba";
      fg = "#16224a";
      dim = "#3a4a6e";
      outline = "#6a7890";
      secondary = "#2e3e6a";
      tertiary = "#4a5a80";
      error = "#7a1a28";
      normal = {
        black = "#16224a";
        red = "#7a1a28";
        green = "#1e4a3a";
        yellow = "#5a4a1a";
        blue = "#1c3a80";
        magenta = "#4a2a6a";
        cyan = "#1a4a5a";
        white = "#8a98a8";
      };
      bright = {
        black = "#4a5a7a";
        red = "#9a3040";
        green = "#2e6a52";
        yellow = "#7a6a2a";
        blue = "#2e52a8";
        magenta = "#6a4a8a";
        cyan = "#2a6a7a";
        white = "#c8d2d6";
      };
    };
    dark = mk {
      bg = "#0e1630";
      bgAlt = "#18224a";
      fg = "#b8c8d8";
      dim = "#8090b0";
      outline = "#3a4a70";
      secondary = "#8fa4c0";
      tertiary = "#d8e4f0";
      error = "#e07080";
      normal = {
        black = "#18224a";
        red = "#d07080";
        green = "#80b8a0";
        yellow = "#c8c090";
        blue = "#7090d0";
        magenta = "#a890c8";
        cyan = "#80b8c8";
        white = "#b8c8d8";
      };
      bright = {
        black = "#3a4a70";
        red = "#f090a0";
        green = "#a0d8c0";
        yellow = "#e8e0b0";
        blue = "#90b0f0";
        magenta = "#c8b0e8";
        cyan = "#a0d8e8";
        white = "#e8f0f8";
      };
    };
  };
}
