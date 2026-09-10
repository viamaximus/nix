# Hosted Rust application template

Generate a project from it:

```sh
cargo generate --path ~/nix/rust/templates/app --name my-tool
```

## What's in it

| Crate | Role |
|---|---|
| `color-eyre` | Error reports with colour, source chains and backtraces |
| `clap` (derive) | CLI parsing, with `env` and `wrap_help` on |
| `serde` / `serde_json` | (De)serialisation |
| `jiff` | Dates and times, with real time-zone handling |
| `itertools` | Iterator adaptors (`sorted_by`, `chunks`, `dedup`, ...) |
| `rayon` | Data parallelism |
| `tokio` | Async runtime |
| `command-run` | Subprocesses with checked exit status and captured output |
| `criterion` (dev) | Statistical benchmarking, wired up as a `harness = false` bench |

## Layout

The logic lives in `src/lib.rs` rather than `src/main.rs`. That is what lets
`benches/` and integration tests reach it — a binary-only crate can't be
benchmarked from `benches/`.

```
src/lib.rs           word-frequency logic + unit tests
src/main.rs          clap CLI, tokio entrypoint, color-eyre install
benches/throughput.rs  criterion benches over three input sizes
```

## Commands

```sh
cargo run -- words README.md -n 5   # run it
cargo run -- --json words -         # read stdin, emit JSON
cargo nextest run                   # tests
cargo criterion                     # benches with HTML reports in target/criterion
cargo machete                       # drop the deps you didn't end up using
```

The template deliberately ships more dependencies than most projects need.
`cargo machete` is the intended way to prune back after you know what the
project actually is.
