# Symbol Naming Standard

This document is the standing rule for naming symbols (labels, RAM
variables, constants) in this disassembly. It exists so that naming
decisions don't have to be re-litigated every time, and so that if this
project is ever merged into a unified multi-target tree (in the spirit of
`mist64/msbasic` or `kiwisincebirth/TRS-80-ROMS`), the names are already
aligned rather than needing a second translation pass.

**Important ground rule:** naming is a documentation exercise only. The
ROM's actual behavior is fixed and verified byte-for-byte against the
original binary (see `spotcheck.sh`). Renaming, merging, or deleting a
symbol never changes what the ROM does — it only changes what we call the
address in our own notes. If a duplicate or conflicting symbol is found,
that's a documentation error to resolve, never evidence of a functional
bug.

## Precedence order for choosing a name

When a symbol needs a name (new routine annotated, or resolving a
duplicate), check sources in this order and use the first match:

1. **`external/TRS-80-ROMS`** (`CONSTANTS.Z80`, `MDL1LEV2.Z80`,
   `MDL3LEV2.Z80`) — if this repo names the same RAM variable or the
   same routine, use that name verbatim. This is the most direct
   relative, since it's the same BASIC lineage on the same CPU.
2. **Established universal Microsoft BASIC internals vocabulary** —
   terms attested across the wider MS BASIC family (6502 and Z80 alike),
   e.g. `FAC`, `ARG`, `CHRGET`/`CHRGOT`, `CRUNCH`, `PROMPT`, `VARTAB`.
   Sources: *Microsoft BASIC Decoded and Other Mysteries*, the *Level II
   ROM Reference Manual* (Edwin Paay), and established community
   disassemblies (e.g. Ira Goldklang's TRS-80 archive).
3. **Invented, VZ200/Laser-specific name** — only when neither source
   above has anything, because the routine or variable is genuinely
   specific to this hardware (cassette I/O, background/foreground color,
   VZ200 video memory layout, DCB glue, etc.). New names should follow
   the existing family-prefix conventions already in use in this project
   rather than being one-off:
   - `CMD_*` — BASIC command entry points (`CMD_PRINT`, `CMD_NEW`, ...)
   - `PUSTR_*` — floating-point-to-string output stages
   - `OUT_CURSOR_*` — cursor movement/output routines
   - (add new families here as they emerge, rather than letting them
     accumulate ungrouped)

## Resolving duplicate-address symbols

- **One name per address.** If two (or more) names exist for the same
  address, apply the precedence order above and pick one. The
  non-chosen name is deleted from `symbols.sym`, not kept as a
  secondary alias comment — unless it genuinely documents a distinct
  sub-byte offset within a multi-byte structure (e.g. a specific byte
  within a multi-byte float), in which case that should be written as
  an explicit offset annotation, not a second top-level symbol at the
  same address.
- **A name that describes something unrelated to what the code actually
  does at that address is a labeling mistake, not a real second
  identity for that address.** Confirm the routine's real job by
  checking how it's actually used elsewhere (is it called/jumped to by
  name anywhere?) before deciding which name survives.
- After resolving, re-run `spotcheck.sh` to confirm the hash is
  unaffected (renaming shouldn't touch bytes, but verify anyway).

## Applying changes

Use `z80bench-cli`'s batch mode:

```
symbol add <NAME> <ADDR> <CATEGORY>
```

to (re)establish the canonical name, and `symbol remove` (check exact
syntax with the tool, since it wasn't confirmed in this pass) to drop
the superseded name.

## Categories

Every symbol should carry one of the existing category tags:
`VECTOR`, `ROM_CALL`, `JUMP_LABEL`, `CONSTANT`, `WRITABLE`. If a
resolved symbol currently has no category, assign the one that best
matches its actual role before moving on.
