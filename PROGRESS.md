# Project Progress - VZ200 English Documentation

## Session: Sunday, May 24, 2026

### Work Summary
- **Target Range**: 0x1ED9 - 0x1FCB
- **Work Done**:
    - Translated and annotated the ROM in the range 0x1ED9 - 0x1FCB based on the German ROM listing (pages 136-140).
    - Identified and handled several "Z80 tricks" where instructions jump into the middle of other instructions (e.g., `RETURN`, `DATA`, `LET` tricks).
    - Added block headers for `UNDEFINED STATEMENT - Error`, `RETURN Statement`, `DATA Statement`, `ELSE Statement`, `LET Statement`, `ON Statement`, and `RESUME Statement`.
    - Added several descriptive labels and symbols for jump targets (`ERR_UNDEFINED_STATEMENT`, `CMD_RETURN`, `CMD_DATA`, `CMD_ELSE`, `CMD_LET`, `CMD_ON`, `CMD_RESUME`, `EXEC_GOTO`, `GOTO_CONTINUE`, `ERROR_HANDLER_RESUME`).
    - Fixed a duplicate `GOSUB` symbol at 0x1EB1.
    - Verified the build: `export.asm` assembles to a bit-perfect match of `VZ200.bin`.

### Statistics
- **Total Annotations**: 3847 (Limit: 100,000)
- **Total Symbols**: 273 (Limit: 6,000)

### Toolchain and Issues
- Used `z80bench-cli` for all annotation and symbol updates.
- Encountered "Z80 tricks" (hidden entry points) at 0x1F03, 0x1F05, 0x1F25, 0x1F59. These were handled by adding `DIRECT_BYTE` entries in `segments.map`.
- Found a duplicate `GOSUB` symbol in `symbols.sym` which caused a build error; it was removed and re-added correctly.
- Disassembly for `RST 8` operand was incorrectly shown as `ADC A,L` at 0x1F72 and 0x1F9F; these were corrected to `DEFB` using `DIRECT_BYTE` segments.

### User Prompt
"Please read @GEMINI.md, and @Z80WORKBENCH_WORKFLOW.md and work on: 0x1ED9 - 0x1FCB This starts at line 5111 in @export.lst this is pages 136-140 in the pdf @doc/book - Laser310-ROM-Listing-german.pdf remember we are translating from the pdf the inline comments, and block comments from german to english."

### Verification
- `md5sum export.bin VZ200.bin`: `42c8f9e6c2133ae0e953b89ccbbdb7e2` (Match)
- Checked `export.lst` for inline comments: Present and verified.

## Session: 2026-05-24
### Range: 0x1FCD - 0x20FD (Line 5274 in export.lst)
- Translated and annotated implementation of:
  - RESUME NEXT
  - ERROR statement
  - AUTO statement
  - IF statement
  - LPRINT statement
  - PRINT statement (including PRINT @ and PRINT #)
- Added block headers and labels for internal entry points (e.g., IF_THEN, PRINT_LOOP).
- Handled RST 8 tricks at 0x1F25, 0x2017, and 0x208E using DIRECT_BYTE segments to expose embedded tokens.
- Added label CMD_END_INPUT at 0x1DBE for the BREAK in INPUT handler.
- Verified bit-perfection: Build matches VZ200.bin (MD5: 42c8f9e6c2133ae0e953b89ccbbdb7e2).
- Stats:
  - Symbols: 280
  - Annotations: 3991
