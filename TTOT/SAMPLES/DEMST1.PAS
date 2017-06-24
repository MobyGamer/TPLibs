program DemoStringOne;
{demST1 - string functions}

Uses DOS, CRT,
     totFAST, totSTR;

Var
   DemoStr : string;

begin
   ClrScr;
   with Screen do
   begin
      DemoStr := '  TechnoJock''s Object Toolkit string demo   ';
      WriteAt(5,1,lightgray,'Source String: ');
      WriteAt(30,1,lightcyan,'"'+DemoStr+'"');
      WriteAt(1,4,lightgray,'SetUpper:');
      WriteAt(30,4,yellow,'"'+SetUpper(DemoStr)+'"');
      WriteAt(1,5,lightgray,'SetLower:');
      WriteAt(30,5,yellow,'"'+SetLower(DemoStr)+'"');
      WriteAt(1,6,lightgray,'SetProper:');
      WriteAt(30,6,yellow,'"'+SetProper(DemoStr)+'"');
      WriteAt(1,7,lightgray,'Total words:');
      WriteAt(30,7,lightgreen,IntToStr(WordCnt(DemoStr)));
      WriteAt(1,8,lightgray,'Posn. Word 3:');
      WriteAt(30,8,lightgreen,IntToStr(PosWord(3,DemoStr)));
      WriteAt(1,9,lightgray,'Words 2..5 are:');
      WriteAt(30,9,yellow,'"'+ExtractWords(2,4,DemoStr)+'"');
      WriteAt(1,10,lightgray,'Strip Leading spaces:');
      WriteAt(30,10,yellow,'"'+Strip('L',' ',DemoStr)+'"');
      WriteAt(1,11,lightgray,'Strip Trailing spaces:');
      WriteAt(30,11,yellow,'"'+Strip('R',' ',DemoStr)+'"');
      WriteAt(1,12,lightgray,'Strip Lng. & Tng. spaces:');
      WriteAt(30,12,yellow,'"'+Strip('B',' ',DemoStr)+'"');
      WriteAt(1,13,lightgray,'Strip All spaces:');
      WriteAt(30,13,yellow,'"'+Strip('A',' ',DemoStr)+'"');
   end;
   GotoXY(1,23);
end.

