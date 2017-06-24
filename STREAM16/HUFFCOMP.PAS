{$B-}   { Use fast boolean evaluation. }

Program HuffComp;

{ Simple compression program using Huffman compression.  Much like
  COMPRESS.PAS. }

{$i StDefine.inc}

uses
  {$ifdef wobjects}  wobjects, {$else}  objects, {$endif}
  {$ifdef windows}   wincrt,                     {$endif}
  streams, huffman;

procedure SyntaxExit(s:string);
begin
  writeln;
  writeln(s);
  writeln;
  writeln('Usage:  HUFFMAN Sourcefile Destfile [/X]');
  writeln(' will compress the source file to the destination');
  writeln(' file, or if /X flag is used, will expand source to destination.');
  halt(99);
end;

var
  Source : PStream;   { We don't know in advance which will be compressed }
  Dest   : PStream;
  Fullsize:longint;
  Filename : string;

begin
  Case ParamCount of
    2 : begin
          {$ifdef windows}
          Filename := Paramstr(1);
          Filename[length(filename)+1] := #0;
          Source := New(PBufStream, init(@filename[1], stOpenRead, 2048));
          Filename := Paramstr(2);
          Filename[length(filename)+1] := #0;
          Dest   := New(PHuffmanFilter, init(New(PBufStream,
                                             init(@filename[1],
                                                  stCreate, 2048))));
          {$else}                                                    
          Source := New(PBufStream, init(Paramstr(1), stOpenRead, 2048));

          Dest   := New(PHuffmanFilter, init(New(PBufStream,
                                             init(Paramstr(2),
                                                  stCreate, 2048))));
          {$endif windows}
          Write('Compressing ',Paramstr(1),' (',Source^.GetSize,
                ' bytes) to ',Paramstr(2));

          { Count characters in source. }
          FullSize := Source^.GetSize;
          Dest^.Write(FullSize,sizeof(FullSize));
          FastCopy(Source^,Dest^,Source^.GetSize);
          Source^.Seek(0);
          With PHuffmanFilter(Dest)^ do
          begin
            Seek(0);
            BuildCode;
            StoreCode;
            Learning := false;
            Write(Fullsize,sizeof(Fullsize));
          end;
        end;
    3 : begin
          if (Paramstr(3) <> '/X') and (Paramstr(3) <> '/x') then
            SyntaxExit('Unrecognized option '+Paramstr(3));
          {$ifdef windows}
          Filename := Paramstr(1);
          Filename[length(filename)+1] := #0;
          Source := New(PHuffmanFilter, init(New(PBufStream,
                                             init(@filename[1],
                                                  stOpenRead, 2048))));
          Filename := Paramstr(2);
          Filename[length(filename)+1] := #0;
          Dest   := New(PBufStream, init(@filename[1], stCreate, 2048));
          {$else}
          Source := New(PHuffmanFilter, init(New(PBufStream,
                                             init(Paramstr(1),
                                                  stOpenRead, 2048))));
          Dest   := New(PBufStream, init(Paramstr(2), stCreate, 2048));
          {$endif}
          Write('Expanding ',Paramstr(1),' (',
                PHuffmanFilter(Source)^.Base^.GetSize,' bytes) to ',
                Paramstr(2));
          with PHuffmanFilter(Source)^ do
          begin
            LoadCode;
            Learning := false;
            Read(Fullsize,Sizeof(Fullsize));
          end;
        end;
    else
      SyntaxExit('Two or three parameters required.');
  end;

  if (Source = nil) or (Source^.status <> stOk) then
    SyntaxExit('Unable to open file '+ParamStr(1)+' for reading.');

  if (Dest = nil) or (Dest^.status <> stOk) then
    SyntaxExit('Unable to create file '+Paramstr(2)+'.');

  FastCopy(Source^, Dest^, FullSize);
  if Dest^.status <> stOK then
    SyntaxExit('File error during compression/expansion.');

  Case ParamCount of
    2 : begin
          Dest^.Flush;
          Writeln(' (',PHuffmanFilter(Dest)^.Base^.GetSize,' bytes).');
        end;
    3 : Writeln(' (',FullSize,' bytes).');
  end;

  Dispose(Source, done);
  Dispose(Dest, done);
end.

end.
