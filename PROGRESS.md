# VZ200 BASIC ROM Disassembly Progress

## Session: April 25, 2026

### Task
Annotate the byte range `0x08A8` to `0x0904` based on the German ROM listing PDF.

### Toolchain Improvements
- **Fixed Annotation Limit:** Discovered that `z80bench-cli` had a hardcoded limit of 1000 annotations (`MAX_ANNOTATIONS` in `annotate.c`), which had been reached. Increased the limit to **100,000** and rebuilt the toolchain.
- **Increased Symbol Limit:** Increased `MAX_SYMBOLS` in `symbols.c` to **6,000** to accommodate future growth.
- **Improved Disassembly:** Added a `DIRECT_BYTE` segment at `0x08D8` to correctly handle the "JP NC trick" (opcode `D2` used to skip the next two bytes). This allowed the disassembler to correctly identify `0x08D9` and `0x08DA` as `POP BC` and `POP HL` respectively, which are valid entry points from a `JR NC` at `0x08D0`.

### Statistics
- **Total Annotations:** 1,315 (Limit: 100,000)
  - Labels: 134
  - Comments: 1,043
  - Blocks: 138
- **Total Symbols:** 35 (Limit: 6,000)

### Work Completed
- **Range:** `0x08A8` - `0x0904` (Single Precision Division logic).
- **Annotations:** Added block comments and inline comments translated into English from `doc/book - Laser310-ROM-Listing-german.pdf`. (Correction: initially copied German text, now updated to English).
- **Symbols:** Defined several symbols for the division routine's RAM workspace:
  - `MULDIV` (`0x0914`)
  - `FDIVC` (`0x7880`)
  - `FDIVC_ARG` (`0x7881`)
  - `FDIVB_ARG` (`0x7885`)
  - `FDIVA_ARG` (`0x7889`)
  - `FDIVG_ARG` (`0x788C`)
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified to contain all new inline comments and block headers in English.

### Deliverable Check Note
- **Language Verification:** Added a step to ensure all exported annotations are translated into English, as the original source is in German.

### Issues Encountered
- The 1000-annotation limit in the backend was silently failing to save new comments. Rebuilding the tool resolved this.
- The "JP NC trick" initially caused the disassembler to skip the targets of a relative jump, which was corrected by manual segment definition.
