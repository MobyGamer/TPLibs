{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{File TOTIO2.INC}


{||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                }
{     L i s t F i e l d O B J   M E T H O D S    }
{                                                }
{||||||||||||||||||||||||||||||||||||||||||||||||}

constructor ListIOOBJ.Init(X1,Y1,width,depth:byte;Title:string);
{}
begin
   MultiLineIOOBJ.Init(X1,Y1,width,depth,Title);
   vTopPick := 1;
   vTotPicks := 0;
   vActivePick := 1;
   vListAssigned := false;
   vScrollBarOn := false;
   vActiveField := false;
end; {ListIOOBJ.Init}

procedure ListIOOBJ.SetValue(Hi:integer); {1.00b}
{}
begin
   if (Hi > 0) and (Hi <= vTotPicks) then
   begin
      if Hi - pred(vTopPick) <= vRows then
         vActivepick := Hi - pred(vTopPick)
      else
      begin
         if vRows > 1 then
         begin
            vActivePick := vRows div 2;
            vTopPick := succ(Hi - vActivePick);
         end
         else
         begin
            vActivePick := 1;
            vTopPick := Hi;
         end;
      end;
   end;
end; {ListIOOBJ.SetValue}

function ListIOOBJ.Select(K:word; X,Y:byte):TAction;
{}
var New: byte;
begin
   vScrollBarOn := (vTotPicks >= vRows);
   vActiveField := true;
   Display(HiStatus);
   WriteLabel(HiStatus);
   WriteMessage;
   if (K = 513) or (K=523) then
   begin
      if vScrollBarOn and (X = vBorder.X2) then
        {nothing for now}
      else
      begin
         New := HitItem(Y);
         if New > 0 then
         begin
            WriteItem(vActivePick,false);
            vActivePick := New;
            WriteItem(vActivePick,true);
         end;
      end;
   end;
   Select := none;
end; {ListIOOBJ.Select}

procedure ListIOOBJ.WriteItem(Item:integer; Selected:boolean);
{}
var
  Str: string;
  High,Nor: byte;
  Status: tStatus;
begin
   if vListAssigned then
   begin
      Str := GetString(pred(vTopPick)+Item);
      if Selected then
         Status := HiStatus
      else
         Status := Norm;
      AssignColors(IOTOT^.vList,IOTOT^.vField,Status,High,Nor);
      if (vActiveField = false) and Selected then
         Nor := IOTOT^.ListCol(2);
      Screen.WriteHi(vBorder.X1,vBorder.Y1+pred(Item),High,Nor,
                     padleft(Str,vBorder.X2-vBorder.X1,' '));
      if Selected and vActiveField then   {1.00e}
         Screen.GotoXY(vBorder.X1,vBorder.Y1+pred(Item));
      if item = vActivePick then
         ShowItemDetails(pred(vTopPick)+Item);
   end;
end; {ListIOOBJ.WriteItem}

procedure ListIOOBJ.DisplayAllPicks;
{}
var I : integer;
begin
   for I := 1 to vRows do
       WriteItem(I,(I=vActivePick));
end; {ListIOOBJ.DisplayAllPicks}

procedure ListIOOBJ.RefreshScrollBar;
{}
var High,Nor:byte;
begin
   AssignColors(IOTOT^.vList,IOTOT^.vField,Norm,High,Nor);
   with vBorder do
   if vScrollBarOn then
      Screen.WriteVScrollBar(X2,Y1,Y2,Nor,pred(vTopPick+vActivePick),vTotPicks)
   else
      Screen.WriteVert(X2,Y1,Nor,replicate(succ(Y2-Y1),' '));
end; {ListIOOBJ.RefreshScrollBar}

function ListIOOBJ.HitItem(Y:byte):byte;
{returns the row number of the item falling on line Y, else returns 0}
var
  B: integer;
begin
    B := Y - pred(vBorder.Y1);
    if (B > vRows) or (B < 0) or (B+pred(vTopPick)>vTotPicks) then
       HitItem := 0
    else
       HitItem := B;
end; {ListIOOBJ.HitItem}

procedure ListIOOBJ.ScrollJump(Y:byte);
{}
var
  Tot: integer;
begin
   Tot := vBorder.Y2 - succ(vBorder.Y1);
   Y := Y - vBorder.Y1;
   if vTopPick + Y <= vTotPicks then
   begin
      if vTotPicks <= vRows then
      begin
         WriteItem(vActivePick,false);
         vActivePick := (Y * vTotPicks) div Tot;
         WriteItem(vActivePick,true);
      end
      else
      begin
         vTopPick := (Y * vTotPicks) div Tot;
         vActivePick := 1;
         DisplayAllPicks;
      end;
   end;
end; {of proc ListIOOBJ.ScrollJump}

procedure ListIOOBJ.ScrollUp;
{}
begin
   if vActivePick = 1 then
   begin
      if vTopPick > 1 then
      begin
         dec(vTopPick);
         DisplayAllPicks;
      end;
   end
   else
   begin
      WriteItem(vActivePick,false);
      dec(vActivePick);
      WriteItem(vActivePick,True);
   end;
end; {of proc ListIOOBJ.ScrollUp}

procedure ListIOOBJ.ScrollDown;
{}
begin
   if pred(vTopPick) + vActivePick < vTotPicks then
   begin
      if vActivePick < vRows then
      begin
         WriteItem(vActivePick,false);
         inc(vActivePick);
         WriteItem(vActivePick,True);
      end
      else
      begin
         inc(vTopPick);
         DisplayAllPicks;
      end;
   end;
end; {of proc ListIOOBJ.ScrollDown}

procedure ListIOOBJ.ScrollPgUp;
{}
begin
   if vTopPick > 1 then
   begin
      vTopPick := vTopPick - vRows;
      if vTopPick < 1 then
         vTopPick := 1;
      DisplayAllPicks;
   end
   else if vActivePick <> 1 then
   begin
      WriteItem(vActivePick,false);
      vActivePick := 1;
      WriteItem(vActivePick,True);
   end;
end; {of proc ListIOOBJ.ScrollPgUp}

procedure ListIOOBJ.ScrollPgDn;
{}
begin
   if pred(vTopPick + vRows) < vTotPicks then
   begin
      vTopPick := vTopPick + vRows;
      vActivePick := 1;
      DisplayAllPicks;
   end
   else if vActivePick + pred(vTopPick) < vTotPicks then
   begin
      WriteItem(vActivePick,false);
      vActivePick := vTotPicks - pred(vTopPick);
      WriteItem(vActivePick,True);
   end;
end; {of proc ListIOOBJ.ScrollPgDn}

procedure ListIOOBJ.ScrollHome;
{}
begin
   if (vTopPick <> 1) or (vActivePick <> 1) then
   begin
      vTopPick := 1;
      vActivePick := 1;
      DisplayAllPicks;
   end;
end; {of proc ListIOOBJ.ScrollHome}

procedure ListIOOBJ.ScrollEnd;
{}
begin
   if vTopPick + pred(vRows) >= vTotPicks then {last node on display}
   begin
      WriteItem(vActivePick,False);
      vActivePick := succ(vTotPicks - vTopPick);
      WriteItem(vActivePick,True);
   end
   else
   begin
     vTopPick := vTotPicks - pred(vRows);
     vActivePick := vRows;
     DisplayAllPicks;
   end;
end; {of proc ListIOOBJ.ScrollEnd}

procedure ListIOOBJ.Display(Status:tStatus);
{}
var
  BorderCol : byte;
  Style: byte;
  I : integer;
begin
   MultiLineIOOBJ.Display(Status);
   for I := 1 to vRows do
(*
      WriteItem(I,((I=vActivePick) and (Status=HiStatus)));
*)
      WriteItem(I,(I=vActivePick));

   if Status <> HiStatus then
      vScrollBarOn := false;
   RefreshScrollBar;
end; {ListIOOBJ.Display}

procedure ListIOOBJ.AdjustMouseKey(var InKey: word;X,Y:byte);
{}
begin
   if (X = vBorder.X2) and (vScrollBarOn) then {probably on scroll bar}
   begin
      if Y = vBorder.Y2 then
         InKey := 611
      else if Y = vBorder.Y1 then
         InKey := 610
      else if (Y > vBorder.Y1) and (Y < vBorder.Y2) then
         Inkey := 614;
   end;
end; {ListIOOBJ.AdjustMouseKey}

function ListIOOBJ.TargetPick(X,Y:byte): longint;
{}
var Pick:integer;
begin
   Pick := 0;
   if (X >= vBorder.X1) and (X <= vBorder.X2) then
   begin
      Pick := Y - pred(vBorder.Y1);
      if (Pick > 0)
      and (Pick <= vRows)
      and (Pick + pred(vTopPick) <= vTotPicks) then
         {OK}
      else
         Pick := 0;
   end;
   TargetPick := Pick;
end; {ListIOOBJ.TargetPick}

procedure ListIOOBJ.MouseChoose(X,Y:byte);
{}
var Pick:integer;
begin
   Pick := TargetPick(X,Y);
   if (Pick <> 0) and (Pick <> vActivePick) then
   begin
      WriteItem(vActivePick,false);
      vActivePick  := Pick;
      WriteItem(vActivePick,True);
   end;
end; {ListIOOBJ.MouseChoose}

function ListIOOBJ.SelectPick(InKey:word;X,Y:byte): tAction;
{Semi-abstract}
begin
   SelectPick := NextField;
end; {ListIOOBJ.SelectPick}

function ListIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;
{}
var
  NextAction: tAction;
begin
   NextAction := none;
   if InKey = 513 then
      AdjustMousekey(Inkey,X,Y);
   case InKey of
      610,
      328,584: ScrollUp; {1.00f}
      32,
      611,
      336,592: ScrollDown;
      513: MouseChoose(X,Y);
      337: ScrollPgDn;
      329: ScrollPgUp;
      335: ScrollEnd;
      327: ScrollHome;
      614: begin  {vertical scroll bar}
              if Y = succ(vBorder.Y1) then
                 ScrollHome
              else if Y = pred(vBorder.Y2) then
                 ScrollEnd
              else
                 ScrollJump(Y); {vertical scroll bar}
           end;
      13,
      523: NextAction := SelectPick(Inkey,X,Y);
   end; {case}
   RefreshScrollBar;
   ProcessKey := NextAction;
end; {ListIOOBJ.ProcessKey}

function ListIOOBJ.GetValue: integer;
{}
begin
   if vTotPicks > 0 then    {1.10a}
      GetValue := pred(vTopPick) + vActivePick
   else
      GetValue := 0;
end; {ListIOOBJ.GetValue}

function ListIOOBJ.Suspend:boolean;
{}
begin
   vScrollBarOn := false;
   vActiveField := false;
   Suspend := VisibleIOOBJ.Suspend;
end; {ListIOOBJ.Suspend}

procedure ListIOOBJ.ShowItemDetails(HiPick: integer);
{abstract}
begin end;
function ListIOOBJ.GetString(Pick:integer): string;
{abstract}
begin end;

destructor ListIOOBJ.Done;
{}
begin
   MultiLineIOOBJ.Done;
end; {ListIOOBJ.Done}

