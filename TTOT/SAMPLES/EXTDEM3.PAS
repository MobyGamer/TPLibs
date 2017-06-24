Program ExtendedDemoThree;
{EXTDEM3 - this program shows how to use the MonoWriteOBJ object
 developed in the ExtFast unit. The demo is actually a simple
 adaptation of the browse demo file DEMBR1}

Uses DOS,CRT,
     totINPUT, totFAST,totLIST, totSTR, ExtFast;

var
   WhiteWrite: MonoWriteOBJ;
   BWin: BrowseArrayOBJ;
   StringList: array[1..26] of string[100];
   I : integer;

begin
   WhiteWrite.Init;
   Screen.AssignWriteOBJ(WhiteWrite);
   for I := 1 to 26 do  {first assign something to the string array}
      StringList[I] := 'Line '+IntToStr(I)+': '+replicate(80,char(I+64));
   ShadowTot^.SetShadowStyle(downright,red,chr(219));
   Screen.Clear(green,' '); {paint the screen}
   Key.SetFast;
   Key.SetClick(true);
   with BWin do
   begin
      Init;
      AssignList(StringList,26,100);
      Go;
      Done;
   end;
end.
