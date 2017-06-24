program DemoDirectoryTwo;
{demdr2 - determining chosen files}

Uses DOS, CRT,
     totFAST, totLIST;

Var
   ListWin:  ListDirObj;
   Tot,L:longint;

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
      begin
         writeln('The highlighted file was '+GetHiString);
         writeln('The tagged files were: ');
         Tot := FileList^.TotalNodes;
         for L := 1 to Tot do
             if GetStatus(L,0) then
                writeln(GetString(L,0,0));
      end;
      Done;
   end;
end.


