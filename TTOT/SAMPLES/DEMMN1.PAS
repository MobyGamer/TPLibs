program DemoMenuOne;
{DEMMN1 - a basic menu}

USES  DOS, CRT,
      totMENU, totFAST;

var
  Main: MenuOBJ;
  Choice: byte;
begin
   Screen.Clear(white,'°'); {paint the screen}
   with Main do
   begin
      Init;
      AddItem('');
      AddItem(' Load a file          ');
      AddItem(' Edit Date            ');
      AddItem(' Save the file        ');
      AddItem(' Change configuration ');
      AddItem('-');
      AddItem(' Quit                 ');
      SetStyleTitle(1,' Main Menu ');
      SetActiveItem(2);
      Choice := Activate;
      Done;
   end;
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice);
end.