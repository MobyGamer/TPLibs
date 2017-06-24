program DemoIOSeven;
{demio7- single field real input}

Uses DOS, CRT,
     totIO1, totIO2;

var
   Field: RealIOOBJ;

begin
   ClrScr;
   with Field do
   begin
      Init(25,14,10);
      SetMinMax(-123123,234234100);
      Setlabel('Enter any real');
      SetValue(35.34);
      SetENotation(true);
      SetRules(EraseDefault);
      Activate;
      Writeln;writeln(GetValue);
      Done;
   end;
end.
