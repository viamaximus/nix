{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      #splash = false;
      preload = [ "~/nix/homeManagerModules/hypr/hyprpaper/plasmawaves.png" ];
      wallpaper = [ ", ~/nix/homeManagerModules/hypr/hyprpaper/plasmawaves.png" ];
    };
  };
}
