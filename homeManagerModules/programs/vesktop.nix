{ config, pkgs, lib, ... }:

{
  home.file.".config/vesktop/settings/quickCss.css".text = with config.lib.stylix.colors.withHashtag; ''
    :root {
      --background-primary: ${base00};
      --background-secondary: ${base01};
      --background-secondary-alt: ${base02};
      --background-tertiary: ${base03};
      --background-accent: ${base0E};
      --background-floating: ${base00};
      --background-mobile-primary: ${base00};
      --background-mobile-secondary: ${base01};
      --background-modifier-hover: ${base02}40;
      --background-modifier-active: ${base02}80;
      --background-modifier-selected: ${base0D}40;
      --background-modifier-accent: ${base0E}20;

      --text-normal: ${base05};
      --text-muted: ${base04};
      --text-link: ${base0D};
      --text-positive: ${base0B};
      --text-warning: ${base0A};
      --text-danger: ${base08};

      --interactive-normal: ${base05};
      --interactive-hover: ${base06};
      --interactive-active: ${base07};
      --interactive-muted: ${base03};

      --channels-default: ${base05};
      --channel-text-area-placeholder: ${base04};
      --channeltextarea-background: ${base01};

      --header-primary: ${base06};
      --header-secondary: ${base04};

      --scrollbar-thin-thumb: ${base02};
      --scrollbar-thin-track: transparent;
      --scrollbar-auto-thumb: ${base02};
      --scrollbar-auto-track: ${base01};

      --elevation-stroke: 0 0 0 1px ${base02};
      --elevation-low: 0 1px 0 ${base02};
      --elevation-medium: 0 4px 4px ${base00}cc;
      --elevation-high: 0 8px 16px ${base00}dd;
    }

    .form__13a2c {
      background-color: var(--background-secondary);
    }

    code {
      background-color: ${base01};
      border-color: ${base02};
      color: ${base0C};
    }

    .mention {
      background-color: ${base0D}40;
      color: ${base0D};
    }

    .embed__8e06d {
      background-color: ${base01};
      border-color: ${base0E};
    }

    .reaction__08ce2 {
      background-color: ${base01};
      border-color: ${base02};
    }

    .reaction__08ce2.reactionMe__4a232 {
      background-color: ${base0D}40;
      border-color: ${base0D};
    }
  '';

  home.file.".config/vesktop/settings/settings.json".text = builtins.toJSON {
    discordBranch = "stable";
    enableReactDevtools = false;
    enableMenu = true;
    minimizeToTray = true;
    vencord = {
      useQuickCss = true;
      enabledThemes = [];
    };
  };
}
