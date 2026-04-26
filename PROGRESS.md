# VZ200 BASIC ROM Disassembly Progress

## Session: April 25, 2026

### Task
Annotate the byte range 0x08A8 to 0x097A based on the German ROM listing PDF.

### Toolchain Improvements
- **Fixed Annotation Limit:** Increased limit to **100,000**.
- **Increased Symbol Limit:** Increased limit to **6,000**.
- **Improved Disassembly:** Added a DIRECT_BYTE segment at 0x08D8 to handle the "JP NC trick".

### Statistics
- Total Annotations: ~1,500
- Total Symbols: 59

### Work Completed
- **Range:** 0x08A8 - 0x0904 (Single Precision Division logic).
- **Range:** 0x0907 - 0x097A (Math support routines: MULDIV, SIGN, FLOAT, ABS).
- **Annotations:** Added block comments and inline comments translated into English from German PDF for these ranges.
- **Symbols:** Defined symbols for division workspace and math routines.

### Note on Overshoot
- Initially annotated range up to 0x0BDE, but inline comments for 0x097B - 0x0BDE were cleared per user request to maintain focus on the assigned section.

### Verification
- export.asm assembles to a bit-perfect match of VZ200.bin.
- export.lst verified to contain correct inline comments for the target ranges (0x08A8-0x097A).
