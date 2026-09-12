{
  config,
  pkgs,
  lib,
  ...
}: let
  orca-slicer-nvidia = pkgs.symlinkJoin {
    name = "orca-slicer";
    paths = [pkgs.orca-slicer];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/orca-slicer \
        --set DRI_PRIME 0 \
        --set __NV_PRIME_RENDER_OFFLOAD 0
    '';
  };
in {
  home.packages = [
    orca-slicer-nvidia
  ];
}
