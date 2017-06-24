{$M 2048,0,131072}
{this uses the Shadowlord method}

{$R-,S-,Q-}

{$DEFINE VERBOSE}
{{$DEFINE BENCHMARK}
{{$DEFINE DEBUG}
{$DEFINE FPS}
{{$DEFINE JOY} {use joystick to control display}

Program cgarot6;
{
rotates/pans/scales a 256x256 bitmap.  This is the semi-famous Paul H. Kahler
method published in January 1994, adapted to CGA and 8088 optimized by
trixter@oldskool.org.

1st revision: Converted to CGA but not optimized;
horizontal run takes 1717 usec.
2nd revision: use BP as temp register to take memory access out of hrun;
horizontal run takes 1538 usec.
3rd revision: unroll the loop so we don't need to use cx at all;
horizontal run takes 1180 usec.
4th revision: use cx instead of ax so that ax is freed up for stosb.
Horizontal run takes 990 usec; 31 cycles, 12 bytes per pixel
5th revision: swap dl with ch so that mov si,dx can be used to enable movsb.
Horizontal run takes 992 usec; 32 cycles, 9 bytes per pixel
6th revision: borrow idea from Kneebiter's code of filling up ax to use stosw;
horizontal run takes 953 usec; 25.5 cycles, 11.5 bytes per pixel
(if es:di is NOT video ram, hrun takes 848 usec)

For an 8088 with 640K of RAM, that's pretty much all she wrote, gentlemen.
To significantly improve performance, we'd have to trade something for it,
like extra registers or memory -- something PC/8088 doesn't have.
}

Uses
  {$IFDEF BENCHMARK}
  ztimer,
  {$ENDIF}
  {$IFDEF JOY}
  joystick,
  {$ENDIF}
  support,
  cgalib,
  cgalib_g;

const
  UsingDOSMEM:boolean=false;

Var
  {$IFDEF FPS}
  TicksSinceMidnight : longint ABSOLUTE $0040:$006c;
  {$ENDIF}
  SinTable,CosTable: Array[0..255] Of Integer;
  Sin2Table,Cos2Table: Array[0..255] Of Integer;
  Map:Word; {holds the segment of the 256x256 texture}
  p1,p2:pointer; {used to allocate memory from Turbo Pascal heap}
  rot,dr:Word;
  X,Y,dist,dd:Word;
  {$IFDEF BENCHMARK}
  count:longint;
  {$ENDIF}
  {$IFDEF FPS}
  fstart,fend:longint;
  fcount:word;
  {$ENDIF}
  {$IFDEF JOY}
  centx,centy:word;
  {$ENDIF}
  curbank:word;

Procedure MakeTables;                   {Creates sin/cos tables}
Var
  Direction:Integer;
  angle:Real;
Begin
  {$IFDEF VERBOSE} write(#13'Making tables...'); {$ENDIF}
  For Direction:=0 To 255 Do Begin   {use 256 degrees in circle}
    angle:=Direction;
    angle:=angle*PI/128;
    SinTable[Direction]:=Round(Sin(angle)*256);
    CosTable[Direction]:=Round(Cos(angle)*256);
    Sin2Table[Direction]:=Round(Sin(angle+PI/2)*256*0.6); {accounts for pixel aspect ratio}
    Cos2Table[Direction]:=Round(Cos(angle+PI/2)*256*0.6); {1.2 would be appropriate for 320x200 but we're using 80x100}
  End;
End;

Procedure DrawScreen(X,Y,scale:Word; rot:Byte; bank:word);
Var
  Temp:LongInt;            {used for intermediate large values}
  ddx,ddy,D2X,D2Y:Integer;
  i,j:Word;

Begin
  {The following lines of code calculate a 'right' and 'down' vector used
  for scanning the source bitmap.  I use quotes because these directions
  depend on the rotation.  For example, with a rotation, 'right' could mean
  up and to the left while 'down' means up and to the right.  Since the
  destination image (screen) is scanned left-right/top-bottom, the bitmap
  needs to be scanned in arbitrary directions to get a rotation.}

  ddx:=(CosTable[rot]*Scale) Div 256;
  ddy:=(SinTable[rot]*Scale) Div 256;

  {Different tables are used for the 'down' vector to account for non-
  square pixels. The 90 degree difference is built into the tables.
  If you don't like that, then use (rot+64) and 255 here
  and take the pi/2 out of CreateTables.}

  d2x:=(Cos2Table[rot]*Scale) Div 256;
  d2y:=(Sin2Table[rot]*SCALE) Div 256;

  {Since we want to rotate around the CENTER of the screen and not the upper
  left corner, we need to move to the center of the bitmap.}

  i:=X-ddx*(cga_curmode.SLWB div 2)-D2X*(cga_curmode.height div 4);
  j:=Y-ddy*(cga_curmode.SLWB div 2)-D2Y*(cga_curmode.height div 4);

  {The following chunk of assembly does the good stuff. It redraws the entire
  screen by scanning left-right/top-bottom on screen while also scanning the
  bitmap in the arbitrary directions determined above.}

  Asm
    push DS
    mov  AX,[Map]      {set ds: to segment of bitmap}
    mov  DS,AX
    mov  AX,$b800      {set es: to video memory}
    mov  ES,AX
    mov  di,bank    {either 0000h or 2000h depending on which frame}
    mov  AX,[ddx]      {this is just to speed things up later}
    mov  SI,AX         {add ax,si  faster than  add ax,[ddx] }
    mov  CX,100        {Number of rows on Screen}

@vloop:
    push cx            {so we can use it in hloop}
    mov  cx,[i]        {start scanning the source bitmap}
    mov  dx,[j]        {at i,j which were calculated above.}
    push bp {save BP last so we can use it in a loop and restore later to not crash when POPing later}
    mov  bp,ddy {stick ddy in bp so that we can avoid memory access in hloop}

    {$IFDEF BENCHMARK} call _PZTimeron {$ENDIF}

    {This next block is repeated 20 times, for each word of a scanline}
                                                         {cycles  bytes}
    add  cx,SI {ddx}  {add the 'right' vector to the current} {3  2}
    add  DX,bp {ddy}  {bitmap coordinates.  8.8 fixed point}  {3  2}
    inc  di
    mov  BL,ch        {bx = 256*int(y)+int(x)}                {2  2}
    mov  BH,DH                                                {2  2}
    mov  al,[BX]      {load a pixel from source}              {10 3}
    stosb

    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;
    add cx,si;add dx,bp;inc di;mov bl,ch;mov BH,DH;mov al,[BX];stosb;

    {$IFDEF BENCHMARK} call _PZTimeroff {$ENDIF}
    add  di,40 {get DI on next scanline}

    pop  bp
    pop  cx {out of hloop, need to get it back to loop properly}

    mov  AX,D2X        { get the 'down' vector }
    add  i,AX          { i,j is the starting coords for a line }
    mov  AX,D2Y        {(use AX becase mov accum,mem is 10c, 3b)}
    add  j,AX          { so this moves down one line }

    dec  cx            {advance one scanline}
    jnz  @vloop        {can't use LOOP here because it's farther away than +/-128}
    pop  DS            { Restore the ds }
  End;
End;

Procedure AllocateMem;
{Returns a segment pointer for a 64K bitmap.  Can't allocate a full,
true 64K heap area thanks to Turbo Pascal's broken heap manager, so we
try to allocate two consecutive 32K heap areas instead.  If that fails,
fall back to asking DOS for a single 64K segment.}
Begin
  {try to allocate full 64K with TP heap -- it is SUPPOSED to be sequencial}
  getmem(p1,$8000); getmem(p2,$8000);
  if seg(p2^)-seg(p1^)=($8000 div 16) then begin
    map:=seg(p1^);
    usingDOSMEM:=false;
  end else begin {our allocation faile}
    freemem(p2,$8000);
    freemem(p1,$8000);
    Asm
      mov   AH,$48
      mov   BX,$1000     { request 64K }
      Int   $21
      jnc   @noerror
      mov   AX,0000
  @noerror:
      mov   Map,AX       {The segment pointer goes in Map}
    End;
    If (Map=0) Then Begin
      WriteLn('Could not allocate 64K from DOS!');
      Halt;
    end;
    usingDOSMEM:=true;
  End;
End;

Procedure GiveBackMem; {returns the memory used for the map to the system}
Begin
  if usingDOSMEM then begin
    Asm
      mov  AH,$49
      mov  DX,Map
      mov  ES,DX
      Int  $21
    End;
  end else begin
    freemem(p2,$8000); freemem(p1,$8000);
  end;
End;

Procedure DrawImage;  {draws a test image which shows some limitations.}

{ If anyone stuffs in code to load a picture in a standard format
  (ie .gif .bmp etc..) I'd like if you send me a copy. Preferably
  something simple. This will have to do for now. }

Var X,Y:Integer;
Begin
  {$IFDEF VERBOSE} write('Drawing source bitmap:'#13#10'Section 1'); {$ENDIF}
  {For X:=-32768 To 32767 Do mem[Map:X]:=0;}
  fillchar(ptr(map,0)^,$ffff,0);
  {$IFDEF VERBOSE} write(#13'Section 2'); {$ENDIF}
  For Y:=0 To 15 Do          {this just frames the area}
    For X:=Y To 255 Do Begin
      mem[Map:Y*256+X]:=1;
      mem[Map:X*256+Y]:=2;
    End;
  {$IFDEF VERBOSE} write(#13'Section 3'); {$ENDIF}
  For Y:=16 To 47 Do         { this part show Aliasing effects }
    For X:=16 To 255 Do mem[Map:Y*256+X]:=2+(X And 1)+(Y And 1);
  {$IFDEF VERBOSE} write(#13'Section 4'); {$ENDIF}
  For Y:= -50 To 50 Do       { this draw the circles }
    For X:= Round(-Sqrt(2500 - Y*Y)) To Round(Sqrt(2500 - Y*Y)) Do
      mem[Map:(Y+100)*256+X+100]:=(5+(X*X+Y*Y) Div 100) or $f0;
  {$IFDEF VERBOSE} write(#13'Section 5'); {$ENDIF}
  For X:=0 To 100 Do         { These lines also show sampling effects }
    For Y:=0 To 8 Do
{      mem[Map:(Y*2560)+X+41100]:=5;}
      mem[Map:(Y*2560)+X+41100]:=255;
End;

Begin
  AllocateMem;
  DrawImage;
  MakeTables;
  cga_init(mode4,true);
  {$IFDEF DEBUG}
  asm
    mov  ax,0004h
    int  10h
  end;
  {$ENDIF}
  cga_clrscr(true);
  X:=32768; Y:=0;         {this corresponds to (128,0) in fixed point}
  rot:=0; dr:=2;          {rotation angle and it's delta}
  dist:=1200; dd:=65534;  {distance to bitmap (sort of) and its delta}
  {$IFDEF FPS}
  fcount:=0;
  fstart:=tickssincemidnight;
  {$ENDIF}
  {$IFNDEF BENCHMARK}
  {$IFDEF JOY}
  centx:=joystick_posAX;
  centy:=joystick_posAY;
  {$ENDIF}
  Repeat
  {$ENDIF}
    curbank:=curbank xor $2000;
    DrawScreen(X,Y,dist,Lo(rot),curbank);
    {$IFDEF FPS}
    inc(fcount);
    {$ENDIF}
    {$IFDEF JOY}
    if joystick_button(_ja1) then begin
      x:=x+(centx-joystick_posax);
      y:=y+(centy-joystick_posay);
    end else begin
      rot:=rot+(centx-joystick_posax);
      dist:=dist+(centy-joystick_posay);
    end;
    {$ELSE}
    rot:=rot+dr;
    Y:=Y+128;      {slow panning. 1/2 pixel per frame}
    dist:=dist+dd;
    If (dist=2000) Or (dist=2) Then dd:=-dd;
    {If Random(950)=1 Then dr:=Random(7)-3;}
    {$ENDIF}
  {$IFNDEF BENCHMARK}
  Until KeyPressed;
  {$ENDIF}
  {$IFDEF FPS}
  fend:=tickssincemidnight;
  {$ENDIF}
  GiveBackMem;
  cga_close;
  {$IFDEF BENCHMARK}
  _PZTimerReport;
  count := _PZTimerCount;
  writeln('# microseconds for last horizontal run: ',count);
  {$ENDIF}
  {$IFDEF FPS}
  writeln('frames counted: ',fcount,' ticks passed: ',fend-fstart);
  writeln('fps: ',(fcount / ((fend-fstart) / 18.2)):2:2);
  {$ENDIF}
End.
