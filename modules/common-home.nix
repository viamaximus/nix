{ config, pkgs, ... }:
{
  home.stateVersion = "25.05";

#  programs.git = {
#    enable = true;
#    userName = "Max";
#    userEmail = "you@example.com";
#  };

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    btop
  ];
}

