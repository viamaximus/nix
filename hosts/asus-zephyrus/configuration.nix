# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
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
      #useOSProber = true;
      efiSupport = true;
      devices = ["nodev"];
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #fix amd gpu
  boot.kernelParams = ["amdgpu.dcdebugmask=0x10"];

  networking.hostName = "asus-zephyrus"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  #Asus Laptop Stuff
  services = {
    supergfxd = {
      enable = true;
    };
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

  #   boot.loader.grub.theme = pkgs.stdenv.mkDerivation {
  #   pname = "distro-grub-themes";
  #   version = "3.1";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "AdisonCavani";
  #     repo = "distro-grub-themes";
  #     rev = "v3.1";
  #     hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
  #   };
  #   installPhase = "cp -r customize/nixos $out";
  # };

  services.displayManager.ly.enable = true;

  services.tailscale.enable = true;

  # Gaming support
  programs.gamemode.enable = true;
  programs.steam.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Audio + Bluetooth provided by ../../nixosModules/audio.nix

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.max = {
    isNormalUser = true;
    description = "max";
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "docker" "audio" "video" "input" "dialout"];
  };

  # virtualisation.docker.enable = true;

  programs.ssh.startAgent = true;

  services.openssh.enable = true;

  services.logind.settings.Login.HandleLidSwitch = "lock";

  # Nix settings + allowUnfree provided by ../../nixosModules/nix-settings.nix
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    kitty
    git
  ];

  #  enable virtualbox virtualization
  #  virtualisation.virtualbox.host.enable = true;
  #  virtualisation.virtualbox.host.enableExtensionPack = true;
  #  users.extraGroups.vboxusers.members = [ "max" ];
  virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
