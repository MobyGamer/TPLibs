{
m_textm unit, part of CGALIB
6/7/2005 by trixter@oldskool.org

Turns 40x25, 80x25, and others into a crude (I stress "crude", here) graphics
mode.  If you ever envied Apple's lowres mode, now you too can have it with
40x25 mode :-)  On the other hand, the ASCII 177 (�) shading works VERY
well on a real CGA monitor.
}

{$G-,E-,N-,Q-}

{{$DEFINE DEBUG}

{$IFDEF DEBUG}
{$R+,S+}
{$ELSE}
{$R-,S-}
{$ENDIF}

Unit m_textm;

Interface

const
  mtext_loc:pointer=ptr($b800,0000);

Procedure m40x25_set;
Procedure m80x25_set;
Procedure m40x50_set;
Procedure m80x50_set;
Procedure m40x100_set;
Procedure m80x100_set;

Procedure mtext_clrscr_direct(filler:char;color:byte;count:word);
Procedure mtext_line_direct(X1,Y1,X2,Y2:Integer;c:Byte;lwb:word);
Procedure mtext_setpixel_direct(X,Y:Integer;c:Byte;lwb:word);
{"lwb" = line width in bytes}

Implementation

uses
  cgalib_g,
  m6845ctl;

Procedure switch(Var a, b: Integer);
Var
  dummy: Integer;
Begin
  dummy := a;
  a := b;
  b := dummy;
End;

Procedure mtext_setpixel_direct;assembler;
asm
  les   di,mtext_loc {point to start of buffer}
  mov   ax,y         {ax=y}
  mov   dx,x         {di=x}
  mov   bx,lwb
  mul   bl           {ax=y*lbw} {prime spot for optimization if this were a constant, like *80 = (y*64)+(y*16) }
  shl   dx,1
  inc   dx           {dx=(x*2)+1}
  add   di,dx
  add   di,ax        {di=(y*80)+((x*2)+1)}
  mov   al,c
  stosb              {store new byte out}
end;

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
Procedure mtext_line_quick_v(X, Y1, Y2: Integer; c:byte; lwb:word); {lwb=line width in bytes}
Var
  Y: Integer;
  m: Word;

Begin
  If Y1>Y2 Then switch(Y1,Y2); {Go downwards on screen}
  m := ((X shl 1)+1) + (Y1*lwb); {Get first memory address}
  y:=y2-y1+1;
  asm
    les   di,mtext_loc
    add   di,m
    mov   al,c {load color}
    mov   dx,lwb
    dec   dx {amount to increment to next pixel... it's one less because stosb auto-increments di}
    mov   cx,y
  @l:
    stosb {store it out}
    add   di,dx {increment index to next byte}
    loop  @l
  end;
End;

Procedure mtext_line_quick_h(X1,Y1,X2:integer;c:byte;lwb:word);
Var
  X, Y:   Integer;
  nbytes: Integer;
  m:      Word;
Begin
  If X1>X2 Then switch(X1, X2); { Go left to right }
  nbytes := (X2-X1+1) ;        { Number of bytes to fill }
  m := ((X1 shl 1) + 1) + (Y1*lwb);          { Starting memory address }
  asm
    les  di,mtext_loc
    mov  ah,c
    mov  al,177    {shaded char}
    add  di,m      {move precomputed offset into di...}
    dec  di        {...and adjust for our word-centric routine}
    mov  cx,nbytes {get the count}
    rep  stosw     {REPeat STOreStringWord by count in cx}
  end;
End;

Procedure m40x25_set;
Begin
  m6845_SetModeTable(0);
  hide_text_cursor; { Don't want cursor in "graphics" mode! }
  m6845_SetMode(c_videosignal_enable);
End;

Procedure mtext_close;
Begin
  asm
    mov  ax,0003h
    int  10h
  end;
End;

Procedure mtext_clrscr_direct(filler:char;color:byte;count:word);assembler;
asm
  les  di,mtext_loc
  mov  al,filler
  {$IFDEF DEBUG}
  mov  ah,87h {first color dark gray, second color light gray, chosen for debugging}
  {$ELSE}
  mov  ah,color
  {$ENDIF}
  mov  cx,count
  shr  cx,1
  cld
  rep  stosw {remember, intel is little-endian so 0,1 of ram after STOSW = al,ah}
End;

{ Draw Bresenham line }
Procedure mtext_line_direct(X1, Y1, X2, Y2: Integer; c: Byte; lwb:word);
Var
  DX,DY:byte;
  incrStraight,incrDiagonal:integer;
  D:integer;
  x,y:byte;
  incX,incY:shortint;

Begin
  If X1 = X2 Then begin {Vertical line?  Do it quicker...}
    mtext_line_quick_v(X1, Y1, Y2, c, lwb);
    exit;
  end;

  If Y1 = Y2 Then begin {Horizontal line?  Do it quicker...}
    {lfill_box(X1, Y1, X2, Y2, c);}
    mtext_line_quick_h(X1,Y1,X2,c,lwb);
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
  mtext_setpixel_direct(X,Y,c,lwb);   { Plot first pixel }

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
    mtext_setpixel_direct(X,Y,c,lwb);
  End;
End;

Procedure m80x25_set;
Begin
  m6845_SetModeTable(1);
  hide_text_cursor; { Don't want cursor in "graphics" mode! }
  m6845_SetMode(c_videosignal_enable+c_fast_char_clock);
End;

Procedure m40x100_set;
{
Use "2 pixel high" text characters. On CGA-type cards that use more than 8
pixels for text characters, like many non-IBM CGA cards and MCGA, this will
work anyway.  Blink is suppressed to get 16 background colors.
}
Begin
  m40x25_set;
  {the rest not done in assembler so you can see what I'm doing}
  m6845_SetRegData(m6845_vertical_total, 127);
  m6845_SetRegData(m6845_vertical_displayed, 100);
  m6845_SetRegData(m6845_vertical_sync_position, 112);
  m6845_SetRegData(m6845_maximum_scanline, 1); {value here is one LESS than number of character cell lines to display}
  hide_text_cursor; { Don't want cursor in "graphics" mode! }
  m6845_SetMode(c_videosignal_enable);
End;

Procedure m80x100_set;
Begin
  m80x25_set;
  {the rest not done in assembler so you can see what I'm doing}
  m6845_SetRegData(m6845_vertical_total, 127);
  m6845_SetRegData(m6845_vertical_displayed, 100);
  m6845_SetRegData(m6845_vertical_sync_position, 112);
  m6845_SetRegData(m6845_maximum_scanline, 1); {value here is one LESS than number of character cell lines to display}
  hide_text_cursor; { Don't want cursor in "graphics" mode! }
  m6845_SetMode(c_videosignal_enable+c_fast_char_clock);
End;

Procedure m40x50_set;
{
Use "2 pixel high" text characters. On CGA-type cards that use more than 8
pixels for text characters, like many non-IBM CGA cards and MCGA, this will
work anyway.  Blink is suppressed to get 16 background colors.
}
Begin
  m40x25_set;
  {the rest not done in assembler so you can see what I'm doing}
  m6845_SetRegData(m6845_vertical_total, 64);
  m6845_SetRegData(m6845_vertical_total_adjust, 2);
  m6845_SetRegData(m6845_vertical_displayed, 50);
  m6845_SetRegData(m6845_vertical_sync_position, 56);
  m6845_SetRegData(m6845_maximum_scanline, 3); {value here is one LESS than number of character cell lines to display}
  hide_text_cursor; { Don't want cursor in "graphics" mode! }
  m6845_SetMode(c_videosignal_enable);
End;

Procedure m80x50_set;
Begin
  m80x25_set;
  {the rest not done in assembler so you can see what I'm doing}
  m6845_SetRegData(m6845_vertical_total, 64);
  m6845_SetRegData(m6845_vertical_total_adjust, 2);
  m6845_SetRegData(m6845_vertical_displayed, 50);
  m6845_SetRegData(m6845_vertical_sync_position, 56);
  m6845_SetRegData(m6845_maximum_scanline, 3); {value here is one LESS than number of character cell lines to display}
  hide_text_cursor; { Don't want cursor in "graphics" mode! }
  m6845_SetMode(c_videosignal_enable+c_fast_char_clock);
End;

End.
