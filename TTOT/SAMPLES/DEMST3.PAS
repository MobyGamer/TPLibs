program DemoStringThree;
{demST3 - number formatting}

Uses DOS, CRT,
     totFAST, totSTR;

Var
   Fmt: FmtNumberOBJ;

begin
   ClrScr;
   with Fmt do
   begin
      Init;
      writeln(FormattedLong(2000,15));
      writeln(FormattedReal(2000,2,15));
      SetSign(PlusMinus);
      writeln(FormattedLong(2000,15));
      SetSign(DBCR);
      writeln(FormattedReal(2000,3,15));
      SetPrefixSuffix('$','');
      writeln(FormattedReal(2000,3,15));
      SetSeparators('*',',','.');
      writeln(FormattedReal(2000,3,15));
      SetJustification(JustRight);
      writeln(FormattedReal(2000,3,15));
      Done;
   end;
   GotoXY(1,23);
end.

