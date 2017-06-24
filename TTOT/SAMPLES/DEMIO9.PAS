program DemoIONine;
{demIO9 - single date field input}

Uses DOS, CRT,
     totIO1, totIO2, totDate;

Var
   Birthday: DateIOOBJ;

begin
   ClrScr;
   with Birthday do
   begin
      Init(35,5,MMDDYY);
      SetLabel('When is your next birthday? ');
      Activate;
      Writeln;
      writeln('You entered the julian date ',GetValue);
      writeln('i.e. ',JultoStr(GetValue,MMDDYY));
      Done;
   end;
end.

