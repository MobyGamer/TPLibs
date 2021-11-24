unit m6845ctl;

{
Update: 20210206 - added dumb hacky MDA support, should be made elegant later

Low-level routines to control the Motorola 6845.
Note that the support in this unit is intended for stock IBM CGA and MDA.
There are clones that have added additional features, such as the AT&T PC6300,
but those additional features are not supported here (yet).

Any mode you create must have 262 displayed lines to be compatible with
most capture devices.  If:

(vertical_total+1)*(maximum_scanline+1)+vertical_total_adjust != 262

...then your mode cannot be captured.  More notes for building your own
mode:

Vertical displayed is the number of character rows you want to have in your
active area, but it's not necessary that this be equal to exactly 200
scanlines (and indeed that's not possible for max scanline = 5). If you
want something close to full screen, calculate 200/(max scanline+1) and
pick the nearest integer (33 in this case). Or just make it 30 to get the
180 scanline screen.

Vertical sync position is the number of character rows between the start of
the active area and the start of sync. For a 200 scanline active area (or a
reduced viewport at the top of the physical screen) it should be the nearest
integer to 224/(max scanline+1). If it's smaller than vertical displayed or
larger than vertical total that could cause rolling.

For a centered reduced viewport, reduce vertical sync position appropriately:
Top: vertical_sync_position = 224/(max_scanline+1)
Bottom: vertical_sync_position = vertical_displayed + 24/(max_scanline+1)
Middle: vertical_sync_position = vertical_displayed/2 + 124/(max_scanline+1)
N% of the way down:
vertical_sync_position = vertical_displayed*N/100 + ((200-2*N)+24)/(max_scanline+1)

}

interface

const
  mode_table_vector=$1d;

  {registers}
  m6845_index:word=$3d4; {index register -- this is different on MDA but as this is a CGA-only lib I don't care :-)}
    m6845_horizontal_total=$00;
    m6845_horizontal_displayed=$01;
    m6845_horizontal_sync_position=$02;
    m6845_horizontal_sync_width=$03;
    m6845_vertical_total=$04;
    m6845_vertical_total_adjust=$05;
    m6845_vertical_displayed=$06;
    m6845_vertical_sync_position=$07;
    m6845_interlace_mode=$08;
    m6845_maximum_scanline=$09;
    m6845_cursor_start=$0a;
    m6845_cursor_end=$0b;
    m6845_start_address_high=$0c;
    m6845_start_address_low=$0d;
    m6845_cursor_location_high=$0e;
    m6845_cursor_location_low=$0f;
    m6845_lightpen_high=$10;
    m6845_lightpen_low=$11;
  m6845_data:word=$3d5; {data register}
  m6845_mode_ctl:word=$3d8; {mode control register}
    {relevant bits}
    c_fast_char_clock=1; {use 160 bytes per line instead of 80; REQUIRED for 80x25 mode, otherwise 40x25 mode}
    c_graphics_enable=2; {otherwise, text mode}
    c_blackandwhite_enable=4; {otherwise, color signal}
    c_videosignal_enable=8; {otherwise, NO VIDEO SIGNAL}
    c_640x200_enable=16; {otherwise, 320x200}
    c_blinking_text=32; {otherwise, all background colors enabled}
  m6845_color_sel=$3d9; {color select register}
    {relevant bits}
    c_black=0; {just in case it wasn't obvious}
    c_blue=1;
    c_green=2;
    c_red=4;
    c_bright=8;
    c_alternate_intensity=16; {alt. intens. colors in graphics mode.  specs say "backgr. color" in text mode?  huh?}
    c_paletteCMW=32; {otherwise, red/green/yellow palette}
  m6845_status:word=$3da;
    {relevant bits}
    c_display_enable=1; {if set, horizontal or vertical retrace is active and vidram can be accessed}
    c_lightpen_trigger=2; {if set, lightpen trigger has occurred}
    c_lightpen_switch=4; {if set, lightpen switch is off}
    c_vertical_sync=8; {if set, vertical retrace is active and vidram can be accessed for next 1.25 ms}
  m6845_clear_lightpen_strobe=$3db;
  m6845_set_lightpen_strobe=$3dc;

  {clocks and rates}
  m6845_cga_bandwidth=14318180; {dot rate is 14.318 MHz}
  (*
  m6845_cga_horizontal_rate=15750; {horizontal scan rate is 15.75 KHz}
  m6845_cga_vertical_rate=60; {60 Hz}
  m6845_cga_dots_per_line=m6845_cga_bandwidth div m6845_cga_horizontal_rate;
  m6845_cga_lines_per_frame=m6845_cga_horizontal_rate div m6845_cga_vertical_rate;
  *)

  {text colors -- ever wondered WHY they are what they are?
  Check the Handy-Dandy Chart(tm):}
  tBlack=0                                         ; {00}
  tBlue=                                     c_blue; {01}
  tGreen=                          c_green         ; {02}
  tCyan=                           c_green + c_blue; {03}
  tRed=                    c_red                   ; {04}
  tMagenta=                c_red +           c_blue; {05}
  tBrown=                  c_red + c_green         ; {06}
  tLightGray=              c_red + c_green + c_blue; {07}
  tDarkGray=    c_bright                           ; {08}
  tLightBlue=   c_bright                   + c_blue; {09}
  tLightGreen=  c_bright         + c_green         ; {10}
  tLightCyan=   c_bright         + c_green + c_blue; {11}
  tLightRed=    c_bright + c_red                   ; {12}
  tLightMagenta=c_bright + c_red           + c_blue; {13}
  tYellow=      c_bright + c_red + c_green         ; {14}
  tWhite=       c_bright + c_red + c_green + c_blue; {15}
  CGAColorLabels:array[0..15] of pchar=(
  'Black','Blue','Green','Cyan','Red','Magenta','Brown','Light Gray',
  'Dark Gray','Light Blue','Light Green','Light Cyan','Light Red','Light Magenta','Yellow','White'
  );

  {Want to see those colors sorted by luminance?  Sure thing:}
  RecY709sorted:array[0..15] of byte=(0,1,4,8,5,6,9,12,13,2,3,7,10,11,14,15);
  {sorted by luminance approximatly by composite color output level:}
  (*RecY709sortedComp:array[0..15] of byte=(0,4,2,8,1,6,$c,$a,5,3,9,$e,7,$d,$b,$f);*)

  {4 different composite luminance groups with blank between them}
  CompLumaGroups:array[0..17] of byte=(1,2,4,8, 0 , 3,5,6,9,10,12, 0 ,7,11,13,14, 0 ,15);
  {10-level subjective eyeball sort:}
  SubjectiveSort1:array[0..9] of byte=(0,1,8,9,2,3,7,10,11,15);

type
  triad=record
    r,g,b:byte;
  end;

const
  cgacolorpal:array[0..15] of triad=(
  (r:$00;g:$00;b:$00),
  (r:$00;g:$00;b:$aa),
  (r:$00;g:$aa;b:$00),
  (r:$00;g:$aa;b:$aa),
  (r:$aa;g:$00;b:$00),
  (r:$aa;g:$00;b:$aa),
  (r:$aa;g:$55;b:$00),
  (r:$aa;g:$aa;b:$aa),
  (r:$55;g:$55;b:$55),
  (r:$55;g:$55;b:$ff),
  (r:$55;g:$ff;b:$55),
  (r:$55;g:$ff;b:$ff),
  (r:$ff;g:$55;b:$55),
  (r:$ff;g:$55;b:$ff),
  (r:$ff;g:$ff;b:$55),
  (r:$ff;g:$ff;b:$ff)
  );


type
  pbyte=^byte;
  CRTCcontrolArray=array[0..15] of byte;
  pCRTCcontrolArray=^CRTCcontrolArray;
  CRTCmodeArray=array[0..7] of byte;
  Int1D_table=record
    modes:array[0..3] of CRTCcontrolArray;
    vidbuflength40:word;
    vidbuflength80:word;
    vidbuflengthgraph1:word;
    vidbuflengthgraph2:word;
    numcharcolumns:CRTCmodeArray;
    modecontrolbytes:CRTCmodeArray;
  end;
  pInt1D_table=^Int1D_table;
  m6845_moderegs=record
    horizontal_total:byte; {total characters per scanline MINUS ONE}
    horizontal_displayed:byte; {characters displayed in each scanline}
    horizontal_sync_position:byte; {Position in scanline where horizontal retrace starts}
    horizontal_sync_width:byte; {Duration of horizontal retrace interval (character clocks)}
    vertical_total:byte; {Total character rows in one frame}
    vertical_total_adjust:byte; {Remaining scanlines in one frame}
    vertical_displayed:byte; {Character rows displayed in each frame}
    vertical_sync_position:byte; {Position in frame where vertical retrace starts}
    interlace_mode:byte; {Enable/disable interlaced scanlines -- can't be used properly because of CGA's 16K memory limit}
    maximum_scanline:byte; {height of one character, in scanlines MINUS ONE}
  end;

var
  Int1D_mode_table:pInt1d_table;

  {absolute locations for the Video BIOS data areas -- BDA=BIOS Data Area
  These are SUPPOSED to be maintained by both the BIOS and user programs,
  but in practice this rarely happens.  CGALIB will attempt to keep these
  areas updated, but I'm not making any promises.  Also note that there
  are additional values in the BDA than those listed below, but I'm not
  covering them in CGALIB because they're for EGA and higher.}
  BDA_crt_mode:byte absolute $0040:$0049; {Current BIOS video mode}
  BDA_crt_cols:word absolute $0040:$004a; {Number of displayed character columns}
  BDA_crt_len:word absolute $0040:$004c; {Size of video buffer in bytes}
  BDA_crt_start:word absolute $0040:$004e; {Offset of start of video buffer}
  BDA_cursor_posn:array[0..7] of word absolute $0040:$0050; {Array of cursor positions for each of the eight video pages}
  BDA_cursor_mode:word absolute $0040:$0060; {Starting and ending scanlines of cursor}
  BDA_active_page:byte absolute $0040:$0062; {Currently displayed video page number}
  BDA_addr_6845:word absolute $0040:$0063; {I/O port address of m6845 (3b4h for mono, 3d4h for color).}
  BDA_crt_mode_set:byte absolute $0040:$0065; {Current value for mode control register}
  BDA_crt_palette:byte absolute $0040:$0066; {Current value for the color select register}

  {I do not use BDA_addr_6845 in my code because CGALIB only supports... wait for it... CGA!}

Procedure m6845_WaitVertRetrace;
{Waits until the very beginning of vertical retrace}

Procedure m6845_WaitStartDisplayCycle;
{Synchronize program execution with the start of the display cycle.
(Actual start is somewhere in the first 20% of the first scanline due to the
slow speed of a 4.77MHz 8088.)}

Procedure m6845_WaitEndCGADisplayCycle;
Procedure m6845_WaitEndPCjrDisplayCycle;
{Synchronize program execution with the end of the CGA display cycle
(200 lines).}

Procedure m6845_SetColor(c:byte);
{Text mode, sets border color.
In 320x200, sets background color.
In 640x200, sets foreground color (background always black).}

Procedure m6845_SetMode(modeflags:byte);
{sets video mode according to mode flags}

function m6845_GetModeTable:pointer;
{returns the location of the BIOS's built-in video mode table.  WARNING:
In my testing, the contents of the mode control byte array were invalid!
I could have missed something -- if so, please let me know -- until then,
set the mode control register yourself}

Procedure m6845_SetModeTable(index:byte);
{follows the mode table vector and sets video mode based on values found there.
valid index is 0 (40x25), 1 (80x25), or 2 (graphics mode).  Of course, I
recommend you use SetUserModeTable instead.}

Procedure m6845_SetUserModeTable(p:pbyte);
{Sets the CRTC mode registers based on a user-supplied table.
ONLY THE FIRST 10 REGISTERS ARE SET (because the rest have nothing
to do with core video mode progamming}

Procedure m6845_SetRegData(idx,dta:byte);
{Generic procedure to send data to any register.  For the lazy :-}

Procedure m6845_SetDisplayAddress(dispaddr:word);
{Set the start address of where the CRT starts reading memory from.
Address is a 14-bit offset starting from the beginning of CGA RAM.}

Procedure m6845_SetCursorLoc(dispaddr:word);
{Set the start address of where the CRT signals a blinking cursor.
address is a 14-bit offset starting from the beginning of CGA RAM.}

Procedure m6845_SetCursorSize(cursize:word);
{Set the start and stop scanlines of the hardware CRT cursor.
High byte is the start scanline and low byte is the stop.}

function CalcRecY709(t:triad):byte;
{Computes "brightness" as per NTSC phosphor calibration and characteristics
of the human visual system.}

implementation

Procedure m6845_WaitVertRetrace;assembler;
{Synchronize program execution with the START of the vertical retrace interval}
Asm
        mov   bl,c_vertical_sync
        mov   dx,m6845_status
@WDR: {wait during retrace, because we don't know where we are in the cycle}
        in    al,dx
        test  al,bl {if our bit is 1, then we're already in retrace, which means we missed it}
        jnz   @WDR  {jump if 1 (not 0) = keep looping as long as we're retracing}
@WDD: {wait for display to be over}
        in    al,dx
        test  al,bl
        jz    @WDD  {loop until we aren't drawing any more (ie. retracing)}
End;

Procedure m6845_WaitStartDisplayCycle;assembler;
{Synchronize program execution with the start of the display cycle}
Asm
  MOV   DX,m6845_status
  mov   bl,c_vertical_sync
  mov   bh,c_display_enable or c_vertical_sync
@WDR: {wait during retrace}
  in    AL,DX
  test  AL,bl
  jz    @WDR {loop while not in vertical retrace (ie. still drawing)}
@hor1:
  in    AL,DX
  test  AL,bh
  jnz   @hor1 {loop if in horizontal or vertical retrace}
End;

Procedure m6845_WaitEndCGADisplayCycle;assembler;
{Synchronize program execution with the end of the CGA display cycle}
Asm
  mov   dx,m6845_status
  mov   bl,c_vertical_sync
  mov   bh,c_display_enable or c_vertical_sync
  mov   ah,c_display_enable
  mov   cx,199
@WDR:
  in    al,dx
  test  al,bl
  jz    @WDR  {wait if not vertically retracing}
  {Now we are tracing back up the screen.  Wait until first scanline.}
  pushf
  cli   {timing individual scanlines must not be interrupted}
@hor1:
  in    al,dx
  test  al,bh
  jnz   @hor1 {wait until not horizontally or vertically retracing}
  {Now we are drawing our first scanline.}
@hor2:
  in    al,dx
  test  al,ah
  jz    @hor2 {wait until horizontally retracing}
  loop  @hor1 {loop 199 more times}
  popf  {restore previous interrupt state}
End;

Procedure m6845_WaitEndPCjrDisplayCycle;assembler;
{Synchronize program execution with the end of the CGA display cycle}
Asm
  mov   dx,m6845_status
  mov   bl,c_vertical_sync
  mov   bh,c_display_enable or c_vertical_sync
  mov   ah,c_display_enable
  mov   cx,128
@WDR:
  in    al,dx
  test  al,bl
  jz    @WDR  {wait if not vertically retracing}
  {Now we are tracing back up the screen.  Wait until first scanline.}
  pushf
  cli   {timing individual scanlines must not be interrupted}
@hor1:
  in    al,dx
  test  al,bh
  jnz   @hor1 {wait until not horizontally or vertically retracing}
  {Now we are drawing our first scanline.}
@hor2:
  in    al,dx
  test  al,ah
  jz    @hor2 {wait until horizontally retracing}
  loop  @hor1 {loop 199 more times}
  popf  {restore previous interrupt state}
End;


procedure m6845_SetColor(c:byte);assembler;
asm
  mov dx,m6845_color_sel
  mov al,c
  out dx,al
end;

Procedure m6845_SetMode(modeflags:byte);assembler;
asm
  mov dx,m6845_mode_ctl
  mov al,modeflags
  out dx,al
end;

function m6845_GetModeTable:pointer;assembler;
asm
  mov ah,35h
  mov al,mode_table_vector
  int 21h {es:bx points to table}
  mov dx,es
  mov ax,bx
end;

Procedure m6845_SetModeTable(index:byte);
var
  foo:byte;
begin
  for foo:=0 to 9 do begin
    port[m6845_index]:=foo;
    port[m6845_data]:=Int1D_Mode_Table^.modes[index][foo];
  end;
  port[m6845_mode_ctl]:=Int1D_Mode_Table^.modecontrolbytes[index];
end;

Procedure m6845_SetUserModeTable;
var
  foo:byte;
begin
  for foo:=0 to 9 do begin
    port[m6845_index]:=foo;
    port[m6845_data]:=p^;
    inc(longint(p));
  end;
end;

Procedure m6845_SetRegData; assembler;
asm
  mov dx,m6845_index
  mov al,idx
  out dx,al
  mov dx,m6845_data
  mov al,dta
  out dx,al
end;

Procedure m6845_SetDisplayAddress(dispaddr:word);assembler;
{Set the start address of where the CRT starts reading memory from.
address is a 14-bit offset starting from the beginning of CGA RAM.}
asm
  mov bx,dispaddr
  and bh,00111111b {not sure what happens if we overflow, so let's not, m'kay?}

  mov dx,m6845_index
  mov al,m6845_start_address_high
  out dx,al
  mov dx,m6845_data
  mov al,bh
  out dx,al

  mov dx,m6845_index
  mov al,m6845_start_address_low
  out dx,al
  mov dx,m6845_data
  mov al,bl
  out dx,al
end;

Procedure m6845_SetCursorLoc(dispaddr:word);assembler;
{Set the start address of where the CRT signals a blinking cursor.
address is a 14-bit offset starting from the beginning of CGA RAM.}
asm
  mov bx,dispaddr
  and bh,00111111b {not sure what happens if we overflow, so let's not, m'kay?}

  mov dx,m6845_index
  mov al,m6845_cursor_location_high
  out dx,al
  mov dx,m6845_data
  mov al,bh
  out dx,al

  mov dx,m6845_index
  mov al,m6845_cursor_location_low
  out dx,al
  mov dx,m6845_data
  mov al,bl
  out dx,al
end;

Procedure m6845_SetCursorSize(cursize:word);assembler;
{Set the start and stop scanlines of the hardware CRT cursor.
High byte is the start scanline and low byte is the stop.}
asm
  mov bx,cursize
  and bx,0001111100011111b {cursor start/stop is 5-bit number; let's enforce that}
  mov ax,0040h
  mov es,ax
  mov di,0060h
  mov es:[di],bx {update the BIOS data area}

  mov dx,m6845_index
  mov al,m6845_cursor_start
  out dx,al
  mov dx,m6845_data
  mov al,bh
  out dx,al

  mov dx,m6845_index
  mov al,m6845_cursor_end
  out dx,al
  mov dx,m6845_data
  mov al,bl
  out dx,al
end;

function CalcRecY709(t:triad):byte;
{Computes "brightness" as per NTSC phosphor calibration and characteristics
of the human visual system.  Not relevant for modern monitors, but good
enough for our purposes}
var
  r:real;
begin
  r:=(t.r*0.2125)+(t.g*0.7154)+(t.b*0.0721);
  CalcRecY709:=trunc(r);
end;

begin
  {$IFDEF STARTUP_MSGS} Writeln('m6845 unit starting...'); {$ENDIF}
  {find the BIOS-provided video mode table and point our struc to it}
  Int1D_mode_table:=m6845_GetModeTable;
  {Adjust for MDA if feasible}
  if Mem[$0000:$0449]=7 then begin
    dec(m6845_index,$20);
    dec(m6845_data,$20);
    dec(m6845_mode_ctl,$20);
    dec(m6845_status,$20);
  end;
end.
