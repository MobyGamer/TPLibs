program cgacal;

const
  {bits for 6845 $3d8 video control}
  c_80cols=1;
  c_graphicsmode=2;
  c_blackandwhite=4;
  c_videosignalenable=8;
  c_640graphics=16;
  c_blink=32;

  {bits for 6845 $3d9 color control}
  c_red=1;
  c_green=2;
  c_blue=4;
  c_intensity=8;
  c_backgroundintensity=16;
  c_palette1=32;

begin
  asm
        {set 40x25 blink off}
        mov     ax,01h {set 40x25}
        int     10h
        mov     dx,3d8h
        mov     al,c_videosignalenable {see c_??? const section for explanation}
        out     dx,al
        {put something onscreen to look at}
        mov     ax,0b800h
        mov     es,ax
        xor     ax,ax
        push    ds
        mov     ds,ax
        mov     si,ax
        mov     di,ax
        cld
        mov     cx,1000
        rep     movsw
        {wait for user to observe, then dismiss}
        xor     ax,ax
        int     16h
  end;
end.