{ config, pkgs, lib, ... }:
let
  isLinux    = pkgs.stdenv.isLinux;
  hasTermPkg = lib.hasAttrByPath [ "my" "hyprland" "terminalPkg" ] config;
  useFoot    = isLinux && hasTermPkg && config.my.hyprland.terminalPkg == pkgs.foot;
in
{
  programs.foot = lib.mkIf useFoot {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        dpi-aware = "yes";
        term = "foot";
      };

      cursor = {
        style = "block";
        blink = "no";
        color = "24273a f4dbd6";  # <- correct key name
      };

      colors = {
        foreground = "cad3f5";
        background = "24273a";
        selection-foreground = "cad3f5";
        selection-background = "363a4f";

        regular0 = "494d64"; regular1 = "ed8796"; regular2 = "a6da95"; regular3 = "eed49f";
        regular4 = "8aadf4"; regular5 = "c6a0f6"; regular6 = "8bd5ca"; regular7 = "b8c0e0";
        bright0  = "5b6078"; bright1  = "ed8796"; bright2  = "a6da95"; bright3  = "eed49f";
        bright4  = "8aadf4"; bright5  = "c6a0f6"; bright6  = "8bd5ca"; bright7  = "a5adcb";
      };
    };
  };
}

