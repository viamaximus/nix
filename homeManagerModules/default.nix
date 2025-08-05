{ config, pkgs, ...}: 
{
  imports = [
    ./programs
    ./hypr
    ./shell
  ];
  options = {
  };
  config = {
  };
}
