{
  description = "Multi-System flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # apple silicon support
    apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chicago95 = {
      url = "github:grassmunk/Chicago95";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    apple-silicon,
    ...
  } @ inputs: {
    nixosConfigurations = {
      mac-asahi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs apple-silicon;};
        modules = [
          apple-silicon.nixosModules.apple-silicon-support
          ./hosts/mac-asahi/configuration.nix
        ];
      };

      mac-asahi-xfce = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs apple-silicon;
          chicago95-src = inputs.chicago95;
        };
        modules = [
          apple-silicon.nixosModules.apple-silicon-support
          ./hosts/mac-asahi-xfce/configuration.nix
        ];
      };

      asus-zephyrus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/asus-zephyrus/configuration.nix
        ];
      };

      cardboard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/cardboard/configuration.nix
        ];
      };

      tower = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/tower/configuration.nix
        ];
      };
    };
  };
}
