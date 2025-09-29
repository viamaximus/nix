{ config, pkgs, lib, ... }:
{
  imports = [
    ./programs
    ./hypr
    ./fonts.nix
    ./shell
  ];

  # Make the 'home-manager' CLI available and silence the news popup
  programs.home-manager.enable = true;
  news.display = "silent";
}

