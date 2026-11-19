{
  lib,
  pkgs,
  ...
}: {
  # t1200-only desktop tweaks; lib.mkForce overrides shared scalars, lists append
  wayland.windowManager.hyprland.settings = {
  };

  # hyprmod writes GUI changes to hyprland-gui.lua, loaded last so it wins over nix
  home.packages = [pkgs.hyprmod];
  home.activation.hyprmodFile = lib.hm.dag.entryAfter ["writeBoundary"] ''
    touch "$HOME/.config/hypr/hyprland-gui.lua"
  '';
  wayland.windowManager.hyprland.extraConfig = ''
    require("hyprland-gui")
  '';

  programs.noctalia.settings.bar.main = {
    radius = lib.mkForce 0;
    concave_edge_corners = lib.mkForce false;
    shadow = lib.mkForce false;
  };
}
