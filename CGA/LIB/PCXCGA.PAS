unit PCXcga;
{Support for loading CGA PCX files, like those exported from DPaint
or ZSoft products.  Currently takes a filename as an argument, but
should probably be converted into a buffer-to-buffer procedure at
some point.  Is somewhat reliant on 320x200 interlaced CGA as the
target.}

INTERFACE

var
  pcxfilename: string;
  file_error: boolean;
  page_addr: word;
  bytes_per_line: word;
  buff0, buff1: pointer;

  { CGA display memory banks: }
  screenbuff0: array[0..7999] of byte absolute $b800:$0000;
  screenbuff1: array[0..7999] of byte absolute $b800:$2000;

procedure READ_PCX_FILE(pfilename: string);

{========================================================================}

IMPLEMENTATION

var     scratch, abuff0, abuff1: pointer;
        repeatcount: byte;
        datalength: word;
        columncount, plane, video_index: word;

const   buffsize = 65521;   { Largest possible }

procedure DECODE_CGA; assembler;

asm

push    bp
jmp     @startproc

{ ------------- Procedure to store CGA image in buffers ----------------- }

@storebyte:
stosb                       { AL into ES:DI, increment DI }
inc     dx                  { increment column count }
cmp     dl, ah              { reached end of line? }
je      @row_ends           { yes }
loop    @storebyte          { not end of row, do another byte }
ret
@row_ends:
xor     bp, 1               { switch banks }
cmp     bp, 1               { is bank 1? }
je      @bank1              { yes }
mov     word ptr abuff1, di { no, save index into bank 1 }
les     di, abuff0          { bank 0 pointer into ES:DI }
xor     dx, dx              { reset column counter }
loop    @storebyte
ret
@bank1:
mov     word ptr abuff0, di { save index into bank 0 }
les     di, abuff1          { bank 1 pointer into ES:DI }
xor     dx, dx              { reset column counter }
loop    @storebyte
ret

{ ---------------- Main assembler procedure for CGA --------------------- }

@startproc:
mov     bp, 0                        { bank in BP }
mov     es, word ptr abuff0[2]       { segment of bank 0 buffer }
mov     di, word ptr abuff0          { offset of buffer }
mov     ah, byte ptr bytes_per_line  { line length in AH }
mov     bx, datalength               { no. of bytes to read }
xor     cx, cx                       { clean up CX for loop counter }
xor     dx, dx                       { initialize column counter }
mov     si, dx                       { initialize input index }
cld                                  { clear DF for stosb }

{ -------------------- Loop through input buffer ------------------------ }

@getbyte:
cmp     si, bx              { end of input buffer? }
je      @exit               { yes, quit }
push    es                  { save output pointer }
push    di
les     di, scratch         { get input pointer in ES:DI }
add     di, si              { add current offset }
mov     al, [es:di]         { get a byte }
inc     si                  { advance input index }
pop     di                  { restore output pointer }
pop     es
cmp     cl, 0               { was previous byte a count? }
jg      @multi_data         { yes, this is data }
cmp     al, 192             { no, test high bits }
jb      @one_data           { not set, not a count }
 { It's a count byte: }
xor     al, 192             { get count from 6 low bits }
mov     cl, al              { store repeat count }
jmp     @getbyte            { go get data byte }
@one_data:
mov     cl, 1               { write byte once }
call    @storebyte
jmp     @getbyte
@multi_data:
call    @storebyte          { CL already set }
jmp     @getbyte

{ ---------------------- Finished with buffer --------------------------- }

@exit:
pop     bp
end;  { asm }

procedure READ_PCX_FILE(pfilename: string);

type    ptrrec = record
                   segm, offs: word;
                 end;

var     entry, gun, pcxcode, mask, colorID: byte;
        palbuf: array[0..66] of byte;
        pcxfile: file;

begin   { READ_PCX_FILE }
  assign(pcxfile, pfilename);
  {$I-} reset(pcxfile, 1);  {$I+}
  file_error:= (IOresult <> 0);
  if file_error then exit;

  getmem(scratch, buffsize);                 { Allocate scratchpad }
  blockread(pcxfile, scratch^, 128);         { Get header into scratchpad }

  move(scratch^, palbuf, 67);
  bytes_per_line:= palbuf[66];

  {------------------------ Setup for CGA ---------------------------------}

  getmem(buff0, 8000);      { Allocate memory for output }
  getmem(buff1, 8000);
  abuff0:= buff0;           { Make copies of pointers }
  abuff1:= buff1;

{ ---------------- Read and decode the image data ----------------------- }

  repeatcount:= 0;                        { Initialize assembler vars. }
  columncount:= 0;
  repeat
    blockread(pcxfile, scratch^, buffsize, datalength);
    decode_CGA;   { Call assembler routine }
  until eof(pcxfile);
  move(buff0^,screenbuff0,sizeof(screenbuff0));
  move(buff1^,screenbuff1,sizeof(screenbuff1));
  close(pcxfile);
  freemem(scratch,buffsize);              { Discard scratchpad }
  end;  { READ_PCX_FILE }

END.