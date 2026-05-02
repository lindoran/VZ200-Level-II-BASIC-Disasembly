# VZ200 BASIC ROM Disassembly Progress

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
