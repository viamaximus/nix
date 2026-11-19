{
  config,
  pkgs,
  lib,
  ...
}: {
  services.udisks2.enable = true;

  security.polkit.enable = true;

  # file manager support for automounting
  services.gvfs.enable = true;

  # nothing in a bare Hyprland session calls udisks2 to mount removable media
  systemd.user.services.udiskie = {
    description = "udiskie removable media automounter";
    documentation = ["man:udiskie(8)"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie --automount --notify --no-tray";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  environment.systemPackages = with pkgs; [
    udiskie  
    udisks   
  ];
}
