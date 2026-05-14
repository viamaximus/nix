{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Essential modules (auto-imported for all hosts)
    ./browsers.nix
    ./common.nix
    ./neovim.nix
    ./git.nix

    # Optional modules below are NOT auto-imported.
    # Hosts should explicitly import what they need:
    # - ./rendering.nix          # blender, davinci-resolve
    # - ./media-tools.nix        # ffmpeg, yt-dlp
    # - ./docker.nix             # docker CLI tools (requires virtualisation.docker.enable in system config)
    # - ./communication.nix      # signal, element, fluffychat
    # - ./hardware-dev.nix       # serial/embedded dev tools
    # - ./homelab.nix            # kubectl
    # - ./reverse-engineering.nix # ida-free
    # - ./desktop-apps.nix       # misc desktop utilities
    # - ./c-dev.nix              # C development tools
    # - ./ghidra.nix             # reverse engineering
    # - ./godot.nix              # game engine
    # - ./rfstuffs.nix           # RF/radio tools
    # - ./kicad.nix              # PCB design
    # - ./wallpaper-switch.nix   # wallpaper switching
    # - ./vesktop.nix            # discord client
    # - ./spotify.nix            # spotify
    # - ./spotify-config.nix     # spotify config
    # - ./3dprint.nix            # 3D printing tools
    # - ./vm.nix                 # virtualization
    # - ./pwndbg.nix             # debugger
  ];
}
