# `t1200-guide`: searchable cheat sheet. Hyprland binds are read live from
# `hyprctl binds -j` (only the ones with descriptions, i.e. the t1200 keymap),
# followed by static notes for everything else. Super+/, NumLk, or `guide`.
#   t1200-guide           print + fzf in the current terminal
#   t1200-guide --window  open in a floating cool-retro-term window
#   t1200-guide --tmux    (used by the tmux `prefix ?` popup)
{pkgs, ...}: let
  notes = pkgs.writeText "t1200-guide-notes" ''

    ── KEYBOARD (QMK) ───────────────────────────────────────────────
    SysRq                       mouse mode on/off (CRT LED lit while on)
      h j k l                     move pointer
      f / Space                   left click
      d                           right click
      s                           middle click
      u / i                       scroll up / down
      y / o                       scroll left / right
      hold a                      precise (slow) pointer
      Esc                         leave mouse mode
    Fn + h j k l                move pointer without switching modes
    Fn + Space                  left click
    NumLk                       this guide (sends F13)
    ScrLk                       hint-click: type a label to click there (F14)
    PrtSc                       screenshot region
    Caps Lock key               Super          (Fn + Caps = real Caps Lock)
    Fn + F1 / F2                F11 / F12
    Fn + Esc                    bootloader (for flashing)
    Fn + LShift + RShift + Del  wipe EEPROM + restart (VIA reloads keymap)

    ── TMUX  (prefix = Ctrl-a) ──────────────────────────────────────
    prefix c                    new tab (window)
    prefix |  /  -              split left/right  /  top/bottom
    prefix h j k l              move between panes
    prefix H J K L              resize pane (repeatable)
    prefix z                    zoom pane (fullscreen toggle)
    prefix x                    close pane
    prefix 1..9                 go to tab
    Alt-h / Alt-l               previous / next tab
    prefix ,                    rename tab
    prefix [                    copy mode (vi keys, v select, y copy)
    prefix d                    detach (session "main" keeps running)
    prefix ?                    this guide in a popup

    ── YAZI  (Super+E, or `y` in a shell to cd on exit) ─────────────
    h j k l                     up / down / parent / enter
    Space                       select           y / x / p   copy / cut / paste
    a                           create (end with / for a dir)
    r                           rename           d / D       trash / delete
    /                           find             z           jump (fzf)
    .                           show hidden      o / Enter   open
    q                           quit

    ── HELIUM + VIMIUM ──────────────────────────────────────────────
    f / F                       click link / open link in new tab
    j k / d u                   scroll / half page
    H / L                       back / forward
    o / O                       open URL or bookmark (current / new tab)
    T                           search open tabs
    J / K                       previous / next tab
    yy                          copy URL         gi   focus first input
    /                           find in page     ?    Vimium help

    ── ZATHURA (pdf) / IMV (images) ─────────────────────────────────
    zathura: j k scroll, J K page, / search, Ctrl-r recolour, d dual page
    imv:     h l prev / next, + - zoom, f fullscreen, q quit

    ── TERMINAL / ON-THEME ALTERNATIVES ─────────────────────────────
    file manager      nautilus     ->  yazi              Super+E
    audio mixer       pavucontrol  ->  wiremix           Super+Ctrl+A
    wi-fi             nm-applet    ->  impala            Super+N
    system monitor    htop         ->  btop              Super+Shift+Esc
    music             spot         ->  spotify_player    Super+S
    discord           vesktop      |   discordo          Super+D / Super+Shift+D
    pdf / images      evince/eog   ->  zathura / imv
    image in terminal kitten icat  ->  chafa (`icat`)
    git               ->  lazygit;  bluetooth -> bluetuith
    images/truecolor needed?       ->  kitty             Super+Shift+Return

    ── PALETTE ──────────────────────────────────────────────────────
    live:     Noctalia settings -> Theme -> Custom palette -> t1200-amber / -green / -plasma / -lcd
              (terminal colours apply to new cool-retro-term windows; Helium on restart)
    default:  hosts/t1200/retro/default.nix  (t1200.retro.scheme)
  '';

  guide = pkgs.writeShellApplication {
    name = "t1200-guide";
    runtimeInputs = with pkgs; [jq fzf coreutils];
    text = ''
      if [ "''${1:-}" = "--window" ]; then
        exec retro-term -T t1200-guide -e t1200-guide
      fi

      render() {
        echo "── HYPRLAND  (Super = Caps Lock key) ────────────────────────────"
        hyprctl binds -j 2>/dev/null | jq -r '
          def mods(m): [
            (if ((m / 64 | floor) % 2) == 1 then "Super" else empty end),
            (if ((m / 4  | floor) % 2) == 1 then "Ctrl"  else empty end),
            (if ((m / 8  | floor) % 2) == 1 then "Alt"   else empty end),
            (if (m % 2) == 1 then "Shift" else empty end)
          ] | join("+");
          .[] | select((.description // "") != "")
              | [((mods(.modmask) | if . == "" then "" else . + "+" end) + .key), .description]
              | @tsv' \
          | awk -F'\t' '{ printf "%-27s %s\n", $1, $2 }'
        cat ${notes}
      }

      render | fzf --no-sort --layout=reverse --no-info --no-multi \
        --prompt='find> ' --header='type to filter, Esc to close' \
        --bind 'enter:ignore' || true
    '';
  };
in {
  home.packages = [guide];
}
