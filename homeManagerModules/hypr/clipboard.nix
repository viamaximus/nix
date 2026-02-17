{config, pkgs, lib, ...}: let
  cliphist-wofi = pkgs.writeShellScriptBin "cliphist-wofi" ''
    if ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Clipboard" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy; then
      exit 0
    fi
  '';
in {
  config = lib.mkIf config.features.desktop.hyprland.enable {
    home.packages = with pkgs; [
      cliphist
      cliphist-wofi
    ];

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
        "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
      ];
      bind = [
        "$mainMod, V, exec, cliphist-wofi"
      ];
    };
  };
}
