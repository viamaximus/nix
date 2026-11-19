{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../homeManagerModules
    ../../homeManagerModules/gaming.nix
    ../../homeManagerModules/hermes.nix
    ../../homeManagerModules/programs/profiles/workstation.nix
  ];

  features.desktop.hyprland.enable = true;
  features.desktop.noctalia.enable = true;
  features.vrcdev.enable = true;
  features.hermes.enable = true;

  home.username = "max";
  home.homeDirectory = "/home/max";

  home.packages = with pkgs; [
    hello
  ];

  # WiVRn's package ships its OpenXR manifest as share/openxr/1/openxr_wivrn.json,
  # but the standard OpenXR loader (what xrizer embeds) only ever looks for a
  # file literally named active_runtime.json under XDG_CONFIG_HOME (not
  # XDG_DATA_HOME — the OpenXR loader's manifest_file.cpp searches
  # ~/.config/openxr, never ~/.local/share/openxr) — nothing registers WiVRn
  # under that name/location on its own, so any app (native OpenXR, or
  # OpenVR-via-xrizer) fails with ERROR_RUNTIME_UNAVAILABLE even though
  # WiVRn itself is running fine. Register it explicitly.
  xdg.configFile."openxr/1/active_runtime.json".source =
    "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    #put .rc files here
  };
  # Monitor layout:
  #
  #                 [ HDMI-A-1 / Acer XV271U M3 2560x1440 ]
  #
  # [ DP-1 / Samsung ] [ DP-3 / Dell 4K scaled 1.25 ] [ DP-2 / Acer portrait ]
  wayland.windowManager.hyprland.settings = let
    hl = import ../../homeManagerModules/hypr/lua.nix {inherit lib;};
  in {
    # Japanese IME (fcitx5 + mozc); toggle with Ctrl+Space.
    on = [(hl.onStart ["fcitx5 -d -r"])];

    monitor = [
      # UP: Acer XV271U M3. hyprctl currently exposes 143.91Hz on HDMI-A-1, not 180Hz.
      {
        output = "HDMI-A-1";
        mode = "2560x1440@143.91";
        position = "2176x0";
        scale = "1";
      }
      # LEFT: Samsung C27F390
      {
        output = "DP-1";
        mode = "1920x1080@60";
        position = "0x1764";
        scale = "1";
      }
      # MIDDLE: Dell S3225QS, scaled
      {
        output = "DP-3";
        mode = "3840x2160@120";
        position = "1920x1440";
        scale = "1.25";
      }
      # RIGHT: Acer XFA240, portrait
      {
        output = "DP-2";
        mode = "1920x1080@144";
        position = "4992x1248";
        scale = "1";
        transform = 1;
      }
    ];

    workspace_rule = [
      {
        workspace = "1";
        monitor = "DP-1";
      }
      {
        workspace = "2";
        monitor = "DP-3";
      }
      {
        workspace = "3";
        monitor = "DP-2";
      }
      {
        workspace = "4";
        monitor = "HDMI-A-1";
      }
    ];

    # VRR: fullscreen only. Best default for games.
    config = {
      misc.vrr = 2;
      debug.vfr = true;
    };

    # make games always open on center monitor
    window_rule = [
      {
        name = "steam-games-center";
        match.class = "steam_app_[0-9]+";
        monitor = "DP-3";
        workspace = "2";
      }
      {
        name = "gamescope-center";
        match.class = "gamescope";
        monitor = "DP-3";
      }
    ];
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
