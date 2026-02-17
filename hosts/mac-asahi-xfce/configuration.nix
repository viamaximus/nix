{
  inputs,
  pkgs,
  lib,
  config,
  chicago95-src,
  ...
}: {
  imports = [
    ../mac-asahi/hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    ../../nixosModules/automount.nix
    ../../nixosModules/fonts.nix
    ../../nixosModules/nix-settings.nix
    ../../nixosModules/audio.nix
  ];

  # Disable Stylix — Chicago95 handles all theming
  stylix.enable = false;

  home-manager = {
    extraSpecialArgs = {inherit inputs chicago95-src;};
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
    peripheralFirmwareDirectory = ../../firmware;
  };

  boot.kernelParams = [
    "apple_dcp.show_notch=1"
  ];

  ############################################
  # Boot / basics
  ############################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.binfmt.emulatedSystems = ["x86_64-linux"];

  programs.nix-ld.enable = true;

  system.activationScripts.setup-x86_64-ld = lib.mkIf pkgs.stdenv.isAarch64 ''
    mkdir -p /lib64
    ln -sfn ${pkgs.pkgsCross.gnu64.glibc}/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
  '';

  system.activationScripts.setup-bin-bash = ''
    mkdir -p /bin
    ln -sfn ${pkgs.bash}/bin/bash /bin/bash
  '';

  system.activationScripts.setup-usr-fhs = ''
    mkdir -p /usr/include /usr/lib

    for file in ${pkgs.ncurses.dev}/include/*; do
      ln -sfn "$file" /usr/include/$(basename "$file")
    done

    for file in ${pkgs.ncurses}/lib/libncurses*.so*; do
      [ -e "$file" ] && ln -sfn "$file" /usr/lib/$(basename "$file")
    done
  '';

  environment.sessionVariables = {
    NIX_CFLAGS_COMPILE = "-I/usr/include";
    NIX_LDFLAGS = "-L/usr/lib";
  };

  boot.extraModprobeConfig = ''
    options brcmfmac feature_disable=1 roamoff=1
  '';

  networking.hostName = "mac-asahi";
  networking.networkmanager.enable = true;

  services.printing.enable = true;

  # Audio + Bluetooth provided by ../../nixosModules/audio.nix

  ############################################
  # XFCE Desktop (instead of Hyprland)
  ############################################
  services.xserver.enable = true;
  services.xserver.dpi = 192;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  services.tailscale.enable = true;

  services.openssh.enable = true;

  services.logind.settings.Login.HandleLidSwitch = "lock";

  ############################################
  # Luckfox Pico udev rules
  ############################################
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2207", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="usb", ATTR{idVendor}=="2207", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="2207", ATTR{idProduct}=="0006", SYMLINK+="android_adb"
    SUBSYSTEM=="usb", ATTR{idVendor}=="2207", ATTR{idProduct}=="0006", SYMLINK+="android%n"
    KERNEL=="ttyUSB[0-9]*", MODE="0666", GROUP="dialout"
    KERNEL=="ttyACM[0-9]*", MODE="0666", GROUP="dialout"
  '';

  ############################################
  # User
  ############################################
  users.users.max = {
    isNormalUser = true;
    description = "max";
    extraGroups = ["wheel" "networkmanager" "audio" "video" "input" "docker" "dialout"];
    shell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;

  programs.zsh.enable = true;

  security.sudo.enable = true;

  programs.ssh.startAgent = true;

  ############################################
  # System packages
  ############################################
  environment.systemPackages = with pkgs; [
    kitty
    neovim
    git
    firefox
  ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "25.05";
}
