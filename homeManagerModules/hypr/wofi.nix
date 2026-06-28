{config, lib, ...}: {
  config = lib.mkIf (config.features.desktop.hyprland.enable && !config.features.desktop.noctalia.enable) {
    programs.wofi.enable = true;
  };
}
