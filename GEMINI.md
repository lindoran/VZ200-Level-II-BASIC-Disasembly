# VZ200 English Documentation Project

## What This Is

This project produces a fully documented, human-readable English annotation of the
VZ200 BASIC ROM (version 2.0), which is generally accepted to be a modified version
of Microsoft Level II BASIC. Documentation is created collaboratively using `z80bench`
(for human review) and `z80bench-cli` (for AI-assisted annotation), cross-referenced
against PDF listings and known Level II BASIC sources.

The end goal is a fully annotated `.asm` file that assembles cleanly and is meaningful
to anyone familiar with Z80 assembly and vintage BASIC interpreters.

---

## Relevant Files

| Path | Description |
|---|---|
| `./VZ200.bin` | VZ200 2.0 BASIC ROM binary |
| `./z80bench` | GUI-based documentation tool (human use only; AI will not invoke this) |
| `./z80bench-cli` | CLI tool AI uses to read and write project annotation files |
| `./doc/` | PDF scans of the original VZ200 ROM listing |
| `./old-progress/` | Previous attempt data — AI may read annotations for context, but must not copy any assembly |
| `./z80bench_info/` | z80bench documentation, workflow guide, and licence file |
| `./external/` | Git submodules, including a fully documented English listing of Level II BASIC for the TRS-80 |
| `TRANSLATE.md` | Running raw translation notes with confidence markers |
| `ORPHANS.md` | Unresolved byte ranges, decision log, and status labels |
| `SOURCES.md` | External sources used, with date, title/URL, and reason for trust |

---

## Getting Started (New AI Session)

Before beginning work, an AI assistant should:

1. Read `./z80bench_info/README.md` for the canonical tool workflow.
2. Read `TRANSLATE.md`, `ORPHANS.md`, and `SOURCES.md` to understand current progress.
3. Check `./old-progress/` annotations for useful context (do not copy assembly verbatim).
4. Review the TRS-80 Level II BASIC listing in `./external/` to orient symbol naming.
5. Confirm the current page range being translated with the user before proceeding.

---

## AI Roles

- Use `z80bench-cli` to create and update project annotation files, following the
  workflow in `./z80bench_info/README.md`.
- Translate **3 pages** of the PDF listing at a time, then pause and wait for user
  instruction before continuing.
- Preserve the original ROM's meaning exactly. Do not alter mnemonics, operands,
  addresses, or byte output under any circumstances.
- Use the generated disassembly listing to resolve bytes and numbers that are
  ambiguous due to scan quality.
- Cross-reference the TRS-80 Level II BASIC listing in `./external/` to identify
  symbol names and infer scope. Read ahead in the listing when needed to make
  informed naming suggestions.
- Reference Level II BASIC documentation on the internet where useful; request
  local PDF copies when a resource would be repeatedly consulted.
- Explicitly report every external source used and update `SOURCES.md` accordingly.
- Update `TRANSLATE.md` with raw translation notes and a confidence marker
  (`high`, `medium`, or `low`) for each translated block.
- Create and maintain `ORPHANS.md` after project setup. Collaborate with the user
  to resolve orphan byte ranges; do not resolve them unilaterally.
- Verify that the output `.asm` assembles cleanly after each dump once direct-byte
  orphan ranges are resolved.
- At the end of each translation batch, export both `export.lst` and `export.asm`
  so the user can review changes directly in code without opening the GUI.
- Ask clarifying questions when context is unclear.
- Do not make ROM design or interpretation decisions without user approval.
- Propose symbol name suggestions but wait for user approval before finalising.

---

## User Roles

- Verify translations for accuracy and contextual meaning.
- Confirm that direct bytes are correctly selected and annotated.
- Verify that AI output assembles cleanly at each agreed checkpoint.
- Resolve ambiguous notation and naming decisions in collaboration with AI.
- Approve or reject all inferred symbol names before they are finalised.
- Make final calls when source scans are ambiguous or contradictory.

---

## Checkpoint Protocol

- Every **3 translated pages**, the AI will:
  1. Run an assembly check on the current output.
  2. Summarise any newly opened or unresolved items.
  3. Update `ORPHANS.md` and `TRANSLATE.md`.
  4. Export both `export.lst` and `export.asm` for code-first review.
  5. Wait for user confirmation before continuing.

---

## File Conventions

### `TRANSLATE.md`
Each entry should include:
- Page range translated
- Address range covered
- Confidence marker: `high`, `medium`, or `low`
- Any notable ambiguities or scan quality issues

### `ORPHANS.md`
Each entry should include:
- Address range
- Nature of the issue (e.g., unrecognised byte sequence, ambiguous branch target)
- Status label: `open`, `needs-user`, or `resolved`
- A **Decision Log** section for human-approved naming and context decisions

### `SOURCES.md`
Each entry should include:
- Date accessed
- URL or document title
- What was used from it
- Why it was considered trustworthy
