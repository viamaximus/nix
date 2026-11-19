# Keyboard/terminal-first apps and defaults for the t1200, plus theming for the
# GUI apps that stay (Helium, Vesktop, GTK, Neovim, cursor).
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.t1200.retro;
in {
  home.packages = with pkgs; [
    chafa # ASCII/block-art image previews (yazi inside CRT, `icat`)
    imv # image viewer, vim keys
    wiremix # terminal audio mixer (replaces pavucontrol)
    spotify-player # terminal spotify client (`spotify_player`)
    discordo # terminal discord client; not the default (third-party clients break Discord ToS)
    ultimate-oldschool-pc-font-pack
  ];

  fonts.fontconfig.enable = true;

  # ── file manager ──
  # Image previews: kitty graphics inside kitty, chafa block-art inside CRT.
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y"; # `y` = yazi that cd's on exit
    settings = {
      mgr = {
        show_hidden = false;
        sort_dir_first = true;
      };
      opener = {
        image = [
          {
            run = ''imv "$@"'';
            orphan = true;
            desc = "imv";
          }
        ];
        pdf = [
          {
            run = ''zathura "$@"'';
            orphan = true;
            desc = "zathura";
          }
        ];
      };
      open.prepend_rules = [
        {
          mime = "image/*";
          use = "image";
        }
        {
          mime = "application/pdf";
          use = "pdf";
        }
      ];
    };
  };

  # ── pdf ──
  programs.zathura = {
    enable = true;
    options = {
      font = "${cfg.font} 12";
      guioptions = "s"; # statusbar only
      recolor = true; # page drawn in palette colours; Ctrl+R toggles
      selection-clipboard = "clipboard";
    };
    extraConfig = "include noctaliarc";
  };

  # ── system monitor (theme rendered by Noctalia) ──
  programs.btop.settings = {
    color_theme = "noctalia";
    theme_background = false;
    rounded_corners = false;
    vim_keys = true;
  };

  # ── browser ──
  home.sessionVariables.BROWSER = lib.mkForce "helium";
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "x-scheme-handler/about" = "helium.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "inode/directory" = "yazi.desktop";
    };
  };

  # ── neovim: follow the Noctalia palette (community "neovim" template writes
  # lua/matugen.lua and reloads it on palette changes) ──
  programs.neovim.plugins = [pkgs.vimPlugins.base16-nvim];
  programs.neovim.initLua = lib.mkAfter ''
    pcall(function() require("matugen").setup() end)
  '';

  # ── vesktop: palette comes from the Noctalia discord template; square it
  # off and use the Toshiba font ──
  home.file.".config/vesktop/settings/settings.json".text = lib.mkForce (builtins.toJSON {
    useQuickCss = true;
    enabledThemes = ["noctalia.theme.css"];
    enableReactDevtools = false;
  });
  home.file.".config/vesktop/settings/quickCss.css".text = ''
    * {
      border-radius: 0 !important;
      box-shadow: none !important;
    }
    :root {
      --font-primary: "${cfg.font}", monospace !important;
      --font-display: "${cfg.font}", monospace !important;
      --font-headline: "${cfg.font}", monospace !important;
      --font-code: "${cfg.font}", monospace !important;
    }
  '';

  # ── GTK / cursor ──
  gtk.font = lib.mkForce {
    name = cfg.font;
    size = 12;
  };
  home.pointerCursor = {
    name = lib.mkForce "Hackneyed";
    package = lib.mkForce pkgs.hackneyed;
    size = lib.mkForce 24;
  };
}
