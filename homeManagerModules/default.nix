{config, pkgs, ...}:
{
  imports = [
    ./programs
    ./programs/hyprland.nix
  ];
}
