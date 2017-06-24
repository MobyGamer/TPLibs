{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.01                             }

{                     Adds DropListIOOBJ  Objects                      }

Unit ExtIO3;
{$I TOTFLAGS.INC}
{
 Development Notes:   6/23/92  1.01  Overhauled input routines to
                                     function in a WinFormOBJ, and
                                     to handle the Esc key.
}

INTERFACE

uses DOS, CRT, 
     totFAST, totWIN, totIO1, totIO2, totSTR, totInput, totLINK;

TYPE

DropListIOOBJ = object (ListIOOBJ)
   vWin: pWinOBJ;
   vLastPick: word;
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte);
   procedure   Drop;
   procedure   MonoDraw(Attr:byte);
   function    Select(K:word; X,Y:byte):TAction;            VIRTUAL;
   function    OnTarget(X,Y: byte):boolean;                 VIRTUAL;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;     VIRTUAL;
   procedure   Display(Status:tStatus);                     VIRTUAL;
   function    Suspend:boolean;                             VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {DropListIOOBJ}

pDropArrayIOOBJ = ^DropArrayIOOBJ;
DropArrayIOOBJ = object (DropListIOOBJ)
   vArrayPtr: pointer;
   vStrLength: byte;
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte);
   procedure   AssignList(var StrArray; Total:Longint; StrLength:byte);
   function    GetString(Pick:integer): string;             VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {DropArrayIOOBJ}

pDropLinkIOOBJ = ^DropLinkIOOBJ;
DropLinkIOOBJ = object (DropListIOOBJ)
   vLinkList: ^DLLOBJ;
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte);
   procedure   AssignList(var LinkList: DLLOBJ);
   function    GetString(Pick:integer): string;             VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {DropLinkIOOBJ}


IMPLEMENTATION
constructor DropListIOOBJ.Init(X1,Y1,width,depth:byte);
{}
begin
   ListIOOBJ.Init(X1,Y1,width,depth,'');
   vWin := nil;
end; {DropListIOOBJ.Init}

function DropListIOOBJ.OnTarget(X,Y: byte):boolean;
{}
begin
   with vBoundary do
   if vWin = nil then
      OnTarget := (Y = Y1) and ListIOOBJ.OnTarget(X,Y)
   else
      Ontarget := (X >= pred(X1)) and (X <= succ(X2)) and (Y >= pred(Y1)) and (Y <= succ(Y2));
end; {DropListIOOBJ.OnTarget}

function DropListIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;  
{}
begin
   ProcessKey := None;
   if vWin = nil then {window not down}
   begin
      case InKey of
         336: Drop;
         513,523: if (Y = vBoundary.Y1) 
         and ((X >= vBoundary.X2-2) and (X <= vBoundary.X2)) then
            Drop;
         328,331: if pred(vTopPick)+vActivePick > 1 then
         begin
            if vTopPick > 1 then
               dec(vTopPick)
            else
               dec(vActivePick);
            MonoDraw(IOTOT^.FieldCol(2));
         end;
         32,333: if pred(vTopPick)+vActivePick < vTotPicks then
         begin
            if vActivePick < vRows then
               inc(vActivePick)
            else
               inc(vTopPick);
            MonoDraw(IOTOT^.FieldCol(2));
         end;
      end; {case}
   end;
(*
   else
   begin
      if  (((InKey = 513) or (Inkey = 523)) 
           and (Y = pred(vBoundary.Y1))
           and (X = vBoundary.X1+2))
      or  (InKey = 13)
      then
      begin
         dispose(vWin,Done);
         vWin := nil;
         MonoDraw(IOTOT^.FieldCol(2));
      end
      else
         Processkey := ListIOOBJ.ProcessKey(InKey,X,Y);
   end;
*)
end; {DropListIOOBJ.ProcessKey}

procedure DropListIOOBJ.Drop;
{}
var
   DK,DX,DY:word;
   Finished:boolean;
   Temp: TAction;

    procedure RemoveDropListWin;
    {}
    begin
       dispose(vWin,Done);
       vWin := nil;
       MonoDraw(IOTOT^.FieldCol(2));
    end;

begin
   new(vWin,Init);
   with vBoundary do
   with vWin^ do
   begin
      SetSize(pred(X1),pred(Y1),succ(X2),succ(Y2),1);
      SetWinRestrict(false);
      SetColors(IOTOT^.FieldCol(1),0,0,IOTOT^.FieldCol(1));
      Draw;
      ListIOOBJ.Display(HiStatus);
   end;
   {now process all keystrokes locally until user clicks
    away from the list}
   Finished := false;
   vLastPick := vActivePick;
   delay(250);
   repeat
      Key.GetInput;
      DK := Key.LastKey;
      DX := Key.LastX;
      DY := Key.LastY;
      if  (((DK = 513) or (DK = 523))
          and (DY = pred(vBoundary.Y1))
          and (DX = vBoundary.X1+2))
      or  (DK = 13)
      then
      begin
         RemoveDropListWin;
         Finished := true;
      end
      else if (DK = 27) then
      begin
         vActivePick := vLastPick;
         RemoveDropListWin;
         Finished := true;
      end
      else if ((DK = 513) or (DK = 523))
           and (
                    (DY < pred(vBoundary.Y1))
                 or (DY > succ(vBoundary.Y2))
                 or (DX < pred(vBoundary.X1))
                 or (DX > succ(vBoundary.X2))
              )
      then
      begin
         vActivePick := vLastPick;
         RemoveDropListWin;
         Finished := true;
         (*
         Key.StuffBuffer(DK);
         *)
      end
      else
         Temp := ListIOOBJ.ProcessKey(DK,DX,DY);
   until Finished;
end; {DropListIOOBJ.Drop}

function DropListIOOBJ.Select(K:word; X,Y:byte):TAction;
{}
begin
   vScrollBarOn := (vTotPicks >= vRows);
   vActiveField := true;
   Display(HiStatus);
   WriteLabel(HiStatus);
   WriteMessage;
   if ((K = 513) or (K=523)) 
   and (Y = vBoundary.Y1) 
   and ((X >= vBoundary.X2-2) and (X <= vBoundary.X2)) then {landed on down arrow}
      Drop;
   Select := none;
end; {DropListIOOBJ.Select}

procedure DropListIOOBJ.MonoDraw(Attr:byte);
{}
var Str :string;
begin
   if vListAssigned then
      with vBoundary do
      begin
         Str := padleft(GetString(GetValue),X2-X1-2,' ');
         Screen.WriteAt(X1,Y1,Attr,Str);
         GotoXY(X1,Y1);
      end;
end; {DropListIOOBJ.MonoDraw}

procedure DropListIOOBJ.Display(Status:tStatus);                  
{}
var
  Attr: byte;
  BackAttr: byte;
begin
   if vWin = nil then
   begin
      if vListAssigned then
      begin
         case Status of
         HiStatus:    Attr := IOTOT^.FieldCol(2);
         Norm:  Attr := IOTOT^.FieldCol(1);
         Off:   Attr := IOTOT^.FieldCol(4);
         end; {case}
         with vBoundary do
         begin
            MonoDraw(Attr);
            BackAttr := BAttr(Screen.ReadAttr(X2-2,Y1));
            Screen.WriteAt(X2-2,Y1,Cattr(BAttr(Attr),Backattr),'Þ Ý');
            Screen.WriteAt(pred(X2),Y1,Attr,'');
         end;
      end;
   end
   else
      ListIOOBJ.Display(Status);
end; {DropListIOOBJ.Display}

function DropListIOOBJ.Suspend:boolean;                          
{}
begin
   if vWin <> nil then
   begin
      dispose(vWin,Done);
      vWin := nil;
   end;
   Display(Norm);
   Suspend := ListIOOBJ.Suspend;
end; {DropListIOOBJ.Suspend}

destructor DropListIOOBJ.Done;                                     
{}
begin
   ListIOOBJ.Done;
end; {DropListIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                    }
{     D r o p A r r a y I O O B J   M E T H O D S    }
{                                                    }
{||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor DropArrayIOOBJ.Init(X1,Y1,width,depth:byte);
{}
begin
   DropListIOOBJ.Init(X1,Y1,width,depth);
end; {DropArrayIOOBJ.Init}

procedure DropArrayIOOBJ.AssignList(var StrArray; Total:Longint; StrLength:byte);
{}
begin
   vArrayPtr := @StrArray;
   vStrLength := StrLength;
   vTotPicks := Total;
   vListAssigned := true;
end; {DropArrayIOOBJ.AssignList}

function DropArrayIOOBJ.GetString(Pick:integer): string;
{}
var
  W : word;
  TempStr : String;
  ArrayOffset: word;
begin
   if (Pick > 0) and (Pick <= vTotPicks) then
   begin
      W := pred(Pick) * succ(vStrLength);
      ArrayOffset := Ofs(vArrayPtr^) + W;
      Move(Mem[Seg(vArrayPtr^):ArrayOffset],TempStr,1);
      Move(Mem[Seg(vArrayPtr^):succ(ArrayOffset)],TempStr[1],ord(TempStr[0]));
   end
   else
      TempStr := '';
   W := vBorder.X2 - succ(vBorder.X1);
   GetString := Padleft(TempStr,W,' ');
end; {DropArrayIOOBJ.GetString}

destructor DropArrayIOOBJ.Done;
{}
begin
   DropListIOOBJ.Done;
end; {DropArrayIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                  }
{     D r o p L i s t I O O B J   M E T H O D S    }
{                                                  }
{||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor DropLinkIOOBJ.Init(X1,Y1,width,depth:byte);
{}
begin
   DropListIOOBJ.Init(X1,Y1,width,depth);
end; {DropLinkIOOBJ.Init}

procedure DropLinkIOOBJ.AssignList(var LinkList: DLLOBJ);
{}
begin
   vLinkList := @LinkList;
   vTotPicks := LinkList.TotalNodes;
   vListAssigned := true;
end;  {DropLinkIOOBJ.AssignList}

function DropLinkIOOBJ.GetString(Pick:integer): string;
{}
var
  TempPtr : DLLNodePtr;
begin
   TempPtr := vLinkList^.NodePtr(Pick);
   if TempPtr <> Nil then
      vLinkList^.ShiftActiveNode(TempPtr,Pick);
   GetString := vLinkList^.GetStr(TempPtr,1,vBorder.X2 - vBorder.X1);
end; {DropLinkIOOBJ.GetString}

destructor DropLinkIOOBJ.Done;
{}
begin
   DropListIOOBJ.Done;
end; {DropLinkIOOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
{$ENDIF}
end.