  Quick guide: migrating/adding secrets

  One-time setup (do this first)

  1. Set up both Yubikeys (plug in main, run, then swap to backup):
  nix shell nixpkgs#age-plugin-yubikey nixpkgs#age

  # On MAIN Yubikey:
  age-plugin-yubikey --generate --slot 2
  age-plugin-yubikey --identity --slot 2 > secrets/master-keys/yubikey-main-identity.txt
  age-plugin-yubikey --identity --slot 2 | age-keygen -y > secrets/master-keys/yubikey-main-recipient.pub

  # Swap to BACKUP Yubikey:
  age-plugin-yubikey --generate --slot 2
  age-plugin-yubikey --identity --slot 2 > secrets/master-keys/yubikey-backup-identity.txt
  age-plugin-yubikey --identity --slot 2 | age-keygen -y > secrets/master-keys/yubikey-backup-recipient.pub

  2. Generate paper backup:
  age-keygen -o /tmp/paper-key.txt
  age-keygen -y < /tmp/paper-key.txt > secrets/master-keys/paper-recipient.pub
  # PRINT /tmp/paper-key.txt and store it offline, then:
  shred -u /tmp/paper-key.txt

  3. Collect host SSH keys (for each machine):
  ssh tower "cat /etc/ssh/ssh_host_ed25519_key.pub" > secrets/public-keys/tower.pub
  ssh asus-zephyrus "cat /etc/ssh/ssh_host_ed25519_key.pub" > secrets/public-keys/asus-zephyrus.pub
  ssh mac-asahi "cat /etc/ssh/ssh_host_ed25519_key.pub" > secrets/public-keys/mac-asahi.pub
  # mac-asahi-xfce uses same host key as mac-asahi
  cp secrets/public-keys/mac-asahi.pub secrets/public-keys/mac-asahi-xfce.pub
  ssh cardboard "cat /etc/ssh/ssh_host_ed25519_key.pub" > secrets/public-keys/cardboard.pub
  # repeat for server, netbook, meshbundle

  4. Add hostPubkey to each host's configuration.nix:
  age.rekey.hostPubkey = builtins.readFile ../../secrets/public-keys/tower.pub;
  (adjust path depth per host — ../../ from hosts/tower/configuration.nix)

  5. Commit the master keys and git add everything, then run initial rekey:
  git add secrets/
  nix run .#agenix-rekey -- rekey   # needs a Yubikey plugged in
  git add secrets/rekeyed/

  ---
  Adding a secret

  1. Create it (Yubikey must be plugged in, will prompt for touch):
  cd /home/max/nix
  nix run nixpkgs#agenix -- -e secrets/secrets/my-secret.age \
    -i secrets/master-keys/yubikey-main-identity.txt

  2. Rekey for all hosts (so hosts can decrypt it without the Yubikey):
  nix run .#agenix-rekey -- rekey

  3. Reference it in a host config:
  age.secrets.my-secret = {
    rekeyFile = ../../secrets/secrets/my-secret.age;
    owner = "max";  # optional
  };
  # Use it: config.age.secrets.my-secret.path  →  /run/agenix/my-secret

  4. Commit:
  git add secrets/secrets/my-secret.age secrets/rekeyed/
  git commit

  ---
  Emergency: paper key recovery

  Place the private key at /home/max/.config/age/paper-key.txt temporarily, run rekey, then delete it.

  # restore from printed paper key to:
  nano ~/.config/age/paper-key.txt   # type it in
  nix run .#agenix-rekey -- rekey
  shred -u ~/.config/age/paper-key.txt
