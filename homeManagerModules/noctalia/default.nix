{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.desktop.noctalia;
in {
  imports = [
    inputs.noctalia.homeModules.default
    ./theme.nix
    ./apptheming.nix
    ./bar.nix
    ./panels.nix
    ./services.nix
    ./wallpaper.nix
    ./plugins.nix
  ];

  options.features.desktop.noctalia.enable =
    mkEnableOption "Noctalia shell (Quickshell bar + panels; compositor-agnostic)";

  config = mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    # Plugin runtime dependencies (screen recorder + bongocat input reactivity).
    home.packages = with pkgs; [
      gpu-screen-recorder
      evtest
    ];
  };
}
