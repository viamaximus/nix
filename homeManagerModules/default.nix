{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./programs
    ./hypr
    ./noctalia
    ./xfce
    ./shell
    ./vrcdev.nix
  ];
  config = {};
}
