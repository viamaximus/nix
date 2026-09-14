{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.kitty = {
    enable = true;
    font = {
      name = lib.mkForce "FiraCode Nerd Font Mono";
      size = lib.mkForce 11;
    };
    settings = {
      confirm_os_window_close = 0;
      copy_on_select = true;
      clipboard_control = "write-clipboard read-clipboard write-primary read-primary";

      background_opacity = lib.mkForce "0.85";
      background_blur = lib.mkForce 32;

      # --- Cutie Pro (https://github.com/mbadolato/iTerm2-Color-Schemes) ---
      background = lib.mkForce "#181818";
      foreground = lib.mkForce "#d5d0c9";
      cursor = lib.mkForce "#efc4cd";
      cursor_text_color = lib.mkForce "#181818";
      selection_background = lib.mkForce "#d5d0c9";
      selection_foreground = lib.mkForce "#181818";
      color0 = lib.mkForce "#000000";
      color1 = lib.mkForce "#f56e7f";
      color2 = lib.mkForce "#bec975";
      color3 = lib.mkForce "#f58669";
      color4 = lib.mkForce "#42d9c5";
      color5 = lib.mkForce "#d286b7";
      color6 = lib.mkForce "#37cb8a";
      color7 = lib.mkForce "#d5c3c3";
      color8 = lib.mkForce "#88847f";
      color9 = lib.mkForce "#e5a1a3";
      color10 = lib.mkForce "#e8d6a7";
      color11 = lib.mkForce "#f1bb79";
      color12 = lib.mkForce "#80c5de";
      color13 = lib.mkForce "#b294bb";
      color14 = lib.mkForce "#9dccbb";
      color15 = lib.mkForce "#ffffff";
      active_tab_foreground = lib.mkForce "#181818";
      active_tab_background = lib.mkForce "#d5d0c9";
      inactive_tab_foreground = lib.mkForce "#88847f";
      inactive_tab_background = lib.mkForce "#0f0f0f";

      window_padding_width = lib.mkForce 8;

      cursor_shape = lib.mkForce "beam";
      cursor_beam_thickness = lib.mkForce "1.5";
      cursor_blink_interval = lib.mkForce 0;

      enable_audio_bell = lib.mkForce false;

      # --- Tab bar ---
      tab_bar_style = lib.mkForce "powerline";
      tab_powerline_style = lib.mkForce "slanted";
      tab_title_template = lib.mkForce "{index}: {title} [{num_windows}]";
      active_tab_font_style = lib.mkForce "bold";

      # --- Ligatures ---
      disable_ligatures = lib.mkForce "never";

      # --- Layouts (splits & windows) ---
      enabled_layouts = lib.mkForce "splits,tall,grid,stack";

      # --- URL handling ---
      url_style = lib.mkForce "curly";
      open_url_with = lib.mkForce "default";
      detect_urls = lib.mkForce true;
      show_hyperlink_targets = lib.mkForce true;
      url_prefixes = lib.mkForce "file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh";

      # --- Scrollback ---
      scrollback_lines = lib.mkForce 10000;
      scrollback_pager_history_size = lib.mkForce 100;

      # --- Remote control (for scripting kitty) ---
      allow_remote_control = lib.mkForce "socket-only";
      listen_on = lib.mkForce "unix:/tmp/kitty-{kitty_pid}";

      # --- Window chrome ---
      window_border_width = lib.mkForce "1px";
      draw_minimal_borders = lib.mkForce true;
      inactive_text_alpha = lib.mkForce "0.7";
    };

    keybindings = {
      # --- Splits (using splits layout) ---
      "ctrl+shift+enter" = "launch --location=hsplit --cwd=current";
      "ctrl+shift+backslash" = "launch --location=vsplit --cwd=current";

      # --- Font size ---
      "ctrl+shift+equal" = "change_font_size all +1.0";
      "ctrl+shift+minus" = "change_font_size all -1.0";
      "ctrl+shift+0" = "change_font_size all 0";

      # --- Navigate splits ---
      "ctrl+shift+h" = "neighboring_window left";
      "ctrl+shift+l" = "neighboring_window right";
      "ctrl+shift+k" = "neighboring_window up";
      "ctrl+shift+j" = "neighboring_window down";

      # --- Resize splits ---
      "ctrl+alt+h" = "resize_window narrower 3";
      "ctrl+alt+l" = "resize_window wider 3";
      "ctrl+alt+k" = "resize_window taller 3";
      "ctrl+alt+j" = "resize_window shorter 3";

      # --- Move splits ---
      "ctrl+shift+alt+h" = "move_window left";
      "ctrl+shift+alt+l" = "move_window right";
      "ctrl+shift+alt+k" = "move_window up";
      "ctrl+shift+alt+j" = "move_window down";

      # --- Layouts ---
      "ctrl+shift+z" = "toggle_layout stack";
      "ctrl+shift+o" = "next_layout";

      # --- Tabs ---
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+1" = "goto_tab 1";
      "ctrl+shift+2" = "goto_tab 2";
      "ctrl+shift+3" = "goto_tab 3";
      "ctrl+shift+4" = "goto_tab 4";
      "ctrl+shift+5" = "goto_tab 5";


      # --- Scrollback pager (pipe to bat/less) ---
      "ctrl+shift+g" = "show_scrollback";
      "ctrl+shift+f" = "launch --stdin-source=@screen_scrollback --type=overlay ${pkgs.bat}/bin/bat --paging=always --style=plain";

      # --- Kittens ---
      "ctrl+shift+u" = "kitten unicode_input";
      "ctrl+shift+e" = "kitten hints --type url --program default";
      "ctrl+shift+p>f" = "kitten hints --type path --program -";
      "ctrl+shift+p>h" = "kitten hints --type hash --program -";
      "ctrl+shift+p>l" = "kitten hints --type line --program -";
      "ctrl+shift+p>w" = "kitten hints --type word --program -";

      # --- Diff kitten ---
      "ctrl+shift+d" = "kitten diff";

      # --- Hyperlinked grep (results open in editor) ---
      "ctrl+shift+slash" = "launch --type=overlay --cwd=current kitten hyperlinked_grep";

      # --- File chooser ---
      "ctrl+shift+period" = "launch --type=overlay kitten choose_files --cwd=current";

      # --- Clipboard kitten ---
      "ctrl+shift+c>s" = "kitten clipboard --set";
      "ctrl+shift+c>g" = "kitten clipboard --get";

      # --- SSH kitten ---
      "ctrl+shift+s" = "launch --type=tab kitten ssh";

      # --- File transfer ---
      "ctrl+shift+p>t" = "kitten transfer";
    };
  };
}
