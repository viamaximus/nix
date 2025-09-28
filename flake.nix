# flake.nix
{
  description = "flake to manage both nixos and home-manager";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self,
    nixpkgs, 
    home-manager,
    ... 
  } @ inputs:
    let
      lib = nixpkgs.lib;
      #the systems we acutally use 
      systems = [
        "x86_64-linux"
	"aarch64-linux"
	"aarch64-darwin"
      ];

      forAllSystems = f: lib.genAttrs systems (system: f system);

      #pkgs stuff
      pkgsFor = system: import nixpkgs {
        inherit system;
	config = {
	  allowUnfree = true;
	};
	overlays = [];
      };
    in 
    {
      #formatter
      formatter = forAllSystems (system: (pkgsFor system).alejandra);
      
      # -----------NIXOS CONFIGS---------------
      nixosConfigurations = {
        asus-zephyrus = lib.nixosSystem {
	  system = "x86_64-linux";
	  specialArgs = {inherit inputs; };
	  modules = [
	    ./modules/common-nixos.nix
	    ./nixosModules
	    ./hosts/asus-zephyrus/nixos.nix
	    
	    #home manager as a nixos module, 25.05
	    home-manager.nixosModules.home-manager {
	      home-manager = {
	        useGlobalPkgs = true;
		useUserPackages = true;
		users.max = import ./home/max;
	      };
	    }
	  ];
	};
	
	fw-13-amd = lib.nixosSystem {
	  system = "x86_64-linux";
	  specialArgs = {inherit inputs; };
	  modules = [
	    ./modules/common-nixos.nix
	    ./nixosModules
	    ./hosts/fw-13-amd/nixos.nix
	    home-manager.nixosModules.home-manager {
	      home-manager = {
	        useGlobalPkgs = true;
		useUserPackages = true;
		users.max = import ./home/max;
	      };
	    }
	  ];
	};
      };
      #-------------HOME CONFIG-----------------
      homeConfigurations = {
        "max@mac-asahi" = home-manager.lib.homeManagerConfiguration {
	  pkgs = pkgsFor "aarch64-linux";
	  extraSpecialArgs = { inherit inputs; };
	  modules = [
	    ./modules/common-home.nix
	    ./homeManagerModules
	    ./hosts/mac-asahi/home.nix
	    ./home/max
	  ];
        };
	"max@mac-darwin" = home-manager.lib.homeManagerConfiguration {
	  pkgs = pkgsFor "aarch64-darwin";
	  extraSpecialArgs = { inherit inputs; };
	  modules = [
	    ./modules/common-home.nix
	    ./homeManagerModules
	    ./hosts/mac-darwin/home.nix
	    ./home/max
	  ];
	};
      };
    };
}
