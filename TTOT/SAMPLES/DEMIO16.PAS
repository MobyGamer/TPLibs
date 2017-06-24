program DemoIOSixteen;
{demIO16 - single WWLinkIOOBJ input}
                   
Uses DOS, CRT,
     totFAST, totIO1, totIO3, totINPUT, totLINK;

Var
   MyList: StrDLLOBJ;
   WWField: WWLinkIOOBJ;

procedure FillList;
{}
var Retcode: integer;
begin
   with MyList do
   begin
      init;
      Retcode := Add('It seems like we have to work at innocence ');
      Retcode := Add('and being pure, and at the same time we have ');
      Retcode := Add('to work at being successful so that we have ');
      Retcode := Add('an understanding as to what the rest of the ');
      Retcode := Add('world is up to.');
      Retcode := Add('');
      Retcode := Add('Brother Anthony Fiore');
   end; 
end; {FillList}

begin
   ClrScr;
   Screen.WriteCenter(1,15,'Press F10 to finish');
   FillList;
   Mouse.Show;
   with WWField do
   begin
      Init(5,7,65,7,'A Quote');
      AssignList(MyList,40);
      WrapFull;
      Activate;
      gotoxy(1,20);
      MyList.Done;
      Done;
   end;
   Mouse.Hide;
end.

