{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  commonPkgs = with pkgs; [
    file
    openssh
    yubikey-manager

    claude-code

    wget
    python3
    alejandra

    nextcloud-client
    cp210x-program
    signal-desktop
    obsidian
    rpi-imager
    qbittorrent
    protonvpn-gui

    cmake
    ninja
    gnumake
    gcc13
    pkg-config

    lazygit
    git
    gh

    impala
    fd
    tree

    #archive tools
    zip
    unzip
    p7zip

    #utils
    ripgrep
    yq-go
    htop
    usbutils

    #misc
    libnotify
    nodejs_22

    # nix tools
    comma
    nix-index

    # command correction
    pay-respects

    # clipboard (wayland)
    wl-clipboard
  ];
in {
  home.packages = commonPkgs;

  programs = {
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      prefix = "C-a";
      terminal = "tmux-256color";
      escapeTime = 0;
      baseIndex = 1;
      extraConfig = ''
        mouse on

        # True color support
        set -ag terminal-overrides ",xterm-256color:RGB"
        set -ag terminal-overrides ",xterm-kitty:RGB"

        # --- Status bar ---
        set -g status-position bottom
        set -g status-interval 5
        set -g status-style "bg=#1e2030,fg=#cad3f5"

        # Left: session name
        set -g status-left-length 30
        set -g status-left "#[bg=#ed8796,fg=#181926,bold] #S #[bg=#1e2030,fg=#ed8796]"

        # Right: directory, git branch, time
        set -g status-right-length 80
        set -g status-right "#[fg=#a6da95]#[bg=#a6da95,fg=#181926] #{b:pane_current_path} #[fg=#7dc4e4]#[bg=#7dc4e4,fg=#181926] #(cd #{pane_current_path} && git branch --show-current 2>/dev/null || echo '-') #[fg=#b7bdf8]#[bg=#b7bdf8,fg=#181926] %H:%M "

        # Window tabs
        set -g window-status-format "#[fg=#494d64]#[bg=#494d64,fg=#cad3f5] #I #W #[fg=#494d64,bg=#1e2030]"
        set -g window-status-current-format "#[fg=#f5a97f]#[bg=#f5a97f,fg=#181926,bold] #I #W #[fg=#f5a97f,bg=#1e2030]"
        set -g window-status-separator ""

        # Pane borders
        set -g pane-border-style "fg=#494d64"
        set -g pane-active-border-style "fg=#b7bdf8"
      '';
    };

    btop.enable = true; # replacement of htop/nmon
    eza = {
      enable = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
      ];
    };
    jq.enable = true; # A lightweight and flexible command-line JSON processor
    aria2.enable = true;
  };
}
