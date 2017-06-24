program DemoListNine;
{demls9 - extending the LinkListOBJ object}

Uses DOS, CRT,
     totFAST, totLINK, totLIST, totSTR, totMSG;

Type
  NewListLinkOBJ = object (ListLinkOBJ)
     {Methods...}
     constructor Init;
     function    MessageTask(HiPick:longint):string;             VIRTUAL;
     function    CharTask(var K:word; var X,Y: byte; 
                          HiPick:longint): tListAction;          VIRTUAL;
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

function NewListLinkOBJ.CharTask(var K:word; var X,Y: byte; 
                                 HiPick:longint): tListAction;     
{}
var MsgWin: MessageOBJ;
begin
   CharTask := none;
   if K = 315 then
   begin
      with MsgWin do
      begin
         Init(6,'Kinda Help');
         AddLine('');
         AddLine('In a real application, this would');
         AddLine('be a help screen, and it would give');
         AddLine('help related to item '+IntToStr(HiPick)+'!');
         AddLine('');
         Show;
         Done;
      end;
      K := 0;
   end
   else if K = 316 then {F2 so swap colors}
   begin
      ListWin.SetStatus(HiPick,1,not ListWin.GetStatus(HiPick,1));
      K := 336; {emulate down cursor}
   end;
end; {NewListLinkOBJ.CharTask}

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
   Screen.WriteCenter(25,white,'  F1 Help   F2 Toggle Color!   [Space] Toggle Tag  ');
   LoadLinkedList;
   with ListWin do
   begin
      Init;
      AssignList(ItemList);
      SetColWidth(15);
      SetDualColors(true);
      Win^.SetTitle(' A Multi-Colored List ');
      Win^.SetSize(20,5,60,20,2);
      Win^.SetMinSize(20,7);
      if not FileOk then
         SetTagging(false);
      Go;
      Done;
   end;
   ItemList.Done;
end.


