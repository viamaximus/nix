{ config, pkgs, ... }:
{
  system.stateVersion = "25.05";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  time.timeZone = "America/New_York";

  services.openssh.enable = true;
  users.mutableUsers = false;
}

