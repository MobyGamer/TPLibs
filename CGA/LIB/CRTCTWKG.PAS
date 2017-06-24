program crtctwkg;
{Display, tweak, and reset the crtc registers in an attempt to come up
with new graphics video modes.}
{MANY thanks to Andrew Jenner for mode ideas and tweaking!}

uses
  cgalib,
  cgalib_g,
  m320_640,
  m6845ctl,
  crt;

const
  thisw=320;
  thish=200;

var
  oldregs,newregs:m6845_moderegs;
  _width:word;_height:byte; {for testing}
  foop:pointer;
  ch:char;
  loopw:word;
  addrofs:word;
  offsets:array[0..199] of word;
  b:byte;

procedure testgrid;
{displays a visual test grid}
var
  b,x,y:byte;
begin
  asm
    mov   ax,$b800
    mov   es,ax
    xor   di,di
    mov   ax,0000010110101111b
    mov   cx,$1000
    rep   stosw
    mov   ax,0011001110011001b
    mov   cx,$1000
    rep   stosw
  end;

{ for y:=0 to 99 do mode4_line_direct(0,y*2,319,y*2,1);}

  mode4_line_direct(0,0,thisw-1,thish-1,3);
  mode4_line_direct(0,thish-1,thisw-1,thish-1,1);
  mode4_line_direct(thisw div 2,0,thisw div 2,thish-1,2);

  {need some colored lines to judge interlacing}
  mode4_line_direct(0,0,thisw-1,0,0);
  mode4_line_direct(0,1,thisw-1,1,1);
  mode4_line_direct(0,2,thisw-1,2,2);
  mode4_line_direct(0,3,thisw-1,3,3);

  {color combinations on monitors that don't interlace}
  mode4_line_direct(0,4,thisw-1,4,0);
  mode4_line_direct(0,5,thisw-1,5,1);
  mode4_line_direct(0,6,thisw-1,6,0);
  mode4_line_direct(0,7,thisw-1,7,2);
  mode4_line_direct(0,8,thisw-1,8,0);
  mode4_line_direct(0,9,thisw-1,9,3);
  mode4_line_direct(0,10,thisw-1,10,1);
  mode4_line_direct(0,11,thisw-1,11,1);
  mode4_line_direct(0,12,thisw-1,12,1);
  mode4_line_direct(0,13,thisw-1,13,2);
  mode4_line_direct(0,14,thisw-1,14,1);
  mode4_line_direct(0,15,thisw-1,15,3);

  {trying to discern individual lines in 400-line interlaced mode}
  mode4_line_direct(0,16,thisw-1,16,0);
  mode4_line_direct(0,17,thisw-1,17,1);
  mode4_line_direct(0,18,thisw-1,18,2);
  mode4_line_direct(0,19,thisw-1,19,3);
  mode4_line_direct(0,20,thisw-1,20,0);
  mode4_line_direct(0,21,thisw-1,21,1);
  mode4_line_direct(0,22,thisw-1,22,2);
  mode4_line_direct(0,23,thisw-1,23,3);

  mode4_line_direct(0,100,thisw-1,100,3);
  mode4_line_direct(0,101,thisw-1,101,2);
  mode4_line_direct(0,102,thisw-1,102,1);
  mode4_line_direct(0,103,thisw-1,103,0);

{  for y:=0 to _height-1 do begin
    for x:=0 to ((_width-1) SHR 2) do begin
      if (x=0) or (y=0) or (x=_width-1) or (y=_height-1)
        then begin
          mem[$b800:(y*(_width SHR 2))+(x SHR 2)]:=(x and 3);
        end;
    end;
  end;}
  for b:=0 to 22 do writeln(b);
end;

procedure reset;
{resets to stock video mode and vars}
var
  b:byte;
begin
  asm
    mov ax,04
    int 10h
  end;
  writeln('reset!');
  {for b:=1 to 23 do writeln(b);}
end;

Procedure DisplayCalcs;
begin
  gotoxy(1,1);
  writeln('calcs:');
  writeln('_width: ',_width,'_height: ',_height);
  writeln('Mode regs:');
  with newregs do begin
    writeln('horizontal_total:         ',horizontal_total);
    writeln('horizontal_displayed:     ',horizontal_displayed);
    writeln('horizontal_sync_position: ',horizontal_sync_position);
    writeln('horizontal_sync_width:    ',horizontal_sync_width);
    writeln('vertical_total:           ',vertical_total);
    writeln('vertical_total_adjust:    ',vertical_total_adjust);
    writeln('vertical_displayed:       ',vertical_displayed);
    writeln('vertical_sync_position:   ',vertical_sync_position);
    writeln('interlace_mode:           ',interlace_mode);
    writeln('maximum_scanline:         ',maximum_scanline);
(*    writeln('Dots per line: ',m6845_cga_dots_per_line,
      '.  Chars per line: ',m6845_cga_dots_per_line div 8{,
      ' lines per frame: ',m6845_cga_lines_per_frame this is a default, not actual!}
    );                                                    *)
    writeln('Modes at (or close to) 262 total lines should vertically sync properly.');
    writeln('Your mode has ',
            (vertical_total+1)*(maximum_scanLine+1)+vertical_total_adjust,
            ' lines.');
  end;
end;

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

begin
  addrofs:=0;
  directvideo:=false;
  reset;

  move(Int1D_Mode_Table^.modes[2{cgagraf}],oldregs,sizeof(oldregs));
  move(oldregs,newregs,sizeof(newregs));
  testgrid;
  {displaycalcs;}
  _height:=thish;
  _width:=thisw;
  repeat
    ch:=readkey;
    with newregs do begin
      case (ch) of
      'r':reset;
      'R':begin
            move(oldregs,newregs,sizeof(newregs));
            reset;
            _width:=thisw;
            _height:=thish;
            addrofs:=0;
          end;
      'g':testgrid;
      #13:displaycalcs;

      '0':inc(maximum_scanline);
      '9':dec(maximum_scanline);
      'T':inc(horizontal_total);
      't':dec(horizontal_total);
      'D':begin inc(horizontal_displayed); inc(_width,8); end;
      'd':begin dec(horizontal_displayed); dec(_width,8); end;
      '+':inc(horizontal_sync_position);
      '-':dec(horizontal_sync_position);
      '.':inc(vertical_sync_position);
      ',':dec(vertical_sync_position);

      '2':begin
            inc(_height);
            inc(vertical_displayed);
            dec(vertical_total_adjust)
          end;
      '1':begin
            dec(_height);
            dec(vertical_displayed);
            inc(vertical_total_adjust);
          end;

      's':savemode;

      'j':begin { attempt at double-pixel-hi graphics modes, mostly useless }
            horizontal_total:=113;
            vertical_total_adjust:=3;
            maximum_scanline:=0;
          end;
      'J':begin {attempt at an interlaced mode, not quite working}
            interlace_mode:=1; {works, but useless :-)}
            vertical_displayed:=vertical_displayed SHR 1;
          end;
      'k':begin {let's try a 320x100 mode}
            vertical_displayed:=vertical_displayed shr 1; {from 100 to 50}
            vertical_sync_position:=87 {vertical_sync_position shr 1}; {from 112 to 65?}
          end;
      'K':begin {let's try a double-hi mode with pages}
            horizontal_total:=113; {56}
            vertical_total:=63; {127}
            vertical_total_adjust:=3; {6}
            vertical_displayed:=50; {100}
            vertical_sync_position:=56; {112}
          end;
      'l':begin {results in ababcdcd pattern -- not too useful}
            vertical_total:=64; {127}
            vertical_total_adjust:=2; {6}
            vertical_displayed:=50; {100}
            vertical_sync_position:=56; {112}
            maximum_scanline:=3; {1}
          end;
      'L':begin {attempt at 160x400 interlaced mode #1}
            horizontal_total:=55; {56}
            horizontal_displayed:=20; {40}
            horizontal_sync_position:=35; {45}
            horizontal_sync_width:=10; {10}
            vertical_total:=127; {64}
            vertical_total_adjust:=11; {2} {11=59.85Hz; 10=60.08Hz}
            vertical_displayed:=100; {50}
            vertical_sync_position:=112; {56}
            interlace_mode:=3; {2}
            maximum_scanline:=1; {3}
          end;
      'm':begin {attempt at 160x400 interlaced mode #2}
            horizontal_total:=57; {56}
            horizontal_displayed:=20; {40}
            horizontal_sync_position:=35; {45}
            horizontal_sync_width:=10; {10}
            vertical_total:=127; {64}
            vertical_total_adjust:=2; {2} {1=60.04Hz; 2=59.80Hz}
            vertical_displayed:=100; {50}
            vertical_sync_position:=112; {56}
            interlace_mode:=3; {2}
            maximum_scanline:=1; {3}
          end;
      '|':repeat {wobble attempt #1}
            asm cli end;
            m6845_WaitStartDisplayCycle;
            for loopw:=0 to 6 do begin
              inc(horizontal_sync_position); m6845_SetUserModeTable(@newregs);
              dec(horizontal_sync_position); m6845_SetUserModeTable(@newregs);
            end;
            m6845_WaitVertRetrace;
            asm sti end;
          until keypressed;
      '\':begin {let's try -- hold onto your hats -- 640x200 in *4* colors -- almost works except pixel clock is confused}
            {horizontal regs set for 80x25}
            horizontal_total:=113;
            horizontal_displayed:=80;
            horizontal_sync_position:=90;
            horizontal_sync_width:=10;
            {vertical regs set for graphics mode}
            vertical_total:=127;
            vertical_total_adjust:=6;
            vertical_displayed:=100;
            vertical_sync_position:=112;
            interlace_mode:=2;
            maximum_scanline:=1;
            m6845_SetUserModeTable(@newregs);
            m6845_SetMode(0);
            m6845_SetMode(c_fast_char_clock+c_graphics_enable+c_videosignal_enable);
          end;
      '>':begin
            inc(addrofs);
            m6845_SetDisplayAddress(addrofs);
          end;
      '<':begin
            dec(addrofs);
            m6845_SetDisplayAddress(addrofs);
          end;

      #32:m6845_SetUserModeTable(@newregs);
      end; {case}
    end;
    {displaycalcs;}
  until ch=#27;
  reset;
  asm
    mov   ax,03
    int   10h
  end;
  displaycalcs;
end.