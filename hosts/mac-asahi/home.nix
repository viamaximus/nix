{ lib, pkgs, ... }:
{
  my.hyprland.enable = true;
  my.hyprland.terminalPkg = pkgs.foot; 

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];

    config.common = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.Screencast" = [ "hyprland" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
    };
  };

  #wayland stuff
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";
  };
  
  wayland.windowManager.hyprland.package = lib.mkForce null;

  home = {
    packages = with pkgs; [
      hello
      curl
      fastfetch
    ];
  };
}
