program DemoIOFifteen;
{demIO15 - single WWArrayIOOBJ input}
                   
Uses DOS, CRT,
     totFAST, totIO1, totIO3, totINPUT;

Var
   MyList: array[1..10] of string[60];
   WWField: WWArrayIOOBJ;

procedure FillArray;
{}
begin
   FillChar(MyList,sizeof(MyList),#0);
   MyList[1] := 'It seems like we have to work at innocence ';
   MyList[2] := 'and being pure, and at the same time we have ';
   MyList[3] := 'to work at being successful so that we have ';
   MyList[4] := 'an understanding as to what the rest of the ';
   MyList[5] := 'world is up to.';
   MyList[6] := '';
   MyList[7] := 'Brother Anthony Fiore';
end; {FillArray}

begin
   ClrScr;
   Screen.WriteCenter(1,15,'Press F10 to finish');
   FillArray;
   Mouse.Show;
   with WWField do
   begin
      Init(5,7,65,7,'A Quote');
      AssignList(MyList,10,60);
      WrapFull;
      Activate;
      gotoxy(1,20);
      Done;
   end;
   Mouse.Hide;
end.

