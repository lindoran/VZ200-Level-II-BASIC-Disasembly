; z80bench export — .
; Generated: Sun May 24 22:11:18 2026
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
              DEFB  0x00,0x00,0x00 ; unused

; Restart 10
              jp    0x7803         ; Jump via RAM vector 7803H to address 1D78H

; Read a character via Device Control Block (DCB)
              push  bc             ; Save BC
              ld    b,0x01         ; Set B for DCB check
              jr    $+48           ; to DCB call routine

; Restart 18
              jp    0x7806         ; Jump via RAM vector 7806H to address 1C90H

; Output a character via Device Control Block (DCB)
              push  bc             ; Save BC
              ld    b,0x02         ; Set B for DCB check
              jr    $+40           ; to DCB call routine

; Restart 20
              jp    0x7809         ; Jump via RAM vector 7809H to address 25D9H
              push  bc             ; not used
              ld    b,0x04
              jr    $+32

; Restart 28
              jp    0x780C         ; Jump to RAM vector 780CH

; Keyboard query
; On return, Reg. A contains the ASCII code of a pressed key, or 0 if none 
; pressed.
              ld    de,0x7815      ; Load DCB address for keyboard
              jr    $-27           ; continue at 13H

; Restart 30
              jp    0x780F         ; Jump to RAM vector 780FH

; Screen output via DCB
; Not used on LASER 110-310.
              ld    de,0x781D      ; Load DCB address
              jr    $-27           ; continue at 1BH

; Restart 38 - Interrupt vector for IM1
              jp    0x2EB8         ; to Interrupt Service Routine

; Printer output via Device Control Block (DCB)
; Reg. A must contain the character to be output
              ld    de,0x7825      ; Load DCB address
              jr    $-35           ; continue at 1BH
              jp    0x2EFD         ; to keyboard read routine
              ret                  ; not used
              DEFB  0x00,0x00      ; unused
              jp    DCB_DISPATCH   ; Jump to DCB call routine

; Keyboard query
; waits until a key is pressed.
; Output: A-reg contains ASCII code of the pressed key
              call  KBD_QUERY      ; Evaluate keyboard
              or    a              ; Key pressed?
              ret   nz             ; Yes, return
              jr    $-5            ; no, wait

; Save character from cursor position
              ld    hl,(0x7820)    ; Load cursor address
              ld    a,(hl)         ; Load character
              ld    (0x783C),a     ; save to 783CH
              ret   
              DEFB  0x4C,0xFE,0x54,0x20,0xD6,0xFD,0x21,0xF1 ; not used
              dec   bc
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
              ld    hl,FDIV_HELPER_ROM ; Source: 18F7H
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
              call  DECZ           ; Handle memory size input
              or    a
              jp    nz,SYNTAX_ERR_HANDLER
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
              jp    c,ERROR_ENTRY  ; otherwise: OUT OF MEMORY error (197AH)
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
              DEFB  0x00,0x7E,0x23,0xFE,0x0D,0x56,0x49,0x44 ; Artifact? No caller
              DEFB  0x45,0x4F,0x20,0x54,0x45,0x43,0x48,0x4E
              DEFB  0x4F,0x4C,0x4F,0x47,0x59,0x0D,0x42,0x41
              DEFB  0x53,0x49,0x43,0x20,0x56,0x32,0x2E,0x30
              DEFB  0x0D,0x0D,0x00 ; term with 00

; L3 Error Handler (?L3 ERROR)
; ERROR_L3: (defined in symbols.sym)
              ld    e,0x2C         ; Load error code 44 (L3 Error)
              jp    ERROR_HANDLER  ; Jump to main error handler

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
              DEFB  0x80,0x80,0x80,0xB8,0xB8,0x80,0xB8,0xB8 ; Char 0x80
              DEFB  0x80,0x87,0x80,0xBF,0xB8,0x87,0xB8,0xBF ; Char 0x84
              DEFB  0x87,0x80,0x87,0xB8,0xBF,0x80,0xBF,0xB8 ; Char 0x88
              DEFB  0x87,0x87,0x87,0xBF,0xBF,0x87,0xBF,0xBF ; Char 0x8C

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
              jp    RDLINE         ; back to line entry
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
              call  RDLINE         ; read line
              ret                  ; Return

; RUN command for CRUN auto-start
              DEFB  0x52,0x55,0x4E,0x00,0xC4 ; Data text 'RUN\00'

; Printer driver
PRINTER_DRIVER:
              inc   sp             ; Increment sp
              ld    (0xA3CD),a     ; Load (0xA3CD) from a
              ld    a,(de)         ; Load a from (de)
              call  0x17D8         ; Call 0x17D8
              call  OUT_HELPER_ROM ; Call 0x190D
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
              jp    MAIN_LOOP      ; to BASIC - main loop

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
              ld    bc,MAIN_LOOP_ENTRY ; load address of main loop
              jp    0x19AE         ; init BASIC variables and pointers.

; The following area from 6D2 to 707 is transferred to the RAM area from 7800 
; to 7835
; Restart Vectors
RAM_VECTOR_BLOCK:
              jp    SYNCHR         ; RST 8H (compare 1 character)
              jp    CHRGTR         ; RST 10H (next character)
              jp    DCOMPR         ; RST 18H (compare HL/DE)
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
              DEFB  0x01,0xF4,0x2E,0x00,0x00,0x00,0x4B,0x49 ; DCB type

; Screen - Device Control Block
; not used except for the cursor address.
              DEFB  0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00 ; DCB type (unknown)

; Printer - Device Control Block
              DEFB  0x06,0x8D,0x05,0x43,0x00,0x00 ; DCB type
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
              ld    hl,FHALF       ; address of constant 0.5
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
              jp    ERROR_HANDLER  ; to error routine

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
              nop                  ; = 1
              nop   
              nop   
              add   a,c

; SINGLE PRECISION CONSTANTS STORAGE LOCATION 2 – “LOGCN2”
LOGCN2:
              inc   bc             ; number of constants = 3
              xor   d
              ld    d,(hl)
              add   hl,de
              add   a,b
              pop   af
              ld    (0x8076),hl
              ld    b,l
              xor   d
              jr    c,$-124

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
              call  POLYN          ; calculate series
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
              jp    z,DIV_ZERO_ERR_HANDLER ; yes, DIVISION BY ZERO - Error

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
              pop   bc
              pop   hl
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
              jp    ERROR_HANDLER  ; Display error

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
              jp    c,0x0C26       ; on overflow, special routine
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
              pop   bc
              pop   hl
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
              jp    z,DIV_ZERO_ERR_HANDLER ; Yes, DIVISION BY ZERO error
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
              ld    (de),a
              inc   b
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
              jp    z,STR_TO_NUM_DP ; yes!
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
              jp    p,SYNTAX_ERR_HANDLER ; not integer, SYNTAX - Error
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
              ld    e,0x32
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
              jp    c,PUSTR_EXP_INT ; yes!
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
              ld    de,FFXDXM      ; Address constant 1D16
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

; Single precision number
              ld    bc,0xB60E      ; Set Y = 1E6
              ld    de,0x1BCA
              call  FCOMP          ; Value >= 1E6?
              jp    p,PUSTR_OVERFLOW_STR ; Yes, field overflow
              ld    d,0x06         ; Precision (6 digits) in D
              call  SIGN           ; Value = 0?
              call  nz,GET_10_EXP  ; No, Exp - Precision + 1 in A
              pop   hl             ; Load buffer pointer
              pop   bc             ; Load length parameter
              jp    m,PUSTR_HAS_DECIMAL ; Decimal places? Yes - jump

; No decimal places
              push  bc             ; Length parameter on stack
              ld    e,a            ; Exp - Precision + 1 in E
              ld    a,b            ; Integer field length in A
              sub   d              ; - Exponent
              sub   e              ; - 1 >= 0?
              call  p,PUT_ZEROS    ; Yes, corresponding number of zeros in buffer
              call  GET_FMT_PARAMS ; Determine parameters for '.' and ','
              call  FAC_TO_STR     ; Generate string
              or    e              ; Exponent - Precision + 1 > 0?
              call  nz,0x1277      ; Yes, corresponding number of zeros in buffer with '.' and ','
              or    e              ; Exponent - Precision + 1 > 0?
              call  nz,SET_DOT_COMMA ; Yes, '.' and ',' in buffer
              pop   de             ; Load length parameter
              jp    0x10B6         ; Execute remaining formatting

; Decimal places present
              ld    e,a            ; Exponent - Precision + 1 to E
              ld    a,c            ; Fractional field length in A
              or    a              ; > 0?
              call  nz,0x0F16      ; Yes, - 1 for '.'
              add   a,e            ; More than present?
              jp    m,0x1162       ; Yes!
              xor   a              ; No, number of superfluous places = 0
              push  bc             ; Length parameter on stack
              push  af             ; -Number of superfluous places on stack
              call  m,FINDIV       ; Remove superfluous places
              jp    m,0x1164       ; Done? No - back
              pop   bc             ; -Number of superfluous places from stack
              ld    a,e            ; -Number of fractional places to be actually output in A
              sub   b              ; Fractional places in A
              pop   bc             ; Reload length parameter
              ld    e,a            ; Fractional places in E
              add   a,d            ; + Precision > 0?
              ld    a,b            ; Integer field length in A
              jp    m,PUSTR_ONLY_DECIMAL ; Yes!
              sub   d              ; Integer field length - Precision
              sub   e              ; + Fractional places to be output > 0?
              call  p,PUT_ZEROS    ; Corresponding number of zeros in buffer
              push  bc             ; Length parameter on stack
              call  GET_FMT_PARAMS ; Determine parameters for '.' and ','
              jr    $+19           ; Continue at 1190H

; Only fractional places
              call  PUT_ZEROS      ; Zeros for integer places in buffer
              ld    a,c            ; Fractional field length in A
              call  0x1294         ; '.' in buffer
              ld    c,a            ; Fractional field length in C
              xor   a              ; Actually output fractional places
              sub   d              ; - Precision
              sub   e              ; = Number of zeros to be inserted
              call  PUT_ZEROS      ; Enter zeros into buffer
              push  bc             ; Save length parameter on stack
              ld    b,a            ; Clear parameters for '.' and ','
              ld    c,a
              call  FAC_TO_STR     ; String into buffer
              pop   bc             ; Load length parameter from stack
              or    c              ; Fractional field length > 0?
              jr    nz,$+5         ; Yes!
              ld    hl,(0x78F3)    ; Load '.' address
              add   a,e            ; Fractional field length - number of actually output fractional 
              dec   a              ; - 1 for '.'
              call  p,PUT_ZEROS    ; > 0? Output corresponding number of zeros
              ld    d,b            ; Integer field length in D
              jp    0x10BF         ; Continue at 10BFH

; Formatted exponent output
              push  hl             ; Buffer pointer on stack
              push  de             ; Format flag on stack
              call  INEG           ; Convert integer to single precision
              pop   de             ; Reload format flag
              xor   a              ; Set flag for single precision

; Entry for single and double precision
              jp    z,0x11B0       ; Single precision? => jump
              ld    e,0x10         ; Double precision = 16 places
              DEFB  0x01           ; LD BC trick
              ld    e,0x06         ; Single precision = 6 places
              call  SIGN           ; Value = 0?
              scf                  ; Yes, set Carry
              call  nz,GET_10_EXP  ; No, Exponent - Precision + 1, C=0
              pop   hl             ; Load buffer pointer
              pop   bc             ; Load length parameter
              push  af             ; Save Exp-Precision+1 and flag
              ld    a,c            ; Fractional field length = 0?
              or    a
              push  af             ; Fractional field length on stack
              call  nz,0x0F16      ; No, fractional field length - 1
              add   a,b            ; Add integer field length
              ld    c,a            ; Total field length in C
              ld    a,d            ; Test format flag
              and   0x04           ; Sign behind number? (Bit 2)
              cp    0x01           ; Yes, 0 in format flag
              sbc   a,a            ; Otherwise -1
              ld    d,a
              add   a,c            ; Total length - 1, if sign not behind number
              ld    c,a            ; in C
              sub   e              ; - Exp - Precision + 1 results in
              push  af             ; -Number of places to be rounded away
              push  bc             ; Length parameter on stack
              call  m,FINDIV       ; Round away places
              jp    m,PUSTR_ROUND_LOOP ; Loop until count = 0
              pop   bc             ; Load length parameter
              pop   af             ; Number of rounded away places
              push  bc             ; Length parameter back on stack
              push  af             ; Number of rounded away places on stack
              jp    m,PUSTR_ROUND_DONE ; Places rounded away? Yes to 11DEH
              xor   a              ; No places rounded away
              cpl                  ; Determine positive number
              inc   a              ; + 1
              add   a,b            ; + Integer length
              inc   a              ; + 1
              add   a,d            ; - 1, if sign before number
              ld    b,a            ; = Position of '.'
              ld    c,0x00         ; Parameter for '.' and ',' = 0 (no ',')
              call  FAC_TO_STR     ; Transfer string to buffer
              pop   af             ; Total length - Precision > 0?
              call  p,WRITE_ZEROS_FMT ; Yes, corresponding number of zeros in buffer
              pop   bc             ; Reload length parameter
              pop   af             ; Fractional length = 0?
              call  z,DCXHRT       ; Yes, delete '.' in buffer
              pop   af             ; Value = 0?
              jr    c,$+5          ; Yes!
              add   a,e            ; Determine exponent to be output
              sub   b              ; SUB B
              sub   d              ; SUB D
              push  bc             ; Length parameter on stack
              call  0x1074         ; Exponent in buffer
              ex    de,hl          ; Buffer end address in HL
              pop   de             ; Length parameter in DE
              jp    0x10BF         ; Continue at 10BFH

; Multiply or divide number by 10 as many times as needed until exactly 6 or 16
; digits are present.
              push  de             ; Save DE
              xor   a              ; Number of shifts = 0
              push  af             ; Number of shifts on stack
              rst   0x20           ; Test type
              jp    po,GET_10_EXP_START ; Single precision!
              ld    a,(FAC)        ; Value >= 65536?
              cp    0x91           ; Value >= 65536?
              jp    nc,GET_10_EXP_START ; Yes!
              ld    de,TENTEN      ; Address constant 1D10
              ld    hl,FAC2        ; Address Y
              call  VMOVE          ; Transfer 1D10 to Y
              call  DMULT          ; Value * 1D10
              pop   af             ; Load number of shifts
              sub   0x0A           ; Subtract 10
              push  af             ; And back on stack
              jr    $-24           ; Continue
              call  GET_10_EXP_TEST ; Yes, continue at 1244H
              rst   0x20           ; Test type
              jp    pe,GET_10_EXP_DBL ; Double precision? Yes, to 1234H
              ld    bc,0x9143      ; Constant 100000 in Y
              ld    de,0x4FF9      ; Load DE with 4FF9H
              call  FCOMP          ; Value > 100000?
              jr    $+8            ; Continue at 123AH
              ld    de,FOUTDL      ; Address constant 1D15
              call  0x0A49         ; Value >= 1D15?
              jp    p,0x124C       ; Yes!
              pop   af             ; Load shifts
              call  0x0F0B         ; Value / 10, shifts + 1
              push  af             ; Shifts on stack
              jr    $-29           ; Continue
              pop   af             ; Load shifts
              call  FINDIV         ; Value * 10, shifts - 1
              push  af             ; Shifts on stack
              call  GET_10_EXP_TEST ; Yes, continue at 124FH
              pop   af             ; Load shifts
              pop   de             ; Restore DE
              ret                  ; Return

; Test if number is large (>= 1E6 or 1D16)
              rst   0x20           ; Test type
              jp    pe,0x125E      ; Double precision? Yes, to 125EH
              ld    bc,0x9474      ; Constant 1E6 in Y
              ld    de,0x23F8      ; Load DE with 23F8H
              call  FCOMP          ; Value >= 1D6?
              jr    $+8            ; Continue
              ld    de,FOUTDU      ; Constant 1D16 in Y
              call  0x0A49         ; Value >= 1D16?
              pop   hl             ; Load return address
              jp    p,GET_10_EXP_LOOP_2 ; Yes, to 1244H
              jp    (hl)           ; No, normal return

; *******************************
; * Write zeros to buffer
; *******************************
WRITE_ZEROS:
              or    a              ; Count = 0?
              ret   z              ; Yes, done
              dec   a              ; Count - 1
              ld    (hl),0x30      ; '0' in buffer
              inc   hl             ; Buffer address + 1
              jr    $-5            ; Continue at 126AH

; *******************************
; * Write zeros with '.' and ','
; *******************************
WRITE_ZEROS_FMT:
              jr    nz,$+6         ; Count > 0? Yes, jump
              ret   z              ; = 0?, done
              call  SET_DOT_COMMA  ; Set '.' and ','
              ld    (hl),0x30      ; '0' in buffer
              inc   hl             ; Buffer address + 1
              dec   a              ; Count - 1
              jr    $-8            ; Back

; *******************************
; * Determine '.' and ',' params
; *******************************
GET_FMT_PARAMS:
              ld    a,e            ; Number of shifts in A
              add   a,d            ; + Precision
              inc   a              ; + 1
              ld    b,a            ; = Decimal point position
              inc   a              ; + 1
              sub   0x03           ; Determine position of ','
              jr    nc,$-2         ; -3 until A is negative
              add   a,0x05         ; + 5
              ld    c,a            ; As ',' parameter in C
              ld    a,(FMT_FLAG)   ; Load format flag
              and   0x40           ; ',' requested? (Bit 6)
              ret   nz             ; Yes, OK
              ld    c,a            ; No, clear ',' parameter
              ret                  ; Return

; *******************************
; * Set '.' and ','
; *******************************
; SET_DOT_COMMA: (defined in symbols.sym)
              dec   b              ; Decimal point position - 1
              jr    nz,$+10        ; Decimal point reached? No!
              ld    (hl),0x2E      ; '.' in buffer
              ld    (0x78F3),hl    ; Remember address of '.'
              inc   hl             ; Buffer pointer + 1
              ld    c,b            ; ',' = 0 (no more ',' to set)
              ret                  ; Done
              dec   c              ; ',' parameter - 1. Next position?
              ret   nz             ; No, back
              ld    (hl),0x2C      ; ',' in buffer
              inc   hl             ; Buffer pointer + 1
              ld    c,0x03         ; ',' parameter = 3 for next ','
              ret                  ; Done

; *******************************
; * Convert single/double prec to ASCII
; *******************************
FF_TO_ASCII:
              push  de             ; Save DE
              rst   0x20           ; Test type
              jp    po,0x12EA      ; Single precision? Continue at 12EAH
              push  bc             ; Parameters for '.' and ',' on stack
              push  hl             ; Buffer pointer on stack
              call  VMOVAF         ; Number in Y
              ld    hl,DHALF       ; Address constant 0.5
              call  VMOVFM         ; 0.5 in X
              call  DADD           ; Number + 0.5 to X
              xor   a              ; Clear normalization flag (Cy)
              call  0x0B7B         ; Separate fractional part
              pop   hl             ; Load buffer pointer
              pop   bc             ; Load '.' and ',' parameters
              ld    de,FODTBL      ; Address fixed-point constants 1D15-1D16
              ld    a,0x0A         ; Digit counter = 10
              call  SET_DOT_COMMA  ; Set '.' and ','
              push  bc             ; Save '.' and ',' parameters
              push  af             ; Save digit counter
              push  hl             ; Save buffer pointer
              push  de             ; Save constant address
              ld    b,0x2F         ; Digit value = '0' - 1
              inc   b              ; Digit value + 1
              pop   hl             ; Constant address in HL
              push  hl             ; And back on stack
              call  0x0D48         ; Number - constant. Underflow?
              jr    nc,$-6         ; No, continue
              pop   hl             ; Constant address in HL
              call  0x0D36         ; Number + constant
              ex    de,hl          ; Constant address in DE (next constant)
              pop   hl             ; Load buffer pointer
              ld    (hl),b         ; Enter digit in buffer
              inc   hl             ; Buffer pointer + 1
              pop   af             ; Load digit counter
              pop   bc             ; Load '.' and ',' parameters
              dec   a              ; Digit counter - 1. 10 digits produced?
              jr    nz,$-28        ; No, continue
              push  bc             ; Save '.' and ',' parameters
              push  hl             ; Save buffer pointer
              ld    hl,0x791D
              call  MOVFM          ; Rest (< 1D6) with single precision in X
              jr    $+14           ; Continue with single precision
              push  bc             ; Parameters for '.' and ',' on stack
              push  hl             ; Buffer pointer on stack
              call  FP_ADD_HALF    ; Number + 0.5 for rounding
              inc   a              ; Clear normalization flag
              call  DROUND         ; Integer of number in Y
              call  MOVFR          ; Enter number in X
FF_TO_ASCII_CONT:
              pop   hl             ; Load buffer pointer
              pop   bc             ; Load '.' and ',' parameters
              xor   a              ; Clear repetition flag
              ld    de,FOSTBL      ; Address constants 1E5 and 1E4
              ccf                  ; Invert repetition flag
              call  SET_DOT_COMMA  ; Set '.' and ','
              push  bc             ; Parameters for '.' and ',' on stack
              push  af             ; Repetition flag on stack
              push  hl             ; Buffer pointer on stack
              push  de             ; Constant pointer in HL
              call  MOVRF          ; Transfer number to Y
              pop   hl             ; Constant pointer in HL
              ld    b,0x2F         ; Digit code = '0' - 1
              inc   b              ; Digit code + 1
              ld    a,e            ; Number - constant. Underflow?
              sub   (hl)           ; LSB
              ld    e,a
              inc   hl             ; Next digit
              ld    a,d
              sbc   a,(hl)
              ld    d,a
              inc   hl             ; MSB
              ld    a,c
              sbc   a,(hl)
              ld    c,a
              dec   hl             ; Constant pointer - 2
              dec   hl             ; To 1st byte of constant
              jr    nc,$-14        ; No underflow, back
              call  0x07B7         ; Number + constant
              inc   hl             ; Address next constant
              call  MOVFR          ; Transfer number to X
              ex    de,hl          ; Constant address in DE
              pop   hl             ; Load buffer pointer
              ld    (hl),b         ; Enter digit in buffer
              inc   hl             ; Buffer pointer + 1
              pop   af             ; Load repetition flag
              pop   bc             ; Load '.' and ',' parameters
              jr    c,$-43         ; 2 passes? No, back
              inc   de             ; Skip next constant
              inc   de
              ld    a,0x04         ; 4 more digits in integer mode
              jr    $+8            ; Process

; *******************************
; * Convert integer to ASCII
; *******************************
INT_TO_ASCII:
              push  de             ; Format flag on stack
              ld    de,FOITBL      ; Address constants 10000 to 1
              ld    a,0x05         ; Digit counter = 5
              call  SET_DOT_COMMA  ; Output '.' and ','
              push  bc             ; Parameters for '.' and ',' on stack
              push  af             ; Digit counter on stack
              push  hl             ; Buffer pointer on stack
              ex    de,hl          ; Constant address in HL
              ld    c,(hl)         ; Load constant
              inc   hl             ; Address next constant
              ld    b,(hl)
              push  bc             ; And save on stack
              inc   hl             ; Address next constant
              ex    (sp),hl        ; Exchange constant address with constant on stack
              ex    de,hl          ; Constant address in DE
              ld    hl,(FACLO)     ; Load number in HL
              ld    b,0x2F         ; Digit code = '0' - 1
              inc   b              ; Digit code + 1
              ld    a,l            ; Number - constant (LSB)
              sub   e
              ld    l,a
              ld    a,h            ; Number - constant (MSB)
              sbc   a,d
              ld    h,a
              jr    nc,$-7         ; Underflow? No, back
              add   hl,de          ; Number + constant
              ld    (FACLO),hl     ; Save number in X
              pop   de             ; Load constant address
              pop   hl             ; Load buffer pointer
              ld    (hl),b         ; Enter digit in buffer
              inc   hl             ; Buffer pointer + 1
              pop   af             ; Load digit counter
              pop   bc             ; Load '.' and ',' parameters
              dec   a              ; Digit counter - 1
              jr    nz,$-39        ; All digits? No, back
              call  SET_DOT_COMMA  ; Output '.' and ','
              ld    (hl),a         ; Mark end of line with X'00'
              pop   de             ; Restore DE
              ret                  ; Done

; ******************************************************************
; * Constants                                                      *
; ******************************************************************
              DEFB  0x00,0x00,0x00,0x00,0xF9,0x02,0x15,0xA2 ; 10 * 10^9 (double precision)

; ******************************************************************
; * DOUBLE PRECISION CONSTANT STORAGE LOCATION – “FOUTDL”          *
; * A double precision constant equal to 999,999,999,999,999.95    *
; ******************************************************************
              DEFB  0xFD,0xFF,0x9F,0x31,0xA9,0x5F,0x63,0xB2 ; 1 * 10^15 (double precision)

; ******************************************************************
; * DOUBLE PRECISION CONSTANT STORAGE LOCATION – “FOUTDU”          *
; * A double precision constant equal to 9,999,999,999,999,999.5   *
; ******************************************************************
              DEFB  0xFE,0xFF,0x03,0xBF,0xC9,0x1B,0x0E,0xB6 ; 1 * 10^16 (double precision)

; ******************************************************************
; * DOUBLE PRECISION CONSTANT STORAGE LOCATION – “DHALF”           *
; * A double precision constant equal to 0.5D0                     *
; ******************************************************************
              DEFB  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80 ; 0.5 (double precision)

; ******************************************************************
; * DOUBLE PRECISION CONSTANT STORAGE LOCATION – “FFXDXM”          *
; * A double precision constant equal to 1D16                      *
; ******************************************************************
              DEFB  0x00,0x00,0x04,0xBF,0xC9,0x1B,0x0E,0xB6 ; 1 * 10^16 (double precision)

; ******************************************************************
; * DOUBLE PRECISION INTEGER CONSTANT STORAGE LOCATION – “FODTBL”  *
; * Powers of ten table (Double Precision)                         *
; ******************************************************************
              DEFB  0x00,0x80,0xC6,0xA4,0x7E,0x8D,0x03,0x00 ; 10^16 (double precision)
              DEFB  0x40,0x7A,0x10,0xF3,0x5A,0x00,0x00,0xA0
              DEFB  0x72,0x4E,0x18,0x09,0x00,0x00,0x10,0xA5
              DEFB  0xD4,0xE8,0x00,0x00,0x00,0xE8,0x76,0x48
              DEFB  0x17,0x00,0x00,0x00,0xE4,0x0B,0x54,0x02
              DEFB  0x00,0x00,0x00,0xCA,0x9A,0x3B,0x00,0x00
              DEFB  0x00,0x00,0xE1,0xF5,0x05,0x00,0x00,0x00
              DEFB  0x80,0x96,0x98,0x00,0x00,0x00,0x00,0x40 ; 10^8 (double precision)
              DEFB  0x42,0x0F,0x00,0x00,0x00,0x00,0xA0,0x86
              DEFB  0x01,0x10,0x27,0x00,0x10,0x27,0xE8,0x03
              DEFB  0x64,0x00,0x0A,0x00,0x01,0x00

; ******************************************************************
; * Subroutine for SQR and ATN                                     *
; * Performs multiplication with -1                                *
; ******************************************************************
              ld    hl,NNEG        ; X = -X - address in HL
              ex    (sp),hl        ; swap with return address on stack
              jp    (hl)           ; return to calling routine

; ******************************************************************
; * SQR function                                                   *
; * Computes the square root of a number                           *
              call  PUSHF          ; Pack argument on the stack
              ld    hl,FHALF       ; Address constant 0.5
              call  MOVFM          ; and transfer to X
              jr    $+5            ; continue at 13F5H

; ******************************************************************
; * Determine the power of a number                                *
; * Input:  Base on the stack                                      *
              call  FRCSNG         ; Convert exponent to single precision
              pop   bc             ; Transfer base to Y
              pop   de             ; Transfer base to Y

; ******************************************************************
; * EXPONENTIATION FUNCTION (^) – “FNPWR”                          *
              call  SIGN           ; Test exponent
              ld    a,b            ; Exponent of base in A
              jr    z,$+62         ; Exponent = 0? yes, result = 1
              jp    p,0x1404       ; Exponent > 0? yes, jump
              or    a              ; Base = 0 and exponent < 0?
              jp    z,DIV_ZERO_ERR_HANDLER ; yes, DIVISION BY ZERO error
              or    a              ; Base = 0 and exponent > 0?
              jp    z,0x0779       ; yes, 0 as result in X
              push  de             ; Base on stack
              push  bc             ; Base on stack
              ld    a,c            ; Base > 0?
              or    0x7F           ; Mask sign bit
              call  MOVRF          ; Transfer exponent to Y
              jp    p,0x1421       ; Base > 0
              push  de             ; Exponent on stack
              push  bc             ; Exponent on stack
              call  0x0B40         ; Integer portion of exponent in X
              pop   bc             ; Reload exponent
              pop   de             ; Reload exponent
              push  af             ; LSB of INT(exponent) on stack
              call  FCOMP          ; INT(exponent) = exponent?
              pop   hl             ; LSB of INT(exponent) in HL
              ld    a,h            ; INT(exponent) odd?
              rra                  ; Rotate right
              pop   hl             ; Transfer base to X
              ld    (FAC_SIGN),hl  ; MSB
              pop   hl             ; Transfer base to X
              ld    (FACLO),hl     ; LSB
              call  c,GETADR_ENTRY_2 ; Result * (-1)
              call  z,NNEG         ; Base = -base
              push  de             ; Exponent on stack
              push  bc             ; Exponent on stack
              call  FNLOG          ; LOG(base) to X
              pop   bc             ; Load exponent into Y
              pop   de             ; Load exponent into Y
              call  0x0847         ; LOG(base) * exponent

; ******************************************************************
; * EXP function                                                   *
; * Determine the exponential function of a number                 *
              call  PUSHF          ; Argument on stack
              ld    bc,0x8138      ; Constant 1.4427 in Y
              ld    de,0xAA3B      ; Constant 1.4427 in Y
              call  0x0847         ; Argument / LOG(2) in X
              ld    a,(FAC)        ; Binary exponent of result > 136?
              cp    0x88           ; Compare with 136
              jp    nc,MLDVEX      ; yes, continue at 0931H
              call  0x0B40         ; INT(exponent) in A and X
              add   a,0x80         ; Add offset
              add   a,0x02         ; Exponent > 126?
              jp    c,MLDVEX       ; yes, continue at 0931H
              push  af             ; Exponent (with offset) on stack
              ld    hl,FONE        ; INT(Arg / LOG(2)) - 1 into X
              call  0x070B         ; INT(Arg / LOG(2)) - 1 into X
              call  MULLN2         ; * LOG(2)
              pop   af             ; Exponent of result back
              pop   bc             ; Reload argument
              pop   de             ; Reload argument
              push  af             ; Exponent back on stack
              call  FP_SUB_Y_MINUS_X ; X = (LOG(2) * INT(Arg / LN2) - 1) - Arg
              call  NNEG           ; Complement (negate)
              ld    hl,EXP_CONSTANTS ; Evaluate series
              call  0x14A9         ; Evaluate series
              ld    de,START       ; 0.5 * 2^exponent in Y
              pop   bc             ; Reload exponent
              ld    c,d            ; Reload exponent
              jp    0x0847         ; Multiply with series result

; ******************************************************************
; * Constants for exponent series                                  *
; ******************************************************************
              DEFB  0x08,0x40,0x2E,0x94,0x74,0x70,0x4F,0x2E ; 8 constants
              DEFB  0x77,0x6E,0x02,0x88,0x7A,0xE6,0xA0,0x2A
              DEFB  0x7C,0x50,0xAA,0xAA,0x7E,0xFF,0xFF,0x7F
              DEFB  0x7F,0x00,0x00,0x80,0x81,0x00,0x00,0x00
              DEFB  0x81

; ******************************************************************
; * Series calculation 1                                           *
; * K1 * Z + K2 * Z^3 + K3 * Z^5                                   *
              call  PUSHF          ; Transfer X to stack
              ld    de,0x0C32      ; Return address on stack
              push  de             ; (effects multiplication with Z at the end)
              push  hl             ; Constant address on stack
              call  MOVRF          ; Transfer Z to Y
              call  0x0847         ; Z^2 to X
              pop   hl             ; Constant address in HL

; ******************************************************************
; * Series calculation 2                                           *
; * K1 + K2 * Z + K3 * Z^2 + K4 * Z^3                               *
; * Input:  Same as series calculation 1                           *
; * Output: Same as series calculation 1                           *
; ******************************************************************
              call  PUSHF          ; Z on stack
              ld    a,(hl)         ; Number of constants in A
              inc   hl             ; Address of 1st constant
              call  MOVFM          ; 1st constant in X
              DEFB  0x06           ; Dummy command (LD B, 0xF1)
              pop   af             ; Load constant counter
              pop   bc             ; Z or Z^2 (series 2 or 1) in Y
              pop   de             ; Z or Z^2 (series 2 or 1) in Y
              dec   a              ; Constant counter - 1
              ret   z              ; finished!
              push  de             ; Y back on stack
              push  bc             ; Y back on stack
              push  af             ; Constant counter on stack
              push  hl             ; Constant address on stack
              call  0x0847         ; X * Z (or Z^2)
              pop   hl             ; Load constant address
              call  MOVRM          ; Next constant in Y
              push  hl             ; Constant address on stack
              call  FP_ADD_X_PLUS_Y ; Add constant to X
              pop   hl             ; Reload constant address
              jr    $-21           ; continue

; RND - Function
; Generate random number
              call  FRCINT         ; Convert argument to integer
              ld    a,h            ; Is argument < 0?
              or    a
              jp    m,0x1E4A       ; Yes, FUNCTION CODE error
              or    l              ; Is argument = 0?
              jp    z,RND0         ; Yes, generate random number between 0 and 1
              push  hl             ; Argument on stack
              call  RND0           ; Real random number in X
              call  MOVRF          ; Transfer to Y
              ex    de,hl          ; Reload argument and
              ex    (sp),hl        ; Random number on stack
              push  bc
              call  0x0ACF         ; Argument with single precision in X
              pop   bc             ; Random number back in Y
              pop   de
              call  0x0847         ; Random number * Argument
              ld    hl,FONE        ; + 1
              call  0x070B
              jp    0x0B40         ; Result = INT(random number * Arg + 1)

; New random number = old random number * 4253261 + 372837
              ld    hl,RND_MULT_TABLE ; Address of the multiplier
              push  hl             ; on stack
              ld    de,START       ; Clear result register (CDE)
              ld    c,e
              ld    h,0x03         ; Byte counter = 3
              ld    l,0x08         ; Bit counter = 8
              ex    de,hl          ; Result register * 2
              add   hl,hl          ; LSB
              ex    de,hl
              ld    a,c            ; MSB
              rla   
              ld    c,a
              ex    (sp),hl        ; Multiplier address in HL
              ld    a,(hl)         ; Byte of the multiplier in A
              rlca                 ; Most significant bit in carry
              ld    (hl),a         ; and save it back
              ex    (sp),hl        ; Multiplier address on stack
              jp    nc,RND02       ; Bit not set, no addition
              push  hl
              ld    hl,(RND_SEED)  ; Add last random number
              add   hl,de          ; LSB
              ex    de,hl
              ld    a,(0x78AC)     ; MSB
              adc   a,c
              ld    c,a
              pop   hl
              dec   l              ; Bit counter - 1
              jp    nz,RND01       ; Byte processed? no-back
              ex    (sp),hl        ; Multiplier address in HL
              inc   hl             ; + 1
              ex    (sp),hl        ; and back on the stack
              dec   h              ; Byte counter - 1
              jp    nz,RND00       ; Finished? no-back
              pop   hl             ; Correct stack
              ld    hl,0xB065      ; Result + 372837 = new random number
              add   hl,de          ; LSB
              ld    (RND_SEED),hl
              call  VALSNG         ; Type = single precision
              ld    a,0x05         ; MSB
              adc   a,c
              ld    (0x78AC),a
              ex    de,hl          ; Transfer to Y
              ld    b,0x80         ; Exp. Y = 0, so that it's between 0 and 1
              ld    hl,0x7925      ; Set sign flag
              ld    (hl),b         ; Result = positive
              dec   hl             ; Exponent X = Exponent Y
              ld    (hl),b
              ld    c,a            ; MSB in C
              ld    b,0x00         ; Clear LSB
              jp    0x0765         ; to normalization

; COS - Function
; Determine the cosine of an angle
              ld    hl,PI2         ; Address constant PI/2
              call  0x070B         ; Add PI/2 to argument

; SIN - Function
; Determine the sine of an angle
              call  PUSHF          ; Argument on stack
              ld    bc,0x8349      ; Constant 2PI in Y
              ld    de,0x0FDB
              call  MOVFR          ; Transfer 2PI to X
              pop   bc             ; Argument in Y
              pop   de
              call  0x08A2         ; X = Argument / 2PI
              call  PUSHF          ; Argument / 2PI on stack
              call  0x0B40         ; INT(Arg/2PI) in X
              pop   bc             ; Arg/2PI from stack in Y
              pop   de
              call  FP_SUB_Y_MINUS_X ; X = Arg/2PI - INT(Arg/2PI)

; Transform interval (0..1) to interval (-0.25 ... 0.25)
              ld    hl,F025        ; Address constant 0.25
              call  FP_SUB_HALF    ; 0.25 - X in X
              call  SIGN           ; Is X >= 0?
              scf                  ; Clear flag for multiplication with (-1)
              jp    p,0x1577       ; Yes!
              call  FP_ADD_HALF    ; 0.5 + X in X
              call  SIGN           ; Is X >= 0?
              or    a              ; Set flag for multiplication with (-1)
              push  af             ; Flag on stack
              call  p,NNEG         ; Yes! X = -X
              ld    hl,F025        ; Address constant 0.25
              call  0x070B         ; 0.25 + X in X
              pop   af             ; Load flag
              call  nc,NNEG        ; Carry = 0? yes - X = -X
              ld    hl,SIN_CONST   ; Constants for series calculation
              jp    POLYN          ; Calculate series
              DEFB  0xDB,0x0F,0x49,0x81,0x00,0x00,0x00,0x7F
              DEFB  0x05,0xBA,0xD7,0x1E,0x86,0x64,0x26,0x99
              DEFB  0x87,0x58,0x34,0x23,0x87,0xE0,0x5D,0xA5
              DEFB  0x86,0xDA,0x0F,0x49,0x83

; TAN - Function
; Calculates the tangent of an angle
              call  PUSHF          ; Argument on stack
              call  FNSIN          ; Determine Sin(Arg)
              pop   bc             ; Argument in Y
              pop   hl
              call  PUSHF          ; Sin(Arg) on stack
              ex    de,hl
              call  MOVFR          ; Transfer argument to X
              call  FNCOS          ; Determine Cos(Arg)
              jp    0x08A0         ; Tan(Arg) = Sin(Arg) / Cos(Arg)

; ATN - Function
; Arc-tangent calculation
              call  SIGN           ; Is argument < 0?
              call  m,GETADR_ENTRY_2 ; Yes, result * (-1)
              call  m,NNEG         ; Abs(Argument) in X
              ld    a,(FAC)        ; Is argument < 1?
              cp    0x81
              jr    c,$+14         ; Yes!
              ld    bc,0x8100      ; No! Y = 1
              ld    d,c
              ld    e,c
              call  0x08A2         ; X = 1 / Argument
              ld    hl,FP_SUB_HALF ; Jump address to 0710 on stack
              push  hl             ; on stack
              ld    hl,ATN_CONST   ; Address constants for series
              call  POLYN          ; Calculate series
              ld    hl,PI2         ; Load address of PI/2
              ret                  ; continue at 0710H

; Constants for the Arcus-Tangens series
              DEFB  0x09           ; Number = 9
              DEFB  0x4A,0xD7,0x3B,0x78 ; = 2.86623 E-03
              DEFB  0x02,0x6E,0x84,0x7B ; = -0.0161657
              DEFB  0xFE,0xC1,0x2F,0x7C ; = 0.0429096
              DEFB  0x74,0x31,0x9A,0x7D ; = -0.0752896
              DEFB  0x84,0x3D,0x5A,0x7D ; = 0.106563
              DEFB  0xC8,0x7F,0x91,0x7E ; = -0.142089
              DEFB  0xE4,0xBB,0x4C,0x7E ; = 0.199936
              DEFB  0x6C,0xAA,0xAA,0x7F ; = -0.333331
              DEFB  0x00,0x00,0x00,0x81 ; = 1

; (Tokens D7 to FA)
              DEFW  0x098A         ; D7 = SGN
              DEFW  0x0B37         ; D8 = INT
              DEFW  0x0977         ; D9 = ABS
              DEFW  0x27D4,0x2AEF,0x27F5 ; DA = FRE
              DEFW  0x13E7         ; DD = SQR
              DEFW  0x14C9         ; DE = RND
              DEFW  0x0809         ; DF = LOG
              DEFW  0x1439         ; E0 = EXP
              DEFW  0x1541         ; E1 = COS
              DEFW  0x1547         ; E2 = SIN
              DEFW  0x15A8         ; E3 = TAN
              DEFW  0x15BD         ; E4 = ATN
              DEFW  0x2CAA         ; E5 = PEEK
              DEFW  0x7952         ; E6 = CVI
              DEFW  0x7958         ; E7 = CVS
              DEFW  0x795E         ; E8 = CVD
              DEFW  0x7961         ; E9 = EOF
              DEFW  0x7964         ; EA = LOC
              DEFW  0x7967         ; EB = LOF
              DEFW  0x796A         ; EC = MKI$
              DEFW  0x796D         ; ED = MKS$
              DEFW  0x7970         ; EE = MKD$
              DEFW  0x0A7F         ; EF = CINT
              DEFW  0x0AB1         ; F0 = CSNG
              DEFW  0x0ADB         ; F1 = CDBL
              DEFW  0x0B26         ; F2 = FIX
              DEFW  0x2A03,0x2836  ; F3 = LEN
              DEFW  0x2AC5,0x2A0F  ; F5 = VAL
              DEFW  0x2A1F,0x2A61  ; F7 = CHR$
              DEFW  0x2A91,0x2A9A  ; F9 = RIGHT$

; BASIC keyword table (sorted by token in ascending order)
KWD_80_END:
              DEFB  0xC5           ; 80 = END ('E'+0x80)
              DEFM  "ND"
              DEFB  0xC6           ; 81 = FOR ('F'+0x80)
              DEFM  "OR"
              DEFB  0xD2           ; 82 = RESET ('R'+0x80)
              DEFM  "ESET"
              DEFB  0xD3           ; 83 = SET ('S'+0x80)
              DEFM  "ET"
              DEFB  0xC3           ; 84 = CLS ('C'+0x80)
              DEFM  "LS"
KWD_85_CMD:
              DEFB  0x81           ; 85 = CMD (not coded)
              DEFB  0x00,0x00
KWD_86_RANDOM:
              DEFB  0x81           ; 86 = RANDOM (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00
KWD_87_NEXT:
              DEFB  0xCE           ; 87 = NEXT ('N'+0x80)
              DEFM  "EXT"
KWD_88_DATA:
              DEFB  0xC4           ; 88 = DATA ('D'+0x80)
              DEFM  "ATA"
KWD_89_INPUT:
              DEFB  0xC9           ; 89 = INPUT ('I'+0x80)
              DEFM  "NPUT"
KWD_8A_DIM:
              DEFB  0xC4           ; 8A = DIM ('D'+0x80)
              DEFM  "IM"
KWD_8B_READ:
              DEFB  0xD2           ; 8B = READ ('R'+0x80)
              DEFM  "EAD"
KWD_8C_LET:
              DEFB  0xCC           ; 8C = LET ('L'+0x80)
              DEFM  "ET"
KWD_8D_GOTO:
              DEFB  0xC7           ; 8D = GOTO ('G'+0x80)
              DEFM  "OTO"
KWD_8E_RUN:
              DEFB  0xD2           ; 8E = RUN ('R'+0x80)
              DEFM  "UN"
KWD_8F_IF:
              DEFB  0xC9           ; 8F = IF ('I'+0x80)
              DEFM  "F"
KWD_90_RESTORE:
              DEFB  0xD2           ; 90 = RESTORE ('R'+0x80)
              DEFM  "ESTORE"
KWD_91_GOSUB:
              DEFB  0xC7           ; 91 = GOSUB ('G'+0x80)
              DEFM  "OSUB"
KWD_92_RETURN:
              DEFB  0xD2           ; 92 = RETURN ('R'+0x80)
              DEFM  "ETURN"
KWD_93_REM:
              DEFB  0xD2           ; 93 = REM ('R'+0x80)
              DEFM  "EM"
KWD_94_STOP:
              DEFB  0xD3           ; 94 = STOP ('S'+0x80)
              DEFM  "TOP"
KWD_95_ELSE:
              DEFB  0xC5           ; 95 = ELSE ('E'+0x80)
              DEFM  "LSE"
KWD_96_COPY:
              DEFB  0xC3           ; 96 = COPY ('C'+0x80)
              DEFM  "OPY"
KWD_97_COLOR:
              DEFB  0xC3           ; 97 = COLOR ('C'+0x80)
              DEFM  "OLOR"
KWD_98_VERIFY:
              DEFB  0xD6           ; 98 = VERIFY ('V'+0x80)
              DEFM  "ERIFY"
KWD_99_DEFINT:
              DEFB  0x81           ; 99 = DEFINT (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00
KWD_9A_DEFSNG:
              DEFB  0x81           ; 9A = DEFSNG (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00
KWD_9B_DEFDBL:
              DEFB  0x81           ; 9B = DEFDBL (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00
KWD_9C_CRUN:
              DEFB  0xC3           ; 9C = CRUN ('C'+0x80)
              DEFM  "RUN"
KWD_9D_MODE:
              DEFB  0xCD           ; 9D = MODE ('M'+0x80)
              DEFM  "ODE"
KWD_9E_SOUND:
              DEFB  0xD3           ; 9E = SOUND ('S'+0x80)
              DEFM  "OUND"
KWD_9F_RESUME:
              DEFB  0x81           ; 9F = RESUME (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00
KWD_A0_OUT:
              DEFB  0xCF           ; A0 = OUT ('O'+0x80)
              DEFM  "UT"
KWD_A1_ON:
              DEFB  0x81           ; A1 = ON (not coded)
              DEFB  0x00
KWD_A2_OPEN:
              DEFB  0x81           ; A2 = OPEN (not coded)
              DEFB  0x00,0x00,0x00
KWD_A3_FIELD:
              DEFB  0x81           ; A3 = FIELD (not coded)
              DEFB  0x00,0x00,0x00,0x00
KWD_A4_GET:
              DEFB  0x81           ; A4 = GET (not coded)
              DEFB  0x00,0x00
KWD_A5_PUT:
              DEFB  0x81           ; A5 = PUT (not coded)
              DEFB  0x00,0x00
KWD_A6_CLOSE:
              DEFB  0x81           ; A6 = CLOSE (not coded)
              DEFB  0x00,0x00,0x00,0x00
KWD_A7_LOAD:
              DEFB  0x81           ; A7 = LOAD (not coded)
              DEFB  0x00,0x00,0x00
KWD_A8_MERGE:
              DEFB  0x81           ; A8 = MERGE (not coded)
              DEFB  0x00,0x00,0x00,0x00
KWD_A9_NAME:
              DEFB  0x81           ; A9 = NAME (not coded)
              DEFB  0x00,0x00,0x00
KWD_AA_KILL:
              DEFB  0x81           ; AA = KILL (not coded)
              DEFB  0x00,0x00,0x00
KWD_AB_LSET:
              DEFB  0x81           ; AB = LSET (not coded)
              DEFB  0x00,0x00,0x00
KWD_AC_RSET:
              DEFB  0x81           ; AC = RSET (not coded)
              DEFB  0x00,0x00,0x00
KWD_AD_SAVE:
              DEFB  0x81           ; AD = SAVE (not coded)
              DEFB  0x00,0x00,0x00
KWD_AE_SYSTEM:
              DEFB  0x81           ; AE = SYSTEM (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00
KWD_AF_LPRINT:
              DEFB  0xCC           ; AF = LPRINT ('L'+0x80)
              DEFM  "PRINT"
KWD_B0_DEF:
              DEFB  0x81           ; B0 = DEF (not coded)
              DEFB  0x00,0x00
KWD_B1_POKE:
              DEFB  0xD0           ; B1 = POKE ('P'+0x80)
              DEFM  "OKE"
KWD_B2_PRINT:
              DEFB  0xD0           ; B2 = PRINT ('P'+0x80)
              DEFM  "RINT"
KWD_B3_CONT:
              DEFB  0xC3           ; B3 = CONT ('C'+0x80)
              DEFM  "ONT"
KWD_B4_LIST:
              DEFB  0xCC           ; B4 = LIST ('L'+0x80)
              DEFM  "IST"
KWD_B5_LLIST:
              DEFB  0xCC           ; B5 = LLIST ('L'+0x80)
              DEFM  "LIST"
KWD_B6_DELETE:
              DEFB  0x81           ; B6 = DELETE (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00 ; not coded
KWD_B7_AUTO:
              DEFB  0x81           ; B7 = AUTO (not coded)
              DEFB  0x00,0x00,0x00 ; not coded
KWD_B8_CLEAR:
              DEFB  0xC3           ; B8 = CLEAR ('C'+0x80)
              DEFM  "LEAR"
KWD_B9_CLOAD:
              DEFB  0xC3           ; B9 = CLOAD ('C'+0x80)
              DEFM  "LOAD"
KWD_BA_CSAVE:
              DEFB  0xC3           ; BA = CSAVE ('C'+0x80)
              DEFM  "SAVE"
KWD_BB_NEW:
              DEFB  0xCE           ; BB = NEW ('N'+0x80)
              DEFM  "EW"
KWD_BC_TAB:
              DEFB  0xD4           ; BC = TAB( ('T'+0x80)
              DEFM  "AB("
KWD_BD_TO:
              DEFB  0xD4           ; BD = TO ('T'+0x80)
              DEFM  "O"
KWD_BE_FN:
              DEFB  0x81           ; BE = FN (not coded)
              DEFB  0x00           ; not coded
KWD_BF_USING:
              DEFB  0xD5           ; BF = USING ('U'+0x80)
              DEFM  "SING"
KWD_C0_VARPTR:
              DEFB  0x81           ; C0 = VARPTR (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00 ; not coded
KWD_C1_USR:
              DEFB  0xD5           ; C1 = USR ('U'+0x80)
              DEFM  "SR"
KWD_C2_ERL:
              DEFB  0x81           ; C2 = ERL (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_C3_ERR:
              DEFB  0x81           ; C3 = ERR (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_C4_STRINGS:
              DEFB  0x81           ; C4 = STRING$ (not coded)
              DEFB  0x00,0x00,0x00,0x00,0x00,0x00 ; not coded
KWD_C5_INSTR:
              DEFB  0x81           ; C5 = INSTR (not coded)
              DEFB  0x00,0x00,0x00,0x00 ; not coded
KWD_C6_POINT:
              DEFB  0xD0           ; C6 = POINT ('P'+0x80)
              DEFM  "OINT"
KWD_C7_TIMES:
              DEFB  0x81           ; C7 = TIME$ (not coded)
              DEFB  0x00,0x00,0x00,0x00 ; not coded
KWD_C8_MEM:
              DEFB  0x81           ; C8 = MEM (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_C9_INKEYS:
              DEFB  0xC9           ; C9 = INKEY$ ('I'+0x80)
              DEFM  "NKEY$"
KWD_CA_THEN:
              DEFB  0xD4           ; CA = THEN ('T'+0x80)
              DEFM  "HEN"
KWD_CB_NOT:
              DEFB  0xCE           ; CB = NOT ('N'+0x80)
              DEFM  "OT"
KWD_CC_STEP:
              DEFB  0xD3           ; CC = STEP ('S'+0x80)
              DEFM  "TEP"
KWD_CD_PLUS:
              DEFB  0xAB           ; CD = + ('+'+0x80)
KWD_CE_MINUS:
              DEFB  0xAD           ; CE = - ('-'+0x80)
KWD_CF_MUL:
              DEFB  0xAA           ; CF = * ('*'+0x80)
KWD_D0_DIV:
              DEFB  0xAF           ; D0 = / ('/'+0x80)
KWD_D1_UP:
              DEFB  0xDE           ; D1 = ^ (exponentiation) (0x5E+0x80)
KWD_D2_AND:
              DEFB  0xC1           ; D2 = AND ('A'+0x80)
              DEFM  "ND"
KWD_D3_OR:
              DEFB  0xCF           ; D3 = OR ('O'+0x80)
              DEFM  "R"
KWD_D4_GT:
              DEFB  0xBE           ; D4 = > ('>'+0x80)
KWD_D5_EQ:
              DEFB  0xBD           ; D5 = = ('='+0x80)
KWD_D6_LT:
              DEFB  0xBC           ; D6 = < ('<'+0x80)
KWD_D7_SGN:
              DEFB  0xD3           ; D7 = SGN ('S'+0x80)
              DEFM  "GN"
KWD_D8_INT:
              DEFB  0xC9           ; D8 = INT ('I'+0x80)
              DEFM  "NT"
KWD_D9_ABS:
              DEFB  0xC1           ; D9 = ABS ('A'+0x80)
              DEFM  "BS"
KWD_DA_FRE:
              DEFB  0x81           ; DA = FRE (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_DB_INP:
              DEFB  0xC9           ; DB = INP ('I'+0x80)
              DEFM  "NP"
KWD_DC_POS:
              DEFB  0x81           ; DC = POS (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_DD_SQR:
              DEFB  0xD3           ; DD = SQR ('S'+0x80)
              DEFM  "QR"
KWD_DE_RND:
              DEFB  0xD2           ; DE = RND ('R'+0x80)
              DEFM  "ND"
KWD_DF_LOG:
              DEFB  0xCC           ; DF = LOG ('L'+0x80)
              DEFM  "OG"
KWD_E0_EXP:
              DEFB  0xC5           ; E0 = EXP ('E'+0x80)
              DEFM  "XP"
KWD_E1_COS:
              DEFB  0xC3           ; E1 = COS ('C'+0x80)
              DEFM  "OS"
KWD_E2_SIN:
              DEFB  0xD3           ; E2 = SIN ('S'+0x80)
              DEFM  "IN"
KWD_E3_TAN:
              DEFB  0xD4           ; E3 = TAN ('T'+0x80)
              DEFM  "AN"
KWD_E4_ATN:
              DEFB  0xC1           ; E4 = ATN ('A'+0x80)
              DEFM  "TN"
KWD_E5_PEEK:
              DEFB  0xD0           ; E5 = PEEK ('P'+0x80)
              DEFM  "EEK"
KWD_E6_CVI:
              DEFB  0x81           ; E6 = CVI (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_E7_CVS:
              DEFB  0x81           ; E7 = CVS (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_E8_CVD:
              DEFB  0x81           ; E8 = CVD (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_E9_EOF:
              DEFB  0x81           ; E9 = EOF (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_EA_LOC:
              DEFB  0x81           ; EA = LOC (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_EB_LOF:
              DEFB  0x81           ; EB = LOF (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_EC_MKIS:
              DEFB  0x81           ; EC = MKI$ (not coded)
              DEFB  0x00,0x00,0x00 ; not coded
KWD_ED_MKSS:
              DEFB  0x81           ; ED = MKS$ (not coded)
              DEFB  0x00,0x00,0x00 ; not coded
KWD_EE_MKDS:
              DEFB  0x81           ; EE = MKD$ (not coded)
              DEFB  0x00,0x00,0x00 ; not coded
KWD_EF_CINT:
              DEFB  0x81           ; EF = CINT (not coded)
              DEFB  0x00,0x00,0x00 ; not coded
KWD_F0_CSNG:
              DEFB  0x81           ; F0 = CSNG (not coded)
              DEFB  0x00,0x00,0x00 ; not coded
KWD_F1_CDBL:
              DEFB  0x81           ; F1 = CDBL (not coded)
              DEFB  0x00,0x00,0x00 ; not coded
KWD_F2_FIX:
              DEFB  0x81           ; F2 = FIX (not coded)
              DEFB  0x00,0x00      ; not coded
KWD_F3_LEN:
              DEFB  0xCC           ; F3 = LEN ('L'+0x80)
              DEFM  "EN"
KWD_F4_STRS:
              DEFB  0xD3           ; F4 = STR$ ('S'+0x80)
              DEFM  "TR$"
KWD_F5_VAL:
              DEFB  0xD6           ; F5 = VAL ('V'+0x80)
              DEFM  "AL"
KWD_F6_ASC:
              DEFB  0xC1           ; F6 = ASC ('A'+0x80)
              DEFM  "SC"
KWD_F7_CHRS:
              DEFB  0xC3           ; F7 = CHR$ ('C'+0x80)
              DEFM  "HR$"
KWD_F8_LEFTS:
              DEFB  0xCC           ; F8 = LEFT$ ('L'+0x80)
              DEFM  "EFT$"
KWD_F9_RIGHTS:
              DEFB  0xD2           ; F9 = RIGHT$ ('R'+0x80)
              DEFM  "IGHT$"
KWD_FA_MIDS:
              DEFB  0xCD           ; FA = MID$ ('M'+0x80)
              DEFM  "ID$"
KWD_FB_SPACE:
              DEFB  0xA7           ; FB = ' ('\''+0x80)
KWD_END_TABLE:
              DEFB  0x80           ; End of table

; (Token 80 - BB)
              DEFW  0x1DAE         ; 80 = END
              DEFW  0x1CA1         ; 81 = FOR
              DEFW  0x0138         ; 82 = RESET
              DEFW  0x0135         ; 83 = SET
              DEFW  0x01C9         ; 84 = CLS
              DEFW  0x7973         ; 85 = CMD
              DEFW  0x01D3         ; 86 = RANDOM
              DEFW  0x22B6         ; 87 = NEXT
              DEFW  0x1F05         ; 88 = DATA
              DEFW  0x219A         ; 89 = INPUT
              DEFW  0x2608         ; 8A = DIM
              DEFW  0x21EF         ; 8B = READ
              DEFW  0x1F21         ; 8C = LET
              DEFW  0x1EC2         ; 8D = GOTO
              DEFW  0x1EA3         ; 8E = RUN
              DEFW  0x2039         ; 8F = IF
              DEFW  0x1D91         ; 90 = RESTORE
              DEFW  0x1EB1         ; 91 = GOSUB
              DEFW  0x1EDE         ; 92 = RETURN
              DEFW  0x1F07         ; 93 = REM
              DEFW  0x1DA9         ; 94 = STOP
              DEFW  0x1F07         ; 95 = ELSE
              DEFW  0x3912         ; 96 = COPY
              DEFW  0x389D         ; 97 = COLOR
              DEFW  0x3738         ; 98 = VERIFY
              DEFW  0x1E03         ; 99 = DEFINT
              DEFW  0x1E06         ; 9A = DEFSNG
              DEFW  0x1E09         ; 9B = DEFDBL
              DEFW  0x372E         ; 9C = CRUN
              DEFW  0x2E63         ; 9D = MODE
              DEFW  0x2BF5         ; 9E = SOUND
              DEFW  0x1FAF         ; 9F = RESUME
              DEFW  0x2AFB         ; A0 = OUT
              DEFW  0x1F6C         ; A1 = ON
              DEFW  0x7979         ; A2 = OPEN
              DEFW  0x797C         ; A3 = FIELD
              DEFW  0x797F         ; A4 = GET
              DEFW  0x7982         ; A5 = PUT
              DEFW  0x7985         ; A6 = CLOSE
              DEFW  0x7988         ; A7 = LOAD
              DEFW  0x798B         ; A8 = MERGE
              DEFW  0x798E         ; A9 = NAME
              DEFW  0x7991         ; AA = KILL
              DEFW  0x7997         ; AB = LSET
              DEFW  0x799A         ; AC = RSET
              DEFW  0x79A0         ; AD = SAVE
              DEFW  0x0000         ; AE = SYSTEM
              DEFW  0x2067         ; AF = LPRINT
              DEFW  0x795B         ; B0 = DEF
              DEFW  0x2CB1         ; B1 = POKE
              DEFW  0x206F         ; B2 = PRINT
              DEFW  0x1DE4         ; B3 = CONT
              DEFW  0x2B2E         ; B4 = LIST
              DEFW  0x2B29         ; B5 = LLIST
              DEFW  0x2BC6         ; B6 = DELETE
              DEFW  0x2008         ; B7 = AUTO
              DEFW  0x1E7A         ; B8 = CLEAR
              DEFW  0x3656         ; B9 = CLOAD
              DEFW  0x34A9         ; BA = CSAVE
              DEFW  0x1B49         ; BB = NEW

; The operator with the higher code has priority
              DEFB  0x79           ; OP_PRI_PLUS
              DEFB  0x79           ; OP_PRI_MINUS
              DEFB  0x7C           ; OP_PRI_MUL
              DEFB  0x7C           ; OP_PRI_DIV
              DEFB  0x7F           ; OP_PRI_POW
              DEFB  0x50           ; OP_PRI_AND
              DEFB  0x46           ; OP_PRI_OR

; Jump table for type adaptation
              DEFW  0x0ADB         ; Conversion to double precision
              DEFW  0x0000         ; unused
              DEFW  0x0A7F         ; Conversion to integer
              DEFW  0x0AF4         ; TYPE MISMATCH - Error if not!
              DEFW  0x0AB1         ; Conversion to single precision

; Double Precision
              DEFW  0x0C77         ; Addition
              DEFW  0x0C70         ; Subtraction
              DEFW  0x0DA1         ; Multiplication
              DEFW  0x0DE5         ; Division
              DEFW  0x0A78         ; Power

; Single Precision
              DEFW  0x0716         ; Addition
              DEFW  0x0713         ; Subtraction
              DEFW  0x0847         ; Multiplication
              DEFW  0x08A2         ; Division
              DEFW  0x0A0C         ; Power

; Integer
              DEFW  0x0BD2         ; Addition
              DEFW  0x0BC7         ; Subtraction
              DEFW  0x0BF2         ; Multiplication
              DEFW  0x2490         ; Division
              DEFW  0x0A39         ; Power

; (not used in LASER 110-310)
              DEFB  0x4E,0x46      ; ERR_NF
              DEFB  0x53,0x4E      ; ERR_SN
              DEFB  0x52,0x47      ; ERR_RG
              DEFB  0x4F,0x44      ; ERR_OD
              DEFB  0x46,0x43      ; ERR_FC
              DEFB  0x4F,0x56      ; ERR_OV
              DEFB  0x4F,0x4D      ; ERR_OM
              DEFB  0x55,0x4C      ; ERR_UL
              DEFB  0x42,0x53      ; ERR_BS
              DEFB  0x44,0x44      ; ERR_DD
              DEFB  0x2F,0x30      ; ERR_D0
              DEFB  0x49,0x44      ; ERR_ID
              DEFB  0x54,0x4D      ; ERR_TM
              DEFB  0x4F,0x53      ; ERR_OS
              DEFB  0x4C,0x53      ; ERR_LS
              DEFB  0x53,0x54      ; ERR_ST
              DEFB  0x43,0x4E      ; ERR_CN
              DEFB  0x4E,0x52      ; ERR_NR
              DEFB  0x52,0x57      ; ERR_RW
              DEFB  0x55,0x45      ; ERR_UE
              DEFB  0x4D,0x4F      ; ERR_MO
              DEFB  0x46,0x44      ; ERR_FD
              DEFB  0x4C,0x33      ; ERR_L3

; Data and subroutines that are transferred to RAM during BASIC initialization.
FDIV_HELPER_ROM:
              sub   0x00           ; Subtraction Z2 - Z1
              ld    l,a            ; modified before each call
              ld    a,h
              sbc   a,0x00
              ld    h,a
              ld    a,b
              sbc   a,0x00
              ld    b,a
              ld    a,0x00
              ret   
USR_START_VEC_ROM:
              DEFW  0x1E4A         ; USR start address, pre-initialized with FUNCTION CODE -Error
RND_MULT_ROM:
              DEFB  0x40,0xE6,0x4D ; Multiplier for RND
INP_HELPER_ROM:
              in    a,(0x00)       ; Subroutine for INP: Load input port into A
              ret   
OUT_HELPER_ROM:
              out   (0x00),a       ; Subroutine for OUT: Output A register over port
              ret   
INKEY_BUF_ROM:
              DEFB  0x00           ; INKEY$ temporary storage
LAST_ERR_ROM:
              DEFB  0x00           ; last error code for ERR
PRN_POS_ROM:
              DEFB  0x00           ; Print head position
OUT_FLAG_ROM:
              DEFB  0x00           ; Output flag
LINE_LEN_ROM:
              DEFB  0x40           ; Line length on screen
TAB_POS_ROM:
              DEFB  0x30           ; last tab position on screen
UNUSED_1916:
              DEFB  0x00           ; unused
STR_SPACE_ROM:
              DEFW  0x7B4C         ; Start of string space
CURR_LINE_ROM:
              DEFW  0xFFFE         ; Current line number
PROG_START_ROM:
              DEFW  0x7AE9         ; Program text start

; Texts
MSG_ERROR_TEXT:
              DEFM  " ERROR\00"
MSG_IN_TEXT:
              DEFB  0x20,0x49,0x4E,0x20,0x00
MSG_READY_TEXT:
              DEFB  0x52,0x45,0x41,0x44,0x59,0x0D,0x00
MSG_BREAK_TEXT:
              DEFB  0x42,0x52,0x45,0x41,0x4B,0x00

; Subroutine for FOR/NEXT and GOSUB/RETURN
; retrieves data back from the stack
STACK_RECOVERY:
              ld    hl,0x0004      ; Stack pointer + 4 into HL
              add   hl,sp          ; (bypass 2 return addresses)
              ld    a,(hl)         ; Load flag
              inc   hl
              cp    0x81           ; Data from FOR loop?
              ret   nz             ; no, finished
              ld    c,(hl)         ; yes, load loop variable address
              inc   hl
              ld    b,(hl)
              inc   hl
              push  hl             ; on stack
              ld    l,c            ; loop variable in HL
              ld    h,b
              ld    a,d
              or    e              ; loop variable specified?
              ex    de,hl          ; no, return with address in DE
              jr    z,$+4
              ex    de,hl
              rst   0x18           ; yes, = found loop variable?
              ld    bc,0x000E      ; 14 in BC
              pop   hl             ; Reload address pointer
              ret   z              ; yes, finished
              add   hl,bc          ; Pointer to next stack data
              jr    $-25           ; same once more

; Make space for program line to be inserted
; or free up variable
MAKE_SPACE:
              call  0x196C         ; is HL still in free memory?
              push  bc             ; no, OUT OF MEMORY - Error
              ex    (sp),hl        ; Swap HL and BC
              pop   bc
              rst   0x18           ; Start of source block reached?
              ld    a,(hl)         ; Relocate 1 byte
              ld    (bc),a
              ret   z              ; yes, finished!
              dec   bc             ; Address pointer - 1
              dec   hl
              jr    $-6            ; next byte

; Test if 2*C bytes are free
; if not, OUT OF MEMORY - Error
CHECK_FREE_MEMORY:
              push  hl             ; HL onto stack
              ld    hl,(0x78FD)    ; Starting address of free memory
              ld    b,0x00         ; B=0
              add   hl,bc          ; Add BC to HL twice
              add   hl,bc
              ld    a,0xE5         ; LD A,0E5H Dummy instruction
              ld    a,0xC6         ; HL > FFC6H ?
              sub   l
              ld    l,a
              ld    a,0xFF
              sbc   a,h
              jr    c,$+6          ; yes, OUT OF MEMORY - Error
              ld    h,a
              add   hl,sp          ; HL + 4A >= SP ?
              pop   hl             ; Restore HL
              ret   c              ; no, return

; Preparation and output of error messages
ERROR_ENTRY:
              ld    e,0x0C         ; Error code in E
              jr    $+38           ; to message output
IMPLICIT_END:
              ld    hl,(0x78A2)    ; Load line number
              ld    a,h            ; in direct mode? (=FFFF)
              and   l
              inc   a
              jr    z,$+10         ; no, jump to END
              ld    a,(0x78F2)     ; Trap flag set?
              or    a
              ld    e,0x22         ; NO RESUME - Load error code
              jr    nz,$+22        ; yes, to message output
              jp    0x1DC1         ; Jump to END
SYNTAX_ERR_DATA:
              ld    hl,(DATA_LINE_NUM) ; last DATA line
              ld    (0x78A2),hl    ; as current line number
SYNTAX_ERR_HANDLER:
              ld    e,0x02         ; Error code in E
              DEFB  0x01           ; LD BC,141EH Dummy instruction
DIV_ZERO_ERR_HANDLER:
              ld    e,0x14         ; DIVISION BY ZERO
              DEFB  0x01           ; LD BC,001EH Dummy instruction
; NEXT_WITHOUT_FOR_ERR_HANDLER: (defined in symbols.sym)
              ld    e,0x00         ; NEXT WITHOUT FOR
              DEFB  0x01           ; LD BC,241EH Dummy instruction
RESUME_WITHOUT_ERR_HANDLER:
              ld    e,0x24         ; RESUME WITHOUT ERROR
ERROR_HANDLER:
              ld    hl,(0x78A2)    ; Load current line number
              ld    (0x78EA),hl    ; store as error line
              ld    (0x78EC),hl    ; store as error line
              ld    bc,0x19B4      ; Load resume address
              ld    hl,(0x78E8)    ; Load current program pointer
              jp    0x1B9A         ; Jump to NEW, initialize stack
              pop   bc             ; Fix stack
              ld    a,e            ; Error code in A and C
              ld    c,e
              ld    (0x789A),a     ; store
              ld    hl,(0x78E6)    ; Load program pointer
              ld    (0x78EE),hl    ; store as error pointer
              ex    de,hl          ; and into DE
              ld    hl,(0x78EA)    ; Line number = FFFF ?
              ld    a,h            ; (= Direct mode)
              and   l
              inc   a
              jr    z,$+9          ; yes, no interruption parameters
              ld    (0x78F5),hl    ; store error line number for CONT
              ex    de,hl          ; and in DE
              ld    (0x78F7),hl    ; store as CONT pointer
              ld    hl,(0x78F0)    ; Address of an error routine (ON ERROR)
              ld    a,h            ; 0?
              or    l
              ex    de,hl          ; into DE
              ld    hl,0x78F2      ; Load trap flag address
              jr    z,$+10         ; no error routine (TRAP)
              and   (hl)           ; still open error trap
              jr    nz,$+7         ; yes, do not perform error handling
              dec   (hl)           ; Set trap flag
              ex    de,hl          ; Address of error routine in HL
              jp    0x1D36         ; Continue program there
              xor   a              ; Clear trap flag
              ld    (hl),a         ; store
              ld    e,c            ; Error code back in E
              call  PRINT_BOL_CHECK ; if required, output CR
              ld    hl,0x3CEC      ; Address of error messages
              call  0x79A6         ; RAM expansion output
              ld    d,a            ; D = 0
              ld    a,0x3F         ; output '?'
              call  CHAR_OUTPUT_DISPATCH ; output error message
              call  0x3CD4         ; output error message
              nop                  ; 6 x NOP
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    hl,MSG_ERROR_TEXT ; Address 'ERROR' text
              push  hl             ; and onto stack
              ld    hl,(0x78EA)    ; Load error line number
              ex    (sp),hl        ; swap with text address on stack
              call  OUTSTR         ; output 'ERROR'
              pop   hl             ; error line number from stack
              ld    de,0xFFFE      ; = 65535? (FFFF)
              rst   0x18
              jp    z,BASIC_INIT_1 ; yes, new system initialization
              ld    a,h            ; = 65535? (FFFF)
              and   l              ; (= direct mode)
              inc   a
              call  nz,INPRT       ; no, output 'IN Line'
              DEFB  0x3E           ; LD A,0C1H dummy instruction

; BASIC - Main Loop
; Jump entry at either 1A18 or 1A19
              pop   bc             ; Correct stack
              call  OUTPUT_SCREEN_SELECT ; Output flag to screen, CR to printer if necessary
              call  0x79AC         ; RAM expansion output
              nop   
              nop   
              nop   
              call  PRINT_BOL_CHECK ; CR on screen, if necessary
              ld    hl,MSG_READY_TEXT ; Address 'READY' text
              call  OUTSTR         ; and output
              ld    a,(0x789A)     ; no significance
              sub   0x02           ; no significance
              nop   
              nop   
              nop   
              ld    hl,0xFFFF      ; Set current line number to FFFF
              ld    (0x78A2),hl
              ld    a,(0x78E1)     ; AUTO function enabled?
              or    a
              jr    z,$+60         ; no, normal input

; Program input under AUTO function
              ld    hl,(0x78E2)    ; load next AUTO line number
              push  hl             ; and onto stack
              call  LINPRT         ; output line number
              ld    a,0x20         ; then a space
              call  CHAR_OUTPUT_DISPATCH ; and output
              pop   de             ; line number in DE
              push  de             ; and back on stack
              call  FNDLIN         ; search for line in program text
              call  c,0x2E53       ; exists! output line
              nop   
              call  RDLINE         ; read line from keyboard
              pop   de             ; load AUTO line number
              jr    nc,$+8         ; no BREAK, continue normally
              xor   a              ; clear AUTO flag
              ld    (0x78E1),a
              jr    $-69           ; back to main loop
              ld    hl,(0x78E4)    ; load AUTO increment
              add   hl,de          ; add to AUTO line number
              jr    c,$-10         ; overflow, leave AUTO mode
              push  de             ; AUTO line number on stack
              ld    de,0xFFF9      ; new AUTO line number > 65528?
              rst   0x18           ; Compare HL/DE
              pop   de             ; load AUTO line number again
              jr    nc,$-18        ; > 65528! leave AUTO mode
              ld    (0x78E2),hl    ; remember new AUTO line number
              DEFB  0x00,0x00
              ld    hl,0x79E7      ; address I/O buffer - 1
              jp    0x1A81         ; analyze line and accept

; Normal program input without AUTO
              DEFB  0x00,0x00
              call  RDLINE         ; read line from keyboard
              jp    c,MAIN_LOOP_READY ; BREAK! to main loop start
              rst   0x10           ; search for first character <> ' '
              inc   a              ; line end (00)?
              dec   a
              jp    z,MAIN_LOOP_READY ; yes, to main loop start
              push  af             ; save flag (Cy=1 if digit)
              call  DECZ           ; decode line number
              dec   hl             ; buffer address back (after line number)
              ld    a,(hl)         ; load character
              cp    0x20           ; = space?
              jr    z,$-4          ; yes, further back
              inc   hl             ; buffer pointer to first char after line number
              ld    a,(hl)         ; load character
              cp    0x20           ; = space?
              call  z,INXHRT       ; yes, skip first space
              push  de             ; line number on stack
              call  STOKEN         ; generate intermediate code
              pop   de
              pop   af
              ld    (0x78E6),hl    ; save current program pointer
              call  0x79B2         ; RAM expansion output
              jp    nc,EXEC        ; execute direct command
              push  de             ; line number on stack
              push  bc             ; line length on stack
              xor   a              ; clear RESUME/RETURN flag
              ld    (0x78DD),a     ; clear flag
              rst   0x10           ; line empty?
              or    a              ; yes, zero flag = 1
              push  af             ; save flag on stack
              ex    de,hl          ; nostalgia from TRS-80 editor
              ld    (0x78EC),hl    ; save line address in HL
              ex    de,hl
              call  FNDLIN         ; search for line in program text
              push  bc             ; save address pointer on stack
              call  c,DELLIN       ; if found, delete
              pop   de             ; line address in DE
              pop   af             ; load flags again
              push  de             ; line address back on stack
              jr    z,$+41         ; at empty line back to start
              pop   de             ; load line address again
              ld    hl,(0x78F9)    ; load program end address
              ex    (sp),hl        ; swap with line length on stack
              pop   bc             ; program end address in BC
              add   hl,bc          ; end address + line length
              push  hl             ; = new end address, save on stack
              call  MAKE_SPACE     ; make space for new line
              pop   hl             ; load new program address
              ld    (0x78F9),hl    ; and save
              ex    de,hl          ; line address in HL
              ld    (hl),h         ; enter any line pointer
              pop   de             ; load line number again
              push  hl             ; line address on stack
              inc   hl             ; line pointer on line number field
              inc   hl
              ld    (hl),e         ; enter line number into line
              inc   hl
              ld    (hl),d
              inc   hl             ; line pointer to first text byte
              ex    de,hl
              ld    hl,(0x78A7)    ; I/O buffer start address
              ex    de,hl          ; in DE
              dec   de             ; - 2 = start of intermediate code
              dec   de
              ld    a,(de)         ; transfer intermediate code to program text
              ld    (hl),a         ; transfer
              inc   hl             ; address pointer + 1
              inc   de
              or    a              ; line end? (00)
              jr    nz,$-5         ; no, transfer next byte
              pop   de             ; load line start address
              call  RENEW_LINE_PTRS ; from line address, renew line pointer
              call  0x79B5         ; RAM expansion output
              call  VRESET         ; Clear variable table and other program data
              call  0x79B8         ; RAM expansion output
              jp    MAIN_LOOP_READY ; to main loop start

; Renew line pointers in entire program text
              ld    hl,(0x78A4)    ; program text start in DE
              ex    de,hl

; Renew line pointers partially
              ld    h,d            ; line start address in HL
              ld    l,e
              ld    a,(hl)         ; line pointer = 0?
              inc   hl             ; (program end?)
              or    (hl)
              ret   z              ; yes, done
              inc   hl             ; Skip pointer and line number
              inc   hl
              inc   hl
              xor   a
              cp    (hl)
              inc   hl
              jr    nz,$-2         ; no line end, back
              ex    de,hl          ; line start address in HL
              ld    (hl),e         ; Address of next line as line pointer
              inc   hl             ; store it
              ld    (hl),d
              jr    $-18           ; next line

; Analyze arguments for LIST command
              ld    de,START       ; set 1st line number = 0
              push  de             ; and on stack
              jr    z,$+11         ; no arguments, continue
              pop   de             ; remove 0 from stack
              call  VAL            ; decode 1st line number
              push  de             ; and pack on stack
              jr    z,$+13         ; no more characters! set 2nd line number = 1st
              rst   8              ; follows a '-' ?
              DEFB  0xCE           ; Token for '-'
              ld    de,0xFFFA      ; set 2nd line number = 65530
              call  nz,VAL         ; more characters? yes, decode 2nd line number
              jp    nz,SYNTAX_ERR_HANDLER ; even more characters? yes, SYNTAX ERROR
              ex    de,hl          ; 2nd line number in HL
              pop   de             ; 1st line number in DE
              ex    (sp),hl        ; 2nd line number on stack with swap return address.
              push  hl             ; return address back on stack

; Search for line in program text
              ld    hl,(0x78A4)    ; load program start address
              ld    b,h            ; line address in BC
              ld    c,l
              ld    a,(hl)         ; program end ?
              inc   hl             ; (line pointer = 0000)
              or    (hl)
              dec   hl
              ret   z              ; yes, done!
              inc   hl             ; program pointer to line number
              inc   hl
              ld    a,(hl)         ; load line number into HL
              inc   hl
              ld    h,(hl)
              ld    l,a
              rst   0x18           ; Compare HL/DE = searched line ?
              ld    h,b            ; load line start address
              ld    l,c
              ld    a,(hl)         ; load line pointer
              inc   hl
              ld    h,(hl)
              ld    l,a
              ccf                  ; invert carry flag
              ret   z              ; searched line? yes-done
              ccf                  ; carry flag back again
              ret   nc             ; line number > searched line
              jr    $-24           ; examine next line

; NEW command
; Reset all variables and pointers
; (the string area definition is preserved)
              ret   nz             ; Parameter? yes-SYNTAX ERROR
              call  CLRSCR         ; clear screen
              ld    hl,(0x78A4)    ; program text start in HL
              call  TROFF          ; call TROFF
              ld    (0x78E1),a     ; delete AUTO mode
              ld    (hl),a         ; line pointer = 0000 at program text start (delete program)
              inc   hl
              ld    (hl),a
              inc   hl             ; pointer behind 0000
              ld    (0x78F9),hl    ; save as program end address
              ld    hl,(0x78A4)    ; load program start address
              dec   hl             ; - 1
              ld    (0x78DF),hl    ; as pointer for program continuation
              ld    b,0x1A         ; counter = 26
              ld    hl,0x7901      ; table start address
              ld    (hl),0x04      ; enter code for single precision
              inc   hl             ; next byte
              djnz  $-3            ; counter - 1. done ?
              xor   a              ; yes, clear TRAP flag
              ld    (0x78F2),a
              ld    l,a            ; HL = 0
              ld    h,a
              ld    (0x78F0),hl    ; address of an error routine = 0
              ld    (0x78F7),hl    ; CONT address pointer = 0
              ld    hl,(0x78B1)    ; load BASIC-RAM end address
              ld    (0x78D6),hl    ; store as string area pointer; deletes all string variables
              call  RESTORE        ; call RESTORE
              ld    hl,(0x78F9)    ; load program end address
              ld    (0x78FB),hl    ; = end address of variable table
              ld    (0x78FD),hl    ; = end address of matrix table
              call  0x79BB         ; RAM expansion output
              pop   bc             ; load return address
              ld    hl,(0x78A0)    ; address of string area
              dec   hl             ; - 2
              dec   hl
              ld    (0x78E8),hl    ; store as stack start address
              inc   hl             ; + 2
              inc   hl
              ld    sp,hl          ; transfer to stack pointer
              ld    hl,0x78B5      ; clear string buffer
              ld    (0x78B3),hl    ; (start address in pointer)
              call  OUTPUT_SCREEN_SELECT ; output flag to screen, CR on printer if necessary.
              call  PRINT_FINAL    ; end check
              xor   a              ; A = 0
              ld    h,a            ; HL = 0
              ld    l,a
              ld    (0x78DC),a     ; release indexing lock
              push  hl             ; 0 on stack as end identifier
              push  bc             ; return addr. back on stack
              ld    hl,(0x78DF)    ; pointer for program continuation
              ret   

; Output question mark and read a line
              ld    a,0x3F         ; output question mark
              call  CHAR_OUTPUT_DISPATCH
              ld    a,0x20         ; output space
              call  CHAR_OUTPUT_DISPATCH
              jp    0x053A         ; read a line

; Analyze line and generate intermediate code (tokenize)
              xor   a              ; clear DATA flag
              ld    (0x78B0),a
              ld    c,a            ; character counter = 0
              ex    de,hl
              ld    hl,(0x78A7)    ; address of I/O buffer
              dec   hl             ; - 2
              dec   hl
              ex    de,hl          ; in DE
              ld    a,(hl)         ; load character from text line
              cp    0x20           ; = space ?
              jp    z,0x1C5B       ; yes! transfer directly
              ld    b,a            ; character in B (as separator)
              cp    0x22           ; = double quote ?
              jp    z,0x1C77       ; yes! transfer string
              or    a              ; line end ?
              jp    z,0x1C7D       ; yes! done
              ld    a,(0x78B0)     ; load DATA flag
              or    a              ; set ?
              ld    a,(hl)         ; load character
              jp    nz,0x1C5B      ; yes! transfer directly
              cp    0x3F           ; = question mark ?
              ld    a,0xB2         ; load PRINT token
              jp    z,0x1C5B       ; yes! transfer to intermediate code
              ld    a,(hl)         ; load character again
              cp    0x30           ; character < '0' ?
              jr    c,$+7          ; yes, check for keywords
              cp    0x3C           ; character < '<' ?
              jp    c,0x1C5B       ; yes, accept directly

; Check text for valid BASIC keyword
              push  de             ; intermediate code pointer on stack
              ld    de,0x164F      ; start address of keywords
              push  bc             ; character counter on stack
              ld    bc,NOTRES      ; set return address
              push  bc
              ld    b,0x7F         ; set token counter = 7F
              ld    a,(hl)         ; load character from text
              cp    0x61           ; lowercase?
              jr    c,$+9          ; no!
              cp    0x7B
              jr    nc,$+5         ; no!
              and   0x5F           ; convert to uppercase
              ld    (hl),a         ; write character back to text
              ld    c,(hl)         ; load 1st character
              ex    de,hl          ; keyword pointer in HL
              inc   hl             ; search for next keyword
              or    (hl)           ; start of a keyword?
              jp    p,0x1C0E       ; no, continue
              inc   b              ; token counter + 1
              ld    a,(hl)         ; 1st character of keyword
              and   0x7F           ; clear bit 7
              ret   z              ; end of keyword table
              cp    c              ; = text character ?
              jr    nz,$-11        ; no, next keyword
              ex    de,hl          ; swap address pointers
              push  hl             ; buffer pointer on stack
              inc   de             ; keyword pointer + 1
              ld    a,(de)         ; next char of keyword
              or    a              ; new keyword ?
              jp    m,0x1C39       ; yes, keyword recognized
              ld    c,a            ; character in C
              ld    a,b            ; Token = GOTO?
              cp    0x8D
              jr    nz,$+4         ; no, continue
              rst   0x10           ; yes, space allowed
              dec   hl             ; buffer pointer back one char
              inc   hl             ; buffer pointer to next character
              ld    a,(hl)         ; load character
              cp    0x61           ; lowercase ?
              jr    c,$+4          ; no!
              and   0x5F           ; convert to uppercase
              cp    c              ; = letter from keyword ?
              jr    z,$-23         ; yes, continue
              pop   hl             ; no, buffer pointer back again
              jr    $-43           ; try next keyword
              ld    c,b            ; Token determined. Token in C
              pop   af             ; clear stack
              ex    de,hl          ; swap address pointers
              ret   

; Token or text to intermediate code
              ex    de,hl          ; HL = buffer pointer
              ld    a,c            ; character or token in A
              pop   bc             ; load character counter
              pop   de             ; load intermediate code pointer
              ex    de,hl          ; swap address pointers
              cp    0x95           ; = ELSE token ?
              ld    (hl),0x3A      ; ':' to intermediate code
              jr    nz,$+4         ; no, ignore ':'
              inc   c              ; yes, character counter + 1
              inc   hl             ; intermediate code pointer after ':'
              cp    0xFB           ; = '\
              jr    nz,$+14        ; no!
              ld    (hl),0x3A      ; yes, ':' to intermediate code
              inc   hl             ; intermediate code pointer + 1
              ld    b,0x93         ; REM token to intermediate code
              ld    (hl),b
              inc   hl             ; intermediate code pointer + 1
              ex    de,hl          ; swap address pointers
              inc   c              ; character counter + 2
              inc   c
              jr    $+31           ; transfer remaining text from buffer unchanged to intermediate c
              ex    de,hl          ; swap address pointers
              inc   hl             ; buffer pointer + 1
              ld    (de),a         ; token or character to intermediate code
              inc   de             ; intermediate code pointer + 1
              inc   c              ; character counter + 1
              sub   0x3A           ; = ':' ?
              jr    z,$+6          ; yes, clear DATA flag
              cp    0x4E           ; DATA token ? (88 - 3A)
              jr    nz,$+5         ; no!
              ld    (0x78B0),a     ; yes, set DATA flag
              sub   0x59           ; REM token ? (93 - 3A)
              jp    nz,0x1BCC      ; no, back
              ld    b,a            ; 0 as separator in B
              ld    a,(hl)         ; text until separator or line end unchanged in intermediate code
              or    a              ; line end ?
              jr    z,$+11         ; yes, done
              cp    b              ; separator ? (with ' = \
              jr    z,$-26         ; yes, back
              inc   hl             ; buffer pointer + 1
              ld    (de),a         ; character to intermediate code
              inc   c              ; character counter + 1
              inc   de             ; intermediate code pointer + 1
              jr    $-11           ; next character
              ld    hl,0x0005      ; HL = 5
              ld    b,h            ; B = 0
              add   hl,bc          ; character counter + 5
              ld    b,h            ; in BC
              ld    c,l
              ld    hl,(0x78A7)    ; start address of I/O buffer - 3
              dec   hl
              dec   hl             ; pointer to byte before intermediate code
              dec   hl
              ld    (de),a         ; mark intermediate code end with 3 zeros
              inc   de
              ld    (de),a         ; (end identifier for direct commands)
              inc   de
              ld    (de),a
              ret                  ; that's it

; Restart 18
; Compare HL and DE
              ld    a,h            ; MSB HL = MSB DE ?
              sub   d
              ret   nz             ; no, done
              ld    a,l            ; LSB HL = LSB DE ?
              sub   e
              ret   

; Restart 8
; Syntax check
              ld    a,(hl)         ; load character from pointer position
              ex    (sp),hl        ; swap pointer with return address
              cp    (hl)           ; = the character following the call ?
              inc   hl             ; return address + 1
              ex    (sp),hl        ; swap with pointer again
              jp    z,CHRGTR       ; equal, continue with RST 10
              jp    SYNTAX_ERR_HANDLER ; not equal, SYNTAX ERROR

; FOR statement
              ld    a,0x64         ; lock indexing
              ld    (0x78DC),a
              call  CMD_LET        ; starting value in loop variable
              ex    (sp),hl        ; program pointer on stack
              call  STACK_RECOVERY ; loop with same loop variable already on stack ?
              pop   de             ; program pointer in DE
              jr    nz,$+7         ; no!
              add   hl,bc          ; yes, delete all loops up to that point by stack correction
              ld    sp,hl          ; set stack pointer new
              ld    (0x78E8),hl    ; and save new starting value
              ex    de,hl          ; program pointer in HL
              ld    c,0x08         ; at least 16 bytes free ?
              call  CHECK_FREE_MEMORY ; no, OUT OF MEMORY error
              push  hl             ; program pointer on stack
              call  CMD_DATA       ; search for next statement
              ex    (sp),hl        ; program pointer to next statement on stack, save old pointer
              push  hl             ; and also back on the stack
              ld    hl,(0x78A2)    ; load line number
              ex    (sp),hl        ; swap with pointer on stack
              rst   8              ; follows a 'TO' token ?
              cp    l
              rst   0x20           ; test type of loop variable
              jp    z,TMERR        ; String? yes, TYPE MISMATCH error
              jp    nc,TMERR       ; double precision? yes, TYPE MISMATCH error
              push  af             ; (FF = Integer, 01 = single precision)
              call  0x2337         ; calculate end value expression
              pop   af             ; load type flag
              push  hl             ; program pointer on stack
              jp    p,0x1CEC       ; single precision!
              call  FRCINT         ; Integer, convert end value
              ex    (sp),hl        ; end value on the stack
              ld    de,0x0001      ; increment value = 1
              ld    a,(hl)         ; load next character
              cp    0xCC           ; = STEP token ?
              call  z,0x2B01       ; yes, evaluate increment value and convert to integer (in DE)
              push  de             ; increment value on the stack
              push  hl             ; save program pointer
              ex    de,hl          ; increment value in HL
              call  ISIGN          ; test increment value
              jr    $+36           ; continue at 1D0E
              call  FRCSNG         ; convert end value to single precision
              call  MOVRF          ; transfer to Y
              pop   hl             ; reload program pointer
              push  bc             ; end value on the stack
              push  de
              ld    bc,0x8100      ; increment value = 1 in Y
              ld    d,c
              ld    e,d
              ld    a,(hl)         ; load next character
              cp    0xCC           ; = STEP token ?
              ld    a,0x01         ; set flag for positive increment
              jr    nz,$+16        ; no!
              call  0x2338         ; evaluate increment value
              push  hl             ; program pointer on the stack
              call  FRCSNG         ; evaluate increment value
              call  MOVRF          ; and enter in Y
              call  SIGN           ; test increment value (A=1 if positive, A=FF if negative)
              pop   hl             ; reload program pointer
              push  bc             ; increment value on stack
              push  de             ; load program pointer
              ld    c,a            ; increment flag in C
              rst   0x20           ; test type of increment value
              ld    b,a            ; (01 = single precision, FF = Integer)
              push  bc             ; type flag and increment flag on stack
              push  hl             ; program pointer on stack
              ld    hl,(0x78DF)    ; address of loop variable in HL
              ex    (sp),hl        ; swap with program pointer on stack
              ld    b,0x81         ; FOR token (81) in B
              push  bc             ; as marker on the stack
              inc   sp             ; remove LSB

; Program execution
; HL must point to ':' or end of line
              call  KBD_QUERY_WRAP ; query keyboard
              or    a              ; new key pressed?
              call  nz,0x1DA0      ; yes, analyze
              ld    (0x78E6),hl    ; save program pointer
              ld    (0x78E8),sp    ; save stack pointer
              ld    a,(hl)         ; load character
              cp    0x3A           ; ':''? (multiple statements in line)
              jr    z,$+43         ; yes!
              or    a              ; line end ?
              jp    nz,SYNTAX_ERR_HANDLER ; no, SYNTAX ERROR
              inc   hl             ; program end?
              ld    a,(hl)         ; (line pointer = 0000)
              inc   hl
              or    (hl)
              jp    z,IMPLICIT_END ; yes, implicit end
              inc   hl             ; program pointer to line number
              ld    e,(hl)         ; load line number in DE
              inc   hl
              ld    d,(hl)         ; line number in HL, program pointer in DE
              ex    de,hl
              ld    (0x78A2),hl    ; line number = current line number
              ld    a,(0x791B)     ; (TRON)
              or    a              ; no!
              jr    z,$+17
              push  de             ; program pointer on stack
              ld    a,0x3C         ; '<' output
              call  CHAR_OUTPUT_DISPATCH
              call  LINPRT         ; line number output
              ld    a,0x3E         ; '>' output
              call  CHAR_OUTPUT_DISPATCH
              pop   de             ; reload program pointer
              ex    de,hl          ; program pointer in HL
              rst   0x10           ; address next character
              ld    de,NEWSTT      ; return address on stack
              push  de
              ret   z              ; end of statement
              sub   0x80           ; token ?
              jp    c,CMD_LET      ; no, assignment without LET
              cp    0x3C           ; statement token ?
              jp    nc,0x2AE7      ; no!
              rlca                 ; token * 2 in BC
              ld    c,a
              ld    b,0x00
              ex    de,hl          ; program pointer in DE
              ld    hl,0x1822      ; start of jump table
              add   hl,bc          ; + 2*token = pointer to jump address
              ld    c,(hl)         ; load jump address
              inc   hl
              ld    b,(hl)
              push  bc             ; and onto the stack
              ex    de,hl          ; reload program pointer in HL

; Restart 10
; Search for next character in program text
; 09, 0A (LF) and 20 (' ') are skipped
              inc   hl             ; program pointer + 1
              ld    a,(hl)         ; load character
              cp    0x3A           ; ':''?
              ret   nc             ; yes!
              cp    0x20           ; space ?
              jp    z,CHRGTR       ; yes, next character
              cp    0x0B           ; digit ?
              jr    nc,$+7         ; next character
              cp    0x09           ; > 09H ? (excludes 09 and 0A)
              jp    nc,CHRGTR      ; yes, next character
              cp    0x30           ; '0' ?
              ccf                  ; yes, Carry = 1
              inc   a              ; line end ?
              dec   a
              ret                  ; done

; RESTORE statement
; Resetting the DATA pointer
              ex    de,hl          ; program pointer in DE
              ld    hl,(0x78A4)    ; program start address
              dec   hl             ; - 1
              ld    (0x78FF),hl    ; store as DATA pointer
              ex    de,hl          ; reload program pointer
              ret                  ; done

; keyboard activity during program execution
; or analyze during LIST
              call  KBD_QUERY_WRAP ; key pressed ?
              or    a              ; no!
              ret   z              ; no, done!
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    (0x7899),a
              dec   a
              ret   nz
              inc   a              ; A = 1 set (BREAK identifier)
              jp    0x1DB4         ; continue at END

; END - statement
; Terminate program execution
              ret   nz             ; following parameters? yes, error
              push  af             ; END flag (A=0) on stack
              call  z,0x79BB       ; RAM expansion exit
              pop   af             ; END flag reload
              ld    (0x78E6),hl    ; save current program pointer
              ld    hl,0x78B5      ; clear intermediate buffer for strings.
              ld    (0x78B3),hl    ; (pointer to start)
              DEFB  0x21           ; LD HL,0FFF6H Dummy instruction

; Entry for BREAK in INPUT statement
              or    0xFF           ; END flag = FF (BREAK in INPUT)
              pop   bc             ; remove return address from stack.
              ld    hl,(0x78A2)    ; load current line number
              push  hl             ; on stack
              push  af             ; END flag on stack
              ld    a,l            ; line number = FFFF ?
              and   h              ; (= direct mode)
              inc   a
              jr    z,$+11         ; yes!
              ld    (0x78F5),hl    ; no, save as CONT line number.
              ld    hl,(0x78E6)    ; current program pointer
              ld    (0x78F7),hl    ; as CONT pointer save
              call  OUTPUT_SCREEN_SELECT ; output flag on screen. CR on
              call  PRINT_BOL_CHECK ; CR on screen, if required
              pop   af             ; reload END flag
              ld    hl,MSG_BREAK_TEXT ; address 'BREAK' text
              jp    nz,0x1A06      ; if not END and not direct mode, output 'BREAK IN line'
              jp    MAIN_LOOP_ENTRY ; back to main loop

; CONT - statement
; Resume program execution after BREAK or error
              ld    hl,(0x78F7)    ; load CONT program pointer
              ld    a,h            ; = 0000 ?
              or    l              ; (no continuation possible)
              ld    e,0x20         ; load error code CAN'T CONTINUE
              jp    z,ERROR_HANDLER ; yes, output error message
              ex    de,hl          ; program pointer in DE
              ld    hl,(0x78F5)    ; load CONT line number
              ld    (0x78A2),hl    ; and save in current line pointer.
              ex    de,hl          ; program pointer in HL
              ret                  ; resume program execution

; TRON - statement
; Turn trace on
              DEFB  0x3E           ; LD A,0AFH at TRON A<>0 set

; TROFF - statement
; Turn trace off
              xor   a              ; at TROFF A = 0 set
              ld    (0x791B),a     ; save as TRACE flag
              ret   
              pop   af             ; not used
              pop   hl
              ret   

; DEFSTR - statement
; Define string variables
              ld    e,0x03         ; typecode = String in E
              DEFB  0x01           ; LD BC,021EH Dummy instruction

; DEFINT - statement
; Define integer variables
              ld    e,0x02         ; typecode = Integer in E
              DEFB  0x01           ; LD BC,041EH Dummy instruction

; DEFSNG - statement
; Define single precision variables
              ld    e,0x04         ; typecode = single precision in E
              DEFB  0x01           ; LD BC,081EH Dummy instruction

; DEFDBL - statement
; Define double precision variables
              ld    e,0x08         ; typecode = double precision in E

; common routine
              call  ISLET          ; next character = letter?
              ld    bc,SYNTAX_ERR_HANDLER ; address SN error routine
              push  bc             ; and on stack
              ret   c              ; no letter, output SYNTAX ERROR.
              sub   0x41           ; determine position in alphabet
              ld    c,a            ; transfer to B and C
              ld    b,a
              rst   0x10           ; load next character
              cp    0xCE           ; = '-' token
              jr    nz,$+11        ; no!
              rst   0x10           ; load next character
              call  ISLET          ; = letter ?
              ret   c              ; no, output SYNTAX ERROR
              sub   0x41           ; determine position in alphabet
              ld    b,a            ; as high value in B
              rst   0x10           ; load next character
              ld    a,b            ; 2nd letter < 1st letter ?
              sub   c
              ret   c              ; yes, output SYNTAX ERROR
              inc   a              ; difference + 1 = counter
              ex    (sp),hl        ; program pointer on stack
              ld    hl,0x7901      ; address typecode table
              ld    b,0x00         ; offset for 1st letter in BC
              add   hl,bc          ; table start = 1st letter in tab.
              ld    (hl),e         ; enter typecode in table
              inc   hl             ; table address + 1
              dec   a              ; counter - 1
              jr    nz,$-3         ; done? no - next letter
              pop   hl             ; reload program pointer
              ld    a,(hl)         ; load character from program text
              cp    0x2C           ; follow more parameters ?
              ret   nz             ; no, done
              rst   0x10           ; load next character
              jr    $-48           ; enter more definitions

; Tests if character is a letter
              ld    a,(hl)         ; load character
              cp    0x41           ; < A ?
              ret   c              ; yes, no letter
              cp    0x5B           ; <= Z yes, Carry = 1
              ccf                  ; invert carry
              ret   

; Evaluate expression and determine integer value < 32768.
              rst   0x10           ; address next character
              call  0x2B02         ; evaluate expression
              ret   p              ; > 32767 ? no, done

; FUNCTION CODE - Error
              ld    e,0x08         ; error code in E
              jp    ERROR_HANDLER  ; output error message

; Convert string to number ( < 65530 )
              ld    a,(hl)         ; load character from string
              cp    0x2E           ; = '.' ?
              ex    de,hl          ; string pointer in DE
              ld    hl,(0x78EC)    ; '.'-line number in HL
              ex    de,hl          ; swap string and '.'-ZNr
              jp    z,CHRGTR       ; yes, done
              dec   hl             ; string pointer - 1
              ld    de,START       ; value = 0 set
              rst   0x10           ; load next character
              ret   nc             ; no digit, done
              push  hl             ; string pointer on stack
              push  af             ; digit on stack
              ld    hl,0x1998      ; value > 1998H ?
              rst   0x18           ; (i.e. value*10 > 65529)
              jp    c,SYNTAX_ERR_HANDLER ; yes, SYNTAX ERROR
              ld    h,d            ; transfer value in HL
              ld    l,e
              add   hl,de          ; value * 2
              add   hl,hl          ; * 4
              add   hl,de          ; * 5
              add   hl,hl          ; * 10
              pop   af             ; reload digit
              sub   0x30           ; remove zone part
              ld    e,a            ; in DE transfer
              ld    d,0x00
              add   hl,de          ; add to 10*value
              ex    de,hl          ; transfer value in DE
              pop   hl             ; pop string pointer
              jr    $-26           ; next digit

; CLEAR - statement
; Clear variables and define string area
              jp    z,0x1B61       ; no parameters? Jump to NEW
              call  0x1E46         ; evaluate expression
              dec   hl             ; program pointer - 1
              rst   0x10           ; address next character
              ret   nz             ; command end?
              push  hl             ; program pointer on stack
              ld    hl,(0x78B1)    ; BASIC-RAM end address loaded
              ld    a,l            ; - argument of CLEAR statement
              sub   e              ; = start of string area - 1
              ld    e,a
              ld    a,h
              sbc   a,d
              ld    d,a
              jp    c,ERROR_ENTRY  ; underflow, OUT OF MEMORY - error
              ld    hl,(0x78F9)    ; start of variable table
              ld    bc,RST28_VEC   ; + 64
              add   hl,bc
              rst   0x18           ; < new string area address - 1?
              jp    nc,ERROR_ENTRY ; no, OUT OF MEMORY - error
              ex    de,hl          ; new string area start - 1
              ld    (0x78A0),hl    ; save
              pop   hl             ; reload program pointer
              jp    0x1B61         ; continue at NEW

; RUN statement
; Start program
              jp    z,VRESET       ; no line number? continue at NEW
              call  0x79C7         ; RAM expansion exit
              call  0x1B61         ; clear variables
              ld    bc,NEWSTT      ; load return address
              jr    $+18           ; continue at GOTO

; GOSUB statement
; Call subroutine
              ld    c,0x03         ; check if 6 bytes are free
              call  CHECK_FREE_MEMORY
              pop   bc             ; remove return address
              push  hl             ; HL on the stack
              push  hl             ; program pointer again on stack
              ld    hl,(0x78A2)    ; with current line number
              ex    (sp),hl        ; swap
              ld    a,0x91         ; 91 as flag for GOSUB
              push  af             ; on the stack
              inc   sp             ; remove LSB
              push  bc             ; return address back on stack

; GOTO - statement
; unconditional jump
              call  DECZ           ; determine jump line number
              call  CMD_ELSE       ; search for end of statement
              push  hl             ; program pointer on stack
              ld    hl,(0x78A2)    ; current line number in HL
              rst   0x18           ; jump to < line number ?
              pop   hl             ; load program pointer
              inc   hl             ; on next line
              call  c,0x1B2F       ; yes, search jump line from this line
              call  nc,FNDLIN      ; no, search jump line from program start
              ld    h,b            ; address of jump line in HL
              ld    l,c
              dec   hl             ; program pointer before jump line
              ret   c              ; line present? yes, continue there

; UNDEFINED STATEMENT - Error
              ld    e,0x0E         ; Error code in E
              jp    ERROR_HANDLER  ; Display error message

; RETURN Statement
              ret   nz             ; Parameter? yes, error
              ld    d,0xFF         ; Get data back from stack
              call  STACK_RECOVERY ; (skip FOR data)
              ld    sp,hl          ; Reinitialize stack
              ld    (0x78E8),hl
              cp    0x91           ; Data from a GOSUB call?
              ld    e,0x04         ; Code for RETURN WITHOUT GOSUB error
              jp    nz,ERROR_HANDLER ; no, display error message
              pop   hl             ; Load line number from stack
              ld    (0x78A2),hl    ; store as current line number
              inc   hl             ; Direct mode?
              ld    a,h
              or    l
              jr    nz,$+9         ; no!
              ld    a,(0x78DD)     ; RESUME/RETURN flag set?
              or    a
              jp    nz,MAIN_LOOP_ENTRY ; yes, back to main loop
              ld    hl,NEWSTT      ; Load program pointer
              ex    (sp),hl        ; Swap with program pointer
              DEFB  0x3E           ; LD A, 0E1H dummy instruction
              pop   hl             ; Load program pointer

; DATA Statement
              DEFB  0x01,0x3A      ; Delimiter 1 = ':' in C

; ELSE Statement
              ld    c,0x00         ; Delimiter 1 = 00 in C
              ld    b,0x00         ; Delimiter 2 = 00 in B
ELSE_SWAP:
              ld    a,c            ; Swap delimiter 1 and 2
              ld    c,b
              ld    b,a
ELSE_LOOP:
              ld    a,(hl)         ; Load character
              or    a              ; = end of line?
              ret   z              ; yes, done
              cp    b              ; = delimiter 2?
              ret   z              ; yes, done
              inc   hl             ; Program pointer + 1
              cp    0x22           ; = opening quote?
              jr    z,$-11         ; yes, swap delimiters
              sub   0x8F           ; IF token?
              jr    nz,$-12        ; no, continue
              cp    b              ; if not in string or after
              adc   a,d            ; nesting counter + 1
              ld    d,a
              jr    $-17

; LET Statement
              call  VARPTR_FIND_OR_CREATE ; Search for variable in table
              rst   8              ; Followed by '=' character?
              DEFB  0xD5
              ex    de,hl          ; Address of variable table
              ld    (0x78DF),hl    ; remember for variable
              ex    de,hl
              push  de             ; and pack on the stack
              rst   0x20           ; Test type
              push  af             ; Type flag on stack
              call  0x2337         ; Evaluate expression
              pop   af             ; Load type flag
              ex    (sp),hl        ; Program pointer on stack
              add   a,0x03         ; Calculate type code
              call  0x2819         ; Convert result of expression to
              call  VDFACS         ; X address in DE
              push  hl             ; Addr. of variable table on stack
              jr    nz,$+42        ; Jump if not string
LET_STRING:
              ld    hl,(FACLO)     ; Load string pointer from X reg
              push  hl             ; and on stack
              inc   hl             ; Load string address
              ld    e,(hl)         ; in DE
              inc   hl
              ld    d,(hl)
              ld    hl,(0x78A4)    ; String not in program text or
              rst   0x18
              jr    nc,$+16        ; yes, string in string space
              ld    hl,(0x78A0)    ; String in program text?
              rst   0x18
              pop   de             ; Load string pointer
              jr    nc,$+17        ; yes, string not in string space!
              ld    hl,(0x78F9)    ; does string pointer point to var. tab.?
              rst   0x18
              jr    nc,$+11        ; no, string not in string space.
              DEFB  0x3E           ; LD A, 0D1H dummy instruction
LET_STRING_MOVE:
              pop   de             ; Load string pointer
              call  0x29F5         ; Delete string in intermediate storage
              ex    de,hl          ; String pointer in HL
              call  0x2843         ; Transfer string to string space
LET_STRING_EXIT:
              call  0x29F5         ; Delete string in intermediate storage
              ex    (sp),hl
LET_EXIT:
              call  VMOVE          ; Value of X in variable table
              pop   de             ; clean up stack
              pop   hl             ; Load program pointer
              ret   

; ON Statement
              cp    0x9E           ; followed by an ERROR token?
              jr    nz,$+39        ; no!
ON_ERROR:
              rst   0x10           ; address next character
              rst   8              ; is it a GOTO token?
              DEFB  0x8D
              call  DECZ           ; Decode line number
              ld    a,d            ; = 0?
              or    e              ; (turn off error handling)
              jr    z,$+11         ; yes!
              call  0x1B2A         ; Search for line in program text
              ld    d,b            ; Line address in DE
              ld    e,c
              pop   hl             ; Load program pointer
              jp    nc,ERR_UNDEFINED_STATEMENT ; Line not present!
ON_ERROR_SET:
              ex    de,hl          ; Address of error routine
              ld    (0x78F0),hl    ; store
              ex    de,hl
              ret   c              ; Line number > 0, done!
ON_ERROR_CHECK:
              ld    a,(0x78F2)     ; already an error occurred?
              or    a              ; and test
              ret   z              ; no, done
              ld    a,(0x789A)     ; Error code in E
              ld    e,a
              jp    ERROR_HANDLER_RESUME ; to error handling
ON_GOTO_GOSUB:
              call  0x2B1C         ; Evaluate expression, integer
              ld    a,(hl)         ; Load character from program text
              ld    b,a            ; in B
              cp    0x91           ; = GOSUB token?
              jr    z,$+5          ; yes!
              rst   8              ; is it a GOTO token?
              DEFB  0x8D
              dec   hl             ; Program pointer - 1
              ld    c,e            ; jump variable in C
ON_LOOP:
              dec   c              ; variable - 1 = 0?
              ld    a,b            ; Token in A for jump execution
              jp    z,EXEC_GOTO    ; yes, execute jump with n-th line number
              call  0x1E5B         ; Decode line number
              cp    0x2C           ; followed by a comma?
              ret   nz             ; no, continue program with the next
              jr    $-11           ; next line number

; RESUME Statement
              ld    de,0x78F2      ; Address TRAP flag
              ld    a,(de)         ; Error occurred?
              or    a
              jp    z,RESUME_WITHOUT_ERR_HANDLER ; no, RESUME WITHOUT ERROR
              inc   a              ; A = 0
              ld    (0x789A),a     ; Clear error code
              ld    (de),a         ; Clear TRAP flag
              ld    a,(hl)         ; Load character
              cp    0x87           ; = NEXT token?
              jr    z,$+14         ; yes! RESUME NEXT
              call  DECZ           ; Decode line number
              ret   nz             ; more characters? yes-error
              ld    a,d            ; line number = 0?
              or    e
              jp    nz,GOTO_CONTINUE ; no, continue at GOTO
              inc   a              ; A = 1
              jr    $+4
RESUME_NEXT:
              rst   0x10           ; next character in program text
              ret   nz             ; not end of line, error
              ld    hl,(0x78EE)    ; pointer to faulty line
              ex    de,hl          ; in DE
              ld    hl,(0x78EA)    ; load error line number
              ld    (0x78A2),hl    ; as current line number entry
              ex    de,hl          ; pointer back in HL
              ret   nz             ; RESUME 0? yes-done
              ld    a,(hl)         ; end of line?
              or    a
              jr    nz,$+6         ; no, next statement in line
              inc   hl             ; program pointer to 1. statement
              inc   hl             ; of the next line
              inc   hl             ; (behind pointer and line number)
              inc   hl
              inc   hl
              ld    a,d            ; direct mode?
              and   e              ; (line number = FFFF)
              inc   a
              jp    nz,CMD_DATA    ; no, next statement, done
              ld    a,(0x78DD)     ; RETURN/RESUME flag set?
              dec   a
              jp    z,CMD_END_INPUT ; ja, terminate program execution.
              jp    CMD_DATA       ; search next statement, done

; ERROR Statement
              call  0x2B1C         ; analyze error code
              ret   nz             ; more characters? yes-error
              or    a              ; error code = 0?
              jp    z,0x1E4A       ; yes, FUNCTION CODE - Error
              dec   a              ; determine internal error code
              add   a,a
              ld    e,a            ; and store in E
              cp    0x2D           ; < 2D ?
              jr    c,$+4          ; yes!

; UNPRINTABLE ERROR
              ld    e,0x26         ; error code in E
              jp    ERROR_HANDLER  ; to error routine

; AUTO Statement
              ld    de,0x000A      ; starting and increment value = 10
              push  de             ; on stack
              jr    z,$+25         ; no further characters entered!
              call  VAL            ; decode starting value
              ex    de,hl          ; starting value in HL, program pointer DE
              ex    (sp),hl        ; starting value on stack
              jr    z,$+19         ; no further characters entered!
              ex    de,hl          ; program pointer in HL
              rst   8              ; follows a comma?
              DEFB  0x2C
              ex    de,hl          ; program pointer again in DE
              ld    hl,(0x78E4)    ; load old increment value
              ex    de,hl          ; program pointer in HL
              jr    z,$+8          ; no further characters after comma!
              call  DECZ           ; decode increment value
              jp    nz,SYNTAX_ERR_HANDLER ; end of line? no-SYNTAX ERROR
              ex    de,hl          ; increment value in HL
              ld    a,h            ; = 0 ?
              or    l
              jp    z,0x1E4A       ; yes, FUNCTION CODE - Error
              ld    (0x78E4),hl    ; save increment value
              ld    (0x78E1),a     ; set AUTO flag
              pop   hl             ; load starting value
              ld    (0x78E2),hl    ; and save
              pop   bc             ; reload return address from stack
              jp    MAIN_LOOP_READY ; to main loop

; IF Statement
              call  0x2337         ; evaluate conditional expression
              ld    a,(hl)         ; load character
              cp    0x2C           ; = ',' ?
              call  z,CHRGTR       ; yes, next character
              cp    0xCA           ; = THEN token?
              call  z,CHRGTR       ; yes, next character
              dec   hl             ; program pointer - 1
              push  hl             ; and on stack
              call  VSIGN          ; result = 0? (not fulfilled!)
              pop   hl             ; load program pointer
              jr    z,$+9          ; yes, to ELSE execution
IF_THEN:
              rst   0x10           ; next character
              jp    c,GOTO         ; digit? yes-execute jump
              jp    0x1D5F         ; no, execute next statement
IF_ELSE:
              ld    d,0x01         ; nesting counter = 1
              call  CMD_DATA       ; search next statement,
              or    a              ; end of line?
              ret   z              ; done, no ELSE
              rst   0x10           ; next character
              cp    0x95           ; = ELSE token?
              jr    nz,$-8         ; no, continue searching
              dec   d              ; correct ELSE?
              jr    nz,$-11        ; no, continue searching
              jr    $-22           ; yes, continue like THEN

; LPRINT Statement
              ld    a,0x01         ; output flag = printer
              ld    (0x789C),a
              jp    PRINT_LOOP     ; continue at PRINT

; PRINT Statement
              call  0x79CA         ; RAM expansion output
              cp    0x40           ; PRINT @ ?
              jr    nz,$+27        ; no!
PRINT_AT:
              call  0x2B01         ; evaluate position expression
              cp    0x02           ; position > 511?
              jp    nc,0x1E4A      ; yes, FUNCTION CODE - Error
              push  hl             ; program pointer on stack
              ld    hl,0x7000      ; load screen start address
              add   hl,de          ; add position
              ld    (0x7820),hl    ; save as new cursor address
              ld    a,e            ; determine cursor position in line
              and   0x1F           ; = last 5 bits of cursor address
              ld    (0x78A6),a     ; save as new cursor position
              pop   hl             ; load program pointer
              rst   8              ; follows a comma?
              DEFB  0x2C
PRINT_HASH:
              cp    0x23           ; cassette output?
              jr    nz,$+10        ; no, continue
              call  0x3B58         ; write lead-in to cassette
              ld    a,0x80         ; output flag on cassette
              ld    (0x789C),a
PRINT_LOOP:
              dec   hl             ; program pointer - 1
              rst   0x10           ; next character. end of statement?
              call  z,PRINT_CR     ; yes, output CR
              jp    z,PRINT_FINAL  ; and done
              cp    0xBF           ; = USING token?
              jp    z,0x2CBD       ; yes, formatted output
              cp    0xBC           ; = TAB token?
              jp    z,PRINT_TAB    ; yes!
              push  hl             ; program pointer on stack
              cp    0x2C           ; comma ?
              jp    z,PRINT_COMMA  ; yes, to next TAB position
              cp    0x3B           ; semicolon ?
              jp    z,0x3B0C       ; wait until all characters output.
              pop   bc             ; load program pointer
              call  0x2337         ; evaluate expression
              push  hl             ; program pointer on stack
              rst   0x20           ; test data type
              jr    z,$+52         ; string? yes, jump
              call  PUSTR_UNFORM_INIT ; convert num. values to string
              call  0x2865         ; string in intermediate storage and X
              call  0x79CD         ; RAM expansion output
              ld    hl,(FACLO)     ; load string pointer from X reg
              ld    a,(0x789C)     ; load output flag
              or    a              ; and test
              jp    m,0x20E9       ; cassette? yes-no formatting
              jr    z,$+10         ; screen? yes-jump
              ld    a,(0x789B)     ; load print head position
              add   a,(hl)         ; + string length
              cp    0x84           ; > line length (132)?
              jr    $+11           ; continue at 20E6H
              ld    a,(0x789D)     ; load screen line length
              ld    b,a            ; in B
              ld    a,(0x78A6)     ; load cursor position in line
              add   a,(hl)         ; + string length
              cp    b              ; > line length (64)?
              call  nc,PRINT_CR    ; yes, output Carriage Return
              call  0x28AA         ; output string
              ld    a,0x20         ; then a space
              call  CHAR_OUTPUT_DISPATCH ; output string
              or    a              ; Z=0, so next command is skipped.
PRINT_VAL:
              call  z,0x28AA       ; print string
              pop   hl             ; load program pointer
              jp    PRINT_LOOP     ; continue!

; Check if cursor is at start of line
PRINT_BOL_CHECK:
              call  0x3B1C         ; load cursor position
              or    a              ; = 0 ?
              ret   z              ; yes, back

; Output Carriage-Return
              ld    a,0x0D         ; load CR code
              call  CHAR_OUTPUT_DISPATCH ; and output
              call  0x79D0         ; RAM expansion output
              xor   a              ; reset A + flags
              ret   

; evaluate ','
              call  0x79D3         ; RAM expansion output
              ld    a,(0x789C)     ; load output flag
              or    a              ; and test
              jp    p,0x2119       ; printer? ja!
              ld    a,0x2C         ; record comma on cassette
              call  CHAR_OUTPUT_DISPATCH ; and output
              jr    $+77           ; continue at 2164H
              jr    z,$+10         ; screen? ja - jump
              ld    a,(0x789B)     ; print head position in line
              cp    0x70           ; = 112?
              jp    0x212B         ; continue at 212BH
              ld    a,(0x789E)     ; load screen line length
              ld    b,a            ; in B
              ld    a,(0x7AAE)     ; load cursor position in line
              cp    b              ; < last TAB position?
              call  nc,PRINT_CR    ; no, output Carriage Return
              jr    nc,$+54        ; and continue
              sub   0x10           ; cursor position - 16 to < 0
              jr    nc,$-2
              cpl                  ; one's complement
              jr    $+37           ; = number of spaces - 1

; evaluate TAB
              call  0x2B1B         ; evaluate expression, integer
              and   0x3F           ; clear bit 7 (max 127)
              ld    e,a            ; in E
              rst   8              ; follows a ')'?
              add   hl,hl
              dec   hl             ; program pointer - 1
              push  hl             ; and on stack
              call  0x79D3         ; RAM expansion output
              ld    a,(0x789C)     ; load output flag
              or    a              ; and test
              jp    m,0x1E4A       ; cassette? FUNCTION CODE - Error
              jp    z,0x2153       ; screen? ja-jump
              ld    a,(0x789B)     ; load print head position
              jr    $+5            ; continue at screen
              ld    a,(0x78A6)     ; load cursor position
              cpl                  ; one's complement
              add   a,e            ; + TAB value
              jr    nc,$+12        ; already reached or exceeded?
              inc   a              ; + 1
              ld    b,a            ; number of spaces to output
              ld    a,0x20         ; load space code
              call  CHAR_OUTPUT_DISPATCH ; and output
              dec   b              ; counter - 1
              jr    nz,$-4         ; != 0? no - next space

; Next PRINT - sub-expression
              pop   hl             ; load program pointer
              rst   0x10           ; address next character
              jp    0x20A0         ; and back

; Final PRINT check
              ld    a,(0x789C)     ; load output flag
              nop                  ; 4 x NOP
              nop   
              nop   
              nop   
              xor   a              ; reset output flag
              ld    (0x789C),a     ; set to screen
              call  0x79BE         ; RAM expansion output
              ret   

; Text Definition
              DEFM  "?REDO"        ; ?REDO
              DEFB  0x0D,0x00      ; 0x0D, 0x00

; Error during data input
              ld    a,(0x78DE)     ; DATA flag set?
              or    a              ; A
              jp    nz,SYNTAX_ERR_DATA ; ja, SYNTAX ERROR in DATA instruction
              ld    a,(0x78A9)     ; input from cassette?
              or    a              ; A
              ld    e,0x2A         ; error code in E
              jp    z,ERROR_HANDLER ; ja, BAD FILE DATA - Error
              pop   bc             ; keyboard input, load buffer pointer
              ld    hl,REDO_TEXT   ; address text '?REDO'
              call  OUTSTR         ; and output
              ld    hl,(0x78E6)    ; current program pointer in HL
              ret                  ; restart input

; INPUT Statement
              call  0x2828         ; direct command?
              ld    a,(hl)         ; load character
              call  0x79D6         ; RAM expansion output
              sub   0x23           ; read from cassette?
              ld    (0x78A9),a     ; difference as INPUT flag (0=cass)
              ld    a,(hl)         ; load character
              jr    nz,$+34        ; no cassette!

; Read from Cassette
              call  0x3B68         ; search file on cassette
              push  hl             ; program pointer on stack
              ld    b,0xFA         ; max. 250 characters
              ld    hl,(0x78A7)    ; address I/O buffer
              call  0x3B88         ; read one byte
              ld    (hl),a         ; transfer to buffer
              inc   hl             ; buffer pointer + 1
              cp    0x0D           ; end of record?
              jr    z,$+4          ; ja!
              djnz  $-9            ; counter - 1 = 0?
              dec   hl             ; ja, mark end of record with 00
              ld    (hl),0x00      ; Load (HL),0
              nop                  ; 3 x NOP
              nop   
              nop   
              ld    hl,(0x78A7)    ; address buffer start
              dec   hl             ; buffer pointer 1 byte before start
              jr    $+36           ; continue at 21EBH

; Read from Keyboard
              ld    bc,0x21DB      ; set return address
              push  bc             ; BC
              cp    0x22           ; with previous text output?
              ret   nz             ; no, continue at 21DBH
              call  0x2866         ; text in buffer and X
              rst   8              ; follows a semicolon?
              DEFB  0x3B           ; DEFB ';'
              push  hl             ; program pointer on stack
              call  0x28AA         ; output text
              pop   hl             ; load program pointer
              ret                  ; continue at 21DBH
              push  hl             ; program pointer on stack
              call  PROMPT_RD      ; print '?' and read line into I/O buffer
              pop   bc             ; program pointer in BC
              jp    c,CMD_END_INPUT ; BREAK? ja - jump
              inc   hl             ; buffer pointer to 1st character
              ld    a,(hl)         ; load character
              or    a              ; end of text?
              dec   hl             ; A
              push  bc             ; program pointer back to 1st character
              jp    z,CMD_DATA_SKIP ; no text, skip INPUT instruction
              ld    (hl),0x2C      ; set comma before first character
              jr    $+7            ; continue at 21F4H

; READ Statement
              push  hl             ; program pointer on stack
              ld    hl,(0x78FF)    ; DATA pointer in HL
              DEFB  0xF6           ; set DATA flag

; Clear DATA flag
; DATA_FLAG_CLEAR: (defined in symbols.sym)
              xor   a              ; clear DATA flag (Redefinition of 21F4H)
              ld    (0x78DE),a     ; save DATA flag
              ex    (sp),hl        ; buffer/DATA pointer on stack
              jr    $+4            ; continue at 21FDH

; Next Variable
              rst   8              ; follows a comma?
              DEFB  0x2C           ; DEFB ','
INPUT_READ_LOOP:
              call  VARPTR_FIND_OR_CREATE ; Search for variable in variable table
              ex    (sp),hl        ; Program pointer on stack
              push  de             ; Var. tab. address in DE
              ld    a,(hl)         ; Load character from buffer
              cp    0x2C           ; = comma ?
              jr    z,$+40         ; yes, continue

; Buffer empty (no ',')
INPUT_EMPTY_BUFFER:
              ld    a,(0x78DE)     ; DATA flag set ?
              or    a
              jp    nz,DATA_FIND_STMT_END ; yes, search for next DATA statement
              ld    a,(0x78A9)     ; Input from cassette ?
              or    a
              ld    e,0x06         ; Error code in E
              jp    z,ERROR_HANDLER ; yes, OUT OF DATA - Error
INPUT_PROMPT_AGAIN:
              ld    a,0x3F         ; Keyboard: output '?'
              call  CHAR_OUTPUT_DISPATCH ; Tastatur: '?' ausgeben
              call  PROMPT_RD      ; Re-enter with '??'
              pop   de             ; Load var. tab. address
              pop   bc             ; Program pointer in BC
              jp    c,CMD_END_INPUT ; BREAK? yes - jump
              inc   hl             ; Buffer pointer to 1st character
              ld    a,(hl)         ; Load character
              or    a              ; End of line ?
              dec   hl             ; Buffer pointer before 1st character
              push  bc             ; Program pointer on stack
              jp    z,CMD_DATA_SKIP ; yes, skip remaining input, without changing variable values
              push  de

; Decode input
INPUT_VALUE_START:
              call  HOOK_INPUT_VALUE ; RAM expansion output
              rst   0x20           ; Test type of variable
              push  af             ; Save type flag
              jr    nz,$+27        ; numeric? yes, jump

; Accept string
INPUT_VALUE_STRING:
              rst   0x10           ; Buffer pointer to next character
              ld    d,a            ; as delimiter in D and B
              ld    b,a
              cp    0x22           ; Quotation mark ?
              jr    z,$+7          ; yes, use '\
              ld    d,0x3A         ; no, ':' and ',' as delimiters
              ld    b,0x2C
              dec   hl             ; Buffer pointer back 1 byte
INPUT_STRING_PROC:
              call  STR_TO_FAC     ; String in temporary storage and X

; Store new variable value
              pop   af             ; Load type flag
              ex    de,hl          ; Buffer pointer in DE
              ld    hl,INPUT_VALUE_NEXT ; Return address in HL
              ex    (sp),hl        ; swap with var. tab. adr. on stack
              push  de             ; Buffer pointer on stack
              jp    LET_ENTRY_2    ; Jump to LET and then 225AH

; Take number into X
INPUT_VALUE_NUMERIC:
              rst   0x10           ; Address next character
              pop   af             ; Load type flag
              push  af             ; and back on stack
              ld    bc,0x2243      ; Return address on stack
              push  bc
              jp    c,STR_TO_NUM   ; Integer and single precision? yes, convert string, then 2243H
              jp    nc,STR_TO_DOUBLE ; double precision? conv., then 2243H
INPUT_VALUE_NEXT:
              dec   hl             ; Buffer pointer - 1
              rst   0x10           ; next character. 00 or ':' ?
              jr    z,$+7          ; yes, end of line !
              cp    0x2C           ; Comma ?
              jp    nz,INPUT_REDO  ; no, error
              ex    (sp),hl        ; Program pointer with buffer pointer exchange on stack
              dec   hl             ; Program pointer - 1
              rst   0x10           ; next character. = end of statement?
              jp    nz,READ_NEXT_VAR ; no, continue with next variables

; No further variables
INPUT_EXTRA_CHECK:
              pop   de
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    a,(0x78DE)     ; Load DATA flag
              or    a              ; set ?
              ex    de,hl          ; Buffer pointer-HL, prog pointer-DE
              jp    nz,0x1D96      ; Store buffer pointer as DATA pointer, Program pointer in HL, do
              push  de             ; Program pointer on stack
              call  HOOK_READ_INPUT_LIST ; RAM expansion output
              or    (hl)
              ld    hl,EXTRA_IGNORED_TEXT ; Address text '?EXTRA IGNORED'
              call  nz,OUTSTR      ; no, output text
              pop   hl             ; Load program pointer
              jp    PRINT_FINAL    ; Output flag to screen, done
              DEFM  "?EXTRA IGNORED"
              DEFB  0x0D,0x00

; Search for next DATA statement
DATA_FIND_STMT_END:
              call  CMD_DATA       ; Search for end of statement
              or    a              ; = end of line ?
              jr    nz,$+20        ; no!
              inc   hl             ; yes, end of program ?
              ld    a,(hl)         ; (Line pointer = 0000)
              inc   hl
              or    (hl)
              ld    e,0x06         ; Error code in E
              jp    z,ERROR_HANDLER ; yes, OUT OF DATA - Error
              inc   hl             ; Load line number
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              ex    de,hl
              ld    (DATA_LINE_NUM),hl ; and store as DATA line number
              ex    de,hl          ; Line number back in DE
DATA_SEARCH_LOOP:
              rst   0x10           ; Next character from program text
              cp    0x88           ; = DATA token ?
              jr    nz,$-27        ; no, continue searching
              jp    INPUT_VALUE_START ; continue reading data

; *****************************************************************
; NEXT statement
; Looping in FOR-NEXT loops
              ld    de,START       ; Var. tab. address = 0 (for NEXT without variable)
              call  nz,VARPTR_FIND_OR_CREATE ; further characters? yes - variable search, var. tab. address in
              ld    (0x78DF),hl    ; Store program pointer
              call  STACK_RECOVERY ; in stack next, or loop search with correct running variable
              jp    nz,NEXT_WITHOUT_FOR_ERR_HANDLER ; not found, NEXT WITHOUT FOR
              ld    sp,hl          ; by stack correction all associated nested loops removed.
              ld    (0x78E8),hl    ; remove nested loops.
              push  de             ; Var. tab. adr of loop var on stack.
              ld    a,(hl)         ; Load increment flag
              inc   hl             ; Stack pointer + 1
              push  af             ; Increment flag on stack
              push  de             ; Var. tab. address on stack
              ld    a,(hl)         ; Load type flag
              inc   hl             ; Stack pointer + 1
              or    a              ; = single precision?
              jp    m,0x22EA       ; no! - jump

; Single precision loop variable
              call  MOVFM          ; Increment value in X
              ex    (sp),hl        ; Load var. tab. address, Stack pointer on stack
              push  hl             ; Var. tab. address back on stack
              call  0x070B         ; Loop variable + increment value
              pop   hl             ; Load var. tab. address
              call  MOVMF          ; Store new value of loop var.
              pop   hl             ; Load stack pointer
              call  MOVRM          ; Load end value into Y
              push  hl             ; Stack pointer on stack
              call  FCOMP          ; Compare loop variable with end value
              jr    $+43           ; continue at 2313H
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
              jp    nz,NEWSTT
              rst   0x10
              call  0x22B9
              rst   8
              jr    z,$+45
              ld    d,0x00
              push  de
              ld    c,0x01
              call  CHECK_FREE_MEMORY
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
              jp    c,SYNTAX_ERR_HANDLER
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
              jp    z,ERROR_HANDLER
              jp    c,STR_TO_NUM
              call  ISLET
              jp    nc,0x2540
              cp    0xCD
              jr    z,$-17
              cp    0x2E
              jp    z,STR_TO_NUM
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
              call  VARPTR_FIND_OR_CREATE
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
              call  ISLET
              jp    c,SYNTAX_ERR_HANDLER
              xor   a
              ld    c,a
              rst   0x10
              jr    c,$+7
              call  ISLET
              jr    c,$+11
              ld    c,a
              rst   0x10
              jr    c,$-1
              call  ISLET
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
              call  MAKE_SPACE
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
              call  GETVAL
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
              jp    nz,ERROR_HANDLER
              pop   af
              sub   (hl)
              jp    z,0x2795
              ld    e,0x10
              jp    ERROR_HANDLER
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
              call  CHECK_FREE_MEMORY
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
              jp    ERROR_HANDLER
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
              call  z,CHRGTR
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
              jp    ERROR_HANDLER
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
              jp    z,ERROR_HANDLER
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
              jp    c,ERROR_HANDLER
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
              jp    nz,SYNTAX_ERR_HANDLER
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
              call  LIST_ARGS
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
              jp    z,MAIN_LOOP
              call  HOOK_READ_INPUT_LIST
              call  ISCNTC
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
              jp    c,MAIN_LOOP_ENTRY
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
              call  PRINT_CR
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
              ld    hl,KWD_80_END
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
              call  LIST_ARGS
              pop   de
              push  bc
              push  bc
              call  FNDLIN
              jr    nc,$+7
              ld    d,h
              ld    e,l
              ex    (sp),hl
              push  hl
              rst   0x18
              jp    nc,0x1E4A
              ld    hl,MSG_READY_TEXT
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
              ld    hl,STACK_RECOVERY
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
              jp    nz,SYNTAX_ERR_HANDLER
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
              call  c,PRINT_CR
              ex    (sp),hl
              call  0x29DD
              pop   hl
              jp    PRINT_FINAL
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
              ld    hl,MSG_READY_TEXT
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
              call  RENEW_LINE_PTRS
              call  0x79B5
              call  VRESET
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
              jp    nz,PRINT_NEXT
              ld    a,(0x7AAF)
              or    a
              jr    nz,$-4
              jp    PRINT_NEXT
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
              call  PRINT_BOL_CHECK
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
              jp    RDLINE
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
