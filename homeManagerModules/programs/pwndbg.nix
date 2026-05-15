{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
