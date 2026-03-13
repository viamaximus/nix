{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.pwndbg.packages.${pkgs.system}.default
  ];
}
