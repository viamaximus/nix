{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./programs
    ./hypr
    ./xfce
    ./shell
  ];
  config = {
  };
}
