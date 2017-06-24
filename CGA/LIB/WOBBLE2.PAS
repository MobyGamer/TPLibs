(*
/* Original by Andrew Jenner: */
#define H_TOTAL_NORMAL 56
#define H_SYNC_NORMAL 45
#define V_DISPLAY_LINES 200

void wobble_frame(int* offsets)
{
  while (inportb(0x3da)&8); /* Wait for vertical retrace to end */
  for (int i=0;i<V_DISPLAY_LINES;++i) {
    while (inportb(0x3da)&1); /* Wait until we're drawing */
    outportb(0x3d4, 0); /* CRTC register 0 - horizontal total */
    outportb(0x3d5, H_TOTAL_NORMAL + offsets[i+1] - offsets[i]);
    outportb(0x3d4, 2); /* CRTC register 2 - horizontal sync */
    outportb(0x3d5, H_SYNC_NORMAL - offsets[i]);
    while (~inportb(0x3da)&1); /* Wait until overscan period */
  }
  while (~inportb(0x3da)&8); /* Wait for vertical retrace */
}
*)

uses
  pcxcga,
  m6845ctl,
  support;

const
  H_TOTAL_NORMAL=56;
  H_SYNC_NORMAL=45;
  V_DISPLAY_LINES=200;

var
  offsets:array[0..V_DISPLAY_LINES] of byte;
  b:byte;
  foo1,foo2:byte;

begin
  asm
    mov ax,0004h
    int 10h
  end;
  for b:=0 to 20 do writeln(b); (*something to see on the screen*)
{  read_pcx_file('\program\cga\lib\graphics\testpic1.pcx');}
  for b:=0 to V_DISPLAY_LINES do offsets[b]:=random(2);
  offsets[0]:=0; offsets[199]:=0; offsets[200]:=0;
  repeat
  inc(offsets[3]); if offsets[3]>3 then offsets[3]:=0;
  asm
    cli
    { Wait for vertical retrace}
    MOV DX,$3da
@wait_vsync:
    IN AL,DX
    TEST AL,8
    JZ @wait_vsync

    { Wait for vertical retrace to end}
@wait_no_vsync:
    IN AL,DX
    TEST AL,8
    JNZ @wait_no_vsync

    { Start of vertical loop}
    MOV SI,offset offsets
    MOV CX,200   { Number of displayed lines}
    LODSB
    MOV AH,AL      { Keep offsets[b] in AH}
@do_wobble:

    { Wait until we're drawing}
@wait_display:
    IN AL,DX
    TEST AL,1
    JNZ @wait_display

    { Update CRTC registers for this line}
    MOV AL,2     { CRTC R2 - horizontal sync position}
    SUB DX,6     { DX = 03d4}
    OUT DX,AL
    INC DX       { DX = 03d5}
    MOV AL,45    { "Normal" horizontal sync position}
    SUB AL,AH
    OUT DX,AL    { 45 - offsets[b]}

    MOV AL,0     { CRTC R0 - horizontal total characters}
    DEC DX       { DX = 03d4}
    OUT DX,AL
    LODSB
    XCHG AH,AL   { AL = offsets[b], AH = offsets[b+1]}
    NEG AL
    ADD AL,AH
    ADD AL,56    { "Normal" horizontal total characters}
    INC DX       { DX = 03d5}
    OUT DX,AL    { 56 + offsets[b+1] - offsets[b]}
    ADD DX,5     { DX = 03da}

    { Wait until overscan period}
@wait_overscan:
    IN AL,DX
    TEST AL,1
    JZ @wait_overscan

    { End of vertical loop}
    LOOP @do_wobble

    sti
  end;
  until keypressed;  readkeychar;
end.