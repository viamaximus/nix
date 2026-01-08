{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../../homeManagerModules
	../../homeManagerModules/gaming.nix
	../../homeManagerModules/programs/3dprint.nix
  ];

  features.desktop.hyprland.enable = true;

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
      fish_add_path $HOME/.local/bin
    '';
  };

  home.file = {
    #put .rc files here
  };

  wayland.windowManager.hyprland.extraConfig = ''
    # monitor def
    # left: 1080@60Hz
    monitor = DP-1,1920x1080@60,0x0,1

    # center: 1440p@179.88Hz
    monitor = DP-3,2560x1440@179.88,1920x-180,1

    # right: 1080@60Hz (portrait right)
    monitor = DP-2,1920x1080@60,4480x-420,1,transform,1

    workspace = 1, monitor:DP-1
    workspace = 2, monitor:DP-3
    workspace = 3, monitor:DP-2

    # make games always open on center monitor
    windowrule = monitor DP-3, class:^(steam_app_[0-9]+)$
    windowrule = monitor DP-3, class:^(gamescope)$
    windowrule = workspace 2, class:^(steam_app_[0-9]+)$
  '';

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
