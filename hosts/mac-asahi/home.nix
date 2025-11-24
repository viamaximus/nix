{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  wallpaperConfig = import ./current-wallpaper.nix;
in
{
  imports = [
    ../../homeManagerModules
  ];
  
  stylix = {
    enable = true;
    image = wallpaperConfig.currentWallpaper;
    polarity = "dark";
  };

  home.username = "max";
  home.homeDirectory = "/home/max";

  home.packages = with pkgs; [
    hello
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      fish_add_path $HOME/.npm-global/bin
    '';
  };

  home.file = {
    #put .rc files here
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
