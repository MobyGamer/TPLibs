Program DemoBoxThree;
{DEMBX3}

USES DOS,CRT, totFAST;

begin
   with Screen do
   begin
      TitledBox(1,1,80,25,27,31,30,1,' Smart Line Drawing ');
      FillBox(30,7,50,18,27,2);
      SmartVertLine(10,1,25,27,2);
      SmartVertLine(70,1,25,27,1);
      SmartVertLine(40,7,18,27,2);
      SmartHorizLine(1,80,10,27,1);
      SmartHorizLine(1,80,20,27,2);
      SmartHorizLine(30,50,13,27,1);
      repeat until keypressed;
      GotoXY(1,25);
   end;
end.



