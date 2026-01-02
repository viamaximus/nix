{
  config,
  pkgs,
  lib,
  ...
}: let
  # see: https://github.com/NixOS/nixpkgs/issues/387526
  orca-slicer-nvidia = pkgs.symlinkJoin {
    name = "orca-slicer";
    paths = [pkgs.orca-slicer];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/orca-slicer \
        --set GBM_BACKEND dri
    '';
  };
in {
  home.packages = [
    orca-slicer-nvidia
  ];
}
