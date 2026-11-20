# Terminal apps vs. the Toshiba font. PxPlus ToshibaTxL1 covers CP437-style
# glyphs: single + double box lines, full/half blocks, shades, ▲▼►◄●○•✓♥…■.
# It has NO rounded corners (╭╮╰╯), heavy lines (━┃┏), partial/quadrant
# blocks (▏▎▍▋▊▉▖▗), braille, ▶◀▸▾◇▮✗, or Nerd Font icons. Missing glyphs
# get drawn from a fallback font at the wrong width and smear over text, so
# each app below is pointed at characters the font has.
#
# Not fixable by config: impala's focused panel uses a hard-coded thick border.
{lib, ...}: {
  # ── lazygit: rounded -> single borders (nerd icons are already off by default)
  programs.lazygit = {
    enable = true;
    settings.gui.border = "single";
  };

  # ── fzf (and fzf-tab completion menus): sharp border, ASCII markers
  # (appended to the shared list in shell/zsh.nix; later flags win)
  programs.fzf.defaultOptions = ["--border=sharp" "--pointer='>'" "--marker='*'" "--scrollbar='|'"];
  programs.fzf.changeDirWidget.options = lib.mkForce [
    "--preview 'eza --tree --level=2 --color=always {} | head -50'"
  ];
  programs.zsh.initContent = lib.mkAfter ''
    zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border=sharp --pointer='>' --marker='*'
  '';

  # ── wiremix (Super+Ctrl+A): custom char set from CP437 glyphs
  xdg.configFile."wiremix/wiremix.toml".text = ''
    char_set = "t1200"

    [char_sets.t1200]
    default_device = "*"
    default_stream = "*"
    selector_top = "░"
    selector_middle = "▒"
    selector_bottom = "░"
    tab_marker_left = "["
    tab_marker_right = "]"
    list_more = "..."
    volume_empty = "░"
    volume_filled = "█"
    meter_left_inactive = "░"
    meter_left_active = "█"
    meter_left_overload = "▓"
    meter_right_inactive = "░"
    meter_right_active = "█"
    meter_right_overload = "▓"
    meter_center_left_inactive = "│"
    meter_center_left_active = "│"
    meter_center_right_inactive = "│"
    meter_center_right_active = "│"
    dropdown_icon = "▼"
    dropdown_selector = ">"
    dropdown_more = "..."
    dropdown_border = "Plain"
    help_more = "..."
    help_border = "Plain"
  '';

  # ── discordo (Super+Shift+D): plain borders, double for the focused pane
  # (key names follow the upstream-HEAD pin in apps.nix; unknown keys are
  # silently ignored, so recheck docs/config.md when bumping it)
  xdg.configFile."discordo/config.toml".text = ''
    [ui.border]
    normal_set = "plain"
    active_set = "double"

    [sidebar.markers]
    expanded = "▼ "
    collapsed = "► "
  '';

  # ── spotify_player (Super+S): ► for play, line progress bar (the default
  # rectangle gauge draws with partial blocks)
  xdg.configFile."spotify-player/app.toml".text = ''
    play_icon = "►"
    pause_icon = "▌▌"
    liked_icon = "♥"
    border_type = "Plain"
    progress_bar_type = "Line"
  '';
}
