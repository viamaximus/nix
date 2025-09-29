{ config, pkgs, lib, ...}: 
{
  imports = [
    ./fish.nix
    ./starship.nix
    ./kitty.nix
    ./foot.nix
    ./tools.nix
    ./fastfetch.nix
  ];
  home.packages = with pkgs; [
    starship
    fish
  ];
}
