{$R-,S-,Q-}

{{$DEFINE DEBUG}

program dbtest; {drawboxes test}

uses
  crt,
  cgalib,
  cgalib_g,
  m6845ctl;

const
  numboxen=25;
  counter:word=0;

type
  coortype=record
    x,y:integer;
  end;
  boxtype=record
    corners:array[0..1] of coortype;
  end;

var
  randx,randy:integer;
  Ticks:longint ABSOLUTE $0040:$006c;
  boxes:array[0..255] of boxtype;

procedure drawboxen(c:integer);
var
  foo:byte;
begin
  for foo:=0 to numboxen-1 do
    cga_rect(
      boxes[foo].corners[0].x,
      boxes[foo].corners[0].y,
      boxes[foo].corners[1].x,
      boxes[foo].corners[1].y,
      c
    );
end;

procedure calcboxen;
var
  foo:byte;
begin
  for foo:=0 to numboxen-1 do begin
    boxes[foo].corners[0].x:=random(cga_curmode.width div 4)+cga_curmode.width div 4;
    boxes[foo].corners[0].y:=random(cga_curmode.height div 4)+cga_curmode.height div 4;
    boxes[foo].corners[1].x:=cga_curmode.width-boxes[foo].corners[0].x;
    boxes[foo].corners[1].y:=cga_curmode.height-boxes[foo].corners[0].y;
  end;
  inc(counter);
end;

begin
  cga_init(cga_askmode,true);

  calcboxen;

  repeat
    cga_WaitStartDisplayCycle;
    {$IFDEF DEBUG}m6845_setcolor(c_red);{$ENDIF}
    drawboxen(0);
    {$IFDEF DEBUG}m6845_SetColor(c_blue);{$ENDIF}
    calcboxen;
    {$IFDEF DEBUG}m6845_SetColor(c_green);{$ENDIF}
    drawboxen(counter mod cga_curmode.maxcolors);
    {$IFDEF DEBUG}m6845_SetColor(c_black);{$ENDIF}
  until keypressed; repeat readkey until not keypressed;
  cga_close;
end.

