;
; Graphics display routines.    Copyright 1987	Everett Kaser
;						35405 Spruce St
;						Albany, OR 97321
;						(503) 928-5259
;					work:	(503) 750-3569
;
page	60,132
title	DISPLAY I/O ROUTINES for CGA 320x200 and EGA 640x350 graphics modes
;
font1	equ	0
;
; for this entire module, the origin (0,0) is at the bottom-left of the screen.
;
;					Everett Kaser	11-03-86
;						for C	06-24-87
CGA	EQU	0	; return values for
EGA	EQU	1	;   setmode function
;
_text	segment	byte public 'code'
_text	ends
_data	segment	word public 'data'
_data	ends
const	segment	word public 'const'
const	ends
_bss	segment	word public 'bss'
_bss	ends
;
	public	_setmode
	public	_setcolors
	public	_plotxy
	public	_bplotxy
	public	_line
	public	_horline
	public	_verline
	public	_clrscreen
	public	_setrand
	public	_rand
	public	_beepon
	public	_beepoff
	public	_flabel
	public	_iskey
	public	_key
	public	_movebytes
;
	public	_machine
;
dgroup	group	const, _bss, _data
	assume	cs:_text, ds:dgroup, ss:dgroup, es:dgroup
;
_data	segment	word public 'data'
;
_machine	dw	?
;
seed	dw	4
;
color	db	?
rule	db	?
backclr	db	?
string	dw	?
rowcnt	db	?
colcnt	db	?
x1	dw	?
y1	dw	?
x2	dw	?
y2	dw	?
stepx	dw	?
stepy	dw	?
difx	dw	?
dify	dw	?
halfdifx dw	?
halfdify dw	?
;
vidseg	dw	?
;
maskbyte db	?
masks	db	256 dup (0)
;
; here are two different fonts. currently I'm using the second font. If
; you want to use the first, you have to change the FONT1 EQU at the
; beginning of the file to be EQU'd to 1.
;
if font1
chartab	db	00h,00h,00h,00h,00h,00h,00h,00h		; 0
	db	0Eh,10h,0Ch,02h,1Ch,05h,07h,05h
	db	0Eh,10h,0Ch,02h,1Ch,05h,02h,05h
	db	1Ch,10h,1Ch,10h,1Ch,05h,02h,05h
	db	1Ch,10h,1Ch,10h,1Ch,07h,02h,02h
	db	1Ch,10h,1Ch,10h,1Ch,0Ah,0Ah,07h
	db	0Ch,12h,1Eh,12h,04h,05h,06h,05h
	db	1Ch,12h,1Ch,12h,1Ch,04h,04h,07h
	db	1Ch,12h,1Ch,12h,1Fh,04h,02h,0Ch
	db	14h,14h,1Ch,14h,14h,07h,02h,02h
	db	10h,10h,10h,1Ch,07h,04h,06h,04h		; 10
	db	11h,0Ah,04h,00h,07h,02h,02h,02h
	db	1Eh,10h,1Ch,10h,17h,04h,06h,04h
	db	0Ch,12h,10h,10h,0Eh,09h,0Eh,09h
	db	0Eh,10h,0Ch,02h,1Eh,09h,09h,06h
	db	0Eh,10h,0Ch,02h,1Ch,07h,02h,07h
	db	1Ch,12h,12h,1Ch,00h,04h,04h,07h
	db	1Ch,12h,12h,1Ch,01h,01h,01h,01h
	db	1Ch,12h,12h,1Ch,06h,01h,02h,07h
	db	1Ch,12h,12h,1Fh,01h,03h,01h,07h
	db	1Ch,12h,12h,1Ch,05h,05h,07h,01h		; 20
	db	12h,1Ah,16h,12h,04h,05h,06h,05h
	db	0Eh,10h,0Ch,02h,1Dh,0Dh,0Bh,09h
	db	1Ch,10h,18h,16h,1Dh,06h,05h,06h
	db	0Ch,12h,10h,0Ch,09h,0Dh,0Bh,09h
	db	1Ch,10h,1Ch,10h,1Dh,1Bh,15h,11h
	db	07h,08h,04h,1Eh,05h,06h,05h,06h
	db	1Ch,10h,1Ch,10h,1Fh,04h,04h,03h
	db	1Eh,10h,1Ch,10h,13h,04h,02h,0Ch
	db	0Eh,10h,16h,12h,0Fh,04h,02h,0Ch
	db	1Ch,12h,1Ch,12h,13h,04h,02h,0Ch		; 30
	db	12h,12h,12h,0Ch,03h,04h,02h,0Ch
	db	00h,00h,00h,00h,00h,00h,00h,00h
	db	06h,06h,06h,06h,06h,00h,06h,00h
	db	1Bh,1Bh,09h,12h,00h,00h,00h,00h
	db	00h,0Ah,1Fh,0Ah,1Fh,0Ah,00h,00h
	db	04h,0Fh,14h,0Eh,05h,1Eh,04h,00h
	db	18h,19h,02h,04h,08h,13h,03h,00h
	db	0Ch,1Ah,1Ah,0Dh,1Ah,1Ah,0Dh,00h
	db	06h,06h,02h,04h,00h,00h,00h,00h
	db	06h,0Ch,18h,18h,18h,0Ch,06h,00h		; 40
	db	0Ch,06h,03h,03h,03h,06h,0Ch,00h
	db	00h,0Ah,04h,1Fh,04h,0Ah,00h,00h
	db	00h,04h,04h,1Fh,04h,04h,00h,00h
	db	00h,00h,00h,00h,06h,06h,02h,04h
	db	00h,00h,00h,1Fh,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,06h,06h,00h
	db	00h,01h,03h,06h,0Ch,18h,10h,00h
	db	0Eh,19h,19h,1Bh,1Dh,19h,0Eh,00h
	db	06h,0Eh,06h,06h,06h,06h,0Fh,00h
	db	0Eh,13h,03h,06h,0Ch,18h,1Fh,00h		; 50
	db	0Eh,13h,03h,0Eh,03h,13h,0Eh,00h
	db	16h,16h,16h,16h,1Fh,06h,06h,00h
	db	1Fh,18h,1Eh,03h,03h,13h,0Eh,00h
	db	0Eh,19h,18h,1Eh,19h,19h,0Eh,00h
	db	1Fh,03h,06h,0Ch,0Ch,0Ch,0Ch,00h
	db	0Eh,19h,19h,0Eh,19h,19h,0Eh,00h
	db	0Eh,13h,13h,0Fh,03h,13h,0Eh,00h
	db	00h,06h,06h,00h,06h,06h,00h,00h
	db	00h,06h,06h,00h,06h,06h,02h,04h
	db	03h,06h,0Ch,18h,0Ch,06h,03h,00h		; 60
	db	00h,00h,1Fh,00h,1Fh,00h,00h,00h
	db	18h,0Ch,06h,03h,06h,0Ch,18h,00h
	db	0Eh,13h,03h,06h,04h,00h,04h,00h
	db	0Eh,11h,17h,15h,17h,10h,0Fh,00h
	db	0Eh,19h,19h,1Fh,19h,19h,19h,00h
	db	1Eh,19h,19h,1Eh,19h,19h,1Eh,00h
	db	0Eh,19h,18h,18h,18h,19h,0Eh,00h
	db	1Eh,19h,19h,19h,19h,19h,1Eh,00h
	db	1Fh,18h,18h,1Eh,18h,18h,1Fh,00h
	db	1Fh,18h,18h,1Eh,18h,18h,18h,00h		; 70
	db	0Eh,19h,18h,1Bh,19h,19h,0Fh,00h
	db	19h,19h,19h,1Fh,19h,19h,19h,00h
	db	0Fh,06h,06h,06h,06h,06h,0Fh,00h
	db	1Fh,06h,06h,06h,16h,16h,0Ch,00h
	db	19h,1Ah,1Ch,18h,1Ch,1Ah,19h,00h
	db	18h,18h,18h,18h,18h,18h,1Fh,00h
	db	11h,1Bh,1Fh,15h,15h,11h,11h,00h
	db	19h,19h,1Dh,1Fh,1Bh,19h,19h,00h
	db	0Eh,19h,19h,19h,19h,19h,0Eh,00h
	db	1Eh,19h,19h,1Eh,18h,18h,18h,00h		; 80
	db	0Eh,19h,19h,19h,1Dh,1Ah,0Dh,00h
	db	1Eh,19h,19h,1Eh,1Bh,19h,19h,00h
	db	0Eh,19h,18h,0Eh,03h,13h,0Eh,00h
	db	1Fh,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,00h
	db	19h,19h,19h,19h,19h,19h,0Eh,00h
	db	19h,19h,19h,19h,19h,0Ah,04h,00h
	db	11h,11h,15h,15h,1Fh,1Bh,11h,00h
	db	19h,1Bh,0Eh,04h,0Eh,1Bh,13h,00h
	db	19h,19h,0Bh,0Eh,06h,06h,06h,00h
	db	1Fh,03h,07h,0Eh,1Ch,18h,1Fh,00h		; 90
	db	1Eh,18h,18h,18h,18h,18h,1Eh,00h
	db	00h,10h,18h,0Ch,06h,03h,01h,00h
	db	0Fh,03h,03h,03h,03h,03h,0Fh,00h
	db	04h,0Eh,1Bh,11h,00h,00h,00h,00h
	db	00h,00h,00h,00h,00h,00h,3Fh,00h
	db	04h,08h,0Ch,0Ch,00h,00h,00h,00h
	db	00h,00h,0Eh,03h,0Fh,13h,0Fh,00h
	db	18h,18h,1Eh,19h,19h,19h,1Eh,00h
	db	00h,00h,0Eh,19h,18h,18h,0Fh,00h
	db	03h,03h,0Fh,13h,13h,13h,0Fh,00h		; 100
	db	00h,00h,0Eh,19h,1Fh,18h,0Fh,00h
	db	07h,0Ch,1Fh,0Ch,0Ch,0Ch,1Eh,00h
	db	00h,00h,0Fh,13h,13h,0Fh,03h,1Eh
	db	18h,18h,1Eh,19h,19h,19h,19h,00h
	db	06h,00h,0Eh,06h,06h,06h,0Fh,00h
	db	03h,00h,07h,03h,03h,03h,13h,0Eh
	db	18h,18h,19h,1Ah,1Ch,1Ah,19h,00h
	db	0Eh,06h,06h,06h,06h,06h,0Fh,00h
	db	00h,00h,11h,1Bh,1Fh,15h,11h,00h
	db	00h,00h,1Eh,19h,19h,19h,19h,00h		; 110
	db	00h,00h,0Eh,19h,19h,19h,0Eh,00h
	db	00h,00h,1Eh,19h,19h,1Eh,18h,18h
	db	00h,00h,0Fh,13h,13h,0Fh,03h,03h
	db	00h,00h,1Eh,19h,18h,18h,18h,00h
	db	00h,00h,0Fh,18h,1Fh,03h,1Eh,00h
	db	0Ch,0Ch,1Fh,0Ch,0Ch,0Dh,06h,00h
	db	00h,00h,13h,13h,13h,13h,0Fh,00h
	db	00h,00h,19h,19h,19h,0Ah,04h,00h
	db	00h,00h,11h,15h,1Fh,1Bh,11h,00h
	db	00h,00h,19h,0Eh,04h,0Eh,13h,00h		; 120
	db	00h,00h,13h,13h,13h,0Fh,03h,1Eh
	db	00h,00h,1Fh,06h,0Ch,18h,1Fh,00h
	db	07h,0Ch,0Ch,18h,0Ch,0Ch,07h,00h
	db	06h,06h,06h,06h,06h,06h,06h,00h
	db	1Ch,06h,06h,03h,06h,06h,1Ch,00h
	db	00h,08h,1Dh,17h,02h,00h,00h,00h
	db	15h,0Ah,15h,0Ah,15h,0Ah,15h,00h
else
chartab	db	4,12,28,60,28,12,4,0			; 0
	db	8,0,8,16,34,34,28,0
	db	124,0,68,40,16,40,68,0
	db	124,0,68,100,84,76,68,0
	db	0,0,52,72,72,72,52,0
	db	56,68,68,120,68,68,120,0
	db	124,68,32,16,32,68,124,0
	db	0,16,8,124,8,16,0,0
	db	0,16,32,124,32,16,0,0
	db	16,16,16,16,84,56,16,0
	db	16,56,84,16,16,16,16,0			; 10
	db	64,32,16,40,68,68,68,0
	db	0,0,36,36,36,56,64,0
	db	0,0,0,0,0,0,0,0
	db	0,4,56,80,16,16,16,0
	db	0,4,56,104,40,40,40,0
	db	56,68,68,124,68,68,56,0
	db	60,80,80,120,80,80,124,0
	db	0,0,40,84,92,80,60,0
	db	16,56,68,68,124,68,68,0
	db	16,0,56,72,72,72,52,0			; 20
	db	40,56,68,68,124,68,68,0
	db	40,0,56,72,72,72,52,0
	db	40,56,68,68,68,68,56,0
	db	40,0,56,68,68,68,56,0
	db	40,68,68,68,68,68,56,0
	db	40,0,68,68,68,68,56,0
	db	64,64,64,124,64,64,64,0
	db	24,24,24,24,24,24,24,24
	db	0,0,0,255,255,0,0,0
	db	24,36,32,112,32,32,124,0		; 30
	db	24,24,24,255,255,24,24,24
	db	0,0,0,0,0,0,0,0
	db	8,8,8,8,8,0,8,0
	db	40,40,40,0,0,0,0,0
	db	40,40,124,40,124,40,40,0
	db	16,60,80,56,20,120,16,0
	db	96,100,8,16,32,76,12,0
	db	32,80,80,32,84,72,52,0
	db	8,8,8,0,0,0,0,0
	db	16,32,64,64,64,32,16,0			; 40
	db	16,8,4,4,4,8,16,0
	db	16,84,56,16,56,84,16,0
	db	0,16,16,124,16,16,0,0
	db	0,0,0,0,8,8,16,0
	db	0,0,0,124,0,0,0,0
	db	0,0,0,0,0,8,0,0
	db	0,4,8,16,32,64,0,0
	db	56,68,76,84,100,68,56,0
	db	16,48,16,16,16,16,56,0
	db	56,68,4,24,32,64,124,0			; 50
	db	124,4,8,24,4,68,56,0
	db	8,24,40,72,124,8,8,0
	db	124,64,120,4,4,68,56,0
	db	28,32,64,120,68,68,56,0
	db	124,4,8,16,32,32,32,0
	db	56,68,68,56,68,68,56,0
	db	56,68,68,60,4,8,112,0
	db	0,0,16,0,16,0,0,0
	db	0,0,16,0,16,16,32,0
	db	4,8,16,32,16,8,4,0			; 60
	db	0,0,124,0,124,0,0,0
	db	64,32,16,8,16,32,64,0
	db	56,68,68,8,16,0,16,0
	db	56,68,84,88,88,64,60,0
	db	56,68,68,124,68,68,68,0			; 65 A
	db	120,68,68,120,68,68,120,0
	db	56,68,64,64,64,68,56,0
	db	120,68,68,68,68,68,120,0
	db	124,64,64,120,64,64,124,0
	db	124,64,64,120,64,64,64,0		; 70
	db	60,64,64,64,76,68,60,0
	db	68,68,68,124,68,68,68,0
	db	56,16,16,16,16,16,56,0
	db	4,4,4,4,4,68,56,0
	db	68,72,80,96,80,72,68,0
	db	64,64,64,64,64,64,124,0
	db	68,108,84,84,68,68,68,0
	db	68,68,100,84,76,68,68,0
	db	56,68,68,68,68,68,56,0
	db	120,68,68,120,64,64,64,0		; 80
	db	56,68,68,68,84,72,52,0
	db	120,68,68,120,80,72,68,0
	db	56,68,64,56,4,68,56,0
	db	124,16,16,16,16,16,16,0
	db	68,68,68,68,68,68,56,0
	db	68,68,68,68,40,40,16,0
	db	68,68,68,84,84,108,68,0
	db	68,68,40,16,40,68,68,0
	db	68,68,40,16,16,16,16,0
	db	124,4,8,16,32,64,124,0			; 90
	db	124,96,96,96,96,96,124,0
	db	0,64,32,16,8,4,0,0
	db	124,12,12,12,12,12,124,0
	db	16,40,68,0,0,0,0,0
	db	0,0,0,0,0,0,124,0
	db	64,32,16,8,0,0,0,0
	db	0,0,56,4,60,68,60,0
	db	64,64,88,100,68,68,120,0
	db	0,0,0,60,64,64,60,0
	db	4,4,52,76,68,68,60,0			; 100
	db	0,0,56,68,124,64,56,0
	db	8,16,16,56,16,16,16,0
	db	0,0,60,68,60,4,24,0
	db	64,64,88,100,68,68,68,0
	db	0,8,0,24,8,8,28,0
	db	0,4,0,4,4,36,24,0
	db	32,32,36,40,48,40,36,0
	db	24,8,8,8,8,8,28,0
	db	0,0,104,84,84,84,84,0
	db	0,0,88,100,68,68,68,0			; 110
	db	0,0,56,68,68,68,56,0
	db	0,0,120,68,120,64,64,0
	db	0,0,56,72,56,8,4,0
	db	0,0,44,48,32,32,32,0
	db	0,0,60,64,56,4,120,0
	db	0,16,56,16,16,16,8,0
	db	0,0,68,68,68,72,52,0
	db	0,0,68,68,40,40,16,0
	db	0,0,68,68,84,84,40,0
	db	0,0,68,40,16,40,68,0			; 120
	db	0,0,68,40,16,32,64,0
	db	0,0,124,8,16,32,124,0
	db	16,32,32,64,32,32,16,0
	db	16,16,16,0,16,16,16,0
	db	16,8,8,4,8,8,16,0
	db	0,0,32,84,8,0,0,0
	db	84,40,84,40,84,40,84,0			; 127
endif
;
_data	ends
	page



_text	segment



; setmode(mode);
;
; SETMODE --- change the display mode
;	at entry:	AL = 0	40x25 BW
;			     1	40x25 COLOR
;			     2	80x25 BW
;			     3	80x25 COLOR
;			     4	320x200 COLOR
;			     5	320x200 BW
;			     6	640x200 BW
;			     7	80x25 BW (monochrome)
;			    10h	640x350 COLOR (ega)
_setmode:
	push	bp
	mov	bp,sp
	mov	ax,[bp+4]		; get mode
	cmp	al,4			; 320x200 CGA graphics?
	jb	smode			; jif no
;
; the following sets up the byte mask table for the bplotxy 'collision' function
; (currently is supported only by 320x200 CGA graphics mode 4).
;
	push	ax			; save mode
	push	es
	push	ds
	pop	es
cgamakemasks:
	lea	di,masks		; load offset of mask bytes
	xor	ah,ah			; there are four pixels per byte of
smloop:	xor	al,al			; CGA 320x200 color video RAM.  Each
	test	ah,3			; pixel has 2 bits, selecting one of
	jz	sml1			; four colors. 00 = background color.
	or	al,3			; these mask bytes are used during 
sml1:	test	ah,0ch			; BPLOTXY to determine if a non-backgnd
	jz	sml2			; color is being bplotted onto a 
	or	al,0ch			; non-background color, resulting in a
sml2:	test	ah,30h			; 'collision'.  There are 256 masks, 1
	jz	sml3			; for each possible bplot byte.  For
	or	al,30h			; each pixel (pair of bits), if either
sml3:	test	ah,0c0h			; bit is set, then both bits of the 
	jz	sml4			; mask are set, so by ANDing the masks
	or	al,0c0h			; with the bplot bytes and the video
sml4:	stosb				; bytes, we can tell if any of the four
	inc	ah			; pixels in the current byte collide.
	jnz	smloop
	pop	es
	pop	ax
smode:
	mov	ah,0			; bios int 10 function setmode
	cmp	al,10h			; EGA graphics?
	jz	isega			; jif yes
	mov	vidseg,0b800h		; default video ram segment to CGA
	mov	_machine,CGA		; default machine type to CGA
successful:
	int	10h
	mov	ax,1
	pop	bp
	ret
isega:
	mov	vidseg,0a000h		; set video ram segment to EGA
	mov	_machine,EGA		; set disptype to EGA
	push	ax
	mov	ah,12h			; return ega information
	mov	bx,0ff10h		; set bh = ff to see if it changes 
	int	10h			;   if bh changes, it's ega
	pop	ax
	cmp	bh,0ffh			; ega?
	jnz	successful		; jif yes
	xor	ax,ax
	pop	bp
	ret
	page
;
; setcolors(colorset, color);
;
_setcolors:
	push	bp
	mov	bp,sp
	mov	bx,[bp+4]	; get colorset
	mov	ax,[bp+6]	; get color
	call	setcolor
	pop	bp
	ret
;
setcolor:
	cmp	_machine,0
	jnz	egasetcolors
;
; cgasetcolors --- sets colorset, background color
;
;	at entry:	AL = background color (0-15)
;				0 black		6  brown	12 light red
;				1 blue		7  white	13 light magenta
;				2 green		8  gray		14 yellow
;				3 cyan		9  light blue	15 white bright
;				4 red		10 light green
;				5 magenta	11 light cyan
;			BL = color set (1=cyan/magenta/white 0=green/red/brown)
cgasetcolors:
	push	ax		; save background color
	mov	bh,1		; set color id 1 (select palette)
	mov	ah,11		; set color palette function of int 10h
	int	10h
	pop	bx		; recover background color
	mov	bh,0		; set color id 0 (background color)
	mov	ah,11		; set color palette function of int 10h
	int	10h
	ret
;
; sets ega palette registers
;	on entry:
;		AL = color value
;		BL = palette number
;
egasetcolors:
	mov	bh,al		; copy color value
	mov	ah,10h		; set palette call
	mov	al,0		; set palette color sub-function number
	cmp	bl,16		; overscan?
	jnz	egasc		; jif no
	inc	al		; change sub-function
egasc:
	int	10h
	ret
	page
;
; plotxy(x,y,color,rule);
;
_plotxy:
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	cx,[bp+4]	; get x
	mov	bx,[bp+6]	; get y
	mov	dx,[bp+8]	; get color
	mov	ax,[bp+10]	; get rule
	mov	dh,al
	call	pixel
	pop	di
	pop	si
	pop	bp
	ret
;
; xxxPIXEL --- color a pixel on the display
;
;	at entry:	BX = y-coordinate
;			CX = x-coordinate
;			DL = color
;			DH = replacement rule (0=force, 1=and, 2=or, 3=xor)
;
pixel:
	cmp	_machine,0
	jnz	egapixel
;
cgapixel:
	call	cgamapxy
	push	ds
	mov	ds,vidseg
	or	dh,dh		; force pixel?
	jz	pxyforce
	cmp	dh,3		; xor pixel?
	jz	pxyxor
	cmp	dh,2		; or pixel?
	jz	pxyor
pxyand:
	or	al,dl		; put and-mask into color byte
	and	[di],al		; and color into display
	jmp	short plotexit
pxyxor:
	xor	[di],dl		; xor color into display
plotexit:
	pop	ds
	ret
pxyor:
	or	[di],dl		; or color into display
	jmp	plotexit
pxyforce:
	and	[di],al		; clear pixel in display
	or	[di],dl		; force new bits into display
	jmp	plotexit
;
egapixel:
	call	egamapxy
	push	es
	mov	es,vidseg
	push	dx		; save bit mask

	shl	cl,1
	shl	cl,1		; set logical operation in ega controller
	shl	cl,1
	mov	dx,3ceh
	mov	al,3
	out	dx,al
	inc	dx
	mov	al,cl
	out	dx,al

	dec	dx
	mov	al,8
	out	dx,al		; set bit mask
	inc	dx
	pop	ax		; recover bit mask
	out	dx,al

	mov	dx,3c4h
	mov	al,2
	out	dx,al		; set plane mask (to set 1 bits of color)
	inc	dx
	mov	al,ch		; get color
	out	dx,al

	mov	ah,es:[di]	; latch current data first
	mov	al,0ffh		; blend in new bits
	stosb
	dec	di

	mov	dx,3c4h
	mov	al,2
	out	dx,al		; set plane mask (to zero 0 bits of color)
	inc	dx
	mov	al,ch		; get color
	not	al		; invert
	out	dx,al

	mov	ah,es:[di]	; latch current data first
	mov	al,0		; logic-force new off bits
	stosb
	pop	es
	ret
;
cgamapxy:
	mov	ax,199
	sub	ax,bx		; invert y coord
	and	ax,0fffeh	; trash lower bit for odd/even
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	di,ax		; si = 16*y
	shl	ax,1
	shl	ax,1		; ax = 64*y
	add	di,ax		; si = 16*y + 64*y = 80*y
	test	bl,1		; odd or even scan line?
	jnz	cgamapodd
	add	di,2000h	; offset to odd bank
cgamapodd:
	mov	ax,cx		; get x-coord
	shr	ax,1
	shr	ax,1		; ax = x/4	(cga320x200 = 4 pixels/byte)
	add	di,ax		; si = offset of byte containing pixel
	and	cl,3		; keep bit address
	shl	cl,1
	ror	dl,1		; get color info in msbits
	ror	dl,1
	ror	dl,cl		; put color info in right place for pixel
	mov	al,3fh		; get pixel mask
	ror	al,cl
	ret
;
egamapxy:
	mov	ax,349
	sub	ax,bx		; invert y coord
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	di,ax		; di = 16*y
	shl	ax,1
	shl	ax,1		; ax = 64*y
	add	di,ax		; di = 16*y + 64*y = 80*y
	mov	ax,cx		; get x-coord
	shr	ax,1
	shr	ax,1		; ax = x/8	(ega650x350 = 8 pixels/byte)
	shr	ax,1
	add	di,ax		; di = offset of byte containing pixel
	and	cx,7		; keep bit address
	mov	ch,dl		; save color
	mov	dl,80h
	ror	dl,cl		; put color info in right place for pixel
	mov	cl,dh		; save rule
	ret
	page
;
; bplotxy(x, y, height, width, picture, rule);
;
; BPLOTXY --- plot a raster picture
;	at entry:	BX = y-coordinate
;			CX = x-coordinate
;			DL = height (# of rows in picture)
;			DH = width (# of bytes in picture)
;			SI = ptr to picture
;			BP = 0 for force,  8000h for xor
;
;	at exit:	AL = 0 if no collision, #0 if collision
_bplotxy:
	push	bp
	mov	bp,sp
	cld
	push	si
	push	di
	mov	bx,[bp+6]
	mov	cx,[bp+4]
	mov	dx,[bp+8]
	mov	ax,[bp+10]
	mov	dh,al
	mov	si,[bp+12]
	mov	bp,[bp+14]
	cmp	_machine,0
	jz	cgabplot
	jmp	egabplot
cgabplot:
	push	dx		; save high,wide
	call	cgamapxy
	pop	dx		; recover
	and	bx,1
	and	bp,8000h
	or	bp,bx		; bp = even/odd row flag
	lea	bx,masks
	mov	maskbyte,0
	push	es
	mov	es,vidseg
bpxybeglin:
	mov	ch,dh		; copy bytes/row
	xor	ah,ah		; zero upper byte
bpxydoline:
	mov	al,[si]		; get first byte of data
	shr	ax,cl		; shift to correct bit alignment
	push	ax
	xlat
	and	al,es:[di]	; check for collisions
	or	maskbyte,al
	pop	ax
	test	bp,8000h	; force?
	jz	bpxyf1		; jif yes
	xor	es:[di],al	; xor in the byte
	jmp	short bpxyfcom
bpxyf1:
	mov	es:[di],al	; force it
bpxyfcom:
	inc	di		; move to next byte of display
	lodsb			; refetch byte for upper this time
	mov	ah,al		; copy it
	dec	ch		; decrement bytes/row count
	jnz	bpxydoline	; jif til line is done
	or	cl,cl		; byte aligned?
	jz	bpxyaligned	; jif yes, we're done with row
	xor	al,al		; zero lower byte (last byte on row)
	shr	ax,cl		; shift to correct bit alignment
	push	ax
	xlat
	and	al,es:[di]	; check for collisions
	or	maskbyte,al
	pop	ax
	test	bp,8000h	; force?
	jz	bpxyf2		; jif yes
	xor	es:[di],al	; xor last bits into display
	jmp	short bpxyaligned
bpxyf2:
	mov	es:[di],al
bpxyaligned:
	mov	al,dh		; get bytes/row
	xor	ah,ah
	sub	di,ax		; move back to start of display box
	xor	bp,1		; toggle odd/even flag
	test	bp,1		; even next?
	jnz	bpxyeven	; jif yes
	add	di,2000h	; move to odd bank
	jmp	short bpxynext
bpxyeven:
	sub	di,1fb0h	; move back to even bank, next row
bpxynext:
	dec	dl		; decrement row counter
	jnz	bpxybeglin	; jif til done
	pop	es
	mov	al,maskbyte
	pop	di
	pop	si
	pop	bp
	ret
;
;
egabplot:
	push	dx
	call	egamapxy
	mov	bl,dl		; save bit mask
	pop	dx		; recover high/wide
	mov	ah,dh		; copy width
	mov	bh,dl		; copy height
	push	es
	mov	es,vidseg
	mov	cl,0
	test	bp,8000h	; force?
	jz	egab2		; jif yes
	mov	cl,18h		; xor
egab2:
	mov	dx,3ceh
	mov	al,3
	out	dx,al		; set logical operation in ega controller
	inc	dx
	mov	al,cl
	out	dx,al
egab1:
	mov	cl,ah		; get width of picture
	xor	ch,ch
	push	di		; save screen pointer
	push	bx		; save bit mask
egab3:
	mov	dx,3ceh
	mov	al,8
	out	dx,al		; set bit mask
	inc	dx
	mov	al,bl
	out	dx,al

	mov	dx,3c4h
	mov	al,2
	out	dx,al		; set plane mask (to set 1 bits of color)
	inc	dx
	mov	al,[si]		; get next pixel color
	out	dx,al

	mov	al,es:[di]		; latch current data first
	mov	byte ptr es:[di],0ffh	; blend in new color bits

	dec	dx
	mov	al,2
	out	dx,al		; set plane mask (to zero 0 bits of color)
	inc	dx
	lodsb			; get color
	not	al		; invert
	out	dx,al

	mov	al,es:[di]		; latch current data first
	mov	byte ptr es:[di],0	; logic-force new off bits
	ror	bl,1
	or	bl,bl
	jns	egabok
	inc	di
egabok:
	loop	egab3
	pop	bx
	pop	di
	add	di,80		; move to next row
	dec	bh
	jnz	egab1
	mov	ax,0
	pop	es
	pop	di
	pop	si
	pop	bp
	ret
	page
;
; line(x1, y1, x2, y2, color, rule);
;
_line:
	push	bp
	mov	bp,sp

	mov	word ptr stepx,1	; init x step value
	mov	word ptr stepy,1	; init y step value

	mov	bx,[bp+4]		; get x-coords of endpoints
	mov	x1,bx
	mov	ax,[bp+8]
	mov	x2,ax

	sub	ax,bx			; get difx
	jnb	gotdifx			; jif x2 >= x1
	neg	ax			; else get x1-x2
	neg	word ptr stepx		; make stepx = -1
gotdifx:
	mov	difx,ax			; save difx away

	mov	dx,[bp+6]		; get y-coords of endpoints
	mov	y1,dx
	mov	cx,[bp+10]
	mov	y2,cx

	sub	cx,dx			; get dify
	jnb	gotdify			; jif y2 >= y1
	neg	cx			; else get y1-y2
	neg	word ptr stepy		; make stepy = -1
gotdify:	
	mov	dify,cx			; save dify away

	mov	ax,[bp+12]		; get color
	mov	color,al
	mov	al,[bp+14]		; get replacement rule
	mov	rule,al

;**************************************************************
; register usage:
;
;    bp=incflag
;    ds=data segment
;    si=counter
;    ax=scratch
;    bx=row
;    cx=scratch
;    dx=row
;**************************************************************
;
	xor	bp,bp			; init flag
	mov	si,bp			; init counter
;
; if difx >= dify then stepx else stepy
;
	mov	ax,difx			; get difx
	cmp	ax,cx			; is difx >= dify ?
	jb	dostepy			; jif no
	shr	ax,1			; get difx / 2
	mov	halfdifx,ax		; save away
	mov	bx,dx			; get y1
forcol:
	mov	cx,x1			; get x1
	jmp	short forcolloop
fcl:
	add	cx,stepx
forcolloop:	
	call	linedot
	add	si,dify			; add it to counter
	cmp	halfdifx,si		; if halfdifx >= counter
	jnb	notx			;     then don't do it
	or	bp,bp			; if incflag
	jnz	notx			;     then don't do it
	inc	bp			; set flag
	add	bx,stepy		; move to next row
notx:
	cmp	si,difx			; if counter < difx
	jb	colwhile		;     then don't reset flag
	sub	si,difx			; dock counter by proper count
	xor	bp,bp			; reset flag
colwhile:
	cmp	cx,x2
	jnz	fcl
done:
	pop	bp
	ret
;
;
dostepy:
	mov	ax,dify			; get dify
	shr	ax,1			; get dify / 2
	mov	halfdify,ax		; save away
	mov	cx,bx			; get x1
forrow:
	mov	bx,y1			; get y1
	jmp	short forrowloop
frl:
	add	bx,stepy
forrowloop:	
	call	linedot
	add	si,difx			; add it to counter
	cmp	halfdify,si		; if halfdifx >= counter
	jnb	noty			;     then don't do it
	or	bp,bp			; if incflag
	jnz	noty			;     then don't do it
	inc	bp			; set flag
	add	cx,stepx		; move to next col
noty:
	cmp	si,dify			; if counter < dify
	jb	rowwhile		;     then don't reset flag
	sub	si,dify			; dock counter by proper count
	xor	bp,bp			; reset flag
rowwhile:
	cmp	bx,y2
	jnz	frl
	jmp	done
;
;
;
;    bx=row
;    cx=col
;    bp, si, bx, cx should not be destroyed
;
linedot:
	push	cx
	push	bx
	push	si
	push	bp
	mov	dl,color
	mov	dh,rule
	call	pixel
	pop	bp
	pop	si
	pop	bx
	pop	cx
	ret
	page
;
; horline(x1, y1, x2, color, rule);
;
_horline:
	push	bp
	mov	bp,sp
	mov	bx,[bp+4]		; get x1
	mov	x1,bx
	mov	cx,[bp+6]		; get y1
	mov	y1,cx
	mov	ax,[bp+8]		; get x2
	mov	x2,ax
	mov	dx,[bp+10]		; get color
	mov	color,dl
	mov	dx,[bp+12]		; get rule
	mov	rule,dl

	sub	ax,bx			; get difx
	jnb	hgotdifx		; jif x2 >= x1
	neg	ax			; else get x1-x2
	mov	dx,x2
	mov	x1,dx
	mov	x2,bx
hgotdifx:
	inc	ax			; # of dots to write
	mov	difx,ax			; save difx away
	mov	bx,cx			; get start y
	mov	cx,x1			; get start x
	mov	dl,color
	cmp	_machine,0
	jz	cgahorline
	jmp	egahorline
cgahorline:
	call	cgamapxy
	mov	cx,difx
	mov	dh,rule
	push	ds
	mov	ds,vidseg
	or	dh,dh
	jz	hpxyforce
	cmp	dh,3
	jz	hpxyxor
	cmp	dh,2
	jz	hpxyor
hpxyand:
	or	dl,al		; force all other bits on for anding
hpxya:
	and	[di],dl		; and in color
	ror	dl,1
	ror	dl,1
	ror	al,1
	ror	al,1
	or	al,al
	js	hxandok
	inc	di
hxandok:
	loop	hpxya
	jmp	short hlexit
hpxyxor:
	xor	[di],dl		; xor color into display
	ror	dl,1
	ror	dl,1
	ror	al,1
	ror	al,1
	or	al,al
	js	hxorok
	inc	di
hxorok:
	loop	hpxyxor
hlexit:
	pop	ds
	pop	bp
	ret
hpxyor:
	or	[di],dl		; or color into display
	ror	dl,1
	ror	dl,1
	ror	al,1
	ror	al,1
	or	al,al
	js	horok
	inc	di
horok:
	loop	hpxyor
	jmp	hlexit
hpxyforce:
	and	[di],al		; clear pixel in display
	or	[di],dl		; force new bits into display
	ror	dl,1
	ror	dl,1
	ror	al,1
	ror	al,1
	or	al,al
	js	hforceok
	inc	di
hforceok:
	loop	hpxyforce
	jmp	hlexit
;
;
egahorline:
	call	egamapxy
	mov	bl,dl		; save bit mask
	mov	bh,ch		; save color
	mov	cx,difx
	mov	ah,rule
	push	ds
	mov	ds,vidseg

	shl	ah,1
	shl	ah,1		; set logical operation in ega controller
	shl	ah,1
	mov	dx,3ceh
	mov	al,3
	out	dx,al
	inc	dx
	mov	al,ah
	out	dx,al

egahl:
	mov	dx,3ceh
	mov	al,8
	out	dx,al		; set bit mask
	inc	dx
	mov	al,bl		; recover bit mask
	test	al,80h		; at start of byte?
	jz	eganot80	; jif no
	cmp	cx,8		; full byte to do?
	jb	eganot80	; jif no
	call	egahlbytes	; do full bytes
	or	cx,cx		; any odd bits left?
	jz	egahlexit	; jif no
	jmp	egahl
eganot80:
	out	dx,al		; set bit mask

	mov	dx,3c4h
	mov	al,2
	out	dx,al		; set plane mask (to set 1 bits of color)
	inc	dx
	mov	al,bh		; get color
	out	dx,al

	mov	al,[di]		; latch current data first
	mov	byte ptr [di],0ffh	; blend in new color bits

	dec	dx
	mov	al,2
	out	dx,al		; set plane mask (to zero 0 bits of color)
	inc	dx
	mov	al,bh		; get color
	not	al		; invert
	out	dx,al

	mov	al,[di]		; latch current data first
	mov	byte ptr [di],0	; logic-force new off bits
	ror	bl,1
	or	bl,bl
	jns	egahlok
	inc	di
egahlok:
	loop	egahl
egahlexit:
	pop	ds
	pop	bp
	ret
;
egahlbytes:
	mov	al,0ffh		; write all bits of byte at once
	out	dx,al		; set bit mask
egahlb:
	mov	dx,3c4h
	mov	al,2
	out	dx,al		; set plane mask (to set 1 bits of color)
	inc	dx
	mov	al,bh		; get color
	out	dx,al

	mov	al,[di]		; latch current data first
	mov	byte ptr [di],0ffh	; blend in new color bits

	dec	dx
	mov	al,2
	out	dx,al		; set plane mask (to zero 0 bits of color)
	inc	dx
	mov	al,bh		; get color
	not	al		; invert
	out	dx,al

	mov	al,[di]		; latch current data first
	mov	byte ptr [di],0	; logic-force new off bits
	inc	di
	sub	cx,8		; decrement dot count by one bytes worth
	cmp	cx,8		; another full byte left?
	jnb	egahlb		; jif yess
	ret
	page
;
; verline(x1, y1, y2, color, rule);
;
_verline:
	push	bp
	mov	bp,sp
	push	di
	mov	bx,[bp+4]		; get x1
	mov	x1,bx
	mov	cx,[bp+6]		; get y1
	mov	y1,cx
	mov	ax,[bp+8]		; get y2
	mov	y2,ax
	mov	dx,[bp+10]		; get color
	mov	color,dl
	mov	dx,[bp+12]		; get rule
	mov	rule,dl

	sub	ax,cx			; get difx
	jnb	vgotdify		; jif y2 >= y1
	neg	ax			; else get y1-y2
	mov	dx,y2
	mov	y1,dx
	mov	y2,cx
vgotdify:
	inc	ax			; # of dots to write
	mov	dify,ax			; save difx away
	mov	cx,bx
	mov	bx,y2
	mov	dl,color
	cmp	_machine,0
	jz	cgaverline
	jmp	egaverline
cgaverline:
	call	cgamapxy
	mov	cx,dify
	mov	dh,rule
	push	ds
	mov	ds,vidseg
	or	dh,dh
	jz	vpxyforce
	cmp	dh,3
	jz	vpxyxor
	cmp	dh,2
	jz	vpxyor
vpxyand:
	or	dl,al
	test	byte ptr es:y2,1	; in upper 2000h bytes?
	jz	vaupper		; jif yes
vpand:
	and	[di],dl		; xor color into display
	add	di,2000h
	dec	cx
	jz	vpdone
vaupper:
	and	[di],dl
	sub	di,1fb0h
	loop	vpand
	jmp	short vpdone
vpxyxor:
	test	byte ptr es:y2,1	; in upper 2000h bytes?
	jz	vupper		; jif yes
vpxor:
	xor	[di],dl		; xor color into display
	add	di,2000h
	dec	cx
	jz	vpdone
vupper:
	xor	[di],dl
	sub	di,1fb0h
	loop	vpxor
vpdone:
	pop	ds
	pop	di
	pop	bp
	ret
vpxyor:
	test	byte ptr es:y2,1	; in upper 2000h bytes?
	jz	voupper			; jif yes
vpor:
	or	[di],dl			; force new bits into display
	add	di,2000h
	dec	cx
	jz	vpdone
voupper:
	or	[di],dl
	sub	di,1fb0h
	loop	vpor
	jmp	vpdone
vpxyforce:
	test	byte ptr es:y2,1	; in upper 2000h bytes?
	jz	vfupper			; jif yes
vpforce:
	and	[di],al			; clear pixel in display
	or	[di],dl			; force new bits into display
	add	di,2000h
	dec	cx
	jz	vpdone
vfupper:
	and	[di],al
	or	[di],dl
	sub	di,1fb0h
	loop	vpforce
	jmp	vpdone
;
;
egaverline:
	call	egamapxy
	mov	bl,dl		; save bit mask
	mov	bh,ch		; save color
	mov	cx,dify
	mov	ah,rule
	push	ds
	mov	ds,vidseg

	shl	ah,1
	shl	ah,1		; set logical operation in ega controller
	shl	ah,1
	mov	dx,3ceh
	mov	al,3
	out	dx,al
	inc	dx
	mov	al,ah
	out	dx,al

	mov	dx,3ceh
	mov	al,8
	out	dx,al		; set bit mask
	inc	dx
	mov	al,bl		; recover bit mask
	out	dx,al
egavl:
	mov	dx,3c4h
	mov	al,2
	out	dx,al		; set plane mask (to set 1 bits of color)
	inc	dx
	mov	al,bh		; get color
	out	dx,al

	mov	al,[di]			; latch current data first
	mov	byte ptr [di],0ffh	; blend in new color bits

	dec	dx
	mov	al,2
	out	dx,al		; set plane mask (to zero 0 bits of color)
	inc	dx
	mov	al,bh		; get color
	not	al		; invert
	out	dx,al

	mov	al,[di]		; latch current data first
	mov	byte ptr [di],0	; logic-force new off bits
	add	di,80		; move to next line
	loop	egavl
	pop	ds
	pop	di
	pop	bp
	ret
	page
;
; clrscreen(color);
;
_clrscreen:
	push	bp
	mov	bp,sp
	cld
	push	di
	mov	ax,[bp+4]		; get color
	push	es
	mov	es,vidseg
	xor	di,di
	cmp	_machine,0
	jnz	egaclear
cgaclear:
	mov	bx,ax
	shl	bx,1
	shl	bx,1
	or	ax,bx
	shl	bx,1
	shl	bx,1
	or	ax,bx			; build entire byte of color
	shl	bx,1
	shl	bx,1
	or	ax,bx
	mov	cx,8192
	rep	stosw
	pop	es
	pop	di
	pop	bp
	ret
egaclear:
	mov	bl,al			; save color

	mov	dx,3ceh
	mov	al,3
	out	dx,al
	inc	dx
	mov	al,0		; no rotate and no logical operation on data
	out	dx,al

	mov	dx,3ceh
	mov	al,8
	out	dx,al		; set bit mask
	inc	dx
	mov	al,0ffh		; all bits
	out	dx,al

	mov	dx,3c4h
	mov	al,2
	out	dx,al		; set plane mask (to set 1 bits of color)
	inc	dx
	mov	al,bl		; get color
	out	dx,al

	push	di
	mov	cx,28000	; number of bytes on ega display
	mov	al,0ffh		; blend in new color bits
	rep	stosb
	pop	di

	dec	dx
	mov	al,2
	out	dx,al		; set plane mask (to zero 0 bits of color)
	inc	dx
	mov	al,bl		; get color
	not	al		; invert
	out	dx,al

	mov	al,0		; logic-force new off bits
	mov	cx,28000
	rep	stosb

	pop	es
	pop	di
	pop	bp
	ret
;
	page
;
;
; setrand(seed);
;
; setrand - set random  # seed
;
_setrand:
	push	bp
	mov	bp,sp
	mov	ax,[bp+4]
 	or	ax,ax	 	 	; if seed specified
 	jnz	setit	 	 	;   use it
 	mov	ah,2ch	 	 	; else
 	int	21h	 	 	;   use system time (secs &
 	mov	ax,dx	 	 	;   1/100's) to get rand seed
setit:
 	mov	seed,ax	 	 	; save seed
	pop	bp
 	ret	 	 	 	; that's all folks
;
; rand();
;
; rand - fetch a new random number;  at entry, cx=limit
;	 	at exit, ax=random number
;
;   formula:     rand(i+1)=261*rand(i) mod 65521
;
_rand:
	push	bp
 	mov	ax,seed	 	; get last rand
 	mov	bx,261	 	; multiplier
 	mul	bx	 	;
 	mov	bx,65521
 	div	bx
 	cmp	dx,0	 	; new seed=0?
 	jnz	seedok	 	; jif no
 	inc	word ptr seed	; change seed
 	jmp	_rand	 	; try again
seedok:
 	mov	seed,dx
 	mov	ax,dx
 	mov	dx,0
 	div	cx
 	mov	ax,dx
	pop	bp
 	ret	 	 	 	; that's all
;
	page
_beepoff:
	in	al,61h
	and	al,0fch
	out	61h,al
	ret
;
; BEEPON --- turns beeper on with timer 2 gate to value in AX at entry.
;
_beepon:
	push	bp
	mov	bp,sp
	mov	al,0b6h
	out	43h,al
	mov	ax,[bp+4]
	out	42h,al
	mov	al,ah
	out	42h,al
	in	al,61h
	or	al,3
	out	61h,al
	pop	bp
	ret
;
	page
;
;
; flabel (x, y, string, fore_color, back_color, rule);
;
_flabel:
	push	bp
	mov	bp,sp
	cld
	push	si
	push	di
	push	es
	mov	cx,[bp+4]
	mov	dx,[bp+6]
	mov	si,[bp+8]
	mov	ax,[bp+10]
	mov	color,al
	mov	ax,[bp+12]
	mov	backclr,al
	mov	ax,[bp+14]
	mov	rule,al
	mov	x1,cx
	mov	y1,dx
	mov	string,si
floop:
	mov	si,string		; get ptr to string
	lodsb				; get next char
	mov	string,si		; save new ptr
	cmp	al,0			; done?
	jz	fldone			; jif yes
	call	fchar			; label the char
	add	x1,6			; move to next char space
	jmp	floop			; do next
;
fldone:
	pop	es
	pop	di
	pop	si
	pop	bp
	ret
;
;	cx = x1
;	dx = y1
;	si = char byte ptr
;	al = char byte
;
fchar:
	lea	si,chartab		; address of char data
	cbw
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	si,ax			; point to actual char data
	mov	cx,x1			; get top left x address
	mov	dx,y1			; get top left y address
	mov	byte ptr rowcnt,8	; # of rows of char data
bytloop:
	lodsb				; get next byte (row)
	mov	byte ptr colcnt,6	; # of cols per row
	shl	ax,1			; throw away leading blanks
if font1
	shl	ax,1
	shl	ax,1
endif
	push	si			; save char data ptr
bitloop:
	mov	ah,backclr		; default background color
	shl	al,1			; get the next bit
	jnc	flbc			; jif bit clear, use background color
	mov	ah,color		; else load foreground color
flbc:
	push	ax			; save rest of byte
	push	bx
	push	cx
	push	dx
	mov	bx,dx			; move y-coord
	mov	dl,ah			; move color
	mov	dh,rule			; get rule
	call	pixel			; plot it
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	inc	cx			; move to right one dot
	dec	byte ptr colcnt		; done with byte?
	jnz	bitloop			; jif no
	pop	si			; recover char data ptr
	sub	cx,6			; move back to left of space
	dec	dx			; move down a row
	dec	byte ptr rowcnt		; done with char?
	jnz	bytloop			; jif no
	ret
;
_iskey:
	mov	ah,1
	int	16h
	jnz	iskeyret
	mov	ax,0
iskeyret:
	ret
;
_key:
	mov	ah,0
	int	16h
	ret
	page
;
; movebytes(*to, *from, count);   for fast moving of a block of bytes
;
_movebytes:
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	di,[bp+4]		; get destination
	mov	si,[bp+6]		; get source
	mov	cx,[bp+8]		; get count
	or	cx,cx			; any to move?
	jz	mbdone			; jif no
	cmp	di,si			; to < from?
	ja	movrev			; jif no, negative move
	cld
movcom:
	rep	movsb
mbdone:
	cld
	pop	di
	pop	si
	pop	bp
	ret
;
movrev:
	add	si,cx			; move to other end
	add	di,cx
	dec	si
	dec	di
	std
	jmp	movcom
;
;
;
_text	ends
;
	end
