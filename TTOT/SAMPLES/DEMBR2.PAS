Program DemoBrowseArray;

Uses DOS,CRT,
     totFAST,totLIST, totSTR;

var
   BWin: BrowseArrayOBJ;
   StringList: array[1..26] of string[100];
   I : integer;
begin
   for I := 1 to 26 do  {first assign something to the string array}
      StringList[I] := 'Line '+IntToStr(I)+': '+replicate(80,char(I+64));
   Screen.Clear(white,'°'); {paint the screen}
   with BWin do
   begin
      Init;
      AssignList(StringList,26,100);
      Win^.SetSize(30,5,50,15,2);
      Win^.SetTitle('Array Browse Demo');
      Go;
      Done;
   end;
end.
