{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./browsers.nix
    ./c-dev.nix
    ./ghidra.nix
    ./common.nix
    ./neovim.nix
    ./git.nix
    ./godot.nix
    ./rfstuffs.nix
    ./kicad.nix
    ./wallpaper-switch.nix
    ./vesktop.nix
    ./spotify.nix
    ./spotify-config.nix
  ];
}
