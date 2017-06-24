Program DemoFastOne;
{DEMFS1}

USES DOS,CRT, totFAST;

var 
  WasOn: boolean;
begin
   Clrscr;
   with Screen do
   begin
      WriteAt(1,1,white,'* 1,1 (original)');
      WriteAt(5,5,white,'* 5,5 (original)');
      SetWindow(20,8,60,15);
      Clear(31,' ');
      WriteAt(1,1,lightcyan,'* 1,1 (in window)');
      WriteAt(5,5,lightcyan,'* 5,5 (in window)');
      WriteAt(20,7,Lightcyan,'This text is too long to fit!');
      GotoXY(1,2);
      TextColor(Lightcyan);
      System.Writeln('Written with Turbo''s Writeln');
      WasOn := WindowOff;   {disbale the window}
      WriteRight(80,23,white,'Written with WindowOff');
      WindowOn;
      WriteAt(1,8,lightcyan,'Window enabled again');
      ResetWindow;
      GotoXY(1,24);
   end;
end.
