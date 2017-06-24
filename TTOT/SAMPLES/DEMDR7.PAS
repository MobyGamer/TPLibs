program DemoDirSeven;
{demdr7 - customizing directory help}

Uses DOS, CRT,
     totFAST, totDir, totIO1, totMSG;

Var
   DirWin: DirWinObj;
   Result: tAction;

{$F+}
procedure NewHelp(ID:word);
{}
var  HelpWin: MessageOBJ;
begin
   with HelpWin do
   begin
      Init(1,' Not Much Help ');
      AddLine('');
      Addline(' Honey, if you need help here, we got big problems! ');
      AddLine('');
      Show;
      Done;
   end;
end; {NewHelp}
{$F-}

begin
   Screen.Clear(white,'°'); {paint the screen}
   with DirWin do
   begin
      Init;
      Action^.SetHelpHook(NewHelp);
      Result := Go;
      if Result = Finished then
         writeln('You chose file: ',GetChosenFile)
      else
         writeln('You escaped!');
      Done;
   end;
end.

