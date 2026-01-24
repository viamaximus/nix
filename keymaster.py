#!/usr/bin/env python3
"""
keymaster.py — encoder/decoder for rf-modulation-platform "game keys".

Change: if you run `keymaster.py -r <CODE>`, the code is taken from the
positional argument automatically (no --code needed).
"""

from __future__ import annotations

import argparse
import base64
import random
import re
from dataclasses import dataclass
from typing import Optional


MODULATION_RANGES = {
    "MOD_2FSK": range(0, 3),        # 0,1,2
    "MOD_ASK_OOK": range(3, 6),     # 3,4,5
    "MOD_GFSK": range(6, 9),        # 6,7,8
    "MOD_4FSK": range(9, 12),       # 9,10,11
    "MOD_MSK": range(12, 15),       # 12,13,14
}

DEBUG_CODES = (15, 16)  # debug uses 15 or 16


def b32encode_nopad(data: bytes) -> str:
    return base64.b32encode(data).decode("ascii").rstrip("=")


def b32decode_nopad(s: str) -> bytes:
    s = s.strip().upper().replace("-", "").replace(" ", "")
    pad = (-len(s)) % 8
    return base64.b32decode(s + ("=" * pad), casefold=True)


def parse_hex_byte(s: str) -> int:
    s = s.strip().lower()
    if s.startswith("0x"):
        s = s[2:]
    if not re.fullmatch(r"[0-9a-f]{1,2}", s):
        raise ValueError("Expected a hex byte like 0xA5 or A5")
    return int(s, 16)


def parse_float(s: str, lo: float, hi: float) -> float:
    v = float(s.strip())
    if v < lo or v > hi:
        raise ValueError(f"Expected float in range [{lo}, {hi}]")
    return v


def parse_int(s: str, lo: int, hi: int) -> int:
    v = int(s.strip(), 10)
    if v < lo or v > hi:
        raise ValueError(f"Expected integer in range [{lo}, {hi}]")
    return v


def prompt_until_ok(prompt: str, parser_fn):
    while True:
        try:
            return parser_fn(input(prompt).strip())
        except (ValueError, TypeError) as e:
            print(f"  Error: {e}")


def choose_modulation_code(mod_name: str, randomize_slot: bool) -> int:
    mod_name = mod_name.strip().upper()
    if mod_name == "MOD_DEBUG":
        return random.choice(DEBUG_CODES) if randomize_slot else DEBUG_CODES[0]

    if mod_name not in MODULATION_RANGES:
        raise ValueError(f"Invalid modulation: {mod_name}")

    r = MODULATION_RANGES[mod_name]
    return random.choice(list(r)) if randomize_slot else min(r)


def modulation_from_code(code: int) -> str:
    if code in DEBUG_CODES:
        return "MOD_DEBUG"
    for name, r in MODULATION_RANGES.items():
        if code in r:
            return name
    return f"UNKNOWN({code})"


@dataclass
class GameKey:
    preamble_byte: int
    address_value: int
    modulation_code: int
    data_rate: float
    deviation: float
    rx_bandwidth: float

    def pack(self) -> bytes:
        data_rate_t = int(round(self.data_rate * 10))
        deviation_t = int(round(self.deviation * 10))
        rx_bw_t = int(round(self.rx_bandwidth * 10))

        if not (0 <= self.preamble_byte <= 255):
            raise ValueError("PREAMBLE_BYTE must fit in a byte")
        if not (0 <= self.address_value <= 255):
            raise ValueError("ADDRESS_VALUE must fit in a byte")
        if not (0 <= self.modulation_code <= 255):
            raise ValueError("MODULATION_CODE must fit in a byte")
        if not (0 <= data_rate_t <= 255):
            raise ValueError("DATA_RATE out of encodable range (0.0..25.5 in steps of 0.1)")
        if not (0 <= deviation_t <= 65535):
            raise ValueError("DEVIATION out of encodable range (0.0..6553.5 in steps of 0.1)")
        if not (0 <= rx_bw_t <= 65535):
            raise ValueError("RX_BANDWIDTH out of encodable range (0.0..6553.5 in steps of 0.1)")

        return (
            bytes([
                self.preamble_byte & 0xFF,
                self.address_value & 0xFF,
                self.modulation_code & 0xFF,
                data_rate_t & 0xFF,
            ])
            + deviation_t.to_bytes(2, "big")
            + rx_bw_t.to_bytes(2, "big")
        )

    @staticmethod
    def unpack(data: bytes) -> "GameKey":
        if len(data) != 8:
            raise ValueError(f"Expected 8 bytes, got {len(data)}")

        preamble = data[0]
        address = data[1]
        modulation_code = data[2]
        data_rate_t = data[3]
        deviation_t = int.from_bytes(data[4:6], "big")
        rx_bw_t = int.from_bytes(data[6:8], "big")

        return GameKey(
            preamble_byte=preamble,
            address_value=address,
            modulation_code=modulation_code,
            data_rate=data_rate_t / 10.0,
            deviation=deviation_t / 10.0,
            rx_bandwidth=rx_bw_t / 10.0,
        )


def generate_interactive(randomize_mod_slot: bool) -> GameKey:
    print("Enter game-key parameters. Examples shown in parentheses.\n")

    preamble = prompt_until_ok(
        "PREAMBLE_BYTE   = 0xYZ (eg 0xA5): ",
        parse_hex_byte,
    )

    address = prompt_until_ok(
        "ADDRESS_VALUE   = 0xYZ (eg 0x2D): ",
        parse_hex_byte,
    )

    print("MODULATION_TYPE options:")
    print("  - MOD_2FSK")
    print("  - MOD_ASK_OOK")
    print("  - MOD_GFSK")
    print("  - MOD_4FSK")
    print("  - MOD_MSK")
    print("  - MOD_DEBUG (uses code 15 or 16)")
    mod_name = prompt_until_ok(
        "MODULATION_TYPE = one of the above (eg MOD_2FSK): ",
        lambda s: s.strip().upper(),
    )
    modulation_code = choose_modulation_code(mod_name, randomize_mod_slot)

    data_rate = prompt_until_ok(
        "DATA_RATE       = float x.y (examples say 1.2): ",
        lambda s: parse_float(s, 0.0, 25.5),
    )

    deviation = prompt_until_ok(
        "DEVIATION       = float xy.z (example 25.0): ",
        lambda s: parse_float(s, 0.0, 6553.5),
    )

    rx_bw = prompt_until_ok(
        "RX_BANDWIDTH    = float XYZ (example 150.0): ",
        lambda s: parse_float(s, 0.0, 6553.5),
    )

    return GameKey(
        preamble_byte=preamble,
        address_value=address,
        modulation_code=modulation_code,
        data_rate=data_rate,
        deviation=deviation,
        rx_bandwidth=rx_bw,
    )


def try_parse_human_code(s: str) -> Optional[bytes]:
    """
    Human format:
      A5 2D 3 12 250 1500

    Tokens:
      preamble(hex) address(hex) modulation_code(int or hex) data_rate_tenths(int)
      deviation_tenths(int) rx_bw_tenths(int)
    """
    toks = re.split(r"[\s,]+", s.strip())
    toks = [t for t in toks if t]
    if len(toks) < 6:
        return None

    try:
        preamble = parse_hex_byte(toks[0])
        address = parse_hex_byte(toks[1])

        modtok = toks[2].lower()
        if modtok.startswith("0x"):
            modulation_code = int(modtok, 16)
        elif re.fullmatch(r"[0-9a-f]{1,2}", modtok):
            modulation_code = int(modtok, 16)
        else:
            modulation_code = int(modtok, 10)

        data_rate_t = parse_int(toks[3], 0, 255)
        deviation_t = parse_int(toks[4], 0, 65535)
        rx_bw_t = parse_int(toks[5], 0, 65535)

        key = GameKey(
            preamble_byte=preamble,
            address_value=address,
            modulation_code=modulation_code,
            data_rate=data_rate_t / 10.0,
            deviation=deviation_t / 10.0,
            rx_bandwidth=rx_bw_t / 10.0,
        )
        return key.pack()
    except Exception:
        return None


def decode_code(code: str) -> bytes:
    # 1) Try Base32
    try:
        data = b32decode_nopad(code)
        if len(data) == 8:
            return data
    except Exception:
        pass

    # 2) Try human format
    human = try_parse_human_code(code)
    if human is not None:
        return human

    raise ValueError("Could not parse code as Base32 or human format: A5 2D 3 12 250 1500")


def print_key(key: GameKey, raw: bytes):
    mod_name = modulation_from_code(key.modulation_code)

    print("\nDecoded game key:")
    print(f"  PREAMBLE_BYTE   = 0x{key.preamble_byte:02X}")
    print(f"  ADDRESS_VALUE   = 0x{key.address_value:02X}")
    print(f"  MODULATION_CODE = {key.modulation_code}  -> {mod_name}")
    print(f"  DATA_RATE       = {key.data_rate:.1f}")
    print(f"  DEVIATION       = {key.deviation:.1f}")
    print(f"  RX_BANDWIDTH    = {key.rx_bandwidth:.1f}")

    data_rate_t = int(round(key.data_rate * 10))
    deviation_t = int(round(key.deviation * 10))
    rx_bw_t = int(round(key.rx_bandwidth * 10))

    print("\nHuman code:")
    print(
        "  "
        + " ".join(
            [
                f"{key.preamble_byte:02X}",
                f"{key.address_value:02X}",
                str(key.modulation_code),
                str(data_rate_t),
                str(deviation_t),
                str(rx_bw_t),
            ]
        )
    )

    print("\nRaw bytes:")
    print("  " + " ".join(f"{b:02X}" for b in raw))

    print("\nBase32 code:")
    print("  " + b32encode_nopad(raw))


def main():
    ap = argparse.ArgumentParser(prog="keymaster.py")
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("-g", "--generate", action="store_true", help="Generate a new game key by prompting for values")
    g.add_argument("-r", "--read", action="store_true", help="Read/decode an existing game key")

    # Positional code for -r usage: `keymaster.py -r VK5QALACFMNAU`
    ap.add_argument("code", nargs="?", help="Code to decode (Base32 or human format). Used with -r/--read.")

    ap.add_argument(
        "--randomize-mod-slot",
        action="store_true",
        help="When encoding, pick a random value inside the 3-slot range for the chosen modulation; for debug chooses 15 or 16.",
    )

    args = ap.parse_args()

    if args.generate:
        key = generate_interactive(randomize_mod_slot=args.randomize_mod_slot)
        raw = key.pack()
        print("\nGenerated.\n")
        print_key(key, raw)
        return

    if args.read:
        if args.code is None:
            # Still allow interactive paste if they didn't provide positional arg
            code = input("Paste code to decode: ").strip()
        else:
            code = args.code.strip()

        raw = decode_code(code)
        key = GameKey.unpack(raw)
        print_key(key, raw)
        return


if __name__ == "__main__":
    main()

