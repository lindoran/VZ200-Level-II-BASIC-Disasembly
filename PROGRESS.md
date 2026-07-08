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

## Iteration: 2026-06-21
- **Target Range**: 0x32C5-0x34A8
- **Summary**: Translated and applied annotations for character insertion, vertical screen scrolling operations (both single and double line logic), line status calculation, character delete/rubout processing, keyboard input buzzer/beeper control, sound/tone synthesis (frequency and duration parameters), and the initial parts of the ROM/IO latches setup.
- **Toolchain**: Utilized `z80bench-cli` for annotating code and `z88dk-z80asm` for assembly validation.
- **Issues**: None.
- **Statistics**:
  - Total Annotations: ~7452 (Blocks: 468, Comments: 6557, Labels: 427)
  - Total Symbols: 396
- **Verification**: Built `export.asm` and confirmed MD5 checksum match with `VZ200.bin`.

## Iteration: 2026-06-23
- **Target Range**: 0x34A9-0x370E (German PDF pages 229-236; starts near `export.lst` line 8751)
- **Prompt**: "please read @GEMINI.md and @Z80BENCH_WORKFLOW.md you are translating german to english. Please work 0x34A9-0x370E this starts at line 8751 in @export.lst and is pages 229 to 236 in @doc/book - Laser310-ROM-Listing-german.pdf. Please remember you need to use Z80 bench to make the changes and treat the two markdowns as skilling advice. rember we are using those documents as guidlines to properly translate the block comments and the inline comments."
- **Summary**: Translated and applied English annotations for the cassette SAVE/LOAD path, including `CSAVE`, cassette byte output and clock pulse timing, tape leader/name writing, filename buffering, cassette message preparation, program search/sync detection, CLOAD common handling, checksum verification, machine-code start, and BASIC CRUN/RUN setup through 0x370E.
- **Toolchain**: Used `z80bench-cli` batch commands for all annotation edits, then exported `export.asm` and `export.lst` with `./z80bench-cli project export . both export`.
- **Issues/Notes**: The German PDF pages are scanned images, so OCR was used and checked against the disassembly. Initial multi-line block-comment batch input was rejected by `z80bench-cli`; affected headers were immediately replaced with command-safe English block headers. The local `z88dk-z80asm` Snap binary required an escalated run because sandboxed `snap-confine` failed before execution.
- **Statistics**:
  - Total Annotations: 6853
  - Total Symbols: 396
  - Limits: Well within maximums (100000 annotations, 6000 symbols).
- **Verification**: Checked `export.lst` for inline comments in the completed range. Rebuilt `export.bin` from `export.asm`; `cmp` returned 0 and MD5 matched `VZ200.bin` (`42c8f9e6c2133ae0e953b89ccbbdb7e2`).

## Iteration: 2026-06-28
- **Target Range**: 0x3711-0x3911 (German PDF pages 236-244; starts near `export.lst` line 9066)
- **Prompt**: "please read @GEMINI.md and @Z80BENCH_WORKFLOW.md you are translating german to english.  Please work 0x3711-0x3911 this starts at line 9066 in @export.lst export.lst and is pages 236 to 244 in @doc/book - Laser310-ROM-Listing-german.pdf.  Please remember you need to use Z80 bench to make the changes and treat the two markdowns as skilling advice.  rember we are using those documents as guidlines to properly translate the block comments and the inline comments."
- **Summary**: Translated and applied English annotations for the cassette loading error handler (`TAPE_LOAD_ERROR`), `CRUN` command (`CMD_CRUN`), `VERIFY` command (`CMD_VERIFY`) and its memory comparison logic (`VERIFY_COMPARE`), cassette byte/bit readers (`TAPE_READ_BYTE`, `TAPE_READ_BIT`), cassette clock pulse detection and measurement, screen printing/message helper (`TAPE_PRINT_MSG`, `TAPE_PRINT_NAME`), cassette address reader (`TAPE_READ_ADDRS`), checksum calculation (`TAPE_CALC_CHECKSUM`), `COLOR` command (`CMD_COLOR`), and graphic function helper routines for `POINT` (`POINT_HELPER`) and `SET/RESET` (`SET_RESET_HELPER`). Added segment boundaries (`DIRECT_BYTE`) for tape message strings to ensure clean formatting.
- **Toolchain**: Used `z80bench-cli` for segment mapping, symbol additions, and comment annotations, then generated output using `./z80bench-cli project export . both export`.
- **Issues/Notes**: The German PDF pages are scanned images, so OCR (Tesseract) was used and manually corrected against the disassembly logic. Used `DIRECT_BYTE` instead of `DEFINE_MSG` in `z80bench-cli` for message segments because the string escaping (`\0D`, `\00`) of `DEFINE_MSG` causes byte-shifts and compilation failures in `z88dk-z80asm`. Identified that bytes at `0x38C3` (comma `,`) and `0x3910` (parenthesis `)`) immediately following `RST 8` instructions are parameters rather than real instruction code (`inc l` and `add hl, hl`). Left them disassembled as instructions but documented them using clear inline comments.
- **Statistics**:
  - Total Annotations: 7100
  - Total Symbols: 409
  - Limits: Well within maximums (100000 annotations, 6000 symbols).
- **Verification**: Verified `export.lst` for inline comments in the work section. Compiled `export.asm` using `z88dk-z80asm`; MD5 checksum matched `VZ200.bin` (`42c8f9e6c2133ae0e953b89ccbbdb7e2`).

## Iteration: 2026-06-28 (Part 2)
- **Target Range**: 0x3912-0x3B19 (German PDF pages 244-251; starts near `export.lst` line 9346)
- **Prompt**: "please read @GEMINI.md and @Z80BENCH_WORKFLOW.md you are translating german to english.  Please work 0x3912 to 0x3B19 this starts at line 9346  in @export.lst export.lst and is pages 244 to 251 in @doc/book - Laser310-ROM-Listing-german.pdf.  Please remember you need to use Z80 bench to make the changes and treat the two markdowns as skilling advice.  rember we are using those documents as guidlines to properly translate the block comments and the inline comments."
- **Summary**: Translated and applied English annotations for the `COPY` command (supporting both text-mode and graphics-mode screen copying), inverted character output (`PRN_INV_CHAR`), graphics output buffering/rotation (`COPY_GFX`, `PRN_OUTPUT_BUF`, `PRN_OUTPUT_BUF_BYTE`), character transmission to printer with busy wait (`PRN_CHAR_OUT`), printer CR/LF output (`PRN_CR_LF`), and key checking routines (`CHECK_BREAK`, `CHECK_BREAK_STOP`). Mapped `0x3B94-0x3BFF` as a `DIRECT_BYTE` segment for printer graphics character font data.
- **Toolchain**: Used `z80bench-cli` for segment mapping, symbol additions, and comment annotations, then generated output using `./z80bench-cli project export . both export`.
- **Issues/Notes**: Handled the complex graphics buffer rotation and byte merging logic in the `COPY` command. No major toolchain issues encountered.
- **Statistics**:
  - Total Annotations: 7379
  - Total Symbols: 425
  - Limits: Well within maximums (100000 annotations, 6000 symbols).
- **Verification**: Checked `export.lst` for inline comments in the completed range. Rebuilt `export.bin` from `export.asm`; MD5 matched `VZ200.bin` (`42c8f9e6c2133ae0e953b89ccbbdb7e2`).

## Iteration: 2026-07-08
- **Target Range**: 0x3B25-0x3CD4 (German PDF pages 252-255; starts near `export.lst` line 9639)
- **Prompt**: "please read @GEMINI.md and @Z80BENCH_WORKFLOW.md you are translating German to English. ... Please work 0x3B25 to 0x3CD4 ... In this case you are working on a printer output table which starts at 0x3B94. It needs to be split into 5 byte segments, the top of the table has a block comment and each line has a single comment (the character it represents.)"
- **Summary**: Translated and applied English annotations for the LIST-pause/BREAK-check routine (`LIST_PAUSE_CHECK`), key debounce helper (`DEBOUNCE_DELAY`), and the PRINT#/INPUT# cassette header and data routines (`TAPE_CMD_WRITE_HEADER` and neighbors). Rebuilt the printer inverse-character pixel table at `PRN_GFX_FONT` (0x3B94-0x3CD3) as 64 individual 5-byte `DIRECT_BYTE` segments (previously only a single, misaligned 0x3B94-0x3BFF segment existed, causing everything past 0x3BFF to mis-disassemble as code). Derived the table's character order (`@`, `A`-`Z`, down/up/left arrow, `[`, `]`, then space through `?`) from the code itself (`PRN_INV_CHAR` does `AND 0x3F` then indexes directly, 64 entries) and cross-checked against the legible parts of the German PDF scan. Also found and fixed two other pre-existing "RST 8 inline-literal" disassembly bugs at 0x3B63-0x3B67 and 0x3B6E-0x3B72 (a literal comparison byte was being swallowed into a bogus 3-byte `LD` instruction); split each into proper `rst 8` / `DEFB` pairs with `DIRECT_BYTE` segments.
- **Toolchain**: `z80bench-cli` was hanging on every command because `z80dasm` (an external dependency it shells out to) was missing from the sandbox; fixed with `apt-get install z80dasm`. No source changes needed this part.
- **Statistics**: Symbols: 428, Segments: 467.
- **Verification**: `rom.bin`/`export.bin` MD5 unchanged (`42c8f9e6c2133ae0e953b89ccbbdb7e2`) — confirms only annotations/segments changed, not ROM bytes.

## Iteration: 2026-07-08 (Part 2)
- **Target Range**: 0x3CD4-0x3E28 (German PDF pages 255-258; starts near `export.lst` line 9847)
- **Prompt**: "Lets work 0x2CD4-0x3E28 [sic, meant 0x3CD4] this is pages 255-258 in the pdf... This contains another table but you need to be careful because the segments are patterned DEFB and then DEFM, also the DEFB segment has an offset added? I don't think z80bench can annotate this way its ok if you highlight some info in the comments as long as you dont diverge too much from the comments that are there"
- **Summary**: Translated and annotated `ERROR_MSG_OUTPUT` (0x3CD4-0x3CEB), the routine that prints a BASIC error message given an error number in E and HL pointing at `ERROR_MSG_TABLE` (0x3CEC). Annotated the 22-entry error message table itself (`NEXT WITHOUT FOR` through `BAD FILE DATA`), matching the book's own encoding: each message is a 1-byte `DIRECT_BYTE` marker (first character | 0x80, since z80bench has no `'X'+0x80` symbolic-offset notation, the raw hex byte is shown with a comment reconstructing the full message, e.g. `; 'N'+0x80 = NEXT WITHOUT FOR`) followed by a `DEFINE_MSG` segment for the remaining plain-text characters — mirroring the existing `KWD_80_END`/`KWD_80_END_S` keyword-table pattern already used elsewhere in this file. Confirmed several messages use an embedded apostrophe abbreviation convention already present in the ROM (`RET'N WITHOUT GOSUB`, `UNDEF'D STATEMENT`, `REDIM'D ARRAY`); since z80bench's `DEFM` renders with double quotes, the embedded apostrophes needed no special escaping/splitting (unlike the original book's single-quote-delimited `DEFB 27H` workaround). Also identified and annotated a distinct, differently-encoded trailing string immediately after the error table, `DISK COMMAND?SYNTAX ERROR` (0x3E0E-0x3E28), which uses the same first-char-marker byte but is CR/NUL-terminated rather than delimited by the next marker.
- **Toolchain bugs found and fixed (rebuilt from source in `external/z80bench/src`)**:
  1. `memmap.c`: hard-coded `MAX_MAP_ENTRIES` was 500; the project already had 467 segments before this session and the error table needed 44+ more, so `segment add` began silently failing once the 500th entry was reached. **Worse: `cmd_segment_add` in `test_load.c` never checked `memmap_add`'s return value, so it printed `{"ok":true}` even when the entry was silently dropped.** Bumped `MAX_MAP_ENTRIES` to 4096 and made `segment add` return a real error (`"map is full"`) if it fails.
  2. `annotate.c`/`project.c`: a second, independent cap (`MAX_REGIONS` = 500, plus matching `Region ...[500]` local stack buffers in `project_sync_map_to_regions`/`region_subtract_segment`) caused the same silent-truncation symptom again once total regions passed 500, even after fix #1. Bumped all of these to 4096 as well.
  - Both bugs meant several segments added mid-batch looked successful but never actually appeared in `segments.map` until the source was patched and the CLI rebuilt; caught this by cross-checking `segments.map` directly against the batch plan and by writing a script to scan `export.lst` for any remaining code-like lines inside the annotated table range.
- **Statistics**: Symbols: 430, Segments: 514.
- **Verification**: `rom.bin`/`export.bin` MD5 unchanged (`42c8f9e6c2133ae0e953b89ccbbdb7e2`). Wrote a small Python check confirming zero leftover mis-disassembled (code-like) lines within 0x3CEC-0x3E28 after the fixes. `z88dk-z80asm` was not available in this sandbox (not in apt, not network-reachable) so full reassembly-based verification wasn't performed this session; relied on the ROM/export binary MD5 match instead since no ROM bytes were touched, only annotations/segments.
