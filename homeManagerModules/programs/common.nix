{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    caligula
    tree
    screen
    unzip
    zip
  ];
}
