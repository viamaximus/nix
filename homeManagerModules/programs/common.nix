{ 
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [

  fastfetch
  neofetch
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

  #homelabby stuff
  docker-compose
  kubectl

  #social
  discord

  #adding some hyprland stuff here for now
  wofi
  nautilus
  kitty
  waybar
  libnotify

    #nmtui -- whats the package name??

  qFlipper
  ];

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
  
  services = {
    # auto mount usb drives
    udiskie.enable = true;
  };
}
