{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../homeManagerModules
  ];

  home.username = "nix";
  home.homeDirectory = "/home/nix";

  home.packages = with pkgs; [
    pkgs.hello
  ];
  
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  
  home.file = {
    #put .rc files here
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
