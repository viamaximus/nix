{
  config,
  pkgs,
  lib,
  ...
}: let
  # glew without EGL: blank 3D viewport on NVIDIA otherwise (OrcaSlicer#12308)
  # drop gcc-unwrapped: static libstdc++ crashes the Bambu plugin (nixpkgs#557126)
  orca-slicer-nvidia = pkgs.symlinkJoin {
    name = "orca-slicer";
    paths = [((pkgs.orca-slicer.override {
      glew = pkgs.glew.override {enableEGL = false;};
    }).overrideAttrs (old: {
      buildInputs = builtins.filter (p: p != pkgs.gcc-unwrapped) old.buildInputs;
    }))];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      # Bambu network plugin dlopen()s libstdc++.so.6 and libz.so.1
      wrapProgram $out/bin/orca-slicer \
        --set DRI_PRIME 0 \
        --set __NV_PRIME_RENDER_OFFLOAD 0 \
        --set GDK_BACKEND x11 \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib pkgs.zlib]}"
    '';
  };
in {
  home.packages = [
    orca-slicer-nvidia
  ];
}
