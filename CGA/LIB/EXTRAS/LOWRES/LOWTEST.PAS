{
LOWTEST
Jim Leonard, 10/20/1995
Based on information by Geoffrey Silverton.

Tests the LOWRES unit.
}

{$g-,e-,n-,q-}

Program LowTest;
Uses
  crt,
  lowres;

Const
  LX1 = 5;                 { Location of lower boxes }
  LY1 = 32;
  LX2 = 76;
  LY2 = 95;
  
  RX1 = 82;
  RY1 = 32;
  RX2 = 154;
  RY2 = 95;
  
Procedure shadow_box(X1, Y1, X2, Y2: Integer;c_light, c_dark: Byte;out: Boolean);
{ Draw a "shadow box" border }
Begin
  If out Then         { "pop out" border }
  Begin
    lline(X1, Y1, X2-1, Y1, c_light);
    lline(X1, Y1, X1, Y2-1, c_light);
    lline(X1, Y2, X2, Y2, c_dark);
    lline(X2, Y1, X2, Y2, c_dark);
  End
  Else                { "push in" border }
  Begin
    lline(X1, Y1, X2, Y1, c_dark);
    lline(X1, Y1, X1, Y2, c_dark);
    lline(X1+1, Y2, X2, Y2, c_light);
    lline(X2, Y1+1, X2, Y2-1, c_light);
  End
End;

Procedure show_screen;
{ Draw screen for demo }
Var
  i, j:  Integer;
  count: Integer;
  
Begin
  prepare_low(0,0,159,99,221,LightGray,LightGray);
  shadow_box(0,0,159,99,White,DarkGray,True);
  
  { Text box }
  shadow_box(4, 5, 77, 25, White, DarkGray, True);
  ltextbackground(LightGray);
  ltextcolor(Blue);
  lgotoxy(8, 14);
  lwrite('LOWRES UNIT');
  lwrite(' demo');
  lgotoxy(11, 22);
  ltextcolor(Black);
  lwrite('160x100 16 colors');
  
  { Checkerboard of colors }
  shadow_box(82, 4, 155, 25, White, DarkGray, False);
  For i:=0 To 17 Do
    For j:=0 To 4 Do
      lfill_box(83+i*4, 5+j*4, 86+i*4, 8+j*4, (i+j) And 15);

  { Lower left box }
  shadow_box(LX1-1, LY1-1, LX2+1, LY2+1, White, DarkGray, False);
  lfill_box(LX1, LY1, LX2, LY2, Black);
  
  { Lower right box }
  shadow_box(RX1-1, RY1-1, RX2+1, RY2+1, White, DarkGray, False);
  lfill_box(RX1, RY1, RX2, RY2, Black);
End;

Procedure demo;
Const
  NUMOLD = 20;
  
Type
  TwoPoint= Record sx, sy, ex, ey: Integer; End;
  
Var
  count1, count2:   Integer;
  dcount1, dcount2: Integer;
  iteration:        LongInt;
  X1, Y1, X2, Y2:   Integer;
  X, Y, xx, yy:     Integer;
  xsize2, ysize2:   Integer;
  i:                Integer;
  old:              Array[1..NUMOLD] Of TwoPoint;
  
Begin
  {*** Line stuff ***}
  xsize2 := (LX2 - LX1 + 1) ShR 1;
  ysize2 := (LY2 - LY1 + 1) ShR 1;
  
  { Store old line coords. for cleanup }
  For i:=1 To NUMOLD Do With old[i] Do
  Begin
    sx := LX1;
    sy := LY1;
    ex := LX1;
    ey := LY1;
  End;

  iteration := 1;
  count1    := 0;
  count2    := 100;
  dcount1   := 10;
  dcount2   := -27;
  While Not KeyPressed Do
  Begin
    {*** Line stuff ***}
    Inc(iteration);
    If iteration = MaxLongInt Then
      iteration := 1;

    Inc(dcount1, 4 - Random(9));
    Inc(dcount2, 4 - Random(9));
    If Abs(dcount1) > 100 Then
      dcount1 := dcount1*4 Div 5;
    If Abs(dcount2) > 100 Then
      dcount2 := dcount2*4 Div 5;
    Inc(count1, dcount1);
    Inc(count2, dcount2);

    X1 := LX1 + Trunc(xsize2 + xsize2*Cos(count1*0.002) - 0.5);
    Y1 := LY1 + Trunc(ysize2 + ysize2*Sin(count1*0.002) - 0.5);
    X2 := LX1 + Trunc(xsize2 - xsize2*Cos(count2*0.002) - 0.5);
    Y2 := LY1 + Trunc(ysize2 - ysize2*Sin(count2*0.002) - 0.5);

    {waitvertretrace;}
    With old[iteration Mod NUMOLD + 1] Do
    Begin
      lline(sx, sy, ex, ey, Black);
      sx := X1;
      sy := Y1;
      ex := X2;
      ey := Y2;
    End;

    lline(X1, Y1, X2, Y2, (iteration ShR 4) Mod 14 + 1);

    {*** Point stuff ***}
    X := Random(RX2-RX1+1);
    Y := Random(RY2-RY1+1);
    xx := (RX2-RX1+1) ShR 1 - X;
    yy := (RY2-RY1+1) ShR 1 - Y;
    lplot(RX1 + X,
    RY1 + Y,
    ((xx*xx+yy*yy) ShR 3) And 15);
  End;
End;

Begin
  enter_lowres_mode;                           { Enter 160x100x16 mode }

  show_screen;
  demo;

  exit_lowres_mode;                            { Don't forget to do this! }
End.
