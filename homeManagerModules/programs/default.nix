{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./common.nix
    ./neovim.nix
    ./git.nix
  ];
}
