{ config, pkgs, lib, ... }:

let
  wallpaper-switch = pkgs.writeShellScriptBin "wallpaper-switch" ''
    set -e

    WALLPAPER_PATH="$1"
    CONFIG_DIR="$HOME/nix-testing"
    WALLPAPER_DIR="$CONFIG_DIR/wallpapers"
    WALLPAPER_CONFIG="$CONFIG_DIR/hosts/mac-asahi/current-wallpaper.nix"
    CURRENT_WALLPAPER="$WALLPAPER_DIR/current-wallpaper"

    if [ -z "$WALLPAPER_PATH" ]; then
        echo "Usage: wallpaper-switch /path/to/wallpaper.jpg"
        echo ""
        echo "Available wallpapers:"
        ${pkgs.findutils}/bin/find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null
        exit 1
    fi

    if [ ! -f "$WALLPAPER_PATH" ]; then
        echo "Error: Wallpaper file not found: $WALLPAPER_PATH"
        exit 1
    fi

    WALLPAPER_PATH=$(${pkgs.coreutils}/bin/realpath "$WALLPAPER_PATH")
    
    EXT="''${WALLPAPER_PATH##*.}"
    
    echo "Copying wallpaper to flake directory..."
    ${pkgs.coreutils}/bin/cp "$WALLPAPER_PATH" "$CURRENT_WALLPAPER.$EXT"
    
    WALLPAPER_RELATIVE=$(${pkgs.coreutils}/bin/realpath --relative-to="$(dirname "$WALLPAPER_CONFIG")" "$CURRENT_WALLPAPER.$EXT")

    echo "Updating wallpaper config..."
    cat > "$WALLPAPER_CONFIG" << NIXEOF
{
  currentWallpaper = $WALLPAPER_RELATIVE;
}
NIXEOF

    echo "Rebuilding system..."
    cd "$CONFIG_DIR"
    sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --impure --flake .#mac-asahi

    echo "Restarting hyprpaper..."
    ${pkgs.procps}/bin/pkill hyprpaper || true
    ${pkgs.hyprpaper}/bin/hyprpaper &

    echo "Done!"
  '';
in
{
  home.packages = [ wallpaper-switch ];
}
