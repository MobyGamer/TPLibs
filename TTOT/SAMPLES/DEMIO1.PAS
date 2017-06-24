program DemoIOOne;
{demIO1 - single field input}

Uses DOS, CRT,
     totFAST, totIO1, totIO2;

Var
   Price: FixedRealIOOBJ;

begin
   ClrScr;
   with Price do
   begin
      Init(35,5,8,2);
      SetLabel('How much was the doppleganger? ');
      SetValue(250.0);
      SetMinMax(0.1,12250.0);
      SetRules(EraseDefault);
      Activate;
      Writeln;writeln('You entered ',GetValue);
      Done;
   end;
end.

