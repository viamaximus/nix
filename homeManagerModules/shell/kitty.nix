{
  config,
  pkgs,
  ...
}: {
  #Kitty config
  programs.kitty = {
    enable = true;
		# themeFile = "Catppuccin-Macchiato";
		# font.name = "JetBrainsMono Nerd Font";
    settings = {
      confirm_os_window_close = -0;
      copy_on_select = true;
      clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
    };
  };
}
