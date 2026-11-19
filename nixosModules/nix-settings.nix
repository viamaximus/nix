{...}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];

    trusted-users = ["root" "@wheel"];

    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://noctalia.cachix.org"
      "https://nixos-apple-silicon.cachix.org"
    ];

    trusted-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://noctalia.cachix.org"
      "https://nixos-apple-silicon.cachix.org"
    ];

    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;

    # Insecure packages we explicitly accept (transitive deps that lag upstream).
    # Add the exact `name-version` here as nixpkgs surfaces them.
    permittedInsecurePackages = [
      "nodejs-20.20.2"
      "nodejs-slim-20.20.2"
      "electron-39.8.10"
    ];
  };
}
