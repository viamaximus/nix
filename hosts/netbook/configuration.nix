{
  config,
  pkgs,
  inputs,
  ...
}: let
  wallpaperConfig = import ./current-wallpaper.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    ../../nixosModules/fonts.nix
    ../../nixosModules/stylix.nix
    ../../nixosModules/nix-settings.nix
    ../../nixosModules/audio.nix
  ];

  stylix = {
    image = wallpaperConfig.currentWallpaper;
    cursor = {
      name = "catppuccin-macchiato-mauve-cursors";
      package = pkgs.catppuccin-cursors.macchiatoMauve;
      size = 24;
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      max = import ./home.nix;
    };
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

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

  networking.hostName = "netbook";

  networking = {
    networkmanager.enable = true;
    useNetworkd = false;
  };
  systemd.network.wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };
  hardware.bluetooth.powerOnBoot = true;

  # Power management for laptop/netbook
  # services.thermald.enable = true;
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "powersave";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
  #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #   };
  # };

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

  # Enable the X11 windowing system and GNOME
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # GNOME-specific optimizations
  services.gnome.core-utilities.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Exclude some GNOME apps we don't need on a minimal netbook
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany  # gnome web browser (we have firefox)
    geary     # email client
    gnome-music
    gnome-photos
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Audio + Bluetooth provided by ../../nixosModules/audio.nix

  users.users.max = {
    isNormalUser = true;
    description = "max";
    shell = pkgs.zsh;
    group = "max";
    extraGroups = ["networkmanager" "wheel" "audio" "video" "input"];
    packages = with pkgs; [];
  };
  users.groups.max = {};

  # programs.ssh.startAgent = true;

  # Nix settings + allowUnfree provided by ../../nixosModules/nix-settings.nix
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    kitty
    git
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
