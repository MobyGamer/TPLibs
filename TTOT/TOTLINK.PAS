{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totLINK;
{$I TOTFLAGS.INC}

{
 Development Notes:
       1.00a     Apr  2 91   Changed file read logic when only Directory
                             requested in FileDLLOBJ.
       1.00b     May 29 91   Corrected DelNode when nil pointer passed
       1.00c     Jun 11 91   Allowed display of directories when mask <> '*.*'
       1.00d     Oct 10 91   Reset vSorted when list modified
}

INTERFACE

Uses DOS,CRT,
     totSTR;

Const
  NoFiles: string[20] = 'No Files';

Type

tFileInfo = record
     FileName: string[12];
     Attr: byte;
     Time: longint;
     Size: longint;
     LoadID: longint;
end; {tFileInfo}

DLLNodePtr = ^DLLNodeObj;
pDLLNodeOBJ = ^DLLNodeOBJ;
DLLNodeOBJ = Object         {this object is not extensible}
   vNextPtr: DLLNodePtr;
   vPrevPtr: DLLNodePtr;
   vDataPtr: pointer;
   vSize: longint;
   vStatus: byte;   {selectable, selected}
   {methods...}
   procedure FreeData;
   function  NextPtr: DLLNodePtr;
   function  PrevPtr: DLLNodePtr;
   function  GetStatus(BitPos:byte): boolean;
   procedure SetStatus(BitPos:byte;On:boolean);
   function  GetStatusByte: byte;
   procedure SetStatusByte(Val:byte); 
end; {DLLNodeOBJ}

DLLPtr = ^DLLOBJ;
pDLLOBJ = ^DLLOBJ;
DLLOBJ = Object
   vStartNodePtr:  DLLNodePtr;
   vEndNodePtr:    DLLNodePtr;
   vActiveNodePtr: DLLNodePtr;
   vTotalNodes:       longint;
   vActiveNodeNumber: longint;
   vSortID:           shortInt;
   vSortAscending:    boolean;
   vSorted:           boolean;
   vMaxNodeSize :     longint;
   {methods...}
   constructor Init;
   function    Add(var TheData;Size:longint): integer;
   function    Change(Node:DLLNodePtr;var TheData;Size:longint): integer;
   function    InsertBefore(Node:DLLNodePtr;var TheData;Size:longint): integer;
   procedure   Get(var TheData);
   procedure   GetNodeData(Node:DLLNodePtr;Var TheData);
   function    GetNodeDataSize(Node:DLLNodePtr):longint;
   function    GetMaxNodeSize: longint;
   procedure   Advance(Amount:longint);
   procedure   Retreat(Amount:longint);
   function    NodePtr(NodeNumber:longint): DLLNodePtr;
   procedure   Jump(NodeNumber:longint);
   procedure   ShiftActiveNode(NewNode: DLLNodePtr; NodeNumber: longint);
   procedure   DelNode(Node:DLLNodePtr);
   procedure   DelAllStatus(BitPos:byte;On:boolean);
   function    TotalNodes: longint;
   function    ActiveNodeNumber: longint;
   function    ActiveNodePtr: DLLNodePtr;
   function    StartNodePtr: DLLNodePtr;
   function    EndNodePtr: DLLNodePtr;
   procedure   EmptyList;
   procedure   Sort(SortID:shortint;Ascending:boolean);
   function    WrongOrder(Node1,Node2:DLLNodePtr;Asc:boolean): boolean; VIRTUAL;
   procedure   SwapNodes(Node1,Node2:DLLNodePtr);                       VIRTUAL;
   function    GetStr(Node:DLLNodePtr;Start,Finish: longint):string;    VIRTUAL;
   destructor  Done;
end; {DLLOBJ}

StrDLLPtr = ^StrDLLOBJ;
pStrDLLOBJ = ^StrDLLOBJ;
StrDLLOBJ = object (DLLOBJ)
   {methods ...}
   constructor Init;
   function    Add(Str:string): integer;
   function    Change(Node:DLLNodePtr;Str: string): integer;
   function    InsertBefore(Node:DLLNodePtr;Str:string): integer;
   function    WrongOrder(Node1,Node2:DLLNodePtr;Asc:boolean): boolean; VIRTUAL;
   function    GetStr(Node:DLLNodePtr;Start,Finish: longint):string;    VIRTUAL;
   destructor  Done;
end; {StrDLLOBJ}

FileDLLPtr = ^FileDLLOBJ; 
pFileDLLOBJ = ^FileDLLOBJ;
FileDLLOBJ = object (DLLOBJ)
   vFileMasks: string;
   vFileAttrib: word;
   {methods ...}
   constructor Init;
   procedure   FillList;
   procedure   SetFileDetails(FileMasks:string; FileAttrib: word);
   procedure   FillNewMask(FileMasks:string);
   function    GetLongStr(Node:DLLNodePtr):string;
   procedure   GetFileRecord(var FileInfo:tFileInfo; Item:longint);
   function    GetFileMask:string;
   function    WrongOrder(Node1,Node2:DLLNodePtr;Asc:boolean): boolean; VIRTUAL;
   procedure   SwapNodes(Node1,Node2:DLLNodePtr);                       VIRTUAL;
   function    GetStr(Node:DLLNodePtr;Start,Finish: longint):string;    VIRTUAL;
   destructor  Done;
end; {FileDLLOBJ}

function Subdirectory(B : byte):boolean;
function FileAttribs(B:byte):string;
function LongName(Info: tFileInfo):string;
procedure LINKInit;

IMPLEMENTATION
{|||||||||||||||||||||||||||||||||||||||||||||}
{                                             }
{     M i s c.  P r o c s   &   F u n c s     }
{                                             }
{|||||||||||||||||||||||||||||||||||||||||||||}
function Subdirectory(B : byte):boolean;
begin
   Subdirectory := ((B and Directory) = Directory);
end; {Subdirectory}

function FileAttribs(B:byte):string;
var
  S : string;
begin
   S := '    ';
   If ((B and ReadOnly) = Readonly) then
      S[1] := 'R';
   If ((B and Hidden) = Hidden) then
      S[2] := 'H';
   If ((B and SysFile) = SysFile) then
      S[3] := 'S';
   If ((B and Archive) = Archive) then
      S[4] := 'A';
   FileAttribs := S;
end; {FileAttribs}

function LongName(Info: tFileInfo):string;
{}
var 
  DT :datetime;
  S: String;
begin
   S := padleft(Info.FileName,12,' ');
   UnPackTime(Info.Time,DT);
   if Subdirectory(Info.Attr) then                  {add file size}
      S := S + Padright('<DIR>',8,' ')
   else
      S := S + Padright(InttoStr(Info.Size),8,' ');
   S := S + ' ';
   with DT do
   begin
      Case Month of        
         1 : S := S + 'Jan ';
         2 : S := S + 'Feb ';
         3 : S := S + 'Mar ';
         4 : S := S + 'Apr ';
         5 : S := S + 'May ';
         6 : S := S + 'Jun ';
         7 : S := S + 'Jul ';
         8 : S := S + 'Aug ';
         9 : S := S + 'Sep ';
         10: S := S + 'Oct ';
         11: S := S + 'Nov ';
         12: S := S + 'Dec ';
      end; {case}
      S := S + Padright(InttoStr(Day),2,'0')+','+IntToStr(Year)+' ';
      if Hour > 12 then
         S := S + Padright(IntToStr(Hour-12),2,' ')+':'+Padright(IntToStr(min),2,'0')+'p'
      else
         S := S + Padright(IntToStr(Hour),2,' ')+':'+Padright(IntToStr(min),2,'0')+'a';
      S := S + ' '+FileAttribs(Info.Attr);
   end;
   LongName := S;
end; {LongName}
{||||||||||||||||||||||||||||||||||||||||||||||}
{                                              }
{     D L L  N o d e O b j   M E T H O D S     }
{                                              }
{||||||||||||||||||||||||||||||||||||||||||||||}
procedure DLLNodeObj.FreeData;
{}
begin
   if (vDataPtr <> Nil) and (vSize > 0) then
   begin
      Freemem(vDataPtr,vSize);
      vDataPtr := nil;
      vSize:= 0;
   end;
end; {DLLNodeObj.FreeData}

function DLLNodeObj.NextPtr: DLLNodePtr;
{}
begin
   NextPtr := vNextPtr;
end; {DLLNodeOBJ.NextPtr}

function DLLNodeObj.PrevPtr: DLLNodePtr;
{}
begin
   PrevPtr := vPrevPtr;
end; {DLLNodeOBJ.PrevPtr}

function DLLNodeObj.GetStatus(BitPos:byte): boolean;
{}
var TestByte: Byte;
begin
   if BitPos > 7 then
      GetStatus := false
   else
   begin
     Testbyte := vStatus;
     TestByte := TestByte SHR BitPos; {move to end bit}
     GetStatus := odd(TestByte);
   end;
end; {DLLNodeOBJ.GetStatus}

procedure DLLNodeObj.SetStatus(BitPos:byte; On:boolean);
{}
var
   Test : integer;
begin
   if BitPos <= 7 then
   begin
      if On then
      begin
         Test := 1 SHL BitPos;
         vStatus := vStatus or Test
      end
      else
      begin
         Test := not (1 SHL BitPos);
         vStatus := vStatus and Test;
      end;
   end;
end; { DLLNodeObj.SetStatus }

function DLLNodeObj.GetStatusByte: byte;
{}
begin
   GetStatusByte := vStatus;
end; {DLLNodeObj.GetStatusByte}

procedure DLLNodeObj.SetStatusByte(Val:byte);
{}
begin
   vStatus := Val;
end; {DLLNodeObj.SetStatusByte}
{|||||||||||||||||||||||||||||||||||||}
{                                     }
{     D L L O b j   M E T H O D S     }
{                                     }
{|||||||||||||||||||||||||||||||||||||}
constructor DLLOBJ.Init;
{}
begin
   vStartNodePtr := nil;
   vEndNodePtr := nil;
   vActiveNodePtr := nil;
   vTotalNodes := 0;
   vActiveNodeNumber := 0;
   vSortID := 0;
   vSortAscending := true;
   vSorted := true;
   vMaxNodeSize := 0;
end; {DLLOBJ.Init}

function DLLOBJ.Add(var TheData; Size:Longint): integer;
{ Adds node after the ActiveNodePtr, and increments the
  ActiveNodePtr.

  Returns status indicating result of attemp to add.
  Codes:          0      Success
                  1      Not enough memory
                  2      Not enough memory for data
}
var
  Temp: DLLNodePtr;
begin
   if MaxAvail < sizeOf(vStartNodePtr^) then
   begin
      Add := 1;  {not enough memory}
      exit;
   end;
   if vStartNodePtr = nil then
   begin
      getmem(vStartNodePtr,sizeof(vStartNodePtr^));
      vStartNodePtr^.vPrevPtr := nil;
      vActiveNodePtr := vStartNodePtr;
      vActiveNodePtr^.vNextPtr := nil;
      vActiveNodeNumber := 1;
      vEndNodePtr := vActiveNodePtr;
   end
   else
   begin
      if vActiveNodePtr^.vNextPtr = nil then
      begin
         getmem(vActiveNodePtr^.vNextPtr,sizeof(vActiveNodePtr^));
         vActiveNodePtr^.vNextPtr^.vPrevPtr := vActiveNodePtr;
         vActiveNodePtr := vActiveNodePtr^.vNextPtr;
         vActiveNodePtr^.vNextPtr := nil;
         inc(vActiveNodeNumber);
         vEndNodePtr := vActiveNodePtr;
      end
      else  {insert a node}
      begin
         getmem(Temp,sizeof(temp^));
         vActiveNodePtr^.vNextPtr^.vPrevPtr := Temp;
         Temp^.vNextPtr := vActiveNodePtr^.vNextPtr;
         Temp^.vPrevPtr := vActiveNodePtr;
         vActiveNodePtr^.vNextPtr := Temp;
         vActiveNodePtr := Temp;
         inc(vActiveNodeNumber);
      end;
   end;
   inc(vTotalNodes);
   {now add the data to the node data pointer}
   if MemAvail < Size then
   begin
     Add := 2;   {not enough memory for data}
     vActiveNodePtr^.vSize := 0;
     vActiveNodePtr^.vDataPtr := nil;
     exit;
   end;
   if Size > 0 then
   begin
      getmem(vActiveNodePtr^.vDataPtr,Size);
      move(TheData,vActiveNodePtr^.vDataPtr^,Size);
      if Size > vMaxNodeSize then
         vMaxNodeSize := Size;
   end
   else
      vActiveNodePtr^.vDataPtr := nil;
   vActiveNodePtr^.vSize := Size;
   vActiveNodePtr^.vStatus := 0;
   vSorted := false;  {1.00d}
   Add := 0;
end; {DLLOBJ.Add}

function DLLOBJ.Change(Node:DLLNodePtr;var TheData; Size:Longint): integer;
{ Returns status indicating result of attemp to add.
  Codes:          0      Success
                  2      Not enough memory for data
                  3      Invalid Node Ptr
}
begin
   if node = nil then
      Change := 3
   else 
   begin
     Node^.FreeData;
     if MaxAvail < Size then
        Change := 2
     else
     begin
         Change := 0;
         getmem(Node^.vDataPtr,Size);
         move(TheData,Node^.vDataPtr^,Size);
         Node^.vSize := Size;
         vSorted := false;  {1.00d}
     end;
   end;
end; {DLLOBJ.Change}

function DLLOBJ.InsertBefore(Node:DLLNodePtr;var TheData;Size:longint): integer;
{ Returns status indicating result of attemp to add.
  Codes:          0      Success
                  1      Not enough memory
                  2      Not enough memory for data
                  3      Invalid Node Ptr
}
var
  Temp: DLLNodePtr;
begin
   if node = nil then
      InsertBefore := 3
   else if MaxAvail < sizeOf(Node^) then
      InsertBefore:= 1  {not enough memory}
   else
   begin
      if Node = vStartNodePtr then {add to head of list}
      begin
         getmem(Node^.vPrevPtr,sizeof(Node^));
         Node^.vPrevPtr^.vNextPtr := Node;
         Node := Node^.vPrevPtr;
         Node^.vPrevPtr := nil;
         vStartNodePtr := Node;
      end
      else
      begin
         getmem(Temp,sizeof(Temp^));
         Node^.vPrevPtr^.vNextPtr := Temp;
         Temp^.vPrevPtr := Node^.PrevPtr;
         Node^.vPrevPtr := Temp;
         Temp^.vNextPtr := Node;
         Node := Temp;
      end;
      inc(vTotalNodes);
      vActiveNodeNumber := 1;
      vActiveNodePtr := vStartNodePtr;
      if MemAvail < Size then
      begin
         InsertBefore := 2;   {not enough memory for data}
         Node^.vSize := 0;
         Node^.vDataPtr := nil;
      end
      else
      begin
         if Size > 0 then
         begin
            getmem(Node^.vDataPtr,Size);
            move(TheData,Node^.vDataPtr^,Size);
         end
         else
           Node^.vDataPtr := nil;
         Node^.vSize := Size;
         InsertBefore := 0;
      end;
   end;
   vSorted := false;  {1.00d}
end; {DLLOBJ.InsertBefore}

procedure DLLOBJ.Get(Var TheData);
{}
begin
    with vActiveNodePtr^ do
       if vDataPtr <> Nil then
          move(vDataPtr^,TheData,vSize);
end; {DLLOBJ.Get}

procedure DLLOBJ.GetNodeData(Node:DLLNodePtr;Var TheData);
{}
begin
    with Node^ do
       if vDataPtr <> Nil then
          move(vDataPtr^,TheData,vSize);
end; {DLLOBJ.GetNodedata}

function DLLOBJ.GetNodeDataSize(Node:DLLNodePtr):longint;
{}
begin
   with Node^ do
   begin
      if vDataPtr = Nil then
         GetNodeDataSize := 0
      else
         GetNodeDataSize := vSize;
   end;
end; {DLLOBJ.GetNodeDataSize}

function DLLOBJ.GetMaxNodeSize: longint;
{}
begin
   GetMaxNodeSize := vMaxNodeSize;
end; {DLLOBJ.GetMaxNodeSize}

function DLLOBJ.GetStr(Node:DLLNodePtr;Start,Finish:longint): String;
{generic method..usually in descendant object}
var temp: string;
begin
   if Start < 0 then Start := 0;
   if Finish < 0 then Finish := 0;
   {validate Start and Finish Parameters}
   if ((Finish = 0) and (Start = 0))
   or (Start > Finish) then   {get full string}
   begin
      Start := 1;
      Finish := 255;
   end
   else if Finish - Start > 254 then      {too long to fit in string}
      Finish := Start + 254;

   if (Node = Nil)
   or (Node^.vDataPtr = Nil)
   or (Node^.vSize = 0)
   or (Start > Node^.vSize) then
      GetStr := ''
   else
   begin
      if Finish > Node^.vSize then
         Finish := Node^.vSize;
      if Start = 0 then
         inc(Start);
      Move(mem[seg(Node^.vDataPtr^):ofs(Node^.vDataPtr^)+pred(Start)],Temp[1],succ(Finish-Start));
      Temp [0] := chr(succ(Finish-Start));
      GetStr := Temp;
   end;
end; {DLLOBJ.GetStr}

procedure DLLOBJ.Advance(Amount:longint);
{}
var
  I : longint;
begin
   for I := 1 to Amount do
      if vActiveNodePtr^.vNextPtr <> nil then
      begin
          vActiveNodePtr := vActiveNodePtr^.vNextPtr;
          inc(vActiveNodeNumber);
      end;
end; {DLLOBJ.Advance}

procedure DLLOBJ.Retreat(Amount:longint);
{}
var
  I : longint;
begin
   for I := 1 to Amount do
      if vActiveNodePtr^.vPrevPtr <> nil then
      begin
          vActiveNodePtr := vActiveNodePtr^.vPrevPtr;
          dec(vActiveNodeNumber);
      end;
end; {DLLOBJ.Retreat}

procedure DLLOBJ.Jump(NodeNumber:longint);
{}
begin
   if NodeNumber = 1 then
   begin
      vActiveNodePtr := vStartNodePtr;
      vActiveNodeNumber := 1;
   end
   else
   begin
      if NodeNumber < vActiveNodeNumber then
         Retreat(vActiveNodeNumber - NodeNumber)
      else
         Advance(NodeNumber - vActiveNodeNumber);
   end;
end; {DLLOBJ.Jump}

procedure DLLOBJ.ShiftActiveNode(NewNode: DLLNodePtr; NodeNumber: longint);
{}
begin
   vActiveNodePtr := NewNode;
   vActiveNodeNumber := NodeNumber;
end; {DLLOBJ.ShiftActiveNode}

function DLLOBJ.NodePtr(NodeNumber:longint): DLLNodePtr;
{}
var
  StartNode: DLLNodePtr;
  DistanceA,
  DistanceB,
  DistanceC,
  Counter,
  I: LongInt;
  Forwards : boolean;
  Indicator : byte;
begin
   if (NodeNumber < 1) or (NodeNumber > vTotalNodes) then
      NodePtr := nil
   else
   begin
      if NodeNumber = 1 then
         NodePtr := vStartNodePtr
      else if NodeNumber = vTotalNodes then
            NodePtr := vEndNodePtr
      else if NodeNumber = vActiveNodeNumber then
            NodePtr := vActiveNodePtr
      else
      begin
         {check for the nearest node ptr, and jump from there}
         DistanceA := abs(NodeNumber - vActiveNodeNumber);
         DistanceB := NodeNumber;
         DistanceC := vTotalNodes - NodeNumber;
         if DistanceA < DistanceB then
         begin
            if DistanceA < DistanceC then
            begin
               StartNode := vActiveNodePtr;
               Forwards := (vActiveNodeNumber < NodeNumber);
               Counter := DistanceA;
            end
            else
            begin
               StartNode := vEndNodePtr;
               Forwards := false;
               Counter := DistanceC;
            end;
         end
         else      {DA > DB}
         begin
            if DistanceB < DistanceC then
            begin
               StartNode := vStartNodePtr;
               Forwards := true;
               Counter := pred(DistanceB);
            end
            else
            begin
               StartNode := vEndNodePtr;
               Forwards := false;
               Counter := DistanceC;
            end;
         end;
         if Forwards then
            for I := 1 to Counter do
                StartNode := StartNode^.NextPtr
         else
            for I := 1 to Counter do
                StartNode := StartNode^.PrevPtr;
         NodePtr := StartNode;

      end;
  end;
end; {DLLOBJ.NodePtr}

function DLLOBJ.TotalNodes: longint;
{}
begin
    TotalNodes := vTotalNodes;
end;

function DLLOBJ.ActiveNodeNumber: longint;
{}
begin
    ActiveNodeNumber := vActiveNodeNumber;
end;

function DLLOBJ.StartNodePtr: DLLNodePtr;
{}
begin
   StartNodePtr := vStartNodePtr;
end; {DLLOBJ.StartNodePtr}

function DLLOBJ.EndNodePtr: DLLNodePtr;
{}
begin
   EndNodePtr := vEndNodePtr;
end; {DLLOBJ.EndNodePtr}

function DLLOBJ.ActiveNodePtr: DLLNodePtr;
{}
begin
    ActiveNodePtr := vActiveNodePtr;
end; {DLLOBJ.ActiveNodePtr}

(* The following procedure requires only 8 bytes on the 
   stack but damn it's slow!
procedure DLLOBJ.SwapNodes(Node1,Node2:DLLNodePtr);
{swaps the position of two nodes in the tree}
var
   TempPrevPtr,
   TempNextPtr : DLLNodePtr;
begin
   if vStartNodePtr = Node1 then
      vStartNodePtr := Node2
   else if vStartNodePtr = Node2 then
      vStartNodePtr := Node1;
   if vEndNodePtr = Node1 then
      vEndNodePtr := Node2
   else if vEndNodePtr = Node2 then
      vEndNodePtr := Node1;
   if vActiveNodePtr = Node1 then
      vActiveNodePtr := Node2
   else if vActiveNodePtr = Node2 then
      vActiveNodePtr := Node1;
   if (Node1^.vNextPtr = Node2) then  {nodes next to each other}
   begin
      TempNextPtr := Node2^.vNextPtr;
      {move Node2 into Node1's place}
      Node2^.vPrevPtr := Node1^.vPrevPtr;
      Node2^.vNextPtr := Node1;
      if Node2^.vPrevPtr <> nil then
         Node2^.vPrevPtr^.vNextPtr := Node2;
      if Node2^.vNextPtr <> nil then
         Node2^.vNextPtr^.vPrevPtr := Node2;
      {move Node1 into Node2's place}
      Node1^.vPrevPtr := Node2;
      Node1^.vNextPtr := TempNextPtr;
      if Node1^.vNextPtr <> nil then
         Node1^.vNextPtr^.vPrevPtr := Node1;
   end
   else
      if (Node1^.vPrevPtr = Node2) then  {nodes next to each other}
      begin
         TempPrevPtr := Node2^.vPrevPtr;
         {move Node2 into Node1's place}
         Node2^.vPrevPtr := Node1;
         Node2^.vNextPtr := Node1^.vNextPtr;
         if Node2^.vNextPtr <> nil then
            Node2^.vNextPtr^.vPrevPtr := Node2;
         {move Node1 into Node2's place}
         Node1^.vPrevPtr := TempPrevPtr;
         Node1^.vNextPtr := Node2;
         if Node1^.vPrevPtr <> nil then
            Node1^.vPrevPtr^.vNextPtr := Node1;
      end
      else  {the nodes are not adjacent to each other}
      begin
         TempPrevPtr := Node2^.vPrevPtr;
         TempNextPtr := Node2^.vNextPtr;
         {move Node2 into Node1's place}
         Node2^.vPrevPtr := Node1^.vPrevPtr;
         Node2^.vNextPtr := Node1^.vNextPtr;
         if Node2^.vPrevPtr <> nil then
            Node2^.vPrevPtr^.vNextPtr := Node2;
         if Node2^.vNextPtr <> nil then
            Node2^.vNextPtr^.vPrevPtr := Node2;
         {move Node1 into Node2's place}
         Node1^.vPrevPtr := TempPrevPtr;
         Node1^.vNextPtr := TempNextPtr;
         if Node1^.vPrevPtr <> nil then
            Node1^.vPrevPtr^.vNextPtr := Node1;
         if Node1^.vNextPtr <> nil then
            Node1^.vNextPtr^.vPrevPtr := Node1;
      end;
end; {DLLOBJ.SwapNodes}
*)

procedure DLLOBJ.SwapNodes(Node1,Node2:DLLNodePtr);
{}
var 
  Ptr1: pointer;
  Size1,Size2: longint;
  Status1: byte;
  Ecode: integer;
begin
   Status1 := Node1^.GetStatusByte;
   Node1^.SetStatusByte(Node2^.GetStatusByte);
   Node2^.SetStatusByte(Status1);
   Size1 := GetNodeDataSize(Node1);
   if Size1 > 0 then
   begin
      getmem(Ptr1,size1);
      GetNodeData(Node1,Ptr1^);
   end;
   Size2 := GetNodeDataSize(Node2);
   Ecode := Change(Node1,Node2^.vDataPtr^,Size2);
   Ecode := Change(Node2,Ptr1^,Size1);
   if Size1 > 0 then
      freemem(Ptr1,Size1);
end; {DLLOBJ.SwapNodes}

procedure DLLOBJ.DelNode(Node: DLLNodePtr);
{}
begin
   if Node <> nil then  {1.00b}
   begin
      if vActiveNodePtr = Node then   {move active ptr to next entry in list}
      begin
         if vActiveNodePtr^.vNextPtr = nil then
         begin
            dec(vActiveNodeNumber);
            vActiveNodePtr := vActiveNodePtr^.vPrevPtr;
         end
         else
            vActiveNodePtr := vActiveNodePtr^.vNextPtr;
      end;
      if Node = vStartNodePtr then
      begin
         if Node^.vNextPtr = nil then {only node in list}
         begin
            Node^.FreeData;
            Freemem(vStartNodePtr,sizeof(vStartNodePtr^));
            vStartNodePtr := nil;
            vEndNodePtr := nil;
         end
         else
         begin
            vStartNodePtr := vStartNodePtr^.vNextPtr;
            vStartNodePtr^.vPrevPtr := nil;
            Node^.FreeData;
            Freemem(Node,sizeof(Node^));
         end;
      end
      else
      begin
         Node^.vPrevPtr^.vNextPtr := Node^.vNextPtr;
         if Node = vEndNodePtr then
            vEndNodePtr := vEndNodePtr^.vPrevPtr
         else
            Node^.vNextPtr^.vPrevPtr := Node^.vPrevPtr;
         Node^.FreeData;
         Freemem(Node,sizeof(Node^));
      end;
      dec(vTotalNodes);
      vSorted := false;  {1.00d}
   end;
end; {DLLOBJ.DelNode}

procedure DLLOBJ.DelAllStatus(BitPos:byte;On:boolean);
{}
var
  TempPtr,TempNextPtr: DLLNodePtr;
begin
   if vStartNodePtr <> nil then
   begin
      TempPtr := vStartNodePtr;
      TempNextPtr := TempPtr^.NextPtr;
      while TempNextPtr <> nil do
      begin
         if TempNextPtr^.GetStatus(BitPos) = On then
            DelNode(TempNextPtr)
         else
            TempPtr := TempPtr^.NextPtr;
            TempNextPtr := TempPtr^.NextPtr;
      end;
       if vStartNodePtr^.GetStatus(BitPos) = On then
            DelNode(vStartNodePtr);
      vSorted := false;  {1.00d}
   end;
end; {DLLOBJ.DelAllStatus}

function DLLOBJ.WrongOrder(Node1,Node2:DLLNodePtr;Asc:boolean):boolean;
{abstract}
begin
   WrongOrder := false;
end; {DLLOBJ.WrongOrder}

procedure DLLOBJ.Sort(SortID:shortint;Ascending:boolean);
{Shell sort}
var
   I,J,Delta : longint;
   Swapped : boolean;
   Ptr1,Ptr2 : DLLNodePtr;
begin
   if ((vSortID <> SortID) or (vSortAscending <> Ascending) or (vSorted = false))
   and (vTotalNodes >= 2) then
   begin
      vSortID := SortID;
      vSortAscending := Ascending;
      Delta := vTotalNodes div 2;
      repeat
         Repeat
            Swapped := false;
            Ptr1 := vStartNodePtr;
            Ptr2 := Ptr1;
            for I := 1 to Delta do
              Ptr2 := Ptr2^.vNextPtr;
            for I := 1 to vTotalNodes - Delta do
            begin
              if I > 1 then
              begin
                 Ptr1 := Ptr1^.vNextPtr;
                 Ptr2 := Ptr2^.vNextPtr;
              end;
              if WrongOrder(Ptr1,Ptr2,vSortAscending) then
              begin
                 SwapNodes(Ptr1,Ptr2);
                 Swapped := true;
              end;
            end;
         Until (not Swapped);
         Delta := Delta div 2;
      Until Delta = 0;
   end;
   vSorted := true;
end; {DLLOBJ.Sort}

procedure DLLOBJ.EmptyList;
{removes all the memory allocated on the heap by chaining back
 through the list and disposing of each node.}
var TempPtr: DLLNodePtr;
begin
   TempPtr := vEndNodePtr;
   if vEndNodePtr <> nil then
   while TempPtr^.vPrevPtr <> nil do
   begin
      TempPtr^.FreeData;
      TempPtr := TempPtr^.vPrevPtr;
      Freemem(TempPtr^.vNextPtr,sizeof(TempPtr^));
   end;
   if vStartNodePtr <> Nil then
   begin
      vStartNodePtr^.FreeData;
      Freemem(vStartNodePtr,sizeof(vStartNodePtr^));
      vStartNodePtr := Nil;
   end;
   vEndNodePtr := nil;
   vActiveNodePtr := nil;
   vTotalNodes := 0;
   vActiveNodeNumber := 0;
   vSorted := false;  {1.00d}
end; {DLLOBJ.EmptyList}

destructor DLLOBJ.Done;
{}
begin
   EmptyList;
end; {of dest DLLOBJ.Done}

{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     S t r D L L O b j   M E T H O D S     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}

{The StrDLLOBJ object is a descendant of the DLLOBJ object, and
 it is designed to specifically manipulate strings}

constructor StrDLLOBJ.Init;
{}
begin
   DLLOBJ.Init;
end; {StrDLLOBJ.Init}

function StrDLLOBJ.Add(Str: string): integer;
{}
var
  Len : byte;
begin
   Len := Length(Str);
   Add := DLLOBJ.Add(Str[1],Len);
end; {StrDLLOBJ.Add}

function StrDLLOBJ.GetStr(Node:DLLNodePtr;Start,Finish:longint): String;
{}
begin
   GetStr := DLLOBJ.GetStr(Node,Start,Finish);
end; {StrDLLOBJ.GetStr}

function StrDLLOBJ.Change(Node:DLLNodePtr;Str: string): integer;
{}
var
  Len:byte;
begin
   Len := length(Str);
   Change := DLLOBJ.Change(Node,Str[1],Len);
end; {StrDLLOBJ.Change}

function StrDLLOBJ.InsertBefore(Node:DLLNodePtr;Str:string): integer;
{}
var
  Len:byte;
begin
   Len := length(Str);
   InsertBefore := DLLOBJ.InsertBefore(Node,Str[1],Len);
end; {StrDLLOBJ.InsertBefore}
 
function StrDLLOBJ.WrongOrder(Node1,Node2:DLLNodePtr;Asc:boolean): boolean;
{}
var S1,S2: string;
begin
(*
   if Asc then
   begin
      GetNodeData(Node1,S1);
      GetNodeData(Node2,S2);
   end
   else
   begin
      GetNodeData(Node1,S2);
      GetNodeData(Node2,S1);
   end;
*)
   if Asc then
   begin
      S1 := GetStr(Node1,1,255);
      S2 := GetStr(Node2,1,255);
   end
   else
   begin
      S1 := GetStr(Node2,1,255);
      S2 := GetStr(Node1,1,255);
   end;
   WrongOrder := (S1 > S2);
end; {StrDLLOBJ.WrongOrder}

destructor StrDLLOBJ.Done;
{}
begin
   DLLOBJ.Done;
end; {StrDLLOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||}
{                                             }
{     F i l e D L L O b j   M E T H O D S     }
{                                             }
{|||||||||||||||||||||||||||||||||||||||||||||}
constructor FileDLLOBJ.Init;
{}
begin
   DLLOBJ.Init;
   vFileMasks := '*.*';
   vFileAttrib := archive + readonly;
end; {FileDLLOBJ.Init}

function FileDLLOBJ.GetStr(Node:DLLNodePtr;Start,Finish: longint):string; 
{ignores Start and Finish parameters - first 13 bytes of the Data is
 the filename.}
var temp : string;
begin
   if (Node = Nil)
   or (Node^.vDataPtr = Nil)
   or (Node^.vSize = 0)  then
      GetStr := ''
   else
   begin
      Move(mem[seg(Node^.vDataPtr^):ofs(Node^.vDataPtr^)],Temp[0],13);
      GetStr := Temp;
   end;
end; {FileDLLOBJ.GetStr}

function FileDLLOBJ.GetLongStr(Node:DLLNodePtr):string;
{}
var Info: tFileInfo;
begin
   if (Node = Nil)
   or (Node^.vDataPtr = Nil)
   or (Node^.vSize = 0)  then
      GetLongStr := ''
   else
   begin
      Move(mem[seg(Node^.vDataPtr^):ofs(Node^.vDataPtr^)],Info,sizeof(Info));
      if Info.FileName = NoFiles then
         GetLongStr := 'No matching files found'
      else
         GetLongStr := LongName(Info);
   end;
end; {FileDLLOBJ.GetLongStr}

procedure FileDLLOBJ.GetFileRecord(var FileInfo:tFileInfo; Item:longint);
{}
var
   Node:DLLNodePtr;
begin
   Node := NodePtr(Item);
   if (Node = Nil)
   or (Node^.vDataPtr = Nil)
   or (Node^.vSize = 0)  then
      FileInfo.FileName := ''
   else
      Move(mem[seg(Node^.vDataPtr^):ofs(Node^.vDataPtr^)],FileInfo,sizeof(FileInfo));
end; {FileDLLOBJ.GetFileRecord}

function FileDLLOBJ.GetFileMask:string;
{}
begin
   GetFileMask := vFileMasks;
end; {FileDLLOBJ.GetFileMask}

procedure FileDLLOBJ.SetFileDetails(FileMasks:string; FileAttrib: word);
{}
begin
   if FileMasks = '' then
      FileMasks := '*.*';
   vFileMasks := FileMasks;
   vFileAttrib := FileAttrib;
end; {FileDLLOBJ.SetFileDetails}

procedure FileDLLOBJ.FillList;
{}
var
  FileDetails: SearchRec;
  FileInfo: tFileInfo;
  TotMasks: byte;
  Mask: string;
  RecSize: byte;
  ECode : integer;

  procedure SaveFileDetails(IsDir:boolean);
  begin
     if FileDetails.Name <> '.' then
     begin
        with FileInfo do
        begin
            FileName := FileDetails.Name;
            Attr := FileDetails.Attr;
            Time := FileDetails.Time;
            Size := FileDetails.Size;
            LoadID := succ(vTotalNodes);
        end;  {with}
        Ecode := Add(FileInfo,RecSize);
        if Ecode = 0 then
          vActiveNodePtr^.SetStatus(1,IsDir);
     end;
  end; {SaveFileDetails}

  procedure ProcessFiles(Attrib:word);
  {}
  var I : integer;
  begin
     for I := 1 to TotMasks do
     begin
        if Attrib = Directory then   {1.00c}
           Mask := '*.*'
        else
           Mask := ExtractWords(I,1,vFileMasks);
        FindFirst(Mask,Attrib,FileDetails);
        while DOSError = 0 do
        begin
           if (Attrib <> Directory) then
              SaveFileDetails(false)
           else if ((Attrib = Directory) and (FileDetails.Attr = Directory)) then
              SaveFileDetails(true);
           FindNext(FileDetails);
        end;
        if Attrib = Directory then   {1.00c}
           exit;
     end;
  end; {ProcessFiles}

begin
   RecSize := sizeof(FileInfo);
   if vStartNodePtr <> Nil then
      EmptyList;
   TotMasks := WordCnt(vFilemasks);
   if ((vFileAttrib and Directory) = Directory) then
   begin
      ProcessFiles(Directory);
      if vFileAttrib <> Directory then {1.00a}
         ProcessFiles(vFileAttrib and (Anyfile-Directory-VolumeID));
   end
   else
      ProcessFiles(vFileAttrib);
   if vTotalNodes = 0 then
   begin
      FileInfo.Filename := NoFiles;
      FileInfo.Time := 0;
      Ecode := Add(FileInfo,RecSize);
   end;
   vSorted := (vSortID = 0) and (vSortAscending = true);
end; {FileDLLOBJ.FillList}

procedure FileDLLOBJ.FillNewMask(FileMasks:string);
{}
begin
   SetFileDetails(FileMasks,vFileAttrib);
   FillList;
end; {FileDLLOBJ.FillNewMask}

function FileDLLOBJ.WrongOrder(Node1,Node2:DLLNodePtr;Asc:boolean): boolean;
{}
var F1,F2: tFileInfo;
    P: integer;
    Name1,Name2: string[8];
    Ext1,Ext2: string[3];

    function Name(F:tFileInfo):string;
    {}
    begin
       P := pos('.',F.FileName);
       if P = 0 then
          Name := F.FileName
       else
          Name := copy(F.FileName,1,pred(P));
    end;{Name}

    function Ext(F:tFileInfo):string;
    {}
    begin
       P:= pos('.',F.FileName);
       if P = 0 then
          Ext := ''
       else
          Ext := copy(F.FileName,succ(P),3);
    end; {Ext}

begin
   fillchar(F1,sizeof(F1),#0);
   fillchar(F2,sizeof(F2),#0);
   if Asc then
   begin
      GetNodeData(Node1,F1);
      GetNodeData(Node2,F2);
   end
   else
   begin
      GetNodeData(Node1,F2);
      GetNodeData(Node2,F1);
   end;
   case vSortID of
      0: WrongOrder := (F1.LoadID > F2.LoadID);  {DOS}
      1: begin                                    {NAME}
            Name1 := Name(F1);
            Name2 := Name(F2);
            if (Name1 = Name2) then
               WrongOrder := (Ext(F1) > Ext(F2))
            else
               WrongOrder := (Name1 > Name2);
      end;
      2: begin                                    {EXT}
            Ext1 := Ext(F1);
            Ext2 := Ext(F2);
            if Ext1 = Ext2 then
               WrongOrder := (Name(F1) > Name(F2))
            else
               WrongOrder := (Ext1 > Ext2);
      end;
      3: WrongOrder := (F1.Size > F2.Size);      {SIZE}
      4: WrongOrder := (F1.Time > F2.Time);      {TIME}
      else WrongOrder := false;
   end; {case}
end; {FileDLLOBJ.WrongOrder}

procedure FileDLLOBJ.SwapNodes(Node1,Node2:DLLNodePtr);
{}
var 
  FileInfo: tFileInfo;
  Size: longint;
  Status1: byte;
begin
   Status1 := Node1^.GetStatusByte;
   Node1^.SetStatusByte(Node2^.GetStatusByte);
   Node2^.SetStatusByte(Status1);
   GetNodeData(Node1,FileInfo);
   Size := sizeof(FileInfo);
   Move(Node2^.vDataPtr^,Node1^.vDataPtr^,size);
   Move(FileInfo,Node2^.vDataPtr^,size);
end; {FileDLLOBJ.SwapNodes}

destructor FileDLLOBJ.Done;
{}
begin
   DLLOBJ.Done;
end; {FileDLLOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure LinkInit;
{initilizes objects and global variables}
begin
end;

{end of unit}
{$ifNDEF OVERLAY}
begin
   LINKInit;
{$ENDif}
end.
