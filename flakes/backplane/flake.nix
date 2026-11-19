{
  description = "Backplane - agentic hardware development (prebuilt release)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    sources = builtins.fromJSON (builtins.readFile ./sources.json);
    systems = builtins.attrNames sources.platforms;
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: rec {
      backplane = pkgs.callPackage ./package.nix {inherit sources;};
      default = backplane;
    });

    overlays.default = final: _prev: {
      backplane = final.callPackage ./package.nix {inherit sources;};
    };

    apps = forAllSystems (pkgs: {
      default = {
        type = "app";
        program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.backplane}/bin/backplane";
      };
    });
  };
}
