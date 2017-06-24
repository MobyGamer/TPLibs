{$R+,S+,Q+}

{There is no reason to optimize initialization code, since it's only run
once.  This is all you need to make a byte-sized sin LUT:}

Uses
  cgalib,
  support;

const
  sinPeriod:word=1; {number of oscillations in the table}
  sinHeight:word=0; {maximum +/- of sine wave}
  sinLength:word=0; {length of table to fill}

Var
  sintab:Array[0..640-1] of integer;
  i,j:Word;
  oldm:longint;
  pvs:pVidSystem;
  palcols:tpaltype;
  p_palcols:ppaltype;
  base:byte;

Begin
  oldm:=memavail;
  pvs:=init_askmode(true);
  pvs^.setDrawPage(hidden);
  pvs^.clear(0);
  sinHeight:=pvs^.height div 2;
  sinLength:=pvs^.width;
  sinPeriod:=1;
  For i := 0 to pvs^.width-1 Do begin
    sintab[i] := round( (sinHeight-1) * Sin(i * Pi / sinLength * (sinPeriod*2)) );
    pvs^.setpixel(i,sintab[i]+(pvs^.height Div 2),i mod pvs^.maxcolors);
  end;
  i:=pvs^.height;
  if i>pvs^.width then i:=pvs^.width;
  for j:=0 to i-1 do pvs^.setpixel(j,j,pvs^.maxcolors-1);
  ReadKeyChar;
  pvs^.pageflip; {show what we wrote}
  ReadKeyChar;
  {let's try to change the palette}
  if pvs^.vidmode=tan160 then begin
    repeat
      for i:=1 to 15 do palcols[i]:=(base+i) and $0f;
      inc(base);
      {palcols[0]:=0;}
      p_palcols:=@palcols;
      pvs^.setpalette(p_palcols);
    until keypressed;
  end;
  pvs^.Done;
  dispose(pvs);
  writeln('old: ',oldm,#13#10'new: ',memavail);
End.
