{
m_lowres unit, part of CGALIB
ver. 2.0, 6/3/2005 by trixter@oldskool.org
Originally based on information and code by Geoffrey Silverton.
Portions converted to assembler and/or optimized by Jim Leonard.

Please note that this unit is specifically for CGA only -- the original
code had additional support for "lowres" mode on EGA and VGA systems...
that code is NOT PRESENT HERE.  If you want the original 1995 unit
that has all the code support in it, such as a small font and text
controls, check "lowres.pas" in the extras\ directory.

"lowres" mode, cryptically mentioned by IBM and others but never with any
explanation or code, is nothing more than a tweak of 80x25 text mode.
The character cell height is quartered, so that an 8x8 cell only displays
the top 8x2.  Then, ASCII 222 ("Þ") is filled into every character column
so that every high-order nybble of the attribute is the background color,
and the low-order nybble is the foreground.  (This differs from G.
Silverton's original code -- he used ASCII 221 and built things backwards
for some reason, no idea why.)  The end result is 160x100 with the 16 text
colors.

A decision must be made when trying to optimize this code:
While there is only 8K of RAM to manipulate, it is not linear, ie. the
color nybble (the attribute byte) alternates with the character byte.
The most obvious optimization is to treat each column as 80 words instead
of 160 bytes, so that STOSW can be used... however, the additional memory
writing may offset the simplified calculations.  Microsecond testing will
be required of any optimization to ensure which method is *actually*
faster on an 8088 machine.  In informal testing, REP STOSW was indeed a tiny
bit faster than LOOP;STOSB when using it to draw a horizontal line from 0,0
to 159,0.  Common sense would dictate that STOSW should only be used when
paired with REP, and that STOSB should be used for individual pixels.
}

{$G-,E-,N-,Q-}

{{$DEFINE DEBUG}

{$IFDEF DEBUG}
{$R+,S+}
{$ELSE}
{$R-,S-}
{$ENDIF}

Unit m_lowres;

Interface

Procedure lowres_set;
Procedure lowres_clrscr_direct(filler:char);

Procedure lowres_setpixel_direct(X, Y: Integer; c: Byte);
{Function  lowres_getpixel(X, Y: Integer): Byte;}
Procedure lowres_line_direct(X1, Y1, X2, Y2: Integer; c: Byte);
{Procedure lbox(X1, Y1, X2, Y2: Integer; c: Byte);
Procedure lfill_box(X1, Y1, X2, Y2: Integer; c: Byte);}

Implementation

uses
  {cgalib_g,}
  m_textm,
  m6845ctl;

Procedure lowres_setpixel_direct;assembler;
asm
  push  ds

  les   di,mtext_loc
  mov   ax,es
  mov   ds,ax
  mov   si,di  {ds:si := es:di}

  mov   ax,y
  mov   cx,x
  mov   dl,c
  mov   bl,160
  mul   bl {ax=y*160} {this MUL is a prime spot for optimization by (y*128)+(y*32) but I'm lazy :-)}
  add   di,cx
  or    di,00000001b
  add   di,ax {di=(x or 1)+(y*160)}
  mov   si,di {ds:si and es:di need to point to same place}
  lodsb {load existing byte}
  shr   cx,1
  jc    @oddcolumn {if x odd, carry flag will be set}
  and   al,00001111b {if even column, save the odd nybble}
  mov   cl,4
  shl   dl,cl {get our nybble into position}
  or    al,dl {OR our color nybble into the byte}
  jmp   @storeit
@oddcolumn:
  and   al,11110000b {if odd column, save the even nybble}
  or    al,dl {OR it in}
@storeit:
  stosb {store new byte out}

  pop   ds
end;

Procedure switch(Var a, b: Integer);
Var
  dummy: Integer;
Begin
  dummy := a;
  a := b;
  b := dummy;
End;

{ HIDE_TEXT_CURSOR hides the textmode cursor by positioning it off screen }
Procedure hide_text_cursor;assembler;
asm
  mov  AH,2
  mov  BH,0
  mov  DH,25 {25 shl 8}
  xor  dl,dl
  int  10h
End;

{ Draw vertical line quicker than Bresenham }
Procedure lline_quick_v(X, Y1, Y2: Integer; c: Byte);
Var
  Y: Integer;
  m: Word;

Begin
  If Y1>Y2 Then switch(Y1,Y2); {Go downwards on screen}
  {Different for odd or even column}
  m := (X Or 1) + Y1*160; {Get first memory address}
  y:=y2-y1+1;
  If not odd(X) {TP has no "even()" :-}
    Then begin
      asm
        push  ds {save ds, as we're about to abuse it}
        les   di,mtext_loc
        add   di,m {adjust offset by m}
        mov   ax,es
        mov   ds,ax
        mov   si,di {ds:si = es:di}
        mov   cl,4 {load with count we're going to use with shift}
        mov   bl,c {load color}
        shl   bl,cl {move it into place since it's an even-column color}
        mov   dx,159 {amount to increment to next pixel... it's one less because stosb and lodsb auto-increment di and si}
        mov   bh,00001111b {we'll need this mask later}
        mov   cx,y
      @l:
        lodsb {grab existing byte to al}
        and   al,bh {keep the odd-column color}
        or    al,bl {OR in our color}
        stosb {store it out}
        add   si,dx {increment index to next byte}
        mov   di,si {update second index as well}
        loop  @l
        pop   ds {restore ds as we've been abusing it}
      end;
    End Else Begin {odd}
      asm
        push  ds {save ds, as we're about to abuse it}

        les   di,mtext_loc
        add   di,m {adjust offset by m}
        mov   ax,es
        mov   ds,ax
        mov   si,di {ds:si = es:di}

        mov   bl,c {load color}
        mov   dx,159 {amount to increment to next pixel... it's one less because stosb and lodsb auto-increment di and si}
        mov   bh,11110000b {we'll need this mask later}
        mov   cx,y
      @l:
        lodsb {grab existing byte to al}
        and   al,bh {keep the odd-column color}
        or    al,bl {OR in our color}
        stosb {store it out}
        add   si,dx {increment index to next byte}
        mov   di,si {update second index as well}
        loop  @l
        pop   ds {restore ds as we've been abusing it}
      end;
    End;
End;

Procedure lline_quick_h(X1,Y1,X2:integer;c:Byte);
Var
  X, Y:   Integer;
  nbytes: Integer;
  m:      Word;
  cbyte:  Byte;
Begin
  If X1>X2 Then switch(X1, X2); { Go left to right }

  If Odd(X1) Then                   { Not entire byte on left edge? }
  Begin
    lowres_setpixel_direct(X1,Y1,c);    { Draw single pixel }
    Inc(X1);
  End;

  If Not Odd(X2) Then               { Not entire byte on right edge? }
  Begin
    lowres_setpixel_direct(X2,Y1,c);    { Draw single pixel }
    Dec(X2);
  End;

  cbyte := c Or (c ShL 4);          { Color byte: both fore. and background }
  nbytes := (X2-X1+1) ShR 1;        { Number of bytes to fill }
  m := (X1 Or 1) + Y1*160;          { Starting memory address }

  (* SLOW
  For X:=1 To nbytes Do           { For each byte in row... }
  Begin
    mem[SegB800:m] := cbyte;      { Set byte }
    Inc(m,2);                     { Move two bytes ahead }
  End;
  *)

  (* much faster
  asm
    mov  ax,$b800
    mov  es,ax
    mov  al,cbyte
    mov  di,m
    mov  cx,nbytes
  @l:
    stosb
    inc  di
    loop @l
  end;
  *)

  {fastest, but thanks to 8088, just barely :-}
  asm
    les  di,mtext_loc
    mov  ah,cbyte  {move double-color-byte into ah}
    mov  al,222    {ax="colr222Þ" but intel is little-endian so it will be written out with al first}
    add  di,m      {add precomputed offset to offset di...}
    dec  di        {...and adjust for our word-centric routine}
    mov  cx,nbytes {get the count}
    rep  stosw     {REPeat STOreStringWord by count in cx}
  end;
End;

Procedure lowres_set;
{
Use "2 pixel high" text characters. On CGA-type cards that use more than 8
pixels for text characters, like many non-IBM CGA cards and MCGA, this will
work anyway.  Blink is suppressed to get 16 background colors.
}

Begin
  asm
    mov  ax,03h
    int  10h
  end;
  {the rest not done in assembler so you can see what I'm doing}
  m6845_SetRegData(m6845_vertical_total, 127);
  m6845_SetRegData(m6845_vertical_displayed, 100);
  m6845_SetRegData(m6845_vertical_sync_position, 112);
  m6845_SetRegData(m6845_maximum_scanline, 1); {value here is one LESS than number of character cell lines to display}
  hide_text_cursor; { Don't want cursor in "graphics" mode! }
  m6845_SetMode(c_videosignal_enable+c_fast_char_clock);
End;

Procedure lowres_close;
Begin
  asm
    mov  ax,0003h
    int  10h
  end;
End;

{ Fill video screen region with "fill" character.                       }
{ Often used with "fill" = chr(222) so can plot pixels in left or right }
{ half of each character using foreground/background colors.            }
Procedure lowres_clrscr_direct(filler:char);assembler;
asm
  les  di,mtext_loc
  mov  al,filler {ascii 222 "Þ" is normally chosen because background of char is empty so we can use hi-nybble for background}
  {$IFDEF DEBUG}
  mov  ah,87h {first color dark gray, second color light gray, chosen for debugging}
  {$ELSE}
  mov  ah,00h
  {$ENDIF}
  mov  cx,$2000 {8192 words of ram}
  rep  stosw {remember, intel is little-endian so 0,1 of ram after STOSW = al,ah}
End;

{ Draw Bresenham line }
Procedure lowres_line_direct;
Var
  DX,DY:byte;
  incrStraight,incrDiagonal:integer;
  D:integer;
  x,y:byte;
  incX,incY:shortint;

Begin
  If X1 = X2 Then begin {Vertical line?  Do it quicker...}
    lline_quick_v(X1, Y1, Y2, c);
    exit;
  end;

  If Y1 = Y2 Then begin {Horizontal line?  Do it quicker...}
    {lfill_box(X1, Y1, X2, Y2, c);}
    lline_quick_h(X1, Y1, X2, c);
    exit;
  end;

  If X2 > X1
    Then incX := 1                   { Right }
    Else incX := -1;                 { Left }
  If Y2 > Y1
    Then incY := 1                   { Down }
    Else incY := -1;                 { Up }

  DX := Abs(X2 - X1);                { Horizontal distance }
  DY := Abs(Y2 - Y1);                { Vertical distance }

  If (DX>DY) Then begin              { Not steep? }
    D := (DY ShL 1) - DX;            { Step less than 1 in vert. dir. }
    incrStraight := DY ShL 1;
    incrDiagonal := (DY-DX) ShL 1;
  End Else Begin                     { Steep. }
    D := (DX ShL 1) - DY;            { Step less than 1 in horiz. dir. }
    incrStraight := DX ShL 1;
    incrDiagonal := (DX-DY) ShL 1;
  End;

  x:=x1; y:=y1;
  lowres_setpixel_direct(X, Y, c);   { Plot first pixel }

  While (X<>X2) Or (Y<>Y2) Do begin  { Until we reach end of the line... }
    If (D <= 0) Then begin { Go straight? }
      Inc(D,incrStraight);
      If (DX>DY)
        then inc(x,incx) {Move horizontally}
        else inc(y,incy); {move vertically}
    End Else Begin { Move diagonally now. }
      Inc(D,incrDiagonal);
      inc(x,incx);
      inc(y,incy);
    End;
    lowres_setpixel_direct(X, Y, c); { Plot calc'd pixel }
  End;
End;

End.
