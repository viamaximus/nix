{
  inputs,
  pkgs,
  ...
}: let
  signalPkgs = import inputs.nixpkgs-signal {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in {
  home.packages = with pkgs;
    [
      element-desktop
      fluffychat
    ]
    ++ [
      signalPkgs.signal-desktop
    ];
}
