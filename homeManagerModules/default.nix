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
  ];
  config = {};
}
