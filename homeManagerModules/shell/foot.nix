{ config, pkgs, lib, ... }:
let
  isLinux   = pkgs.stdenv.isLinux;
  hasTermPkg = lib.hasAttrByPath [ "my" "hyprland" "terminalPkg" ] config;
  useFoot    = isLinux && hasTermPkg && config.my.hyprland.terminalPkg == pkgs.foot;
in
{
  programs.foot = lib.mkIf useFoot {
    enable = true;
    settings = {
      main = {
        # match your kitty font (Nerd)
        font = "JetBrainsMono Nerd Font:size=12";
        dpi-aware = "yes";
        term = "foot";
      };

      # Catppuccin Macchiato palette
      colors = {
        foreground = "cad3f5";
        background = "24273a";

        # regular
        regular0 = "494d64"; # black (surface1-ish)
        regular1 = "ed8796"; # red
        regular2 = "a6da95"; # green
        regular3 = "eed49f"; # yellow
        regular4 = "8aadf4"; # blue
        regular5 = "c6a0f6"; # magenta (mauve)
        regular6 = "8bd5ca"; # cyan   (teal)
        regular7 = "b8c0e0"; # white  (subtext1)

        # bright
        bright0 = "5b6078"; # bright black
        bright1 = "ed8796";
        bright2 = "a6da95";
        bright3 = "eed49f";
        bright4 = "8aadf4";
        bright5 = "c6a0f6";
        bright6 = "8bd5ca";
        bright7 = "a5adcb";

        selection-foreground = "cad3f5";
        selection-background = "363a4f";
        cursor = "f4dbd6";
      };
    };
  };
}

