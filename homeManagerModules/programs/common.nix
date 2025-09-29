{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
  hyprEnabled = config.my.hyprland.enable or false;
  terminalPkg = config.my.hyprland.terminalPkg or null;

  # convenience
  hasPkg = name: lib.hasAttr name pkgs;
  opt    = lib.optionals;
in
{
  config = {
    # ---------- CLI / GUI tools ----------
    home.packages =
      (with pkgs; [
        # dev & git
        lazygit
        lazydocker

        # finders
        fd
        ripgrep

        # system info
        fastfetch
        neofetch
        htop
        tree
        screen

        # archives
        zip
        unzip
        p7zip

        # yaml/json tools
        yq-go

        # k8s / containers (CLI only; daemon handled by OS)
        kubectl
        docker-compose
      ])
      # ---- Linux-only bits ----
      ++ opt isLinux (with pkgs; [
        usbutils
        # `nmtui` lives in this package:
        networkmanager
        libnotify
      ])

      # niche tools if present in this nixpkgs
      ++ opt (isLinux && hasPkg "cp210x-program") [ pkgs.cp210x-program ]
      ++ opt (isLinux && hasPkg "rpi-imager")     [ pkgs.rpi-imager ]
      ++ opt (isLinux && hasPkg "caligula")       [ pkgs.caligula ]
      ++ opt (isLinux && hasPkg "impala")         [ pkgs.impala ]
      ++ opt (isLinux && hasPkg "qflipper")       [ pkgs.qflipper ]

      # Discord is often unavailable on aarch64; add only if supported here
      ++ opt (isLinux && hasPkg "discord" &&
              lib.elem pkgs.stdenv.hostPlatform.system pkgs.discord.meta.platforms)
         [ pkgs.discord ]

      # ---- Hyprland-adjacent apps (only when Hypr is enabled on Linux) ----
      ++ opt (isLinux && hyprEnabled) (
        (with pkgs; [
          wofi
          waybar
          nautilus
          libnotify
        ])
        # use your chosen terminal (kitty on most hosts, foot on mac-asahi)
        ++ opt (terminalPkg != null) [ terminalPkg ]
      );

    # ---------- HM program modules ----------
    programs = {
      tmux = {
        enable   = true;
        clock24  = true;
        keyMode  = "vi";
        extraConfig = "set -g mouse on";
      };

      btop.enable = true;   # nice htop alternative
      eza.enable  = true;   # modern ls
      jq.enable   = true;   # JSON processor
      aria2.enable = true;  # downloader
      # ssh.enable = true;  # uncomment if you want HM to manage ssh config
    };

    # ---------- User services ----------
    services = {
      # automount / tray helper – only on Linux
      udiskie = lib.mkIf isLinux { enable = true; };
    };
  };
}

