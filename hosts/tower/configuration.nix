{
  config,
  pkgs,
  inputs,
  hostInventory,
  ...
}: let
  wallpaperConfig = import ./current-wallpaper.nix;
  truenasShare = share: {
    device = "//192.168.1.101/${share}";
    fsType = "cifs";
    options = [
      "credentials=/etc/samba/truenas-creds"
      "uid=max"
      "gid=max"
      "iocharset=utf8"
      "vers=3.0"
      "x-systemd.automount"
      "noauto"
      "_netdev"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=10s"
    ];
  };
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
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Low-latency PipeWire for gaming (from fufexan/nix-gaming).
  services.pipewire.lowLatency.enable = true;
  nix.settings = {
    extra-substituters = ["https://nix-gaming.cachix.org"];
    extra-trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  # Theming on tower is handled by Noctalia (wallpaper-dynamic colors + templates),
  # so Stylix is disabled here. GTK/icon/font/cursor are re-homed in
  # homeManagerModules/noctalia/apptheming.nix.
  stylix.enable = false;

  home-manager = {
    extraSpecialArgs = {inherit inputs hostInventory;};
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

  # NOTE: do NOT use linuxPackages_latest with NVIDIA — the bleeding-edge
  # kernel (7.1.x) outpaces the NVIDIA driver and the kernel module fails to
  # compile. Track the nixpkgs default kernel, which is kept NVIDIA-compatible.
  boot.kernelPackages = pkgs.linuxPackages;

  # Keep the HDA codec awake — power-saving makes the Dell HDMI audio pop and
  # leaves artifacts for a second or two after audio pauses/stops.
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  networking.hostName = "tower"; # Define your hostname.

  networking = {
    networkmanager.enable = true;
    # tailscale0 trust + UDP port handled by ../../nixosModules/networking.nix
    useNetworkd = false;
  };
  systemd.network.wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };
  hardware.bluetooth.powerOnBoot = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1003", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1004", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1005", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1006", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1007", MODE="0666"
  '';

  boot.blacklistedKernelModules = ["nouveau"];

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/4808c298-cd75-4cbd-bdef-71c063463b2e";
    fsType = "ext4";
    options = [
      "noatime"
      "discard"
    ];
  };

  # TrueNAS SMB shares (192.168.1.101). Mounted on-demand (x-systemd.automount)
  # since TrueNAS isn't always up. Credentials live outside the Nix store at
  # /etc/samba/truenas-creds (root:root, mode 600) — not committed to git.
  fileSystems."/mnt/truenas/plex-media" = truenasShare "plex-media";
  fileSystems."/mnt/truenas/terashare" = truenasShare "terashare";
  fileSystems."/mnt/truenas/turboshare" = truenasShare "turboshare";

  systemd.tmpfiles.rules = [
    "d /mnt/games 0755 max max -"
    "d /mnt/truenas 0755 max max -"
  ];

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

  # Japanese input. The XKB "jp" layout (in hyprland kb_layout) only changes the
  # physical layout; typing kana/kanji needs an IME. fcitx5 + mozc: toggle with
  # Ctrl+Space. Autostarted from Hyprland in hosts/tower/home.nix.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };

  virtualisation.docker.enable = true;

  # For BambuStudio (nixpkgs build hits a blank 3D viewport on this GPU/compositor
  # combo, same failure as OrcaSlicer's). Flatpak's self-contained runtime avoids
  # both the nixpkgs packaging quirks and manual FHS shimming.
  services.flatpak.enable = true;
  # nixpkgs' flatpak (1.18.0) has a regression where flatpak-spawn leaks the
  # host's PATH into nested loader sandboxes (e.g. glycin icon loaders); NixOS's
  # non-FHS PATH means the target binary isn't there, so bwrap fails with
  # "execvp prlimit: No such file or directory" and the app crashes on icon load.
  # Fixed upstream in 1.18.1 (also several security fixes). Remove once nixpkgs
  # catches up. See: https://github.com/flatpak/flatpak/issues/6717
  services.flatpak.package = pkgs.flatpak.overrideAttrs (old: rec {
    version = "1.18.1";
    src = pkgs.fetchurl {
      url = "https://github.com/flatpak/flatpak/releases/download/${version}/flatpak-${version}.tar.xz";
      hash = "sha256-vGg/yRbtIcBSS7Bk81jCrBhYa47IjHby9/KJh3UhYxw=";
    };
  });
  # Missing portal.Settings backend makes flatpak GTK apps fall back to broken
  # local icon-theme lookups (BambuStudio's flatpak crashes on icon load without it).
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  programs.xwayland.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  ###gaming support
  programs.gamemode.enable = true;
  programs.steam.enable = true;

  # Noctalia greeter (greetd-based) replaces ly. The module enables greetd and
  # sets the session command automatically.
  programs.noctalia-greeter = {
    enable = true;
    package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      output = {
        name = "DP-3";
        scale = 1.25;
        layout = "DP-1:0,1764; DP-3:1920,1440; DP-2:4992,1248; HDMI-A-1:2176,0";
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

  # Audio + Bluetooth provided by ../../nixosModules/audio.nix

  users.users.max = {
    isNormalUser = true;
    description = "max";
    shell = pkgs.zsh;
    group = "max";
    extraGroups = ["networkmanager" "wheel" "docker" "audio" "video" "input" "dialout"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };
  users.groups.max = {};

  programs.ssh.startAgent = true;

  # Nix settings + allowUnfree provided by ../../nixosModules/nix-settings.nix
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    kitty
    git
    catppuccin-cursors.mochaMauve # greeter cursor theme (system-wide for greetd)
    cifs-utils # mount.cifs for the TrueNAS fileSystems entries above; must be
    # system-wide, not just in the user profile, so systemd's automount unit
    # (running as root) can find the helper.
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = pkgs.steam-run.args.multiPkgs pkgs;
  };

  nixpkgs.config.allowUnfree = true;
  viamaximus.sshWebKeys.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
