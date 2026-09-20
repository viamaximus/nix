{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.features.desktop.hyprland.enable {
    gtk.enable = true;
    gtk.gtk4.theme = lib.mkDefault null;
  };
}
