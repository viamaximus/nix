{config, pkgs, ...}:
{
  imports = [
    ./programs
    ./hypr
    ./fonts.nix
    ./shell
  ];
}
