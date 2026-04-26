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
| `./z80bench-cli` | CLI tool AI uses to read and write project annotation files |
| `./doc/` | PDF scans of the original VZ200 ROM listing |
| `./old-progress/` | Previous attempt data — AI may read annotations for context, but must not copy any assembly |
| `./z80bench_info/` | z80bench documentation, workflow guide, and licence file |
| `./external/` | Git submodules, including a fully documented English listing of Level II BASIC for the TRS-80 |
| `./PROGRESS.md` | will contain all of the notes from the previous iteration (look below for details.)

in the path on this system you have access to z88dk-z80asm for an assembler. you may use that.
in the root of the repo there is a simlink to the z80bench-cli if it's not starting you can build it (its a submodule to the repo)


---

## Getting Started (New AI Session)

Before beginning work, an AI assistant should:

1) Read all relivent docs and understand how z80bench-cli works. (full source is in @./external/z80bench)
2) Familiarize with the formatting expected in in export.lst (the project deleverable.)
3) run a test build on export.asm, and compair the binary against VZ200.bin
4) if the build fails, or there are any issues / questions ask at this time.
5) sometimes there will be prior work in the requested range, use this work and verify it against the translation


After that is completed go to work

1) you are translating the annotations from the german pdf found in @"./doc/book - Laser310-ROM-Listing-german.pdf"
2) these annotations include: Block comments (headers, separators made with astrix '*' symbols, and in line comments.
3) please work on just the section given (this will be a memory range.)
4) you can view the other pdf "book - other - Level II ROM Reference Manual.pdf" for information
5) you can view the submodule @./external/TRS-80-ROMS for ideas for lable names and symbol names.
6) only update the work files with z80bench-cli
7) do not make any design changes to the rom, we are working on only annotations for the listing.
8) keep track of annotation total count and symbol total count.

After you have completed the listing work deliver the files

1) sumerize what was done by updating (or creating) PROGRESS.md
  - this should include any work done to understand the toolchain
  - this should include any issues incountered the user has to follow up on
  - this should include the prompt from the user.
  - should include annotation and symbol count and warn if getting close to maximums in z80bench
2) export the deliverables using z80bench.cli (these are export.asm and export.lst)
3) check export.lst for inline comments on the work section completed. 
  - this is a common miss. if they are not there, recheck work and fix 
  - after fixed you will need to go back to step 1 in this section (deliverables)
  - iterate this until the inline comments are present
4) make sure annotations are in english, if not go back and translate.
5) build export.asm and compare to VZ200.bin


# Z80 bench maximums:
<pre>
  ┌────────────────┬─────────────────────────────────┬─────────────────┬───────────────────────────────────────────────┐
  │ Component      │ Limit                           │ Location        │ Impact                                        │
  ├────────────────┼─────────────────────────────────┼─────────────────┼───────────────────────────────────────────────┤
  │ Annotations    │ 100000                          │ annotate.c      │ Total comments, labels, and block headers.    │
  │ Symbols        │ 6000                            │ symbols.c       │ Total EQU definitions in symbols.sym.         │
  │ Map Entries    │ 100                             │ memmap.c        │ Total segments in segments.map.               │
  │ Regions        │ 100                             │ annotate.c      │ Total basic memory regions (CODE, DATA, etc). │
  │ Total Lines    │ 100,000                         │ project.c       │ Maximum number of disassembled lines.         │
  │ Label Length   │ 64 chars                        │ z80bench_core.h │ Maximum length of a symbol or label name.     │
  │ Comment Length │ 1024 chars                      │ z80bench_core.h │ Maximum length of a single comment.           │
  └────────────────┴─────────────────────────────────┴─────────────────┴───────────────────────────────────────────────┘
</pre>
