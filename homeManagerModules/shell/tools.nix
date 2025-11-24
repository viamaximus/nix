{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    zoxide
    fzf
    tree
  ];
  # programs.zoxide = {
  #   enable = true;
  #   enableFishIntegration = true;
  #   options = [
  #     "--cmd cd"
  #   ];
  # };
}
