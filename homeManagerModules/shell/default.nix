{ config, pkgs, lib, ...}: 
{
  imports = [
    ./fish.nix
    ./starship.nix
    ./kitty.nix
    ./tools.nix
  ];
  home.packages = with pkgs; [
    starship
    fish
  ];
}
