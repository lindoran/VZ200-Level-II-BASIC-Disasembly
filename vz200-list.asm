; ------------------------------------------------------------
; Listing processed by z80fmt (C version)
; ------------------------------------------------------------

; z80dasm 1.1.6

; command line: z80dasm -a -l -t -g0x0000 ./vz200.rom



	org	00000h



0000:  f3            RESET:       di               ;disable interrupts
0001:  af            l0001h:      xor a            ;clear A register (faster than ld a,0)
0002:  32 00 68                   ld (IOREG),a     ;clear I/O Register
0005:  c3 74 06      l0005h:      jp BASINIT1      ;Jump to Basic init 1 at 0674h
0008:  c3 00 78      HNDLRES08:   jp RESET08
000B:  e1            l000bh:      pop hl
000C:  e9                         jp (hl)
000D:  00                         nop
000E:  00            l000eh:      nop
000F:  00            l000fh:      nop
0010:  c3 03 78                   jp RESET10
0013:  c5            l0013h:      push bc
0014:  06 01                      ld b,001h
0016:  18 2e                      jr l0046h
0018:  c3 06 78                   jp RESET18
001B:  c5            l001bh:      push bc
001C:  06 02                      ld b,002h
001E:  18 26         l001eh:      jr l0046h
0020:  c3 09 78      l0020h:      jp RESET20
0023:  c5                         push bc
0024:  06 04                      ld b,004h
0026:  18 1e                      jr l0046h
0028:  c3 0c 78      l0028h:      jp RESET28
002B:  11 15 78      sub_002bh:   ld de,07815h
002E:  18 e3                      jr l0013h
0030:  c3 0f 78                   jp RESET30
0033:  11 1d 78      l0033h:      ld de,0781dh
0036:  18 e3         l0036h:      jr l001bh
0038:  c3 b8 2e                   jp SYSIHAND
003B:  11 25 78      sub_003bh:   ld de,07825h
003E:  18 db                      jr l001bh
0040:  c3 fd 2e      l0040h:      jp ONEKBSCAN
0043:  c9                         ret
0044:  00                         nop
0045:  00                         nop
0046:  c3 c2 03      l0046h:      jp l03c2h
0049:  cd 2b 00      KBGET:       call sub_002bh
004C:  b7                         or a
004D:  c0                         ret nz
004E:  18 f9                      jr KBGET
0050:  2a 20 78      SCRGET:      ld hl,(CURPOS)
0053:  7e            sub_0053h:   ld a,(hl)
0054:  32 3c 78                   ld (0783ch),a
0057:  c9                         ret
0058:  4c                         ld c,h
0059:  fe 54                      cp 054h
005B:  20 d6                      jr nz,l0033h
005D:  fd 21 f1                   ld iy,00bf1h
0061:  78                         ld a,b
0062:  b1                         or c
0063:  20 fb                      jr nz,$-3
0065:  c9                         ret
0066:  31 00 06                   ld sp,00600h
0069:  3a ec 68                   ld a,(068ech)
006C:  3c                         inc a
006D:  fe 02                      cp 002h
006F:  d2 00 00                   jp nc,RESET
0072:  c3 cc 06                   jp l06cch

;*******************************************************************************
;*Basic init 2                                                                 *
;*75h                                                                          * 
;*******************************************************************************

; io copy
0075:  11 80 78      BASINIT2:    ld de,07880h     ;Subroutines for Divide, Out, Inp In RAM
0078:  21 f7 18                   ld hl,l18f7h     ;Subroutines for Divide, Out, Inp in ROM
007B:  01 27 00                   ld bc,00027h     ;copy 27h bytes (39 bytes)
007E:  ed b0                      ldir
0080:  21 e5 79                   ld hl,079e5h     ; Start of IO Buffer
0083:  36 3a                      ld (hl),03ah     ; Character ':'
0085:  23                         inc hl
0086:  70                         ld (hl),b        ; B = 0 after block copy
0087:  23                         inc hl
0088:  36 2c                      ld (hl),02ch     ; Character ','
008A:  23                         inc hl
008B:  22 a7 78                   ld (078a7h),hl   ; Store IO buffer address (79E8H)

; Disk – manually assemble default disk‑command vectors in RAM
008E:  11 2d 01                   ld de,l012d      ; Address of the default "Disk Command Error" handler
0091:  06 1c                      ld b,01ch        ; Number of disk command vectors to initialize (28 entries)
0093:  21 52 79                   ld hl,07952h     ; Start of the disk command vector table in RAM
0096:  36 c3         l0096h:      ld (hl),0c3h     ; Write opcode for JP, 0C3h
0098:  23                         inc hl		
0099:  73                         ld (hl),e        ; Low byte of jp target address 2dh
009A:  23                         inc hl
009B:  72                         ld (hl),d        ; High byte of jp target address 01h
009C:  23                         inc hl           ; advance to next vector set
009D:  10 f7                      djnz l0096h      ; repeat until all vectors contain the jp instruction

; BASIC – manually assemble command extension vector slots with default RET instructions
009F:  06 15                      ld b,015h        ; Number of extension slots to initialize (21 entries)
00A1:  36 c9         l00a1h:      ld (hl),0c9h     ; Store RET opcode (C9h) in current slot
00A3:  23                         inc hl           ; 3 bytes per slot (opcode + 2 byte address)
00A4:  23                         inc hl
00A5:  23                         inc hl
00A6:  10 f9                      djnz l00a1h      ; repeat until all slots contain the ret instruction

; BASIC - finalize startup state and prepare exicution envioronment  
00A8:  21 e8 7a                   ld hl,07ae8h     ; Mark program start location
00AB:  70                         ld (hl),b        ; Store 00h at 7AE8h (B was 00h from last djnz)
00AC:  31 f8 79                   ld sp,079f8h     ; set up stack pointer at top of basic RAM Work Area
00AF:  cd 8f 1b                   call INITRT      ; init runtime enviornment from NEW command
00B2:  cd c9 01                   call CLRSCR      ; clear screen (TODO: pick up from here)
00B5:  00            l00b5h:      nop              ; artifact from Level II Basic (also delay of 13.4uS)
00B6:  00                         nop
00B7:  00                         nop
00B8:  00                         nop
00B9:  00                         nop
00BA:  00                         nop
00BB:  00                         nop
00BC:  00                         nop
00BD:  00                         nop
00BE:  18 04                      jr l00c4h

; unreachable data level II BASIC artifact
00C0:  d7 b7 20 12                db 0D7h,0B7h,020h,012h


00C4:  21 4c 7b      l00c4h:      ld hl,07b4ch
00C7:  23            l00c7h:      inc hl
00C8:  7c                         ld a,h
00C9:  b5                         or l
00CA:  28 1b                      jr z,l00e7h
00CC:  7e                         ld a,(hl)
00CD:  47                         ld b,a
00CE:  2f                         cpl
00CF:  77                         ld (hl),a
00D0:  be                         cp (hl)
00D1:  70                         ld (hl),b
00D2:  28 f3                      jr z,l00c7h
00D4:  18 11                      jr l00e7h
00D6:  cd 5a 1e      l00d6h:      call sub_1e5ah
00D9:  b7                         or a
00DA:  c2 97 19                   jp nz,l1997h
00DD:  eb                         ex de,hl
00DE:  2b                         dec hl
00DF:  3e 8f                      ld a,08fh
00E1:  46                         ld b,(hl)
00E2:  77                         ld (hl),a
00E3:  be                         cp (hl)
00E4:  70                         ld (hl),b
00E5:  20 ce                      jr nz,l00b5h
00E7:  2b            l00e7h:      dec hl
00E8:  11 14 7c      sub_00e8h:   ld de,07c14h
00EB:  df                         rst 18h
00EC:  da 7a 19                   jp c,l197ah
00EF:  11 ce ff                   ld de,0ffceh
00F2:  22 b1 78                   ld (MEMTOP),hl
00F5:  19                         add hl,de
00F6:  22 a0 78                   ld (STRINGS),hl
00F9:  cd 4d 1b                   call NEWCLRP
00FC:  cd 84 34                   call sub_3484h
00FF:  21 0f 01      l00ffh:      ld hl,l010fh
0102:  cd a7 28                   call OUTSTR
0105:  ed 56                      im 1
0107:  c3 8e 06                   jp l068eh
010A:  00                         nop
010B:  7e            l010bh:      ld a,(hl)
010C:  23                         inc hl
010D:  fe 0d                      cp 00dh
010F:  56            l010fh:      ld d,(hl)
0110:  49                         ld c,c
0111:  44                         ld b,h
0112:  45                         ld b,l
0113:  4f                         ld c,a
0114:  20 54                      jr nz,l016ah
0116:  45                         ld b,l
0117:  43                         ld b,e
0118:  48                         ld c,b
0119:  4e                         ld c,(hl)
011A:  4f                         ld c,a
011B:  4c                         ld c,h
011C:  4f                         ld c,a
011D:  47                         ld b,a
011E:  59                         ld e,c
011F:  0d                         dec c
0120:  42                         ld b,d
0121:  41                         ld b,c
0122:  53                         ld d,e
0123:  49            l0123h:      ld c,c
0124:  43                         ld b,e
0125:  20 56                      jr nz,$+88
0127:  32 2e 30                   ld (l302eh),a
012A:  0d                         dec c
012B:  0d                         dec c
012C:  00                         nop
012D:  1e 2c         l012dh:      ld e,02ch
012F:  c3 a2 19                   jp l19a2h
0132:  d7            l0132h:      rst 10h
0133:  af                         xor a
0134:  01 3e 80                   ld bc,0803eh
0137:  01 3e 01                   ld bc,l013eh
013A:  f5                         push af
013B:  cf                         rst 8
013C:  28 cd                      jr z,l010bh
013E:  1c            l013eh:      inc e
013F:  2b                         dec hl
0140:  fe 80                      cp 080h
0142:  d2 4a 1e                   jp nc,l1e4ah
0145:  f5                         push af
0146:  cf                         rst 8
0147:  2c                         inc l
0148:  cd 1c 2b      l0148h:      call sub_2b1ch
014B:  fe 40                      cp 040h
014D:  d2 4a 1e                   jp nc,l1e4ah
0150:  5f                         ld e,a
0151:  af                         xor a
0152:  57                         ld d,a
0153:  eb                         ex de,hl
0154:  29                         add hl,hl
0155:  29                         add hl,hl
0156:  29                         add hl,hl
0157:  29                         add hl,hl
0158:  29                         add hl,hl
0159:  eb                         ex de,hl
015A:  f1                         pop af
015B:  f5                         push af
015C:  cb 3f                      srl a
015E:  cb 3f                      srl a
0160:  83                         add a,e
0161:  5f                         ld e,a
0162:  7a                         ld a,d
0163:  f6 70                      or 070h
0165:  57                         ld d,a
0166:  f1                         pop af
0167:  e6 03                      and 003h
0169:  87                         add a,a
016A:  47            l016ah:      ld b,a
016B:  f1                         pop af
016C:  b7                         or a
016D:  ca e7 38                   jp z,l38e7h
0170:  f5            l0170h:      push af
0171:  0e 3f                      ld c,03fh
0173:  3a 46 78                   ld a,(07846h)
0176:  cb 27                      sla a
0178:  cb 27                      sla a
017A:  cb 0f         l017ah:      rrc a
017C:  cb 09                      rrc c
017E:  10 fa                      djnz l017ah
0180:  c3 03 39                   jp l3903h
0183:  21 39 78      l0183h:      ld hl,07839h
0186:  cb 9e                      res 3,(hl)
0188:  21 84 03                   ld hl,l0384h
018B:  cd a7 28                   call OUTSTR
018E:  c3 cf 36                   jp l36cfh
0191:  f1                         pop af
0192:  fe 20                      cp 020h
0194:  20 14                      jr nz,$+22
0196:  1a            l0196h:      ld a,(de)
0197:  13                         inc de
0198:  fe 20                      cp 020h
019A:  28 fa         l019ah:      jr z,l0196h
019C:  fe d7                      cp 0d7h
019E:  e5            l019eh:      push hl
019F:  3a 99 78                   ld a,(07899h)
01A2:  b7                         or a
01A3:  20 06                      jr nz,l01abh
01A5:  cd 58 03                   call sub_0358h
01A8:  b7                         or a
01A9:  28 11                      jr z,l01bch
01AB:  f5            l01abh:      push af
01AC:  af                         xor a
01AD:  32 99 78      l01adh:      ld (07899h),a
01B0:  3c                         inc a
01B1:  cd 57 28                   call sub_2857h
01B4:  f1                         pop af
01B5:  2a d4 78                   ld hl,(078d4h)
01B8:  77                         ld (hl),a
01B9:  c3 84 28                   jp l2884h
01BC:  21 28 19      l01bch:      ld hl,01928h
01BF:  22 21 79                   ld (07921h),hl
01C2:  3e 03                      ld a,003h
01C4:  32 af 78                   ld (078afh),a
01C7:  e1                         pop hl
01C8:  c9                         ret

01C9:  3e 1c         CLRSCR:      ld a,01ch
01CB:  cd 3a 03                   call CHOUT
01CE:  3e 1f                      ld a,01fh
01D0:  c3 3a 03                   jp CHOUT
01D3:  ed 5f                      ld a,r
01D5:  32 ab 78      l01d5h:      ld (078abh),a
01D8:  c9                         ret

01D9:  54            l01d9h:      ld d,h
01DA:  47                         ld b,a
01DB:  42                         ld b,d
01DC:  35                         dec (hl)
01DD:  4e                         ld c,(hl)
01DE:  36 59                      ld (hl),059h
01E0:  48            l01e0h:      ld c,b
01E1:  57                         ld d,a
01E2:  53                         ld d,e
01E3:  58                         ld e,b
01E4:  32 2e 39                   ld (l392dh+1),a
01E7:  4f                         ld c,a
01E8:  4c                         ld c,h
01E9:  00                         nop
01EA:  00                         nop
01EB:  00                         nop
01EC:  00                         nop
01ED:  00                         nop
01EE:  2d                         dec l
01EF:  0d                         dec c
01F0:  3a 45 44                   ld a,(04445h)
01F3:  43                         ld b,e
01F4:  33                         inc sp
01F5:  2c                         inc l
01F6:  38 49                      jr c,l0241h
01F8:  4b                         ld c,e
01F9:  51                         ld d,c
01FA:  41                         ld b,c
01FB:  5a                         ld e,d
01FC:  31 20 30                   ld sp,03020h
01FF:  50                         ld d,b
0200:  3b            l0200h:      dec sp
0201:  52                         ld d,d
0202:  46                         ld b,(hl)
0203:  56                         ld d,(hl)
0204:  34                         inc (hl)
0205:  4d                         ld c,l
0206:  37                         scf
0207:  55                         ld d,l
0208:  4a                         ld c,d
0209:  8c            l0209h:      adc a,h
020A:  89                         adc a,c
020B:  00                         nop
020C:  25                         dec h
020D:  5e                         ld e,(hl)
020E:  26 83                      ld h,083h
0210:  86                         add a,(hl)
0211:  8d                         adc a,l
0212:  82                         add a,d
0213:  00                         nop
0214:  22 3e 29                   ld (l293eh),hl
0217:  5b                         ld e,e
0218:  3f                         ccf
0219:  00                         nop
021A:  00                         nop
021B:  00                         nop
021C:  00                         nop
021D:  00                         nop
021E:  3d            l021eh:      dec a
021F:  0d                         dec c
0220:  2a 8b 84                   ld hl,(0848bh)
0223:  00                         nop
0224:  23                         inc hl
0225:  3c                         inc a
0226:  28 85                      jr z,l01adh
0228:  2f                         cpl
0229:  8e                         adc a,(hl)
022A:  81                         add a,c
022B:  80                         add a,b
022C:  21 20 40                   ld hl,04020h
022F:  5d                         ld e,l
0230:  2b                         dec hl
0231:  87                         add a,a
0232:  88                         adc a,b
0233:  00                         nop
0234:  24                         inc h
0235:  5c                         ld e,h
0236:  27                         daa
0237:  8a                         adc a,d
0238:  8f                         adc a,a
0239:  ca 8d b5      l0239h:      jp z,0b58dh
023C:  b4                         or h
023D:  97                         sub a
023E:  8e                         adc a,(hl)
023F:  95                         sub l
0240:  84                         add a,h
0241:  bd            l0241h:      cp l
0242:  cc b1 b9                   call z,0b9b1h
0245:  1b                         dec de
0246:  8b                         adc a,e
0247:  8c                         adc a,h
0248:  15                         dec d
0249:  00                         nop
024A:  00                         nop
024B:  00                         nop
024C:  00                         nop
024D:  00                         nop
024E:  01 00 00                   ld bc,RESET
0251:  87                         add a,a
0252:  8a                         adc a,d
0253:  b3                         or e
0254:  9c                         sbc a,h
0255:  09                         add hl,bc
0256:  bb                         cp e
0257:  89                         adc a,c
0258:  bc                         cp h
0259:  81                         add a,c
025A:  9d                         sbc a,l
025B:  e5                         push hl
025C:  ba                         cp d
025D:  0a                         ld a,(bc)
025E:  88                         adc a,b
025F:  b2                         or d
0260:  7f                         ld a,a
0261:  92                         sub d
0262:  91                         sub c
0263:  af                         xor a
0264:  98                         sbc a,b
0265:  08                         ex af,af'
0266:  80                         add a,b
0267:  8f                         adc a,a
0268:  93                         sub e
0269:  fa 94 9e      l0269h:      jp m,09e94h
026C:  df                         rst 18h
026D:  bf                         cp a
026E:  e0                         ret po
026F:  f9                         ld sp,hl
0270:  83                         add a,e
0271:  f5                         push af
0272:  f4 a0 e1                   call p,0e1a0h
0275:  00                         nop
0276:  d9                         exx
0277:  d3 00                      out (000h),a
0279:  00                         nop
027A:  00                         nop
027B:  00                         nop
027C:  00                         nop
027D:  00                         nop
027E:  01 00 00                   ld bc,RESET
0281:  f3                         di
0282:  90                         sub b
0283:  96                         sub (hl)
0284:  e3                         ex (sp),hl
0285:  00                         nop
	defb 0ddh,0d2h,0c6h	;illegal sequence		;0286	dd d2 c6 	. . . 

0289:  f7                         rst 30h
028A:  f6 db                      or 0dbh
028C:  e2 00 d8                   jp po,0d800h
028F:  cb 00                      rlc b
0291:  f8                         ret m
0292:  de c1                      sbc a,0c1h
0294:  e4 00 d7                   call po,0d700h
0297:  c9                         ret
0298:  82                         add a,d
0299:  e2 e1 e3      l0299h:      jp po,0e3e1h
029C:  e4 df e0                   call po,0e0dfh
029F:  d7                         rst 10h
	defb 0ddh,0d9h,0d8h	;illegal sequence		;02a0	dd d9 d8 	. . . 

02A3:  f7                         rst 30h
02A4:  f5                         push af
02A5:  f3                         di
02A6:  f8                         ret m
02A7:  f7                         rst 30h
02A8:  f9                         ld sp,hl
02A9:  9d                         sbc a,l
02AA:  f6 f4                      or 0f4h
02AC:  de e5                      sbc a,0e5h
02AE:  fa 80 80                   jp m,08080h
02B1:  80                         add a,b
02B2:  b8                         cp b
02B3:  b8                         cp b
02B4:  80                         add a,b
02B5:  b8                         cp b
02B6:  b8                         cp b
02B7:  80                         add a,b
02B8:  87                         add a,a
02B9:  80                         add a,b
02BA:  bf                         cp a
02BB:  b8                         cp b
02BC:  87                         add a,a
02BD:  b8                         cp b
02BE:  bf                         cp a
02BF:  87                         add a,a
02C0:  80                         add a,b
02C1:  87                         add a,a
02C2:  b8                         cp b
02C3:  bf                         cp a
02C4:  80                         add a,b
02C5:  bf                         cp a
02C6:  b8                         cp b
02C7:  87                         add a,a
02C8:  87                         add a,a
02C9:  87                         add a,a
02CA:  bf                         cp a
02CB:  bf                         cp a
02CC:  87                         add a,a
02CD:  bf                         cp a
02CE:  bf                         cp a
02CF:  72            l02cfh:      ld (hl),d
02D0:  02                         ld (bc),a
02D1:  4f                         ld c,a
02D2:  02                         ld (bc),a
02D3:  2e 02                      ld l,002h
02D5:  0e 02                      ld c,002h
02D7:  f1                         pop af
02D8:  01 d5 01                   ld bc,l01d5h
02DB:  b7                         or a
02DC:  01 9e 01                   ld bc,l019eh
02DF:  86                         add a,(hl)
02E0:  01 70 01                   ld bc,l0170h
02E3:  5b                         ld e,e
02E4:  01 48 01                   ld bc,l0148h
02E7:  35                         dec (hl)
02E8:  01 23 01                   ld bc,l0123h
02EB:  13                         inc de
02EC:  01 03 01                   ld bc,00103h
02EF:  f4 00 e6                   call p,0e600h
02F2:  00                         nop
02F3:  d9                         exx
02F4:  00                         nop
02F5:  cd 00 c1                   call 0c100h
02F8:  00                         nop
02F9:  b6                         or (hl)
02FA:  00                         nop
02FB:  ab                         xor e
02FC:  00                         nop
02FD:  a1                         and c
02FE:  00                         nop
02FF:  98                         sbc a,b
0300:  00            l0300h:      nop
0301:  8f                         adc a,a
0302:  00            l0302h:      nop
0303:  87                         add a,a
0304:  00                         nop
0305:  7f                         ld a,a
0306:  00                         nop
0307:  78                         ld a,b
0308:  00                         nop
0309:  70                         ld (hl),b
030A:  00                         nop
030B:  6a                         ld l,d
030C:  00                         nop
030D:  47            sub_030dh:   ld b,a
030E:  3a 3c 78                   ld a,(0783ch)
0311:  2a 20 78                   ld hl,(CURPOS)
0314:  77                         ld (hl),a
0315:  78                         ld a,b
0316:  c9                         ret
0317:  01 20 00      sub_0317h:   ld bc,l0020h
031A:  b7                         or a
031B:  ed 42                      sbc hl,bc
031D:  22 20 78                   ld (CURPOS),hl
0320:  c9                         ret
0321:  01 02 03      l0321h:      ld bc,l0302h
0324:  04                         inc b
0325:  06 08                      ld b,008h
0327:  0c                         inc c
0328:  10 18                      djnz l0342h
032A:  c5            sub_032ah:   push bc
032B:  4f                         ld c,a
032C:  cd c1 79                   call 079c1h
032F:  3a 9c 78                   ld a,(OUTDEV)
0332:  b7                         or a
0333:  79                         ld a,c
0334:  c1                         pop bc
0335:  fa 54 3b                   jp m,l3b54h
0338:  20 62                      jr nz,l039ch
033A:  d5            CHOUT:       push de
033B:  f5                         push af
033C:  c5                         push bc
033D:  e5                         push hl
033E:  cd 8b 30                   call INTCHOUT
0341:  e1                         pop hl
0342:  c1            l0342h:      pop bc
0343:  00                         nop
0344:  00                         nop
0345:  f1                         pop af
0346:  d1                         pop de
0347:  c9                         ret
0348:  3a 3d 78                   ld a,(0783dh)
034B:  e6 08                      and 008h
034D:  3a 20 78                   ld a,(CURPOS)
0350:  28 03                      jr z,l0355h
0352:  0f                         rrca
0353:  e6 1f                      and 01fh
0355:  e6 1f         l0355h:      and 01fh
0357:  c9                         ret
0358:  cd c4 79      sub_0358h:   call 079c4h
035B:  d5                         push de
035C:  cd 2b 00                   call sub_002bh
035F:  d1                         pop de
0360:  c9                         ret
0361:  0a            l0361h:      ld a,(bc)
0362:  0b                         dec bc
0363:  0c                         inc c
0364:  0c                         inc c
0365:  0d                         dec c
0366:  0e 0f                      ld c,00fh
0368:  0f                         rrca
0369:  10 11                      djnz $+19
036B:  12                         ld (de),a
036C:  13                         inc de
036D:  15                         dec d
036E:  16 17                      ld d,017h
0370:  19                         add hl,de
0371:  1a                         ld a,(de)
0372:  1c                         inc e
0373:  1d                         dec e
0374:  1f                         rra
0375:  21 23 25                   ld hl,02523h
0378:  27                         daa
0379:  29                         add hl,hl
037A:  2c                         inc l
037B:  2e 31                      ld l,031h
037D:  34                         inc (hl)
037E:  35                         dec (hl)
037F:  3a 4f 4b                   ld a,(04b4fh)
0382:  0d                         dec c
0383:  00                         nop
0384:  45            l0384h:      ld b,l
0385:  52                         ld d,d
0386:  52                         ld d,d
0387:  4f                         ld c,a
0388:  52                         ld d,d
0389:  0d                         dec c
038A:  00                         nop
038B:  af            sub_038bh:   xor a
038C:  32 9c 78                   ld (OUTDEV),a
038F:  3a 9b 78                   ld a,(0789bh)
0392:  b7                         or a
0393:  c8                         ret z
0394:  3e 0d                      ld a,00dh
0396:  d5                         push de
0397:  cd 9c 03                   call l039ch
039A:  d1                         pop de
039B:  c9                         ret
039C:  f5            l039ch:      push af
039D:  d5                         push de
039E:  c5                         push bc
039F:  4f                         ld c,a
03A0:  1e 00                      ld e,000h
03A2:  fe 0c                      cp 00ch
03A4:  28 10                      jr z,l03b6h
03A6:  fe 0a                      cp 00ah
03A8:  20 03                      jr nz,l03adh
03AA:  3e 0d                      ld a,00dh
03AC:  4f                         ld c,a
03AD:  fe 0d         l03adh:      cp 00dh
03AF:  28 05                      jr z,l03b6h
03B1:  3a 9b 78                   ld a,(0789bh)
03B4:  3c                         inc a
03B5:  5f                         ld e,a
03B6:  7b            l03b6h:      ld a,e
03B7:  32 9b 78                   ld (0789bh),a
03BA:  79                         ld a,c
03BB:  cd 3b 00                   call sub_003bh
03BE:  c1                         pop bc
03BF:  d1                         pop de
03C0:  f1                         pop af
03C1:  c9                         ret
03C2:  e5            l03c2h:      push hl
03C3:  dd e5                      push ix
03C5:  d5                         push de
03C6:  dd e1                      pop ix
03C8:  d5                         push de
03C9:  21 dd 03                   ld hl,l03ddh
03CC:  e5                         push hl
03CD:  4f                         ld c,a
03CE:  1a                         ld a,(de)
03CF:  a0                         and b
03D0:  b8                         cp b
03D1:  c2 33 78                   jp nz,07833h
03D4:  fe 02                      cp 002h
03D6:  dd 6e 01                   ld l,(ix+001h)
03D9:  dd 66 02                   ld h,(ix+002h)
03DC:  e9                         jp (hl)
03DD:  d1            l03ddh:      pop de
03DE:  dd e1                      pop ix
03E0:  e1                         pop hl
03E1:  c1                         pop bc
03E2:  c9                         ret
03E3:  21 39 78      l03e3h:      ld hl,07839h
03E6:  cb ee                      set 5,(hl)
03E8:  2a 20 78                   ld hl,(CURPOS)
03EB:  cd 53 00                   call sub_0053h
03EE:  7c                         ld a,h
03EF:  fe 71                      cp 071h
03F1:  20 10                      jr nz,l0403h
03F3:  7d                         ld a,l
03F4:  fe e0                      cp 0e0h
03F6:  20 0b                      jr nz,l0403h
03F8:  3a d7 7a                   ld a,(07ad7h)
03FB:  b7                         or a
03FC:  20 05                      jr nz,l0403h
03FE:  3e 0d                      ld a,00dh
0400:  cd 8b 30                   call INTCHOUT
0403:  41            l0403h:      ld b,c
0404:  c5                         push bc
0405:  21 39 78                   ld hl,07839h
0408:  cb 86                      res 0,(hl)
040A:  cb 96                      res 2,(hl)
040C:  cb 46         l040ch:      bit 0,(hl)
040E:  28 fc                      jr z,l040ch
0410:  3a a6 78                   ld a,(078a6h)
0413:  4f                         ld c,a
0414:  af                         xor a
0415:  32 a6 78                   ld (078a6h),a
0418:  47                         ld b,a
0419:  2a 20 78                   ld hl,(CURPOS)
041C:  ed 42                      sbc hl,bc
041E:  22 20 78      l041eh:      ld (CURPOS),hl
0421:  11 e8 79                   ld de,BUFFIDX
0424:  c1                         pop bc
0425:  21 39 78                   ld hl,07839h
0428:  cb 66                      bit 4,(hl)
042A:  2a 20 78                   ld hl,(CURPOS)
042D:  28 42                      jr z,l0471h
042F:  c5                         push bc
0430:  e5                         push hl
0431:  cd a8 33                   call sub_33a8h
0434:  e1                         pop hl
0435:  c1                         pop bc
0436:  b7                         or a
0437:  20 08                      jr nz,l0441h
0439:  7d                         ld a,l
043A:  d6 20                      sub 020h
043C:  6f                         ld l,a
043D:  7c                         ld a,h
043E:  de 00         l043eh:      sbc a,000h
0440:  67                         ld h,a
0441:  48            l0441h:      ld c,b
0442:  1a            l0442h:      ld a,(de)
0443:  be                         cp (hl)
0444:  20 07                      jr nz,l044dh
0446:  23                         inc hl
0447:  13                         inc de
0448:  10 f8                      djnz l0442h
044A:  c5                         push bc
044B:  18 04                      jr l0451h
044D:  01 00 00      l044dh:      ld bc,RESET
0450:  c5                         push bc
0451:  e5            l0451h:      push hl
0452:  cd a8 33                   call sub_33a8h
0455:  e1                         pop hl
0456:  c1                         pop bc
0457:  c5                         push bc
0458:  fe 80                      cp 080h
045A:  28 0a                      jr z,l0466h
045C:  3e 40                      ld a,040h
045E:  91                         sub c
045F:  47                         ld b,a
0460:  d1                         pop de
0461:  1e 00                      ld e,000h
0463:  d5                         push de
0464:  18 05                      jr l046bh
0466:  06 20         l0466h:      ld b,020h
0468:  2a 20 78                   ld hl,(CURPOS)
046B:  11 e8 79      l046bh:      ld de,BUFFIDX
046E:  c3 a8 3e                   jp l3ea8h
0471:  01 00 00      l0471h:      ld bc,RESET
0474:  c5                         push bc
0475:  e5                         push hl
0476:  cd a8 33                   call sub_33a8h
0479:  e1                         pop hl
047A:  fe 80                      cp 080h
047C:  28 0e                      jr z,l048ch
047E:  fe 81                      cp 081h
0480:  28 06                      jr z,l0488h
0482:  01 20 00                   ld bc,l0020h
0485:  b7                         or a
0486:  ed 42                      sbc hl,bc
0488:  06 40         l0488h:      ld b,040h
048A:  18 02                      jr l048eh
048C:  06 20         l048ch:      ld b,020h
048E:  3a 18 78      l048eh:      ld a,(07818h)
0491:  b7                         or a
0492:  ca 40 3e                   jp z,l3e40h
0495:  7e            l0495h:      ld a,(hl)
0496:  fe 40                      cp 040h
0498:  da ae 04                   jp c,l04aeh
049B:  c1                         pop bc
049C:  11 a4 04                   ld de,l04a4h
049F:  d5                         push de
04A0:  c5                         push bc
04A1:  c3 02 05                   jp l0502h
04A4:  d8            l04a4h:      ret c
04A5:  21 1a 3e                   ld hl,l3e1ah
04A8:  cd a7 28                   call OUTSTR
04AB:  c3 e3 03                   jp l03e3h
04AE:  fe 22         l04aeh:      cp 022h
04B0:  20 31                      jr nz,l04e3h
04B2:  12                         ld (de),a
04B3:  23                         inc hl
04B4:  13                         inc de
04B5:  05                         dec b
04B6:  28 36                      jr z,l04eeh
04B8:  7e            l04b8h:      ld a,(hl)
04B9:  fe 40                      cp 040h
04BB:  da c9 04                   jp c,l04c9h
04BE:  fe 80                      cp 080h
04C0:  da c5 04                   jp c,l04c5h
04C3:  e6 8f                      and 08fh
04C5:  f6 80         l04c5h:      or 080h
04C7:  18 13                      jr l04dch
04C9:  fe 22         l04c9h:      cp 022h
04CB:  20 09                      jr nz,l04d6h
04CD:  e5                         push hl
04CE:  21 39 78                   ld hl,07839h
04D1:  cb 66                      bit 4,(hl)
04D3:  e1                         pop hl
04D4:  28 0d                      jr z,l04e3h
04D6:  cb 6f         l04d6h:      bit 5,a
04D8:  20 02                      jr nz,l04dch
04DA:  f6 40                      or 040h
04DC:  12            l04dch:      ld (de),a
04DD:  23                         inc hl
04DE:  13                         inc de
04DF:  10 d7                      djnz l04b8h
04E1:  18 0b                      jr l04eeh
04E3:  cb 6f         l04e3h:      bit 5,a
04E5:  20 02                      jr nz,l04e9h
04E7:  f6 40                      or 040h
04E9:  12            l04e9h:      ld (de),a
04EA:  23                         inc hl
04EB:  13                         inc de
04EC:  10 a7                      djnz l0495h
04EE:  1b            l04eeh:      dec de
04EF:  7a                         ld a,d
04F0:  fe 79                      cp 079h
04F2:  20 06                      jr nz,l04fah
04F4:  7b                         ld a,e
04F5:  fe e8                      cp 0e8h
04F7:  da ff 04                   jp c,l04ffh
04FA:  1a            l04fah:      ld a,(de)
04FB:  fe 20                      cp 020h
04FD:  28 ef                      jr z,l04eeh
04FF:  13            l04ffh:      inc de
0500:  af                         xor a
0501:  12                         ld (de),a
0502:  cd a8 33      l0502h:      call sub_33a8h
0505:  2a 20 78                   ld hl,(CURPOS)
0508:  fe 81                      cp 081h
050A:  cd 53 00                   call sub_0053h
050D:  20 04                      jr nz,l0513h
050F:  af                         xor a
0510:  cd 8b 30                   call INTCHOUT
0513:  af            l0513h:      xor a
0514:  cd 8b 30                   call INTCHOUT
0517:  3a 38 78                   ld a,(07838h)
051A:  e6 fd                      and 0fdh
051C:  32 38 78                   ld (07838h),a
051F:  21 39 78                   ld hl,07839h
0522:  cb 56                      bit 2,(hl)
0524:  28 05                      jr z,l052bh
0526:  3e 01                      ld a,001h
0528:  37                         scf
0529:  18 01                      jr l052ch
052B:  af            l052bh:      xor a
052C:  21 39 78      l052ch:      ld hl,07839h
052F:  cb a6                      res 4,(hl)
0531:  21 e8 79                   ld hl,BUFFIDX
0534:  c1                         pop bc
0535:  f5                         push af
0536:  09                         add hl,bc
0537:  c3 29 3e                   jp l3e29h
053A:  3a af 7a      l053ah:      ld a,(07aafh)
053D:  b7                         or a
053E:  20 fa                      jr nz,l053ah
0540:  06 40                      ld b,040h
0542:  21 e8 79                   ld hl,BUFFIDX
0545:  3e 20                      ld a,020h
0547:  77            l0547h:      ld (hl),a
0548:  23                         inc hl
0549:  10 fc                      djnz l0547h
054B:  af                         xor a
054C:  77                         ld (hl),a
054D:  cd a8 33                   call sub_33a8h
0550:  b7                         or a
0551:  3a a6 78                   ld a,(078a6h)
0554:  20 02                      jr nz,l0558h
0556:  c6 20                      add a,020h
0558:  4f            l0558h:      ld c,a
0559:  af                         xor a
055A:  47                         ld b,a
055B:  2a 20 78                   ld hl,(CURPOS)
055E:  ed 42                      sbc hl,bc
0560:  11 e8 79                   ld de,BUFFIDX
0563:  c5                         push bc
0564:  ed b0                      ldir
0566:  c1                         pop bc
0567:  21 39 78                   ld hl,07839h
056A:  cb e6                      set 4,(hl)
056C:  cd e3 03                   call l03e3h
056F:  c9                         ret
0570:  52            l0570h:      ld d,d
0571:  55                         ld d,l
0572:  4e                         ld c,(hl)
0573:  00                         nop
0574:  c4 33 32                   call nz,sub_3233h
0577:  cd a3 1a                   call 01aa3h
057A:  cd d8 17                   call sub_17d8h
057D:  cd 0d 19                   call sub_190dh
0580:  ca 5a 12                   jp z,0125ah
0583:  cd 49 1f                   call sub_1f49h
0586:  38 18                      jr c,$+26
0588:  ef                         rst 28h
0589:  3a 38 04                   ld a,(00438h)
	defb 0ddh,079h,0b7h	;illegal sequence		;058c	dd 79 b7 	. y . 

058F:  28 33                      jr z,CHKPRT
0591:  fe 0b                      cp 00bh
0593:  28 0a                      jr z,l059fh
0595:  fe 0c                      cp 00ch
0597:  20 14                      jr nz,l05adh
0599:  af                         xor a
059A:  dd b6 03                   or (ix+003h)
059D:  28 0e                      jr z,l05adh
059F:  dd 7e 03      l059fh:      ld a,(ix+003h)
05A2:  dd 96 04                   sub (ix+004h)
05A5:  47                         ld b,a
05A6:  cd e2 3a      l05a6h:      call PRNCLRF
05A9:  10 fb                      djnz l05a6h
05AB:  18 12                      jr l05bfh
05AD:  cd b6 3a      l05adh:      call sub_3ab6h
05B0:  79                         ld a,c
05B1:  fe 0d                      cp 00dh
05B3:  c0                         ret nz
05B4:  dd 34 04                   inc (ix+004h)
05B7:  dd 7e 04                   ld a,(ix+004h)
05BA:  dd be 03                   cp (ix+003h)
05BD:  79                         ld a,c
05BE:  c0                         ret nz
05BF:  dd 36 04      l05bfh:      ld (ix+004h),000h
05C3:  c9                         ret
05C4:  db 00         CHKPRT:      in a,(000h)
05C6:  e6 01                      and 001h
05C8:  c9                         ret
05C9:  c5            sub_05c9h:   push bc
05CA:  e5                         push hl
05CB:  06 04                      ld b,004h
05CD:  21 d2 7a                   ld hl,07ad2h
05D0:  77            l05d0h:      ld (hl),a
05D1:  23                         inc hl
05D2:  10 fc                      djnz l05d0h
05D4:  e1                         pop hl
05D5:  c1                         pop bc
05D6:  c9                         ret
05D7:  21 38 78      l05d7h:      ld hl,07838h
05DA:  cb 56                      bit 2,(hl)
05DC:  28 15                      jr z,l05f3h
05DE:  57                         ld d,a
05DF:  3a 3a 78                   ld a,(0783ah)
05E2:  b7                         or a
05E3:  28 0f                      jr z,l05f4h
05E5:  3c                         inc a
05E6:  32 3a 78                   ld (0783ah),a
05E9:  fe 2a                      cp 02ah
05EB:  28 02                      jr z,l05efh
05ED:  af                         xor a
05EE:  c9                         ret
05EF:  cb 96         l05efh:      res 2,(hl)
05F1:  af                         xor a
05F2:  c9                         ret
05F3:  57            l05f3h:      ld d,a
05F4:  21 38 78      l05f4h:      ld hl,07838h
05F7:  7e                         ld a,(hl)
05F8:  e6 18                      and 018h
05FA:  20 0b                      jr nz,l0607h
05FC:  cb de                      set 3,(hl)
05FE:  af                         xor a
05FF:  32 37 78                   ld (07837h),a
0602:  7a                         ld a,d
0603:  32 36 78      l0603h:      ld (07836h),a
0606:  c9                         ret
0607:  cb 66         l0607h:      bit 4,(hl)
0609:  20 2a                      jr nz,l0635h
060B:  3a 36 78                   ld a,(07836h)
060E:  ba                         cp d
060F:  20 21                      jr nz,l0632h
0611:  ed 4b 42                   ld bc,(07842h)
0615:  2a 44 78                   ld hl,(07844h)
0618:  7b                         ld a,e
0619:  cd 35 2f                   call sub_2f35h
061C:  ba                         cp d
061D:  ca d7 2f                   jp z,l2fd7h
0620:  fe 00                      cp 000h
0622:  ca d7 2f                   jp z,l2fd7h
0625:  21 38 78      l0625h:      ld hl,07838h
0628:  cb de                      set 3,(hl)
062A:  cb e6                      set 4,(hl)
062C:  cb 96                      res 2,(hl)
062E:  32 37 78                   ld (07837h),a
0631:  c9                         ret
0632:  7a            l0632h:      ld a,d
0633:  18 f0                      jr l0625h
0635:  3a 36 78      l0635h:      ld a,(07836h)
0638:  ba                         cp d
0639:  28 08                      jr z,l0643h
063B:  3a 37 78                   ld a,(07837h)
063E:  ba                         cp d
063F:  28 02                      jr z,l0643h
0641:  af                         xor a
0642:  c9                         ret
0643:  ed 4b 42      l0643h:      ld bc,(07842h)
0647:  2a 44 78                   ld hl,(07844h)
064A:  7b                         ld a,e
064B:  cd 35 2f                   call sub_2f35h
064E:  ba                         cp d
064F:  28 05                      jr z,l0656h
0651:  fe 00                      cp 000h
0653:  c2 d7 2f                   jp nz,l2fd7h
0656:  21 38 78      l0656h:      ld hl,07838h
0659:  cb de                      set 3,(hl)
065B:  cb a6                      res 4,(hl)
065D:  3a 36 78                   ld a,(07836h)
0660:  ba                         cp d
0661:  20 05                      jr nz,l0668h
0663:  af            l0663h:      xor a
0664:  32 37 78                   ld (07837h),a
0667:  c9                         ret
0668:  3a 37 78      l0668h:      ld a,(07837h)
066B:  32 36 78                   ld (07836h),a
066E:  18 f3                      jr l0663h
0670:  dd cb 09                   set 2,(ix+009h)

;*******************************************************************************
;*Basic init 1                                                                 *
;*0674h                                                                        * 
;*******************************************************************************

0674:  00            BASINIT1:    nop              ; Level II basic fragment for alignment??                   
0675:  00                         nop			   ; Below relocates ROM into RAM area	
0676:  21 d2 06      l0676h:      ld hl,l06d2h     ; ROM 6d2h to 707h - RESET08 IN ROM	
0679:  11 00 78                   ld de,RESET08	   ; RAM 7800h to 7835 - RESET08 IN RAM
067C:  01 36 00                   ld bc,l0036h     ; Length 36h bytes (54 bytes)
067F:  ed b0                      ldir
0681:  3d                         dec a			   ; this happens 128x 
0682:  3d                         dec a			   ; to fill each workspace
0683:  20 f1                      jr nz,l0676h     ; copy until done

; ******************************************************************************
; * clear workspace area stub from de (in basic intit 1 this is 7836h to       *
; * 785ch) always jumps to 0075h after completion, regardless of caller.       *
; * this has outside callers.                                                  *
; * 685h                                                                       *
; ******************************************************************************


0685:  06 27         CLRSTUB1:    ld b,027h		   ; clear workspace 27h bytes (39 bytes)
0687:  12            l0687h:      ld (de),a		   ; this is bytes 7836h to 785Ch in init  1	
0688:  13                         inc de
0689:  10 fc                      djnz l0687h      ; loop until its cleared
068B:  c3 75 00                   jp BASINIT2      ; to basic init 2

;******************************************************************************
;*Basic init 3                                                                *
;*068Eh                                                                       *
;******************************************************************************

068E:  21 00 40      l068eh:      ld hl,04000h
0691:  cd a4 06                   call sub_06a4h
0694:  21 00 60                   ld hl,06000h
0697:  cd a4 06                   call sub_06a4h
069A:  21 00 80                   ld hl,08000h
069D:  cd a4 06                   call sub_06a4h
06A0:  fb            EIENTBAS:    ei
06A1:  c3 19 1a                   jp BASENT
06A4:  3e aa         sub_06a4h:   ld a,0aah
06A6:  be                         cp (hl)
06A7:  23                         inc hl
06A8:  c0                         ret nz
06A9:  2f                         cpl
06AA:  be                         cp (hl)
06AB:  23                         inc hl
06AC:  c0                         ret nz
06AD:  3e e7                      ld a,0e7h
06AF:  be                         cp (hl)
06B0:  23                         inc hl
06B1:  c0                         ret nz
06B2:  2f                         cpl
06B3:  be                         cp (hl)
06B4:  23                         inc hl
06B5:  c0                         ret nz
06B6:  fb                         ei
06B7:  e9                         jp (hl)
06B8:  0e 02                      ld c,002h
06BA:  cd 59 1a                   call 01a59h
06BD:  cd b8 34                   call sub_34b8h
06C0:  cd e3 18                   call sub_18e3h
06C3:  28 c0                      jr z,CLRSTUB1
06C5:  ef                         rst 28h
06C6:  2c                         inc l
06C7:  28 14                      jr z,$+22
06C9:  cd f1 34                   call sub_34f1h
06CC:  01 18 1a      l06cch:      ld bc,01a18h
06CF:  c3 ae 19                   jp l19aeh
06D2:  c3 96 1c      l06d2h:      jp EXSTR
06D5:  c3 78 1d                   jp CHKCHR
06D8:  c3 90 1c                   jp CMPHLDE
06DB:  c3 d9 25                   jp l25d9h
06DE:  c9                         ret
06DF:  00                         nop
06E0:  00                         nop
06E1:  c9                         ret
06E2:  00                         nop
06E3:  00                         nop
06E4:  fb                         ei
06E5:  c9                         ret
06E6:  00                         nop
06E7:  01 f4 2e                   ld bc,SCANKEYB
06EA:  00                         nop
06EB:  00                         nop
06EC:  00                         nop
06ED:  4b                         ld c,e
06EE:  49                         ld c,c
06EF:  00                         nop
06F0:  00                         nop
06F1:  00                         nop
06F2:  00                         nop
06F3:  70                         ld (hl),b
06F4:  00                         nop
06F5:  00                         nop
06F6:  00                         nop
06F7:  06 8d                      ld b,08dh
06F9:  05                         dec b
06FA:  43                         ld b,e
06FB:  00                         nop
06FC:  00                         nop
06FD:  50                         ld d,b
06FE:  52                         ld d,d
06FF:  c3 00 50                   jp 05000h
0702:  c7                         rst 0
0703:  00                         nop
0704:  00                         nop
0705:  3e 00                      ld a,000h
0707:  c9                         ret
0708:  21 80 13      sub_0708h:   ld hl,l1380h
070B:  cd c2 09      sub_070bh:   call sub_09c2h
070E:  18 06                      jr l0716h
0710:  cd c2 09      sub_0710h:   call sub_09c2h
0713:  cd 82 09      sub_0713h:   call sub_0982h
0716:  78            l0716h:      ld a,b
0717:  b7                         or a
0718:  c8                         ret z
0719:  3a 24 79                   ld a,(07924h)
071C:  b7                         or a
071D:  ca b4 09                   jp z,l09b4h
0720:  90                         sub b
0721:  30 0c                      jr nc,l072fh
0723:  2f                         cpl
0724:  3c                         inc a
0725:  eb                         ex de,hl
0726:  cd a4 09                   call sub_09a4h
0729:  eb                         ex de,hl
072A:  cd b4 09                   call l09b4h
072D:  c1                         pop bc
072E:  d1                         pop de
072F:  fe 19         l072fh:      cp 019h
0731:  d0                         ret nc
0732:  f5                         push af
0733:  cd df 09                   call sub_09dfh
0736:  67                         ld h,a
0737:  f1                         pop af
0738:  cd d7 07                   call sub_07d7h
073B:  b4                         or h
073C:  21 21 79                   ld hl,07921h
073F:  f2 54 07                   jp p,l0754h
0742:  cd b7 07                   call sub_07b7h
0745:  d2 96 07                   jp nc,l0796h
0748:  23                         inc hl
0749:  34                         inc (hl)
074A:  ca b2 07                   jp z,l07b2h
074D:  2e 01                      ld l,001h
074F:  cd eb 07                   call sub_07ebh
0752:  18 42                      jr l0796h
0754:  af            l0754h:      xor a
0755:  90                         sub b
0756:  47                         ld b,a
0757:  7e                         ld a,(hl)
0758:  9b                         sbc a,e
0759:  5f                         ld e,a
075A:  23                         inc hl
075B:  7e                         ld a,(hl)
075C:  9a                         sbc a,d
075D:  57                         ld d,a
075E:  23                         inc hl
075F:  7e                         ld a,(hl)
0760:  99                         sbc a,c
0761:  4f                         ld c,a
0762:  dc c3 07      l0762h:      call c,sub_07c3h
0765:  68            l0765h:      ld l,b
0766:  63                         ld h,e
0767:  af                         xor a
0768:  47            l0768h:      ld b,a
0769:  79                         ld a,c
076A:  b7                         or a
076B:  20 18                      jr nz,l0785h
076D:  4a                         ld c,d
076E:  54                         ld d,h
076F:  65                         ld h,l
0770:  6f                         ld l,a
0771:  78                         ld a,b
0772:  d6 08                      sub 008h
0774:  fe e0                      cp 0e0h
0776:  20 f0                      jr nz,l0768h
0778:  af            l0778h:      xor a
0779:  32 24 79      l0779h:      ld (07924h),a
077C:  c9                         ret
077D:  05            l077dh:      dec b
077E:  29                         add hl,hl
077F:  7a                         ld a,d
0780:  17                         rla
0781:  57                         ld d,a
0782:  79                         ld a,c
0783:  8f                         adc a,a
0784:  4f                         ld c,a
0785:  f2 7d 07      l0785h:      jp p,l077dh
0788:  78                         ld a,b
0789:  5c                         ld e,h
078A:  45                         ld b,l
078B:  b7            l078bh:      or a
078C:  28 08                      jr z,l0796h
078E:  21 24 79                   ld hl,07924h
0791:  86                         add a,(hl)
0792:  77                         ld (hl),a
0793:  30 e3                      jr nc,l0778h
0795:  c8                         ret z
0796:  78            l0796h:      ld a,b
0797:  21 24 79      l0797h:      ld hl,07924h
079A:  b7                         or a
079B:  fc a8 07                   call m,sub_07a8h
079E:  46                         ld b,(hl)
079F:  23                         inc hl
07A0:  7e                         ld a,(hl)
07A1:  e6 80                      and 080h
07A3:  a9                         xor c
07A4:  4f                         ld c,a
07A5:  c3 b4 09                   jp l09b4h
07A8:  1c            sub_07a8h:   inc e
07A9:  c0                         ret nz
07AA:  14                         inc d
07AB:  c0                         ret nz
07AC:  0c                         inc c
07AD:  c0                         ret nz
07AE:  0e 80                      ld c,080h
07B0:  34                         inc (hl)
07B1:  c0                         ret nz
07B2:  1e 0a         l07b2h:      ld e,00ah
07B4:  c3 a2 19                   jp l19a2h
07B7:  7e            sub_07b7h:   ld a,(hl)
07B8:  83                         add a,e
07B9:  5f                         ld e,a
07BA:  23                         inc hl
07BB:  7e                         ld a,(hl)
07BC:  8a                         adc a,d
07BD:  57                         ld d,a
07BE:  23                         inc hl
07BF:  7e                         ld a,(hl)
07C0:  89                         adc a,c
07C1:  4f                         ld c,a
07C2:  c9                         ret
07C3:  21 25 79      sub_07c3h:   ld hl,07925h
07C6:  7e                         ld a,(hl)
07C7:  2f                         cpl
07C8:  77                         ld (hl),a
07C9:  af                         xor a
07CA:  6f                         ld l,a
07CB:  90                         sub b
07CC:  47                         ld b,a
07CD:  7d                         ld a,l
07CE:  9b                         sbc a,e
07CF:  5f                         ld e,a
07D0:  7d                         ld a,l
07D1:  9a                         sbc a,d
07D2:  57                         ld d,a
07D3:  7d                         ld a,l
07D4:  99                         sbc a,c
07D5:  4f                         ld c,a
07D6:  c9                         ret
07D7:  06 00         sub_07d7h:   ld b,000h
07D9:  d6 08         l07d9h:      sub 008h
07DB:  38 07                      jr c,l07e4h
07DD:  43                         ld b,e
07DE:  5a                         ld e,d
07DF:  51                         ld d,c
07E0:  0e 00                      ld c,000h
07E2:  18 f5                      jr l07d9h
07E4:  c6 09         l07e4h:      add a,009h
07E6:  6f                         ld l,a
07E7:  af            l07e7h:      xor a
07E8:  2d                         dec l
07E9:  c8                         ret z
07EA:  79                         ld a,c
07EB:  1f            sub_07ebh:   rra
07EC:  4f                         ld c,a
07ED:  7a                         ld a,d
07EE:  1f                         rra
07EF:  57                         ld d,a
07F0:  7b                         ld a,e
07F1:  1f                         rra
07F2:  5f                         ld e,a
07F3:  78                         ld a,b
07F4:  1f                         rra
07F5:  47                         ld b,a
07F6:  18 ef                      jr l07e7h
07F8:  00            l07f8h:      nop
07F9:  00                         nop
07FA:  00                         nop
07FB:  81                         add a,c
07FC:  03            l07fch:      inc bc
07FD:  aa                         xor d
07FE:  56                         ld d,(hl)
07FF:  19            l07ffh:      add hl,de
0800:  80            l0800h:      add a,b
0801:  f1                         pop af
0802:  22 76 80                   ld (08076h),hl
0805:  45                         ld b,l
0806:  aa                         xor d
0807:  38 82                      jr c,l078bh
0809:  cd 55 09      sub_0809h:   call sub_0955h
080C:  b7                         or a
080D:  ea 4a 1e                   jp pe,l1e4ah
0810:  21 24 79                   ld hl,07924h
0813:  7e                         ld a,(hl)
0814:  01 35 80                   ld bc,08035h
0817:  11 f3 04                   ld de,004f3h
081A:  90                         sub b
081B:  f5                         push af
081C:  70                         ld (hl),b
081D:  d5                         push de
081E:  c5            l081eh:      push bc
081F:  cd 16 07                   call l0716h
0822:  c1                         pop bc
0823:  d1                         pop de
0824:  04                         inc b
0825:  cd a2 08                   call sub_08a2h
0828:  21 f8 07                   ld hl,l07f8h
082B:  cd 10 07                   call sub_0710h
082E:  21 fc 07                   ld hl,l07fch
0831:  cd 9a 14                   call sub_149ah
0834:  01 80 80                   ld bc,08080h
0837:  11 00 00                   ld de,RESET
083A:  cd 16 07                   call l0716h
083D:  f1                         pop af
083E:  cd 89 0f                   call sub_0f89h
0841:  01 31 80      sub_0841h:   ld bc,08031h
0844:  11 18 72                   ld de,07218h
0847:  cd 55 09      l0847h:      call sub_0955h
084A:  c8                         ret z
084B:  2e 00                      ld l,000h
084D:  cd 14 09                   call sub_0914h
0850:  79                         ld a,c
0851:  32 4f 79                   ld (0794fh),a
0854:  eb                         ex de,hl
0855:  22 50 79                   ld (07950h),hl
0858:  01 00 00                   ld bc,RESET
085B:  50                         ld d,b
085C:  58                         ld e,b
085D:  21 65 07                   ld hl,l0765h
0860:  e5                         push hl
0861:  21 69 08                   ld hl,l0869h
0864:  e5                         push hl
0865:  e5                         push hl
0866:  21 21 79                   ld hl,07921h
0869:  7e            l0869h:      ld a,(hl)
086A:  23                         inc hl
086B:  b7                         or a
086C:  28 24                      jr z,l0892h
086E:  e5                         push hl
086F:  2e 08                      ld l,008h
0871:  1f            l0871h:      rra
0872:  67                         ld h,a
0873:  79                         ld a,c
0874:  30 0b                      jr nc,l0881h
0876:  e5                         push hl
0877:  2a 50 79                   ld hl,(07950h)
087A:  19                         add hl,de
087B:  eb                         ex de,hl
087C:  e1                         pop hl
087D:  3a 4f 79                   ld a,(0794fh)
0880:  89                         adc a,c
0881:  1f            l0881h:      rra
0882:  4f                         ld c,a
0883:  7a                         ld a,d
0884:  1f                         rra
0885:  57                         ld d,a
0886:  7b                         ld a,e
0887:  1f                         rra
0888:  5f                         ld e,a
0889:  78                         ld a,b
088A:  1f                         rra
088B:  47                         ld b,a
088C:  2d                         dec l
088D:  7c                         ld a,h
088E:  20 e1                      jr nz,l0871h
0890:  e1            l0890h:      pop hl
0891:  c9                         ret
0892:  43            l0892h:      ld b,e
0893:  5a                         ld e,d
0894:  51                         ld d,c
0895:  4f                         ld c,a
0896:  c9                         ret
0897:  cd a4 09      sub_0897h:   call sub_09a4h
089A:  21 d8 0d                   ld hl,l0dd8h
089D:  cd b1 09                   call sub_09b1h
08A0:  c1            l08a0h:      pop bc
08A1:  d1                         pop de
08A2:  cd 55 09      sub_08a2h:   call sub_0955h
08A5:  ca 9a 19                   jp z,0199ah
08A8:  2e ff                      ld l,0ffh
08AA:  cd 14 09                   call sub_0914h
08AD:  34                         inc (hl)
08AE:  34                         inc (hl)
08AF:  2b                         dec hl
08B0:  7e                         ld a,(hl)
08B1:  32 89 78                   ld (07889h),a
08B4:  2b                         dec hl
08B5:  7e                         ld a,(hl)
08B6:  32 85 78                   ld (07885h),a
08B9:  2b                         dec hl
08BA:  7e                         ld a,(hl)
08BB:  32 81 78                   ld (07881h),a
08BE:  41                         ld b,c
08BF:  eb                         ex de,hl
08C0:  af                         xor a
08C1:  4f                         ld c,a
08C2:  57                         ld d,a
08C3:  5f                         ld e,a
08C4:  32 8c 78                   ld (0788ch),a
08C7:  e5            l08c7h:      push hl
08C8:  c5                         push bc
08C9:  7d                         ld a,l
08CA:  cd 80 78                   call 07880h
08CD:  de 00                      sbc a,000h
08CF:  3f                         ccf
08D0:  30 07                      jr nc,$+9
08D2:  32 8c 78                   ld (0788ch),a
08D5:  f1                         pop af
08D6:  f1                         pop af
08D7:  37                         scf
08D8:  d2 c1 e1                   jp nc,0e1c1h
08DB:  79                         ld a,c
08DC:  3c                         inc a
08DD:  3d                         dec a
08DE:  1f                         rra
08DF:  fa 97 07                   jp m,l0797h
08E2:  17                         rla
08E3:  7b                         ld a,e
08E4:  17                         rla
08E5:  5f                         ld e,a
08E6:  7a                         ld a,d
08E7:  17                         rla
08E8:  57                         ld d,a
08E9:  79                         ld a,c
08EA:  17                         rla
08EB:  4f                         ld c,a
08EC:  29                         add hl,hl
08ED:  78                         ld a,b
08EE:  17                         rla
08EF:  47                         ld b,a
08F0:  3a 8c 78                   ld a,(0788ch)
08F3:  17                         rla
08F4:  32 8c 78                   ld (0788ch),a
08F7:  79                         ld a,c
08F8:  b2                         or d
08F9:  b3                         or e
08FA:  20 cb                      jr nz,l08c7h
08FC:  e5                         push hl
08FD:  21 24 79                   ld hl,07924h
0900:  35                         dec (hl)
0901:  e1                         pop hl
0902:  20 c3                      jr nz,l08c7h
0904:  c3 b2 07                   jp l07b2h
0907:  3e ff         sub_0907h:   ld a,0ffh
0909:  2e af                      ld l,0afh
090B:  21 2d 79                   ld hl,0792dh
090E:  4e                         ld c,(hl)
090F:  23                         inc hl
0910:  ae                         xor (hl)
0911:  47                         ld b,a
0912:  2e 00                      ld l,000h
0914:  78            sub_0914h:   ld a,b
0915:  b7                         or a
0916:  28 1f                      jr z,l0937h
0918:  7d                         ld a,l
0919:  21 24 79                   ld hl,07924h
091C:  ae                         xor (hl)
091D:  80                         add a,b
091E:  47                         ld b,a
091F:  1f                         rra
0920:  a8                         xor b
0921:  78                         ld a,b
0922:  f2 36 09                   jp p,l0936h
0925:  c6 80                      add a,080h
0927:  77                         ld (hl),a
0928:  ca 90 08                   jp z,l0890h
092B:  cd df 09                   call sub_09dfh
092E:  77                         ld (hl),a
092F:  2b            sub_092fh:   dec hl
0930:  c9                         ret
0931:  cd 55 09      l0931h:      call sub_0955h
0934:  2f                         cpl
0935:  e1                         pop hl
0936:  b7            l0936h:      or a
0937:  e1            l0937h:      pop hl
0938:  f2 78 07                   jp p,l0778h
093B:  c3 b2 07                   jp l07b2h
093E:  cd bf 09      sub_093eh:   call sub_09bfh
0941:  78                         ld a,b
0942:  b7                         or a
0943:  c8                         ret z
0944:  c6 02                      add a,002h
0946:  da b2 07                   jp c,l07b2h
0949:  47                         ld b,a
094A:  cd 16 07                   call l0716h
094D:  21 24 79                   ld hl,07924h
0950:  34                         inc (hl)
0951:  c0                         ret nz
0952:  c3 b2 07                   jp l07b2h
0955:  3a 24 79      sub_0955h:   ld a,(07924h)
0958:  b7                         or a
0959:  c8                         ret z
095A:  3a 23 79                   ld a,(07923h)
095D:  fe 2f                      cp 02fh
095F:  17            l095fh:      rla
0960:  9f            l0960h:      sbc a,a
0961:  c0                         ret nz
0962:  3c                         inc a
0963:  c9                         ret
0964:  06 88         sub_0964h:   ld b,088h
0966:  11 00 00                   ld de,RESET
0969:  21 24 79      l0969h:      ld hl,07924h
096C:  4f                         ld c,a
096D:  70                         ld (hl),b
096E:  06 00                      ld b,000h
0970:  23                         inc hl
0971:  36 80                      ld (hl),080h
0973:  17                         rla
0974:  c3 62 07                   jp l0762h
0977:  cd 94 09                   call sub_0994h
097A:  f0                         ret p
097B:  e7            l097bh:      rst 20h
097C:  fa 5b 0c                   jp m,l0c5bh
097F:  ca f6 0a                   jp z,l0af6h
0982:  21 23 79      sub_0982h:   ld hl,07923h
0985:  7e                         ld a,(hl)
0986:  ee 80                      xor 080h
0988:  77                         ld (hl),a
0989:  c9                         ret
098A:  cd 94 09                   call sub_0994h
098D:  6f            sub_098dh:   ld l,a
098E:  17                         rla
098F:  9f                         sbc a,a
0990:  67                         ld h,a
0991:  c3 9a 0a                   jp l0a9ah
0994:  e7            sub_0994h:   rst 20h
0995:  ca f6 0a                   jp z,l0af6h
0998:  f2 55 09                   jp p,sub_0955h
099B:  2a 21 79                   ld hl,(07921h)
099E:  7c            sub_099eh:   ld a,h
099F:  b5                         or l
09A0:  c8                         ret z
09A1:  7c                         ld a,h
09A2:  18 bb                      jr l095fh
09A4:  eb            sub_09a4h:   ex de,hl
09A5:  2a 21 79                   ld hl,(07921h)
09A8:  e3                         ex (sp),hl
09A9:  e5                         push hl
09AA:  2a 23 79                   ld hl,(07923h)
09AD:  e3                         ex (sp),hl
09AE:  e5                         push hl
09AF:  eb                         ex de,hl
09B0:  c9                         ret
09B1:  cd c2 09      sub_09b1h:   call sub_09c2h
09B4:  eb            l09b4h:      ex de,hl
09B5:  22 21 79                   ld (07921h),hl
09B8:  60                         ld h,b
09B9:  69                         ld l,c
09BA:  22 23 79                   ld (07923h),hl
09BD:  eb                         ex de,hl
09BE:  c9                         ret
09BF:  21 21 79      sub_09bfh:   ld hl,07921h
09C2:  5e            sub_09c2h:   ld e,(hl)
09C3:  23                         inc hl
09C4:  56            sub_09c4h:   ld d,(hl)
09C5:  23                         inc hl
09C6:  4e                         ld c,(hl)
09C7:  23                         inc hl
09C8:  46                         ld b,(hl)
09C9:  23            sub_09c9h:   inc hl
09CA:  c9                         ret
09CB:  11 21 79      sub_09cbh:   ld de,07921h
09CE:  06 04                      ld b,004h
09D0:  18 05                      jr l09d7h
09D2:  eb            l09d2h:      ex de,hl
09D3:  3a af 78      l09d3h:      ld a,(078afh)
09D6:  47                         ld b,a
09D7:  1a            l09d7h:      ld a,(de)
09D8:  77                         ld (hl),a
09D9:  13                         inc de
09DA:  23                         inc hl
09DB:  05                         dec b
09DC:  20 f9                      jr nz,l09d7h
09DE:  c9                         ret
09DF:  21 23 79      sub_09dfh:   ld hl,07923h
09E2:  7e                         ld a,(hl)
09E3:  07                         rlca
09E4:  37                         scf
09E5:  1f                         rra
09E6:  77                         ld (hl),a
09E7:  3f                         ccf
09E8:  1f                         rra
09E9:  23                         inc hl
09EA:  23                         inc hl
09EB:  77                         ld (hl),a
09EC:  79                         ld a,c
09ED:  07                         rlca
09EE:  37                         scf
09EF:  1f                         rra
09F0:  4f                         ld c,a
09F1:  1f                         rra
09F2:  ae                         xor (hl)
09F3:  c9                         ret
09F4:  21 27 79      l09f4h:      ld hl,07927h
09F7:  11 d2 09      sub_09f7h:   ld de,l09d2h
09FA:  18 06                      jr l0a02h
09FC:  21 27 79      sub_09fch:   ld hl,07927h
09FF:  11 d3 09                   ld de,l09d3h
0A02:  d5            l0a02h:      push de
0A03:  11 21 79      sub_0a03h:   ld de,07921h
0A06:  e7                         rst 20h
0A07:  d8                         ret c
0A08:  11 1d 79                   ld de,0791dh
0A0B:  c9                         ret
0A0C:  78            sub_0a0ch:   ld a,b
0A0D:  b7                         or a
0A0E:  ca 55 09                   jp z,sub_0955h
0A11:  21 5e 09                   ld hl,0095eh
0A14:  e5                         push hl
0A15:  cd 55 09                   call sub_0955h
0A18:  79                         ld a,c
0A19:  c8                         ret z
0A1A:  21 23 79                   ld hl,07923h
0A1D:  ae                         xor (hl)
0A1E:  79                         ld a,c
0A1F:  f8                         ret m
0A20:  cd 26 0a                   call sub_0a26h
0A23:  1f            l0a23h:      rra
0A24:  a9                         xor c
0A25:  c9                         ret
0A26:  23            sub_0a26h:   inc hl
0A27:  78                         ld a,b
0A28:  be                         cp (hl)
0A29:  c0                         ret nz
0A2A:  2b                         dec hl
0A2B:  79                         ld a,c
0A2C:  be                         cp (hl)
0A2D:  c0                         ret nz
0A2E:  2b                         dec hl
0A2F:  7a                         ld a,d
0A30:  be                         cp (hl)
0A31:  c0                         ret nz
0A32:  2b                         dec hl
0A33:  7b                         ld a,e
0A34:  96                         sub (hl)
0A35:  c0                         ret nz
0A36:  e1                         pop hl
0A37:  e1                         pop hl
0A38:  c9                         ret
0A39:  7a            sub_0a39h:   ld a,d
0A3A:  ac                         xor h
0A3B:  7c                         ld a,h
0A3C:  fa 5f 09                   jp m,l095fh
0A3F:  ba                         cp d
0A40:  c2 60 09                   jp nz,l0960h
0A43:  7d                         ld a,l
0A44:  93                         sub e
0A45:  c2 60 09                   jp nz,l0960h
0A48:  c9                         ret
0A49:  21 27 79      sub_0a49h:   ld hl,07927h
0A4C:  cd d3 09                   call l09d3h
0A4F:  11 2e 79      sub_0a4fh:   ld de,0792eh
0A52:  1a                         ld a,(de)
0A53:  b7                         or a
0A54:  ca 55 09                   jp z,sub_0955h
0A57:  21 5e 09                   ld hl,0095eh
0A5A:  e5                         push hl
0A5B:  cd 55 09                   call sub_0955h
0A5E:  1b                         dec de
0A5F:  1a                         ld a,(de)
0A60:  4f                         ld c,a
0A61:  c8                         ret z
0A62:  21 23 79                   ld hl,07923h
0A65:  ae                         xor (hl)
0A66:  79                         ld a,c
0A67:  f8                         ret m
0A68:  13                         inc de
0A69:  23                         inc hl
0A6A:  06 08                      ld b,008h
0A6C:  1a            l0a6ch:      ld a,(de)
0A6D:  96                         sub (hl)
0A6E:  c2 23 0a                   jp nz,l0a23h
0A71:  1b                         dec de
0A72:  2b                         dec hl
0A73:  05                         dec b
0A74:  20 f6                      jr nz,l0a6ch
0A76:  c1                         pop bc
0A77:  c9                         ret
0A78:  cd 4f 0a                   call sub_0a4fh
0A7B:  c2 5e 09                   jp nz,0095eh
0A7E:  c9                         ret
0A7F:  e7            l0a7fh:      rst 20h
0A80:  2a 21 79                   ld hl,(07921h)
0A83:  f8                         ret m
0A84:  ca f6 0a                   jp z,l0af6h
0A87:  d4 b9 0a                   call nc,sub_0ab9h
0A8A:  21 b2 07                   ld hl,l07b2h
0A8D:  e5                         push hl
0A8E:  3a 24 79      sub_0a8eh:   ld a,(07924h)
0A91:  fe 90                      cp 090h
0A93:  30 0e                      jr nc,l0aa3h
0A95:  cd fb 0a                   call sub_0afbh
0A98:  eb                         ex de,hl
0A99:  d1            l0a99h:      pop de
0A9A:  22 21 79      l0a9ah:      ld (07921h),hl
0A9D:  3e 02                      ld a,002h
0A9F:  32 af 78      l0a9fh:      ld (078afh),a
0AA2:  c9                         ret
0AA3:  01 80 90      l0aa3h:      ld bc,09080h
0AA6:  11 00 00                   ld de,RESET
0AA9:  cd 0c 0a                   call sub_0a0ch
0AAC:  c0                         ret nz
0AAD:  61                         ld h,c
0AAE:  6a                         ld l,d
0AAF:  18 e8                      jr l0a99h
0AB1:  e7            sub_0ab1h:   rst 20h
0AB2:  e0                         ret po
0AB3:  fa cc 0a                   jp m,l0acch
0AB6:  ca f6 0a                   jp z,l0af6h
0AB9:  cd bf 09      sub_0ab9h:   call sub_09bfh
0ABC:  cd ef 0a                   call 00aefh
0ABF:  78                         ld a,b
0AC0:  b7                         or a
0AC1:  c8                         ret z
0AC2:  cd df 09                   call sub_09dfh
0AC5:  21 20 79                   ld hl,07920h
0AC8:  46                         ld b,(hl)
0AC9:  c3 96 07                   jp l0796h
0ACC:  2a 21 79      l0acch:      ld hl,(07921h)
0ACF:  cd ef 0a      sub_0acfh:   call 00aefh
0AD2:  7c                         ld a,h
0AD3:  55                         ld d,l
0AD4:  1e 00                      ld e,000h
0AD6:  06 90                      ld b,090h
0AD8:  c3 69 09                   jp l0969h
0ADB:  e7            sub_0adbh:   rst 20h
0ADC:  d0                         ret nc
0ADD:  ca f6 0a                   jp z,l0af6h
0AE0:  fc cc 0a                   call m,l0acch
0AE3:  21 00 00      sub_0ae3h:   ld hl,RESET
0AE6:  22 1d 79                   ld (0791dh),hl
0AE9:  22 1f 79                   ld (0791fh),hl
0AEC:  3e 08         sub_0aech:   ld a,008h
0AEE:  01 3e 04                   ld bc,l043eh
0AF1:  c3 9f 0a                   jp l0a9fh
0AF4:  e7            sub_0af4h:   rst 20h
0AF5:  c8                         ret z
0AF6:  1e 18         l0af6h:      ld e,018h
0AF8:  c3 a2 19                   jp l19a2h
0AFB:  47            sub_0afbh:   ld b,a
0AFC:  4f                         ld c,a
0AFD:  57                         ld d,a
0AFE:  5f                         ld e,a
0AFF:  b7                         or a
0B00:  c8                         ret z
0B01:  e5                         push hl
0B02:  cd bf 09                   call sub_09bfh
0B05:  cd df 09                   call sub_09dfh
0B08:  ae                         xor (hl)
0B09:  67                         ld h,a
0B0A:  fc 1f 0b                   call m,sub_0b1fh
0B0D:  3e 98                      ld a,098h
0B0F:  90                         sub b
0B10:  cd d7 07                   call sub_07d7h
0B13:  7c                         ld a,h
0B14:  17                         rla
0B15:  dc a8 07                   call c,sub_07a8h
0B18:  06 00                      ld b,000h
0B1A:  dc c3 07                   call c,sub_07c3h
0B1D:  e1                         pop hl
0B1E:  c9                         ret
0B1F:  1b            sub_0b1fh:   dec de
0B20:  7a                         ld a,d
0B21:  a3                         and e
0B22:  3c                         inc a
0B23:  c0                         ret nz
0B24:  0b            sub_0b24h:   dec bc
0B25:  c9                         ret
0B26:  e7                         rst 20h
0B27:  f8                         ret m
0B28:  cd 55 09                   call sub_0955h
0B2B:  f2 37 0b                   jp p,l0b37h
0B2E:  cd 82 09                   call sub_0982h
0B31:  cd 37 0b                   call l0b37h
0B34:  c3 7b 09                   jp l097bh
0B37:  e7            l0b37h:      rst 20h
0B38:  f8                         ret m
0B39:  30 1e                      jr nc,l0b59h
0B3B:  28 b9                      jr z,l0af6h
0B3D:  cd 8e 0a                   call sub_0a8eh
0B40:  21 24 79      sub_0b40h:   ld hl,07924h
0B43:  7e                         ld a,(hl)
0B44:  fe 98                      cp 098h
0B46:  3a 21 79                   ld a,(07921h)
0B49:  d0                         ret nc
0B4A:  7e                         ld a,(hl)
0B4B:  cd fb 0a                   call sub_0afbh
0B4E:  36 98                      ld (hl),098h
0B50:  7b                         ld a,e
0B51:  f5                         push af
0B52:  79                         ld a,c
0B53:  17                         rla
0B54:  cd 62 07                   call l0762h
0B57:  f1                         pop af
0B58:  c9                         ret
0B59:  21 24 79      l0b59h:      ld hl,07924h
0B5C:  7e                         ld a,(hl)
0B5D:  fe 90                      cp 090h
0B5F:  da 7f 0a                   jp c,l0a7fh
0B62:  20 14                      jr nz,l0b78h
0B64:  4f                         ld c,a
0B65:  2b                         dec hl
0B66:  7e                         ld a,(hl)
0B67:  ee 80                      xor 080h
0B69:  06 06                      ld b,006h
0B6B:  2b            l0b6bh:      dec hl
0B6C:  b6                         or (hl)
0B6D:  05                         dec b
0B6E:  20 fb                      jr nz,l0b6bh
0B70:  b7                         or a
0B71:  21 00 80                   ld hl,08000h
0B74:  ca 9a 0a                   jp z,l0a9ah
0B77:  79                         ld a,c
0B78:  fe b8         l0b78h:      cp 0b8h
0B7A:  d0                         ret nc
0B7B:  f5            sub_0b7bh:   push af
0B7C:  cd bf 09                   call sub_09bfh
0B7F:  cd df 09                   call sub_09dfh
0B82:  ae                         xor (hl)
0B83:  2b                         dec hl
0B84:  36 b8                      ld (hl),0b8h
0B86:  f5                         push af
0B87:  fc a0 0b                   call m,sub_0ba0h
0B8A:  21 23 79                   ld hl,07923h
0B8D:  3e b8                      ld a,0b8h
0B8F:  90                         sub b
0B90:  cd 69 0d                   call sub_0d69h
0B93:  f1                         pop af
0B94:  fc 20 0d                   call m,sub_0d20h
0B97:  af                         xor a
0B98:  32 1c 79                   ld (0791ch),a
0B9B:  f1                         pop af
0B9C:  d0                         ret nc
0B9D:  c3 d8 0c                   jp l0cd8h
0BA0:  21 1d 79      sub_0ba0h:   ld hl,0791dh
0BA3:  7e            l0ba3h:      ld a,(hl)
0BA4:  35                         dec (hl)
0BA5:  b7                         or a
0BA6:  23                         inc hl
0BA7:  28 fa                      jr z,l0ba3h
0BA9:  c9                         ret
0BAA:  e5            sub_0baah:   push hl
0BAB:  21 00 00                   ld hl,RESET
0BAE:  78                         ld a,b
0BAF:  b1                         or c
0BB0:  28 12                      jr z,l0bc4h
0BB2:  3e 10                      ld a,010h
0BB4:  29            l0bb4h:      add hl,hl
0BB5:  da 3d 27                   jp c,l273dh
0BB8:  eb                         ex de,hl
0BB9:  29                         add hl,hl
0BBA:  eb                         ex de,hl
0BBB:  30 04                      jr nc,l0bc1h
0BBD:  09                         add hl,bc
0BBE:  da 3d 27                   jp c,l273dh
0BC1:  3d            l0bc1h:      dec a
0BC2:  20 f0                      jr nz,l0bb4h
0BC4:  eb            l0bc4h:      ex de,hl
0BC5:  e1                         pop hl
0BC6:  c9                         ret
0BC7:  7c                         ld a,h
0BC8:  17                         rla
0BC9:  9f                         sbc a,a
0BCA:  47                         ld b,a
0BCB:  cd 51 0c                   call sub_0c51h
0BCE:  79                         ld a,c
0BCF:  98                         sbc a,b
0BD0:  18 03                      jr l0bd5h
0BD2:  7c            sub_0bd2h:   ld a,h
0BD3:  17                         rla
0BD4:  9f                         sbc a,a
0BD5:  47            l0bd5h:      ld b,a
0BD6:  e5                         push hl
0BD7:  7a                         ld a,d
0BD8:  17                         rla
0BD9:  9f                         sbc a,a
0BDA:  19                         add hl,de
0BDB:  88                         adc a,b
0BDC:  0f                         rrca
0BDD:  ac                         xor h
0BDE:  f2 99 0a                   jp p,l0a99h
0BE1:  c5                         push bc
0BE2:  eb                         ex de,hl
0BE3:  cd cf 0a                   call sub_0acfh
0BE6:  f1                         pop af
0BE7:  e1                         pop hl
0BE8:  cd a4 09                   call sub_09a4h
0BEB:  eb                         ex de,hl
0BEC:  cd 6b 0c                   call sub_0c6bh
0BEF:  c3 8f 0f                   jp l0f8fh
0BF2:  7c                         ld a,h
0BF3:  b5                         or l
0BF4:  ca 9a 0a                   jp z,l0a9ah
0BF7:  e5                         push hl
0BF8:  d5                         push de
0BF9:  cd 45 0c                   call sub_0c45h
0BFC:  c5                         push bc
0BFD:  44                         ld b,h
0BFE:  4d                         ld c,l
0BFF:  21 00 00                   ld hl,RESET
0C02:  3e 10                      ld a,010h
0C04:  29            l0c04h:      add hl,hl
0C05:  38 1f                      jr c,$+33
0C07:  eb                         ex de,hl
0C08:  29                         add hl,hl
0C09:  eb                         ex de,hl
0C0A:  30 04                      jr nc,l0c10h
0C0C:  09                         add hl,bc
0C0D:  da 26 0c                   jp c,00c26h
0C10:  3d            l0c10h:      dec a
0C11:  20 f1                      jr nz,l0c04h
0C13:  c1                         pop bc
0C14:  d1                         pop de
0C15:  7c                         ld a,h
0C16:  b7                         or a
0C17:  fa 1f 0c                   jp m,l0c1fh
0C1A:  d1                         pop de
0C1B:  78                         ld a,b
0C1C:  c3 4d 0c                   jp l0c4dh
0C1F:  ee 80         l0c1fh:      xor 080h
0C21:  b5                         or l
0C22:  28 13                      jr z,l0c37h
0C24:  eb                         ex de,hl
0C25:  01 c1 e1                   ld bc,0e1c1h
0C28:  cd cf 0a                   call sub_0acfh
0C2B:  e1                         pop hl
0C2C:  cd a4 09                   call sub_09a4h
0C2F:  cd cf 0a                   call sub_0acfh
0C32:  c1            l0c32h:      pop bc
0C33:  d1                         pop de
0C34:  c3 47 08                   jp l0847h
0C37:  78            l0c37h:      ld a,b
0C38:  b7                         or a
0C39:  c1                         pop bc
0C3A:  fa 9a 0a                   jp m,l0a9ah
0C3D:  d5                         push de
0C3E:  cd cf 0a                   call sub_0acfh
0C41:  d1                         pop de
0C42:  c3 82 09                   jp sub_0982h
0C45:  7c            sub_0c45h:   ld a,h
0C46:  aa                         xor d
0C47:  47                         ld b,a
0C48:  cd 4c 0c                   call sub_0c4ch
0C4B:  eb                         ex de,hl
0C4C:  7c            sub_0c4ch:   ld a,h
0C4D:  b7            l0c4dh:      or a
0C4E:  f2 9a 0a                   jp p,l0a9ah
0C51:  af            sub_0c51h:   xor a
0C52:  4f                         ld c,a
0C53:  95                         sub l
0C54:  6f                         ld l,a
0C55:  79                         ld a,c
0C56:  9c                         sbc a,h
0C57:  67                         ld h,a
0C58:  c3 9a 0a                   jp l0a9ah
0C5B:  2a 21 79      l0c5bh:      ld hl,(07921h)
0C5E:  cd 51 0c                   call sub_0c51h
0C61:  7c                         ld a,h
0C62:  ee 80                      xor 080h
0C64:  b5                         or l
0C65:  c0                         ret nz
0C66:  eb            sub_0c66h:   ex de,hl
0C67:  cd ef 0a                   call 00aefh
0C6A:  af                         xor a
0C6B:  06 98         sub_0c6bh:   ld b,098h
0C6D:  c3 69 09                   jp l0969h
0C70:  21 2d 79                   ld hl,0792dh
0C73:  7e                         ld a,(hl)
0C74:  ee 80                      xor 080h
0C76:  77                         ld (hl),a
0C77:  21 2e 79      sub_0c77h:   ld hl,0792eh
0C7A:  7e                         ld a,(hl)
0C7B:  b7                         or a
0C7C:  c8                         ret z
0C7D:  47                         ld b,a
0C7E:  2b                         dec hl
0C7F:  4e                         ld c,(hl)
0C80:  11 24 79                   ld de,07924h
0C83:  1a                         ld a,(de)
0C84:  b7                         or a
0C85:  ca f4 09                   jp z,l09f4h
0C88:  90                         sub b
0C89:  30 16                      jr nc,l0ca1h
0C8B:  2f                         cpl
0C8C:  3c                         inc a
0C8D:  f5                         push af
0C8E:  0e 08                      ld c,008h
0C90:  23                         inc hl
0C91:  e5                         push hl
0C92:  1a            l0c92h:      ld a,(de)
0C93:  46                         ld b,(hl)
0C94:  77                         ld (hl),a
0C95:  78                         ld a,b
0C96:  12                         ld (de),a
0C97:  1b                         dec de
0C98:  2b                         dec hl
0C99:  0d                         dec c
0C9A:  20 f6                      jr nz,l0c92h
0C9C:  e1                         pop hl
0C9D:  46                         ld b,(hl)
0C9E:  2b                         dec hl
0C9F:  4e                         ld c,(hl)
0CA0:  f1                         pop af
0CA1:  fe 39         l0ca1h:      cp 039h
0CA3:  d0                         ret nc
0CA4:  f5                         push af
0CA5:  cd df 09                   call sub_09dfh
0CA8:  23                         inc hl
0CA9:  36 00                      ld (hl),000h
0CAB:  47                         ld b,a
0CAC:  f1                         pop af
0CAD:  21 2d 79                   ld hl,0792dh
0CB0:  cd 69 0d                   call sub_0d69h
0CB3:  3a 26 79                   ld a,(07926h)
0CB6:  32 1c 79                   ld (0791ch),a
0CB9:  78                         ld a,b
0CBA:  b7                         or a
0CBB:  f2 cf 0c                   jp p,l0ccfh
0CBE:  cd 33 0d                   call sub_0d33h
0CC1:  d2 0e 0d                   jp nc,l0d0eh
0CC4:  eb                         ex de,hl
0CC5:  34                         inc (hl)
0CC6:  ca b2 07                   jp z,l07b2h
0CC9:  cd 90 0d                   call sub_0d90h
0CCC:  c3 0e 0d                   jp l0d0eh
0CCF:  cd 45 0d      l0ccfh:      call sub_0d45h
0CD2:  21 25 79                   ld hl,07925h
0CD5:  dc 57 0d                   call c,sub_0d57h
0CD8:  af            l0cd8h:      xor a
0CD9:  47            l0cd9h:      ld b,a
0CDA:  3a 23 79                   ld a,(07923h)
0CDD:  b7                         or a
0CDE:  20 1e                      jr nz,l0cfeh
0CE0:  21 1c 79                   ld hl,0791ch
0CE3:  0e 08                      ld c,008h
0CE5:  56            l0ce5h:      ld d,(hl)
0CE6:  77                         ld (hl),a
0CE7:  7a                         ld a,d
0CE8:  23                         inc hl
0CE9:  0d                         dec c
0CEA:  20 f9                      jr nz,l0ce5h
0CEC:  78                         ld a,b
0CED:  d6 08                      sub 008h
0CEF:  fe c0                      cp 0c0h
0CF1:  20 e6                      jr nz,l0cd9h
0CF3:  c3 78 07                   jp l0778h
0CF6:  05            l0cf6h:      dec b
0CF7:  21 1c 79                   ld hl,0791ch
0CFA:  cd 97 0d                   call sub_0d97h
0CFD:  b7                         or a
0CFE:  f2 f6 0c      l0cfeh:      jp p,l0cf6h
0D01:  78                         ld a,b
0D02:  b7                         or a
0D03:  28 09                      jr z,l0d0eh
0D05:  21 24 79                   ld hl,07924h
0D08:  86                         add a,(hl)
0D09:  77                         ld (hl),a
0D0A:  d2 78 07                   jp nc,l0778h
0D0D:  c8                         ret z
0D0E:  3a 1c 79      l0d0eh:      ld a,(0791ch)
0D11:  b7            l0d11h:      or a
0D12:  fc 20 0d                   call m,sub_0d20h
0D15:  21 25 79                   ld hl,07925h
0D18:  7e                         ld a,(hl)
0D19:  e6 80                      and 080h
0D1B:  2b                         dec hl
0D1C:  2b                         dec hl
0D1D:  ae                         xor (hl)
0D1E:  77                         ld (hl),a
0D1F:  c9                         ret
0D20:  21 1d 79      sub_0d20h:   ld hl,0791dh
0D23:  06 07                      ld b,007h
0D25:  34            l0d25h:      inc (hl)
0D26:  c0                         ret nz
0D27:  23                         inc hl
0D28:  05                         dec b
0D29:  20 fa                      jr nz,l0d25h
0D2B:  34                         inc (hl)
0D2C:  ca b2 07                   jp z,l07b2h
0D2F:  2b                         dec hl
0D30:  36 80                      ld (hl),080h
0D32:  c9                         ret
0D33:  21 27 79      sub_0d33h:   ld hl,07927h
0D36:  11 1d 79      sub_0d36h:   ld de,0791dh
0D39:  0e 07         sub_0d39h:   ld c,007h
0D3B:  af                         xor a
0D3C:  1a            l0d3ch:      ld a,(de)
0D3D:  8e                         adc a,(hl)
0D3E:  12                         ld (de),a
0D3F:  13                         inc de
0D40:  23                         inc hl
0D41:  0d                         dec c
0D42:  20 f8                      jr nz,l0d3ch
0D44:  c9                         ret
0D45:  21 27 79      sub_0d45h:   ld hl,07927h
0D48:  11 1d 79      sub_0d48h:   ld de,0791dh
0D4B:  0e 07         sub_0d4bh:   ld c,007h
0D4D:  af                         xor a
0D4E:  1a            l0d4eh:      ld a,(de)
0D4F:  9e                         sbc a,(hl)
0D50:  12                         ld (de),a
0D51:  13                         inc de
0D52:  23                         inc hl
0D53:  0d                         dec c
0D54:  20 f8                      jr nz,l0d4eh
0D56:  c9                         ret
0D57:  7e            sub_0d57h:   ld a,(hl)
0D58:  2f                         cpl
0D59:  77                         ld (hl),a
0D5A:  21 1c 79                   ld hl,0791ch
0D5D:  06 08                      ld b,008h
0D5F:  af                         xor a
0D60:  4f            l0d60h:      ld c,a
0D61:  79            l0d61h:      ld a,c
0D62:  9e                         sbc a,(hl)
0D63:  77                         ld (hl),a
0D64:  23                         inc hl
0D65:  05                         dec b
0D66:  20 f9                      jr nz,l0d61h
0D68:  c9                         ret
0D69:  71            sub_0d69h:   ld (hl),c
0D6A:  e5                         push hl
0D6B:  d6 08         l0d6bh:      sub 008h
0D6D:  38 0e                      jr c,l0d7dh
0D6F:  e1                         pop hl
0D70:  e5            sub_0d70h:   push hl
0D71:  11 00 08                   ld de,l0800h
0D74:  4e            l0d74h:      ld c,(hl)
0D75:  73                         ld (hl),e
0D76:  59                         ld e,c
0D77:  2b                         dec hl
0D78:  15                         dec d
0D79:  20 f9                      jr nz,l0d74h
0D7B:  18 ee                      jr l0d6bh
0D7D:  c6 09         l0d7dh:      add a,009h
0D7F:  57                         ld d,a
0D80:  af            l0d80h:      xor a
0D81:  e1                         pop hl
0D82:  15                         dec d
0D83:  c8                         ret z
0D84:  e5            l0d84h:      push hl
0D85:  1e 08                      ld e,008h
0D87:  7e            l0d87h:      ld a,(hl)
0D88:  1f                         rra
0D89:  77                         ld (hl),a
0D8A:  2b                         dec hl
0D8B:  1d                         dec e
0D8C:  20 f9                      jr nz,l0d87h
0D8E:  18 f0                      jr l0d80h
0D90:  21 23 79      sub_0d90h:   ld hl,07923h
0D93:  16 01                      ld d,001h
0D95:  18 ed                      jr l0d84h
0D97:  0e 08         sub_0d97h:   ld c,008h
0D99:  7e            l0d99h:      ld a,(hl)
0D9A:  17                         rla
0D9B:  77                         ld (hl),a
0D9C:  23                         inc hl
0D9D:  0d                         dec c
0D9E:  20 f9                      jr nz,l0d99h
0DA0:  c9                         ret
0DA1:  cd 55 09      sub_0da1h:   call sub_0955h
0DA4:  c8                         ret z
0DA5:  cd 0a 09                   call 0090ah
0DA8:  cd 39 0e                   call sub_0e39h
0DAB:  71                         ld (hl),c
0DAC:  13                         inc de
0DAD:  06 07                      ld b,007h
0DAF:  1a            l0dafh:      ld a,(de)
0DB0:  13                         inc de
0DB1:  b7                         or a
0DB2:  d5                         push de
0DB3:  28 17                      jr z,l0dcch
0DB5:  0e 08                      ld c,008h
0DB7:  c5            l0db7h:      push bc
0DB8:  1f                         rra
0DB9:  47                         ld b,a
0DBA:  dc 33 0d                   call c,sub_0d33h
0DBD:  cd 90 0d                   call sub_0d90h
0DC0:  78                         ld a,b
0DC1:  c1                         pop bc
0DC2:  0d                         dec c
0DC3:  20 f2                      jr nz,l0db7h
0DC5:  d1            l0dc5h:      pop de
0DC6:  05                         dec b
0DC7:  20 e6                      jr nz,l0dafh
0DC9:  c3 d8 0c                   jp l0cd8h
0DCC:  21 23 79      l0dcch:      ld hl,07923h
0DCF:  cd 70 0d                   call sub_0d70h
0DD2:  18 f1                      jr l0dc5h
0DD4:  00            l0dd4h:      nop
0DD5:  00                         nop
0DD6:  00                         nop
0DD7:  00                         nop
0DD8:  00            l0dd8h:      nop
0DD9:  00                         nop
0DDA:  20 84                      jr nz,l0d60h
0DDC:  11 d4 0d      sub_0ddch:   ld de,l0dd4h
0DDF:  21 27 79                   ld hl,07927h
0DE2:  cd d3 09                   call l09d3h
0DE5:  3a 2e 79                   ld a,(0792eh)
0DE8:  b7                         or a
0DE9:  ca 9a 19                   jp z,0199ah
0DEC:  cd 07 09                   call sub_0907h
0DEF:  34                         inc (hl)
0DF0:  34                         inc (hl)
0DF1:  cd 39 0e                   call sub_0e39h
0DF4:  21 51 79                   ld hl,07951h
0DF7:  71                         ld (hl),c
0DF8:  41                         ld b,c
0DF9:  11 4a 79      l0df9h:      ld de,0794ah
0DFC:  21 27 79                   ld hl,07927h
0DFF:  cd 4b 0d                   call sub_0d4bh
0E02:  1a                         ld a,(de)
0E03:  99                         sbc a,c
0E04:  3f                         ccf
0E05:  38 0b                      jr c,$+13
0E07:  11 4a 79                   ld de,0794ah
0E0A:  21 27 79                   ld hl,07927h
0E0D:  cd 39 0d                   call sub_0d39h
0E10:  af                         xor a
0E11:  da 12 04                   jp c,00412h
0E14:  3a 23 79                   ld a,(07923h)
0E17:  3c                         inc a
0E18:  3d                         dec a
0E19:  1f                         rra
0E1A:  fa 11 0d                   jp m,l0d11h
0E1D:  17                         rla
0E1E:  21 1d 79                   ld hl,0791dh
0E21:  0e 07                      ld c,007h
0E23:  cd 99 0d                   call l0d99h
0E26:  21 4a 79                   ld hl,0794ah
0E29:  cd 97 0d                   call sub_0d97h
0E2C:  78                         ld a,b
0E2D:  b7                         or a
0E2E:  20 c9                      jr nz,l0df9h
0E30:  21 24 79                   ld hl,07924h
0E33:  35                         dec (hl)
0E34:  20 c3                      jr nz,l0df9h
0E36:  c3 b2 07                   jp l07b2h
0E39:  79            sub_0e39h:   ld a,c
0E3A:  32 2d 79      l0e3ah:      ld (0792dh),a
0E3D:  2b                         dec hl
0E3E:  11 50 79                   ld de,07950h
0E41:  01 00 07                   ld bc,00700h
0E44:  7e            l0e44h:      ld a,(hl)
0E45:  12                         ld (de),a
0E46:  71                         ld (hl),c
0E47:  1b                         dec de
0E48:  2b                         dec hl
0E49:  05                         dec b
0E4A:  20 f8                      jr nz,l0e44h
0E4C:  c9                         ret
0E4D:  cd fc 09      sub_0e4dh:   call sub_09fch
0E50:  eb                         ex de,hl
0E51:  2b                         dec hl
0E52:  7e                         ld a,(hl)
0E53:  b7                         or a
0E54:  c8                         ret z
0E55:  c6 02                      add a,002h
0E57:  da b2 07                   jp c,l07b2h
0E5A:  77                         ld (hl),a
0E5B:  e5                         push hl
0E5C:  cd 77 0c                   call sub_0c77h
0E5F:  e1                         pop hl
0E60:  34                         inc (hl)
0E61:  c0                         ret nz
0E62:  c3 b2 07                   jp l07b2h
0E65:  cd 78 07      l0e65h:      call l0778h
0E68:  cd ec 0a                   call sub_0aech
0E6B:  f6 af                      or 0afh
0E6D:  eb                         ex de,hl
0E6E:  01 ff 00                   ld bc,l00ffh
0E71:  60                         ld h,b
0E72:  68                         ld l,b
0E73:  cc 9a 0a                   call z,l0a9ah
0E76:  eb                         ex de,hl
0E77:  7e                         ld a,(hl)
0E78:  fe 2d                      cp 02dh
0E7A:  f5                         push af
0E7B:  ca 83 0e                   jp z,l0e83h
0E7E:  fe 2b                      cp 02bh
0E80:  28 01                      jr z,l0e83h
0E82:  2b                         dec hl
0E83:  d7            l0e83h:      rst 10h
0E84:  da 29 0f                   jp c,l0f29h
0E87:  fe 2e                      cp 02eh
0E89:  ca e4 0e                   jp z,l0ee4h
0E8C:  fe 45                      cp 045h
0E8E:  28 14                      jr z,l0ea4h
0E90:  fe 25                      cp 025h
0E92:  ca ee 0e                   jp z,l0eeeh
0E95:  fe 23                      cp 023h
0E97:  ca f5 0e                   jp z,l0ef5h
0E9A:  fe 21                      cp 021h
0E9C:  ca f6 0e                   jp z,l0ef6h
0E9F:  fe 44                      cp 044h
0EA1:  20 24                      jr nz,l0ec7h
0EA3:  b7                         or a
0EA4:  cd fb 0e      l0ea4h:      call sub_0efbh
0EA7:  e5                         push hl
0EA8:  21 bd 0e                   ld hl,l0ebdh
0EAB:  e3                         ex (sp),hl
0EAC:  d7                         rst 10h
0EAD:  15                         dec d
0EAE:  fe ce                      cp 0ceh
0EB0:  c8                         ret z
0EB1:  fe 2d                      cp 02dh
0EB3:  c8                         ret z
0EB4:  14                         inc d
0EB5:  fe cd                      cp 0cdh
0EB7:  c8                         ret z
0EB8:  fe 2b                      cp 02bh
0EBA:  c8                         ret z
0EBB:  2b                         dec hl
0EBC:  f1                         pop af
0EBD:  d7            l0ebdh:      rst 10h
0EBE:  da 94 0f                   jp c,l0f94h
0EC1:  14                         inc d
0EC2:  20 03                      jr nz,l0ec7h
0EC4:  af                         xor a
0EC5:  93                         sub e
0EC6:  5f                         ld e,a
0EC7:  e5            l0ec7h:      push hl
0EC8:  7b                         ld a,e
0EC9:  90                         sub b
0ECA:  f4 0a 0f      l0ecah:      call p,sub_0f0ah
0ECD:  fc 18 0f                   call m,sub_0f18h
0ED0:  20 f8                      jr nz,l0ecah
0ED2:  e1                         pop hl
0ED3:  f1                         pop af
0ED4:  e5                         push hl
0ED5:  cc 7b 09                   call z,l097bh
0ED8:  e1                         pop hl
0ED9:  e7                         rst 20h
0EDA:  e8                         ret pe
0EDB:  e5                         push hl
0EDC:  21 90 08                   ld hl,l0890h
0EDF:  e5                         push hl
0EE0:  cd a3 0a                   call l0aa3h
0EE3:  c9                         ret
0EE4:  e7            l0ee4h:      rst 20h
0EE5:  0c                         inc c
0EE6:  20 df                      jr nz,l0ec7h
0EE8:  dc fb 0e                   call c,sub_0efbh
0EEB:  c3 83 0e                   jp l0e83h
0EEE:  e7            l0eeeh:      rst 20h
0EEF:  f2 97 19                   jp p,l1997h
0EF2:  23            l0ef2h:      inc hl
0EF3:  18 d2                      jr l0ec7h
0EF5:  b7            l0ef5h:      or a
0EF6:  cd fb 0e      l0ef6h:      call sub_0efbh
0EF9:  18 f7                      jr l0ef2h
0EFB:  e5            sub_0efbh:   push hl
0EFC:  d5                         push de
0EFD:  c5                         push bc
0EFE:  f5                         push af
0EFF:  cc b1 0a                   call z,sub_0ab1h
0F02:  f1                         pop af
0F03:  c4 db 0a                   call nz,sub_0adbh
0F06:  c1                         pop bc
0F07:  d1                         pop de
0F08:  e1                         pop hl
0F09:  c9                         ret
0F0A:  c8            sub_0f0ah:   ret z
0F0B:  f5            sub_0f0bh:   push af
0F0C:  e7                         rst 20h
0F0D:  f5                         push af
0F0E:  e4 3e 09                   call po,sub_093eh
0F11:  f1                         pop af
0F12:  ec 4d 0e                   call pe,sub_0e4dh
0F15:  f1                         pop af
0F16:  3d            sub_0f16h:   dec a
0F17:  c9                         ret
0F18:  d5            sub_0f18h:   push de
0F19:  e5                         push hl
0F1A:  f5                         push af
0F1B:  e7                         rst 20h
0F1C:  f5                         push af
0F1D:  e4 97 08                   call po,sub_0897h
0F20:  f1                         pop af
0F21:  ec dc 0d                   call pe,sub_0ddch
0F24:  f1                         pop af
0F25:  e1                         pop hl
0F26:  d1                         pop de
0F27:  3c                         inc a
0F28:  c9                         ret
0F29:  d5            l0f29h:      push de
0F2A:  78                         ld a,b
0F2B:  89                         adc a,c
0F2C:  47                         ld b,a
0F2D:  c5                         push bc
0F2E:  e5                         push hl
0F2F:  7e                         ld a,(hl)
0F30:  d6 30                      sub 030h
0F32:  f5                         push af
0F33:  e7                         rst 20h
0F34:  f2 5d 0f                   jp p,l0f5dh
0F37:  2a 21 79                   ld hl,(07921h)
0F3A:  11 cd 0c                   ld de,00ccdh
0F3D:  df                         rst 18h
0F3E:  30 19                      jr nc,l0f59h
0F40:  54                         ld d,h
0F41:  5d                         ld e,l
0F42:  29                         add hl,hl
0F43:  29                         add hl,hl
0F44:  19                         add hl,de
0F45:  29                         add hl,hl
0F46:  f1                         pop af
0F47:  4f                         ld c,a
0F48:  09                         add hl,bc
0F49:  7c                         ld a,h
0F4A:  b7                         or a
0F4B:  fa 57 0f                   jp m,l0f57h
0F4E:  22 21 79                   ld (07921h),hl
0F51:  e1            l0f51h:      pop hl
0F52:  c1                         pop bc
0F53:  d1                         pop de
0F54:  c3 83 0e                   jp l0e83h
0F57:  79            l0f57h:      ld a,c
0F58:  f5                         push af
0F59:  cd cc 0a      l0f59h:      call l0acch
0F5C:  37                         scf
0F5D:  30 18         l0f5dh:      jr nc,l0f77h
0F5F:  01 74 94                   ld bc,09474h
0F62:  11 00 24                   ld de,l2400h
0F65:  cd 0c 0a                   call sub_0a0ch
0F68:  f2 74 0f                   jp p,l0f74h
0F6B:  cd 3e 09                   call sub_093eh
0F6E:  f1                         pop af
0F6F:  cd 89 0f                   call sub_0f89h
0F72:  18 dd                      jr l0f51h
0F74:  cd e3 0a      l0f74h:      call sub_0ae3h
0F77:  cd 4d 0e      l0f77h:      call sub_0e4dh
0F7A:  cd fc 09                   call sub_09fch
0F7D:  f1                         pop af
0F7E:  cd 64 09                   call sub_0964h
0F81:  cd e3 0a                   call sub_0ae3h
0F84:  cd 77 0c                   call sub_0c77h
0F87:  18 c8                      jr l0f51h
0F89:  cd a4 09      sub_0f89h:   call sub_09a4h
0F8C:  cd 64 09                   call sub_0964h
0F8F:  c1            l0f8fh:      pop bc
0F90:  d1                         pop de
0F91:  c3 16 07                   jp l0716h
0F94:  7b            l0f94h:      ld a,e
0F95:  fe 0a                      cp 00ah
0F97:  30 09                      jr nc,$+11
0F99:  07                         rlca
0F9A:  07                         rlca
0F9B:  83                         add a,e
0F9C:  07                         rlca
0F9D:  86                         add a,(hl)
0F9E:  d6 30                      sub 030h
0FA0:  5f                         ld e,a
0FA1:  fa 1e 32                   jp m,0321eh
0FA4:  c3 bd 0e                   jp l0ebdh
0FA7:  e5            sub_0fa7h:   push hl
0FA8:  21 24 19                   ld hl,l1924h
0FAB:  cd a7 28                   call OUTSTR
0FAE:  e1                         pop hl
0FAF:  cd 9a 0a      sub_0fafh:   call l0a9ah
0FB2:  af                         xor a
0FB3:  cd 34 10                   call sub_1034h
0FB6:  b6                         or (hl)
0FB7:  cd d9 0f                   call sub_0fd9h
0FBA:  c3 a6 28                   jp l28a6h
0FBD:  af            sub_0fbdh:   xor a
0FBE:  cd 34 10      sub_0fbeh:   call sub_1034h
0FC1:  e6 08                      and 008h
0FC3:  28 02                      jr z,l0fc7h
0FC5:  36 2b                      ld (hl),02bh
0FC7:  eb            l0fc7h:      ex de,hl
0FC8:  cd 94 09                   call sub_0994h
0FCB:  eb                         ex de,hl
0FCC:  f2 d9 0f                   jp p,sub_0fd9h
0FCF:  36 2d                      ld (hl),02dh
0FD1:  c5                         push bc
0FD2:  e5                         push hl
0FD3:  cd 7b 09                   call l097bh
0FD6:  e1                         pop hl
0FD7:  c1                         pop bc
0FD8:  b4                         or h
0FD9:  23            sub_0fd9h:   inc hl
0FDA:  36 30                      ld (hl),030h
0FDC:  3a d8 78                   ld a,(078d8h)
0FDF:  57                         ld d,a
0FE0:  17                         rla
0FE1:  3a af 78                   ld a,(078afh)
0FE4:  da 9a 10                   jp c,l109ah
0FE7:  ca 92 10                   jp z,l1092h
0FEA:  fe 04                      cp 004h
0FEC:  d2 3d 10                   jp nc,l103dh
0FEF:  01 00 00                   ld bc,RESET
0FF2:  cd 2f 13                   call sub_132fh
0FF5:  21 30 79      sub_0ff5h:   ld hl,07930h
0FF8:  46                         ld b,(hl)
0FF9:  0e 20                      ld c,020h
0FFB:  3a d8 78                   ld a,(078d8h)
0FFE:  5f                         ld e,a
0FFF:  e6 20                      and 020h
1001:  28 07                      jr z,l100ah
1003:  78                         ld a,b
1004:  b9                         cp c
1005:  0e 2a                      ld c,02ah
1007:  20 01                      jr nz,l100ah
1009:  41                         ld b,c
100A:  71            l100ah:      ld (hl),c
100B:  d7                         rst 10h
100C:  28 14                      jr z,l1022h
100E:  fe 45                      cp 045h
1010:  28 10                      jr z,l1022h
1012:  fe 44                      cp 044h
1014:  28 0c                      jr z,l1022h
1016:  fe 30                      cp 030h
1018:  28 f0                      jr z,l100ah
101A:  fe 2c                      cp 02ch
101C:  28 ec                      jr z,l100ah
101E:  fe 2e                      cp 02eh
1020:  20 03                      jr nz,l1025h
1022:  2b            l1022h:      dec hl
1023:  36 30                      ld (hl),030h
1025:  7b            l1025h:      ld a,e
1026:  e6 10                      and 010h
1028:  28 03                      jr z,l102dh
102A:  2b                         dec hl
102B:  36 24                      ld (hl),024h
102D:  7b            l102dh:      ld a,e
102E:  e6 04                      and 004h
1030:  c0                         ret nz
1031:  2b                         dec hl
1032:  70                         ld (hl),b
1033:  c9                         ret
1034:  32 d8 78      sub_1034h:   ld (078d8h),a
1037:  21 30 79                   ld hl,07930h
103A:  36 20                      ld (hl),020h
103C:  c9                         ret
103D:  fe 05         l103dh:      cp 005h
103F:  e5                         push hl
1040:  de 00                      sbc a,000h
1042:  17                         rla
1043:  57                         ld d,a
1044:  14                         inc d
1045:  cd 01 12                   call sub_1201h
1048:  01 00 03                   ld bc,l0300h
104B:  82                         add a,d
104C:  fa 57 10                   jp m,l1057h
104F:  14                         inc d
1050:  ba                         cp d
1051:  30 04                      jr nc,l1057h
1053:  3c                         inc a
1054:  47                         ld b,a
1055:  3e 02                      ld a,002h
1057:  d6 02         l1057h:      sub 002h
1059:  e1                         pop hl
105A:  f5                         push af
105B:  cd 91 12                   call sub_1291h
105E:  36 30                      ld (hl),030h
1060:  cc c9 09                   call z,sub_09c9h
1063:  cd a4 12                   call sub_12a4h
1066:  2b            l1066h:      dec hl
1067:  7e                         ld a,(hl)
1068:  fe 30                      cp 030h
106A:  28 fa                      jr z,l1066h
106C:  fe 2e                      cp 02eh
106E:  c4 c9 09                   call nz,sub_09c9h
1071:  f1                         pop af
1072:  28 1f                      jr z,l1093h
1074:  f5            sub_1074h:   push af
1075:  e7                         rst 20h
1076:  3e 22                      ld a,022h
1078:  8f                         adc a,a
1079:  77                         ld (hl),a
107A:  23                         inc hl
107B:  f1                         pop af
107C:  36 2b                      ld (hl),02bh
107E:  f2 85 10                   jp p,l1085h
1081:  36 2d                      ld (hl),02dh
1083:  2f                         cpl
1084:  3c                         inc a
1085:  06 2f         l1085h:      ld b,02fh
1087:  04            l1087h:      inc b
1088:  d6 0a                      sub 00ah
108A:  30 fb                      jr nc,l1087h
108C:  c6 3a                      add a,03ah
108E:  23                         inc hl
108F:  70                         ld (hl),b
1090:  23                         inc hl
1091:  77                         ld (hl),a
1092:  23            l1092h:      inc hl
1093:  36 00         l1093h:      ld (hl),000h
1095:  eb                         ex de,hl
1096:  21 30 79                   ld hl,07930h
1099:  c9                         ret
109A:  23            l109ah:      inc hl
109B:  c5                         push bc
109C:  fe 04                      cp 004h
109E:  7a                         ld a,d
109F:  d2 09 11                   jp nc,l1109h
10A2:  1f                         rra
10A3:  da a3 11                   jp c,l11a3h
10A6:  01 03 06                   ld bc,l0603h
10A9:  cd 89 12                   call sub_1289h
10AC:  d1                         pop de
10AD:  7a                         ld a,d
10AE:  d6 05                      sub 005h
10B0:  f4 69 12                   call p,sub_1269h
10B3:  cd 2f 13                   call sub_132fh
10B6:  7b            l10b6h:      ld a,e
10B7:  b7                         or a
10B8:  cc 2f 09                   call z,sub_092fh
10BB:  3d                         dec a
10BC:  f4 69 12                   call p,sub_1269h
10BF:  e5            l10bfh:      push hl
10C0:  cd f5 0f                   call sub_0ff5h
10C3:  e1                         pop hl
10C4:  28 02                      jr z,l10c8h
10C6:  70                         ld (hl),b
10C7:  23                         inc hl
10C8:  36 00         l10c8h:      ld (hl),000h
10CA:  21 2f 79                   ld hl,0792fh
10CD:  23            l10cdh:      inc hl
10CE:  3a f3 78      l10ceh:      ld a,(078f3h)
10D1:  95                         sub l
10D2:  92                         sub d
10D3:  c8                         ret z
10D4:  7e                         ld a,(hl)
10D5:  fe 20                      cp 020h
10D7:  28 f4                      jr z,l10cdh
10D9:  fe 2a                      cp 02ah
10DB:  28 f0                      jr z,l10cdh
10DD:  2b                         dec hl
10DE:  e5                         push hl
10DF:  f5            l10dfh:      push af
10E0:  01 df 10                   ld bc,l10dfh
10E3:  c5                         push bc
10E4:  d7                         rst 10h
10E5:  fe 2d                      cp 02dh
10E7:  c8                         ret z
10E8:  fe 2b                      cp 02bh
10EA:  c8                         ret z
10EB:  fe 24                      cp 024h
10ED:  c8                         ret z
10EE:  c1                         pop bc
10EF:  fe 30                      cp 030h
10F1:  20 0f                      jr nz,l1102h
10F3:  23                         inc hl
10F4:  d7                         rst 10h
10F5:  30 0b                      jr nc,l1102h
10F7:  2b                         dec hl
10F8:  01 2b 77                   ld bc,0772bh
10FB:  f1                         pop af
10FC:  28 fb                      jr z,$-3
10FE:  c1                         pop bc
10FF:  c3 ce 10                   jp l10ceh
1102:  f1            l1102h:      pop af
1103:  28 fd                      jr z,l1102h
1105:  e1                         pop hl
1106:  36 25                      ld (hl),025h
1108:  c9                         ret
1109:  e5            l1109h:      push hl
110A:  1f                         rra
110B:  da aa 11                   jp c,l11aah
110E:  28 14                      jr z,l1124h
1110:  11 84 13                   ld de,l1384h
1113:  cd 49 0a                   call sub_0a49h
1116:  16 10                      ld d,010h
1118:  fa 32 11                   jp m,l1132h
111B:  e1            l111bh:      pop hl
111C:  c1                         pop bc
111D:  cd bd 0f                   call sub_0fbdh
1120:  2b                         dec hl
1121:  36 25                      ld (hl),025h
1123:  c9                         ret
1124:  01 0e b6      l1124h:      ld bc,0b60eh
1127:  11 ca 1b                   ld de,l1bcah
112A:  cd 0c 0a                   call sub_0a0ch
112D:  f2 1b 11                   jp p,l111bh
1130:  16 06                      ld d,006h
1132:  cd 55 09      l1132h:      call sub_0955h
1135:  c4 01 12                   call nz,sub_1201h
1138:  e1                         pop hl
1139:  c1                         pop bc
113A:  fa 57 11                   jp m,l1157h
113D:  c5                         push bc
113E:  5f                         ld e,a
113F:  78                         ld a,b
1140:  92                         sub d
1141:  93                         sub e
1142:  f4 69 12                   call p,sub_1269h
1145:  cd 7d 12                   call sub_127dh
1148:  cd a4 12                   call sub_12a4h
114B:  b3                         or e
114C:  c4 77 12                   call nz,sub_1277h
114F:  b3                         or e
1150:  c4 91 12                   call nz,sub_1291h
1153:  d1                         pop de
1154:  c3 b6 10                   jp l10b6h
1157:  5f            l1157h:      ld e,a
1158:  79                         ld a,c
1159:  b7                         or a
115A:  c4 16 0f                   call nz,sub_0f16h
115D:  83                         add a,e
115E:  fa 62 11                   jp m,l1162h
1161:  af                         xor a
1162:  c5            l1162h:      push bc
1163:  f5                         push af
1164:  fc 18 0f      l1164h:      call m,sub_0f18h
1167:  fa 64 11                   jp m,l1164h
116A:  c1                         pop bc
116B:  7b                         ld a,e
116C:  90                         sub b
116D:  c1                         pop bc
116E:  5f                         ld e,a
116F:  82                         add a,d
1170:  78                         ld a,b
1171:  fa 7f 11                   jp m,l117fh
1174:  92                         sub d
1175:  93                         sub e
1176:  f4 69 12                   call p,sub_1269h
1179:  c5                         push bc
117A:  cd 7d 12                   call sub_127dh
117D:  18 11                      jr l1190h
117F:  cd 69 12      l117fh:      call sub_1269h
1182:  79                         ld a,c
1183:  cd 94 12                   call sub_1294h
1186:  4f                         ld c,a
1187:  af                         xor a
1188:  92                         sub d
1189:  93                         sub e
118A:  cd 69 12                   call sub_1269h
118D:  c5                         push bc
118E:  47                         ld b,a
118F:  4f                         ld c,a
1190:  cd a4 12      l1190h:      call sub_12a4h
1193:  c1                         pop bc
1194:  b1                         or c
1195:  20 03                      jr nz,l119ah
1197:  2a f3 78                   ld hl,(078f3h)
119A:  83            l119ah:      add a,e
119B:  3d                         dec a
119C:  f4 69 12                   call p,sub_1269h
119F:  50                         ld d,b
11A0:  c3 bf 10                   jp l10bfh
11A3:  e5            l11a3h:      push hl
11A4:  d5                         push de
11A5:  cd cc 0a                   call l0acch
11A8:  d1                         pop de
11A9:  af                         xor a
11AA:  ca b0 11      l11aah:      jp z,011b0h
11AD:  1e 10                      ld e,010h
11AF:  01 1e 06                   ld bc,0061eh
11B2:  cd 55 09                   call sub_0955h
11B5:  37                         scf
11B6:  c4 01 12                   call nz,sub_1201h
11B9:  e1                         pop hl
11BA:  c1                         pop bc
11BB:  f5                         push af
11BC:  79                         ld a,c
11BD:  b7                         or a
11BE:  f5                         push af
11BF:  c4 16 0f                   call nz,sub_0f16h
11C2:  80                         add a,b
11C3:  4f                         ld c,a
11C4:  7a                         ld a,d
11C5:  e6 04                      and 004h
11C7:  fe 01                      cp 001h
11C9:  9f                         sbc a,a
11CA:  57                         ld d,a
11CB:  81                         add a,c
11CC:  4f                         ld c,a
11CD:  93                         sub e
11CE:  f5                         push af
11CF:  c5                         push bc
11D0:  fc 18 0f      l11d0h:      call m,sub_0f18h
11D3:  fa d0 11                   jp m,l11d0h
11D6:  c1                         pop bc
11D7:  f1                         pop af
11D8:  c5                         push bc
11D9:  f5                         push af
11DA:  fa de 11                   jp m,l11deh
11DD:  af                         xor a
11DE:  2f            l11deh:      cpl
11DF:  3c                         inc a
11E0:  80                         add a,b
11E1:  3c                         inc a
11E2:  82                         add a,d
11E3:  47                         ld b,a
11E4:  0e 00                      ld c,000h
11E6:  cd a4 12                   call sub_12a4h
11E9:  f1                         pop af
11EA:  f4 71 12                   call p,sub_1271h
11ED:  c1                         pop bc
11EE:  f1                         pop af
11EF:  cc 2f 09                   call z,sub_092fh
11F2:  f1                         pop af
11F3:  38 03                      jr c,l11f8h
11F5:  83                         add a,e
11F6:  90                         sub b
11F7:  92                         sub d
11F8:  c5            l11f8h:      push bc
11F9:  cd 74 10                   call sub_1074h
11FC:  eb                         ex de,hl
11FD:  d1                         pop de
11FE:  c3 bf 10                   jp l10bfh
1201:  d5            sub_1201h:   push de
1202:  af                         xor a
1203:  f5                         push af
1204:  e7                         rst 20h
1205:  e2 22 12                   jp po,l1222h
1208:  3a 24 79      l1208h:      ld a,(07924h)
120B:  fe 91                      cp 091h
120D:  d2 22 12                   jp nc,l1222h
1210:  11 64 13                   ld de,l1364h
1213:  21 27 79                   ld hl,07927h
1216:  cd d3 09                   call l09d3h
1219:  cd a1 0d                   call sub_0da1h
121C:  f1                         pop af
121D:  d6 0a                      sub 00ah
121F:  f5                         push af
1220:  18 e6                      jr l1208h
1222:  cd 4f 12      l1222h:      call sub_124fh
1225:  e7            l1225h:      rst 20h
1226:  ea 34 12                   jp pe,l1234h
1229:  01 43 91                   ld bc,09143h
122C:  11 f9 4f                   ld de,04ff9h
122F:  cd 0c 0a                   call sub_0a0ch
1232:  18 06                      jr l123ah
1234:  11 6c 13      l1234h:      ld de,l136ch
1237:  cd 49 0a                   call sub_0a49h
123A:  f2 4c 12      l123ah:      jp p,l124ch
123D:  f1                         pop af
123E:  cd 0b 0f                   call sub_0f0bh
1241:  f5                         push af
1242:  18 e1                      jr l1225h
1244:  f1            l1244h:      pop af
1245:  cd 18 0f                   call sub_0f18h
1248:  f5                         push af
1249:  cd 4f 12                   call sub_124fh
124C:  f1            l124ch:      pop af
124D:  d1                         pop de
124E:  c9                         ret
124F:  e7            sub_124fh:   rst 20h
1250:  ea 5e 12                   jp pe,l125eh
1253:  01 74 94                   ld bc,09474h
1256:  11 f8 23                   ld de,l23f8h
1259:  cd 0c 0a                   call sub_0a0ch
125C:  18 06                      jr l1264h
125E:  11 74 13      l125eh:      ld de,l1374h
1261:  cd 49 0a                   call sub_0a49h
1264:  e1            l1264h:      pop hl
1265:  f2 44 12                   jp p,l1244h
1268:  e9                         jp (hl)
1269:  b7            sub_1269h:   or a
126A:  c8            l126ah:      ret z
126B:  3d                         dec a
126C:  36 30                      ld (hl),030h
126E:  23                         inc hl
126F:  18 f9                      jr l126ah
1271:  20 04         sub_1271h:   jr nz,sub_1277h
1273:  c8            l1273h:      ret z
1274:  cd 91 12                   call sub_1291h
1277:  36 30         sub_1277h:   ld (hl),030h
1279:  23                         inc hl
127A:  3d                         dec a
127B:  18 f6                      jr l1273h
127D:  7b            sub_127dh:   ld a,e
127E:  82                         add a,d
127F:  3c                         inc a
1280:  47                         ld b,a
1281:  3c                         inc a
1282:  d6 03         l1282h:      sub 003h
1284:  30 fc                      jr nc,l1282h
1286:  c6 05                      add a,005h
1288:  4f                         ld c,a
1289:  3a d8 78      sub_1289h:   ld a,(078d8h)
128C:  e6 40                      and 040h
128E:  c0                         ret nz
128F:  4f                         ld c,a
1290:  c9                         ret
1291:  05            sub_1291h:   dec b
1292:  20 08                      jr nz,l129ch
1294:  36 2e         sub_1294h:   ld (hl),02eh
1296:  22 f3 78                   ld (078f3h),hl
1299:  23                         inc hl
129A:  48                         ld c,b
129B:  c9                         ret
129C:  0d            l129ch:      dec c
129D:  c0                         ret nz
129E:  36 2c                      ld (hl),02ch
12A0:  23                         inc hl
12A1:  0e 03                      ld c,003h
12A3:  c9                         ret
12A4:  d5            sub_12a4h:   push de
12A5:  e7                         rst 20h
12A6:  e2 ea 12                   jp po,l12eah
12A9:  c5                         push bc
12AA:  e5                         push hl
12AB:  cd fc 09                   call sub_09fch
12AE:  21 7c 13                   ld hl,l137ch
12B1:  cd f7 09                   call sub_09f7h
12B4:  cd 77 0c                   call sub_0c77h
12B7:  af                         xor a
12B8:  cd 7b 0b                   call sub_0b7bh
12BB:  e1                         pop hl
12BC:  c1                         pop bc
12BD:  11 8c 13                   ld de,l138ch
12C0:  3e 0a                      ld a,00ah
12C2:  cd 91 12      l12c2h:      call sub_1291h
12C5:  c5                         push bc
12C6:  f5                         push af
12C7:  e5                         push hl
12C8:  d5                         push de
12C9:  06 2f                      ld b,02fh
12CB:  04            l12cbh:      inc b
12CC:  e1                         pop hl
12CD:  e5                         push hl
12CE:  cd 48 0d                   call sub_0d48h
12D1:  30 f8                      jr nc,l12cbh
12D3:  e1                         pop hl
12D4:  cd 36 0d                   call sub_0d36h
12D7:  eb                         ex de,hl
12D8:  e1                         pop hl
12D9:  70                         ld (hl),b
12DA:  23                         inc hl
12DB:  f1                         pop af
12DC:  c1                         pop bc
12DD:  3d                         dec a
12DE:  20 e2                      jr nz,l12c2h
12E0:  c5                         push bc
12E1:  e5                         push hl
12E2:  21 1d 79                   ld hl,0791dh
12E5:  cd b1 09                   call sub_09b1h
12E8:  18 0c                      jr l12f6h
12EA:  c5            l12eah:      push bc
12EB:  e5                         push hl
12EC:  cd 08 07                   call sub_0708h
12EF:  3c                         inc a
12F0:  cd fb 0a                   call sub_0afbh
12F3:  cd b4 09                   call l09b4h
12F6:  e1            l12f6h:      pop hl
12F7:  c1                         pop bc
12F8:  af                         xor a
12F9:  11 d2 13                   ld de,l13d2h
12FC:  3f            l12fch:      ccf
12FD:  cd 91 12                   call sub_1291h
1300:  c5                         push bc
1301:  f5                         push af
1302:  e5                         push hl
1303:  d5                         push de
1304:  cd bf 09                   call sub_09bfh
1307:  e1                         pop hl
1308:  06 2f                      ld b,02fh
130A:  04            l130ah:      inc b
130B:  7b                         ld a,e
130C:  96                         sub (hl)
130D:  5f                         ld e,a
130E:  23                         inc hl
130F:  7a                         ld a,d
1310:  9e                         sbc a,(hl)
1311:  57                         ld d,a
1312:  23                         inc hl
1313:  79                         ld a,c
1314:  9e                         sbc a,(hl)
1315:  4f                         ld c,a
1316:  2b                         dec hl
1317:  2b                         dec hl
1318:  30 f0                      jr nc,l130ah
131A:  cd b7 07                   call sub_07b7h
131D:  23                         inc hl
131E:  cd b4 09                   call l09b4h
1321:  eb                         ex de,hl
1322:  e1                         pop hl
1323:  70                         ld (hl),b
1324:  23                         inc hl
1325:  f1                         pop af
1326:  c1                         pop bc
1327:  38 d3                      jr c,l12fch
1329:  13                         inc de
132A:  13                         inc de
132B:  3e 04                      ld a,004h
132D:  18 06                      jr l1335h
132F:  d5            sub_132fh:   push de
1330:  11 d8 13                   ld de,l13d8h
1333:  3e 05                      ld a,005h
1335:  cd 91 12      l1335h:      call sub_1291h
1338:  c5                         push bc
1339:  f5                         push af
133A:  e5                         push hl
133B:  eb                         ex de,hl
133C:  4e                         ld c,(hl)
133D:  23                         inc hl
133E:  46                         ld b,(hl)
133F:  c5                         push bc
1340:  23                         inc hl
1341:  e3                         ex (sp),hl
1342:  eb                         ex de,hl
1343:  2a 21 79                   ld hl,(07921h)
1346:  06 2f                      ld b,02fh
1348:  04            l1348h:      inc b
1349:  7d            l1349h:      ld a,l
134A:  93                         sub e
134B:  6f                         ld l,a
134C:  7c                         ld a,h
134D:  9a                         sbc a,d
134E:  67                         ld h,a
134F:  30 f7                      jr nc,l1348h
1351:  19                         add hl,de
1352:  22 21 79                   ld (07921h),hl
1355:  d1                         pop de
1356:  e1                         pop hl
1357:  70                         ld (hl),b
1358:  23                         inc hl
1359:  f1                         pop af
135A:  c1                         pop bc
135B:  3d                         dec a
135C:  20 d7                      jr nz,l1335h
135E:  cd 91 12                   call sub_1291h
1361:  77                         ld (hl),a
1362:  d1                         pop de
1363:  c9                         ret
1364:  00            l1364h:      nop
1365:  00                         nop
1366:  00                         nop
1367:  00                         nop
1368:  f9                         ld sp,hl
1369:  02                         ld (bc),a
136A:  15                         dec d
136B:  a2                         and d
	defb 0fdh,0ffh,09fh	;illegal sequence		;136c	fd ff 9f 	. . . 

136F:  31 a9 5f      l136ch:      ld sp,05fa9h
1372:  63                         ld h,e
1373:  b2                         or d
1374:  fe ff         l1374h:      cp 0ffh
1376:  03                         inc bc
1377:  bf                         cp a
1378:  c9                         ret
1379:  1b                         dec de
137A:  0e b6                      ld c,0b6h
137C:  00            l137ch:      nop
137D:  00                         nop
137E:  00                         nop
137F:  00                         nop
1380:  00            l1380h:      nop
1381:  00                         nop
1382:  00                         nop
1383:  80                         add a,b
1384:  00            l1384h:      nop
1385:  00                         nop
1386:  04                         inc b
1387:  bf                         cp a
1388:  c9                         ret
1389:  1b                         dec de
138A:  0e b6                      ld c,0b6h
138C:  00            l138ch:      nop
138D:  80                         add a,b
138E:  c6 a4                      add a,0a4h
1390:  7e                         ld a,(hl)
1391:  8d                         adc a,l
1392:  03                         inc bc
1393:  00                         nop
1394:  40                         ld b,b
1395:  7a                         ld a,d
1396:  10 f3                      djnz $-11
1398:  5a                         ld e,d
1399:  00                         nop
139A:  00                         nop
139B:  a0                         and b
139C:  72                         ld (hl),d
139D:  4e                         ld c,(hl)
139E:  18 09                      jr l13a9h
13A0:  00                         nop
13A1:  00                         nop
13A2:  10 a5                      djnz l1349h
13A4:  d4 e8 00                   call nc,sub_00e8h
13A7:  00                         nop
13A8:  00                         nop
13A9:  e8            l13a9h:      ret pe
13AA:  76                         halt
13AB:  48                         ld c,b
13AC:  17                         rla
13AD:  00                         nop
13AE:  00                         nop
13AF:  00                         nop
13B0:  e4 0b 54                   call po,0540bh
13B3:  02                         ld (bc),a
13B4:  00                         nop
13B5:  00                         nop
13B6:  00                         nop
13B7:  ca 9a 3b                   jp z,l3b9ah
13BA:  00                         nop
13BB:  00                         nop
13BC:  00                         nop
13BD:  00                         nop
13BE:  e1                         pop hl
13BF:  f5                         push af
13C0:  05                         dec b
13C1:  00                         nop
13C2:  00                         nop
13C3:  00                         nop
13C4:  80                         add a,b
13C5:  96                         sub (hl)
13C6:  98                         sbc a,b
13C7:  00                         nop
13C8:  00                         nop
13C9:  00                         nop
13CA:  00                         nop
13CB:  40                         ld b,b
13CC:  42                         ld b,d
13CD:  0f                         rrca
13CE:  00                         nop
13CF:  00                         nop
13D0:  00                         nop
13D1:  00                         nop
13D2:  a0            l13d2h:      and b
13D3:  86                         add a,(hl)
13D4:  01 10 27                   ld bc,l2710h
13D7:  00                         nop
13D8:  10 27         l13d8h:      djnz l1401h
13DA:  e8                         ret pe
13DB:  03                         inc bc
13DC:  64                         ld h,h
13DD:  00                         nop
13DE:  0a                         ld a,(bc)
13DF:  00                         nop
13E0:  01 00 21                   ld bc,l2100h
13E3:  82                         add a,d
13E4:  09                         add hl,bc
13E5:  e3                         ex (sp),hl
13E6:  e9                         jp (hl)
13E7:  cd a4 09                   call sub_09a4h
13EA:  21 80 13                   ld hl,l1380h
13ED:  cd b1 09                   call sub_09b1h
13F0:  18 03                      jr l13f5h
13F2:  cd b1 0a      l13f2h:      call sub_0ab1h
13F5:  c1            l13f5h:      pop bc
13F6:  d1                         pop de
13F7:  cd 55 09                   call sub_0955h
13FA:  78                         ld a,b
13FB:  28 3c                      jr z,l1439h
13FD:  f2 04 14                   jp p,l1404h
1400:  b7                         or a
1401:  ca 9a 19      l1401h:      jp z,0199ah
1404:  b7            l1404h:      or a
1405:  ca 79 07                   jp z,l0779h
1408:  d5                         push de
1409:  c5                         push bc
140A:  79                         ld a,c
140B:  f6 7f                      or 07fh
140D:  cd bf 09                   call sub_09bfh
1410:  f2 21 14                   jp p,l1421h
1413:  d5                         push de
1414:  c5                         push bc
1415:  cd 40 0b                   call sub_0b40h
1418:  c1                         pop bc
1419:  d1                         pop de
141A:  f5                         push af
141B:  cd 0c 0a                   call sub_0a0ch
141E:  e1            l141eh:      pop hl
141F:  7c                         ld a,h
1420:  1f                         rra
1421:  e1            l1421h:      pop hl
1422:  22 23 79                   ld (07923h),hl
1425:  e1                         pop hl
1426:  22 21 79                   ld (07921h),hl
1429:  dc e2 13                   call c,013e2h
142C:  cc 82 09                   call z,sub_0982h
142F:  d5                         push de
1430:  c5                         push bc
1431:  cd 09 08                   call sub_0809h
1434:  c1                         pop bc
1435:  d1                         pop de
1436:  cd 47 08                   call l0847h
1439:  cd a4 09      l1439h:      call sub_09a4h
143C:  01 38 81                   ld bc,08138h
143F:  11 3b aa                   ld de,0aa3bh
1442:  cd 47 08                   call l0847h
1445:  3a 24 79                   ld a,(07924h)
1448:  fe 88                      cp 088h
144A:  d2 31 09                   jp nc,l0931h
144D:  cd 40 0b                   call sub_0b40h
1450:  c6 80                      add a,080h
1452:  c6 02                      add a,002h
1454:  da 31 09                   jp c,l0931h
1457:  f5                         push af
1458:  21 f8 07                   ld hl,l07f8h
145B:  cd 0b 07                   call sub_070bh
145E:  cd 41 08                   call sub_0841h
1461:  f1                         pop af
1462:  c1                         pop bc
1463:  d1                         pop de
1464:  f5                         push af
1465:  cd 13 07                   call sub_0713h
1468:  cd 82 09                   call sub_0982h
146B:  21 79 14                   ld hl,l1479h
146E:  cd a9 14                   call sub_14a9h
1471:  11 00 00                   ld de,RESET
1474:  c1                         pop bc
1475:  4a                         ld c,d
1476:  c3 47 08                   jp l0847h
1479:  08            l1479h:      ex af,af'
147A:  40                         ld b,b
147B:  2e 94                      ld l,094h
147D:  74                         ld (hl),h
147E:  70                         ld (hl),b
147F:  4f                         ld c,a
1480:  2e 77                      ld l,077h
1482:  6e                         ld l,(hl)
1483:  02                         ld (bc),a
1484:  88                         adc a,b
1485:  7a                         ld a,d
1486:  e6 a0                      and 0a0h
1488:  2a 7c 50                   ld hl,(0507ch)
148B:  aa                         xor d
148C:  aa                         xor d
148D:  7e                         ld a,(hl)
148E:  ff                         rst 38h
148F:  ff                         rst 38h
1490:  7f                         ld a,a
1491:  7f                         ld a,a
1492:  00                         nop
1493:  00                         nop
1494:  80                         add a,b
1495:  81                         add a,c
1496:  00                         nop
1497:  00                         nop
1498:  00                         nop
1499:  81                         add a,c
149A:  cd a4 09      sub_149ah:   call sub_09a4h
149D:  11 32 0c                   ld de,l0c32h
14A0:  d5                         push de
14A1:  e5                         push hl
14A2:  cd bf 09                   call sub_09bfh
14A5:  cd 47 08                   call l0847h
14A8:  e1                         pop hl
14A9:  cd a4 09      sub_14a9h:   call sub_09a4h
14AC:  7e                         ld a,(hl)
14AD:  23                         inc hl
14AE:  cd b1 09                   call sub_09b1h
14B1:  06 f1                      ld b,0f1h
14B3:  c1                         pop bc
14B4:  d1                         pop de
14B5:  3d                         dec a
14B6:  c8                         ret z
14B7:  d5                         push de
14B8:  c5                         push bc
14B9:  f5                         push af
14BA:  e5                         push hl
14BB:  cd 47 08                   call l0847h
14BE:  e1                         pop hl
14BF:  cd c2 09                   call sub_09c2h
14C2:  e5                         push hl
14C3:  cd 16 07                   call l0716h
14C6:  e1                         pop hl
14C7:  18 e9                      jr $-21
14C9:  cd 7f 0a                   call l0a7fh
14CC:  7c                         ld a,h
14CD:  b7                         or a
14CE:  fa 4a 1e                   jp m,l1e4ah
14D1:  b5                         or l
14D2:  ca f0 14                   jp z,l14f0h
14D5:  e5                         push hl
14D6:  cd f0 14                   call l14f0h
14D9:  cd bf 09                   call sub_09bfh
14DC:  eb                         ex de,hl
14DD:  e3                         ex (sp),hl
14DE:  c5                         push bc
14DF:  cd cf 0a                   call sub_0acfh
14E2:  c1                         pop bc
14E3:  d1                         pop de
14E4:  cd 47 08                   call l0847h
14E7:  21 f8 07                   ld hl,l07f8h
14EA:  cd 0b 07                   call sub_070bh
14ED:  c3 40 0b                   jp sub_0b40h
14F0:  21 90 78      l14f0h:      ld hl,07890h
14F3:  e5                         push hl
14F4:  11 00 00                   ld de,RESET
14F7:  4b                         ld c,e
14F8:  26 03                      ld h,003h
14FA:  2e 08         l14fah:      ld l,008h
14FC:  eb            l14fch:      ex de,hl
14FD:  29                         add hl,hl
14FE:  eb                         ex de,hl
14FF:  79                         ld a,c
1500:  17                         rla
1501:  4f                         ld c,a
1502:  e3                         ex (sp),hl
1503:  7e                         ld a,(hl)
1504:  07                         rlca
1505:  77                         ld (hl),a
1506:  e3                         ex (sp),hl
1507:  d2 16 15                   jp nc,l1516h
150A:  e5                         push hl
150B:  2a aa 78                   ld hl,(078aah)
150E:  19                         add hl,de
150F:  eb                         ex de,hl
1510:  3a ac 78                   ld a,(078ach)
1513:  89                         adc a,c
1514:  4f                         ld c,a
1515:  e1                         pop hl
1516:  2d            l1516h:      dec l
1517:  c2 fc 14                   jp nz,l14fch
151A:  e3                         ex (sp),hl
151B:  23                         inc hl
151C:  e3                         ex (sp),hl
151D:  25                         dec h
151E:  c2 fa 14                   jp nz,l14fah
1521:  e1                         pop hl
1522:  21 65 b0                   ld hl,0b065h
1525:  19                         add hl,de
1526:  22 aa 78                   ld (078aah),hl
1529:  cd ef 0a                   call 00aefh
152C:  3e 05                      ld a,005h
152E:  89                         adc a,c
152F:  32 ac 78                   ld (078ach),a
1532:  eb                         ex de,hl
1533:  06 80                      ld b,080h
1535:  21 25 79                   ld hl,07925h
1538:  70                         ld (hl),b
1539:  2b                         dec hl
153A:  70                         ld (hl),b
153B:  4f                         ld c,a
153C:  06 00                      ld b,000h
153E:  c3 65 07                   jp l0765h
1541:  21 8b 15      sub_1541h:   ld hl,l158bh
1544:  cd 0b 07                   call sub_070bh
1547:  cd a4 09      sub_1547h:   call sub_09a4h
154A:  01 49 83                   ld bc,08349h
154D:  11 db 0f                   ld de,00fdbh
1550:  cd b4 09                   call l09b4h
1553:  c1                         pop bc
1554:  d1                         pop de
1555:  cd a2 08                   call sub_08a2h
1558:  cd a4 09                   call sub_09a4h
155B:  cd 40 0b                   call sub_0b40h
155E:  c1                         pop bc
155F:  d1                         pop de
1560:  cd 13 07                   call sub_0713h
1563:  21 8f 15                   ld hl,l158fh
1566:  cd 10 07                   call sub_0710h
1569:  cd 55 09                   call sub_0955h
156C:  37                         scf
156D:  f2 77 15                   jp p,l1577h
1570:  cd 08 07                   call sub_0708h
1573:  cd 55 09                   call sub_0955h
1576:  b7                         or a
1577:  f5            l1577h:      push af
1578:  f4 82 09                   call p,sub_0982h
157B:  21 8f 15                   ld hl,l158fh
157E:  cd 0b 07                   call sub_070bh
1581:  f1                         pop af
1582:  d4 82 09                   call nc,sub_0982h
1585:  21 93 15                   ld hl,l1593h
1588:  c3 9a 14                   jp sub_149ah
158B:  db 0f         l158bh:      in a,(00fh)
158D:  49                         ld c,c
158E:  81                         add a,c
158F:  00            l158fh:      nop
1590:  00                         nop
1591:  00                         nop
1592:  7f                         ld a,a
1593:  05            l1593h:      dec b
1594:  ba                         cp d
1595:  d7                         rst 10h
1596:  1e 86                      ld e,086h
1598:  64                         ld h,h
1599:  26 99                      ld h,099h
159B:  87                         add a,a
159C:  58                         ld e,b
159D:  34                         inc (hl)
159E:  23                         inc hl
159F:  87                         add a,a
15A0:  e0                         ret po
15A1:  5d                         ld e,l
15A2:  a5                         and l
15A3:  86                         add a,(hl)
15A4:  da 0f 49                   jp c,0490fh
15A7:  83                         add a,e
15A8:  cd a4 09                   call sub_09a4h
15AB:  cd 47 15                   call sub_1547h
15AE:  c1                         pop bc
15AF:  e1                         pop hl
15B0:  cd a4 09                   call sub_09a4h
15B3:  eb                         ex de,hl
15B4:  cd b4 09                   call l09b4h
15B7:  cd 41 15                   call sub_1541h
15BA:  c3 a0 08                   jp l08a0h
15BD:  cd 55 09                   call sub_0955h
15C0:  fc e2 13                   call m,013e2h
15C3:  fc 82 09                   call m,sub_0982h
15C6:  3a 24 79                   ld a,(07924h)
15C9:  fe 81                      cp 081h
15CB:  38 0c                      jr c,l15d9h
15CD:  01 00 81                   ld bc,08100h
15D0:  51                         ld d,c
15D1:  59                         ld e,c
15D2:  cd a2 08                   call sub_08a2h
15D5:  21 10 07                   ld hl,sub_0710h
15D8:  e5                         push hl
15D9:  21 e3 15      l15d9h:      ld hl,l15e3h
15DC:  cd 9a 14                   call sub_149ah
15DF:  21 8b 15                   ld hl,l158bh
15E2:  c9                         ret
15E3:  09            l15e3h:      add hl,bc
15E4:  4a                         ld c,d
15E5:  d7                         rst 10h
15E6:  3b                         dec sp
15E7:  78                         ld a,b
15E8:  02                         ld (bc),a
15E9:  6e                         ld l,(hl)
15EA:  84                         add a,h
15EB:  7b                         ld a,e
15EC:  fe c1                      cp 0c1h
15EE:  2f                         cpl
15EF:  7c                         ld a,h
15F0:  74                         ld (hl),h
15F1:  31 9a 7d                   ld sp,07d9ah
15F4:  84                         add a,h
15F5:  3d                         dec a
15F6:  5a                         ld e,d
15F7:  7d                         ld a,l
15F8:  c8                         ret z
15F9:  7f                         ld a,a
15FA:  91                         sub c
15FB:  7e                         ld a,(hl)
15FC:  e4 bb 4c                   call po,04cbbh
15FF:  7e                         ld a,(hl)
1600:  6c                         ld l,h
1601:  aa                         xor d
1602:  aa                         xor d
1603:  7f                         ld a,a
1604:  00                         nop
1605:  00                         nop
1606:  00                         nop
1607:  81                         add a,c
1608:  8a            l1608h:      adc a,d
1609:  09                         add hl,bc
160A:  37                         scf
160B:  0b                         dec bc
160C:  77                         ld (hl),a
160D:  09                         add hl,bc
160E:  d4 27 ef                   call nc,0ef27h
1611:  2a f5 27                   ld hl,(l27f5h)
1614:  e7                         rst 20h
1615:  13                         inc de
1616:  c9                         ret
1617:  14                         inc d
1618:  09                         add hl,bc
1619:  08                         ex af,af'
161A:  39                         add hl,sp
161B:  14                         inc d
161C:  41                         ld b,c
161D:  15                         dec d
161E:  47                         ld b,a
161F:  15                         dec d
1620:  a8                         xor b
1621:  15                         dec d
1622:  bd                         cp l
1623:  15                         dec d
1624:  aa                         xor d
1625:  2c                         inc l
1626:  52                         ld d,d
1627:  79                         ld a,c
1628:  58                         ld e,b
1629:  79                         ld a,c
162A:  5e                         ld e,(hl)
162B:  79                         ld a,c
162C:  61                         ld h,c
162D:  79                         ld a,c
162E:  64                         ld h,h
162F:  79                         ld a,c
1630:  67                         ld h,a
1631:  79                         ld a,c
1632:  6a                         ld l,d
1633:  79                         ld a,c
1634:  6d                         ld l,l
1635:  79                         ld a,c
1636:  70                         ld (hl),b
1637:  79                         ld a,c
1638:  7f                         ld a,a
1639:  0a                         ld a,(bc)
163A:  b1                         or c
163B:  0a                         ld a,(bc)
163C:  db 0a                      in a,(00ah)
163E:  26 0b                      ld h,00bh
1640:  03                         inc bc
1641:  2a 36 28                   ld hl,(l2836h)
1644:  c5                         push bc
1645:  2a 0f 2a                   ld hl,(l2a0fh)
1648:  1f                         rra
1649:  2a 61 2a                   ld hl,(l2a61h)
164C:  91                         sub c
164D:  2a 9a 2a                   ld hl,(l2a9ah)
1650:  c5            l1650h:      push bc
1651:  4e                         ld c,(hl)
1652:  44                         ld b,h
1653:  c6 4f                      add a,04fh
1655:  52                         ld d,d
1656:  d2 45 53                   jp nc,05345h
1659:  45                         ld b,l
165A:  54                         ld d,h
165B:  d3 45                      out (045h),a
165D:  54                         ld d,h
165E:  c3 4c 53                   jp 0534ch
1661:  81                         add a,c
1662:  00                         nop
1663:  00                         nop
1664:  81                         add a,c
1665:  00                         nop
1666:  00                         nop
1667:  00                         nop
1668:  00                         nop
1669:  00                         nop
166A:  ce 45                      adc a,045h
166C:  58                         ld e,b
166D:  54                         ld d,h
166E:  c4 41 54                   call nz,05441h
1671:  41                         ld b,c
1672:  c9                         ret
1673:  4e                         ld c,(hl)
1674:  50                         ld d,b
1675:  55                         ld d,l
1676:  54                         ld d,h
1677:  c4 49 4d                   call nz,04d49h
167A:  d2 45 41                   jp nc,04145h
167D:  44                         ld b,h
167E:  cc 45 54                   call z,05445h
1681:  c7                         rst 0
1682:  4f                         ld c,a
1683:  54                         ld d,h
1684:  4f                         ld c,a
1685:  d2 55 4e                   jp nc,04e55h
1688:  c9                         ret
1689:  46                         ld b,(hl)
168A:  d2 45 53                   jp nc,05345h
168D:  54                         ld d,h
168E:  4f                         ld c,a
168F:  52                         ld d,d
1690:  45                         ld b,l
1691:  c7                         rst 0
1692:  4f                         ld c,a
1693:  53                         ld d,e
1694:  55                         ld d,l
1695:  42                         ld b,d
1696:  d2 45 54                   jp nc,05445h
1699:  55                         ld d,l
169A:  52                         ld d,d
169B:  4e                         ld c,(hl)
169C:  d2 45 4d                   jp nc,04d45h
169F:  d3 54                      out (054h),a
16A1:  4f                         ld c,a
16A2:  50                         ld d,b
16A3:  c5                         push bc
16A4:  4c                         ld c,h
16A5:  53                         ld d,e
16A6:  45                         ld b,l
16A7:  c3 4f 50                   jp 0504fh
16AA:  59                         ld e,c
16AB:  c3 4f 4c                   jp 04c4fh
16AE:  4f                         ld c,a
16AF:  52                         ld d,d
16B0:  d6 45                      sub 045h
16B2:  52                         ld d,d
16B3:  49                         ld c,c
16B4:  46                         ld b,(hl)
16B5:  59                         ld e,c
16B6:  81                         add a,c
16B7:  00                         nop
16B8:  00                         nop
16B9:  00                         nop
16BA:  00                         nop
16BB:  00                         nop
16BC:  81                         add a,c
16BD:  00                         nop
16BE:  00                         nop
16BF:  00                         nop
16C0:  00                         nop
16C1:  00                         nop
16C2:  81                         add a,c
16C3:  00                         nop
16C4:  00                         nop
16C5:  00                         nop
16C6:  00                         nop
16C7:  00                         nop
16C8:  c3 52 55                   jp 05552h
16CB:  4e                         ld c,(hl)
16CC:  cd 4f 44                   call 0444fh
16CF:  45                         ld b,l
16D0:  d3 4f                      out (04fh),a
16D2:  55                         ld d,l
16D3:  4e                         ld c,(hl)
16D4:  44                         ld b,h
16D5:  81                         add a,c
16D6:  00                         nop
16D7:  00                         nop
16D8:  00                         nop
16D9:  00                         nop
16DA:  00                         nop
16DB:  cf                         rst 8
16DC:  55                         ld d,l
16DD:  54                         ld d,h
16DE:  81                         add a,c
16DF:  00                         nop
16E0:  81                         add a,c
16E1:  00                         nop
16E2:  00                         nop
16E3:  00                         nop
16E4:  81                         add a,c
16E5:  00                         nop
16E6:  00                         nop
16E7:  00                         nop
16E8:  00                         nop
16E9:  81                         add a,c
16EA:  00                         nop
16EB:  00                         nop
16EC:  81                         add a,c
16ED:  00                         nop
16EE:  00                         nop
16EF:  81                         add a,c
16F0:  00                         nop
16F1:  00                         nop
16F2:  00                         nop
16F3:  00                         nop
16F4:  81                         add a,c
16F5:  00                         nop
16F6:  00                         nop
16F7:  00                         nop
16F8:  81                         add a,c
16F9:  00                         nop
16FA:  00                         nop
16FB:  00                         nop
16FC:  00                         nop
16FD:  81                         add a,c
16FE:  00                         nop
16FF:  00                         nop
1700:  00                         nop
1701:  81                         add a,c
1702:  00                         nop
1703:  00                         nop
1704:  00                         nop
1705:  81                         add a,c
1706:  00                         nop
1707:  00                         nop
1708:  00                         nop
1709:  81                         add a,c
170A:  00                         nop
170B:  00                         nop
170C:  00                         nop
170D:  81                         add a,c
170E:  00                         nop
170F:  00                         nop
1710:  00                         nop
1711:  81                         add a,c
1712:  00                         nop
1713:  00                         nop
1714:  00                         nop
1715:  00                         nop
1716:  00                         nop
1717:  cc 50 52                   call z,05250h
171A:  49                         ld c,c
171B:  4e                         ld c,(hl)
171C:  54                         ld d,h
171D:  81                         add a,c
171E:  00                         nop
171F:  00                         nop
1720:  d0                         ret nc
1721:  4f                         ld c,a
1722:  4b                         ld c,e
1723:  45                         ld b,l
1724:  d0                         ret nc
1725:  52                         ld d,d
1726:  49                         ld c,c
1727:  4e                         ld c,(hl)
1728:  54                         ld d,h
1729:  c3 4f 4e                   jp 04e4fh
172C:  54                         ld d,h
172D:  cc 49 53                   call z,05349h
1730:  54                         ld d,h
1731:  cc 4c 49                   call z,0494ch
1734:  53                         ld d,e
1735:  54                         ld d,h
1736:  81                         add a,c
1737:  00                         nop
1738:  00                         nop
1739:  00                         nop
173A:  00                         nop
173B:  00                         nop
173C:  81                         add a,c
173D:  00                         nop
173E:  00                         nop
173F:  00                         nop
1740:  c3 4c 45                   jp 0454ch
1743:  41                         ld b,c
1744:  52                         ld d,d
1745:  c3 4c 4f                   jp 04f4ch
1748:  41                         ld b,c
1749:  44                         ld b,h
174A:  c3 53 41                   jp 04153h
174D:  56                         ld d,(hl)
174E:  45                         ld b,l
174F:  ce 45                      adc a,045h
1751:  57                         ld d,a
1752:  d4 41 42                   call nc,04241h
1755:  28 d4                      jr z,$-42
1757:  4f                         ld c,a
1758:  81                         add a,c
1759:  00                         nop
175A:  d5                         push de
175B:  53                         ld d,e
175C:  49                         ld c,c
175D:  4e                         ld c,(hl)
175E:  47                         ld b,a
175F:  81                         add a,c
1760:  00                         nop
1761:  00                         nop
1762:  00                         nop
1763:  00                         nop
1764:  00                         nop
1765:  d5                         push de
1766:  53                         ld d,e
1767:  52                         ld d,d
1768:  81                         add a,c
1769:  00                         nop
176A:  00                         nop
176B:  81                         add a,c
176C:  00                         nop
176D:  00                         nop
176E:  81                         add a,c
176F:  00                         nop
1770:  00                         nop
1771:  00                         nop
1772:  00                         nop
1773:  00                         nop
1774:  00                         nop
1775:  81                         add a,c
1776:  00                         nop
1777:  00                         nop
1778:  00                         nop
1779:  00                         nop
177A:  d0                         ret nc
177B:  4f                         ld c,a
177C:  49                         ld c,c
177D:  4e                         ld c,(hl)
177E:  54                         ld d,h
177F:  81                         add a,c
1780:  00                         nop
1781:  00                         nop
1782:  00                         nop
1783:  00                         nop
1784:  81                         add a,c
1785:  00                         nop
1786:  00                         nop
1787:  c9                         ret
1788:  4e                         ld c,(hl)
1789:  4b                         ld c,e
178A:  45                         ld b,l
178B:  59                         ld e,c
178C:  24                         inc h
178D:  d4 48 45                   call nc,04548h
1790:  4e                         ld c,(hl)
1791:  ce 4f                      adc a,04fh
1793:  54                         ld d,h
1794:  d3 54                      out (054h),a
1796:  45                         ld b,l
1797:  50                         ld d,b
1798:  ab                         xor e
1799:  ad                         xor l
179A:  aa                         xor d
179B:  af                         xor a
179C:  de c1                      sbc a,0c1h
179E:  4e                         ld c,(hl)
179F:  44                         ld b,h
17A0:  cf                         rst 8
17A1:  52                         ld d,d
17A2:  be                         cp (hl)
17A3:  bd                         cp l
17A4:  bc                         cp h
17A5:  d3 47                      out (047h),a
17A7:  4e                         ld c,(hl)
17A8:  c9                         ret
17A9:  4e                         ld c,(hl)
17AA:  54                         ld d,h
17AB:  c1                         pop bc
17AC:  42                         ld b,d
17AD:  53                         ld d,e
17AE:  81                         add a,c
17AF:  00                         nop
17B0:  00                         nop
17B1:  c9                         ret
17B2:  4e                         ld c,(hl)
17B3:  50                         ld d,b
17B4:  81                         add a,c
17B5:  00                         nop
17B6:  00                         nop
17B7:  d3 51                      out (051h),a
17B9:  52                         ld d,d
17BA:  d2 4e 44                   jp nc,0444eh
17BD:  cc 4f 47                   call z,0474fh
17C0:  c5                         push bc
17C1:  58                         ld e,b
17C2:  50                         ld d,b
17C3:  c3 4f 53                   jp 0534fh
17C6:  d3 49                      out (049h),a
17C8:  4e                         ld c,(hl)
17C9:  d4 41 4e                   call nc,04e41h
17CC:  c1                         pop bc
17CD:  54                         ld d,h
17CE:  4e                         ld c,(hl)
17CF:  d0                         ret nc
17D0:  45                         ld b,l
17D1:  45                         ld b,l
17D2:  4b                         ld c,e
17D3:  81                         add a,c
17D4:  00            l17d4h:      nop
17D5:  00                         nop
17D6:  81                         add a,c
17D7:  00                         nop
17D8:  00            sub_17d8h:   nop
17D9:  81                         add a,c
17DA:  00                         nop
17DB:  00                         nop
17DC:  81                         add a,c
17DD:  00                         nop
17DE:  00                         nop
17DF:  81                         add a,c
17E0:  00                         nop
17E1:  00                         nop
17E2:  81                         add a,c
17E3:  00                         nop
17E4:  00                         nop
17E5:  81                         add a,c
17E6:  00                         nop
17E7:  00                         nop
17E8:  00                         nop
17E9:  81                         add a,c
17EA:  00                         nop
17EB:  00                         nop
17EC:  00                         nop
17ED:  81                         add a,c
17EE:  00                         nop
17EF:  00                         nop
17F0:  00                         nop
17F1:  81                         add a,c
17F2:  00                         nop
17F3:  00                         nop
17F4:  00                         nop
17F5:  81                         add a,c
17F6:  00                         nop
17F7:  00                         nop
17F8:  00                         nop
17F9:  81                         add a,c
17FA:  00                         nop
17FB:  00                         nop
17FC:  00                         nop
17FD:  81                         add a,c
17FE:  00                         nop
17FF:  00                         nop
1800:  cc 45 4e                   call z,04e45h
1803:  d3 54                      out (054h),a
1805:  52                         ld d,d
1806:  24                         inc h
1807:  d6 41                      sub 041h
1809:  4c                         ld c,h
180A:  c1                         pop bc
180B:  53                         ld d,e
180C:  43                         ld b,e
180D:  c3 48 52                   jp 05248h
1810:  24                         inc h
1811:  cc 45 46                   call z,04645h
1814:  54                         ld d,h
1815:  24                         inc h
1816:  d2 49 47                   jp nc,04749h
1819:  48                         ld c,b
181A:  54                         ld d,h
181B:  24                         inc h
181C:  cd 49 44                   call 04449h
181F:  24                         inc h
1820:  a7                         and a
1821:  80                         add a,b
1822:  ae            l1822h:      xor (hl)
1823:  1d                         dec e
1824:  a1                         and c
1825:  1c                         inc e
1826:  38 01                      jr c,l1829h
1828:  35                         dec (hl)
1829:  01 c9 01      l1829h:      ld bc,CLRSCR
182C:  73                         ld (hl),e
182D:  79                         ld a,c
182E:  d3 01                      out (001h),a
1830:  b6                         or (hl)
1831:  22 05 1f                   ld (l1f05h),hl
1834:  9a                         sbc a,d
1835:  21 08 26                   ld hl,l2608h
1838:  ef                         rst 28h
1839:  21 21 1f                   ld hl,l1f21h
183C:  c2 1e a3                   jp nz,0a31eh
183F:  1e 39                      ld e,039h
1841:  20 91                      jr nz,l17d4h
1843:  1d                         dec e
1844:  b1                         or c
1845:  1e de                      ld e,0deh
1847:  1e 07                      ld e,007h
1849:  1f                         rra
184A:  a9                         xor c
184B:  1d                         dec e
184C:  07                         rlca
184D:  1f                         rra
184E:  12                         ld (de),a
184F:  39                         add hl,sp
1850:  9d                         sbc a,l
1851:  38 38                      jr c,$+58
1853:  37                         scf
1854:  03                         inc bc
1855:  1e 06                      ld e,006h
1857:  1e 09                      ld e,009h
1859:  1e 2e                      ld e,02eh
185B:  37                         scf
185C:  63                         ld h,e
185D:  2e f5                      ld l,0f5h
185F:  2b                         dec hl
1860:  af                         xor a
1861:  1f                         rra
1862:  fb                         ei
1863:  2a 6c 1f                   ld hl,(l1f6ch)
1866:  79                         ld a,c
1867:  79                         ld a,c
1868:  7c                         ld a,h
1869:  79                         ld a,c
186A:  7f                         ld a,a
186B:  79                         ld a,c
186C:  82                         add a,d
186D:  79            l186dh:      ld a,c
186E:  85                         add a,l
186F:  79                         ld a,c
1870:  88                         adc a,b
1871:  79                         ld a,c
1872:  8b                         adc a,e
1873:  79                         ld a,c
1874:  8e                         adc a,(hl)
1875:  79                         ld a,c
1876:  91                         sub c
1877:  79                         ld a,c
1878:  97                         sub a
1879:  79                         ld a,c
187A:  9a                         sbc a,d
187B:  79                         ld a,c
187C:  a0                         and b
187D:  79                         ld a,c
187E:  00                         nop
187F:  00                         nop
1880:  67                         ld h,a
1881:  20 5b                      jr nz,l18deh
1883:  79                         ld a,c
1884:  b1                         or c
1885:  2c                         inc l
1886:  6f                         ld l,a
1887:  20 e4                      jr nz,l186dh
1889:  1d                         dec e
188A:  2e 2b                      ld l,02bh
188C:  29                         add hl,hl
188D:  2b                         dec hl
188E:  c6 2b                      add a,02bh
1890:  08                         ex af,af'
1891:  20 7a                      jr nz,sub_190dh
1893:  1e 56                      ld e,056h
1895:  36 a9                      ld (hl),0a9h
1897:  34                         inc (hl)
1898:  49                         ld c,c
1899:  1b                         dec de
189A:  79            l189ah:      ld a,c
189B:  79                         ld a,c
189C:  7c                         ld a,h
189D:  7c                         ld a,h
189E:  7f                         ld a,a
189F:  50                         ld d,b
18A0:  46                         ld b,(hl)
18A1:  db 0a         l18a1h:      in a,(00ah)
18A3:  00                         nop
18A4:  00                         nop
18A5:  7f                         ld a,a
18A6:  0a                         ld a,(bc)
18A7:  f4 0a b1                   call p,0b10ah
18AA:  0a                         ld a,(bc)
18AB:  77            l18abh:      ld (hl),a
18AC:  0c                         inc c
18AD:  70                         ld (hl),b
18AE:  0c                         inc c
18AF:  a1                         and c
18B0:  0d                         dec c
18B1:  e5                         push hl
18B2:  0d                         dec c
18B3:  78                         ld a,b
18B4:  0a                         ld a,(bc)
18B5:  16 07         l18b5h:      ld d,007h
18B7:  13                         inc de
18B8:  07                         rlca
18B9:  47                         ld b,a
18BA:  08                         ex af,af'
18BB:  a2                         and d
18BC:  08                         ex af,af'
18BD:  0c                         inc c
18BE:  0a                         ld a,(bc)
18BF:  d2 0b c7      l18bfh:      jp nc,0c70bh
18C2:  0b                         dec bc
18C3:  f2 0b 90                   jp p,0900bh
18C6:  24                         inc h
18C7:  39                         add hl,sp
18C8:  0a                         ld a,(bc)
18C9:  4e                         ld c,(hl)
18CA:  46                         ld b,(hl)
18CB:  53                         ld d,e
18CC:  4e                         ld c,(hl)
18CD:  52                         ld d,d
18CE:  47                         ld b,a
18CF:  4f                         ld c,a
18D0:  44                         ld b,h
18D1:  46                         ld b,(hl)
18D2:  43                         ld b,e
18D3:  4f                         ld c,a
18D4:  56                         ld d,(hl)
18D5:  4f                         ld c,a
18D6:  4d                         ld c,l
18D7:  55                         ld d,l
18D8:  4c                         ld c,h
18D9:  42                         ld b,d
18DA:  53                         ld d,e
18DB:  44                         ld b,h
18DC:  44                         ld b,h
18DD:  2f                         cpl
18DE:  30 49         l18deh:      jr nc,l1929h
18E0:  44                         ld b,h
18E1:  54                         ld d,h
18E2:  4d                         ld c,l
18E3:  4f            sub_18e3h:   ld c,a
18E4:  53                         ld d,e
18E5:  4c                         ld c,h
18E6:  53                         ld d,e
18E7:  53                         ld d,e
18E8:  54                         ld d,h
18E9:  43                         ld b,e
18EA:  4e                         ld c,(hl)
18EB:  4e                         ld c,(hl)
18EC:  52                         ld d,d
18ED:  52                         ld d,d
18EE:  57                         ld d,a
18EF:  55                         ld d,l
18F0:  45                         ld b,l
18F1:  4d                         ld c,l
18F2:  4f                         ld c,a
18F3:  46                         ld b,(hl)
18F4:  44                         ld b,h
18F5:  4c                         ld c,h
18F6:  33                         inc sp
18F7:  d6 00         l18f7h:      sub 000h
18F9:  6f                         ld l,a
18FA:  7c                         ld a,h
18FB:  de 00                      sbc a,000h
18FD:  67                         ld h,a
18FE:  78                         ld a,b
18FF:  de 00                      sbc a,000h
1901:  47                         ld b,a
1902:  3e 00                      ld a,000h
1904:  c9                         ret
1905:  4a                         ld c,d
1906:  1e 40                      ld e,040h
1908:  e6 4d                      and 04dh
190A:  db 00                      in a,(000h)
190C:  c9                         ret
190D:  d3 00         sub_190dh:   out (000h),a
190F:  c9                         ret
1910:  00                         nop
1911:  00                         nop
1912:  00                         nop
1913:  00                         nop
1914:  40                         ld b,b
1915:  30 00                      jr nc,l1917h
1917:  4c            l1917h:      ld c,h
1918:  7b                         ld a,e
1919:  fe ff                      cp 0ffh
191B:  e9                         jp (hl)
191C:  7a                         ld a,d
191D:  20 45         l191dh:      jr nz,l1964h
191F:  52                         ld d,d
1920:  52                         ld d,d
1921:  4f                         ld c,a
1922:  52                         ld d,d
1923:  00                         nop
1924:  20 49         l1924h:      jr nz,l196fh
1926:  4e                         ld c,(hl)
1927:  20 00                      jr nz,l1929h
1929:  52            l1929h:      ld d,d
192A:  45                         ld b,l
192B:  41                         ld b,c
192C:  44                         ld b,h
192D:  59                         ld e,c
192E:  0d                         dec c
192F:  00                         nop
1930:  42            l1930h:      ld b,d
1931:  52                         ld d,d
1932:  45                         ld b,l
1933:  41                         ld b,c
1934:  4b                         ld c,e
1935:  00                         nop
1936:  21 04 00      sub_1936h:   ld hl,00004h
1939:  39                         add hl,sp
193A:  7e            l193ah:      ld a,(hl)
193B:  23                         inc hl
193C:  fe 81                      cp 081h
193E:  c0                         ret nz
193F:  4e                         ld c,(hl)
1940:  23                         inc hl
1941:  46                         ld b,(hl)
1942:  23                         inc hl
1943:  e5                         push hl
1944:  69                         ld l,c
1945:  60                         ld h,b
1946:  7a                         ld a,d
1947:  b3                         or e
1948:  eb                         ex de,hl
1949:  28 02                      jr z,l194dh
194B:  eb                         ex de,hl
194C:  df                         rst 18h
194D:  01 0e 00      l194dh:      ld bc,l000eh
1950:  e1                         pop hl
1951:  c8                         ret z
1952:  09                         add hl,bc
1953:  18 e5                      jr l193ah
1955:  cd 6c 19      sub_1955h:   call 0196ch
1958:  c5            sub_1958h:   push bc
1959:  e3                         ex (sp),hl
195A:  c1                         pop bc
195B:  df            l195bh:      rst 18h
195C:  7e                         ld a,(hl)
195D:  02                         ld (bc),a
195E:  c8                         ret z
195F:  0b                         dec bc
1960:  2b                         dec hl
1961:  18 f8                      jr l195bh
1963:  e5            sub_1963h:   push hl
1964:  2a fd 78      l1964h:      ld hl,(MTRIXTAB)
1967:  06 00                      ld b,000h
1969:  09                         add hl,bc
196A:  09                         add hl,bc
196B:  3e e5                      ld a,0e5h
196D:  3e c6                      ld a,0c6h
196F:  95            l196fh:      sub l
1970:  6f                         ld l,a
1971:  3e ff                      ld a,0ffh
1973:  9c                         sbc a,h
1974:  38 04                      jr c,l197ah
1976:  67                         ld h,a
1977:  39                         add hl,sp
1978:  e1                         pop hl
1979:  d8                         ret c
197A:  1e 0c         l197ah:      ld e,00ch
197C:  18 24                      jr l19a2h
197E:  2a a2 78      l197eh:      ld hl,(078a2h)
1981:  7c                         ld a,h
1982:  a5                         and l
1983:  3c                         inc a
1984:  28 08                      jr z,l198eh
1986:  3a f2 78                   ld a,(TRAPFLAG)
1989:  b7                         or a
198A:  1e 22                      ld e,022h
198C:  20 14                      jr nz,l19a2h
198E:  c3 c1 1d      l198eh:      jp l1dc1h
1991:  2a da 78      l1991h:      ld hl,(078dah)
1994:  22 a2 78                   ld (078a2h),hl
1997:  1e 02         l1997h:      ld e,002h
1999:  01 1e 14                   ld bc,l141eh
199C:  01 1e 00                   ld bc,l001eh
199F:  01 1e 24                   ld bc,0241eh
19A2:  2a a2 78      l19a2h:      ld hl,(078a2h)
19A5:  22 ea 78                   ld (078eah),hl
19A8:  22 ec 78                   ld (078ech),hl
19AB:  01 b4 19      l19abh:      ld bc,l19b4h
19AE:  2a e8 78      l19aeh:      ld hl,(STSTACK)
19B1:  c3 9a 1b                   jp INITRTSP
19B4:  c1            l19b4h:      pop bc
19B5:  7b                         ld a,e
19B6:  4b                         ld c,e
19B7:  32 9a 78                   ld (0789ah),a
19BA:  2a e6 78                   ld hl,(078e6h)
19BD:  22 ee 78                   ld (078eeh),hl
19C0:  eb                         ex de,hl
19C1:  2a ea 78                   ld hl,(078eah)
19C4:  7c                         ld a,h
19C5:  a5                         and l
19C6:  3c                         inc a
19C7:  28 07                      jr z,l19d0h
19C9:  22 f5 78                   ld (078f5h),hl
19CC:  eb                         ex de,hl
19CD:  22 f7 78                   ld (CONTPNT),hl
19D0:  2a f0 78      l19d0h:      ld hl,(ERRLOC)
19D3:  7c                         ld a,h
19D4:  b5                         or l
19D5:  eb                         ex de,hl
19D6:  21 f2 78                   ld hl,TRAPFLAG
19D9:  28 08                      jr z,l19e3h
19DB:  a6                         and (hl)
19DC:  20 05                      jr nz,l19e3h
19DE:  35                         dec (hl)
19DF:  eb                         ex de,hl
19E0:  c3 36 1d                   jp l1d36h
19E3:  af            l19e3h:      xor a
19E4:  77                         ld (hl),a
19E5:  59                         ld e,c
19E6:  cd f9 20                   call sub_20f9h
19E9:  21 ec 3c                   ld hl,l3cech
19EC:  cd a6 79                   call 079a6h
19EF:  57                         ld d,a
19F0:  3e 3f                      ld a,03fh
19F2:  cd 2a 03                   call sub_032ah
19F5:  cd d4 3c                   call 03cd4h
19F8:  00                         nop
19F9:  00                         nop
19FA:  00                         nop
19FB:  00                         nop
19FC:  00                         nop
19FD:  00                         nop
19FE:  21 1d 19                   ld hl,l191dh
1A01:  e5                         push hl
1A02:  2a ea 78                   ld hl,(078eah)
1A05:  e3                         ex (sp),hl
1A06:  cd a7 28      l1a06h:      call OUTSTR
1A09:  e1                         pop hl
1A0A:  11 fe ff                   ld de,0fffeh
1A0D:  df                         rst 18h
1A0E:  ca 74 06                   jp z,BASINIT1
1A11:  7c                         ld a,h
1A12:  a5                         and l
1A13:  3c                         inc a
1A14:  c4 a7 0f                   call nz,sub_0fa7h
1A17:  3e c1                      ld a,0c1h
1A19:  cd 8b 03      BASENT:      call sub_038bh
1A1C:  cd ac 79                   call 079ach
1A1F:  00                         nop
1A20:  00                         nop
1A21:  00                         nop
1A22:  cd f9 20                   call sub_20f9h
1A25:  21 29 19                   ld hl,l1929h
1A28:  cd a7 28                   call OUTSTR
1A2B:  3a 9a 78                   ld a,(0789ah)
1A2E:  d6 02                      sub 002h
1A30:  00                         nop
1A31:  00                         nop
1A32:  00                         nop
1A33:  21 ff ff      l1a33h:      ld hl,0ffffh
1A36:  22 a2 78                   ld (078a2h),hl
1A39:  3a e1 78                   ld a,(078e1h)
1A3C:  b7                         or a
1A3D:  28 3a                      jr z,l1a79h
1A3F:  2a e2 78                   ld hl,(078e2h)
1A42:  e5                         push hl
1A43:  cd af 0f                   call sub_0fafh
1A46:  3e 20                      ld a,020h
1A48:  cd 2a 03                   call sub_032ah
1A4B:  d1                         pop de
1A4C:  d5                         push de
1A4D:  cd 2c 1b                   call sub_1b2ch
1A50:  dc 53 2e                   call c,sub_2e53h
1A53:  00                         nop
1A54:  cd e3 03                   call l03e3h
1A57:  d1                         pop de
1A58:  30 06                      jr nc,l1a60h
1A5A:  af            l1a5ah:      xor a
1A5B:  32 e1 78                   ld (078e1h),a
1A5E:  18 b9                      jr BASENT
1A60:  2a e4 78      l1a60h:      ld hl,(078e4h)
1A63:  19                         add hl,de
1A64:  38 f4                      jr c,l1a5ah
1A66:  d5                         push de
1A67:  11 f9 ff                   ld de,0fff9h
1A6A:  df                         rst 18h
1A6B:  d1                         pop de
1A6C:  30 ec                      jr nc,l1a5ah
1A6E:  22 e2 78                   ld (078e2h),hl
1A71:  00                         nop
1A72:  00                         nop
1A73:  21 e7 79                   ld hl,079e7h
1A76:  c3 81 1a                   jp l1a81h
1A79:  00            l1a79h:      nop
1A7A:  00                         nop
1A7B:  cd e3 03                   call l03e3h
1A7E:  da 33 1a                   jp c,l1a33h
1A81:  d7            l1a81h:      rst 10h
1A82:  3c                         inc a
1A83:  3d                         dec a
1A84:  ca 33 1a                   jp z,l1a33h
1A87:  f5                         push af
1A88:  cd 5a 1e                   call sub_1e5ah
1A8B:  2b            l1a8bh:      dec hl
1A8C:  7e                         ld a,(hl)
1A8D:  fe 20                      cp 020h
1A8F:  28 fa                      jr z,l1a8bh
1A91:  23                         inc hl
1A92:  7e                         ld a,(hl)
1A93:  fe 20                      cp 020h
1A95:  cc c9 09                   call z,sub_09c9h
1A98:  d5                         push de
1A99:  cd c0 1b                   call sub_1bc0h
1A9C:  d1                         pop de
1A9D:  f1                         pop af
1A9E:  22 e6 78                   ld (078e6h),hl
1AA1:  cd b2 79                   call 079b2h
1AA4:  d2 5a 1d                   jp nc,l1d5ah
1AA7:  d5                         push de
1AA8:  c5                         push bc
1AA9:  af                         xor a
1AAA:  32 dd 78                   ld (078ddh),a
1AAD:  d7                         rst 10h
1AAE:  b7                         or a
1AAF:  f5                         push af
1AB0:  eb                         ex de,hl
1AB1:  22 ec 78                   ld (078ech),hl
1AB4:  eb                         ex de,hl
1AB5:  cd 2c 1b                   call sub_1b2ch
1AB8:  c5                         push bc
1AB9:  dc e4 2b                   call c,sub_2be4h
1ABC:  d1                         pop de
1ABD:  f1                         pop af
1ABE:  d5                         push de
1ABF:  28 27                      jr z,l1ae8h
1AC1:  d1                         pop de
1AC2:  2a f9 78                   ld hl,(PROGEND)
1AC5:  e3                         ex (sp),hl
1AC6:  c1                         pop bc
1AC7:  09                         add hl,bc
1AC8:  e5                         push hl
1AC9:  cd 55 19                   call sub_1955h
1ACC:  e1                         pop hl
1ACD:  22 f9 78                   ld (PROGEND),hl
1AD0:  eb                         ex de,hl
1AD1:  74                         ld (hl),h
1AD2:  d1                         pop de
1AD3:  e5                         push hl
1AD4:  23                         inc hl
1AD5:  23                         inc hl
1AD6:  73                         ld (hl),e
1AD7:  23                         inc hl
1AD8:  72                         ld (hl),d
1AD9:  23                         inc hl
1ADA:  eb                         ex de,hl
1ADB:  2a a7 78                   ld hl,(078a7h)
1ADE:  eb                         ex de,hl
1ADF:  1b                         dec de
1AE0:  1b                         dec de
1AE1:  1a            l1ae1h:      ld a,(de)
1AE2:  77                         ld (hl),a
1AE3:  23                         inc hl
1AE4:  13                         inc de
1AE5:  b7                         or a
1AE6:  20 f9                      jr nz,l1ae1h
1AE8:  d1            l1ae8h:      pop de
1AE9:  cd fc 1a                   call sub_1afch
1AEC:  cd b5 79                   call 079b5h
1AEF:  cd 5d 1b                   call NWPRGST
1AF2:  cd b8 79                   call 079b8h
1AF5:  c3 33 1a                   jp l1a33h
1AF8:  2a a4 78                   ld hl,(PROGST)
1AFB:  eb                         ex de,hl
1AFC:  62            sub_1afch:   ld h,d
1AFD:  6b                         ld l,e
1AFE:  7e                         ld a,(hl)
1AFF:  23                         inc hl
1B00:  b6                         or (hl)
1B01:  c8                         ret z
1B02:  23                         inc hl
1B03:  23                         inc hl
1B04:  23                         inc hl
1B05:  af                         xor a
1B06:  be            l1b06h:      cp (hl)
1B07:  23                         inc hl
1B08:  20 fc                      jr nz,l1b06h
1B0A:  eb                         ex de,hl
1B0B:  73                         ld (hl),e
1B0C:  23                         inc hl
1B0D:  72                         ld (hl),d
1B0E:  18 ec                      jr sub_1afch
1B10:  11 00 00      sub_1b10h:   ld de,RESET
1B13:  d5                         push de
1B14:  28 09                      jr z,$+11
1B16:  d1                         pop de
1B17:  cd 4f 1e                   call sub_1e4fh
1B1A:  d5                         push de
1B1B:  28 0b                      jr z,l1b28h
1B1D:  cf                         rst 8
1B1E:  ce 11                      adc a,011h
1B20:  fa ff c4                   jp m,0c4ffh
1B23:  4f                         ld c,a
1B24:  1e c2                      ld e,0c2h
1B26:  97                         sub a
1B27:  19                         add hl,de
1B28:  eb            l1b28h:      ex de,hl
1B29:  d1                         pop de
1B2A:  e3            sub_1b2ah:   ex (sp),hl
1B2B:  e5                         push hl
1B2C:  2a a4 78      sub_1b2ch:   ld hl,(PROGST)
1B2F:  44            l1b2fh:      ld b,h
1B30:  4d                         ld c,l
1B31:  7e                         ld a,(hl)
1B32:  23                         inc hl
1B33:  b6                         or (hl)
1B34:  2b                         dec hl
1B35:  c8                         ret z
1B36:  23                         inc hl
1B37:  23                         inc hl
1B38:  7e                         ld a,(hl)
1B39:  23                         inc hl
1B3A:  66                         ld h,(hl)
1B3B:  6f                         ld l,a
1B3C:  df                         rst 18h
1B3D:  60                         ld h,b
1B3E:  69                         ld l,c
1B3F:  7e                         ld a,(hl)
1B40:  23                         inc hl
1B41:  66                         ld h,(hl)
1B42:  6f                         ld l,a
1B43:  3f                         ccf
1B44:  c8                         ret z
1B45:  3f                         ccf
1B46:  d0                         ret nc
1B47:  18 e6                      jr l1b2fh

;********************************************************************************
;* NEW – Command                                                                *
;* Reset all variables and pointers                                             *
;* (the string area definition remains unchanged)                               *
;********************************************************************************

1B49:  c0                         ret nz           ; Paramiter? Yes -> syntax error
1B4A:  cd c9 01                   call CLRSCR   ; call Clear Screen 
1B4D:  2a a4 78      NEWCLRP:     ld hl,(PROGST)   ; Load start of program text into HL
1B50:  cd f8 1d                   call 01df8h	   ; call TROFF
1B53:  32 e1 78                   ld (078e1h),a	   ; clear AUTO Mode
1B56:  77                         ld (hl),a		   ; set line pointer to zero
1B57:  23                         inc hl
1B58:  77                         ld (hl),a		   
1B59:  23                         inc hl           ; Pointer after: 0000h, HL = 78a6h
1B5A:  22 f9 78                   ld (PROGEND),hl  ; Progend to 1 byte after line pointer(78a6h)
1B5D:  2a a4 78      NWPRGST:     ld hl,(PROGST)   ; Load Program start address
1B60:  2b                         dec hl           ; point to continuation of line pointer PROGST+1
1B61:  22 df 78      STPCPTR:     ld (PROGCNT),hl  ; set continuation pointer

; Typecode table = single precision floating point
1B64:  06 1a                      ld b,01ah        ; Table has 26 entries (A-Z)
1B66:  21 01 79                   ld hl,TYPETAB    ; HL = address of Typecode table	 
1B69:  36 04         l1b69h:      ld (hl),004h	   ; set typecode to single precision floating point
1B6B:  23                         inc hl           
1B6C:  10 fb                      djnz l1b69h      ; loop for all 26 entries

; trapflag reset, clear string variables and pointers
1B6E:  af                         xor a			   ; clear A (and trapflag)
1B6F:  32 f2 78                   ld (TRAPFLAG),a  ; clear trapflag	
1B72:  6f                         ld l,a           ; clear HL
1B73:  67                         ld h,a
1B74:  22 f0 78                   ld (ERRLOC),hl   ; clear error routine address
1B77:  22 f7 78                   ld (CONTPNT),hl  ; clear continuation pointer
1B7A:  2a b1 78                   ld hl,(MEMTOP)   ; load memory top to HL
1B7D:  22 d6 78                   ld (STRAPNT),hl  ; set string area pointer to memory top

; variable reset
1B80:  cd 91 1d                   call sub_1d91h   ; call RESTORE
1B83:  2a f9 78                   ld hl,(PROGEND)  ; Load program end address
1B86:  22 fb 78                   ld (DIMVAR),hl   ; = end addres of variable table
1B89:  22 fd 78                   ld (MTRIXTAB),hl ; = end addres of matrix table. 
1B8C:  cd bb 79                   call 079bbh      ; call RAM expansion exit

; stack pointer reset / init runtime enviornment
1B8F:  c1            INITRT:      pop bc           ; load return address (from caller)
1B90:  2a a0 78                   ld hl,(STRINGS)  ; load address of string area
1B93:  2b                         dec hl           ; SUB 4	
1B94:  2b                         dec hl
1B95:  22 e8 78                   ld (STSTACK),hl  ; save as start of stack address 
1B98:  23                         inc hl		   ; ADD 4	
1B99:  23                         inc hl

; init runtime stack pointer (string buffer will be overwritten as needed)
1B9A:  f9            INITRTSP:    ld sp,hl		   ; make it the stack pointer (fall through or caller)
1B9B:  21 b5 78                   ld hl,STRBUFP    ; HL = Start of string buffer
1B9E:  22 b3 78                   ld (WORKPNT),hl  ; set as workspace pointer
1BA1:  cd 8b 03                   call sub_038bh   ; output flag to screen, CR to printer if needed 
1BA4:  cd 69 21                   call sub_2169h   ; final check
1BA7:  af                         xor a			   ; clear a
1BA8:  67                         ld h,a		   ; clear hl
1BA9:  6f                         ld l,a
1BAA:  32 dc 78                   ld (IDXLOCK),a   ; clear indexing lock 
1BAD:  e5                         push hl          ; push 0000 to stack as end marker
1BAE:  c5                         push bc          ; pus return address back to stack
1BAF:  2a df 78                   ld hl,(PROGCNT)  ; HL = program continuation pointer
1BB2:  c9                         ret


1BB3:  3e 3f         sub_1bb3h:   ld a,03fh
1BB5:  cd 2a 03                   call sub_032ah
1BB8:  3e 20                      ld a,020h
1BBA:  cd 2a 03                   call sub_032ah
1BBD:  c3 3a 05                   jp l053ah
1BC0:  af            sub_1bc0h:   xor a
1BC1:  32 b0 78                   ld (078b0h),a
1BC4:  4f                         ld c,a
1BC5:  eb                         ex de,hl
1BC6:  2a a7 78                   ld hl,(078a7h)
1BC9:  2b                         dec hl
1BCA:  2b            l1bcah:      dec hl
1BCB:  eb                         ex de,hl
1BCC:  7e            l1bcch:      ld a,(hl)
1BCD:  fe 20                      cp 020h
1BCF:  ca 5b 1c                   jp z,l1c5bh
1BD2:  47                         ld b,a
1BD3:  fe 22                      cp 022h
1BD5:  ca 77 1c                   jp z,l1c77h
1BD8:  b7                         or a
1BD9:  ca 7d 1c                   jp z,l1c7dh
1BDC:  3a b0 78                   ld a,(078b0h)
1BDF:  b7                         or a
1BE0:  7e                         ld a,(hl)
1BE1:  c2 5b 1c                   jp nz,l1c5bh
1BE4:  fe 3f                      cp 03fh
1BE6:  3e b2                      ld a,0b2h
1BE8:  ca 5b 1c                   jp z,l1c5bh
1BEB:  7e                         ld a,(hl)
1BEC:  fe 30                      cp 030h
1BEE:  38 05                      jr c,l1bf5h
1BF0:  fe 3c                      cp 03ch
1BF2:  da 5b 1c                   jp c,l1c5bh
1BF5:  d5            l1bf5h:      push de
1BF6:  11 4f 16                   ld de,0164fh
1BF9:  c5                         push bc
1BFA:  01 3d 1c                   ld bc,l1c3dh
1BFD:  c5                         push bc
1BFE:  06 7f                      ld b,07fh
1C00:  7e                         ld a,(hl)
1C01:  fe 61                      cp 061h
1C03:  38 07                      jr c,l1c0ch
1C05:  fe 7b                      cp 07bh
1C07:  30 03                      jr nc,l1c0ch
1C09:  e6 5f                      and 05fh
1C0B:  77                         ld (hl),a
1C0C:  4e            l1c0ch:      ld c,(hl)
1C0D:  eb                         ex de,hl
1C0E:  23            l1c0eh:      inc hl
1C0F:  b6                         or (hl)
1C10:  f2 0e 1c                   jp p,l1c0eh
1C13:  04                         inc b
1C14:  7e                         ld a,(hl)
1C15:  e6 7f                      and 07fh
1C17:  c8                         ret z
1C18:  b9                         cp c
1C19:  20 f3                      jr nz,l1c0eh
1C1B:  eb                         ex de,hl
1C1C:  e5                         push hl
1C1D:  13            l1c1dh:      inc de
1C1E:  1a                         ld a,(de)
1C1F:  b7                         or a
1C20:  fa 39 1c                   jp m,l1c39h
1C23:  4f                         ld c,a
1C24:  78                         ld a,b
1C25:  fe 8d                      cp 08dh
1C27:  20 02                      jr nz,l1c2bh
1C29:  d7                         rst 10h
1C2A:  2b                         dec hl
1C2B:  23            l1c2bh:      inc hl
1C2C:  7e                         ld a,(hl)
1C2D:  fe 61                      cp 061h
1C2F:  38 02                      jr c,l1c33h
1C31:  e6 5f                      and 05fh
1C33:  b9            l1c33h:      cp c
1C34:  28 e7                      jr z,l1c1dh
1C36:  e1                         pop hl
1C37:  18 d3                      jr l1c0ch
1C39:  48            l1c39h:      ld c,b
1C3A:  f1                         pop af
1C3B:  eb                         ex de,hl
1C3C:  c9                         ret
1C3D:  eb            l1c3dh:      ex de,hl
1C3E:  79                         ld a,c
1C3F:  c1                         pop bc
1C40:  d1                         pop de
1C41:  eb                         ex de,hl
1C42:  fe 95                      cp 095h
1C44:  36 3a                      ld (hl),03ah
1C46:  20 02                      jr nz,l1c4ah
1C48:  0c                         inc c
1C49:  23                         inc hl
1C4A:  fe fb         l1c4ah:      cp 0fbh
1C4C:  20 0c                      jr nz,l1c5ah
1C4E:  36 3a                      ld (hl),03ah
1C50:  23                         inc hl
1C51:  06 93                      ld b,093h
1C53:  70                         ld (hl),b
1C54:  23                         inc hl
1C55:  eb                         ex de,hl
1C56:  0c                         inc c
1C57:  0c                         inc c
1C58:  18 1d                      jr l1c77h
1C5A:  eb            l1c5ah:      ex de,hl
1C5B:  23            l1c5bh:      inc hl
1C5C:  12                         ld (de),a
1C5D:  13                         inc de
1C5E:  0c                         inc c
1C5F:  d6 3a                      sub 03ah
1C61:  28 04                      jr z,l1c67h
1C63:  fe 4e                      cp 04eh
1C65:  20 03                      jr nz,l1c6ah
1C67:  32 b0 78      l1c67h:      ld (078b0h),a
1C6A:  d6 59         l1c6ah:      sub 059h
1C6C:  c2 cc 1b                   jp nz,l1bcch
1C6F:  47                         ld b,a
1C70:  7e            l1c70h:      ld a,(hl)
1C71:  b7                         or a
1C72:  28 09                      jr z,l1c7dh
1C74:  b8                         cp b
1C75:  28 e4                      jr z,l1c5bh
1C77:  23            l1c77h:      inc hl
1C78:  12                         ld (de),a
1C79:  0c                         inc c
1C7A:  13                         inc de
1C7B:  18 f3                      jr l1c70h
1C7D:  21 05 00      l1c7dh:      ld hl,l0005h
1C80:  44                         ld b,h
1C81:  09                         add hl,bc
1C82:  44                         ld b,h
1C83:  4d                         ld c,l
1C84:  2a a7 78                   ld hl,(078a7h)
1C87:  2b                         dec hl
1C88:  2b                         dec hl
1C89:  2b                         dec hl
1C8A:  12                         ld (de),a
1C8B:  13                         inc de
1C8C:  12                         ld (de),a
1C8D:  13                         inc de
1C8E:  12                         ld (de),a
1C8F:  c9                         ret
1C90:  7c            CMPHLDE:     ld a,h
1C91:  92                         sub d
1C92:  c0                         ret nz
1C93:  7d                         ld a,l
1C94:  93                         sub e
1C95:  c9                         ret
1C96:  7e            EXSTR:       ld a,(hl)
1C97:  e3                         ex (sp),hl
1C98:  be                         cp (hl)
1C99:  23                         inc hl
1C9A:  e3                         ex (sp),hl
1C9B:  ca 78 1d                   jp z,CHKCHR
1C9E:  c3 97 19                   jp l1997h
1CA1:  3e 64                      ld a,064h
1CA3:  32 dc 78                   ld (IDXLOCK),a
1CA6:  cd 21 1f                   call l1f21h
1CA9:  e3                         ex (sp),hl
1CAA:  cd 36 19                   call sub_1936h
1CAD:  d1                         pop de
1CAE:  20 05                      jr nz,l1cb5h
1CB0:  09                         add hl,bc
1CB1:  f9                         ld sp,hl
1CB2:  22 e8 78                   ld (STSTACK),hl
1CB5:  eb            l1cb5h:      ex de,hl
1CB6:  0e 08                      ld c,008h
1CB8:  cd 63 19                   call sub_1963h
1CBB:  e5                         push hl
1CBC:  cd 05 1f                   call l1f05h
1CBF:  e3                         ex (sp),hl
1CC0:  e5                         push hl
1CC1:  2a a2 78                   ld hl,(078a2h)
1CC4:  e3                         ex (sp),hl
1CC5:  cf                         rst 8
1CC6:  bd                         cp l
1CC7:  e7                         rst 20h
1CC8:  ca f6 0a                   jp z,l0af6h
1CCB:  d2 f6 0a                   jp nc,l0af6h
1CCE:  f5                         push af
1CCF:  cd 37 23                   call 02337h
1CD2:  f1                         pop af
1CD3:  e5                         push hl
1CD4:  f2 ec 1c                   jp p,l1cech
1CD7:  cd 7f 0a                   call l0a7fh
1CDA:  e3                         ex (sp),hl
1CDB:  11 01 00                   ld de,l0001h
1CDE:  7e                         ld a,(hl)
1CDF:  fe cc                      cp 0cch
1CE1:  cc 01 2b                   call z,sub_2b01h
1CE4:  d5                         push de
1CE5:  e5                         push hl
1CE6:  eb                         ex de,hl
1CE7:  cd 9e 09                   call sub_099eh
1CEA:  18 22                      jr l1d0eh
1CEC:  cd b1 0a      l1cech:      call sub_0ab1h
1CEF:  cd bf 09                   call sub_09bfh
1CF2:  e1                         pop hl
1CF3:  c5                         push bc
1CF4:  d5                         push de
1CF5:  01 00 81                   ld bc,08100h
1CF8:  51                         ld d,c
1CF9:  5a                         ld e,d
1CFA:  7e                         ld a,(hl)
1CFB:  fe cc                      cp 0cch
1CFD:  3e 01                      ld a,001h
1CFF:  20 0e                      jr nz,l1d0fh
1D01:  cd 38 23                   call sub_2338h
1D04:  e5                         push hl
1D05:  cd b1 0a                   call sub_0ab1h
1D08:  cd bf 09                   call sub_09bfh
1D0B:  cd 55 09                   call sub_0955h
1D0E:  e1            l1d0eh:      pop hl
1D0F:  c5            l1d0fh:      push bc
1D10:  d5                         push de
1D11:  4f                         ld c,a
1D12:  e7                         rst 20h
1D13:  47                         ld b,a
1D14:  c5                         push bc
1D15:  e5                         push hl
1D16:  2a df 78                   ld hl,(PROGCNT)
1D19:  e3                         ex (sp),hl
1D1A:  06 81         l1d1ah:      ld b,081h
1D1C:  c5                         push bc
1D1D:  33                         inc sp
1D1E:  cd 58 03      l1d1eh:      call sub_0358h
1D21:  b7                         or a
1D22:  c4 a0 1d                   call nz,sub_1da0h
1D25:  22 e6 78                   ld (078e6h),hl
1D28:  ed 73 e8                   ld (STSTACK),sp
1D2C:  7e                         ld a,(hl)
1D2D:  fe 3a                      cp 03ah
1D2F:  28 29                      jr z,l1d5ah
1D31:  b7                         or a
1D32:  c2 97 19                   jp nz,l1997h
1D35:  23                         inc hl
1D36:  7e            l1d36h:      ld a,(hl)
1D37:  23                         inc hl
1D38:  b6                         or (hl)
1D39:  ca 7e 19                   jp z,l197eh
1D3C:  23                         inc hl
1D3D:  5e                         ld e,(hl)
1D3E:  23                         inc hl
1D3F:  56                         ld d,(hl)
1D40:  eb                         ex de,hl
1D41:  22 a2 78                   ld (078a2h),hl
1D44:  3a 1b 79                   ld a,(0791bh)
1D47:  b7                         or a
1D48:  28 0f                      jr z,l1d59h
1D4A:  d5                         push de
1D4B:  3e 3c                      ld a,03ch
1D4D:  cd 2a 03                   call sub_032ah
1D50:  cd af 0f                   call sub_0fafh
1D53:  3e 3e                      ld a,03eh
1D55:  cd 2a 03                   call sub_032ah
1D58:  d1                         pop de
1D59:  eb            l1d59h:      ex de,hl
1D5A:  d7            l1d5ah:      rst 10h
1D5B:  11 1e 1d                   ld de,l1d1eh
1D5E:  d5                         push de
1D5F:  c8            l1d5fh:      ret z
1D60:  d6 80         l1d60h:      sub 080h
1D62:  da 21 1f                   jp c,l1f21h
1D65:  fe 3c                      cp 03ch
1D67:  d2 e7 2a                   jp nc,l2ae7h
1D6A:  07                         rlca
1D6B:  4f                         ld c,a
1D6C:  06 00                      ld b,000h
1D6E:  eb                         ex de,hl
1D6F:  21 22 18                   ld hl,l1822h
1D72:  09                         add hl,bc
1D73:  4e                         ld c,(hl)
1D74:  23                         inc hl
1D75:  46                         ld b,(hl)
1D76:  c5                         push bc
1D77:  eb                         ex de,hl
1D78:  23            CHKCHR:      inc hl
1D79:  7e                         ld a,(hl)
1D7A:  fe 3a                      cp 03ah
1D7C:  d0                         ret nc
1D7D:  fe 20                      cp 020h
1D7F:  ca 78 1d                   jp z,CHKCHR
1D82:  fe 0b                      cp 00bh
1D84:  30 05                      jr nc,l1d8bh
1D86:  fe 09                      cp 009h
1D88:  d2 78 1d                   jp nc,CHKCHR
1D8B:  fe 30         l1d8bh:      cp 030h
1D8D:  3f                         ccf
1D8E:  3c                         inc a
1D8F:  3d                         dec a
1D90:  c9                         ret
1D91:  eb            sub_1d91h:   ex de,hl
1D92:  2a a4 78                   ld hl,(PROGST)
1D95:  2b                         dec hl
1D96:  22 ff 78      l1d96h:      ld (078ffh),hl
1D99:  eb                         ex de,hl
1D9A:  c9                         ret
1D9B:  cd 58 03      sub_1d9bh:   call sub_0358h
1D9E:  b7                         or a
1D9F:  c8                         ret z
1DA0:  00            sub_1da0h:   nop
1DA1:  00                         nop
1DA2:  00                         nop
1DA3:  00                         nop
1DA4:  00                         nop
1DA5:  32 99 78                   ld (07899h),a
1DA8:  3d                         dec a
1DA9:  c0                         ret nz
1DAA:  3c                         inc a
1DAB:  c3 b4 1d                   jp l1db4h
1DAE:  c0                         ret nz
1DAF:  f5                         push af
1DB0:  cc bb 79                   call z,079bbh
1DB3:  f1                         pop af
1DB4:  22 e6 78      l1db4h:      ld (078e6h),hl
1DB7:  21 b5 78                   ld hl,STRBUFP
1DBA:  22 b3 78                   ld (WORKPNT),hl
1DBD:  21 f6 ff                   ld hl,0fff6h
1DC0:  c1                         pop bc
1DC1:  2a a2 78      l1dc1h:      ld hl,(078a2h)
1DC4:  e5                         push hl
1DC5:  f5                         push af
1DC6:  7d                         ld a,l
1DC7:  a4                         and h
1DC8:  3c                         inc a
1DC9:  28 09                      jr z,l1dd4h
1DCB:  22 f5 78                   ld (078f5h),hl
1DCE:  2a e6 78                   ld hl,(078e6h)
1DD1:  22 f7 78                   ld (CONTPNT),hl
1DD4:  cd 8b 03      l1dd4h:      call sub_038bh
1DD7:  cd f9 20                   call sub_20f9h
1DDA:  f1                         pop af
1DDB:  21 30 19                   ld hl,l1930h
1DDE:  c2 06 1a                   jp nz,l1a06h
1DE1:  c3 18 1a                   jp 01a18h
1DE4:  2a f7 78                   ld hl,(CONTPNT)
1DE7:  7c                         ld a,h
1DE8:  b5                         or l
1DE9:  1e 20                      ld e,020h
1DEB:  ca a2 19                   jp z,l19a2h
1DEE:  eb                         ex de,hl
1DEF:  2a f5 78                   ld hl,(078f5h)
1DF2:  22 a2 78                   ld (078a2h),hl
1DF5:  eb                         ex de,hl
1DF6:  c9                         ret
1DF7:  3e af                      ld a,0afh
1DF9:  32 1b 79                   ld (0791bh),a
1DFC:  c9                         ret
1DFD:  f1                         pop af
1DFE:  e1                         pop hl
1DFF:  c9                         ret
1E00:  1e 03                      ld e,003h
1E02:  01 1e 02                   ld bc,l021eh
1E05:  01 1e 04                   ld bc,l041eh
1E08:  01 1e 08                   ld bc,l081eh
1E0B:  cd 3d 1e      l1e0bh:      call sub_1e3dh
1E0E:  01 97 19                   ld bc,l1997h
1E11:  c5                         push bc
1E12:  d8                         ret c
1E13:  d6 41                      sub 041h
1E15:  4f                         ld c,a
1E16:  47                         ld b,a
1E17:  d7                         rst 10h
1E18:  fe ce                      cp 0ceh
1E1A:  20 09                      jr nz,l1e25h
1E1C:  d7                         rst 10h
1E1D:  cd 3d 1e                   call sub_1e3dh
1E20:  d8                         ret c
1E21:  d6 41                      sub 041h
1E23:  47                         ld b,a
1E24:  d7                         rst 10h
1E25:  78            l1e25h:      ld a,b
1E26:  91                         sub c
1E27:  d8                         ret c
1E28:  3c                         inc a
1E29:  e3                         ex (sp),hl
1E2A:  21 01 79                   ld hl,TYPETAB
1E2D:  06 00                      ld b,000h
1E2F:  09                         add hl,bc
1E30:  73            l1e30h:      ld (hl),e
1E31:  23                         inc hl
1E32:  3d                         dec a
1E33:  20 fb                      jr nz,l1e30h
1E35:  e1                         pop hl
1E36:  7e                         ld a,(hl)
1E37:  fe 2c                      cp 02ch
1E39:  c0                         ret nz
1E3A:  d7                         rst 10h
1E3B:  18 ce                      jr l1e0bh
1E3D:  7e            sub_1e3dh:   ld a,(hl)
1E3E:  fe 41                      cp 041h
1E40:  d8                         ret c
1E41:  fe 5b                      cp 05bh
1E43:  3f                         ccf
1E44:  c9                         ret
1E45:  d7            sub_1e45h:   rst 10h
1E46:  cd 02 2b      sub_1e46h:   call sub_2b02h
1E49:  f0                         ret p
1E4A:  1e 08         l1e4ah:      ld e,008h
1E4C:  c3 a2 19                   jp l19a2h
1E4F:  7e            sub_1e4fh:   ld a,(hl)
1E50:  fe 2e                      cp 02eh
1E52:  eb                         ex de,hl
1E53:  2a ec 78                   ld hl,(078ech)
1E56:  eb                         ex de,hl
1E57:  ca 78 1d                   jp z,CHKCHR
1E5A:  2b            sub_1e5ah:   dec hl
1E5B:  11 00 00      sub_1e5bh:   ld de,RESET
1E5E:  d7            l1e5eh:      rst 10h
1E5F:  d0                         ret nc
1E60:  e5                         push hl
1E61:  f5                         push af
1E62:  21 98 19                   ld hl,l1997h+1
1E65:  df                         rst 18h
1E66:  da 97 19                   jp c,l1997h
1E69:  62                         ld h,d
1E6A:  6b                         ld l,e
1E6B:  19                         add hl,de
1E6C:  29                         add hl,hl
1E6D:  19                         add hl,de
1E6E:  29                         add hl,hl
1E6F:  f1                         pop af
1E70:  d6 30                      sub 030h
1E72:  5f                         ld e,a
1E73:  16 00                      ld d,000h
1E75:  19                         add hl,de
1E76:  eb                         ex de,hl
1E77:  e1                         pop hl
1E78:  18 e4                      jr l1e5eh
1E7A:  ca 61 1b                   jp z,STPCPTR
1E7D:  cd 46 1e                   call sub_1e46h
1E80:  2b                         dec hl
1E81:  d7                         rst 10h
1E82:  c0                         ret nz
1E83:  e5                         push hl
1E84:  2a b1 78                   ld hl,(MEMTOP)
1E87:  7d                         ld a,l
1E88:  93                         sub e
1E89:  5f                         ld e,a
1E8A:  7c                         ld a,h
1E8B:  9a                         sbc a,d
1E8C:  57                         ld d,a
1E8D:  da 7a 19                   jp c,l197ah
1E90:  2a f9 78                   ld hl,(PROGEND)
1E93:  01 28 00                   ld bc,l0028h
1E96:  09                         add hl,bc
1E97:  df                         rst 18h
1E98:  d2 7a 19                   jp nc,l197ah
1E9B:  eb                         ex de,hl
1E9C:  22 a0 78                   ld (STRINGS),hl
1E9F:  e1                         pop hl
1EA0:  c3 61 1b                   jp STPCPTR
1EA3:  ca 5d 1b                   jp z,NWPRGST
1EA6:  cd c7 79                   call 079c7h
1EA9:  cd 61 1b                   call STPCPTR
1EAC:  01 1e 1d                   ld bc,l1d1eh
1EAF:  18 10                      jr l1ec1h
1EB1:  0e 03                      ld c,003h
1EB3:  cd 63 19                   call sub_1963h
1EB6:  c1                         pop bc
1EB7:  e5                         push hl
1EB8:  e5                         push hl
1EB9:  2a a2 78                   ld hl,(078a2h)
1EBC:  e3                         ex (sp),hl
1EBD:  3e 91                      ld a,091h
1EBF:  f5                         push af
1EC0:  33                         inc sp
1EC1:  c5            l1ec1h:      push bc
1EC2:  cd 5a 1e      l1ec2h:      call sub_1e5ah
1EC5:  cd 07 1f      l1ec5h:      call l1f05h+2
1EC8:  e5                         push hl
1EC9:  2a a2 78                   ld hl,(078a2h)
1ECC:  df                         rst 18h
1ECD:  e1                         pop hl
1ECE:  23                         inc hl
1ECF:  dc 2f 1b                   call c,l1b2fh
1ED2:  d4 2c 1b                   call nc,sub_1b2ch
1ED5:  60                         ld h,b
1ED6:  69                         ld l,c
1ED7:  2b                         dec hl
1ED8:  d8                         ret c
1ED9:  1e 0e         l1ed9h:      ld e,00eh
1EDB:  c3 a2 19                   jp l19a2h
1EDE:  c0                         ret nz
1EDF:  16 ff                      ld d,0ffh
1EE1:  cd 36 19                   call sub_1936h
1EE4:  f9                         ld sp,hl
1EE5:  22 e8 78                   ld (STSTACK),hl
1EE8:  fe 91                      cp 091h
1EEA:  1e 04                      ld e,004h
1EEC:  c2 a2 19                   jp nz,l19a2h
1EEF:  e1                         pop hl
1EF0:  22 a2 78                   ld (078a2h),hl
1EF3:  23                         inc hl
1EF4:  7c                         ld a,h
1EF5:  b5                         or l
1EF6:  20 07                      jr nz,l1effh
1EF8:  3a dd 78                   ld a,(078ddh)
1EFB:  b7                         or a
1EFC:  c2 18 1a                   jp nz,01a18h
1EFF:  21 1e 1d      l1effh:      ld hl,l1d1eh
1F02:  e3                         ex (sp),hl
1F03:  3e e1                      ld a,0e1h
1F05:  01 3a 0e      l1f05h:      ld bc,l0e3ah
1F08:  00                         nop
1F09:  06 00                      ld b,000h
1F0B:  79            l1f0bh:      ld a,c
1F0C:  48                         ld c,b
1F0D:  47                         ld b,a
1F0E:  7e            l1f0eh:      ld a,(hl)
1F0F:  b7                         or a
1F10:  c8                         ret z
1F11:  b8                         cp b
1F12:  c8                         ret z
1F13:  23                         inc hl
1F14:  fe 22                      cp 022h
1F16:  28 f3                      jr z,l1f0bh
1F18:  d6 8f                      sub 08fh
1F1A:  20 f2                      jr nz,l1f0eh
1F1C:  b8                         cp b
1F1D:  8a                         adc a,d
1F1E:  57                         ld d,a
1F1F:  18 ed                      jr l1f0eh
1F21:  cd 0d 26      l1f21h:      call 0260dh
1F24:  cf                         rst 8
1F25:  d5                         push de
1F26:  eb                         ex de,hl
1F27:  22 df 78                   ld (PROGCNT),hl
1F2A:  eb                         ex de,hl
1F2B:  d5                         push de
1F2C:  e7                         rst 20h
1F2D:  f5                         push af
1F2E:  cd 37 23                   call 02337h
1F31:  f1                         pop af
1F32:  e3                         ex (sp),hl
1F33:  c6 03         l1f33h:      add a,003h
1F35:  cd 19 28                   call sub_2819h
1F38:  cd 03 0a                   call sub_0a03h
1F3B:  e5                         push hl
1F3C:  20 28                      jr nz,l1f66h
1F3E:  2a 21 79                   ld hl,(07921h)
1F41:  e5                         push hl
1F42:  23                         inc hl
1F43:  5e                         ld e,(hl)
1F44:  23                         inc hl
1F45:  56                         ld d,(hl)
1F46:  2a a4 78                   ld hl,(PROGST)
1F49:  df            sub_1f49h:   rst 18h
1F4A:  30 0e                      jr nc,$+16
1F4C:  2a a0 78                   ld hl,(STRINGS)
1F4F:  df                         rst 18h
1F50:  d1                         pop de
1F51:  30 0f                      jr nc,l1f62h
1F53:  2a f9 78                   ld hl,(PROGEND)
1F56:  df                         rst 18h
1F57:  30 09                      jr nc,l1f62h
1F59:  3e d1                      ld a,0d1h
1F5B:  cd f5 29                   call sub_29f5h
1F5E:  eb                         ex de,hl
1F5F:  cd 43 28                   call sub_2843h
1F62:  cd f5 29      l1f62h:      call sub_29f5h
1F65:  e3                         ex (sp),hl
1F66:  cd d3 09      l1f66h:      call l09d3h
1F69:  d1                         pop de
1F6A:  e1                         pop hl
1F6B:  c9                         ret
1F6C:  fe 9e         l1f6ch:      cp 09eh
1F6E:  20 25                      jr nz,l1f95h
1F70:  d7                         rst 10h
1F71:  cf                         rst 8
1F72:  8d                         adc a,l
1F73:  cd 5a 1e                   call sub_1e5ah
1F76:  7a                         ld a,d
1F77:  b3                         or e
1F78:  28 09                      jr z,l1f83h
1F7A:  cd 2a 1b                   call sub_1b2ah
1F7D:  50                         ld d,b
1F7E:  59                         ld e,c
1F7F:  e1                         pop hl
1F80:  d2 d9 1e                   jp nc,l1ed9h
1F83:  eb            l1f83h:      ex de,hl
1F84:  22 f0 78                   ld (ERRLOC),hl
1F87:  eb                         ex de,hl
1F88:  d8                         ret c
1F89:  3a f2 78                   ld a,(TRAPFLAG)
1F8C:  b7                         or a
1F8D:  c8                         ret z
1F8E:  3a 9a 78                   ld a,(0789ah)
1F91:  5f                         ld e,a
1F92:  c3 ab 19                   jp l19abh
1F95:  cd 1c 2b      l1f95h:      call sub_2b1ch
1F98:  7e                         ld a,(hl)
1F99:  47                         ld b,a
1F9A:  fe 91                      cp 091h
1F9C:  28 03                      jr z,l1fa1h
1F9E:  cf                         rst 8
1F9F:  8d                         adc a,l
1FA0:  2b                         dec hl
1FA1:  4b            l1fa1h:      ld c,e
1FA2:  0d            l1fa2h:      dec c
1FA3:  78                         ld a,b
1FA4:  ca 60 1d                   jp z,l1d60h
1FA7:  cd 5b 1e                   call sub_1e5bh
1FAA:  fe 2c                      cp 02ch
1FAC:  c0                         ret nz
1FAD:  18 f3                      jr l1fa2h
1FAF:  11 f2 78                   ld de,TRAPFLAG
1FB2:  1a                         ld a,(de)
1FB3:  b7                         or a
1FB4:  ca a0 19                   jp z,019a0h
1FB7:  3c                         inc a
1FB8:  32 9a 78                   ld (0789ah),a
1FBB:  12                         ld (de),a
1FBC:  7e                         ld a,(hl)
1FBD:  fe 87                      cp 087h
1FBF:  28 0c                      jr z,l1fcdh
1FC1:  cd 5a 1e                   call sub_1e5ah
1FC4:  c0                         ret nz
1FC5:  7a                         ld a,d
1FC6:  b3                         or e
1FC7:  c2 c5 1e                   jp nz,l1ec5h
1FCA:  3c                         inc a
1FCB:  18 02                      jr l1fcfh
1FCD:  d7            l1fcdh:      rst 10h
1FCE:  c0                         ret nz
1FCF:  2a ee 78      l1fcfh:      ld hl,(078eeh)
1FD2:  eb                         ex de,hl
1FD3:  2a ea 78                   ld hl,(078eah)
1FD6:  22 a2 78                   ld (078a2h),hl
1FD9:  eb                         ex de,hl
1FDA:  c0                         ret nz
1FDB:  7e                         ld a,(hl)
1FDC:  b7                         or a
1FDD:  20 04                      jr nz,l1fe3h
1FDF:  23                         inc hl
1FE0:  23                         inc hl
1FE1:  23                         inc hl
1FE2:  23                         inc hl
1FE3:  23            l1fe3h:      inc hl
1FE4:  7a                         ld a,d
1FE5:  a3                         and e
1FE6:  3c                         inc a
1FE7:  c2 05 1f                   jp nz,l1f05h
1FEA:  3a dd 78                   ld a,(078ddh)
1FED:  3d                         dec a
1FEE:  ca be 1d                   jp z,01dbeh
1FF1:  c3 05 1f                   jp l1f05h
1FF4:  cd 1c 2b                   call sub_2b1ch
1FF7:  c0                         ret nz
1FF8:  b7                         or a
1FF9:  ca 4a 1e                   jp z,l1e4ah
1FFC:  3d                         dec a
1FFD:  87                         add a,a
1FFE:  5f                         ld e,a
1FFF:  fe 2d                      cp 02dh
2001:  38 02                      jr c,l2005h
2003:  1e 26                      ld e,026h
2005:  c3 a2 19      l2005h:      jp l19a2h
2008:  11 0a 00                   ld de,0000ah
200B:  d5                         push de
200C:  28 17                      jr z,l2025h
200E:  cd 4f 1e                   call sub_1e4fh
2011:  eb                         ex de,hl
2012:  e3                         ex (sp),hl
2013:  28 11                      jr z,l2026h
2015:  eb                         ex de,hl
2016:  cf                         rst 8
2017:  2c                         inc l
2018:  eb                         ex de,hl
2019:  2a e4 78                   ld hl,(078e4h)
201C:  eb                         ex de,hl
201D:  28 06                      jr z,l2025h
201F:  cd 5a 1e                   call sub_1e5ah
2022:  c2 97 19                   jp nz,l1997h
2025:  eb            l2025h:      ex de,hl
2026:  7c            l2026h:      ld a,h
2027:  b5                         or l
2028:  ca 4a 1e                   jp z,l1e4ah
202B:  22 e4 78                   ld (078e4h),hl
202E:  32 e1 78                   ld (078e1h),a
2031:  e1                         pop hl
2032:  22 e2 78                   ld (078e2h),hl
2035:  c1                         pop bc
2036:  c3 33 1a                   jp l1a33h
2039:  cd 37 23                   call 02337h
203C:  7e                         ld a,(hl)
203D:  fe 2c                      cp 02ch
203F:  cc 78 1d                   call z,CHKCHR
2042:  fe ca                      cp 0cah
2044:  cc 78 1d                   call z,CHKCHR
2047:  2b                         dec hl
2048:  e5                         push hl
2049:  cd 94 09                   call sub_0994h
204C:  e1                         pop hl
204D:  28 07                      jr z,l2056h
204F:  d7            l204fh:      rst 10h
2050:  da c2 1e                   jp c,l1ec2h
2053:  c3 5f 1d                   jp l1d5fh
2056:  16 01         l2056h:      ld d,001h
2058:  cd 05 1f      l2058h:      call l1f05h
205B:  b7                         or a
205C:  c8                         ret z
205D:  d7                         rst 10h
205E:  fe 95                      cp 095h
2060:  20 f6                      jr nz,l2058h
2062:  15                         dec d
2063:  20 f3                      jr nz,l2058h
2065:  18 e8                      jr l204fh
2067:  3e 01                      ld a,001h
2069:  32 9c 78                   ld (OUTDEV),a
206C:  c3 9b 20                   jp l209bh
206F:  cd ca 79                   call 079cah
2072:  fe 40                      cp 040h
2074:  20 19                      jr nz,l208fh
2076:  cd 01 2b                   call sub_2b01h
2079:  fe 02                      cp 002h
207B:  d2 4a 1e                   jp nc,l1e4ah
207E:  e5                         push hl
207F:  21 00 70                   ld hl,VRAMBASE
2082:  19                         add hl,de
2083:  22 20 78                   ld (CURPOS),hl
2086:  7b                         ld a,e
2087:  e6 1f                      and 01fh
2089:  32 a6 78                   ld (078a6h),a
208C:  e1                         pop hl
208D:  cf                         rst 8
208E:  2c                         inc l
208F:  fe 23         l208fh:      cp 023h
2091:  20 08                      jr nz,l209bh
2093:  cd 58 3b                   call sub_3b58h
2096:  3e 80                      ld a,080h
2098:  32 9c 78                   ld (OUTDEV),a
209B:  2b            l209bh:      dec hl
209C:  d7                         rst 10h
209D:  cc fe 20                   call z,sub_20feh
20A0:  ca 69 21      l20a0h:      jp z,sub_2169h
20A3:  fe bf                      cp 0bfh
20A5:  ca bd 2c                   jp z,l2cbdh
20A8:  fe bc                      cp 0bch
20AA:  ca 37 21                   jp z,l2137h
20AD:  e5                         push hl
20AE:  fe 2c                      cp 02ch
20B0:  ca 08 21                   jp z,l2108h
20B3:  fe 3b                      cp 03bh
20B5:  ca 0c 3b                   jp z,l3b0ch
20B8:  c1                         pop bc
20B9:  cd 37 23                   call 02337h
20BC:  e5                         push hl
20BD:  e7                         rst 20h
20BE:  28 32                      jr z,l20f2h
20C0:  cd bd 0f                   call sub_0fbdh
20C3:  cd 65 28                   call sub_2865h
20C6:  cd cd 79                   call 079cdh
20C9:  2a 21 79                   ld hl,(07921h)
20CC:  3a 9c 78                   ld a,(OUTDEV)
20CF:  b7                         or a
20D0:  fa e9 20                   jp m,l20e9h
20D3:  28 08                      jr z,l20ddh
20D5:  3a 9b 78                   ld a,(0789bh)
20D8:  86                         add a,(hl)
20D9:  fe 84                      cp 084h
20DB:  18 09                      jr l20e6h
20DD:  3a 9d 78      l20ddh:      ld a,(0789dh)
20E0:  47                         ld b,a
20E1:  3a a6 78                   ld a,(078a6h)
20E4:  86                         add a,(hl)
20E5:  b8                         cp b
20E6:  d4 fe 20      l20e6h:      call nc,sub_20feh
20E9:  cd aa 28      l20e9h:      call sub_28aah
20EC:  3e 20                      ld a,020h
20EE:  cd 2a 03                   call sub_032ah
20F1:  b7                         or a
20F2:  cc aa 28      l20f2h:      call z,sub_28aah
20F5:  e1                         pop hl
20F6:  c3 9b 20                   jp l209bh
20F9:  cd 1c 3b      sub_20f9h:   call sub_3b1ch
20FC:  b7                         or a
20FD:  c8                         ret z
20FE:  3e 0d         sub_20feh:   ld a,00dh
2100:  cd 2a 03      l2100h:      call sub_032ah
2103:  cd d0 79      sub_2103h:   call 079d0h
2106:  af                         xor a
2107:  c9                         ret
2108:  cd d3 79      l2108h:      call 079d3h
210B:  3a 9c 78                   ld a,(OUTDEV)
210E:  b7                         or a
210F:  f2 19 21                   jp p,l2119h
2112:  3e 2c                      ld a,02ch
2114:  cd 2a 03                   call sub_032ah
2117:  18 4b                      jr l2164h
2119:  28 08         l2119h:      jr z,l2123h
211B:  3a 9b 78                   ld a,(0789bh)
211E:  fe 70                      cp 070h
2120:  c3 2b 21                   jp l212bh
2123:  3a 9e 78      l2123h:      ld a,(0789eh)
2126:  47                         ld b,a
2127:  3a ae 7a                   ld a,(07aaeh)
212A:  b8                         cp b
212B:  d4 fe 20      l212bh:      call nc,sub_20feh
212E:  30 34                      jr nc,l2164h
2130:  d6 10         l2130h:      sub 010h
2132:  30 fc                      jr nc,l2130h
2134:  2f                         cpl
2135:  18 23                      jr l215ah
2137:  cd 1b 2b      l2137h:      call sub_2b1bh
213A:  e6 3f                      and 03fh
213C:  5f                         ld e,a
213D:  cf                         rst 8
213E:  29                         add hl,hl
213F:  2b                         dec hl
2140:  e5                         push hl
2141:  cd d3 79                   call 079d3h
2144:  3a 9c 78                   ld a,(OUTDEV)
2147:  b7                         or a
2148:  fa 4a 1e                   jp m,l1e4ah
214B:  ca 53 21                   jp z,l2153h
214E:  3a 9b 78                   ld a,(0789bh)
2151:  18 03                      jr l2156h
2153:  3a a6 78      l2153h:      ld a,(078a6h)
2156:  2f            l2156h:      cpl
2157:  83                         add a,e
2158:  30 0a                      jr nc,l2164h
215A:  3c            l215ah:      inc a
215B:  47                         ld b,a
215C:  3e 20                      ld a,020h
215E:  cd 2a 03      l215eh:      call sub_032ah
2161:  05                         dec b
2162:  20 fa                      jr nz,l215eh
2164:  e1            l2164h:      pop hl
2165:  d7                         rst 10h
2166:  c3 a0 20                   jp l20a0h
2169:  3a 9c 78      sub_2169h:   ld a,(OUTDEV)
216C:  00                         nop
216D:  00                         nop
216E:  00                         nop
216F:  00                         nop
2170:  af                         xor a
2171:  32 9c 78                   ld (OUTDEV),a
2174:  cd be 79                   call 079beh
2177:  c9                         ret
2178:  3f            l2178h:      ccf
2179:  52                         ld d,d
217A:  45                         ld b,l
217B:  44                         ld b,h
217C:  4f                         ld c,a
217D:  0d                         dec c
217E:  00                         nop
217F:  3a de 78      l217fh:      ld a,(078deh)
2182:  b7                         or a
2183:  c2 91 19                   jp nz,l1991h
2186:  3a a9 78                   ld a,(078a9h)
2189:  b7                         or a
218A:  1e 2a                      ld e,02ah
218C:  ca a2 19                   jp z,l19a2h
218F:  c1                         pop bc
2190:  21 78 21                   ld hl,l2178h
2193:  cd a7 28                   call OUTSTR
2196:  2a e6 78                   ld hl,(078e6h)
2199:  c9                         ret
219A:  cd 28 28                   call sub_2828h
219D:  7e                         ld a,(hl)
219E:  cd d6 79                   call 079d6h
21A1:  d6 23                      sub 023h
21A3:  32 a9 78                   ld (078a9h),a
21A6:  7e                         ld a,(hl)
21A7:  20 20                      jr nz,l21c9h
21A9:  cd 68 3b                   call sub_3b68h
21AC:  e5                         push hl
21AD:  06 fa                      ld b,0fah
21AF:  2a a7 78                   ld hl,(078a7h)
21B2:  cd 88 3b      l21b2h:      call sub_3b88h
21B5:  77                         ld (hl),a
21B6:  23                         inc hl
21B7:  fe 0d                      cp 00dh
21B9:  28 02                      jr z,l21bdh
21BB:  10 f5                      djnz l21b2h
21BD:  2b            l21bdh:      dec hl
21BE:  36 00                      ld (hl),000h
21C0:  00                         nop
21C1:  00                         nop
21C2:  00                         nop
21C3:  2a a7 78                   ld hl,(078a7h)
21C6:  2b                         dec hl
21C7:  18 22                      jr l21ebh
21C9:  01 db 21      l21c9h:      ld bc,l21dbh
21CC:  c5                         push bc
21CD:  fe 22                      cp 022h
21CF:  c0                         ret nz
21D0:  cd 66 28                   call sub_2866h
21D3:  cf                         rst 8
21D4:  3b                         dec sp
21D5:  e5                         push hl
21D6:  cd aa 28                   call sub_28aah
21D9:  e1                         pop hl
21DA:  c9                         ret
21DB:  e5            l21dbh:      push hl
21DC:  cd b3 1b                   call sub_1bb3h
21DF:  c1                         pop bc
21E0:  da be 1d                   jp c,01dbeh
21E3:  23                         inc hl
21E4:  7e                         ld a,(hl)
21E5:  b7                         or a
21E6:  2b                         dec hl
21E7:  c5                         push bc
21E8:  ca 04 1f                   jp z,01f04h
21EB:  36 2c         l21ebh:      ld (hl),02ch
21ED:  18 05                      jr $+7
21EF:  e5                         push hl
21F0:  2a ff 78                   ld hl,(078ffh)
21F3:  f6 af                      or 0afh
21F5:  32 de 78                   ld (078deh),a
21F8:  e3                         ex (sp),hl
21F9:  18 02                      jr l21fdh
21FB:  cf            l21fbh:      rst 8
21FC:  2c                         inc l
21FD:  cd 0d 26      l21fdh:      call 0260dh
2200:  e3                         ex (sp),hl
2201:  d5                         push de
2202:  7e                         ld a,(hl)
2203:  fe 2c                      cp 02ch
2205:  28 26                      jr z,l222dh
2207:  3a de 78                   ld a,(078deh)
220A:  b7                         or a
220B:  c2 96 22                   jp nz,l2296h
220E:  3a a9 78                   ld a,(078a9h)
2211:  b7                         or a
2212:  1e 06                      ld e,006h
2214:  ca a2 19                   jp z,l19a2h
2217:  3e 3f                      ld a,03fh
2219:  cd 2a 03                   call sub_032ah
221C:  cd b3 1b                   call sub_1bb3h
221F:  d1                         pop de
2220:  c1                         pop bc
2221:  da be 1d                   jp c,01dbeh
2224:  23                         inc hl
2225:  7e                         ld a,(hl)
2226:  b7                         or a
2227:  2b                         dec hl
2228:  c5                         push bc
2229:  ca 04 1f                   jp z,01f04h
222C:  d5                         push de
222D:  cd dc 79      l222dh:      call 079dch
2230:  e7                         rst 20h
2231:  f5                         push af
2232:  20 19                      jr nz,l224dh
2234:  d7                         rst 10h
2235:  57                         ld d,a
2236:  47                         ld b,a
2237:  fe 22                      cp 022h
2239:  28 05                      jr z,l2240h
223B:  16 3a                      ld d,03ah
223D:  06 2c                      ld b,02ch
223F:  2b                         dec hl
2240:  cd 69 28      l2240h:      call sub_2869h
2243:  f1            l2243h:      pop af
2244:  eb                         ex de,hl
2245:  21 5a 22                   ld hl,l225ah
2248:  e3                         ex (sp),hl
2249:  d5                         push de
224A:  c3 33 1f                   jp l1f33h
224D:  d7            l224dh:      rst 10h
224E:  f1                         pop af
224F:  f5                         push af
2250:  01 43 22                   ld bc,l2243h
2253:  c5                         push bc
2254:  da 6c 0e                   jp c,00e6ch
2257:  d2 65 0e                   jp nc,l0e65h
225A:  2b            l225ah:      dec hl
225B:  d7                         rst 10h
225C:  28 05                      jr z,l2263h
225E:  fe 2c                      cp 02ch
2260:  c2 7f 21                   jp nz,l217fh
2263:  e3            l2263h:      ex (sp),hl
2264:  2b                         dec hl
2265:  d7                         rst 10h
2266:  c2 fb 21                   jp nz,l21fbh
2269:  d1                         pop de
226A:  00                         nop
226B:  00                         nop
226C:  00                         nop
226D:  00                         nop
226E:  00                         nop
226F:  3a de 78                   ld a,(078deh)
2272:  b7                         or a
2273:  eb                         ex de,hl
2274:  c2 96 1d                   jp nz,l1d96h
2277:  d5                         push de
2278:  cd df 79                   call 079dfh
227B:  b6                         or (hl)
227C:  21 86 22                   ld hl,l2286h
227F:  c4 a7 28                   call nz,OUTSTR
2282:  e1                         pop hl
2283:  c3 69 21                   jp sub_2169h
2286:  3f            l2286h:      ccf
2287:  45                         ld b,l
2288:  58                         ld e,b
2289:  54                         ld d,h
228A:  52                         ld d,d
228B:  41                         ld b,c
228C:  20 49                      jr nz,l22d7h
228E:  47                         ld b,a
228F:  4e                         ld c,(hl)
2290:  4f                         ld c,a
2291:  52                         ld d,d
2292:  45                         ld b,l
2293:  44                         ld b,h
2294:  0d                         dec c
2295:  00                         nop
2296:  cd 05 1f      l2296h:      call l1f05h
2299:  b7                         or a
229A:  20 12                      jr nz,l22aeh
229C:  23                         inc hl
229D:  7e                         ld a,(hl)
229E:  23                         inc hl
229F:  b6                         or (hl)
22A0:  1e 06                      ld e,006h
22A2:  ca a2 19                   jp z,l19a2h
22A5:  23                         inc hl
22A6:  5e                         ld e,(hl)
22A7:  23                         inc hl
22A8:  56                         ld d,(hl)
22A9:  eb                         ex de,hl
22AA:  22 da 78                   ld (078dah),hl
22AD:  eb                         ex de,hl
22AE:  d7            l22aeh:      rst 10h
22AF:  fe 88                      cp 088h
22B1:  20 e3                      jr nz,l2296h
22B3:  c3 2d 22                   jp l222dh
22B6:  11 00 00                   ld de,RESET
22B9:  c4 0d 26      sub_22b9h:   call nz,0260dh
22BC:  22 df 78                   ld (PROGCNT),hl
22BF:  cd 36 19                   call sub_1936h
22C2:  c2 9d 19                   jp nz,0199dh
22C5:  f9                         ld sp,hl
22C6:  22 e8 78                   ld (STSTACK),hl
22C9:  d5                         push de
22CA:  7e                         ld a,(hl)
22CB:  23                         inc hl
22CC:  f5                         push af
22CD:  d5                         push de
22CE:  7e                         ld a,(hl)
22CF:  23                         inc hl
22D0:  b7                         or a
22D1:  fa ea 22                   jp m,l22eah
22D4:  cd b1 09                   call sub_09b1h
22D7:  e3            l22d7h:      ex (sp),hl
22D8:  e5                         push hl
22D9:  cd 0b 07                   call sub_070bh
22DC:  e1                         pop hl
22DD:  cd cb 09                   call sub_09cbh
22E0:  e1                         pop hl
22E1:  cd c2 09                   call sub_09c2h
22E4:  e5                         push hl
22E5:  cd 0c 0a                   call sub_0a0ch
22E8:  18 29                      jr l2313h
22EA:  23            l22eah:      inc hl
22EB:  23                         inc hl
22EC:  23                         inc hl
22ED:  23                         inc hl
22EE:  4e                         ld c,(hl)
22EF:  23                         inc hl
22F0:  46                         ld b,(hl)
22F1:  23                         inc hl
22F2:  e3                         ex (sp),hl
22F3:  5e                         ld e,(hl)
22F4:  23                         inc hl
22F5:  56                         ld d,(hl)
22F6:  e5                         push hl
22F7:  69                         ld l,c
22F8:  60                         ld h,b
22F9:  cd d2 0b                   call sub_0bd2h
22FC:  3a af 78                   ld a,(078afh)
22FF:  fe 04                      cp 004h
2301:  ca b2 07                   jp z,l07b2h
2304:  eb                         ex de,hl
2305:  e1                         pop hl
2306:  72                         ld (hl),d
2307:  2b                         dec hl
2308:  73                         ld (hl),e
2309:  e1                         pop hl
230A:  d5                         push de
230B:  5e                         ld e,(hl)
230C:  23                         inc hl
230D:  56                         ld d,(hl)
230E:  23                         inc hl
230F:  e3                         ex (sp),hl
2310:  cd 39 0a                   call sub_0a39h
2313:  e1            l2313h:      pop hl
2314:  c1                         pop bc
2315:  90                         sub b
2316:  cd c2 09                   call sub_09c2h
2319:  28 09                      jr z,l2324h
231B:  eb                         ex de,hl
231C:  22 a2 78                   ld (078a2h),hl
231F:  69                         ld l,c
2320:  60                         ld h,b
2321:  c3 1a 1d                   jp l1d1ah
2324:  f9            l2324h:      ld sp,hl
2325:  22 e8 78                   ld (STSTACK),hl
2328:  2a df 78                   ld hl,(PROGCNT)
232B:  7e                         ld a,(hl)
232C:  fe 2c                      cp 02ch
232E:  c2 1e 1d                   jp nz,l1d1eh
2331:  d7                         rst 10h
2332:  cd b9 22                   call sub_22b9h
2335:  cf            sub_2335h:   rst 8
2336:  28 2b                      jr z,$+45
2338:  16 00         sub_2338h:   ld d,000h
233A:  d5            l233ah:      push de
233B:  0e 01                      ld c,001h
233D:  cd 63 19                   call sub_1963h
2340:  cd 9f 24                   call sub_249fh
2343:  22 f3 78                   ld (078f3h),hl
2346:  2a f3 78      l2346h:      ld hl,(078f3h)
2349:  c1            l2349h:      pop bc
234A:  7e                         ld a,(hl)
234B:  16 00                      ld d,000h
234D:  d6 d4         l234dh:      sub 0d4h
234F:  38 13                      jr c,l2364h
2351:  fe 03                      cp 003h
2353:  30 0f                      jr nc,l2364h
2355:  fe 01                      cp 001h
2357:  17                         rla
2358:  aa                         xor d
2359:  ba                         cp d
235A:  57                         ld d,a
235B:  da 97 19                   jp c,l1997h
235E:  22 d8 78                   ld (078d8h),hl
2361:  d7                         rst 10h
2362:  18 e9                      jr l234dh
2364:  7a            l2364h:      ld a,d
2365:  b7                         or a
2366:  c2 ec 23                   jp nz,l23ech
2369:  7e                         ld a,(hl)
236A:  22 d8 78                   ld (078d8h),hl
236D:  d6 cd                      sub 0cdh
236F:  d8                         ret c
2370:  fe 07                      cp 007h
2372:  d0                         ret nc
2373:  5f                         ld e,a
2374:  3a af 78                   ld a,(078afh)
2377:  d6 03                      sub 003h
2379:  b3                         or e
237A:  ca 8f 29                   jp z,l298fh
237D:  21 9a 18                   ld hl,l189ah
2380:  19                         add hl,de
2381:  78                         ld a,b
2382:  56                         ld d,(hl)
2383:  ba                         cp d
2384:  d0                         ret nc
2385:  c5                         push bc
2386:  01 46 23                   ld bc,l2346h
2389:  c5                         push bc
238A:  7a                         ld a,d
238B:  fe 7f                      cp 07fh
238D:  ca d4 23                   jp z,l23d4h
2390:  fe 51                      cp 051h
2392:  da e1 23                   jp c,l23e1h
2395:  21 21 79      l2395h:      ld hl,07921h
2398:  b7                         or a
2399:  3a af 78                   ld a,(078afh)
239C:  3d                         dec a
239D:  3d                         dec a
239E:  3d                         dec a
239F:  ca f6 0a                   jp z,l0af6h
23A2:  4e                         ld c,(hl)
23A3:  23                         inc hl
23A4:  46                         ld b,(hl)
23A5:  c5                         push bc
23A6:  fa c5 23                   jp m,l23c5h
23A9:  23                         inc hl
23AA:  4e                         ld c,(hl)
23AB:  23                         inc hl
23AC:  46                         ld b,(hl)
23AD:  c5                         push bc
23AE:  f5                         push af
23AF:  b7                         or a
23B0:  e2 c4 23                   jp po,023c4h
23B3:  f1                         pop af
23B4:  23                         inc hl
23B5:  38 03                      jr c,l23bah
23B7:  21 1d 79                   ld hl,0791dh
23BA:  4e            l23bah:      ld c,(hl)
23BB:  23                         inc hl
23BC:  46                         ld b,(hl)
23BD:  23                         inc hl
23BE:  c5                         push bc
23BF:  4e                         ld c,(hl)
23C0:  23                         inc hl
23C1:  46                         ld b,(hl)
23C2:  c5                         push bc
23C3:  06 f1                      ld b,0f1h
23C5:  c6 03         l23c5h:      add a,003h
23C7:  4b                         ld c,e
23C8:  47                         ld b,a
23C9:  c5                         push bc
23CA:  01 06 24                   ld bc,l2406h
23CD:  c5            l23cdh:      push bc
23CE:  2a d8 78                   ld hl,(078d8h)
23D1:  c3 3a 23                   jp l233ah
23D4:  cd b1 0a      l23d4h:      call sub_0ab1h
23D7:  cd a4 09                   call sub_09a4h
23DA:  01 f2 13                   ld bc,l13f2h
23DD:  16 7f                      ld d,07fh
23DF:  18 ec                      jr l23cdh
23E1:  d5            l23e1h:      push de
23E2:  cd 7f 0a                   call l0a7fh
23E5:  d1                         pop de
23E6:  e5                         push hl
23E7:  01 e9 25                   ld bc,l25e9h
23EA:  18 e1                      jr l23cdh
23EC:  78            l23ech:      ld a,b
23ED:  fe 64                      cp 064h
23EF:  d0                         ret nc
23F0:  c5                         push bc
23F1:  d5                         push de
23F2:  11 04 64                   ld de,06404h
23F5:  21 b8 25                   ld hl,l25b8h
23F8:  e5            l23f8h:      push hl
23F9:  e7                         rst 20h
23FA:  c2 95 23                   jp nz,l2395h
23FD:  2a 21 79                   ld hl,(07921h)
2400:  e5            l2400h:      push hl
2401:  01 8c 25                   ld bc,l258ch
2404:  18 c7                      jr l23cdh
2406:  c1            l2406h:      pop bc
2407:  79                         ld a,c
2408:  32 b0 78                   ld (078b0h),a
240B:  78                         ld a,b
240C:  fe 08                      cp 008h
240E:  28 28                      jr z,l2438h
2410:  3a af 78                   ld a,(078afh)
2413:  fe 08                      cp 008h
2415:  ca 60 24                   jp z,l2460h
2418:  57                         ld d,a
2419:  78                         ld a,b
241A:  fe 04                      cp 004h
241C:  ca 72 24                   jp z,l2472h
241F:  7a                         ld a,d
2420:  fe 03                      cp 003h
2422:  ca f6 0a                   jp z,l0af6h
2425:  d2 7c 24                   jp nc,l247ch
2428:  21 bf 18                   ld hl,l18bfh
242B:  06 00                      ld b,000h
242D:  09                         add hl,bc
242E:  09                         add hl,bc
242F:  4e                         ld c,(hl)
2430:  23                         inc hl
2431:  46                         ld b,(hl)
2432:  d1                         pop de
2433:  2a 21 79                   ld hl,(07921h)
2436:  c5                         push bc
2437:  c9                         ret
2438:  cd db 0a      l2438h:      call sub_0adbh
243B:  cd fc 09                   call sub_09fch
243E:  e1                         pop hl
243F:  22 1f 79                   ld (0791fh),hl
2442:  e1                         pop hl
2443:  22 1d 79                   ld (0791dh),hl
2446:  c1            l2446h:      pop bc
2447:  d1                         pop de
2448:  cd b4 09                   call l09b4h
244B:  cd db 0a      l244bh:      call sub_0adbh
244E:  21 ab 18                   ld hl,l18abh
2451:  3a b0 78      l2451h:      ld a,(078b0h)
2454:  07                         rlca
2455:  c5                         push bc
2456:  4f                         ld c,a
2457:  06 00                      ld b,000h
2459:  09                         add hl,bc
245A:  c1                         pop bc
245B:  7e                         ld a,(hl)
245C:  23                         inc hl
245D:  66                         ld h,(hl)
245E:  6f                         ld l,a
245F:  e9                         jp (hl)
2460:  c5            l2460h:      push bc
2461:  cd fc 09                   call sub_09fch
2464:  f1                         pop af
2465:  32 af 78                   ld (078afh),a
2468:  fe 04                      cp 004h
246A:  28 da                      jr z,l2446h
246C:  e1                         pop hl
246D:  22 21 79                   ld (07921h),hl
2470:  18 d9                      jr l244bh
2472:  cd b1 0a      l2472h:      call sub_0ab1h
2475:  c1                         pop bc
2476:  d1                         pop de
2477:  21 b5 18      l2477h:      ld hl,l18b5h
247A:  18 d5                      jr l2451h
247C:  e1            l247ch:      pop hl
247D:  cd a4 09                   call sub_09a4h
2480:  cd cf 0a                   call sub_0acfh
2483:  cd bf 09                   call sub_09bfh
2486:  e1                         pop hl
2487:  22 23 79                   ld (07923h),hl
248A:  e1                         pop hl
248B:  22 21 79                   ld (07921h),hl
248E:  18 e7                      jr l2477h
2490:  e5                         push hl
2491:  eb                         ex de,hl
2492:  cd cf 0a                   call sub_0acfh
2495:  e1                         pop hl
2496:  cd a4 09                   call sub_09a4h
2499:  cd cf 0a                   call sub_0acfh
249C:  c3 a0 08                   jp l08a0h
249F:  d7            sub_249fh:   rst 10h
24A0:  1e 28                      ld e,028h
24A2:  ca a2 19                   jp z,l19a2h
24A5:  da 6c 0e                   jp c,00e6ch
24A8:  cd 3d 1e                   call sub_1e3dh
24AB:  d2 40 25                   jp nc,l2540h
24AE:  fe cd                      cp 0cdh
24B0:  28 ed                      jr z,sub_249fh
24B2:  fe 2e                      cp 02eh
24B4:  ca 6c 0e                   jp z,00e6ch
24B7:  fe ce                      cp 0ceh
24B9:  ca 32 25                   jp z,l2532h
24BC:  fe 22         l24bch:      cp 022h
24BE:  ca 66 28                   jp z,sub_2866h
24C1:  fe cb                      cp 0cbh
24C3:  ca c4 25                   jp z,l25c4h
24C6:  fe 26                      cp 026h
24C8:  ca 94 79                   jp z,07994h
24CB:  fe c3                      cp 0c3h
24CD:  20 0a                      jr nz,l24d9h
24CF:  d7                         rst 10h
24D0:  3a 9a 78                   ld a,(0789ah)
24D3:  e5                         push hl
24D4:  cd f8 27                   call sub_27f8h
24D7:  e1                         pop hl
24D8:  c9                         ret
24D9:  fe c2         l24d9h:      cp 0c2h
24DB:  20 0a                      jr nz,l24e7h
24DD:  d7                         rst 10h
24DE:  e5                         push hl
24DF:  2a ea 78                   ld hl,(078eah)
24E2:  cd 66 0c                   call sub_0c66h
24E5:  e1                         pop hl
24E6:  c9                         ret
24E7:  fe c0         l24e7h:      cp 0c0h
24E9:  20 14                      jr nz,l24ffh
24EB:  d7                         rst 10h
24EC:  cf                         rst 8
24ED:  28 cd                      jr z,l24bch
24EF:  0d                         dec c
24F0:  26 cf                      ld h,0cfh
24F2:  29                         add hl,hl
24F3:  e5                         push hl
24F4:  eb                         ex de,hl
24F5:  7c                         ld a,h
24F6:  b5                         or l
24F7:  ca 4a 1e                   jp z,l1e4ah
24FA:  cd 9a 0a                   call l0a9ah
24FD:  e1                         pop hl
24FE:  c9                         ret
24FF:  fe c1         l24ffh:      cp 0c1h
2501:  ca fe 27                   jp z,l27feh
2504:  fe c5                      cp 0c5h
2506:  ca 9d 79                   jp z,0799dh
2509:  fe c8                      cp 0c8h
250B:  ca c9 27                   jp z,l27c9h
250E:  fe c7                      cp 0c7h
2510:  ca 76 79                   jp z,07976h
2513:  fe c6                      cp 0c6h
2515:  ca 32 01                   jp z,l0132h
2518:  fe c9                      cp 0c9h
251A:  ca 9d 01                   jp z,0019dh
251D:  fe c4                      cp 0c4h
251F:  ca 2f 2a                   jp z,l2a2fh
2522:  fe be                      cp 0beh
2524:  ca 55 79                   jp z,07955h
2527:  d6 d7                      sub 0d7h
2529:  d2 4e 25                   jp nc,l254eh
252C:  cd 35 23      sub_252ch:   call sub_2335h
252F:  cf                         rst 8
2530:  29                         add hl,hl
2531:  c9                         ret
2532:  16 7d         l2532h:      ld d,07dh
2534:  cd 3a 23                   call l233ah
2537:  2a f3 78                   ld hl,(078f3h)
253A:  e5                         push hl
253B:  cd 7b 09                   call l097bh
253E:  e1            l253eh:      pop hl
253F:  c9                         ret
2540:  cd 0d 26      l2540h:      call 0260dh
2543:  e5            l2543h:      push hl
2544:  eb                         ex de,hl
2545:  22 21 79                   ld (07921h),hl
2548:  e7                         rst 20h
2549:  c4 f7 09                   call nz,sub_09f7h
254C:  e1                         pop hl
254D:  c9                         ret
254E:  06 00         l254eh:      ld b,000h
2550:  07                         rlca
2551:  4f                         ld c,a
2552:  c5                         push bc
2553:  d7                         rst 10h
2554:  79                         ld a,c
2555:  fe 41                      cp 041h
2557:  38 16                      jr c,l256fh
2559:  cd 35 23                   call sub_2335h
255C:  cf                         rst 8
255D:  2c                         inc l
255E:  cd f4 0a                   call sub_0af4h
2561:  eb                         ex de,hl
2562:  2a 21 79                   ld hl,(07921h)
2565:  e3                         ex (sp),hl
2566:  e5                         push hl
2567:  eb                         ex de,hl
2568:  cd 1c 2b                   call sub_2b1ch
256B:  eb                         ex de,hl
256C:  e3                         ex (sp),hl
256D:  18 14                      jr l2583h
256F:  cd 2c 25      l256fh:      call sub_252ch
2572:  e3                         ex (sp),hl
2573:  7d                         ld a,l
2574:  fe 0c                      cp 00ch
2576:  38 07                      jr c,l257fh
2578:  fe 1b                      cp 01bh
257A:  e5                         push hl
257B:  dc b1 0a                   call c,sub_0ab1h
257E:  e1                         pop hl
257F:  11 3e 25      l257fh:      ld de,l253eh
2582:  d5                         push de
2583:  01 08 16      l2583h:      ld bc,l1608h
2586:  09            sub_2586h:   add hl,bc
2587:  4e                         ld c,(hl)
2588:  23                         inc hl
2589:  66                         ld h,(hl)
258A:  69                         ld l,c
258B:  e9                         jp (hl)
258C:  cd d7 29      l258ch:      call sub_29d7h
258F:  7e                         ld a,(hl)
2590:  23                         inc hl
2591:  4e                         ld c,(hl)
2592:  23                         inc hl
2593:  46                         ld b,(hl)
2594:  d1                         pop de
2595:  c5                         push bc
2596:  f5                         push af
2597:  cd de 29                   call sub_29deh
259A:  d1                         pop de
259B:  5e                         ld e,(hl)
259C:  23                         inc hl
259D:  4e                         ld c,(hl)
259E:  23                         inc hl
259F:  46                         ld b,(hl)
25A0:  e1                         pop hl
25A1:  7b            l25a1h:      ld a,e
25A2:  b2                         or d
25A3:  c8                         ret z
25A4:  7a                         ld a,d
25A5:  d6 01                      sub 001h
25A7:  d8                         ret c
25A8:  af                         xor a
25A9:  bb                         cp e
25AA:  3c                         inc a
25AB:  d0                         ret nc
25AC:  15                         dec d
25AD:  1d                         dec e
25AE:  0a                         ld a,(bc)
25AF:  be                         cp (hl)
25B0:  23                         inc hl
25B1:  03                         inc bc
25B2:  28 ed                      jr z,l25a1h
25B4:  3f                         ccf
25B5:  c3 60 09                   jp l0960h
25B8:  3c            l25b8h:      inc a
25B9:  8f                         adc a,a
25BA:  c1                         pop bc
25BB:  a0                         and b
25BC:  c6 ff                      add a,0ffh
25BE:  9f                         sbc a,a
25BF:  cd 8d 09                   call sub_098dh
25C2:  18 12                      jr l25d6h
25C4:  16 5a         l25c4h:      ld d,05ah
25C6:  cd 3a 23                   call l233ah
25C9:  cd 7f 0a                   call l0a7fh
25CC:  7d                         ld a,l
25CD:  2f                         cpl
25CE:  6f                         ld l,a
25CF:  7c                         ld a,h
25D0:  2f                         cpl
25D1:  67                         ld h,a
25D2:  22 21 79                   ld (07921h),hl
25D5:  c1                         pop bc
25D6:  c3 46 23      l25d6h:      jp l2346h
25D9:  3a af 78      l25d9h:      ld a,(078afh)
25DC:  fe 08                      cp 008h
25DE:  30 05                      jr nc,l25e5h
25E0:  d6 03                      sub 003h
25E2:  b7                         or a
25E3:  37                         scf
25E4:  c9                         ret
25E5:  d6 03         l25e5h:      sub 003h
25E7:  b7                         or a
25E8:  c9                         ret
25E9:  c5            l25e9h:      push bc
25EA:  cd 7f 0a                   call l0a7fh
25ED:  f1                         pop af
25EE:  d1                         pop de
25EF:  01 fa 27                   ld bc,l27fah
25F2:  c5                         push bc
25F3:  fe 46                      cp 046h
25F5:  20 06                      jr nz,l25fdh
25F7:  7b                         ld a,e
25F8:  b5                         or l
25F9:  6f                         ld l,a
25FA:  7c                         ld a,h
25FB:  b2                         or d
25FC:  c9                         ret
25FD:  7b            l25fdh:      ld a,e
25FE:  a5                         and l
25FF:  6f                         ld l,a
2600:  7c                         ld a,h
2601:  a2                         and d
2602:  c9                         ret
2603:  2b            l2603h:      dec hl
2604:  d7                         rst 10h
2605:  c8                         ret z
2606:  cf                         rst 8
2607:  2c                         inc l
2608:  01 03 26      l2608h:      ld bc,l2603h
260B:  c5                         push bc
260C:  f6 af                      or 0afh
260E:  32 ae 78                   ld (078aeh),a
2611:  46                         ld b,(hl)
2612:  cd 3d 1e                   call sub_1e3dh
2615:  da 97 19                   jp c,l1997h
2618:  af                         xor a
2619:  4f                         ld c,a
261A:  d7                         rst 10h
261B:  38 05                      jr c,l2622h
261D:  cd 3d 1e                   call sub_1e3dh
2620:  38 09                      jr c,l262bh
2622:  4f            l2622h:      ld c,a
2623:  d7            l2623h:      rst 10h
2624:  38 fd                      jr c,l2623h
2626:  cd 3d 1e                   call sub_1e3dh
2629:  30 f8                      jr nc,l2623h
262B:  11 52 26      l262bh:      ld de,l2652h
262E:  d5                         push de
262F:  16 02                      ld d,002h
2631:  fe 25                      cp 025h
2633:  c8                         ret z
2634:  14                         inc d
2635:  fe 24                      cp 024h
2637:  c8                         ret z
2638:  00                         nop
2639:  00                         nop
263A:  00                         nop
263B:  00                         nop
263C:  00                         nop
263D:  00                         nop
263E:  00                         nop
263F:  00                         nop
2640:  00                         nop
2641:  78                         ld a,b
2642:  d6 41                      sub 041h
2644:  e6 7f                      and 07fh
2646:  5f                         ld e,a
2647:  16 00                      ld d,000h
2649:  e5                         push hl
264A:  21 01 79                   ld hl,TYPETAB
264D:  19                         add hl,de
264E:  56                         ld d,(hl)
264F:  e1                         pop hl
2650:  2b                         dec hl
2651:  c9                         ret
2652:  7a            l2652h:      ld a,d
2653:  32 af 78                   ld (078afh),a
2656:  d7                         rst 10h
2657:  3a dc 78                   ld a,(IDXLOCK)
265A:  b7                         or a
265B:  c2 64 26                   jp nz,l2664h
265E:  7e                         ld a,(hl)
265F:  d6 28                      sub 028h
2661:  ca e9 26                   jp z,l26e9h
2664:  af            l2664h:      xor a
2665:  32 dc 78                   ld (IDXLOCK),a
2668:  e5                         push hl
2669:  d5                         push de
266A:  2a f9 78                   ld hl,(PROGEND)
266D:  eb            l266dh:      ex de,hl
266E:  2a fb 78                   ld hl,(DIMVAR)
2671:  df                         rst 18h
2672:  e1                         pop hl
2673:  28 19                      jr z,l268eh
2675:  1a                         ld a,(de)
2676:  6f                         ld l,a
2677:  bc                         cp h
2678:  13                         inc de
2679:  20 0b                      jr nz,$+13
267B:  1a                         ld a,(de)
267C:  b9                         cp c
267D:  20 07                      jr nz,$+9
267F:  13                         inc de
2680:  1a                         ld a,(de)
2681:  b8                         cp b
2682:  ca cc 26                   jp z,l26cch
2685:  3e 13                      ld a,013h
2687:  13                         inc de
2688:  e5                         push hl
2689:  26 00                      ld h,000h
268B:  19                         add hl,de
268C:  18 df                      jr l266dh
268E:  7c            l268eh:      ld a,h
268F:  e1                         pop hl
2690:  e3                         ex (sp),hl
2691:  f5                         push af
2692:  d5                         push de
2693:  11 f1 24                   ld de,024f1h
2696:  df                         rst 18h
2697:  28 36                      jr z,l26cfh
2699:  11 43 25                   ld de,l2543h
269C:  df                         rst 18h
269D:  d1                         pop de
269E:  28 35                      jr z,l26d5h
26A0:  f1                         pop af
26A1:  e3                         ex (sp),hl
26A2:  e5                         push hl
26A3:  c5                         push bc
26A4:  4f                         ld c,a
26A5:  06 00                      ld b,000h
26A7:  c5                         push bc
26A8:  03                         inc bc
26A9:  03                         inc bc
26AA:  03                         inc bc
26AB:  2a fd 78                   ld hl,(MTRIXTAB)
26AE:  e5                         push hl
26AF:  09                         add hl,bc
26B0:  c1                         pop bc
26B1:  e5                         push hl
26B2:  cd 55 19                   call sub_1955h
26B5:  e1                         pop hl
26B6:  22 fd 78                   ld (MTRIXTAB),hl
26B9:  60                         ld h,b
26BA:  69                         ld l,c
26BB:  22 fb 78                   ld (DIMVAR),hl
26BE:  2b            l26beh:      dec hl
26BF:  36 00                      ld (hl),000h
26C1:  df                         rst 18h
26C2:  20 fa                      jr nz,l26beh
26C4:  d1                         pop de
26C5:  73                         ld (hl),e
26C6:  23                         inc hl
26C7:  d1                         pop de
26C8:  73                         ld (hl),e
26C9:  23                         inc hl
26CA:  72                         ld (hl),d
26CB:  eb                         ex de,hl
26CC:  13            l26cch:      inc de
26CD:  e1                         pop hl
26CE:  c9                         ret
26CF:  57            l26cfh:      ld d,a
26D0:  5f                         ld e,a
26D1:  f1                         pop af
26D2:  f1                         pop af
26D3:  e3                         ex (sp),hl
26D4:  c9                         ret
26D5:  32 24 79      l26d5h:      ld (07924h),a
26D8:  c1                         pop bc
26D9:  67                         ld h,a
26DA:  6f                         ld l,a
26DB:  22 21 79                   ld (07921h),hl
26DE:  e7                         rst 20h
26DF:  20 06                      jr nz,l26e7h
26E1:  21 28 19                   ld hl,01928h
26E4:  22 21 79                   ld (07921h),hl
26E7:  e1            l26e7h:      pop hl
26E8:  c9                         ret
26E9:  e5            l26e9h:      push hl
26EA:  2a ae 78                   ld hl,(078aeh)
26ED:  e3                         ex (sp),hl
26EE:  57                         ld d,a
26EF:  d5            l26efh:      push de
26F0:  c5                         push bc
26F1:  cd 45 1e                   call sub_1e45h
26F4:  c1                         pop bc
26F5:  f1                         pop af
26F6:  eb                         ex de,hl
26F7:  e3                         ex (sp),hl
26F8:  e5                         push hl
26F9:  eb                         ex de,hl
26FA:  3c                         inc a
26FB:  57                         ld d,a
26FC:  7e                         ld a,(hl)
26FD:  fe 2c                      cp 02ch
26FF:  28 ee                      jr z,l26efh
2701:  cf                         rst 8
2702:  29                         add hl,hl
2703:  22 f3 78                   ld (078f3h),hl
2706:  e1                         pop hl
2707:  22 ae 78                   ld (078aeh),hl
270A:  d5                         push de
270B:  2a fb 78                   ld hl,(DIMVAR)
270E:  3e 19                      ld a,019h
2710:  eb            l2710h:      ex de,hl
2711:  2a fd 78                   ld hl,(MTRIXTAB)
2714:  eb                         ex de,hl
2715:  df                         rst 18h
2716:  3a af 78                   ld a,(078afh)
2719:  28 27                      jr z,l2742h
271B:  be                         cp (hl)
271C:  23                         inc hl
271D:  20 08                      jr nz,$+10
271F:  7e                         ld a,(hl)
2720:  b9                         cp c
2721:  23                         inc hl
2722:  20 04                      jr nz,l2728h
2724:  7e                         ld a,(hl)
2725:  b8                         cp b
2726:  3e 23                      ld a,023h
2728:  23            l2728h:      inc hl
2729:  5e                         ld e,(hl)
272A:  23                         inc hl
272B:  56                         ld d,(hl)
272C:  23                         inc hl
272D:  20 e0                      jr nz,$-30
272F:  3a ae 78                   ld a,(078aeh)
2732:  b7                         or a
2733:  1e 12                      ld e,012h
2735:  c2 a2 19                   jp nz,l19a2h
2738:  f1                         pop af
2739:  96                         sub (hl)
273A:  ca 95 27                   jp z,l2795h
273D:  1e 10         l273dh:      ld e,010h
273F:  c3 a2 19                   jp l19a2h
2742:  77            l2742h:      ld (hl),a
2743:  23                         inc hl
2744:  5f                         ld e,a
2745:  16 00                      ld d,000h
2747:  f1                         pop af
2748:  71                         ld (hl),c
2749:  23                         inc hl
274A:  70                         ld (hl),b
274B:  23                         inc hl
274C:  4f                         ld c,a
274D:  cd 63 19                   call sub_1963h
2750:  23                         inc hl
2751:  23                         inc hl
2752:  22 d8 78                   ld (078d8h),hl
2755:  71                         ld (hl),c
2756:  23                         inc hl
2757:  3a ae 78                   ld a,(078aeh)
275A:  17                         rla
275B:  79                         ld a,c
275C:  01 0b 00      l275ch:      ld bc,l000bh
275F:  30 02                      jr nc,l2763h
2761:  c1                         pop bc
2762:  03                         inc bc
2763:  71            l2763h:      ld (hl),c
2764:  23                         inc hl
2765:  70                         ld (hl),b
2766:  23                         inc hl
2767:  f5                         push af
2768:  cd aa 0b                   call sub_0baah
276B:  f1                         pop af
276C:  3d                         dec a
276D:  20 ed                      jr nz,l275ch
276F:  f5                         push af
2770:  42                         ld b,d
2771:  4b                         ld c,e
2772:  eb                         ex de,hl
2773:  19                         add hl,de
2774:  38 c7                      jr c,l273dh
2776:  cd 6c 19                   call 0196ch
2779:  22 fd 78                   ld (MTRIXTAB),hl
277C:  2b            l277ch:      dec hl
277D:  36 00                      ld (hl),000h
277F:  df                         rst 18h
2780:  20 fa                      jr nz,l277ch
2782:  03                         inc bc
2783:  57                         ld d,a
2784:  2a d8 78                   ld hl,(078d8h)
2787:  5e                         ld e,(hl)
2788:  eb                         ex de,hl
2789:  29                         add hl,hl
278A:  09                         add hl,bc
278B:  eb                         ex de,hl
278C:  2b                         dec hl
278D:  2b                         dec hl
278E:  73                         ld (hl),e
278F:  23                         inc hl
2790:  72                         ld (hl),d
2791:  23                         inc hl
2792:  f1                         pop af
2793:  38 30                      jr c,l27c5h
2795:  47            l2795h:      ld b,a
2796:  4f                         ld c,a
2797:  7e                         ld a,(hl)
2798:  23                         inc hl
2799:  16 e1                      ld d,0e1h
279B:  5e                         ld e,(hl)
279C:  23                         inc hl
279D:  56                         ld d,(hl)
279E:  23                         inc hl
279F:  e3                         ex (sp),hl
27A0:  f5                         push af
27A1:  df                         rst 18h
27A2:  d2 3d 27                   jp nc,l273dh
27A5:  cd aa 0b                   call sub_0baah
27A8:  19                         add hl,de
27A9:  f1                         pop af
27AA:  3d                         dec a
27AB:  44                         ld b,h
27AC:  4d                         ld c,l
27AD:  20 eb                      jr nz,$-19
27AF:  3a af 78                   ld a,(078afh)
27B2:  44                         ld b,h
27B3:  4d                         ld c,l
27B4:  29                         add hl,hl
27B5:  d6 04                      sub 004h
27B7:  38 04                      jr c,l27bdh
27B9:  29                         add hl,hl
27BA:  28 06                      jr z,l27c2h
27BC:  29                         add hl,hl
27BD:  b7            l27bdh:      or a
27BE:  e2 c2 27                   jp po,l27c2h
27C1:  09                         add hl,bc
27C2:  c1            l27c2h:      pop bc
27C3:  09                         add hl,bc
27C4:  eb                         ex de,hl
27C5:  2a f3 78      l27c5h:      ld hl,(078f3h)
27C8:  c9                         ret
27C9:  af            l27c9h:      xor a
27CA:  e5                         push hl
27CB:  32 af 78                   ld (078afh),a
27CE:  cd d4 27                   call sub_27d4h
27D1:  e1                         pop hl
27D2:  d7                         rst 10h
27D3:  c9                         ret
27D4:  2a fd 78      sub_27d4h:   ld hl,(MTRIXTAB)
27D7:  eb                         ex de,hl
27D8:  21 00 00                   ld hl,RESET
27DB:  39                         add hl,sp
27DC:  e7                         rst 20h
27DD:  20 0d                      jr nz,l27ech
27DF:  cd da 29                   call sub_29dah
27E2:  cd e6 28                   call sub_28e6h
27E5:  2a a0 78                   ld hl,(STRINGS)
27E8:  eb                         ex de,hl
27E9:  2a d6 78                   ld hl,(STRAPNT)
27EC:  7d            l27ech:      ld a,l
27ED:  93                         sub e
27EE:  6f                         ld l,a
27EF:  7c                         ld a,h
27F0:  9a                         sbc a,d
27F1:  67                         ld h,a
27F2:  c3 66 0c                   jp sub_0c66h
27F5:  3a a6 78      l27f5h:      ld a,(078a6h)
27F8:  6f            sub_27f8h:   ld l,a
27F9:  af                         xor a
27FA:  67            l27fah:      ld h,a
27FB:  c3 9a 0a                   jp l0a9ah
27FE:  cd a9 79      l27feh:      call 079a9h
2801:  d7                         rst 10h
2802:  cd 2c 25                   call sub_252ch
2805:  e5                         push hl
2806:  21 90 08                   ld hl,l0890h
2809:  e5                         push hl
280A:  3a af 78                   ld a,(078afh)
280D:  f5                         push af
280E:  fe 03                      cp 003h
2810:  cc da 29                   call z,sub_29dah
2813:  f1                         pop af
2814:  eb                         ex de,hl
2815:  2a 8e 78                   ld hl,(USRRT)
2818:  e9                         jp (hl)
2819:  e5            sub_2819h:   push hl
281A:  e6 07                      and 007h
281C:  21 a1 18                   ld hl,l18a1h
281F:  4f                         ld c,a
2820:  06 00                      ld b,000h
2822:  09                         add hl,bc
2823:  cd 86 25                   call sub_2586h
2826:  e1                         pop hl
2827:  c9                         ret
2828:  e5            sub_2828h:   push hl
2829:  2a a2 78                   ld hl,(078a2h)
282C:  23                         inc hl
282D:  7c                         ld a,h
282E:  b5                         or l
282F:  e1                         pop hl
2830:  c0                         ret nz
2831:  1e 16                      ld e,016h
2833:  c3 a2 19                   jp l19a2h
2836:  cd bd 0f      l2836h:      call sub_0fbdh
2839:  cd 65 28                   call sub_2865h
283C:  cd da 29                   call sub_29dah
283F:  01 2b 2a                   ld bc,l2a2bh
2842:  c5                         push bc
2843:  7e            sub_2843h:   ld a,(hl)
2844:  23                         inc hl
2845:  e5                         push hl
2846:  cd bf 28                   call sub_28bfh
2849:  e1                         pop hl
284A:  4e                         ld c,(hl)
284B:  23                         inc hl
284C:  46                         ld b,(hl)
284D:  cd 5a 28                   call sub_285ah
2850:  e5                         push hl
2851:  6f                         ld l,a
2852:  cd ce 29                   call sub_29ceh
2855:  d1                         pop de
2856:  c9                         ret
2857:  cd bf 28      sub_2857h:   call sub_28bfh
285A:  21 d3 78      sub_285ah:   ld hl,078d3h
285D:  e5                         push hl
285E:  77                         ld (hl),a
285F:  23                         inc hl
2860:  73                         ld (hl),e
2861:  23                         inc hl
2862:  72                         ld (hl),d
2863:  e1                         pop hl
2864:  c9                         ret
2865:  2b            sub_2865h:   dec hl
2866:  06 22         sub_2866h:   ld b,022h
2868:  50                         ld d,b
2869:  e5            sub_2869h:   push hl
286A:  0e ff                      ld c,0ffh
286C:  23            l286ch:      inc hl
286D:  7e                         ld a,(hl)
286E:  0c                         inc c
286F:  b7                         or a
2870:  28 06                      jr z,l2878h
2872:  ba                         cp d
2873:  28 03                      jr z,l2878h
2875:  b8                         cp b
2876:  20 f4                      jr nz,l286ch
2878:  fe 22         l2878h:      cp 022h
287A:  cc 78 1d                   call z,CHKCHR
287D:  e3                         ex (sp),hl
287E:  23                         inc hl
287F:  eb                         ex de,hl
2880:  79                         ld a,c
2881:  cd 5a 28                   call sub_285ah
2884:  11 d3 78      l2884h:      ld de,078d3h
2887:  3e d5                      ld a,0d5h
2889:  2a b3 78                   ld hl,(WORKPNT)
288C:  22 21 79                   ld (07921h),hl
288F:  3e 03                      ld a,003h
2891:  32 af 78                   ld (078afh),a
2894:  cd d3 09                   call l09d3h
2897:  11 d6 78                   ld de,STRAPNT
289A:  df                         rst 18h
289B:  22 b3 78                   ld (WORKPNT),hl
289E:  e1                         pop hl
289F:  7e                         ld a,(hl)
28A0:  c0                         ret nz
28A1:  1e 1e                      ld e,01eh
28A3:  c3 a2 19                   jp l19a2h
28A6:  23            l28a6h:      inc hl
28A7:  cd 65 28      OUTSTR:      call sub_2865h
28AA:  cd da 29      sub_28aah:   call sub_29dah
28AD:  cd c4 09                   call sub_09c4h
28B0:  14                         inc d
28B1:  15            l28b1h:      dec d
28B2:  c8                         ret z
28B3:  0a                         ld a,(bc)
28B4:  cd 2a 03                   call sub_032ah
28B7:  fe 0d                      cp 00dh
28B9:  cc 03 21                   call z,sub_2103h
28BC:  03                         inc bc
28BD:  18 f2                      jr l28b1h
28BF:  b7            sub_28bfh:   or a
28C0:  0e f1                      ld c,0f1h
28C2:  f5                         push af
28C3:  2a a0 78                   ld hl,(STRINGS)
28C6:  eb                         ex de,hl
28C7:  2a d6 78                   ld hl,(STRAPNT)
28CA:  2f                         cpl
28CB:  4f                         ld c,a
28CC:  06 ff                      ld b,0ffh
28CE:  09                         add hl,bc
28CF:  23                         inc hl
28D0:  df                         rst 18h
28D1:  38 07                      jr c,l28dah
28D3:  22 d6 78                   ld (STRAPNT),hl
28D6:  23                         inc hl
28D7:  eb                         ex de,hl
28D8:  f1            l28d8h:      pop af
28D9:  c9                         ret
28DA:  f1            l28dah:      pop af
28DB:  1e 1a                      ld e,01ah
28DD:  ca a2 19                   jp z,l19a2h
28E0:  bf                         cp a
28E1:  f5                         push af
28E2:  01 c1 28                   ld bc,028c1h
28E5:  c5                         push bc
28E6:  2a b1 78      sub_28e6h:   ld hl,(MEMTOP)
28E9:  22 d6 78      l28e9h:      ld (STRAPNT),hl
28EC:  21 00 00                   ld hl,RESET
28EF:  e5                         push hl
28F0:  2a a0 78                   ld hl,(STRINGS)
28F3:  e5                         push hl
28F4:  21 b5 78                   ld hl,STRBUFP
28F7:  eb            l28f7h:      ex de,hl
28F8:  2a b3 78                   ld hl,(WORKPNT)
28FB:  eb                         ex de,hl
28FC:  df                         rst 18h
28FD:  01 f7 28                   ld bc,l28f7h
2900:  c2 4a 29                   jp nz,l294ah
2903:  2a f9 78                   ld hl,(PROGEND)
2906:  eb            l2906h:      ex de,hl
2907:  2a fb 78                   ld hl,(DIMVAR)
290A:  eb                         ex de,hl
290B:  df                         rst 18h
290C:  28 13                      jr z,l2921h
290E:  7e                         ld a,(hl)
290F:  23                         inc hl
2910:  23                         inc hl
2911:  23                         inc hl
2912:  fe 03                      cp 003h
2914:  20 04                      jr nz,l291ah
2916:  cd 4b 29                   call sub_294bh
2919:  af                         xor a
291A:  5f            l291ah:      ld e,a
291B:  16 00                      ld d,000h
291D:  19                         add hl,de
291E:  18 e6                      jr l2906h
2920:  c1            l2920h:      pop bc
2921:  eb            l2921h:      ex de,hl
2922:  2a fd 78                   ld hl,(MTRIXTAB)
2925:  eb                         ex de,hl
2926:  df                         rst 18h
2927:  ca 6b 29                   jp z,l296bh
292A:  7e                         ld a,(hl)
292B:  23                         inc hl
292C:  cd c2 09                   call sub_09c2h
292F:  e5                         push hl
2930:  09                         add hl,bc
2931:  fe 03                      cp 003h
2933:  20 eb                      jr nz,l2920h
2935:  22 d8 78                   ld (078d8h),hl
2938:  e1                         pop hl
2939:  4e                         ld c,(hl)
293A:  06 00                      ld b,000h
293C:  09                         add hl,bc
293D:  09                         add hl,bc
293E:  23            l293eh:      inc hl
293F:  eb            l293fh:      ex de,hl
2940:  2a d8 78                   ld hl,(078d8h)
2943:  eb                         ex de,hl
2944:  df                         rst 18h
2945:  28 da                      jr z,l2921h
2947:  01 3f 29                   ld bc,l293fh
294A:  c5            l294ah:      push bc
294B:  af            sub_294bh:   xor a
294C:  b6                         or (hl)
294D:  23                         inc hl
294E:  5e                         ld e,(hl)
294F:  23                         inc hl
2950:  56                         ld d,(hl)
2951:  23                         inc hl
2952:  c8                         ret z
2953:  44                         ld b,h
2954:  4d                         ld c,l
2955:  2a d6 78                   ld hl,(STRAPNT)
2958:  df                         rst 18h
2959:  60                         ld h,b
295A:  69                         ld l,c
295B:  d8                         ret c
295C:  e1                         pop hl
295D:  e3                         ex (sp),hl
295E:  df                         rst 18h
295F:  e3                         ex (sp),hl
2960:  e5                         push hl
2961:  60                         ld h,b
2962:  69                         ld l,c
2963:  d0                         ret nc
2964:  c1                         pop bc
2965:  f1                         pop af
2966:  f1                         pop af
2967:  e5                         push hl
2968:  d5                         push de
2969:  c5                         push bc
296A:  c9                         ret
296B:  d1            l296bh:      pop de
296C:  e1                         pop hl
296D:  7d                         ld a,l
296E:  b4                         or h
296F:  c8                         ret z
2970:  2b                         dec hl
2971:  46                         ld b,(hl)
2972:  2b                         dec hl
2973:  4e                         ld c,(hl)
2974:  e5                         push hl
2975:  2b                         dec hl
2976:  6e                         ld l,(hl)
2977:  26 00                      ld h,000h
2979:  09                         add hl,bc
297A:  50                         ld d,b
297B:  59                         ld e,c
297C:  2b                         dec hl
297D:  44                         ld b,h
297E:  4d                         ld c,l
297F:  2a d6 78                   ld hl,(STRAPNT)
2982:  cd 58 19                   call sub_1958h
2985:  e1                         pop hl
2986:  71                         ld (hl),c
2987:  23                         inc hl
2988:  70                         ld (hl),b
2989:  69                         ld l,c
298A:  60                         ld h,b
298B:  2b                         dec hl
298C:  c3 e9 28                   jp l28e9h
298F:  c5            l298fh:      push bc
2990:  e5                         push hl
2991:  2a 21 79                   ld hl,(07921h)
2994:  e3                         ex (sp),hl
2995:  cd 9f 24                   call sub_249fh
2998:  e3                         ex (sp),hl
2999:  cd f4 0a                   call sub_0af4h
299C:  7e                         ld a,(hl)
299D:  e5                         push hl
299E:  2a 21 79                   ld hl,(07921h)
29A1:  e5                         push hl
29A2:  86                         add a,(hl)
29A3:  1e 1c                      ld e,01ch
29A5:  da a2 19                   jp c,l19a2h
29A8:  cd 57 28                   call sub_2857h
29AB:  d1                         pop de
29AC:  cd de 29                   call sub_29deh
29AF:  e3                         ex (sp),hl
29B0:  cd dd 29                   call sub_29ddh
29B3:  e5                         push hl
29B4:  2a d4 78                   ld hl,(078d4h)
29B7:  eb                         ex de,hl
29B8:  cd c6 29                   call sub_29c6h
29BB:  cd c6 29                   call sub_29c6h
29BE:  21 49 23                   ld hl,l2349h
29C1:  e3                         ex (sp),hl
29C2:  e5                         push hl
29C3:  c3 84 28                   jp l2884h
29C6:  e1            sub_29c6h:   pop hl
29C7:  e3                         ex (sp),hl
29C8:  7e                         ld a,(hl)
29C9:  23                         inc hl
29CA:  4e                         ld c,(hl)
29CB:  23                         inc hl
29CC:  46                         ld b,(hl)
29CD:  6f                         ld l,a
29CE:  2c            sub_29ceh:   inc l
29CF:  2d            l29cfh:      dec l
29D0:  c8                         ret z
29D1:  0a                         ld a,(bc)
29D2:  12                         ld (de),a
29D3:  03                         inc bc
29D4:  13                         inc de
29D5:  18 f8                      jr l29cfh
29D7:  cd f4 0a      sub_29d7h:   call sub_0af4h
29DA:  2a 21 79      sub_29dah:   ld hl,(07921h)
29DD:  eb            sub_29ddh:   ex de,hl
29DE:  cd f5 29      sub_29deh:   call sub_29f5h
29E1:  eb                         ex de,hl
29E2:  c0                         ret nz
29E3:  d5                         push de
29E4:  50                         ld d,b
29E5:  59                         ld e,c
29E6:  1b                         dec de
29E7:  4e                         ld c,(hl)
29E8:  2a d6 78                   ld hl,(STRAPNT)
29EB:  df                         rst 18h
29EC:  20 05                      jr nz,l29f3h
29EE:  47                         ld b,a
29EF:  09                         add hl,bc
29F0:  22 d6 78                   ld (STRAPNT),hl
29F3:  e1            l29f3h:      pop hl
29F4:  c9                         ret
29F5:  2a b3 78      sub_29f5h:   ld hl,(WORKPNT)
29F8:  2b                         dec hl
29F9:  46                         ld b,(hl)
29FA:  2b                         dec hl
29FB:  4e                         ld c,(hl)
29FC:  2b                         dec hl
29FD:  df                         rst 18h
29FE:  c0                         ret nz
29FF:  22 b3 78                   ld (WORKPNT),hl
2A02:  c9                         ret
2A03:  01 f8 27                   ld bc,sub_27f8h
2A06:  c5                         push bc
2A07:  cd d7 29      sub_2a07h:   call sub_29d7h
2A0A:  af                         xor a
2A0B:  57                         ld d,a
2A0C:  7e                         ld a,(hl)
2A0D:  b7                         or a
2A0E:  c9                         ret
2A0F:  01 f8 27      l2a0fh:      ld bc,sub_27f8h
2A12:  c5                         push bc
2A13:  cd 07 2a      sub_2a13h:   call sub_2a07h
2A16:  ca 4a 1e                   jp z,l1e4ah
2A19:  23                         inc hl
2A1A:  5e                         ld e,(hl)
2A1B:  23                         inc hl
2A1C:  56                         ld d,(hl)
2A1D:  1a                         ld a,(de)
2A1E:  c9                         ret
2A1F:  3e 01                      ld a,001h
2A21:  cd 57 28                   call sub_2857h
2A24:  cd 1f 2b                   call sub_2b1fh
2A27:  2a d4 78                   ld hl,(078d4h)
2A2A:  73                         ld (hl),e
2A2B:  c1            l2a2bh:      pop bc
2A2C:  c3 84 28                   jp l2884h
2A2F:  d7            l2a2fh:      rst 10h
2A30:  cf                         rst 8
2A31:  28 cd                      jr z,$-49
2A33:  1c                         inc e
2A34:  2b                         dec hl
2A35:  d5                         push de
2A36:  cf                         rst 8
2A37:  2c                         inc l
2A38:  cd 37 23                   call 02337h
2A3B:  cf                         rst 8
2A3C:  29                         add hl,hl
2A3D:  e3                         ex (sp),hl
2A3E:  e5                         push hl
2A3F:  e7                         rst 20h
2A40:  28 05                      jr z,l2a47h
2A42:  cd 1f 2b                   call sub_2b1fh
2A45:  18 03                      jr l2a4ah
2A47:  cd 13 2a      l2a47h:      call sub_2a13h
2A4A:  d1            l2a4ah:      pop de
2A4B:  f5                         push af
2A4C:  f5                         push af
2A4D:  7b                         ld a,e
2A4E:  cd 57 28                   call sub_2857h
2A51:  5f                         ld e,a
2A52:  f1                         pop af
2A53:  1c                         inc e
2A54:  1d                         dec e
2A55:  28 d4                      jr z,l2a2bh
2A57:  2a d4 78                   ld hl,(078d4h)
2A5A:  77            l2a5ah:      ld (hl),a
2A5B:  23                         inc hl
2A5C:  1d                         dec e
2A5D:  20 fb                      jr nz,l2a5ah
2A5F:  18 ca                      jr l2a2bh
2A61:  cd df 2a      l2a61h:      call sub_2adfh
2A64:  af                         xor a
2A65:  e3            l2a65h:      ex (sp),hl
2A66:  4f                         ld c,a
2A67:  3e e5                      ld a,0e5h
2A69:  e5            l2a69h:      push hl
2A6A:  7e                         ld a,(hl)
2A6B:  b8                         cp b
2A6C:  38 02                      jr c,$+4
2A6E:  78                         ld a,b
2A6F:  11 0e 00                   ld de,l000eh
2A72:  c5                         push bc
2A73:  cd bf 28                   call sub_28bfh
2A76:  c1                         pop bc
2A77:  e1                         pop hl
2A78:  e5                         push hl
2A79:  23                         inc hl
2A7A:  46                         ld b,(hl)
2A7B:  23                         inc hl
2A7C:  66                         ld h,(hl)
2A7D:  68                         ld l,b
2A7E:  06 00                      ld b,000h
2A80:  09                         add hl,bc
2A81:  44                         ld b,h
2A82:  4d                         ld c,l
2A83:  cd 5a 28                   call sub_285ah
2A86:  6f                         ld l,a
2A87:  cd ce 29                   call sub_29ceh
2A8A:  d1                         pop de
2A8B:  cd de 29                   call sub_29deh
2A8E:  c3 84 28                   jp l2884h
2A91:  cd df 2a                   call sub_2adfh
2A94:  d1                         pop de
2A95:  d5                         push de
2A96:  1a                         ld a,(de)
2A97:  90                         sub b
2A98:  18 cb                      jr l2a65h
2A9A:  eb            l2a9ah:      ex de,hl
2A9B:  7e                         ld a,(hl)
2A9C:  cd e2 2a                   call sub_2ae2h
2A9F:  04                         inc b
2AA0:  05                         dec b
2AA1:  ca 4a 1e                   jp z,l1e4ah
2AA4:  c5                         push bc
2AA5:  1e ff                      ld e,0ffh
2AA7:  fe 29                      cp 029h
2AA9:  28 05                      jr z,l2ab0h
2AAB:  cf                         rst 8
2AAC:  2c                         inc l
2AAD:  cd 1c 2b                   call sub_2b1ch
2AB0:  cf            l2ab0h:      rst 8
2AB1:  29                         add hl,hl
2AB2:  f1                         pop af
2AB3:  e3                         ex (sp),hl
2AB4:  01 69 2a                   ld bc,l2a69h
2AB7:  c5                         push bc
2AB8:  3d                         dec a
2AB9:  be                         cp (hl)
2ABA:  06 00                      ld b,000h
2ABC:  d0                         ret nc
2ABD:  4f                         ld c,a
2ABE:  7e                         ld a,(hl)
2ABF:  91                         sub c
2AC0:  bb                         cp e
2AC1:  47                         ld b,a
2AC2:  d8                         ret c
2AC3:  43                         ld b,e
2AC4:  c9                         ret
2AC5:  cd 07 2a                   call sub_2a07h
2AC8:  ca f8 27                   jp z,sub_27f8h
2ACB:  5f                         ld e,a
2ACC:  23                         inc hl
2ACD:  7e                         ld a,(hl)
2ACE:  23                         inc hl
2ACF:  66                         ld h,(hl)
2AD0:  6f                         ld l,a
2AD1:  e5                         push hl
2AD2:  19                         add hl,de
2AD3:  46                         ld b,(hl)
2AD4:  72                         ld (hl),d
2AD5:  e3                         ex (sp),hl
2AD6:  c5                         push bc
2AD7:  7e                         ld a,(hl)
2AD8:  cd 65 0e                   call l0e65h
2ADB:  c1                         pop bc
2ADC:  e1                         pop hl
2ADD:  70                         ld (hl),b
2ADE:  c9                         ret
2ADF:  eb            sub_2adfh:   ex de,hl
2AE0:  cf                         rst 8
2AE1:  29                         add hl,hl
2AE2:  c1            sub_2ae2h:   pop bc
2AE3:  d1                         pop de
2AE4:  c5                         push bc
2AE5:  43                         ld b,e
2AE6:  c9                         ret
2AE7:  fe 7a         l2ae7h:      cp 07ah
2AE9:  c2 97 19                   jp nz,l1997h
2AEC:  c3 d9 79                   jp 079d9h
2AEF:  cd 1f 2b                   call sub_2b1fh
2AF2:  32 94 78                   ld (07894h),a
2AF5:  cd 93 78                   call 07893h
2AF8:  c3 f8 27                   jp sub_27f8h
2AFB:  cd 0e 2b                   call sub_2b0eh
2AFE:  c3 96 78                   jp 07896h
2B01:  d7            sub_2b01h:   rst 10h
2B02:  cd 37 23      sub_2b02h:   call 02337h
2B05:  e5            sub_2b05h:   push hl
2B06:  cd 7f 0a                   call l0a7fh
2B09:  eb                         ex de,hl
2B0A:  e1                         pop hl
2B0B:  7a                         ld a,d
2B0C:  b7                         or a
2B0D:  c9                         ret
2B0E:  cd 1c 2b      sub_2b0eh:   call sub_2b1ch
2B11:  32 94 78                   ld (07894h),a
2B14:  32 97 78                   ld (07897h),a
2B17:  cf                         rst 8
2B18:  2c                         inc l
2B19:  18 01                      jr sub_2b1ch
2B1B:  d7            sub_2b1bh:   rst 10h
2B1C:  cd 37 23      sub_2b1ch:   call 02337h
2B1F:  cd 05 2b      sub_2b1fh:   call sub_2b05h
2B22:  c2 4a 1e                   jp nz,l1e4ah
2B25:  2b                         dec hl
2B26:  d7                         rst 10h
2B27:  7b                         ld a,e
2B28:  c9                         ret
2B29:  3e 01                      ld a,001h
2B2B:  32 9c 78                   ld (OUTDEV),a
2B2E:  c1                         pop bc
2B2F:  cd 10 1b                   call sub_1b10h
2B32:  c5                         push bc
2B33:  cd 25 3b      l2b33h:      call sub_3b25h
2B36:  22 a2 78                   ld (078a2h),hl
2B39:  e1                         pop hl
2B3A:  d1                         pop de
2B3B:  4e                         ld c,(hl)
2B3C:  23                         inc hl
2B3D:  46                         ld b,(hl)
2B3E:  23                         inc hl
2B3F:  78                         ld a,b
2B40:  b1                         or c
2B41:  ca 19 1a                   jp z,BASENT
2B44:  cd df 79                   call 079dfh
2B47:  cd 9b 1d                   call sub_1d9bh
2B4A:  c5                         push bc
2B4B:  4e                         ld c,(hl)
2B4C:  23                         inc hl
2B4D:  46                         ld b,(hl)
2B4E:  23                         inc hl
2B4F:  c5                         push bc
2B50:  e3                         ex (sp),hl
2B51:  eb                         ex de,hl
2B52:  df                         rst 18h
2B53:  c1                         pop bc
2B54:  da 18 1a                   jp c,01a18h
2B57:  e3                         ex (sp),hl
2B58:  e5                         push hl
2B59:  c5                         push bc
2B5A:  eb                         ex de,hl
2B5B:  22 ec 78                   ld (078ech),hl
2B5E:  cd af 0f                   call sub_0fafh
2B61:  3e 20                      ld a,020h
2B63:  e1                         pop hl
2B64:  cd 2a 03                   call sub_032ah
2B67:  cd 7e 2b                   call sub_2b7eh
2B6A:  2a a7 78                   ld hl,(078a7h)
2B6D:  cd 75 2b                   call sub_2b75h
2B70:  cd fe 20                   call sub_20feh
2B73:  18 be                      jr l2b33h
2B75:  7e            sub_2b75h:   ld a,(hl)
2B76:  b7                         or a
2B77:  c8                         ret z
2B78:  cd 2a 03                   call sub_032ah
2B7B:  23                         inc hl
2B7C:  18 f7                      jr sub_2b75h
2B7E:  e5            sub_2b7eh:   push hl
2B7F:  2a a7 78                   ld hl,(078a7h)
2B82:  44                         ld b,h
2B83:  4d                         ld c,l
2B84:  e1                         pop hl
2B85:  16 ff                      ld d,0ffh
2B87:  18 03                      jr l2b8ch
2B89:  03            l2b89h:      inc bc
2B8A:  15                         dec d
2B8B:  c8                         ret z
2B8C:  7e            l2b8ch:      ld a,(hl)
2B8D:  b7                         or a
2B8E:  23                         inc hl
2B8F:  02                         ld (bc),a
2B90:  c8                         ret z
2B91:  c3 9d 2e                   jp l2e9dh
2B94:  fe fb         l2b94h:      cp 0fbh
2B96:  20 08                      jr nz,l2ba0h
2B98:  0b                         dec bc
2B99:  0b                         dec bc
2B9A:  0b                         dec bc
2B9B:  0b                         dec bc
2B9C:  14                         inc d
2B9D:  14                         inc d
2B9E:  14                         inc d
2B9F:  14                         inc d
2BA0:  fe 95         l2ba0h:      cp 095h
2BA2:  cc 24 0b                   call z,sub_0b24h
2BA5:  d6 7f                      sub 07fh
2BA7:  e5                         push hl
2BA8:  5f                         ld e,a
2BA9:  21 50 16                   ld hl,l1650h
2BAC:  7e            l2bach:      ld a,(hl)
2BAD:  b7                         or a
2BAE:  23                         inc hl
2BAF:  f2 ac 2b                   jp p,l2bach
2BB2:  1d                         dec e
2BB3:  20 f7                      jr nz,l2bach
2BB5:  e6 7f                      and 07fh
2BB7:  02            l2bb7h:      ld (bc),a
2BB8:  03                         inc bc
2BB9:  15                         dec d
2BBA:  ca d8 28                   jp z,l28d8h
2BBD:  7e                         ld a,(hl)
2BBE:  23                         inc hl
2BBF:  b7                         or a
2BC0:  f2 b7 2b                   jp p,l2bb7h
2BC3:  e1                         pop hl
2BC4:  18 c6                      jr l2b8ch
2BC6:  cd 10 1b                   call sub_1b10h
2BC9:  d1                         pop de
2BCA:  c5                         push bc
2BCB:  c5                         push bc
2BCC:  cd 2c 1b                   call sub_1b2ch
2BCF:  30 05                      jr nc,l2bd6h
2BD1:  54                         ld d,h
2BD2:  5d                         ld e,l
2BD3:  e3                         ex (sp),hl
2BD4:  e5                         push hl
2BD5:  df                         rst 18h
2BD6:  d2 4a 1e      l2bd6h:      jp nc,l1e4ah
2BD9:  21 29 19                   ld hl,l1929h
2BDC:  cd a7 28                   call OUTSTR
2BDF:  c1                         pop bc
2BE0:  21 e8 1a                   ld hl,l1ae8h
2BE3:  e3                         ex (sp),hl
2BE4:  eb            sub_2be4h:   ex de,hl
2BE5:  2a f9 78                   ld hl,(PROGEND)
2BE8:  1a            l2be8h:      ld a,(de)
2BE9:  02                         ld (bc),a
2BEA:  03                         inc bc
2BEB:  13                         inc de
2BEC:  df                         rst 18h
2BED:  20 f9                      jr nz,l2be8h
2BEF:  60                         ld h,b
2BF0:  69                         ld l,c
2BF1:  22 f9 78                   ld (PROGEND),hl
2BF4:  c9                         ret
2BF5:  cd 1c 2b      l2bf5h:      call sub_2b1ch
2BF8:  fe 20                      cp 020h
2BFA:  d2 4a 1e                   jp nc,l1e4ah
2BFD:  32 d2 7a                   ld (07ad2h),a
2C00:  cf                         rst 8
2C01:  2c                         inc l
2C02:  cd 1c 2b                   call sub_2b1ch
2C05:  b7                         or a
2C06:  ca 4a 1e                   jp z,l1e4ah
2C09:  fe 0a                      cp 00ah
2C0B:  d2 4a 1e                   jp nc,l1e4ah
2C0E:  f3                         di
2C0F:  e5                         push hl
2C10:  3d                         dec a
2C11:  f5                         push af
2C12:  3a d2 7a                   ld a,(07ad2h)
2C15:  b7                         or a
2C16:  28 40                      jr z,l2c58h
2C18:  3d                         dec a
2C19:  cb 27                      sla a
2C1B:  4f                         ld c,a
2C1C:  af                         xor a
2C1D:  47                         ld b,a
2C1E:  f1                         pop af
2C1F:  21 cf 02                   ld hl,l02cfh
2C22:  09                         add hl,bc
2C23:  5e                         ld e,(hl)
2C24:  23                         inc hl
2C25:  56                         ld d,(hl)
2C26:  d5                         push de
2C27:  21 61 03                   ld hl,l0361h
2C2A:  cb 39                      srl c
2C2C:  09                         add hl,bc
2C2D:  5e                         ld e,(hl)
2C2E:  16 00                      ld d,000h
2C30:  21 21 03                   ld hl,l0321h
2C33:  4f                         ld c,a
2C34:  09                         add hl,bc
2C35:  46                         ld b,(hl)
2C36:  d5                         push de
2C37:  e1                         pop hl
2C38:  19            l2c38h:      add hl,de
2C39:  10 fd                      djnz l2c38h
2C3B:  e5                         push hl
2C3C:  c1                         pop bc
2C3D:  e1                         pop hl
2C3E:  cd f8 3a      l2c3eh:      call sub_3af8h
2C41:  3a 3b 78                   ld a,(CPIOREG)
2C44:  57                         ld d,a
2C45:  cd 69 34                   call sub_3469h
2C48:  0b                         dec bc
2C49:  79                         ld a,c
2C4A:  b0                         or b
2C4B:  20 f1                      jr nz,l2c3eh
2C4D:  e1            l2c4dh:      pop hl
2C4E:  fb                         ei
2C4F:  7e                         ld a,(hl)
2C50:  23                         inc hl
2C51:  fe 3b                      cp 03bh
2C53:  ca f5 2b                   jp z,l2bf5h
2C56:  2b                         dec hl
2C57:  c9                         ret
2C58:  f1            l2c58h:      pop af
2C59:  4f                         ld c,a
2C5A:  af                         xor a
2C5B:  47                         ld b,a
2C5C:  21 21 03                   ld hl,l0321h
2C5F:  09                         add hl,bc
2C60:  46                         ld b,(hl)
2C61:  21 36 19                   ld hl,sub_1936h
2C64:  e5                         push hl
2C65:  d1                         pop de
2C66:  19            l2c66h:      add hl,de
2C67:  10 fd                      djnz l2c66h
2C69:  cd f8 3a      l2c69h:      call sub_3af8h
2C6C:  2b                         dec hl
2C6D:  7d                         ld a,l
2C6E:  b4                         or h
2C6F:  20 f8                      jr nz,l2c69h
2C71:  18 da                      jr l2c4dh
2C73:  c5            sub_2c73h:   push bc
2C74:  47                         ld b,a
2C75:  3e 08                      ld a,008h
2C77:  cd ba 3a                   call sub_3abah
2C7A:  78                         ld a,b
2C7B:  e6 0f                      and 00fh
2C7D:  e5                         push hl
2C7E:  cb 27                      sla a
2C80:  4f                         ld c,a
2C81:  af                         xor a
2C82:  47                         ld b,a
2C83:  21 af 02                   ld hl,002afh
2C86:  09                         add hl,bc
2C87:  7e                         ld a,(hl)
2C88:  47                         ld b,a
2C89:  23                         inc hl
2C8A:  7e                         ld a,(hl)
2C8B:  4f                         ld c,a
2C8C:  78                         ld a,b
2C8D:  cd ba 3a                   call sub_3abah
2C90:  cd ba 3a                   call sub_3abah
2C93:  cd ba 3a                   call sub_3abah
2C96:  79                         ld a,c
2C97:  cd ba 3a                   call sub_3abah
2C9A:  cd ba 3a                   call sub_3abah
2C9D:  cd ba 3a                   call sub_3abah
2CA0:  e1                         pop hl
2CA1:  c1                         pop bc
2CA2:  3e 0f                      ld a,00fh
2CA4:  cd ba 3a                   call sub_3abah
2CA7:  c9                         ret
2CA8:  30 9d                      jr nc,$-97
2CAA:  cd 7f 0a                   call l0a7fh
2CAD:  7e                         ld a,(hl)
2CAE:  c3 f8 27                   jp sub_27f8h
2CB1:  cd 02 2b                   call sub_2b02h
2CB4:  d5                         push de
2CB5:  cf                         rst 8
2CB6:  2c                         inc l
2CB7:  cd 1c 2b                   call sub_2b1ch
2CBA:  d1                         pop de
2CBB:  12                         ld (de),a
2CBC:  c9                         ret
2CBD:  cd 38 23      l2cbdh:      call sub_2338h
2CC0:  cd f4 0a                   call sub_0af4h
2CC3:  cf                         rst 8
2CC4:  3b                         dec sp
2CC5:  eb                         ex de,hl
2CC6:  2a 21 79                   ld hl,(07921h)
2CC9:  18 08                      jr l2cd3h
2CCB:  3a de 78      l2ccbh:      ld a,(078deh)
2CCE:  b7                         or a
2CCF:  28 0c         l2ccfh:      jr z,l2cddh
2CD1:  d1                         pop de
2CD2:  eb                         ex de,hl
2CD3:  e5            l2cd3h:      push hl
2CD4:  af                         xor a
2CD5:  32 de 78                   ld (078deh),a
2CD8:  ba                         cp d
2CD9:  f5                         push af
2CDA:  d5                         push de
2CDB:  46                         ld b,(hl)
2CDC:  b0                         or b
2CDD:  ca 4a 1e      l2cddh:      jp z,l1e4ah
2CE0:  23                         inc hl
2CE1:  4e                         ld c,(hl)
2CE2:  23                         inc hl
2CE3:  66                         ld h,(hl)
2CE4:  69                         ld l,c
2CE5:  18 1c                      jr l2d03h
2CE7:  58            l2ce7h:      ld e,b
2CE8:  e5                         push hl
2CE9:  0e 02                      ld c,002h
2CEB:  7e            l2cebh:      ld a,(hl)
2CEC:  23                         inc hl
2CED:  fe 25                      cp 025h
2CEF:  ca 17 2e                   jp z,02e17h
2CF2:  fe 20                      cp 020h
2CF4:  20 03                      jr nz,l2cf9h
2CF6:  0c                         inc c
2CF7:  10 f2                      djnz l2cebh
2CF9:  e1            l2cf9h:      pop hl
2CFA:  43                         ld b,e
2CFB:  3e 25                      ld a,025h
2CFD:  cd 49 2e      l2cfdh:      call sub_2e49h
2D00:  cd 2a 03                   call sub_032ah
2D03:  af            l2d03h:      xor a
2D04:  5f                         ld e,a
2D05:  57                         ld d,a
2D06:  cd 49 2e      l2d06h:      call sub_2e49h
2D09:  57                         ld d,a
2D0A:  7e                         ld a,(hl)
2D0B:  23                         inc hl
2D0C:  fe 21                      cp 021h
2D0E:  ca 14 2e                   jp z,l2e14h
2D11:  fe 23                      cp 023h
2D13:  28 37                      jr z,l2d4ch
2D15:  05                         dec b
2D16:  ca fe 2d                   jp z,l2dfeh
2D19:  fe 2b                      cp 02bh
2D1B:  3e 08                      ld a,008h
2D1D:  28 e7                      jr z,l2d06h
2D1F:  2b                         dec hl
2D20:  7e                         ld a,(hl)
2D21:  23                         inc hl
2D22:  fe 2e                      cp 02eh
2D24:  28 40                      jr z,l2d66h
2D26:  fe 25                      cp 025h
2D28:  28 bd                      jr z,l2ce7h
2D2A:  be                         cp (hl)
2D2B:  20 d0                      jr nz,l2cfdh
2D2D:  fe 24                      cp 024h
2D2F:  28 14                      jr z,$+22
2D31:  fe 2a                      cp 02ah
2D33:  20 c8                      jr nz,l2cfdh
2D35:  78                         ld a,b
2D36:  fe 02                      cp 002h
2D38:  23                         inc hl
2D39:  38 03                      jr c,l2d3eh
2D3B:  7e                         ld a,(hl)
2D3C:  fe 24                      cp 024h
2D3E:  3e 20         l2d3eh:      ld a,020h
2D40:  20 07                      jr nz,l2d49h
2D42:  05                         dec b
2D43:  1c                         inc e
2D44:  fe af                      cp 0afh
2D46:  c6 10                      add a,010h
2D48:  23                         inc hl
2D49:  1c            l2d49h:      inc e
2D4A:  82                         add a,d
2D4B:  57                         ld d,a
2D4C:  1c            l2d4ch:      inc e
2D4D:  0e 00                      ld c,000h
2D4F:  05                         dec b
2D50:  28 47                      jr z,l2d99h
2D52:  7e                         ld a,(hl)
2D53:  23                         inc hl
2D54:  fe 2e                      cp 02eh
2D56:  28 18                      jr z,l2d70h
2D58:  fe 23                      cp 023h
2D5A:  28 f0                      jr z,l2d4ch
2D5C:  fe 2c                      cp 02ch
2D5E:  20 1a                      jr nz,l2d7ah
2D60:  7a                         ld a,d
2D61:  f6 40                      or 040h
2D63:  57                         ld d,a
2D64:  18 e6                      jr l2d4ch
2D66:  7e            l2d66h:      ld a,(hl)
2D67:  fe 23                      cp 023h
2D69:  3e 2e                      ld a,02eh
2D6B:  20 90                      jr nz,l2cfdh
2D6D:  0e 01                      ld c,001h
2D6F:  23                         inc hl
2D70:  0c            l2d70h:      inc c
2D71:  05                         dec b
2D72:  28 25                      jr z,l2d99h
2D74:  7e                         ld a,(hl)
2D75:  23                         inc hl
2D76:  fe 23                      cp 023h
2D78:  28 f6                      jr z,l2d70h
2D7A:  d5            l2d7ah:      push de
2D7B:  11 97 2d                   ld de,02d97h
2D7E:  d5                         push de
2D7F:  54                         ld d,h
2D80:  5d                         ld e,l
2D81:  fe 5b                      cp 05bh
2D83:  c0                         ret nz
2D84:  be                         cp (hl)
2D85:  c0                         ret nz
2D86:  23                         inc hl
2D87:  be                         cp (hl)
2D88:  c0                         ret nz
2D89:  23                         inc hl
2D8A:  be                         cp (hl)
2D8B:  c0                         ret nz
2D8C:  23                         inc hl
2D8D:  78                         ld a,b
2D8E:  d6 04                      sub 004h
2D90:  d8                         ret c
2D91:  d1                         pop de
2D92:  d1                         pop de
2D93:  47                         ld b,a
2D94:  14                         inc d
2D95:  23                         inc hl
2D96:  ca eb d1                   jp z,0d1ebh
2D99:  7a            l2d99h:      ld a,d
2D9A:  2b                         dec hl
2D9B:  1c                         inc e
2D9C:  e6 08                      and 008h
2D9E:  20 15                      jr nz,l2db5h
2DA0:  1d                         dec e
2DA1:  78                         ld a,b
2DA2:  b7                         or a
2DA3:  28 10                      jr z,l2db5h
2DA5:  7e                         ld a,(hl)
2DA6:  d6 2d                      sub 02dh
2DA8:  28 06                      jr z,l2db0h
2DAA:  fe fe                      cp 0feh
2DAC:  20 07                      jr nz,l2db5h
2DAE:  3e 08                      ld a,008h
2DB0:  c6 04         l2db0h:      add a,004h
2DB2:  82                         add a,d
2DB3:  57                         ld d,a
2DB4:  05                         dec b
2DB5:  e1            l2db5h:      pop hl
2DB6:  f1                         pop af
2DB7:  28 50                      jr z,l2e09h
2DB9:  c5                         push bc
2DBA:  d5                         push de
2DBB:  cd 37 23                   call 02337h
2DBE:  d1                         pop de
2DBF:  c1                         pop bc
2DC0:  c5                         push bc
2DC1:  e5                         push hl
2DC2:  43                         ld b,e
2DC3:  78                         ld a,b
2DC4:  81                         add a,c
2DC5:  fe 19                      cp 019h
2DC7:  d2 4a 1e                   jp nc,l1e4ah
2DCA:  7a                         ld a,d
2DCB:  f6 80                      or 080h
2DCD:  cd be 0f                   call sub_0fbeh
2DD0:  cd a7 28                   call OUTSTR
2DD3:  e1            l2dd3h:      pop hl
2DD4:  2b                         dec hl
2DD5:  d7                         rst 10h
2DD6:  37                         scf
2DD7:  28 0d                      jr z,l2de6h
2DD9:  32 de 78                   ld (078deh),a
2DDC:  fe 3b                      cp 03bh
2DDE:  28 05                      jr z,l2de5h
2DE0:  fe 2c                      cp 02ch
2DE2:  c2 97 19                   jp nz,l1997h
2DE5:  d7            l2de5h:      rst 10h
2DE6:  c1            l2de6h:      pop bc
2DE7:  eb                         ex de,hl
2DE8:  e1                         pop hl
2DE9:  e5                         push hl
2DEA:  f5                         push af
2DEB:  d5                         push de
2DEC:  7e                         ld a,(hl)
2DED:  90                         sub b
2DEE:  23                         inc hl
2DEF:  4e                         ld c,(hl)
2DF0:  23                         inc hl
2DF1:  66                         ld h,(hl)
2DF2:  69                         ld l,c
2DF3:  16 00                      ld d,000h
2DF5:  5f                         ld e,a
2DF6:  19                         add hl,de
2DF7:  78                         ld a,b
2DF8:  b7                         or a
2DF9:  c2 03 2d                   jp nz,l2d03h
2DFC:  18 06                      jr l2e04h
2DFE:  cd 49 2e      l2dfeh:      call sub_2e49h
2E01:  cd 2a 03                   call sub_032ah
2E04:  e1            l2e04h:      pop hl
2E05:  f1                         pop af
2E06:  c2 cb 2c                   jp nz,l2ccbh
2E09:  dc fe 20      l2e09h:      call c,sub_20feh
2E0C:  e3                         ex (sp),hl
2E0D:  cd dd 29                   call sub_29ddh
2E10:  e1                         pop hl
2E11:  c3 69 21                   jp sub_2169h
2E14:  0e 01         l2e14h:      ld c,001h
2E16:  3e f1                      ld a,0f1h
2E18:  05                         dec b
2E19:  cd 49 2e                   call sub_2e49h
2E1C:  e1                         pop hl
2E1D:  f1                         pop af
2E1E:  28 e9                      jr z,l2e09h
2E20:  c5                         push bc
2E21:  cd 37 23                   call 02337h
2E24:  cd f4 0a                   call sub_0af4h
2E27:  c1                         pop bc
2E28:  c5                         push bc
2E29:  e5                         push hl
2E2A:  2a 21 79                   ld hl,(07921h)
2E2D:  41                         ld b,c
2E2E:  0e 00                      ld c,000h
2E30:  c5                         push bc
2E31:  cd 68 2a                   call 02a68h
2E34:  cd aa 28                   call sub_28aah
2E37:  2a 21 79                   ld hl,(07921h)
2E3A:  f1                         pop af
2E3B:  96                         sub (hl)
2E3C:  47                         ld b,a
2E3D:  3e 20                      ld a,020h
2E3F:  04                         inc b
2E40:  05            l2e40h:      dec b
2E41:  ca d3 2d                   jp z,l2dd3h
2E44:  cd 2a 03                   call sub_032ah
2E47:  18 f7                      jr l2e40h
2E49:  f5            sub_2e49h:   push af
2E4A:  7a                         ld a,d
2E4B:  b7                         or a
2E4C:  3e 2b                      ld a,02bh
2E4E:  c4 2a 03                   call nz,sub_032ah
2E51:  f1                         pop af
2E52:  c9                         ret
2E53:  60            sub_2e53h:   ld h,b
2E54:  69                         ld l,c
2E55:  23                         inc hl
2E56:  23                         inc hl
2E57:  23                         inc hl
2E58:  23                         inc hl
2E59:  cd 7e 2b                   call sub_2b7eh
2E5C:  2a a7 78                   ld hl,(078a7h)
2E5F:  cd 75 2b                   call sub_2b75h
2E62:  c9                         ret
2E63:  cf                         rst 8
2E64:  28 cd                      jr z,$-49
2E66:  1c                         inc e
2E67:  2b                         dec hl
2E68:  b7                         or a
2E69:  28 12                      jr z,l2e7dh
2E6B:  3d                         dec a
2E6C:  28 03                      jr z,l2e71h
2E6E:  c3 4a 1e                   jp l1e4ah
2E71:  16 00         l2e71h:      ld d,000h
2E73:  3a 3b 78                   ld a,(CPIOREG)
2E76:  f6 08                      or 008h
2E78:  32 3b 78                   ld (CPIOREG),a
2E7B:  18 0a                      jr l2e87h
2E7D:  16 20         l2e7dh:      ld d,020h
2E7F:  3a 3b 78                   ld a,(CPIOREG)
2E82:  e6 f7                      and 0f7h
2E84:  32 3b 78                   ld (CPIOREG),a
2E87:  32 00 68      l2e87h:      ld (IOREG),a
2E8A:  e5                         push hl
2E8B:  21 00 70                   ld hl,VRAMBASE
2E8E:  01 00 08                   ld bc,l0800h
2E91:  7a            l2e91h:      ld a,d
2E92:  77                         ld (hl),a
2E93:  23                         inc hl
2E94:  0b                         dec bc
2E95:  78                         ld a,b
2E96:  b1                         or c
2E97:  20 f8                      jr nz,l2e91h
2E99:  e1                         pop hl
2E9A:  cf                         rst 8
2E9B:  29                         add hl,hl
2E9C:  c9                         ret
2E9D:  fe 22         l2e9dh:      cp 022h
2E9F:  ca b3 2e                   jp z,l2eb3h
2EA2:  b7                         or a
2EA3:  f2 89 2b                   jp p,l2b89h
2EA6:  c3 94 2b                   jp l2b94h
2EA9:  7e            l2ea9h:      ld a,(hl)
2EAA:  b7                         or a
2EAB:  23                         inc hl
2EAC:  02                         ld (bc),a
2EAD:  c8                         ret z
2EAE:  fe 22                      cp 022h
2EB0:  ca 89 2b                   jp z,l2b89h
2EB3:  03            l2eb3h:      inc bc
2EB4:  15                         dec d
2EB5:  c8                         ret z
2EB6:  18 f1                      jr l2ea9h
2EB8:  f5            SYSIHAND:    push af
2EB9:  c5                         push bc
2EBA:  d5                         push de
2EBB:  e5                         push hl
2EBC:  cd 7d 78                   call LOCIHAND
2EBF:  cd 7b 3f                   call sub_3f7bh
2EC2:  cd dc 2e                   call sub_2edch
2EC5:  cd fd 2e                   call ONEKBSCAN
2EC8:  f5                         push af
2EC9:  21 39 78                   ld hl,07839h
2ECC:  cb 46                      bit 0,(hl)
2ECE:  cc 1b 30                   call z,sub_301bh
2ED1:  f1                         pop af
2ED2:  cd 30 34                   call sub_3430h
2ED5:  e1                         pop hl
2ED6:  d1                         pop de
2ED7:  c1                         pop bc
2ED8:  f1                         pop af
2ED9:  fb                         ei
2EDA:  ed 4d                      reti
2EDC:  3a 39 78      sub_2edch:   ld a,(07839h)
2EDF:  cb 47                      bit 0,a
2EE1:  c0                         ret nz
2EE2:  21 41 78                   ld hl,07841h
2EE5:  35                         dec (hl)
2EE6:  c0                         ret nz
2EE7:  3e 10                      ld a,010h
2EE9:  32 41 78                   ld (07841h),a
2EEC:  2a 20 78                   ld hl,(CURPOS)
2EEF:  3e 40                      ld a,040h
2EF1:  ae                         xor (hl)
2EF2:  77                         ld (hl),a
2EF3:  c9                         ret
2EF4:  cd fd 2e      SCANKEYB:    call ONEKBSCAN
2EF7:  f5                         push af
2EF8:  cd 0e 2f                   call sub_2f0eh
2EFB:  f1                         pop af
2EFC:  c9                         ret
2EFD:  3a 00 68      ONEKBSCAN:   ld a,(IOREG)
2F00:  f6 c0                      or 0c0h
2F02:  2f                         cpl
2F03:  fe 00                      cp 000h
2F05:  28 07                      jr z,sub_2f0eh
2F07:  cd 28 2f                   call sub_2f28h
2F0A:  b7                         or a
2F0B:  c2 d7 05                   jp nz,l05d7h
2F0E:  21 38 78      sub_2f0eh:   ld hl,07838h
2F11:  cb 56                      bit 2,(hl)
2F13:  28 08                      jr z,l2f1dh
2F15:  3a 3a 78                   ld a,(0783ah)
2F18:  b7                         or a
2F19:  28 02                      jr z,l2f1dh
2F1B:  cb 96                      res 2,(hl)
2F1D:  7e            l2f1dh:      ld a,(hl)
2F1E:  e6 06                      and 006h
2F20:  32 38 78                   ld (07838h),a
2F23:  af                         xor a
2F24:  32 36 78                   ld (07836h),a
2F27:  c9                         ret
2F28:  21 fe 68      sub_2f28h:   ld hl,KBROW0
2F2B:  0e 08                      ld c,008h
2F2D:  06 06         l2f2dh:      ld b,006h
2F2F:  7e                         ld a,(hl)
2F30:  f6 04                      or 004h
2F32:  1f            l2f32h:      rra
2F33:  30 2d                      jr nc,l2f62h
2F35:  10 fb         sub_2f35h:   djnz l2f32h
2F37:  cb 05                      rlc l
2F39:  0d                         dec c
2F3A:  20 f1                      jr nz,l2f2dh
2F3C:  06 04                      ld b,004h
2F3E:  21 df 68                   ld hl,KBROW5
2F41:  7e                         ld a,(hl)
2F42:  cb 57                      bit 2,a
2F44:  28 10                      jr z,l2f56h
2F46:  cb 05                      rlc l
2F48:  7e                         ld a,(hl)
2F49:  cb 57                      bit 2,a
2F4B:  28 0d                      jr z,l2f5ah
2F4D:  cb 05                      rlc l
2F4F:  7e                         ld a,(hl)
2F50:  cb 57                      bit 2,a
2F52:  28 0a                      jr z,l2f5eh
2F54:  af                         xor a
2F55:  c9                         ret
2F56:  0e 03         l2f56h:      ld c,003h
2F58:  18 06                      jr l2f60h
2F5A:  0e 02         l2f5ah:      ld c,002h
2F5C:  18 02                      jr l2f60h
2F5E:  0e 01         l2f5eh:      ld c,001h
2F60:  f6 04         l2f60h:      or 004h
2F62:  5f            l2f62h:      ld e,a
2F63:  3e 06                      ld a,006h
2F65:  90                         sub b
2F66:  cb 27                      sla a
2F68:  cb 27                      sla a
2F6A:  cb 27                      sla a
2F6C:  c6 08                      add a,008h
2F6E:  91                         sub c
2F6F:  ed 43 42                   ld (07842h),bc
2F73:  22 44 78                   ld (07844h),hl
2F76:  21 d9 01                   ld hl,l01d9h
2F79:  4f                         ld c,a
2F7A:  06 00                      ld b,000h
2F7C:  3a fb 68                   ld a,(KBROW2)
2F7F:  cb 57                      bit 2,a
2F81:  20 0a                      jr nz,l2f8dh
2F83:  21 38 78                   ld hl,07838h
2F86:  cb c6                      set 0,(hl)
2F88:  21 09 02                   ld hl,l0209h
2F8B:  18 3d                      jr l2fcah
2F8D:  3a fd 68      l2f8dh:      ld a,(KBROW1)
2F90:  cb 57                      bit 2,a
2F92:  20 39                      jr nz,l2fcdh
2F94:  3a 7f 68                   ld a,(KBROW7)
2F97:  cb 57                      bit 2,a
2F99:  20 0e                      jr nz,l2fa9h
2F9B:  21 38 78                   ld hl,07838h
2F9E:  cb 6e                      bit 5,(hl)
2FA0:  20 04                      jr nz,l2fa6h
2FA2:  7e                         ld a,(hl)
2FA3:  ee 22                      xor 022h
2FA5:  77                         ld (hl),a
2FA6:  af            l2fa6h:      xor a
2FA7:  c1                         pop bc
2FA8:  c9                         ret
2FA9:  21 38 78      l2fa9h:      ld hl,07838h
2FAC:  cb fe                      set 7,(hl)
2FAE:  cb 56                      bit 2,(hl)
2FB0:  28 05                      jr z,l2fb7h
2FB2:  21 69 02                   ld hl,l0269h
2FB5:  18 13                      jr l2fcah
2FB7:  3a bf 68      l2fb7h:      ld a,(KBROW6)
2FBA:  cb 57                      bit 2,a
2FBC:  20 07                      jr nz,l2fc5h
2FBE:  cb d6                      set 2,(hl)
2FC0:  af                         xor a
2FC1:  32 3a 78                   ld (0783ah),a
2FC4:  c9                         ret
2FC5:  cb 96         l2fc5h:      res 2,(hl)
2FC7:  21 39 02                   ld hl,l0239h
2FCA:  09            l2fcah:      add hl,bc
2FCB:  7e                         ld a,(hl)
2FCC:  c9                         ret
2FCD:  3a 38 78      l2fcdh:      ld a,(07838h)
2FD0:  e6 81                      and 081h
2FD2:  28 f6                      jr z,l2fcah
2FD4:  af                         xor a
2FD5:  e1                         pop hl
2FD6:  c9                         ret
2FD7:  21 38 78      l2fd7h:      ld hl,07838h
2FDA:  cb 6e                      bit 5,(hl)
2FDC:  28 25                      jr z,l3003h
2FDE:  3a 3a 78                   ld a,(0783ah)
2FE1:  3c                         inc a
2FE2:  32 3a 78                   ld (0783ah),a
2FE5:  fe 2a                      cp 02ah
2FE7:  28 02                      jr z,l2febh
2FE9:  af                         xor a
2FEA:  c9                         ret
2FEB:  7e            l2febh:      ld a,(hl)
2FEC:  e6 df                      and 0dfh
2FEE:  f6 40                      or 040h
2FF0:  32 38 78                   ld (07838h),a
2FF3:  af            l2ff3h:      xor a
2FF4:  32 3a 78                   ld (0783ah),a
2FF7:  cb 66                      bit 4,(hl)
2FF9:  20 04                      jr nz,l2fffh
2FFB:  3a 36 78                   ld a,(07836h)
2FFE:  c9                         ret
2FFF:  3a 37 78      l2fffh:      ld a,(07837h)
3002:  c9                         ret
3003:  cb 76         l3003h:      bit 6,(hl)
3005:  20 07                      jr nz,l300eh
3007:  cb ee                      set 5,(hl)
3009:  af                         xor a
300A:  32 3a 78                   ld (0783ah),a
300D:  c9                         ret
300E:  3a 3a 78      l300eh:      ld a,(0783ah)
3011:  3c                         inc a
3012:  32 3a 78                   ld (0783ah),a
3015:  fe 06                      cp 006h
3017:  28 da                      jr z,l2ff3h
3019:  af                         xor a
301A:  c9                         ret
301B:  b7            sub_301bh:   or a
301C:  c8                         ret z
301D:  f5                         push af
301E:  cd 39 30                   call sub_3039h
3021:  f1                         pop af
3022:  fe 0d                      cp 00dh
3024:  c8                         ret z
3025:  fe 01                      cp 001h
3027:  c8                         ret z
3028:  3a 39 78                   ld a,(07839h)
302B:  cb 47                      bit 0,a
302D:  c0                         ret nz
302E:  3e 20         l302eh:      ld a,020h
3030:  32 41 78                   ld (07841h),a
3033:  2a 20 78                   ld hl,(CURPOS)
3036:  c3 b2 3e                   jp l3eb2h
3039:  21 38 78      sub_3039h:   ld hl,07838h
303C:  cb 7e                      bit 7,(hl)
303E:  ca 57 31                   jp z,l3157h
3041:  b7                         or a
3042:  f2 57 31                   jp p,l3157h
3045:  f5                         push af
3046:  d6 80                      sub 080h
3048:  3c                         inc a
3049:  47                         ld b,a
304A:  21 4f 16                   ld hl,0164fh
304D:  23            l304dh:      inc hl
304E:  cb 7e                      bit 7,(hl)
3050:  28 fb                      jr z,l304dh
3052:  10 f9                      djnz l304dh
3054:  7e                         ld a,(hl)
3055:  cd 82 30      l3055h:      call sub_3082h
3058:  7e                         ld a,(hl)
3059:  cb 7f                      bit 7,a
305B:  28 f8                      jr z,l3055h
305D:  f1                         pop af
305E:  06 16                      ld b,016h
3060:  21 99 02                   ld hl,l0299h
3063:  be            l3063h:      cp (hl)
3064:  28 16                      jr z,l307ch
3066:  23                         inc hl
3067:  10 fa                      djnz l3063h
3069:  fe b0                      cp 0b0h
306B:  c0                         ret nz
306C:  3e 20                      ld a,020h
306E:  cd 82 30                   call sub_3082h
3071:  3e 46                      ld a,046h
3073:  cd 82 30                   call sub_3082h
3076:  3e 4e                      ld a,04eh
3078:  cd 82 30                   call sub_3082h
307B:  c9                         ret
307C:  3e 28         l307ch:      ld a,028h
307E:  cd 82 30                   call sub_3082h
3081:  c9                         ret
3082:  e6 7f         sub_3082h:   and 07fh
3084:  e5                         push hl
3085:  cd 57 31                   call l3157h
3088:  e1                         pop hl
3089:  23                         inc hl
308A:  c9                         ret
308B:  f5            INTCHOUT:    push af
308C:  3a 3b 78                   ld a,(CPIOREG)
308F:  cb 5f                      bit 3,a
3091:  28 17                      jr z,l30aah
3093:  e6 f7                      and 0f7h
3095:  32 3b 78                   ld (CPIOREG),a
3098:  32 00 68                   ld (IOREG),a
309B:  01 00 02                   ld bc,l0200h
309E:  21 00 70                   ld hl,VRAMBASE
30A1:  cd be 3e      l30a1h:      call sub_3ebeh
30A4:  23                         inc hl
30A5:  0b                         dec bc
30A6:  79                         ld a,c
30A7:  b0                         or b
30A8:  20 f7                      jr nz,l30a1h
30AA:  f1            l30aah:      pop af
30AB:  21 39 78                   ld hl,07839h
30AE:  cb 6e                      bit 5,(hl)
30B0:  ca 06 31                   jp z,l3106h
30B3:  fe 20                      cp 020h
30B5:  d2 c0 30                   jp nc,l30c0h
30B8:  f5                         push af
30B9:  3a af 7a      l30b9h:      ld a,(07aafh)
30BC:  b7                         or a
30BD:  20 fa                      jr nz,l30b9h
30BF:  f1                         pop af
30C0:  f3            l30c0h:      di
30C1:  2a b0 7a                   ld hl,(07ab0h)
30C4:  77                         ld (hl),a
30C5:  23                         inc hl
30C6:  22 b0 7a                   ld (07ab0h),hl
30C9:  21 af 7a                   ld hl,07aafh
30CC:  34                         inc (hl)
30CD:  f5                         push af
30CE:  3a a6 78                   ld a,(078a6h)
30D1:  86                         add a,(hl)
30D2:  32 ae 7a                   ld (07aaeh),a
30D5:  f1                         pop af
30D6:  fb                         ei
30D7:  fe 20                      cp 020h
30D9:  da e3 30                   jp c,l30e3h
30DC:  3e 14                      ld a,014h
30DE:  be            l30deh:      cp (hl)
30DF:  da de 30                   jp c,l30deh
30E2:  c9                         ret
30E3:  af            l30e3h:      xor a
30E4:  be            l30e4h:      cp (hl)
30E5:  20 fd                      jr nz,l30e4h
30E7:  c9                         ret
30E8:  3a af 7a      l30e8h:      ld a,(07aafh)
30EB:  b7                         or a
30EC:  c8                         ret z
30ED:  47                         ld b,a
30EE:  21 b2 7a                   ld hl,07ab2h
30F1:  e5                         push hl
30F2:  7e            l30f2h:      ld a,(hl)
30F3:  23                         inc hl
30F4:  e5                         push hl
30F5:  c5                         push bc
30F6:  cd 06 31                   call l3106h
30F9:  c1                         pop bc
30FA:  e1                         pop hl
30FB:  10 f5                      djnz l30f2h
30FD:  e1                         pop hl
30FE:  22 b0 7a                   ld (07ab0h),hl
3101:  af                         xor a
3102:  32 af 7a                   ld (07aafh),a
3105:  c9                         ret
3106:  cd 0d 03      l3106h:      call sub_030dh
3109:  b7                         or a
310A:  28 04                      jr z,l3110h
310C:  fe 0d                      cp 00dh
310E:  20 4a                      jr nz,l315ah
3110:  f5            l3110h:      push af
3111:  2a 20 78                   ld hl,(CURPOS)
3114:  3a a6 78                   ld a,(078a6h)
3117:  4f                         ld c,a
3118:  af                         xor a
3119:  47                         ld b,a
311A:  32 a6 78                   ld (078a6h),a
311D:  ed 42                      sbc hl,bc
311F:  01 20 00                   ld bc,l0020h
3122:  09                         add hl,bc
3123:  7c                         ld a,h
3124:  fe 72                      cp 072h
3126:  f4 f3 33                   call p,sub_33f3h
3129:  22 20 78                   ld (CURPOS),hl
312C:  cd 53 00                   call sub_0053h
312F:  f1                         pop af
3130:  b7                         or a
3131:  c8                         ret z
3132:  cd a8 33                   call sub_33a8h
3135:  fe 80                      cp 080h
3137:  c8                         ret z
3138:  fe 81                      cp 081h
313A:  20 05                      jr nz,l3141h
313C:  3d                         dec a
313D:  77                         ld (hl),a
313E:  23                         inc hl
313F:  77                         ld (hl),a
3140:  c9                         ret
3141:  3e 80         l3141h:      ld a,080h
3143:  77                         ld (hl),a
3144:  c9                         ret
3145:  cb 77         l3145h:      bit 6,a
3147:  28 04                      jr z,l314dh
3149:  c3 60 3f                   jp l3f60h
314C:  00                         nop
314D:  e6 8f         l314dh:      and 08fh
314F:  47                         ld b,a
3150:  3a 46 78                   ld a,(07846h)
3153:  b0                         or b
3154:  47            l3154h:      ld b,a
3155:  18 5f                      jr l31b6h
3157:  cd 0d 03      l3157h:      call sub_030dh
315A:  b7            l315ah:      or a
315B:  fa 45 31                   jp m,l3145h
315E:  fe 0d                      cp 00dh
3160:  c8                         ret z
3161:  fe 08                      cp 008h
3163:  ca 27 32                   jp z,l3227h
3166:  fe 1b                      cp 01bh
3168:  ca 53 32                   jp z,l3253h
316B:  fe 0a                      cp 00ah
316D:  ca 6d 32                   jp z,l326dh
3170:  fe 08                      cp 008h
3172:  ca 27 32                   jp z,l3227h
3175:  fe 09                      cp 009h
3177:  ca b8 31                   jp z,l31b8h
317A:  fe 01                      cp 001h
317C:  c8                         ret z
317D:  fe 7f                      cp 07fh
317F:  ca cb 33                   jp z,l33cbh
3182:  fe 15                      cp 015h
3184:  ca c6 32                   jp z,l32c6h
3187:  fe 18                      cp 018h
3189:  ca 27 32                   jp z,l3227h
318C:  fe 19                      cp 019h
318E:  ca b8 31                   jp z,l31b8h
3191:  fe 1b                      cp 01bh
3193:  ca 53 32                   jp z,l3253h
3196:  fe 1c                      cp 01ch
3198:  ca 87 32                   jp z,l3287h
319B:  fe 1d                      cp 01dh
319D:  ca b4 32                   jp z,l32b4h
31A0:  fe 1f                      cp 01fh
31A2:  ca 92 32                   jp z,l3292h
31A5:  fe 20                      cp 020h
31A7:  f8                         ret m
31A8:  c3 ca 3e                   jp l3ecah
31AB:  21 38 78      l31abh:      ld hl,07838h
31AE:  cb 4e                      bit 1,(hl)
31B0:  e1                         pop hl
31B1:  28 02                      jr z,l31b5h
31B3:  f6 40                      or 040h
31B5:  47            l31b5h:      ld b,a
31B6:  78            l31b6h:      ld a,b
31B7:  77                         ld (hl),a
31B8:  cd bf 31      l31b8h:      call sub_31bfh
31BB:  cd 50 00                   call SCRGET
31BE:  c9                         ret
31BF:  3a a6 78      sub_31bfh:   ld a,(078a6h)
31C2:  3c                         inc a
31C3:  fe 20                      cp 020h
31C5:  20 2b                      jr nz,l31f2h
31C7:  cd a8 33                   call sub_33a8h
31CA:  fe 81                      cp 081h
31CC:  28 23                      jr z,l31f1h
31CE:  b7                         or a
31CF:  20 35                      jr nz,l3206h
31D1:  47                         ld b,a
31D2:  3a 39 78                   ld a,(07839h)
31D5:  cb 47                      bit 0,a
31D7:  78                         ld a,b
31D8:  c8                         ret z
31D9:  af            l31d9h:      xor a
31DA:  23                         inc hl
31DB:  77                         ld (hl),a
31DC:  23                         inc hl
31DD:  e5                         push hl
31DE:  ed 4b a4                   ld bc,(PROGST)
31E2:  0b                         dec bc
31E3:  0b                         dec bc
31E4:  b7                         or a
31E5:  ed 42                      sbc hl,bc
31E7:  e1                         pop hl
31E8:  30 07                      jr nc,l31f1h
31EA:  7e                         ld a,(hl)
31EB:  b7                         or a
31EC:  20 03                      jr nz,l31f1h
31EE:  3e 80                      ld a,080h
31F0:  77                         ld (hl),a
31F1:  af            l31f1h:      xor a
31F2:  32 a6 78      l31f2h:      ld (078a6h),a
31F5:  2a 20 78                   ld hl,(CURPOS)
31F8:  01 01 00                   ld bc,l0001h
31FB:  09                         add hl,bc
31FC:  7c                         ld a,h
31FD:  fe 72                      cp 072h
31FF:  f4 f3 33                   call p,sub_33f3h
3202:  22 20 78                   ld (CURPOS),hl
3205:  c9                         ret
3206:  f5            l3206h:      push af
3207:  ed 5b 20                   ld de,(CURPOS)
320B:  13                         inc de
320C:  7a                         ld a,d
320D:  fe 72                      cp 072h
320F:  28 10                      jr z,l3221h
3211:  e5                         push hl
3212:  21 39 78                   ld hl,07839h
3215:  cb 46                      bit 0,(hl)
3217:  20 07                      jr nz,l3220h
3219:  cb 66                      bit 4,(hl)
321B:  20 03                      jr nz,l3220h
321D:  cd 2c 33                   call sub_332ch
3220:  e1            l3220h:      pop hl
3221:  f1            l3221h:      pop af
3222:  3c                         inc a
3223:  77                         ld (hl),a
3224:  c3 d9 31                   jp l31d9h
3227:  3a a6 78      l3227h:      ld a,(078a6h)
322A:  3d                         dec a
322B:  f2 35 32                   jp p,l3235h
322E:  cd a8 33                   call sub_33a8h
3231:  b7                         or a
3232:  c0                         ret nz
3233:  3e 1f         sub_3233h:   ld a,01fh
3235:  32 a6 78      l3235h:      ld (078a6h),a
3238:  01 01 00                   ld bc,l0001h
323B:  2a 20 78                   ld hl,(CURPOS)
323E:  af                         xor a
323F:  ed 42                      sbc hl,bc
3241:  7c                         ld a,h
3242:  fe 70                      cp 070h
3244:  da 4e 32                   jp c,l324eh
3247:  22 20 78                   ld (CURPOS),hl
324A:  cd 53 00                   call sub_0053h
324D:  c9                         ret
324E:  af            l324eh:      xor a
324F:  32 a6 78                   ld (078a6h),a
3252:  c9                         ret
3253:  21 39 78      l3253h:      ld hl,07839h
3256:  cb 66                      bit 4,(hl)
3258:  c0                         ret nz
3259:  01 20 00                   ld bc,l0020h
325C:  2a 20 78                   ld hl,(CURPOS)
325F:  af                         xor a
3260:  ed 42                      sbc hl,bc
3262:  7c                         ld a,h
3263:  fe 70                      cp 070h
3265:  f8                         ret m
3266:  22 20 78                   ld (CURPOS),hl
3269:  cd 53 00                   call sub_0053h
326C:  c9                         ret
326D:  21 39 78      l326dh:      ld hl,07839h
3270:  cb 66                      bit 4,(hl)
3272:  c0                         ret nz
3273:  01 20 00                   ld bc,l0020h
3276:  2a 20 78                   ld hl,(CURPOS)
3279:  09                         add hl,bc
327A:  7c                         ld a,h
327B:  fe 72                      cp 072h
327D:  f4 24 34                   call p,sub_3424h
3280:  22 20 78                   ld (CURPOS),hl
3283:  cd 53 00                   call sub_0053h
3286:  c9                         ret
3287:  21 00 70      l3287h:      ld hl,VRAMBASE
328A:  22 20 78                   ld (CURPOS),hl
328D:  af                         xor a
328E:  32 a6 78                   ld (078a6h),a
3291:  c9                         ret
3292:  21 00 70      l3292h:      ld hl,VRAMBASE
3295:  22 20 78                   ld (CURPOS),hl
3298:  01 00 02                   ld bc,l0200h
329B:  cd be 3e      l329bh:      call sub_3ebeh
329E:  23                         inc hl
329F:  0b                         dec bc
32A0:  79                         ld a,c
32A1:  b0                         or b
32A2:  20 f7                      jr nz,l329bh
32A4:  af                         xor a
32A5:  32 a6 78                   ld (078a6h),a
32A8:  06 10                      ld b,010h
32AA:  3e 80                      ld a,080h
32AC:  21 d7 7a                   ld hl,07ad7h
32AF:  77            l32afh:      ld (hl),a
32B0:  23                         inc hl
32B1:  10 fc                      djnz l32afh
32B3:  c9                         ret
32B4:  2a 20 78      l32b4h:      ld hl,(CURPOS)
32B7:  3a a6 78                   ld a,(078a6h)
32BA:  4f                         ld c,a
32BB:  af                         xor a
32BC:  47                         ld b,a
32BD:  32 a6 78                   ld (078a6h),a
32C0:  ed 42                      sbc hl,bc
32C2:  22 20 78                   ld (CURPOS),hl
32C5:  c9                         ret
32C6:  cd a8 33      l32c6h:      call sub_33a8h
32C9:  fe 81                      cp 081h
32CB:  28 31                      jr z,l32feh
32CD:  3a a6 78                   ld a,(078a6h)
32D0:  fe 1f                      cp 01fh
32D2:  28 25                      jr z,l32f9h
32D4:  4f                         ld c,a
32D5:  af                         xor a
32D6:  47                         ld b,a
32D7:  2a 20 78                   ld hl,(CURPOS)
32DA:  ed 42                      sbc hl,bc
32DC:  01 1f 00                   ld bc,l001eh+1
32DF:  09                         add hl,bc
32E0:  cd e9 3e                   call sub_3ee9h
32E3:  20 14                      jr nz,l32f9h
32E5:  e5                         push hl
32E6:  d1                         pop de
32E7:  2b                         dec hl
32E8:  3a a6 78                   ld a,(078a6h)
32EB:  4f                         ld c,a
32EC:  3e 1f                      ld a,01fh
32EE:  91            l32eeh:      sub c
32EF:  4f                         ld c,a
32F0:  ed b8                      lddr
32F2:  cd f6 3e                   call sub_3ef6h
32F5:  32 3c 78                   ld (0783ch),a
32F8:  c9                         ret
32F9:  cd a8 33      l32f9h:      call sub_33a8h
32FC:  b7                         or a
32FD:  c8                         ret z
32FE:  fe 80         l32feh:      cp 080h
3300:  28 1e                      jr z,l3320h
3302:  3a a6 78                   ld a,(078a6h)
3305:  4f                         ld c,a
3306:  af                         xor a
3307:  47                         ld b,a
3308:  2a 20 78                   ld hl,(CURPOS)
330B:  ed 42                      sbc hl,bc
330D:  01 3f 00                   ld bc,0003fh
3310:  09                         add hl,bc
3311:  cd e9 3e                   call sub_3ee9h
3314:  c0                         ret nz
3315:  e5                         push hl
3316:  d1                         pop de
3317:  2b                         dec hl
3318:  3a a6 78                   ld a,(078a6h)
331B:  4f                         ld c,a
331C:  3e 3f                      ld a,03fh
331E:  18 ce                      jr l32eeh
3320:  e5            l3320h:      push hl
3321:  cd 2c 33                   call sub_332ch
3324:  e1                         pop hl
3325:  3e 81                      ld a,081h
3327:  77                         ld (hl),a
3328:  23                         inc hl
3329:  af                         xor a
332A:  77                         ld (hl),a
332B:  c9                         ret
332C:  2a 20 78      sub_332ch:   ld hl,(CURPOS)
332F:  7c                         ld a,h
3330:  fe 71                      cp 071h
3332:  20 2b                      jr nz,l335fh
3334:  7d                         ld a,l
3335:  fe e0                      cp 0e0h
3337:  da 5f 33                   jp c,l335fh
333A:  3a a6 78                   ld a,(078a6h)
333D:  f5                         push af
333E:  3a d7 7a                   ld a,(07ad7h)
3341:  fe 81                      cp 081h
3343:  20 08                      jr nz,l334dh
3345:  e5                         push hl
3346:  cd f3 33                   call sub_33f3h
3349:  e1                         pop hl
334A:  cd 17 03                   call sub_0317h
334D:  e5            l334dh:      push hl
334E:  cd f3 33                   call sub_33f3h
3351:  e1                         pop hl
3352:  cd 17 03                   call sub_0317h
3355:  f1                         pop af
3356:  32 a6 78                   ld (078a6h),a
3359:  d1                         pop de
335A:  e1                         pop hl
335B:  2b                         dec hl
335C:  e5                         push hl
335D:  d5                         push de
335E:  c9                         ret
335F:  3a a6 78      l335fh:      ld a,(078a6h)
3362:  4f                         ld c,a
3363:  af                         xor a
3364:  47                         ld b,a
3365:  ed 42                      sbc hl,bc
3367:  01 40 00                   ld bc,l0040h
336A:  09                         add hl,bc
336B:  e5                         push hl
336C:  eb                         ex de,hl
336D:  21 00 72                   ld hl,07200h
3370:  ed 52                      sbc hl,de
3372:  e5                         push hl
3373:  c1                         pop bc
3374:  21 df 71                   ld hl,071dfh
3377:  11 ff 71                   ld de,071ffh
337A:  79                         ld a,c
337B:  b0                         or b
337C:  28 02                      jr z,l3380h
337E:  ed b8                      lddr
3380:  e1            l3380h:      pop hl
3381:  cd 02 3f                   call sub_3f02h
3384:  00                         nop
3385:  12            l3385h:      ld (de),a
3386:  1b                         dec de
3387:  10 fc                      djnz l3385h
3389:  cd a8 33                   call sub_33a8h
338C:  e5                         push hl
338D:  c1                         pop bc
338E:  21 e6 7a                   ld hl,07ae6h
3391:  e5                         push hl
3392:  b7                         or a
3393:  ed 42                      sbc hl,bc
3395:  e5                         push hl
3396:  c1                         pop bc
3397:  e1                         pop hl
3398:  e5                         push hl
3399:  d1                         pop de
339A:  2b                         dec hl
339B:  ed b8                      lddr
339D:  3a e6 7a                   ld a,(07ae6h)
33A0:  fe 81                      cp 081h
33A2:  c0                         ret nz
33A3:  2a 20 78                   ld hl,(CURPOS)
33A6:  18 b7                      jr l335fh
33A8:  3a a6 78      sub_33a8h:   ld a,(078a6h)
33AB:  4f                         ld c,a
33AC:  af                         xor a
33AD:  47                         ld b,a
33AE:  2a 20 78                   ld hl,(CURPOS)
33B1:  ed 42                      sbc hl,bc
33B3:  e5                         push hl
33B4:  c1                         pop bc
33B5:  78                         ld a,b
33B6:  e6 0f                      and 00fh
33B8:  cb 3f                      srl a
33BA:  47                         ld b,a
33BB:  cb 19                      rr c
33BD:  cb 39                      srl c
33BF:  cb 39                      srl c
33C1:  cb 39                      srl c
33C3:  cb 39                      srl c
33C5:  21 d7 7a                   ld hl,07ad7h
33C8:  09                         add hl,bc
33C9:  7e                         ld a,(hl)
33CA:  c9                         ret
33CB:  cd a8 33      l33cbh:      call sub_33a8h
33CE:  fe 81                      cp 081h
33D0:  2a 20 78                   ld hl,(CURPOS)
33D3:  e5                         push hl
33D4:  d1                         pop de
33D5:  23                         inc hl
33D6:  3a a6 78                   ld a,(078a6h)
33D9:  4f                         ld c,a
33DA:  28 13                      jr z,l33efh
33DC:  fe 1f                      cp 01fh
33DE:  28 08                      jr z,l33e8h
33E0:  3e 1f                      ld a,01fh
33E2:  91            l33e2h:      sub c
33E3:  4f                         ld c,a
33E4:  af                         xor a
33E5:  47                         ld b,a
33E6:  ed b0                      ldir
33E8:  cd f6 3e      l33e8h:      call sub_3ef6h
33EB:  cd 50 00                   call SCRGET
33EE:  c9                         ret
33EF:  3e 3f         l33efh:      ld a,03fh
33F1:  18 ef                      jr l33e2h
33F3:  11 00 70      sub_33f3h:   ld de,VRAMBASE
33F6:  21 20 70                   ld hl,07020h
33F9:  01 e0 01                   ld bc,l01e0h
33FC:  ed b0                      ldir
33FE:  cd 02 3f                   call sub_3f02h
3401:  00                         nop
3402:  12            l3402h:      ld (de),a
3403:  13                         inc de
3404:  10 fc                      djnz l3402h
3406:  21 d7 7a                   ld hl,07ad7h
3409:  e5                         push hl
340A:  d1                         pop de
340B:  23                         inc hl
340C:  01 0f 00                   ld bc,l000fh
340F:  ed b0                      ldir
3411:  1a                         ld a,(de)
3412:  fe 81                      cp 081h
3414:  20 03                      jr nz,l3419h
3416:  af                         xor a
3417:  18 02                      jr l341bh
3419:  3e 80         l3419h:      ld a,080h
341B:  12            l341bh:      ld (de),a
341C:  af                         xor a
341D:  32 a6 78                   ld (078a6h),a
3420:  21 e0 71                   ld hl,071e0h
3423:  c9                         ret
3424:  3a d7 7a      sub_3424h:   ld a,(07ad7h)
3427:  fe 81                      cp 081h
3429:  cc f3 33                   call z,sub_33f3h
342C:  cd f3 33                   call sub_33f3h
342F:  c9                         ret
3430:  21 39 78      sub_3430h:   ld hl,07839h
3433:  b7                         or a
3434:  20 0b                      jr nz,l3441h
3436:  cb ce                      set 1,(hl)
3438:  01 ff 03                   ld bc,003ffh
343B:  0b            l343bh:      dec bc
343C:  79                         ld a,c
343D:  b0                         or b
343E:  20 fb                      jr nz,l343bh
3440:  c9                         ret
3441:  cb 46         l3441h:      bit 0,(hl)
3443:  c0                         ret nz
3444:  fe 0d                      cp 00dh
3446:  28 06                      jr z,l344eh
3448:  fe 01                      cp 001h
344A:  20 04                      jr nz,BEEP
344C:  cb d6                      set 2,(hl)
344E:  cb c6         l344eh:      set 0,(hl)
3450:  e5            BEEP:        push hl
3451:  21 a0 00                   ld hl,000a0h
3454:  01 06 00                   ld bc,l0005h+1
3457:  cd 5c 34                   call sub_345ch
345A:  e1                         pop hl
345B:  c9                         ret
345C:  3a 3b 78      sub_345ch:   ld a,(CPIOREG)
345F:  57                         ld d,a
3460:  cd 69 34      l3460h:      call sub_3469h
3463:  0b                         dec bc
3464:  79                         ld a,c
3465:  b0                         or b
3466:  20 f8                      jr nz,l3460h
3468:  c9                         ret
3469:  c5            sub_3469h:   push bc
346A:  7a                         ld a,d
346B:  ee 21                      xor 021h
346D:  32 00 68                   ld (IOREG),a
3470:  e5                         push hl
3471:  c1                         pop bc
3472:  0b            l3472h:      dec bc
3473:  79                         ld a,c
3474:  b0                         or b
3475:  20 fb                      jr nz,l3472h
3477:  7a                         ld a,d
3478:  32 00 68                   ld (IOREG),a
347B:  e5                         push hl
347C:  c1                         pop bc
347D:  0b            l347dh:      dec bc
347E:  79                         ld a,c
347F:  b0                         or b
3480:  20 fb                      jr nz,l347dh
3482:  c1                         pop bc
3483:  c9                         ret
3484:  cd a0 3f      sub_3484h:   call sub_3fa0h
3487:  3e 20                      ld a,020h
3489:  32 3b 78                   ld (CPIOREG),a
348C:  32 00 68                   ld (IOREG),a
348F:  3e 3c                      ld a,03ch
3491:  32 3a 78                   ld (0783ah),a
3494:  3e 10                      ld a,010h
3496:  32 41 78                   ld (07841h),a
3499:  af                         xor a
349A:  32 af 7a                   ld (07aafh),a
349D:  21 b2 7a                   ld hl,07ab2h
34A0:  22 b0 7a                   ld (07ab0h),hl
34A3:  3e c9                      ld a,0c9h
34A5:  c3 37 3e                   jp l3e37h
34A8:  c9                         ret
34A9:  f3                         di
34AA:  0e f0                      ld c,0f0h
34AC:  cd 58 35                   call sub_3558h
34AF:  da fe 3a                   jp c,l3afeh
34B2:  e5                         push hl
34B3:  01 9a 01                   ld bc,l019ah
34B6:  0b            l34b6h:      dec bc
34B7:  79                         ld a,c
34B8:  b0            sub_34b8h:   or b
34B9:  20 fb                      jr nz,l34b6h
34BB:  cd f8 3a                   call sub_3af8h
34BE:  dd 21 23                   ld ix,07823h
34C2:  2a a4 78                   ld hl,(PROGST)
34C5:  7d                         ld a,l
34C6:  cd 11 35                   call sub_3511h
34C9:  dd 77 00                   ld (ix+000h),a
34CC:  af                         xor a
34CD:  dd 77 01                   ld (ix+001h),a
34D0:  7c                         ld a,h
34D1:  cd 11 35                   call sub_3511h
34D4:  cd 8e 38                   call sub_388eh
34D7:  eb                         ex de,hl
34D8:  2a f9 78                   ld hl,(PROGEND)
34DB:  7d                         ld a,l
34DC:  cd 11 35                   call sub_3511h
34DF:  cd 8e 38                   call sub_388eh
34E2:  7c                         ld a,h
34E3:  cd 11 35                   call sub_3511h
34E6:  cd 8e 38                   call sub_388eh
34E9:  cd f8 3a                   call sub_3af8h
34EC:  1a            l34ech:      ld a,(de)
34ED:  13                         inc de
34EE:  cd 11 35                   call sub_3511h
34F1:  cd 8e 38      sub_34f1h:   call sub_388eh
34F4:  cd f8 3a                   call sub_3af8h
34F7:  df                         rst 18h
34F8:  20 f2                      jr nz,l34ech
34FA:  dd 7e 00                   ld a,(ix+000h)
34FD:  cd 11 35                   call sub_3511h
3500:  dd 7e 01                   ld a,(ix+001h)
3503:  cd 11 35                   call sub_3511h
3506:  06 14                      ld b,014h
3508:  af                         xor a
3509:  cd 11 35      l3509h:      call sub_3511h
350C:  10 fb                      djnz l3509h
350E:  e1                         pop hl
350F:  fb                         ei
3510:  c9                         ret
3511:  f5            sub_3511h:   push af
3512:  c5                         push bc
3513:  e5                         push hl
3514:  2e 08                      ld l,008h
3516:  67                         ld h,a
3517:  cd 42 35      l3517h:      call sub_3542h
351A:  cb 04                      rlc h
351C:  30 0d                      jr nc,l352bh
351E:  cd 42 35                   call sub_3542h
3521:  cd 42 35                   call sub_3542h
3524:  2d            l3524h:      dec l
3525:  20 f0                      jr nz,l3517h
3527:  e1                         pop hl
3528:  c1                         pop bc
3529:  f1                         pop af
352A:  c9                         ret
352B:  3a 3b 78      l352bh:      ld a,(CPIOREG)
352E:  f6 06                      or 006h
3530:  32 00 68                   ld (IOREG),a
3533:  06 99                      ld b,099h
3535:  10 fe         l3535h:      djnz l3535h
3537:  e6 f9                      and 0f9h
3539:  32 00 68                   ld (IOREG),a
353C:  06 99                      ld b,099h
353E:  10 fe         l353eh:      djnz l353eh
3540:  18 e2                      jr l3524h
3542:  3a 3b 78      sub_3542h:   ld a,(CPIOREG)
3545:  f6 06                      or 006h
3547:  32 00 68                   ld (IOREG),a
354A:  06 4c                      ld b,04ch
354C:  10 fe         l354ch:      djnz l354ch
354E:  e6 f9                      and 0f9h
3550:  32 00 68                   ld (IOREG),a
3553:  06 4c                      ld b,04ch
3555:  10 fe         l3555h:      djnz l3555h
3557:  c9                         ret
3558:  cd 8c 35      sub_3558h:   call sub_358ch
355B:  06 ff                      ld b,0ffh
355D:  3e 80         l355dh:      ld a,080h
355F:  cd 11 35                   call sub_3511h
3562:  cd e8 3a                   call sub_3ae8h
3565:  d8                         ret c
3566:  10 f5                      djnz l355dh
3568:  06 05                      ld b,005h
356A:  3e fe         l356ah:      ld a,0feh
356C:  cd 11 35                   call sub_3511h
356F:  cd e8 3a                   call sub_3ae8h
3572:  d8                         ret c
3573:  10 f5                      djnz l356ah
3575:  79                         ld a,c
3576:  cd 11 35                   call sub_3511h
3579:  cd e8 3a                   call sub_3ae8h
357C:  d8                         ret c
357D:  3a d6 7a                   ld a,(07ad6h)
3580:  47                         ld b,a
3581:  11 9d 7a                   ld de,07a9dh
3584:  1a            l3584h:      ld a,(de)
3585:  13                         inc de
3586:  cd 11 35                   call sub_3511h
3589:  10 f9                      djnz l3584h
358B:  c9                         ret
358C:  06 10         sub_358ch:   ld b,010h
358E:  11 9d 7a                   ld de,07a9dh
3591:  7e                         ld a,(hl)
3592:  fe 3a                      cp 03ah
3594:  28 12                      jr z,l35a8h
3596:  b7                         or a
3597:  28 0f                      jr z,l35a8h
3599:  cf                         rst 8
359A:  22 7e b7                   ld (0b77eh),hl
359D:  28 09                      jr z,l35a8h
359F:  23                         inc hl
35A0:  fe 22                      cp 022h
35A2:  28 04                      jr z,l35a8h
35A4:  12                         ld (de),a
35A5:  13                         inc de
35A6:  10 f3                      djnz $-11
35A8:  af            l35a8h:      xor a
35A9:  12                         ld (de),a
35AA:  3e 11                      ld a,011h
35AC:  90                         sub b
35AD:  32 d6 7a                   ld (07ad6h),a
35B0:  c9                         ret
35B1:  3a 4c 78      sub_35b1h:   ld a,(0784ch)
35B4:  b7                         or a
35B5:  c0                         ret nz
35B6:  3a 3b 78                   ld a,(CPIOREG)
35B9:  cb 5f                      bit 3,a
35BB:  28 0b                      jr z,l35c8h
35BD:  e6 f7                      and 0f7h
35BF:  32 3b 78                   ld (CPIOREG),a
35C2:  32 00 68                   ld (IOREG),a
35C5:  cd 92 32                   call l3292h
35C8:  21 ff 71      l35c8h:      ld hl,071ffh
35CB:  22 20 78                   ld (CURPOS),hl
35CE:  3e 1f                      ld a,01fh
35D0:  32 a6 78                   ld (078a6h),a
35D3:  3a e5 7a                   ld a,(07ae5h)
35D6:  fe 81                      cp 081h
35D8:  c0                         ret nz
35D9:  3d                         dec a
35DA:  32 e5 7a                   ld (07ae5h),a
35DD:  32 e6 7a                   ld (07ae6h),a
35E0:  c9                         ret
35E1:  21 42 38                   ld hl,l3842h
35E4:  cd f4 37                   call sub_37f4h
35E7:  cd f8 3a      l35e7h:      call sub_3af8h
35EA:  3a 00 68                   ld a,(IOREG)
35ED:  cb 77                      bit 6,a
35EF:  20 f6                      jr nz,l35e7h
35F1:  cd 8f 37      l35f1h:      call sub_378fh
35F4:  38 f1                      jr c,l35e7h
35F6:  cb 47                      bit 0,a
35F8:  28 f7                      jr z,l35f1h
35FA:  06 07                      ld b,007h
35FC:  cd 8f 37      l35fch:      call sub_378fh
35FF:  38 e6                      jr c,l35e7h
3601:  10 f9                      djnz l35fch
3603:  fe 80                      cp 080h
3605:  20 e0                      jr nz,l35e7h
3607:  cd 75 37      l3607h:      call sub_3775h
360A:  da e7 35                   jp c,l35e7h
360D:  fe 80                      cp 080h
360F:  28 f6                      jr z,l3607h
3611:  06 04                      ld b,004h
3613:  fe fe         l3613h:      cp 0feh
3615:  c2 e7 35                   jp nz,l35e7h
3618:  cd 75 37                   call sub_3775h
361B:  da e7 35                   jp c,l35e7h
361E:  10 f3                      djnz l3613h
3620:  cd 75 37                   call sub_3775h
3623:  32 d2 7a                   ld (07ad2h),a
3626:  21 b2 7a                   ld hl,07ab2h
3629:  06 12                      ld b,012h
362B:  cd 75 37      l362bh:      call sub_3775h
362E:  77                         ld (hl),a
362F:  b7                         or a
3630:  28 06                      jr z,l3638h
3632:  23                         inc hl
3633:  10 f6                      djnz l362bh
3635:  c3 e7 35                   jp l35e7h
3638:  21 5a 38      l3638h:      ld hl,l385ah
363B:  cd f4 37                   call sub_37f4h
363E:  21 b2 7a                   ld hl,07ab2h
3641:  cd 14 38                   call sub_3814h
3644:  21 b2 7a                   ld hl,07ab2h
3647:  11 9d 7a                   ld de,07a9dh
364A:  1a            l364ah:      ld a,(de)
364B:  b7                         or a
364C:  c8                         ret z
364D:  be                         cp (hl)
364E:  c2 e7 35                   jp nz,l35e7h
3651:  23                         inc hl
3652:  13                         inc de
3653:  18 f5                      jr l364ah
3655:  c9                         ret
3656:  e5                         push hl
3657:  21 39 78                   ld hl,07839h
365A:  cb b6                      res 6,(hl)
365C:  cb 9e                      res 3,(hl)
365E:  e1                         pop hl
365F:  f3            l365fh:      di
3660:  cd 8c 35                   call sub_358ch
3663:  e5                         push hl
3664:  cd b1 35                   call sub_35b1h
3667:  21 42 38      l3667h:      ld hl,l3842h
366A:  cd f4 37                   call sub_37f4h
366D:  cd e7 35      l366dh:      call l35e7h
3670:  3a d2 7a                   ld a,(07ad2h)
3673:  fe f2                      cp 0f2h
3675:  28 f6                      jr z,l366dh
3677:  21 60 38                   ld hl,l3860h
367A:  cd 04 38                   call sub_3804h
367D:  dd 21 23                   ld ix,07823h
3681:  cd 68 38                   call sub_3868h
3684:  da 11 37                   jp c,l3711h
3687:  e5                         push hl
3688:  ed 52                      sbc hl,de
368A:  da 11 37                   jp c,l3711h
368D:  ed 53 1e                   ld (0781eh),de
3691:  e5                         push hl
3692:  c1                         pop bc
3693:  e1                         pop hl
3694:  3a 39 78                   ld a,(07839h)
3697:  cb 5f                      bit 3,a
3699:  c2 42 37                   jp nz,l3742h
369C:  cd 73 3f      l369ch:      call sub_3f73h
369F:  12                         ld (de),a
36A0:  cd 8e 38                   call sub_388eh
36A3:  13                         inc de
36A4:  0b                         dec bc
36A5:  79                         ld a,c
36A6:  b0                         or b
36A7:  20 f3                      jr nz,l369ch
36A9:  cd 75 37                   call sub_3775h
36AC:  dd be 00                   cp (ix+000h)
36AF:  c2 11 37                   jp nz,l3711h
36B2:  cd 75 37                   call sub_3775h
36B5:  dd be 01                   cp (ix+001h)
36B8:  c2 11 37                   jp nz,l3711h
36BB:  22 f9 78                   ld (PROGEND),hl
36BE:  fb                         ei
36BF:  3e 0d                      ld a,00dh
36C1:  cd 8b 30                   call INTCHOUT
36C4:  3a d2 7a                   ld a,(07ad2h)
36C7:  fe f1                      cp 0f1h
36C9:  20 04                      jr nz,l36cfh
36CB:  2a 1e 78                   ld hl,(0781eh)
36CE:  e9                         jp (hl)
36CF:  21 29 19      l36cfh:      ld hl,l1929h
36D2:  cd a7 28                   call OUTSTR
36D5:  2a a4 78                   ld hl,(PROGST)
36D8:  e5                         push hl
36D9:  21 39 78                   ld hl,07839h
36DC:  cb 76                      bit 6,(hl)
36DE:  20 03                      jr nz,l36e3h
36E0:  c3 e8 1a                   jp l1ae8h
36E3:  21 39 78      l36e3h:      ld hl,07839h
36E6:  cb b6                      res 6,(hl)
36E8:  d1                         pop de
36E9:  cd fc 1a                   call sub_1afch
36EC:  cd b5 79                   call 079b5h
36EF:  cd 5d 1b                   call NWPRGST
36F2:  cd b8 79                   call 079b8h
36F5:  21 ff ff                   ld hl,0ffffh
36F8:  22 a2 78                   ld (078a2h),hl
36FB:  21 e8 79                   ld hl,BUFFIDX
36FE:  11 70 05                   ld de,l0570h
3701:  1a            l3701h:      ld a,(de)
3702:  77                         ld (hl),a
3703:  b7                         or a
3704:  28 04                      jr z,l370ah
3706:  23                         inc hl
3707:  13                         inc de
3708:  18 f7                      jr l3701h
370A:  21 e7 79      l370ah:      ld hl,079e7h
370D:  af                         xor a
370E:  c3 81 1a                   jp l1a81h
3711:  21 4a 38      l3711h:      ld hl,l384ah
3714:  fb                         ei
3715:  cd a7 28                   call OUTSTR
3718:  f3                         di
3719:  3a 4c 78                   ld a,(0784ch)
371C:  b7                         or a
371D:  c2 67 36                   jp nz,l3667h
3720:  21 ff 71                   ld hl,071ffh
3723:  22 20 78                   ld (CURPOS),hl
3726:  3e 1f                      ld a,01fh
3728:  32 a6 78                   ld (078a6h),a
372B:  c3 67 36                   jp l3667h
372E:  e5                         push hl
372F:  21 39 78                   ld hl,07839h
3732:  cb f6                      set 6,(hl)
3734:  e1                         pop hl
3735:  c3 5f 36                   jp l365fh
3738:  e5                         push hl
3739:  21 39 78                   ld hl,07839h
373C:  cb de                      set 3,(hl)
373E:  e1                         pop hl
373F:  c3 5f 36                   jp l365fh
3742:  eb            l3742h:      ex de,hl
3743:  cd 75 37      l3743h:      call sub_3775h
3746:  be                         cp (hl)
3747:  28 09                      jr z,l3752h
3749:  21 6c 37                   ld hl,l376ch
374C:  cd a7 28                   call OUTSTR
374F:  c3 83 01                   jp l0183h
3752:  23            l3752h:      inc hl
3753:  0b                         dec bc
3754:  79                         ld a,c
3755:  b0                         or b
3756:  20 eb                      jr nz,l3743h
3758:  21 39 78                   ld hl,07839h
375B:  cb 9e                      res 3,(hl)
375D:  21 6c 37                   ld hl,l376ch
3760:  cd a7 28                   call OUTSTR
3763:  21 80 03                   ld hl,00380h
3766:  cd a7 28                   call OUTSTR
3769:  c3 cf 36                   jp l36cfh
376C:  0d            l376ch:      dec c
376D:  56                         ld d,(hl)
376E:  45                         ld b,l
376F:  52                         ld d,d
3770:  49                         ld c,c
3771:  46                         ld b,(hl)
3772:  59                         ld e,c
3773:  20 00                      jr nz,sub_3775h
3775:  c5            sub_3775h:   push bc
3776:  d5                         push de
3777:  06 08                      ld b,008h
3779:  cd 8f 37      l3779h:      call sub_378fh
377C:  38 0e                      jr c,l378ch
377E:  10 f9                      djnz l3779h
3780:  d1                         pop de
3781:  c1                         pop bc
3782:  32 d3 7a                   ld (07ad3h),a
3785:  cd f8 3a                   call sub_3af8h
3788:  3a d3 7a                   ld a,(07ad3h)
378B:  c9                         ret
378C:  d1            l378ch:      pop de
378D:  c1                         pop bc
378E:  c9                         ret
378F:  c5            sub_378fh:   push bc
3790:  01 ff 07      l3790h:      ld bc,l07ffh
3793:  3a 00 68      l3793h:      ld a,(IOREG)
3796:  cb 77                      bit 6,a
3798:  28 08                      jr z,l37a2h
379A:  0b                         dec bc
379B:  79                         ld a,c
379C:  b0                         or b
379D:  20 f4                      jr nz,l3793h
379F:  c1                         pop bc
37A0:  37                         scf
37A1:  c9                         ret
37A2:  3a 00 68      l37a2h:      ld a,(IOREG)
37A5:  cb 77                      bit 6,a
37A7:  20 ea                      jr nz,l3793h
37A9:  3a 00 68                   ld a,(IOREG)
37AC:  cb 77                      bit 6,a
37AE:  20 e3                      jr nz,l3793h
37B0:  06 52                      ld b,052h
37B2:  10 fe         l37b2h:      djnz l37b2h
37B4:  3a 00 68                   ld a,(IOREG)
37B7:  cb 77                      bit 6,a
37B9:  20 09                      jr nz,l37c4h
37BB:  3a 00 68      l37bbh:      ld a,(IOREG)
37BE:  cb 77                      bit 6,a
37C0:  28 f9                      jr z,l37bbh
37C2:  18 cc                      jr l3790h
37C4:  06 5a         l37c4h:      ld b,05ah
37C6:  0e 00                      ld c,000h
37C8:  3a 00 68      l37c8h:      ld a,(IOREG)
37CB:  cb 77                      bit 6,a
37CD:  28 0b                      jr z,l37dah
37CF:  10 f7         l37cfh:      djnz l37c8h
37D1:  79            l37d1h:      ld a,c
37D2:  3d                         dec a
37D3:  1f                         rra
37D4:  cb 12                      rl d
37D6:  c1                         pop bc
37D7:  7a                         ld a,d
37D8:  b7                         or a
37D9:  c9                         ret
37DA:  3a 00 68      l37dah:      ld a,(IOREG)
37DD:  cb 77                      bit 6,a
37DF:  20 ee                      jr nz,l37cfh
37E1:  3a 00 68                   ld a,(IOREG)
37E4:  cb 77                      bit 6,a
37E6:  20 e7                      jr nz,l37cfh
37E8:  0c                         inc c
37E9:  3a 00 68      l37e9h:      ld a,(IOREG)
37EC:  cb 77                      bit 6,a
37EE:  20 df                      jr nz,l37cfh
37F0:  10 f7                      djnz l37e9h
37F2:  18 dd                      jr l37d1h
37F4:  3a 4c 78      sub_37f4h:   ld a,(0784ch)
37F7:  b7                         or a
37F8:  c0                         ret nz
37F9:  11 e0 71                   ld de,071e0h
37FC:  06 20                      ld b,020h
37FE:  cd f6 3e      l37feh:      call sub_3ef6h
3801:  13                         inc de
3802:  10 fa                      djnz l37feh
3804:  3a 4c 78      sub_3804h:   ld a,(0784ch)
3807:  b7                         or a
3808:  c0                         ret nz
3809:  cd 0e 3f                   call sub_3f0eh
380C:  7e            l380ch:      ld a,(hl)
380D:  b7                         or a
380E:  c8                         ret z
380F:  12                         ld (de),a
3810:  13                         inc de
3811:  23                         inc hl
3812:  18 f8                      jr l380ch
3814:  3a 4c 78      sub_3814h:   ld a,(0784ch)
3817:  b7                         or a
3818:  c0                         ret nz
3819:  11 e9 71                   ld de,071e9h
381C:  e5                         push hl
381D:  3a d2 7a                   ld a,(07ad2h)
3820:  e6 0f                      and 00fh
3822:  21 3f 38                   ld hl,l383fh
3825:  85                         add a,l
3826:  6f                         ld l,a
3827:  3e 00                      ld a,000h
3829:  8c                         adc a,h
382A:  67                         ld h,a
382B:  cd 21 3f                   call sub_3f21h
382E:  00                         nop
382F:  00                         nop
3830:  12                         ld (de),a
3831:  13                         inc de
3832:  13                         inc de
3833:  e1                         pop hl
3834:  7e            l3834h:      ld a,(hl)
3835:  b7                         or a
3836:  c8                         ret z
3837:  cd 33 3f                   call sub_3f33h
383A:  13                         inc de
383B:  23                         inc hl
383C:  18 f6                      jr l3834h
383E:  c9                         ret
383F:  14            l383fh:      inc d
3840:  02                         ld (bc),a
3841:  04                         inc b
3842:  57            l3842h:      ld d,a
3843:  41                         ld b,c
3844:  49                         ld c,c
3845:  54                         ld d,h
3846:  49                         ld c,c
3847:  4e                         ld c,(hl)
3848:  47                         ld b,a
3849:  00                         nop
384A:  0d            l384ah:      dec c
384B:  4c                         ld c,h
384C:  4f                         ld c,a
384D:  41                         ld b,c
384E:  44                         ld b,h
384F:  49                         ld c,c
3850:  4e                         ld c,(hl)
3851:  47                         ld b,a
3852:  20 45                      jr nz,l3899h
3854:  52                         ld d,d
3855:  52                         ld d,d
3856:  4f                         ld c,a
3857:  52                         ld d,d
3858:  0d                         dec c
3859:  00                         nop
385A:  46            l385ah:      ld b,(hl)
385B:  4f                         ld c,a
385C:  55                         ld d,l
385D:  4e                         ld c,(hl)
385E:  44                         ld b,h
385F:  00                         nop
3860:  4c            l3860h:      ld c,h
3861:  4f                         ld c,a
3862:  41                         ld b,c
3863:  44                         ld b,h
3864:  49                         ld c,c
3865:  4e                         ld c,(hl)
3866:  47                         ld b,a
3867:  00                         nop
3868:  cd 75 37      sub_3868h:   call sub_3775h
386B:  d8                         ret c
386C:  5f                         ld e,a
386D:  dd 77 00                   ld (ix+000h),a
3870:  af                         xor a
3871:  dd 77 01                   ld (ix+001h),a
3874:  cd 75 37                   call sub_3775h
3877:  d8                         ret c
3878:  57                         ld d,a
3879:  cd 8e 38                   call sub_388eh
387C:  cd 75 37                   call sub_3775h
387F:  d8                         ret c
3880:  6f                         ld l,a
3881:  cd 8e 38                   call sub_388eh
3884:  cd 75 37                   call sub_3775h
3887:  d8                         ret c
3888:  67                         ld h,a
3889:  cd 8e 38                   call sub_388eh
388C:  b7                         or a
388D:  c9                         ret
388E:  dd 86 00      sub_388eh:   add a,(ix+000h)
3891:  dd 77 00                   ld (ix+000h),a
3894:  3e 00                      ld a,000h
3896:  dd 8e 01                   adc a,(ix+001h)
3899:  dd 77 01      l3899h:      ld (ix+001h),a
389C:  c9                         ret
389D:  7e                         ld a,(hl)
389E:  fe 2c                      cp 02ch
38A0:  28 20                      jr z,l38c2h
38A2:  cd 1c 2b                   call sub_2b1ch
38A5:  b7                         or a
38A6:  ca 4a 1e                   jp z,l1e4ah
38A9:  fe 09                      cp 009h
38AB:  d2 4a 1e                   jp nc,l1e4ah
38AE:  3d                         dec a
38AF:  e6 07                      and 007h
38B1:  cb 27                      sla a
38B3:  cb 27                      sla a
38B5:  cb 27                      sla a
38B7:  cb 27                      sla a
38B9:  32 46 78                   ld (07846h),a
38BC:  7e                         ld a,(hl)
38BD:  b7                         or a
38BE:  c8                         ret z
38BF:  fe 3a                      cp 03ah
38C1:  c8                         ret z
38C2:  cf            l38c2h:      rst 8
38C3:  2c                         inc l
38C4:  cd 1c 2b                   call sub_2b1ch
38C7:  b7                         or a
38C8:  20 0c                      jr nz,l38d6h
38CA:  3a 3b 78                   ld a,(CPIOREG)
38CD:  cb a7                      res 4,a
38CF:  32 3b 78                   ld (CPIOREG),a
38D2:  32 00 68                   ld (IOREG),a
38D5:  c9                         ret
38D6:  fe 01         l38d6h:      cp 001h
38D8:  c2 4a 1e                   jp nz,l1e4ah
38DB:  3a 3b 78                   ld a,(CPIOREG)
38DE:  cb e7                      set 4,a
38E0:  32 3b 78                   ld (CPIOREG),a
38E3:  32 00 68                   ld (IOREG),a
38E6:  c9                         ret
38E7:  0e c0         l38e7h:      ld c,0c0h
38E9:  cb 09         l38e9h:      rrc c
38EB:  10 fc                      djnz l38e9h
38ED:  1a                         ld a,(de)
38EE:  a1                         and c
38EF:  47                         ld b,a
38F0:  79                         ld a,c
38F1:  cb 08         l38f1h:      rrc b
38F3:  cb 0f                      rrc a
38F5:  fe 03                      cp 003h
38F7:  20 f8                      jr nz,l38f1h
38F9:  78                         ld a,b
38FA:  3c                         inc a
38FB:  e5                         push hl
38FC:  cd 8d 09                   call sub_098dh
38FF:  e1                         pop hl
3900:  c3 0f 39                   jp l390fh
3903:  47            l3903h:      ld b,a
3904:  1a                         ld a,(de)
3905:  a1                         and c
3906:  12                         ld (de),a
3907:  f1                         pop af
3908:  b7                         or a
3909:  f2 0f 39                   jp p,l390fh
390C:  1a                         ld a,(de)
390D:  b0                         or b
390E:  12                         ld (de),a
390F:  cf            l390fh:      rst 8
3910:  29                         add hl,hl
3911:  c9                         ret
3912:  f3                         di
3913:  e5                         push hl
3914:  3a 3b 78                   ld a,(CPIOREG)
3917:  cb 5f                      bit 3,a
3919:  c2 8e 39                   jp nz,l398eh
391C:  21 00 70                   ld hl,VRAMBASE
391F:  0e 10                      ld c,010h
3921:  06 20         l3921h:      ld b,020h
3923:  7e            l3923h:      ld a,(hl)
3924:  b7                         or a
3925:  f2 2d 39                   jp p,l392dh
3928:  cd 73 2c                   call sub_2c73h
392B:  18 16                      jr l3943h
392D:  c3 44 3f      l392dh:      jp l3f44h
3930:  00                         nop
3931:  e6 3f         l3931h:      and 03fh
3933:  cd 56 39                   call sub_3956h
3936:  18 0b                      jr l3943h
3938:  e6 3f         l3938h:      and 03fh
393A:  cb 6f                      bit 5,a
393C:  20 02                      jr nz,l3940h
393E:  f6 40                      or 040h
3940:  cd ba 3a      l3940h:      call sub_3abah
3943:  23            l3943h:      inc hl
3944:  10 dd                      djnz l3923h
3946:  3e 0d                      ld a,00dh
3948:  cd ba 3a                   call sub_3abah
394B:  cd f8 3a                   call sub_3af8h
394E:  0d                         dec c
394F:  79                         ld a,c
3950:  b7                         or a
3951:  20 ce                      jr nz,l3921h
3953:  e1                         pop hl
3954:  fb                         ei
3955:  c9                         ret
3956:  f5            sub_3956h:   push af
3957:  c5                         push bc
3958:  d5                         push de
3959:  e5                         push hl
395A:  6f                         ld l,a
395B:  26 00                      ld h,000h
395D:  3e 08                      ld a,008h
395F:  cd ba 3a                   call sub_3abah
3962:  06 04                      ld b,004h
3964:  e5                         push hl
3965:  d1                         pop de
3966:  b7                         or a
3967:  ed 5a         l3967h:      adc hl,de
3969:  10 fc                      djnz l3967h
396B:  e5                         push hl
396C:  c1                         pop bc
396D:  21 94 3b                   ld hl,l3b94h
3970:  09                         add hl,bc
3971:  3e ff                      ld a,0ffh
3973:  cd ba 3a                   call sub_3abah
3976:  06 05                      ld b,005h
3978:  7e            l3978h:      ld a,(hl)
3979:  23                         inc hl
397A:  cd ba 3a                   call sub_3abah
397D:  10 f9                      djnz l3978h
397F:  3e ff                      ld a,0ffh
3981:  cd ba 3a                   call sub_3abah
3984:  3e 0f                      ld a,00fh
3986:  cd ba 3a                   call sub_3abah
3989:  e1                         pop hl
398A:  d1                         pop de
398B:  c1                         pop bc
398C:  f1                         pop af
398D:  c9                         ret
398E:  af            l398eh:      xor a
398F:  32 d6 7a                   ld (07ad6h),a
3992:  32 d6 7a                   ld (07ad6h),a
3995:  3e 08                      ld a,008h
3997:  cd ba 3a                   call sub_3abah
399A:  dd 21 d2                   ld ix,07ad2h
399E:  21 00 70                   ld hl,VRAMBASE
39A1:  11 00 00                   ld de,RESET
39A4:  0e c0         l39a4h:      ld c,0c0h
39A6:  cd f8 3a      l39a6h:      call sub_3af8h
39A9:  e5                         push hl
39AA:  cd c9 05                   call sub_05c9h
39AD:  06 03                      ld b,003h
39AF:  7e            l39afh:      ld a,(hl)
39B0:  a1                         and c
39B1:  c5                         push bc
39B2:  47                         ld b,a
39B3:  cb 08         l39b3h:      rrc b
39B5:  cb 08                      rrc b
39B7:  cb 09                      rrc c
39B9:  cb 09                      rrc c
39BB:  79                         ld a,c
39BC:  fe 03                      cp 003h
39BE:  c2 b3 39                   jp nz,l39b3h
39C1:  78                         ld a,b
39C2:  c1                         pop bc
39C3:  fe 03                      cp 003h
39C5:  28 0d                      jr z,l39d4h
39C7:  fe 02                      cp 002h
39C9:  28 0e                      jr z,l39d9h
39CB:  fe 01                      cp 001h
39CD:  28 10                      jr z,l39dfh
39CF:  11 00 00                   ld de,RESET
39D2:  18 0f                      jr l39e3h
39D4:  11 e0 e0      l39d4h:      ld de,0e0e0h
39D7:  18 0a                      jr l39e3h
39D9:  16 40         l39d9h:      ld d,040h
39DB:  1e a0                      ld e,0a0h
39DD:  18 04                      jr l39e3h
39DF:  16 a0         l39dfh:      ld d,0a0h
39E1:  1e 40                      ld e,040h
39E3:  dd 7e 00      l39e3h:      ld a,(ix+000h)
39E6:  cb 3f                      srl a
39E8:  cb 3f                      srl a
39EA:  cb 3f                      srl a
39EC:  e5                         push hl
39ED:  21 d3 7a                   ld hl,07ad3h
39F0:  cd 6a 3a                   call sub_3a6ah
39F3:  e1                         pop hl
39F4:  b2                         or d
39F5:  dd 77 00                   ld (ix+000h),a
39F8:  dd 7e 02                   ld a,(ix+002h)
39FB:  cb 3f                      srl a
39FD:  cb 3f                      srl a
39FF:  cb 3f                      srl a
3A01:  e5                         push hl
3A02:  21 d5 7a                   ld hl,07ad5h
3A05:  cd 6a 3a                   call sub_3a6ah
3A08:  e1                         pop hl
3A09:  b3                         or e
3A0A:  dd 77 02                   ld (ix+002h),a
3A0D:  3e 20                      ld a,020h
3A0F:  85                         add a,l
3A10:  6f                         ld l,a
3A11:  3e 00                      ld a,000h
3A13:  8c                         adc a,h
3A14:  67                         ld h,a
3A15:  10 50                      djnz l3a67h
3A17:  cd 73 3a                   call sub_3a73h
3A1A:  e1                         pop hl
3A1B:  cb 39                      srl c
3A1D:  cb 39                      srl c
3A1F:  79                         ld a,c
3A20:  b7                         or a
3A21:  20 83                      jr nz,l39a6h
3A23:  23                         inc hl
3A24:  7d                         ld a,l
3A25:  e6 1f                      and 01fh
3A27:  c2 a4 39                   jp nz,l39a4h
3A2A:  cd e2 3a                   call PRNCLRF
3A2D:  3a d6 7a                   ld a,(07ad6h)
3A30:  3c                         inc a
3A31:  fe 03                      cp 003h
3A33:  20 01                      jr nz,l3a36h
3A35:  af                         xor a
3A36:  32 d6 7a      l3a36h:      ld (07ad6h),a
3A39:  20 04                      jr nz,l3a3fh
3A3B:  3e 40                      ld a,040h
3A3D:  18 02                      jr l3a41h
3A3F:  3e 20         l3a3fh:      ld a,020h
3A41:  85            l3a41h:      add a,l
3A42:  6f                         ld l,a
3A43:  3e 00                      ld a,000h
3A45:  8c                         adc a,h
3A46:  67                         ld h,a
3A47:  fe 78                      cp 078h
3A49:  d2 5f 3a                   jp nc,l3a5fh
3A4C:  fe 77                      cp 077h
3A4E:  c2 a4 39                   jp nz,l39a4h
3A51:  7d                         ld a,l
3A52:  fe e0                      cp 0e0h
3A54:  da a4 39                   jp c,l39a4h
3A57:  3e ff                      ld a,0ffh
3A59:  32 d6 7a                   ld (07ad6h),a
3A5C:  c3 a4 39                   jp l39a4h
3A5F:  3e 0f         l3a5fh:      ld a,00fh
3A61:  cd ba 3a                   call sub_3abah
3A64:  e1                         pop hl
3A65:  fb                         ei
3A66:  c9                         ret
3A67:  c3 af 39      l3a67h:      jp l39afh
3A6A:  d2 70 3a      sub_3a6ah:   jp nc,l3a70h
3A6D:  cb c6                      set 0,(hl)
3A6F:  c9                         ret
3A70:  cb 86         l3a70h:      res 0,(hl)
3A72:  c9                         ret
3A73:  cd 85 3a      sub_3a73h:   call sub_3a85h
3A76:  dd 23                      inc ix
3A78:  dd 23                      inc ix
3A7A:  cd 85 3a                   call sub_3a85h
3A7D:  dd 2b                      dec ix
3A7F:  dd 2b                      dec ix
3A81:  cd 85 3a                   call sub_3a85h
3A84:  c9                         ret
3A85:  dd 7e 01      sub_3a85h:   ld a,(ix+001h)
3A88:  cb 0f                      rrc a
3A8A:  dd 7e 00                   ld a,(ix+000h)
3A8D:  f5                         push af
3A8E:  3a d6 7a                   ld a,(07ad6h)
3A91:  fe 02                      cp 002h
3A93:  28 1d                      jr z,l3ab2h
3A95:  fe 01                      cp 001h
3A97:  28 16                      jr z,l3aafh
3A99:  f1                         pop af
3A9A:  17                         rla
3A9B:  f5            l3a9bh:      push af
3A9C:  3a d6 7a                   ld a,(07ad6h)
3A9F:  fe ff                      cp 0ffh
3AA1:  20 05                      jr nz,l3aa8h
3AA3:  f1                         pop af
3AA4:  e6 07                      and 007h
3AA6:  18 01                      jr l3aa9h
3AA8:  f1            l3aa8h:      pop af
3AA9:  f6 80         l3aa9h:      or 080h
3AAB:  cd ba 3a                   call sub_3abah
3AAE:  c9                         ret
3AAF:  f1            l3aafh:      pop af
3AB0:  18 e9                      jr l3a9bh
3AB2:  f1            l3ab2h:      pop af
3AB3:  1f                         rra
3AB4:  18 e5                      jr l3a9bh
3AB6:  b7            sub_3ab6h:   or a
3AB7:  fa d8 3a                   jp m,l3ad8h
3ABA:  f5            sub_3abah:   push af
3ABB:  cd e8 3a      l3abbh:      call sub_3ae8h
3ABE:  d2 c4 3a                   jp nc,l3ac4h
3AC1:  f1                         pop af
3AC2:  37                         scf
3AC3:  c9                         ret
3AC4:  db 00         l3ac4h:      in a,(000h)
3AC6:  cb 47                      bit 0,a
3AC8:  20 f1                      jr nz,l3abbh
3ACA:  f1                         pop af
3ACB:  d3 0e                      out (00eh),a
3ACD:  d3 0d                      out (00dh),a
3ACF:  fe 0d                      cp 00dh
3AD1:  37                         scf
3AD2:  3f                         ccf
3AD3:  c0                         ret nz
3AD4:  3e 0a                      ld a,00ah
3AD6:  18 e2                      jr sub_3abah
3AD8:  cb 77         l3ad8h:      bit 6,a
3ADA:  ca 73 2c                   jp z,sub_2c73h
3ADD:  e6 3f                      and 03fh
3ADF:  c3 56 39                   jp sub_3956h
3AE2:  3e 0d         PRNCLRF:     ld a,00dh
3AE4:  cd ba 3a                   call sub_3abah
3AE7:  c9                         ret
3AE8:  b7            sub_3ae8h:   or a
3AE9:  3a fd 68                   ld a,(KBROW1)
3AEC:  cb 57                      bit 2,a
3AEE:  c0                         ret nz
3AEF:  3a df 68                   ld a,(KBROW5)
3AF2:  37                         scf
3AF3:  cb 57                      bit 2,a
3AF5:  c8                         ret z
3AF6:  3f                         ccf
3AF7:  c9                         ret
3AF8:  cd e8 3a      sub_3af8h:   call sub_3ae8h
3AFB:  d0                         ret nc
3AFC:  e1                         pop hl
3AFD:  e1                         pop hl
3AFE:  3a 39 78      l3afeh:      ld a,(07839h)
3B01:  e6 b7                      and 0b7h
3B03:  32 39 78                   ld (07839h),a
3B06:  3e 01                      ld a,001h
3B08:  fb                         ei
3B09:  c3 a0 1d                   jp sub_1da0h
3B0C:  3a 9c 78      l3b0ch:      ld a,(OUTDEV)
3B0F:  b7                         or a
3B10:  c2 64 21                   jp nz,l2164h
3B13:  3a af 7a      l3b13h:      ld a,(07aafh)
3B16:  b7                         or a
3B17:  20 fa                      jr nz,l3b13h
3B19:  c3 64 21                   jp l2164h
3B1C:  3a af 7a      sub_3b1ch:   ld a,(07aafh)
3B1F:  b7                         or a
3B20:  c0                         ret nz
3B21:  3a a6 78                   ld a,(078a6h)
3B24:  c9                         ret
3B25:  21 ef 68      sub_3b25h:   ld hl,KBROW4
3B28:  cb 66                      bit 4,(hl)
3B2A:  20 18                      jr nz,l3b44h
3B2C:  cd 48 3b                   call sub_3b48h
3B2F:  cb 66         l3b2fh:      bit 4,(hl)
3B31:  28 fc                      jr z,l3b2fh
3B33:  cd 48 3b                   call sub_3b48h
3B36:  cd f8 3a      l3b36h:      call sub_3af8h
3B39:  cb 66                      bit 4,(hl)
3B3B:  20 f9                      jr nz,l3b36h
3B3D:  cd 48 3b                   call sub_3b48h
3B40:  cb 66         l3b40h:      bit 4,(hl)
3B42:  28 fc                      jr z,l3b40h
3B44:  21 ff ff      l3b44h:      ld hl,0ffffh
3B47:  c9                         ret
3B48:  21 ff 07      sub_3b48h:   ld hl,l07ffh
3B4B:  2b            l3b4bh:      dec hl
3B4C:  7d                         ld a,l
3B4D:  b4                         or h
3B4E:  20 fb                      jr nz,l3b4bh
3B50:  21 ef 68                   ld hl,KBROW4
3B53:  c9                         ret
3B54:  cd 11 35      l3b54h:      call sub_3511h
3B57:  c9                         ret
3B58:  f3            sub_3b58h:   di
3B59:  23                         inc hl
3B5A:  0e f2                      ld c,0f2h
3B5C:  cd 58 35                   call sub_3558h
3B5F:  da fe 3a                   jp c,l3afeh
3B62:  2b                         dec hl
3B63:  cf                         rst 8
3B64:  22 cf 2c                   ld (l2ccfh),hl
3B67:  c9                         ret
3B68:  f3            sub_3b68h:   di
3B69:  23                         inc hl
3B6A:  cd 8c 35                   call sub_358ch
3B6D:  2b                         dec hl
3B6E:  cf                         rst 8
3B6F:  22 cf 2c                   ld (l2ccfh),hl
3B72:  e5                         push hl
3B73:  cd b1 35                   call sub_35b1h
3B76:  21 42 38                   ld hl,l3842h
3B79:  cd f4 37                   call sub_37f4h
3B7C:  cd e7 35      l3b7ch:      call l35e7h
3B7F:  3a d2 7a                   ld a,(07ad2h)
3B82:  fe f2                      cp 0f2h
3B84:  20 f6                      jr nz,l3b7ch
3B86:  e1                         pop hl
3B87:  c9                         ret
3B88:  cd 75 37      sub_3b88h:   call sub_3775h
3B8B:  fe 0d                      cp 00dh
3B8D:  c0                         ret nz
3B8E:  f5                         push af
3B8F:  cd f9 20                   call sub_20f9h
3B92:  f1                         pop af
3B93:  c9                         ret
3B94:  c1            l3b94h:      pop bc
3B95:  be                         cp (hl)
3B96:  a2                         and d
3B97:  ae                         xor (hl)
3B98:  b1                         or c
3B99:  83                         add a,e
	defb 0edh;next byte illegal after ed		;3b9a	ed 	. 

3B9B:  ee ed         l3b9ah:      xor 0edh
3B9D:  83                         add a,e
3B9E:  80                         add a,b
3B9F:  b6                         or (hl)
3BA0:  b6                         or (hl)
3BA1:  b6                         or (hl)
3BA2:  c1                         pop bc
3BA3:  c1                         pop bc
3BA4:  be                         cp (hl)
3BA5:  be                         cp (hl)
3BA6:  be                         cp (hl)
	defb 0ddh,080h,0beh	;illegal sequence		;3ba7	dd 80 be 	. . . 

3BAA:  be                         cp (hl)
3BAB:  be                         cp (hl)
3BAC:  c1                         pop bc
3BAD:  80                         add a,b
3BAE:  b6                         or (hl)
3BAF:  b6                         or (hl)
3BB0:  b6                         or (hl)
3BB1:  be                         cp (hl)
3BB2:  80                         add a,b
3BB3:  f6 f6                      or 0f6h
3BB5:  f6 fe                      or 0feh
3BB7:  c1                         pop bc
3BB8:  be                         cp (hl)
3BB9:  be                         cp (hl)
3BBA:  ae                         xor (hl)
3BBB:  8c                         adc a,h
3BBC:  80                         add a,b
3BBD:  f7                         rst 30h
3BBE:  f7                         rst 30h
3BBF:  f7                         rst 30h
3BC0:  80                         add a,b
3BC1:  ff                         rst 38h
3BC2:  be                         cp (hl)
3BC3:  80                         add a,b
3BC4:  be                         cp (hl)
3BC5:  ff                         rst 38h
3BC6:  df                         rst 18h
3BC7:  bf                         cp a
3BC8:  bf                         cp a
3BC9:  c0                         ret nz
3BCA:  fe 80                      cp 080h
3BCC:  f7                         rst 30h
3BCD:  eb                         ex de,hl
3BCE:  dd be 80                   cp (ix-080h)
3BD1:  bf                         cp a
3BD2:  bf                         cp a
3BD3:  bf                         cp a
3BD4:  bf                         cp a
3BD5:  80                         add a,b
	defb 0fdh,0f3h,0fdh	;illegal sequence		;3bd6	fd f3 fd 	. . . 

3BD9:  80                         add a,b
3BDA:  80                         add a,b
	defb 0fdh,0fbh,0f7h	;illegal sequence		;3bdb	fd fb f7 	. . . 

3BDE:  80                         add a,b
3BDF:  c1                         pop bc
3BE0:  be                         cp (hl)
3BE1:  be                         cp (hl)
3BE2:  be                         cp (hl)
3BE3:  c1                         pop bc
3BE4:  80                         add a,b
3BE5:  f6 f6                      or 0f6h
3BE7:  f6 f9                      or 0f9h
3BE9:  c1                         pop bc
3BEA:  be                         cp (hl)
3BEB:  ae                         xor (hl)
3BEC:  de a1                      sbc a,0a1h
3BEE:  80                         add a,b
3BEF:  f6 e6                      or 0e6h
3BF1:  d6 b9                      sub 0b9h
3BF3:  d9                         exx
3BF4:  b6                         or (hl)
3BF5:  b6                         or (hl)
3BF6:  b6                         or (hl)
3BF7:  cd fe fe                   call 0fefeh
3BFA:  80                         add a,b
3BFB:  fe fe                      cp 0feh
3BFD:  c0                         ret nz
3BFE:  bf                         cp a
3BFF:  bf                         cp a
3C00:  bf                         cp a
3C01:  c0                         ret nz
3C02:  f8                         ret m
3C03:  e7                         rst 20h
3C04:  9f                         sbc a,a
3C05:  e7                         rst 20h
3C06:  f8                         ret m
3C07:  80                         add a,b
3C08:  df                         rst 18h
3C09:  e7                         rst 20h
3C0A:  df                         rst 18h
3C0B:  80                         add a,b
3C0C:  9c                         sbc a,h
	defb 0edh;next byte illegal after ed		;3c0d	ed 	. 

3C0E:  f7                         rst 30h
3C0F:  eb                         ex de,hl
3C10:  9c                         sbc a,h
3C11:  fc fb 87                   call m,087fbh
3C14:  fb                         ei
3C15:  fc 9e ae                   call m,0ae9eh
3C18:  b6                         or (hl)
3C19:  ba                         cp d
3C1A:  bc                         cp h
3C1B:  ff                         rst 38h
3C1C:  80                         add a,b
3C1D:  be                         cp (hl)
3C1E:  be                         cp (hl)
3C1F:  ff                         rst 38h
	defb 0fdh,0fbh,0f7h	;illegal sequence		;3c20	fd fb f7 	. . . 

3C23:  ef                         rst 28h
3C24:  df                         rst 18h
3C25:  ff                         rst 38h
3C26:  be                         cp (hl)
3C27:  be                         cp (hl)
3C28:  80                         add a,b
3C29:  ff                         rst 38h
3C2A:  fb                         ei
	defb 0fdh,080h,0fdh	;illegal sequence		;3c2b	fd 80 fd 	. . . 

3C2E:  fb                         ei
3C2F:  f7                         rst 30h
3C30:  e3                         ex (sp),hl
3C31:  d6 f7                      sub 0f7h
3C33:  f7                         rst 30h
3C34:  ff                         rst 38h
3C35:  ff                         rst 38h
3C36:  ff                         rst 38h
3C37:  ff                         rst 38h
3C38:  ff                         rst 38h
3C39:  ff                         rst 38h
3C3A:  ff                         rst 38h
3C3B:  a0                         and b
3C3C:  ff                         rst 38h
3C3D:  ff                         rst 38h
3C3E:  ff                         rst 38h
3C3F:  f8                         ret m
3C40:  ff                         rst 38h
3C41:  f8                         ret m
3C42:  ff                         rst 38h
3C43:  eb                         ex de,hl
3C44:  80                         add a,b
3C45:  eb                         ex de,hl
3C46:  80                         add a,b
	defb 0edh;next byte illegal after ed		;3c47	ed 	. 

3C48:  db d6                      in a,(0d6h)
3C4A:  80                         add a,b
3C4B:  d6 ed                      sub 0edh
3C4D:  d9                         exx
3C4E:  e9                         jp (hl)
3C4F:  f7                         rst 30h
3C50:  cb cd                      set 1,l
3C52:  c9                         ret
3C53:  d6 a9                      sub 0a9h
3C55:  df                         rst 18h
3C56:  af                         xor a
3C57:  f7                         rst 30h
3C58:  f8                         ret m
3C59:  fc ff ff                   call m,0ffffh
3C5C:  ff                         rst 38h
3C5D:  e3                         ex (sp),hl
3C5E:  dd be ff                   cp (ix-001h)
3C61:  ff                         rst 38h
3C62:  be                         cp (hl)
3C63:  dd e3                      ex (sp),ix
3C65:  ff                         rst 38h
3C66:  d6 e3                      sub 0e3h
3C68:  80                         add a,b
3C69:  e3                         ex (sp),hl
3C6A:  d5                         push de
3C6B:  f7                         rst 30h
3C6C:  f7                         rst 30h
3C6D:  c1                         pop bc
3C6E:  f7                         rst 30h
3C6F:  f7                         rst 30h
3C70:  df                         rst 18h
3C71:  c7                         rst 0
3C72:  f7                         rst 30h
3C73:  ff                         rst 38h
3C74:  ff                         rst 38h
3C75:  f7                         rst 30h
3C76:  f7                         rst 30h
3C77:  f7                         rst 30h
3C78:  f7                         rst 30h
3C79:  f7                         rst 30h
3C7A:  ff                         rst 38h
3C7B:  9f                         sbc a,a
3C7C:  9f                         sbc a,a
3C7D:  ff                         rst 38h
3C7E:  ff                         rst 38h
3C7F:  df                         rst 18h
3C80:  ef                         rst 28h
3C81:  f7                         rst 30h
3C82:  fb                         ei
	defb 0fdh,0c1h,0aeh	;illegal sequence		;3c83	fd c1 ae 	. . . 

3C86:  b6                         or (hl)
3C87:  ba                         cp d
3C88:  c1                         pop bc
3C89:  ff                         rst 38h
3C8A:  bd                         cp l
3C8B:  80                         add a,b
3C8C:  bf                         cp a
3C8D:  ff                         rst 38h
3C8E:  9d                         sbc a,l
3C8F:  ae                         xor (hl)
3C90:  b6                         or (hl)
3C91:  ba                         cp d
3C92:  bd                         cp l
	defb 0ddh,0bbh,0bbh	;illegal sequence		;3c93	dd bb bb 	. . . 

3C96:  bb                         cp e
3C97:  c9                         ret
3C98:  e7                         rst 20h
3C99:  eb                         ex de,hl
	defb 0edh;next byte illegal after ed		;3c9a	ed 	. 

3C9B:  80                         add a,b
3C9C:  ef                         rst 28h
3C9D:  d8                         ret c
3C9E:  ba                         cp d
3C9F:  da da c6                   jp c,0c6dah
3CA2:  c1                         pop bc
3CA3:  b6                         or (hl)
3CA4:  b6                         or (hl)
3CA5:  b6                         or (hl)
3CA6:  cf                         rst 8
3CA7:  fc fe 86                   call m,086feh
3CAA:  fa fc c9                   jp m,0c9fch
3CAD:  b6                         or (hl)
3CAE:  b6                         or (hl)
3CAF:  b6                         or (hl)
3CB0:  c9                         ret
3CB1:  f9                         ld sp,hl
3CB2:  b6                         or (hl)
3CB3:  b6                         or (hl)
3CB4:  b6                         or (hl)
3CB5:  c1                         pop bc
3CB6:  ff                         rst 38h
3CB7:  c9                         ret
3CB8:  c9                         ret
3CB9:  ff                         rst 38h
3CBA:  ff                         rst 38h
3CBB:  bf                         cp a
3CBC:  c4 e4 ff                   call nz,0ffe4h
3CBF:  ff                         rst 38h
3CC0:  f7                         rst 30h
3CC1:  eb                         ex de,hl
	defb 0ddh,0deh,0deh	;illegal sequence		;3cc2	dd de de 	. . . 

3CC5:  eb                         ex de,hl
3CC6:  eb                         ex de,hl
3CC7:  eb                         ex de,hl
3CC8:  eb                         ex de,hl
3CC9:  eb                         ex de,hl
3CCA:  de de                      sbc a,0deh
	defb 0ddh,0ebh,0f7h	;illegal sequence		;3ccc	dd eb f7 	. . . 

	defb 0fdh,0feh,0a6h	;illegal sequence		;3ccf	fd fe a6 	. . . 

3CD2:  fa fd cb                   jp m,0cbfdh
3CD5:  3b                         dec sp
3CD6:  1c                         inc e
3CD7:  7e            l3cd7h:      ld a,(hl)
3CD8:  23                         inc hl
3CD9:  b7                         or a
3CDA:  f2 d7 3c                   jp p,l3cd7h
3CDD:  1d                         dec e
3CDE:  20 f7                      jr nz,l3cd7h
3CE0:  e6 7f                      and 07fh
3CE2:  cd 2a 03      l3ce2h:      call sub_032ah
3CE5:  7e                         ld a,(hl)
3CE6:  23                         inc hl
3CE7:  b7                         or a
3CE8:  f2 e2 3c                   jp p,l3ce2h
3CEB:  c9                         ret
3CEC:  ce 45         l3cech:      adc a,045h
3CEE:  58                         ld e,b
3CEF:  54                         ld d,h
3CF0:  20 57                      jr nz,l3d49h
3CF2:  49                         ld c,c
3CF3:  54                         ld d,h
3CF4:  48                         ld c,b
3CF5:  4f                         ld c,a
3CF6:  55                         ld d,l
3CF7:  54                         ld d,h
3CF8:  20 46                      jr nz,l3d40h
3CFA:  4f                         ld c,a
3CFB:  52                         ld d,d
3CFC:  d3 59                      out (059h),a
3CFE:  4e                         ld c,(hl)
3CFF:  54                         ld d,h
3D00:  41                         ld b,c
3D01:  58                         ld e,b
3D02:  d2 45 54                   jp nc,05445h
3D05:  27                         daa
3D06:  4e                         ld c,(hl)
3D07:  20 57                      jr nz,l3d60h
3D09:  49                         ld c,c
3D0A:  54                         ld d,h
3D0B:  48                         ld c,b
3D0C:  4f                         ld c,a
3D0D:  55                         ld d,l
3D0E:  54                         ld d,h
3D0F:  20 47                      jr nz,l3d58h
3D11:  4f                         ld c,a
3D12:  53                         ld d,e
3D13:  55                         ld d,l
3D14:  42                         ld b,d
3D15:  cf                         rst 8
3D16:  55                         ld d,l
3D17:  54                         ld d,h
3D18:  20 4f                      jr nz,l3d69h
3D1A:  46                         ld b,(hl)
3D1B:  20 44                      jr nz,$+70
3D1D:  41                         ld b,c
3D1E:  54                         ld d,h
3D1F:  41                         ld b,c
3D20:  c6 55                      add a,055h
3D22:  4e                         ld c,(hl)
3D23:  43                         ld b,e
3D24:  54                         ld d,h
3D25:  49                         ld c,c
3D26:  4f                         ld c,a
3D27:  4e                         ld c,(hl)
3D28:  20 43                      jr nz,l3d6dh
3D2A:  4f                         ld c,a
3D2B:  44                         ld b,h
3D2C:  45                         ld b,l
3D2D:  cf                         rst 8
3D2E:  56                         ld d,(hl)
3D2F:  45                         ld b,l
3D30:  52                         ld d,d
3D31:  46                         ld b,(hl)
3D32:  4c                         ld c,h
3D33:  4f                         ld c,a
3D34:  57                         ld d,a
3D35:  cf                         rst 8
3D36:  55                         ld d,l
3D37:  54                         ld d,h
3D38:  20 4f                      jr nz,l3d89h
3D3A:  46                         ld b,(hl)
3D3B:  20 4d                      jr nz,l3d8ah
3D3D:  45                         ld b,l
3D3E:  4d                         ld c,l
3D3F:  4f                         ld c,a
3D40:  52            l3d40h:      ld d,d
3D41:  59                         ld e,c
3D42:  d5                         push de
3D43:  4e                         ld c,(hl)
3D44:  44                         ld b,h
3D45:  45                         ld b,l
3D46:  46                         ld b,(hl)
3D47:  27                         daa
3D48:  44                         ld b,h
3D49:  20 53         l3d49h:      jr nz,l3d9eh
3D4B:  54                         ld d,h
3D4C:  41                         ld b,c
3D4D:  54                         ld d,h
3D4E:  45                         ld b,l
3D4F:  4d                         ld c,l
3D50:  45                         ld b,l
3D51:  4e                         ld c,(hl)
3D52:  54                         ld d,h
3D53:  c2 41 44                   jp nz,04441h
3D56:  20 53                      jr nz,$+85
3D58:  55            l3d58h:      ld d,l
3D59:  42                         ld b,d
3D5A:  53                         ld d,e
3D5B:  43                         ld b,e
3D5C:  52                         ld d,d
3D5D:  49                         ld c,c
3D5E:  50                         ld d,b
3D5F:  54                         ld d,h
3D60:  d2 45 44      l3d60h:      jp nc,04445h
3D63:  49                         ld c,c
3D64:  4d                         ld c,l
3D65:  27                         daa
3D66:  44                         ld b,h
3D67:  20 41                      jr nz,l3daah
3D69:  52            l3d69h:      ld d,d
3D6A:  52                         ld d,d
3D6B:  41                         ld b,c
3D6C:  59                         ld e,c
3D6D:  c4 49 56      l3d6dh:      call nz,05649h
3D70:  49                         ld c,c
3D71:  53                         ld d,e
3D72:  49                         ld c,c
3D73:  4f                         ld c,a
3D74:  4e                         ld c,(hl)
3D75:  20 42                      jr nz,l3db9h
3D77:  59                         ld e,c
3D78:  20 5a                      jr nz,l3dd4h
3D7A:  45                         ld b,l
3D7B:  52                         ld d,d
3D7C:  4f                         ld c,a
3D7D:  c9                         ret
3D7E:  4c                         ld c,h
3D7F:  4c                         ld c,h
3D80:  45                         ld b,l
3D81:  47                         ld b,a
3D82:  41                         ld b,c
3D83:  4c                         ld c,h
3D84:  20 44                      jr nz,l3dcah
3D86:  49                         ld c,c
3D87:  52                         ld d,d
3D88:  45                         ld b,l
3D89:  43            l3d89h:      ld b,e
3D8A:  54            l3d8ah:      ld d,h
3D8B:  d4 59 50                   call nc,05059h
3D8E:  45                         ld b,l
3D8F:  20 4d                      jr nz,l3ddeh
3D91:  49                         ld c,c
3D92:  53                         ld d,e
3D93:  4d                         ld c,l
3D94:  41                         ld b,c
3D95:  54                         ld d,h
3D96:  43                         ld b,e
3D97:  48                         ld c,b
3D98:  cf                         rst 8
3D99:  55                         ld d,l
3D9A:  54                         ld d,h
3D9B:  20 4f                      jr nz,l3dech
3D9D:  46                         ld b,(hl)
3D9E:  20 53         l3d9eh:      jr nz,$+85
3DA0:  50                         ld d,b
3DA1:  41                         ld b,c
3DA2:  43                         ld b,e
3DA3:  45                         ld b,l
3DA4:  d3 54                      out (054h),a
3DA6:  52                         ld d,d
3DA7:  49                         ld c,c
3DA8:  4e                         ld c,(hl)
3DA9:  47                         ld b,a
3DAA:  20 54         l3daah:      jr nz,l3e00h
3DAC:  4f                         ld c,a
3DAD:  4f                         ld c,a
3DAE:  20 4c                      jr nz,l3dfch
3DB0:  4f                         ld c,a
3DB1:  4e                         ld c,(hl)
3DB2:  47                         ld b,a
3DB3:  c6 4f                      add a,04fh
3DB5:  52                         ld d,d
3DB6:  4d                         ld c,l
3DB7:  55                         ld d,l
3DB8:  4c                         ld c,h
3DB9:  41            l3db9h:      ld b,c
3DBA:  20 54                      jr nz,$+86
3DBC:  4f                         ld c,a
3DBD:  4f                         ld c,a
3DBE:  20 43                      jr nz,$+69
3DC0:  4f                         ld c,a
3DC1:  4d                         ld c,l
3DC2:  50                         ld d,b
3DC3:  4c                         ld c,h
3DC4:  45                         ld b,l
3DC5:  58                         ld e,b
3DC6:  c3 41 4e                   jp 04e41h
3DC9:  27                         daa
3DCA:  54            l3dcah:      ld d,h
3DCB:  20 43                      jr nz,$+69
3DCD:  4f                         ld c,a
3DCE:  4e                         ld c,(hl)
3DCF:  54                         ld d,h
3DD0:  ce 4f                      adc a,04fh
3DD2:  20 52                      jr nz,l3e26h
3DD4:  45            l3dd4h:      ld b,l
3DD5:  53                         ld d,e
3DD6:  55                         ld d,l
3DD7:  4d                         ld c,l
3DD8:  45                         ld b,l
3DD9:  d2 45 53                   jp nc,05345h
3DDC:  55                         ld d,l
3DDD:  4d                         ld c,l
3DDE:  45            l3ddeh:      ld b,l
3DDF:  20 57                      jr nz,$+89
3DE1:  49                         ld c,c
3DE2:  54                         ld d,h
3DE3:  48                         ld c,b
3DE4:  4f                         ld c,a
3DE5:  55                         ld d,l
3DE6:  54                         ld d,h
3DE7:  d5                         push de
3DE8:  4e                         ld c,(hl)
3DE9:  50                         ld d,b
3DEA:  52                         ld d,d
3DEB:  49                         ld c,c
3DEC:  4e            l3dech:      ld c,(hl)
3DED:  54                         ld d,h
3DEE:  41                         ld b,c
3DEF:  42                         ld b,d
3DF0:  4c                         ld c,h
3DF1:  45                         ld b,l
3DF2:  cd 49 53                   call 05349h
3DF5:  53                         ld d,e
3DF6:  49                         ld c,c
3DF7:  4e                         ld c,(hl)
3DF8:  47                         ld b,a
3DF9:  20 4f                      jr nz,l3e4ah
3DFB:  50                         ld d,b
3DFC:  45            l3dfch:      ld b,l
3DFD:  52                         ld d,d
3DFE:  41                         ld b,c
3DFF:  4e                         ld c,(hl)
3E00:  44            l3e00h:      ld b,h
3E01:  c2 41 44                   jp nz,04441h
3E04:  20 46                      jr nz,$+72
3E06:  49                         ld c,c
3E07:  4c                         ld c,h
3E08:  45                         ld b,l
3E09:  20 44                      jr nz,l3e4fh
3E0B:  41                         ld b,c
3E0C:  54                         ld d,h
3E0D:  41                         ld b,c
3E0E:  c4 49 53                   call nz,05349h
3E11:  4b                         ld c,e
3E12:  20 43                      jr nz,l3e57h
3E14:  4f                         ld c,a
3E15:  4d                         ld c,l
3E16:  4d                         ld c,l
3E17:  41                         ld b,c
3E18:  4e                         ld c,(hl)
3E19:  44                         ld b,h
3E1A:  3f            l3e1ah:      ccf
3E1B:  53                         ld d,e
3E1C:  59                         ld e,c
3E1D:  4e                         ld c,(hl)
3E1E:  54                         ld d,h
3E1F:  41                         ld b,c
3E20:  58                         ld e,b
3E21:  20 45                      jr nz,$+71
3E23:  52                         ld d,d
3E24:  52                         ld d,d
3E25:  4f                         ld c,a
3E26:  52            l3e26h:      ld d,d
3E27:  0d                         dec c
3E28:  00                         nop
3E29:  7e            l3e29h:      ld a,(hl)
3E2A:  b7                         or a
3E2B:  20 07                      jr nz,l3e34h
3E2D:  3e 20                      ld a,020h
3E2F:  77                         ld (hl),a
3E30:  23                         inc hl
3E31:  af                         xor a
3E32:  77                         ld (hl),a
3E33:  2b                         dec hl
3E34:  2b            l3e34h:      dec hl
3E35:  f1                         pop af
3E36:  c9                         ret
3E37:  32 7d 78      l3e37h:      ld (LOCIHAND),a
3E3A:  3e 10                      ld a,010h
3E3C:  32 46 78                   ld (07846h),a
3E3F:  c9                         ret
3E40:  7e            l3e40h:      ld a,(hl)
3E41:  cb 77                      bit 6,a
3E43:  28 05                      jr z,l3e4ah
3E45:  fe 80                      cp 080h
3E47:  da 5d 3e                   jp c,l3e5dh
3E4A:  c1            l3e4ah:      pop bc
3E4B:  11 53 3e                   ld de,l3e53h
3E4E:  d5                         push de
3E4F:  c5            l3e4fh:      push bc
3E50:  c3 02 05                   jp l0502h
3E53:  d8            l3e53h:      ret c
3E54:  21 1a 3e                   ld hl,l3e1ah
3E57:  cd a7 28      l3e57h:      call OUTSTR
3E5A:  c3 e3 03                   jp l03e3h
3E5D:  fe 62         l3e5dh:      cp 062h
3E5F:  20 39                      jr nz,l3e9ah
3E61:  e6 bf                      and 0bfh
3E63:  12                         ld (de),a
3E64:  23                         inc hl
3E65:  13                         inc de
3E66:  05                         dec b
3E67:  ca ee 04                   jp z,l04eeh
3E6A:  7e            l3e6ah:      ld a,(hl)
3E6B:  cb 7f                      bit 7,a
3E6D:  20 06                      jr nz,l3e75h
3E6F:  cb 77                      bit 6,a
3E71:  20 0c                      jr nz,l3e7fh
3E73:  18 06                      jr l3e7bh
3E75:  e6 8f         l3e75h:      and 08fh
3E77:  f6 80                      or 080h
3E79:  18 17                      jr l3e92h
3E7B:  f6 c0         l3e7bh:      or 0c0h
3E7D:  18 13                      jr l3e92h
3E7F:  fe 62         l3e7fh:      cp 062h
3E81:  20 09                      jr nz,l3e8ch
3E83:  e5                         push hl
3E84:  21 39 78                   ld hl,07839h
3E87:  cb 66                      bit 4,(hl)
3E89:  e1                         pop hl
3E8A:  28 0e                      jr z,l3e9ah
3E8C:  cb 6f         l3e8ch:      bit 5,a
3E8E:  28 02                      jr z,l3e92h
3E90:  e6 bf                      and 0bfh
3E92:  12            l3e92h:      ld (de),a
3E93:  23                         inc hl
3E94:  13                         inc de
3E95:  10 d3                      djnz l3e6ah
3E97:  c3 ee 04                   jp l04eeh
3E9A:  cb 6f         l3e9ah:      bit 5,a
3E9C:  28 02                      jr z,l3ea0h
3E9E:  e6 bf                      and 0bfh
3EA0:  12            l3ea0h:      ld (de),a
3EA1:  23                         inc hl
3EA2:  13                         inc de
3EA3:  10 9b                      djnz l3e40h
3EA5:  c3 ee 04                   jp l04eeh
3EA8:  3a 18 78      l3ea8h:      ld a,(07818h)
3EAB:  b7                         or a
3EAC:  c2 b8 04                   jp nz,l04b8h
3EAF:  c3 6a 3e                   jp l3e6ah
3EB2:  3a 18 78      l3eb2h:      ld a,(07818h)
3EB5:  b7                         or a
3EB6:  20 03                      jr nz,l3ebbh
3EB8:  cb b6                      res 6,(hl)
3EBA:  c9                         ret
3EBB:  cb f6         l3ebbh:      set 6,(hl)
3EBD:  c9                         ret
3EBE:  3a 18 78      sub_3ebeh:   ld a,(07818h)
3EC1:  b7                         or a
3EC2:  3e 20                      ld a,020h
3EC4:  20 02                      jr nz,l3ec8h
3EC6:  f6 40                      or 040h
3EC8:  77            l3ec8h:      ld (hl),a
3EC9:  c9                         ret
3ECA:  f5            l3ecah:      push af
3ECB:  3a 18 78                   ld a,(07818h)
3ECE:  b7                         or a
3ECF:  28 07                      jr z,l3ed8h
3ED1:  f1                         pop af
3ED2:  e6 3f                      and 03fh
3ED4:  e5                         push hl
3ED5:  c3 ab 31                   jp l31abh
3ED8:  f1            l3ed8h:      pop af
3ED9:  f6 40                      or 040h
3EDB:  e5                         push hl
3EDC:  21 38 78                   ld hl,07838h
3EDF:  cb 4e                      bit 1,(hl)
3EE1:  e1                         pop hl
3EE2:  28 02                      jr z,l3ee6h
3EE4:  e6 bf                      and 0bfh
3EE6:  c3 b5 31      l3ee6h:      jp l31b5h
3EE9:  3a 18 78      sub_3ee9h:   ld a,(07818h)
3EEC:  b7                         or a
3EED:  7e                         ld a,(hl)
3EEE:  20 03                      jr nz,l3ef3h
3EF0:  fe 60                      cp 060h
3EF2:  c9                         ret
3EF3:  fe 20         l3ef3h:      cp 020h
3EF5:  c9                         ret
3EF6:  3a 18 78      sub_3ef6h:   ld a,(07818h)
3EF9:  b7                         or a
3EFA:  3e 20                      ld a,020h
3EFC:  20 02                      jr nz,l3f00h
3EFE:  f6 40                      or 040h
3F00:  12            l3f00h:      ld (de),a
3F01:  c9                         ret
3F02:  06 20         sub_3f02h:   ld b,020h
3F04:  3a 18 78                   ld a,(07818h)
3F07:  b7                         or a
3F08:  3e 20                      ld a,020h
3F0A:  c0                         ret nz
3F0B:  f6 40                      or 040h
3F0D:  c9                         ret
3F0E:  11 e0 71      sub_3f0eh:   ld de,071e0h
3F11:  3a 18 78                   ld a,(07818h)
3F14:  b7                         or a
3F15:  c0                         ret nz
3F16:  f1                         pop af
3F17:  7e            l3f17h:      ld a,(hl)
3F18:  b7                         or a
3F19:  c8                         ret z
3F1A:  cb b7                      res 6,a
3F1C:  12                         ld (de),a
3F1D:  13                         inc de
3F1E:  23                         inc hl
3F1F:  18 f6                      jr l3f17h
3F21:  3a 18 78      sub_3f21h:   ld a,(07818h)
3F24:  b7                         or a
3F25:  7e                         ld a,(hl)
3F26:  20 07                      jr nz,l3f2fh
3F28:  cb f7                      set 6,a
3F2A:  12                         ld (de),a
3F2B:  13                         inc de
3F2C:  3e 7a                      ld a,07ah
3F2E:  c9                         ret
3F2F:  12            l3f2fh:      ld (de),a
3F30:  3e 3a                      ld a,03ah
3F32:  c9                         ret
3F33:  f5            sub_3f33h:   push af
3F34:  3a 18 78                   ld a,(07818h)
3F37:  b7                         or a
3F38:  20 05                      jr nz,l3f3fh
3F3A:  f1                         pop af
3F3B:  f6 40                      or 040h
3F3D:  12                         ld (de),a
3F3E:  c9                         ret
3F3F:  f1            l3f3fh:      pop af
3F40:  e6 3f                      and 03fh
3F42:  12                         ld (de),a
3F43:  c9                         ret
3F44:  f5            l3f44h:      push af
3F45:  3a 18 78                   ld a,(07818h)
3F48:  b7                         or a
3F49:  20 09                      jr nz,l3f54h
3F4B:  f1                         pop af
3F4C:  cb 77                      bit 6,a
3F4E:  c2 38 39                   jp nz,l3938h
3F51:  c3 31 39                   jp l3931h
3F54:  f1            l3f54h:      pop af
3F55:  cb 77                      bit 6,a
3F57:  ca 38 39                   jp z,l3938h
3F5A:  c3 31 39                   jp l3931h
3F5D:  c3 31 39                   jp l3931h
3F60:  f5            l3f60h:      push af
3F61:  3a 18 78                   ld a,(07818h)
3F64:  b7                         or a
3F65:  20 06                      jr nz,l3f6dh
3F67:  f1                         pop af
3F68:  e6 3f                      and 03fh
3F6A:  c3 54 31                   jp l3154h
3F6D:  f1            l3f6dh:      pop af
3F6E:  e6 7f                      and 07fh
3F70:  c3 54 31                   jp l3154h
3F73:  cd 75 37      sub_3f73h:   call sub_3775h
3F76:  d0                         ret nc
3F77:  e1                         pop hl
3F78:  c3 11 37                   jp l3711h
3F7B:  3a 19 78      sub_3f7bh:   ld a,(07819h)
3F7E:  47                         ld b,a
3F7F:  3a 18 78                   ld a,(07818h)
3F82:  b8                         cp b
3F83:  ca e8 30                   jp z,l30e8h
3F86:  32 19 78                   ld (07819h),a
3F89:  21 00 70                   ld hl,VRAMBASE
3F8C:  01 00 02                   ld bc,l0200h
3F8F:  7e            l3f8fh:      ld a,(hl)
3F90:  b7                         or a
3F91:  fa 97 3f                   jp m,l3f97h
3F94:  ee 40                      xor 040h
3F96:  77                         ld (hl),a
3F97:  23            l3f97h:      inc hl
3F98:  0b                         dec bc
3F99:  78                         ld a,b
3F9A:  b1                         or c
3F9B:  20 f2                      jr nz,l3f8fh
3F9D:  c3 e8 30                   jp l30e8h
3FA0:  3a fd 68      sub_3fa0h:   ld a,(KBROW1)
3FA3:  cb 57                      bit 2,a
3FA5:  3e 20                      ld a,020h
3FA7:  20 08                      jr nz,l3fb1h
3FA9:  f6 40                      or 040h
3FAB:  32 18 78                   ld (07818h),a
3FAE:  32 19 78                   ld (07819h),a
3FB1:  32 3c 78      l3fb1h:      ld (0783ch),a
3FB4:  c3 c9 01                   jp CLRSCR
3FB7:  00                         nop
3FB8:  00                         nop
3FB9:  00                         nop
3FBA:  00                         nop
3FBB:  00                         nop
3FBC:  00                         nop
3FBD:  00                         nop
3FBE:  00                         nop
3FBF:  00                         nop
3FC0:  00                         nop
3FC1:  00                         nop
3FC2:  00                         nop
3FC3:  00                         nop
3FC4:  00                         nop
3FC5:  00                         nop
3FC6:  00                         nop
3FC7:  00                         nop
3FC8:  00                         nop
3FC9:  00                         nop
3FCA:  00                         nop
3FCB:  00                         nop
3FCC:  00                         nop
3FCD:  00                         nop
3FCE:  00                         nop
3FCF:  00                         nop
3FD0:  00                         nop
3FD1:  00                         nop
3FD2:  00                         nop
3FD3:  00                         nop
3FD4:  00                         nop
3FD5:  00                         nop
3FD6:  00                         nop
3FD7:  00                         nop
3FD8:  00                         nop
3FD9:  00                         nop
3FDA:  00                         nop
3FDB:  00                         nop
3FDC:  00                         nop
3FDD:  00                         nop
3FDE:  00                         nop
3FDF:  00                         nop
3FE0:  00                         nop
3FE1:  00                         nop
3FE2:  00                         nop
3FE3:  00                         nop
3FE4:  00                         nop
3FE5:  00                         nop
3FE6:  00                         nop
3FE7:  00                         nop
3FE8:  00                         nop
3FE9:  00                         nop
3FEA:  00                         nop
3FEB:  00                         nop
3FEC:  00                         nop
3FED:  00                         nop
3FEE:  00                         nop
3FEF:  00                         nop
3FF0:  ff                         rst 38h
3FF1:  ff                         rst 38h
3FF2:  ff                         rst 38h
3FF3:  ff                         rst 38h
3FF4:  ff                         rst 38h
3FF5:  ff                         rst 38h
3FF6:  ff                         rst 38h
3FF7:  ff                         rst 38h
3FF8:  ff                         rst 38h
3FF9:  ff                         rst 38h
3FFA:  ff                         rst 38h
3FFB:  ff                         rst 38h
3FFC:  ff                         rst 38h
3FFD:  ff                         rst 38h
3FFE:  ff                         rst 38h
3FFF:  ff                         rst 38h
