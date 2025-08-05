{ config, pkgs, lib, ...}: 
{
  home.packages = with pkgs; [
    zoxide
    fzf
  ];
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [
      "--cmd cd"
    ];
  };
}
