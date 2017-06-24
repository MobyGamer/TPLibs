{$B-}   { Use fast boolean evaluation. }

program textdemo;

{ Demonstrates use of TTextFilter and TWorkStream }

{$i stdefine.inc}

uses
  {$ifdef windows}  wincrt,                     {$endif}
  {$ifdef wobjects} wobjects, {$else} objects,  {$endif}
  streams;

var
  i : integer;
  S : PWorkStream;
  T : PTextFilter;
  offsets : array[1..15000] of longint;
  line : string;
  startmem : longint;

  function MyTempStream(MinSize,MaxSize:Longint;
                      Preference:TStreamRanking):PStream; far;
  var
    result : PStream;
  begin
    Write('S is ',S^.GetSize:6,' bytes, Memavail=',memavail:6);
    result := TempStream(MinSize,MaxSize,Preference);
    Writeln(', allocated ',StreamName(result));
    MyTempStream := result;
  end;

begin
  TempEnvVar := 'TMP';
  startmem := Memavail;
  { Create a temporary file with blocks in EMS, XMS or on the heap: }
  S := New(PWorkStream, Init(TempStream,2048,65520,ForSpeed));
  S^.Allocate := MyTempStream;
  if (S=nil) or (S^.status <> stOK) then
  begin
    writeln('Failed to create temporary stream.');
    halt(99);
  end;

  { Insert it into a text filter }
  New(T, init(S, 'TempStream'));
  if (T=nil) or (T^.status <> stOK) then
  begin
    writeln('Failed to create text filter.');
    halt(98);
  end;

  { Now write 15000 lines to it. }
  Rewrite(T^.TextFile);
  for i:=1 to 15000 do
  begin
    offsets[i] := T^.GetPos;
    writeln(T^.TextFile, '------------- Line number ',i:5,' --------------');
  end;
  writeln('Have written 15000 lines (',T^.Getsize,' bytes) to work stream.');

  { Now read them back in a strange order. }
  Reset(T^.TextFile);
  writeln('The first line is ');
  Readln(T^.TextFile,line);
  writeln(line);
  for i:=5 downto 1 do
  begin
    writeln('Line ',i*100,' is:');
    T^.Seek(offsets[i*100]);
    readln(T^.TextFile,line);
    writeln(line);
  end;

  writeln('Lines 14995 onwards are:');
  T^.seek(offsets[14995]);
  while not eof(T^.Textfile) do
  begin
    readln(T^.TextFile,line);
    writeln(line);
  end;

  { All done; dispose of the filter to release the memory }
  dispose(T,done);

  if memavail <> startmem then
    writeln('Error!  ',startmem-memavail,' bytes of memory left allocated.');

  writeln('All done!');
end.

