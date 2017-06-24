program disppcx;

uses
  support,
  cgalib,
  pcxcga;

begin
  if paramcount<1 then fatalerror(1,'No filename given');
  if not fileexists(paramstr(1)) then fatalerror(2,paramstr(1)+' not found');
  cga_init(cga_askmode,true);
  read_pcx_file(paramstr(1));
  readkeychar;
  cga_close;
end.