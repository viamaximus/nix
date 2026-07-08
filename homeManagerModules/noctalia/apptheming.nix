{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.features.desktop.noctalia.enable {
  gtk = {
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Sans";
      size = 11;
    };
  };

  xdg.configFile."gtk-4.0/gtk.css".force = true;

  home.pointerCursor = {
    name = "catppuccin-mocha-mauve-cursors";
    package = pkgs.catppuccin-cursors.mochaMauve;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.kitty.extraConfig = lib.mkAfter "include themes/noctalia.conf";

  # qt{5,6}ct/colors/noctalia.conf; these conf files select it (custom_palette +
  # color_scheme_path) and qtct is set as the platform theme.
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "fusion";
  };

  # The qt module sets QT_QPA_PLATFORMTHEME=qt5ct, but OBS/qBittorrent/VLC are
  # Qt6 and need the qt6ct plugin. Force it.
  home.sessionVariables.QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    custom_palette=true
    color_scheme_path=${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf
    icon_theme=Papirus-Dark
    standard_dialogs=default
    style=Fusion
  '';
  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    custom_palette=true
    color_scheme_path=${config.home.homeDirectory}/.config/qt5ct/colors/noctalia.conf
    icon_theme=Papirus-Dark
    standard_dialogs=default
    style=Fusion
  '';

  home.packages = with pkgs; [
    adw-gtk3
    papirus-icon-theme
  ];
}
