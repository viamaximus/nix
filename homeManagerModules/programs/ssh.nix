{
  hostInventory,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    matchBlocks =
      lib.mapAttrs
      (_: meta: {
        hostname = meta.hostName;
        user = meta.user;
        forwardAgent = true;
      })
      hostInventory;
  };
}
