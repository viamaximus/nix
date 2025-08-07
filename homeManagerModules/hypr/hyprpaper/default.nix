{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      #splash = false;
      preload = [ "~/nixos-config/nix/homeManagerModules/hypr/hyprpaper/plasmawaves.png" ];
      wallpaper = [ ", ~/nixos-config/nix/homeManagerModules/hypr/hyprpaper/plasmawaves.png" ];
    };
  };
}
