program bittest;

uses
  m6845ctl,
  support;

begin
  asm
    mov ax,0003
    int 10h
    push ds
    mov ax,0
    mov ds,ax
    xor si,si
    mov ax,$b800
    mov es,ax
    mov di,si
    mov cx,(80*25)
    rep movsw
  end;
  readkeychar;
  port[$3d9]:=c_alternate_intensity;
  readkeychar;
  port[$3d8]:=c_fast_char_clock+c_videosignal_enable;
  readkeychar;
end.

