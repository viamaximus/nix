{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv) isAarch64 isx86_64;

  universalPkgs = with pkgs; [
    python3
    alejandra

    cp210x-program

    signal-desktop
    # cosign

    obsidian

    cmake
    ninja
    gnumake
    gcc13
    pkg-config
    spdlog
    fmt

    lazygit
    git
    gh

    lazydocker
    docker
    docker-buildx
    docker-compose
    impala
    fd

    caligula
    # rpi-imager

    fastfetch
    neofetch
    tree

    screen
    tio

    #archive tools
    zip
    unzip
    p7zip

    # usbimager

    #utils
    ripgrep
    yq-go
    htop
    usbutils
    feh

    #misc
    libnotify
    nodejs_22
    cbonsai
    cowsay

    #bluetooth
    bluetuith

    #audio
    pwvucontrol

    #EVIL
    # google-chrome
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ungoogled-chromium

    #homelabby stuff
    kubectl

    #social
    # discord
    # element-desktop

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
    eza.enable = true; # A modern replacement for ‘ls’
    jq.enable = true; # A lightweight and flexible command-line JSON processor
    #ssh.enable = true;
    aria2.enable = true;
  };
}
