# Bare-metal async Rust template (embassy, RP2040)

```sh
cargo generate --path ~/nix/rust/templates/embedded --name my-firmware
```

## Toolchain prerequisite

This template needs the `thumbv6m-none-eabi` target. **nixpkgs' `rustc` does
not ship bare-metal targets** — its sysroot only carries the host, wasm and
bpf. Either:

- let the bundled `rust-toolchain.toml` do it, with `rustup` on `PATH`; or
- add a Rust overlay (fenix / rust-overlay) to the flake and pull
  `targets.thumbv6m-none-eabi.stable.rust-std` declaratively.

Until one of those is in place `cargo build` fails with
`can't find crate for 'core'`.

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

## Note on the editor

`rust-analyzer` is configured (in `nvim/plugin/rust.lua`) to detect embedded
projects and turn **off** `cargo.allFeatures`. Enabling every feature on a HAL
crate selects mutually-exclusive chip families at once and makes the whole
crate fail to resolve. Detection keys on a `-none-` target in
`.cargo/config.toml`, a `#![no_std]` crate root, or an embedded dependency in
`Cargo.toml` — this template trips all three.
