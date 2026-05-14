{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isx86_64;
in {
  home.packages = with pkgs; [
    (blender.override {cudaSupport = isx86_64;})
    davinci-resolve
  ];
}
