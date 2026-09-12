/* RP2040 memory layout.
 *
 * BOOT2 is the 256-byte second-stage bootloader the chip's ROM copies into
 * RAM and runs; embassy-rp supplies its contents and link-rp.x places it.
 * FLASH assumes the 2 MiB part on a stock Pico -- adjust LENGTH for a board
 * with a different QSPI chip. RAM is the RP2040's 264 KiB of SRAM.
 *
 * For RP2350 (Pico 2) this file changes and the `rp2040` feature in
 * Cargo.toml becomes `rp235xa`.
 */
MEMORY
{
    BOOT2 : ORIGIN = 0x10000000, LENGTH = 0x100
    FLASH : ORIGIN = 0x10000100, LENGTH = 2048K - 0x100
    RAM   : ORIGIN = 0x20000000, LENGTH = 264K
}
