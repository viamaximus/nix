{ inputs, pkgs, lib, config, hyprland, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  ##
  # home manger
  ##
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      max = import ./home.nix;
    };
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };


  ############################################
  # Apple Silicon / Asahi (local firmware)
  ############################################
  hardware.asahi = {
    enable = true;
    setupAsahiSound = true;
    peripheralFirmwareDirectory = ../../firmware; # path literal
  };
  
  boot.kernelParams = [
    "apple_dcp.show_notch=1"
  ];

  ############################################
  # Boot / basics
  ############################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "mac-asahi";
  networking.networkmanager.enable = true;

  ############################################
  # Audio stack
  ############################################
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  ############################################
  # Hyprland 0.51.0 from flake (PINNED)
  ############################################
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.system}.hyprland;
    # If you ever want their NixOS module too:
    # extraConfig = '' ... '';
  };

  ############################################
  # Login manager: greetd → Hyprland as max
  ############################################
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "Hyprland";
      user = "max";
    };
  };

  services.seatd.enable = true;

  ############################################
  # User
  ############################################
  users.users.max = {
    isNormalUser = true;
    description = "max";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "docker" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  security.sudo.enable = true;

  ############################################
  # System packages (minimal)
  ############################################
  environment.systemPackages = with pkgs; [
    foot
    kitty
    neovim
    mesa-demos
    vulkan-tools
    wayland-utils
    wl-clipboard
    git
    firefox
  ];
  nixpkgs.config.allowUnfree = true;

  ############################################
  # Nix / Cachix
  ############################################
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];

    trusted-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];

    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  ############################################
  # Locale / time
  ############################################
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";


  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.noto
    nerd-fonts.hack
    nerd-fonts.ubuntu
  ];


  # This is about defaults/migrations, not package pinning
  system.stateVersion = "25.05";
}

