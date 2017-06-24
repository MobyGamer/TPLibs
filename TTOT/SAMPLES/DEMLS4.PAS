program DemoList4;
{demls4 - reading a list from a text file}

Uses DOS, CRT,
     totFAST, totLINK, totLIST;

Var
   ListWin:  ListLinkObj;
   ItemList: StrDLLOBJ;
   FileOK: boolean;

procedure LoadLinkedList;
{}
var 
  F: text;
  Line:string;
  Result: integer;
begin
   with ItemList do
   begin
      Init;
      {$I-}
      Assign(F,'demls4.txt');
      Reset(F);
      {$I+}
      FileOK := (IOResult = 0);
      if not FileOK then
         Result := Add('File not found')
      else
      begin
         while not eof(F) do
         begin
            Readln(F,Line);
            Result := Add(Line);
         end;
         close(F);
      end;
   end;
end; {LoadLinkedList}

begin
   Screen.Clear(white,'°'); {paint the screen}
   LoadLinkedList;
   with ListWin do
   begin
      Init;
      AssignList(ItemList);
      SetColWidth(15);
      Win^.SetTitle(' Items from file DEMLS4.TXT ');
      Win^.SetSize(20,5,60,20,1);
      if not FileOk then
         SetTagging(false);
      Go;
      Done;
   end;
   ItemList.Done;
end.


