unit m_comp;
{
Part of CGALIB.  Containes routines for 16-color CGA Composite mode.

Code adapted from traditional CGA routines by Richard Wilton.
}

interface

Procedure composite_set;
Procedure composite_setpixel_direct(x,y:word;color:byte);
Procedure composite_line_direct(x1,y1,x2,y2:integer;color:byte);

implementation

uses
  {cgalib_g,}
  m320_640,
  m6845ctl;

Procedure composite_PixelAddr_direct;assembler;
{
Determines buffer address of pixel in 160x200 16-color mode
Caller:
  AX = y-coordinate (0-199)
  BX = x-coordinate (0-159)

Returns:
  AH = bit mask
  BX = byte offset in buffer
  CL = number of bits to shift left
  ES = video buffer segment
}
asm
  mov     cl,bl           { CL := low-order byte of x}
  xchg    ah,al           { AX := 100h * y}
  shl     bx,1            { BX := x*2}
  shr     ax,1            { AL := 80h*(y&1)}
  add     bh,al           { BX := x*2 + 8000h*(y&1)}
  xor     al,al           { AX := 100h*(y/2)}
  add     bx,ax           { BX := x*2 + 8000h*(y&1) + 100h*(y/2)}
  shr     ax,1
  shr     ax,1            { AX := 40h*(y/2)}
  add     bx,ax           { BX := x*2 + 8000h*(y&1) + 140h*(y/2)}
  shr     bx,1
  shr     bx,1            { BX := x/2 + 2000h*(y&1) + 50h*(y/2)}
  les     dx,mode46_loc   { ES:DX = start of video buffer }
  add     bx,dx           { BX := byte offset in video buffer}
                          { ES:BX := byte address of pixel}
  and     cl,1            { CL := x & 1}
  xor     cl,1            { CL := 1 - (x & 1)}
  shl     cl,1
  shl     cl,1            { cl := cl * 4}
  mov     ah,$f           { AH := unshifted bit mask}
end;

Procedure composite_SetPixel_direct(x,y:word;color:byte);assembler;
asm
   mov   ax,y
   mov   bx,x
   call  composite_PixelAddr_direct {AH = bit mask, ES:BX -> buffer, CL = #bits to shift left}
   mov   al,color {AH = bitmask, AL = color}
   shl   ax,cl {AH = bit mask in proper position, AL = pixel value in proper position}
   not   ah {AH = inverse bit mask}
   and   es:[bx],ah {zero the pixel value}
   or    es:[bx],al {set the pixel value}
end;

procedure ModeSetPreamble;
{sets the CRTC mode registers for 320x200/640x200 memory organization and display}
const
  index=2;
  modetable_size=sizeof(CRTCControlArray);
  NumValsToSet=10; {we're only interested in the first 10; don't care about cursor location, etc}
begin
  asm
    push ds
    lds si,int1d_mode_table
    add si,index*modetable_size {jump forward to the data we're looking for}
    mov dx,m6845_index
    xor ax,ax {ah is going to be our index/counter}
@loadandset:
    mov al,ah {move index to al}
    out dx,al {tell 6845 we want index AH}
    lodsb {grab the data value}
    inc dx {move port up to the data register}
    out dx,al {send it}
    dec dx {move back down to the index register}
    inc ah {increase our index}
    cmp ah,NumValsToSet {are we done?}
    jne @loadandset {if not, keep going}
    pop ds {done with the array}
  end;
end;

Procedure composite_set;
begin
  ModeSetPreamble;
  asm
    mov dx,m6845_mode_ctl
    mov al,c_videosignal_enable+c_graphics_enable+c_640x200_enable
    out dx,al
  end;
  BDA_crt_mode:=6;
  m6845_setcolor(15);
end;

Procedure composite_line_direct(x1,y1,x2,y2:integer;color:byte);

var
  VARleafincr,
  VARincr1,
  VARincr2,
  VARroutine:word;

const
  ByteOffsetShift=1; {used to convert pixels to byte offset}
  PropagatedPixel:array[0..15] of byte = (
    0,   {0000 0000}
    17,  {0001 0001}
    34,  {0010 0010}
    51,  {0011 0011}
    68,  {0100 0100}
    85,  {0101 0101}
    102, {0110 0110}
    119, {0111 0111}
    136, {1000 1000}
    153, {1001 1001}
    170, {1010 1010}
    187, {1011 1011}
    204, {1100 1100}
    221, {1101 1101}
    238, {1110 1110}
    255  {1111 1111}
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
    call    composite_PixelAddr_direct { AH := bit mask}
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
    call    composite_PixelAddr_direct     { AH := bit mask}
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
    call    composite_PixelAddr_direct     { AH := bit mask}
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
{    and     cl,3
    xor     cl,3}
    and     cl,1
    xor     cl,1
    shl     cl,1
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

    push cx
    mov cl,4
    ror     dl,cl            { rotate pixel value}
    ror     dh,cl            { rotate bit mask}
    pop cx
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

    push cx
    mov cl,4
    ror     dl,cl            { rotate pixel value}
    ror     dh,cl            { rotate bit mask}
    cmc                     { cf set if bit mask not rotated to}
                            {  leftmost pixel position}
    pop cx

    adc     bx,0            { BX := offset of next byte}

    loop    @L21

@Lexit:         { return}
  end;
end;


end.
