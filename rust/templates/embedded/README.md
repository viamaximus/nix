# Bare-metal async Rust template (embassy, RP2040)

```sh
cargo generate --path ~/nix/rust/templates/embedded --name my-firmware
```

## Toolchain

The `thumbv6m-none-eabi` target comes from fenix, declared in `flake.nix` and
pulled in by `features.rust.embeddedTargets` in
`homeManagerModules/programs/neovim.nix`. Nothing to install by hand.

nixpkgs' own `rustc` cannot do this -- its sysroot ships std for the host,
wasm and bpf only, and its `rustc-src` contains just `proc_macro`, so even
`-Z build-std` is not a way out. That is why the whole toolchain (rustc,
cargo, clippy, rustfmt, rust-analyzer) comes from fenix: a cross target's
`rust-std` is only usable by the exact rustc release that built it.

To add another target, append it to `features.rust.embeddedTargets`.
`thumbv7em-none-eabihf` (STM32F4, nRF52) is already on the default list.

Verified building: 19.8 KB of text for the debug profile, linking cleanly for
RP2040.

## What's in it

| Crate | Role |
|---|---|
| `embassy-executor` | Async task executor (`platform-cortex-m`, thread + interrupt) |
| `embassy-time` | Timers and delays, with uptime timestamps in logs |
| `embassy-sync` | Channels and mutexes usable from interrupt context |
| `embassy-rp` | RP2040 HAL |
| `defmt` / `defmt-rtt` | Deferred formatting; logs stream over the debug probe |
| `panic-probe` | Panic handler that reports through defmt |
| `cortex-m` / `cortex-m-rt` | Core peripheral access and the reset vector |

## Running

`cargo run` flashes the board and streams logs, via the runner in
`.cargo/config.toml`:

```sh
cargo run --release          # probe-rs run --chip RP2040
probe-rs list                # check the probe is visible first
```

`probe-rs-tools` is installed globally by the Neovim module.

## Retargeting

Only the HAL line changes; `embassy-executor`, `-time` and `-sync` are
chip-agnostic. Swap `embassy-rp` for `embassy-stm32` / `embassy-nrf`, then
update three places:

1. `Cargo.toml` — the HAL dependency and its chip feature
2. `.cargo/config.toml` — `build.target` and `probe-rs --chip`
3. `build.rs` — drop `-Tlink-rp.x` (that one is RP2040-specific)
4. `memory.x` — flash/RAM origins and lengths for the new part

Make sure the new target is in `features.rust.embeddedTargets` too, or the
build fails with `can't find crate for 'core'`.

## Note on the editor

`rust-analyzer` is configured (in `nvim/plugin/rust.lua`) to detect embedded
projects and turn **off** `cargo.allFeatures`. Enabling every feature on a HAL
crate selects mutually-exclusive chip families at once and makes the whole
crate fail to resolve. Detection keys on a `-none-` target in
`.cargo/config.toml`, a `#![no_std]` crate root, or an embedded dependency in
`Cargo.toml` — this template trips all three.
