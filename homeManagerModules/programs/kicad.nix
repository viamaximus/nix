{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  backplane = inputs.backplane.packages.${pkgs.stdenv.hostPlatform.system} or {};
in {
  imports = [
  ];
  home.packages = with pkgs;
    [
      kicad
      # kikit depends on pybars3, marked insecure in nixpkgs (CVE-2026-119716).
      # Re-enable once a fixed pybars3 lands.
      # kikit
    ]
    ++ lib.optional (backplane ? default) backplane.default;
}
