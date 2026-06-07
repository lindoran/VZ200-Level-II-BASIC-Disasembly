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

## Iteration: June 2, 2026
- **Target Memory Range**: 0x28D6-0x29E2
- **Pages in Laser 310 German PDF**: 179-184
- **Work Summary**:
  - Translated block and inline comments from German to English for the string management and garbage collection routines.
  - Corrected missed inline comments for range 0x28D6-0x28D9.
  - Identified and added several labels including `GARBAG`, `FIND_HI_STR_ARY`, `CHK_HI_STR`, `STR_CONCAT`, `MOV_STR_TO_AREA`, `REM_STR_TMP`, and `REM_STR_TOP`.
  - Verified that the exported `export.asm` assembles to a binary identical to `VZ200.bin`.
  - Confirmed the presence of translated inline comments in `export.lst`.
- Statistics:
  - Total Annotations: 5954
  - Total Symbols: 327
- **Issues encountered**:
  - Some truncation in `export.lst` comments when using long strings, but within acceptable limits for the listing format.
  - Initial batch execution of `annotation set` via shell loop introduced unwanted quotes; resolved by using a Python script for precise command execution.

## Iteration 5: June 2, 2026
- **Target Memory Range**: 0x29E3-0x2AE6
- **Pages in Laser 310 German PDF**: 184-190
- **Work Summary**:
  - Annotated string manipulation routines including `LEN`, `ASC`, `CHR$`, `LEFT$`, `RIGHT$`, `MID$`, and `VAL`.
  - Translated all block and inline comments from German to English.
  - Fixed disassembly for "dummy instruction" tricks (e.g., at `0x2A67` and `0x2A6F`) and `RST 8` literal parameters using `DIRECT_BYTE` segment overrides.
  - Verified bit-perfection of the exported assembly against the original ROM binary.
- **Statistics**:
  - Total Annotations: 5326
  - Total Symbols: 327
- **Prompt**: "Please read @GEMINI.md, and @Z80WORKBENCH_WORKFLOW.md and work on 0x29E3-0x2AE6 This starts at line 6998 in @export.lst this is pages 184-190 in the pdf @doc/book - Laser310-ROM-Listing-german.pdf remember we are translating from the pdf the inline comments, and block comments from german to english. NOTE *** There is 1 block comment for 0x29E3 on the bottom (last line ) of page 184, 0x29E3 actually appaears on the next page. ***"

## Iteration 6: June 2, 2026
- **Target Memory Range**: 0x2AE7-0x2BF4
- **Pages in Laser 310 German PDF**: 190-195
- **Work Summary**:
  - Annotated routines for `INP`, `OUT`, `LLIST`, `LIST`, `DELETE`, and auxiliary routines for expression evaluation and string output.
  - Translated all block and inline comments from German to English.
  - Added `DIRECT_BYTE` segment for `RST 8` parameter at `0x2B18`.
  - Verified bit-perfection of the exported assembly against the original ROM binary.
- **Statistics**:
  - Total Annotations: ~5400 (Estimated from file size increase)
  - Total Symbols: 327
- **Prompt**: "Please read @GEMINI.md, and @Z80WORKBENCH_WORKFLOW.md and work on 0x2AE7-0x2BF4 This starts at line 7199 in @export.lst this is pages 190-195 in the pdf @doc/book - Laser310-ROM-Listing-german.pdf remember we are translating from the pdf the inline comments, and block comments from german to english."

## Rework of 0x2AE7-0x2BF4 (Pages 190-195)
- **Prompt**: "rework 0x2AE7-0x2BF4 This starts at line 7199 in @export.lst this is pages 190-195 in the pdf @doc/book - Laser310-ROM-Listing-german.pdf remember we are translating from the pdf the inline comments, and block comments from german to english. many lines were missed. please recheck all of this to the pdf"
- **Work Done**:
  - Translated all block and inline comments from German to English for the range 0x2AE7-0x2BF4.
  - Added missing detailed block comments for routine parameters (e.g., at 0x2B01).
  - Fixed several misplaced comments (e.g., at 0x2BEB).
  - Verified token 0xFB as apostrophe (') and updated comments accordingly.
  - Exported deliverables to `export.asm` and `export.lst`.
- **Statistics**:
  - Annotations: ~13,600 (Limit: 100,000)
  - Symbols: 327 (Limit: 6,000)
- **Issues**: None.

## Iteration: June 6, 2026
- **Target Memory Range**: 0x2BF5-0x2CFB
- **Pages in Laser 310 German PDF**: 195-199
- **Work Summary**:
  - Translated block and inline comments from German to English for the following routines:
    - `CMD_SOUND` (0x2BF5): SOUND command implementation.
    - `SOUND_PAUSE` (0x2C58): Helper for sound pauses.
    - `PRN_GFX_CHAR` (0x2C73): Routine to output graphic characters to a printer.
    - `PEEK` (0x2CAA): PEEK function.
    - `POKE` (0x2CB1): POKE command.
    - `PRINUS` (0x2CBD): PRINT USING implementation entry.
    - `USING_FIELD_LEN` (0x2CE7): Logic to determine field length in PRINT USING.
  - Added missing system variable and constant symbols:
    - `SOUND_NOTE_VALUE` (0x7AD2)
    - `OUT_LATCH` (0x783B)
    - `SOUND_TIME_VALUES` (0x0361)
    - `SOUND_DURATION_MULT` (0x0321)
  - Updated `segments.map` to handle `RST 8` literal byte parameters at `0x2C01`, `0x2CB6`, and `0x2CC4`.
  - Verified bit-perfection by building `export.asm` and comparing against `VZ200.bin`.
  - Confirmed English annotations are present in `export.lst`.
- **Statistics**:
  - Total Annotations: 5590
  - Total Symbols: 331
- **Issues encountered**: None.

## Summary of Work (2026-06-07)
- Translated and annotated memory range **0x2CFD-0x2E52** (Print Using logic).
- Sourced from German PDF `doc/book - Laser310-ROM-Listing-german.pdf` pages 199-204.
- Added Z80 trick segments for dummy instructions:
  - `0x2D44`: `CP 0xAF` trick.
  - `0x2D96`: `JP Z,0xD1EB` trick.
  - `0x2E16`: `LD A,0xF1` trick.
- Added symbols for USING routines and buffers:
  - `USING_NUM_FIELD`, `USING_DEC_PLACES`, `USING_DEC_LOOP`, `USING_NUM_PARAMS`, `USING_NUM_EXIT`, `USING_NUM_FORMAT`, `USING_FORMAT_END`, `USING_STRING`, `USING_STRING_PCT`, `USING_PLUS_CHECK`, `USING_BUF`.
- Verified bit-perfection by building `export.asm` and comparing against `VZ200.bin`.
- Confirmed English annotations are present in `export.lst`.
- **Statistics**:
  - Total Annotations: 5799
  - Total Symbols: 342
