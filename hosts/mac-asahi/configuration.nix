{
  inputs,
  pkgs,
  lib,
  config,
  hyprland,
  ...
}:
let
  wallpaperConfig = import ./current-wallpaper.nix;
in {
  imports = [
    ./hardware-configuration.nix
	inputs.home-manager.nixosModules.home-manager
	inputs.stylix.nixosModules.stylix
	../../nixosModules/automount.nix
	../../nixosModules/fonts.nix
	../../nixosModules/stylix.nix
  ];

  stylix = {
    image = wallpaperConfig.currentWallpaper;
    cursor = {
      name = "Catppuccin-Macchiato-Mauve";
      package = pkgs.catppuccin-cursors.macchiatoMauve;
      size = 24;
    };
  };

  ##
  # home manger
  ##
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
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

  # Enable x86_64 emulation for Luckfox SDK toolchain
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  # Enable nix-ld for dynamic linker support (FHS compatibility)
  programs.nix-ld.enable = true;

  # For x86_64 emulation under QEMU, create /lib64 with x86_64 glibc
  system.activationScripts.setup-x86_64-ld = lib.mkIf pkgs.stdenv.isAarch64 ''
    mkdir -p /lib64
    ln -sfn ${pkgs.pkgsCross.gnu64.glibc}/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
  '';

  # Create /bin/bash symlink for SDK Makefiles (FHS compatibility)
  system.activationScripts.setup-bin-bash = ''
    mkdir -p /bin
    ln -sfn ${pkgs.bash}/bin/bash /bin/bash
  '';

  # Create /usr symlinks for SDK build dependencies (FHS compatibility)
  system.activationScripts.setup-usr-fhs = ''
    mkdir -p /usr/include /usr/lib

    # Link ncurses headers
    for file in ${pkgs.ncurses.dev}/include/*; do
      ln -sfn "$file" /usr/include/$(basename "$file")
    done

    # Link ncurses libraries
    for file in ${pkgs.ncurses}/lib/libncurses*.so*; do
      [ -e "$file" ] && ln -sfn "$file" /usr/lib/$(basename "$file")
    done
  '';

  # Make gcc look in /usr/include and /usr/lib for FHS compatibility
  environment.sessionVariables = {
    NIX_CFLAGS_COMPILE = "-I/usr/include";
    NIX_LDFLAGS = "-L/usr/lib";
  };

  # Disable P2P support in brcmfmac WiFi driver to suppress boot errors
  boot.extraModprobeConfig = ''
    options brcmfmac p2pon=0
  '';

  networking.hostName = "mac-asahi";
  networking.networkmanager.enable = true;

  ############################################
  # Printing
  ############################################
  services.printing.enable = true;

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
  # Bluetooth
  ############################################
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  ############################################
  # Hyprland 0.51.0 from flake (PINNED)
  ############################################
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  ############################################
  # Login manager: greetd → Hyprland as max
  ############################################
	# services.greetd = {
  	#   enable = true;
  	#   settings.default_session = {
  	#     command = "Hyprland";
  	#     user = "max";
  	#   };
  	# };
  services.displayManager.ly.enable = true;

  services.seatd.enable = true;

  services.tailscale.enable = true;

  services.openssh.enable = true;

  services.logind.settings.Login.HandleLidSwitch = "lock";

  ############################################
  # Luckfox Pico udev rules
  ############################################
  services.udev.extraRules = ''
    # Common USB-to-serial adapters (FTDI, CH340, CP210x, Prolific)
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", MODE="0666", GROUP="dialout"

    # Rockchip devices (Luckfox RV1103) - Serial
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2207", MODE="0666", GROUP="dialout"

    # Rockchip devices (Luckfox RV1103) - ADB
    SUBSYSTEM=="usb", ATTR{idVendor}=="2207", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="2207", ATTR{idProduct}=="0006", SYMLINK+="android_adb"
    SUBSYSTEM=="usb", ATTR{idVendor}=="2207", ATTR{idProduct}=="0006", SYMLINK+="android%n"

    # Generic USB serial devices (fallback)
    KERNEL=="ttyUSB[0-9]*", MODE="0666", GROUP="dialout"
    KERNEL=="ttyACM[0-9]*", MODE="0666", GROUP="dialout"
  '';

  ############################################
  # User
  ############################################
  users.users.max = {
    isNormalUser = true;
    description = "max";
    extraGroups = ["wheel" "networkmanager" "audio" "video" "input" "docker" "dialout" "plugdev" ];
    shell = pkgs.fish;
  };

  virtualisation.docker.enable = true;

  programs.fish.enable = true;

  security.sudo.enable = true;

  programs.ssh.startAgent = true;

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
    experimental-features = ["nix-command" "flakes"];

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

  # This is about defaults/migrations, not package pinning
  system.stateVersion = "25.05";
}
