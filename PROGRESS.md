# Progress Report - June 8, 2026 (Re-work)

## Target Memory Range
0x2F55 - 0x307B (Pages 209-213 of German PDF)

## Work Summary
- Re-worked the translation and annotation of the following routines to ensure all German terms (like 'ja', 'nein', 'fertig', 'zurück') are idiomatic English:
  - `KBD_SCAN_BIT_LOOP` (0x2F56): Keyboard bit-by-bit scan.
  - `KBD_CALC_OFFSET` (0x2F63): Calculating offset for keyboard tables.
  - `KBD_LOAD_TABLE` (0x2F76): Loading keyboard translation tables.
  - `KBD_REPEAT` (0x2FD7): Keyboard repeat logic and timing.
  - `ECHO_CHAR` (0x301B): Character display routine.
  - `DIRECT_OUT_CHAR_TOKEN` (0x3039): Outputting keywords and characters.
  - `CHECK_APPEND_PAREN` (0x305E): Automatic '(' insertion logic.
  - `DEF_SPECIAL_PROC` (0x3069): Special case for 'DEF FN'.
- Fixed several instances where 'ja' was left untranslated or translated as 'no' by mistake.
- Verified all inline and block comments against the German source PDF (pages 209-213).
- Added labels and comments to document the code structure and logic clearly in English.
- Verified bit-perfection against `VZ200.bin`.

## Statistics
- Total Symbols: 364
- Total Annotations: 6053
- Limits: Well within project maximums.

## Verification
- Build successful and bit-perfect.
- `export.lst` checked for English annotations and inline comments.
- Grep search confirmed no remaining German keywords ('ja', 'nein', 'fertig', 'zurück') in the target range.

## Issues/Notes
- Corrected a previous error where some 'ja!' comments were missed or mis-translated.
- Final listing now uses consistent English terminology for branch results and completion status.

## Iteration: 2026-06-09
- **Target Range**: 0x307C-0x31BE
- **Summary**: Translated and applied annotations for character output control, buffered output, and cursor management. Added descriptive symbols for key entry points.
- **Toolchain**: Used `z80bench-cli` for annotation management and `z88dk-z80asm` for verification.
- **Issues**: OCR misread 0x3106 as 0x3186 on page 215. Verified correct address in disassembly.
- **Statistics**:
  - Total Annotations: ~7075 (Blocks: 452, Comments: 6196, Labels: 427)
  - Total Symbols: 375
- **Verification**: Built `export.asm` and confirmed MD5 match with `VZ200.bin`.

## Iteration: 2026-06-09 (Part 2)
- **Target Range**: 0x31BE-0x32C5
- **Summary**: Translated and applied annotations for cursor movement (inc/dec/up/down/home/SOL) and screen clearing. Added relevant RAM symbols and jump labels.
- **Toolchain**: Used `z80bench-cli` for annotation management and `z88dk-z80asm` for verification.
- **Issues**: None.
- **Statistics**:
  - Total Annotations: ~7193 (Blocks: 459, Comments: 6307, Labels: 427)
  - Total Symbols: 386
- **Verification**: Built `export.asm` and confirmed MD5 match with `VZ200.bin`.
