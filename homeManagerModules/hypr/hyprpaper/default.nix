{config, pkgs, lib, ...}: {
  config = lib.mkIf config.features.desktop.hyprland.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        preload = ["../../../current.jpg"];
        wallpaper = [", ../../../current.jpg"];
      };
    };
  };
}
