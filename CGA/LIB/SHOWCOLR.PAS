{$R-,Q-}

program showcolr;
{
Shows all the possible colors of a certain video mode.
}

uses
  cgalib,cgalib_g,support;

const
  numsqx=16;
  numsqy=16;

var
  i,j:word;
  xw,yw:byte;
  c:byte;
  vs:pvidSystem;

begin
  vs:=init_askmode(true);
  vs^.clear(1);

  c:=0;
  For i:=0 To numsqx-1 Do
    For j:=0 To numsqy-1 Do begin
      xw:=vs^.width div numsqx;
      yw:=vs^.height div numsqy;
      vs^.box(i*xw, j*yw, xw+(i*xw)-1, yw+(j*yw)-1,c mod vs^.maxcolors);
      inc(c);
    end;
  readkeychar;
  vs^.Done;
  dispose(vs);
end.
