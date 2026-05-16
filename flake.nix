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
    nixpkgs-signal.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    pwndbg = {
      url = "github:pwndbg/pwndbg/dev";
    };
    chicago95 = {
      url = "github:grassmunk/Chicago95";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    apple-silicon,
    ...
  } @ inputs: let
    hostInventory = {
      mac-asahi = {
        hostName = "mac-asahi";
        user = "max";
      };
      mac-asahi-xfce = {
        hostName = "mac-asahi";
        user = "max";
      };
      asus-zephyrus = {
        hostName = "asus-zephyrus";
        user = "max";
      };
      cardboard = {
        hostName = "cardboard";
        user = "nix";
      };
      tower = {
        hostName = "tower";
        user = "max";
      };
      server = {
        hostName = "server";
        user = "max";
      };
      netbook = {
        hostName = "netbook";
        user = "max";
      };
      meshbundle = {
        hostName = "meshbundle";
        user = "mesh";
      };
    };
  in {
    nixosConfigurations = {
      mac-asahi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs apple-silicon hostInventory;};
        modules = [
          apple-silicon.nixosModules.apple-silicon-support
          ./hosts/mac-asahi/configuration.nix
        ];
      };

      mac-asahi-xfce = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs apple-silicon hostInventory;
          chicago95-src = inputs.chicago95;
        };
        modules = [
          apple-silicon.nixosModules.apple-silicon-support
          ./hosts/mac-asahi-xfce/configuration.nix
        ];
      };

      asus-zephyrus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs hostInventory;};
        modules = [
          ./hosts/asus-zephyrus/configuration.nix
        ];
      };

      cardboard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs hostInventory;};
        modules = [
          ./hosts/cardboard/configuration.nix
        ];
      };

      tower = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs hostInventory;};
        modules = [
          ./hosts/tower/configuration.nix
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs hostInventory;};
        modules = [
          ./hosts/server/configuration.nix
        ];
      };

      netbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs hostInventory;};
        modules = [
          ./hosts/netbook/configuration.nix
        ];
      };

      meshbundle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs hostInventory;};
        modules = [
          ./hosts/meshbundle/configuration.nix
        ];
      };
    };

    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = self;
      nixosConfigurations = self.nixosConfigurations;
      agePackage = p: p.age;
    };
  };
}
