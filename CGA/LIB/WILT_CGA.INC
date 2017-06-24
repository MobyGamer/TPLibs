{
The great majority of this code comes from Richard Wilton's excellent book
"Programmer's Guide to PC & PS/2 Video Systems".
Translation, notes, and optimization by trixter@oldskool.org.

The routines here could be further optimized by using a pre-built table
of scanline offsets.  The method used in the "PixelAddr" routines takes
at least 15 cycles @ 12 bytes; however, a "mov bx,linenum;xlat" would take
11 cycles and only one byte.  I leave this as an exercise to the reader as
I have other fish to fry right now :-)
}

const
  OriginOffset=0;
  VideoBufferSeg=$b800;

Procedure mode4_PixelAddr_direct;assembler;
{
Determines buffer address of pixel in 320x200 4-color mode
Caller:
  AX = y-coordinate (0-199)
  BX = x-coordinate (0-319)

Returns:
  AH = bit mask
  BX = byte offset in buffer
  CL = number of bits to shift left
  ES = video buffer segment
}
asm
  mov     cl,bl           { CL := low-order byte of x}
  xchg    ah,al           { AX := 100h * y}
  shr     ax,1            { AL := 80h * (y&1)}
  add     bh,al           { BX := x + 8000h*(y&1)}
  xor     al,al           { AX := 100h*(y/2)}
  add     bx,ax           { BX := x + 8000h*(y&1) + 100h*(y/2)}
  shr     ax,1
  shr     ax,1            { AX := 40h*(y/2)}
  add     bx,ax           { BX := x + 8000h*(y&1) + 140h*(y/2)}
  shr     bx,1
  shr     bx,1            { BX := x/4 + 2000h*(y&1) + 50h*(y/2)}
  add     bx,OriginOffset { BX := byte offset in video buffer}
  mov     ax,VideoBufferSeg
  mov     es,ax           { ES:BX := byte address of pixel}
  mov     ah,3            { AH := unshifted bit mask}
  and     cl,ah           { CL := x & 3}
  xor     cl,ah           { CL := 3 - (x & 3)}
  shl     cl,1            { CL := # bits to shift left}
end;

Procedure mode6_PixelAddr_direct;assembler;
{
Determines buffer address of pixel in 640x200 2-color mode
Caller:
  AX = y-coordinate (0-199)
  BX = x-coordinate (0-639)

Returns:
  AH = bit mask
  BX = byte offset in buffer
  CL = number of bits to shift left
  ES = video buffer segment
}
asm
  mov     cl,bl           { CL := low-order byte of x}
  xchg    ah,al           { AX := 100h * y}
  shr     bx,1            { BX := x/2}
  shr     ax,1            { AL := 80h*(y&1)}
  add     bh,al           { BX := x/2 + 8000h*(y&1)}
  xor     al,al           { AX := 100h*(y/2)}
  add     bx,ax           { BX := x/2 + 8000h*(y&1) + 100h*(y/2)}
  shr     ax,1
  shr     ax,1            { AX := 40h*(y/2)}
  add     bx,ax           { BX := x/2 + 8000h*(y&1) + 140h*(y/2)}
  shr     bx,1
  shr     bx,1            { BX := x/8 + 2000h*(y&1) + 50h*(y/2)}
  add     bx,OriginOffset { BX := byte offset in video buffer}
  mov     ax,VideoBufferSeg
  mov     es,ax           { ES:BX := byte address of pixel}
  and     cl,7            { CL := x & 7}
  xor     cl,7            { CL := number of bits to shift left}
  mov     ah,1            { AH := unshifted bit mask}
end;

Procedure mode4_SetPixel_direct(x,y:word;color:byte);assembler;
asm
   mov   ax,y
   mov   bx,x
   call  mode4_PixelAddr_direct {AH = bit mask, ES:BX -> buffer, CL = #bits to shift left}
   mov   al,color {AH = bitmask, AL = color}
   shl   ax,cl {AH = bit mask in proper position, AL = pixel value in proper position}
   not   ah {AH = inverse bit mask}
   and   es:[bx],ah {zero the pixel value}
   or    es:[bx],al {set the pixel value}
   {Note the direct es:[bx] access -- if it were to happen MORE than twice,
   it would be better to load into a register, do the operations, and
   then put back.  But we're doing only two, so I'm pretty sure this is faster.}
end;

Procedure mode6_SetPixel_direct(x,y:word;color:byte);assembler;
asm
   mov   ax,y
   mov   bx,x
   call  mode6_PixelAddr_direct {AH = bit mask, ES:BX -> buffer, CL = #bits to shift left}
   mov   al,color {AH = bitmask, AL = color}
   shl   ax,cl {AH = bit mask in proper position, AL = pixel value in proper position}
   not   ah {AH = inverse bit mask}
   and   es:[bx],ah {zero the pixel value}
   or    es:[bx],al {set the pixel value}
   {Note the direct es:[bx] access -- if it were to happen MORE than twice,
   it would be better to load into a register, do the operations, and
   then put back.  But we're doing only two, so I'm pretty sure this is faster.}
end;

Procedure mode6_line_direct(x1,y1,x2,y2:integer;color:byte);
{
Most of the execution time in this routine is spent in the inner loops
of the four line-drawing modules. To optimize the speed of the inner
loops, as much computation as possible is performed outside of them.
In particular, the inner loop of HorizLine06 (at label @L43) is very
fast because it consists only of a single 80x86 machine instruction.

The routines LoSlopeLine06 and HiSlopeLine06 implement Bresenham's
algorithm. The inner loop of HiSlopeLine06 (at @L21) is simpler than
the inner loop of LoSlopeLine06 (at @L11). This is because
HiSlopeLine06 increments the pixel y-coordinate, and thus the buffer
offset, on every iteration, so the only other code needed in the loop
is the code to increment the decision variable and update the pixel
bit mask. In LoSlopeLine06, the x-coordinate is incremented on each
iteration by rotating the pixel bit mask. This necessitates some extra
code to update the bit mask and buffer offset in accordance with the
decision variable's value.

The routine for 320-by-200 4-color mode, shown in the next procedure,
similar to the one for 640-by-200 2-color mode. In fact, you could
write a single routine that works in either mode without undue
sacrifice in performance. The differences lie in how the address of
the first pixel in the line is calculated (that is, a call to
PixelAddr04 versus one to PixelAddr06) and in how many bits are masked
and updated for each pixel in the buffer. The bit mask is 1 bit wide
in 640-by-200 2-color mode and 2 bits wide in 320-by-200 4-color mode.

On the CGA, the code that handles vertical increments is complicated
by the need to step across the interleaves in the video buffer. The
pixel address is incremented by 2000H to move from the first
interleave (even y-coordinates) to the second interleave (odd y-
coordinates). To increment from a pixel at an odd y-coordinate to the
pixel just below it, you add -2000H (to increment from the second to
the first interleave) plus 80 (the number of bytes in each pixel row
in the buffer). The increment is thus 0E050H (80 - 2000H).

(Another technique of determining the proper offset, if you think you
can optimize for it, is to switch between b800h and ba00h for the two banks.
Finally, it might be worth looking into the possibility of using a table of
200 words with a precalc'd table of offsets to be used with XLAT.)
}

var
  VARleafincr,
  VARincr1,
  VARincr2,
  VARroutine:word;

const
  ByteOffsetShift=3; {used to convert pixels to byte offset}
  PropagatedPixel:array[0..1] of byte = (
    0,   {00000000}
    255  {11111111}
  );

begin
  asm
    mov     si,2000h        { increment for video buffer interleave}
    mov     di,80-2000h     { increment from last to first interleave}

    mov     cx,x2
    sub     cx,x1        { CX := x2 - x1}
    jz      @VertLine06      { jump if vertical line}

{ force x1 < x2}

    jns     @L01             { jump if x2 > x1}

    neg     cx              { CX := x1 - x2}

    mov     bx,x2        { exchange x1 and x2}
    xchg    bx,x1
    mov     x2,bx

    mov     bx,y2        { exchange y1 and y2}
    xchg    bx,y1
    mov     y2,bx

{ calculate dy = ABS(y2-y1)}

@L01:
    mov     bx,y2
    sub     bx,y1        { BX := y2 - y1}
    jnz     @L02

    jmp     @HorizLine06     { jump if horizontal line}

@L02:
    jns     @L03

    neg     bx              { BX := y1 - y2}
    neg     si              { negate increments for buffer interleave}
    neg     di
    xchg    si,di           { exchange increments}

{ select appropriate routine for slope of line}

@L03:
    mov     VARleafincr,di  { save increment for buffer interleave}

    mov     VARroutine,offset @LoSlopeLine06
    cmp     bx,cx
    jle     @L04             { jump if dy <= dx (slope <= 1)}
    mov     VARroutine,offset @HiSlopeLine06
    xchg    bx,cx           { exchange dy and dx}

{ calculate initial decision variable and increments}

@L04:
    shl     bx,1            { BX := 2 * dy}
    mov     VARincr1,bx     { incr1 := 2 * dy}
    sub     bx,cx
    mov     di,bx           { DI := d = 2 * dy - dx}
    sub     bx,cx
    mov     VARincr2,bx     { incr2 := 2 * (dy - dx)}

{ calculate first pixel address}

    push    cx              { preserve this register}
    mov     ax,y1        { AX := y}
    mov     bx,x1        { BX := x}
    call    mode6_PixelAddr_direct     { AH := bit mask}
                            { ES:BX -> buffer}
                            { CL := # bits to shift left}

    mov     al,color         { AL := unshifted pixel value}
    shl     ax,cl           { AH := bit mask in proper position}
                            { AL := pixel value in proper position}

    mov     dx,ax           { DH := bit mask}
                            { DL := pixel value}
    not     dh              { DH := inverse bit mask}

    pop     cx              { restore this register}
    inc     cx              { CX := # of pixels to draw}

    test    bx,2000h        { set zero flag if BX in 1st interleave}
    jz      @L05

    xchg    si,VARleafincr  { exchange increment values if 1st pixel}
                            {  lies in 1st interleave}

@L05:
    jmp     VARroutine      { jump to appropriate routine for slope}


{ routine for vertical lines}

@VertLine06:
    mov     ax,y1        { AX := y1}
    mov     bx,y2        { BX := y2}
    mov     cx,bx
    sub     cx,ax           { CX := dy}
    jge     @L31             { jump if dy >= 0}

    neg     cx              { force dy >= 0}
    mov     ax,bx           { AX := y2}

@L31:
    inc     cx              { CX := # of pixels to draw}
    mov     bx,x1        { BX := x}
    push    cx              { preserve this register}
    call    mode6_PixelAddr_direct { AH := bit mask}
                            { ES:BX -> video buffer}
                            { CL := # bits to shift left}
    mov     al,color        { AL := pixel value}
    shl     ax,cl           { AH := bit mask in proper position}
                            { AL := pixel value in proper position}
    not     ah              { AH := inverse bit mask}
    pop     cx              { restore this register}

    test    bx,si           { set zero flag if BX in 1st interleave}
    jz      @L32

    xchg    si,di           { exchange increment values if 1st pixel}
                            {  lies in 1st interleave}

@L32:
    test    al,al
    jz      @L34             { jump if pixel value = 0}

@L33:
    or      es:[bx],al      { set pixel values in buffer}
    add     bx,si           { increment to next portion of interleave}
    xchg    si,di           { toggle between increment values}
    loop    @L33             { loop down the line}
    jmp     @L35

@L34:
    and     es:[bx],ah      { reset pixel values in buffer}
    add     bx,si           { increment to next portion of interleave}
    xchg    si,di           { toggle between increment values}
    loop    @L34

@L35:            jmp     @Lexit


{ routine for horizontal lines (slope = 0)}

@HorizLine06:
    mov     ax,y1
    mov     bx,x1
    call    mode6_PixelAddr_direct { AH := bit mask}
                            { ES:BX -> video buffer}
                            { CL := # bits to shift left}
    mov     di,bx           { ES:DI -> buffer}

    mov     dh,ah
    not     dh              { DH := unshifted bit mask for leftmost}
                            {        byte}
    mov     dl,0FFh         { DL := unshifted bit mask for}
                            {        rightmost byte}

    shl     dh,cl           { DH := reverse bit mask for first byte}
    not     dh              { DH := bit mask for first byte}

    mov     cx,x2
    and     cl,7
    xor     cl,7            { CL := number of bits to shift left}
    shl     dl,cl           { DL := bit mask for last byte}

{ determine byte offset of first and last pixel in the line}

    mov     ax,x2        { AX := x2}
    mov     bx,x1        { BX := x1}

    mov     cl,ByteOffsetShift      { number of bits to shift to    }
                                    {  convert pixels to bytes}

    shr     ax,cl           { AX := byte offset of x2}
    shr     bx,cl           { BX := byte offset of x1}
    mov     cx,ax
    sub     cx,bx           { CX := (# bytes in line) - 1}

{ propagate pixel value throughout one byte}

    mov     bx,offset PropagatedPixel
    mov     al,color        { AL := pixel value}
    xlat

{ set pixels in leftmost byte of the line}

    or      dh,dh
    js      @L43             { jump if byte-aligned (x1 is leftmost}
                            {  pixel in byte)}
    or      cx,cx
    jnz     @L42             { jump if more than one byte in the line}

    and     dl,dh           { bit mask for the line}
    jmp     @L44

@L42:
    mov     ah,al
    and     ah,dh           { AH := masked pixel bits}
    not     dh              { DH := reverse bit mask for 1st byte}
    and     es:[di],dh      { zero masked pixels in buffer}
    or      es:[di],ah      { update masked pixels in buffer}
    inc     di
    dec     cx

{ use a fast 8086 machine instruction to draw the remainder of the line}

@L43:
    shr    cx,1  {prepare for stosw}
    mov    ah,al {prepare for stosw}
    rep    stosw {update all pixels in the line}
    jnc    @L44  {if no carry, # pixels was even so keep going...}
    stosb        {if carry, spit out the last byte}

{ set pixels in the rightmost byte of the line}

@L44:
    and     al,dl           { AL := masked pixels for last byte}
    not     dl
    and     es:[di],dl      { zero masked pixels in buffer}
    or      es:[di],al      { update masked pixels in buffer}

    jmp     @Lexit


{ routine for dy <= dx (slope <= 1)}     { ES:BX -> video buffer}
                            { CX = # pixels to draw}
                            { DH = inverse bit mask}
                            { DL = pixel value in proper position}
                            { SI = buffer interleave increment}
                            { DI = decision variable}
@LoSlopeLine06:

@L10:
    mov     ah,es:[bx]      { AH := byte from video buffer}

@L11:
    and     ah,dh           { zero pixel value at current bit offset}
    or      ah,dl           { set pixel value in byte}

    ror     dl,1            { rotate pixel value}
    ror     dh,1            { rotate bit mask}
    jnc     @L14             { jump if bit mask rotated to}
                            {  leftmost pixel position}

{ bit mask not shifted out}

    or      di,di           { test sign of d}
    jns     @L12             { jump if d >= 0}

    add     di,VARincr1     { d := d + incr1}
    loop    @L11

    mov     es:[bx],ah      { store remaining pixels in buffer}
    jmp     @Lexit

@L12:
    add     di,VARincr2     { d := d + incr2}
    mov     es:[bx],ah      { update buffer}

    add     bx,si           { increment y}
    xchg    si,VARleafincr  { exchange interleave increment values}
    loop    @L10
    jmp     @Lexit

{ bit mask shifted out}

@L14:
    mov     es:[bx],ah      { update buffer}
    inc     bx              { BX := offset of next byte}

    or      di,di           { test sign of d}
    jns     @L15             { jump if non-negative}

    add     di,VARincr1     { d := d + incr1}
    loop    @L10
    jmp     @Lexit

@L15:
    add     di,VARincr2     { d := d + incr2}

    add     bx,si           { increment y}
    xchg    si,VARleafincr

    loop    @L10
    jmp     @Lexit


{ routine for dy > dx (slope > 1) }      { ES:BX -> video buffer}
                            { CX = # pixels to draw}
                            { DH = inverse bit mask}
                            { DL = pixel value in proper position}
                            { SI = buffer interleave increment}
                            { DI = decision variable}
@HiSlopeLine06:

@L21:
    and     es:[bx],dh      { zero pixel value in video buffer}
    or      es:[bx],dl      { set pixel value in byte}

    add     bx,si           { increment y}
    xchg    si,VARleafincr  { exchange interleave increment values}

@L22:
    or      di,di           { test sign of d}
    jns     @L23             { jump if d >= 0}

    add     di,VARincr1     { d := d + incr1}
    loop    @L21

    jmp     @Lexit


@L23:
    add     di,VARincr2     { d := d + incr2}

    ror     dl,1            { rotate pixel value}
    ror     dh,1            { rotate bit mask}
    cmc                     { cf set if bit mask not rotated to}
                            {  leftmost pixel position}

    adc     bx,0            { BX := offset of next byte}

    loop    @L21

@Lexit:
  end;
end;

Procedure mode4_line_direct(x1,y1,x2,y2:integer;color:byte);

var
  VARleafincr,
  VARincr1,
  VARincr2,
  VARroutine:word;

const
  ByteOffsetShift=2; {used to convert pixels to byte offset}
  PropagatedPixel:array[0..3] of byte = (
    0,   {00000000}
    85,  {01010101}
    170, {10101010}
    255  {11111111}
  );

begin
  asm
    mov     si,2000h        { increment for video buffer interleave}
    mov     di,80-2000h     { increment from last to first interleave}

    mov     cx,x2
    sub     cx,x1        { CX := x2 - x1}
    jz      @VertLine04      { jump if vertical line}

{ force x1 < x2}

    jns     @L01             { jump if x2 > x1}

    neg     cx              { CX := x1 - x2}

    mov     bx,x2        { exchange x1 and x2}
    xchg    bx,x1
    mov     x2,bx

    mov     bx,y2        { exchange y1 and y2}
    xchg    bx,y1
    mov     y2,bx

{ calculate dy = ABS(y2-y1)}

@L01:
    mov     bx,y2
    sub     bx,y1        { BX := y2 - y1}
    jnz     @L02

    jmp     @HorizLine04     { jump if horizontal line}

@L02:
    jns     @L03

    neg     bx              { BX := y1 - y2}
    neg     si              { negate increments for buffer interleave}
    neg     di
    xchg    si,di           { exchange increments}

{ select appropriate routine for slope of line}

@L03:
    mov     VARleafincr,di  { save increment for buffer interleave}

    mov     VARroutine,offset @LoSlopeLine04
    cmp     bx,cx
    jle     @L04             { jump if dy <= dx (slope <= 1)}
    mov     VARroutine,offset @HiSlopeLine04
    xchg    bx,cx           { exchange dy and dx}

{ calculate initial decision variable and increments}

@L04:
    shl     bx,1            { BX := 2 * dy}
    mov     VARincr1,bx     { incr1 := 2 * dy}
    sub     bx,cx
    mov     di,bx           { DI := d = 2 * dy - dx}
    sub     bx,cx
    mov     VARincr2,bx     { incr2 := 2 * (dy - dx)}

{ calculate first pixel address}

    push    cx              { preserve this register}
    mov     ax,y1        { AX := y}
    mov     bx,x1        { BX := x}
    call    mode4_PixelAddr_direct { AH := bit mask}
                            { ES:BX -> buffer}
                            { CL := # bits to shift left}

    mov     al,color         { AL := unshifted pixel value}
    shl     ax,cl           { AH := bit mask in proper position}
                            { AL := pixel value in proper position}

    mov     dx,ax           { DH := bit mask}
                            { DL := pixel value}
    not     dh              { DH := inverse bit mask}

    pop     cx              { restore this register}
    inc     cx              { CX := # of pixels to draw}

    test    bx,2000h        { set zero flag if BX in 1st interleave}
    jz      @L05

    xchg    si,VARleafincr  { exchange increment values if 1st pixel}
                            {  lies in 1st interleave}

@L05:
    jmp     VARroutine      { jump to appropriate routine for slope}


{ routine for vertical lines}

@VertLine04:
    mov     ax,y1        { AX := y1}
    mov     bx,y2        { BX := y2}
    mov     cx,bx
    sub     cx,ax           { CX := dy}
    jge     @L31             { jump if dy >= 0}

    neg     cx              { force dy >= 0}
    mov     ax,bx           { AX := y2}

@L31:
    inc     cx              { CX := # of pixels to draw}
    mov     bx,x1        { BX := x}
    push    cx              { preserve this register}
    call    mode4_PixelAddr_direct     { AH := bit mask}
                            { ES:BX -> video buffer}
                            { CL := # bits to shift left}
    mov     al,color         { AL := pixel value}
    shl     ax,cl           { AH := bit mask in proper position}
                            { AL := pixel value in proper position}
    not     ah              { AH := inverse bit mask}
    pop     cx              { restore this register}

    test    bx,si           { set zero flag if BX in 1st interleave}
    jz      @L32

    xchg    si,di           { exchange increment values if 1st pixel}
                            {  lies in 1st interleave}

@L32:
    and     es:[bx],ah      { zero pixel in buffer}
    or      es:[bx],al      { set pixel value in buffer}

    add     bx,si           { increment to next portion of interleave}
    xchg    si,di           { toggle between increment values}

    loop    @L32

    jmp     @Lexit



{ routine for horizontal lines (slope = 0)}

@HorizLine04:
    mov     ax,y1
    mov     bx,x1
    call    mode4_PixelAddr_direct     { AH := bit mask}
                            { ES:BX -> video buffer}
                            { CL := # bits to shift left}
    mov     di,bx           { ES:DI -> buffer}

    mov     dh,ah
    not     dh              { DH := unshifted bit mask for leftmost}
                            {        byte}
    mov     dl,0FFh         { DL := unshifted bit mask for}
                            {        rightmost byte}

    shl     dh,cl           { DH := reverse bit mask for first byte}
    not     dh              { DH := bit mask for first byte}

    mov     cx,x2
    and     cl,3
    xor     cl,3
    shl     cl,1            { CL := number of bits to shift left}
    shl     dl,cl           { DL := bit mask for last byte}

{ determine byte offset of first and last pixel in the line}

    mov     ax,x2        { AX := x2}
    mov     bx,x1        { BX := x1}

    mov     cl,ByteOffsetShift      { number of bits to shift to}
                                    {  convert pixels to bytes}

    shr     ax,cl           { AX := byte offset of x2}
    shr     bx,cl           { BX := byte offset of x1 }
    mov     cx,ax
    sub     cx,bx           { CX := (# bytes in line) - 1}

{ propagate pixel value throughout one byte}

    mov     bx,offset PropagatedPixel
    mov     al,color { AL := pixel value}
    xlat                    { AL := propagated pixel value}

{ set pixels in leftmost byte of the line}

    or      dh,dh
    js      @L43             { jump if byte-aligned (x1 is leftmost}
                            {  pixel in byte)}
    or      cx,cx
    jnz     @L42             { jump if more than one byte in the line}

    and     dl,dh           { bit mask for the line}
    jmp     @L44 {was jmp short}

@L42:
    mov     ah,al
    and     ah,dh           { AH := masked pixel bits}
    not     dh              { DH := reverse bit mask for 1st byte}
    and     es:[di],dh      { zero masked pixels in buffer}
    or      es:[di],ah      { update masked pixels in buffer}
    inc     di
    dec     cx

{ use a fast 8086 machine instruction to draw the remainder of the line}

@L43:
    shr   cx,1  {prepare for stosw}
    mov   ah,al {prepare for stosw}
    rep   stosw {update all pixels in the line}
    jnc @L44
    stosb

{ set pixels in the rightmost byte of the line}

@L44:
    and     al,dl           { AL := masked pixels for last byte}
    not     dl
    and     es:[di],dl      { zero masked pixels in buffer}
    or      es:[di],al      { update masked pixels in buffer}

    jmp     @Lexit


{ routine for dy <= dx (slope <= 1)     { ES:BX -> video buffer}
                            { CX = #pixels to draw}
                            { DH = inverse bit mask}
                            { DL = pixel value in proper position}
                            { SI = buffer interleave increment}
                            { DI = decision variable}
@LoSlopeLine04:

@L10:
    mov     ah,es:[bx]      { AH := byte from video buffer}

@L11:
    and     ah,dh           { zero pixel value at current bit offset}
    or      ah,dl           { set pixel value in byte}

    ror     dl,1            { rotate pixel value}
    ror     dl,1
    ror     dh,1            { rotate bit mask}
    ror     dh,1
    jnc     @L14             { jump if bit mask rotated to}
                            {  leftmost pixel position}

{ bit mask not shifted out}

    or      di,di           { test sign of d}
    jns     @L12             { jump if d >= 0}

    add     di,VARincr1     { d := d + incr1}
    loop    @L11

    mov     es:[bx],ah      { store remaining pixels in buffer}
    jmp     @Lexit {was jmp short}

@L12:
    add     di,VARincr2     { d := d + incr2}
    mov     es:[bx],ah      { update buffer}

    add     bx,si           { increment y}
    xchg    si,VARleafincr  { exchange interleave increment values}

    loop    @L10
    jmp     @Lexit {was jmp short}

{ bit mask shifted out}

@L14:
    mov     es:[bx],ah      { update buffer}
    inc     bx              { BX := offset of next byte}

    or      di,di           { test sign of d}
    jns     @L15             { jump if non-negative}

    add     di,VARincr1     { d := d + incr1}
    loop    @L10
    jmp     @Lexit {was jmp short}


@L15:
    add     di,VARincr2     { d := d + incr2}

    add     bx,si           { increment y}
    xchg    si,VARleafincr

    loop    @L10
    jmp     @Lexit {was jmp short}


{ routine for dy > dx (slope > 1)      }{ ES:BX -> video buffer}
                            { CX = #pixels to draw}
                            { DH = inverse bit mask}
                            { DL = pixel value in proper position}
                            { SI = buffer interleave increment}
                            { DI = decision variable}
@HiSlopeLine04:

@L21:
    and     es:[bx],dh      { zero pixel value in video buffer}
    or      es:[bx],dl      { set pixel value in byte}

    add     bx,si           { increment y}
    xchg    si,VARleafincr  { exchange interleave increment values}

@L22:
    or      di,di           { test sign of d}
    jns     @L23             { jump if d >= 0}

    add     di,VARincr1     { d := d + incr1}
    loop    @L21

    jmp     @Lexit {was jmp short}


@L23:
    add     di,VARincr2     { d := d + incr2}

    ror     dl,1            { rotate pixel value}
    ror     dl,1
    ror     dh,1            { rotate bit mask}
    ror     dh,1
    cmc                     { cf set if bit mask not rotated to}
                            {  leftmost pixel position}

    adc     bx,0            { BX := offset of next byte}

    loop    @L21


@Lexit:         { return}
  end;
end;
