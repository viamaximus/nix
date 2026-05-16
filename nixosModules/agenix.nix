{
  inputs,
  lib,
  pkgs,
  ...
}: {
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
    storageMode = "local";
    localStorageDir = inputs.self + "/secrets/rekeyed";

    masterIdentities = [
      {
        # Main Yubikey (PIV slot 2 / slot 82)
        identity = inputs.self + "/secrets/master-keys/yubikey-main-identity.txt";
        pubkey = lib.fileContents (inputs.self + "/secrets/master-keys/yubikey-main-recipient.pub");
      }
      {
        # Backup Yubikey (PIV slot 2 / slot 82)
        identity = inputs.self + "/secrets/master-keys/yubikey-backup-identity.txt";
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
