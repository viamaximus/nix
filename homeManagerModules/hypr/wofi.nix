{
  config,
  pkgs,
  ...
}: {
  programs.wofi.enable = true;
	# xdg.configFile."wofi/style.css".source = ./wofi-style.css;
}
