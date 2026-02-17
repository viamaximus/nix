{config, lib, ...}: {
  config = lib.mkIf config.features.desktop.hyprland.enable {
    programs.wofi.enable = true;
  };
}
