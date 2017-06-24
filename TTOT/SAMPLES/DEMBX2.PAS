Program DemoBoxTwo;
{DEMBX2}

USES DOS,CRT, totFAST;

begin
   with Screen do
   begin
      Clear(white,chr(178));
      TitledBox(1,1,19,10,27,31,30,1,'Default');
      TitledBox(21,1,39,10,27,31,30,1,'_Bottom');
      TitledBox(41,1,59,10,27,31,30,1,'|Drop Box');
      TitledBox(61,1,80,10,27,31,30,1,'<Left');
      TitledBox(1,12,19,22,27,31,30,1,'>Right');
      TitledBox(21,12,39,22,27,31,30,1,'_<Bottom Left');
      TitledBox(41,12,59,22,27,31,30,1,'>|Drop Right');
      TitledBox(61,12,80,22,27,31,30,1,'< Spaced Left ');
      WriteCenter(24,white,'You get the idea!');
      repeat until keypressed;
      GotoXY(1,25);
   end;
end.




