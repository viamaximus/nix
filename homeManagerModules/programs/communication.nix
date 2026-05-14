{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    signal-desktop
    element-desktop
    fluffychat
  ];
}
