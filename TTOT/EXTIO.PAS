{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.00                             }
{                        Adds a Boolean field                          }
Unit ExtIO;
{$I TOTFLAGS.INC}

{
 Development Notes:

}
INTERFACE

uses DOS, CRT, totFAST, totIO1, totSTR, totInput;

TYPE
BooleanIOOBJ = object (VisibleIOOBJ)
   OnString: StringBut;
   OffString: StringBut;
   vInput: boolean;
   {methods...}
   constructor Init(X,Y:byte; Yes,No:stringbut);
   function    GetValue: boolean;
   procedure   SetValue(On:boolean);
   procedure   Activate;
   procedure   Display(Status:tStatus);                  VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;         VIRTUAL;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;  VIRTUAL;
   function    Suspend:boolean;                          VIRTUAL;
   destructor  Done;                                     VIRTUAL;
end; {BooleanIOOBJ}

IMPLEMENTATION

constructor BooleanIOOBJ.Init(X,Y:byte; Yes,No:stringbut);
{}
var L:byte;
begin
   VisibleIOOBJ.Init;
   OnString := Yes;
   OffString := No;
   L := length(OnString);
   if L < length(OffString) then
      L := length(OffString);
   with vBoundary do
   begin
      X1 := X;
      X2 := X + pred(L);
      Y1 := Y;
      Y2 := Y;
   end;
   vInput := true;
end; {BooleanIOOBJ.Init}

function BooleanIOOBJ.GetValue: boolean;
{}
begin
   GetValue := vInput;
end; {BooleanIOOBJ.GetValue}

procedure BooleanIOOBJ.SetValue(On:boolean);
{}
begin
   vInput := On;
end; {BooleanIOOBJ.SetValue}

procedure BooleanIOOBJ.Display(Status:tStatus);                  
{}
var Att: byte;
begin
   case Status of
      HiStatus: Att := IOTOT^.FieldCol(2);
      Norm:     Att := IOTOT^.FieldCol(1);
      Off:      Att := IOTOT^.FieldCol(4);
   end; {case}
   with vBoundary do
      if vInput then
         Screen.WriteAT(X1,Y1,Att,padleft(OnString,succ(X2-X1),' '))
      else
         Screen.WriteAT(X1,Y1,Att,padleft(OffString,succ(X2-X1),' '));
end; {BooleanIOOBJ.Display}

function BooleanIOOBJ.Select(K:word; X,Y:byte):tAction;         
{}
begin
   Display(HiStatus);
   WriteLabel(HiStatus);
   WriteMessage;
   Screen.GotoXY(vBoundary.X1,vBoundary.Y1);
   Select := none;
end; {BooleanIOOBJ.Select}

function BooleanIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;  
{}
begin
   if (InKey = 513) 
   or (InKey = 32) 
   or (inKey = 328) 
   or (InKey = 336) then
   begin
      vInput := not vInput;
      Display(HiStatus);
   end;
   if InKey = 513 then {absorb mouse}
      delay(100);
   if (InKey = 13) then
      ProcessKey := Enter
   else
      ProcessKey := None;
end; {BooleanIOOBJ.ProcessKey}

procedure BooleanIOOBJ.Activate;
{}
var
   Action: tAction;
begin
   Action := Select(0,0,0);
   Display(HiStatus);
   WriteLabel(HiStatus);
   with Key do 
   begin
      repeat
         GetInput;
         Action := ProcessKey(LastKey,LastX,LastY);
      until ((LastKey = 324) or (LastKey = 13)) and Suspend;
   end;
end; {BooleanIOOBJ.Activate}

function BooleanIOOBJ.Suspend:boolean;                        
{}
begin
   Suspend := VisibleIOOBJ.Suspend;
end; {BooleanIOOBJ.Suspend}

destructor BooleanIOOBJ.Done;                                     
{}
begin
   VisibleIOOBJ.Done;
end; {BooleanIOOBJ.Done}

end.