program DemoMenuFour;
{DEMMN1 - a simple lotus menu}

USES  DOS, CRT,
      totMENU, totFAST;

var
  P: LotusMenuOBJ;
  Choice: byte;
begin
   Screen.Clear(white,'°'); {paint the screen}
   with P do
   begin
      Init;
      AddItem('Worksheet');
      AddItem('Range');
      AddItem('Copy');
      AddItem('Move');
      AddItem('File');
      AddItem('Print');
      AddItem('Graph');
      AddItem('Data');
      AddItem('System');
      AddItem('Quit');
      SetActiveItem(1);
      SetGap(1);
      Choice := Activate;
      Done;
   end;
   GotoXY(1,5);
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice);
end.     