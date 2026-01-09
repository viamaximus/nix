# NixOS configuration
multi-system configuration with Hyprland, Stylix, and Apple Silicon support

i tend to bounce around between a few machines, so i needed a single flake that i could distribute to keep consistent.

## screenshots

![desktop](.github/screenshots/desktop.png)

## features

### desktop environment
- hyprland - wayland compositor with lots of configuration
- waybar - status bar with spotify, weather, and custom power menu
- stylix - automatic theme based on wallpaper, with included wallpaper switch script
- notifications - themed notifications with mako
- shared modules - centralized fonts and stylix configuration across all systems

### dev tools
- neovim
- kicad and kikit plugin
- robust sdr tool suite
- godot engine
- docker and kubectl

### multi-machine info
- mac-asahi (aarch64) - my daily driver, apple silicon with asahi linux
- asus-zephyrus (x86_64) - laptop with nvidia gpu, asus-specific hardware support
- cardboard (x86_64) - itx machine built into a cardboard box, local nix cache server
- tower (x86_64) - gaming desktop with nvidia gpu, bluetooth audio, steam/gamemode support

### homelabby stuff
- tailscale VPN
- local nix cache (in progress)
- docker with system-level integration
- ssh access (mostly used in conjunction with tailscale)

### gaming (tower)
- steam with gamemode integration
- nvidia gpu with proprietary drivers
- bluetooth audio for wireless headsets
- dedicated games drive auto-mounted at /mnt/games

Wallpaper switching command: 

```wallpaper-switch my-wallpaper.jpg```
1. updates current to my-wallpaper.jpg
2. regenerated stylix color pallete
3. applies changes & rebuilds nix system

### Wallpaper Switching Demo
  <table>
    <tr>
      <td><img src=".github/screenshots/desktop.png" alt="before"/></td>
      <td><img src=".github/screenshots/blossoms-desktop.png" alt="after"/></td>
    </tr>
    <tr>
      <td align="center">fern</td>
      <td align="center">sakura</td>
    </tr>
  </table>

structure
```
  ├── flake.nix              # flake entry point
  ├── hosts/                 # per-machine configurations
  │   ├── mac-asahi/         # apple silicon mac
  │   ├── asus-zephyrus/     # x86 laptop
  │   ├── cardboard/         # x86 itx machine
  │   └── tower/             # gaming desktop
  ├── homeManagerModules/    # shared user configurations
  │   ├── hypr/              # hyprland configuration and extensions
  │   ├── programs/          # application configs
  │   └── shell/             # terminal setup
  ├── nixosModules/          # system-level modules
  │   ├── fonts.nix          # shared fonts
  │   ├── stylix.nix         # shared theme base
  │   └── automount.nix      # usb automounting
  └── wallpapers/            # theme wallpapers
```

## todo
- update hyprland (currently locked to 0.51 due to asahi issues with 0.52, but need to investigate 0.53)
- simplify wallpaper switch system (maybe waybar widget)
- low battery notification
- fix lid switch/laptop behavior
- expand options for desktop environments

