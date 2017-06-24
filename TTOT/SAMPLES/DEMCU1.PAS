program DemoCursorOne;

uses DOS,CRT,
     totSYS, totFAST;

var
  Ch : char;
  Temp: byte;

procedure msg;
{}
begin
   writeln('Character height: ',Screen.CharHeight);
   writeln('Press N-on O-off F-full H-half C-condensed S-25 lines Esc-quit');
end; {Msg}

begin
   Msg;
   repeat
      Ch := ReadKey;
      case upcase(Ch) of
      'N': Screen.CursOn;
      'O': Screen.CursOff;
      'F': Screen.CursFull;
      'H': Screen.CursHalf;
      'C': begin
               Monitor^.SetCondensed;
               Msg;
           end;
      'S': begin 
               Monitor^.Set25;
               Clrscr;
               Msg;
           end;
      end; {case}
   until Ch = #027;
   Screen.CursOn;
   Monitor^.Set25;
end.


