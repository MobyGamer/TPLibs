program crtctwkt;
{
Display, tweak, and reset the crtc registers in an attempt to come up
with new text video modes.  Unfinished, but works enough to
explore new text modes.  I got a 90x30 mode working :-)
}

uses
  cgalib,
  cgalib_g,
  m6845ctl,
  crt;

var
  oldregs,newregs:m6845_moderegs;
  _width,_height:byte; {for testing}
  foop:pointer;
  ch:char;

procedure savemode;
var
  f:file;numwritten:word;
begin
  assign(f,'mode.dmp');
  rewrite(f,1);
  blockwrite(f,newregs,sizeof(newregs),numwritten);
  close(f);
  if numwritten<>sizeof(newregs) then begin
    sound(200);
    delay(500);
    nosound;
  end;
end;

procedure testgrid;
{displays a visual test grid}
var
  x,y:byte;
begin
  asm
    mov   ax,$b800
    mov   es,ax
    xor   di,di
    mov   ax,$0700
    mov   cx,$2000
    rep   stosw
  end;
  for y:=0 to _height-1 do begin
    for x:=0 to _width-1 do begin
       if {(x=0) or }(y=0) or (x=_width-1) or (y=_height-1)
         then begin
           mem[$b800:(y*(_width*2))+(x*2)]:=48+(x mod 10);
         end;
    end;
  end;
end;

procedure reset;
{resets to stock video mode to see what you're doing}
begin
  asm
    mov ax,03
    int 10h
  end;
{  _width:=80;
  _height:=25;}
  writeln('reset!');
end;

Procedure DisplayCalcs;
begin
  testgrid;
  gotoxy(1,1);
  writeln('calcs:');
  writeln('_width: ',_width,'_height: ',_height);
  writeln('Mode regs:');
  with newregs do begin
    writeln('horizontal_total:         ',horizontal_total,' (total characters per scanline-1)');
    writeln('horizontal_displayed:     ',horizontal_displayed,' (characters displayed in each scanline)');
    writeln('horizontal_sync_position: ',horizontal_sync_position,' (Pos. in scanline where hor. retrace starts)');
    writeln('horizontal_sync_width:    ',horizontal_sync_width,' (Duration of hor. retrace interval (char.clcks))');
    writeln('vertical_total:           ',vertical_total,' (Total character rows in one frame)');
    writeln('vertical_total_adjust:    ',vertical_total_adjust,' (Remaining scanlines in one frame)');
    writeln('vertical_displayed:       ',vertical_displayed,' (Character rows displayed in each frame)');
    writeln('vertical_sync_position:   ',vertical_sync_position,' (Pos. in frame where vert. retrace starts)');
    writeln('interlace_mode:           ',interlace_mode,' (set to 2; IBM 5153 doesn''t support interlacing)');
    writeln('maximum_scanline:         ',maximum_scanline,' (height of one character, in scanlines-1)');
  end;
  writeln('Reminder: dots per line: ',m6845_cga_dots_per_line,
    ' chars per line: ',m6845_cga_dots_per_line div 8,
    ' lines per frame: ',m6845_cga_lines_per_frame
  );
end;

begin
  directvideo:=true;
  checksnow:=true;
  _width:=80;
  _height:=25;
  reset;
  move(Int1D_Mode_Table^.modes[1{80x25}],oldregs,sizeof(oldregs));
  move(oldregs,newregs,sizeof(newregs));
  testgrid;
  displaycalcs;
  repeat
    ch:=readkey;
    with newregs do begin
      case (ch) of
      'r':reset;
      'R':begin move(oldregs,newregs,sizeof(newregs)); reset; end;
      'g':testgrid;
      's':savemode;

      '0':inc(maximum_scanline);
      '9':dec(maximum_scanline);
      'T':inc(horizontal_total);
      't':dec(horizontal_total);
      'D':begin inc(horizontal_displayed); inc(_width); end;
      'd':begin dec(horizontal_displayed); dec(_width); end;
      '+':inc(horizontal_sync_position);
      '-':dec(horizontal_sync_position);
      'V':inc(vertical_sync_position);
      'v':dec(vertical_sync_position);
      'Q':inc(vertical_total);
      'q':dec(vertical_total);

      '2':begin
            inc(_height);
            vertical_displayed:=_height;
            vertical_total_adjust:=vertical_total-vertical_displayed;
          end;
      '1':begin
            dec(_height);
            vertical_displayed:=_height;
            vertical_total_adjust:=vertical_total-vertical_displayed;
          end;
      '8':begin {trying to work up an 80x25 mode here}
            vertical_displayed:=25;
            vertical_total_adjust:=6;
            vertical_total:=vertical_displayed+vertical_total_adjust;
            vertical_sync_position:=vertical_displayed+3;
            maximum_scanline:=7;
          end;
      '5':begin {trying to work up an 80x50 mode here}
            vertical_displayed:=50;
            vertical_total_adjust:=12;
            vertical_total:=vertical_displayed+vertical_total_adjust;
            vertical_sync_position:=vertical_displayed;
            maximum_scanline:=3;
          end;
      'i':begin {trying for 80x25-based interlaced 400 lines}
            interlace_mode:=3; {00000011b}
          end;

      #32:m6845_SetUserModeTable(@newregs);
      end; {case}
    end;
    displaycalcs;
  until ch=#27;
  reset;
  displaycalcs;
end.
