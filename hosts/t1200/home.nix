{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../homeManagerModules
    ../../homeManagerModules/programs/profiles/slim.nix
    ./bezel.nix
    ./desktop.nix
    inputs.nix-index-database.homeModules.nix-index
  ];

  programs.nix-index.package = lib.hiPrio inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-db;

  features.desktop.hyprland.enable = true;
  features.desktop.noctalia.enable = true;

  features.git = {
    agentSigning = true;
    browserAuth = true;
  };

  home.username = "max";
  home.homeDirectory = "/home/max";

  home.packages = with pkgs; [
    hello
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    cool-retro-term
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    #put .rc files here
  };

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
