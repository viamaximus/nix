{
  hostInventory,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks =
      {
        "github.com" = {
          identityFile = "~/.ssh/id_ed25519_sk";
          identitiesOnly = true;
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
