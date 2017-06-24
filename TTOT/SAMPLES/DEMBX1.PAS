Program DemoBoxOne;
{DEMBX1}

USES DOS,CRT, totFAST;

begin
   Clrscr;
   with Screen do
   begin
      Box(1,1,19,10,white,0);
      WriteAt(2,2,white,'Style 0');
      Box(21,1,39,10,white,1);
      WriteAt(22,2,white,'Style 1');
      Box(41,1,59,10,white,2);
      WriteAt(42,2,white,'Style 2');
      Box(61,1,80,10,white,3);
      WriteAt(62,2,white,'Style 3');
      Box(1,12,19,20,white,4);
      WriteAt(2,13,white,'Style 4');
      Box(21,12,39,20,white,5);
      WriteAt(22,13,white,'Style 5');
      Box(41,12,59,20,white,6);
      WriteAt(42,13,white,'Style 6');
      Box(61,12,80,20,white,127);
      WriteAt(62,13,white,'Style 127');
      WriteAt(1,22,white,'Style 1,3');
      Horizline(13,80,22,white,1);
      WriteAt(1,23,white,'Style 2,4');
      Horizline(13,80,23,white,4);
      WriteAt(1,24,white,'Style 14');
      Horizline(13,80,24,white,14);
      WriteAt(1,25,white,'Style 219');
      Horizline(13,80,25,white,219);
      repeat until keypressed;
      gotoXY(1,25);
   end;
end.
