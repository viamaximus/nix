{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      #splash = false;
      preload = [ "~/nixos-config/homeManagerModules/hypr/hyprpaper/plasmawaves.png" ];
      wallpaper = [ ", ~/nixos-config/homeManagerModules/hypr/hyprpaper/plasmawaves.png" ];
    };
  };
}
