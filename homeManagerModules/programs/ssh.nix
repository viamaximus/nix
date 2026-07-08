{
  hostInventory,
  lib,
  osConfig ? null,
  ...
}: let
  isTower = (osConfig.networking.hostName or "") == "tower";
  # tower has the 5C Nano fixed in place, so it's tried first there;
  # every other host tries the 5C first. Both are always listed so
  # whichever key is physically plugged in still works.
  githubIdentityFiles =
    if isTower
    then ["~/.ssh/id_ed25519_sk_yk5cnano" "~/.ssh/id_ed25519_sk_yk5c"]
    else ["~/.ssh/id_ed25519_sk_yk5c" "~/.ssh/id_ed25519_sk_yk5cnano"];
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks =
      {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identitiesOnly = true;
          identityFile = githubIdentityFiles;
        };
      }
      // lib.mapAttrs
      (_: meta: {
        hostname = meta.hostName;
        user = meta.user;
        forwardAgent = true;
      })
      hostInventory;
  };
}
