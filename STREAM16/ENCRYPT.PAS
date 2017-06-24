{$B-}   { Use fast boolean evaluation. }

program Encrypt;

{ Program to demonstrate use of TEncryptFilter }

{$i StDefine.inc}

uses
  {$ifdef wobjects} wobjects, {$else} objects,  {$endif}
  {$ifdef windows}  wincrt,   {$endif}
  streams;

procedure SyntaxExit(s:string);
begin
  writeln;
  writeln(s);
  writeln;
  writeln('Usage:  ENCRYPT Sourcefile Destfile');
  writeln(' will encrypt sourcefile using key $12345678.');
  writeln(' Run ENCRYPT on the encrypted file to decrypt it.');
  halt(99);
end;

var
  Source : PBufStream;
  Dest   : PEncryptFilter;
  filename : string;
begin
  if paramcount <> 2 then
    SyntaxExit('Two parameters required.');

  { Open the source file with a buffer size of 2048. }

  {$ifdef windows}
  Filename := Paramstr(1);
  Filename[length(filename)+1] := #0;
  New(Source, Init( @filename[1], stOpenRead, 2048) );
  {$else}
  New(Source, Init( Paramstr(1), stOpenRead, 2048) );
  {$endif windows}

  if (Source = nil) or (Source^.status <> stOk) then
    SyntaxExit('Unable to open file '+ParamStr(1)+' for reading.');

  { Open the destination file with a buffer size of 2048, and insert it
    into the encrypting filter. }

  {$ifdef windows}
  Filename := Paramstr(2);
  Filename[length(filename)+1] := #0;
  New(Dest,   Init($12345678, New(PBufStream,
                                  Init( @filename[1], stCreate, 2048))));
  {$else}                                             
  New(Dest,   Init($12345678, New(PBufStream,
                                  Init( Paramstr(2), stCreate, 2048))));
  {$endif windows}
  if (Dest = nil) or (Dest^.status <> stOk) then
    SyntaxExit('Unable to create file '+Paramstr(2)+'.');

  { Encrypt the source file by copying it to the filter.}

  Write('Encrypting ',Paramstr(1),' to ',Paramstr(2),'...');
  FastCopy(Source^, Dest^, Source^.GetSize);
  if Dest^.status <> stOK then
    SyntaxExit('File error during encryption.');

  { Dispose of stream variables to close the files.}

  Dispose(Source, done);
  Dispose(Dest, done);

  Writeln('Done.');
end.
