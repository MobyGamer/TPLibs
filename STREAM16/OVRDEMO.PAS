{$B-}   { Use fast boolean evaluation. }

program ovrdemo;

{ Program to demonstrate use of two overlay files. }

{$i stdefine.inc}

{$ifndef overlays}
   This program only works in modes that support overlays.
{$endif}

uses
  overlay,objects,streams,
  ovr1,ovr2;

{$O ovr1}
{$O ovr2}

type
  PMessageStream = ^TMessageStream;
  TMessageStream = object(TNamedBufStream)
    { This stream prints its name every time anything is read from it. }

    procedure read(var buf; size:word); virtual;
  end;

procedure TMessageStream.Read;
begin
  writeln('Reading from ',filename^);
  TNamedBufStream.Read(buf,size);
end;

var
  stream1, stream2 : PMessageStream;
begin
  ovrinit('ovrdemo.ovr');

  writeln('The overlay streams aren''t being used yet.');

  proc1;
  proc2;

  writeln('Now loading overlays to the two streams.');

  ovrclearbuf;    { Make sure no overlay is loaded. }

  new(stream1, init('ovrdemo.1',stCreate,2048));
  ovrinitstream(stream1);

  proc1;          { This loads proc1 to Stream1, but doesn't trigger a read
                    yet. }

  new(stream2, init('ovrdemo.2',stCreate,2048));
  ovrinitstream(stream2);

  proc2;          { This loads proc2 to Stream2, but again, no read. }

  writeln('Now each unit is on a different stream; let''s call them a few ');
  writeln('times.');

  proc1;
  proc2;
  proc1;
  proc2;

  writeln('Now the overlay streams will be disposed of.');

  OvrDisposeStreams;

  writeln('These calls will use the old overlay mechanism.');
  proc1;
  proc2;
end.

