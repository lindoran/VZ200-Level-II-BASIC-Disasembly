# VZ200 English Documentation Progress

## Summary of Work (2026-05-27)
- Translated and annotated memory range **0x26E9-0x27C8** (Matrix Management).
- Sourced from German PDF `doc/book - Laser310-ROM-Listing-german.pdf` pages 169-173.
- Identified and labeled key routines:
  - `ARYMN` (0x26E9): Matrix Management entry.
  - `ARYFND` (0x272F): Matrix Found logic.
  - `ARYINI` (0x2742): Setup New Matrix logic.
  - `ARYADR` (0x2795): Determine Address of Matrix Element.
- Added missing system variable symbols:
  - `DIMFLG` (0x78AE)
  - `SAVP` (0x78F3)
  - `ARYTAB` (0x78FB)
  - `STREND` (0x78FD)
- Split instructions at `0x270E`, `0x2726`, and `0x2799` using `segments.map` to handle entry points within "swallowing" instructions (Z80 tricks).
- Verified bit-perfection by building `export.asm` and comparing against `VZ200.bin`.

## Summary of Work (2026-05-27 - Session 2)
- Translated and annotated memory range **0x27C9-0x28D9** (Memory/String Functions).
- Sourced from German PDF `doc/book - Laser310-ROM-Listing-german.pdf` pages 173-179.
- Identified and labeled key routines:
  - `MEM` (0x27C9): MEM Function.
  - `FRE` (0x27D4): FRE Function.
  - `POS` (0x27F5): POS Function.
  - `USR` (0x27FE): USR Function.
  - `CONVRT` (0x2819): Convert value to desired type.
  - `DIRCHK` (0x2828): Check for DIRECT mode.
  - `STRS` (0x2836): STR$ Function.
  - `STRINI` (0x2857): Initialize string.
  - `STRFDESC` (0x2865): Extract string from descriptor.
  - `STCPERR` (0x28A1): STRING FORMULA TOO COMPLEX error.
  - `STROUT` (0x28A6): Print string.
  - `STR_RES_SPACE` (0x28BF): Reserve string space.
- Added missing system variable symbols:
  - `TTYPOS` (0x78A6)
  - `STKTOP` (0x78A0)
  - `VALTYP` (0x78AF)
  - `MEMSIZ` (0x78B1)
  - `TEMPPT` (0x78B3)
  - `TEMPST` (0x78B5)
  - `DSCTMP` (0x78D3)
  - `FRETOP` (0x78D6)
- Resolved Z80 "swallowing" tricks at `0x2887` and `0x28C0` using `segments.map`.
- Verified bit-perfection: `42c8f9e6c2133ae0e953b89ccbbdb7e2`.

## Prompt
"Please read @GEMINI.md, and @Z80WORKBENCH_WORKFLOW.md and work on 0x27C9-0x28D9 This starts at line 6612 in @export.lst this is pages 173-179 in the pdf @doc/book - Laser310-ROM-Listing-german.pdf remember we are translating from the pdf the inline comments, and block comments from german to english."

## Statistics
- **Annotations**: 5405 / 100,000 (5.4%)
- **Symbols**: 327 / 6,000 (5.5%)

## Toolchain Notes
- Discovered that `batch` mode in `z80bench-cli` fails on blank lines; removed them before processing.
- Verified `export.lst` contains correctly translated English headers and inline comments.

## Issues Encountered
- None.
