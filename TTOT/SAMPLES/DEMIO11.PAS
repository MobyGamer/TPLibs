program DemoIOEleven;
{demIO11 - single Radio Button input}

Uses DOS, CRT,
     totFAST, totINPUT, totIO1, totIO2;

Var
   Bool: RadioIOOBJ;

begin
   ClrScr;
   with Bool do
   begin
      Init(35,12,20,5,'Sex?');
      SetBoxOn(True);
      AddItem('~M~ale',77,true);
      AddItem('~F~emale',70,false);
      Mouse.Show;
      Activate;
      Mouse.Hide;
      gotoxy(1,20);
      if GetValue = 1 then
         writeln('You are male!')
      else
         writeln('Hi, I''m Bob.');
      Done;
   end;
end.

