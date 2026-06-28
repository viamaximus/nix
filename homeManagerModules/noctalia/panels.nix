{
  config,
  lib,
  ...
}:
lib.mkIf config.features.desktop.noctalia.enable {
  programs.noctalia.settings = {
    shell.launcher = {
      categories = true;
      show_icons = true;
      sort_by_usage = true;
      app_grid = false;
    };

    shell.screenshot = {
      save_to_file = true;
      copy_to_clipboard = true;
    };

    control_center = {
      sidebar = "compact";
      shortcuts = [
        {type = "wifi";}
        {type = "bluetooth";}
        {type = "caffeine";}
        {type = "nightlight";}
        {type = "screen_recorder";}
        {type = "power_profile";}
      ];
    };

    lockscreen = {
      enabled = true;
      blurred_desktop = true;
      allow_empty_password = false;
    };

    osd.position = "top_center";
  };
}
