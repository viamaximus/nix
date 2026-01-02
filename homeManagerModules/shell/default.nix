{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./fish.nix
    ./starship.nix
    ./kitty.nix
    #./tools.nix
    ./fastfetch.nix
  ];
}
