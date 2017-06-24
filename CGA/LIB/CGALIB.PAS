{$O+,F+}
{{$DEFINE DEBUG}
{$DEFINE FASTCLEAR}
{{$DEFINE FAKEHIDDEN} {try to emulate fake hidden pages}
unit cgalib;

{
version 0.2, trixter@oldskool.org.  Hurredly coded at the partyplace on
20090419 and then cleaned up the week thereafter.

CGALib is an OOP graphics library for IBM color video systems based on the
Motorola 6845 character generator.  These include:
  CGA text and graphics modes, both stock and "tweaked"
  Tandy 1000 and PCjr graphics modes (incomplete)

Features include:
  - pixel
  - line
  - rectangle
  - filled box
  - hidden/visible page facility

Video pages work two ways in CGALIB:
  If there is only one physical video page, then:
    - PageFlip() will copy that page to video ram
  If there are two or more physical pages, then:
    - PageFlip() will toggle the display between two different areas of
    video ram; and automatically flip the active drawing page

OOP Organization:

tVidSystem
  tVidCGAG
    tVidCGAGmode4        320x200x4
    tVidCGAGmode6        640x200x2
    tVidCGAGcomposite    160x200x16
  tVidTANG
    tVidTANG160          160x200x16
    tVidTANG320          320x200x16
    tVidTANG640          640x400x4
  tVidCGAT
    tVidCGAT40x25        40x25x136
    tVidCGAT80x25        80x25x136
    tVidCGAT40x50        40x50x136
    tVidCGAT80x50        80x50x136
    tVidCGAT40x100       40x100x136
    tVidCGAT80x100       80x100x136
    tVidlowres           160x100x16

To do:
  - flesh out each mode with hierarchy
  - pageflip/setactive/segs for each mode
  - make textmode routines use charmask
  - sprite facilities
}

interface

uses
  objects;

const
  nummodes=12;

type
  tpaltype=array[0..15] of byte; {for tandy/pcjr palettes}
  ppaltype=^tpaltype;

  vidmodetype=(
    {All text modes use #177 (±) as the "pixel" which gives us maximum 136 "colors"}
    text40x25, text80x25, {stock text modes}
    text40x50, text80x50, text40x100,text80x100, {tweaked text modes}
    lowres, {"lowres" 160x100x16, uses ASCII #222 (Þ) to enable use of the attribute byte as "pixels"}
    mode4,mode6, {320x200x4 and 640x200x2}
    composite, {160x200x16 composite color CGA}
    tan160, {tandy/pcjr 160x200x16}
    dummy {used for benchmarking purposes}
  );
  pagetype=(hidden,visible);

  {Parent generic class object "vidsystem" for screwing with graphics mode.}
  pvidSystem=^tvidSystem;
  tvidSystem=object(TObject)
    vidMode:vidmodetype;
    Width:word; {width in pixels.  Example: 320 (range [0..319])}
    Height:word; {height in pixels.  Example: 200 (range [0..199])}
    MaxColors:word;
    BitsPerPixel:byte;
    SLW:word; {ScanLineWidth, in bytes}

    {hidden/visible/virtual page support stuff.  The idea is that there are
    two pages available, one for drawing and one for showing.  These swap
    places whenever the user wants to show the hidden stuff as visible and
    then start working behind the scenes again.  The user selects which
    page to draw on with setDrawPage() and can flip pages with PageFlip.
    With hardware video pages, the active drawing page is automatically
    flipped when display pages are.  With software pages, the active drawing
    page stays set to the hidden buffer, unless setDrawPage() is called
    to point to the visible screen.}
    hardwarepages:boolean;
    page0,page1,DrawPage:pointer; {pointers to screen buffers.  page0 is always real hardware video ram}
    curpage,numpages:byte; {curpage = current displayed/visible page}
    BufSize:word; {if hidden buffer needs to be allocated in main memory, this is its size}

    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure clear(color:byte); virtual;
    {Clears page to a certain value}
    Procedure line(x1,y1,x2,y2:integer;color:byte); virtual;
    {Draws a line from x1,y1 to x2,y2.  Clipping is not currently implemented.}
    Procedure setpixel(x,y:integer;color:byte); virtual;
    {Sets a pixel element.  Clipping is not currently implemented.}
    Procedure rect(x1,y1,x2,y2:integer;color:byte); virtual;
    Procedure box(x1,y1,x2,y2:integer;color:byte); virtual;
    {Draws an open or filled rectangle.  x1,y1 is assumed
    to be the upper-left coordinate and x2,y2 the bottom-right.}
    Procedure WaitVertRetrace;
    Procedure WaitStartDisplayCycle;
    Procedure SetDrawPage(p:pagetype); virtual;
    {Sets which page the routines plot to}
    Procedure pageflip; virtual;
    {makes the hidden page visible and vice versa.}
    Procedure setcolor(color:byte); {sets the background (320x200) or
    foreground (640x200) or border (textmode) color index}
    Procedure setpalette(var palcols:ppaltype); virtual; {an array of index
    entries to replace the current index entries}

    private

    vHidden,vVisible:word; {segments to various buffers.  These will be fixed
    if only one video page available (one in system ram, the other real)}
    usebios:boolean; {use the BIOS when setting video modes.  Slower, but
    more compatible with emulators.}
  end; {object}

  {cga-specific modes}

  pvidCGAG=^tvidCGAG; {CGA non-tweaked graphics-based modes generic class}
  tvidCGAG=object(tvidSystem)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure setDrawPage(p:pagetype); virtual; {needed to set active seg for cga routines}
    Procedure pageflip; virtual;
  end;

  pvidCGAGmode4=^tvidCGAGmode4;
  tvidCGAGmode4=object(tvidCGAG)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure line(x1,y1,x2,y2:integer;color:byte); virtual;
    Procedure setpixel(x,y:integer;color:byte); virtual;
  end;

  pvidCGAGmode6=^tvidCGAGmode6;
  tvidCGAGmode6=object(tvidCGAG)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure line(x1,y1,x2,y2:integer;color:byte); virtual;
    Procedure setpixel(x,y:integer;color:byte); virtual;
  end;

  pvidCGAGcomposite=^tvidCGAGcomposite; {CGA graphics-based modes}
  tvidCGAGcomposite=object(tvidCGAG)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure line(x1,y1,x2,y2:integer;color:byte); virtual;
    Procedure setpixel(x,y:integer;color:byte); virtual;
  end;

  {tandy-specific modes}

  pvidTANG=^tvidTANG; {tandy/pcjr non-tweaked graphics-based modes generic class}
  tvidTANG=object(tvidSystem)
    NumRamPages:byte; {number of 16k pages a screen needs -- either 1 or 2}
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure setDrawPage(p:pagetype); virtual; {needed to set active seg for cga routines}
    Procedure pageflip; virtual;
    Procedure setpalette(var palcols:ppaltype); virtual;
  end;

  pvidTANG160=^tvidTANG160; {CGA graphics-based modes}
  tvidTANG160=object(tvidTANG)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure line(x1,y1,x2,y2:integer;color:byte); virtual;
    Procedure setpixel(x,y:integer;color:byte); virtual;
  end;

  {text modes}

  pvidCGAT=^tvidCGAT; {CGA text-based modes generic class}
  tvidCGAT=object(tvidSystem)
    charmask:char; {#177 for shaded, or the halfbar for lowres}
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure line(x1,y1,x2,y2:integer;color:byte); virtual;
    Procedure setpixel(x,y:integer;color:byte); virtual;
    {$IFDEF FASTCLEAR}
    Procedure clear(color:byte); virtual;
    {$ENDIF}
    Procedure pageflip; virtual;
    Procedure setDrawPage(p:pagetype); virtual; {needed to set active seg for cga routines}
  end;

  pVidCGAT40x25=^tVidCGAT40x25;
  tVidCGAT40x25=object(tvidCGAT)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
  end;

  pVidCGAT80x25=^tVidCGAT80x25;
  tVidCGAT80x25=object(tvidCGAT)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
  end;

  pVidCGAT40x50=^tVidCGAT40x50;
  tVidCGAT40x50=object(tvidCGAT)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
  end;

  pVidCGAT80x50=^tVidCGAT80x50;
  tVidCGAT80x50=object(tvidCGAT)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
  end;

  pVidCGAT40x100=^tVidCGAT40x100;
  tVidCGAT40x100=object(tvidCGAT)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
  end;

  pVidCGAT80x100=^tVidCGAT80x100;
  tVidCGAT80x100=object(tvidCGAT)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
  end;

  pvidLowres=^tvidLowres; {CGA classic 160x100 lowres text-based mode}
  tvidLowres=object(tvidCGAT)
    Constructor Init(mode:vidmodetype;compatible:boolean);
    Destructor Done; virtual;
    Procedure clear(color:byte); virtual;
    Procedure line(x1,y1,x2,y2:integer;color:byte); virtual;
    Procedure setpixel(x,y:integer;color:byte); virtual;
  end;

function init_askmode(compatible_init:boolean):pVidsystem;
{asks the user what video mode they want to use and returns a pointer
as the initialized object}

const
  ModeDescriptions:array[text40x25..dummy] of string[40]=(
    '40x25   136 colors',
    '80x25   136 colors',
    '40x50   136 colors',
    '80x50   136 colors',
    '40x100  136 colors',
    '80x100  136 colors',
    '160x100 16 colors',
    '320x200 4 colors',
    '640x200 2 colors',
    '160x200 composite color',
    '160x200 16 colors (Tandy)',
    'dummy   (used for benchmarking)'
  );


implementation

uses
  support,
  m6845ctl, {motorola 6845 control}
  m320_640, {mode-specific routines for 320x200x4 and 640x200x2}
  m_comp,   {mode-specific routines for 160x200x16 composite color CGA}
  m_lowres, {mode-specific routines for "lowres" mode (160x100x16 tweaked text}
  m_textm;  {the lowest of low-res modes :-)  Contains standard and tweaked text modes}

{----generic video system----}

Constructor tVidSystem.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init;
  {mystuff follows}
  vidMode:=mode;
  Width:=8;
  Height:=8;
  MaxColors:=2;
  BitsPerPixel:=1;
  SLW:=1; {ScanLineWidth, in bytes}
  bufSize:=8; {total size of a screen (buffer), in bytes}
  page0:=ptr($b800,0000); {pointers to screen buffers}
  page1:=nil; {this is the responsibility of child objects}
  DrawPage:=page0;
  curpage:=0;
  numpages:=1;
  BufSize:=8; {if hidden buffer needs to be allocated in main memory, this is its size}
  usebios:=compatible;
end;

Destructor tVidSystem.Done;
begin
  {mystuff}
  asm
    mov ax,0003
    int 10h
  end;
  Inherited Done;
end;

Procedure tVidSystem.clear(color:byte);
begin
  {generic class}
  box(0,0,width-1,height-1,color);
end;

Procedure tVidSystem.line(x1,y1,x2,y2:integer;color:byte);
begin
  {generic class}
end;

Procedure tVidSystem.setpixel(x,y:integer;color:byte);
begin
  {generic class}
end;

Procedure tVidSystem.rect(x1,y1,x2,y2:integer;color:byte);
begin
  {perform clipping}
  if (x1>width-1) or (y1>height-1) then exit; {if x1 or y1 off the screen, then the entire thing is off the screen!}
  if x2>width-1 then x2:=width-1;   {clip to right of screen}
  if y2>height-1 then y2:=height-1; {clip to bottom of screen}
  {draw rectangle}
  line(x1,y1,x2,y1,color); {top}
  line(x2,y1,x2,y2,color); {right}
  line(x1,y2,x2,y2,color); {bottom}
  line(x1,y1,x1,y2,color); {left}
end;

Procedure tVidSystem.box(x1,y1,x2,y2:integer;color:byte);
var
  loop:word;
begin
  {perform clipping}
  if (x1>width-1) or (y1>height-1) then exit; {if x1 or y1 off the screen, then the entire thing is off the screen!}
  if x2>width-1 then x2:=width-1;   {clip to right of screen}
  if y2>height-1 then y2:=height-1; {clip to bottom of screen}
  {draw filled box}
  for loop:=y1 to y2 do line(x1,loop,x2,loop,color);
end;

Procedure tVidSystem.WaitVertRetrace;
begin
  m6845_waitvertretrace;
end;

Procedure tVidSystem.WaitStartDisplayCycle;
begin
  m6845_WaitStartDisplayCycle;
end;

Procedure tVidSystem.setDrawPage(p:pagetype);
begin
  case p of
    hidden:begin {draw to the non-active page}
      if curpage=0 then DrawPage:=page1 else DrawPage:=page0;
    end;
    visible:begin {draw to the active page}
      if curpage=0 then DrawPage:=page0 else DrawPage:=page1;
    end;
  end;
end;

Procedure tVidSystem.pageflip;
begin
  {generic class}
  {swap currently displayed pages}
  curpage:=curpage xor 1;
  {swap active pages}
  if DrawPage=page0 then DrawPage:=page1 else DrawPage:=page0;
end;

Procedure tVidSystem.setcolor;
begin
  m6845_setcolor(color);
end;

Procedure TVidSystem.setpalette;
begin
end;

{---CGA graphics-based modes----}

Constructor TVidCGAG.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  hardwarePages:=false;
  SLW:=80; {ScanLineWidth, in bytes}
  bufSize:=16384; {total size of a screen (buffer), in bytes}
  mode46_loc:=DrawPage; {make sure active drawing buffer location is set}
end;

Destructor TVidCGAG.Done;
begin
  {mystuff}
  Inherited Done;
end;

Procedure TVidCGAG.setDrawPage;
begin
  Inherited setDrawPage(p); {set up generic/internal vars}
  mode46_loc:=drawpage; {make sure active drawing buffer location is set}
end;

Procedure TVidCGAG.PageFlip;
begin
  if not hardwarepages then begin
    if DrawPage<>page0                    {if active drawing page is offscreen,}
      then move(DrawPage^,page0^,bufsize) {move it to the screen}
      else drawpage:=page1;               {else set active drawing to offscreen}
  end else begin
    Inherited PageFlip;
  end;
  mode46_loc:=DrawPage; {make sure active drawing buffer location is set}
end;


Constructor TVidCGAGmode4.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm
    mov ax,0004
    int 10h
  end else begin
    mode4_set;
  end;
  Width:=320;
  Height:=200;
  MaxColors:=4;
  BitsPerPixel:=2;
  {$IFDEF FAKEHIDDEN}
  getmem(page1,bufSize); {pointers to screen buffers}
  {$ENDIF}
end;

Destructor TVidCGAGmode4.Done;
begin
  {mystuff}
  {$IFDEF FAKEHIDDEN}
  freemem(page1,bufsize);
  {$ENDIF}
  Inherited Done;
end;

Procedure TVidCGAGmode4.line(x1,y1,x2,y2:integer;color:byte);
begin
  mode4_line_direct(x1,y1,x2,y2,color);
end;

Procedure TVidCGAGmode4.setpixel(x,y:integer;color:byte);
begin
  mode4_setpixel_direct(x,y,color);
end;

Constructor TVidCGAGmode6.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm
    mov ax,0006
    int 10h
  end else begin
    mode6_set;
  end;
  Width:=640;
  Height:=200;
  MaxColors:=2;
  BitsPerPixel:=8;
  {$IFDEF FAKEHIDDEN}
  getmem(page1,bufSize); {pointers to screen buffers}
  {$ENDIF}
end;

Destructor TVidCGAGmode6.Done;
begin
  {mystuff}
  {$IFDEF FAKEHIDDEN}
  freemem(page1,bufsize);
  {$ENDIF}
  Inherited Done;
end;

Procedure TVidCGAGmode6.line(x1,y1,x2,y2:integer;color:byte);
begin
  mode6_line_direct(x1,y1,x2,y2,color);
end;

Procedure TVidCGAGmode6.setpixel(x,y:integer;color:byte);
begin
  mode6_setpixel_direct(x,y,color);
end;

Constructor TVidCGAGcomposite.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm
    mov ax,0006
    int 10h
  end;
  composite_set;
  Width:=160;
  Height:=200;
  MaxColors:=16;
  BitsPerPixel:=4;
  {$IFDEF FAKEHIDDEN}
  getmem(page1,bufSize); {pointers to screen buffers}
  {$ENDIF}
end;

Destructor TVidCGAGcomposite.Done;
begin
  {mystuff}
  {$IFDEF FAKEHIDDEN}
  freemem(page1,bufsize);
  {$ENDIF}
  Inherited Done;
end;

Procedure TVidCGAGcomposite.line(x1,y1,x2,y2:integer;color:byte);
begin
  composite_line_direct(x1,y1,x2,y2,color);
end;

Procedure TVidCGAGcomposite.setpixel(x,y:integer;color:byte);
begin
  composite_setpixel_direct(x,y,color);
end;

{---Tandy/PCjr graphics modes----}

Constructor TVidTANG.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  SLW:=80; {ScanLineWidth, in bytes}
  bufSize:=16384; {total size of a screen (buffer), in bytes}
end;

Destructor TVidTANG.Done;
begin
  {mystuff}
  Inherited Done;
end;

Procedure TVidTANG.setDrawPage;
{this is pretty messed up; see the pcjrsupport unit for a better way to do this}
begin
  Inherited setDrawPage(p); {set up generic/internal vars}
  mode46_loc:=DrawPage; {make sure active drawing location is set}
  {our video pages are 6 and 7 for numrampages=1; 4(+5) and 6(+7) for numrampage=2}
  {this code maps visible and hidden to the same location}
  if numrampages=1 {160x200x16 mode}
    then if p=visible
      then port[$3DF]:=64 OR (((6+curpage)         SHL 3)+(6+curpage))  {mapped and visible are the same}
      else port[$3DF]:=64 OR (((6+(curpage xor 1)) SHL 3)+(6+curpage))  {mapped and visible are opposite}
    else if p=visible {320x200x16 or 640x200x4}
      then port[$3DF]:=64 OR (((4+(curpage*2))         SHL 3)+(4+(curpage*2)))  {mapped and visible are the same}
      else port[$3DF]:=64 OR (((4+((curpage xor 1)*2)) SHL 3)+(4+(curpage*2))); {mapped and visible are opposite}
end;

Procedure TVidTANG.PageFlip;
begin
  Inherited PageFlip;
  mode46_loc:=DrawPage; {make sure active drawing location is set}
  {display the displayed page}
  {port[$3DF] := (mappedpage SHL 3)+displayedpage;}
  {our video pages are 6 and 7 (or 4 and 6 if using bigger video modes).
  Swap visible and mapped.}
  if numrampages=1 {160x200x16 mode}
    then port[$3DF]:=((6+(curpage xor 1)) SHL 3)+(6+curpage)  {mapped and visible are opposite}
    else port[$3DF]:=((4+((curpage xor 1)*2)) SHL 3)+(4+(curpage*2)); {mapped and visible are opposite}
end;

Procedure TVidTANG.setpalette(var palcols:ppaltype);
{this is crap and needs cleanup and optimization! for one thing, why
waiting for vert retrace all the time?  Also, compatible with PCjr?}
var
  foop:pointer;
  col,idx:word;
begin
  foop:=palcols;
  for idx:=0 to 15 do begin
    col:=palcols^[idx];
    asm
            MOV DI,16           {Port offset for palette registers}

  {  ;Entered here to set border registr}
            MOV DX,3DAH         {Address & status register}
            CLI
    @SetPalette2:
            IN  AL,DX
            AND AL,8
            JZ  @SetPalette2    {Wait for vertical retrace      }
            MOV AX,idx{BX}              {Get palette number           }
            ADD AX,DI           {ADD offset for palette or border   }
            OUT DX,AL           {Set palette                        }
            MOV AX,col{CX}              {Get color to store            }
            MOV DX,3DEH         {Palette data register              }
            OUT DX,AL           {Set palette color                  }
            MOV DX,3DAH         {Address & status register       }
            XOR AX,AX           {AL = 0 to reset address register }
            OUT DX,AL           {Reset it         }
            STI                 {Re-enable interrupts}
    end;
  end;
end;

Constructor tVidTANG160.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  hardwarepages:=true;
  NumRamPages:=1;
  asm
    mov ax,0008
    int 10h
  end;

  Width:=160;
  Height:=200;
  MaxColors:=16;
  BitsPerPixel:=4;
  page0:=ptr($b800,0000);
  page1:=page0; {pages are controlled through 3df mapping register}
  curpage:=0;
  DrawPage:=page0;
  numpages:=2;
end;

Destructor TVidTANG160.Done;
begin
  {mystuff}
  Inherited Done;
end;

Procedure TVidTANG160.line(x1,y1,x2,y2:integer;color:byte);
begin
  composite_line_direct(x1,y1,x2,y2,color);
end;

Procedure TVidTANG160.setpixel(x,y:integer;color:byte);
begin
  composite_setpixel_direct(x,y,color);
end;

{-----CGA text-based modes-----}

Constructor TVidCGAT.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  MaxColors:=256;
  BitsPerPixel:=8;
  charmask:='±';
end;

Destructor TVidCGAT.Done;
begin
  {mystuff}
  Inherited Done;
end;

Procedure TVidCGAT.line(x1,y1,x2,y2:integer;color:byte);
begin
  mtext_line_direct(x1,y1,x2,y2,color,SLW);
end;

Procedure TVidCGAT.setpixel(x,y:integer;color:byte);
begin
  mtext_setpixel_direct(x,y,color,SLW);
end;

{$IFDEF FASTCLEAR}
Procedure TVidCGAT.clear;
begin
  mtext_clrscr_direct(charmask,(color SHL 4)+color,bufsize); {ASCII 177}
end;
{$ENDIF}

Procedure TVidCGAT.pageflip;
begin
  if not hardwarepages then begin
    if DrawPage<>page0                    {if active drawing page is offscreen,}
      then move(DrawPage^,page0^,bufsize) {move it to the screen}
      else drawpage:=page1;               {else set active drawing to offscreen}
  end else begin
    m6845_SetDisplayAddress(word(drawpage) shr 1);
    Inherited PageFlip;
  end;
  mtext_loc:=DrawPage; {make sure active drawing buffer location is set}
end;

Procedure TVidCGAT.setDrawPage;
begin
  Inherited setDrawPage(p);
  mtext_loc:=DrawPage; {make sure active drawing segment is set}
end;

Constructor TVidCGAT40x25.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm mov ax,0001; int 10h; end;
  m40x25_set; width:=40; height:=25; hardwarepages:=true; SLW:=width*2; bufSize:=height*SLW;
  page1:=page0; inc(word(page1),bufsize); {adjust page1 pointer downward in video memory}
end;

Destructor TVidCGAT40x25.Done;
begin
  {mystuff, then:} Inherited Done;
end;

Constructor TVidCGAT80x25.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm mov ax,0003; int 10h; end;
  m80x25_set; width:=80; height:=25; hardwarepages:=true; SLW:=width*2; bufSize:=height*SLW;
  page1:=page0; inc(word(page1),bufsize); {adjust page1 pointer downward in video memory}
end;

Destructor TVidCGAT80x25.Done;
begin
  {mystuff, then:} Inherited Done;
end;

Constructor TVidCGAT40x50.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm mov ax,0001; int 10h; end;
  m40x50_set; width:=40; height:=50; hardwarepages:=true; SLW:=width*2; bufSize:=height*SLW;
  page1:=page0; inc(word(page1),bufsize); {adjust page1 pointer downward in video memory}
end;

Destructor TVidCGAT40x50.Done;
begin
  {mystuff, then:} Inherited Done;
end;

Constructor TVidCGAT80x50.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm mov ax,0003; int 10h; end;
  {$IFNDEF DEBUG} m80x50_set; {$ENDIF} width:=80; height:=50; hardwarepages:=true; SLW:=width*2; bufSize:=height*SLW;
  page1:=page0; inc(word(page1),bufsize); {adjust page1 pointer downward in video memory}
end;

Destructor TVidCGAT80x50.Done;
begin
  {mystuff, then:} Inherited Done;
end;

Constructor TVidCGAT40x100.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm mov ax,0001; int 10h; end;
  m40x100_set; width:=40; height:=100; hardwarepages:=true; SLW:=width*2; bufSize:=height*SLW;
  page1:=page0; inc(word(page1),bufsize); {adjust page1 pointer downward in video memory}
end;

Destructor TVidCGAT40x100.Done;
begin
  {mystuff, then:} Inherited Done;
end;

Constructor TVidCGAT80x100.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  if compatible then asm mov ax,0003; int 10h; end;
  m80x100_set; width:=80; height:=100; hardwarepages:=false; SLW:=width*2; bufSize:=height*SLW;
  {$IFDEF FAKEHIDDEN}
  getmem(page1,bufsize);
  {$ENDIF}
end;

Destructor TVidCGAT80x100.Done;
begin
  {$IFDEF FAKEHIDDEN}
  freemem(page1,bufsize);
  {$ENDIF}
  Inherited Done;
end;



{-----CGA classic 160x100 lowres text-based mode----}

Constructor TVidlowres.Init(mode:vidmodetype;compatible:boolean);
begin
  Inherited Init(mode,compatible);
  {mystuff follows}
  {$IFNDEF DEBUG}
  lowres_set;
  {$ENDIF}
  hardwarePages:=false;
  charmask:='Þ';
  lowres_clrscr_direct(charmask);
  width:=160;
  height:=100;
  MaxColors:=16;
  BitsPerPixel:=4;
  SLW:=16000 div height;
  hardwarepages:=false;
  bufSize:=SLW*height; {total size of a screen (buffer), in bytes}
  {$IFDEF FAKEHIDDEN}
  getmem(page1,bufsize);
  {$ENDIF}
end;

Destructor TVidlowres.Done;
begin
  {mystuff}
  {$IFDEF FAKEHIDDEN}
  freemem(page1,bufsize);
  {$ENDIF}
  Inherited Done;
end;

Procedure TVidlowres.clear;
begin
  lowres_clrscr_direct(charmask);
end;

Procedure TVidlowres.line(x1,y1,x2,y2:integer;color:byte);
begin
  lowres_line_direct(x1,y1,x2,y2,color);
end;

Procedure TVidlowres.setpixel(x,y:integer;color:byte);
begin
  lowres_setpixel_direct(x,y,color);
end;

function init_askmode;
var
  foo:vidmodetype;
  pvs:pVidSystem;
  loop:byte;
  c:char;
begin
  for loop:=0 to nummodes-1 do writeln(chr(byte(loop)+65),'. ',ModeDescriptions[vidmodetype(loop)]);
  c:=upcase(readkeychar);
  foo:=vidmodetype(ord(c)-65);
  case foo of
    text40x25 :pvs:=new(pvidCGAT40x25,    Init(foo,compatible_init));
    text80x25 :pvs:=new(pvidCGAT80x25,    Init(foo,compatible_init));
    text40x50 :pvs:=new(pvidCGAT40x50,    Init(foo,compatible_init));
    text80x50 :pvs:=new(pvidCGAT80x50,    Init(foo,compatible_init));
    text40x100:pvs:=new(pvidCGAT40x100,   Init(foo,compatible_init));
    text80x100:pvs:=new(pvidCGAT80x100,   Init(foo,compatible_init));
    lowres    :pvs:=new(pVidLowres,       Init(foo,compatible_init));
    mode4     :pvs:=new(pvidCGAGmode4,    Init(foo,compatible_init));
    mode6     :pvs:=new(pvidCGAGmode6,    Init(foo,compatible_init));
    composite :pvs:=new(pvidCGAGcomposite,Init(foo,compatible_init));
    tan160    :pvs:=new(pvidTANG160,      Init(foo,compatible_init));
    dummy     :pvs:=new(pvidSystem,       Init(foo,compatible_init));
  end; {case}
  init_askmode:=pvs;
end;

end.

