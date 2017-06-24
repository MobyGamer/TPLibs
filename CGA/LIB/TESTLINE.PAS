program testline; {benchmarks line drawing}
{$DEFINE VISUAL} {uses visual benchmarking -- change to TIMING to use zen timer}

uses
  support,
  m6845ctl,
  cgalib;

var
  counter:byte;
  x,y:word;
  x1,y1,x2,y2:word;
  c:byte;
  ch:char;
  vs:pvidSystem;

procedure benchon;
begin
  {$IFDEF VISUAL}
  Asm
    mov   cx,m6845_color_sel {we'll need this later}
    mov   dx,m6845_status
  @WDR: {wait during retrace}
    in    AL,DX
    test  AL,c_vertical_sync
    jz    @WDR {loop while not in vertical retrace (still displaying stuff)}

    cli   {clear interrupts -- horizontal is much shorter than vertical}
  @hor1:
    in    AL,DX
    test  AL,c_display_enable or c_vertical_sync
    jnz   @hor1 {loop if in horizontal (or vertical) retrace}
    {now set color}
    {and   al,$0f} {what we previous grabbed has bits set in it -- limit to 16 and use it}
    {above code is disabled because you can actually SEE it execute -- the
    AND takes 4 cycles to fetch and 4 cycles to execute... so we'll just use what we have}
    mov   dx,cx {faster than mov dx,immed}
    out   dx,al
    sti   {turn interrupts back on}
  End;
  {$ENDIF}
end;

procedure benchoff;
begin
  {$IFDEF VISUAL} vs^.setcolor(1); {$ENDIF}
end;

begin
  asm
    mov  ax,0003h
    int  10h
  end;
  writeln('This program tests CGALIB''s line drawing functionality.  A series');
  writeln('of general-purpose and specialized lines are drawn, along with a');
  writeln('visual benchmark of how long it takes the line to draw.  You can');
  writeln('use this program to determine which parts of your line routine');
  writeln('need improvement (for example, horizontal lines are used for filling).');
  writeln('**With good programming, most of the lines drawn here should not exceed');
  writeln('a single frame.**');
  writeln(#13#10'Please choose a video mode:');
  vs:=init_askmode(true);
  {vs^.clear(1,visible);}
  vs^.clear(1);
  repeat {top right to bottom left}
    benchon;
    {vs^.line(0,0,vs^.width-1,vs^.height-1,vs^.maxcolors-1,visible);}
    vs^.line(0,0,vs^.width-1,vs^.height-1,vs^.maxcolors-1);
    benchoff;
    inc(counter); counter:=counter AND $0f;
  until keypressed; repeat ReadKeyChar until not keypressed;
  repeat {top right to bottom left}
    benchon;
    {vs^.line(vs^.width-1,0,0,vs^.height-1,vs^.maxcolors-1,visible);}
    vs^.line(vs^.width-1,0,0,vs^.height-1,vs^.maxcolors-1);
    benchoff;
    inc(counter); counter:=counter AND $0f;
  until keypressed; repeat ReadKeyChar until not keypressed;
  repeat {middle left to middle right (tests fast horizontal filling}
    benchon;
    {vs^.line(0,(vs^.height-1) div 2,
             vs^.width-1,(vs^.height-1) div 2,
             vs^.maxcolors-1,visible);}
    vs^.line(0,(vs^.height-1) div 2,
             vs^.width-1,(vs^.height-1) div 2,
             vs^.maxcolors-1);
    benchoff;
    inc(counter); counter:=counter AND $0f;
  until keypressed; repeat ReadKeyChar until not keypressed;
  repeat {middle top to middle bottom (tests special-case vertical lines}
    benchon;
    {vs^.line((vs^.width-1) div 2,0,(vs^.width-1) div 2,vs^.height-1,vs^.maxcolors-1,visible);}
    vs^.line((vs^.width-1) div 2,0,(vs^.width-1) div 2,vs^.height-1,vs^.maxcolors-1);
    benchoff;
    inc(counter); counter:=counter AND $0f;
  until keypressed; repeat ReadKeyChar until not keypressed;

  x1:=vs^.width div 2; y1:=vs^.height div 2;
  counter:=0;
  repeat {sweep the display}
    for x:=0 to vs^.width-1 do begin
      x2:=x;
      y2:=0;
      c:=counter mod vs^.maxcolors;
      {benchon; vs^.line(x1,y1,x2,y2,c,visible); benchoff;}
      benchon; vs^.line(x1,y1,x2,y2,c); benchoff;
      inc(counter);
    end;
    for y:=0 to vs^.height-1 do begin
      x2:=vs^.width-1;
      y2:=y;
      c:=counter mod vs^.maxcolors;
      {benchon; vs^.line(x1,y1,x2,y2,c,visible); benchoff;}
      benchon; vs^.line(x1,y1,x2,y2,c); benchoff;
      inc(counter);
    end;
    for x:=vs^.width-1 downto 0 do begin
      x2:=x;
      y2:=vs^.height-1;
      c:=counter mod vs^.maxcolors;
      {benchon; vs^.line(x1,y1,x2,y2,c,visible); benchoff;}
      benchon; vs^.line(x1,y1,x2,y2,c); benchoff;
      inc(counter);
    end;
    for y:=vs^.height-1 downto 0 do begin
      x2:=0;
      y2:=y;
      c:=counter mod vs^.maxcolors;
      {benchon; vs^.line(x1,y1,x2,y2,c,visible); benchoff;}
      benchon; vs^.line(x1,y1,x2,y2,c); benchoff;
      inc(counter);
    end;
  until keypressed; repeat ReadKeyChar until not keypressed;
  vs^.Done;
  dispose(vs);
end.
