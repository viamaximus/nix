# nixosModules/stylix.nix
{ config, pkgs, ... }:

{
  stylix = {
    # Turn Stylix on
    enable = true;

    # Your wallpaper, relative to this file
    image = ./wallpaper.jpeg;

    # Dark or light theme hint
    polarity = "dark";

  };
}

