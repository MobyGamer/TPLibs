program DemoDateTwo;
{DEMDT2 - example date statements}

uses DOS,CRT, totDATE;

var
 M,D,Y:longint;

begin
   ClrScr;
   writeln(TodayInJul);
   writeln(JultoStr(TodayInJul,DDMMYYYY));
   writeln(FancyDateStr(TodayInJul,false,false));
   writeln(FancyDateStr(TodayInJul,true,false));
   writeln(FancyDateStr(TodayInJul,false,true));
   writeln(FancyDateStr(TodayInJul,true,true));
   writeln;
   writeln(RelativeDate('02/20/56',MMDDYY,90));
   writeln;
   writeln(JulToStr(StartOfYear(StrToJul('30/06/1990',DDMMYYYY)),DDMMYYYY));
   writeln(JulToStr(EndOfYear(StrToJul('30/06/1990',DDMMYYYY)),DDMMYYYY));
   writeln;
   writeln(ValidDateStr('02/29/90',MMDDYY));
   writeln(ValidDate(2,29,90));
   writeln(DateFormat(MMDDYY));
   repeat until keypressed;
end.