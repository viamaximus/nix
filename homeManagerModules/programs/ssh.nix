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
          hostname = "github.com";
          user = "git";
          identitiesOnly = true;
          identityFile = [
            "~/.ssh/id_ed25519_sk_yk5cnano"
          ];
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
