{config, pkgs, lib, ...}: let
  hl = import ./lua.nix {inherit lib;};
  cliphist-wofi = pkgs.writeShellScriptBin "cliphist-wofi" ''
    if ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Clipboard" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy; then
      exit 0
    fi
  '';
in {
  config = lib.mkIf (config.features.desktop.hyprland.enable && !config.features.desktop.noctalia.enable) {
    home.packages = with pkgs; [
      cliphist
      cliphist-wofi
    ];

    wayland.windowManager.hyprland.settings = {
      on = [
        (hl.onStart [
          "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
          "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
        ])
      ];
      bind = [
        (hl.bind "${hl.mod} + V" (hl.exec "cliphist-wofi"))
      ];
    };
  };
}
