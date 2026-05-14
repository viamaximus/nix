{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (blender.override {
      cudaSupport = pkgs.stdenv.isx86_64;
    })
    davinci-resolve
  ];
}
