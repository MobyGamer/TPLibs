program DemoMenuTwo;
{DEMMN2 - a customized menu}

USES  DOS, CRT,
      totMENU, totFAST, totLOOK, totSYS;

var
  Main: MoveMenuOBJ;
  Choice: byte;
begin
   Screen.PartClear(1,1,80,24,white,'°'); {paint the screen}
   Screen.PartClear(1,24,80,25,30,' ');
   with Main do
   begin
      Init;
      AddItem('');
      AddFullItem(' ~1~   Load a file          ',1,49,'Loads a new database file',nil);
      AddFullItem(' ~2~   Edit Date            ',2,50,'Full screen editing of data base entries',nil);
      AddFullItem(' ~3~   Save the file        ',3,51,'Save database file to disk',nil);
      AddFullItem(' ~4~   Change configuration ',4,52,'Modify colors and defaults',nil);
      AddItem('');
      AddFullItem(' ~Q~   Quit                 ',99,81,'Exit system and return to DOS',nil);
      SetStyleTitle(6,'Main Menu');
      SetActiveItem(2);
      SetMessageXY(25,25);
      SetGap(1);
      Win^.SetClose(False);
      Win^.SetColors(75,79,79,75);
      SetColors(31,30,79,78,72);
      Choice := Activate;
      Done;
   end;
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice);
end.