# VZ200 BASIC ROM Disassembly Progress

## Session: May 14, 2026

### Task
Re-work and annotate the memory range 0x000D to 0x005F based on Gerhard Wolf's Laser 310 German ROM listing (pages 6-8). This range was previously showing as raw byte data and required disassembly into instructions and English translation of the German annotations.

### Work Summary
- **Disassembly Fixes**:
  - Removed a large `DIRECT_BYTE` segment that was forcing the entire range to show as `DEFB` data.
  - Correctly disassembled the RST jump vectors and DCB call routines.
  - Added specific `DIRECT_BYTE` segments for truly unused/garbage data areas: `UNUSED_DATA_1` (0x000D-0x000F), `UNUSED_DATA_2` (0x0044-0x0045), and `UNUSED_DATA_3` (0x0058-0x005F).
- **DCB Dispatch Logic**:
  - Annotated the "DCB-Aufrufroutine" path. Validated that `0x0046` correctly jumps to `DCB_DISPATCH` at `0x03C2` in the VZ200 ROM, despite potential OCR discrepancies in some listing versions.
- **Translation**:
  - Translated all German block headers, inline comments, and separators into English.
  - Included detailed block notes for routines such as the keyboard query (`0x002B` and `0x0049`) and screen output (`0x0033`).
- **Bit-Perfection Fix**:
  - Identified and fixed a pre-existing assembly shift issue where `DEFINE_MSG` segments (0x191D-0x1935) were being exported in a format (`\0D\00`) that `z88dk-z80asm` misinterpreted, adding extra bytes to the binary. 
  - Updated these segments to `DIRECT_BYTE` to ensure stable, bit-perfect assembly across all tools.
- **Verification**:
  - `export.asm` now assembles to a bit-perfect match of `VZ200.bin` (MD5: `42c8f9e6c2133ae0e953b89ccbbdb7e2`).
  - `export.lst` verified for correct English inline comments and logical disassembly across the 0x000D-0x005F range.

### Statistics
- **Total Symbols:** 216 (Limit: 6000)
- **Total Annotations:** 3104 (Limit: 100000)

### Verification
- `z88dk-z80asm -b export.asm` produced `export.bin` which matches `VZ200.bin`.
- `export.lst` verified for presence of English inline comments for the range 0x000D-0x005F.

## Session: May 13, 2026 (Part 2)

### Task
Annotate the byte range 0x18F7 to 0x19FD based on Gerhard Wolf's Laser 310 German ROM listing (pages 109-113). This section contains system routines for division, I/O handling, and error message processing.

### Work Summary
- **System Routines & Data**:
  - Documented the ROM source for self-modifying RAM routines: `FDIV_HELPER_ROM` (0x18F7), `INP_HELPER_ROM` (0x190A), and `OUT_HELPER_ROM` (0x190D).
  - Labeled and annotated system data word vectors: `USR_START_VEC_ROM`, `RND_MULT_ROM`, `STR_SPACE_ROM`, `CURR_LINE_ROM`, and `PROG_START_ROM`.
  - Documented internal system variables including `INKEY_BUF_ROM`, `LAST_ERR_ROM`, `PRN_POS_ROM`, `OUT_FLAG_ROM`, `LINE_LEN_ROM`, and `TAB_POS_ROM`.
- **System Messages**:
  - Annotated and formatted core system messages: `MSG_ERROR_TEXT` (" ERROR"), `MSG_IN_TEXT` (" IN "), `MSG_READY_TEXT` ("READY\r"), and `MSG_BREAK_TEXT` ("BREAK").
- **Core Subroutines**:
  - `STACK_RECOVERY` (0x1936): Subroutine for retrieving loop and call data from the stack for FOR/NEXT and GOSUB/RETURN.
  - `MAKE_SPACE` (0x1955): Subroutine to relocate program blocks or variables in memory.
  - `CHECK_FREE_MEMORY` (0x1963): Memory validation routine.
  - `ERROR_HANDLER` (0x19A2): Main error processing and reporting logic.
- **Error Entry Points**:
  - Documented individual error handlers: `ERROR_ENTRY` (0x197A), `IMPLICIT_END` (0x197E), `SYNTAX_ERR_DATA` (0x1991), `SYNTAX_ERR_HANDLER` (0x1997), `DIV_ZERO_ERR_HANDLER` (0x199A), `NEXT_WITHOUT_FOR_ERR_HANDLER` (0x199D), and `RESUME_WITHOUT_ERR_HANDLER` (0x19A0).
- **Tricks & Overlaps**:
  - Handled multiple "LD BC trick" and "LD A trick" overlapping instructions at addresses 0x196B, 0x1999, 0x199C, and 0x199F using `DIRECT_BYTE` segments and explanatory annotations.
- **Translation**:
  - Translated all German annotations and block headers into technical English.
- **Verification**:
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified for correct formatting and English inline comments across the target range.

### Statistics
- **Total Symbols:** 216 (Limit: 6000)
- **Total Annotations:** 3075 (Limit: 100000)

### Verification
- `z88dk-z80asm -b export.asm` produced `export.bin` which matches `VZ200.bin`.
- `export.lst` verified for presence of English inline comments for the range 0x18F7-0x19FD.

## Session: May 13, 2026 (Part 1)

### Task
Annotate the byte range 0x1736 to 0x1821 based on Gerhard Wolf's Laser 310 German ROM listing (pages 102-105) and cross-referenced with TRS-80 Level II BASIC sources.

### Work Summary
- **Keyword Table Restructuring**:
  - Successfully restructured the second half of the BASIC keyword table (Tokens B6 to FB) into the requested "unpacked" format.
  - Split each keyword into a `DIRECT_BYTE` segment for the first character (token indicator) and a `DEFINE_MSG` segment for the remaining characters.
  - Handled "not coded" keywords (DELETE, AUTO, FN, VARPTR, ERL, ERR, STRING$, INSTR, TIME$, MEM, FRE, POS, CVI, CVS, CVD, EOF, LOC, LOF, MKI$, MKS$, MKD$, CINT, CSNG, CDBL, FIX) by defining them as `DIRECT_BYTE` segments with appropriate English annotations.
  - Fixed a duplicate label issue for `KWD_92_RETURN` which was incorrectly placed in a previous session.
- **Translation**:
  - Translated all German ROM annotations into English.
  - Applied descriptive inline comments indicating the token value and the character expression for each keyword.
- **Verification**:
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified for correct unpacked formatting and English inline comments across the target range.

### Statistics
- **Total Symbols:** 216 (Limit: 6000)
- **Total Annotations:** 2963 (Limit: 100000)

### Verification
- `z88dk-z80asm -b export.asm` produced `export.bin` which matches `VZ200.bin`.
- `export.lst` verified for presence of high-density English inline comments for the range 0x1736-0x1821.

## Session: May 12, 2026

### Task
Expand z80bench tool limits and establish a strategy for documenting the BASIC keyword table (page 100).

### Work Summary
- **Toolchain Upgrades**:
  - Increased `MAX_MAP_ENTRIES` (segments) and `MAX_REGIONS` from 100 to 500 across the `z80bench` codebase (`memmap.c`, `annotate.c`, `project.c`, `ui_panels.c`).
  - Increased `MAX_TOTAL_LINES` to 500,000 in `project.c` to accommodate larger disassemblies.
  - Successfully rebuilt `z80bench` and `z80bench-cli` from source.
- **Keyword Table Strategy**:
  - Developed a hybrid annotation strategy for Microsoft BASIC keyword tables (where the first character typically has bit 7 set as a terminator/token).
  - **Strategy**: Split each keyword into a `DIRECT_BYTE` segment for the first character and a `DEFINE_MSG` segment for the remainder.
  - **Comments**: Applied descriptive inline comments to the first byte of each keyword indicating the token value and the character expression (e.g., `; 80 = END ('E'+0x80)`).
  - **Demonstration**: Applied this strategy to the range `0x1650` - `0x1660` (END through CLS keywords).
- **Verification**:
  - `export.asm` continues to assemble to a bit-perfect match of `VZ200.bin`.
  - `export.lst` now shows a highly readable hybrid hex/text representation for keywords that matches the logical structure of the original Laser 310 PDF.

### Statistics
- **Total Symbols:** 216 (Limit: 6000)
- **Total Annotations:** 3343 (Limit: 100000)

### Verification
- `z88dk-z80asm -b export.asm` produced `export.bin` which matches `VZ200.bin`.
- `export.lst` verified for the new keyword formatting.

## Session: May 11, 2026

### Task
Annotate the byte range 0x15E3 to 0x18F5 based on Gerhard Wolf's Laser 310 German ROM listing (pages 99-109). This section contains table data including constants, keywords, jump tables, and error abbreviations.

### Work Summary
- Translated and applied English inline comments and block headers for the range 0x15E3 - 0x18F5.
- Documented the following tables:
  - **Arcus-Tangens Series Constants** (0x15E3 - 0x1607): Individually annotated 9 constants.
  - **Function Jump Table** (0x1608 - 0x164F): Labeled and commented all function entry points (D7-FA).
  - **BASIC Keyword Table** (0x1650 - 0x1821): Annotated ~124 keywords with their corresponding token values.
  - **Command Jump Table** (0x1822 - 0x1899): Labeled and commented all command entry points (80-BB).
  - **Operator Priority Table** (0x189A - 0x18A0): Documented priorities for Z80 operators.
  - **Type Conversion Jump Table** (0x18A1 - 0x18AA): Annotated routines for precision and type handling.
  - **Arithmetic and Comparison Jump Table** (0x18AB - 0x18C8): Documented entry points for DP, Single, and Integer math.
  - **Error Abbreviation Table** (0x18C9 - 0x18F5): Labeled and translated all error message tokens (NF, SN, etc.).
- **Workflow / Segment Management**:
  - Combined multiple small, unrelated segments in `segments.map` to stay below the 100-segment limit of `z80bench`.
  - Strategically split the `BASIC_KEYWORDS` and `ERROR_MESSAGES` tables into smaller segments to allow for precise line breaks and inline comments in the listing.
  - Cleaned up duplicate symbols in `symbols.sym` and ensured no conflicts between global symbols and annotation labels in `export.asm`.
- **Verification**:
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified for high-density English inline comments across all table sections.

### Statistics
- **Total Symbols:** 216 (Limit: 6000)
- **Total Annotations:** 3338 (Limit: 100000)

### Verification
- `z88dk-z80asm -b export.asm` produced `export.bin` which matches `VZ200.bin`.
- `export.lst` verified for presence of English inline comments for the range 0x15E3-0x18F5.

## Session: May 10, 2026 (Part 2)

### Task
Annotate the byte range 0x14C9 to 0x15E2 based on Gerhard Wolf's Laser 310 German ROM listing (pages 94-99) and cross-referenced with TRS-80 Level II BASIC sources.

### Work Summary
- Translated and applied comprehensive English inline comments and block headers for the range 0x14C9 - 0x15E2, covering trigonometric and random number functions.
- Identified and labeled key math routines:
  - `FNRND` (0x14C9): Random number function ($RND(n)$).
  - `RND0` (0x14F0): Core random number generator routine.
  - `FNCOS` (0x1541): Cosine function ($COS(x)$).
  - `FNSIN` (0x1547): Sine function ($SIN(x)$).
  - `FNTAN` (0x15A8): Tangent function ($TAN(x)$).
  - `FNATN` (0x15BD): Arc-tangent function ($ATN(x)$).
- Documented internal jump labels for loops: `RND00`, `RND01`, `RND02`.
- Labeled and correctly formatted constant data in `segments.map` and `symbols.sym`:
  - `PI2` (0x158B): $\pi/2$ constant.
  - `F025` (0x158F): 0.25 constant.
  - `SIN_CONST` (0x1593): Constants for the Sine series.
  - `ATN_CONST` (0x15E3): Constants for the Arc-tangent series.
- Identified and labeled random number seed and multiplier table in RAM:
  - `RND_SEED` (0x78AA): Current random number seed.
  - `RND_MULT_TABLE` (0x7890): Multiplier table used for RND generation.
- Corrected disassembler behavior by marking math constant ranges as `DIRECT_BYTE` in `segments.map`, ensuring data is not disassembled as code.
- Binary identity maintained: `export.asm` assembles to a bit-perfect match of `VZ200.bin`.

### Statistics
- **Total Symbols:** 216 (Limit: 6000)
- **Total Annotations:** 3155 (Limit: 100000)

### Verification
- `z88dk-z80asm -b export.asm` produced `export.bin` which matches `VZ200.bin`.
- `export.lst` verified for presence of high-density inline comments and properly formatted constant tables in the target range.

# VZ200 BASIC ROM Disassembly Progress

## Session: May 10, 2026

### Task
Annotate the byte range 0x1364 to 0x14B6 based on Gerhard Wolf's Laser 310 German ROM listing (pages 90-94) and cross-referenced with TRS-80 Level II BASIC sources.

### Work Summary
- Identified and labeled a large block of floating point and integer constants (0x1364 - 0x13E1).
- Broken up constant tables (`FODTBL`, `FOSTBL`, `FOITBL`, `EXP_SERIES`) into individual lines in `segments.map` to allow for precise line-by-line annotation matching the German listing.
- Handled multiple overlapping instruction tricks (Z80 byte-reuse) at `0x13E0` (`GETADR`) and `0x14B1` (`POLYN_LD_B_TRICK`) using `DIRECT_BYTE` segments.
- Translated and applied comprehensive English inline comments for every instruction and data line in the target range, following the German PDF literally.
- Identified and documented key routines with detailed multi-line block headers:
  - `GETADR` (0x13E0): Return address manipulation for polynomial series.
  - `FNSQR` (0x13E7): Square root function ($X^{0.5}$).
  - `FNPWR` (0x13F2): Power function ($X^Y$).
  - `EXP` (0x1439): Exponential function.
  - `POLYN` (0x149A): Polynomial series evaluation.
- Binary identity maintained: `export.asm` assembles to a bit-perfect match of `VZ200.bin`.

### Statistics
- **Total Symbols:** 201 (Limit: 6000)
- **Total Annotations:** 2661 (Limit: 100000)

### Verification
- `z88dk-z80asm -b export.asm` produced `export.bin` which matches `VZ200.bin`.
- `export.lst` verified for presence of high-density inline comments and properly formatted constant tables in the target range.

## Session: May 6, 2026

### Task
Annotate the byte range 0x1264 to 0x1363 based on Gerhard Wolf's Laser 310 German ROM listing (pages 85-90) and cross-referenced with TRS-80 Level II BASIC sources.

### Work Summary
- Translated and applied annotations for the range 0x1264 - 0x1363.
- Identified and labeled key routines:
  - `WRITE_ZEROS` (0x1269): Write zeros to buffer.
  - `WRITE_ZEROS_FMT` (0x1271): Write zeros with decimal/thousands separators.
  - `GET_FMT_PARAMS` (0x127D): Determine parameters for '.' and ','.
  - `SET_DOT_COMMA` (0x1291): Set '.' and ',' in buffer.
  - `FF_TO_ASCII` (0x12A4): Convert single/double precision numbers to ASCII string.
  - `INT_TO_ASCII` (0x132F): Convert integer to ASCII string.
- All German comments translated to English.
- Binary identity maintained: `export.asm` assembles to a bit-perfect match of `VZ200.bin`.

### Statistics
- **Total Symbols:** 186 (Limit: 6000)
- **Total Annotations:** 2514 (Limit: 100000)

### Verification
- `z88dk-z80asm -b export.asm` produced `export.bin` which matches `VZ200.bin`.
- `export.lst` verified for presence of inline comments in the target range.

## Session: May 5, 2026 (Part 2)

### Task
Annotate the byte range 0x1124 to 0x124E based on Gerhard Wolf's Laser 310 German ROM listing and cross-referenced with TRS-80 Level II BASIC sources.

### Statistics
- Total Annotations: 2,357
- Total Symbols: 186

### Work Completed
- **Range:** 0x1124 - 0x124E (Formatting single precision numbers, decimal place handling, integer/fractional logic, formatted exponent output, and the large number normalization loop).
- **Annotations:** Added block comments, labels, and inline comments in English. Routines documented include `FFXSFX` (PUSTR_SINGLE), `FFXSDC` (PUSTR_NO_DECIMAL), `FFXSDP` (PUSTR_HAS_DECIMAL), `FFXIFL` (PUSTR_EXP_INT), `FFXDFL` (PUSTR_EXP_FLOAT), and `FONTINV` (GET_10_EXP).
- **Symbols added:** `FFXSFX`, `FFXSDC`, `FFXSDP`, `FFXIFL`, `FFXDFL`, `FONTINV`, `PUSTR_ONLY_DECIMAL`, `PUSTR_ROUND_LOOP`, `PUSTR_ROUND_DONE`, `GET_10_EXP_SINGLE`, `GET_10_EXP_START`, `GET_10_EXP_DBL`, `GET_10_EXP_LOOP`, `GET_10_EXP_LOOP_2`, `GET_10_EXP_TEST`.
- **Bug Fix / Trick:** Handled the "LD BC trick" at 0x11AF (overlapping code) by defining it as a `DIRECT_BYTE` segment in `segments.map`. This enabled proper disassembly and annotation of the `LD E,6` instruction at 0x11B0.
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified to contain correct English inline comments for the range 0x1124-0x124E.

## Session: May 5, 2026 (Part 1)

## Session: May 1, 2026 (Part 2)

### Task
Annotate the byte range 0x0E65 to 0x1033 based on Gerhard Wolf's Laser 310 German ROM listing and cross-referenced with TRS-80 Level II BASIC sources.

### Statistics
- Total Annotations: 2,044
- Total Symbols: 147

### Work Completed
- **Range:** 0x0E65 - 0x1033 (String to number conversion, numeric type handling, precision force routines, multiply/divide real by 10, process digit, 8-bit addition, exponent processing, error message IN, output line number, formatted string conversion (PRINT USING support), integer to string).
- **Annotations:** Added block comments, labels, and inline comments in English. Routines documented include `STR_TO_DOUBLE`, `FIN`, `FINC`, `FINEX`, `FINEC`, `FINDP`, `FININT`, `FINDBF`, `FINSNF`, `FINFRC`, `FINMUL`, `FINDIV`, `FINDIG`, `FINDGV`, `FINDG1`, `FINDG2`, `FINDG3`, `FINDGD`, `FADD8`, `FINEDG`, `INPRT`, `LINPRT`, `PUFOUT`, `INT_TO_STR`, and `PUSTR_BITS_2_5`.
- **Symbols added:** `STR_TO_DOUBLE`, `FIN`, `FINC`, `FINEX`, `FINEC`, `FINDP`, `FININT`, `FINDBF`, `FINSNF`, `FINFRC`, `FINMUL`, `FINDIV`, `FINDIG`, `FINDGV`, `FINDG1`, `FINDG2`, `FINDG3`, `FINDGD`, `FADD8`, `FINEDG`, `INPRT`, `LINPRT`, `PUFOUT`, `INT_TO_STR`, `PUSTR_BITS_2_5`, `FOUINI`, `FOUFRV`, `OUTSTR`, `MSG_IN`, `FA_ZERO`, `FBUFFR`, `FMT_FLAG`.
- **Bug Fix / Trick:** Handled overlapping instructions at 0x0E6C and 0x0FA2 by adding `DIRECT_BYTE` segments at 0x0E6B and 0x0FA1 in `segments.map`. This allowed setting labels and comments on these addresses which were previously "swallowed" by the disassembler as operands.
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified to contain correct English inline comments for the range 0x0E65-0x1033.

## Session: May 1, 2026 (Part 1)

### Task
Annotate the byte range 0x0D56 to 0x0E61 based on Gerhard Wolf's Laser 310 German ROM listing and cross-referenced with TRS-80 Level II BASIC sources.

### Statistics
- Total Annotations: 2,141
- Total Symbols: 115

### Work Completed
- **Range:** 0x0D56 - 0x0E61 (Complement mantissa, Shift right, Shift X right, Shift area left, Double Precision Multiplication, Division by 10, Double Precision Division, DP Multi-purpose subroutine, DP Multiply by 10).
- **Annotations:** Added block comments, labels, and inline comments in English. Routines documented include `DNEGR`, `DXSHFT`, `DLSHFT`, `DMULT`, `DDIV10`, `DDIV`, `DMULDV`, and `DMUL10`.
- **Symbols added:** `DNEGR`, `DSHFR3`, `DSHFR4`, `DXSHFT`, `DLSHFT`, `DMULT`, `DDIV10`, `DDIV`, `DMULDV`, `DMUL10`.
- **Bug Fix / Trick:** Handled the "JP C trick" at 0x0E11 (overlapping code) by defining it as a `DIRECT_BYTE` segment to allow proper annotation of the nested instructions at 0x0E12 and 0x0E13.
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified to contain correct English inline comments for the range 0x0D56-0x0E61.

## Session: April 30, 2026 (Part 4)

### Task
Annotate the byte range 0x0D02 to 0x0D56 based on Gerhard Wolf's Laser 310 German ROM listing.

### Statistics
- Total Annotations: 1,990
- Total Symbols: 105

### Work Completed
- **Range:** 0x0D02 - 0x0D56 (Normalization/Rounding continuation, Sign flag manipulation, Rounding routine, Double Precision Mantissa Addition, Double Precision Mantissa Subtraction).
- **Annotations:** Added block comments, labels, and inline comments in English. Routines documented include `DROUNA`, `DADDAA`, and `DADDAS`.
- **Symbols added:** `DROUNA`, `DADDAA`, `DADDAS`.
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified to contain all requested English inline comments.
- **Workflow Improvement:** Created `Z80BENCH_WORKFLOW.md` to document the toolchain usage for future sessions.

## Session: April 30, 2026 (Part 3)

### Task
Fix and complete missing English inline comments in the memory range 0x0C05 to 0x0D01 based on Gerhard Wolf's Laser 310 German ROM listing.

### Statistics
- Total Annotations: 1,988
- Total Symbols: 102

### Work Completed
- **Range:** 0x0C05 - 0x0D01.
- **Improvements:** Added detailed English inline comments for every instruction in the target range, matching the German source listing.
- **Logic Correction:** Corrected the path descriptions for Double Precision Addition (`DADD`). Identified that the `JP P` instruction at 0x0CBB actually branches to the subtraction path (used when signs are different) and falls through to the addition path (used when signs are the same), consistent with Z80 sign flag logic and MSB manipulations in the preceding `UNPACK` routine.
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` verified to contain all requested English inline comments.

## Session: April 30, 2026 (Part 2)

### Task
Annotate the byte range 0x0C05 to 0x0D01 based on TRS-80 Level II BASIC source and logic analysis.

### Statistics
- Total Annotations: 1,919
- Total Symbols: 102

### Work Completed
- **Range:** 0x0C05 - 0x0D01 (Integer Multiply continuation, Handle negative product, Integer division/multiplication support, Negate HL, Double Precision Subtraction, Double Precision Addition, Double Precision Normalization).
- **Annotations:** Added block comments, labels, and inline comments in English. Routines documented include `IMULT_OVERFLOW_CHECK`, `IMULT_NEG`, `IMULT_OVERFLOW`, `IMULDV`, `INEGH`, `INEGHL`, `INEG_B`, `DSUB`, `DADD`, `DNORML`.
- **Symbols added:** `IMULT_NEG`, `IMULDV`, `INEGH`, `INEGHL`, `INEG_B`, `DSUB`, `DADD`, `DNORML`, `NNEG`, `FLOATR`, `DROUND_DP`, `DSHFTR`.
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` contains correct English inline comments and labels for the target range.

## Session: April 30, 2026 (Part 1)

### Task
Annotate the byte range 0x0B01 to 0x0C04 based on TRS-80 Level II BASIC source and logic analysis.

### Statistics
- Total Annotations: 1,839
- Total Symbols: 90

### Work Completed
- **Range:** 0x0B01 - 0x0C04 (Quick Integer conversion, Single Precision Subtraction, INT function for single and double precision, Integer Multiply, Subtraction, Addition, and Division).
- **Annotations:** Added block comments, labels, and inline comments in English. Routines documented include `QINT`, `QINTA`, `FSUB`, `FNINT`, `DINT`, `DINT_NEG`, `UMULT`, `ISUB`, `IADD`, `IDIV`, and `IDIV2`.
- **Symbols added:** `QINT`, `QINTA`, `FSUB`, `FNINT`, `DINT`, `DINT_NEG`, `UMULT`, `ISUB`, `IADD`, `IDIV`, `IDIV2`, `ROUND`, `NGER`.
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` contains correct English inline comments and labels for the target range.

## Session: April 29, 2026 (Part 2)

### Task
Annotate the byte range 0x0A28 to 0x0B00 based on the German ROM listing PDF and TRS-80 Level II BASIC source.

### Statistics
- Total Annotations: 1,334
- Total Symbols: 77

### Work Completed
- **Range:** 0x0A28 - 0x0B00 (Floating point and integer comparison, double precision comparison, integer conversion, force precision routines, and type mismatch error handling).
- **Annotations:** Added block comments, labels, and inline comments in English. Cross-referenced with TRS-80 Level II BASIC for logic validation.
- **Symbols added:** `DCOMPS`, `SIGNS_2`, `XDCOMP`, `SIGN_X`, `FCOMPS`, `DCOMP1`, `OVERR`, `CONIS`, `CONIS2`, `VALINT`, `CONISD`, `FRCSNG`, `CONSD`, `FRCDBL`, `CONDS`, `VALDBL`, `VALSNG`, `CHKSTR`.
- **Verification:**
  - `export.asm` assembles to a bit-perfect match of `VZ200.bin`.
  - `export.lst` contains correct inline comments and labels for the target range.

## Session: April 29, 2026 (Part 1)

### Task
Annotate the byte range 0x097B to 0x0A27 based on the German ROM listing PDF.

### Statistics
- Total Annotations: 1,222
- Total Symbols: 59

### Work Completed
- **Range:** 0x097B - 0x0A27 (FAC negation, SGN, sign testing, FAC transport, FAC address determination, and floating point comparison).
- **Annotations:** Added block comments and inline comments translated into English from German PDF for these ranges.
- **Verification:**
  - export.asm assembles to a bit-perfect match of VZ200.bin.
  - export.lst verified to contain correct inline comments for the target ranges (0x097B-0x0A27).

## Session: April 25, 2026 (Prior Session)
... (etc)
