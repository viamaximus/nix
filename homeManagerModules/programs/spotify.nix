{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    spotify-player
    spot
    playerctl
  ];
}
