{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.kitty = {
    enable = true;
    font = {
      name = lib.mkForce "JetBrainsMono Nerd Font";
      size = lib.mkForce 11;
    };
    settings = {
      confirm_os_window_close = 0;
      copy_on_select = true;
      clipboard_control = "write-clipboard read-clipboard write-primary read-primary";

      background_opacity = lib.mkForce "0.85";
      background_blur = lib.mkForce 32;

      window_padding_width = lib.mkForce 8;

      cursor_shape = lib.mkForce "beam";
      cursor_beam_thickness = lib.mkForce "1.5";
      cursor_blink_interval = lib.mkForce 0;

      enable_audio_bell = lib.mkForce false;

      tab_bar_style = lib.mkForce "powerline";
      tab_powerline_style = lib.mkForce "slanted";
    };
  };
}
