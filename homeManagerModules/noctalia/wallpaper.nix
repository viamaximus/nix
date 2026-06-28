{
  config,
  lib,
  ...
}:
lib.mkIf config.features.desktop.noctalia.enable {
  # Replaces hyprpaper + the wallpaper-switch rebuild script. Wallpapers live in
  # the repo and are linked into ~/Pictures/Wallpapers; switch live via the
  # launcher (/wall) or `noctalia msg panel-toggle wallpaper`.
  home.file."Pictures/Wallpapers" = {
    source = ../../wallpapers;
    recursive = true;
  };

  programs.noctalia.settings.wallpaper = {
    enabled = true;
    fill_mode = "crop";
    directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
    default.path = "${config.home.homeDirectory}/Pictures/Wallpapers/current-wallpaper.jpg";
  };
}
