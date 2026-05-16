{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isAarch64 isx86_64;
in {
  home.packages =
    (with pkgs; [
      qbittorrent
      protonvpn-gui
      snapshot
      obs-studio
      vlc
      nextcloud-client
      keepassxc
      obsidian
      fastfetch
      neofetch
      feh
      cbonsai
      cowsay
      bluetuith
      pwvucontrol
      nautilus
    ])
    ++ lib.optionals isx86_64 [pkgs.discord]
    ++ lib.optionals isAarch64 [pkgs.discordo pkgs.vesktop];
}
