program hlinetst;
{
Used to test horizontal line accuracy (vital for polyfilling)
}

uses
  cgalib,cgalib_g,support;

var
  i,j:word;

begin
  cga_init(cga_askmode,true);
  cga_clrscr(true);
  i:=0;
  while (i < (cga_curmode.width div 2))
    and (i < (cga_curmode.height div 2)) do begin
    cga_line(i,i*2,i+i,i*2,cga_curmode.maxcolors-1);
    inc(i);
  end;
  readkeychar;
  cga_close;
end.
