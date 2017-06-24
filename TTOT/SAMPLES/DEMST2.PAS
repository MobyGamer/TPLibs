program DemoStringTwo;
{demST2 - more string functions}

Uses DOS, CRT,
     totSTR;

Const
    MyInt:integer = 4000;
    MyReal:real = 89.99;
    MyIntStr = '8000';
    MyRealStr = '89.95';
    MyHexStr = 'FFFF';

begin
   ClrScr;
   writeln('Test number - ',MyInt);
   writeln;
   writeln('IntToStr:    ',IntToStr(MyInt));
   writeln('IntToHEXStr: ',IntToHEXStr(MyInt));
   writeln;
   writeln;
   writeln('Test number - ',MyReal:5:2);
   writeln;
   writeln('RealToStr: ',RealToStr(MyReal,5));
   writeln('RealToStr: ',RealToStr(MyReal,1));
   writeln('RealToStr: ',RealToStr(MyReal,FLOATING));
   writeln('RealToSciStr: ',RealToSciStr(MyReal,FLOATING));
   writeln;
   writeln;
   writeln('Test Strings: ',MyIntStr,' ',MyRealStr,' ',MyHEXStr);
   writeln;
   writeln('ValidInt: ',ValidInt(MyIntStr));
   writeln('ValidInt: ',ValidInt(MyHEXStr));
   writeln('ValidInt: ',ValidInt(MyRealStr));
   writeln('ValidReal: ',ValidReal(MyIntStr));
   writeln('ValidReal: ',ValidReal(MyRealStr));
   GotoXY(1,23);

end.

