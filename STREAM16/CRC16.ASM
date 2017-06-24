IDEAL
; This CRC-16 routine and tables were converted from C code discovered
; in rzsz.arc by Chuck Forsberg.  The comments there are:
;
; crctab calculated by Mark G. Mendel, Network Systems Corporation
;
; updcrc macro derived from article Copyright (C) 1986 Stephen Satchell.
;  NOTE: First srgument must be in range 0 to 255.
;        Second argument is referenced twice.
;
; Programmers may incorporate any or all code into their programs,
; giving proper credit within the source. Publication of the
; source routines is permitted so long as proper credit is given
; to Stephen Satchell, Satchell Evaluations and Chuck Forsberg,
; Omen Technology.
;
; <End of rzsz comments>
;
; The C macro is:
;
; #define updcrc(cp, crc) ( crctab[((crc >> 8) & 255)] ^ (crc << 8) ^ cp)
;
; This routine appears to compute the 16 bit CRC used by XModem and its
; derivatives.  For transmission, the CRC value should start with 0 and,
; after the block crc is computed, the value should be updated with two
; nulls and transmitted high-order byte first.  The computed CRC value
; on the received block + 2 byte CRC should be zero.
c:\dosauto
;
; This TASM conversion done by:
;
;   Edwin T. Floyd [76067h747]
;   #9 Adams Park Ct.
;   Columbush GA 31909
;   404-576-3305 (work)
;   404-322-0076 (home)
;
; Borland's Turbo Assembler - TASM is required to assemble this program.
;
SEGMENT  code BYTE PUBLIC
         ASSUME cs:code
;            0
crctab   dw     00000h, 01021h, 02042h, 03063h, 04084h, 050a5h, 060c6h, 070e7h
         dw     08108h, 09129h, 0a14ah, 0b16bh, 0c18ch, 0d1adh, 0e1ceh, 0f1efh
;            1
         dw     01231h, 00210h, 03273h, 02252h, 052b5h, 04294h, 072f7h, 062d6h
         dw     09339h, 08318h, 0b37bh, 0a35ah, 0d3bdh, 0c39ch, 0f3ffh, 0e3deh
;            2
         dw     02462h, 03443h, 00420h, 01401h, 064e6h, 074c7h, 044a4h, 05485h
         dw     0a56ah, 0b54bh, 08528h, 09509h, 0e5eeh, 0f5cfh, 0c5ach, 0d58dh
;            3
         dw     03653h, 02672h, 01611h, 00630h, 076d7h, 066f6h, 05695h, 046b4h
         dw     0b75bh, 0a77ah, 09719h, 08738h, 0f7dfh, 0e7feh, 0d79dh, 0c7bch
;            4
         dw     048c4h, 058e5h, 06886h, 078a7h, 00840h, 01861h, 02802h, 03823h
         dw     0c9cch, 0d9edh, 0e98eh, 0f9afh, 08948h, 09969h, 0a90ah, 0b92bh
;            5
         dw     05af5h, 04ad4h, 07ab7h, 06a96h, 01a71h, 00a50h, 03a33h, 02a12h
         dw     0dbfdh, 0cbdch, 0fbbfh, 0eb9eh, 09b79h, 08b58h, 0bb3bh, 0ab1ah
;            6
         dw     06ca6h, 07c87h, 04ce4h, 05cc5h, 02c22h, 03c03h, 00c60h, 01c41h
         dw     0edaeh, 0fd8fh, 0cdech, 0ddcdh, 0ad2ah, 0bd0bh, 08d68h, 09d49h
;            7
         dw     07e97h, 06eb6h, 05ed5h, 04ef4h, 03e13h, 02e32h, 01e51h, 00e70h
         dw     0ff9fh, 0efbeh, 0dfddh, 0cffch, 0bf1bh, 0af3ah, 09f59h, 08f78h
;            8
         dw     09188h, 081a9h, 0b1cah, 0a1ebh, 0d10ch, 0c12dh, 0f14eh, 0e16fh
         dw     01080h, 000a1h, 030c2h, 020e3h, 05004h, 04025h, 07046h, 06067h
;            9
         dw     083b9h, 09398h, 0a3fbh, 0b3dah, 0c33dh, 0d31ch, 0e37fh, 0f35eh
         dw     002b1h, 01290h, 022f3h, 032d2h, 04235h, 05214h, 06277h, 07256h
;            A
         dw     0b5eah, 0a5cbh, 095a8h, 08589h, 0f56eh, 0e54fh, 0d52ch, 0c50dh
         dw     034e2h, 024c3h, 014a0h, 00481h, 07466h, 06447h, 05424h, 04405h
;            B
         dw     0a7dbh, 0b7fah, 08799h, 097b8h, 0e75fh, 0f77eh, 0c71dh, 0d73ch
         dw     026d3h, 036f2h, 00691h, 016b0h, 06657h, 07676h, 04615h, 05634h
;            C
         dw     0d94ch, 0c96dh, 0f90eh, 0e92fh, 099c8h, 089e9h, 0b98ah, 0a9abh
         dw     05844h, 04865h, 07806h, 06827h, 018c0h, 008e1h, 03882h, 028a3h
;            D
         dw     0cb7dh, 0db5ch, 0eb3fh, 0fb1eh, 08bf9h, 09bd8h, 0abbbh, 0bb9ah
         dw     04a75h, 05a54h, 06a37h, 07a16h, 00af1h, 01ad0h, 02ab3h, 03a92h
;            E
         dw     0fd2eh, 0ed0fh, 0dd6ch, 0cd4dh, 0bdaah, 0ad8bh, 09de8h, 08dc9h
         dw     07c26h, 06c07h, 05c64h, 04c45h, 03ca2h, 02c83h, 01ce0h, 00cc1h
;            F
         dw     0ef1fh, 0ff3eh, 0cf5dh, 0df7ch, 0af9bh, 0bfbah, 08fd9h, 09ff8h
         dw     06e17h, 07e36h, 04e55h, 05e74h, 02e93h, 03eb2h, 00ed1h, 01ef0h

         MODEL TPASCAL

PUBLIC   UpdateCRC16
PROC     UpdateCRC16 FAR initcrc:WORD,inbuf:DWORD,inlen:WORD
; UpdateCRC16 takes an initial CRC value and updates it with inlen bytes from
; inbuf. The updated CRC is returned in AX.  The Pascal declaration is:
; Function UpdateCRC16(InitCRC : Word; Var InBuf; InLen : Word) : Word;
; Stomps registers: AX,BX,CX,SI
         push   ds
         lds    si,[inbuf]    ; ds:si := ^inbuf
         mov    ax,[initcrc]  ; ax := initcrc
         mov    cx,[inlen]    ; cx := inlen
         or     cx,cx
         jz     @@done
@@loop:
         xor    bh,bh
         mov    bl,ah
         mov    ah,al
         lodsb
         shl    bx,1
         xor    ax,[crctab+bx]
         loop   @@loop
@@done:
         pop    ds
         ret
ENDP

ENDS
END