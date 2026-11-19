{lib, ...}: {
  # t1200-only desktop tweaks; lib.mkForce overrides shared scalars, lists append
  wayland.windowManager.hyprland.settings = {
  };

  programs.noctalia.settings.bar.main = {
    radius = lib.mkForce 0;
    concave_edge_corners = lib.mkForce false;
    shadow = lib.mkForce false;
  };
}
