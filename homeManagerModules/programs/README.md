# Home Manager Program Modules

This directory is split into a small base plus optional modules and profiles.

## Auto-imported base

Imported through `../../homeManagerModules` for normal desktop hosts:

- `common.nix`
- `git.nix`
- `neovim.nix`

This base is intentionally CLI-focused.

## Optional modules

- `browsers.nix`
- `c-dev.nix`
- `communication.nix`
- `desktop-apps.nix`
- `docker.nix`
- `ghidra.nix`
- `godot.nix`
- `hardware-dev.nix`
- `homelab.nix`
- `kicad.nix`
- `media-tools.nix`
- `pwndbg.nix`
- `rendering.nix`
- `reverse-engineering.nix`
- `rfstuffs.nix`
- `spotify.nix`
- `spotify-config.nix`
- `vesktop.nix`
- `vm.nix`
- `wallpaper-switch.nix`
- `3dprint.nix`

## Profiles

- `profiles/desktop.nix`
  Light desktop bundle: browsers, communication, and everyday GUI apps.

- `profiles/workstation.nix`
  Full desktop/dev bundle used by the main workstations in this repo.
