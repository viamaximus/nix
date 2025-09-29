{ config, pkgs, lib, ... }:
{
  imports = [
    ./programs
    ./hypr
    ./fonts.nix
    ./shell
  ];

  # Let HM manage itself and silence the “news” popups
  programs.home-manager.enable = true;
  news.display = "silent";
}

