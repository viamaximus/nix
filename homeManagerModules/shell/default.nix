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
    #./tools.nix
    ./fastfetch.nix
  ];
}
