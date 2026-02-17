{config, lib, ...}: {
  config = lib.mkIf config.features.desktop.hyprland.enable {
    programs.hyprlock.enable = true;
    programs.hyprlock.settings = {
      general = {
        disable_loading_bar = true;
        grace = 3;
        hide_cursor = true;
        no_fade_in = false;
      };
    };
  };
}
