{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    virtualbox
  ];

  programs = {
  };

  services = {
  };
}
