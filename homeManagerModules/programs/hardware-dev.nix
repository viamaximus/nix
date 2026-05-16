{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      pulseview
      unixtools.xxd
      cp210x-program
      caligula
      screen
      tio
    ]
    ++ lib.optionals stdenv.isx86_64 [
      saleae-logic-2
    ];
}
