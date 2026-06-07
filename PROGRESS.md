# Progress Report - June 7, 2026

## Target Memory Range
0x2E52 - 0x2F55 (Pages 205-209 of German PDF)

## Work Summary
- Translated and annotated the following routines:
  - `AUTO_LINE_OUT` (0x2E53): Outputting existing lines during AUTO mode.
  - `MODE_CMD` (0x2E63): Implementation of the VZ-specific `MODE` command.
  - `MODE_SCREEN_CLEAR` (0x2E87): Clearing the screen for the selected mode.
  - `LIST_STRING_OUT` (0x2E9D): Additional routine for LISTing strings.
  - `ISR_TIMER` (0x2EB8): Main Interrupt Service Routine (20ms).
  - `CURSOR_BLINK` (0x2EDC): Cursor blinking and display.
  - `KBD_READ_CHAR` (0x2EF4): Reading characters from the keyboard.
  - `KBD_SCAN_ONCE` (0x2EFD): Single-pass keyboard scanning.
  - `KBD_FLAGS_RESET` (0x2F0E): Resetting keyboard flags.
  - `KBD_SCAN_ROWS` (0x2F28): Row-by-row keyboard scanning.
- Correctly handled `RST 8` data byte arguments in `segments.map`.
- Added missing symbols `GETBYT` and `IO_BUF_PTR`.
- Verified bit-perfection against `VZ200.bin`.

## Statistics
- Total Symbols: 356
- Total Annotations: 5922
- No limits reached.

## Verification
- Build successful and bit-perfect.
- `export.lst` checked for English annotations and inline comments.
- No German keywords remaining in the target range.

## Issues/Notes
- The `RST 8` instructions in the `MODE` command were followed by data bytes that the disassembler initially tried to interpret as instructions. This was corrected using `segments.map`.
