# nixosModules/hyprland.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.my.hyprland;
in
{
  options.my.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland desktop (system side)";
    # You can switch DM later; greetd+tuigreet is a simple default.
    useGreetd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use greetd + tuigreet to start Hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    # Modern graphics flag (was hardware.opengl) in 24.11+ and 25.05
    hardware.graphics = {
      enable = true;
      enable32Bit = true;  # 32-bit userspace (Steam, etc.)
    };  # See docs about hardware.graphics on 24.11/25.05. :contentReference[oaicite:1]{index=1}

    # PipeWire (audio) – the Wayland-friendly stack
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
    };

    # PolicyKit for desktop auth
    security.polkit.enable = true;

    # XDG portals with Hyprland portal
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
    };

    # Helpful Wayland env for apps
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";   # Electron/Chromium
      MOZ_ENABLE_WAYLAND = "1";
      GTK_USE_PORTAL = "1";
    };

    # Fonts (feel free to tweak to your taste)
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];

    # Display manager: greetd + tuigreet that launches Hyprland
    services.greetd = lib.mkIf cfg.useGreetd {
      enable = true;
      settings = {
        default_session = {
          # dbus-run-session helps ensure a proper session bus
          command = "${pkgs.dbus}/bin/dbus-run-session " +
                    "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/Hyprland";
          user = "greeter";
        };
      };
    };

    # (Optional) You can switch to SDDM/GDM later if you prefer.
    # Example SDDM Wayland:
    # services.displayManager.sddm.enable = true;
    # services.displayManager.sddm.wayland.enable = true;

    # NOTE: Hyprland itself is provided to the user via Home-Manager (below).
    # If you also want the system module/desktop entry from nixpkgs or the Hyprland flake,
    # we can add it later—but keeping to nixpkgs 25.05 is simplest for now. :contentReference[oaicite:2]{index=2}
  };
}

