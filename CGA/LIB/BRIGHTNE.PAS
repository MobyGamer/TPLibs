program brightness;

uses
  support,
  m6845ctl;

var
  f:file;
  b:byte;

begin
  for b:=0 to 15 do writeln(hex(b),' '
  ,hex(cgacolorpal[b].r),',',hex(cgacolorpal[b].g),',',hex(cgacolorpal[b].b)
  ,' ',CalcRecY709(cgacolorpal[b]));
  readkeychar; writeln;
  assign(f,'pcjrcomp.act'); reset(f,1); blockread(f,cgacolorpal,sizeof(cgacolorpal)); close(f);
  for b:=0 to 15 do writeln(hex(b),' '
  ,hex(cgacolorpal[b].r),',',hex(cgacolorpal[b].g),',',hex(cgacolorpal[b].b)
  ,' ',CalcRecY709(cgacolorpal[b]));
end.