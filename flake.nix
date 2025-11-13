{
  description = "Asahi NixOS + Hyprland 0.51.0 (minimal, no HM)";

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # apple silicon support
    apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    apple-silicon.inputs.nixpkgs.follows = "nixpkgs";
    # hyprland 0.51.0
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.51.0&submodules=1";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, apple-silicon, hyprland, ... }@inputs: {
    nixosConfigurations = {
      mac-asahi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs apple-silicon hyprland; };
        modules = [
          apple-silicon.nixosModules.apple-silicon-support
          # ./hardware-configuration.nix
          ./hosts/mac-asahi/configuration.nix
        ];
      };
      homeManagerModules.default = ./homeManagerModules;
    };
  };
}

