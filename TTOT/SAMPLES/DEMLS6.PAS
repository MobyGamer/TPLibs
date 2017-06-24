program DemoList6;
{demls6 - displaying a list message}

Uses DOS, CRT,
     totFAST, totLINK, totLIST, totSTR, totMSG;

Var
   ListWin:  ListLinkObj;
   ItemList: StrDLLOBJ;
   FileOK: boolean;

{$F+}
function MsgHook(HiPick:longint):string;
{}
begin
   MsgHook := 'The Hi Pick is '+IntToStr(HiPick);
end; {MsgHook}
{$F-}

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
      SetMsgHook(MsgHook);
      Win^.SetTitle(' A List With Messages ');
      Win^.SetSize(20,5,60,20,2);
      Win^.SetMinSize(20,7);
      if not FileOk then
         SetTagging(false);
      Go;
      Done;
   end;
   ItemList.Done;
end.


