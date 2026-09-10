//! Linker configuration.
//!
//! `link.x` comes from cortex-m-rt, `link-rp.x` and the RP2040 `memory.x` are
//! emitted by embassy-rp's own build script, and `defmt.x` sets up the defmt
//! log sections. `--nmagic` turns off page alignment, which otherwise wastes
//! a large chunk of the RP2040's flash.
fn main() {
    println!("cargo:rustc-link-arg-bins=--nmagic");
    println!("cargo:rustc-link-arg-bins=-Tlink.x");
    println!("cargo:rustc-link-arg-bins=-Tlink-rp.x");
    println!("cargo:rustc-link-arg-bins=-Tdefmt.x");
    println!("cargo:rerun-if-changed=build.rs");
}
