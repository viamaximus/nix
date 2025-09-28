{ pkgs, ... }:
{
  gtk = {
    enable = true;

    cursorTheme = {
        name = "Catppuccin-Macchiato-Light";
        package = pkgs.catppuccin-cursors.macchiatoLight;
    };

    theme = {
      name = "Catppuccin-Macchiato-Compact-Blue-dark";
      package = pkgs.catppuccin-gtk.override {
        size = "compact";
        accents = ["blue"];
        variant = "macchiato";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-folders;
    };

    gtk3.extraConfig = {
        Settings = ''
            gtk-application-prefer-dark-theme = 1;
        '';
    };

    gtk4.extraConfig = {
        Settings = ''
            gtk-application-prefer-dark-theme = 1;
            '';
    };

  };
}
