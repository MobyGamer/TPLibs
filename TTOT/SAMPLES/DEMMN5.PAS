program DemoMenuFive;
{DEMMN5 - a nested Lotus menu}

USES  DOS, CRT,
      totMENU, totFAST;

var
  Main,
  Worksheet,
  Range: LotusMenuOBJ;
  Choice: word;

procedure Pretend;
begin
   Screen.Clear(31,' '); {paint the screen}
   Screen.WriteAt(1,4,48,replicate(80,' '));
   Screen.WriteCenter(4,48,'Not 1-2-3!');
   Screen.PartClear(1,5,4,25,48,' ');
end; {Pretend}

begin
   Pretend;
   with Worksheet do
   begin
      Init;
      AddFullItem('~G~lobal',100,71,'Global stuff',nil);
      AddFullItem('~I~nsert',101,73,'Insert stuff',nil);
      AddFullItem('~D~elete',102,68,'Delete stuff',nil);
      AddFullItem('~C~olumn',103,67,'Column stuff',nil);
      AddFullItem('~E~rase',104,69,'Erase stuff',nil);
      AddFullItem('~T~itles',105,84,'Titles stuff',nil);
      AddFullItem('~W~indow',106,87,'Window stuff',nil);
      AddFullItem('~S~tatus',107,83,'Status stuff',nil);
      AddFullItem('~P~age',108,80,'Page stuff',nil);
      AddFullItem('~H~ide',109,72,'Hide things',nil);
      SetActiveItem(1);
      SetGap(1);
   end;
   with Range do
   begin
      Init;
      AddFullItem('~F~ormat',200,70,'Format stuff',nil);
      AddFullItem('~L~abel',201,76,'Label stuff',nil);
      AddFullItem('~E~rase',202,69,'Erase stuff',nil);
      AddFullItem('~N~ame',203,78,'Name stuff',nil);
      AddFullItem('~J~ustify',204,74,'Justify stuff',nil);
      AddFullItem('~P~rot',205,80,'Protect stuff',nil);
      AddFullItem('~U~nprot',206,85,'Unprotect stuff',nil);
      AddFullItem('~I~nput',207,73,'Input stuff',nil);
      AddFullItem('~V~alue',208,86,'Value stuff',nil);
      AddFullItem('~T~rans',209,84,'Transpose stuff',nil);
      AddFullItem('~S~earch',209,83,'Search for things',nil);
      SetActiveItem(1);
      SetGap(1);
   end;
   with Main do
   begin
      Init;
      AddFullItem('~W~orksheet',1,87,'Worksheet and global operations',@Worksheet);
      AddFullItem('~R~ange',2,82,'Commands for manipulating data ranges',@Range);
      AddFullItem('~C~opy',3,67,'Cell and range copying commands',nil);
      AddFullItem('~M~ove',4,77,'Cell and range moving commands',nil);
      AddFullItem('~F~ile',5,70,'File loading and saving operations',nil);
      AddFullItem('~P~rint',6,80,'Graph and spreadsheet printing',nil);
      AddFullItem('~G~raph',7,71,'Spreadsheet charting',nil);
      AddFullItem('~D~ata',8,68,'Database operations',nil);
      AddFullItem('~S~ystem',9,83,'Drop to the Operating System',nil);
      AddFullItem('~Q~uit',99,81,'Miller Time!',nil);
      SetActiveItem(1);
      SetGap(1);
      Choice := Activate;
      Done;
      Worksheet.Done;
      Range.Done;
   end;
   gotoxy(1,5);
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice);
end.    
