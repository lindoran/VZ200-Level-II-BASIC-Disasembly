# VZ200 English BASIC Listing

## What is this?

This is the complete, annotated listing for the VZ200 V2.0 BASIC ROM — the built-in BASIC interpreter for the VZ200 computer.

It's almost a byte-for-byte copy of TRS-80 Level II BASIC, modified for the VZ200's VDG (video display), keyboard, and bespoke cassette tape controls.

This is an English translation of the original German-language listing found in the `./doc` folder.

## File Layout

- `export.lst` — the translated, annotated listing
- `export.asm` — the assembly source, ready to assemble
- `export.*` — other intermediate export files

### z80bench work files

- `annotations.ann` — offset-based annotations for the ROM
- `segments.map` — segment/region definitions
- `symbols.sym` — symbol table
- `VZ200.bin` / `rom.bin` — the original, unmodified system ROM
- `VZ200.hex` — hex dump of the ROM

## Setup

The `z80bench` toolchain lives in `external/z80bench` as a git submodule. It needs to be initialized before the `z80bench-cli` symlink at the project root will resolve:

```
git submodule update --init --recursive
```