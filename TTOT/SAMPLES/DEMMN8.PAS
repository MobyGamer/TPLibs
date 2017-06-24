program DemoMenuEight;
{DEMMN8 - reading a menu from disk}
USES  DOS, CRT,
      totMENU, totFAST, totLINK;

var
  Menu: EZPullLinkOBJ;
  Choice: word;

procedure CreateMenu;
{}
var
  FileList: StrDLLOBJ;
  Retcode: integer;
  F: text;
  Line:string;
begin
   assign(F,'DEMMN8.TXT');
   {$I-}
   reset(F);
   {$I+}
   if ioresult <> 0 then
   begin
      Writeln('Error: the file DEMMN8.TXT must be in the default directory!');
      halt(1);
   end;
   with FileList do
   begin
      Init;
      Retcode := 0;
      ReadLn(F,Line);
      while not eof(F) and (Retcode = 0) do
      begin
         Readln(F,Line);
         Retcode := Add(Line);
      end;
      close(F);
   end;
   with Menu do
   begin
      Init;
      AssignList(FileList);
      FileList.Done;
   end;
end; {CreateMenu}

begin
   Screen.PartClear(1,2,80,24,white,'°'); {paint the screen}
   Screen.PartClear(1,1,80,1,31,' ');
   Screen.PartClear(1,25,80,25,31,' ');
   Screen.WritePlain(9,25,'³');
   CreateMenu;
   with Menu do
   begin
      Choice := Push(13,0,0);   {Pass Enter to make menu pull down}
      Done;
   end;
   GotoXY(25,15);
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice);
end.     