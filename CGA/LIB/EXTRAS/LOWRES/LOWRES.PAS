{
LOWRES unit ver. 2.0 (3.0 as soon as I convert everything to assembler)
5/13/2005 by trixter@oldskool.org
Originally based on information and code by Geoffrey Silverton
}

{$g-,e-,n-,r-,s-,i-,Q-}

{{$DEFINE DEBUG}

Unit lowres;

Interface

uses
  dos;

Const
  ON   = True;
  OFF  = False;

Type
  vsystem=(VMONO,VHERC,VCGA,VEGA,VVGA,VMCGA,VOTHER);

Var
  card:vsystem;

Function  whatvsystem:vsystem;
Procedure WaitVertRetrace;

Procedure enter_lowres_mode;
Procedure prepare_low(X1, Y1, X2, Y2: Integer; Fill, c1, c2: Byte);
Procedure exit_lowres_mode;

Procedure lplot(X, Y: Integer; c: Byte);
Function  lgetdotcolor(X, Y: Integer): Byte;
Procedure lline(X1, Y1, X2, Y2: Integer; c: Byte);
Procedure lbox(X1, Y1, X2, Y2: Integer; c: Byte);
Procedure lfill_box(X1, Y1, X2, Y2: Integer; c: Byte);
Procedure lgotoxy(X, Y: Integer);
Procedure ltextcolor(c: Byte);
Procedure ltextbackground(c: Byte);
Procedure lwrite(st: String);
Procedure lwrite_chr(CH: Char);
Procedure lwrite_num(X: Integer);

Implementation

{This is a little 5x6 pixel font.  Not too pretty, but small.}
{$I LOWFONT.INC}

const
  lowres_installed:Boolean=false;

Var
  cursorx_, cursory_:Integer;
  color_, color_back_:Byte;
  blinking:Boolean;

{**************************** LOCAL ROUTINES *****************************}

Procedure WaitVertRetrace;assembler;
asm
  mov  dx,3dah
@l1:
  in   al,dx
  test al,8
  jz   @l1
@l2:
  in   al,dx
  test al,8
  jnz  @l2
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

{ Set video register }
Procedure set_video_reg(n, Val: Byte);
Begin
  port[$3D4] := n;            { Write to CGA/EGA/MCGA/VGA register }
  port[$3D5] := Val;
End;

{ Draw vertical line quicker than Bresenham }
Procedure lline_quick_v(X, Y1, Y2: Integer; c: Byte);
Var
  Y: Integer;
  m: Word;
Begin
  {Go downwards on screen}
  If Y1>Y2
    Then switch(Y1, Y2);

  {Get first memory address}
  m := (X Or 1) + Y1*160;

  {Different for odd or even column}
  If Odd(X)
    Then For Y:=Y1 To Y2 Do begin
      mem[segb800:m] := mem[SegB800:m] And 15 Or (c ShL 4); {Set background colors}
      Inc(m, 160);
    End
    Else For Y:=Y1 To Y2 Do Begin
      mem[SegB800:m] := mem[SegB800:m] And 240 Or c; {Set foreground colors}
      Inc(m, 160);
    End;
End;

{**************************** GLOBAL ROUTINES *****************************}

{ Read color value at pixel position }
Function lgetdotcolor;
Var m: Word;
Begin
  m := (X Or 1) + Y*160;      { Get memory address }
  If Odd(X)                   { Check background if odd, else foreground }
  Then
    lgetdotcolor := (mem[SegB800:m] And 240) ShR 4
  Else
    lgetdotcolor := mem[SegB800:m] And 15;
End;

(*
{ Plot color value at given pixel coordinates }
Procedure lplot;
Var
  m:Word;
Begin
  m:=(X Or 1) + Y*160;      { Get memory address }
  If Odd(X)
    { Set background color if odd column }
    Then mem[SegB800:m] := mem[SegB800:m] And 15 Or (c ShL 4)
    { Set foreground color if even column }
    Else mem[SegB800:m] := mem[SegB800:m] And 240 Or c;
End;
*)
Procedure lplot;assembler;
asm
  push ds
  mov ax,$b800
  mov es,ax
  mov ds,ax {ds:si and es:di need to point to same place}
  mov ax,y
  mov bl,160
  mul bl {y*160}
  mov cx,x  {keep copy of x}
  mov di,cx
  or di,00000001b
  add di,ax {(x or 1)+(y*160)}
  mov si,di {ds:si and es:di need to point to same place}
  shr cx,1 {if odd, carry flag will be set}
  lodsb {load existing byte, doesn't modify flags}
  mov dl,c {get color}
  jc @oddcolumn
  and al,11110000b
  or al,dl
  jmp @storeit
@oddcolumn:
  mov cl,4
  shl dl,cl {get it ready for or'ing into nybble}
  and al,00001111b {discard nybble we're going to change}
  or al,dl {OR it in}
@storeit:
  stosb {store new byte out}
  pop ds
end;

(*  m:=(X Or 1) + Y*160;      { Get memory address }
  If Odd(X)
    { Set background color if odd column }
    Then mem[SegB800:m] := mem[SegB800:m] And $0f Or (c ShL 4)
    { Set foreground color if even column }
    Else mem[SegB800:m] := mem[SegB800:m] And $f0 Or c;*)

{******* Text functions... ********}

{ Move down one "line" and to extreme left of screen }
Procedure new_line;
Begin
  cursorx_ := 0;
  inc(cursory_,6);
End;

{ Write character at cursor position }
Procedure lwrite_chr;
Var
  i,j,b,len:Byte;
Begin
  {Carriage-return in text?}
  If CH = #13
    Then new_line
    Else Begin
      {Get width of character}
      len := lofont[Ord(CH)][5];
      If cursorx_+len>159 Then new_line;
      {Go through each column of character}
      For i := 0 To len-1 Do begin
        {Start with bit 7 (high bit)}
        b := 128;
        {Go through 6 bits (6 rows of pixels)}
        For j := 0 To 5 Do begin
          If (lofont[Ord(CH)][i] And b) <> 0
            Then lplot(i+cursorx_, j+cursory_-5, color_)        {foreground}
            Else lplot(i+cursorx_, j+cursory_-5, color_back_);  {background}
          {Move to next lower bit}
          b := b ShR 1;
        End;
      End;
      {Advance to next character position}
      inc(cursorx_,len+1);
      {Fill in space between characters (remove this if causes problems)}
      {lline_quick_v(cursorx_-1, cursory_, cursory_-5, color_back_);}
    End;
End;

{ Set a new text color }
Procedure ltextcolor;
Begin
  color_ := c;
End;

{ Set a new text color }
Procedure ltextbackground;
Begin
  color_back_ := c;
End;

{ Change cursor position }
Procedure lgotoxy;
Begin
  cursorx_ := X;
  cursory_ := Y;
End;

{ Write text string }
Procedure lwrite;
Var
  i: Byte;
Begin
  For i := 1 To Length(st) Do lwrite_chr(st[i]);
End;

{ Write number value string }
Procedure lwrite_num;
Var
  st: String[6];
Begin
  Str(X, st);                     { integer --> string }
  lwrite(st);                     { Write that string }
End;

{********* Miscellaneous stuff... **********}

{ Which video card? }
(*Function video_card_detected;
Var detected, dummy: Integer;
Begin
  DetectGraph(detected, dummy);     { Use Turbo graphics unit function }
  video_card_detected := detected;
End;*)

Function whatvsystem:vsystem;

Const
  hcrt=$3b4;

Var
  rr:registers;
  ts:vsystem;

  Function find6845(Addr:Word):Boolean; (* TRUE IF 6845 *)
  Var
    tmp:Byte;
  Begin
    port[Addr]:=$F;
    tmp:=port[Addr+1];
    port[Addr+1]:=$66;
    for tmp:=0 to 10 do waitvertretrace;{Delay(150);}
    find6845:=port[Addr+1]=$66;
    port[Addr+1]:=tmp;
  End;

  Function findmono:vsystem;
  Var
    cnt:Word;
    tmp1,tmp2:Byte;
  Begin
    If find6845(hcrt) Then
    Begin
      tmp1:=port[hcrt+6] And $80;
      Repeat
        tmp2:=port[hcrt+6] And $80;
      Until tmp1<>tmp2;
      If tmp1<>tmp2 Then findmono:=VHERC
      Else findmono:=VMONO;
    End
    Else (* Not Mono *)
      findmono:=VOTHER;
  End;

  Function findCGA:vsystem;
  Begin
    If find6845($3D4) Then findCGA:=VCGA
    Else findCGA:=VOTHER;
  End;

  Function findEGA:vsystem;
  Begin
    rr.BX:=$0010;
    rr.AX:=$1200;
    Intr($10,rr);
    If lo(rr.BX)<>$10 Then
    Begin
      Case Lo(rr.CL) Div 2 Of
        0,3:findEGA:=VCGA;
        1,4:findEGA:=VEGA;
        2,5:findEGA:=VHerc;
      End
    End
    Else (* No ega *)
      findEGA:=VOTHER;
  End;

  Function findPS2:vsystem;
  Begin
    rr.AX:=$1A00;
    Intr($10,rr);
    If Lo(rr.AX)=$1A Then
    Begin
      Case Lo(rr.BX) Of
        0,3,6,9:findPS2:=Vother;
        1:findPS2:=VMONO;
        2:findPS2:=VCGA;
        4,10:findPS2:=VEGA;
        5:findPS2:=VHERC;
        7,8:findPS2:=VVGA;
        11,12:findPS2:=VMCGA;
      End
    End
    Else
      findPS2:=VOTHER;
  End;

Begin
  ts:=findPS2;
  If ts=Vother Then
    ts:=findEGA;
  If ts=Vother Then
    ts:=findmono;
  If ts=Vother Then
    ts:=findCGA;
  whatvsystem:=ts;
End; {whatvsystem}

{ Change value of port $3?8 }
Procedure video(request: Boolean);
Begin
  Case card Of
    VCGA, VMCGA, VVGA:
      port[$3D8] := 1 Or (Ord(request) ShL 3) Or (Ord(blinking) ShL 5);
    VMONO, VHerc:
      port[$3b8] := 1 Or (Ord(request) ShL 3) Or (Ord(blinking) ShL 5);
  End;
End;

{ LORES_MODE enters (if not already in) the 160x100 lowres 16 color mode. }
{ This undocumented "graphics" mode can be achieved on most color cards.  }

{ CGA and similar cards: use "2 pixel high" text  }
{   characters. On CGA-type cards that use more   }
{   than 8 pixels for text characters, like many  }
{   non-IBM CGA cards and MCGA, this will work    }
{   anyway.  Blink is suppressed to get 16        }
{   background colors.  This is done by making    }
{   bit 5 of port $3d8 zero.                      }

{ EGA, VGA: use 3 pixel or 4 pixel high text      }
{   respectively.  Blink is suppressed by using   }
{   function $10 of interrupt $10, subfunction 3, }
{   set BL = 0.  On the EGA card, 100 rows of     }
{   "text" do not evenly fit on the screen.  In   }
{   order to display all 100 rows, 3 pixel high   }
{   characters are used and a fair amount of the  }
{   screen is left blank at the bottom.  You      }
{   really have a 160x116 pixel mode.             }

Procedure enter_lowres_mode;
Begin
  asm
    mov  ax,03h
    int  10h
  end;
  {FillChar(mem[SegB800:0], 24000, 0); { FILL ALL 16K NEEDED+EXTRA FOR EGA }
  lowres_installed := True;
  blinking := OFF;

  card := whatvsystem;

  {$IFNDEF DEBUG}
  Case card Of
    VCGA, VMCGA:
    Begin
      video(off);
      set_video_reg(4, 127);  { REG. 4 IS VERTICAL TOTAL ROWS }
      set_video_reg(6, 100);  { REG. 6 IS VERTICAL DISPLAYED ROWS }
      set_video_reg(7, 112);  { REG. 7 IS "VERTICAL SYNC. POSITION" }
      set_video_reg(9, 1);    { REG. 9 IS PIXEL HEIGHT OF TEXT         }
                              {   (SET TO 2 PIXELS HERE: 0 WOULD BE 1) }
      video(on);              { Blink turned off by this routine on CGA }
    End;
    VVGA:
    Begin
      video(off);
      set_video_reg(9, 3);    { SET PIXEL HEIGHT = 4 }
      asm
        mov  ax,1003h
        mov  bl,0
        int  10h
      end;
      video(on);
    End;
    VEGA:
    Begin
      video(off);
      set_video_reg(9, 2);    { SET PIXEL HEIGHT = 3 }
      asm
        mov  ax,1003h
        mov  bl,0
        int  10h
      end;
      video(on);
    End;
  End;
  hide_text_cursor;               { Don't want cursor in "graphics" mode! }
  {$ENDIF}

  cursorx_ := 0;
  cursory_ := 5;
  color_   := 14;
End;

Procedure exit_lowres_mode;
Begin
  If lowres_installed Then
  Begin
    asm
      mov  ax,0004h
      int  10h
      mov  ax,0003h
      int  10h
    end;
    {reg.AX := $0004;}          { Restore normal text mode characteristics }
    {Intr($10, reg);}           {   (Turbo Pascal may be unaware of our    }
                                {    changes.  So use BIOS.)               }

    {TextMode(LastMode);}       { Tell Turbo Pascal to use user's old mode }

    lowres_installed := False;
  End;
End;


{ Fill video screen region with "fill" character.                       }
{ Often used with "fill" = chr(221) so can plot pixels in left or right }
{ half of each character using foreground/background colors.            }
Procedure prepare_low;
Var
  xa, xb:    Integer;
  X, Y:      Integer;
  filler, m: Word;
Begin
  If X1 > X2 Then switch(X1, X2);  { Go left to right }
  If Y1 > Y2 Then switch(Y1, Y2);  { Top to bottom }

  { Two pixel columns for each byte address: }
  xa := X1 ShR 1;                  { x1 / 2 to get byte address }
  xb := X2 ShR 1;                  { x2 / 2 to get byte address}

  m := Y1 * 160;                   { Memory address of start of pixel row }

  filler := Fill                   { Character with          }
  + c1 ShL 8               {   foreground color      }
  + c2 ShL 12;             {   and background color. }

  For Y := Y1 To Y2 Do
  Begin
    For X := xa To xb Do
      memw[SegB800 : (X ShL 1) + m] := filler;  { Set word of memory }
    Inc(m, 160);                                   { Down one row }
  End;
End;

{ Draw Bresenham line }
Procedure lline;
Var
  DX, dy:                     Integer;
  incrStraight, incrDiagonal: Integer;
  D:                          Integer;
  X, Y:                       Integer;
  incX, incY:                 Integer;

Begin
  If X1 = X2 Then
    lline_quick_v(X1, Y1, Y2, c);    { Vertical line?  Do it quicker... }

  If Y1 = Y2 Then
    lfill_box(X1, Y1, X2, Y2, c);    { Horizontal line?  Do it quicker... }

  If X2 > X1 Then incX := 1          { Right }
  Else incX := -1;        { Left }
  If Y2 > Y1 Then incY := 1          { Down }
  Else incY := -1;        { Up }

  DX := Abs(X2 - X1);                { Horizontal distance }
  dy := Abs(Y2 - Y1);                { Vertical distance }

  If DX > dy Then                    { Not steep? }
  Begin
    D := (dy ShL 1) - DX;               { Step less than 1 in vert. dir. }
    incrStraight := dy ShL 1;
    incrDiagonal := (dy-DX) ShL 1;
  End
  Else                               { Steep. }
  Begin
    D := (DX ShL 1) - dy;               { Step less than 1 in horiz. dir. }
    incrStraight := DX ShL 1;
    incrDiagonal := (DX-dy) ShL 1;
  End;

  X := X1;                                { Start out... }
  Y := Y1;
  lplot(X, Y, c);                         { Plot first pixel }

  While (X <> X2) Or (Y <> Y2) Do         { Until we reach end of the line... }
  Begin
    If (D <= 0) Then                     { Still go straigt? }
    Begin
      Inc(D, incrStraight);              { Yes, go straight }
      If (DX>dy) Then
        Inc(X, incX)                     { Move in horizontal direction }
      Else
        Inc(Y, incY);                    { Move in vertical direction }
    End
    Else
    Begin
      Inc(D, incrDiagonal);              { Move diagonally now. }
      Inc(X, incX);
      Inc(Y, incY);
    End;

    lplot(X, Y, c);                        { Plot this pixel }
  End;
End;

{ Draw box }
Procedure lbox;
Begin
  lfill_box(X1, Y1, X2, Y1, c);    { Horizontal lines }
  lfill_box(X1, Y2, X2, Y2, c);

  lline_quick_v(X1, Y1, Y2, c);    { Vertical lines }
  lline_quick_v(X2, Y1, Y2, c);
End;

{ Draw filled box }
Procedure lfill_box;
Var
  X, Y:   Integer;
  nbytes: Integer;
  m:      Word;
  cbyte:  Byte;
Begin
  If X1>X2 Then                     { Go left to right }
    switch(X1, X2);
  If Y1>Y2 Then                     { Go top to bottom }
    switch(Y1, Y2);

  If Odd(X1) Then                   { Not entire byte on left edge? }
  Begin
    lline_quick_v(X1, Y1, Y2, c);    { Draw single pixel column }
    Inc(X1);
  End;

  If Not Odd(X2) Then               { Not entire byte on right edge? }
  Begin
    lline_quick_v(X2, Y1, Y2, c);    { Draw single pixel column }
    Dec(X2);
  End;

  cbyte := c Or (c ShL 4);          { Color byte: both fore. and background }
  nbytes := (X2-X1+1) ShR 1;        { Number of bytes to fill }
  m := (X1 Or 1) + Y1*160;          { Starting memory address }

  For Y:=Y1 To Y2 Do                { For each row of pixels... }
  Begin
    For X:=1 To nbytes Do           { For each byte in row... }
    Begin
      mem[SegB800:m] := cbyte;   { Set byte }
      Inc(m,2);                     { Move two bytes ahead }
    End;
    Inc(m, 160 - (nbytes ShL 1));   { Go back to left and down a line }
  End;
End;

End.
