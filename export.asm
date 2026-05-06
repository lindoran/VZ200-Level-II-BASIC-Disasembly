; z80bench export — .
; Generated: Tue May  5 23:12:35 2026
; Assembler: z88dk/z80asm

        INCLUDE "symbols.sym"
        ORG     0x0000


; Initialisation of the computer
; START: (defined in symbols.sym)
              di                   ; Test Start
              xor   a              ; Clear A (color index 0)
              ld    (0x6800),a     ; Set background color (black)
              jp    BASIC_INIT_1   ; Jump to RESET part 1 (at 0674H)

;
; *****************************************************************
; RST08_VEC: (defined in symbols.sym)
              jp    0x7800         ; RST 08H: Jump to RAM hook at 7800H (SYNCHR)

;
; Not used in VZ200
              pop   hl             ; Pop return address to HL
              jp    (hl)           ; Jump to HL (return to caller)
              DEFB  0x00,0x00,0x00
; RST10_VEC: (defined in symbols.sym)
              jp    0x7803         ; RST 10H: Jump to RAM hook at 7803H (CHRGOT)

; Reading a character via Device Control Block (DCB)
; GET_CHAR_DCB: (defined in symbols.sym)
              push  bc             ; Read character via DCB
              ld    b,0x01         ; Set B for DCB check
              jr    $+48           ; Jump to DCB dispatcher
; RST18_VEC: (defined in symbols.sym)
              jp    0x7806         ; RST 18H: Jump to RAM hook at 7806H (CMPHDE)

; Output of a character via Device Control Block (DCB)
; PUT_CHAR_DCB: (defined in symbols.sym)
              push  bc             ; Output character via DCB
              ld    b,0x02         ; Set B for DCB check
              jr    $+40           ; Jump to DCB dispatcher
; RST20_VEC: (defined in symbols.sym)
              jp    0x7809         ; RST 20H: Jump to RAM hook at 7809H (TSTTYP)
              push  bc             ; Unused code path (GET_CHAR skip)
              ld    b,0x04         ; Set B for DCB check
              jr    $+32           ; Jump to DCB dispatcher
; RST28_VEC: (defined in symbols.sym)
              jp    0x780C         ; RST 28H: Jump to RAM hook at 780CH

; Keyboard query
; KBD_QUERY: (defined in symbols.sym)
              ld    de,0x7815      ; Load keyboard DCB address
              jr    $-27           ; Continue keyboard routine
; RST30_VEC: (defined in symbols.sym)
              jp    0x780F         ; RST 30H: Jump to RAM hook at 780FH

; Screen output via DCB
; SCR_OUT_DCB: (defined in symbols.sym)
              ld    de,0x781D      ; Load screen DCB address
              jr    $-27           ; Continue output routine
; RST38_VEC: (defined in symbols.sym)
              jp    0x2EB8         ; RST 38H: Jump to Interrupt Service Routine (2EB8H)

; Printer output via Device Control Block (DCB)
; PRN_OUT_DCB: (defined in symbols.sym)
              ld    de,0x7825      ; Load printer DCB address
              jr    $-35           ; Continue output routine
              jp    0x2EFD         ; Jump to keyboard read routine (2EFDH)
              ret                  ; Return from unused path
              DEFB  0x00,0x00
; DCB_CALL: (defined in symbols.sym)
              jp    DCB_DISPATCH   ; Jump to DCB dispatcher (0674H)

; Keyboard query waits until a key is pressed
; KBD_WAIT: (defined in symbols.sym)
              call  KBD_QUERY      ; Call keyboard scan (002BH)
              or    a              ; Key pressed?
              ret   nz             ; Yes, return
              jr    $-5            ; No, wait

;
; *****************************************************************
;
; Save character from cursor position
; GET_CURSOR_CHAR: (defined in symbols.sym)
              ld    hl,(0x7820)    ; Load cursor address (7820H)
              ld    a,(hl)         ; Load character from cursor position
              ld    (0x783C),a     ; Save character to 783CH
              ret                  ; Return

; not used in vz200
              DEFB  0x4C,0xFE,0x54,0x20,0xD6,0xFD,0x21,0xF1

;
; Delay loop (input: register BC determines duration)
; DELAY_LOOP: (defined in symbols.sym)
              dec   bc             ; Decrement BC
              ld    a,b            ; B = 0?
              or    c              ; C = 0?
              jr    nz,$-3         ; No, continue loop
              ret                  ; Yes, return

; Interupt vector for 'Non maskable interrupts'
; NMI_VEC: (defined in symbols.sym)
              ld    sp,0x0600      ; Set stack pointer to 6000H
              ld    a,(0x68EC)     ; Load latch byte from 68ECH
              inc   a              ; Increment A
              cp    0x02           ; CP 2
              jp    nc,START       ; Jump if NC to cold start (0000H)
              jp    0x06CC         ; Jump to warm start (06CCH)

; BASIC initialisation part 2
; BASIC_INIT_2: (defined in symbols.sym)
              ld    de,FDIVC       ; Destination: 7880H (RAM hooks)
              ld    hl,0x18F7      ; Source: 18F7H
              ld    bc,0x0027      ; Length: 27H bytes
              ldir                 ; Copy routines to RAM

; Set up I/O buffer
; INIT_IO_BUF: (defined in symbols.sym)
              ld    hl,0x79E5      ; Load I/O buffer start (79E5H)
              ld    (hl),0x3A      ; Store ':' prompt
              inc   hl             ; Increment HL
              ld    (hl),b         ; Store character from B
              inc   hl             ; Increment HL
              ld    (hl),0x2C      ; Store ',' character
              inc   hl             ; Increment HL
              ld    (0x78A7),hl    ; Save I/O buffer pointer to 78A7H

; Initialisation of the DOS error hooks (RAM: 7952H)
INIT_DOS_HOOKS:
              ld    de,ERROR_L3    ; Address of L3 error handler (012DH)
              ld    b,0x1C         ; 28 DOS commands to initialize
              ld    hl,0x7952      ; RAM hook table address (7952H)
INIT_DOS_LOOP:
              ld    (hl),0xC3      ; Store JP opcode (0xC3)
              inc   hl             ; Increment RAM pointer
              ld    (hl),e         ; Low byte of L3 handler
              inc   hl             ; Increment RAM pointer
              ld    (hl),d         ; High byte of L3 handler
              inc   hl             ; Increment RAM pointer
              djnz  $-7            ; Loop for 28 entries

; Initialisation of the DOS exits with RET (RAM: 79A6H)
INIT_DOS_EXITS:
              ld    b,0x15         ; 21 DOS exits to initialize
INIT_EXIT_LOOP:
              ld    (hl),0xC9      ; Store RET opcode (0xC9)
              inc   hl             ; Advance 3 bytes (unused JP slot)
              inc   hl
              inc   hl
              djnz  $-5            ; Loop for 21 entries

; End of BASIC initialisation
INIT_BASIC_FINISH:
              ld    hl,0x7AE8      ; Load start of user RAM (7AE8H)
              ld    (hl),b         ; Initialize it to zero
              ld    sp,0x79F8      ; Set temporary stack pointer (79F8H)
              call  0x1B8F         ; Initialize stack and variables (STKINI)
              call  CLRSCR         ; Clear screen and home cursor (CLRSCR)

;
; ************************************************************************
; Unused code block / timing delay? falls into next segment
; possbile removed block from TRS-80?
              DEFB  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
              DEFB  0x00

; Skip memory test
SKIP_MEM_TEST:
              jr    $+6            ; Jump to memory test routine
              rst   0x10
              or    a
              jr    nz,$+20

; Memory test (memory size check)
MEM_TEST:
              ld    hl,0x7B4C      ; Start of RAM check (7B4CH)
MEM_TEST_LOOP:
              inc   hl             ; Next ram location
              ld    a,h            ; Get MSB
              or    l              ; Get LSB
              jr    z,$+29         ; End of memory if zero (HIMEM)
              ld    a,(hl)         ; Get byte from memory
              ld    b,a            ; Save original byte in B
              cpl                  ; Complement byte for test
              ld    (hl),a         ; Write to memory
              cp    (hl)           ; Check if it was stored correctly
              ld    (hl),b         ; Restore original byte
              jr    z,$-11         ; Loop back if memory exists
              jr    $+19

;
; ***********************************************************
; unused code in VZ200 pr. G. Wolf book
;
; Symbol name from Level II listing for TRS 80  
;
; TODO: Document from TRS 80 listing.
; ***********************************************************
MEM_SIZE_INPUT:
              call  0x1E5A         ; Handle memory size input
              or    a
              jp    nz,0x1997
              ex    de,hl
              dec   hl
              ld    a,0x8F
              ld    b,(hl)
              ld    (hl),a
              cp    (hl)
              ld    (hl),b
              jr    nz,$-48

;
; ***********************************************************
;
; Set end of memory for BASIC
              dec   hl             ; address of the last byte
              ld    de,0x7C14      ; at least 1868 bytes must be free
              rst   0x18           ; check free memory
              jp    c,0x197A       ; otherwise: OUT OF MEMORY error (197AH)
              ld    de,0xFFCE      ; DE = -50 (FFCE is 2s comp. -50)
              ld    (0x78B1),hl    ; store end-of-memory address (@ 78B1H)
              add   hl,de          ; HL = end of memory - 50
              ld    (0x78A0),hl    ; = start of string space - 1
INIT_VARS_2:
              call  0x1B4D         ; call the NEW routine (1B4DH)
              call  0x3484         ; initialize counters and pointers (3484H)
              ld    hl,0x010F      ; Load banner string address (010FH)
              call  OUTSTR         ; Print banner string (OUTSTR)
              im    1              ; Set Interrupt Mode 1
              jp    BASIC_INIT_3   ; Jump to memory expansion check (068EH)
              DEFB  0x00,0x7E,0x23,0xFE,0x0D ; Artifact? No caller

; Banner-Text: VIDEO TECHNOLOGY BASIC V2.0
              DEFM  "VIDEO TECHNOLOGY"
              DEFB  0x0D
              DEFM  "BASIC V2.0"
              DEFB  0x0D,0x0D,0x00 ; term with 00

; L3 Error Handler (?L3 ERROR)
; ERROR_L3: (defined in symbols.sym)
              ld    e,0x2C         ; Load error code 44 (L3 Error)
              jp    0x19A2         ; Jump to main error handler

; GRAPHICS ROUTINE - Common Code for SET, RESET and POINT
; A will be 0 for POINT, 80H for SET and 1 for RESET.
POINT:
              rst   0x10           ; Get next character (RST 10H)
              xor   a              ; A = 0 (POINT flag)
              DEFB  0x01           ; Skip LD A,n (01 matches LD BC,nn)
SET:
              ld    a,0x80         ; A = 80H (SET flag)
              DEFB  0x01           ; Skip LD A,n
RESET:
              ld    a,0x01         ; A = 1 (RESET flag)
              push  af             ; Save command flag (POINT/SET/RESET)
              rst   8              ; Expect '(' (RST 08H)
              jr    z,$-49         ; JR Z, 010BH (GETBYT?)
              inc   e              ; INC E
              dec   hl             ; DEC HL
              cp    0x80           ; X < 128?
              jp    nc,0x1E4A      ; JP NC, FCERR (1E4AH)
              push  af             ; Save X
              rst   8              ; Expect ',' (RST 08H)
              inc   l              ; INC L
              call  0x2B1C         ; Call GETBYT (2B1CH?)
              cp    0x40           ; Y < 64?
              jp    nc,0x1E4A      ; JP NC, FCERR (1E4AH)
              ld    e,a            ; E = Y
              xor   a              ; A = 0
              ld    d,a            ; D = 0
              ex    de,hl          ; DE <-> HL (HL = Y)
              add   hl,hl          ; Y * 2
              add   hl,hl          ; Y * 4
              add   hl,hl          ; Y * 8
              add   hl,hl          ; Y * 16
              add   hl,hl          ; Y * 32
              ex    de,hl          ; DE <-> HL (DE = Y * 32)
              pop   af             ; Get X
              push  af             ; Save X
              srl   a              ; X / 2
              srl   a              ; X / 4
              add   a,e            ; A = X/4 + (Y*32 mod 256)
              ld    e,a            ; E = A
              ld    a,d            ; A = D (high byte of Y*32)
              or    0x70           ; OR 70H (Video RAM starts at 7000H)
              ld    d,a            ; D = A (DE = 7000H + Y*32 + X/4)
              pop   af             ; Get X again
              and   0x03           ; X AND 03H (pixel position in byte)
              add   a,a            ; A = pixel * 2
              ld    b,a            ; B = A
              pop   af             ; Get original command flag (POINT/SET/RESET)
              or    a              ; Is it POINT (0)?
              jp    z,0x38E7       ; Yes, JP to POINT routine (38E7H)
              push  af             ; Save Command flag
              ld    c,0x3F         ; C = 3FH (Graphics mask?)
              ld    a,(0x7846)     ; Get color mode latch?
              sla   a              ; SLA A
              sla   a              ; SLA A
              rrc   a              ; RRC A
              rrc   c              ; RRC C
              djnz  $-4            ; DJNZ hBc2 (Shift bit into position)
              jp    0x3903         ; JP to rest of SET/RESET (3903H)

; Set cursor to 7839H and reset bit 3
              ld    hl,0x7839      ; Load 7839H (Cursor flags?)
              res   3,(hl)         ; Reset bit 3
              ld    hl,0x0384      ; Load address of 'ERROR' message
              call  OUTSTR         ; Print string (OUTSTR)
              jp    0x36CF         ; Jump to 36CFH

;
; *******************************************************
; UNUSED BYTE ARTIFACT INSIDE VZ200 ROM
; *******************************************************
              DEFB  0xF1,0xFE,0x20,0x20,0x14,0x1A,0x13,0xFE
              DEFB  0x20,0x28,0xFA,0xFE

; Parameter / Coordinate Parsing (for Graphics?)
              rst   0x10           ; Get next character (RST 10H)
              push  hl             ; Save pointer
              ld    a,(0x7899)     ; Get RAM byte 7899H
              or    a              ; Zero?
              jr    nz,$+8         ; No, skip next part
              call  KBD_QUERY_WRAP ; Call 0358H
              or    a              ; Zero?
              jr    z,$+19         ; Yes, skip ahead
              push  af
              xor   a
              ld    (0x7899),a
              inc   a
              call  0x2857         ; Call STRINI (2857H)
              pop   af
              ld    hl,(0x78D4)    ; Get 78D4H
              ld    (hl),a
              jp    0x2884         ; Jump to 2884H
              ld    hl,0x1928      ; Load 1928H into 7921H
              ld    (FACLO),hl
              ld    a,0x03         ; Set 78AFH to 3
              ld    (VALTYP),a
              pop   hl             ; Restore HL
              ret                  ; Return

; Clear Screen and Home Cursor
; CLRSCR_HOME: (defined in symbols.sym)
              ld    a,0x1C         ; Clear screen (1CH)
              call  SCREEN_OUT_CHAR
              ld    a,0x1F         ; Move cursor home (1FH)
              jp    SCREEN_OUT_CHAR

; RANDOM statement seed initialization
RANDOM_INIT:
              ld    a,r            ; Get Refresh Register R
              ld    (0x78AB),a     ; Store refresh value as random seed base
              ret   

; *******************************
; Keyboard tables
; *******************************
; Key codes without SHIFT
KEYBOARD_CODES_NORMAL:
              DEFB  0x54,0x47,0x42,0x35,0x4E,0x36,0x59,0x48 ; Bit row 0
              DEFB  0x57,0x53,0x58,0x32,0x2E,0x39,0x4F,0x4C ; Bit row 1
              DEFB  0x00,0x00,0x00,0x00,0x00,0x2D,0x0D,0x3A ; Bit row 2
              DEFB  0x45,0x44,0x43,0x33,0x2C,0x38,0x49,0x4B ; Bit row 3
              DEFB  0x51,0x41,0x5A,0x31,0x20,0x30,0x50,0x3B ; Bit row 4
              DEFB  0x52,0x46,0x56,0x34,0x4D,0x37,0x55,0x4A ; Bit row 5

; Key codes with SHIFT (incl. semigraphics)
KEYBOARD_CODES_SHIFT:
              DEFB  0x8C,0x89,0x00,0x25,0x5E,0x26,0x83,0x86 ; Bit row 0
              DEFB  0x8D,0x82,0x00,0x22,0x3E,0x29,0x5B,0x3F ; Bit row 1
              DEFB  0x00,0x00,0x00,0x00,0x00,0x3D,0x0D,0x2A ; Bit row 2
              DEFB  0x8B,0x84,0x00,0x23,0x3C,0x28,0x85,0x2F ; Bit row 3
              DEFB  0x8E,0x81,0x80,0x21,0x20,0x40,0x5D,0x2B ; Bit row 4
              DEFB  0x87,0x88,0x00,0x24,0x5C,0x27,0x8A,0x8F ; Bit row 5

; Key codes with CTRL (incl. CMD tokens)
KEYBOARD_CODES_CTRL:
              DEFB  0xCA,0x8D,0xB5,0xB4,0x97,0x8E,0x95,0x84 ; Bit row 0
              DEFB  0xBD,0xCC,0xB1,0xB9,0x1B,0x8B,0x8C,0x15 ; Bit row 1
              DEFB  0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00 ; Bit row 2
              DEFB  0x87,0x8A,0xB3,0x9C,0x09,0xBB,0x89,0xBC ; Bit row 3
              DEFB  0x81,0x9D,0xE5,0xBA,0x0A,0x88,0xB2,0x7F ; Bit row 4
              DEFB  0x92,0x91,0xAF,0x98,0x08,0x80,0x8F,0x93 ; Bit row 5

; Function key codes (with CTRL+ENTER)
KEYBOARD_CODES_FUNCTION:
              DEFB  0xFA,0x94,0x9E,0xDF,0xBF,0xE0,0xF9,0x83 ; Bit row 0
              DEFB  0xF5,0xF4,0xA0,0xE1,0x00,0xD9,0xD3,0x00 ; Bit row 1
              DEFB  0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00 ; Bit row 2
              DEFB  0xF3,0x90,0x96,0xE3,0x00,0xDD,0xD2,0xC6 ; Bit row 3
              DEFB  0xF7,0xF6,0xDB,0xE2,0x00,0xD8,0xCB,0x00 ; Bit row 4
              DEFB  0xF8,0xDE,0xC1,0xE4,0x00,0xD7,0xC9,0x82 ; Bit row 5

; Tokens that append '(' on output
TOKEN_APPEND_PAREN:
              DEFB  0xE2,0xE1,0xE3,0xE4,0xDF,0xE0,0xD7,0xDD ; Token row 0
              DEFB  0xD9,0xD8,0xF7,0xF5,0xF3,0xF8,0xF7,0xF9 ; Token row 1
              DEFB  0x9D,0xF6,0xF4,0xDE,0xE5,0xFA ; Token row 2

; *******************************
; Printer semigraphics output table
; (2 bytes per character)
; *******************************
PRINTER_GRAPHICS_TABLE:
              DEFB  0x80,0x80      ; Char 0x80
              DEFB  0x80,0xB8      ; Char 0x81
              DEFB  0xB8,0x80      ; Char 0x82
              DEFB  0xB8,0xB8      ; Char 0x83
              DEFB  0x80,0x87      ; Char 0x84
              DEFB  0x80,0xBF      ; Char 0x85
              DEFB  0xB8,0x87      ; Char 0x86
              DEFB  0xB8,0xBF      ; Char 0x87
              DEFB  0x87,0x80      ; Char 0x88
              DEFB  0x87,0xB8      ; Char 0x89
              DEFB  0xBF,0x80      ; Char 0x8A
              DEFB  0xBF,0xB8      ; Char 0x8B
              DEFB  0x87,0x87      ; Char 0x8C
              DEFB  0x87,0xBF      ; Char 0x8D
              DEFB  0xBF,0x87      ; Char 0x8E
              DEFB  0xBF,0xBF      ; Char 0x8F

; *******************************
; SOUND frequency table
; (2-byte value per note)
; *******************************
SOUND_FREQ_TABLE:
              DEFW  0x0272,0x024F,0x022E,0x020E,0x01F1,0x01D5,0x01B7,0x019E ; A2-E3
              DEFW  0x0186,0x0170,0x015B,0x0148,0x0135,0x0123,0x0113,0x0103 ; F3-C#4
              DEFW  0x00F4,0x00E6,0x00D9,0x00CD,0x00C1,0x00B6,0x00AB,0x00A1 ; C#4-G4
              DEFW  0x0098,0x008F,0x0087,0x007F,0x0078,0x0070,0x006A ; A4-D5

; *******************************
; Restore character at cursor position
; (part of screen output routine)
; *******************************
CURSOR_CHAR_RESTORE:
              ld    b,a            ; Output character in B
              ld    a,(0x783C)     ; Load character at cursor position
              ld    hl,(0x7820)    ; Load cursor address
              ld    (hl),a         ; Write character
              ld    a,b            ; Restore output character in A
              ret                  ; Return

; *******************************
; Cursor address one line back
CURSOR_LINE_BACK:
              ld    bc,RST20_VEC   ; Line length
              or    a              ; Clear carry
              sbc   hl,bc          ; Cursor address minus one line
              ld    (0x7820),hl    ; Store in cursor pointer
              ret                  ; Return

; *******************************
; SOUND duration multipliers
; (1 byte per input code 1-9)
; *******************************
              DEFB  0x01,0x02,0x03,0x04,0x06,0x08,0x0C,0x10 ; A2-E3
              DEFB  0x18           ; Data bytes 0x18

; Output character to screen, printer or cassette.
CHAR_OUTPUT_DISPATCH:
              push  bc             ; save BC
              ld    c,a            ; store character in C
              call  0x79C1         ; RAM expansion output (RET)
              ld    a,(0x789C)     ; load output flag
              or    a              ; and test
              ld    a,c            ; character back to A
              pop   bc             ; restore BC
              jp    m,0x3B54       ; Cassette? yes - continue at 3B54H
              jr    nz,$+100       ; Printer? yes - to printer output

; Output a character to the screen
SCREEN_OUT_CHAR:
              push  de             ; save registers
              push  af             ; Push af
              push  bc             ; Push bc
              push  hl             ; Push hl
              call  0x308B         ; call output routine
              pop   hl             ; restore registers
              pop   bc             ; Pop bc
              nop                  ; No operation
              nop                  ; No operation
              pop   af             ; Pop af
              pop   de             ; Pop de
              ret                  ; done

; Determine cursor position in line
; not used on LASER 110-310
CURSOR_COL_GET:
              ld    a,(0x783D)     ; Load a from (0x783D)
              and   0x08           ; AND A with 0x08
              ld    a,(0x7820)     ; Load a from (0x7820)
              jr    z,$+5          ; Relative jump if z to $+5
              rrca                 ; Rotate A right
              and   0x1F           ; AND A with 0x1F
              and   0x1F           ; AND A with 0x1F
              ret                  ; Return

; Keyboard query
KBD_QUERY_WRAP:
              call  0x79C4         ; RAM expansion output (RET)
              push  de             ; save DE
              call  KBD_QUERY      ; evaluate keyboard
              pop   de             ; restore DE
              ret                  ; Return

; Table of basic time values for each individual note of the SOUND command.
              DEFB  0x0A,0x0B,0x0C,0x0C,0x0D,0x0E,0x0F,0x0F ; A2-E3
              DEFB  0x10,0x11,0x12,0x13,0x15,0x16,0x17,0x19 ; F3-C4
              DEFB  0x1A,0x1C,0x1D,0x1F,0x21,0x23,0x25,0x27 ; C#4-G#4
              DEFB  0x29,0x2C,0x2E,0x31,0x34,0x35,0x3A ; A4-D#5

; OK and error message of the VERIFY command
              DEFM  "OK"           ; \
              DEFB  0x0D,0x00      ; Data bytes 0x0D,0x00
              DEFM  "ERROR"        ; \
              DEFB  0x0D,0x00      ; Data bytes 0x0D,0x00

; Output flag to screen.
; CR on printer, if not at start of line
OUTPUT_SCREEN_SELECT:
              xor   a              ; output flag to screen
              ld    (0x789C),a     ; Load (0x789C) from a
              ld    a,(0x789B)     ; printer position in line
              or    a              ; = 0?
              ret   z              ; yes - done

; Output carriage return to printer
              ld    a,0x0D         ; load CR
              push  de             ; save DE
              call  PRINTER_OUT_CHAR ; output CR
              pop   de             ; restore DE
              ret                  ; Return

; Output character to printer.
PRINTER_OUT_CHAR:
              push  af             ; save registers
              push  de             ; Push de
              push  bc             ; Push bc
              ld    c,a            ; character in C
              ld    e,0x00         ; E = 0
              cp    0x0C           ; is it a Form Feed?
              jr    z,$+18         ; yes!
              cp    0x0A           ; is it a Line Feed?
              jr    nz,$+5         ; no!
              ld    a,0x0D         ; yes, replace with carriage return
              ld    c,a            ; and in C
              cp    0x0D           ; is it a carriage return?
              jr    z,$+7          ; yes!
              ld    a,(0x789B)     ; load print head position
              inc   a              ; +1
              ld    e,a            ; in E
              ld    a,e            ; save new position (CR=0)
              ld    (0x789B),a     ; Load (0x789B) from a
              ld    a,c            ; character to be output in A
              call  PRN_OUT_DCB    ; print character
              pop   bc             ; restore register contents
              pop   de             ; Pop de
              pop   af             ; Pop af
              ret                  ; done

; Call driver routines via the Device Control Block
DCB_DISPATCH:
              push  hl             ; save registers
              push  ix             ; Push ix
              push  de             ; DCB address in IX
              pop   ix             ; Pop ix
              push  de             ; and on stack
              ld    hl,0x03DD      ; return address on stack
              push  hl             ; Push hl
              ld    c,a            ; character to C
              ld    a,(de)         ; load DCB identifier (1st byte)
              and   b              ; AND with specified type
              cp    b              ; correct type?
              jp    nz,0x7833      ; no, return via RAM 7833H
              cp    0x02           ; set carry for inputs
              ld    l,(ix+0x01)    ; load driver address from DCB
              ld    h,(ix+0x02)    ; Load h from (ix+0x02)
              jp    (hl)           ; jump to driver
              pop   de             ; restore registers
              pop   ix             ; Pop ix
              pop   hl             ; Pop hl
              pop   bc             ; Pop bc
              ret                  ; done

; Read a line from the keyboard.
; The line is read until the RETURN or BREAK key is pressed, displayed on the 
; screen and then transferred to the I/O buffer.
INPUT_LINE_READ:
              ld    hl,0x7839      ; initialization flag for
              set   5,(hl)         ; set buffered output.
              ld    hl,(0x7820)    ; load cursor address
              call  0x0053         ; save character at cursor position
              ld    a,h            ; cursor at the beginning of the last line?
              cp    0x71           ; Compare A with 0x71
              jr    nz,$+18        ; no
              ld    a,l            ; Load a from l
              cp    0xE0           ; Compare A with 0xE0
              jr    nz,$+13        ; no
              ld    a,(0x7AD7)     ; check status of 1st line
              or    a              ; = continuation line?
              jr    nz,$+7         ; no!
              ld    a,0x0D         ; scroll image up one line
              call  0x308B         ; Call 0x308B
              ld    b,c            ; length of leading text in B
              push  bc             ; on stack (B=C)
              ld    hl,0x7839      ; address Flag 2
              res   0,(hl)         ; reset CR flag
              res   2,(hl)         ; reset BREAK flag
              bit   0,(hl)         ; wait until CR flag is set
              jr    z,$-2          ; Relative jump if z to $-2

; Determine starting address of input line
              ld    a,(0x78A6)     ; load column in input line
              ld    c,a            ; in BC
              xor   a              ; Clear A
              ld    (0x78A6),a     ; column counter = 0 (start of line)
              ld    b,a            ; Load b from a
              ld    hl,(0x7820)    ; load cursor address
              sbc   hl,bc          ; - column = start of line
              ld    (0x7820),hl    ; back to cursor pointer

; Load buffer and line address
              ld    de,0x79E8      ; starting address of I/O buffer
              pop   bc             ; character counter of leading text
              ld    hl,0x7839      ; address Flag 2
              bit   4,(hl)         ; is this an INPUT command?
              ld    hl,(0x7820)    ; load starting address of line
              jr    z,$+68         ; no INPUT cmd, continue at 471H

; For INPUT set text pointer after given text
              push  bc             ; save registers
              push  hl             ; Push hl
              call  0x33A8         ; determine status of line
              pop   hl             ; reload HL + BC
              pop   bc             ; Pop bc
              or    a              ; continuation line? (status=00)
              jr    nz,$+10        ; no!
              ld    a,l            ; line address in HL - 1 line
              sub   0x20           ; Subtract 0x20 from A
              ld    l,a            ; Load l from a
              ld    a,h            ; Load a from h
              sbc   a,0x00         ; Subtract 0x00 with carry from a
              ld    h,a            ; Load h from a
              ld    c,b            ; number of leading characters
              ld    a,(de)         ; pointer after leading text
              cp    (hl)           ; compare if not changed
              jr    nz,$+9         ; not equal, stop
              inc   hl             ; screen pointer + 1
              inc   de             ; buffer pointer + 1
              djnz  $-6            ; done?
              push  bc             ; if equal, remember length
              jr    $+6            ; continue at 0451
              ld    bc,START       ; unequal, length = 0
              push  bc             ; on the stack
              push  hl             ; save HL
              call  0x33A8         ; read status of line
              pop   hl             ; reload HL + BC
              pop   bc             ; Pop bc
              push  bc             ; remember length again
              cp    0x80           ; single line?
              jr    z,$+12         ; yes!
              ld    a,0x40         ; max characters = 64 - lead
              sub   c              ; Subtract c from A
              ld    b,a            ; Load b from a
              pop   de             ; number of leading characters in stack
              ld    e,0x00         ; set to 0
              push  de             ; Push de
              jr    $+7            ; take 2 lines
              ld    b,0x20         ; take 1 line
              ld    hl,(0x7820)    ; load text start address
              ld    de,0x79E8      ; I/O buffer address
              jp    0x3EA8         ; check background color

; Determine text starting address and max length, if not INPUT command
              ld    bc,START       ; set leading text length = 0
              push  bc             ; on stack
              push  hl             ; save HL
              call  0x33A8         ; determine status of line
              pop   hl             ; reload HL
              cp    0x80           ; single line?
              jr    z,$+16         ; yes!
              cp    0x81           ; 2 lines?
              jr    z,$+8          ; yes!
              ld    bc,RST20_VEC   ; for continuation line, back one line
              or    a              ; Test A
              sbc   hl,bc          ; Subtract bc with carry from hl
              ld    b,0x40         ; take 2 lines
              jr    $+4            ; Relative jump to $+4
              ld    b,0x20         ; take 1 line
              ld    a,(0x7818)     ; check background color
              or    a              ; 0 = green, 1 = black
              jp    z,0x3E40       ; if green continue at 3E40H

; Transferring data from screen to I/O buffer
              ld    a,(hl)         ; load character from screen
              cp    0x40           ; graphics or inverse?
              jp    c,0x04AE       ; no, take it
              pop   bc             ; if not INPUT, then graphics and inverse are only allowed in str
              ld    de,0x04A4      ; return address in stack
              push  de             ; Push de
              push  bc             ; Push bc
              jp    0x0502         ; check text end identifier (BREAK?)
              ret   c              ; BREAK, back to BASIC
              ld    hl,0x3E1A      ; text \
              call  OUTSTR         ; output
              jp    INPUT_LINE_READ ; back to line entry
              cp    0x22           ; string identifier?
              jr    nz,$+51        ; no, continue
              ld    (de),a         ; character in I/O buffer
              inc   hl             ; screen address + 1
              inc   de             ; buffer address + 1
              dec   b              ; character counter -1
              jr    z,$+56         ; if 0, end takeover
              ld    a,(hl)         ; load character from screen
              cp    0x40           ; normal text character?
              jp    c,0x04C9       ; yes!
              cp    0x80           ; inverse text character?
              jp    c,0x04C5       ; yes!
              and   0x8F           ; graphics character, clear bits 4,5,6
              or    0x80           ; set bit 7
              jr    $+21           ; Relative jump to $+21
              cp    0x22           ; string delimiter '\
              jr    nz,$+11        ; no!
              push  hl             ; save HL
              ld    hl,0x7839      ; address Flag 2
              bit   4,(hl)         ; INPUT command?
              pop   hl             ; reload HL
              jr    z,$+15         ; no - from now on graphics and inverse not allowed.
              bit   5,a            ; character in real ASCII code
              jr    nz,$+4         ; convert, e.g. 'A' from 01 to 41
              or    0x40           ; affects codes 00 - 1FH
              ld    (de),a         ; character in I/O buffer
              inc   hl             ; screen address + 1
              inc   de             ; buffer address + 1
              djnz  $-39           ; counter - 1
              jr    $+13           ; = 0, then done
              bit   5,a            ; character in real ASCII code
              jr    nz,$+4         ; convert, e.g. 'C' from 03 to 43
              or    0x40           ; affects codes 00 - 1FH
              ld    (de),a         ; character in I/O buffer
              inc   hl             ; screen address + 1
              inc   de             ; buffer address + 1
              djnz  $-87           ; counter - 1

; Finalize buffer after transfer
              dec   de             ; eliminate blanks at buffer end
              ld    a,d            ; at buffer start?
              cp    0x79           ; Compare A with 0x79
              jr    nz,$+8         ; no
              ld    a,e            ; Load a from e
              cp    0xE8           ; Compare A with 0xE8
              jp    c,0x04FF       ; yes, done
              ld    a,(de)         ; load character
              cp    0x20           ; = blank?
              jr    z,$-15         ; yes, further back
              inc   de             ; buffer end with X'00'
              xor   a              ; mark it
              ld    (de),a         ; Load (de) from a

; Output one or two blank lines by line status
              call  0x33A8         ; determine line status
              ld    hl,(0x7820)    ; load cursor pointer
              cp    0x81           ; 2 lines?
              call  0x0053         ; save character from cursor position.
              jr    nz,$+6         ; single line
              xor   a              ; 1 blank line output
              call  0x308B         ; Call 0x308B
              xor   a              ; 1 blank line output
              call  0x308B         ; Call 0x308B
              ld    a,(0x7838)     ; load Flag 1
              and   0xFD           ; reset INVERSE flag
              ld    (0x7838),a     ; Flag 1 back
              ld    hl,0x7839      ; address Flag 2
              bit   2,(hl)         ; BREAK flag set?
              jr    z,$+7          ; no!
              ld    a,0x01         ; BREAK, A=1
              scf                  ; + set carry
              jr    $+3            ; Relative jump to $+3
              xor   a              ; no BREAK, A=0

; Reset input command flag and continue
              ld    hl,0x7839      ; address Flag 2
              res   4,(hl)         ; reset INPUT-Cmd flag
              ld    hl,0x79E8      ; address I/O buffer
              pop   bc             ; to start of input
              push  af             ; save BREAK identifier
              add   hl,bc          ; Add hl,bc
              jp    0x3E29         ; continue at 3E29H

; INPUT helper: read one line into I/O buffer
              ld    a,(0x7AAF)     ; wait until text output finished.
              or    a              ; 7AAFH contains number of characters in
              jr    nz,$-4         ; print buffer; if 0 = empty
              ld    b,0x40         ; clear I/O buffer (length 64)
              ld    hl,0x79E8      ; buffer starting address
              ld    a,0x20         ; space in A
              ld    (hl),a         ; transfer to buffer
              inc   hl             ; buffer address + 1
              djnz  $-2            ; counter - 1, if 0 - done!
              xor   a              ; 0 in A
              ld    (hl),a         ; mark buffer end with X'00'.
              call  0x33A8         ; determine line status
              or    a              ; continuation line?
              ld    a,(0x78A6)     ; load column counter
              jr    nz,$+4         ; no continuation line!
              add   a,0x20         ; add one line for continuation line.
              ld    c,a            ; transfer column counter to BC
              xor   a              ; set B = 0
              ld    b,a            ; Load b from a
              ld    hl,(0x7820)    ; load cursor pointer
              sbc   hl,bc          ; - column = start of line
              ld    de,0x79E8      ; load I/O buffer address
              push  bc             ; remember column counter
              ldir                 ; existing text from line to buffer
              pop   bc             ; reload column counter
              ld    hl,0x7839      ; address Flag 2
              set   4,(hl)         ; set INPUT-Cmd flag
              call  INPUT_LINE_READ ; read line
              ret                  ; Return

; RUN command for CRUN auto-start
              DEFM  "RUN\00"       ; Data text 'RUN\00'

; Printer driver
              DEFB  0xC4           ; Data bytes 0xC4

; Printer driver
PRINTER_DRIVER:
              inc   sp             ; Increment sp
              ld    (0xA3CD),a     ; Load (0xA3CD) from a
              ld    a,(de)         ; Load a from (de)
              call  0x17D8         ; Call 0x17D8
              call  0x190D         ; Call 0x190D
              jp    z,0x125A       ; Jump if z to 0x125A
              call  0x1F49         ; Call 0x1F49
              jr    c,$+26         ; Relative jump if c to $+26
              rst   0x28           ; Call restart vector 0x28
              ld    a,(0x0438)     ; Load a from (0x0438)
              defb  0x00DD,0x0079,0x00B7 ; Data bytes 0x00DD,0x0079,0x00B7
              jr    z,$+53         ; yes, just determine printer status
              cp    0x0B           ; Page feed?
              jr    z,$+12         ; yes - execute
              cp    0x0C           ; conditional page feed?
              jr    nz,$+22        ; no!
              xor   a              ; only executed if number of
              or    (ix+0x03)      ; lines/page is not 0
              jr    z,$+16         ; else output 0C to printer
              ld    a,(ix+0x03)    ; lines/page
              sub   (ix+0x04)      ; - number of printed lines
              ld    b,a            ; in B as skip counter
              call  0x3AE2         ; output Carriage-Return + Line Feed
              djnz  $-3            ; until new page
              jr    $+20           ; Relative jump to $+20
              call  0x3AB6         ; character output
              ld    a,c            ; reload character
              cp    0x0D           ; was that a CR?
              ret   nz             ; no, done
              inc   (ix+0x04)      ; increment line counter in DCB
              ld    a,(ix+0x04)    ; at the beginning of a new page?
              cp    (ix+0x03)      ; (line counter - lines/page)
              ld    a,c            ; character back in A
              ret   nz             ; no new page - done
              ld    (ix+0x04),0x00 ; line counter = 0
              ret                  ; Return
              in    a,(0x00)       ; determine printer status
              and   0x01           ; only BUSY is checked
              ret                  ; Return

; Clear 4-byte graphics print buffer
PRN_GFXBUF_CLEAR:
              push  bc             ; save BC + HL
              push  hl             ; Push hl
              ld    b,0x04         ; counter = 4
              ld    hl,0x7AD2      ; load buffer address
              ld    (hl),a         ; transfer A to buffer
              inc   hl             ; buffer address + 1
              djnz  $-2            ; counter - 1 = 0? yes - done!
              pop   hl             ; restore registers
              pop   bc             ; Pop bc
              ret                  ; Return

; Part of the keyboard query
; Handles the pressing of a second key before the first one has been released 
; (Rollover)
; In Flag 1 (7838H), bits 3 and 4 are used to indicate the status of the two 
; keyboard buffers B1 (7836H) and B2 (7837H).
; Bit4 Bit3 Status
; 0 0 : B1 and B2 are not pressed
; 0 1 : B1 pressed, B2 not pressed
; 1 0 : B1 not pressed, B2 pressed
; 1 1 : B1 and B2 pressed
KBD_ROLLOVER:
              ld    hl,0x7838      ; address Flag 1
              bit   2,(hl)         ; function flag set?
              jr    z,$+23         ; no - continue at 05F3H
              ld    d,a            ; save key code
              ld    a,(0x783A)     ; load timer value
              or    a              ; = 0?
              jr    z,$+17         ; yes - continue at 05F4H
              inc   a              ; timer value + 1
              ld    (0x783A),a     ; store back
              cp    0x2A           ; time elapsed? (approx. 0.84 sec)
              jr    z,$+4          ; yes!
              xor   a              ; clear character
              ret                  ; and back
              res   2,(hl)         ; clear function flag
              xor   a              ; clear character
              ret                  ; back
              ld    d,a            ; save character in D
              ld    hl,0x7838      ; address Flag 1
              ld    a,(hl)         ; load into A
              and   0x18           ; test bits 3 and 4
              jr    nz,$+13        ; bit 3 and/or bit 4 set
              set   3,(hl)         ; set bit 3
              xor   a              ; clear B2
              ld    (0x7837),a     ; Load (0x7837) from a
              ld    a,d            ; reload character
              ld    (0x7836),a     ; and enter in B1
              ret                  ; only one key pressed - done!

; Key was held
              bit   4,(hl)         ; already two keys in the buffer?
              jr    nz,$+44        ; yes!
              ld    a,(0x7836)     ; load character from B1
              cp    d              ; = pressed key?
              jr    nz,$+35        ; no, a new one
              ld    bc,(0x7842)    ; load row/column counter
              ld    hl,(0x7844)    ; load matrix address
              ld    a,e            ; content of matrix row
              call  0x2F35         ; check remaining keys
              cp    d              ; same as before?
              jp    z,0x2FD7       ; yes, for key repeat
              cp    0x00           ; no further one?
              jp    z,0x2FD7       ; yes, for key repeat
              ld    hl,0x7838      ; address Flag 1
              set   3,(hl)         ; set both status bits 3+4
              set   4,(hl)         ; Set bit 4 of (hl)
              res   2,(hl)         ; reset function flag
              ld    (0x7837),a     ; character in B2
              ret                  ; and back
              ld    a,d            ; new key code in A
              jr    $-14           ; enter in B2

; Two keys already registered
              ld    a,(0x7836)     ; load character from B1
              cp    d              ; = new key code?
              jr    z,$+10         ; yes!
              ld    a,(0x7837)     ; load character from B2
              cp    d              ; = new key code?
              jr    z,$+4          ; yes!
              xor   a              ; 3 keys - yuck
              ret                  ; back with A = 0
              ld    bc,(0x7842)    ; load row/column counter
              ld    hl,(0x7844)    ; load matrix address
              ld    a,e            ; load content of matrix row
              call  0x2F35         ; continue searching matrix
              cp    d              ; same key?
              jr    z,$+7          ; yes!
              cp    0x00           ; no further key?
              jp    nz,0x2FD7      ; yes - for key repeat
              ld    hl,0x7838      ; address Flag 1
              set   3,(hl)         ; set status flag for B1
              res   4,(hl)         ; clear status flag for B2
              ld    a,(0x7836)     ; load character from B1
              cp    d              ; = entered character?
              jr    nz,$+7         ; no!
              xor   a              ; clear B2
              ld    (0x7837),a     ; Load (0x7837) from a
              ret                  ; back
              ld    a,(0x7837)     ; transfer B2 to B1
              ld    (0x7836),a     ; Load (0x7836) from a
              jr    $-11           ; clear B2
              set   2,(ix+0x09)    ; Set bit 2 of (ix+0x09)

; BASIC - Initialization Part 1
BASIC_INIT_1:
              nop                  ; starts well
              nop                  ; No operation
              ld    hl,RAM_VECTOR_BLOCK ; ROM 6D2 - 707 into
              ld    de,0x7800      ; RAM 7800 - 7835
              ld    bc,0x0036      ; transfer
              ldir                 ; Execute ldir
              dec   a              ; the whole 128x
              dec   a              ; why ???????
              jr    nz,$-13        ; probably burn-in !!!!!
              ld    b,0x27         ; clear the next 39 bytes
              ld    (de),a         ; (7836 - 785C)
              inc   de             ; Increment de
              djnz  $-2            ; Decrement B and jump if not zero to $-2
              jp    BASIC_INIT_2   ; to BASIC - initialization T. 2

; BASIC - Initialization Part 3
; Check for external ROM cassette
BASIC_INIT_3:
              ld    hl,0x4000      ; 1st possibility at 4000H
              call  ROM_CART_CHECK ; check there
              ld    hl,0x6000      ; 2nd possibility at 6000H
              call  ROM_CART_CHECK ; check
              ld    hl,0x8000      ; 3rd possibility at 8000H
              call  ROM_CART_CHECK ; check
              ei                   ; no insert - interrupts on
              jp    0x1A19         ; to BASIC - main loop

; ROM insert must begin with the byte sequence AA 55 E7 18
ROM_CART_CHECK:
              ld    a,0xAA         ; ROM insert must begin with the
              cp    (hl)           ; byte sequence AA 55 E7 18
              inc   hl             ; next byte
              ret   nz             ; was nothing already
              cpl                  ; form 2nd value (55)
              cp    (hl)           ; equal?
              inc   hl             ; next byte
              ret   nz             ; unequal!
              ld    a,0xE7         ; 3rd value = E7
              cp    (hl)           ; is that correct?
              inc   hl             ; next byte
              ret   nz             ; no, not that either
              cpl                  ; form 4th value (18)
              cp    (hl)           ; is this one correct too?
              inc   hl             ; next byte
              ret   nz             ; no - no insert
              ei                   ; interrupts on
              jp    (hl)           ; jump to ROM insert
              ld    c,0x02         ; Load c from 0x02
              call  0x1A59         ; Call 0x1A59
              call  0x34B8         ; Call 0x34B8
              call  0x18E3         ; Call 0x18E3
              jr    z,$-62         ; Relative jump if z to $-62
              rst   0x28           ; Call restart vector 0x28
              inc   l              ; Increment l
              jr    z,$+22         ; Relative jump if z to $+22
              call  0x34F1         ; Call 0x34F1
              ld    bc,0x1A18      ; load address of main loop
              jp    0x19AE         ; init BASIC variables and pointers.

; The following area from 6D2 to 707 is transferred to the RAM area from 7800 
; to 7835
; Restart Vectors
RAM_VECTOR_BLOCK:
              jp    0x1C96         ; RST 8H (compare 1 character)
              jp    0x1D78         ; RST 10H (next character)
              jp    0x1C90         ; RST 18H (compare HL/DE)
              jp    0x25D9         ; RST 20H (test data type)
              ret                  ; RST 28H
              nop                  ; No operation
              nop                  ; No operation
              ret                  ; RST 30H
              nop                  ; No operation
              nop                  ; No operation
              ei                   ; RST 38H (Interrupt)
              ret                  ; Return
              nop                  ; No operation

; Keyboard - Device Control Block
              DEFB  0x01           ; DCB type
              DEFW  0x2EF4
              DEFB  0x00,0x00,0x00

; Keyboard Name
              DEFM  "KI"           ; Keyboard Name

; Screen - Device Control Block
; not used except for the cursor address.
              DEFB  0x00           ; DCB type (unknown)
              DEFW  0x0000         ; used by SET, RESET and POINT.
              DEFW  0x7000         ; cursor address pointer
              DEFB  0x00,0x00,0x00

; Printer - Device Control Block
              DEFB  0x06           ; DCB type
              DEFW  0x058D         ; driver address
              DEFB  0x43           ; lines/page + 1
              DEFB  0x00           ; line counter
              DEFB  0x00
              DEFM  "PR"           ; Printer Name
              jp    0x5000         ; not used
              rst   0              ; not used
              nop                  ; No operation
              nop                  ; No operation

; Entry for wrong DCB type
              ld    a,0x00         ; entry for wrong DCB type
              ret                  ; in the DCB call routine

; Addition and subtraction with single precision
; Various entry points according to the required function.
FP_ADD_HALF:
              ld    hl,0x1380      ; address of constant 0.5
              call  MOVRM          ; load constant into Y then add to X
              jr    $+8            ; jump to addition
FP_SUB_HALF:
              call  MOVRM          ; load constant into Y
FP_SUB_Y_MINUS_X:
              call  NNEG           ; X = -X
FP_ADD_X_PLUS_Y:
              ld    a,b            ; Y = 0? (Exp. Y = 0)
              or    a              ; Test A
              ret   z              ; yes, done
              ld    a,(FAC)        ; X = 0? (Exp. X = 0)
              or    a              ; Test A
              jp    z,MOVFR        ; yes, done, X=Y
              sub   b              ; Exp. Y <= Exp. X?
              jr    nc,$+14        ; yes
              cpl                  ; negate Exp.Diff
              inc   a              ; exchange X with Y
              ex    de,hl          ; save LSB Y
              call  PUSHF          ; put X on stack
              ex    de,hl          ; restore LSB Y
              call  MOVFR          ; transfer Y to X
              pop   bc             ; load stack to Y
              pop   de             ; Pop de
              cp    0x19           ; Exp.Diff > mantissa (24 bits)
              ret   nc             ; no, X = X, done
              push  af             ; save Exp.Diff.
              call  UNPACK         ; A(7) = 0 if different signs
              ld    h,a            ; save sign flag
              pop   af             ; reload Exp.Difference
              call  SHIFTR         ; shift Y right by this difference
              or    h              ; signs equal?
              ld    hl,FACLO       ; LSB X address in HL
              jp    p,0x0754       ; no, subtract

; Mantissa addition
              call  0x07B7         ; add mantissas
              jp    nc,0x0796      ; overflow? no=jump
              inc   hl             ; pointer to Exp. X
              inc   (hl)           ; Exp. X + 1
              jp    z,0x07B2       ; overflow? yes=OV-Error
              ld    l,0x01         ; shift mantissa of X by 1 bit
              call  0x07EB         ; right
              jr    $+68           ; done!

; Mantissa subtraction
              xor   a              ; Mant. Y - Mant. X to Mant. Y
              sub   b              ; low order byte (created by shifting)
              ld    b,a            ; result
              ld    a,(hl)         ; LSB subtraction
              sbc   a,e            ; Subtract e with carry from a
              ld    e,a            ; Load e from a
              inc   hl             ; next byte
              ld    a,(hl)         ; subtract
              sbc   a,d            ; Subtract d with carry from a
              ld    d,a            ; Load d from a
              inc   hl             ; MSB subtract
              ld    a,(hl)         ; Load a from (hl)
              sbc   a,c            ; Subtract c with carry from a
              ld    c,a            ; underflow?
              call  c,NGER         ; invert sign flag

; Normalize
              ld    l,b            ; res. mant. from CDEB to CDHL
              ld    h,e            ; Load h from e
              xor   a              ; shift counter = 0
              ld    b,a            ; Load b from a
              ld    a,c            ; MSB Y = 0?
              or    a              ; Test A
              jr    nz,$+26        ; no
              ld    c,d            ; shift Y left by 1 byte
              ld    d,h            ; H to D
              ld    h,l            ; L to H
              ld    l,a            ; L = 0
              ld    a,b            ; shift counter - 8
              sub   0x08           ; Subtract 0x08 from A
              cp    0xE0           ; 32 left shifts? (number = 0)
              jr    nz,$-14        ; no!

; Set real value = 0
              xor   a              ; exponent in X = 0
              ld    (FAC),a        ; i.e. X = 0
              ret                  ; Return

; 2nd part of normalization
              dec   b              ; shift counter - 1
              add   hl,hl          ; CDHL one bit left (HL * 2)
              ld    a,d            ; D * 2
              rla                  ; Rotate A left through carry
              ld    d,a            ; Load d from a
              ld    a,c            ; C * 2
              adc   a,a            ; Add a with carry to a
              ld    c,a            ; highest bit of Y set?
              jp    p,0x077D       ; no, continue
              ld    a,b            ; shift counter to A
              ld    e,h            ; CDHL back to CDEB
              ld    b,l            ; Load b from l
              or    a              ; no shift?
              jr    z,$+10         ; yes
              ld    hl,FAC         ; address X exponent
              add   a,(hl)         ; Exp. X + number of shifts
              ld    (hl),a         ; = Exp. X. Underflow?
              jr    nc,$-27        ; yes! X=0 and back
              ret   z              ; number of shifts = Exp. X? back!

; Finalize result: round and copy Y to X
              ld    a,b            ; load LSB Y
              ld    hl,FAC         ; address X exponent
              or    a              ; LSB Y(7) = 0?
              call  m,ROUND        ; no - round Y
              ld    b,(hl)         ; Exp. X to Exp. Y
              inc   hl             ; sign flag
              ld    a,(hl)         ; load
              and   0x80           ; mask out sign
              xor   c              ; link with MSB Y (invert)
              ld    c,a            ; and back to MSB Y
              jp    MOVFR          ; Y to X as result

; Rounding
; ROUND: (defined in symbols.sym)
              inc   e              ; LSB Y + 1
              ret   nz             ; = 0?, no-done
              inc   d              ; next byte Y + 1
              ret   nz             ; = 0?, no-done
              inc   c              ; MSB Y + 1
              ret   nz             ; = 0?, no-done
              ld    c,0x80         ; yes, MSB Y = 80H
              inc   (hl)           ; exponent X + 1
              ret   nz             ; = 0?, no-back

; Overflow error
              ld    e,0x0A         ; error number in E
              jp    0x19A2         ; to error routine

; Single precision mantissa addition
              ld    a,(hl)         ; LSB X in A
              add   a,e            ; + LSB Y
              ld    e,a            ; sum in LSB Y
              inc   hl             ; X address + 1
              ld    a,(hl)         ; add next byte
              adc   a,d            ; Add d with carry to a
              ld    d,a            ; Load d from a
              inc   hl             ; HL = MSB X
              ld    a,(hl)         ; MSB X + MSB Y
              adc   a,c            ; Add c with carry to a
              ld    c,a            ; in MSB Y
              ret                  ; Return

; Negate mantissa Y
; NGER: (defined in symbols.sym)
              ld    hl,0x7925      ; invert sign flag
              ld    a,(hl)         ; Load a from (hl)
              cpl                  ; Complement A
              ld    (hl),a         ; Load (hl) from a
              xor   a              ; A = 0
              ld    l,a            ; L = 0
              sub   b              ; LSB Y = 0 - LSB Y
              ld    b,a            ; Load b from a
              ld    a,l            ; Load a from l
              sbc   a,e            ; next byte Y = 0 - next byte Y
              ld    e,a            ; Load e from a
              ld    a,l            ; Load a from l
              sbc   a,d            ; next byte Y = 0 - next byte Y
              ld    d,a            ; Load d from a
              ld    a,l            ; Load a from l
              sbc   a,c            ; MSB Y = 0 - MSB Y
              ld    c,a            ; Load c from a
              ret   

; SINGLE PRECISION MATH ROUTINE – “SHIFTR”
; This routine will shift the number in C/D/E right the number of times
; held in Register A. The general idea is to shift right 8 places
; as many times as is possible within the number of times in A,
; and then jump out to shift single bits once you can't shift 8
; at a time anymore. Alters everything except Register H.
SHIFTR:
              ld    b,0x00         ; LSB of result = 0
SHIFTR1:
              sub   0x08           ; shift 8 or more places?

; (none)
              jr    c,$+9          ; no!
              ld    b,e            ; shift Y right by one byte
              ld    e,d
              ld    d,c
              ld    c,0x00
              jr    $-9

; SINGLE PRECISION MATH ROUTINE – “SHFTR2”
; This routine will shift the number in C/D/E right the number
; of times held in Register A, but one byte at a time.
SHFTR2:
              add   a,0x09         ; shift count + 1 in L
              ld    l,a
SHFTR3:
              xor   a              ; clear Carry
SHFTR4:
              dec   l              ; shift counter - 1
              ret   z              ; = 0? yes-done
              ld    a,c            ; MSB Y one bit right
              rra   
              ld    c,a
              ld    a,d            ; next byte Y one bit right
              rra   
              ld    d,a
              ld    a,e            ; next byte Y one bit right
              rra   
              ld    e,a
              ld    a,b            ; LSB Y one bit right
              rra   
              ld    b,a
              jr    $-15           ; continue

; SINGLE PRECISION CONSTANT STORAGE LOCATION – “FONE”
FONE:
              DEFB  0x00,0x00,0x00,0x81 ; = 1

; SINGLE PRECISION CONSTANTS STORAGE LOCATION 2 – “LOGCN2”
LOGCN2:
              DEFB  0x03,0xAA,0x56,0x19,0x80,0xF1,0x22,0x76 ; number of constants = 3
              DEFB  0x80,0x45,0xAA,0x38,0x82

; LEVEL II BASIC LOG ROUTINE – “FNLOG”
; Computes the natural log (base E) of the single precision value in
; WRA1. The result is returned as a single precision value in WRA1.
FNLOG:
              call  SIGN           ; argument <= 0?
              or    a              ; if FAC < 0, then an error
              jp    pe,0x1E4A      ; yes, Function-Code Error
              ld    hl,FAC         ; exponent of argument in A
              ld    a,(hl)         ; get exponent
              ld    bc,0x8035      ; Y = 0.707092
              ld    de,0x04F3
              sub   b              ; offset Exp X in A
              push  af             ; save
              ld    (hl),b         ; Exp. X = 0
              push  de             ; Y on stack
              push  bc
              call  FP_ADD_X_PLUS_Y ; X = X + 0.707092
              pop   bc             ; reload Y with constant
              pop   de
              inc   b              ; Exp. Y + 1 (Y = SQR(2))
              call  0x08A2         ; X = SQR(2) / X
              ld    hl,FONE        ; load address of constant 1
              call  FP_SUB_HALF    ; X = 1 - X
              ld    hl,LOGCN2      ; address of 1st series constant
              call  0x149A         ; calculate series
              ld    bc,0x8080      ; Y = -0.5
              ld    de,START
              call  FP_ADD_X_PLUS_Y ; X = X - 0.5
              pop   af             ; exponent of argument
              call  FADD8          ; X = X + A

; SINGLE PRECISION MULTIPLICATION – “FMLT”
MULLN2:
              ld    bc,0x8031      ; Y = LOG(2) approx. 0.693147
              ld    de,0x7218
              call  SIGN           ; X = 0?
FMLT:
              ret   z              ; yes, done
              ld    l,0x00         ; flag for exponent processing
              call  MULDIV         ; process exponents and signs
              ld    a,c            ; mantissa from Y to 794F...
              ld    (0x794F),a     ; MSB
              ex    de,hl          ; LSB
              ld    (0x7950),hl
              ld    bc,START       ; Y = clear result register
              ld    d,b
              ld    e,b
              ld    hl,0x0765      ; different return addresses for
              push  hl             ; 3 passes on stack
              ld    hl,FMLT2       ; to normalization after 3rd pass
              push  hl             ; after 1st and 2nd pass
              push  hl             ; repeat
FMLT1:
              ld    hl,FACLO       ; load LSB X address
FMLT2:
              ld    a,(hl)         ; LSB X in A
              inc   hl             ; address next X-byte
              or    a              ; content = 0?
              jr    z,$+38         ; yes, shift result 1 byte right
              push  hl             ; save address pointer
              ld    l,0x08         ; bit counter = 8
              rra                  ; shift a bit into carry
              ld    h,a            ; save A in H
              ld    a,c            ; load MSB of result
              jr    nc,$+13        ; bit in carry = 1?
              push  hl             ; yes! - save HL
              ld    hl,(0x7950)    ; load LSB of 2nd factor
              add   hl,de          ; + result LSB
              ex    de,hl          ; in LSB Y
              pop   hl             ; reload HL
              ld    a,(0x794F)     ; load MSB of 2nd factor
              adc   a,c            ; + result MSB
              rra                  ; shift result 1 bit right
              ld    c,a            ; MSB
              ld    a,d            ; next byte
              rra   
              ld    d,a
              ld    a,e            ; next byte
              rra   
              ld    e,a
              ld    a,b            ; LSB
              rra   
              ld    b,a
              dec   l              ; bit counter - 1
              ld    a,h            ; reload X-byte
              jr    nz,$-29        ; bit counter = 0, no-back
              pop   hl             ; yes - load X-byte address
              ret                  ; continue
              ld    b,e            ; result 1 byte right. B = E
              ld    e,d            ; E = D
              ld    d,c            ; D = C
              ld    c,a            ; C = 0
              ret   

; SINGLE PRECISION MATH ROUTINE – “FDIV”
FDIV:
              call  PUSHF          ; save value in X on stack
              ld    hl,0x0DD8      ; address constant 10
              call  MOVFM          ; transfer to X
              pop   bc             ; load former X-value into Y
              pop   de

; Single Precision Division
              call  SIGN           ; divisor = 0?
DV0ERR_JMP:
              jp    z,0x199A       ; yes, DIVISION BY ZERO - Error

; X = Y / X
              ld    l,0xFF         ; Flag for exponent processing for division
              call  MULDIV         ; Process exponents and signs
              inc   (hl)           ; Correct exponent result
              inc   (hl)           ; + 2 (0914 = Exp.Y - Exp.X - 1)
              dec   hl             ; HL to MSB X
              ld    a,(hl)         ; X in division subroutine (from 7840H)
              ld    (FDIVA_ARG),a  ; MSB
              dec   hl             ; DEC HL
              ld    a,(hl)         ; Next byte
              ld    (FDIVB_ARG),a
              dec   hl             ; DEC HL
              ld    a,(hl)         ; LSB
              ld    (FDIVC_ARG),a
              ld    b,c            ; Transfer Y to B,H,L (dividend)
              ex    de,hl
              xor   a              ; Y = 0 (for quotient)
              ld    c,a
              ld    d,a
              ld    e,a
              ld    (FDIVG_ARG),a  ; MSB divisor = 0 (for shifting)
FDIV1:
              push  hl             ; Dividend on stack
              push  bc
              ld    a,l            ; Load LSB dividend
              call  FDIVC          ; Dividend - divisor
              sbc   a,0x00         ; MSB dividend = carry, underflow?
              ccf                  ; Complement carry
              jr    nc,$+9         ; yes - restore subtraction, 0 in quotient
              ld    (FDIVG_ARG),a  ; MSB dividend in subroutine
              pop   af             ; Remove dividend from stack
              pop   af
              scf                  ; Set carry flag (1 in quotient)

; to skip following 2 POPs
              DEFB  0xD2           ; JP NC,0E1C1H is never executed.
              pop   bc             ; Get dividend from stack
              pop   hl             ; = undo subtraction
FDIV2:
              ld    a,c            ; MSB of quotient in A
              inc   a              ; Test bit 7
              dec   a
              rra                  ; Last bit for rounding in bit 7
              jp    m,0x0797       ; was bit 7 at INC/DEC=1, yes-done
              rla                  ; Quotient 1 bit to the left
              ld    a,e            ; Result bit (0 or 1) is
              rla                  ; shifted in from carry bit
              ld    e,a
              ld    a,d
              rla   
              ld    d,a
              ld    a,c
              rla   
              ld    c,a
              add   hl,hl          ; Dividend * 2
              ld    a,b
              rla   
              ld    b,a
              ld    a,(FDIVG_ARG)  ; = MSB dividend
              rla   
              ld    (FDIVG_ARG),a
              ld    a,c            ; is the result still 0?
              or    d
              or    e
              jr    nz,$-51        ; no - continue
              push  hl             ; Save dividend LSB
              ld    hl,FAC         ; Address quotient exponent
              dec   (hl)           ; - 1
              pop   hl             ; Reload dividend LSB
              jr    nz,$-59        ; Quotient exp. not equal 0 - continue
              jp    0x07B2         ; Exponent = 0, OVERFLOW - Error

; 0907H-0913H – DOUBLE PRECISION MATH ROUTINE – “MULDVS”
; This routine is to check for special cases and to add exponents for
; the FMULT and FDIV routines. Registers A, B, H and L are modified.
MULDVS:
              ld    a,0xFF         ; Set flag for division
MULDVA_SKIP:
              ld    l,0xAF         ; LD L,0AFH to skip the XOR
MULDVA:
              ld    hl,ARG         ; Address MSB Y
              ld    c,(hl)         ; Sign Y in C
              inc   hl             ; HL to exponent X
              xor   (hl)           ; Combine with sign flag
              ld    b,a            ; Mult: B=Exp.Y Div: B=-Exp.Y-1
              ld    l,0x00         ; Flag in L = 0

; Entry point: Multiplication, single precision (L=0)
MULDV:
              ld    a,b            ; Exponent Y loaded
              or    a              ; 0? (i.e. Y = 0)
              jr    z,$+33         ; yes, return to main program immediately
              ld    a,l            ; Load flag
              ld    hl,FAC         ; Address Exp. X
              xor   (hl)           ; Combine with flag
              add   a,b            ; + Exponent Y
              ld    b,a            ; Sum after Exponent Y
              rra                  ; Over- or underflow?
              xor   b              ; XOR B
              ld    a,b            ; Load new Exponent Y
; MULDV1_INTERNAL: (defined in symbols.sym)
              jp    p,MULDV1       ; Under-/overflow
              add   a,0x80         ; Add offset
              ld    (hl),a         ; and save as new exponent X.
POPHRT:
              jp    z,0x0890       ; = 0? yes-to main program back
              call  UNPACK         ; Process sign
              ld    (hl),a         ; in temporary storage
DCXHRT:
              dec   hl             ; Address exponent X
              ret   

; Exponents over-/underflow
MLDVEX:
              call  SIGN           ; Test signs of X
              cpl                  ; Complement result
              pop   hl             ; Remove return address from stack
; MULDV1: (defined in symbols.sym)
              or    a              ; Was it an underflow?
; MULDV2: (defined in symbols.sym)
              pop   hl             ; One more return address from stack
              jp    p,FA_ZERO      ; Underflow, X=0, RET
              jp    0x07B2         ; OVERFLOW-Error

; Single Precision Multiplication by 10
MUL10:
              call  MOVRF          ; Transfer X to Y
              ld    a,b            ; Value = 0? (Exp.Y=0)
              or    a
              ret   z              ; yes, done
              add   a,0x02         ; Exp. Y + 2, i.e. Y = Value * 4
              jp    c,0x07B2       ; at overflow OVERFLOW-Error
              ld    b,a            ; Exponent back in Y
              call  FP_ADD_X_PLUS_Y ; X = X + Y, i.e. X = Value * 5
              ld    hl,FAC         ; Exponent X + 1
              inc   (hl)           ; i.e. X = Value * 10
              ret   nz             ; Overflow? no-back
              jp    0x07B2         ; yes - OVERFLOW-Error

; Test a real number
SIGN:
              ld    a,(FAC)        ; Load Exponent X
              or    a              ; = 0? (X = 0)
              ret   z
              ld    a,(FAC_SIGN)   ; Load MSB X
              cp    0x2F           ; CP 2F - Dummy instruction, elim. CPL
ICOMPS:
              rla                  ; Shift sign X into Carry
SIGNS:
              sbc   a,a            ; A = 0 - Carry
              ret   nz             ; X > 0? no - finished
              inc   a              ; yes, set A = 1
              ret   

; 8-bit signed integer to single precision conversion
FLOAT:
              ld    b,0x88         ; Exponent of result in B
              ld    de,START       ; Clear for normalization

; Separate entry point
; FLOATR: (defined in symbols.sym)
              ld    hl,FAC         ; Address exponent in X
              ld    c,a            ; Number to convert in C
              ld    (hl),b         ; Exponent to X
              ld    b,0x00         ; B=0 for normalization
              inc   hl             ; Address MSB in X
              ld    (hl),0x80      ; Sign = '-'
              rla                  ; Sign of converted number into carry
              jp    0x0762         ; to normalization

; LEVEL II BASIC ABS() ROUTINE – “FNABS”
; Computes the absolute value of the FAC. The result is returned
; as a single precision value in the FAC.
FNABS:
              call  VSIGN          ; X > 0?
              ret   p              ; yes, done

; Invert number in FAC X
VNEG:
              rst   0x20           ; Test type of FAC X
              jp    m,INEG_B       ; integer? yes - continue at 0x0C5B
              jp    z,TMERR        ; string? yes - TYPE MISMATCH Error

; Invert real number in FAC X
; NNEG: (defined in symbols.sym)
              ld    hl,FAC_SIGN    ; Address MSB of FAC X
              ld    a,(hl)         ; and load
              xor   0x80           ; Invert sign bit
              ld    (hl),a         ; write MSB back to FAC X
              ret   

; SGN function
FNSGN:
              call  VSIGN          ; Test FAC X

; Convert A to 16-bit signed integer
CONIA:
              ld    l,a            ; Number in L
              rla                  ; Number < 0?
              sbc   a,a            ; yes, -1 in A and H
              ld    h,a            ; no, 0 in A and H
              jp    MAKINT         ; Transfer HL to FAC X

; Test all numeric types
VSIGN:
              rst   0x20           ; Test type
              jp    z,TMERR        ; String? yes - TYPE MISMATCH Error
              jp    p,SIGN         ; Single or double precision

; Test integer number
ISIGNA:
              ld    hl,(FACLO)     ; Integer number in HL

; 099EH - MATH COMPARE ROUTINE - INTEGER SIGN (HL)
; Finds the sign of the value held at (HL). Only Register A is altered.
ISIGN:
              ld    a,h            ; is it 0?
              or    l
              ret   z              ; yes - done
              ld    a,h            ; no - MSB in A
              jr    $-67           ; continue at 0x095F

; Transport numbers of different types
; From FAC X to stack (single precision)
PUSHF:
              ex    de,hl          ; Save HL in DE
              ld    hl,(FACLO)     ; LSB of FAC X in HL
              ex    (sp),hl        ; swap RET address with HL on stack
              push  hl             ; push RET address back on stack
              ld    hl,(FAC_SIGN)  ; MSB X + Exp X in HL
              ex    (sp),hl        ; swap RET address with HL on stack
              push  hl             ; push RET address back on stack
              ex    de,hl          ; Restore content of HL
              ret   

; Transfer single precision number from RAM to FAC X
MOVFM:
              call  MOVRM          ; Transfer number to FAC Y

; Transfer single precision number from FAC Y to FAC X
MOVFR:
              ex    de,hl          ; LSB Y in HL, save HL in DE
              ld    (FACLO),hl     ; Transfer HL to LSB Y
              ld    h,b            ; MSB Y + Exp Y in HL
              ld    l,c
              ld    (FAC_SIGN),hl  ; Store as MSB X and Exp X
              ex    de,hl          ; Restore content of HL
              ret   

; Transfer single precision number from FAC X to FAC Y
MOVRF:
              ld    hl,FACLO       ; Address LSB of FAC X
MOVRM:
              ld    e,(hl)         ; Load LSB
              inc   hl             ; Next byte
GETBCD:
              ld    d,(hl)         ; Load byte
              inc   hl             ; Next byte
              ld    c,(hl)         ; Load byte
              inc   hl             ; Load Exp
              ld    b,(hl)
INXHRT:
              inc   hl             ; HL behind the number
              ret   

; Transfer single precision number from FAC X to RAM
MOVMF:
              ld    de,FACLO       ; X-address in DE
              ld    b,0x04         ; Number of bytes for single precision
              jr    $+7            ; continue at 0x09D7

; Transfer any type from (HL) to (DE)
MOVVFM:
              ex    de,hl          ; Swap destination and source address

; Transfer any type from (DE) to (HL)
VMOVE:
              ld    a,(VALTYP)     ; Load type of the number
VMOVEA:
              ld    b,a            ; serves as byte counter
MOVE1:
              ld    a,(de)         ; Load byte
              ld    (hl),a         ; and transfer to new area
              inc   de             ; Addresses + 1
              inc   hl
              dec   b              ; Counter - 1
              jr    nz,$-5         ; > 0? yes - back
              ret                  ; done

; Processing of signs for real numbers
UNPACK:
              ld    hl,FAC_SIGN    ; Address MSB of FAC X
              ld    a,(hl)         ; and load into A
              rlca                 ; Sign in bit 0 of A
              scf                  ; Set Carry = 1
              rra                  ; Sign in Carry, MSB X(7) = 1
              ld    (hl),a         ; back to MSB of FAC X
              ccf                  ; Complement sign
              rra                  ; and into A(7)
              inc   hl             ; Address HL to sign flag
              inc   hl
              ld    (hl),a         ; store complemented sign
              ld    a,c            ; MSB Y in A
              rlca                 ; Sign of FAC Y in bit 0 of A
              scf                  ; Set Carry = 1
              rra                  ; MSB Y(7) = 1, sign Y in Carry
              ld    c,a            ; MSB Y back
              rra                  ; Sign in A(7)
              xor   (hl)           ; Combine with complemented MSB X
              ret   

; Transfer any type from FAC Y to FAC X
; VMOVFA: (defined in symbols.sym)
              ld    hl,FAC2        ; FAC Y address in HL
; VMOVFM: (defined in symbols.sym)
              ld    de,MOVVFM      ; Address of transport routine
              jr    $+8

; Transfer any type from FAC X to FAC Y
; VMOVAF: (defined in symbols.sym)
              ld    hl,FAC2        ; FAC Y address in HL
              ld    de,VMOVE       ; Address of transport routine
              push  de             ; Transport routine address on stack

; Determine address of FAC X depending on type
; VDFACS: (defined in symbols.sym)
              ld    de,FACLO       ; X-address for Integer, Strings and single precision
              rst   0x20           ; Test type
              ret   c              ; Double precision? no - done
              ld    de,0x791D      ; X-address for double precision
              ret                  ; done

; Comparison routines
; Comparison of single precision numbers
; FCOMP: (defined in symbols.sym)
              ld    a,b            ; FAC Y = 0?
              or    a
              jp    z,SIGN         ; yes - test FAC X and back
              ld    hl,0x095E      ; Address of test routine on stack
              push  hl             ; push address
              call  SIGN           ; FAC X = 0?
              ld    a,c            ; MSB FAC Y in A
              ret   z              ; yes - sign of FAC Y = result
              ld    hl,FAC_SIGN    ; Load address of MSB FAC X
              xor   (hl)           ; Sign FAC X = Sign FAC Y?
              ld    a,c            ; MSB FAC Y in A
              ret   m              ; no, -sign of FAC Y = result
; FCOMP_SAME_SIGN: (defined in symbols.sym)
              call  FCOMP2_CORE    ; Comparison for same signs

; Internal
; FCOMPD: (defined in symbols.sym)
              rra                  ; Carry in bit 7 of A
              xor   c              ; if FAC Y negative, invert A(7)
              ret                  ; done
; FCOMP2_CORE: (defined in symbols.sym)
              inc   hl             ; Address of FAC X exponent in HL
              ld    a,b            ; Load FAC Y exponent

; Comparison for same signs
; FCOMP2: (defined in symbols.sym)
              cp    (hl)           ; Exponents equal, check mantissa
              ret   nz             ; Exponents not equal
              dec   hl             ; Address MSB
              ld    a,c            ; MSB of Y
              cp    (hl)           ; compare with MSB of X
              ret   nz             ; different? yes - done
              dec   hl             ; Address middle byte
              ld    a,d            ; Middle byte of Y
              cp    (hl)           ; compare with middle byte of X
              ret   nz             ; different? yes - done
              dec   hl             ; Address LSB
              ld    a,e            ; LSB of Y
              sub   (hl)           ; compare with LSB of X
              ret   nz             ; different? yes - done
              pop   hl             ; Balance stack
              pop   hl             ; Balance stack
              ret                  ; done

; Comparison of integers
; DCOMP: (defined in symbols.sym)
              ld    a,d            ; MSB of first integer
              xor   h              ; Signs equal?
              ld    a,h            ; Restore MSB
              jp    m,ICOMPS       ; no, result determined by sign
              cp    d              ; MSB of second integer
              jp    nz,SIGNS       ; different? yes - done
              ld    a,l            ; LSB of first integer
              sub   e              ; compare with LSB of second integer
              jp    nz,SIGNS       ; different? yes - done
              ret                  ; done

; Comparison of double precision numbers
              ld    hl,FAC2        ; Address FAC2
              call  VMOVE          ; Transfer to FAC2

; Internal
              ld    de,ARG_EXP     ; Address ARG_EXP
              ld    a,(de)         ; Load exponent
              or    a              ; Zero?
              jp    z,SIGN         ; yes, sign of X determines result
              ld    hl,0x095E      ; Address of result routine
              push  hl             ; onto stack
              call  SIGN           ; Test FAC X
              dec   de             ; Address ARG_SIGN
              ld    a,(de)         ; Load sign
              ld    c,a            ; Save sign
              ret   z              ; Zero? yes - done
              ld    hl,FAC_SIGN    ; Address FAC_SIGN
              xor   (hl)           ; Signs equal?
              ld    a,c            ; Restore sign of Y
              ret   m              ; no, sign of Y determines result
              inc   de             ; Address MSB of Y
              inc   hl             ; Address MSB of X
              ld    b,0x08         ; 8 bytes for double precision
              ld    a,(de)         ; Load byte from Y
              sub   (hl)           ; compare with byte from X
              jp    nz,FCOMPD      ; different? yes - done
              dec   de             ; Address next byte
              dec   hl             ; Address next byte
              dec   b              ; Decrement counter
              jr    nz,$-8         ; more? yes - back
              pop   bc             ; Balance stack
              ret                  ; done

; Comparison of X and Y
              call  XDCOMP         ; Compare X and Y
              jp    nz,0x095E      ; different? yes - done
              ret                  ; done

; Convert to integer
; FRCINT: (defined in symbols.sym)
              rst   0x20           ; Test type
              ld    hl,(FACLO)     ; Load integer from FACLO
              ret   m              ; Integer? yes - done
              jp    z,TMERR        ; String? yes - error
              call  nc,CONSD       ; Double precision? yes - convert to single
              ld    hl,0x07B2      ; Address of OVERFLOW Error
              push  hl             ; onto stack
              ld    a,(FAC)        ; FAC exponent
              cp    0x90           ; > 16 bits?
              jr    nc,$+16        ; yes - check if -32768
              call  DROUND         ; Convert to integer
              ex    de,hl          ; HL = integer
              pop   de             ; Balance stack

; Transfer HL to FAC X and set type to integer
; MAKINT: (defined in symbols.sym)
              ld    (FACLO),hl     ; Store in FACLO
              ld    a,0x02         ; Type = Integer
              ld    (VALTYP),a     ; Store in VALTYP
              ret                  ; done

; Test for -32768
; INT: (defined in symbols.sym)
              ld    bc,0x9080      ; -32768 in floating point
              ld    de,START       ; more bytes
              call  FCOMP          ; Compare with FAC X
              ret   nz             ; not -32768? yes - back (OVERFLOW)
              ld    h,c            ; H = 0x80
              ld    l,d            ; L = 0x00
              jr    $-22           ; continue at MAKINT

; Force single precision
              rst   0x20           ; Test type
              ret   po             ; Single precision? yes - done
              jp    m,INEG         ; Integer? yes - convert
              jp    z,TMERR        ; String? yes - error
              call  MOVRF          ; Transfer FAC X to FAC Y
              call  VALSNG         ; Set type to single
              ld    a,b            ; Exponent in A
              or    a              ; Zero?
              ret   z              ; yes - done
              call  UNPACK         ; Prepare for rounding
              ld    hl,0x7920      ; FACLO - 1
              ld    b,(hl)         ; chopped byte
              jp    0x0796         ; round

; Convert integer to single precision
; INEG: (defined in symbols.sym)
              ld    hl,(FACLO)     ; Load integer from FACLO
              call  VALSNG         ; Set type to single
              ld    a,h            ; H in A
              ld    d,l            ; L in D
              ld    e,0x00         ; E = 0
              ld    b,0x90         ; Exponent for 16-bit integer
              jp    FLOATR         ; Normalize

; Force double precision
              rst   0x20           ; Test type
              ret   nc             ; Double precision? yes - done
              jp    z,TMERR        ; String? yes - error
              call  m,INEG         ; Integer? yes - convert to single first
              ld    hl,START       ; zero
              ld    (0x791D),hl    ; clear low bytes
              ld    (0x791F),hl    ; clear low bytes
              ld    a,0x08         ; Type = Double
              ld    bc,0x043E      ; Skip VALSNG (ld bc, 0x043E)
              jp    CONISD         ; Store in VALTYP

; Ensure string type
              rst   0x20           ; Test type
              ret   z              ; String? yes - done

; TYPE MISMATCH Error
; TMERR: (defined in symbols.sym)
              ld    e,0x18         ; Error code
              jp    0x19A2         ; Display error

; Quick integer conversion / Rounding
; DROUND: (defined in symbols.sym)
              ld    b,a            ; A in B
              ld    c,a            ; A in C
              ld    d,a            ; A in D
              ld    e,a            ; A in E
              or    a              ; A = 0?
              ret   z              ; yes - done

; SINGLE PRECISION MATH ROUTINE – “QINT”
; This routine is a quick “Greatest Integer” function.
; The result of INT(FAC X) is left in BC:DE as a signed number.
; QINT: (defined in symbols.sym)
              push  hl             ; Save HL
              call  MOVRF          ; Get SINGLE in FAC X into BC:DE
              call  UNPACK         ; Unpack FAC X
              xor   (hl)           ; XOR with MSB of FAC X (sign bit)
              ld    h,a            ; Save result in H
              call  m,QINTA        ; If negative, decrement DE (adjust for INT of negative)
              ld    a,0x98         ; Load A with maximum exponent (0x98)
              sub   b              ; Subtract exponent of FAC X
              call  SHIFTR         ; Shift BC:DE right by A times
              ld    a,h            ; Load A with H (stored sign bit)
              rla                  ; Shift sign into carry
              call  c,ROUND        ; If negative, round
              ld    b,0x00         ; B = 0
              call  c,NGER         ; If negative, negate
              pop   hl             ; Restore HL
              ret                  ; Done
; QINTA: (defined in symbols.sym)
              dec   de             ; Decrement DE
              ld    a,d            ; Check if DE became 0xFFFF
              and   e              ; AND D with E
              inc   a              ; Increment A
              ret   nz             ; If not zero, return
              dec   bc             ; Decrement BC
              ret                  ; Done

; SINGLE PRECISION MATH ROUTINE – “FSUB”
; Subtract the single precision value in (BC:DE) from the single
; precision value in FAC X. The difference is left in FAC X.
; FSUB: (defined in symbols.sym)
              rst   0x20           ; Check current number type
              ret   m              ; Return if Double Precision
              call  SIGN           ; Get sign of FAC X
              jp    p,FNINT        ; If positive, proceed to addition
              call  NNEG           ; Negate FAC X
              call  FNINT          ; Call addition
              jp    VNEG           ; Negate result and return

; LEVEL II BASIC INT() ROUTINE – “FNINT”
; Returns the integer portion of a floating point number.
; If the value is positive, the integer portion is returned.
; If negative with a fractional part, it is rounded up before truncation.
; FNINT: (defined in symbols.sym)
              rst   0x20           ; Check current number type
              ret   m              ; Already integer? Return
              jr    nc,$+32        ; If double, go to DINT
              jr    z,$-69         ; If string, Type Mismatch error
              call  CONIS          ; Check if fits in integer
              ld    hl,FAC         ; FAC address
              ld    a,(hl)         ; Get exponent
              cp    0x98           ; Test for fractional bits
              ld    a,(FACLO)      ; FACLO
              ret   nc             ; Return if no fractional bits
              ld    a,(hl)         ; Get exponent
              call  DROUND         ; Convert to integer
              ld    (hl),0x98      ; Set exponent to 0x98
              ld    a,e            ; E to A
              push  af             ; Save AF
              ld    a,c            ; C to A
              rla                  ; Rotate
              call  0x0762         ; Float the integer
              pop   af             ; Restore AF
              ret                  ; Done

; DOUBLE PRECISION INT() ROUTINE – “DINT”
; Double precision INT routine. Works by adding 0.5 and truncating.
; DINT: (defined in symbols.sym)
              ld    hl,FAC         ; Address of FAC
              ld    a,(hl)         ; Get exponent
              cp    0x90           ; Compare with 0x90
              jp    c,FRCINT       ; If < 0x90, force integer
              jr    nz,$+22        ; If zero, done
              ld    c,a            ; A to C
              dec   hl             ; HL to FAC MSB
              ld    a,(hl)         ; Get byte
              xor   0x80           ; XOR 0x80
              ld    b,0x06         ; B = 6 (mantissa bytes)
              dec   hl             ; HL-1
              or    (hl)           ; OR with (HL)
              dec   b              ; Decrement B
              jr    nz,$-3         ; Loop
              or    a              ; OR A
              ld    hl,0x8000      ; LD HL, 0x8000
              jp    z,MAKINT       ; Jump to MAKINT
              ld    a,c            ; A = C
              cp    0xB8           ; Compare with 0xB8
              ret   nc             ; Done if NC
              push  af             ; Save A
              call  MOVRF          ; Move FAC X to Y
              call  UNPACK         ; Unpack FAC X
              xor   (hl)           ; XOR (HL)
              dec   hl             ; HL-1
              ld    (hl),0xB8      ; LD (HL), 0xB8
              push  af             ; Save AF
              call  m,DINT_NEG     ; Call m, DINT_NEG
              ld    hl,FAC_SIGN    ; HL to FAC sign
              ld    a,0xB8         ; A = 0xB8
              sub   b              ; Subtract exponent
              call  DSHFTR         ; Shift right
              pop   af             ; Restore AF
              call  m,DROUNA       ; Call m, 0x0D20
              xor   a              ; XOR A
              ld    (0x791C),a     ; Store A at 0x791C
              pop   af             ; Restore AF
              ret   nc             ; Done if NC
              jp    DNORML         ; Jump to 0x0CD8
; DINT_NEG: (defined in symbols.sym)
              ld    hl,0x791D      ; LD HL, FAC-7
              ld    a,(hl)         ; Get byte
              dec   (hl)           ; Decrement (HL)
              or    a              ; OR A
              inc   hl             ; HL+1
              jr    z,$-4          ; Loop if zero
              ret                  ; Done

; INTEGER MULTIPLY ROUTINE – “UMULT”
; UMULT: (defined in symbols.sym)
              push  hl             ; Save HL
              ld    hl,START       ; HL = 0
              ld    a,b            ; A = B
              or    c              ; OR C
              jr    z,$+20         ; If zero, done
              ld    a,0x10         ; A = 16 bits
              add   hl,hl          ; HL = HL * 2
              jp    c,0x273D       ; Overflow? BS ERROR
              ex    de,hl          ; EX DE, HL
              add   hl,hl          ; HL = HL * 2
              ex    de,hl          ; EX DE, HL
              jr    nc,$+6         ; If no carry, skip addition
              add   hl,bc          ; HL = HL + BC
              jp    c,0x273D       ; Overflow? BS ERROR
              dec   a              ; Decrement bit counter
              jr    nz,$-14        ; Loop
              ex    de,hl          ; Result to DE
              pop   hl             ; Restore HL
              ret                  ; Done

; INTEGER SUBTRACTION – “ISUB”
; ISUB: (defined in symbols.sym)
              ld    a,h            ; A = H
              rla                  ; Sign to carry
              sbc   a,a            ; A = 0x00 or 0xFF
              ld    b,a            ; B = A
              call  INEGHL         ; Prepare DE for subtraction
              ld    a,c            ; A = C
              sbc   a,b            ; SBC A, B
              jr    $+5            ; Skip next instruction

; INTEGER ADDITION – “IADD”
; IADD: (defined in symbols.sym)
              ld    a,h            ; A = H
              rla                  ; Sign to carry
              sbc   a,a            ; A = 0x00 or 0xFF
              ld    b,a            ; B = A
              push  hl             ; Save HL
              ld    a,d            ; A = D
              rla                  ; Sign to carry
              sbc   a,a            ; A = 0x00 or 0xFF
              add   hl,de          ; HL = HL + DE
              adc   a,b            ; ADC A, B
              rrca                 ; Rotate
              xor   h              ; Check for overflow
              jp    p,0x0A99       ; Jump if no overflow

; INTEGER DIVISION – “IDIV”
; IDIV: (defined in symbols.sym)
              push  bc             ; Save BC
              ex    de,hl          ; EX DE, HL
              call  0x0ACF         ; Division core
              pop   af             ; Restore AF
              pop   hl             ; Restore HL
              call  PUSHF          ; Check signs
              ex    de,hl          ; EX DE, HL
              call  0x0C6B         ; Negate DE if needed
              jp    0x0F8F         ; Done

; INTEGER DIVISION FOR ARRAYS – “IDIV2”
; IDIV2: (defined in symbols.sym)
              ld    a,h            ; A = H
              or    l              ; OR L
              jp    z,MAKINT       ; If zero, result 0
              push  hl             ; Save HL
              push  de             ; Save DE
              call  IMULDV         ; Division core
              push  bc             ; Save BC
              ld    b,h            ; B = H
              ld    c,l            ; C = L
              ld    hl,START       ; HL = 0
              ld    a,0x10         ; A = 16 bits
              add   hl,hl          ; HL = HL * 2
IMULT_OVERFLOW_CHECK:
              jr    c,$+33         ; on overflow, special routine
              ex    de,hl          ; 1st factor * 2
              add   hl,hl
              ex    de,hl
IMULT_NEXT:
              jr    nc,$+6         ; no, no addition
              add   hl,bc          ; yes, result + 2nd factor
              jp    c,IMULT_OVERFLOW ; on overflow, special routine
IMULT_LOOP_END:
              dec   a              ; Counter - 1
              jr    nz,$-13        ; not 0, next pass
              pop   bc             ; load sign flag
              pop   de             ; get 1st factor from stack
              ld    a,h            ; Result > 32767 ?
              or    a
              jp    m,IMULT_NEG    ; yes, overflow!
              pop   de             ; get 2nd factor from stack
              ld    a,b            ; result with sign flag
              jp    INEGA          ; correct

; Handle negative integer multiplication result
; IMULT_NEG: (defined in symbols.sym)
              xor   0x80           ; Result = 32768 ?
              or    l
              jr    z,$+21         ; yes!
              ex    de,hl          ; 1st factor in HL
IMULT_LD_BC_TRICK:
              DEFB  0x01           ; Dummy instruction
IMULT_OVERFLOW:
              pop   bc             ; load sign flag
              pop   hl             ; load 1st factor in HL
              call  0x0ACF         ; 1st factor to single precision in X
              pop   hl             ; get 2nd factor from stack
              call  PUSHF          ; 1st factor from X to stack
              call  0x0ACF         ; 2nd factor to single precision in X
              pop   bc             ; 1st factor from stack to Y
              pop   de
              jp    0x0847         ; X = Y * X
IMULT_CHECK_SIGN:
              ld    a,b            ; sign flag in A
              or    a              ; result should be negative
              pop   bc             ; clean up stack
              jp    m,MAKINT       ; is negative, HL (-32768) in X
              push  de             ; 1st factor on stack
              call  0x0ACF         ; HL (-32768) to single precision in X
              pop   de             ; load 1st factor again
              jp    NNEG           ; complement X, done

; Integer division/multiplication support
; IMULDV: (defined in symbols.sym)
              ld    a,h            ; if signs equal,
              xor   d              ; B(7)=0, if different B(7)=1
              ld    b,a
; INEGH: (defined in symbols.sym)
              call  INEGH2         ; form absolute values
              ex    de,hl
INEGH2:
              ld    a,h            ; sign negative?
INEGA:
              or    a              ; Is HL positive?
              jp    p,MAKINT       ; no, HL in X, done

; Negate HL register pair
; INEGHL: (defined in symbols.sym)
              xor   a              ; A = 0
              ld    c,a            ; C = 0
              sub   l              ; 0 - L in L
              ld    l,a
              ld    a,c            ; A = 0
              sbc   a,h            ; 0 - H in H
              ld    h,a
              jp    MAKINT         ; transfer HL to X

; Integer negation of FACLO
; INEG_B: (defined in symbols.sym)
              ld    hl,(FACLO)     ; transfer argument to HL
              call  INEGHL         ; 0 - argument in HL and X
              ld    a,h            ; HL = 32768 ?
              xor   0x80
              or    l
              ret   nz             ; no, done!
INEG_OVERFLOW:
              ex    de,hl          ; yes, convert HL to single precision
              call  VALSNG         ; set type = single precision
              xor   a
              ld    b,0x98         ; set exponent = 152 (0x98)
              jp    FLOATR         ; continue at 0969H

; Double Precision Subtraction (FAC = FAC - ARG)
; DSUB: (defined in symbols.sym)
              ld    hl,ARG         ; address MSB Y
              ld    a,(hl)         ; invert sign Y
              xor   0x80
              ld    (hl),a

; Double Precision Addition (FAC = FAC + ARG)
; DADD: (defined in symbols.sym)
              ld    hl,ARG_EXP     ; address exponent Y
              ld    a,(hl)         ; Y = 0 ?
              or    a
              ret   z              ; yes, X = result
              ld    b,a            ; exponent Y in B
              dec   hl             ; address MSB Y
              ld    c,(hl)         ; sign Y in C
              ld    de,FAC         ; address exponent X
              ld    a,(de)
              or    a              ; X = 0 ?
              jp    z,VMOVFA       ; yes, Y to X as result
              sub   b              ; exponent X >= exponent Y ?
DADD_SWAP:
              jr    nc,$+24        ; yes
              cpl                  ; no, invert exponent diff.
              inc   a
              push  af             ; and save on stack
              ld    c,0x08         ; byte counter
              inc   hl             ; address exponent Y
              push  hl             ; and on stack
DADD_SWAP_LOOP:
              ld    a,(de)         ; exchange 1 byte
              ld    b,(hl)
              ld    (hl),a
              ld    a,b
              ld    (de),a
              dec   de             ; address pointer - 1
              dec   hl
              dec   c              ; done ?
              jr    nz,$-8         ; no, next byte
              pop   hl
              ld    b,(hl)         ; exponent Y in B
              dec   hl             ; address MSB Y in HL
              ld    c,(hl)         ; MSB Y in C
              pop   af             ; load exponent diff.
DADD_CHECK_EXP:
              cp    0x39           ; >= mantissa length + 1 ?
              ret   nc             ; yes, done!
              push  af             ; exponent diff. on stack
              call  UNPACK         ; remove sign bits, form sign flag of result
              inc   hl             ; extra byte for right shift
              ld    (hl),0x00      ; clear (7926H)
              ld    b,a            ; sign flag in B
              pop   af             ; load exponent diff. (shift counter)
              ld    hl,ARG         ; address MSB Y
              call  DSHFTR         ; shift Y right
              ld    a,(0x7926)     ; shifted out byte
              ld    (0x791C),a     ; transfer to X
              ld    a,b            ; both signs equal ?
              or    a
DADD_POS:
              jp    p,DADD_ADD     ; if different signs, subtraction
              call  DADDAA         ; if same signs, addition
              jp    nc,DROUND_DP   ; no overflow, to end
              ex    de,hl          ; HL = address exponent X
              inc   (hl)           ; exponent X + 1, overflow ?
              jp    z,0x07B2       ; yes, OVERFLOW - error
              call  DXSHFT         ; shift mantissa 1 bit right
              jp    DROUND_DP      ; continue at 0D0EH

; Add mantissas
DADD_ADD:
              call  DADDAS         ; mantissa subtraction
              ld    hl,0x7925      ; address sign flag
              call  c,DNEGR        ; underflow ? yes, complement mantissa X

; Double Precision Normalization
; DNORML: (defined in symbols.sym)
              xor   a              ; shift counter = 0
DNORM_LOOP:
              ld    b,a
              ld    a,(FAC_SIGN)   ; load MSB X
              or    a              ; = 0 ?
              jr    nz,$+32        ; no !
DNORM_SHIFT_8:
              ld    hl,0x791C      ; yes, shift X left by 1 byte
              ld    c,0x08         ; byte counter
DNORM_SHIFT_LOOP:
              ld    d,(hl)         ; load byte
              ld    (hl),a         ; last byte at this position
              ld    a,d
              inc   hl             ; increment address
              dec   c              ; done ?
              jr    nz,$-5         ; no, continue
              ld    a,b            ; shift counter - 8
              sub   0x08
              cp    0xC0           ; 40 shifts? (X = 0)
              jr    nz,$-24        ; no, continue
              jp    FA_ZERO        ; yes, X = 0, done!
DNORM_BIT_LOOP:
              dec   b              ; shifts - 1
              ld    hl,0x791C      ; address LSB X
              call  DLSHFT         ; shift X left 1 bit
              or    a              ; highest bit set?
              jp    p,DNORM_BIT_LOOP ; no, continue
              ld    a,b            ; number of shifts = 0 ?
              or    a              ; A = 0 ?
              jr    z,$+11         ; yes, to the end
              ld    hl,FAC         ; address exponent X
              add   a,(hl)         ; new exponent = old exponent + number of shifts
              ld    (hl),a         ; back to X
              jp    nc,FA_ZERO     ; underflow? yes, X=0, done
              ret   z              ; X = 0? yes, done!
              ld    a,(0x791C)     ; highest bit of LSB X = 0?
              or    a              ; test A
              call  m,DROUNA       ; no, round X
              ld    hl,0x7925      ; address sign flag
              ld    a,(hl)         ; load and sign
              and   0x80           ; mask out
              dec   hl             ; address MSB X load
              dec   hl
              xor   (hl)           ; invert sign and combine with MSB X
              ld    (hl),a         ; MSB back to X
              ret   

; Rounding
              ld    hl,0x791D      ; load address LSB X
              ld    b,0x07         ; mantissa length = 7 bytes
              inc   (hl)           ; byte content + 1, overflow?
              ret   nz             ; no, done
              inc   hl             ; yes, next byte
              dec   b              ; all mantissa bytes?
              jr    nz,$-4         ; no, continue
              inc   (hl)           ; carry through whole mantissa?
              jp    z,0x07B2       ; yes, OVERFLOW - Error
              dec   hl             ; set MSB X = 80H
              ld    (hl),0x80
              ret   

; Double Precision Mantissa Addition
              ld    hl,FAC2        ; address LSB Y
              ld    de,0x791D      ; address LSB X
              ld    c,0x07         ; counter = 7 bytes
              xor   a              ; clear carry
              ld    a,(de)         ; load byte from X
              adc   a,(hl)         ; add byte from Y
              ld    (de),a         ; save sum in X
              inc   de             ; increase address pointers
              inc   hl
              dec   c              ; done?
              jr    nz,$-6         ; no, continue
              ret   

; Double Precision Mantissa Subtraction
              ld    hl,FAC2        ; address LSB Y
              ld    de,0x791D      ; address LSB X
              ld    c,0x07         ; counter as counter
              xor   a              ; clear carry
              ld    a,(de)         ; load byte from X
              sbc   a,(hl)         ; subtract byte from Y
              ld    (de),a         ; difference in X save
              inc   de             ; address pointer + 1
              inc   hl
              dec   c              ; done?
              jr    nz,$-6         ; no, continue
              ret   

; DOUBLE PRECISION MATH ROUTINE - \
              ld    a,(hl)         ; complement sign flag
              cpl   
              ld    (hl),a
              ld    hl,0x791C      ; Address of X LSB
              ld    b,0x08         ; Byte counter = 8
              xor   a              ; Clear carry
              ld    c,a            ; C = 0
              ld    a,c            ; A = 0
              sbc   a,(hl)         ; Subtract byte from 0
              ld    (hl),a         ; and store back
              inc   hl             ; Address pointer + 1
              dec   b              ; Done?
              jr    nz,$-5         ; No, continue
              ret   

; DOUBLE PRECISION MATH ROUTINE - \
              ld    (hl),c         ; Store MSB
              push  hl             ; MSB address on stack
              sub   0x08           ; More than 8 shifts?
              jr    c,$+16         ; No!
              pop   hl             ; Address back from stack
              push  hl             ; and back on stack
              ld    de,0x0800      ; Byte counter = 8 (D), Clear temporary storage (E)
              ld    c,(hl)         ; Load byte into C
              ld    (hl),e         ; Enter last byte from temporary storage
              ld    e,c            ; Byte from C into temporary storage
              dec   hl             ; Address pointer - 1
              dec   d              ; Byte counter - 1
              jr    nz,$-5         ; Done? No, back
              jr    $-16           ; Next byte shift
              add   a,0x09         ; Bit shifts + 1
              ld    d,a            ; in D
              xor   a              ; Clear carry
              pop   hl             ; Load address pointer from stack
              dec   d              ; Another shift?
              ret   z              ; No, done
              push  hl             ; Save address pointer
              ld    e,0x08         ; Byte counter = 8
              ld    a,(hl)         ; Load byte
              rra                  ; Shift 1 bit right
              ld    (hl),a         ; and back to memory
              dec   hl             ; Address pointer - 1
              dec   e              ; Byte counter - 1
              jr    nz,$-5         ; Done? No, back
              jr    $-14           ; Next bit shift

; Shift X Register Right by 1 Bit
              ld    hl,FAC_SIGN    ; Address MSB of X
              ld    d,0x01         ; Bit counter = 1
              jr    $-17           ; Continue at 0D84H

; Shift Memory Area Left by 1 Bit
              ld    c,0x08         ; Byte counter = 8
              ld    a,(hl)         ; Load byte
              rla                  ; Shift left
              ld    (hl),a         ; and back to memory
              inc   hl             ; Address pointer + 1
              dec   c              ; Byte counter - 1
              jr    nz,$-5         ; Done? No, back
              ret   

; LEVEL II BASIC DOUBLE PRECISION MULTIPLICATION - \
              call  SIGN           ; 1st factor = 0?
              ret   z              ; Yes, done
              call  0x090A         ; Process exponent and sign
              call  DMULDV         ; Transfer mantissa of 1st factor from X to 414A-4150. Clear X.
              ld    (hl),c         ; Clear LSB of X
              inc   de             ; Address LSB of 1st factor
              ld    b,0x07         ; Byte counter = 7
              ld    a,(de)         ; Load byte from 1st factor
              inc   de             ; Address pointer 1st factor + 1
              or    a              ; Is it 0?
              push  de             ; Address pointer on stack
              jr    z,$+25         ; Byte is 0!
              ld    c,0x08         ; Not 0, bit counter = 8
              push  bc             ; Save bit counter
              rra                  ; Next bit set?
              ld    b,a            ; Transfer byte to B
              call  c,DADDAA       ; Yes, add 2nd factor to X
              call  DXSHFT         ; Rotate X one bit right
              ld    a,b            ; Transfer byte from B back to A
              pop   bc             ; Reload bit counter
              dec   c              ; Byte finished processing?
              jr    nz,$-12        ; No, next bit
              pop   de             ; Reload address pointer
              dec   b              ; All 7 bytes processed?
              jr    nz,$-24        ; No, next byte
              jp    DNORML         ; To normalization
              ld    hl,FAC_SIGN    ; Shift result right by 1 byte
              call  0x0D70
              jr    $-13           ; Next byte
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              jr    nz,$-122

; Division by 10 with Double Precision
              ld    de,0x0DD4      ; Load address of constant 10
              ld    hl,FAC2        ; Load address of Y
              call  VMOVE          ; Constant 10 in Y

; LEVEL II BASIC DOUBLE PRECISION DIVISION - \
              ld    a,(ARG_EXP)    ; Divisor = 0?
              or    a
              jp    z,0x199A       ; Yes, DIVISION BY ZERO error
              call  MULDVS         ; Process sign and exponent
              inc   (hl)           ; Exponent correction (+2)
              inc   (hl)           ; (0907 results in Exp X - Exp Y - 1)
              call  DMULDV         ; Dividend in area 414A-4150. Clear X for result
              ld    hl,0x7951      ; Highest byte of dividend = 0
              ld    (hl),c
              ld    b,c            ; Clear flag
              ld    de,0x794A      ; Address dividend
              ld    hl,FAC2        ; Address divisor
              call  0x0D4B         ; Dividend - divisor in dividend
              ld    a,(de)         ; Load MSB of dividend
              sbc   a,c            ; - Carry (C=0)
              ccf                  ; Invert carry, underflow?
              jr    c,$+13         ; No, shift 1 into result
              ld    de,0x794A      ; Yes, undo subtraction
              ld    hl,FAC2        ; DE=Dividend, HL=Divisor
              call  0x0D39         ; Dividend + divisor in dividend
              xor   a              ; Clear carry
              DEFB  0xDA           ; Dummy instruction (JP C, 0x0412)
              ld    (de),a         ; Store MSB of dividend
              inc   b              ; Set flag
              ld    a,(FAC_SIGN)   ; Load MSB of result
              inc   a              ; Bit 7 set?
              dec   a
              rra                  ; Found bit in A(7) for rounding
              jp    m,0x0D11       ; Done, to rounding
              rla                  ; Shift bit back into carry
              ld    hl,0x791D      ; Address LSB of result (X)
              ld    c,0x07         ; Byte counter = 7
              call  0x0D99         ; Rotate result left, shift in bit.
              ld    hl,0x794A      ; Address of dividend
              call  DLSHFT         ; Rotate dividend 1 bit left
              ld    a,b            ; Flag set?
              or    a
              jr    nz,$-53        ; Yes, continue
              ld    hl,FAC         ; No, exponent of result - 1
              dec   (hl)           ; Underflow?
              jr    nz,$-59        ; No, continue
              jp    0x07B2         ; Yes, OVERFLOW error

; Subroutine for Double Precision Multiplication and Division
              ld    a,c            ; MSB of Y in memory
              ld    (ARG),a
              dec   hl             ; Load MSB of X address
              ld    de,0x7950      ; Pointer to auxiliary register
              ld    bc,0x0700      ; Transfer X to auxiliary register. Clear X, byte counter = 7
              ld    a,(hl)         ; Load byte from X
              ld    (de),a         ; in auxiliary register
              ld    (hl),c         ; Clear byte in X
              dec   de             ; Address pointer - 1
              dec   hl
              dec   b              ; Byte counter - 1
              jr    nz,$-6         ; Done? No, back
              ret   

; Double Precision Multiplication by 10
              call  VMOVAF         ; Transfer X to Y
              ex    de,hl          ; Load address of exponent X
              dec   hl
              ld    a,(hl)         ; Factor in X = 0?
              or    a
              ret   z              ; Yes, result = 0
              add   a,0x02         ; Exponent X + 2 (Factor * 4)
              jp    c,0x07B2       ; Overflow? Yes, OVERFLOW error
              ld    (hl),a         ; Store exponent back
              push  hl             ; Address of exponent X on stack
              call  DADD           ; X + Y to X (X = Factor * 5)
              pop   hl             ; Address of exponent X from stack
              inc   (hl)           ; Exponent X + 1 (X = Factor * 10)
              ret   nz             ; Overflow? No, done
              jp    0x07B2         ; Yes, OVERFLOW error

; Convert string to double precision number
              call  FA_ZERO        ; X = 0
              call  VALDBL         ; Type = double precision
              DEFB  0xF6           ; Zero-Flag = 0

; Convert string to number of appropriate type
              xor   a              ; Zero-Flag = 1 (Byte also in instruction E68)
              ex    de,hl          ; Address pointer in DE
              ld    bc,0x00FF      ; Decimal places = 0, '.'-Flag = FF
              ld    h,b            ; HL = 0
              ld    l,b
              call  z,MAKINT       ; Jump if 0E6C? yes, type=integer
              ex    de,hl          ; Address pointer back in HL
              ld    a,(hl)         ; Load character
              cp    0x2D           ; '-'? yes -> Z-Flag = 1
              push  af             ; Flag on stack
              jp    z,FINC         ; yes, next character
              cp    0x2B           ; '+' ?
              jr    z,$+3          ; yes, next character
              dec   hl             ; no sign, address pointer - 1
              rst   0x10           ; followed by a digit?
              jp    c,FINDIG       ; yes!
              cp    0x2E           ; '.'
              jp    z,FINDP        ; yes!
              cp    0x45           ; 'E'? (Exponent for single precision)
              jr    z,$+22         ; yes!
              cp    0x25           ; '%'? (Treat number as integer)
              jp    z,FININT       ; yes!
              cp    0x23           ; '#'? (Treat number as double precision)
              jp    z,FINDBF       ; yes!
              cp    0x21           ; '!'? (Treat number as single precision)
              jp    z,FINSNF       ; yes!
              cp    0x44           ; 'D'? (Exponent for double precision)
              jr    nz,$+38        ; no!

; Determine exponent
              or    a              ; Set flag for type adjustment
              call  FINFRC         ; X to single or double precision
              push  hl             ; Save address pointer
              ld    hl,FINEC       ; Load return address
              ex    (sp),hl        ; Exchange on stack with address pointer
              rst   0x10           ; Next character
              dec   d              ; Exp.-Sign-Flag to '-'
              cp    0xCE           ; '-' (Token)
              ret   z              ; yes!
              cp    0x2D           ; '-'
              ret   z              ; yes!
              inc   d              ; Exp.-Sign-Flag to '+'
              cp    0xCD           ; '+' (Token)
              ret   z              ; yes!
              cp    0x2B           ; '+'
              ret   z              ; yes!
              dec   hl             ; no sign, address pointer back
              pop   af             ; Remove return address from stack
              rst   0x10           ; Next character
              jp    c,FINEDG       ; Digit? yes-continue at 0F94H
              inc   d              ; no, Exp.-Sign-Flag = '-' ?
              jr    nz,$+5         ; no!
              xor   a              ; yes, invert exponent
              sub   e              ; and back into E
              ld    e,a
              push  hl             ; Save address pointer
              ld    a,e            ; Exponent - decimal places
              sub   b              ; Difference > 0 ?
              call  p,FINMUL       ; yes, Number * 10, Difference - 1
              call  m,FINDIV       ; no, Number / 10, Difference + 1
              jr    nz,$-6         ; repeat until difference = 0
              pop   hl             ; Load address pointer
              pop   af             ; Sign flag back on stack
              push  hl             ; Address pointer back on stack
              call  z,VNEG         ; Sign-Flag='-'? yes, X = -X
              pop   hl             ; Address pointer back
              rst   0x20           ; Test type
              ret   pe             ; Double precision? yes-done
              push  hl             ; Address pointer back on stack
              ld    hl,0x0890      ; Return address on stack
              push  hl
              call  INT            ; Single precision, if possible, convert to integer
              ret                  ; continue at 0890H

; Process decimal point
              rst   0x20           ; Test type
              inc   c              ; '.'-Flag = 0? (was there already a '.')
              jr    nz,$-31        ; yes, done
              call  c,FINFRC       ; Single precision! convert integer to single precision
              jp    FINC           ; next character

; '%' found
              rst   0x20           ; Test type
              jp    p,0x1997       ; not integer, SYNTAX - Error
              inc   hl             ; address pointer + 1
              jr    $-44           ; done!

; '#' found
              or    a              ; Set flag for type adjustment
              call  FINFRC         ; X to single or double precision
              jr    $-7            ; continue at 0EF2H

; Convert number to single or double precision
              push  hl             ; Save registers on stack
              push  de
              push  bc
              push  af             ; Save flag
              call  z,FRCSNG       ; Z-flag=1, convert to single precision
              pop   af             ; Reload flag
              call  nz,FRCDBL      ; Z-flag=0, convert to double precision
              pop   bc             ; Restore register contents
              pop   de
              pop   hl
              ret   

; Multiply real number by 10
              ret   z              ; Z-Flag = 1?, return
              push  af             ; A on stack
              rst   0x20           ; Test type
              push  af             ; Remember type-flag
              call  po,MUL10       ; type=single prec? => * 10
              pop   af             ; Reload type-flag
              call  pe,DMUL10      ; type=double prec? => * 10
              pop   af             ; Restore A-reg
              dec   a              ; A - 1
              ret   

; Divide real number by 10
              push  de             ; Save register
              push  hl
              push  af
              rst   0x20           ; Test type
              push  af             ; Save type-flag
              call  po,FDIV        ; type=single prec? => / 10
              pop   af             ; Reload type-flag
              call  pe,DDIV10      ; type=double prec? => / 10
              pop   af             ; Restore register contents
              pop   hl
              pop   de
              inc   a              ; A + 1
              ret   

; Process digit
              push  de             ; Save Exp.-Sign-Flag and Exponent
              ld    a,b            ; Next character. + 1, if '.'-Flag 0
              adc   a,c
              ld    b,a            ; in B
              push  bc             ; Save decimal places and flag
              push  hl             ; Save address pointer
              ld    a,(hl)         ; Load digit
              sub   0x30           ; Remove zone part
              push  af             ; Adjusted digit on stack
              rst   0x20           ; Test type
              jp    p,FINDGV       ; single or double precision!

; Integer
              ld    hl,(FACLO)     ; Load value from X
              ld    de,0x0CCD      ; > = 3277 ? (i.e. 10 * X >= 32770)
              rst   0x18           ; Compare with HL
              jr    nc,$+27        ; yes, convert to single precision
              ld    d,h            ; Multiply number by 10
              ld    e,l
              add   hl,hl          ; * 2
              add   hl,hl          ; * 4
              add   hl,de          ; * 5
              add   hl,hl          ; * 10
              pop   af             ; Reload digit
              ld    c,a            ; in BC (B = 0)
              add   hl,bc          ; and add to number
              ld    a,h            ; new number > 32767 ?
              or    a              ; Test A
              jp    m,FINDG1       ; yes, convert to single precision
              ld    (FACLO),hl     ; new number back in X
              pop   hl             ; Reload address pointer
              pop   bc             ; Reload decimal places + flag
              pop   de             ; Restore Exp.-Sign-Flag + Exponent
              jp    FINC           ; next character
              ld    a,c            ; Save digit
              push  af             ; A on stack
              call  INEG           ; convert HL to single precision
              scf                  ; ignore in jump instruction
              jr    nc,$+26        ; double precision? yes-jump!

; Single precision number
              ld    bc,0x9474      ; Constant 1E6 in Y
              ld    de,0x2400
              call  FCOMP          ; Value >= 1E6 ?
              jp    p,FINDG3       ; yes, convert to double precision
              call  MUL10          ; Value * 10
              pop   af             ; Reload digit
              call  FADD8          ; and add to number
              jr    $-33           ; back

; Double precision number
              call  CONDS          ; convert to double precision
              call  DMUL10         ; Value * 10
              call  VMOVAF         ; Transfer number to Y
              pop   af             ; Reload digit
              call  FLOAT          ; Transfer to X
              call  CONDS          ; convert to double precision
              call  DADD           ; and add to number
              jr    $-54           ; back

; Add 8 Bit Integer to single precision number
              call  PUSHF          ; Save 1st addend on stack
              call  FLOAT          ; 2. Addend with single precision in X
              pop   bc             ; 1. Addend from stack in Y
              pop   de
              jp    FP_ADD_X_PLUS_Y ; form sum

; Process exponent digit
              ld    a,e            ; Exponent > 9 ?
              cp    0x0A
              jr    nc,$+11        ; yes, generate overflow
              rlca                 ; Exponent * 10
              rlca  
              add   a,e
              rlca  
              add   a,(hl)         ; Add digit
              sub   0x30           ; Eliminate zone part
              ld    e,a            ; new exponent
              DEFB  0xFA           ; Dummy, will never be executed
              ld    e,0x32         ; Exponent = 32, causes overflow later
              jp    FINEC          ; process next digit

; To complete an error message
; output ' IN line number'
              push  hl             ; line number on stack
              ld    hl,MSG_IN      ; Load text address 'IN '
              call  OUTSTR         ; output text
              pop   hl             ; reload line number

; Output line number
              call  MAKINT         ; line number as integer in X
              xor   a              ; clear format-flag
              call  FOUINI         ; initialize buffer
              or    (hl)           ; X as integer without sign
              call  0x0FD9         ; convert to string
              jp    0x28A6         ; output string
              xor   a

; Convert number to formatted string
              call  FOUINI         ; address buffer start (7930H)
              and   0x08           ; output '+'?
              jr    z,$+4          ; no!
              ld    (hl),0x2B      ; '+' in buffer
              ex    de,hl          ; buffer pointer in DE
              call  VSIGN          ; Number >= 0?
              ex    de,hl          ; buffer pointer back in HL
              jp    p,0x0FD9       ; yes!
              ld    (hl),0x2D      ; '-' in buffer
              push  bc             ; length parameter on stack
              push  hl             ; buffer pointer on stack
              call  VNEG           ; save signs
              pop   hl             ; reload buffer pointer
              pop   bc             ; reload length parameter
              or    h              ; reset null-flag
              inc   hl             ; buffer pointer behind sign
              ld    (hl),0x30      ; '0' in buffer
              ld    a,(FMT_FLAG)   ; Format-Flag in D
              ld    d,a
              rla                  ; execute formatting?
              ld    a,(VALTYP)     ; load type
              jp    c,PUSTR_FORM   ; yes!
              jp    z,0x1092       ; Value = 0, done
              cp    0x04           ; single or double precision?
              jp    nc,FOUFRV      ; yes!

; Convert integer to string
              ld    bc,START       ; delete parameter for '.' and ','
              call  PUSTR_INT_SUB  ; generate string

; Process format-flag bits 2-5
              ld    hl,FBUFFR      ; buffer pointer on start
              ld    b,(hl)         ; load character
              ld    c,0x20         ; fill leading blanks
              ld    a,(FMT_FLAG)   ; load format-flag
              ld    e,a            ; in E
              and   0x20           ; fill with '*'? (Bit 5)
              jr    z,$+9          ; no!
              ld    a,b            ; sign = filler?
              cp    c
              ld    c,0x2A         ; filler = '*'
              jr    nz,$+3         ; no!
              ld    b,c            ; sign = filler
              ld    (hl),c         ; filler in buffer
              rst   0x10           ; next character = line end?
              jr    z,$+22         ; yes, do not fill further
              cp    0x45           ; Exp. indicator for single precision?
              jr    z,$+18         ; yes, do not fill further
              cp    0x44           ; Exp. indicator for double precision?
              jr    z,$+14         ; yes, do not fill further
              cp    0x30           ; '0'?
              jr    z,$-14         ; yes, continue filling
              cp    0x2C           ; ','?
              jr    z,$-18         ; yes, continue filling
              cp    0x2E           ; '.'
              jr    nz,$+5         ; no, do not fill further
              dec   hl             ; insert a '0' before '.', 'E' or 'D'
              ld    (hl),0x30
              ld    a,e            ; dollar sign before number?
              and   0x10           ; (Bit 4 of format-flag)
              jr    z,$+5          ; no!
              dec   hl             ; buffer pointer - 1
              ld    (hl),0x24      ; '$' in buffer
              ld    a,e            ; sign behind number?
              and   0x04           ; (Bit 2 of format-flag)
              ret   nz             ; yes, return
              dec   hl             ; buffer pointer before number
              ld    (hl),b         ; sign before number
              ret   
              ld    (FMT_FLAG),a   ; Save format flag
              ld    hl,FBUFFR      ; Address start of buffer
              ld    (hl),0x20      ; Space at start of buffer
              ret                  ; Return

; Convert single or double precision unformatted into string
              cp    0x05           ; Determine number of places
              push  hl             ; Buffer pointer on stack
              sbc   a,0x00         ; Type - Carry in A
              rla                  ; * 2 = number of places
              ld    d,a            ; Number of places in D
              inc   d              ; + 1
              call  GET_10_EXP     ; Determine power of 10 exponent
              ld    bc,0x0300      ; Set parameters for '.' and ','
              add   a,d            ; Exponent + 2 >= 0?
              jp    m,0x1057       ; no, exponent in buffer
              inc   d              ; Number of places + 2 in D
              cp    d              ; Exponent < number of places?
              jr    nc,$+6         ; no, exponent in buffer
              inc   a              ; yes, exponent + 3 = decimal point
              ld    b,a            ; B = exponent + 3
              ld    a,0x02         ; no exponent is output
              sub   0x02           ; Exponent - 2 in A
              pop   hl             ; Reload buffer pointer
              push  af             ; Exponent on stack
              call  SET_DOT_COMMA  ; Set '.' and ','
              ld    (hl),0x30      ; '0' in buffer
              call  z,INXHRT       ; '.' set? yes, buffer pointer + 1
              call  FAC_TO_STR     ; Convert mantissa to string
              dec   hl             ; Buffer pointer - 1
              ld    a,(hl)         ; Load character
              cp    0x30           ; = '0'?
              jr    z,$-4          ; yes, continue
              cp    0x2E           ; '.' before the last zero?
              call  nz,INXHRT      ; no! buffer pointer + 1
              pop   af             ; Load exponent. = 0?
              jr    z,$+33         ; yes, no exponent in buffer
              push  af             ; Exponent back on stack
              rst   0x20           ; Test type, Carry=1 for single precision
              ld    a,0x22         ; Load 'D' / 2
              adc   a,a            ; Exp. identifier = 'D' or 'E'
              ld    (hl),a         ; Enter in buffer
              inc   hl             ; Buffer pointer + 1
              pop   af             ; Load exponent. < 0?
              ld    (hl),0x2B      ; '+' in buffer
              jp    p,FOUFRV_POS   ; Exponent > 0!
              ld    (hl),0x2D      ; '-' in buffer
              cpl                  ; Remove sign
              inc   a              ; Increment A
              ld    b,0x2F         ; Digit = '0' - 1
              inc   b              ; Digit + 1 (yields 1st digit)
              sub   0x0A           ; Exponent - 10 = underflow?
              jr    nc,$-3         ; no, continue
              add   a,0x3A         ; yes, undo last subtraction. + '0' yields 2nd digit
              inc   hl             ; Buffer pointer + 1
              ld    (hl),b         ; 1st digit in buffer
              inc   hl             ; Buffer pointer + 1 in buffer
              ld    (hl),a         ; 2nd digit in buffer
              inc   hl             ; Buffer pointer + 1
              ld    (hl),0x00      ; End marker in buffer
              ex    de,hl          ; Buffer end address in DE
              ld    hl,FBUFFR      ; Buffer start address in HL
              ret                  ; done !!!

; Generate formatted string
              inc   hl             ; Buffer pointer + 1
              push  bc             ; Length parameters on stack
              cp    0x04           ; Single or double precision?
              ld    a,d            ; Format flag in A
              jp    nc,PUSTR_VAL   ; yes!

; Convert integer to string
              rra                  ; Exponent output? (Bit 0)
              jp    c,0x11A3       ; yes!
              ld    bc,0x0603      ; Parameters for '.' and ','
              call  0x1289         ; no ',' output?
              pop   de             ; Load length parameter into DE
              ld    a,d            ; Pre-decimal places - 5 >= 0?
              sub   0x05
              call  p,PUT_ZEROS    ; output corresponding number of zeros
              call  PUSTR_INT_SUB  ; Convert number to string
              ld    a,e            ; no post-decimal places?
              or    a              ; OR A
              call  z,DCXHRT       ; yes, delete '.' in buffer
              dec   a              ; Post-decimal places - 1 > 0?
              call  p,PUT_ZEROS    ; output corresponding number of zeros
              push  hl             ; Buffer pointer on stack

; Remaining formatting. Establish correct field length
              call  PUSTR_BITS_2_5 ; Process remaining format specifications
              pop   hl             ; Reload buffer pointer
              jr    z,$+4          ; Sign behind number?
              ld    (hl),b         ; Set sign behind number
              inc   hl             ; Buffer pointer + 1
              ld    (hl),0x00      ; Mark end of line with X'00'
              ld    hl,0x792F      ; Load address before buffer
              inc   hl             ; Buffer address + 1
              ld    a,(0x78F3)     ; LSB '.'-position
              sub   l              ; SUB L
              sub   d              ; - pre-decimal places = 0?
              ret   z              ; yes, done
              ld    a,(hl)         ; Load character
              cp    0x20           ; = ' '?
              jr    z,$-10         ; yes, continue
              cp    0x2A           ; = '*'?
              jr    z,$-14         ; yes, continue
              dec   hl             ; Buffer pointer - 1
              push  hl             ; and onto stack
              push  af             ; Character + flag on stack
              ld    bc,PUSTR_STACK_CHAR ; Set return address
              push  bc             ; PUSH BC
              rst   0x10           ; next character
              cp    0x2D           ; = '-'?
              ret   z              ; yes, continue
              cp    0x2B           ; = '+'?
              ret   z              ; yes, continue
              cp    0x24           ; = '$'?
              ret   z              ; yes, continue
              pop   bc             ; Remove return address again
              cp    0x30           ; = '0'?
              jr    nz,$+17        ; no, field overflow
              inc   hl             ; Buffer pointer + 1 (behind '.')
              rst   0x10           ; next character. = digit?
              jr    nc,$+13        ; no, field overflow
              dec   hl             ; Buffer pointer to '.'
              DEFB  0x01           ; LD BC,772B Dummy instruction
              dec   hl
              ld    (hl),a
              pop   af             ; Get character from stack
              jr    z,$-3          ; last character? no-to 10F9H
              pop   bc             ; Get buffer pointer from stack
              jp    PUSTR_LOOP     ; continue at 10CEH

; Field overflow
              pop   af             ; Get character from stack
              jr    z,$-1          ; last character?
              pop   hl             ; Reload buffer pointer
              ld    (hl),0x25      ; '%' for field overflow before number
              ret                  ; Return

; Generate formatted string of single or double precision numbers
              push  hl             ; Buffer pointer on stack
              rra                  ; Exponent output?
              jp    c,PUSTR_EXP    ; yes!
              jr    z,$+22         ; for single precision => jump
              ld    de,0x1384      ; Address constant 1D16
              call  0x0A49         ; Value >= 1D16?
              ld    d,0x10         ; Precision (16 places) in D
              jp    m,0x1132       ; Value < 1D16!

; Field overflow
              pop   hl             ; Reload buffer pointer
              pop   bc             ; Load length parameter
              call  PUSTR_UNFORM_INIT ; Generate unformatted string
              dec   hl             ; Buffer pointer - 1
              ld    (hl),0x25      ; '%' for field overflow before string
              ret                  ; Return
              ld    bc,0xB60E
              ld    de,0x1BCA
              call  FCOMP
              jp    p,PUSTR_OVERFLOW_STR
              ld    d,0x06
              call  SIGN
              call  nz,GET_10_EXP
              pop   hl
              pop   bc
              jp    m,0x1157
              push  bc
              ld    e,a
              ld    a,b
              sub   d
              sub   e
              call  p,PUT_ZEROS
              call  0x127D
              call  FAC_TO_STR
              or    e
              call  nz,0x1277
              or    e
              call  nz,SET_DOT_COMMA
              pop   de
              jp    0x10B6
              ld    e,a
              ld    a,c
              or    a
              call  nz,0x0F16
              add   a,e
              jp    m,0x1162
              xor   a
              push  bc
              push  af
              call  m,FINDIV
              jp    m,0x1164
              pop   bc
              ld    a,e
              sub   b
              pop   bc
              ld    e,a
              add   a,d
              ld    a,b
              jp    m,0x117F
              sub   d
              sub   e
              call  p,PUT_ZEROS
              push  bc
              call  0x127D
              jr    $+19
              call  PUT_ZEROS
              ld    a,c
              call  0x1294
              ld    c,a
              xor   a
              sub   d
              sub   e
              call  PUT_ZEROS
              push  bc
              ld    b,a
              ld    c,a
              call  FAC_TO_STR
              pop   bc
              or    c
              jr    nz,$+5
              ld    hl,(0x78F3)
              add   a,e
              dec   a
              call  p,PUT_ZEROS
              ld    d,b
              jp    0x10BF
              push  hl
              push  de
              call  INEG
              pop   de
              xor   a
              jp    z,0x11B0
              ld    e,0x10
              ld    bc,0x061E
              call  SIGN
              scf   
              call  nz,GET_10_EXP
              pop   hl
              pop   bc
              push  af
              ld    a,c
              or    a
              push  af
              call  nz,0x0F16
              add   a,b
              ld    c,a
              ld    a,d
              and   0x04
              cp    0x01
              sbc   a,a
              ld    d,a
              add   a,c
              ld    c,a
              sub   e
              push  af
              push  bc
              call  m,FINDIV
              jp    m,0x11D0
              pop   bc
              pop   af
              push  bc
              push  af
              jp    m,0x11DE
              xor   a
              cpl   
              inc   a
              add   a,b
              inc   a
              add   a,d
              ld    b,a
              ld    c,0x00
              call  FAC_TO_STR
              pop   af
              call  p,0x1271
              pop   bc
              pop   af
              call  z,DCXHRT
              pop   af
              jr    c,$+5
              add   a,e
              sub   b
              sub   d
              push  bc
              call  0x1074
              ex    de,hl
              pop   de
              jp    0x10BF
              push  de
              xor   a
              push  af
              rst   0x20
              jp    po,0x1222
              ld    a,(FAC)
              cp    0x91
              jp    nc,0x1222
              ld    de,0x1364
              ld    hl,FAC2
              call  VMOVE
              call  DMULT
              pop   af
              sub   0x0A
              push  af
              jr    $-24
              call  0x124F
              rst   0x20
              jp    pe,0x1234
              ld    bc,0x9143
              ld    de,0x4FF9
              call  FCOMP
              jr    $+8
              ld    de,0x136C
              call  0x0A49
              jp    p,0x124C
              pop   af
              call  0x0F0B
              push  af
              jr    $-29
              pop   af
              call  FINDIV
              push  af
              call  0x124F
              pop   af
              pop   de
              ret   
              rst   0x20
              jp    pe,0x125E
              ld    bc,0x9474
              ld    de,0x23F8
              call  FCOMP
              jr    $+8
              ld    de,0x1374
              call  0x0A49
              pop   hl
              jp    p,0x1244
              jp    (hl)
              or    a
              ret   z
              dec   a
              ld    (hl),0x30
              inc   hl
              jr    $-5
              jr    nz,$+6
              ret   z
              call  SET_DOT_COMMA
              ld    (hl),0x30
              inc   hl
              dec   a
              jr    $-8
              ld    a,e
              add   a,d
              inc   a
              ld    b,a
              inc   a
              sub   0x03
              jr    nc,$-2
              add   a,0x05
              ld    c,a
              ld    a,(FMT_FLAG)
              and   0x40
              ret   nz
              ld    c,a
              ret   
              dec   b
              jr    nz,$+10
              ld    (hl),0x2E
              ld    (0x78F3),hl
              inc   hl
              ld    c,b
              ret   
              dec   c
              ret   nz
              ld    (hl),0x2C
              inc   hl
              ld    c,0x03
              ret   
              push  de
              rst   0x20
              jp    po,0x12EA
              push  bc
              push  hl
              call  VMOVAF
              ld    hl,0x137C
              call  VMOVFM
              call  DADD
              xor   a
              call  0x0B7B
              pop   hl
              pop   bc
              ld    de,0x138C
              ld    a,0x0A
              call  SET_DOT_COMMA
              push  bc
              push  af
              push  hl
              push  de
              ld    b,0x2F
              inc   b
              pop   hl
              push  hl
              call  0x0D48
              jr    nc,$-6
              pop   hl
              call  0x0D36
              ex    de,hl
              pop   hl
              ld    (hl),b
              inc   hl
              pop   af
              pop   bc
              dec   a
              jr    nz,$-28
              push  bc
              push  hl
              ld    hl,0x791D
              call  MOVFM
              jr    $+14
              push  bc
              push  hl
              call  FP_ADD_HALF
              inc   a
              call  DROUND
              call  MOVFR
              pop   hl
              pop   bc
              xor   a
              ld    de,0x13D2
              ccf   
              call  SET_DOT_COMMA
              push  bc
              push  af
              push  hl
              push  de
              call  MOVRF
              pop   hl
              ld    b,0x2F
              inc   b
              ld    a,e
              sub   (hl)
              ld    e,a
              inc   hl
              ld    a,d
              sbc   a,(hl)
              ld    d,a
              inc   hl
              ld    a,c
              sbc   a,(hl)
              ld    c,a
              dec   hl
              dec   hl
              jr    nc,$-14
              call  0x07B7
              inc   hl
              call  MOVFR
              ex    de,hl
              pop   hl
              ld    (hl),b
              inc   hl
              pop   af
              pop   bc
              jr    c,$-43
              inc   de
              inc   de
              ld    a,0x04
              jr    $+8
              push  de
              ld    de,0x13D8
              ld    a,0x05
              call  SET_DOT_COMMA
              push  bc
              push  af
              push  hl
              ex    de,hl
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              push  bc
              inc   hl
              ex    (sp),hl
              ex    de,hl
              ld    hl,(FACLO)
              ld    b,0x2F
              inc   b
              ld    a,l
              sub   e
              ld    l,a
              ld    a,h
              sbc   a,d
              ld    h,a
              jr    nc,$-7
              add   hl,de
              ld    (FACLO),hl
              pop   de
              pop   hl
              ld    (hl),b
              inc   hl
              pop   af
              pop   bc
              dec   a
              jr    nz,$-39
              call  SET_DOT_COMMA
              ld    (hl),a
              pop   de
              ret   
              nop   
              nop   
              nop   
              nop   
              ld    sp,hl
              ld    (bc),a
              dec   d
              and   d
              defb  0x00FD,0x00FF,0x009F
              ld    sp,0x5FA9
              ld    h,e
              or    d
              cp    0xFF
              inc   bc
              cp    a
              ret   
              dec   de
              ld    c,0xB6
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              add   a,b
              nop   
              nop   
              inc   b
              cp    a
              ret   
              dec   de
              ld    c,0xB6
              nop   
              add   a,b
              add   a,0xA4
              ld    a,(hl)
              adc   a,l
              inc   bc
              nop   
              ld    b,b
              ld    a,d
              djnz  $-11
              ld    e,d
              nop   
              nop   
              and   b
              ld    (hl),d
              ld    c,(hl)
              jr    $+11
              nop   
              nop   
              djnz  $-89
              call  nc,0x00E8
              nop   
              nop   
              ret   pe
              halt  
              ld    c,b
              rla   
              nop   
              nop   
              nop   
              call  po,0x540B
              ld    (bc),a
              nop   
              nop   
              nop   
              jp    z,0x3B9A
              nop   
              nop   
              nop   
              nop   
              pop   hl
              push  af
              dec   b
              nop   
              nop   
              nop   
              add   a,b
              sub   (hl)
              sbc   a,b
              nop   
              nop   
              nop   
              nop   
              ld    b,b
              ld    b,d
              rrca  
              nop   
              nop   
              nop   
              nop   
              and   b
              add   a,(hl)
              ld    bc,0x2710
              nop   
              djnz  $+41
              ret   pe
              inc   bc
              ld    h,h
              nop   
              ld    a,(bc)
              nop   
              ld    bc,0x2100
              add   a,d
              add   hl,bc
              ex    (sp),hl
              jp    (hl)
              call  PUSHF
              ld    hl,0x1380
              call  MOVFM
              jr    $+5
              call  FRCSNG
              pop   bc
              pop   de
              call  SIGN
              ld    a,b
              jr    z,$+62
              jp    p,0x1404
              or    a
              jp    z,0x199A
              or    a
              jp    z,0x0779
              push  de
              push  bc
              ld    a,c
              or    0x7F
              call  MOVRF
              jp    p,0x1421
              push  de
              push  bc
              call  0x0B40
              pop   bc
              pop   de
              push  af
              call  FCOMP
              pop   hl
              ld    a,h
              rra   
              pop   hl
              ld    (FAC_SIGN),hl
              pop   hl
              ld    (FACLO),hl
              call  c,0x13E2
              call  z,NNEG
              push  de
              push  bc
              call  FNLOG
              pop   bc
              pop   de
              call  0x0847
              call  PUSHF
              ld    bc,0x8138
              ld    de,0xAA3B
              call  0x0847
              ld    a,(FAC)
              cp    0x88
              jp    nc,MLDVEX
              call  0x0B40
              add   a,0x80
              add   a,0x02
              jp    c,MLDVEX
              push  af
              ld    hl,FONE
              call  0x070B
              call  MULLN2
              pop   af
              pop   bc
              pop   de
              push  af
              call  FP_SUB_Y_MINUS_X
              call  NNEG
              ld    hl,0x1479
              call  0x14A9
              ld    de,START
              pop   bc
              ld    c,d
              jp    0x0847
              ex    af,af'
              ld    b,b
              ld    l,0x94
              ld    (hl),h
              ld    (hl),b
              ld    c,a
              ld    l,0x77
              ld    l,(hl)
              ld    (bc),a
              adc   a,b
              ld    a,d
              and   0xA0
              ld    hl,(0x507C)
              xor   d
              xor   d
              ld    a,(hl)
              rst   0x38
              rst   0x38
              ld    a,a
              ld    a,a
              nop   
              nop   
              add   a,b
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              call  PUSHF
              ld    de,0x0C32
              push  de
              push  hl
              call  MOVRF
              call  0x0847
              pop   hl
              call  PUSHF
              ld    a,(hl)
              inc   hl
              call  MOVFM
              ld    b,0xF1
              pop   bc
              pop   de
              dec   a
              ret   z
              push  de
              push  bc
              push  af
              push  hl
              call  0x0847
              pop   hl
              call  MOVRM
              push  hl
              call  FP_ADD_X_PLUS_Y
              pop   hl
              jr    $-21
              call  FRCINT
              ld    a,h
              or    a
              jp    m,0x1E4A
              or    l
              jp    z,0x14F0
              push  hl
              call  0x14F0
              call  MOVRF
              ex    de,hl
              ex    (sp),hl
              push  bc
              call  0x0ACF
              pop   bc
              pop   de
              call  0x0847
              ld    hl,FONE
              call  0x070B
              jp    0x0B40
              ld    hl,0x7890
              push  hl
              ld    de,START
              ld    c,e
              ld    h,0x03
              ld    l,0x08
              ex    de,hl
              add   hl,hl
              ex    de,hl
              ld    a,c
              rla   
              ld    c,a
              ex    (sp),hl
              ld    a,(hl)
              rlca  
              ld    (hl),a
              ex    (sp),hl
              jp    nc,0x1516
              push  hl
              ld    hl,(0x78AA)
              add   hl,de
              ex    de,hl
              ld    a,(0x78AC)
              adc   a,c
              ld    c,a
              pop   hl
              dec   l
              jp    nz,0x14FC
              ex    (sp),hl
              inc   hl
              ex    (sp),hl
              dec   h
              jp    nz,0x14FA
              pop   hl
              ld    hl,0xB065
              add   hl,de
              ld    (0x78AA),hl
              call  VALSNG
              ld    a,0x05
              adc   a,c
              ld    (0x78AC),a
              ex    de,hl
              ld    b,0x80
              ld    hl,0x7925
              ld    (hl),b
              dec   hl
              ld    (hl),b
              ld    c,a
              ld    b,0x00
              jp    0x0765
              ld    hl,0x158B
              call  0x070B
              call  PUSHF
              ld    bc,0x8349
              ld    de,0x0FDB
              call  MOVFR
              pop   bc
              pop   de
              call  0x08A2
              call  PUSHF
              call  0x0B40
              pop   bc
              pop   de
              call  FP_SUB_Y_MINUS_X
              ld    hl,0x158F
              call  FP_SUB_HALF
              call  SIGN
              scf   
              jp    p,0x1577
              call  FP_ADD_HALF
              call  SIGN
              or    a
              push  af
              call  p,NNEG
              ld    hl,0x158F
              call  0x070B
              pop   af
              call  nc,NNEG
              ld    hl,0x1593
              jp    0x149A
              in    a,(0x0F)
              ld    c,c
              add   a,c
              nop   
              nop   
              nop   
              ld    a,a
              dec   b
              cp    d
              rst   0x10
              ld    e,0x86
              ld    h,h
              ld    h,0x99
              add   a,a
              ld    e,b
              inc   (hl)
              inc   hl
              add   a,a
              ret   po
              ld    e,l
              and   l
              add   a,(hl)
              jp    c,0x490F
              add   a,e
              call  PUSHF
              call  0x1547
              pop   bc
              pop   hl
              call  PUSHF
              ex    de,hl
              call  MOVFR
              call  0x1541
              jp    0x08A0
              call  SIGN
              call  m,0x13E2
              call  m,NNEG
              ld    a,(FAC)
              cp    0x81
              jr    c,$+14
              ld    bc,0x8100
              ld    d,c
              ld    e,c
              call  0x08A2
              ld    hl,FP_SUB_HALF
              push  hl
              ld    hl,0x15E3
              call  0x149A
              ld    hl,0x158B
              ret   
              add   hl,bc
              ld    c,d
              rst   0x10
              dec   sp
              ld    a,b
              ld    (bc),a
              ld    l,(hl)
              add   a,h
              ld    a,e
              cp    0xC1
              cpl   
              ld    a,h
              ld    (hl),h
              ld    sp,0x7D9A
              add   a,h
              dec   a
              ld    e,d
              ld    a,l
              ret   z
              ld    a,a
              sub   c
              ld    a,(hl)
              call  po,0x4CBB
              ld    a,(hl)
              ld    l,h
              xor   d
              xor   d
              ld    a,a
              nop   
              nop   
              nop   
              add   a,c
              adc   a,d
              add   hl,bc
              scf   
              dec   bc
              ld    (hl),a
              add   hl,bc
              call  nc,0xEF27
              ld    hl,(0x27F5)
              rst   0x20
              inc   de
              ret   
              inc   d
              add   hl,bc
              ex    af,af'
              add   hl,sp
              inc   d
              ld    b,c
              dec   d
              ld    b,a
              dec   d
              xor   b
              dec   d
              cp    l
              dec   d
              xor   d
              inc   l
              ld    d,d
              ld    a,c
              ld    e,b
              ld    a,c
              ld    e,(hl)
              ld    a,c
              ld    h,c
              ld    a,c
              ld    h,h
              ld    a,c
              ld    h,a
              ld    a,c
              ld    l,d
              ld    a,c
              ld    l,l
              ld    a,c
              ld    (hl),b
              ld    a,c
              ld    a,a
              ld    a,(bc)
              or    c
              ld    a,(bc)
              in    a,(0x0A)
              ld    h,0x0B
              inc   bc
              ld    hl,(0x2836)
              push  bc
              ld    hl,(0x2A0F)
              rra   
              ld    hl,(0x2A61)
              sub   c
              ld    hl,(0x2A9A)
              push  bc
              ld    c,(hl)
              ld    b,h
              add   a,0x4F
              ld    d,d
              jp    nc,0x5345
              ld    b,l
              ld    d,h
              out   (0x45),a
              ld    d,h
              jp    0x534C
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              adc   a,0x45
              ld    e,b
              ld    d,h
              call  nz,0x5441
              ld    b,c
              ret   
              ld    c,(hl)
              ld    d,b
              ld    d,l
              ld    d,h
              call  nz,0x4D49
              jp    nc,0x4145
              ld    b,h
              call  z,0x5445
              rst   0
              ld    c,a
              ld    d,h
              ld    c,a
              jp    nc,0x4E55
              ret   
              ld    b,(hl)
              jp    nc,0x5345
              ld    d,h
              ld    c,a
              ld    d,d
              ld    b,l
              rst   0
              ld    c,a
              ld    d,e
              ld    d,l
              ld    b,d
              jp    nc,0x5445
              ld    d,l
              ld    d,d
              ld    c,(hl)
              jp    nc,0x4D45
              out   (0x54),a
              ld    c,a
              ld    d,b
              push  bc
              ld    c,h
              ld    d,e
              ld    b,l
              jp    0x504F
              ld    e,c
              jp    0x4C4F
              ld    c,a
              ld    d,d
              sub   0x45
              ld    d,d
              ld    c,c
              ld    b,(hl)
              ld    e,c
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              jp    0x5552
              ld    c,(hl)
              call  0x444F
              ld    b,l
              out   (0x4F),a
              ld    d,l
              ld    c,(hl)
              ld    b,h
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              rst   8
              ld    d,l
              ld    d,h
              add   a,c
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              call  z,0x5250
              ld    c,c
              ld    c,(hl)
              ld    d,h
              add   a,c
              nop   
              nop   
              ret   nc
              ld    c,a
              ld    c,e
              ld    b,l
              ret   nc
              ld    d,d
              ld    c,c
              ld    c,(hl)
              ld    d,h
              jp    0x4E4F
              ld    d,h
              call  z,0x5349
              ld    d,h
              call  z,0x494C
              ld    d,e
              ld    d,h
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              jp    0x454C
              ld    b,c
              ld    d,d
              jp    0x4F4C
              ld    b,c
              ld    b,h
              jp    0x4153
              ld    d,(hl)
              ld    b,l
              adc   a,0x45
              ld    d,a
              call  nc,0x4241
              jr    z,$-42
              ld    c,a
              add   a,c
              nop   
              push  de
              ld    d,e
              ld    c,c
              ld    c,(hl)
              ld    b,a
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              push  de
              ld    d,e
              ld    d,d
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              nop   
              ret   nc
              ld    c,a
              ld    c,c
              ld    c,(hl)
              ld    d,h
              add   a,c
              nop   
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              ret   
              ld    c,(hl)
              ld    c,e
              ld    b,l
              ld    e,c
              inc   h
              call  nc,0x4548
              ld    c,(hl)
              adc   a,0x4F
              ld    d,h
              out   (0x54),a
              ld    b,l
              ld    d,b
              xor   e
              xor   l
              xor   d
              xor   a
              sbc   a,0xC1
              ld    c,(hl)
              ld    b,h
              rst   8
              ld    d,d
              cp    (hl)
              cp    l
              cp    h
              out   (0x47),a
              ld    c,(hl)
              ret   
              ld    c,(hl)
              ld    d,h
              pop   bc
              ld    b,d
              ld    d,e
              add   a,c
              nop   
              nop   
              ret   
              ld    c,(hl)
              ld    d,b
              add   a,c
              nop   
              nop   
              out   (0x51),a
              ld    d,d
              jp    nc,0x444E
              call  z,0x474F
              push  bc
              ld    e,b
              ld    d,b
              jp    0x534F
              out   (0x49),a
              ld    c,(hl)
              call  nc,0x4E41
              pop   bc
              ld    d,h
              ld    c,(hl)
              ret   nc
              ld    b,l
              ld    b,l
              ld    c,e
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              nop   
              add   a,c
              nop   
              nop   
              call  z,0x4E45
              out   (0x54),a
              ld    d,d
              inc   h
              sub   0x41
              ld    c,h
              pop   bc
              ld    d,e
              ld    b,e
              jp    0x5248
              inc   h
              call  z,0x4645
              ld    d,h
              inc   h
              jp    nc,0x4749
              ld    c,b
              ld    d,h
              inc   h
              call  0x4449
              inc   h
              and   a
              add   a,b
              xor   (hl)
              dec   e
              and   c
              inc   e
              jr    c,$+3
              dec   (hl)
              ld    bc,CLRSCR
              ld    (hl),e
              ld    a,c
              out   (0x01),a
              or    (hl)
              ld    (0x1F05),hl
              sbc   a,d
              ld    hl,0x2608
              rst   0x28
              ld    hl,0x1F21
              jp    nz,0xA31E
              ld    e,0x39
              jr    nz,$-109
              dec   e
              or    c
              ld    e,0xDE
              ld    e,0x07
              rra   
              xor   c
              dec   e
              rlca  
              rra   
              ld    (de),a
              add   hl,sp
              sbc   a,l
              jr    c,$+58
              scf   
              inc   bc
              ld    e,0x06
              ld    e,0x09
              ld    e,0x2E
              scf   
              ld    h,e
              ld    l,0xF5
              dec   hl
              xor   a
              rra   
              ei    
              ld    hl,(0x1F6C)
              ld    a,c
              ld    a,c
              ld    a,h
              ld    a,c
              ld    a,a
              ld    a,c
              add   a,d
              ld    a,c
              add   a,l
              ld    a,c
              adc   a,b
              ld    a,c
              adc   a,e
              ld    a,c
              adc   a,(hl)
              ld    a,c
              sub   c
              ld    a,c
              sub   a
              ld    a,c
              sbc   a,d
              ld    a,c
              and   b
              ld    a,c
              nop   
              nop   
              ld    h,a
              jr    nz,$+93
              ld    a,c
              or    c
              inc   l
              ld    l,a
              jr    nz,$-26
              dec   e
              ld    l,0x2B
              add   hl,hl
              dec   hl
              add   a,0x2B
              ex    af,af'
              jr    nz,$+124
              ld    e,0x56
              ld    (hl),0xA9
              inc   (hl)
              ld    c,c
              dec   de
              ld    a,c
              ld    a,c
              ld    a,h
              ld    a,h
              ld    a,a
              ld    d,b
              ld    b,(hl)
              in    a,(0x0A)
              nop   
              nop   
              ld    a,a
              ld    a,(bc)
              call  p,0xB10A
              ld    a,(bc)
              ld    (hl),a
              inc   c
              ld    (hl),b
              inc   c
              and   c
              dec   c
              push  hl
              dec   c
              ld    a,b
              ld    a,(bc)
              ld    d,0x07
              inc   de
              rlca  
              ld    b,a
              ex    af,af'
              and   d
              ex    af,af'
              inc   c
              ld    a,(bc)
              jp    nc,0xC70B
              dec   bc
              jp    p,0x900B
              inc   h
              add   hl,sp
              ld    a,(bc)
              ld    c,(hl)
              ld    b,(hl)
              ld    d,e
              ld    c,(hl)
              ld    d,d
              ld    b,a
              ld    c,a
              ld    b,h
              ld    b,(hl)
              ld    b,e
              ld    c,a
              ld    d,(hl)
              ld    c,a
              ld    c,l
              ld    d,l
              ld    c,h
              ld    b,d
              ld    d,e
              ld    b,h
              ld    b,h
              cpl   
              jr    nc,$+75
              ld    b,h
              ld    d,h
              ld    c,l
              ld    c,a
              ld    d,e
              ld    c,h
              ld    d,e
              ld    d,e
              ld    d,h
              ld    b,e
              ld    c,(hl)
              ld    c,(hl)
              ld    d,d
              ld    d,d
              ld    d,a
              ld    d,l
              ld    b,l
              ld    c,l
              ld    c,a
              ld    b,(hl)
              ld    b,h
              ld    c,h
              inc   sp
              sub   0x00
              ld    l,a
              ld    a,h
              sbc   a,0x00
              ld    h,a
              ld    a,b
              sbc   a,0x00
              ld    b,a
              ld    a,0x00
              ret   
              ld    c,d
              ld    e,0x40
              and   0x4D
              in    a,(0x00)
              ret   
              out   (0x00),a
              ret   
              nop   
              nop   
              nop   
              nop   
              ld    b,b
              jr    nc,$+2
              ld    c,h
              ld    a,e
              cp    0xFF
              jp    (hl)
              ld    a,d
              jr    nz,$+71
              ld    d,d
              ld    d,d
              ld    c,a
              ld    d,d
              nop   
              jr    nz,$+75
              ld    c,(hl)
              jr    nz,$+2
              ld    d,d
              ld    b,l
              ld    b,c
              ld    b,h
              ld    e,c
              dec   c
              nop   
              ld    b,d
              ld    d,d
              ld    b,l
              ld    b,c
              ld    c,e
              nop   
              ld    hl,0x0004
              add   hl,sp
              ld    a,(hl)
              inc   hl
              cp    0x81
              ret   nz
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              inc   hl
              push  hl
              ld    l,c
              ld    h,b
              ld    a,d
              or    e
              ex    de,hl
              jr    z,$+4
              ex    de,hl
              rst   0x18
              ld    bc,0x000E
              pop   hl
              ret   z
              add   hl,bc
              jr    $-25
              call  0x196C
              push  bc
              ex    (sp),hl
              pop   bc
              rst   0x18
              ld    a,(hl)
              ld    (bc),a
              ret   z
              dec   bc
              dec   hl
              jr    $-6
              push  hl
              ld    hl,(0x78FD)
              ld    b,0x00
              add   hl,bc
              add   hl,bc
              ld    a,0xE5
              ld    a,0xC6
              sub   l
              ld    l,a
              ld    a,0xFF
              sbc   a,h
              jr    c,$+6
              ld    h,a
              add   hl,sp
              pop   hl
              ret   c
              ld    e,0x0C
              jr    $+38
              ld    hl,(0x78A2)
              ld    a,h
              and   l
              inc   a
              jr    z,$+10
              ld    a,(0x78F2)
              or    a
              ld    e,0x22
              jr    nz,$+22
              jp    0x1DC1
              ld    hl,(0x78DA)
              ld    (0x78A2),hl
              ld    e,0x02
              ld    bc,0x141E
              ld    bc,0x001E
              ld    bc,0x241E
              ld    hl,(0x78A2)
              ld    (0x78EA),hl
              ld    (0x78EC),hl
              ld    bc,0x19B4
              ld    hl,(0x78E8)
              jp    0x1B9A
              pop   bc
              ld    a,e
              ld    c,e
              ld    (0x789A),a
              ld    hl,(0x78E6)
              ld    (0x78EE),hl
              ex    de,hl
              ld    hl,(0x78EA)
              ld    a,h
              and   l
              inc   a
              jr    z,$+9
              ld    (0x78F5),hl
              ex    de,hl
              ld    (0x78F7),hl
              ld    hl,(0x78F0)
              ld    a,h
              or    l
              ex    de,hl
              ld    hl,0x78F2
              jr    z,$+10
              and   (hl)
              jr    nz,$+7
              dec   (hl)
              ex    de,hl
              jp    0x1D36
              xor   a
              ld    (hl),a
              ld    e,c
              call  0x20F9
              ld    hl,0x3CEC
              call  0x79A6
              ld    d,a
              ld    a,0x3F
              call  CHAR_OUTPUT_DISPATCH
              call  0x3CD4
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    hl,0x191D
              push  hl
              ld    hl,(0x78EA)
              ex    (sp),hl
              call  OUTSTR
              pop   hl
              ld    de,0xFFFE
              rst   0x18
              jp    z,BASIC_INIT_1
              ld    a,h
              and   l
              inc   a
              call  nz,INPRT
              ld    a,0xC1
              call  OUTPUT_SCREEN_SELECT
              call  0x79AC
              nop   
              nop   
              nop   
              call  0x20F9
              ld    hl,0x1929
              call  OUTSTR
              ld    a,(0x789A)
              sub   0x02
              nop   
              nop   
              nop   
              ld    hl,0xFFFF
              ld    (0x78A2),hl
              ld    a,(0x78E1)
              or    a
              jr    z,$+60
              ld    hl,(0x78E2)
              push  hl
              call  LINPRT
              ld    a,0x20
              call  CHAR_OUTPUT_DISPATCH
              pop   de
              push  de
              call  0x1B2C
              call  c,0x2E53
              nop   
              call  INPUT_LINE_READ
              pop   de
              jr    nc,$+8
              xor   a
              ld    (0x78E1),a
              jr    $-69
              ld    hl,(0x78E4)
              add   hl,de
              jr    c,$-10
              push  de
              ld    de,0xFFF9
              rst   0x18
              pop   de
              jr    nc,$-18
              ld    (0x78E2),hl
              nop   
              nop   
              ld    hl,0x79E7
              jp    0x1A81
              nop   
              nop   
              call  INPUT_LINE_READ
              jp    c,0x1A33
              rst   0x10
              inc   a
              dec   a
              jp    z,0x1A33
              push  af
              call  0x1E5A
              dec   hl
              ld    a,(hl)
              cp    0x20
              jr    z,$-4
              inc   hl
              ld    a,(hl)
              cp    0x20
              call  z,INXHRT
              push  de
              call  0x1BC0
              pop   de
              pop   af
              ld    (0x78E6),hl
              call  0x79B2
              jp    nc,0x1D5A
              push  de
              push  bc
              xor   a
              ld    (0x78DD),a
              rst   0x10
              or    a
              push  af
              ex    de,hl
              ld    (0x78EC),hl
              ex    de,hl
              call  0x1B2C
              push  bc
              call  c,0x2BE4
              pop   de
              pop   af
              push  de
              jr    z,$+41
              pop   de
              ld    hl,(0x78F9)
              ex    (sp),hl
              pop   bc
              add   hl,bc
              push  hl
              call  0x1955
              pop   hl
              ld    (0x78F9),hl
              ex    de,hl
              ld    (hl),h
              pop   de
              push  hl
              inc   hl
              inc   hl
              ld    (hl),e
              inc   hl
              ld    (hl),d
              inc   hl
              ex    de,hl
              ld    hl,(0x78A7)
              ex    de,hl
              dec   de
              dec   de
              ld    a,(de)
              ld    (hl),a
              inc   hl
              inc   de
              or    a
              jr    nz,$-5
              pop   de
              call  0x1AFC
              call  0x79B5
              call  0x1B5D
              call  0x79B8
              jp    0x1A33
              ld    hl,(0x78A4)
              ex    de,hl
              ld    h,d
              ld    l,e
              ld    a,(hl)
              inc   hl
              or    (hl)
              ret   z
              inc   hl
              inc   hl
              inc   hl
              xor   a
              cp    (hl)
              inc   hl
              jr    nz,$-2
              ex    de,hl
              ld    (hl),e
              inc   hl
              ld    (hl),d
              jr    $-18
              ld    de,START
              push  de
              jr    z,$+11
              pop   de
              call  0x1E4F
              push  de
              jr    z,$+13
              rst   8
              adc   a,0x11
              jp    m,0xC4FF
              ld    c,a
              ld    e,0xC2
              sub   a
              add   hl,de
              ex    de,hl
              pop   de
              ex    (sp),hl
              push  hl
              ld    hl,(0x78A4)
              ld    b,h
              ld    c,l
              ld    a,(hl)
              inc   hl
              or    (hl)
              dec   hl
              ret   z
              inc   hl
              inc   hl
              ld    a,(hl)
              inc   hl
              ld    h,(hl)
              ld    l,a
              rst   0x18
              ld    h,b
              ld    l,c
              ld    a,(hl)
              inc   hl
              ld    h,(hl)
              ld    l,a
              ccf   
              ret   z
              ccf   
              ret   nc
              jr    $-24
              ret   nz
              call  CLRSCR
              ld    hl,(0x78A4)
              call  0x1DF8
              ld    (0x78E1),a
              ld    (hl),a
              inc   hl
              ld    (hl),a
              inc   hl
              ld    (0x78F9),hl
              ld    hl,(0x78A4)
              dec   hl
              ld    (0x78DF),hl
              ld    b,0x1A
              ld    hl,0x7901
              ld    (hl),0x04
              inc   hl
              djnz  $-3
              xor   a
              ld    (0x78F2),a
              ld    l,a
              ld    h,a
              ld    (0x78F0),hl
              ld    (0x78F7),hl
              ld    hl,(0x78B1)
              ld    (0x78D6),hl
              call  0x1D91
              ld    hl,(0x78F9)
              ld    (0x78FB),hl
              ld    (0x78FD),hl
              call  0x79BB
              pop   bc
              ld    hl,(0x78A0)
              dec   hl
              dec   hl
              ld    (0x78E8),hl
              inc   hl
              inc   hl
              ld    sp,hl
              ld    hl,0x78B5
              ld    (0x78B3),hl
              call  OUTPUT_SCREEN_SELECT
              call  0x2169
              xor   a
              ld    h,a
              ld    l,a
              ld    (0x78DC),a
              push  hl
              push  bc
              ld    hl,(0x78DF)
              ret   
              ld    a,0x3F
              call  CHAR_OUTPUT_DISPATCH
              ld    a,0x20
              call  CHAR_OUTPUT_DISPATCH
              jp    0x053A
              xor   a
              ld    (0x78B0),a
              ld    c,a
              ex    de,hl
              ld    hl,(0x78A7)
              dec   hl
              dec   hl
              ex    de,hl
              ld    a,(hl)
              cp    0x20
              jp    z,0x1C5B
              ld    b,a
              cp    0x22
              jp    z,0x1C77
              or    a
              jp    z,0x1C7D
              ld    a,(0x78B0)
              or    a
              ld    a,(hl)
              jp    nz,0x1C5B
              cp    0x3F
              ld    a,0xB2
              jp    z,0x1C5B
              ld    a,(hl)
              cp    0x30
              jr    c,$+7
              cp    0x3C
              jp    c,0x1C5B
              push  de
              ld    de,0x164F
              push  bc
              ld    bc,0x1C3D
              push  bc
              ld    b,0x7F
              ld    a,(hl)
              cp    0x61
              jr    c,$+9
              cp    0x7B
              jr    nc,$+5
              and   0x5F
              ld    (hl),a
              ld    c,(hl)
              ex    de,hl
              inc   hl
              or    (hl)
              jp    p,0x1C0E
              inc   b
              ld    a,(hl)
              and   0x7F
              ret   z
              cp    c
              jr    nz,$-11
              ex    de,hl
              push  hl
              inc   de
              ld    a,(de)
              or    a
              jp    m,0x1C39
              ld    c,a
              ld    a,b
              cp    0x8D
              jr    nz,$+4
              rst   0x10
              dec   hl
              inc   hl
              ld    a,(hl)
              cp    0x61
              jr    c,$+4
              and   0x5F
              cp    c
              jr    z,$-23
              pop   hl
              jr    $-43
              ld    c,b
              pop   af
              ex    de,hl
              ret   
              ex    de,hl
              ld    a,c
              pop   bc
              pop   de
              ex    de,hl
              cp    0x95
              ld    (hl),0x3A
              jr    nz,$+4
              inc   c
              inc   hl
              cp    0xFB
              jr    nz,$+14
              ld    (hl),0x3A
              inc   hl
              ld    b,0x93
              ld    (hl),b
              inc   hl
              ex    de,hl
              inc   c
              inc   c
              jr    $+31
              ex    de,hl
              inc   hl
              ld    (de),a
              inc   de
              inc   c
              sub   0x3A
              jr    z,$+6
              cp    0x4E
              jr    nz,$+5
              ld    (0x78B0),a
              sub   0x59
              jp    nz,0x1BCC
              ld    b,a
              ld    a,(hl)
              or    a
              jr    z,$+11
              cp    b
              jr    z,$-26
              inc   hl
              ld    (de),a
              inc   c
              inc   de
              jr    $-11
              ld    hl,0x0005
              ld    b,h
              add   hl,bc
              ld    b,h
              ld    c,l
              ld    hl,(0x78A7)
              dec   hl
              dec   hl
              dec   hl
              ld    (de),a
              inc   de
              ld    (de),a
              inc   de
              ld    (de),a
              ret   
              ld    a,h
              sub   d
              ret   nz
              ld    a,l
              sub   e
              ret   
              ld    a,(hl)
              ex    (sp),hl
              cp    (hl)
              inc   hl
              ex    (sp),hl
              jp    z,0x1D78
              jp    0x1997
              ld    a,0x64
              ld    (0x78DC),a
              call  0x1F21
              ex    (sp),hl
              call  0x1936
              pop   de
              jr    nz,$+7
              add   hl,bc
              ld    sp,hl
              ld    (0x78E8),hl
              ex    de,hl
              ld    c,0x08
              call  0x1963
              push  hl
              call  0x1F05
              ex    (sp),hl
              push  hl
              ld    hl,(0x78A2)
              ex    (sp),hl
              rst   8
              cp    l
              rst   0x20
              jp    z,TMERR
              jp    nc,TMERR
              push  af
              call  0x2337
              pop   af
              push  hl
              jp    p,0x1CEC
              call  FRCINT
              ex    (sp),hl
              ld    de,0x0001
              ld    a,(hl)
              cp    0xCC
              call  z,0x2B01
              push  de
              push  hl
              ex    de,hl
              call  ISIGN
              jr    $+36
              call  FRCSNG
              call  MOVRF
              pop   hl
              push  bc
              push  de
              ld    bc,0x8100
              ld    d,c
              ld    e,d
              ld    a,(hl)
              cp    0xCC
              ld    a,0x01
              jr    nz,$+16
              call  0x2338
              push  hl
              call  FRCSNG
              call  MOVRF
              call  SIGN
              pop   hl
              push  bc
              push  de
              ld    c,a
              rst   0x20
              ld    b,a
              push  bc
              push  hl
              ld    hl,(0x78DF)
              ex    (sp),hl
              ld    b,0x81
              push  bc
              inc   sp
              call  KBD_QUERY_WRAP
              or    a
              call  nz,0x1DA0
              ld    (0x78E6),hl
              ld    (0x78E8),sp
              ld    a,(hl)
              cp    0x3A
              jr    z,$+43
              or    a
              jp    nz,0x1997
              inc   hl
              ld    a,(hl)
              inc   hl
              or    (hl)
              jp    z,0x197E
              inc   hl
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              ex    de,hl
              ld    (0x78A2),hl
              ld    a,(0x791B)
              or    a
              jr    z,$+17
              push  de
              ld    a,0x3C
              call  CHAR_OUTPUT_DISPATCH
              call  LINPRT
              ld    a,0x3E
              call  CHAR_OUTPUT_DISPATCH
              pop   de
              ex    de,hl
              rst   0x10
              ld    de,0x1D1E
              push  de
              ret   z
              sub   0x80
              jp    c,0x1F21
              cp    0x3C
              jp    nc,0x2AE7
              rlca  
              ld    c,a
              ld    b,0x00
              ex    de,hl
              ld    hl,0x1822
              add   hl,bc
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              push  bc
              ex    de,hl
              inc   hl
              ld    a,(hl)
              cp    0x3A
              ret   nc
              cp    0x20
              jp    z,0x1D78
              cp    0x0B
              jr    nc,$+7
              cp    0x09
              jp    nc,0x1D78
              cp    0x30
              ccf   
              inc   a
              dec   a
              ret   
              ex    de,hl
              ld    hl,(0x78A4)
              dec   hl
              ld    (0x78FF),hl
              ex    de,hl
              ret   
              call  KBD_QUERY_WRAP
              or    a
              ret   z
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    (0x7899),a
              dec   a
              ret   nz
              inc   a
              jp    0x1DB4
              ret   nz
              push  af
              call  z,0x79BB
              pop   af
              ld    (0x78E6),hl
              ld    hl,0x78B5
              ld    (0x78B3),hl
              ld    hl,0xFFF6
              pop   bc
              ld    hl,(0x78A2)
              push  hl
              push  af
              ld    a,l
              and   h
              inc   a
              jr    z,$+11
              ld    (0x78F5),hl
              ld    hl,(0x78E6)
              ld    (0x78F7),hl
              call  OUTPUT_SCREEN_SELECT
              call  0x20F9
              pop   af
              ld    hl,0x1930
              jp    nz,0x1A06
              jp    0x1A18
              ld    hl,(0x78F7)
              ld    a,h
              or    l
              ld    e,0x20
              jp    z,0x19A2
              ex    de,hl
              ld    hl,(0x78F5)
              ld    (0x78A2),hl
              ex    de,hl
              ret   
              ld    a,0xAF
              ld    (0x791B),a
              ret   
              pop   af
              pop   hl
              ret   
              ld    e,0x03
              ld    bc,0x021E
              ld    bc,0x041E
              ld    bc,0x081E
              call  0x1E3D
              ld    bc,0x1997
              push  bc
              ret   c
              sub   0x41
              ld    c,a
              ld    b,a
              rst   0x10
              cp    0xCE
              jr    nz,$+11
              rst   0x10
              call  0x1E3D
              ret   c
              sub   0x41
              ld    b,a
              rst   0x10
              ld    a,b
              sub   c
              ret   c
              inc   a
              ex    (sp),hl
              ld    hl,0x7901
              ld    b,0x00
              add   hl,bc
              ld    (hl),e
              inc   hl
              dec   a
              jr    nz,$-3
              pop   hl
              ld    a,(hl)
              cp    0x2C
              ret   nz
              rst   0x10
              jr    $-48
              ld    a,(hl)
              cp    0x41
              ret   c
              cp    0x5B
              ccf   
              ret   
              rst   0x10
              call  0x2B02
              ret   p
              ld    e,0x08
              jp    0x19A2
              ld    a,(hl)
              cp    0x2E
              ex    de,hl
              ld    hl,(0x78EC)
              ex    de,hl
              jp    z,0x1D78
              dec   hl
              ld    de,START
              rst   0x10
              ret   nc
              push  hl
              push  af
              ld    hl,0x1998
              rst   0x18
              jp    c,0x1997
              ld    h,d
              ld    l,e
              add   hl,de
              add   hl,hl
              add   hl,de
              add   hl,hl
              pop   af
              sub   0x30
              ld    e,a
              ld    d,0x00
              add   hl,de
              ex    de,hl
              pop   hl
              jr    $-26
              jp    z,0x1B61
              call  0x1E46
              dec   hl
              rst   0x10
              ret   nz
              push  hl
              ld    hl,(0x78B1)
              ld    a,l
              sub   e
              ld    e,a
              ld    a,h
              sbc   a,d
              ld    d,a
              jp    c,0x197A
              ld    hl,(0x78F9)
              ld    bc,RST28_VEC
              add   hl,bc
              rst   0x18
              jp    nc,0x197A
              ex    de,hl
              ld    (0x78A0),hl
              pop   hl
              jp    0x1B61
              jp    z,0x1B5D
              call  0x79C7
              call  0x1B61
              ld    bc,0x1D1E
              jr    $+18
              ld    c,0x03
              call  0x1963
              pop   bc
              push  hl
              push  hl
              ld    hl,(0x78A2)
              ex    (sp),hl
              ld    a,0x91
              push  af
              inc   sp
              push  bc
              call  0x1E5A
              call  0x1F07
              push  hl
              ld    hl,(0x78A2)
              rst   0x18
              pop   hl
              inc   hl
              call  c,0x1B2F
              call  nc,0x1B2C
              ld    h,b
              ld    l,c
              dec   hl
              ret   c
              ld    e,0x0E
              jp    0x19A2
              ret   nz
              ld    d,0xFF
              call  0x1936
              ld    sp,hl
              ld    (0x78E8),hl
              cp    0x91
              ld    e,0x04
              jp    nz,0x19A2
              pop   hl
              ld    (0x78A2),hl
              inc   hl
              ld    a,h
              or    l
              jr    nz,$+9
              ld    a,(0x78DD)
              or    a
              jp    nz,0x1A18
              ld    hl,0x1D1E
              ex    (sp),hl
              ld    a,0xE1
              ld    bc,0x0E3A
              nop   
              ld    b,0x00
              ld    a,c
              ld    c,b
              ld    b,a
              ld    a,(hl)
              or    a
              ret   z
              cp    b
              ret   z
              inc   hl
              cp    0x22
              jr    z,$-11
              sub   0x8F
              jr    nz,$-12
              cp    b
              adc   a,d
              ld    d,a
              jr    $-17
              call  0x260D
              rst   8
              push  de
              ex    de,hl
              ld    (0x78DF),hl
              ex    de,hl
              push  de
              rst   0x20
              push  af
              call  0x2337
              pop   af
              ex    (sp),hl
              add   a,0x03
              call  0x2819
              call  VDFACS
              push  hl
              jr    nz,$+42
              ld    hl,(FACLO)
              push  hl
              inc   hl
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              ld    hl,(0x78A4)
              rst   0x18
              jr    nc,$+16
              ld    hl,(0x78A0)
              rst   0x18
              pop   de
              jr    nc,$+17
              ld    hl,(0x78F9)
              rst   0x18
              jr    nc,$+11
              ld    a,0xD1
              call  0x29F5
              ex    de,hl
              call  0x2843
              call  0x29F5
              ex    (sp),hl
              call  VMOVE
              pop   de
              pop   hl
              ret   
              cp    0x9E
              jr    nz,$+39
              rst   0x10
              rst   8
              adc   a,l
              call  0x1E5A
              ld    a,d
              or    e
              jr    z,$+11
              call  0x1B2A
              ld    d,b
              ld    e,c
              pop   hl
              jp    nc,0x1ED9
              ex    de,hl
              ld    (0x78F0),hl
              ex    de,hl
              ret   c
              ld    a,(0x78F2)
              or    a
              ret   z
              ld    a,(0x789A)
              ld    e,a
              jp    0x19AB
              call  0x2B1C
              ld    a,(hl)
              ld    b,a
              cp    0x91
              jr    z,$+5
              rst   8
              adc   a,l
              dec   hl
              ld    c,e
              dec   c
              ld    a,b
              jp    z,0x1D60
              call  0x1E5B
              cp    0x2C
              ret   nz
              jr    $-11
              ld    de,0x78F2
              ld    a,(de)
              or    a
              jp    z,0x19A0
              inc   a
              ld    (0x789A),a
              ld    (de),a
              ld    a,(hl)
              cp    0x87
              jr    z,$+14
              call  0x1E5A
              ret   nz
              ld    a,d
              or    e
              jp    nz,0x1EC5
              inc   a
              jr    $+4
              rst   0x10
              ret   nz
              ld    hl,(0x78EE)
              ex    de,hl
              ld    hl,(0x78EA)
              ld    (0x78A2),hl
              ex    de,hl
              ret   nz
              ld    a,(hl)
              or    a
              jr    nz,$+6
              inc   hl
              inc   hl
              inc   hl
              inc   hl
              inc   hl
              ld    a,d
              and   e
              inc   a
              jp    nz,0x1F05
              ld    a,(0x78DD)
              dec   a
              jp    z,0x1DBE
              jp    0x1F05
              call  0x2B1C
              ret   nz
              or    a
              jp    z,0x1E4A
              dec   a
              add   a,a
              ld    e,a
              cp    0x2D
              jr    c,$+4
              ld    e,0x26
              jp    0x19A2
              ld    de,0x000A
              push  de
              jr    z,$+25
              call  0x1E4F
              ex    de,hl
              ex    (sp),hl
              jr    z,$+19
              ex    de,hl
              rst   8
              inc   l
              ex    de,hl
              ld    hl,(0x78E4)
              ex    de,hl
              jr    z,$+8
              call  0x1E5A
              jp    nz,0x1997
              ex    de,hl
              ld    a,h
              or    l
              jp    z,0x1E4A
              ld    (0x78E4),hl
              ld    (0x78E1),a
              pop   hl
              ld    (0x78E2),hl
              pop   bc
              jp    0x1A33
              call  0x2337
              ld    a,(hl)
              cp    0x2C
              call  z,0x1D78
              cp    0xCA
              call  z,0x1D78
              dec   hl
              push  hl
              call  VSIGN
              pop   hl
              jr    z,$+9
              rst   0x10
              jp    c,0x1EC2
              jp    0x1D5F
              ld    d,0x01
              call  0x1F05
              or    a
              ret   z
              rst   0x10
              cp    0x95
              jr    nz,$-8
              dec   d
              jr    nz,$-11
              jr    $-22
              ld    a,0x01
              ld    (0x789C),a
              jp    0x209B
              call  0x79CA
              cp    0x40
              jr    nz,$+27
              call  0x2B01
              cp    0x02
              jp    nc,0x1E4A
              push  hl
              ld    hl,0x7000
              add   hl,de
              ld    (0x7820),hl
              ld    a,e
              and   0x1F
              ld    (0x78A6),a
              pop   hl
              rst   8
              inc   l
              cp    0x23
              jr    nz,$+10
              call  0x3B58
              ld    a,0x80
              ld    (0x789C),a
              dec   hl
              rst   0x10
              call  z,0x20FE
              jp    z,0x2169
              cp    0xBF
              jp    z,0x2CBD
              cp    0xBC
              jp    z,0x2137
              push  hl
              cp    0x2C
              jp    z,0x2108
              cp    0x3B
              jp    z,0x3B0C
              pop   bc
              call  0x2337
              push  hl
              rst   0x20
              jr    z,$+52
              call  PUSTR_UNFORM_INIT
              call  0x2865
              call  0x79CD
              ld    hl,(FACLO)
              ld    a,(0x789C)
              or    a
              jp    m,0x20E9
              jr    z,$+10
              ld    a,(0x789B)
              add   a,(hl)
              cp    0x84
              jr    $+11
              ld    a,(0x789D)
              ld    b,a
              ld    a,(0x78A6)
              add   a,(hl)
              cp    b
              call  nc,0x20FE
              call  0x28AA
              ld    a,0x20
              call  CHAR_OUTPUT_DISPATCH
              or    a
              call  z,0x28AA
              pop   hl
              jp    0x209B
              call  0x3B1C
              or    a
              ret   z
              ld    a,0x0D
              call  CHAR_OUTPUT_DISPATCH
              call  0x79D0
              xor   a
              ret   
              call  0x79D3
              ld    a,(0x789C)
              or    a
              jp    p,0x2119
              ld    a,0x2C
              call  CHAR_OUTPUT_DISPATCH
              jr    $+77
              jr    z,$+10
              ld    a,(0x789B)
              cp    0x70
              jp    0x212B
              ld    a,(0x789E)
              ld    b,a
              ld    a,(0x7AAE)
              cp    b
              call  nc,0x20FE
              jr    nc,$+54
              sub   0x10
              jr    nc,$-2
              cpl   
              jr    $+37
              call  0x2B1B
              and   0x3F
              ld    e,a
              rst   8
              add   hl,hl
              dec   hl
              push  hl
              call  0x79D3
              ld    a,(0x789C)
              or    a
              jp    m,0x1E4A
              jp    z,0x2153
              ld    a,(0x789B)
              jr    $+5
              ld    a,(0x78A6)
              cpl   
              add   a,e
              jr    nc,$+12
              inc   a
              ld    b,a
              ld    a,0x20
              call  CHAR_OUTPUT_DISPATCH
              dec   b
              jr    nz,$-4
              pop   hl
              rst   0x10
              jp    0x20A0
              ld    a,(0x789C)
              nop   
              nop   
              nop   
              nop   
              xor   a
              ld    (0x789C),a
              call  0x79BE
              ret   
              ccf   
              ld    d,d
              ld    b,l
              ld    b,h
              ld    c,a
              dec   c
              nop   
              ld    a,(0x78DE)
              or    a
              jp    nz,0x1991
              ld    a,(0x78A9)
              or    a
              ld    e,0x2A
              jp    z,0x19A2
              pop   bc
              ld    hl,0x2178
              call  OUTSTR
              ld    hl,(0x78E6)
              ret   
              call  0x2828
              ld    a,(hl)
              call  0x79D6
              sub   0x23
              ld    (0x78A9),a
              ld    a,(hl)
              jr    nz,$+34
              call  0x3B68
              push  hl
              ld    b,0xFA
              ld    hl,(0x78A7)
              call  0x3B88
              ld    (hl),a
              inc   hl
              cp    0x0D
              jr    z,$+4
              djnz  $-9
              dec   hl
              ld    (hl),0x00
              nop   
              nop   
              nop   
              ld    hl,(0x78A7)
              dec   hl
              jr    $+36
              ld    bc,0x21DB
              push  bc
              cp    0x22
              ret   nz
              call  0x2866
              rst   8
              dec   sp
              push  hl
              call  0x28AA
              pop   hl
              ret   
              push  hl
              call  0x1BB3
              pop   bc
              jp    c,0x1DBE
              inc   hl
              ld    a,(hl)
              or    a
              dec   hl
              push  bc
              jp    z,0x1F04
              ld    (hl),0x2C
              jr    $+7
              push  hl
              ld    hl,(0x78FF)
              or    0xAF
              ld    (0x78DE),a
              ex    (sp),hl
              jr    $+4
              rst   8
              inc   l
              call  0x260D
              ex    (sp),hl
              push  de
              ld    a,(hl)
              cp    0x2C
              jr    z,$+40
              ld    a,(0x78DE)
              or    a
              jp    nz,0x2296
              ld    a,(0x78A9)
              or    a
              ld    e,0x06
              jp    z,0x19A2
              ld    a,0x3F
              call  CHAR_OUTPUT_DISPATCH
              call  0x1BB3
              pop   de
              pop   bc
              jp    c,0x1DBE
              inc   hl
              ld    a,(hl)
              or    a
              dec   hl
              push  bc
              jp    z,0x1F04
              push  de
              call  0x79DC
              rst   0x20
              push  af
              jr    nz,$+27
              rst   0x10
              ld    d,a
              ld    b,a
              cp    0x22
              jr    z,$+7
              ld    d,0x3A
              ld    b,0x2C
              dec   hl
              call  0x2869
              pop   af
              ex    de,hl
              ld    hl,0x225A
              ex    (sp),hl
              push  de
              jp    0x1F33
              rst   0x10
              pop   af
              push  af
              ld    bc,0x2243
              push  bc
              jp    c,FIN
              jp    nc,STR_TO_DOUBLE
              dec   hl
              rst   0x10
              jr    z,$+7
              cp    0x2C
              jp    nz,0x217F
              ex    (sp),hl
              dec   hl
              rst   0x10
              jp    nz,0x21FB
              pop   de
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    a,(0x78DE)
              or    a
              ex    de,hl
              jp    nz,0x1D96
              push  de
              call  0x79DF
              or    (hl)
              ld    hl,0x2286
              call  nz,OUTSTR
              pop   hl
              jp    0x2169
              ccf   
              ld    b,l
              ld    e,b
              ld    d,h
              ld    d,d
              ld    b,c
              jr    nz,$+75
              ld    b,a
              ld    c,(hl)
              ld    c,a
              ld    d,d
              ld    b,l
              ld    b,h
              dec   c
              nop   
              call  0x1F05
              or    a
              jr    nz,$+20
              inc   hl
              ld    a,(hl)
              inc   hl
              or    (hl)
              ld    e,0x06
              jp    z,0x19A2
              inc   hl
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              ex    de,hl
              ld    (0x78DA),hl
              ex    de,hl
              rst   0x10
              cp    0x88
              jr    nz,$-27
              jp    0x222D
              ld    de,START
              call  nz,0x260D
              ld    (0x78DF),hl
              call  0x1936
              jp    nz,0x199D
              ld    sp,hl
              ld    (0x78E8),hl
              push  de
              ld    a,(hl)
              inc   hl
              push  af
              push  de
              ld    a,(hl)
              inc   hl
              or    a
              jp    m,0x22EA
              call  MOVFM
              ex    (sp),hl
              push  hl
              call  0x070B
              pop   hl
              call  MOVMF
              pop   hl
              call  MOVRM
              push  hl
              call  FCOMP
              jr    $+43
              inc   hl
              inc   hl
              inc   hl
              inc   hl
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              inc   hl
              ex    (sp),hl
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              push  hl
              ld    l,c
              ld    h,b
              call  IADD
              ld    a,(VALTYP)
              cp    0x04
              jp    z,0x07B2
              ex    de,hl
              pop   hl
              ld    (hl),d
              dec   hl
              ld    (hl),e
              pop   hl
              push  de
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              inc   hl
              ex    (sp),hl
              call  DCOMP
              pop   hl
              pop   bc
              sub   b
              call  MOVRM
              jr    z,$+11
              ex    de,hl
              ld    (0x78A2),hl
              ld    l,c
              ld    h,b
              jp    0x1D1A
              ld    sp,hl
              ld    (0x78E8),hl
              ld    hl,(0x78DF)
              ld    a,(hl)
              cp    0x2C
              jp    nz,0x1D1E
              rst   0x10
              call  0x22B9
              rst   8
              jr    z,$+45
              ld    d,0x00
              push  de
              ld    c,0x01
              call  0x1963
              call  0x249F
              ld    (0x78F3),hl
              ld    hl,(0x78F3)
              pop   bc
              ld    a,(hl)
              ld    d,0x00
              sub   0xD4
              jr    c,$+21
              cp    0x03
              jr    nc,$+17
              cp    0x01
              rla   
              xor   d
              cp    d
              ld    d,a
              jp    c,0x1997
              ld    (FMT_FLAG),hl
              rst   0x10
              jr    $-21
              ld    a,d
              or    a
              jp    nz,0x23EC
              ld    a,(hl)
              ld    (FMT_FLAG),hl
              sub   0xCD
              ret   c
              cp    0x07
              ret   nc
              ld    e,a
              ld    a,(VALTYP)
              sub   0x03
              or    e
              jp    z,0x298F
              ld    hl,0x189A
              add   hl,de
              ld    a,b
              ld    d,(hl)
              cp    d
              ret   nc
              push  bc
              ld    bc,0x2346
              push  bc
              ld    a,d
              cp    0x7F
              jp    z,0x23D4
              cp    0x51
              jp    c,0x23E1
              ld    hl,FACLO
              or    a
              ld    a,(VALTYP)
              dec   a
              dec   a
              dec   a
              jp    z,TMERR
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              push  bc
              jp    m,0x23C5
              inc   hl
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              push  bc
              push  af
              or    a
              jp    po,0x23C4
              pop   af
              inc   hl
              jr    c,$+5
              ld    hl,0x791D
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              inc   hl
              push  bc
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              push  bc
              ld    b,0xF1
              add   a,0x03
              ld    c,e
              ld    b,a
              push  bc
              ld    bc,0x2406
              push  bc
              ld    hl,(FMT_FLAG)
              jp    0x233A
              call  FRCSNG
              call  PUSHF
              ld    bc,0x13F2
              ld    d,0x7F
              jr    $-18
              push  de
              call  FRCINT
              pop   de
              push  hl
              ld    bc,0x25E9
              jr    $-29
              ld    a,b
              cp    0x64
              ret   nc
              push  bc
              push  de
              ld    de,0x6404
              ld    hl,0x25B8
              push  hl
              rst   0x20
              jp    nz,0x2395
              ld    hl,(FACLO)
              push  hl
              ld    bc,0x258C
              jr    $-55
              pop   bc
              ld    a,c
              ld    (0x78B0),a
              ld    a,b
              cp    0x08
              jr    z,$+42
              ld    a,(VALTYP)
              cp    0x08
              jp    z,0x2460
              ld    d,a
              ld    a,b
              cp    0x04
              jp    z,0x2472
              ld    a,d
              cp    0x03
              jp    z,TMERR
              jp    nc,0x247C
              ld    hl,0x18BF
              ld    b,0x00
              add   hl,bc
              add   hl,bc
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              pop   de
              ld    hl,(FACLO)
              push  bc
              ret   
              call  FRCDBL
              call  VMOVAF
              pop   hl
              ld    (0x791F),hl
              pop   hl
              ld    (0x791D),hl
              pop   bc
              pop   de
              call  MOVFR
              call  FRCDBL
              ld    hl,0x18AB
              ld    a,(0x78B0)
              rlca  
              push  bc
              ld    c,a
              ld    b,0x00
              add   hl,bc
              pop   bc
              ld    a,(hl)
              inc   hl
              ld    h,(hl)
              ld    l,a
              jp    (hl)
              push  bc
              call  VMOVAF
              pop   af
              ld    (VALTYP),a
              cp    0x04
              jr    z,$-36
              pop   hl
              ld    (FACLO),hl
              jr    $-37
              call  FRCSNG
              pop   bc
              pop   de
              ld    hl,0x18B5
              jr    $-41
              pop   hl
              call  PUSHF
              call  0x0ACF
              call  MOVRF
              pop   hl
              ld    (FAC_SIGN),hl
              pop   hl
              ld    (FACLO),hl
              jr    $-23
              push  hl
              ex    de,hl
              call  0x0ACF
              pop   hl
              call  PUSHF
              call  0x0ACF
              jp    0x08A0
              rst   0x10
              ld    e,0x28
              jp    z,0x19A2
              jp    c,FIN
              call  0x1E3D
              jp    nc,0x2540
              cp    0xCD
              jr    z,$-17
              cp    0x2E
              jp    z,FIN
              cp    0xCE
              jp    z,0x2532
              cp    0x22
              jp    z,0x2866
              cp    0xCB
              jp    z,0x25C4
              cp    0x26
              jp    z,0x7994
              cp    0xC3
              jr    nz,$+12
              rst   0x10
              ld    a,(0x789A)
              push  hl
              call  0x27F8
              pop   hl
              ret   
              cp    0xC2
              jr    nz,$+12
              rst   0x10
              push  hl
              ld    hl,(0x78EA)
              call  INEG_OVERFLOW
              pop   hl
              ret   
              cp    0xC0
              jr    nz,$+22
              rst   0x10
              rst   8
              jr    z,$-49
              dec   c
              ld    h,0xCF
              add   hl,hl
              push  hl
              ex    de,hl
              ld    a,h
              or    l
              jp    z,0x1E4A
              call  MAKINT
              pop   hl
              ret   
              cp    0xC1
              jp    z,0x27FE
              cp    0xC5
              jp    z,0x799D
              cp    0xC8
              jp    z,0x27C9
              cp    0xC7
              jp    z,0x7976
              cp    0xC6
              jp    z,POINT
              cp    0xC9
              jp    z,0x019D
              cp    0xC4
              jp    z,0x2A2F
              cp    0xBE
              jp    z,0x7955
              sub   0xD7
              jp    nc,0x254E
              call  0x2335
              rst   8
              add   hl,hl
              ret   
              ld    d,0x7D
              call  0x233A
              ld    hl,(0x78F3)
              push  hl
              call  VNEG
              pop   hl
              ret   
              call  0x260D
              push  hl
              ex    de,hl
              ld    (FACLO),hl
              rst   0x20
              call  nz,VMOVFM
              pop   hl
              ret   
              ld    b,0x00
              rlca  
              ld    c,a
              push  bc
              rst   0x10
              ld    a,c
              cp    0x41
              jr    c,$+24
              call  0x2335
              rst   8
              inc   l
              call  CHKSTR
              ex    de,hl
              ld    hl,(FACLO)
              ex    (sp),hl
              push  hl
              ex    de,hl
              call  0x2B1C
              ex    de,hl
              ex    (sp),hl
              jr    $+22
              call  0x252C
              ex    (sp),hl
              ld    a,l
              cp    0x0C
              jr    c,$+9
              cp    0x1B
              push  hl
              call  c,FRCSNG
              pop   hl
              ld    de,0x253E
              push  de
              ld    bc,0x1608
              add   hl,bc
              ld    c,(hl)
              inc   hl
              ld    h,(hl)
              ld    l,c
              jp    (hl)
              call  0x29D7
              ld    a,(hl)
              inc   hl
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              pop   de
              push  bc
              push  af
              call  0x29DE
              pop   de
              ld    e,(hl)
              inc   hl
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              pop   hl
              ld    a,e
              or    d
              ret   z
              ld    a,d
              sub   0x01
              ret   c
              xor   a
              cp    e
              inc   a
              ret   nc
              dec   d
              dec   e
              ld    a,(bc)
              cp    (hl)
              inc   hl
              inc   bc
              jr    z,$-17
              ccf   
              jp    SIGNS
              inc   a
              adc   a,a
              pop   bc
              and   b
              add   a,0xFF
              sbc   a,a
              call  CONIA
              jr    $+20
              ld    d,0x5A
              call  0x233A
              call  FRCINT
              ld    a,l
              cpl   
              ld    l,a
              ld    a,h
              cpl   
              ld    h,a
              ld    (FACLO),hl
              pop   bc
              jp    0x2346
              ld    a,(VALTYP)
              cp    0x08
              jr    nc,$+7
              sub   0x03
              or    a
              scf   
              ret   
              sub   0x03
              or    a
              ret   
              push  bc
              call  FRCINT
              pop   af
              pop   de
              ld    bc,0x27FA
              push  bc
              cp    0x46
              jr    nz,$+8
              ld    a,e
              or    l
              ld    l,a
              ld    a,h
              or    d
              ret   
              ld    a,e
              and   l
              ld    l,a
              ld    a,h
              and   d
              ret   
              dec   hl
              rst   0x10
              ret   z
              rst   8
              inc   l
              ld    bc,0x2603
              push  bc
              or    0xAF
              ld    (0x78AE),a
              ld    b,(hl)
              call  0x1E3D
              jp    c,0x1997
              xor   a
              ld    c,a
              rst   0x10
              jr    c,$+7
              call  0x1E3D
              jr    c,$+11
              ld    c,a
              rst   0x10
              jr    c,$-1
              call  0x1E3D
              jr    nc,$-6
              ld    de,0x2652
              push  de
              ld    d,0x02
              cp    0x25
              ret   z
              inc   d
              cp    0x24
              ret   z
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    a,b
              sub   0x41
              and   0x7F
              ld    e,a
              ld    d,0x00
              push  hl
              ld    hl,0x7901
              add   hl,de
              ld    d,(hl)
              pop   hl
              dec   hl
              ret   
              ld    a,d
              ld    (VALTYP),a
              rst   0x10
              ld    a,(0x78DC)
              or    a
              jp    nz,0x2664
              ld    a,(hl)
              sub   0x28
              jp    z,0x26E9
              xor   a
              ld    (0x78DC),a
              push  hl
              push  de
              ld    hl,(0x78F9)
              ex    de,hl
              ld    hl,(0x78FB)
              rst   0x18
              pop   hl
              jr    z,$+27
              ld    a,(de)
              ld    l,a
              cp    h
              inc   de
              jr    nz,$+13
              ld    a,(de)
              cp    c
              jr    nz,$+9
              inc   de
              ld    a,(de)
              cp    b
              jp    z,0x26CC
              ld    a,0x13
              inc   de
              push  hl
              ld    h,0x00
              add   hl,de
              jr    $-31
              ld    a,h
              pop   hl
              ex    (sp),hl
              push  af
              push  de
              ld    de,0x24F1
              rst   0x18
              jr    z,$+56
              ld    de,0x2543
              rst   0x18
              pop   de
              jr    z,$+55
              pop   af
              ex    (sp),hl
              push  hl
              push  bc
              ld    c,a
              ld    b,0x00
              push  bc
              inc   bc
              inc   bc
              inc   bc
              ld    hl,(0x78FD)
              push  hl
              add   hl,bc
              pop   bc
              push  hl
              call  0x1955
              pop   hl
              ld    (0x78FD),hl
              ld    h,b
              ld    l,c
              ld    (0x78FB),hl
              dec   hl
              ld    (hl),0x00
              rst   0x18
              jr    nz,$-4
              pop   de
              ld    (hl),e
              inc   hl
              pop   de
              ld    (hl),e
              inc   hl
              ld    (hl),d
              ex    de,hl
              inc   de
              pop   hl
              ret   
              ld    d,a
              ld    e,a
              pop   af
              pop   af
              ex    (sp),hl
              ret   
              ld    (FAC),a
              pop   bc
              ld    h,a
              ld    l,a
              ld    (FACLO),hl
              rst   0x20
              jr    nz,$+8
              ld    hl,0x1928
              ld    (FACLO),hl
              pop   hl
              ret   
              push  hl
              ld    hl,(0x78AE)
              ex    (sp),hl
              ld    d,a
              push  de
              push  bc
              call  0x1E45
              pop   bc
              pop   af
              ex    de,hl
              ex    (sp),hl
              push  hl
              ex    de,hl
              inc   a
              ld    d,a
              ld    a,(hl)
              cp    0x2C
              jr    z,$-16
              rst   8
              add   hl,hl
              ld    (0x78F3),hl
              pop   hl
              ld    (0x78AE),hl
              push  de
              ld    hl,(0x78FB)
              ld    a,0x19
              ex    de,hl
              ld    hl,(0x78FD)
              ex    de,hl
              rst   0x18
              ld    a,(VALTYP)
              jr    z,$+41
              cp    (hl)
              inc   hl
              jr    nz,$+10
              ld    a,(hl)
              cp    c
              inc   hl
              jr    nz,$+6
              ld    a,(hl)
              cp    b
              ld    a,0x23
              inc   hl
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              inc   hl
              jr    nz,$-30
              ld    a,(0x78AE)
              or    a
              ld    e,0x12
              jp    nz,0x19A2
              pop   af
              sub   (hl)
              jp    z,0x2795
              ld    e,0x10
              jp    0x19A2
              ld    (hl),a
              inc   hl
              ld    e,a
              ld    d,0x00
              pop   af
              ld    (hl),c
              inc   hl
              ld    (hl),b
              inc   hl
              ld    c,a
              call  0x1963
              inc   hl
              inc   hl
              ld    (FMT_FLAG),hl
              ld    (hl),c
              inc   hl
              ld    a,(0x78AE)
              rla   
              ld    a,c
              ld    bc,ROMRET
              jr    nc,$+4
              pop   bc
              inc   bc
              ld    (hl),c
              inc   hl
              ld    (hl),b
              inc   hl
              push  af
              call  UMULT
              pop   af
              dec   a
              jr    nz,$-17
              push  af
              ld    b,d
              ld    c,e
              ex    de,hl
              add   hl,de
              jr    c,$-55
              call  0x196C
              ld    (0x78FD),hl
              dec   hl
              ld    (hl),0x00
              rst   0x18
              jr    nz,$-4
              inc   bc
              ld    d,a
              ld    hl,(FMT_FLAG)
              ld    e,(hl)
              ex    de,hl
              add   hl,hl
              add   hl,bc
              ex    de,hl
              dec   hl
              dec   hl
              ld    (hl),e
              inc   hl
              ld    (hl),d
              inc   hl
              pop   af
              jr    c,$+50
              ld    b,a
              ld    c,a
              ld    a,(hl)
              inc   hl
              ld    d,0xE1
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              inc   hl
              ex    (sp),hl
              push  af
              rst   0x18
              jp    nc,0x273D
              call  UMULT
              add   hl,de
              pop   af
              dec   a
              ld    b,h
              ld    c,l
              jr    nz,$-19
              ld    a,(VALTYP)
              ld    b,h
              ld    c,l
              add   hl,hl
              sub   0x04
              jr    c,$+6
              add   hl,hl
              jr    z,$+8
              add   hl,hl
              or    a
              jp    po,0x27C2
              add   hl,bc
              pop   bc
              add   hl,bc
              ex    de,hl
              ld    hl,(0x78F3)
              ret   
              xor   a
              push  hl
              ld    (VALTYP),a
              call  0x27D4
              pop   hl
              rst   0x10
              ret   
              ld    hl,(0x78FD)
              ex    de,hl
              ld    hl,START
              add   hl,sp
              rst   0x20
              jr    nz,$+15
              call  0x29DA
              call  0x28E6
              ld    hl,(0x78A0)
              ex    de,hl
              ld    hl,(0x78D6)
              ld    a,l
              sub   e
              ld    l,a
              ld    a,h
              sbc   a,d
              ld    h,a
              jp    INEG_OVERFLOW
              ld    a,(0x78A6)
              ld    l,a
              xor   a
              ld    h,a
              jp    MAKINT
              call  0x79A9
              rst   0x10
              call  0x252C
              push  hl
              ld    hl,0x0890
              push  hl
              ld    a,(VALTYP)
              push  af
              cp    0x03
              call  z,0x29DA
              pop   af
              ex    de,hl
              ld    hl,(0x788E)
              jp    (hl)
              push  hl
              and   0x07
              ld    hl,0x18A1
              ld    c,a
              ld    b,0x00
              add   hl,bc
              call  0x2586
              pop   hl
              ret   
              push  hl
              ld    hl,(0x78A2)
              inc   hl
              ld    a,h
              or    l
              pop   hl
              ret   nz
              ld    e,0x16
              jp    0x19A2
              call  PUSTR_UNFORM_INIT
              call  0x2865
              call  0x29DA
              ld    bc,0x2A2B
              push  bc
              ld    a,(hl)
              inc   hl
              push  hl
              call  0x28BF
              pop   hl
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              call  0x285A
              push  hl
              ld    l,a
              call  0x29CE
              pop   de
              ret   
              call  0x28BF
              ld    hl,0x78D3
              push  hl
              ld    (hl),a
              inc   hl
              ld    (hl),e
              inc   hl
              ld    (hl),d
              pop   hl
              ret   
              dec   hl
              ld    b,0x22
              ld    d,b
              push  hl
              ld    c,0xFF
              inc   hl
              ld    a,(hl)
              inc   c
              or    a
              jr    z,$+8
              cp    d
              jr    z,$+5
              cp    b
              jr    nz,$-10
              cp    0x22
              call  z,0x1D78
              ex    (sp),hl
              inc   hl
              ex    de,hl
              ld    a,c
              call  0x285A
              ld    de,0x78D3
              ld    a,0xD5
              ld    hl,(0x78B3)
              ld    (FACLO),hl
              ld    a,0x03
              ld    (VALTYP),a
              call  VMOVE
              ld    de,0x78D6
              rst   0x18
              ld    (0x78B3),hl
              pop   hl
              ld    a,(hl)
              ret   nz
              ld    e,0x1E
              jp    0x19A2
              inc   hl
              call  0x2865
              call  0x29DA
              call  GETBCD
              inc   d
              dec   d
              ret   z
              ld    a,(bc)
              call  CHAR_OUTPUT_DISPATCH
              cp    0x0D
              call  z,0x2103
              inc   bc
              jr    $-12
              or    a
              ld    c,0xF1
              push  af
              ld    hl,(0x78A0)
              ex    de,hl
              ld    hl,(0x78D6)
              cpl   
              ld    c,a
              ld    b,0xFF
              add   hl,bc
              inc   hl
              rst   0x18
              jr    c,$+9
              ld    (0x78D6),hl
              inc   hl
              ex    de,hl
              pop   af
              ret   
              pop   af
              ld    e,0x1A
              jp    z,0x19A2
              cp    a
              push  af
              ld    bc,0x28C1
              push  bc
              ld    hl,(0x78B1)
              ld    (0x78D6),hl
              ld    hl,START
              push  hl
              ld    hl,(0x78A0)
              push  hl
              ld    hl,0x78B5
              ex    de,hl
              ld    hl,(0x78B3)
              ex    de,hl
              rst   0x18
              ld    bc,0x28F7
              jp    nz,0x294A
              ld    hl,(0x78F9)
              ex    de,hl
              ld    hl,(0x78FB)
              ex    de,hl
              rst   0x18
              jr    z,$+21
              ld    a,(hl)
              inc   hl
              inc   hl
              inc   hl
              cp    0x03
              jr    nz,$+6
              call  0x294B
              xor   a
              ld    e,a
              ld    d,0x00
              add   hl,de
              jr    $-24
              pop   bc
              ex    de,hl
              ld    hl,(0x78FD)
              ex    de,hl
              rst   0x18
              jp    z,0x296B
              ld    a,(hl)
              inc   hl
              call  MOVRM
              push  hl
              add   hl,bc
              cp    0x03
              jr    nz,$-19
              ld    (FMT_FLAG),hl
              pop   hl
              ld    c,(hl)
              ld    b,0x00
              add   hl,bc
              add   hl,bc
              inc   hl
              ex    de,hl
              ld    hl,(FMT_FLAG)
              ex    de,hl
              rst   0x18
              jr    z,$-36
              ld    bc,0x293F
              push  bc
              xor   a
              or    (hl)
              inc   hl
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              inc   hl
              ret   z
              ld    b,h
              ld    c,l
              ld    hl,(0x78D6)
              rst   0x18
              ld    h,b
              ld    l,c
              ret   c
              pop   hl
              ex    (sp),hl
              rst   0x18
              ex    (sp),hl
              push  hl
              ld    h,b
              ld    l,c
              ret   nc
              pop   bc
              pop   af
              pop   af
              push  hl
              push  de
              push  bc
              ret   
              pop   de
              pop   hl
              ld    a,l
              or    h
              ret   z
              dec   hl
              ld    b,(hl)
              dec   hl
              ld    c,(hl)
              push  hl
              dec   hl
              ld    l,(hl)
              ld    h,0x00
              add   hl,bc
              ld    d,b
              ld    e,c
              dec   hl
              ld    b,h
              ld    c,l
              ld    hl,(0x78D6)
              call  0x1958
              pop   hl
              ld    (hl),c
              inc   hl
              ld    (hl),b
              ld    l,c
              ld    h,b
              dec   hl
              jp    0x28E9
              push  bc
              push  hl
              ld    hl,(FACLO)
              ex    (sp),hl
              call  0x249F
              ex    (sp),hl
              call  CHKSTR
              ld    a,(hl)
              push  hl
              ld    hl,(FACLO)
              push  hl
              add   a,(hl)
              ld    e,0x1C
              jp    c,0x19A2
              call  0x2857
              pop   de
              call  0x29DE
              ex    (sp),hl
              call  0x29DD
              push  hl
              ld    hl,(0x78D4)
              ex    de,hl
              call  0x29C6
              call  0x29C6
              ld    hl,0x2349
              ex    (sp),hl
              push  hl
              jp    0x2884
              pop   hl
              ex    (sp),hl
              ld    a,(hl)
              inc   hl
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              ld    l,a
              inc   l
              dec   l
              ret   z
              ld    a,(bc)
              ld    (de),a
              inc   bc
              inc   de
              jr    $-6
              call  CHKSTR
              ld    hl,(FACLO)
              ex    de,hl
              call  0x29F5
              ex    de,hl
              ret   nz
              push  de
              ld    d,b
              ld    e,c
              dec   de
              ld    c,(hl)
              ld    hl,(0x78D6)
              rst   0x18
              jr    nz,$+7
              ld    b,a
              add   hl,bc
              ld    (0x78D6),hl
              pop   hl
              ret   
              ld    hl,(0x78B3)
              dec   hl
              ld    b,(hl)
              dec   hl
              ld    c,(hl)
              dec   hl
              rst   0x18
              ret   nz
              ld    (0x78B3),hl
              ret   
              ld    bc,0x27F8
              push  bc
              call  0x29D7
              xor   a
              ld    d,a
              ld    a,(hl)
              or    a
              ret   
              ld    bc,0x27F8
              push  bc
              call  0x2A07
              jp    z,0x1E4A
              inc   hl
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              ld    a,(de)
              ret   
              ld    a,0x01
              call  0x2857
              call  0x2B1F
              ld    hl,(0x78D4)
              ld    (hl),e
              pop   bc
              jp    0x2884
              rst   0x10
              rst   8
              jr    z,$-49
              inc   e
              dec   hl
              push  de
              rst   8
              inc   l
              call  0x2337
              rst   8
              add   hl,hl
              ex    (sp),hl
              push  hl
              rst   0x20
              jr    z,$+7
              call  0x2B1F
              jr    $+5
              call  0x2A13
              pop   de
              push  af
              push  af
              ld    a,e
              call  0x2857
              ld    e,a
              pop   af
              inc   e
              dec   e
              jr    z,$-42
              ld    hl,(0x78D4)
              ld    (hl),a
              inc   hl
              dec   e
              jr    nz,$-3
              jr    $-52
              call  0x2ADF
              xor   a
              ex    (sp),hl
              ld    c,a
              ld    a,0xE5
              push  hl
              ld    a,(hl)
              cp    b
              jr    c,$+4
              ld    a,b
              ld    de,0x000E
              push  bc
              call  0x28BF
              pop   bc
              pop   hl
              push  hl
              inc   hl
              ld    b,(hl)
              inc   hl
              ld    h,(hl)
              ld    l,b
              ld    b,0x00
              add   hl,bc
              ld    b,h
              ld    c,l
              call  0x285A
              ld    l,a
              call  0x29CE
              pop   de
              call  0x29DE
              jp    0x2884
              call  0x2ADF
              pop   de
              push  de
              ld    a,(de)
              sub   b
              jr    $-51
              ex    de,hl
              ld    a,(hl)
              call  0x2AE2
              inc   b
              dec   b
              jp    z,0x1E4A
              push  bc
              ld    e,0xFF
              cp    0x29
              jr    z,$+7
              rst   8
              inc   l
              call  0x2B1C
              rst   8
              add   hl,hl
              pop   af
              ex    (sp),hl
              ld    bc,0x2A69
              push  bc
              dec   a
              cp    (hl)
              ld    b,0x00
              ret   nc
              ld    c,a
              ld    a,(hl)
              sub   c
              cp    e
              ld    b,a
              ret   c
              ld    b,e
              ret   
              call  0x2A07
              jp    z,0x27F8
              ld    e,a
              inc   hl
              ld    a,(hl)
              inc   hl
              ld    h,(hl)
              ld    l,a
              push  hl
              add   hl,de
              ld    b,(hl)
              ld    (hl),d
              ex    (sp),hl
              push  bc
              ld    a,(hl)
              call  STR_TO_DOUBLE
              pop   bc
              pop   hl
              ld    (hl),b
              ret   
              ex    de,hl
              rst   8
              add   hl,hl
              pop   bc
              pop   de
              push  bc
              ld    b,e
              ret   
              cp    0x7A
              jp    nz,0x1997
              jp    0x79D9
              call  0x2B1F
              ld    (0x7894),a
              call  0x7893
              jp    0x27F8
              call  0x2B0E
              jp    0x7896
              rst   0x10
              call  0x2337
              push  hl
              call  FRCINT
              ex    de,hl
              pop   hl
              ld    a,d
              or    a
              ret   
              call  0x2B1C
              ld    (0x7894),a
              ld    (0x7897),a
              rst   8
              inc   l
              jr    $+3
              rst   0x10
              call  0x2337
              call  0x2B05
              jp    nz,0x1E4A
              dec   hl
              rst   0x10
              ld    a,e
              ret   
              ld    a,0x01
              ld    (0x789C),a
              pop   bc
              call  0x1B10
              push  bc
              call  0x3B25
              ld    (0x78A2),hl
              pop   hl
              pop   de
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              inc   hl
              ld    a,b
              or    c
              jp    z,0x1A19
              call  0x79DF
              call  0x1D9B
              push  bc
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              inc   hl
              push  bc
              ex    (sp),hl
              ex    de,hl
              rst   0x18
              pop   bc
              jp    c,0x1A18
              ex    (sp),hl
              push  hl
              push  bc
              ex    de,hl
              ld    (0x78EC),hl
              call  LINPRT
              ld    a,0x20
              pop   hl
              call  CHAR_OUTPUT_DISPATCH
              call  0x2B7E
              ld    hl,(0x78A7)
              call  0x2B75
              call  0x20FE
              jr    $-64
              ld    a,(hl)
              or    a
              ret   z
              call  CHAR_OUTPUT_DISPATCH
              inc   hl
              jr    $-7
              push  hl
              ld    hl,(0x78A7)
              ld    b,h
              ld    c,l
              pop   hl
              ld    d,0xFF
              jr    $+5
              inc   bc
              dec   d
              ret   z
              ld    a,(hl)
              or    a
              inc   hl
              ld    (bc),a
              ret   z
              jp    0x2E9D
              cp    0xFB
              jr    nz,$+10
              dec   bc
              dec   bc
              dec   bc
              dec   bc
              inc   d
              inc   d
              inc   d
              inc   d
              cp    0x95
              call  z,0x0B24
              sub   0x7F
              push  hl
              ld    e,a
              ld    hl,0x1650
              ld    a,(hl)
              or    a
              inc   hl
              jp    p,0x2BAC
              dec   e
              jr    nz,$-7
              and   0x7F
              ld    (bc),a
              inc   bc
              dec   d
              jp    z,0x28D8
              ld    a,(hl)
              inc   hl
              or    a
              jp    p,0x2BB7
              pop   hl
              jr    $-56
              call  0x1B10
              pop   de
              push  bc
              push  bc
              call  0x1B2C
              jr    nc,$+7
              ld    d,h
              ld    e,l
              ex    (sp),hl
              push  hl
              rst   0x18
              jp    nc,0x1E4A
              ld    hl,0x1929
              call  OUTSTR
              pop   bc
              ld    hl,0x1AE8
              ex    (sp),hl
              ex    de,hl
              ld    hl,(0x78F9)
              ld    a,(de)
              ld    (bc),a
              inc   bc
              inc   de
              rst   0x18
              jr    nz,$-5
              ld    h,b
              ld    l,c
              ld    (0x78F9),hl
              ret   
              call  0x2B1C
              cp    0x20
              jp    nc,0x1E4A
              ld    (0x7AD2),a
              rst   8
              inc   l
              call  0x2B1C
              or    a
              jp    z,0x1E4A
              cp    0x0A
              jp    nc,0x1E4A
              di    
              push  hl
              dec   a
              push  af
              ld    a,(0x7AD2)
              or    a
              jr    z,$+66
              dec   a
              sla   a
              ld    c,a
              xor   a
              ld    b,a
              pop   af
              ld    hl,SOUND_FREQ_TABLE
              add   hl,bc
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              push  de
              ld    hl,0x0361
              srl   c
              add   hl,bc
              ld    e,(hl)
              ld    d,0x00
              ld    hl,0x0321
              ld    c,a
              add   hl,bc
              ld    b,(hl)
              push  de
              pop   hl
              add   hl,de
              djnz  $-1
              push  hl
              pop   bc
              pop   hl
              call  0x3AF8
              ld    a,(0x783B)
              ld    d,a
              call  0x3469
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-13
              pop   hl
              ei    
              ld    a,(hl)
              inc   hl
              cp    0x3B
              jp    z,0x2BF5
              dec   hl
              ret   
              pop   af
              ld    c,a
              xor   a
              ld    b,a
              ld    hl,0x0321
              add   hl,bc
              ld    b,(hl)
              ld    hl,0x1936
              push  hl
              pop   de
              add   hl,de
              djnz  $-1
              call  0x3AF8
              dec   hl
              ld    a,l
              or    h
              jr    nz,$-6
              jr    $-36
              push  bc
              ld    b,a
              ld    a,0x08
              call  0x3ABA
              ld    a,b
              and   0x0F
              push  hl
              sla   a
              ld    c,a
              xor   a
              ld    b,a
              ld    hl,PRINTER_GRAPHICS_TABLE
              add   hl,bc
              ld    a,(hl)
              ld    b,a
              inc   hl
              ld    a,(hl)
              ld    c,a
              ld    a,b
              call  0x3ABA
              call  0x3ABA
              call  0x3ABA
              ld    a,c
              call  0x3ABA
              call  0x3ABA
              call  0x3ABA
              pop   hl
              pop   bc
              ld    a,0x0F
              call  0x3ABA
              ret   
              jr    nc,$-97
              call  FRCINT
              ld    a,(hl)
              jp    0x27F8
              call  0x2B02
              push  de
              rst   8
              inc   l
              call  0x2B1C
              pop   de
              ld    (de),a
              ret   
              call  0x2338
              call  CHKSTR
              rst   8
              dec   sp
              ex    de,hl
              ld    hl,(FACLO)
              jr    $+10
              ld    a,(0x78DE)
              or    a
              jr    z,$+14
              pop   de
              ex    de,hl
              push  hl
              xor   a
              ld    (0x78DE),a
              cp    d
              push  af
              push  de
              ld    b,(hl)
              or    b
              jp    z,0x1E4A
              inc   hl
              ld    c,(hl)
              inc   hl
              ld    h,(hl)
              ld    l,c
              jr    $+30
              ld    e,b
              push  hl
              ld    c,0x02
              ld    a,(hl)
              inc   hl
              cp    0x25
              jp    z,0x2E17
              cp    0x20
              jr    nz,$+5
              inc   c
              djnz  $-12
              pop   hl
              ld    b,e
              ld    a,0x25
              call  0x2E49
              call  CHAR_OUTPUT_DISPATCH
              xor   a
              ld    e,a
              ld    d,a
              call  0x2E49
              ld    d,a
              ld    a,(hl)
              inc   hl
              cp    0x21
              jp    z,0x2E14
              cp    0x23
              jr    z,$+57
              dec   b
              jp    z,0x2DFE
              cp    0x2B
              ld    a,0x08
              jr    z,$-23
              dec   hl
              ld    a,(hl)
              inc   hl
              cp    0x2E
              jr    z,$+66
              cp    0x25
              jr    z,$-65
              cp    (hl)
              jr    nz,$-46
              cp    0x24
              jr    z,$+22
              cp    0x2A
              jr    nz,$-54
              ld    a,b
              cp    0x02
              inc   hl
              jr    c,$+5
              ld    a,(hl)
              cp    0x24
              ld    a,0x20
              jr    nz,$+9
              dec   b
              inc   e
              cp    0xAF
              add   a,0x10
              inc   hl
              inc   e
              add   a,d
              ld    d,a
              inc   e
              ld    c,0x00
              dec   b
              jr    z,$+73
              ld    a,(hl)
              inc   hl
              cp    0x2E
              jr    z,$+26
              cp    0x23
              jr    z,$-14
              cp    0x2C
              jr    nz,$+28
              ld    a,d
              or    0x40
              ld    d,a
              jr    $-24
              ld    a,(hl)
              cp    0x23
              ld    a,0x2E
              jr    nz,$-110
              ld    c,0x01
              inc   hl
              inc   c
              dec   b
              jr    z,$+39
              ld    a,(hl)
              inc   hl
              cp    0x23
              jr    z,$-8
              push  de
              ld    de,0x2D97
              push  de
              ld    d,h
              ld    e,l
              cp    0x5B
              ret   nz
              cp    (hl)
              ret   nz
              inc   hl
              cp    (hl)
              ret   nz
              inc   hl
              cp    (hl)
              ret   nz
              inc   hl
              ld    a,b
              sub   0x04
              ret   c
              pop   de
              pop   de
              ld    b,a
              inc   d
              inc   hl
              jp    z,0xD1EB
              ld    a,d
              dec   hl
              inc   e
              and   0x08
              jr    nz,$+23
              dec   e
              ld    a,b
              or    a
              jr    z,$+18
              ld    a,(hl)
              sub   0x2D
              jr    z,$+8
              cp    0xFE
              jr    nz,$+9
              ld    a,0x08
              add   a,0x04
              add   a,d
              ld    d,a
              dec   b
              pop   hl
              pop   af
              jr    z,$+82
              push  bc
              push  de
              call  0x2337
              pop   de
              pop   bc
              push  bc
              push  hl
              ld    b,e
              ld    a,b
              add   a,c
              cp    0x19
              jp    nc,0x1E4A
              ld    a,d
              or    0x80
              call  PUFOUT
              call  OUTSTR
              pop   hl
              dec   hl
              rst   0x10
              scf   
              jr    z,$+15
              ld    (0x78DE),a
              cp    0x3B
              jr    z,$+7
              cp    0x2C
              jp    nz,0x1997
              rst   0x10
              pop   bc
              ex    de,hl
              pop   hl
              push  hl
              push  af
              push  de
              ld    a,(hl)
              sub   b
              inc   hl
              ld    c,(hl)
              inc   hl
              ld    h,(hl)
              ld    l,c
              ld    d,0x00
              ld    e,a
              add   hl,de
              ld    a,b
              or    a
              jp    nz,0x2D03
              jr    $+8
              call  0x2E49
              call  CHAR_OUTPUT_DISPATCH
              pop   hl
              pop   af
              jp    nz,0x2CCB
              call  c,0x20FE
              ex    (sp),hl
              call  0x29DD
              pop   hl
              jp    0x2169
              ld    c,0x01
              ld    a,0xF1
              dec   b
              call  0x2E49
              pop   hl
              pop   af
              jr    z,$-21
              push  bc
              call  0x2337
              call  CHKSTR
              pop   bc
              push  bc
              push  hl
              ld    hl,(FACLO)
              ld    b,c
              ld    c,0x00
              push  bc
              call  0x2A68
              call  0x28AA
              ld    hl,(FACLO)
              pop   af
              sub   (hl)
              ld    b,a
              ld    a,0x20
              inc   b
              dec   b
              jp    z,0x2DD3
              call  CHAR_OUTPUT_DISPATCH
              jr    $-7
              push  af
              ld    a,d
              or    a
              ld    a,0x2B
              call  nz,CHAR_OUTPUT_DISPATCH
              pop   af
              ret   
              ld    h,b
              ld    l,c
              inc   hl
              inc   hl
              inc   hl
              inc   hl
              call  0x2B7E
              ld    hl,(0x78A7)
              call  0x2B75
              ret   
              rst   8
              jr    z,$-49
              inc   e
              dec   hl
              or    a
              jr    z,$+20
              dec   a
              jr    z,$+5
              jp    0x1E4A
              ld    d,0x00
              ld    a,(0x783B)
              or    0x08
              ld    (0x783B),a
              jr    $+12
              ld    d,0x20
              ld    a,(0x783B)
              and   0xF7
              ld    (0x783B),a
              ld    (0x6800),a
              push  hl
              ld    hl,0x7000
              ld    bc,0x0800
              ld    a,d
              ld    (hl),a
              inc   hl
              dec   bc
              ld    a,b
              or    c
              jr    nz,$-6
              pop   hl
              rst   8
              add   hl,hl
              ret   
              cp    0x22
              jp    z,0x2EB3
              or    a
              jp    p,0x2B89
              jp    0x2B94
              ld    a,(hl)
              or    a
              inc   hl
              ld    (bc),a
              ret   z
              cp    0x22
              jp    z,0x2B89
              inc   bc
              dec   d
              ret   z
              jr    $-13
              push  af
              push  bc
              push  de
              push  hl
              call  0x787D
              call  0x3F7B
              call  0x2EDC
              call  0x2EFD
              push  af
              ld    hl,0x7839
              bit   0,(hl)
              call  z,0x301B
              pop   af
              call  0x3430
              pop   hl
              pop   de
              pop   bc
              pop   af
              ei    
              reti  
              ld    a,(0x7839)
              bit   0,a
              ret   nz
              ld    hl,0x7841
              dec   (hl)
              ret   nz
              ld    a,0x10
              ld    (0x7841),a
              ld    hl,(0x7820)
              ld    a,0x40
              xor   (hl)
              ld    (hl),a
              ret   
              call  0x2EFD
              push  af
              call  0x2F0E
              pop   af
              ret   
              ld    a,(0x6800)
              or    0xC0
              cpl   
              cp    0x00
              jr    z,$+9
              call  0x2F28
              or    a
              jp    nz,KBD_ROLLOVER
              ld    hl,0x7838
              bit   2,(hl)
              jr    z,$+10
              ld    a,(0x783A)
              or    a
              jr    z,$+4
              res   2,(hl)
              ld    a,(hl)
              and   0x06
              ld    (0x7838),a
              xor   a
              ld    (0x7836),a
              ret   
              ld    hl,0x68FE
              ld    c,0x08
              ld    b,0x06
              ld    a,(hl)
              or    0x04
              rra   
              jr    nc,$+47
              djnz  $-3
              rlc   l
              dec   c
              jr    nz,$-13
              ld    b,0x04
              ld    hl,0x68DF
              ld    a,(hl)
              bit   2,a
              jr    z,$+18
              rlc   l
              ld    a,(hl)
              bit   2,a
              jr    z,$+15
              rlc   l
              ld    a,(hl)
              bit   2,a
              jr    z,$+12
              xor   a
              ret   
              ld    c,0x03
              jr    $+8
              ld    c,0x02
              jr    $+4
              ld    c,0x01
              or    0x04
              ld    e,a
              ld    a,0x06
              sub   b
              sla   a
              sla   a
              sla   a
              add   a,0x08
              sub   c
              ld    (0x7842),bc
              ld    (0x7844),hl
              ld    hl,KEYBOARD_CODES_NORMAL
              ld    c,a
              ld    b,0x00
              ld    a,(0x68FB)
              bit   2,a
              jr    nz,$+12
              ld    hl,0x7838
              set   0,(hl)
              ld    hl,KEYBOARD_CODES_SHIFT
              jr    $+63
              ld    a,(0x68FD)
              bit   2,a
              jr    nz,$+59
              ld    a,(0x687F)
              bit   2,a
              jr    nz,$+16
              ld    hl,0x7838
              bit   5,(hl)
              jr    nz,$+6
              ld    a,(hl)
              xor   0x22
              ld    (hl),a
              xor   a
              pop   bc
              ret   
              ld    hl,0x7838
              set   7,(hl)
              bit   2,(hl)
              jr    z,$+7
              ld    hl,KEYBOARD_CODES_FUNCTION
              jr    $+21
              ld    a,(0x68BF)
              bit   2,a
              jr    nz,$+9
              set   2,(hl)
              xor   a
              ld    (0x783A),a
              ret   
              res   2,(hl)
              ld    hl,KEYBOARD_CODES_CTRL
              add   hl,bc
              ld    a,(hl)
              ret   
              ld    a,(0x7838)
              and   0x81
              jr    z,$-8
              xor   a
              pop   hl
              ret   
              ld    hl,0x7838
              bit   5,(hl)
              jr    z,$+39
              ld    a,(0x783A)
              inc   a
              ld    (0x783A),a
              cp    0x2A
              jr    z,$+4
              xor   a
              ret   
              ld    a,(hl)
              and   0xDF
              or    0x40
              ld    (0x7838),a
              xor   a
              ld    (0x783A),a
              bit   4,(hl)
              jr    nz,$+6
              ld    a,(0x7836)
              ret   
              ld    a,(0x7837)
              ret   
              bit   6,(hl)
              jr    nz,$+9
              set   5,(hl)
              xor   a
              ld    (0x783A),a
              ret   
              ld    a,(0x783A)
              inc   a
              ld    (0x783A),a
              cp    0x06
              jr    z,$-36
              xor   a
              ret   
              or    a
              ret   z
              push  af
              call  0x3039
              pop   af
              cp    0x0D
              ret   z
              cp    0x01
              ret   z
              ld    a,(0x7839)
              bit   0,a
              ret   nz
              ld    a,0x20
              ld    (0x7841),a
              ld    hl,(0x7820)
              jp    0x3EB2
              ld    hl,0x7838
              bit   7,(hl)
              jp    z,0x3157
              or    a
              jp    p,0x3157
              push  af
              sub   0x80
              inc   a
              ld    b,a
              ld    hl,0x164F
              inc   hl
              bit   7,(hl)
              jr    z,$-3
              djnz  $-5
              ld    a,(hl)
              call  0x3082
              ld    a,(hl)
              bit   7,a
              jr    z,$-6
              pop   af
              ld    b,0x16
              ld    hl,TOKEN_APPEND_PAREN
              cp    (hl)
              jr    z,$+24
              inc   hl
              djnz  $-4
              cp    0xB0
              ret   nz
              ld    a,0x20
              call  0x3082
              ld    a,0x46
              call  0x3082
              ld    a,0x4E
              call  0x3082
              ret   
              ld    a,0x28
              call  0x3082
              ret   
              and   0x7F
              push  hl
              call  0x3157
              pop   hl
              inc   hl
              ret   
              push  af
              ld    a,(0x783B)
              bit   3,a
              jr    z,$+25
              and   0xF7
              ld    (0x783B),a
              ld    (0x6800),a
              ld    bc,0x0200
              ld    hl,0x7000
              call  0x3EBE
              inc   hl
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-7
              pop   af
              ld    hl,0x7839
              bit   5,(hl)
              jp    z,0x3106
              cp    0x20
              jp    nc,0x30C0
              push  af
              ld    a,(0x7AAF)
              or    a
              jr    nz,$-4
              pop   af
              di    
              ld    hl,(0x7AB0)
              ld    (hl),a
              inc   hl
              ld    (0x7AB0),hl
              ld    hl,0x7AAF
              inc   (hl)
              push  af
              ld    a,(0x78A6)
              add   a,(hl)
              ld    (0x7AAE),a
              pop   af
              ei    
              cp    0x20
              jp    c,0x30E3
              ld    a,0x14
              cp    (hl)
              jp    c,0x30DE
              ret   
              xor   a
              cp    (hl)
              jr    nz,$-1
              ret   
              ld    a,(0x7AAF)
              or    a
              ret   z
              ld    b,a
              ld    hl,0x7AB2
              push  hl
              ld    a,(hl)
              inc   hl
              push  hl
              push  bc
              call  0x3106
              pop   bc
              pop   hl
              djnz  $-9
              pop   hl
              ld    (0x7AB0),hl
              xor   a
              ld    (0x7AAF),a
              ret   
              call  CURSOR_CHAR_RESTORE
              or    a
              jr    z,$+6
              cp    0x0D
              jr    nz,$+76
              push  af
              ld    hl,(0x7820)
              ld    a,(0x78A6)
              ld    c,a
              xor   a
              ld    b,a
              ld    (0x78A6),a
              sbc   hl,bc
              ld    bc,RST20_VEC
              add   hl,bc
              ld    a,h
              cp    0x72
              call  p,0x33F3
              ld    (0x7820),hl
              call  0x0053
              pop   af
              or    a
              ret   z
              call  0x33A8
              cp    0x80
              ret   z
              cp    0x81
              jr    nz,$+7
              dec   a
              ld    (hl),a
              inc   hl
              ld    (hl),a
              ret   
              ld    a,0x80
              ld    (hl),a
              ret   
              bit   6,a
              jr    z,$+6
              jp    0x3F60
              nop   
              and   0x8F
              ld    b,a
              ld    a,(0x7846)
              or    b
              ld    b,a
              jr    $+97
              call  CURSOR_CHAR_RESTORE
              or    a
              jp    m,0x3145
              cp    0x0D
              ret   z
              cp    0x08
              jp    z,0x3227
              cp    0x1B
              jp    z,0x3253
              cp    0x0A
              jp    z,0x326D
              cp    0x08
              jp    z,0x3227
              cp    0x09
              jp    z,0x31B8
              cp    0x01
              ret   z
              cp    0x7F
              jp    z,0x33CB
              cp    0x15
              jp    z,0x32C6
              cp    0x18
              jp    z,0x3227
              cp    0x19
              jp    z,0x31B8
              cp    0x1B
              jp    z,0x3253
              cp    0x1C
              jp    z,0x3287
              cp    0x1D
              jp    z,0x32B4
              cp    0x1F
              jp    z,0x3292
              cp    0x20
              ret   m
              jp    0x3ECA
              ld    hl,0x7838
              bit   1,(hl)
              pop   hl
              jr    z,$+4
              or    0x40
              ld    b,a
              ld    a,b
              ld    (hl),a
              call  0x31BF
              call  GET_CURSOR_CHAR
              ret   
              ld    a,(0x78A6)
              inc   a
              cp    0x20
              jr    nz,$+45
              call  0x33A8
              cp    0x81
              jr    z,$+37
              or    a
              jr    nz,$+55
              ld    b,a
              ld    a,(0x7839)
              bit   0,a
              ld    a,b
              ret   z
              xor   a
              inc   hl
              ld    (hl),a
              inc   hl
              push  hl
              ld    bc,(0x78A4)
              dec   bc
              dec   bc
              or    a
              sbc   hl,bc
              pop   hl
              jr    nc,$+9
              ld    a,(hl)
              or    a
              jr    nz,$+5
              ld    a,0x80
              ld    (hl),a
              xor   a
              ld    (0x78A6),a
              ld    hl,(0x7820)
              ld    bc,0x0001
              add   hl,bc
              ld    a,h
              cp    0x72
              call  p,0x33F3
              ld    (0x7820),hl
              ret   
              push  af
              ld    de,(0x7820)
              inc   de
              ld    a,d
              cp    0x72
              jr    z,$+18
              push  hl
              ld    hl,0x7839
              bit   0,(hl)
              jr    nz,$+9
              bit   4,(hl)
              jr    nz,$+5
              call  0x332C
              pop   hl
              pop   af
              inc   a
              ld    (hl),a
              jp    0x31D9
              ld    a,(0x78A6)
              dec   a
              jp    p,0x3235
              call  0x33A8
              or    a
              ret   nz
              ld    a,0x1F
              ld    (0x78A6),a
              ld    bc,0x0001
              ld    hl,(0x7820)
              xor   a
              sbc   hl,bc
              ld    a,h
              cp    0x70
              jp    c,0x324E
              ld    (0x7820),hl
              call  0x0053
              ret   
              xor   a
              ld    (0x78A6),a
              ret   
              ld    hl,0x7839
              bit   4,(hl)
              ret   nz
              ld    bc,RST20_VEC
              ld    hl,(0x7820)
              xor   a
              sbc   hl,bc
              ld    a,h
              cp    0x70
              ret   m
              ld    (0x7820),hl
              call  0x0053
              ret   
              ld    hl,0x7839
              bit   4,(hl)
              ret   nz
              ld    bc,RST20_VEC
              ld    hl,(0x7820)
              add   hl,bc
              ld    a,h
              cp    0x72
              call  p,0x3424
              ld    (0x7820),hl
              call  0x0053
              ret   
              ld    hl,0x7000
              ld    (0x7820),hl
              xor   a
              ld    (0x78A6),a
              ret   
              ld    hl,0x7000
              ld    (0x7820),hl
              ld    bc,0x0200
              call  0x3EBE
              inc   hl
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-7
              xor   a
              ld    (0x78A6),a
              ld    b,0x10
              ld    a,0x80
              ld    hl,0x7AD7
              ld    (hl),a
              inc   hl
              djnz  $-2
              ret   
              ld    hl,(0x7820)
              ld    a,(0x78A6)
              ld    c,a
              xor   a
              ld    b,a
              ld    (0x78A6),a
              sbc   hl,bc
              ld    (0x7820),hl
              ret   
              call  0x33A8
              cp    0x81
              jr    z,$+51
              ld    a,(0x78A6)
              cp    0x1F
              jr    z,$+39
              ld    c,a
              xor   a
              ld    b,a
              ld    hl,(0x7820)
              sbc   hl,bc
              ld    bc,0x001F
              add   hl,bc
              call  0x3EE9
              jr    nz,$+22
              push  hl
              pop   de
              dec   hl
              ld    a,(0x78A6)
              ld    c,a
              ld    a,0x1F
              sub   c
              ld    c,a
              lddr  
              call  0x3EF6
              ld    (0x783C),a
              ret   
              call  0x33A8
              or    a
              ret   z
              cp    0x80
              jr    z,$+32
              ld    a,(0x78A6)
              ld    c,a
              xor   a
              ld    b,a
              ld    hl,(0x7820)
              sbc   hl,bc
              ld    bc,0x003F
              add   hl,bc
              call  0x3EE9
              ret   nz
              push  hl
              pop   de
              dec   hl
              ld    a,(0x78A6)
              ld    c,a
              ld    a,0x3F
              jr    $-48
              push  hl
              call  0x332C
              pop   hl
              ld    a,0x81
              ld    (hl),a
              inc   hl
              xor   a
              ld    (hl),a
              ret   
              ld    hl,(0x7820)
              ld    a,h
              cp    0x71
              jr    nz,$+45
              ld    a,l
              cp    0xE0
              jp    c,0x335F
              ld    a,(0x78A6)
              push  af
              ld    a,(0x7AD7)
              cp    0x81
              jr    nz,$+10
              push  hl
              call  0x33F3
              pop   hl
              call  CURSOR_LINE_BACK
              push  hl
              call  0x33F3
              pop   hl
              call  CURSOR_LINE_BACK
              pop   af
              ld    (0x78A6),a
              pop   de
              pop   hl
              dec   hl
              push  hl
              push  de
              ret   
              ld    a,(0x78A6)
              ld    c,a
              xor   a
              ld    b,a
              sbc   hl,bc
              ld    bc,0x0040
              add   hl,bc
              push  hl
              ex    de,hl
              ld    hl,0x7200
              sbc   hl,de
              push  hl
              pop   bc
              ld    hl,0x71DF
              ld    de,0x71FF
              ld    a,c
              or    b
              jr    z,$+4
              lddr  
              pop   hl
              call  0x3F02
              nop   
              ld    (de),a
              dec   de
              djnz  $-2
              call  0x33A8
              push  hl
              pop   bc
              ld    hl,0x7AE6
              push  hl
              or    a
              sbc   hl,bc
              push  hl
              pop   bc
              pop   hl
              push  hl
              pop   de
              dec   hl
              lddr  
              ld    a,(0x7AE6)
              cp    0x81
              ret   nz
              ld    hl,(0x7820)
              jr    $-71
              ld    a,(0x78A6)
              ld    c,a
              xor   a
              ld    b,a
              ld    hl,(0x7820)
              sbc   hl,bc
              push  hl
              pop   bc
              ld    a,b
              and   0x0F
              srl   a
              ld    b,a
              rr    c
              srl   c
              srl   c
              srl   c
              srl   c
              ld    hl,0x7AD7
              add   hl,bc
              ld    a,(hl)
              ret   
              call  0x33A8
              cp    0x81
              ld    hl,(0x7820)
              push  hl
              pop   de
              inc   hl
              ld    a,(0x78A6)
              ld    c,a
              jr    z,$+21
              cp    0x1F
              jr    z,$+10
              ld    a,0x1F
              sub   c
              ld    c,a
              xor   a
              ld    b,a
              ldir  
              call  0x3EF6
              call  GET_CURSOR_CHAR
              ret   
              ld    a,0x3F
              jr    $-15
              ld    de,0x7000
              ld    hl,0x7020
              ld    bc,0x01E0
              ldir  
              call  0x3F02
              nop   
              ld    (de),a
              inc   de
              djnz  $-2
              ld    hl,0x7AD7
              push  hl
              pop   de
              inc   hl
              ld    bc,0x000F
              ldir  
              ld    a,(de)
              cp    0x81
              jr    nz,$+5
              xor   a
              jr    $+4
              ld    a,0x80
              ld    (de),a
              xor   a
              ld    (0x78A6),a
              ld    hl,0x71E0
              ret   
              ld    a,(0x7AD7)
              cp    0x81
              call  z,0x33F3
              call  0x33F3
              ret   
              ld    hl,0x7839
              or    a
              jr    nz,$+13
              set   1,(hl)
              ld    bc,0x03FF
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-3
              ret   
              bit   0,(hl)
              ret   nz
              cp    0x0D
              jr    z,$+8
              cp    0x01
              jr    nz,$+6
              set   2,(hl)
              set   0,(hl)
              push  hl
              ld    hl,0x00A0
              ld    bc,0x0006
              call  0x345C
              pop   hl
              ret   
              ld    a,(0x783B)
              ld    d,a
              call  0x3469
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-6
              ret   
              push  bc
              ld    a,d
              xor   0x21
              ld    (0x6800),a
              push  hl
              pop   bc
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-3
              ld    a,d
              ld    (0x6800),a
              push  hl
              pop   bc
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-3
              pop   bc
              ret   
              call  0x3FA0
              ld    a,0x20
              ld    (0x783B),a
              ld    (0x6800),a
              ld    a,0x3C
              ld    (0x783A),a
              ld    a,0x10
              ld    (0x7841),a
              xor   a
              ld    (0x7AAF),a
              ld    hl,0x7AB2
              ld    (0x7AB0),hl
              ld    a,0xC9
              jp    0x3E37
              ret   
              di    
              ld    c,0xF0
              call  0x3558
              jp    c,0x3AFE
              push  hl
              ld    bc,0x019A
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-3
              call  0x3AF8
              ld    ix,0x7823
              ld    hl,(0x78A4)
              ld    a,l
              call  0x3511
              ld    (ix+0x00),a
              xor   a
              ld    (ix+0x01),a
              ld    a,h
              call  0x3511
              call  0x388E
              ex    de,hl
              ld    hl,(0x78F9)
              ld    a,l
              call  0x3511
              call  0x388E
              ld    a,h
              call  0x3511
              call  0x388E
              call  0x3AF8
              ld    a,(de)
              inc   de
              call  0x3511
              call  0x388E
              call  0x3AF8
              rst   0x18
              jr    nz,$-12
              ld    a,(ix+0x00)
              call  0x3511
              ld    a,(ix+0x01)
              call  0x3511
              ld    b,0x14
              xor   a
              call  0x3511
              djnz  $-3
              pop   hl
              ei    
              ret   
              push  af
              push  bc
              push  hl
              ld    l,0x08
              ld    h,a
              call  0x3542
              rlc   h
              jr    nc,$+15
              call  0x3542
              call  0x3542
              dec   l
              jr    nz,$-14
              pop   hl
              pop   bc
              pop   af
              ret   
              ld    a,(0x783B)
              or    0x06
              ld    (0x6800),a
              ld    b,0x99
              djnz  $+0
              and   0xF9
              ld    (0x6800),a
              ld    b,0x99
              djnz  $+0
              jr    $-28
              ld    a,(0x783B)
              or    0x06
              ld    (0x6800),a
              ld    b,0x4C
              djnz  $+0
              and   0xF9
              ld    (0x6800),a
              ld    b,0x4C
              djnz  $+0
              ret   
              call  0x358C
              ld    b,0xFF
              ld    a,0x80
              call  0x3511
              call  0x3AE8
              ret   c
              djnz  $-9
              ld    b,0x05
              ld    a,0xFE
              call  0x3511
              call  0x3AE8
              ret   c
              djnz  $-9
              ld    a,c
              call  0x3511
              call  0x3AE8
              ret   c
              ld    a,(0x7AD6)
              ld    b,a
              ld    de,0x7A9D
              ld    a,(de)
              inc   de
              call  0x3511
              djnz  $-5
              ret   
              ld    b,0x10
              ld    de,0x7A9D
              ld    a,(hl)
              cp    0x3A
              jr    z,$+20
              or    a
              jr    z,$+17
              rst   8
              ld    (0xB77E),hl
              jr    z,$+11
              inc   hl
              cp    0x22
              jr    z,$+6
              ld    (de),a
              inc   de
              djnz  $-11
              xor   a
              ld    (de),a
              ld    a,0x11
              sub   b
              ld    (0x7AD6),a
              ret   
              ld    a,(0x784C)
              or    a
              ret   nz
              ld    a,(0x783B)
              bit   3,a
              jr    z,$+13
              and   0xF7
              ld    (0x783B),a
              ld    (0x6800),a
              call  0x3292
              ld    hl,0x71FF
              ld    (0x7820),hl
              ld    a,0x1F
              ld    (0x78A6),a
              ld    a,(0x7AE5)
              cp    0x81
              ret   nz
              dec   a
              ld    (0x7AE5),a
              ld    (0x7AE6),a
              ret   
              ld    hl,0x3842
              call  0x37F4
              call  0x3AF8
              ld    a,(0x6800)
              bit   6,a
              jr    nz,$-8
              call  0x378F
              jr    c,$-13
              bit   0,a
              jr    z,$-7
              ld    b,0x07
              call  0x378F
              jr    c,$-24
              djnz  $-5
              cp    0x80
              jr    nz,$-30
              call  0x3775
              jp    c,0x35E7
              cp    0x80
              jr    z,$-8
              ld    b,0x04
              cp    0xFE
              jp    nz,0x35E7
              call  0x3775
              jp    c,0x35E7
              djnz  $-11
              call  0x3775
              ld    (0x7AD2),a
              ld    hl,0x7AB2
              ld    b,0x12
              call  0x3775
              ld    (hl),a
              or    a
              jr    z,$+8
              inc   hl
              djnz  $-8
              jp    0x35E7
              ld    hl,0x385A
              call  0x37F4
              ld    hl,0x7AB2
              call  0x3814
              ld    hl,0x7AB2
              ld    de,0x7A9D
              ld    a,(de)
              or    a
              ret   z
              cp    (hl)
              jp    nz,0x35E7
              inc   hl
              inc   de
              jr    $-9
              ret   
              push  hl
              ld    hl,0x7839
              res   6,(hl)
              res   3,(hl)
              pop   hl
              di    
              call  0x358C
              push  hl
              call  0x35B1
              ld    hl,0x3842
              call  0x37F4
              call  0x35E7
              ld    a,(0x7AD2)
              cp    0xF2
              jr    z,$-8
              ld    hl,0x3860
              call  0x3804
              ld    ix,0x7823
              call  0x3868
              jp    c,0x3711
              push  hl
              sbc   hl,de
              jp    c,0x3711
              ld    (0x781E),de
              push  hl
              pop   bc
              pop   hl
              ld    a,(0x7839)
              bit   3,a
              jp    nz,0x3742
              call  0x3F73
              ld    (de),a
              call  0x388E
              inc   de
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-11
              call  0x3775
              cp    (ix+0x00)
              jp    nz,0x3711
              call  0x3775
              cp    (ix+0x01)
              jp    nz,0x3711
              ld    (0x78F9),hl
              ei    
              ld    a,0x0D
              call  0x308B
              ld    a,(0x7AD2)
              cp    0xF1
              jr    nz,$+6
              ld    hl,(0x781E)
              jp    (hl)
              ld    hl,0x1929
              call  OUTSTR
              ld    hl,(0x78A4)
              push  hl
              ld    hl,0x7839
              bit   6,(hl)
              jr    nz,$+5
              jp    0x1AE8
              ld    hl,0x7839
              res   6,(hl)
              pop   de
              call  0x1AFC
              call  0x79B5
              call  0x1B5D
              call  0x79B8
              ld    hl,0xFFFF
              ld    (0x78A2),hl
              ld    hl,0x79E8
              ld    de,0x0570
              ld    a,(de)
              ld    (hl),a
              or    a
              jr    z,$+6
              inc   hl
              inc   de
              jr    $-7
              ld    hl,0x79E7
              xor   a
              jp    0x1A81
              ld    hl,0x384A
              ei    
              call  OUTSTR
              di    
              ld    a,(0x784C)
              or    a
              jp    nz,0x3667
              ld    hl,0x71FF
              ld    (0x7820),hl
              ld    a,0x1F
              ld    (0x78A6),a
              jp    0x3667
              push  hl
              ld    hl,0x7839
              set   6,(hl)
              pop   hl
              jp    0x365F
              push  hl
              ld    hl,0x7839
              set   3,(hl)
              pop   hl
              jp    0x365F
              ex    de,hl
              call  0x3775
              cp    (hl)
              jr    z,$+11
              ld    hl,0x376C
              call  OUTSTR
              jp    0x0183
              inc   hl
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-19
              ld    hl,0x7839
              res   3,(hl)
              ld    hl,0x376C
              call  OUTSTR
              ld    hl,0x0380
              call  OUTSTR
              jp    0x36CF
              dec   c
              ld    d,(hl)
              ld    b,l
              ld    d,d
              ld    c,c
              ld    b,(hl)
              ld    e,c
              jr    nz,$+2
              push  bc
              push  de
              ld    b,0x08
              call  0x378F
              jr    c,$+16
              djnz  $-5
              pop   de
              pop   bc
              ld    (0x7AD3),a
              call  0x3AF8
              ld    a,(0x7AD3)
              ret   
              pop   de
              pop   bc
              ret   
              push  bc
              ld    bc,0x07FF
              ld    a,(0x6800)
              bit   6,a
              jr    z,$+10
              dec   bc
              ld    a,c
              or    b
              jr    nz,$-10
              pop   bc
              scf   
              ret   
              ld    a,(0x6800)
              bit   6,a
              jr    nz,$-20
              ld    a,(0x6800)
              bit   6,a
              jr    nz,$-27
              ld    b,0x52
              djnz  $+0
              ld    a,(0x6800)
              bit   6,a
              jr    nz,$+11
              ld    a,(0x6800)
              bit   6,a
              jr    z,$-5
              jr    $-50
              ld    b,0x5A
              ld    c,0x00
              ld    a,(0x6800)
              bit   6,a
              jr    z,$+13
              djnz  $-7
              ld    a,c
              dec   a
              rra   
              rl    d
              pop   bc
              ld    a,d
              or    a
              ret   
              ld    a,(0x6800)
              bit   6,a
              jr    nz,$-16
              ld    a,(0x6800)
              bit   6,a
              jr    nz,$-23
              inc   c
              ld    a,(0x6800)
              bit   6,a
              jr    nz,$-31
              djnz  $-7
              jr    $-33
              ld    a,(0x784C)
              or    a
              ret   nz
              ld    de,0x71E0
              ld    b,0x20
              call  0x3EF6
              inc   de
              djnz  $-4
              ld    a,(0x784C)
              or    a
              ret   nz
              call  0x3F0E
              ld    a,(hl)
              or    a
              ret   z
              ld    (de),a
              inc   de
              inc   hl
              jr    $-6
              ld    a,(0x784C)
              or    a
              ret   nz
              ld    de,0x71E9
              push  hl
              ld    a,(0x7AD2)
              and   0x0F
              ld    hl,0x383F
              add   a,l
              ld    l,a
              ld    a,0x00
              adc   a,h
              ld    h,a
              call  0x3F21
              nop   
              nop   
              ld    (de),a
              inc   de
              inc   de
              pop   hl
              ld    a,(hl)
              or    a
              ret   z
              call  0x3F33
              inc   de
              inc   hl
              jr    $-8
              ret   
              inc   d
              ld    (bc),a
              inc   b
              ld    d,a
              ld    b,c
              ld    c,c
              ld    d,h
              ld    c,c
              ld    c,(hl)
              ld    b,a
              nop   
              dec   c
              ld    c,h
              ld    c,a
              ld    b,c
              ld    b,h
              ld    c,c
              ld    c,(hl)
              ld    b,a
              jr    nz,$+71
              ld    d,d
              ld    d,d
              ld    c,a
              ld    d,d
              dec   c
              nop   
              ld    b,(hl)
              ld    c,a
              ld    d,l
              ld    c,(hl)
              ld    b,h
              nop   
              ld    c,h
              ld    c,a
              ld    b,c
              ld    b,h
              ld    c,c
              ld    c,(hl)
              ld    b,a
              nop   
              call  0x3775
              ret   c
              ld    e,a
              ld    (ix+0x00),a
              xor   a
              ld    (ix+0x01),a
              call  0x3775
              ret   c
              ld    d,a
              call  0x388E
              call  0x3775
              ret   c
              ld    l,a
              call  0x388E
              call  0x3775
              ret   c
              ld    h,a
              call  0x388E
              or    a
              ret   
              add   a,(ix+0x00)
              ld    (ix+0x00),a
              ld    a,0x00
              adc   a,(ix+0x01)
              ld    (ix+0x01),a
              ret   
              ld    a,(hl)
              cp    0x2C
              jr    z,$+34
              call  0x2B1C
              or    a
              jp    z,0x1E4A
              cp    0x09
              jp    nc,0x1E4A
              dec   a
              and   0x07
              sla   a
              sla   a
              sla   a
              sla   a
              ld    (0x7846),a
              ld    a,(hl)
              or    a
              ret   z
              cp    0x3A
              ret   z
              rst   8
              inc   l
              call  0x2B1C
              or    a
              jr    nz,$+14
              ld    a,(0x783B)
              res   4,a
              ld    (0x783B),a
              ld    (0x6800),a
              ret   
              cp    0x01
              jp    nz,0x1E4A
              ld    a,(0x783B)
              set   4,a
              ld    (0x783B),a
              ld    (0x6800),a
              ret   
              ld    c,0xC0
              rrc   c
              djnz  $-2
              ld    a,(de)
              and   c
              ld    b,a
              ld    a,c
              rrc   b
              rrc   a
              cp    0x03
              jr    nz,$-6
              ld    a,b
              inc   a
              push  hl
              call  CONIA
              pop   hl
              jp    0x390F
              ld    b,a
              ld    a,(de)
              and   c
              ld    (de),a
              pop   af
              or    a
              jp    p,0x390F
              ld    a,(de)
              or    b
              ld    (de),a
              rst   8
              add   hl,hl
              ret   
              di    
              push  hl
              ld    a,(0x783B)
              bit   3,a
              jp    nz,0x398E
              ld    hl,0x7000
              ld    c,0x10
              ld    b,0x20
              ld    a,(hl)
              or    a
              jp    p,0x392D
              call  0x2C73
              jr    $+24
              jp    0x3F44
              nop   
              and   0x3F
              call  0x3956
              jr    $+13
              and   0x3F
              bit   5,a
              jr    nz,$+4
              or    0x40
              call  0x3ABA
              inc   hl
              djnz  $-33
              ld    a,0x0D
              call  0x3ABA
              call  0x3AF8
              dec   c
              ld    a,c
              or    a
              jr    nz,$-48
              pop   hl
              ei    
              ret   
              push  af
              push  bc
              push  de
              push  hl
              ld    l,a
              ld    h,0x00
              ld    a,0x08
              call  0x3ABA
              ld    b,0x04
              push  hl
              pop   de
              or    a
              adc   hl,de
              djnz  $-2
              push  hl
              pop   bc
              ld    hl,0x3B94
              add   hl,bc
              ld    a,0xFF
              call  0x3ABA
              ld    b,0x05
              ld    a,(hl)
              inc   hl
              call  0x3ABA
              djnz  $-5
              ld    a,0xFF
              call  0x3ABA
              ld    a,0x0F
              call  0x3ABA
              pop   hl
              pop   de
              pop   bc
              pop   af
              ret   
              xor   a
              ld    (0x7AD6),a
              ld    (0x7AD6),a
              ld    a,0x08
              call  0x3ABA
              ld    ix,0x7AD2
              ld    hl,0x7000
              ld    de,START
              ld    c,0xC0
              call  0x3AF8
              push  hl
              call  PRN_GFXBUF_CLEAR
              ld    b,0x03
              ld    a,(hl)
              and   c
              push  bc
              ld    b,a
              rrc   b
              rrc   b
              rrc   c
              rrc   c
              ld    a,c
              cp    0x03
              jp    nz,0x39B3
              ld    a,b
              pop   bc
              cp    0x03
              jr    z,$+15
              cp    0x02
              jr    z,$+16
              cp    0x01
              jr    z,$+18
              ld    de,START
              jr    $+17
              ld    de,0xE0E0
              jr    $+12
              ld    d,0x40
              ld    e,0xA0
              jr    $+6
              ld    d,0xA0
              ld    e,0x40
              ld    a,(ix+0x00)
              srl   a
              srl   a
              srl   a
              push  hl
              ld    hl,0x7AD3
              call  0x3A6A
              pop   hl
              or    d
              ld    (ix+0x00),a
              ld    a,(ix+0x02)
              srl   a
              srl   a
              srl   a
              push  hl
              ld    hl,0x7AD5
              call  0x3A6A
              pop   hl
              or    e
              ld    (ix+0x02),a
              ld    a,0x20
              add   a,l
              ld    l,a
              ld    a,0x00
              adc   a,h
              ld    h,a
              djnz  $+82
              call  0x3A73
              pop   hl
              srl   c
              srl   c
              ld    a,c
              or    a
              jr    nz,$-123
              inc   hl
              ld    a,l
              and   0x1F
              jp    nz,0x39A4
              call  0x3AE2
              ld    a,(0x7AD6)
              inc   a
              cp    0x03
              jr    nz,$+3
              xor   a
              ld    (0x7AD6),a
              jr    nz,$+6
              ld    a,0x40
              jr    $+4
              ld    a,0x20
              add   a,l
              ld    l,a
              ld    a,0x00
              adc   a,h
              ld    h,a
              cp    0x78
              jp    nc,0x3A5F
              cp    0x77
              jp    nz,0x39A4
              ld    a,l
              cp    0xE0
              jp    c,0x39A4
              ld    a,0xFF
              ld    (0x7AD6),a
              jp    0x39A4
              ld    a,0x0F
              call  0x3ABA
              pop   hl
              ei    
              ret   
              jp    0x39AF
              jp    nc,0x3A70
              set   0,(hl)
              ret   
              res   0,(hl)
              ret   
              call  0x3A85
              inc   ix
              inc   ix
              call  0x3A85
              dec   ix
              dec   ix
              call  0x3A85
              ret   
              ld    a,(ix+0x01)
              rrc   a
              ld    a,(ix+0x00)
              push  af
              ld    a,(0x7AD6)
              cp    0x02
              jr    z,$+31
              cp    0x01
              jr    z,$+24
              pop   af
              rla   
              push  af
              ld    a,(0x7AD6)
              cp    0xFF
              jr    nz,$+7
              pop   af
              and   0x07
              jr    $+3
              pop   af
              or    0x80
              call  0x3ABA
              ret   
              pop   af
              jr    $-21
              pop   af
              rra   
              jr    $-25
              or    a
              jp    m,0x3AD8
              push  af
              call  0x3AE8
              jp    nc,0x3AC4
              pop   af
              scf   
              ret   
              in    a,(0x00)
              bit   0,a
              jr    nz,$-13
              pop   af
              out   (0x0E),a
              out   (0x0D),a
              cp    0x0D
              scf   
              ccf   
              ret   nz
              ld    a,0x0A
              jr    $-28
              bit   6,a
              jp    z,0x2C73
              and   0x3F
              jp    0x3956
              ld    a,0x0D
              call  0x3ABA
              ret   
              or    a
              ld    a,(0x68FD)
              bit   2,a
              ret   nz
              ld    a,(0x68DF)
              scf   
              bit   2,a
              ret   z
              ccf   
              ret   
              call  0x3AE8
              ret   nc
              pop   hl
              pop   hl
              ld    a,(0x7839)
              and   0xB7
              ld    (0x7839),a
              ld    a,0x01
              ei    
              jp    0x1DA0
              ld    a,(0x789C)
              or    a
              jp    nz,0x2164
              ld    a,(0x7AAF)
              or    a
              jr    nz,$-4
              jp    0x2164
              ld    a,(0x7AAF)
              or    a
              ret   nz
              ld    a,(0x78A6)
              ret   
              ld    hl,0x68EF
              bit   4,(hl)
              jr    nz,$+26
              call  0x3B48
              bit   4,(hl)
              jr    z,$-2
              call  0x3B48
              call  0x3AF8
              bit   4,(hl)
              jr    nz,$-5
              call  0x3B48
              bit   4,(hl)
              jr    z,$-2
              ld    hl,0xFFFF
              ret   
              ld    hl,0x07FF
              dec   hl
              ld    a,l
              or    h
              jr    nz,$-3
              ld    hl,0x68EF
              ret   
              call  0x3511
              ret   
              di    
              inc   hl
              ld    c,0xF2
              call  0x3558
              jp    c,0x3AFE
              dec   hl
              rst   8
              ld    (0x2CCF),hl
              ret   
              di    
              inc   hl
              call  0x358C
              dec   hl
              rst   8
              ld    (0x2CCF),hl
              push  hl
              call  0x35B1
              ld    hl,0x3842
              call  0x37F4
              call  0x35E7
              ld    a,(0x7AD2)
              cp    0xF2
              jr    nz,$-8
              pop   hl
              ret   
              call  0x3775
              cp    0x0D
              ret   nz
              push  af
              call  0x20F9
              pop   af
              ret   
              pop   bc
              cp    (hl)
              and   d
              xor   (hl)
              or    c
              add   a,e
              DEFB  0xED
              xor   0xED
              add   a,e
              add   a,b
              or    (hl)
              or    (hl)
              or    (hl)
              pop   bc
              pop   bc
              cp    (hl)
              cp    (hl)
              cp    (hl)
              defb  0x00DD,0x0080,0x00BE
              cp    (hl)
              cp    (hl)
              pop   bc
              add   a,b
              or    (hl)
              or    (hl)
              or    (hl)
              cp    (hl)
              add   a,b
              or    0xF6
              or    0xFE
              pop   bc
              cp    (hl)
              cp    (hl)
              xor   (hl)
              adc   a,h
              add   a,b
              rst   0x30
              rst   0x30
              rst   0x30
              add   a,b
              rst   0x38
              cp    (hl)
              add   a,b
              cp    (hl)
              rst   0x38
              rst   0x18
              cp    a
              cp    a
              ret   nz
              cp    0x80
              rst   0x30
              ex    de,hl
              cp    (ix-0x80)
              cp    a
              cp    a
              cp    a
              cp    a
              add   a,b
              defb  0x00FD,0x00F3,0x00FD
              add   a,b
              add   a,b
              defb  0x00FD,0x00FB,0x00F7
              add   a,b
              pop   bc
              cp    (hl)
              cp    (hl)
              cp    (hl)
              pop   bc
              add   a,b
              or    0xF6
              or    0xF9
              pop   bc
              cp    (hl)
              xor   (hl)
              sbc   a,0xA1
              add   a,b
              or    0xE6
              sub   0xB9
              exx   
              or    (hl)
              or    (hl)
              or    (hl)
              call  0xFEFE
              add   a,b
              cp    0xFE
              ret   nz
              cp    a
              cp    a
              cp    a
              ret   nz
              ret   m
              rst   0x20
              sbc   a,a
              rst   0x20
              ret   m
              add   a,b
              rst   0x18
              rst   0x20
              rst   0x18
              add   a,b
              sbc   a,h
              DEFB  0xED
              rst   0x30
              ex    de,hl
              sbc   a,h
              call  m,0x87FB
              ei    
              call  m,0xAE9E
              or    (hl)
              cp    d
              cp    h
              rst   0x38
              add   a,b
              cp    (hl)
              cp    (hl)
              rst   0x38
              defb  0x00FD,0x00FB,0x00F7
              rst   0x28
              rst   0x18
              rst   0x38
              cp    (hl)
              cp    (hl)
              add   a,b
              rst   0x38
              ei    
              defb  0x00FD,0x0080,0x00FD
              ei    
              rst   0x30
              ex    (sp),hl
              sub   0xF7
              rst   0x30
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              and   b
              rst   0x38
              rst   0x38
              rst   0x38
              ret   m
              rst   0x38
              ret   m
              rst   0x38
              ex    de,hl
              add   a,b
              ex    de,hl
              add   a,b
              DEFB  0xED
              in    a,(0xD6)
              add   a,b
              sub   0xED
              exx   
              jp    (hl)
              rst   0x30
              set   1,l
              ret   
              sub   0xA9
              rst   0x18
              xor   a
              rst   0x30
              ret   m
              call  m,0xFFFF
              rst   0x38
              ex    (sp),hl
              cp    (ix-0x01)
              rst   0x38
              cp    (hl)
              ex    (sp),ix
              rst   0x38
              sub   0xE3
              add   a,b
              ex    (sp),hl
              push  de
              rst   0x30
              rst   0x30
              pop   bc
              rst   0x30
              rst   0x30
              rst   0x18
              rst   0
              rst   0x30
              rst   0x38
              rst   0x38
              rst   0x30
              rst   0x30
              rst   0x30
              rst   0x30
              rst   0x30
              rst   0x38
              sbc   a,a
              sbc   a,a
              rst   0x38
              rst   0x38
              rst   0x18
              rst   0x28
              rst   0x30
              ei    
              defb  0x00FD,0x00C1,0x00AE
              or    (hl)
              cp    d
              pop   bc
              rst   0x38
              cp    l
              add   a,b
              cp    a
              rst   0x38
              sbc   a,l
              xor   (hl)
              or    (hl)
              cp    d
              cp    l
              defb  0x00DD,0x00BB,0x00BB
              cp    e
              ret   
              rst   0x20
              ex    de,hl
              DEFB  0xED
              add   a,b
              rst   0x28
              ret   c
              cp    d
              jp    c,0xC6DA
              pop   bc
              or    (hl)
              or    (hl)
              or    (hl)
              rst   8
              call  m,0x86FE
              jp    m,0xC9FC
              or    (hl)
              or    (hl)
              or    (hl)
              ret   
              ld    sp,hl
              or    (hl)
              or    (hl)
              or    (hl)
              pop   bc
              rst   0x38
              ret   
              ret   
              rst   0x38
              rst   0x38
              cp    a
              call  nz,0xFFE4
              rst   0x38
              rst   0x30
              ex    de,hl
              defb  0x00DD,0x00DE,0x00DE
              ex    de,hl
              ex    de,hl
              ex    de,hl
              ex    de,hl
              ex    de,hl
              sbc   a,0xDE
              defb  0x00DD,0x00EB,0x00F7
              defb  0x00FD,0x00FE,0x00A6
              jp    m,0xCBFD
              dec   sp
              inc   e
              ld    a,(hl)
              inc   hl
              or    a
              jp    p,0x3CD7
              dec   e
              jr    nz,$-7
              and   0x7F
              call  CHAR_OUTPUT_DISPATCH
              ld    a,(hl)
              inc   hl
              or    a
              jp    p,0x3CE2
              ret   
              adc   a,0x45
              ld    e,b
              ld    d,h
              jr    nz,$+89
              ld    c,c
              ld    d,h
              ld    c,b
              ld    c,a
              ld    d,l
              ld    d,h
              jr    nz,$+72
              ld    c,a
              ld    d,d
              out   (0x59),a
              ld    c,(hl)
              ld    d,h
              ld    b,c
              ld    e,b
              jp    nc,0x5445
              daa   
              ld    c,(hl)
              jr    nz,$+89
              ld    c,c
              ld    d,h
              ld    c,b
              ld    c,a
              ld    d,l
              ld    d,h
              jr    nz,$+73
              ld    c,a
              ld    d,e
              ld    d,l
              ld    b,d
              rst   8
              ld    d,l
              ld    d,h
              jr    nz,$+81
              ld    b,(hl)
              jr    nz,$+70
              ld    b,c
              ld    d,h
              ld    b,c
              add   a,0x55
              ld    c,(hl)
              ld    b,e
              ld    d,h
              ld    c,c
              ld    c,a
              ld    c,(hl)
              jr    nz,$+69
              ld    c,a
              ld    b,h
              ld    b,l
              rst   8
              ld    d,(hl)
              ld    b,l
              ld    d,d
              ld    b,(hl)
              ld    c,h
              ld    c,a
              ld    d,a
              rst   8
              ld    d,l
              ld    d,h
              jr    nz,$+81
              ld    b,(hl)
              jr    nz,$+79
              ld    b,l
              ld    c,l
              ld    c,a
              ld    d,d
              ld    e,c
              push  de
              ld    c,(hl)
              ld    b,h
              ld    b,l
              ld    b,(hl)
              daa   
              ld    b,h
              jr    nz,$+85
              ld    d,h
              ld    b,c
              ld    d,h
              ld    b,l
              ld    c,l
              ld    b,l
              ld    c,(hl)
              ld    d,h
              jp    nz,0x4441
              jr    nz,$+85
              ld    d,l
              ld    b,d
              ld    d,e
              ld    b,e
              ld    d,d
              ld    c,c
              ld    d,b
              ld    d,h
              jp    nc,0x4445
              ld    c,c
              ld    c,l
              daa   
              ld    b,h
              jr    nz,$+67
              ld    d,d
              ld    d,d
              ld    b,c
              ld    e,c
              call  nz,0x5649
              ld    c,c
              ld    d,e
              ld    c,c
              ld    c,a
              ld    c,(hl)
              jr    nz,$+68
              ld    e,c
              jr    nz,$+92
              ld    b,l
              ld    d,d
              ld    c,a
              ret   
              ld    c,h
              ld    c,h
              ld    b,l
              ld    b,a
              ld    b,c
              ld    c,h
              jr    nz,$+70
              ld    c,c
              ld    d,d
              ld    b,l
              ld    b,e
              ld    d,h
              call  nc,0x5059
              ld    b,l
              jr    nz,$+79
              ld    c,c
              ld    d,e
              ld    c,l
              ld    b,c
              ld    d,h
              ld    b,e
              ld    c,b
              rst   8
              ld    d,l
              ld    d,h
              jr    nz,$+81
              ld    b,(hl)
              jr    nz,$+85
              ld    d,b
              ld    b,c
              ld    b,e
              ld    b,l
              out   (0x54),a
              ld    d,d
              ld    c,c
              ld    c,(hl)
              ld    b,a
              jr    nz,$+86
              ld    c,a
              ld    c,a
              jr    nz,$+78
              ld    c,a
              ld    c,(hl)
              ld    b,a
              add   a,0x4F
              ld    d,d
              ld    c,l
              ld    d,l
              ld    c,h
              ld    b,c
              jr    nz,$+86
              ld    c,a
              ld    c,a
              jr    nz,$+69
              ld    c,a
              ld    c,l
              ld    d,b
              ld    c,h
              ld    b,l
              ld    e,b
              jp    0x4E41
              daa   
              ld    d,h
              jr    nz,$+69
              ld    c,a
              ld    c,(hl)
              ld    d,h
              adc   a,0x4F
              jr    nz,$+84
              ld    b,l
              ld    d,e
              ld    d,l
              ld    c,l
              ld    b,l
              jp    nc,0x5345
              ld    d,l
              ld    c,l
              ld    b,l
              jr    nz,$+89
              ld    c,c
              ld    d,h
              ld    c,b
              ld    c,a
              ld    d,l
              ld    d,h
              push  de
              ld    c,(hl)
              ld    d,b
              ld    d,d
              ld    c,c
              ld    c,(hl)
              ld    d,h
              ld    b,c
              ld    b,d
              ld    c,h
              ld    b,l
              call  0x5349
              ld    d,e
              ld    c,c
              ld    c,(hl)
              ld    b,a
              jr    nz,$+81
              ld    d,b
              ld    b,l
              ld    d,d
              ld    b,c
              ld    c,(hl)
              ld    b,h
              jp    nz,0x4441
              jr    nz,$+72
              ld    c,c
              ld    c,h
              ld    b,l
              jr    nz,$+70
              ld    b,c
              ld    d,h
              ld    b,c
              call  nz,0x5349
              ld    c,e
              jr    nz,$+69
              ld    c,a
              ld    c,l
              ld    c,l
              ld    b,c
              ld    c,(hl)
              ld    b,h
              ccf   
              ld    d,e
              ld    e,c
              ld    c,(hl)
              ld    d,h
              ld    b,c
              ld    e,b
              jr    nz,$+71
              ld    d,d
              ld    d,d
              ld    c,a
              ld    d,d
              dec   c
              nop   
              ld    a,(hl)
              or    a
              jr    nz,$+9
              ld    a,0x20
              ld    (hl),a
              inc   hl
              xor   a
              ld    (hl),a
              dec   hl
              dec   hl
              pop   af
              ret   
              ld    (0x787D),a
              ld    a,0x10
              ld    (0x7846),a
              ret   
              ld    a,(hl)
              bit   6,a
              jr    z,$+7
              cp    0x80
              jp    c,0x3E5D
              pop   bc
              ld    de,0x3E53
              push  de
              push  bc
              jp    0x0502
              ret   c
              ld    hl,0x3E1A
              call  OUTSTR
              jp    INPUT_LINE_READ
              cp    0x62
              jr    nz,$+59
              and   0xBF
              ld    (de),a
              inc   hl
              inc   de
              dec   b
              jp    z,0x04EE
              ld    a,(hl)
              bit   7,a
              jr    nz,$+8
              bit   6,a
              jr    nz,$+14
              jr    $+8
              and   0x8F
              or    0x80
              jr    $+25
              or    0xC0
              jr    $+21
              cp    0x62
              jr    nz,$+11
              push  hl
              ld    hl,0x7839
              bit   4,(hl)
              pop   hl
              jr    z,$+16
              bit   5,a
              jr    z,$+4
              and   0xBF
              ld    (de),a
              inc   hl
              inc   de
              djnz  $-43
              jp    0x04EE
              bit   5,a
              jr    z,$+4
              and   0xBF
              ld    (de),a
              inc   hl
              inc   de
              djnz  $-99
              jp    0x04EE
              ld    a,(0x7818)
              or    a
              jp    nz,0x04B8
              jp    0x3E6A
              ld    a,(0x7818)
              or    a
              jr    nz,$+5
              res   6,(hl)
              ret   
              set   6,(hl)
              ret   
              ld    a,(0x7818)
              or    a
              ld    a,0x20
              jr    nz,$+4
              or    0x40
              ld    (hl),a
              ret   
              push  af
              ld    a,(0x7818)
              or    a
              jr    z,$+9
              pop   af
              and   0x3F
              push  hl
              jp    0x31AB
              pop   af
              or    0x40
              push  hl
              ld    hl,0x7838
              bit   1,(hl)
              pop   hl
              jr    z,$+4
              and   0xBF
              jp    0x31B5
              ld    a,(0x7818)
              or    a
              ld    a,(hl)
              jr    nz,$+5
              cp    0x60
              ret   
              cp    0x20
              ret   
              ld    a,(0x7818)
              or    a
              ld    a,0x20
              jr    nz,$+4
              or    0x40
              ld    (de),a
              ret   
              ld    b,0x20
              ld    a,(0x7818)
              or    a
              ld    a,0x20
              ret   nz
              or    0x40
              ret   
              ld    de,0x71E0
              ld    a,(0x7818)
              or    a
              ret   nz
              pop   af
              ld    a,(hl)
              or    a
              ret   z
              res   6,a
              ld    (de),a
              inc   de
              inc   hl
              jr    $-8
              ld    a,(0x7818)
              or    a
              ld    a,(hl)
              jr    nz,$+9
              set   6,a
              ld    (de),a
              inc   de
              ld    a,0x7A
              ret   
              ld    (de),a
              ld    a,0x3A
              ret   
              push  af
              ld    a,(0x7818)
              or    a
              jr    nz,$+7
              pop   af
              or    0x40
              ld    (de),a
              ret   
              pop   af
              and   0x3F
              ld    (de),a
              ret   
              push  af
              ld    a,(0x7818)
              or    a
              jr    nz,$+11
              pop   af
              bit   6,a
              jp    nz,0x3938
              jp    0x3931
              pop   af
              bit   6,a
              jp    z,0x3938
              jp    0x3931
              jp    0x3931
              push  af
              ld    a,(0x7818)
              or    a
              jr    nz,$+8
              pop   af
              and   0x3F
              jp    0x3154
              pop   af
              and   0x7F
              jp    0x3154
              call  0x3775
              ret   nc
              pop   hl
              jp    0x3711
              ld    a,(0x7819)
              ld    b,a
              ld    a,(0x7818)
              cp    b
              jp    z,0x30E8
              ld    (0x7819),a
              ld    hl,0x7000
              ld    bc,0x0200
              ld    a,(hl)
              or    a
              jp    m,0x3F97
              xor   0x40
              ld    (hl),a
              inc   hl
              dec   bc
              ld    a,b
              or    c
              jr    nz,$-12
              jp    0x30E8
              ld    a,(0x68FD)
              bit   2,a
              ld    a,0x20
              jr    nz,$+10
              or    0x40
              ld    (0x7818),a
              ld    (0x7819),a
              ld    (0x783C),a
              jp    CLRSCR
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
              rst   0x38
