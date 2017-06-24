program DemoDirectoryOne;
{demdr1 - the default directory list}

Uses DOS, CRT,
     totFAST, totLIST;

Var
   ListWin:  ListDirObj;

begin
   Screen.Clear(white,'°'); {paint the screen}
   with ListWin do
   begin
      Init;
      ReadFiles('*.*',AnyFile);
      Go;
      Win^.Remove;
      if (LastKey = 27) or (Lastkey = 600) then
         writeln('You escaped!')
      else
         writeln('You chose file '+GetHiString);
      Done;
   end;
end.


