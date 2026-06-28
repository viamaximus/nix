{
  config,
  lib,
  ...
}:
lib.mkIf config.features.desktop.noctalia.enable {
  programs.noctalia.settings = {
    # Replaces mako (was top-right).
    notification = {
      enable_daemon = true;
      position = "top_right";
    };

    # Coordinates carried over from the old gammastep config (NYC).
    # Weather needs a geocoded location; manual lat/long alone don't populate the
    # weather widget, so set a named address (it geocodes to coords + display name).
    location = {
      auto_locate = false;
      address = "New York, NY";
      latitude = 40.7;
      longitude = -74.0;
    };

    # Replaces gammastep. Default OFF (the bar moon toggle starts disabled);
    # temperatures apply when toggled on.
    nightlight = {
      enabled = false;
      temperature_day = 6500;
      temperature_night = 3500;
    };

    weather = {
      enabled = true;
      unit = "imperial";
      refresh_minutes = 30;
    };

    # Replaces hypridle: lock @5min, screen-off @10min, never suspend
    # (tower keeps sleep targets masked for SSH access).
    idle.behavior = {
      lock = {
        timeout = 300;
        action = "lock";
        enabled = true;
      };
      screen-off = {
        timeout = 600;
        action = "screen_off";
        enabled = true;
      };
      suspend.enabled = false;
    };
  };
}
