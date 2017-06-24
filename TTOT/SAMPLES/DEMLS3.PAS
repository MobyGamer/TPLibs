program DemoList3;
{demls3}

Uses DOS, CRT,
     totFAST, totLIST, totLOOK;

Var
   Items : array [1..20] of string[30];
   ListWin:  ListArrayObj;

procedure FillArray;
{}
begin
   Items[1] := 'One';
   Items[2] := 'Two';
   Items[3] := 'Three';
   Items[4] := 'Four';
   Items[5] := 'Five';
   Items[6] := 'Six';
   Items[7] := 'Seven';
   Items[8] := 'Eight';
   Items[9] := 'Nine';
   Items[10] := 'Ten';
   Items[11] := 'Eleven';
   Items[12] := 'Twelve';
   Items[13] := 'Thirteen';
   Items[14] := 'Fourteen';
   Items[15] := 'Fifteen';
   Items[16] := 'Sixteen';
   Items[17] := 'Seventeen';
   Items[18] := 'Eighteen';
   Items[19] := 'Nineteen';
   Items[20] := 'Twenty';
end; {FillArray}

begin
   Screen.Clear(white,'°'); {paint the screen}
   FillArray;
   with ListWin do
   begin
      Init;
      AssignList(Items,20,30,true);
      SetColWidth(15);
      Win^.SetTitle(' Pick a number! ');
      Win^.SetSize(24,7,55,18,2);
      LookTOT^.SetListChars(chr(16),chr(17),chr(14),chr(32));
      Go;
      Done;
   end;
end.


