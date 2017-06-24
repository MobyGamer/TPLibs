program setmodetest;
{Dumb little program to illustrate how QUICKLY you can switch video modes
without using the BIOS.  Unfortunately, it's not seamless; there is a tiny
amount of "bounce" as the CGA monitor picks up the sync of the new video
mode.  This small frame of resync prevents some cool tweakmodes I had
in mind, like text and graphics mixed :-).  Oh well, still fun to see just
how fast you can switch.}

uses
  support,
  m320_640,
  m_textm,
  m6845ctl;

var
  foop,barp:pointer;
  foo:word;

{{$DEFINE DEBUG}
begin
  barp:=ptr($b800,0000);
  foop:=ptr(0,0);
  move(foop^,barp^,$4000);
  m6845_setmodetable(0);
  repeat
    {$IFDEF DEBUG}for foo:=0 to 60 do m6845_waitvertretrace;{$ENDIF}
    m6845_waitvertretrace;
    m6845_SetMode(c_videosignal_enable+c_graphics_enable);
    {$IFDEF DEBUG}for foo:=0 to 60 do m6845_waitvertretrace;{$ENDIF}
    m6845_waitvertretrace;
    {mode4_set;}
    m6845_SetMode(c_videosignal_enable{+c_80x25_enable});
  until keypressed; repeat readkeychar until not keypressed;
  asm
    mov ax,3
    int 10h
  end;
end.

