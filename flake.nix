##flake.nix##
{
  description = "a simple nixos flake";
  inputs = {
    #nixos official 25.05 branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };
  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
in
  {
    nixosConfigurations = {
      asus-zephyrus = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/asus-zephyrus/configuration.nix
        ];
      };

      cardboard = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/cardboard/configuration.nix
        ];
      };
      homeManagerModules.default = ./homeManagerModules;
    };
  };
}
