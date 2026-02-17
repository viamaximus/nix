{config, pkgs, lib, ...}: {
  config = lib.mkIf config.features.desktop.hyprland.enable {
    services.gammastep = {
      enable = true;
      provider = "manual";
      latitude = 40.7;
      longitude = -74.0;
      temperature = {
        day = 6500;
        night = 3500;
      };
      settings = {
        general = {
          fade = 1;
          adjustment-method = "wayland";
        };
      };
      tray = true;
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mainMod SHIFT, N, exec, ${pkgs.systemd}/bin/systemctl --user restart gammastep"
      ];
    };
  };
}
