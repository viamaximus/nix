# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  config,
  pkgs,
  inputs,
  hostInventory,
  ...
}: let
  wallpaperConfig = import ./current-wallpaper.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    ../../nixosModules/terminal.nix
    ../../nixosModules/networking.nix
    ../../nixosModules/automount.nix
    ../../nixosModules/fonts.nix
    ../../nixosModules/stylix.nix
    ../../nixosModules/nix-settings.nix
    ../../nixosModules/audio.nix
    ../../nixosModules/ssh-web-keys.nix
    ../../nixosModules/agenix.nix
    ../../nixosModules/secrets.nix
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Theming on cardboard is handled by Noctalia (wallpaper-dynamic colors +
  # templates), so Stylix is disabled here. GTK/icon/font/cursor are re-homed in
  # homeManagerModules/noctalia/apptheming.nix.
  stylix.enable = false;

  home-manager = {
    extraSpecialArgs = {inherit inputs hostInventory;};
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

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1003", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1004", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1005", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1006", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1007", MODE="0666"
  '';

  programs.zsh.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  programs.xwayland.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  programs.hyprlock.enable = true;
  security.pam.services.hyprlock = {};
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  # Noctalia greeter (greetd-based) replaces ly. The module enables greetd and
  # sets the session command automatically. Locking is handled by Noctalia's
  # own lock screen (so no system-level hyprlock here).
  programs.noctalia-greeter = {
    enable = true;
    package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      output = {
        name = "HDMI-A-1";
        scale = 1;
      };
      cursor = {
        theme = "catppuccin-mocha-mauve-cursors";
        size = 24;
        path = "/run/current-system/sw/share/icons";
      };
      keyboard.layout = "us";
    };
  };
  # Noctalia status integrations.
  services.upower.enable = true;

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
    extraGroups = ["networkmanager" "wheel" "docker" "audio" "video" "input" "dialout"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  virtualisation.docker.enable = true;

  programs.ssh.startAgent = true;

  # Secret-service backend for git-credential-manager's token store. Keep the
  # plain OpenSSH agent (used for yubikey commit signing), not gcr's.
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  # allowUnfree provided by ../../nixosModules/nix-settings.nix
  environment.systemPackages = with pkgs; [
    neovim
    kitty
    git
    catppuccin-cursors.mochaMauve # greeter cursor theme (system-wide for greetd)
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  viamaximus.sshWebKeys.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
