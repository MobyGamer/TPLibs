{$B-}   { Use fast boolean evaluation. }

program Compress;

{ Program to demonstrate use of TLZWFilter }

{$i stdefine.inc}

uses
  {$ifdef windows}  wincrt,                    {$endif}
  {$ifdef wobjects} wobjects, {$else} objects, {$endif}
  streams;

procedure SyntaxExit(s:string);
begin
  writeln;
  writeln(s);
  writeln;
  writeln('Usage:  COMPRESS Sourcefile Destfile [/X]');
  writeln(' will compress the source file to the destination');
  writeln(' file, or if /X flag is used, will expand source to destination.');
  halt(99);
end;

var
  Source : PStream;   { We don't know in advance which will be compressed }
  Dest   : PStream;
  filename : string;
begin
  Case ParamCount of                          
    2 : begin
          {$ifdef windows}
          Filename := Paramstr(1);
          Filename[length(filename)+1] := #0;
          Source := New(PBufStream, init(@filename[1], stOpenRead, 2048));
          Filename := Paramstr(2);
          Filename[length(filename)+1] := #0;
          Dest   := New(PLZWFilter, init(New(PBufStream,
                                             init(@filename[1],
                                                  stCreate, 2048)),
                                         stOpenWrite));
          {$else}                                                    
          Source := New(PBufStream, init(Paramstr(1), stOpenRead, 2048));

          Dest   := New(PLZWFilter, init(New(PBufStream,
                                             init(Paramstr(2),
                                                  stCreate, 2048)),
                                         stOpenWrite));
          {$endif windows}
          Write('Compressing ',Paramstr(1),' (',Source^.GetSize,
                ' bytes) to ',Paramstr(2));
        end;
    3 : begin
          if (Paramstr(3) <> '/X') and (Paramstr(3) <> '/x') then
            SyntaxExit('Unrecognized option '+Paramstr(3));
          {$ifdef windows}
          Filename := Paramstr(2);
          Filename[length(filename)+1] := #0;
         Source := New(PLZWFilter, init(New(PBufStream,
                                             init(@filename[1],
                                                  stOpenRead, 2048)),
                                         stOpenRead));
          Filename := Paramstr(2);
          Filename[length(filename)+1] := #0;
          Dest   := New(PBufStream, init(@filename[1], stCreate, 2048));
          {$else}
          Source := New(PLZWFilter, init(New(PBufStream,
                                             init(Paramstr(1),
                                                  stOpenRead, 2048)),
                                         stOpenRead));
          Dest   := New(PBufStream, init(Paramstr(2), stCreate, 2048));
          {$endif windows}
          Write('Expanding ',Paramstr(1),' (',
                PLZWFilter(Source)^.Base^.GetSize,' bytes) to ',
                Paramstr(2));
        end;
    else
      SyntaxExit('Two or three parameters required.');
  end;

  if (Source = nil) or (Source^.status <> stOk) then
    SyntaxExit('Unable to open file '+ParamStr(1)+' for reading.');

  if (Dest = nil) or (Dest^.status <> stOk) then
    SyntaxExit('Unable to create file '+Paramstr(2)+'.');

  FastCopy(Source^,Dest^, Source^.GetSize);
  if Dest^.status <> stOK then
    SyntaxExit('File error during compression/expansion.');

  Case ParamCount of
    2 : begin
          Dest^.Flush;
          Writeln(' (',PLZWFilter(Dest)^.Base^.GetSize,' bytes).');
        end;
    3 : Writeln(' (',Dest^.GetSize,' bytes).');
  end;

  Dispose(Source, done);
  Dispose(Dest, done);
end.
