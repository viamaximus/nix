{ config, pkgs, lib, ...}: 

{
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper
    ./waybar
    ./gtk.nix
  ];
  config = lib.mkIf (pkgs.stdenv.isLinux && config.my.hyprland.enable) {
 	 home.packages = with pkgs; [
 	   hyprpaper
 	   hyprcursor
 	   hyprlock
 	   hypridle
 	   kitty
 	   libnotify
 	   mako
 	   qt5.qtwayland
 	   qt6.qtwayland
 	   swayidle
 	   swaylock-effects
 	   wlogout
 	   wl-clipboard
 	   wofi
 	   waybar
 	   brightnessctl
 	   grim
 	   slurp
	   pamixer
	   clipman
 	 ];
  };
}
