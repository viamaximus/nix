# Home Manager Programs Modules

This directory contains modular program configurations for home-manager.

## Auto-Imported Modules (Essential)

These modules are automatically imported for **all** hosts via `default.nix`:

- **browsers.nix** - Web browser configurations
- **common.nix** - Essential CLI tools, basic dev tools, file managers
- **neovim.nix** - Neovim configuration
- **git.nix** - Git configuration

## Optional Modules (Explicit Import Required)

These modules must be explicitly imported in each host's `home.nix`:

### Media & Content Creation
- **rendering.nix** - Blender, DaVinci Resolve (HEAVY packages)
- **media-tools.nix** - FFmpeg, yt-dlp

### Development & Tools
- **c-dev.nix** - C development tools
- **docker.nix** - Docker CLI tools (requires `virtualisation.docker.enable = true` in system config)
- **pwndbg.nix** - Debugger enhancements

### Hardware & Electronics
- **hardware-dev.nix** - Serial/embedded development (cp210x, tio, screen, caligula)
- **rfstuffs.nix** - RF/radio tools
- **kicad.nix** - PCB design
- **3dprint.nix** - 3D printing tools

### Reverse Engineering & Security
- **reverse-engineering.nix** - IDA Free
- **ghidra.nix** - Ghidra reverse engineering

### Communication & Social
- **communication.nix** - Signal, Element, FluffyChat

### Desktop Applications
- **desktop-apps.nix** - Nextcloud, Obsidian, misc utilities
- **vesktop.nix** - Discord client
- **spotify.nix** - Spotify
- **spotify-config.nix** - Spotify configuration
- **wallpaper-switch.nix** - Wallpaper switching utilities

### Other
- **godot.nix** - Godot game engine
- **homelab.nix** - Kubectl and K8s tools
- **vm.nix** - Virtualization tools

## Usage Example

```nix
# hosts/myhost/home.nix
{
  imports = [
    ../../homeManagerModules  # Gets essential modules automatically

    # Explicitly import only what you need:
    ../../homeManagerModules/programs/docker.nix
    ../../homeManagerModules/programs/communication.nix
    ../../homeManagerModules/programs/media-tools.nix
  ];

  # ... rest of config
}
```

## Important Notes

1. **Docker**: The `docker.nix` module only provides CLI tools. You must also:
   - Add `virtualisation.docker.enable = true;` to your `configuration.nix`
   - Add your user to the docker group: `extraGroups = [ "docker" ];`

2. **allowUnfree**: Unfree packages are enabled globally via `homeManagerModules/default.nix` for user-level nix commands.

3. **Minimal Hosts**: For minimal systems (like netbook), only import the base `homeManagerModules` without any optional modules.
