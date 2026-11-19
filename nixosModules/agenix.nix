{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Rekeying target for this host. Drop a host's
  # /etc/ssh/ssh_host_ed25519_key.pub here to bring it into the rotation.
  hostPubkeyFile = inputs.self + "/secrets/public-keys/${config.networking.hostName}.pub";
in {
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  environment.systemPackages = [
    pkgs.age
    pkgs.age-plugin-yubikey
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  age.rekey = {
    hostPubkey = lib.mkIf (builtins.pathExists hostPubkeyFile) (lib.fileContents hostPubkeyFile);

    storageMode = "local";
    localStorageDir = inputs.self + "/secrets/rekeyed";

    masterIdentities = [
      {
        # Main Yubikey (PIV slot 2 / slot 82)
        identity = inputs.self + "/secrets/master-keys/yubikey-main-identity.pub";
        pubkey = lib.fileContents (inputs.self + "/secrets/master-keys/yubikey-main-recipient.pub");
      }
      {
        # Backup Yubikey (PIV slot 2 / slot 82)
        identity = inputs.self + "/secrets/master-keys/yubikey-backup-identity.pub";
        pubkey = lib.fileContents (inputs.self + "/secrets/master-keys/yubikey-backup-recipient.pub");
      }
      {
        # Paper backup — private key is stored offline (printed), NOT in repo.
        # Place the key at this path temporarily for emergency rekeying, then delete.
        identity = "/home/max/.config/age/paper-key.txt";
        pubkey = lib.fileContents (inputs.self + "/secrets/master-keys/paper-recipient.pub");
      }
    ];
  };
}
