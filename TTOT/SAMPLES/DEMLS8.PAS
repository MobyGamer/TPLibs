program DemoListEight;
{demls8 - using Message and Character hooks}

Uses DOS, CRT,
     totFAST, totLINK, totLIST, totSTR, totMSG;

Var
   ListWin:  ListLinkObj;
   ItemList: StrDLLOBJ;
   FileOK: boolean;

{$F+}
function HelpHook(var K:word; var X,Y: byte; HiPick:longint): tListAction;
{}
var MsgWin: MessageOBJ;
begin
   HelpHook := None;
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
end; {HelpHook}

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
   Screen.WriteCenter(25,white,'  F1 Help   F2 Toggle Color!   [Space] Toggle Tag  ');
   LoadLinkedList;
   with ListWin do
   begin
      Init;
      AssignList(ItemList);
      SetColWidth(15);
      SetCharHook(HelpHook);
      SetMsgHook(MsgHook);
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


