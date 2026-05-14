{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    nextcloud-client
    obsidian
    alejandra
    fastfetch
    neofetch
    cbonsai
    cowsay
    bluetuith
    pwvucontrol
    feh
    spdlog
    fmt
  ];
}
