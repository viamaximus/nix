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
    # Enable unfree packages for user-level nix commands
    # (nix profile install, nix run, nix-shell, etc.)
    nixpkgs.config.allowUnfree = true;
  };
}
