; z80bench export — .
; Generated: Thu Apr  2 12:56:48 2026
; Assembler: z88dk/z80asm

        INCLUDE "symbols.sym"
        ORG     0x0000


; Initialisation of the computer
; START: (defined in symbols.sym)
              di                   ; Main entry point from RESET
              xor   a              ; Clear A (color index 0)
              ld    (0x6800),a     ; Set background color (black)
              jp    0x0674         ; Jump to RESET part 1 (at 0674H)

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
              jp    0x03C2         ; Jump to DCB dispatcher (0674H)

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
              DEFB  0x4C,0xFE,0x54,0x20
              DEFB  0xD6,0xFD,0x21,0xF1

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
              ld    de,0x7880      ; Destination: 7880H (RAM hooks)
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
              ld    hl,ERCALL      ; RAM hook table address (7952H)
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
              call  STKINI         ; Initialize stack and variables (STKINI)
              call  CLRSCR         ; Clear screen and home cursor (CLRSCR)
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   

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
              jp    0x068E         ; Jump to memory expansion check (068EH)
              DEFB  0x00,0x7E,0x23,0xFE ; Artifact? No caller
              DEFB  0x0D

; Banner-Text: VIDEO TECHNOLOGY BASIC V2.0
              DEFM  "VIDEO TECHNOLOGY"
              DEFB  0x0D
              DEFM  "BASIC V2.0"
              DEFB  0x0D,0x0D,0x00 ; term with 00

; L3 Error Handler (?L3 ERROR)
; ERROR_L3: (defined in symbols.sym)
              ld    e,0x2C         ; Load error code 44 (L3 Error)
              jp    ERROR_HANDLER  ; Jump to main error handler
              rst   0x10
              xor   a
              ld    bc,0x803E
              ld    bc,0x013E
              push  af
              rst   8
              jr    z,$-49
              inc   e
              dec   hl
              cp    0x80
              jp    nc,0x1E4A
              push  af
              rst   8
              inc   l
              call  0x2B1C
              cp    0x40
              jp    nc,0x1E4A
              ld    e,a
              xor   a
              ld    d,a
              ex    de,hl
              add   hl,hl
              add   hl,hl
              add   hl,hl
              add   hl,hl
              add   hl,hl
              ex    de,hl
              pop   af
              push  af
              srl   a
              srl   a
              add   a,e
              ld    e,a
              ld    a,d
              or    0x70
              ld    d,a
              pop   af
              and   0x03
              add   a,a
              ld    b,a
              pop   af
              or    a
              jp    z,0x38E7
              push  af
              ld    c,0x3F
              ld    a,(0x7846)
              sla   a
              sla   a
              rrc   a
              rrc   c
              djnz  $-4
              jp    0x3903
              ld    hl,0x7839
              res   3,(hl)
              ld    hl,0x0384
              call  OUTSTR
              jp    0x36CF
              pop   af
              cp    0x20
              jr    nz,$+22
              ld    a,(de)
              inc   de
              cp    0x20
              jr    z,$-4
              cp    0xD7
              push  hl
              ld    a,(0x7899)
              or    a
              jr    nz,$+8
              call  0x0358
              or    a
              jr    z,$+19
              push  af
              xor   a
              ld    (0x7899),a
              inc   a
              call  0x2857
              pop   af
              ld    hl,(0x78D4)
              ld    (hl),a
              jp    0x2884
              ld    hl,0x1928
              ld    (0x7921),hl
              ld    a,0x03
              ld    (0x78AF),a
              pop   hl
              ret   
              ld    a,0x1C
              call  0x033A
              ld    a,0x1F
              jp    0x033A
              ld    a,r
              ld    (0x78AB),a
              ret   
              ld    d,h
              ld    b,a
              ld    b,d
              dec   (hl)
              ld    c,(hl)
              ld    (hl),0x59
              ld    c,b
              ld    d,a
              ld    d,e
              ld    e,b
              ld    (0x392E),a
              ld    c,a
              ld    c,h
              nop   
              nop   
              nop   
              nop   
              nop   
              dec   l
              dec   c
              ld    a,(0x4445)
              ld    b,e
              inc   sp
              inc   l
              jr    c,$+75
              ld    c,e
              ld    d,c
              ld    b,c
              ld    e,d
              ld    sp,0x3020
              ld    d,b
              dec   sp
              ld    d,d
              ld    b,(hl)
              ld    d,(hl)
              inc   (hl)
              ld    c,l
              scf   
              ld    d,l
              ld    c,d
              adc   a,h
              adc   a,c
              nop   
              dec   h
              ld    e,(hl)
              ld    h,0x83
              add   a,(hl)
              adc   a,l
              add   a,d
              nop   
              ld    (0x293E),hl
              ld    e,e
              ccf   
              nop   
              nop   
              nop   
              nop   
              nop   
              dec   a
              dec   c
              ld    hl,(0x848B)
              nop   
              inc   hl
              inc   a
              jr    z,$-121
              cpl   
              adc   a,(hl)
              add   a,c
              add   a,b
              ld    hl,0x4020
              ld    e,l
              dec   hl
              add   a,a
              adc   a,b
              nop   
              inc   h
              ld    e,h
              daa   
              adc   a,d
              adc   a,a
              jp    z,0xB58D
              or    h
              sub   a
              adc   a,(hl)
              sub   l
              add   a,h
              cp    l
              call  z,0xB9B1
              dec   de
              adc   a,e
              adc   a,h
              dec   d
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    bc,START
              add   a,a
              adc   a,d
              or    e
              sbc   a,h
              add   hl,bc
              cp    e
              adc   a,c
              cp    h
              add   a,c
              sbc   a,l
              push  hl
              cp    d
              ld    a,(bc)
              adc   a,b
              or    d
              ld    a,a
              sub   d
              sub   c
              xor   a
              sbc   a,b
              ex    af,af'
              add   a,b
              adc   a,a
              sub   e
              jp    m,0x9E94
              rst   0x18
              cp    a
              ret   po
              ld    sp,hl
              add   a,e
              push  af
              call  p,0xE1A0
              nop   
              exx   
              out   (0x00),a
              nop   
              nop   
              nop   
              nop   
              nop   
              ld    bc,START
              di    
              sub   b
              sub   (hl)
              ex    (sp),hl
              nop   
              defb  0x00DD,0x00D2,0x00C6
              rst   0x30
              or    0xDB
              jp    po,0xD800
              rlc   b
              ret   m
              sbc   a,0xC1
              call  po,0xD700
              ret   
              add   a,d
              jp    po,0xE3E1
              call  po,0xE0DF
              rst   0x10
              defb  0x00DD,0x00D9,0x00D8
              rst   0x30
              push  af
              di    
              ret   m
              rst   0x30
              ld    sp,hl
              sbc   a,l
              or    0xF4
              sbc   a,0xE5
              jp    m,0x8080
              add   a,b
              cp    b
              cp    b
              add   a,b
              cp    b
              cp    b
              add   a,b
              add   a,a
              add   a,b
              cp    a
              cp    b
              add   a,a
              cp    b
              cp    a
              add   a,a
              add   a,b
              add   a,a
              cp    b
              cp    a
              add   a,b
              cp    a
              cp    b
              add   a,a
              add   a,a
              add   a,a
              cp    a
              cp    a
              add   a,a
              cp    a
              cp    a
              ld    (hl),d
              ld    (bc),a
              ld    c,a
              ld    (bc),a
              ld    l,0x02
              ld    c,0x02
              pop   af
              ld    bc,0x01D5
              or    a
              ld    bc,0x019E
              add   a,(hl)
              ld    bc,0x0170
              ld    e,e
              ld    bc,0x0148
              dec   (hl)
              ld    bc,0x0123
              inc   de
              ld    bc,0x0103
              call  p,0xE600
              nop   
              exx   
              nop   
              call  0xC100
              nop   
              or    (hl)
              nop   
              xor   e
              nop   
              and   c
              nop   
              sbc   a,b
              nop   
              adc   a,a
              nop   
              add   a,a
              nop   
              ld    a,a
              nop   
              ld    a,b
              nop   
              ld    (hl),b
              nop   
              ld    l,d
              nop   
              ld    b,a
              ld    a,(0x783C)
              ld    hl,(0x7820)
              ld    (hl),a
              ld    a,b
              ret   
              ld    bc,RST20_VEC
              or    a
              sbc   hl,bc
              ld    (0x7820),hl
              ret   
              ld    bc,0x0302
              inc   b
              ld    b,0x08
              inc   c
              djnz  $+26
              push  bc
              ld    c,a
              call  0x79C1
              ld    a,(0x789C)
              or    a
              ld    a,c
              pop   bc
              jp    m,0x3B54
              jr    nz,$+100
              push  de
              push  af
              push  bc
              push  hl
              call  0x308B
              pop   hl
              pop   bc
              nop   
              nop   
              pop   af
              pop   de
              ret   
              ld    a,(0x783D)
              and   0x08
              ld    a,(0x7820)
              jr    z,$+5
              rrca  
              and   0x1F
              and   0x1F
              ret   
              call  0x79C4
              push  de
              call  KBD_QUERY
              pop   de
              ret   
              ld    a,(bc)
              dec   bc
              inc   c
              inc   c
              dec   c
              ld    c,0x0F
              rrca  
              djnz  $+19
              ld    (de),a
              inc   de
              dec   d
              ld    d,0x17
              add   hl,de
              ld    a,(de)
              inc   e
              dec   e
              rra   
              ld    hl,0x2523
              daa   
              add   hl,hl
              inc   l
              ld    l,0x31
              inc   (hl)
              dec   (hl)
              ld    a,(0x4B4F)
              dec   c
              nop   
              ld    b,l
              ld    d,d
              ld    d,d
              ld    c,a
              ld    d,d
              dec   c
              nop   
              xor   a
              ld    (0x789C),a
              ld    a,(0x789B)
              or    a
              ret   z
              ld    a,0x0D
              push  de
              call  0x039C
              pop   de
              ret   
              push  af
              push  de
              push  bc
              ld    c,a
              ld    e,0x00
              cp    0x0C
              jr    z,$+18
              cp    0x0A
              jr    nz,$+5
              ld    a,0x0D
              ld    c,a
              cp    0x0D
              jr    z,$+7
              ld    a,(0x789B)
              inc   a
              ld    e,a
              ld    a,e
              ld    (0x789B),a
              ld    a,c
              call  PRN_OUT_DCB
              pop   bc
              pop   de
              pop   af
              ret   
              push  hl
              push  ix
              push  de
              pop   ix
              push  de
              ld    hl,0x03DD
              push  hl
              ld    c,a
              ld    a,(de)
              and   b
              cp    b
              jp    nz,0x7833
              cp    0x02
              ld    l,(ix+0x01)
              ld    h,(ix+0x02)
              jp    (hl)
              pop   de
              pop   ix
              pop   hl
              pop   bc
              ret   
              ld    hl,0x7839
              set   5,(hl)
              ld    hl,(0x7820)
              call  0x0053
              ld    a,h
              cp    0x71
              jr    nz,$+18
              ld    a,l
              cp    0xE0
              jr    nz,$+13
              ld    a,(0x7AD7)
              or    a
              jr    nz,$+7
              ld    a,0x0D
              call  0x308B
              ld    b,c
              push  bc
              ld    hl,0x7839
              res   0,(hl)
              res   2,(hl)
              bit   0,(hl)
              jr    z,$-2
              ld    a,(0x78A6)
              ld    c,a
              xor   a
              ld    (0x78A6),a
              ld    b,a
              ld    hl,(0x7820)
              sbc   hl,bc
              ld    (0x7820),hl
              ld    de,0x79E8
              pop   bc
              ld    hl,0x7839
              bit   4,(hl)
              ld    hl,(0x7820)
              jr    z,$+68
              push  bc
              push  hl
              call  0x33A8
              pop   hl
              pop   bc
              or    a
              jr    nz,$+10
              ld    a,l
              sub   0x20
              ld    l,a
              ld    a,h
              sbc   a,0x00
              ld    h,a
              ld    c,b
              ld    a,(de)
              cp    (hl)
              jr    nz,$+9
              inc   hl
              inc   de
              djnz  $-6
              push  bc
              jr    $+6
              ld    bc,START
              push  bc
              push  hl
              call  0x33A8
              pop   hl
              pop   bc
              push  bc
              cp    0x80
              jr    z,$+12
              ld    a,0x40
              sub   c
              ld    b,a
              pop   de
              ld    e,0x00
              push  de
              jr    $+7
              ld    b,0x20
              ld    hl,(0x7820)
              ld    de,0x79E8
              jp    0x3EA8
              ld    bc,START
              push  bc
              push  hl
              call  0x33A8
              pop   hl
              cp    0x80
              jr    z,$+16
              cp    0x81
              jr    z,$+8
              ld    bc,RST20_VEC
              or    a
              sbc   hl,bc
              ld    b,0x40
              jr    $+4
              ld    b,0x20
              ld    a,(0x7818)
              or    a
              jp    z,0x3E40
              ld    a,(hl)
              cp    0x40
              jp    c,0x04AE
              pop   bc
              ld    de,0x04A4
              push  de
              push  bc
              jp    0x0502
              ret   c
              ld    hl,0x3E1A
              call  OUTSTR
              jp    0x03E3
              cp    0x22
              jr    nz,$+51
              ld    (de),a
              inc   hl
              inc   de
              dec   b
              jr    z,$+56
              ld    a,(hl)
              cp    0x40
              jp    c,0x04C9
              cp    0x80
              jp    c,0x04C5
              and   0x8F
              or    0x80
              jr    $+21
              cp    0x22
              jr    nz,$+11
              push  hl
              ld    hl,0x7839
              bit   4,(hl)
              pop   hl
              jr    z,$+15
              bit   5,a
              jr    nz,$+4
              or    0x40
              ld    (de),a
              inc   hl
              inc   de
              djnz  $-39
              jr    $+13
              bit   5,a
              jr    nz,$+4
              or    0x40
              ld    (de),a
              inc   hl
              inc   de
              djnz  $-87
              dec   de
              ld    a,d
              cp    0x79
              jr    nz,$+8
              ld    a,e
              cp    0xE8
              jp    c,0x04FF
              ld    a,(de)
              cp    0x20
              jr    z,$-15
              inc   de
              xor   a
              ld    (de),a
              call  0x33A8
              ld    hl,(0x7820)
              cp    0x81
              call  0x0053
              jr    nz,$+6
              xor   a
              call  0x308B
              xor   a
              call  0x308B
              ld    a,(0x7838)
              and   0xFD
              ld    (0x7838),a
              ld    hl,0x7839
              bit   2,(hl)
              jr    z,$+7
              ld    a,0x01
              scf   
              jr    $+3
              xor   a
              ld    hl,0x7839
              res   4,(hl)
              ld    hl,0x79E8
              pop   bc
              push  af
              add   hl,bc
              jp    0x3E29
              ld    a,(0x7AAF)
              or    a
              jr    nz,$-4
              ld    b,0x40
              ld    hl,0x79E8
              ld    a,0x20
              ld    (hl),a
              inc   hl
              djnz  $-2
              xor   a
              ld    (hl),a
              call  0x33A8
              or    a
              ld    a,(0x78A6)
              jr    nz,$+4
              add   a,0x20
              ld    c,a
              xor   a
              ld    b,a
              ld    hl,(0x7820)
              sbc   hl,bc
              ld    de,0x79E8
              push  bc
              ldir  
              pop   bc
              ld    hl,0x7839
              set   4,(hl)
              call  0x03E3
              ret   
              ld    d,d
              ld    d,l
              ld    c,(hl)
              nop   
              call  nz,0x3233
              call  0x1AA3
              call  0x17D8
              call  0x190D
              jp    z,0x125A
              call  0x1F49
              jr    c,$+26
              rst   0x28
              ld    a,(0x0438)
              defb  0x00DD,0x0079,0x00B7
              jr    z,$+53
              cp    0x0B
              jr    z,$+12
              cp    0x0C
              jr    nz,$+22
              xor   a
              or    (ix+0x03)
              jr    z,$+16
              ld    a,(ix+0x03)
              sub   (ix+0x04)
              ld    b,a
              call  0x3AE2
              djnz  $-3
              jr    $+20
              call  0x3AB6
              ld    a,c
              cp    0x0D
              ret   nz
              inc   (ix+0x04)
              ld    a,(ix+0x04)
              cp    (ix+0x03)
              ld    a,c
              ret   nz
              ld    (ix+0x04),0x00
              ret   
              in    a,(0x00)
              and   0x01
              ret   
              push  bc
              push  hl
              ld    b,0x04
              ld    hl,0x7AD2
              ld    (hl),a
              inc   hl
              djnz  $-2
              pop   hl
              pop   bc
              ret   
              ld    hl,0x7838
              bit   2,(hl)
              jr    z,$+23
              ld    d,a
              ld    a,(0x783A)
              or    a
              jr    z,$+17
              inc   a
              ld    (0x783A),a
              cp    0x2A
              jr    z,$+4
              xor   a
              ret   
              res   2,(hl)
              xor   a
              ret   
              ld    d,a
              ld    hl,0x7838
              ld    a,(hl)
              and   0x18
              jr    nz,$+13
              set   3,(hl)
              xor   a
              ld    (0x7837),a
              ld    a,d
              ld    (0x7836),a
              ret   
              bit   4,(hl)
              jr    nz,$+44
              ld    a,(0x7836)
              cp    d
              jr    nz,$+35
              ld    bc,(0x7842)
              ld    hl,(0x7844)
              ld    a,e
              call  0x2F35
              cp    d
              jp    z,0x2FD7
              cp    0x00
              jp    z,0x2FD7
              ld    hl,0x7838
              set   3,(hl)
              set   4,(hl)
              res   2,(hl)
              ld    (0x7837),a
              ret   
              ld    a,d
              jr    $-14
              ld    a,(0x7836)
              cp    d
              jr    z,$+10
              ld    a,(0x7837)
              cp    d
              jr    z,$+4
              xor   a
              ret   
              ld    bc,(0x7842)
              ld    hl,(0x7844)
              ld    a,e
              call  0x2F35
              cp    d
              jr    z,$+7
              cp    0x00
              jp    nz,0x2FD7
              ld    hl,0x7838
              set   3,(hl)
              res   4,(hl)
              ld    a,(0x7836)
              cp    d
              jr    nz,$+7
              xor   a
              ld    (0x7837),a
              ret   
              ld    a,(0x7837)
              ld    (0x7836),a
              jr    $-11
              set   2,(ix+0x09)
              nop   
              nop   
              ld    hl,0x06D2
              ld    de,0x7800
              ld    bc,0x0036
              ldir  
              dec   a
              dec   a
              jr    nz,$-13
              ld    b,0x27
              ld    (de),a
              inc   de
              djnz  $-2
              jp    BASIC_INIT_2
              ld    hl,0x4000
              call  0x06A4
              ld    hl,0x6000
              call  0x06A4
              ld    hl,0x8000
              call  0x06A4
              ei    
              jp    0x1A19
              ld    a,0xAA
              cp    (hl)
              inc   hl
              ret   nz
              cpl   
              cp    (hl)
              inc   hl
              ret   nz
              ld    a,0xE7
              cp    (hl)
              inc   hl
              ret   nz
              cpl   
              cp    (hl)
              inc   hl
              ret   nz
              ei    
              jp    (hl)
              ld    c,0x02
              call  0x1A59
              call  0x34B8
              call  0x18E3
              jr    z,$-62
              rst   0x28
              inc   l
              jr    z,$+22
              call  0x34F1
              ld    bc,0x1A18
              jp    0x19AE
              jp    0x1C96
              jp    0x1D78
              jp    0x1C90
              jp    0x25D9
              ret   
              nop   
              nop   
              ret   
              nop   
              nop   
              ei    
              ret   
              nop   
              ld    bc,0x2EF4
              nop   
              nop   
              nop   
              ld    c,e
              ld    c,c
              nop   
              nop   
              nop   
              nop   
              ld    (hl),b
              nop   
              nop   
              nop   
              ld    b,0x8D
              dec   b
              ld    b,e
              nop   
              nop   
              ld    d,b
              ld    d,d
              jp    0x5000
              rst   0
              nop   
              nop   
              ld    a,0x00
              ret   
              ld    hl,0x1380
              call  0x09C2
              jr    $+8
              call  0x09C2
              call  0x0982
              ld    a,b
              or    a
              ret   z
              ld    a,(0x7924)
              or    a
              jp    z,0x09B4
              sub   b
              jr    nc,$+14
              cpl   
              inc   a
              ex    de,hl
              call  0x09A4
              ex    de,hl
              call  0x09B4
              pop   bc
              pop   de
              cp    0x19
              ret   nc
              push  af
              call  0x09DF
              ld    h,a
              pop   af
              call  0x07D7
              or    h
              ld    hl,0x7921
              jp    p,0x0754
              call  0x07B7
              jp    nc,0x0796
              inc   hl
              inc   (hl)
              jp    z,0x07B2
              ld    l,0x01
              call  0x07EB
              jr    $+68
              xor   a
              sub   b
              ld    b,a
              ld    a,(hl)
              sbc   a,e
              ld    e,a
              inc   hl
              ld    a,(hl)
              sbc   a,d
              ld    d,a
              inc   hl
              ld    a,(hl)
              sbc   a,c
              ld    c,a
              call  c,0x07C3
              ld    l,b
              ld    h,e
              xor   a
              ld    b,a
              ld    a,c
              or    a
              jr    nz,$+26
              ld    c,d
              ld    d,h
              ld    h,l
              ld    l,a
              ld    a,b
              sub   0x08
              cp    0xE0
              jr    nz,$-14
              xor   a
              ld    (0x7924),a
              ret   
              dec   b
              add   hl,hl
              ld    a,d
              rla   
              ld    d,a
              ld    a,c
              adc   a,a
              ld    c,a
              jp    p,0x077D
              ld    a,b
              ld    e,h
              ld    b,l
              or    a
              jr    z,$+10
              ld    hl,0x7924
              add   a,(hl)
              ld    (hl),a
              jr    nc,$-27
              ret   z
              ld    a,b
              ld    hl,0x7924
              or    a
              call  m,0x07A8
              ld    b,(hl)
              inc   hl
              ld    a,(hl)
              and   0x80
              xor   c
              ld    c,a
              jp    0x09B4
              inc   e
              ret   nz
              inc   d
              ret   nz
              inc   c
              ret   nz
              ld    c,0x80
              inc   (hl)
              ret   nz
              ld    e,0x0A
              jp    ERROR_HANDLER
              ld    a,(hl)
              add   a,e
              ld    e,a
              inc   hl
              ld    a,(hl)
              adc   a,d
              ld    d,a
              inc   hl
              ld    a,(hl)
              adc   a,c
              ld    c,a
              ret   
              ld    hl,0x7925
              ld    a,(hl)
              cpl   
              ld    (hl),a
              xor   a
              ld    l,a
              sub   b
              ld    b,a
              ld    a,l
              sbc   a,e
              ld    e,a
              ld    a,l
              sbc   a,d
              ld    d,a
              ld    a,l
              sbc   a,c
              ld    c,a
              ret   
              ld    b,0x00
              sub   0x08
              jr    c,$+9
              ld    b,e
              ld    e,d
              ld    d,c
              ld    c,0x00
              jr    $-9
              add   a,0x09
              ld    l,a
              xor   a
              dec   l
              ret   z
              ld    a,c
              rra   
              ld    c,a
              ld    a,d
              rra   
              ld    d,a
              ld    a,e
              rra   
              ld    e,a
              ld    a,b
              rra   
              ld    b,a
              jr    $-15
              nop   
              nop   
              nop   
              add   a,c
              inc   bc
              xor   d
              ld    d,(hl)
              add   hl,de
              add   a,b
              pop   af
              ld    (0x8076),hl
              ld    b,l
              xor   d
              jr    c,$-124
              call  0x0955
              or    a
              jp    pe,0x1E4A
              ld    hl,0x7924
              ld    a,(hl)
              ld    bc,0x8035
              ld    de,0x04F3
              sub   b
              push  af
              ld    (hl),b
              push  de
              push  bc
              call  0x0716
              pop   bc
              pop   de
              inc   b
              call  0x08A2
              ld    hl,0x07F8
              call  0x0710
              ld    hl,0x07FC
              call  0x149A
              ld    bc,0x8080
              ld    de,START
              call  0x0716
              pop   af
              call  0x0F89
              ld    bc,0x8031
              ld    de,0x7218
              call  0x0955
              ret   z
              ld    l,0x00
              call  0x0914
              ld    a,c
              ld    (0x794F),a
              ex    de,hl
              ld    (0x7950),hl
              ld    bc,START
              ld    d,b
              ld    e,b
              ld    hl,0x0765
              push  hl
              ld    hl,0x0869
              push  hl
              push  hl
              ld    hl,0x7921
              ld    a,(hl)
              inc   hl
              or    a
              jr    z,$+38
              push  hl
              ld    l,0x08
              rra   
              ld    h,a
              ld    a,c
              jr    nc,$+13
              push  hl
              ld    hl,(0x7950)
              add   hl,de
              ex    de,hl
              pop   hl
              ld    a,(0x794F)
              adc   a,c
              rra   
              ld    c,a
              ld    a,d
              rra   
              ld    d,a
              ld    a,e
              rra   
              ld    e,a
              ld    a,b
              rra   
              ld    b,a
              dec   l
              ld    a,h
              jr    nz,$-29
              pop   hl
              ret   
              ld    b,e
              ld    e,d
              ld    d,c
              ld    c,a
              ret   
              call  0x09A4
              ld    hl,0x0DD8
              call  0x09B1
              pop   bc
              pop   de
              call  0x0955
              jp    z,0x199A
              ld    l,0xFF
              call  0x0914
              inc   (hl)
              inc   (hl)
              dec   hl
              ld    a,(hl)
              ld    (0x7889),a
              dec   hl
              ld    a,(hl)
              ld    (0x7885),a
              dec   hl
              ld    a,(hl)
              ld    (0x7881),a
              ld    b,c
              ex    de,hl
              xor   a
              ld    c,a
              ld    d,a
              ld    e,a
              ld    (0x788C),a
              push  hl
              push  bc
              ld    a,l
              call  0x7880
              sbc   a,0x00
              ccf   
              jr    nc,$+9
              ld    (0x788C),a
              pop   af
              pop   af
              scf   
              jp    nc,0xE1C1
              ld    a,c
              inc   a
              dec   a
              rra   
              jp    m,0x0797
              rla   
              ld    a,e
              rla   
              ld    e,a
              ld    a,d
              rla   
              ld    d,a
              ld    a,c
              rla   
              ld    c,a
              add   hl,hl
              ld    a,b
              rla   
              ld    b,a
              ld    a,(0x788C)
              rla   
              ld    (0x788C),a
              ld    a,c
              or    d
              or    e
              jr    nz,$-51
              push  hl
              ld    hl,0x7924
              dec   (hl)
              pop   hl
              jr    nz,$-59
              jp    0x07B2
              ld    a,0xFF
              ld    l,0xAF
              ld    hl,0x792D
              ld    c,(hl)
              inc   hl
              xor   (hl)
              ld    b,a
              ld    l,0x00
              ld    a,b
              or    a
              jr    z,$+33
              ld    a,l
              ld    hl,0x7924
              xor   (hl)
              add   a,b
              ld    b,a
              rra   
              xor   b
              ld    a,b
              jp    p,0x0936
              add   a,0x80
              ld    (hl),a
              jp    z,0x0890
              call  0x09DF
              ld    (hl),a
              dec   hl
              ret   
              call  0x0955
              cpl   
              pop   hl
              or    a
              pop   hl
              jp    p,0x0778
              jp    0x07B2
              call  0x09BF
              ld    a,b
              or    a
              ret   z
              add   a,0x02
              jp    c,0x07B2
              ld    b,a
              call  0x0716
              ld    hl,0x7924
              inc   (hl)
              ret   nz
              jp    0x07B2
              ld    a,(0x7924)
              or    a
              ret   z
              ld    a,(0x7923)
              cp    0x2F
              rla   
              sbc   a,a
              ret   nz
              inc   a
              ret   
              ld    b,0x88
              ld    de,START
              ld    hl,0x7924
              ld    c,a
              ld    (hl),b
              ld    b,0x00
              inc   hl
              ld    (hl),0x80
              rla   
              jp    0x0762
              call  0x0994
              ret   p
              rst   0x20
              jp    m,0x0C5B
              jp    z,0x0AF6
              ld    hl,0x7923
              ld    a,(hl)
              xor   0x80
              ld    (hl),a
              ret   
              call  0x0994
              ld    l,a
              rla   
              sbc   a,a
              ld    h,a
              jp    0x0A9A
              rst   0x20
              jp    z,0x0AF6
              jp    p,0x0955
              ld    hl,(0x7921)
              ld    a,h
              or    l
              ret   z
              ld    a,h
              jr    $-67
              ex    de,hl
              ld    hl,(0x7921)
              ex    (sp),hl
              push  hl
              ld    hl,(0x7923)
              ex    (sp),hl
              push  hl
              ex    de,hl
              ret   
              call  0x09C2
              ex    de,hl
              ld    (0x7921),hl
              ld    h,b
              ld    l,c
              ld    (0x7923),hl
              ex    de,hl
              ret   
              ld    hl,0x7921
              ld    e,(hl)
              inc   hl
              ld    d,(hl)
              inc   hl
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              inc   hl
              ret   
              ld    de,0x7921
              ld    b,0x04
              jr    $+7
              ex    de,hl
              ld    a,(0x78AF)
              ld    b,a
              ld    a,(de)
              ld    (hl),a
              inc   de
              inc   hl
              dec   b
              jr    nz,$-5
              ret   
              ld    hl,0x7923
              ld    a,(hl)
              rlca  
              scf   
              rra   
              ld    (hl),a
              ccf   
              rra   
              inc   hl
              inc   hl
              ld    (hl),a
              ld    a,c
              rlca  
              scf   
              rra   
              ld    c,a
              rra   
              xor   (hl)
              ret   
              ld    hl,0x7927
              ld    de,0x09D2
              jr    $+8
              ld    hl,0x7927
              ld    de,0x09D3
              push  de
              ld    de,0x7921
              rst   0x20
              ret   c
              ld    de,0x791D
              ret   
              ld    a,b
              or    a
              jp    z,0x0955
              ld    hl,0x095E
              push  hl
              call  0x0955
              ld    a,c
              ret   z
              ld    hl,0x7923
              xor   (hl)
              ld    a,c
              ret   m
              call  0x0A26
              rra   
              xor   c
              ret   
              inc   hl
              ld    a,b
              cp    (hl)
              ret   nz
              dec   hl
              ld    a,c
              cp    (hl)
              ret   nz
              dec   hl
              ld    a,d
              cp    (hl)
              ret   nz
              dec   hl
              ld    a,e
              sub   (hl)
              ret   nz
              pop   hl
              pop   hl
              ret   
              ld    a,d
              xor   h
              ld    a,h
              jp    m,0x095F
              cp    d
              jp    nz,0x0960
              ld    a,l
              sub   e
              jp    nz,0x0960
              ret   
              ld    hl,0x7927
              call  0x09D3
              ld    de,0x792E
              ld    a,(de)
              or    a
              jp    z,0x0955
              ld    hl,0x095E
              push  hl
              call  0x0955
              dec   de
              ld    a,(de)
              ld    c,a
              ret   z
              ld    hl,0x7923
              xor   (hl)
              ld    a,c
              ret   m
              inc   de
              inc   hl
              ld    b,0x08
              ld    a,(de)
              sub   (hl)
              jp    nz,0x0A23
              dec   de
              dec   hl
              dec   b
              jr    nz,$-8
              pop   bc
              ret   
              call  0x0A4F
              jp    nz,0x095E
              ret   
              rst   0x20
              ld    hl,(0x7921)
              ret   m
              jp    z,0x0AF6
              call  nc,0x0AB9
              ld    hl,0x07B2
              push  hl
              ld    a,(0x7924)
              cp    0x90
              jr    nc,$+16
              call  0x0AFB
              ex    de,hl
              pop   de
              ld    (0x7921),hl
              ld    a,0x02
              ld    (0x78AF),a
              ret   
              ld    bc,0x9080
              ld    de,START
              call  0x0A0C
              ret   nz
              ld    h,c
              ld    l,d
              jr    $-22
              rst   0x20
              ret   po
              jp    m,0x0ACC
              jp    z,0x0AF6
              call  0x09BF
              call  0x0AEF
              ld    a,b
              or    a
              ret   z
              call  0x09DF
              ld    hl,0x7920
              ld    b,(hl)
              jp    0x0796
              ld    hl,(0x7921)
              call  0x0AEF
              ld    a,h
              ld    d,l
              ld    e,0x00
              ld    b,0x90
              jp    0x0969
              rst   0x20
              ret   nc
              jp    z,0x0AF6
              call  m,0x0ACC
              ld    hl,START
              ld    (0x791D),hl
              ld    (0x791F),hl
              ld    a,0x08
              ld    bc,0x043E
              jp    0x0A9F
              rst   0x20
              ret   z
              ld    e,0x18
              jp    ERROR_HANDLER
              ld    b,a
              ld    c,a
              ld    d,a
              ld    e,a
              or    a
              ret   z
              push  hl
              call  0x09BF
              call  0x09DF
              xor   (hl)
              ld    h,a
              call  m,0x0B1F
              ld    a,0x98
              sub   b
              call  0x07D7
              ld    a,h
              rla   
              call  c,0x07A8
              ld    b,0x00
              call  c,0x07C3
              pop   hl
              ret   
              dec   de
              ld    a,d
              and   e
              inc   a
              ret   nz
              dec   bc
              ret   
              rst   0x20
              ret   m
              call  0x0955
              jp    p,0x0B37
              call  0x0982
              call  0x0B37
              jp    0x097B
              rst   0x20
              ret   m
              jr    nc,$+32
              jr    z,$-69
              call  0x0A8E
              ld    hl,0x7924
              ld    a,(hl)
              cp    0x98
              ld    a,(0x7921)
              ret   nc
              ld    a,(hl)
              call  0x0AFB
              ld    (hl),0x98
              ld    a,e
              push  af
              ld    a,c
              rla   
              call  0x0762
              pop   af
              ret   
              ld    hl,0x7924
              ld    a,(hl)
              cp    0x90
              jp    c,0x0A7F
              jr    nz,$+22
              ld    c,a
              dec   hl
              ld    a,(hl)
              xor   0x80
              ld    b,0x06
              dec   hl
              or    (hl)
              dec   b
              jr    nz,$-3
              or    a
              ld    hl,0x8000
              jp    z,0x0A9A
              ld    a,c
              cp    0xB8
              ret   nc
              push  af
              call  0x09BF
              call  0x09DF
              xor   (hl)
              dec   hl
              ld    (hl),0xB8
              push  af
              call  m,0x0BA0
              ld    hl,0x7923
              ld    a,0xB8
              sub   b
              call  0x0D69
              pop   af
              call  m,0x0D20
              xor   a
              ld    (0x791C),a
              pop   af
              ret   nc
              jp    0x0CD8
              ld    hl,0x791D
              ld    a,(hl)
              dec   (hl)
              or    a
              inc   hl
              jr    z,$-4
              ret   
              push  hl
              ld    hl,START
              ld    a,b
              or    c
              jr    z,$+20
              ld    a,0x10
              add   hl,hl
              jp    c,0x273D
              ex    de,hl
              add   hl,hl
              ex    de,hl
              jr    nc,$+6
              add   hl,bc
              jp    c,0x273D
              dec   a
              jr    nz,$-14
              ex    de,hl
              pop   hl
              ret   
              ld    a,h
              rla   
              sbc   a,a
              ld    b,a
              call  0x0C51
              ld    a,c
              sbc   a,b
              jr    $+5
              ld    a,h
              rla   
              sbc   a,a
              ld    b,a
              push  hl
              ld    a,d
              rla   
              sbc   a,a
              add   hl,de
              adc   a,b
              rrca  
              xor   h
              jp    p,0x0A99
              push  bc
              ex    de,hl
              call  0x0ACF
              pop   af
              pop   hl
              call  0x09A4
              ex    de,hl
              call  0x0C6B
              jp    0x0F8F
              ld    a,h
              or    l
              jp    z,0x0A9A
              push  hl
              push  de
              call  0x0C45
              push  bc
              ld    b,h
              ld    c,l
              ld    hl,START
              ld    a,0x10
              add   hl,hl
              jr    c,$+33
              ex    de,hl
              add   hl,hl
              ex    de,hl
              jr    nc,$+6
              add   hl,bc
              jp    c,0x0C26
              dec   a
              jr    nz,$-13
              pop   bc
              pop   de
              ld    a,h
              or    a
              jp    m,0x0C1F
              pop   de
              ld    a,b
              jp    0x0C4D
              xor   0x80
              or    l
              jr    z,$+21
              ex    de,hl
              ld    bc,0xE1C1
              call  0x0ACF
              pop   hl
              call  0x09A4
              call  0x0ACF
              pop   bc
              pop   de
              jp    0x0847
              ld    a,b
              or    a
              pop   bc
              jp    m,0x0A9A
              push  de
              call  0x0ACF
              pop   de
              jp    0x0982
              ld    a,h
              xor   d
              ld    b,a
              call  0x0C4C
              ex    de,hl
              ld    a,h
              or    a
              jp    p,0x0A9A
              xor   a
              ld    c,a
              sub   l
              ld    l,a
              ld    a,c
              sbc   a,h
              ld    h,a
              jp    0x0A9A
              ld    hl,(0x7921)
              call  0x0C51
              ld    a,h
              xor   0x80
              or    l
              ret   nz
              ex    de,hl
              call  0x0AEF
              xor   a
              ld    b,0x98
              jp    0x0969
              ld    hl,0x792D
              ld    a,(hl)
              xor   0x80
              ld    (hl),a
              ld    hl,0x792E
              ld    a,(hl)
              or    a
              ret   z
              ld    b,a
              dec   hl
              ld    c,(hl)
              ld    de,0x7924
              ld    a,(de)
              or    a
              jp    z,0x09F4
              sub   b
              jr    nc,$+24
              cpl   
              inc   a
              push  af
              ld    c,0x08
              inc   hl
              push  hl
              ld    a,(de)
              ld    b,(hl)
              ld    (hl),a
              ld    a,b
              ld    (de),a
              dec   de
              dec   hl
              dec   c
              jr    nz,$-8
              pop   hl
              ld    b,(hl)
              dec   hl
              ld    c,(hl)
              pop   af
              cp    0x39
              ret   nc
              push  af
              call  0x09DF
              inc   hl
              ld    (hl),0x00
              ld    b,a
              pop   af
              ld    hl,0x792D
              call  0x0D69
              ld    a,(0x7926)
              ld    (0x791C),a
              ld    a,b
              or    a
              jp    p,0x0CCF
              call  0x0D33
              jp    nc,0x0D0E
              ex    de,hl
              inc   (hl)
              jp    z,0x07B2
              call  0x0D90
              jp    0x0D0E
              call  0x0D45
              ld    hl,0x7925
              call  c,0x0D57
              xor   a
              ld    b,a
              ld    a,(0x7923)
              or    a
              jr    nz,$+32
              ld    hl,0x791C
              ld    c,0x08
              ld    d,(hl)
              ld    (hl),a
              ld    a,d
              inc   hl
              dec   c
              jr    nz,$-5
              ld    a,b
              sub   0x08
              cp    0xC0
              jr    nz,$-24
              jp    0x0778
              dec   b
              ld    hl,0x791C
              call  0x0D97
              or    a
              jp    p,0x0CF6
              ld    a,b
              or    a
              jr    z,$+11
              ld    hl,0x7924
              add   a,(hl)
              ld    (hl),a
              jp    nc,0x0778
              ret   z
              ld    a,(0x791C)
              or    a
              call  m,0x0D20
              ld    hl,0x7925
              ld    a,(hl)
              and   0x80
              dec   hl
              dec   hl
              xor   (hl)
              ld    (hl),a
              ret   
              ld    hl,0x791D
              ld    b,0x07
              inc   (hl)
              ret   nz
              inc   hl
              dec   b
              jr    nz,$-4
              inc   (hl)
              jp    z,0x07B2
              dec   hl
              ld    (hl),0x80
              ret   
              ld    hl,0x7927
              ld    de,0x791D
              ld    c,0x07
              xor   a
              ld    a,(de)
              adc   a,(hl)
              ld    (de),a
              inc   de
              inc   hl
              dec   c
              jr    nz,$-6
              ret   
              ld    hl,0x7927
              ld    de,0x791D
              ld    c,0x07
              xor   a
              ld    a,(de)
              sbc   a,(hl)
              ld    (de),a
              inc   de
              inc   hl
              dec   c
              jr    nz,$-6
              ret   
              ld    a,(hl)
              cpl   
              ld    (hl),a
              ld    hl,0x791C
              ld    b,0x08
              xor   a
              ld    c,a
              ld    a,c
              sbc   a,(hl)
              ld    (hl),a
              inc   hl
              dec   b
              jr    nz,$-5
              ret   
              ld    (hl),c
              push  hl
              sub   0x08
              jr    c,$+16
              pop   hl
              push  hl
              ld    de,0x0800
              ld    c,(hl)
              ld    (hl),e
              ld    e,c
              dec   hl
              dec   d
              jr    nz,$-5
              jr    $-16
              add   a,0x09
              ld    d,a
              xor   a
              pop   hl
              dec   d
              ret   z
              push  hl
              ld    e,0x08
              ld    a,(hl)
              rra   
              ld    (hl),a
              dec   hl
              dec   e
              jr    nz,$-5
              jr    $-14
              ld    hl,0x7923
              ld    d,0x01
              jr    $-17
              ld    c,0x08
              ld    a,(hl)
              rla   
              ld    (hl),a
              inc   hl
              dec   c
              jr    nz,$-5
              ret   
              call  0x0955
              ret   z
              call  0x090A
              call  0x0E39
              ld    (hl),c
              inc   de
              ld    b,0x07
              ld    a,(de)
              inc   de
              or    a
              push  de
              jr    z,$+25
              ld    c,0x08
              push  bc
              rra   
              ld    b,a
              call  c,0x0D33
              call  0x0D90
              ld    a,b
              pop   bc
              dec   c
              jr    nz,$-12
              pop   de
              dec   b
              jr    nz,$-24
              jp    0x0CD8
              ld    hl,0x7923
              call  0x0D70
              jr    $-13
              nop   
              nop   
              nop   
              nop   
              nop   
              nop   
              jr    nz,$-122
              ld    de,0x0DD4
              ld    hl,0x7927
              call  0x09D3
              ld    a,(0x792E)
              or    a
              jp    z,0x199A
              call  0x0907
              inc   (hl)
              inc   (hl)
              call  0x0E39
              ld    hl,0x7951
              ld    (hl),c
              ld    b,c
              ld    de,0x794A
              ld    hl,0x7927
              call  0x0D4B
              ld    a,(de)
              sbc   a,c
              ccf   
              jr    c,$+13
              ld    de,0x794A
              ld    hl,0x7927
              call  0x0D39
              xor   a
              jp    c,0x0412
              ld    a,(0x7923)
              inc   a
              dec   a
              rra   
              jp    m,0x0D11
              rla   
              ld    hl,0x791D
              ld    c,0x07
              call  0x0D99
              ld    hl,0x794A
              call  0x0D97
              ld    a,b
              or    a
              jr    nz,$-53
              ld    hl,0x7924
              dec   (hl)
              jr    nz,$-59
              jp    0x07B2
              ld    a,c
              ld    (0x792D),a
              dec   hl
              ld    de,0x7950
              ld    bc,0x0700
              ld    a,(hl)
              ld    (de),a
              ld    (hl),c
              dec   de
              dec   hl
              dec   b
              jr    nz,$-6
              ret   
              call  0x09FC
              ex    de,hl
              dec   hl
              ld    a,(hl)
              or    a
              ret   z
              add   a,0x02
              jp    c,0x07B2
              ld    (hl),a
              push  hl
              call  0x0C77
              pop   hl
              inc   (hl)
              ret   nz
              jp    0x07B2
              call  0x0778
              call  0x0AEC
              or    0xAF
              ex    de,hl
              ld    bc,0x00FF
              ld    h,b
              ld    l,b
              call  z,0x0A9A
              ex    de,hl
              ld    a,(hl)
              cp    0x2D
              push  af
              jp    z,0x0E83
              cp    0x2B
              jr    z,$+3
              dec   hl
              rst   0x10
              jp    c,0x0F29
              cp    0x2E
              jp    z,0x0EE4
              cp    0x45
              jr    z,$+22
              cp    0x25
              jp    z,0x0EEE
              cp    0x23
              jp    z,0x0EF5
              cp    0x21
              jp    z,0x0EF6
              cp    0x44
              jr    nz,$+38
              or    a
              call  0x0EFB
              push  hl
              ld    hl,0x0EBD
              ex    (sp),hl
              rst   0x10
              dec   d
              cp    0xCE
              ret   z
              cp    0x2D
              ret   z
              inc   d
              cp    0xCD
              ret   z
              cp    0x2B
              ret   z
              dec   hl
              pop   af
              rst   0x10
              jp    c,0x0F94
              inc   d
              jr    nz,$+5
              xor   a
              sub   e
              ld    e,a
              push  hl
              ld    a,e
              sub   b
              call  p,0x0F0A
              call  m,0x0F18
              jr    nz,$-6
              pop   hl
              pop   af
              push  hl
              call  z,0x097B
              pop   hl
              rst   0x20
              ret   pe
              push  hl
              ld    hl,0x0890
              push  hl
              call  0x0AA3
              ret   
              rst   0x20
              inc   c
              jr    nz,$-31
              call  c,0x0EFB
              jp    0x0E83
              rst   0x20
              jp    p,0x1997
              inc   hl
              jr    $-44
              or    a
              call  0x0EFB
              jr    $-7
              push  hl
              push  de
              push  bc
              push  af
              call  z,0x0AB1
              pop   af
              call  nz,0x0ADB
              pop   bc
              pop   de
              pop   hl
              ret   
              ret   z
              push  af
              rst   0x20
              push  af
              call  po,0x093E
              pop   af
              call  pe,0x0E4D
              pop   af
              dec   a
              ret   
              push  de
              push  hl
              push  af
              rst   0x20
              push  af
              call  po,0x0897
              pop   af
              call  pe,0x0DDC
              pop   af
              pop   hl
              pop   de
              inc   a
              ret   
              push  de
              ld    a,b
              adc   a,c
              ld    b,a
              push  bc
              push  hl
              ld    a,(hl)
              sub   0x30
              push  af
              rst   0x20
              jp    p,0x0F5D
              ld    hl,(0x7921)
              ld    de,0x0CCD
              rst   0x18
              jr    nc,$+27
              ld    d,h
              ld    e,l
              add   hl,hl
              add   hl,hl
              add   hl,de
              add   hl,hl
              pop   af
              ld    c,a
              add   hl,bc
              ld    a,h
              or    a
              jp    m,0x0F57
              ld    (0x7921),hl
              pop   hl
              pop   bc
              pop   de
              jp    0x0E83
              ld    a,c
              push  af
              call  0x0ACC
              scf   
              jr    nc,$+26
              ld    bc,0x9474
              ld    de,0x2400
              call  0x0A0C
              jp    p,0x0F74
              call  0x093E
              pop   af
              call  0x0F89
              jr    $-33
              call  0x0AE3
              call  0x0E4D
              call  0x09FC
              pop   af
              call  0x0964
              call  0x0AE3
              call  0x0C77
              jr    $-54
              call  0x09A4
              call  0x0964
              pop   bc
              pop   de
              jp    0x0716
              ld    a,e
              cp    0x0A
              jr    nc,$+11
              rlca  
              rlca  
              add   a,e
              rlca  
              add   a,(hl)
              sub   0x30
              ld    e,a
              jp    m,0x321E
              jp    0x0EBD
              push  hl
              ld    hl,0x1924
              call  OUTSTR
              pop   hl
              call  0x0A9A
              xor   a
              call  0x1034
              or    (hl)
              call  0x0FD9
              jp    0x28A6
              xor   a
              call  0x1034
              and   0x08
              jr    z,$+4
              ld    (hl),0x2B
              ex    de,hl
              call  0x0994
              ex    de,hl
              jp    p,0x0FD9
              ld    (hl),0x2D
              push  bc
              push  hl
              call  0x097B
              pop   hl
              pop   bc
              or    h
              inc   hl
              ld    (hl),0x30
              ld    a,(0x78D8)
              ld    d,a
              rla   
              ld    a,(0x78AF)
              jp    c,0x109A
              jp    z,0x1092
              cp    0x04
              jp    nc,0x103D
              ld    bc,START
              call  0x132F
              ld    hl,0x7930
              ld    b,(hl)
              ld    c,0x20
              ld    a,(0x78D8)
              ld    e,a
              and   0x20
              jr    z,$+9
              ld    a,b
              cp    c
              ld    c,0x2A
              jr    nz,$+3
              ld    b,c
              ld    (hl),c
              rst   0x10
              jr    z,$+22
              cp    0x45
              jr    z,$+18
              cp    0x44
              jr    z,$+14
              cp    0x30
              jr    z,$-14
              cp    0x2C
              jr    z,$-18
              cp    0x2E
              jr    nz,$+5
              dec   hl
              ld    (hl),0x30
              ld    a,e
              and   0x10
              jr    z,$+5
              dec   hl
              ld    (hl),0x24
              ld    a,e
              and   0x04
              ret   nz
              dec   hl
              ld    (hl),b
              ret   
              ld    (0x78D8),a
              ld    hl,0x7930
              ld    (hl),0x20
              ret   
              cp    0x05
              push  hl
              sbc   a,0x00
              rla   
              ld    d,a
              inc   d
              call  0x1201
              ld    bc,0x0300
              add   a,d
              jp    m,0x1057
              inc   d
              cp    d
              jr    nc,$+6
              inc   a
              ld    b,a
              ld    a,0x02
              sub   0x02
              pop   hl
              push  af
              call  0x1291
              ld    (hl),0x30
              call  z,0x09C9
              call  0x12A4
              dec   hl
              ld    a,(hl)
              cp    0x30
              jr    z,$-4
              cp    0x2E
              call  nz,0x09C9
              pop   af
              jr    z,$+33
              push  af
              rst   0x20
              ld    a,0x22
              adc   a,a
              ld    (hl),a
              inc   hl
              pop   af
              ld    (hl),0x2B
              jp    p,0x1085
              ld    (hl),0x2D
              cpl   
              inc   a
              ld    b,0x2F
              inc   b
              sub   0x0A
              jr    nc,$-3
              add   a,0x3A
              inc   hl
              ld    (hl),b
              inc   hl
              ld    (hl),a
              inc   hl
              ld    (hl),0x00
              ex    de,hl
              ld    hl,0x7930
              ret   
              inc   hl
              push  bc
              cp    0x04
              ld    a,d
              jp    nc,0x1109
              rra   
              jp    c,0x11A3
              ld    bc,0x0603
              call  0x1289
              pop   de
              ld    a,d
              sub   0x05
              call  p,0x1269
              call  0x132F
              ld    a,e
              or    a
              call  z,0x092F
              dec   a
              call  p,0x1269
              push  hl
              call  0x0FF5
              pop   hl
              jr    z,$+4
              ld    (hl),b
              inc   hl
              ld    (hl),0x00
              ld    hl,0x792F
              inc   hl
              ld    a,(0x78F3)
              sub   l
              sub   d
              ret   z
              ld    a,(hl)
              cp    0x20
              jr    z,$-10
              cp    0x2A
              jr    z,$-14
              dec   hl
              push  hl
              push  af
              ld    bc,0x10DF
              push  bc
              rst   0x10
              cp    0x2D
              ret   z
              cp    0x2B
              ret   z
              cp    0x24
              ret   z
              pop   bc
              cp    0x30
              jr    nz,$+17
              inc   hl
              rst   0x10
              jr    nc,$+13
              dec   hl
              ld    bc,0x772B
              pop   af
              jr    z,$-3
              pop   bc
              jp    0x10CE
              pop   af
              jr    z,$-1
              pop   hl
              ld    (hl),0x25
              ret   
              push  hl
              rra   
              jp    c,0x11AA
              jr    z,$+22
              ld    de,0x1384
              call  0x0A49
              ld    d,0x10
              jp    m,0x1132
              pop   hl
              pop   bc
              call  0x0FBD
              dec   hl
              ld    (hl),0x25
              ret   
              ld    bc,0xB60E
              ld    de,0x1BCA
              call  0x0A0C
              jp    p,0x111B
              ld    d,0x06
              call  0x0955
              call  nz,0x1201
              pop   hl
              pop   bc
              jp    m,0x1157
              push  bc
              ld    e,a
              ld    a,b
              sub   d
              sub   e
              call  p,0x1269
              call  0x127D
              call  0x12A4
              or    e
              call  nz,0x1277
              or    e
              call  nz,0x1291
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
              call  m,0x0F18
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
              call  p,0x1269
              push  bc
              call  0x127D
              jr    $+19
              call  0x1269
              ld    a,c
              call  0x1294
              ld    c,a
              xor   a
              sub   d
              sub   e
              call  0x1269
              push  bc
              ld    b,a
              ld    c,a
              call  0x12A4
              pop   bc
              or    c
              jr    nz,$+5
              ld    hl,(0x78F3)
              add   a,e
              dec   a
              call  p,0x1269
              ld    d,b
              jp    0x10BF
              push  hl
              push  de
              call  0x0ACC
              pop   de
              xor   a
              jp    z,0x11B0
              ld    e,0x10
              ld    bc,0x061E
              call  0x0955
              scf   
              call  nz,0x1201
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
              call  m,0x0F18
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
              call  0x12A4
              pop   af
              call  p,0x1271
              pop   bc
              pop   af
              call  z,0x092F
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
              ld    a,(0x7924)
              cp    0x91
              jp    nc,0x1222
              ld    de,0x1364
              ld    hl,0x7927
              call  0x09D3
              call  0x0DA1
              pop   af
              sub   0x0A
              push  af
              jr    $-24
              call  0x124F
              rst   0x20
              jp    pe,0x1234
              ld    bc,0x9143
              ld    de,0x4FF9
              call  0x0A0C
              jr    $+8
              ld    de,0x136C
              call  0x0A49
              jp    p,0x124C
              pop   af
              call  0x0F0B
              push  af
              jr    $-29
              pop   af
              call  0x0F18
              push  af
              call  0x124F
              pop   af
              pop   de
              ret   
              rst   0x20
              jp    pe,0x125E
              ld    bc,0x9474
              ld    de,0x23F8
              call  0x0A0C
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
              call  0x1291
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
              ld    a,(0x78D8)
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
              call  0x09FC
              ld    hl,0x137C
              call  0x09F7
              call  0x0C77
              xor   a
              call  0x0B7B
              pop   hl
              pop   bc
              ld    de,0x138C
              ld    a,0x0A
              call  0x1291
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
              call  0x09B1
              jr    $+14
              push  bc
              push  hl
              call  0x0708
              inc   a
              call  0x0AFB
              call  0x09B4
              pop   hl
              pop   bc
              xor   a
              ld    de,0x13D2
              ccf   
              call  0x1291
              push  bc
              push  af
              push  hl
              push  de
              call  0x09BF
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
              call  0x09B4
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
              call  0x1291
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
              ld    hl,(0x7921)
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
              ld    (0x7921),hl
              pop   de
              pop   hl
              ld    (hl),b
              inc   hl
              pop   af
              pop   bc
              dec   a
              jr    nz,$-39
              call  0x1291
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
              call  0x09A4
              ld    hl,0x1380
              call  0x09B1
              jr    $+5
              call  0x0AB1
              pop   bc
              pop   de
              call  0x0955
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
              call  0x09BF
              jp    p,0x1421
              push  de
              push  bc
              call  0x0B40
              pop   bc
              pop   de
              push  af
              call  0x0A0C
              pop   hl
              ld    a,h
              rra   
              pop   hl
              ld    (0x7923),hl
              pop   hl
              ld    (0x7921),hl
              call  c,0x13E2
              call  z,0x0982
              push  de
              push  bc
              call  0x0809
              pop   bc
              pop   de
              call  0x0847
              call  0x09A4
              ld    bc,0x8138
              ld    de,0xAA3B
              call  0x0847
              ld    a,(0x7924)
              cp    0x88
              jp    nc,0x0931
              call  0x0B40
              add   a,0x80
              add   a,0x02
              jp    c,0x0931
              push  af
              ld    hl,0x07F8
              call  0x070B
              call  0x0841
              pop   af
              pop   bc
              pop   de
              push  af
              call  0x0713
              call  0x0982
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
              call  0x09A4
              ld    de,0x0C32
              push  de
              push  hl
              call  0x09BF
              call  0x0847
              pop   hl
              call  0x09A4
              ld    a,(hl)
              inc   hl
              call  0x09B1
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
              call  0x09C2
              push  hl
              call  0x0716
              pop   hl
              jr    $-21
              call  0x0A7F
              ld    a,h
              or    a
              jp    m,0x1E4A
              or    l
              jp    z,0x14F0
              push  hl
              call  0x14F0
              call  0x09BF
              ex    de,hl
              ex    (sp),hl
              push  bc
              call  0x0ACF
              pop   bc
              pop   de
              call  0x0847
              ld    hl,0x07F8
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
              call  0x0AEF
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
              call  0x09A4
              ld    bc,0x8349
              ld    de,0x0FDB
              call  0x09B4
              pop   bc
              pop   de
              call  0x08A2
              call  0x09A4
              call  0x0B40
              pop   bc
              pop   de
              call  0x0713
              ld    hl,0x158F
              call  0x0710
              call  0x0955
              scf   
              jp    p,0x1577
              call  0x0708
              call  0x0955
              or    a
              push  af
              call  p,0x0982
              ld    hl,0x158F
              call  0x070B
              pop   af
              call  nc,0x0982
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
              call  0x09A4
              call  0x1547
              pop   bc
              pop   hl
              call  0x09A4
              ex    de,hl
              call  0x09B4
              call  0x1541
              jp    0x08A0
              call  0x0955
              call  m,0x13E2
              call  m,0x0982
              ld    a,(0x7924)
              cp    0x81
              jr    c,$+14
              ld    bc,0x8100
              ld    d,c
              ld    e,c
              call  0x08A2
              ld    hl,0x0710
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
              call  0x032A
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
              jp    z,0x0674
              ld    a,h
              and   l
              inc   a
              call  nz,0x0FA7
              ld    a,0xC1
              call  0x038B
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
              call  0x0FAF
              ld    a,0x20
              call  0x032A
              pop   de
              push  de
              call  0x1B2C
              call  c,0x2E53
              nop   
              call  0x03E3
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
              call  0x03E3
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
              call  z,0x09C9
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
              call  0x038B
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
              call  0x032A
              ld    a,0x20
              call  0x032A
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
              jp    z,0x0AF6
              jp    nc,0x0AF6
              push  af
              call  0x2337
              pop   af
              push  hl
              jp    p,0x1CEC
              call  0x0A7F
              ex    (sp),hl
              ld    de,0x0001
              ld    a,(hl)
              cp    0xCC
              call  z,0x2B01
              push  de
              push  hl
              ex    de,hl
              call  0x099E
              jr    $+36
              call  0x0AB1
              call  0x09BF
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
              call  0x0AB1
              call  0x09BF
              call  0x0955
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
              call  0x0358
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
              call  0x032A
              call  0x0FAF
              ld    a,0x3E
              call  0x032A
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
              call  0x0358
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
              call  0x038B
              call  0x20F9
              pop   af
              ld    hl,0x1930
              jp    nz,0x1A06
              jp    0x1A18
              ld    hl,(0x78F7)
              ld    a,h
              or    l
              ld    e,0x20
              jp    z,ERROR_HANDLER
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
              jp    ERROR_HANDLER
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
              jp    ERROR_HANDLER
              ret   nz
              ld    d,0xFF
              call  0x1936
              ld    sp,hl
              ld    (0x78E8),hl
              cp    0x91
              ld    e,0x04
              jp    nz,ERROR_HANDLER
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
              call  0x0A03
              push  hl
              jr    nz,$+42
              ld    hl,(0x7921)
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
              call  0x09D3
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
              jp    ERROR_HANDLER
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
              call  0x0994
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
              call  0x0FBD
              call  0x2865
              call  0x79CD
              ld    hl,(0x7921)
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
              call  0x032A
              or    a
              call  z,0x28AA
              pop   hl
              jp    0x209B
              call  0x3B1C
              or    a
              ret   z
              ld    a,0x0D
              call  0x032A
              call  0x79D0
              xor   a
              ret   
              call  0x79D3
              ld    a,(0x789C)
              or    a
              jp    p,0x2119
              ld    a,0x2C
              call  0x032A
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
              call  0x032A
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
              jp    z,ERROR_HANDLER
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
              jp    z,ERROR_HANDLER
              ld    a,0x3F
              call  0x032A
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
              jp    c,0x0E6C
              jp    nc,0x0E65
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
              jp    z,ERROR_HANDLER
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
              call  0x09B1
              ex    (sp),hl
              push  hl
              call  0x070B
              pop   hl
              call  0x09CB
              pop   hl
              call  0x09C2
              push  hl
              call  0x0A0C
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
              call  0x0BD2
              ld    a,(0x78AF)
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
              call  0x0A39
              pop   hl
              pop   bc
              sub   b
              call  0x09C2
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
              ld    (0x78D8),hl
              rst   0x10
              jr    $-21
              ld    a,d
              or    a
              jp    nz,0x23EC
              ld    a,(hl)
              ld    (0x78D8),hl
              sub   0xCD
              ret   c
              cp    0x07
              ret   nc
              ld    e,a
              ld    a,(0x78AF)
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
              ld    hl,0x7921
              or    a
              ld    a,(0x78AF)
              dec   a
              dec   a
              dec   a
              jp    z,0x0AF6
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
              ld    hl,(0x78D8)
              jp    0x233A
              call  0x0AB1
              call  0x09A4
              ld    bc,0x13F2
              ld    d,0x7F
              jr    $-18
              push  de
              call  0x0A7F
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
              ld    hl,(0x7921)
              push  hl
              ld    bc,0x258C
              jr    $-55
              pop   bc
              ld    a,c
              ld    (0x78B0),a
              ld    a,b
              cp    0x08
              jr    z,$+42
              ld    a,(0x78AF)
              cp    0x08
              jp    z,0x2460
              ld    d,a
              ld    a,b
              cp    0x04
              jp    z,0x2472
              ld    a,d
              cp    0x03
              jp    z,0x0AF6
              jp    nc,0x247C
              ld    hl,0x18BF
              ld    b,0x00
              add   hl,bc
              add   hl,bc
              ld    c,(hl)
              inc   hl
              ld    b,(hl)
              pop   de
              ld    hl,(0x7921)
              push  bc
              ret   
              call  0x0ADB
              call  0x09FC
              pop   hl
              ld    (0x791F),hl
              pop   hl
              ld    (0x791D),hl
              pop   bc
              pop   de
              call  0x09B4
              call  0x0ADB
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
              call  0x09FC
              pop   af
              ld    (0x78AF),a
              cp    0x04
              jr    z,$-36
              pop   hl
              ld    (0x7921),hl
              jr    $-37
              call  0x0AB1
              pop   bc
              pop   de
              ld    hl,0x18B5
              jr    $-41
              pop   hl
              call  0x09A4
              call  0x0ACF
              call  0x09BF
              pop   hl
              ld    (0x7923),hl
              pop   hl
              ld    (0x7921),hl
              jr    $-23
              push  hl
              ex    de,hl
              call  0x0ACF
              pop   hl
              call  0x09A4
              call  0x0ACF
              jp    0x08A0
              rst   0x10
              ld    e,0x28
              jp    z,ERROR_HANDLER
              jp    c,0x0E6C
              call  0x1E3D
              jp    nc,0x2540
              cp    0xCD
              jr    z,$-17
              cp    0x2E
              jp    z,0x0E6C
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
              call  0x0C66
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
              call  0x0A9A
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
              jp    z,0x0132
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
              call  0x097B
              pop   hl
              ret   
              call  0x260D
              push  hl
              ex    de,hl
              ld    (0x7921),hl
              rst   0x20
              call  nz,0x09F7
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
              call  0x0AF4
              ex    de,hl
              ld    hl,(0x7921)
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
              call  c,0x0AB1
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
              jp    0x0960
              inc   a
              adc   a,a
              pop   bc
              and   b
              add   a,0xFF
              sbc   a,a
              call  0x098D
              jr    $+20
              ld    d,0x5A
              call  0x233A
              call  0x0A7F
              ld    a,l
              cpl   
              ld    l,a
              ld    a,h
              cpl   
              ld    h,a
              ld    (0x7921),hl
              pop   bc
              jp    0x2346
              ld    a,(0x78AF)
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
              call  0x0A7F
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
              ld    (0x78AF),a
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
              ld    (0x7924),a
              pop   bc
              ld    h,a
              ld    l,a
              ld    (0x7921),hl
              rst   0x20
              jr    nz,$+8
              ld    hl,0x1928
              ld    (0x7921),hl
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
              ld    a,(0x78AF)
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
              call  0x1963
              inc   hl
              inc   hl
              ld    (0x78D8),hl
              ld    (hl),c
              inc   hl
              ld    a,(0x78AE)
              rla   
              ld    a,c
              ld    bc,0x000B
              jr    nc,$+4
              pop   bc
              inc   bc
              ld    (hl),c
              inc   hl
              ld    (hl),b
              inc   hl
              push  af
              call  0x0BAA
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
              ld    hl,(0x78D8)
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
              call  0x0BAA
              add   hl,de
              pop   af
              dec   a
              ld    b,h
              ld    c,l
              jr    nz,$-19
              ld    a,(0x78AF)
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
              ld    (0x78AF),a
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
              jp    0x0C66
              ld    a,(0x78A6)
              ld    l,a
              xor   a
              ld    h,a
              jp    0x0A9A
              call  0x79A9
              rst   0x10
              call  0x252C
              push  hl
              ld    hl,0x0890
              push  hl
              ld    a,(0x78AF)
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
              call  0x0FBD
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
              ld    (0x7921),hl
              ld    a,0x03
              ld    (0x78AF),a
              call  0x09D3
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
              call  0x09C4
              inc   d
              dec   d
              ret   z
              ld    a,(bc)
              call  0x032A
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
              call  0x09C2
              push  hl
              add   hl,bc
              cp    0x03
              jr    nz,$-19
              ld    (0x78D8),hl
              pop   hl
              ld    c,(hl)
              ld    b,0x00
              add   hl,bc
              add   hl,bc
              inc   hl
              ex    de,hl
              ld    hl,(0x78D8)
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
              ld    hl,(0x7921)
              ex    (sp),hl
              call  0x249F
              ex    (sp),hl
              call  0x0AF4
              ld    a,(hl)
              push  hl
              ld    hl,(0x7921)
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
              call  0x0AF4
              ld    hl,(0x7921)
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
              call  0x0E65
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
              call  0x0A7F
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
              call  0x0FAF
              ld    a,0x20
              pop   hl
              call  0x032A
              call  0x2B7E
              ld    hl,(0x78A7)
              call  0x2B75
              call  0x20FE
              jr    $-64
              ld    a,(hl)
              or    a
              ret   z
              call  0x032A
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
              ld    hl,0x02CF
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
              ld    hl,0x02AF
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
              call  0x0A7F
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
              call  0x0AF4
              rst   8
              dec   sp
              ex    de,hl
              ld    hl,(0x7921)
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
              call  0x032A
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
              call  0x0FBE
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
              call  0x032A
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
              call  0x0AF4
              pop   bc
              push  bc
              push  hl
              ld    hl,(0x7921)
              ld    b,c
              ld    c,0x00
              push  bc
              call  0x2A68
              call  0x28AA
              ld    hl,(0x7921)
              pop   af
              sub   (hl)
              ld    b,a
              ld    a,0x20
              inc   b
              dec   b
              jp    z,0x2DD3
              call  0x032A
              jr    $-7
              push  af
              ld    a,d
              or    a
              ld    a,0x2B
              call  nz,0x032A
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
              jp    nz,0x05D7
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
              ld    hl,0x01D9
              ld    c,a
              ld    b,0x00
              ld    a,(0x68FB)
              bit   2,a
              jr    nz,$+12
              ld    hl,0x7838
              set   0,(hl)
              ld    hl,0x0209
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
              ld    hl,0x0269
              jr    $+21
              ld    a,(0x68BF)
              bit   2,a
              jr    nz,$+9
              set   2,(hl)
              xor   a
              ld    (0x783A),a
              ret   
              res   2,(hl)
              ld    hl,0x0239
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
              ld    hl,0x0299
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
              call  0x030D
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
              call  0x030D
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
              call  0x0317
              push  hl
              call  0x33F3
              pop   hl
              call  0x0317
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
              call  0x098D
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
              call  0x05C9
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
              call  0x032A
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
              jp    0x03E3
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
