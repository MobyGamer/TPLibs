program testram;
{
tests CGA RAM for errors

I worked my CGA so hard in developing this library that some of the pixels
started to display single-bit errors that flickered on and off, so to
determine if it was the display RAM, I wrote this program.
}

uses
  cgalib,
  support;

const
  cgasize=16384;

type
  scr=array[0..cgasize-1] of byte;
  pscr=^scr;

var
  rambuf,scrbuf:pscr;
  foo,bar:word;

begin
  getmem(rambuf,cgasize);
  scrbuf:=ptr($b800,0);
  cga_init(cga_askmode,true);
  cga_clrscr(true);
{  for foo:=0 to cgasize-1 do rambuf^[foo]:=foo and $ff;}
  asm
    les di,rambuf
    mov cx,cgasize
  @l:
    mov ax,cx
    stosb
    loop @l
  end;
  moveword(rambuf,scrbuf,cgasize);
  {fake an error for testing} (*rambuf^[12345]:=0;*)
  repeat
    foo:=BuffersEqual(rambuf,scrbuf,cgasize);
  until (foo<>0) or keypressed;
  cga_close;
  if foo<>0
    then fatalerror(1,'Different at offset: '+inttostr(foo-1))
    else fatalerror(0,'(no error, buffers are equal)');
end.
