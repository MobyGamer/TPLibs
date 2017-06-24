Unit ExtLINK;
{Illustrates how you can extend the Toolkit DLLOBJ to provide
 a list for records}

{$I TOTFLAGS.INC}
INTERFACE
Uses DOS,CRT,
     totINPUT, totFAST, totSTR, totDATE, totIO2, totLINK, totLIST;

TYPE
RecordInfo = record
   FirstName: string[15];
   LastName: string[15];
   Company: string[20];
   Tel: string[10];
   CumDollarsSpent: real;
   LastOrder: longint;
   Comments: string[40];
end;

RecordDLLOBJ = object (DLLOBJ)
   constructor Init;
   function    Add(Rec:RecordInfo): integer;
   function    Change(Node:DLLNodePtr;Rec:RecordInfo): integer;
   function    InsertBefore(Node:DLLNodePtr;Rec:RecordInfo): integer;
   function    WrongOrder(Node1,Node2:DLLNodePtr;Asc:boolean): boolean; VIRTUAL;
   function    GetStr(Node:DLLNodePtr;Start,Finish: longint):string;    VIRTUAL;
   destructor  Done; 
end; {RecordDLLOBJ}

IMPLEMENTATION

{\\\\\\\\\\\\\\ RecordDLLOBJ METHODS \\\\\\\\\\\\\\\\\\\\}

constructor RecordDLLOBJ.Init;
{}
begin
   DLLOBJ.Init;
end; {RecordDLLOBJ.Init}

function RecordDLLOBJ.Add(Rec:RecordInfo): integer;
{}
begin
   Add := DLLOBJ.Add(Rec,sizeof(Rec));
end; {RecordDLLOBJ.Add}

function RecordDLLOBJ.Change(Node:DLLNodePtr;Rec:RecordInfo): integer;
{}
begin
   Change := DLLOBJ.Change(Node,Rec,sizeof(Rec));
end; {RecordDLLOBJ.Change}

function RecordDLLOBJ.InsertBefore(Node:DLLNodePtr;Rec:RecordInfo): integer;
{}
begin
   InsertBefore := DLLOBJ.InsertBefore(Node,Rec,sizeof(Rec));
end; {RecordDLLOBJ.InsertBefore}

function RecordDLLOBJ.WrongOrder(Node1,Node2:DLLNodePtr;Asc:boolean): boolean;
{This is called by the DLLOBJ sort routine to see if two items are in the
 correct order. You must check vSortID to determine which element of the 
 record to sort on.}
var
  S1,S2: string;
  Rec1,Rec2: RecordInfo;
  R1,R2: real;
  D1,D2: longint;
begin
   GetNodeData(Node1,Rec1);
   GetNodeData(Node2,Rec2);
   if vSortID in [1,2,3] then
   begin
      case vSortID of
         1:begin      {LastName}
            S1 := Rec1.LastName;
            S2 := Rec2.LastName;
         end;
         2: begin     {Company}
            S1 := Rec1.Company;
            S2 := Rec2.Company;
         end;
         3: begin     {Tel}
            S1 := Rec1.Tel;
            S2 := Rec2.Tel;
         end;
      end; {case}
      if Asc then
         WrongOrder := (S1 > S2)
      else
         WrongOrder := (S2 > S1);
   end
   else if vSortID = 4 then  {CumDollars}
   begin
      R1 := Rec1.CumDollarsSpent;
      R2 := Rec2.CumDollarsSpent;
      if Asc then
         WrongOrder := (R1 > R2)
      else
         WrongOrder := (R2 > R1);
   end
   else  {LastOrder}
   begin
      D1 := Rec1.LastOrder;
      D2 := Rec2.LastOrder;
      if Asc then
         WrongOrder := (D1 > D2)
      else
         WrongOrder := (D2 > D1);
   end;
end; {RecordDLLOBJ.WrongOrder}

function RecordDLLOBJ.GetStr(Node:DLLNodePtr;Start,Finish: longint):string;   
{Returns string representation of record}
var 
  Temp: string;
  Rec: RecordInfo;
begin
   if Node = nil then
      GetStr := 'Not found'
   else
   begin
      GetNodeData(Node,Rec);  {inherited method}
      with Rec do
      begin
         Temp := inttostr(ActiveNodeNumber)+': '+
                 FirstName+
                 LastName+
                 Company;
         if Finish > 53 then
            Temp := Temp + PicFormat(Tel,'(###) ###-####',' ')+' ';
         if Finish > 68 then
            Temp := Temp + JultoStr(LastOrder,MMDDYY)+' ';
         if Finish > 77 then
            Temp := Temp + FmtNumberTOT.FormattedReal(CumDollarsSpent,2,10)+' ';
         if Finish > 88 then
            Temp := Temp + Comments;
       end;
       GetStr := copy(Temp,Start,succ(Finish-start));
    end;
end; {RecordDLLOBJ.GetStr}

destructor RecordDLLOBJ.Done; 
{}
begin
   DLLOBJ.Done;
end; {RecordDLLOBJ.Done}

end.