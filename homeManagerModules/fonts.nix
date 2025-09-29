{ lib, pkgs, ... }:
{
  fonts.fontconfig.enable = true;  # HM option, works on non-NixOS too

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
  ];
}

