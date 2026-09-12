//! Linker configuration.
//!
//! `memory.x` has to be copied somewhere on the linker's search path, which is
//! the conventional cortex-m-rt build-script dance. `link.x` then comes from
//! cortex-m-rt, `link-rp.x` from embassy-rp (it places the RP2040 boot2 block),
//! and `defmt.x` sets up the defmt log sections. `--nmagic` turns off page
//! alignment, which would otherwise waste a large chunk of flash.

use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

fn main() {
    let out = PathBuf::from(env::var_os("OUT_DIR").expect("OUT_DIR is always set"));

    File::create(out.join("memory.x"))
        .expect("failed to create memory.x in OUT_DIR")
        .write_all(include_bytes!("memory.x"))
        .expect("failed to write memory.x");

    println!("cargo:rustc-link-search={}", out.display());

    println!("cargo:rustc-link-arg-bins=--nmagic");
    println!("cargo:rustc-link-arg-bins=-Tlink.x");
    println!("cargo:rustc-link-arg-bins=-Tlink-rp.x");
    println!("cargo:rustc-link-arg-bins=-Tdefmt.x");

    println!("cargo:rerun-if-changed=memory.x");
    println!("cargo:rerun-if-changed=build.rs");
}
