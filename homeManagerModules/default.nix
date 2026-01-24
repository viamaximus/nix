{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./programs
    ./hypr
    ./shell
  ];
  options = {
  };
  config = {
    stylix.targets.firefox.profileNames = [ "default" ];
  };
}
