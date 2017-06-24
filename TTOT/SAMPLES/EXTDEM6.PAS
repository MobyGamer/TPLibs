Program ExtendedDemoSix;
{EXTDEM6 - this program shows how to extend RecordListOBJ object 
           from the extLINK unit, and ListLinkDLL from totLINK to
           produce a customised record Lister.}

Uses DOS,CRT,
     totFAST, totINPUT, totIO2, totLIST, extLINK, totSTR, totLINK;


TYPE
  
Rec2DLLOBJ = object (RecordDLLOBJ)
   constructor Init;
   function    GetStr(Node:DLLNodePtr;Start,Finish: longint):string;  VIRTUAL;
   destructor  Done;                                                  VIRTUAL;
end; {Rec2DLLOBJ}

ListRecOBJ = object (ListLinkOBJ)
   constructor Init;
   function    MessageTask(HiPick:longint):string;                    VIRTUAL;
   destructor  Done;                                                  VIRTUAL;
end; {ListRecOBJ}

VAR
  RecList: Rec2DLLOBJ;
  ListWin: ListRecOBJ;

{\\\\\\\\\\\\\\\\\\ OBJECT EXTENSIONS \\\\\\\\\\\\\\\\\\\\\\\\}
constructor Rec2DLLOBJ.Init;
{}
begin
   RecordDLLOBJ.Init;
end; {Rec2DLLOBJ.Init}

function Rec2DLLOBJ.GetStr(Node:DLLNodePtr;Start,Finish: longint):string;
{gets last name only for displaying in list}
var 
  Temp: string;
  Rec: RecordInfo;
begin
   if Node = nil then
      GetStr := 'Not found'
   else
   begin
      If (Start = 0) and (Finish = 0) then {must be a call from message!}
         GetStr := RecordDLLOBJ.GetStr(Node,1,80)
      else
      begin
         GetNodeData(Node,Rec);  {inherited method}
         Temp := Rec.LastName;
         GetStr := copy(Temp,Start,succ(Finish-start));
      end;
   end;
end; {Rec2DLLOBJ.GetStr}

destructor Rec2DLLOBJ.Done;
{}
begin
   RecordDLLOBJ.Done;
end; {Rec2DLLOBJ.Done}

constructor ListRecOBJ.Init;
{}
begin
   ListLinkOBJ.Init;
   vMsgActive := true;
end; {ListRecOBJ.Init}

function ListRecOBJ.MessageTask(HiPick:longint):string;
{returns the record details as the message}
var 
  Temp: string;
  Rec: RecordInfo;
begin
   MessageTask := vLinkList^.GetStr(vLinkList^.NodePtr(HiPick),0,0);
end; {ListRecOBJ.MessageTask}

destructor ListRecOBJ.Done;                              
{}
begin
   ListLinkOBJ.Done;
end; {ListRecOBJ.Done}
{\\\\\\\\\\\\\\\\\\ MAIN PROGRAM CODE \\\\\\\\\\\\\\\\\\\\\\\\}
procedure BuildTheList(Filename:string);
{loads in the data from disk - could also be from d/b}
var 
  F: file of RecordInfo;
  Rec: RecordInfo;
  Ecode: integer;
begin
   assign(F,filename);
   {$I-}
   reset(F);
   {$I+}
   if ioresult <> 0 then
   begin
      clrscr;
      writeln('The file ',filename,' cannot be located.');
      writeln('Demo aborting. Run demo from directory containing file.');
      halt(1);
   end;
   Ecode := 0;
   RecList.Init;
   while not eof(F) and (Ecode = 0) do
   begin
      Read(F,Rec);
      with Rec do
      begin
         FirstName:= padleft(FirstName,15,' ');
         LastName:= padleft(LastName,15,' ');
         Company:= padleft(Company,20,' ');
      end;
      Ecode := RecList.Add(Rec);
   end;
   close(F);
end; {BuildtheList}

begin {Main program}
   Clrscr;
   Screen.WriteCenter(12,143,'Reading and Sorting Database');
   BuildTheList('EXTDEM5.DBF');
   RecList.Sort(1,true);
   Screen.Clear(white,'°'); {paint the screen}
   Key.SetFast;
   with FMTNumberTOT do
   begin
      SetJustification(JustRight);
      SetPrefixSuffix('$','');
   end;
   with ListWin do
   begin
      Init;
      Win^.SetTitle(' D/B List ');
      AssignList(RecList);
      SetColWidth(17);
      Go;
   end;
end.
