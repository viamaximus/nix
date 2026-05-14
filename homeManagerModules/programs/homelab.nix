{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    kubectl
  ];
}
