program DemoIOSix;
{demIO6 - single string field input}

Uses DOS, CRT,
     totFAST, totIO1, totIO2, totSTR;

var
  Field: StringIOOBJ;

begin
   with Field do
   begin
      Init(40,5,10);
      SetLabel('Field (StringIOOBJ)');
      SetCase(upper);
      SetValue('hello');
      SetRules(EraseDefault+JumpIfFull);
      clrscr;
      Activate;
      writeln;writeln('You entered ',GetValue);
      Done;
   end;
end.