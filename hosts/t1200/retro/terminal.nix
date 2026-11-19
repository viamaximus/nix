# cool-retro-term as the default terminal, always running inside tmux for
# tabs (windows) and splits (panes). kitty stays as the fallback for things
# CRT can't render (images, truecolor).
#
# CRT keeps its settings in a Qt LocalStorage SQLite DB rather than a config
# file, so `crt-apply` rewrites that DB from the Nix profile below plus the
# colours Noctalia last rendered. It runs on every launch and on every palette
# change, so settings changed in CRT's own GUI don't persist; change them here.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.t1200.retro;
  term = cfg.palettes.${cfg.scheme}.${cfg.palettes.${cfg.scheme}.mode}.terminal;
  font = "System: ${cfg.font}";

  # App-wide settings (_CURRENT_SETTINGS).
  crtSettings = {
    fontScaling = 0.8; # system fonts are 30px * scaling -> 24px, ~30 rows on 720px
    fontNames = [font font font]; # one per rasterization mode
    showMenubar = false;
    showTerminalSize = false;
    windowScaling = 1;
    bloomQuality = 0.5;
    burnInQuality = 0.5;
    useCustomCommand = false;
    customCommand = "";
  };

  # Look (_CURRENT_PROFILE). Kept subtle: scanlines, light glow, no wobble.
  crtProfile = {
    backgroundColor = term.background;
    fontColor = term.foreground;
    chromaColor = 0.3; # 0 = pure mono; 0.3 keeps a hint of ANSI hue
    saturationColor = 0.35;
    flickering = 0.05;
    horizontalSync = 0;
    staticNoise = 0.03;
    screenCurvature = 0.08;
    glowingLine = 0.06;
    burnIn = 0.15;
    bloom = 0.35;
    rasterization = 0; # no own scanlines: the Hyprland screen shader (crt.frag) adds them
    jitter = 0;
    rbgShift = 0;
    brightness = 0.5;
    contrast = 0.85;
    ambientLight = 0.1;
    windowOpacity = 1;
    fontName = font;
    fontWidth = 1;
    margin = 0.15;
    blinkingCursor = true;
    frameMargin = 0;
  };

  crtApply = pkgs.writeShellApplication {
    name = "crt-apply";
    runtimeInputs = with pkgs; [sqlite jq coreutils];
    text = ''
      dir="''${XDG_DATA_HOME:-$HOME/.local/share}/cool-retro-term/cool-retro-term/QML/OfflineStorage/Databases"
      db="$dir/27e743fe85b8912a46804fed99e8a9ab.sqlite" # md5("coolretroterm1")
      colors="''${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/t1200/crt-colors.json"
      mkdir -p "$dir"
      [ -f "''${db%.sqlite}.ini" ] || cat > "''${db%.sqlite}.ini" <<'EOF'
      [General]
      Description=StorageDatabase
      Driver=QSQLITE
      EstimatedSize=100000
      Name=coolretroterm1
      Version=1.0
      EOF

      profile='${builtins.toJSON crtProfile}'
      if [ -s "$colors" ] && jq -e . "$colors" >/dev/null 2>&1; then
        profile=$(jq -c --slurpfile c "$colors" '. + $c[0]' <<<"$profile")
      fi
      settings='${builtins.toJSON crtSettings}'

      q() { printf "%s" "$1" | sed "s/'/'''/g"; }
      sqlite3 "$db" \
        "CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT);" \
        "INSERT OR REPLACE INTO settings VALUES('_CURRENT_SETTINGS', '$(q "$settings")');" \
        "INSERT OR REPLACE INTO settings VALUES('_CURRENT_PROFILE', '$(q "$profile")');"
    '';
  };

  # Attach to the "main" session; if it's already open in another window,
  # start a throwaway session instead of mirroring it.
  retroTmux = pkgs.writeShellApplication {
    name = "retro-tmux";
    runtimeInputs = [pkgs.tmux];
    text = ''
      if tmux has-session -t main 2>/dev/null \
        && [ "$(tmux display-message -p -t main '#{session_attached}')" -gt 0 ]; then
        exec tmux new-session \; set-option destroy-unattached on
      fi
      exec tmux new-session -A -s main
    '';
  };

  # `retro-term` -> CRT + tmux; `retro-term -e cmd ...` -> CRT running cmd.
  retroTerm = pkgs.writeShellApplication {
    name = "retro-term";
    runtimeInputs = [crtApply pkgs.cool-retro-term retroTmux];
    text = ''
      crt-apply || true
      if [ "$#" -eq 0 ]; then
        exec cool-retro-term -e retro-tmux
      fi
      exec cool-retro-term "$@"
    '';
  };
in {
  options.t1200.retro.crtApply = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    default = crtApply;
  };

  config = {
    home.packages = [pkgs.cool-retro-term crtApply retroTmux retroTerm];
    home.sessionVariables.TERMINAL = "retro-term";

    # Seed the DB at activation so the first launch is already themed.
    home.activation.crtApply = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${crtApply}/bin/crt-apply || true
    '';

    # Extends the shared tmux config (prefix C-a, vi keys); colours come from
    # the Noctalia template so they follow palette switches.
    programs.tmux.extraConfig = lib.mkAfter ''
      # ── t1200 ─────────────────────────────────────────────
      set -g status-left-length 20
      set -g status-right-length 20
      set -g status-justify left
      set -g renumber-windows on

      # tabs = windows, splits = panes (| left/right, - top/bottom)
      bind c new-window -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 4
      bind -r J resize-pane -D 2
      bind -r K resize-pane -U 2
      bind -r L resize-pane -R 4
      bind -n M-h previous-window
      bind -n M-l next-window
      bind ? display-popup -E -w 90% -h 90% "t1200-guide --tmux"

      source-file -q ~/.config/tmux/noctalia.conf
    '';

    # kitty fallback: same palette, retro font, no transparency.
    programs.kitty = {
      font.name = lib.mkOverride 40 cfg.font;
      font.size = lib.mkOverride 40 12;
      settings = {
        background_opacity = lib.mkOverride 40 "1.0";
        background_blur = lib.mkOverride 40 0;
        cursor_shape = lib.mkOverride 40 "block";
        tab_bar_style = lib.mkOverride 40 "separator";
      };
      extraConfig = lib.mkAfter ''
        include themes/noctalia.conf
      '';
    };
  };
}
