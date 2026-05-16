{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ida-free
  ];
}
