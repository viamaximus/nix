{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    cp210x-program
    screen
    tio
    caligula
  ];
}
