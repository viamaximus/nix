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
    nixpkgs.config.allowUnfree = true;
  };
}
