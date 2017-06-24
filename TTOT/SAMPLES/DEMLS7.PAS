program DemoList7;
{demls6 - creating a descendant ListObject}

Uses DOS, CRT,
     totFAST, totLINK, totLIST, totSTR, totMSG;

Type
  NewListLinkOBJ = object (ListLinkOBJ)
     {Methods...}
     constructor Init;
     function    MessageTask(HiPick:longint):string;             VIRTUAL;
     destructor  Done;                                           VIRTUAL;
  end; {NewListLinkOBJ}

Var
   ListWin:  NewListLinkObj;
   ItemList: StrDLLOBJ;
   FileOK: boolean;
{+++++new object methods+++++}
constructor NewListLinkOBJ.Init;
{}
begin
   ListLinkOBJ.Init;
   vMsgActive := true;
end; {NewListLinkOBJ.Init}

function  NewListLinkOBJ.MessageTask(HiPick:longint):string;
{}
begin
   MessageTask := 'The Hi Pick is '+IntToStr(HiPick);
end; {NewListLinkOBJ.MessageTask}

destructor NewListLinkOBJ.Done;
{}
begin
   ListLinkOBJ.Done;
end; {NewListLinkOBJ.Done}
{+++++end of new object methods+++++}

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
