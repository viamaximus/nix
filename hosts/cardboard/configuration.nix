# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:
let
  wallpaperConfig = import ./current-wallpaper.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      ../../nixosModules/automount.nix
      ../../nixosModules/fonts.nix
      ../../nixosModules/stylix.nix
      ../../nixosModules/nix-settings.nix
      ../../nixosModules/audio.nix
    ];

  stylix = {
    image = wallpaperConfig.currentWallpaper;
    cursor = {
      name = "Catppuccin-Macchiato-Mauve";
      package = pkgs.catppuccin-cursors.macchiatoMauve;
      size = 24;
    };
  };


  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      nix = import ./home.nix;
    };
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  # Nix settings provided by ../../nixosModules/nix-settings.nix

  # Bootloader.
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      devices = ["nodev"];
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "cardboard"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.zsh.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  programs.xwayland.enable = true;
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  security.pam.services.hyprlock = {};

  services.tailscale.enable = true;

  services.displayManager.ly.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Audio provided by ../../nixosModules/audio.nix
  features.bluetooth.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nix = {
    isNormalUser = true;
    description = "nix";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" "video" "input" "dialout" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  virtualisation.docker.enable = true;

  programs.ssh.startAgent = true;

  # Install firefox.
  programs.firefox.enable = true;

  # allowUnfree provided by ../../nixosModules/nix-settings.nix
  environment.systemPackages = with pkgs; [
    neovim
    kitty
    git
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?

}
