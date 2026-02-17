{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./zsh.nix
    ./starship.nix
    ./kitty.nix
    ./fastfetch.nix
  ];
}
