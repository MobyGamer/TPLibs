program DemoDirFive;
{demdr5 - the directory dialog box}

Uses DOS, CRT,
     totFAST, totDir, totIO1;

Var
   DirWin: DirWinObj;
   Result: tAction;
begin
   Screen.Clear(white,'°'); {paint the screen}
   with DirWin do
   begin
      Init;
      Result := Go;
      if Result = Finished then
         writeln('You chose file: ',GetChosenFile)
      else
         writeln('You escaped!');
      Done;
   end;
end.

