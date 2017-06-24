program DemoDirSix;
{demdr6 - customizing the directory dialog box}

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
      SetFileDetails('','*.EXE *.COM *.BAT',AnyFile - Directory);
      SetSortDetails(2,true);
      Win^.SetColors(15,15,15,15);
      IOTOT^.SetColLabel(15,15,15,15);
      IOTOT^.SetColList(7,7,112,112);
      IOTOT^.SetColField(7,112,8,8);
      IOTOT^.SetColButton(112,127,127,127);
      Result := Go;
      if Result = Finished then
         writeln('You chose file: ',GetChosenFile)
      else
         writeln('You escaped!');
      Done;
   end;
end.

