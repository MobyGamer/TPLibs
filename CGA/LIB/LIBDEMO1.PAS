{{$DEFINE DEBUG}
Program libdemo1;
Uses
  support,m6845ctl,cgalib,cgalib_g;

Const
  {?X? assume width of 160; ?Y? assume height of 100}
  LX1:word= 5;   LY1:word= 32;
  LX2:word= 76;  LY2:word= 95;

  RX1:word= 82;  RY1:word= 32;
  RX2:word= 154; RY2:word= 95;

Procedure shadow_box(X1, Y1, X2, Y2: Integer;c_light, c_dark: Byte;out: Boolean);
{ Draw a "shadow box" border }
Begin
  If out Then begin   { "pop out" border }
    cga_line(X1, Y1, X2-1, Y1, c_light);
    cga_line(X1, Y1, X1, Y2-1, c_light);
    cga_line(X1, Y2, X2, Y2, c_dark);
    cga_line(X2, Y1, X2, Y2, c_dark);
  End else begin      { "push in" border }
    cga_line(X1, Y1, X2, Y1, c_dark);
    cga_line(X1, Y1, X1, Y2, c_dark);
    cga_line(X1+1, Y2, X2, Y2, c_light);
    cga_line(X2, Y1+1, X2, Y2-1, c_light);
  End
End;

Procedure show_screen;
{ Draw screen for demo }
Var
  i, j:  Integer;
  count: Integer;
  
Begin
  cga_clrscr(true);
  {fill with lightgray}
  cga_box(0,0,cga_curmode.width-1,cga_curmode.height-1,tLightGray);

  shadow_box(0,0,cga_curmode.width-1,cga_curmode.height-1,tWhite,tDarkGray,True);

  { Text box }
  shadow_box(4, 5, 77, 25, tWhite, tDarkGray, True);

  { Checkerboard of colors }
  shadow_box(rx1, lx1-1, rx2+1, lx2 div 3, tWhite, tDarkGray, False);
  For i:=0 To 17 Do
    For j:=0 To 4 Do
      cga_box(rx1+1+i*4, lx1+j*4, rx1+4+i*4, lx1+3+j*4, (i+j) mod cga_curmode.maxcolors);

  { Lower left box }
  shadow_box(LX1-1, LY1-1, LX2+1, LY2+1, tWhite, tDarkGray, False);
  cga_box(LX1, LY1, LX2, LY2, 0);

  { Lower right box }
  shadow_box(RX1-1, RY1-1, RX2+1, RY2+1, tWhite, tDarkGray, False);
  cga_box(RX1, RY1, RX2, RY2, 0);
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
  For i:=1 To NUMOLD Do With old[i] Do Begin
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
  While Not KeyPressed Do Begin
    {*** Line stuff ***}
    Inc(iteration);
    If iteration = MaxLongInt Then iteration := 1;

    Inc(dcount1, 4 - Random(9));
    Inc(dcount2, 4 - Random(9));
    If Abs(dcount1) > 100 Then dcount1 := dcount1*4 Div 5;
    If Abs(dcount2) > 100 Then dcount2 := dcount2*4 Div 5;
    Inc(count1, dcount1);
    Inc(count2, dcount2);

    X1 := LX1 + Trunc(xsize2 + xsize2*Cos(count1*0.002) - 0.5);
    Y1 := LY1 + Trunc(ysize2 + ysize2*Sin(count1*0.002) - 0.5);
    X2 := LX1 + Trunc(xsize2 - xsize2*Cos(count2*0.002) - 0.5);
    Y2 := LY1 + Trunc(ysize2 - ysize2*Sin(count2*0.002) - 0.5);

    With old[iteration Mod NUMOLD + 1] Do Begin
      cga_line(sx, sy, ex, ey, 0);
      sx := X1;
      sy := Y1;
      ex := X2;
      ey := Y2;
    End;

    cga_line(X1, Y1, X2, Y2, ((iteration ShR 4) and (cga_curmode.maxcolors-1)) {+ 1});

    {*** Point stuff ***}
    X := Random(RX2-RX1+1);
    Y := Random(RY2-RY1+1);
    xx := (RX2-RX1+1) ShR 1 - X;
    yy := (RY2-RY1+1) ShR 1 - Y;
    cga_setpixel(RX1 + X,RY1 + Y,
    ((xx*xx+yy*yy) ShR 3) mod cga_curmode.maxcolors);
  End;
End;

Begin
  cga_init(cga_askmode,true);
  {adjust some values for different resolutions -- initial values are calibrated to 160x100}
  lx1:=round(lx1 / (160 / cga_curmode.width));
  lx2:=round(lx2 / (160 / cga_curmode.width));
  rx1:=round(rx1 / (160 / cga_curmode.width));
  rx2:=round(rx2 / (160 / cga_curmode.width));

  ly1:=round(ly1 / (100 / cga_curmode.height));
  ly2:=round(ly2 / (100 / cga_curmode.height));
  ry1:=round(ry1 / (100 / cga_curmode.height));
  ry2:=round(ry2 / (100 / cga_curmode.height));

  {$IFDEF DEBUG}
  asm
    mov ax,3
    int 10h
  end;
  {$ENDIF}

  show_screen;
  demo;

  cga_close;
End.
