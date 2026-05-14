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
  ];
in {
  home.packages = commonPkgs;

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
    aria2.enable = true;
  };
}
