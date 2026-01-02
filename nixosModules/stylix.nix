{ config, pkgs, lib, ... }:
let
  # automatically select catppuccin cursor variant based on theme colors
  # maps stylix accent color to the closest catppuccin cursor accent
  accentColor =
    let
      primaryColor = config.lib.stylix.colors.base0D;

      colorMap = {
        "blue" = "Blue";
        "purple" = "Mauve";
        "pink" = "Pink";
        "red" = "Red";
        "orange" = "Peach";
        "yellow" = "Yellow";
        "green" = "Green";
        "teal" = "Teal";
        "sky" = "Sky";
      };

    in "Mauve";

  variant = if config.stylix.polarity == "dark" then "Macchiato" else "Latte";

  cursorName = "Catppuccin-${variant}-${accentColor}";
  cursorPackage = pkgs.catppuccin-cursors."${lib.toLower variant}${accentColor}";
in
{
  stylix = {
    enable = true;

    # wallpaper, relative to this file
    image = ./wallpaper.jpeg;

    polarity = "dark";

    cursor = {
      name = cursorName;
      package = cursorPackage;
      size = 24;
    };
  };
}

