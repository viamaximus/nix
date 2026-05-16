                                                                                       
  ---                                                                                   
  Secrets Management Plan: agenix + agenix-rekey + Yubikey                              
                                                                                        
  How it works (overview)                                                               
                                                                                        
  - agenix: NixOS module that decrypts .age files at activation and exposes them as     
  /run/agenix/secret-name                                                               
  - agenix-rekey: Extension that lets you keep one canonical copy of each secret
  (encrypted to your Yubikey), then automatically re-encrypts it for each host's SSH
  host key. Rekeyed copies live in the repo.
  - age-plugin-yubikey: Stores the age master private key in a Yubikey PIV slot. You
  need the key + PIN/touch to rekey secrets, but deploys work without the Yubikey (using
   the rekeyed host copies).

  ---
  Phase 1: Flake inputs

  Add to flake.nix:

  agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  agenix-rekey = {
    url = "github:oddlama/agenix-rekey";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  Add the agenix-rekey output (alongside nixosConfigurations):

  outputs = { self, nixpkgs, ... } @ inputs: let
    # ... existing stuff ...
  in {
    nixosConfigurations = { ... };  # existing

    # NEW: agenix-rekey app used to rekey secrets
    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = self;
      nixosConfigurations = self.nixosConfigurations;
      agePackage = p: p.age;
    };
  };

  ---
  Phase 2: One-time Yubikey setup

  Install tools temporarily: nix shell nixpkgs#age nixpkgs#age-plugin-yubikey

  # Generate an age identity in PIV slot 82 (82-95 are available, 82 is conventional for
   age)
  age-plugin-yubikey --generate --slot 2  # slot 2 = PIV slot 82

  # This outputs two things. Save them:
  # 1. Identity stub (reference to the Yubikey, NOT the private key):
  age-plugin-yubikey --identity --slot 2 > secrets/master-keys/yubikey-identity.txt

  # 2. Recipient public key:
  age-plugin-yubikey --identity --slot 2 | age-keygen -y >
  secrets/master-keys/yubikey-recipient.pub

  The identity stub is safe to commit — it's just a reference to which Yubikey/slot, not
   key material.

  If you want multiple Yubikeys (backup key), generate another and add both recipients.

  ---
  Phase 3: Collect host SSH public keys

  agenix-rekey re-encrypts each secret to the host's SSH host key. Collect them from
  each machine:

  mkdir -p secrets/public-keys

  # On each host, or pull from /etc/ssh/ if you have access:
  ssh tower        "cat /etc/ssh/ssh_host_ed25519_key.pub" >
  secrets/public-keys/tower.pub
  ssh asus-zephyrus "cat /etc/ssh/ssh_host_ed25519_key.pub" >
  secrets/public-keys/asus-zephyrus.pub
  ssh mac-asahi    "cat /etc/ssh/ssh_host_ed25519_key.pub" >
  secrets/public-keys/mac-asahi.pub
  # etc. for all hosts

  ---
  Phase 4: Shared agenix module

  Create nixosModules/agenix.nix:

  { inputs, config, lib, ... }: {
    imports = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
    ];

    age.rekey = {
      # The Yubikey identity stub — used when rekeying, not at deploy time
      masterIdentities = [{
        identity = "${inputs.self}/secrets/master-keys/yubikey-identity.txt";
        pubkey = builtins.readFile
  "${inputs.self}/secrets/master-keys/yubikey-recipient.pub";
      }];

      # Store rekeyed files in the repo (committed to git)
      storageMode = "local";
      localStorageDir = "${inputs.self}/secrets/rekeyed";
    };
  }

  Add per-host in each configuration.nix:

  age.rekey.hostPubkey = builtins.readFile ../../../secrets/public-keys/tower.pub;

  Wire the module into each host in flake.nix (or a shared imports list):

  modules = [
    ./nixosModules/agenix.nix
    ./hosts/tower/configuration.nix
  ];

  ---
  Phase 5: Adding secrets (ongoing workflow)

  Create a secrets/secrets.nix (agenix access control — only needs your Yubikey pubkey
  since agenix-rekey handles host distribution):

  let
    yubikey = builtins.readFile ./master-keys/yubikey-recipient.pub;
  in {
    "secrets/wifi-home.age".publicKeys = [ yubikey ];
    "secrets/user-password.age".publicKeys = [ yubikey ];
    # etc.
  }

  Encrypt a new secret (Yubikey required, touch prompt):
  cd secrets/
  nix run nixpkgs#agenix -- -e secrets/wifi-home.age

  Rekey all secrets for all hosts (Yubikey required):
  nix run .#agenix-rekey -- rekey

  This generates/updates secrets/rekeyed/<hostname>/<hash>-<secretname>.age for every
  host that references that secret. Commit these files — they're safe to push (encrypted
   to host SSH keys, not sensitive).

  ---
  Phase 6: Reference secrets in host configs

  # In hosts/tower/configuration.nix
  age.secrets.wifi-home = {
    rekeyFile = ../../../secrets/secrets/wifi-home.age;
    # optional: owner, group, mode, path
  };

  # Use it:
  networking.wireless.networks."MyNetwork".psk = config.age.secrets.wifi-home.path;
  # (path resolves to /run/agenix/wifi-home at runtime)

  ---
  Phase 7: Developer tooling (optional but nice)

  Add to your shell or justfile:

  # Rekey all secrets (need Yubikey plugged in)
  just rekey:
    nix run .#agenix-rekey -- rekey

  # Edit a secret (need Yubikey plugged in)
  just secret name:
    nix run nixpkgs#agenix -- -e secrets/secrets/{{name}}.age -i
  secrets/master-keys/yubikey-identity.txt

  ---
  Key properties of this setup

  ┌──────────────────────┬──────────────────────────────────────────────────────────┐
  │       Concern        │                          Answer                          │
  ├──────────────────────┼──────────────────────────────────────────────────────────┤
  │ Deploy without       │ Yes — hosts use their own SSH key to decrypt rekeyed     │
  │ Yubikey?             │ copies                                                   │
  ├──────────────────────┼──────────────────────────────────────────────────────────┤
  │ Yubikey lost?        │ Add a backup Yubikey recipient before rekeying, or keep  │
  │                      │ a paper backup of the age identity                       │
  ├──────────────────────┼──────────────────────────────────────────────────────────┤
  │ New host?            │ Add SSH pubkey, add age.rekey.hostPubkey, reference      │
  │                      │ secrets in config, run rekey                             │
  ├──────────────────────┼──────────────────────────────────────────────────────────┤
  │ New secret?          │ Add to secrets.nix, agenix -e to encrypt, rekey to       │
  │                      │ distribute                                               │
  ├──────────────────────┼──────────────────────────────────────────────────────────┤
  │ Safe to push rekeyed │ Yes — encrypted to host SSH pubkeys                      │
  │  files?              │                                                          │
  ├──────────────────────┼──────────────────────────────────────────────────────────┤
  │ Safe to push         │ Yes — encrypted to your Yubikey                          │
  │ canonical secrets?   │                                                          │
  └──────────────────────┴──────────────────────────────────────────────────────────┘
