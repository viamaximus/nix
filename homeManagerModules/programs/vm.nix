{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals stdenv.hostPlatform.isx86_64 [
      virtualbox
    ];

  programs = {
  };

  services = {
  };
}
