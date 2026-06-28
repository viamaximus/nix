{
  config,
  lib,
  ...
}:
lib.mkIf config.features.desktop.noctalia.enable {
  # Colors are generated from the current wallpaper (Material-You style), so the
  # palette follows whatever wallhaven wallpaper is set. To pin a fixed palette
  # instead: source = "builtin"; builtin = "Catppuccin";
  programs.noctalia.settings.theme = {
    mode = "dark";
    source = "wallpaper";
    wallpaper_scheme = "vibrant";

    # Render the generated palette into app configs (replaces Stylix). Each
    # template writes a color file; app-side wiring lives in apptheming.nix
    # (kitty include) and the GTK template's apply hook (gtk.css @import).
    templates = {
      enable_builtin_templates = true;
      builtin_ids = ["gtk3" "gtk4" "kitty" "qt"];
      enable_community_templates = true;
      community_ids = ["discord" "zen-browser" "neovim" "steam"];
    };
  };
}
