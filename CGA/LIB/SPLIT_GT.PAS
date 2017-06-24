program split_tg;
{Attempts to switch from graphics to text mode in mid-frame}

uses
  support,
  m6845ctl;

var
  foop,barp:pointer;
  foo:word;

begin
  writeln('hit a key to start');
  readkeychar;
  asm
    mov ax,0004
    int 10h
  end;
  barp:=ptr($b800,0000);
  foop:=ptr(0,0);
  move(foop^,barp^,$4000); {set up junk on the screen we can see}
  m6845_setmodetable(2); {40x25}
  repeat
    asm
      mov     dx,m6845_status {m6845_status is how we monitor retrace}
      mov     cx,100          {scanline to do the switch at}
      or      cx,1            {switch must start at odd line}
      mov     bx,0108h {bh=c_display_enable, bl=c_vertical_sync}
      {---wait until we're drawing---}
    @wait:
      in      al,dx
      test    al,bl
      jnz     @wait    {loop if already in retrace; otherwise, fall through (drawing)}
    @retrace:
      in      al,dx
      test    al,bl
      jz      @retrace {loop if drawing; otherwise, fall through (in vert. retrace)}
      cli              {shut off interrupts (entering time-critical part)}
    @waitfordraw:
      in      al,dx    {grab horizontal/vertical status}
      test    al,bh    {0 if drawing, 1 if retracing}
      jnz     @waitfordraw {if retracing, keep waiting}
      {--now we're drawing the first scanline.  start counting--}
    @waitforsplit:
     @


      loop    @waitforsplit

      sti              {enable software interrupts (done with critical part)}

    end;
  until keypressed; repeat readkeychar until not keypressed;
  asm
    mov ax,3
    int 10h
  end;
end.

