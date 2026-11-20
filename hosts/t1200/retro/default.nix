# t1200 retro theme (host-only). Everything in this folder is imported from
# hosts/t1200/home.nix only, so none of it reaches other hosts.
{lib, ...}: let
  palettes = import ./palettes.nix;
in {
  imports = [
    ./noctalia.nix
    ./hyprland.nix
    ./terminal.nix
    ./shell.nix
    ./apps.nix
    ./guide.nix
    ./screen-filter.nix
    ./tui.nix
  ];

  options.t1200.retro = {
    scheme = lib.mkOption {
      type = lib.types.enum (builtins.attrNames palettes);
      description = "Default retro palette (all four stay switchable live in Noctalia).";
    };
    palettes = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = palettes;
    };
    font = lib.mkOption {
      type = lib.types.str;
      default = "PxPlus ToshibaTxL1 8x16";
      description = "Toshiba text-mode font from ultimate-oldschool-pc-font-pack.";
    };
  };

  # ── Pick the default scheme ────────────────────────────────────────────────
  # Changing this needs a rebuild; switching live is Noctalia Settings ->
  # Theme -> Custom palette (t1200-amber / -green / -plasma / -lcd).
  config.t1200.retro.scheme = "amber"; # P3 amber phosphor
  # config.t1200.retro.scheme = "green"; # P1 green phosphor
  # config.t1200.retro.scheme = "plasma"; # T3100 orange gas-plasma
  # config.t1200.retro.scheme = "lcd"; # T1200 blue-grey STN LCD (light)
}
