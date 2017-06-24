Program DemoScrollOne;
{DEMSC1}

USES DOS,CRT, totFAST;

begin
   Clrscr;
   with Screen do
   begin
      WriteHScrollBar(1,80,1,31,1,1000);
      WriteHScrollBar(1,80,3,31,950,1000);
      WriteHScrollBar(1,39,5,31,500,1000);
      WriteHScrollBar(41,80,5,31,25,100);
      WriteVScrollBar(1,7,23,31,1,50);
      WriteVScrollBar(3,7,23,31,50,50);
      WriteVScrollBar(5,7,23,31,2,4);
      ScrollTOT^.SetScrollChars(chr(30),chr(31),chr(17),chr(16),
                                chr(4),chr(219));
      WriteHScrollBar(10,70,11,27,5,10);
      WriteVScrollBar(50,13,23,27,8,10);
      GotoXY(1,24);
   end;
end.
