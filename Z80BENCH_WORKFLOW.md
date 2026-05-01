# z80bench Workflow Guide for AI Assistants

This guide explains how to use `z80bench-cli` to annotate the VZ200 ROM disassembly.

## Core Concepts
- **Annotations**: Includes labels, inline comments, and block headers.
- **Symbols**: Global EQU definitions (stored in `symbols.sym`).
- **Segments/Regions**: Memory map definitions (CODE, DATA, etc.).

## Tool Usage
The `z80bench-cli` tool manages the project state.

### Basic Commands
- `annotation set <addr> label|comment|block "<value>"`: Sets an annotation.
- `symbol add <name> <addr> <type>`: Adds a symbol to `symbols.sym`.
  - Common types: `JUMP_LABEL`, `ROM_CALL`, `CONSTANT`.
- `project export . both export`: Generates `export.asm` and `export.lst`.
- `batch .`: Executes multiple commands from stdin.

## Typical Workflow
1. **Verification**: Run a test build to ensure bit-perfection.
   ```bash
   z88dk-z80asm -b export.asm && md5sum export.bin VZ200.bin
   ```
2. **Translation**: Extract German comments from the PDF and translate them to English.
3. **Batch Application**: Prepare a batch of `annotation set` and `symbol add` commands.
   ```bash
   cat <<EOF | ./z80bench-cli batch .
   annotation set 0x1234 comment "My comment"
   symbol add MY_LABEL 0x1234 JUMP_LABEL
   EOF
   ```
4. **Export**: Export the changes.
   ```bash
   ./z80bench-cli project export . both export
   ```
5. **Validation**: Check `export.lst` for inline comments and perform a final bit-perfection check.

### Tips for Success
- **Address Notation**: Use the `0x` prefix for hex addresses (e.g., `0x0D02`).
- **Symbol Collisions**: Always `grep` `symbols.sym` before adding a new symbol to avoid duplicates.
- **Batch Mode**: Use the `batch` command to apply multiple changes in a single tool call. This is much faster and reduces context usage.
- **Label Names**: Cross-reference `external/TRS-80-ROMS` for idiomatic label names (e.g., `DADD`, `DROUND`).

### Statistics Tracking
To get accurate counts for `PROGRESS.md`:
```bash
# Total Symbols
./z80bench-cli project info . | jq '.symbols'

# Total Annotations (Labels + Comments + Blocks)
./z80bench-cli annotation list . | jq '.annotations | length'
```

### Troubleshooting
- **Missing Inline Comments**: If comments don't appear in `export.lst` after an export:
  1. Verify the `annotation set` command returned `{"ok":true...}`.
  2. Ensure you ran `project export . both export` AFTER setting the annotations.
  3. Check that the address used for the annotation matches the instruction's start address in `export.lst`.

## Deliverables
Always update `PROGRESS.md` with:
- Target memory range.
- Summary of work (translation, logic fixes).
- Updated statistics (Total Annotations and Symbols).
- Verification results.
