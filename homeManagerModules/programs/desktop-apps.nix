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
      proton-vpn
      snapshot
      obs-studio
      vlc
      nextcloud-client
      keepassxc
      obsidian
      fastfetch
      feh
      cbonsai
      cowsay
      bluetuith
      pwvucontrol
      nautilus
    ])
    ++ lib.optionals isx86_64 [pkgs.vesktop]
    ++ lib.optionals isAarch64 [pkgs.discordo pkgs.vesktop];
}
