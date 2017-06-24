program TVstatic;
{idea by Andrew Jenner}

uses
  cgalib,
  cgalib_g,
  m6845ctl,
  support;

var
  screen:array[0..$4000-1] of byte absolute $b800:0000;
  w:word;

begin
  cga_init(cga_askmode,true);
  for w:=0 to $4000-1 do screen[w]:=random(256);
  repeat
    m6845_SetDisplayAddress(random($4000));
    m6845_WaitVertRetrace;
  until keypressed; readkeychar;
  cga_close;
end.

