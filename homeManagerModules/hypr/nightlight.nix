{config, pkgs, lib, ...}: let
  hl = import ./lua.nix {inherit lib;};
in {
  config = lib.mkIf (config.features.desktop.hyprland.enable && !config.features.desktop.noctalia.enable) {
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
        (hl.bind "${hl.mod} + SHIFT + N" (hl.exec "${pkgs.systemd}/bin/systemctl --user restart gammastep"))
      ];
    };
  };
}
