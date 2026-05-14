{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    lazydocker
    docker
    docker-buildx
    docker-compose
  ];
}
