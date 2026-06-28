{...}: {
  # Vencord settings: load the Noctalia-generated Discord theme. The discord
  # community template renders ~/.config/vesktop/themes/noctalia.theme.css from
  # the current (wallpaper) palette; enabling it here makes vesktop use it.
  home.file.".config/vesktop/settings/settings.json".text = builtins.toJSON {
    useQuickCss = false;
    enabledThemes = ["noctalia.theme.css"];
    enableReactDevtools = false;
  };

  # Vesktop app settings (separate file from Vencord's).
  home.file.".config/vesktop/settings.json".text = builtins.toJSON {
    discordBranch = "stable";
    minimizeToTray = true;
  };
}
