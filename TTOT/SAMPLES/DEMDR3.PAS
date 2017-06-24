program DemoDirectoryThree;
{demdr3 - a customized directory list}

Uses DOS, CRT,
     totFAST, totLINK, totLIST;

Var
   ListWin:  ListDirObj;
   FileInfo: tFileInfo;

begin
   Screen.Clear(white,'°'); {paint the screen}
   with ListWin do
   begin
      Init;
      SetTagging(false);
      (*ReadFiles('*.pas *.exe *.doc',AnyFile - directory); {exclude directories} *)
      ReadFiles('*.*',AnyFile - directory); {exclude directories}
      FileList^.Sort(1,true);               {sort in name order}
      Win^.SetTitle(' Choose a file ');
      Go;
      Win^.Remove;
      if (LastKey = 27) or (Lastkey = 600) then
         writeln('You escaped!')
      else
      begin
         writeln('You chose file '+GetHiString);
         writeln(FileList^.GetLongStr(FileList^.ActiveNodePtr));
         FileList^.GetFileRecord(FileInfo, FileList^.ActiveNodeNumber);
         with FileInfo do
         begin
            writeln('Name:           ', FileName);
            writeln('Attr:           ', Attr);
            writeln('Packed Time:    ', Time);
            writeln('Size:           ', Size);
            writeln('Directory entry:',LoadID);
         end;
      end;
      Done;
   end;
end.


