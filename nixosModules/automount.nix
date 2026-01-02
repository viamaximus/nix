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

  environment.systemPackages = with pkgs; [
    udiskie  
    udisks   
  ];
}
