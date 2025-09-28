{ lib, pkgs, ... }:
{
  my.hyprland.enable = true;

  #wayland stuff
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";
  };
  
  wayland.windowManager.hyprland.package = null;

  home = {
    packages = with pkgs; [
      hello
      curl
      fastfetch
    ];
  };
}
