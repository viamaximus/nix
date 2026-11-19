{config, lib, ...}: {
  config = lib.mkIf (config.features.desktop.hyprland.enable && !config.features.desktop.noctalia.enable) {
    services.hypridle.enable = true;
    services.hypridle.settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
        }
        # suspend disabled - user wants to be able to SSH in
      ];
    };
  };
}
