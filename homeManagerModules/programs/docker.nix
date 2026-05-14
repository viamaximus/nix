{
  config,
  lib,
  pkgs,
  ...
}: {
  # NOTE: This only installs Docker CLI tools.
  # The Docker daemon must be enabled at the system level:
  # Add `virtualisation.docker.enable = true;` to your configuration.nix
  # Also add your user to the docker group: extraGroups = [ "docker" ];

  home.packages = with pkgs; [
    lazydocker
    docker
    docker-buildx
    docker-compose
  ];
}
