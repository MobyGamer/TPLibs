program DemoMenuThree;
{DEMMN3 - nested pop-up menus}

USES  DOS, CRT,
      totMENU, totFAST, totLOOK, totSYS;

var
  Main,
  Load: MenuOBJ;

  Choice: byte;
begin
   Screen.PartClear(1,1,80,24,white,'°'); {paint the screen}
   Screen.PartClear(1,24,80,25,30,' ');
   with Load do
   begin
      Init;
      AddItem('');
      AddFullItem(' ~1~  Accounts Payable    ',11,49,'Load database ACTP1',nil);
      AddFullItem(' ~2~  Accounts Receivable ',12,50,'Load database ACTR7',nil);
      AddFullItem(' ~3~  Net Assets Employed ',13,51,'Load the ledger file',nil);
      AddFullItem(' ~4~  Net Cash Flow       ',14,52,'Load the cash file',nil);
      SetStyleTitle(6,'Load Menu');
      SetActiveItem(2);
      SetMessageXY(25,25);
      SetGap(1);
      Win^.SetClose(False);
   end;
   with Main do
   begin
      Init;
      AddItem('');
      AddFullItem(' ~1~   Load a file         ',1,49,'Loads a new database file',@Load);
      AddFullItem(' ~2~   Edit Date            ',2,50,'Full screen editing of data base entries',nil);
      AddFullItem(' ~3~   Save the file        ',3,51,'Save database file to disk',nil);
      AddFullItem(' ~4~   Change configuration ',4,52,'Modify colors and defaults',nil);
      AddItem('');
      AddFullItem(' ~Q~   Quit                 ',99,81,'Exit system and return to DOS',nil);
      SetStyleTitle(6,'Main Menu');
      SetActiveItem(2);
      SetMenuXY(0,4);
      SetMessageXY(25,25);
      SetGap(1);
      Win^.SetClose(False);
      Choice := Activate;
      Done;
      Load.Done;
   end;
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice);
end.