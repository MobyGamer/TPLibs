unit m320_640;
{
Part of CGALIB.  Containes primitives for mode 4 and mode 6 CGA.
}

interface

const
  mode46_loc:pointer=ptr($b800,0000);

Procedure mode4_set;
Procedure mode4_setpixel_direct(x,y:word;color:byte);
Procedure mode4_line_direct(x1,y1,x2,y2:integer;color:byte);

Procedure mode6_set;
Procedure mode6_setpixel_direct(x,y:word;color:byte);
Procedure mode6_line_direct(x1,y1,x2,y2:integer;color:byte);

Procedure mode46_clrscr_direct(vidseg:word);

implementation

uses
  cgalib_g,
  m6845ctl;

{$I trix_cga.inc}

procedure ModeSetPreamble;
{sets the CRTC mode registers for 320x200/640x200 memory organization and display}
const
  index=2;
  modetable_size=sizeof(CRTCControlArray);
  NumValsToSet=10; {we're only interested in the first 10; don't care about cursor location, etc}
begin
  asm
    push ds
    lds si,int1d_mode_table
    add si,index*modetable_size {jump forward to the data we're looking for}
    mov dx,m6845_index
    xor ax,ax {ah is going to be our index/counter}
@loadandset:
    mov al,ah {move index to al}
    out dx,al {tell 6845 we want index AH}
    lodsb {grab the data value}
    inc dx {move port up to the data register}
    out dx,al {send it}
    dec dx {move back down to the index register}
    inc ah {increase our index}
    cmp ah,NumValsToSet {are we done?}
    jne @loadandset {if not, keep going}
    pop ds {done with the array}
  end;
end;

Procedure mode4_set;
begin
  ModeSetPreamble;
  asm
    mov dx,m6845_mode_ctl
    mov al,c_videosignal_enable+c_graphics_enable
    out dx,al
  end;
  BDA_crt_mode:=4;
end;

Procedure mode6_set;
begin
  ModeSetPreamble;
  asm
    mov dx,m6845_mode_ctl
    mov al,c_videosignal_enable+c_graphics_enable+c_640x200_enable+c_blackandwhite_enable
    out dx,al
  end;
  m6845_setcolor(15);
  BDA_crt_mode:=6;
end;

Procedure mode46_clrscr_direct;assembler;
asm
  mov  ax,$b800
  mov  es,ax
  xor  ax,ax
  xor  di,di
  mov  cx,$2000 { $4000 shr 1 }
  cld
  rep  stosw
end;

end.
