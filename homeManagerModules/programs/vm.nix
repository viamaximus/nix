{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals stdenv.isx86_64 [
      virtualbox
    ];

  programs = {
  };

  services = {
  };
}
