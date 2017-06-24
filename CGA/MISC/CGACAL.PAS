program cgacal;
{
Displays test pattern with all 16 colors to calibrate CGA monitor.
trixter@oldskool.org 20060118

This program will also simulate CGA on a VGA adapter, for the curious who want
to see the IBM BIOS default colors, which are also modeled after CGA.

Does not support EGA since I don't have EGA set up on a machine right now.
}

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

  cols=40;
  rows=25;

var
  ch:char;
  realCGA:boolean;

Function ReadKeyChar:Char; Assembler;
Asm
  mov ah, 00h
  int 16h
end;

procedure testpattern;

const
  length=5;
  labels:array[0..3] of string[40]=(
    ' blk  blu green cyn  red magntbrown gry ',
    'dark lightlightlightlightlight          ',
    ' gry  blu green cyn  red magnt yel white',
    'Calibrate monitor; hit a key to exit.   '
  );

var
  y,x,baz:byte;

  procedure putcharxy(x,y,ch:byte);
  begin
    mem[$b800:(y*80)+(x*2)]:=ch;
  end;

  procedure putAttrXY(x,y,fore,back:byte);
  begin
    mem[$b800:(y*80)+(x*2)+1]:=(back SHL 4) or fore;
  end;

begin
  asm {clear video memory with spaces}
    mov cx,rows*cols
    mov ax,$b800
    mov es,ax
    xor di,di
    mov ax,0720h {0=back, 7=fore, 20=space}
    rep stosw
  end;
  for y:=0 to (rows div 2)-1 do begin
    for x:=0 to 7 do begin
      for baz:=0 to length-1 do begin
        {top bars}
        putAttrXY((x*length)+baz,y,   15,x  );{15=white text}
        {bottom bars}
        putAttrXY((x*length)+baz,y+12,0, x+8);{0=black text}
      end;
    end;
  end;
  {write out the labels}
  for x:=0 to cols-1 do begin
    putCharXY(x, 6,byte(labels[0][x+1]));
    putCharXY(x,17,byte(labels[1][x+1]));
    putCharXY(x,18,byte(labels[2][x+1]));
    putCharXY(x,24,byte(labels[3][x+1]));
  end;
  {set border color so that composite monitors don't flip out}
  {asm
    mov dx,$3d9
    mov al,6
    out dx,al
  end;}
end;

Procedure InitVideo;
begin
  realCGA:=false;
  if paramcount=0 then begin
    write('CGACAL - Displays a test pattern you can use to calibrate a CGA monitor'#13#10#13#10);
    write('Are you running this program on _real_ CGA hardware?'#13#10);
    write('(If not, or running in an emulator, answer "N") ');
    ch:=upcase(readkeychar);
    if ch='Y' then realCGA:=true;
  end else begin
    realCGA:=true;
  end;

  {set up the video mode}
  if realCGA
    then asm
      mov  ax,01h {set 40x25}
      int  10h
      mov  dx,3d8h
      mov  al,c_videosignalenable {see c_??? const section for explanation}
      out  dx,al
    end else asm {if VGA, do something completely different}
      MOV AX,1200h {set up 200 scan lines}
      MOV BL,30h
      INT 10h
      MOV AX,0001h {set up normal 40x25 text mode}
      INT 10h
      MOV AX,1102h {load 80x50 vga character set}
      MOV BL,00
      INT 10h
      mov ax,1003h {disable blink on ega/vga}
      mov bl,0
      int 10h
    end;
end;

Procedure CloseVideo;
begin
  if realCGA
    then asm
      mov  ax,03h {set 80x25}
      int  10h
      mov  dx,3d8h
      mov  al,c_80cols+c_blink+c_videosignalenable
      out  dx,al
    end else asm {set up 80x50 mode}
      MOV AX,1202h {set up 400 scan lines}
      MOV BL,30h
      INT 10h
      MOV AX,0003h {set up 80x25 text mode}
      INT 10h
      mov ax,1003h {re-enable blink on ega/vga}
      mov bl,1
      int 10h
    end;
end;

begin
  initvideo;
  testpattern;
  readkeychar;
  closevideo;
end.
