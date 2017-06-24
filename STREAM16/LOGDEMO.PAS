{$B-}   { Use fast boolean evaluation. }

program logdemo;

{ Demonstrates use of TLogFilter }

{$i stdefine.inc}

uses
  {$ifdef windows}  wincrt,                    {$endif}
  {$ifdef wobjects} wobjects, {$else} objects, {$endif}
  streams;

var
  i : integer;
  inlog,log : PLogFilter;

begin
  { Log both input and output to Logdemo.out }

  new(log, init( new(PDOSStream, init('Logdemo.out',stCreate))));

  log^.log(input);
  log^.log(output);

  writeln('This is the Logdemo program, which logs input and output');
  writeln('to LOGDEMO.OUT');
  write('Enter an integer:');
  readln(i);
  writeln('Logging will now be turned off.');

  if not log^.unlog(input) then;   { This is one way to stop logging. }
  close(output);       { This is another way. }

  { Re-open output; input was never closed. }
  rewrite(output);

  writeln('This line will not be logged.');
  write('Enter another integer:');
  readln(i);
  writeln('Logging will be turned back on now.');

  log^.log(input);
  log^.log(output);

  writeln('This line will be logged to the file.');

  writeln('All done now; close the log.');

  dispose(log,done);

  writeln('The log has been closed, so this line won''t be logged.');
end.
