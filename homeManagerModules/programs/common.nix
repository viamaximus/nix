{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv) isAarch64 isx86_64;

  universalPkgs = with pkgs; [
    # Essential CLI tools
    file
    git
    gh
    lazygit

    # File management & search
    ripgrep
    fd
    tree

    # Archive tools
    zip
    unzip
    p7zip

    # System monitoring
    htop
    usbutils

    # Development basics
    python3
    nodejs_22
    cmake
    ninja
    gnumake
    gcc13
    pkg-config

    # Utilities
    libnotify
    yq-go
    impala

    # Browsers
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ungoogled-chromium

    # Essential GUI apps
    nautilus
    kitty
  ];

  x86Pkgs = with pkgs; [
    discord
  ];

  armPkgs = with pkgs; [
    discordo
    vesktop
  ];
in {
  home.packages =
    universalPkgs
    ++ lib.optionals isx86_64 x86Pkgs
    ++ lib.optionals isAarch64 armPkgs;

  programs = {
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      extraConfig = "mouse on";
    };

    btop.enable = true; # replacement of htop/nmon
    eza.enable = true; # A modern replacement for 'ls'
    jq.enable = true; # A lightweight and flexible command-line JSON processor
    aria2.enable = true;
  };
}
