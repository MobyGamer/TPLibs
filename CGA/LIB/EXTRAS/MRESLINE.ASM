.model tpascal
.8086
.CODE
LOCALS

; mresline.asm - slight fixups by trixter@oldskool.org
;
;    Version 3.2m  DMD  Medium resolution graphics routine for drawing
;    April 30, 1986     lines on an IBMPC with the standard color
;                       graphics board.  Copyright (c) by David Dantowitz,
;                       April 30, 1986
;
;    This routine was written by David Dantowitz.  The routine
;    implements Bresenham's algorithm for line drawing.  
;
;    This routine may be used at the user's discretion for no charge
;    what so ever.  This software has been tested and should work
;    as documented, but no guarantees are made.  The user assumes
;    full responsibility for the assembly and use of this code.
;
;    Portions of this routine may be used in other contexts when proper
;    copyright and source identifications are made.  This code may
;    be modified to conform to other calling standards, but other
;    changes should be made only after consultation with the author.
;
;    This routine was written to be as general and as fast as possible,
;    any ideas for changes that result in improved speed would be 
;    appreciated by the author.  Support for other color graphics
;    boards is also possible and again the user is asked to contact
;    the author.
;
;
;    This implementation breaks lines into the following 8 categories,
;    the last four of which use Bresenham's algorithm.
;
;           horizontal
;           vertical
;           slope equal to 1
;           slope equal to -1
;           slope between 0 and 1
;           slope between 1 and infinity
;           slope between 0 and -1
;           slope between -1 and negative infinity
;
;    This routine does NOT check the points for bounds restrictions.
;    This is to enable well behaved software to run as fast as 
;    possible.  This routine is called by first pushing the X and
;    Y values for the first point and then the X and Y values for
;    the second point, and lastly the color for the line.
;    Note that the color is expected to be between 0 and 3.
;    Also note that all the parameters are words.
;
;
;    To use with TURBO Pascal you must assemble the file into a
;    .COM file.  To do this perfrom the following commands:
;
;    A> MASM MRESLINE;
;    A> LINK MRESLINE;
;    A> EXE2BIN MRESLINE.EXE MRESLINE.COM
;
;    When assembled into a .COM file (MRESLINE.ASM) this routine 
;    may be declared in TURBO Pascal with the following declaration:
;
;    PROCEDURE Med_res_line(X1, Y1, X2, Y2, Color : Integer); external 'mresline.com';
;           
;
;    Any suggestions for improvements are welcome and may be sent
;    to me at either of the addresses below.
;
;    David Dantowitz
;    Digital Equipment Corporation
;    Foster Street
;    LTN2-2/H07
;    Littleton, MA   01460
;
;    Dantowitz%Eagle1.DEC@decwrl.ARPA
;
;    The views and ideas expressed here are my own and do not
;    necessarily reflect those of the Digital Equipment Corporation.

public line_m

line_m proc far
arg @@X1:word,@@Y1:word,@@X2:word,@@Y2:word,@@Color:word

;  Save the base pointer
;
;        push bp
;        mov bp,sp
;
;  Get the two points
;
;        mov ax,[bp+12]   ;   X1
;        mov cx,[bp+10]   ;   Y1
;
;        mov bx,[bp+8]    ;   X2
;        mov dx,[bp+6]    ;   Y2

        mov ax,@@X1
        mov cx,@@Y1

        mov bx,@@X2
        mov dx,@@Y2

;  The difference between X1 and X2 will be represented as dX.
;  Likewise for Y1 and Y2 (dY).
;
;  Note: all lines are drawn with the X value increasing.
;       
;  If dX < 0 exchange the two points
;


	mov si,bx
      	sub si,ax        ; compute dX

	jg noswit	 ; If dX > 0 then don't switch the points


;
;  Switch the points and reverse the sign of dX (SI)
;
        neg si
	xchg ax,bx
	xchg cx,dx

noswit: mov bx,@@Color

        mov bp,dx
	sub bp,cx       ; compute dY

        xor di,di	; di = 0

;
;  All vertical lines are drawn with the Y value increasing.


        cmp si,di			; dX = 0 ?
        jne noswit_2                    ; not a vertical line


        cmp bp,di  			; dY > 0 ?
        jg noswit_2			; no need to switch points

        mov cx,dx			; Just copy lower value, the higher
                    			; value is implied by dY.

        neg bp	      			; Change the sign of dY

noswit_2:

; Compute the address of the first byte

;
; AX = initial X
; BX = color
; CX = initial Y
; SI = dX                                       
; BP = dY
;

        mov dx,cx      			; DX = starting Y

        and dl,0feh			; DX = (Y DIV 2) * 2

        mov di,dx			; DI = DX

        shl dx,1			; DX = 4 * DX
        shl dx,1                                     

        add di,dx			; DI = DI + DX  {DI = 5 * (Y DIV 2) * 2)}

        shl di,1			; DI = 8 * DI
        shl di,1
        shl di,1
                                                     
; 
;
;   Note that DI presently is equal to 80 * (Y DIV 2) ... the first byte
;   on the raster line that contains the first pixel of the line.
;

;
;   (Screen memory for graphics is divided into two sections.  The even
;   raster lines have addresses 0 to 1F3Fh (80 bytes/line * 100 lines).
;   The odd raster lines have addresses 2000h to 3F3Fh.  Thus all lines
;   with odd Y coordinates have the 2000h bit set.
;


;   If odd then start in the second bank, otherwise start in the first bank.

        shr cl,1		
        jnc t1
        xor di,2000h


t1:     mov cl,al			; Save the low byte of X

        shr ax,1			; AX = X DIV 4
        shr ax,1

        add di,ax			; DI = DI + AX

; Note that DI now points to the byte that contains the first pixel


;
;   Save the data segment register.  Also load up the screen segment
;   register value into DS and ES.
;

        push ds
        mov ax,0b800h
        mov ds,ax			; Used for screen access
        mov es,ax			; Used for horizontal lines

;
;   DI now points to the first byte, but which bits are the first pixel ?
;   the low bits of CL (low bits of X) will tell us.
;
;
;   This sets up the single pixel mask.

        and cl,3			; Just the low 2 bits

        shl cl,1			; two bits/pixel

;
;
;   C0 marks the first pixel
;   30 marks the second pixel
;   0C marks the third pixel
;   03 marks the forth pixel
;

        mov ah,0C0h			; first bit position

        shr ah,cl			; shift appropriately


;
;  We now set up the color mask, it has the following format:
;
;    bits :  7 6 5 4 3 2 1 0
;            C c C c C c C c
;
;  Where "C c" are the two bits used to specify the color of the pixel.
;
;
        mov al,bl			; starting color 
					; AL = 000000Cc

        shl al,1
        shl al,1
        or al,bl			; AL = 0000CcCc

        shl al,1
        shl al,1
        or al,bl			; AL = 00CcCcCc

        shl al,1
        shl al,1
        or al,bl			; AL = CcCcCcCc

        xor bx,bx			; BX = 0
;        
; AH = pixel mask (which pixel within a byte)
; AL = color mask
; BX = 0
; CL = low two bits of X shifted one bit to the left 
;      (used later for horizontal lines)
; SI = dX
; BP = dY
; DI = points to the byte containing the first pixel
;

        cmp si,bx		    	; dX = 0 ?
        je vertical			; The line is vertical


;
;   Here we know that dX is positive, so the sign of dY will
;   tell us the sign of the line's slope.
;  
        cmp bp,bx			; sign of dY ? 

        je horizontal 			; 0 ... horizontal line

	jg Slope_gtr_a			; slope > 0

        jmp Slope_less			; slope < 0

Slope_gtr_a:          			; extra jump due to long distance
        jmp Slope_gtr

;
;   Version, author identification and copyright notice
;
        db 'Portions Copyright David Dantowitz'


vertical label near
;
;   Vertical lines are drawn in two parts, the even rasters, then the odd
;   rasters.  (Note the order is dependent on the line's starting point.)
;

        mov cx,bp			; # points = dY + 1
        inc cx

        mov bp,80			; a constant (# bytes/raster)

        shr cx,1   	                ; divide in two (carry set if odd)
        mov dx,cx 	                ; save count (second half)

        adc cx,bx                       ; add the carry (bx=0)
        mov si,di     	                ; save starting point


        mov bh,ah			; pixel mask

        and bh,al                       ; get the color

        not ah				; old pixel mask (unchanged pixels)
 
        cmp dx,0			; If DX = 0 then there is only one point
        je second_bank			; don't draw in odd and even, just one.


;
;  Note that the code below is repeated in a similar fashion for most
;  of the actual pixel writing.  This code is only commented once.
;
        
first_bank:
        mov bl,ah			; copy the old pixel mask

        and bl,[di]			; clear new pixel

        or bl,bh			; add new pixel color
 
        mov [di],bl       		; save byte

        add di,bp			; next line

	loop first_bank

        xor si,2000h			; change the bank
        mov cx,dx


        cmp si,2000h   			; if second bank is even then
        jge second_bank			; go to the next raster.

        add si,bp
        
second_bank:

        mov bl,ah			; copy the old pixel mask

        and bl,[si]			; clear new pixel

        or bl,bh			; add new pixel color

        mov [si],bl       		; save byte

        add si,bp			; next line

	loop second_bank

	jmp ret_line        
      

horizontal label near

;
;  Horizontal lines are drawn mostly using the STOSW instruction.
;  Only the ends are drawn with explicit code.  Most of the code 
;  in this routine deals with words, not bytes. 
;
        
;        As a reminder
;
; AH = pixel mask (which pixel within a byte)
; AL = color mask
; BX = 0
; CL = low two bits of X shifted one bit to the left 
;      (used here for horizontal lines)
; SI = dX
; BP = dY
; DI = points to the byte containing the first pixel
;

;
;  If this is a short line then go to special set up code.
;
        cmp si,3			; If dX = 1 or 2 then short_horiz
        jl short_horiz 			; (dX = 0 is a vertical line)

        inc si				; # points = dX + 1

        mov ch,bh                       ; (bh = 0)
        shr cx,1                        ; shift back (see note above)
        sub cx,4

;
;  CX = -(the number of pixels in the first byte)
;
        add si,cx                       ; sub the first byte's pixels from
					; the total count
        
;
;  We now set up a pixel mask for the first byte's pixels in AH
;
;  old AH   new AH
;    C0       FF
;    30       3F
;    0C       0F
;    03       03
;
 

        shl ah,1
        mov cl,ah
        dec ah                   
        xor ah,cl
        

;
;  Set up the masks and write the pixels in the first byte
;

        mov bl,ah
        not bl
        and ah,al
        

        and bl,[di]
        or bl,ah
        mov [di],bl

        inc di				; point to the next byte
 

        mov ah,al			; AX = CcCcCcCcCcCcCcCc 
					; (a word color mask)
                                        
        mov cx,7
        and cx,si                       ; CX = how many extra pixels 
                                        ;      in the last word
                                        
        jnz h_4				; If not 0 
    

;
;  The number of remaining pixels is a multiple of 8, the number of
;  pixels in a word.
;

        mov cx,si			; # pixels

        shr cx,1
        shr cx,1
        shr cx,1			; CX = # pixels DIV 8
        
h_2:    cld				; set direction to increase

rep     stosw 				; save the pixels

        jmp ret_line			


;
;  Special initialization code for two or three pixel lines
;
;

short_horiz:

        mov bh,ah			; BH = AH (pixel mask)
					; BL = 0

        mov dx,bx			; Save it in DX
        mov cx,si

;
;  Now make a mask for all two or three pixels
;
s_l:    shr bx,1
        shr bx,1
        or dx,bx
        loop s_l

;
;  DX = the pixel mask for the last few pixels
;

        mov ah,al			; AX = CcCcCcCcCcCcCcCc 
					; (a word color mask)
                                        
        jmp h_3



h_4:
;
; CX = the number of pixels in the last word
;

;
;  Set up the pixel mask for the last work of pixels
;

        mov dx,0C000h                   ; Initial mask

        dec cl   			; Create the mask
        shl cl,1
        sar dx,cl

;
;  Write as many pixels as possible in multiples of 8, the number
;  of pixels in a word.
;

        mov cx,si			; # pixels

        shr cx,1
        shr cx,1
        shr cx,1			; CX = # pixels DIV 8


        jcxz h_3			; less than 8 pixels left 
					; (no full words)
        
        cld				; set direction to increase

rep     stosw 				; save the pixels


        
h_3: 

;
;  last word of pixels
;

;  
;  DX = last word pixel mask
;  AX = color mask
;  DI = address of last word
;

        xchg dh,dl			; swap low and high bytes

        mov bx,dx			; unchanged mask
        not bx

        and dx,ax			; colors

        and bx,[di]			; clear new save others

        or bx,dx			; add new pixels

        mov [di],bx			; save pixels

        jmp ret_line        

        
Slope_gtr:

;        As a reminder
;
; AH = pixel mask (which pixel within a byte)
; AL = color mask
; BX = 0
; SI = dX
; BP = dY
; DI = points to the byte containing the first pixel
;


;   Slope > 0
;
;   From here we distinguish between slope < 1 and slope > 1
;
;
	cmp bp,si
	jg Slope_gtr_1
        jne Slope_less_1
        jmp Slope_1

Slope_less_1:

;
;   The slope is less than 1 and greater than 0.  On each iteration
; of the loop we increment X.  Depending on the value of the decision
; variable (DX) we may or may not increment Y.
;
                                                            
	mov cx,si			; # points = dX + 1
        inc cx   

;
;  Initialize the decision variables.
;
	shl bp,1			; BP = 2 * dY
	mov dx,bp			; DX = 2 * dY       
	sub dx,si			; DX = 2 * dY - dX
	neg si				; SI = -dX
	shl si,1			; SI = -2 * dX
	add si,bp			; SI = 2 * (dY - dX)

pix1:	or bh,ah                        ; Add next pixel

        ror ah,1			; shift mask to next pixel
        ror ah,1

        jc t1_6                         ; End of the byte ... write it


	cmp dh,bl                       ; Test the decision variable
					; Note BL = 0
	jge t1_5

	add dx,bp			; Change decision variable
	loop pix1

	jmp final_dots
        
t1_5:   mov bl,bh                       ; write this byte
        not bl
        and bh,al
        
        and bl,[di]
        or bl,bh
        mov [di],bl

        xor bx,bx			; BX = 0


t1_3:   xor di,2000h                    ; Switch banks ?
        cmp di,2000h
        jge t1_4

        add di,80			; increment Y
        
t1_4:	add dx,si
	loop pix1
	jmp ret_line

t1_6:   mov bl,bh			; write this byte
        not bl
        and bh,al
        

        and bl,[di]
        or bl,bh
        mov [di],bl
        inc di
        xor bx,bx			; BX = 0

	cmp dh,bl                       ; Test the decision variable
					; Note BL = 0
        jge t1_3

        add dx,bp
        loop pix1                
        jmp ret_line


Slope_gtr_1:

;        As a reminder
;
; AH = pixel mask (which pixel within a byte)
; AL = color mask
; BX = 0
; SI = dX
; BP = dY
; DI = points to the byte containing the first pixel
;

;
;     The slope is greater than 1.  On each iteration of the loop we 
;   increment Y.  Depending on the value of the decision variable (DX) 
;   we may or may not increment X.
;
	mov cx,bp                	; # points = dY + 1
	inc cx                                             

	shl si,1			; SI = 2 * dX
	mov dx,si                       ; SI = 2 * dX
	sub dx,bp			; DX = 2 * dX - dY
	neg bp                          ; BP = -dY
	shl bp,1			; BP = -2 * dY
	add bp,si			; BP = 2 * (dX - dY)
                                                            
        mov bh,ah			; Set up the masks 
        and bh,al			; (they do not change)
        mov al,ah
        not al

;
; AL = unchanged pixel mask
; AH = pixel mask (used as a rotating counter here)
; BH = color mask
; 

pix2:	mov bl,al			; write the pixel

        and bl,[di]
        or bl,bh
        mov [di],bl       


        xor di,2000h			; Change banks
        cmp di,2000h

        jge t2_1

        add di,80			; next Y

t2_1:   cmp dx,0			; Check decision variable
        jge t2_2
        
        add dx,si

        loop pix2
        jmp ret_line
        
t2_2:   ror al,1			; increment X and rotate masks
        ror bh,1
        ror ah,1

        ror al,1
        ror bh,1
        ror ah,1

        adc di,0			; if masks wrap around go to next
					; byte

        add dx,bp
        loop pix2
        jmp ret_line
        
        

Slope_less:

	neg bp				; make dY > 0

        cmp bp,si			; (note: we know that dX > 0)

        jg case4                        ; slope < -1

        jne not_meqn1			; slope > -1

        jmp Slope_neg_1			; slope = -1


not_meqn1:

;
;  This section of the code is almost the same as for slope < 1 (above).
;  The only difference is that here Y is decremented, instead of 
;  incremented.
;

        mov cx,si
        inc cx
        shl bp,1
        mov dx,bp
        sub dx,si
        neg si
        shl si,1
        add si,bp
        

pix3:   or bh,ah
        ror ah,1
        ror ah,1
        jc t3_6

	cmp dh,bl
	jge t3_5

	add dx,bp
	loop pix3
	jmp final_dots
        
t3_5:   mov bl,bh
        not bl
        and bh,al
        
        and bl,[di]
        or bl,bh
        mov [di],bl
        xor bx,bx


t3_3:   xor di,2000h			; here's the difference !
        cmp di,2000h

        jl t3_4

        sub di,80
        
t3_4:	add dx,si
	loop pix3
	jmp ret_line


t3_6:   mov bl,bh
        not bl
        and bh,al
        

        and bl,[di]
        or bl,bh
        mov [di],bl
        inc di
        xor bx,bx

        cmp dh,bl
        jge t3_3
        add dx,bp
        loop pix3
        jmp ret_line


case4:

;
;  This section of the code is almost the same as for slope > 1 (above).
;  The only difference is that here Y is decremented, instead of 
;  incremented.
;

	mov cx,bp
        inc cx
        shl si,1
        mov dx,si
        sub dx,bp
        neg bp
        shl bp,1
        add bp,si

        mov bh,ah
        and bh,al
        mov al,ah
        not al

pix4:	mov bl,al
        
        and bl,[di]
        or bl,bh
        mov [di],bl       


        xor di,2000h			; here's the difference !
        cmp di,2000h

        jl t4_1

        sub di,80

t4_1:   cmp dx,0
        jge t4_2
        
        add dx,si
        loop pix4
        jmp ret_line
        
t4_2:   ror al,1
        ror bh,1
        ror ah,1

        ror al,1
        ror bh,1
        ror ah,1

        adc di,0
        add dx,bp
        loop pix4
        jmp ret_line
        
        
Slope_1 label near

;
;  The slope is 1.
;

        mov cx,si			; # points = dX + 1
        inc cx

        xor si,si			; SI = 0

        mov dx,2000h			; constants
        mov bp,80

        mov bh,ah			; set up initial masks
        and bh,al
        mov al,ah
        not al


meq1_next:
	mov bl,al
        
        
        and bl,[di]
        or bl,bh
        mov [di],bl       


        xor di,dx			; Bank testing
        test di,dx

        jne meq1_1

        add di,bp

meq1_1: ror al,1			; similar to code above
        ror bh,1
        ror ah,1

        ror al,1
        ror bh,1
        ror ah,1

        adc di,si

        loop meq1_next
	jmp ret_line
        


Slope_neg_1 label near


;
;  This section of the code is almost the same as for slope = -1 (above).
;  The only difference is that here Y is decremented, instead of 
;  incremented.
;


        mov cx,si
        inc cx

        xor si,si

        mov dx,2000h
        mov bp,80
        
        mov bh,ah
        and bh,al
        mov al,ah
        not al


meqn1_next:
	mov bl,al
        
        and bl,[di]
        or bl,bh
        mov [di],bl       


        xor di,dx			; Here's the difference !
        test di,dx
        je meqn1_1
        sub di,bp

meqn1_1:
        ror al,1
        ror bh,1
        ror ah,1

        ror al,1
        ror bh,1
        ror ah,1

        adc di,si

        loop meqn1_next
	jmp ret_line        


final_dots label near

;
;  This code writes the pixels that remain in the BH register.
;

;
;  BH = pixel buffer
;  BL = 0
;  AL = color mask
;  DI = points to the byte containing the pixels
;
        
        cmp bh,bl
        je ret_line
        mov bl,bh
        not bl
        and bh,al
        
        and bl,[di]
        or bl,bh
        mov [di],bl       

ret_line label near

        pop ds                          ; Restore the registers
;        pop bp
;        ret 0AH                         ; remove arguments from the stack
        ret

endp line_m

CODE ENDS
     END

