Program DemoBrowseArrayFive;
{DEMBR5 - changing default colors}

Uses DOS,CRT,
     totINPUT, totFAST,totLIST, totSTR;

var
   BWin: BrowseArrayOBJ;
   StringList: array[1..26] of string[100];
   I : integer;

begin
   for I := 1 to 26 do  {first assign something to the string array}
      StringList[I] := 'Line '+IntToStr(I)+': '+replicate(80,char(I+64));
   Screen.Clear(white,'°'); {paint the screen}
   Key.SetFast;
   Key.SetClick(true);
   with BWin do
   begin
      Init;
      AssignList(StringList,26,100);
      {now lets change some colors}
      Win^.SetColors(23,27,31,30);
      Go;
      Done;
   end;
end.
