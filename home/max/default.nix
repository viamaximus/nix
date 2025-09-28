{ config, pkgs, ... }:
{
  home.username = "max";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/max" else "/home/max";

  programs.fzf.enable = true;
  programs.starship.enable = true;
  
  programs.home-manager.enable = true;

  programs.git.extraConfig = {
    pull.rebase = true;
    init.defaultBranch = "main";
  };
}

