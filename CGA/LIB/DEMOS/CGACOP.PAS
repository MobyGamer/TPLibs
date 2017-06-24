{$R-}
Program CGACopper;
{
CGA copper routine, originally implemented for Tandy 1000 by Jon Merkel.
Adapted for CGA and optimzied by trixter@oldskool.org.  20050613

The basic idea is to wait for horizontal retrace, then (quickly!!) change
the background color.  Do this every line, and you can give each scanline
a different background color, giving you all 16 colors onscreen at once
(albeit in horizontal lines that reach from one side of the screen to the
other).  While some impressive full-screen SIN magic could be performed
this way, this program only displays a single copper bar. You do the rest :-)
}

uses
  m320_640,
  m6845ctl;

const
  barsize=22;
  coppersize=150;
  height=coppersize-barsize;
  bar:array [1..barsize] of byte=(
    {gray bar; each value is a color index}
    {8,8,8,7,8,7,7,7,15,15,7,15,15,7,7,7,8,7,8,8,8,0}
    {blue bar}
    1,1,1,9,1,9,9,9,3,3,9,3,3,9,9,9,1,9,1,1,1,0
  );
  start:integer=0;
var
  startlist:array [0..127] of word;
  copperlist:array [1..coppersize] of byte;

procedure DoCopper; assembler;
asm
  mov     dx,m6845_status {m6845_status is how we monitor retrace}
  mov     si,offset copperlist {point si to list of scanline colors}
  mov     cx,coppersize {number of lines to set}
  mov     bx,0108h {bh=c_display_enable, bl=c_vertical_sync}
@wait:
  in      al,dx
  test    al,bl
  jnz     @wait    {loop if in already in retrace}
@retrace:
  in      al,dx
  test    al,bl
  jz      @retrace {loop if not; when we exit this loop, we're in vert. retrace}
  dec     dx       {get dx ready by setting to $3d9 for what we're going to do with it}
  cli              {shut off interrupts (entering time-critical part)}
@loop:             {We probably don't need to CLI; just a bad habit, I guess :-}
  inc     dx       {increment dx to 03DA which is m6845_status}
  mov     ah,[si]  {load our color from the list of scanline colors}
  inc     si       {move it to the next color in the list}
@w:
  in      al,dx
  test    al,bh
  jnz     @w       {loop if in horizontal retrace (just in case we're already in the middle of it}
@r:
  in      al,dx
  test    al,bh
  jz      @r       {loop if NOT in horizontal retrace -- when loop ends, we are in horizontal retrace}
  dec     dx       {move dx back down to 03D9 which is m6845_color_select}
  mov     al,ah    {get our color back into al...}
  out     dx,al    {...so we can change the background color}
  loop    @loop    {loop for the rest of the scanlines}
  sti              {enable software interrupts (done with critical part)}
end;

var
  j:word;
begin
  for j:=0 to 127 do {build the sin array}
    startlist[j]:=round(height/2*sin(j*pi/64)+height/2)+1;
  mode4_set;
  for j:=0 to 80*50 do {fill screen with some garbage for display}
    mem[$B800:j*2]:=random(256);
  repeat
    fillchar(copperlist, coppersize, 0); {init copperlist to 0}
    move(bar, copperlist[startlist[start]], barsize); {copy our copper bar into the copperlist at a (moving) start point}
    start:=(start+1) and $7F;
    DoCopper;
  until mem[0:$41A] <> mem[0:$41C]; {detect keypress}
  asm
    xor ax,ax
    int $16
  end; {discard keypress}
  asm
    mov ax,3
    int $10
  end; {switch back to text mode}
end.
{
Hey Jon:  I optimized your time critical code from):

  mov dl,0D9h 4c 2b
  mov al,ah   2c 2b
  out dx,al   8c 1b = 14 cycles and 5 bytes = 34 cycles worst case

to:

  dec dx      3c 1b
  mov al,ah   2c 2b
  out dx,al   8c 1b = 13 cycles and 4 bytes = 29 cycles worst case

Who's the man?  Who's the man?!?  ;-)
Of course, before I gloat TOO much, I haven't tried this on a PCjr.
Those things are 100% display memory... fuckers :-)
}
