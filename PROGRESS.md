# VZ200 BASIC ROM Disassembly Progress

## Session: April 30, 2026

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
