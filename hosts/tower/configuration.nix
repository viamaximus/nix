{
  config,
  pkgs,
  lib,
  inputs,
  hostInventory,
  ...
}: let
  wallpaperConfig = import ./current-wallpaper.nix;
  # Both Steam library locations (home.nix has no second library of its own;
  # /mnt/games/SteamLibrary is the fileSystems entry below) — SteamVR could
  # live in either.
  steamvrLaunchers = [
    "/home/max/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher"
    "/mnt/games/SteamLibrary/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher"
  ];
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

  # nixpkgs' wivrn (26.6.1) is older than the Quest client, which rejects the
  # server as an incompatible version. Bump to the matching v26.9 release
  # (same monado pin nixpkgs uses, just following wivrn's own monado-rev file
  # for that tag) until nixpkgs catches up. Also build with cudaSupport so it
  # can use NVENC — without it, WiVRn finds no usable hardware encoder on
  # this NVIDIA GPU (Vulkan video encode extensions are present in the
  # driver, but WiVRn's encoder selection doesn't pick them up here) and the
  # Quest connects then immediately drops.
  nixpkgs.overlays = [
    (final: prev: {
      wivrn = (prev.wivrn.override {cudaSupport = true;}).overrideAttrs (old: let
        newSrc = final.fetchFromGitHub {
          owner = "wivrn";
          repo = "wivrn";
          rev = "v26.9";
          hash = "sha256-/kXgbku/4EeYY5YTwtY71csgxOP8bRACLqOvKXolg5g=";
        };
      in {
        version = "26.9";
        src = newSrc;
        monado = final.applyPatches {
          src = final.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "monado";
            repo = "monado";
            rev = "f037264d23e2472a444a157370647fcd601ed81b";
            hash = "sha256-exHbecudAy57szL7kut7/fBYCoekEs3riZzhMtFWS/c=";
          };
          postPatch = ''
            ${newSrc}/patches/apply.sh ${newSrc}/patches/monado/*
          '';
        };
      });
    })
  ];

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

  boot.supportedFilesystems.ntfs = true;

  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/FEC674D0C6748B23";
    fsType = "ntfs3";
    noCheck = true;
    options = [
      "rw"
      "uid=1000"
      "gid=987"
      "umask=022"
      "noatime"
      "windows_names"
      "nofail"
      "x-systemd.device-timeout=5s"
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
  hardware.steam-hardware.enable = true;

  # ALVR: left enabled but effectively superseded by WiVRn below — its
  # SteamVR driver hits a direct-mode interface mismatch
  # (IVRDriverDirectModeComponent_007 vs what current SteamVR expects),
  # causing a restart loop and a garbled/stale-reprojected image.
  programs.alvr = {
    enable = true;
    openFirewall = true; # TCP/UDP 9943, 9944
  };
  # Virtual Desktop Streamer isn't packaged in nixpkgs (installed/updated
  # through Steam itself) — only the firewall ports are needed here.
  networking.firewall.allowedTCPPorts = [38810 38820 38830 38840];

  # WiVRn: native-Linux OpenXR streamer to the Quest over the LAN. Avoids
  # SteamVR entirely — xrizer (OpenVR→OpenXR shim) lets SteamVR-only games
  # run against WiVRn's Monado runtime directly, sidestepping the
  # vrserver/vrcompositor driver-interface problems above.
  services.wivrn = {
    enable = true;
    openFirewall = true; # TCP/UDP 9757 + mDNS discovery via avahi
    autoStart = true;
    highPriority = true; # cap_sys_nice for the compositor via a setuid wrapper
    steam.importOXRRuntimes = true; # let Steam's sandbox see the WiVRn OpenXR runtime
    # wayvr (formerly wlx-overlay-s): XSOverlay-style desktop/notification
    # overlay, native OpenXR — shown as WiVRn's dashboard/home environment.
    config = {
      enable = true;
      json = {
        application = [pkgs.wayvr];
        encoder = {
          encoder = "nvenc";
          codec = "av1";
        };
      };
    };
  };

  # SteamVR's vrcompositor-launcher needs CAP_SYS_NICE for realtime scheduling.
  # Its own setup script grants this via pkexec, which has no polkit agent in
  # this Hyprland session, so the grant silently fails and SteamVR reports
  # "setup is incomplete". Grant it from the system side instead, and
  # re-apply periodically, since every SteamVR update rewrites the binary
  # (clearing the capability). +ep (not Valve's own +eip) avoids the
  # inheritable flag's known vrcompositor crash/graphics-reset bug.
  #
  # A systemd.path watch on the binary was tried first but is too fragile:
  # Steam's own background verification/update traffic in that directory can
  # burst past the path unit's default trigger-rate limit and fail outright.
  # A timer is immune to that — it just re-applies on a schedule instead of
  # reacting to filesystem events.
  systemd.services.steamvr-setcap = {
    description = "Grant SteamVR's vrcompositor-launcher cap_sys_nice";
    after = ["local-fs.target"];
    startLimitIntervalSec = 0;
    serviceConfig.Type = "oneshot";
    script = ''
      for launcher in ${lib.concatMapStringsSep " " lib.escapeShellArg steamvrLaunchers}; do
        if [ -e "$launcher" ]; then
          ${pkgs.libcap}/bin/setcap cap_sys_nice+ep "$launcher"
        fi
      done
      exit 0
    '';
  };

  systemd.timers.steamvr-setcap = {
    description = "Periodically grant SteamVR's vrcompositor-launcher cap_sys_nice";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
  };

  # Noctalia greeter (greetd-based) replaces ly. The module enables greetd and
  # sets the session command automatically.
  services.displayManager.noctalia-greeter = {
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
    xrizer # OpenVR->OpenXR shim; path pasted into WiVRn dashboard as a
    # "Custom" OpenVR compatibility library (/run/current-system/sw/lib/xrizer)
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
