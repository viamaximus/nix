{ config, pkgs, lib, ... }:
let
  hasTermPkg = lib.hasAttrByPath [ "my" "hyprland" "terminalPkg" ] config;
  useKitty   = hasTermPkg && config.my.hyprland.terminalPkg == pkgs.kitty;
in
{
  programs.kitty = lib.mkIf useKitty {
    enable = true;

    # your original theme & font
    themeFile = "Catppuccin-Macchiato";
    font.name = "JetBrainsMono Nerd Font";

    settings = {
      confirm_os_window_close = -0;
      copy_on_select = true;
      clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
    };
  };
}

