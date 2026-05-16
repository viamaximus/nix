{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    saleae-logic-2
    pulseview
    unixtools.xxd
    cp210x-program
    caligula
    screen
    tio
  ];
}
