# Backups

Nightly [restic](https://restic.net) snapshots of each host's home directory to
the TrueNAS, over SFTP. Bulk directories that aren't worth versioning are
mirrored separately with rsync.

Enabled per host with `features.backup.enable` (`nixosModules/backup.nix`).
Currently on: tower, asus-zephyrus, mac-asahi.

## How it's put together

| Layer | What it gives you |
| --- | --- |
| restic repo, one per host | Point-in-time snapshots, deduped and encrypted client-side. Daily runs cost only the delta. |
| ZFS snapshots on the backup dataset | Protection against a compromised or buggy client running `forget --prune` and destroying its own history. |
| rsync archive | Plain files, no history, for bulk data too large to want versioned (tower's `~/vrchat`). |

The NAS never sees plaintext — restic encrypts before upload. Each host has its
own repository under `<repoRoot>/<hostname>`, so there's no lock contention and
one host's corruption can't take the others with it.

Transport is restic's native SFTP backend over SSH. Every host already runs
Tailscale, so once TrueNAS joins the tailnet you can point
`features.backup.nas.host` at its tailnet name and the laptops will back up
from anywhere instead of only on the LAN.

## One-time setup

### 1. On TrueNAS

Create a dataset for the backups and an account the hosts log in as:

```
# dataset, e.g. terashare/backups and terashare/archive
# user: restic, with a shell and a home directory
```

Then:

- Enable the **SSH** service.
- Give the `restic` user a login shell (SFTP needs it).
- Add a **periodic snapshot task** on the backups dataset — daily, keep 30
  days. This is the layer that survives a client deleting its own snapshots.
- Optionally install Tailscale so off-LAN hosts can reach it.

Note the *server-side* dataset path, which includes the pool name
(`/mnt/tank/terashare/backups`, not `/mnt/terashare/backups`). If it differs
from the default, set it:

```nix
features.backup.nas.repoRoot = "/mnt/<pool>/terashare/backups";
features.backup.nas.archiveRoot = "/mnt/<pool>/terashare/archive";
```

### 2. Create the repository password

Needs a Yubikey plugged in. One password shared by all hosts, so any machine
can restore any host's repo:

```
cd /home/max/nix
nix run nixpkgs#agenix -- -e secrets/secrets/restic-password.age \
  -i secrets/master-keys/yubikey-main-identity.pub
nix run .#agenix-rekey.x86_64-linux.rekey
git add secrets/secrets/restic-password.age secrets/rekeyed/
```

Until this exists, a host with `features.backup.enable` fails to build with an
assertion pointing back here.

> The paper key is the disaster-recovery path: if every machine is gone, the
> printed key decrypts the repo password, which decrypts the backups. See
> `yubikeysetup.md`.

### 3. Per host

Each host generates its own SSH key on first activation and never shares it —
the private half stays on the machine. After `nixos-rebuild switch`:

```
journalctl -u restic-ssh-key          # prints the public key
```

Paste that into `restic`'s `~/.ssh/authorized_keys` on the TrueNAS, then kick
off the first run:

```
systemctl start restic-backups-$(hostname)
journalctl -fu restic-backups-$(hostname)
```

The first run creates the repository (`initialize = true`) and uploads
everything, so it takes a while. Subsequent runs are deltas.

## Operating it

The `restic-<hostname>` wrapper has the repository and password preset. Run it
as root:

```
sudo restic-tower snapshots                       # list snapshots
sudo restic-tower stats                           # repo size
sudo restic-tower diff <snap-a> <snap-b>

sudo restic-tower restore latest --target /tmp/r --include /home/max/projects/foo
sudo restic-tower mount /mnt/restore              # browse every snapshot as files
```

Schedules:

| Unit | When | What |
| --- | --- | --- |
| `restic-backups-<host>.timer` | daily, +30m jitter | the backup |
| `restic-maintenance.timer` | Sun 04:00, +1h jitter | `forget --prune` + `check --read-data-subset=2%` |
| `backup-archive.timer` | weekly, +1h jitter | rsync of `archive.paths` |

All three are `Persistent = true`, so a laptop that was asleep catches up after
boot. Pruning is deliberately off the daily path — it's slow over SFTP.

Retention is `--keep-last 3 --keep-daily 7 --keep-weekly 4 --keep-monthly 12
--keep-yearly 3`, adjustable via `features.backup.retention`.

## What gets backed up

`/home/<user>`, minus caches, build output and re-downloadable blobs. The
default exclude list lives in `nixosModules/backup.nix`; add host-specific ones
with `features.backup.extraExclude`. Cargo `target/` directories are skipped
automatically via `--exclude-caches`, since cargo writes `CACHEDIR.TAG`.

tower additionally excludes `~/vrchat` and the llama.cpp model weights, and
mirrors `~/vrchat` to the archive instead:

```nix
features.backup.archive = {
  enable = true;
  paths = ["/home/max/vrchat"];
};
```

The archive is additive by default — local deletions are not propagated. Set
`features.backup.archive.delete = true` to mirror instead.

## Watch the free space

`terashare` was 74% full (1.1T free) when this was set up. tower's restic set
is roughly 50G, but `~/vrchat` alone is 110G in the archive. Check with
`sudo restic-tower stats` before loosening the exclude list.

## Adding a host

1. `ssh <host> "cat /etc/ssh/ssh_host_ed25519_key.pub" > secrets/public-keys/<host>.pub`
2. `nix run .#agenix-rekey.x86_64-linux.rekey` (Yubikey plugged in)
3. Import `../../nixosModules/backup.nix` and set `features.backup.enable = true;`
4. Rebuild, then do step 3 of the one-time setup above.
