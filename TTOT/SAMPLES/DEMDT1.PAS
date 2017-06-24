program DemoDateOne;
{DEMDT1 - simple date statements}

uses DOS,CRT, totDATE;

var
 M,D,Y:longint;

begin
   writeln(GregToJul(2,11,1991));
   writeln(FancyDateStr(GregToJul(2,20,1956)+100,true,true));
   writeln;
   writeln(GregtoJul(3,21,57));
   JulToGreg(2447654,M,D,Y);
   writeln(M,' ',D,' ',Y);
   writeln(DOWJul(2448299));
   writeln(StartofYear(2448299));
   writeln(EndOfYear(2448299));
   writeln(RelativeDate('04/05/91',MMDDYY,-7));
   writeln(FancyDateStr(2448299,true,true));
end.