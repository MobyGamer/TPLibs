{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10t                            }

Unit totIO1;
{$I TOTFLAGS.INC}

{
 Development Notes:
        1.00a  3/25/91   Checked for Active Status on HotKeys and
                         allowed for no active fields in form.
        1.00b  3/29/91   Changed HotSpotItemPtr in FormOBJ
        1.00c  5/23/91   Added reaction to Mouse method 1
        1.00d  5/29/91   Removed double leave hook calls
        1.00e  6/01/91   Corrected Label FreeMem in VisibileIOOBJ
        1.00f  6/11/91   Corrected Group label FreeMem
        1.00g  6/11/91   Changed test for Bypassing in FormOBJ
        1.00h  7/02/91   Added StayPut ID for Leave Field Hooks
        1.00i  7/23/91   Change Radio Button to change selected item
                         when presses Up or Down cursor.
        1.00j  9/03/91   Added StopID to FormOBJ to determine
                         which field ended input.
        1.00k  9/03/91   Check active field for hotkey first - before
                         jumping to first field.
        1.00l  9/03/91   Changed colors for inactive Radio and Check groups.
        1.00m  9/03/91   Absorbed mouse press on field selection
        1.00n  9/09/91   Changed leave field hook refresh proc
        1.00o 10/03/91   Refeshed field when StayPut
        1.00p  9/03/92   Checked for active status on group object hotkeys
        1.10a 05/03/93   Add label update in leave field hook
                         & wait for mouse release before getting next input
        1.10b 05/24/93   Ignored hotkeys with value of zero
        1.10t 03/24/17   changed info methods to variables to improve speed/size
}

INTERFACE

uses DOS, CRT,
     totSYS, totLOOK, totFAST, totWIN, totSTR, totINPUT;

CONST
   NoRules      = $00;
   AllowNull    = $01;
   SuppressZero = $02;
   EraseDefault = $08;
   JumpIfFull   = $10;
   MaxButtonWidth = 25;  {alter as necessary}
   HelpID = 65535;
   StayPut = 65534;  {1.00h}
TYPE

tCursPos = (CursLeft,CursRight,CursPrev);
tStatus = (HiStatus, Norm, Off);
tAction = (None,NextField,PrevField,Finished,Escaped,
           Refresh,Signal,Enter,Help,Stop1,Stop2,Stop3,Stop4,
           Stop5,Stop6,Stop7,Stop8,Stop9);
tColor = array[1..4] of byte;

StringBut = string[MaxButtonWidth];

LeaveFieldfunc = function(var FieldID:word): tAction;
EnterFieldfunc = function(var NewID:word; OldID:word): tAction;
CharFunc =       function(var K:word;var X,Y:byte; var FieldID:word): tAction;
HelpProc =       procedure(ID:word);

tSignal = record
   ID: word;
   MsgType: word;
   case word of           {variant record}
   0: (MsgPtr: pointer);
   1: (MsgLong: longint);
   2: (MsgWord: word);
   3: (MsgInt: integer);
   4: (MsgByte: byte);
   5: (MsgChar: char);
end;

InputOBJ = object  {defines the default attributes for the fields}
   vLabel: tColor;
   vButton: tColor;
   vGroup: tColor;
   vList: tColor;
   vField: tColor;  {Off, On, Mask, Inactive}
   vMessage: byte;
   vInputPad: char;
   vCase: tCase;
   vForceCase: boolean;     {adjust case of characters during input}
   vInputJust: tJust;
   vCursorLoc: tCursPos;
   vInsert: boolean;      {is field initially in insert mode}
   vRules: byte;          {erasedefault, jumpiffull..... etc.}
   {methods...}
   constructor Init;
   procedure   SetDefaults;
   procedure   SetColLabel(Off,OffHot,On,OnHot: byte);
   procedure   SetColButton(Off,OffHot,On,OnHot: byte);
   procedure   SetColGroup(Off,OffHot,On,OnHot: byte);
   procedure   SetColList(Off,OffHot,On,OnHot: byte);
   procedure   SetColField(Off,On,Mask,Inactive: byte);
   procedure   SetColMsg(Col:byte);
   procedure   SetIns(InsOn:boolean);
   procedure   SetRules(Rules:byte);
   procedure   SetPadChar(Pad:char);
   procedure   SetJust(Just:tJust);
   procedure   SetCursor(Curs: tCursPos);
   procedure   SetCase(Cas:tCase);
   procedure   SetForceCase(On:boolean);
   function    LabelCol(Element:byte): byte;
   function    ButtonCol(Element:byte): byte;
   function    GroupCol(Element:byte): byte;
   function    ListCol(Element:byte): byte;
   function    FieldCol(Element:byte): byte;
   (*
   function    MessageCol: byte;
   function    InputPad: char;
   function    InputIns:boolean;
   function    InputRules: byte;
   function    InputPadChar: char;
   function    InputJust: tJust;
   function    InputCursorLoc: tCursPos;
   function    InputCase: tCase;
   function    InputForceCase: boolean;
   *)
   destructor  Done;
end; {InputOBJ}

pItemIOOBJ = ^ItemIOOBJ;
ItemIOOBJ = object
   vBoundary: tCoords;
   vHotKey: word;
   vID: word;
   vActive: boolean;
   {methods ...}
   constructor Init;
   procedure   SetActiveStatus(Selectable:boolean);
   (*
   function    Active:boolean;
   function    GetHotKey: word;
   *)
   procedure   SetHotkey(HK:word);
   (*
   function    GetID: word;
   *)
   procedure   SetID(ID:word);
   function    Ontarget(X,Y: byte): boolean;                           VIRTUAL;
   function    Visible: boolean;                                       VIRTUAL;
   procedure   RaiseSignal(var TheSig:tSignal);                        VIRTUAL;
   procedure   HandleSignal(var BaseSig:tSignal; var NewSig:tSignal);  VIRTUAL;
   procedure   ShutdownSignal(var BaseSig:tSignal);                    VIRTUAL;
   function    IsHotkey(HK:word):boolean;                              VIRTUAL;
   procedure   WriteLabel(Status:tStatus);                             VIRTUAL;
   procedure   Display(Status:tStatus);                                VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;                       VIRTUAL;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;                VIRTUAL;
   function    Suspend:boolean;                                        VIRTUAL;
   destructor  Done;                                                   VIRTUAL;
end; {ItemIOOBJ}

pHotkeyIOOBJ = ^HotkeyIOOBJ;
HotkeyIOOBJ = object (ItemIOOBJ)
   vActionCode: tAction;
   {methods ...}
   constructor Init(HK:Word;Act:tAction);
   function    IsHotkey(HK:word):boolean;                              VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;                       VIRTUAL;
   destructor  Done;                                                   VIRTUAL;
end; {HotkeyIOOBJ}

pControlKeysIOOBJ = ^ControlKeysIOOBJ;
ControlKeysIOOBJ = object (ItemIOOBJ)
   vFinKey: word;
   vNexkey: word;
   vPreKey: word;
   vEscKey: word;
   {methods ...}
   constructor Init;
   procedure   SetKeys(Next,Prev,Fin,Esc:Word);
   function    IsHotkey(HK:word):boolean;                              VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;                       VIRTUAL;
   destructor  Done;                                                   VIRTUAL;
end; {ControlKeysIOOBJ}

pVisibleIOOBJ = ^VisibleIOOBJ;
VisibleIOOBJ = object (ItemIOOBJ)
  vLblPtr: pointer;
  vMsgPtr: pointer;
  vMsgX: byte;
  vMsgY: byte;
  {methods ...}
  constructor Init;
  procedure   SetLabel(Lbl:string);
  procedure   SetMessage(X,Y:byte; Msg:string);
  procedure   WriteMessage;
  function    Ontarget(X,Y: byte): boolean;             VIRTUAL;
  function    Visible: boolean;                         VIRTUAL;
  procedure   WriteLabel(Status:tStatus);               VIRTUAL;
  function    Suspend:boolean;                          VIRTUAL;
  destructor  Done;                                     VIRTUAL;
end; {VisibleIOOBJ}

pStripIOOBJ = ^StripIOOBJ;
StripIOOBJ = object(VisibleIOOBJ)
   vTitle: StringBut;
   vActionCode: tAction;
   {methods ...}
   constructor Init(X1,Y1:byte;Tit:string;Act:tAction);
   function    Ontarget(X,Y: byte): boolean;            VIRTUAL;
   function    IsHotkey(HK:word):boolean;               VIRTUAL;
   procedure   Display(Status:tStatus);                 VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;        VIRTUAL;
   function    ProcessKey(InKey:word;X,Y:byte):tAction; VIRTUAL;
   destructor  Done;                                    VIRTUAL;
end; {StripIOOBJ}

pStrip3dIOOBJ = ^Strip3dIOOBJ;
Strip3dIOOBJ = object(StripIOOBJ)
   {methods ...}
   constructor Init(X1,Y1:byte;Tit:string;Act:tAction);
   procedure   Display(Status:tStatus);                 VIRTUAL;
   destructor  Done;                                    VIRTUAL;
end; {Strip3dIOOBJ}

pButtonIOOBJ = ^ButtonIOOBJ;
ButtonIOOBJ = object(StripIOOBJ)
   {methods ...}
   constructor Init(X1,Y1:byte;Tit:string;Act:tAction);
   procedure   Display(Status:tStatus);                 VIRTUAL;
   destructor  Done;                                    VIRTUAL;
end; {ButtonIOOBJ}

pMultiLineIOOBJ = ^MultiLineIOOBJ;
MultiLineIOOBJ = object (VisibleIOOBJ)
   vBorder: tCoords;
   vTitle: StrVisible;
   vRows: byte;
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte;Title:string);
   procedure   SetBoxOn(On:boolean);
   procedure   Display(Status:tStatus);                  VIRTUAL;
   procedure   Activate;                                 VIRTUAL;
   destructor  Done;                                     VIRTUAL;
end; {MultiLineIOOBJ}

GroupItemPtr = ^GroupItem;
GroupItem = record
   NextNode: GroupItemPtr;
   PrevNode: GroupItemPtr;
   StrPtr: Pointer;
   HK: word;
   Selected: boolean;
end;

pGroupIOOBJ = ^GroupIOOBJ;
GroupIOOBJ = object (MultiLineIOOBJ)
   vItemStack: GroupItemPtr;
   vTotalItems: byte;
   vActiveItem: byte;
   vOnStr: string[3];
   vOffStr: string[3];
   vSubHotkeysActive : boolean;
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte;Title:string);
   procedure   SetSubHotkeysActive(On:boolean);
   function    EndNode: GroupItemPtr;
   function    NodePtr(Item:byte): GroupItemPtr;
   procedure   AddItem(Str:string;HK:word;Selected:boolean);
   function    HotKeyItem(HK:word): integer;
   function    HitItem(X,Y:byte):byte;
   procedure   WriteItem(Item:byte; IsActive:boolean);
   function    Select(K:word; X,Y:byte):tAction;                     VIRTUAL;
   function    IsHotkey(HK:word):boolean;                            VIRTUAL;
   procedure   Display(Status:tStatus);                              VIRTUAL;
   destructor  Done;                                                 VIRTUAL;
end;  {GroupIOOBJ}

pCheckIOOBJ = ^CheckIOOBJ;
CheckIOOBJ = object (GroupIOOBJ)
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte;Title:string);
   procedure   SetValue(Item:byte;Selected:boolean);
   function    GetValue(Item:byte):boolean;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;              VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;                     VIRTUAL;
   destructor  Done;                                                 VIRTUAL;
end; {CheckIOOBJ}

pRadioIOOBJ = ^RadioIOOBJ;
RadioIOOBJ = object (GroupIOOBJ)
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte;Title:string);
   procedure   SetValue(Item:byte);
   function    GetValue: byte;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;              VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;                     VIRTUAL;
   destructor  Done;                                                 VIRTUAL;
end; {RadioIOOBJ}

pItemNode = ^ItemNode;
ItemNode = record
   Item: pItemIOOBJ;
   NextNode: pItemNode;
   PrevNode: pItemNode;
end; {ItemList}

pFormOBJ = ^FormOBJ;
FormOBJ = object
   vItemStack: pItemNode;
   vActiveItem: pItemNode;
   vCharHook: CharFunc;
   vLeaveHook: LeaveFieldFunc;
   vEnterHook: EnterFieldFunc;
   vHelpHook:  HelpProc;
   {methods ...}
   constructor Init;
   procedure   AddItem(var NewItem: ItemIOOBJ);
   procedure   SetCharHook(Func:CharFunc);
   procedure   SetLeaveHook(Func:LeaveFieldFunc);
   procedure   SetEnterHook(Func:EnterFieldFunc);
   procedure   SetHelpHook(Proc:HelpProc);
   function    EndNode: pItemNode;
   procedure   SetActiveItem(ID:word);
   function    HotKeyItemPtr(HotKey:word):pItemNode;
   function    IDItemPtr(ID:word):pItemNode;
   function    HotSpotItemPtr(X,Y:byte):pItemNode;
   function    Go: tAction;
   procedure   BroadcastSignal(TheSig:tSignal; SignalSource: pItemNode);
   procedure   DisplayItems;
   function    StopID:word;
   procedure   AdjustKey(var Key:word;var X,Y: byte);          VIRTUAL;
   procedure   HelpTask(ID:word);                              VIRTUAL;
   function    CharTask(var K:word;var X,Y:byte;
                        var FieldID:word):tAction;             VIRTUAL;
   function    EnterTask(var NewID:word; OldID:word): tAction; VIRTUAL;
   function    LeaveTask(var FieldID:word): tAction;           VIRTUAL;
   destructor  Done;                                           VIRTUAL;
end; {FormOBJ}

WinFormPtr = ^WinFormOBJ;
pWinFormOBJ = WinFormPtr;
WinFormOBJ = object (FormOBJ)
   vWinPtr: MoveWinPtr;
   {methods ...}
   constructor Init;
   (*
   function    Win: MoveWinPtr;
   *)
   procedure   Draw;
   procedure   AdjustKey(var Key:word;var X,Y: byte);       VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {WinFormOBJ}

procedure IO1Init;
function NoCharHook(var K:word;var X,Y:byte;var FieldID:word): tAction;
function NoEnterHook(var FieldID:word; OtherID:word): tAction;
function NoLeaveHook(var ID:word): tAction;
procedure NoHelpHook(ID:word);
procedure AssignColors(Main,Inactive:tColor; Status:tStatus; var High,Nor:byte);

var
  IOTOT: ^InputOBJ;

IMPLEMENTATION
Var
   FormHelpCalled,
   EscapingForm: boolean;
{|||||||||||||||||||||||||||||||||||||||||||||}
{                                             }
{     M i s c.  P r o c s   &   F u n c s     }
{                                             }
{|||||||||||||||||||||||||||||||||||||||||||||}
{$F+}
function NoCharHook(var K:word;var X,Y:byte;var FieldID:word): tAction;
{}
begin
   NoCharHook := None;
end; {NoCharHook}

function NoEnterHook(var FieldID:word; OtherID:word): tAction;
{}
begin
   NoEnterHook := none;
end; {NoEnterHook}

function NoLeaveHook(var ID:word): tAction;
{}
begin
   NoLeaveHook := none;
end; {NoLeaveHook}

procedure NoHelpHook(ID:word);
{}
begin
   Ding;
end; {NoHelpHook}
{$IFNDEF OVERLAY}
   {$F-}
{$ENDIF}

procedure AssignColors(Main,Inactive:tColor; Status:tStatus; var High,Nor:byte);
{}
begin
   Case Status of
      HiStatus: begin
         High := Main[4];
         Nor := Main[3];
      end;
      Norm: begin
         High := Main[2];
         Nor := Main[1];
      end;
      Off: begin
         High := Inactive[4];
         Nor := Inactive[4];
      end;
   end; {case}
end; {AssignColors}
{|||||||||||||||||||||||||||||||||||||||||}
{                                         }
{     I n p u t O B J   M E T H O D S     }
{                                         }
{|||||||||||||||||||||||||||||||||||||||||}
constructor InputOBJ.Init;
{}
begin
   SetDefaults;
end; {InputlOBJ.Init}

procedure InputOBJ.SetDefaults;
{}
begin
   if Monitor^.ColorOn then {color System}
   begin
      SetColLabel(78,76,79,76);
      SetColButton(32,46,47,46);
      SetColGroup(48,62,63,62);
      SetColList(48,62,31,30);
      SetColField(48,31,23,71);
   end
   else
   begin
      SetColLabel(7,15,15,15);
      SetColButton(7,15,15,15);
      SetColGroup(7,15,15,15);
      SetColList(7,15,15,15);
      SetColField(7,15,15,15);
   end;
   SetColMsg(0);
   vInputPad := chr(250);
   vCase := Leave;
   vForceCase := false;
   vInputJust :=  JustLeft;
   vCursorLoc := CursPrev;
   vInsert := false;
   vRules :=  AllowNull;
end; {InputOBJ.SetDefaults}

procedure InputOBJ.SetColLabel(Off,OffHot,On,OnHot: byte);
{}
begin
   vLabel[1] := Off;
   vLabel[2] := OffHot;
   vLabel[3] := On;
   vLabel[4] := OnHot;
end; {InputOBJ.SetColLabel}

procedure InputOBJ.SetColButton(Off,OffHot,On,OnHot: byte);
{}
begin
   vButton[1] := Off;
   vButton[2] := OffHot;
   vButton[3] := On;
   vButton[4] := OnHot;
end; {InputOBJ.SetColButton}

procedure InputOBJ.SetColGroup(Off,OffHot,On,OnHot: byte);
{}
begin
   vGroup[1] := Off;
   vGroup[2] := OffHot;
   vGroup[3] := On;
   vGroup[4] := OnHot;
end; {InputOBJ.SetColGroup}

procedure InputOBJ.SetColList(Off,OffHot,On,OnHot: byte);
{}
begin
   vList[1] := Off;
   vList[2] := OffHot;
   vList[3] := On;
   vList[4] := OnHot;
end; {InputOBJ.SetColList}

procedure InputOBJ.SetColField(Off,On,Mask,Inactive: byte);
{}
begin
   vField[1] := Off;
   vField[2] := On;
   vField[3] := Mask;
   vField[4] := InActive;
end; {InputOBJ.SetColField}

procedure InputOBJ.SetColMsg(Col:byte);
{}
begin
   vMessage := Col;
end; {InputOBJ.SetColMsg}

function InputOBJ.LabelCol(Element:byte): byte;
{}
begin
   LabelCol := vLabel[Element];
end; {InputOBJ.LabelCol}

function InputOBJ.ButtonCol(Element:byte): byte;
{}
begin
   ButtonCol := vButton[Element];
end; {InputOBJ.ButtonCol}

function InputOBJ.GroupCol(Element:byte): byte;
{}
begin
   GroupCol := vGroup[Element];
end; {InputOBJ.GroupCol}

function InputOBJ.ListCol(Element:byte): byte;
{}
begin
   ListCol := vList[Element];
end; {InputOBJ.ListCol}

function InputOBJ.FieldCol(Element:byte): byte;
{}
begin
   FieldCol := vField[Element];
end; {InputOBJ.FieldCol}

(*
function InputOBJ.MessageCol: byte;
{}
begin
   MessageCol := vMessage;
end; {InputOBJ.MessageCol}
*)

procedure InputOBJ.SetIns(InsOn:boolean);
{}
begin
   vInsert := InsOn;
end; {InputOBJ.SetIns}

procedure InputOBJ.SetRules(Rules:byte);
{}
begin
   vRules := Rules;
end; {SetRules}

procedure InputOBJ.SetPadChar(Pad:char);
{}
begin
   vInputPad := Pad;
end; {InputOBJ.SetPadChar}

procedure InputOBJ.SetCursor(Curs:tCursPos);
{}
begin
   vCursorLoc := Curs;
end; {InputOBJ.SetCurs}

procedure InputOBJ.SetJust(Just:tJust);
{}
begin
   vInputJust := Just;
end; {InputOBJ.SetJust}

procedure InputOBJ.SetCase(Cas:tCase);
{}
begin
   vCase := Cas;
end; {InputOBJ.SetCase}

procedure InputOBJ.SetForceCase(On:boolean);
{}
begin
   vForceCase := On;
end; {InputOBJ.SetForceCase}

(*
function InputOBJ.InputPad: char;
{}
begin
   InputPad := vInputPad;
end; {of func InputOBJ.InputPad}

function InputOBJ.InputIns:boolean;
{}
begin
   InputIns := vInsert;
end; {InputOBJ.InputIns}

function InputOBJ.InputRules:byte;
{}
begin
   InputRules := vRules;
end; {InputOBJ.InputRules}

function InputOBJ.InputPadChar:char;
{}
begin
   InputPadChar := vInputPad;
end; {InputOBJ.InputPadChar}

function InputOBJ.InputJust:tJust;
{}
begin
   InputJust := vInputJust;
end; {InputOBJ.InputJust}

function InputOBJ.InputCursorLoc:tCursPos;
{}
begin
   InputCursorLoc := vCursorLoc;
end; {InputOBJ.InputCursorLoc}

function InputOBJ.InputCase:tCase;
{}
begin
   InputCase := vCase;
end; {InputOBJ.InputCase}

function InputOBJ.InputForceCase:boolean;
{}
begin
   InputForceCase := vForceCase;
end; {InputOBJ.InputForceCase}
*)

destructor InputOBJ.Done;
begin end;
{||||||||||||||||||||||||||||||||||||||}
{                                      }
{     I t e m O B J   M E T H O D S    }
{                                      }
{||||||||||||||||||||||||||||||||||||||}
constructor ItemIOOBJ.Init;
{}
begin
   vActive := false;
   vHotKey := 0;
   vID := 0;
   vBoundary.X1 := 0;
   vBoundary.Y1 := 0;
   vBoundary.X2 := 0;
   vBoundary.Y2 := 0;
end; {cons ItemIOOBJ.Init}

procedure ItemIOOBJ.SetActiveStatus(Selectable:boolean);
{}
begin
   vActive := Selectable;
end; {ItemIOOBJ.SetActiveStatus}

procedure ItemIOOBJ.SetHotkey(HK:word);
{}
begin
    vHotKey := HK;
end; {ItemIOOBJ.SetHotkey}

(*
function ItemIOOBJ.GetHotKey:word;
{}
begin
   GetHotKey := vHotkey;
end; {ItemIOOBJ.GetHotKey}
*)

procedure ItemIOOBJ.SetID(ID:word);
{}
begin
    vID := ID;
end; {ItemIOOBJ.SetID}

(*
function ItemIOOBJ.GetID:word;
{}
begin
   GetID := vID;
end; {ItemIOOBJ.GetID}
*)

function ItemIOOBJ.Visible: boolean;
{}
begin
   Visible := false;
end; {ItemIOOBJ.Visible}

(*
function ItemIOOBJ.Active:boolean;
{}
begin
   Active := vActive;
end; {ItemIOOBJ.Active}
*)

function ItemIOOBJ.IsHotKey(HK:word):boolean;
{}
begin
   IsHotKey := (HK = vHotKey) and vActive;   {1.00a}
end; {ItemIOOBJ.IsHotKey}

function ItemIOOBJ.OnTarget(X,Y: byte):boolean;
{}
begin
   Ontarget :=     (X >= vBoundary.X1)
               and (X <= vBoundary.X2)
               and (Y >= vBoundary.Y1)
               and (Y <= vBoundary.Y2)
               and vActive;
end; {ItemIOOBJ.HotKey}

function ItemIOOBJ.Select(K:word; X,Y:byte):tAction;
{}
begin
   Select := None;
end;

function ItemIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;
{}
begin
   ProcessKey := None;
end;

procedure ItemIOOBJ.WriteLabel(Status:tStatus);
{}
begin end;

procedure ItemIOOBJ.Display(Status:tStatus);
{}
begin end;

function ItemIOOBJ.Suspend;
{}
begin
   Display(Norm);
   Suspend := true;
end; {ItemIOOBJ.Suspend}

procedure ItemIOOBJ.RaiseSignal(var TheSig:tSignal);
{abstract}
begin end;

procedure ItemIOOBJ.HandleSignal(var BaseSig:tSignal; var NewSig:tSignal);
{abstract}
begin end;

procedure ItemIOOBJ.ShutDownSignal(var BaseSig:tSignal);
{abstract}
begin end;

destructor ItemIOOBJ.Done;
{}
begin end;

{||||||||||||||||||||||||||||||||||||||||||}
{                                          }
{     H o t k e y O B J   M E T H O D S    }
{                                          }
{||||||||||||||||||||||||||||||||||||||||||}

constructor HotkeyIOOBJ.Init(HK:word; Act:tAction);
{}
begin
   ItemIOOBJ.Init;
   vBoundary.X1 := -128;
   vBoundary.X2 := -128;
   vBoundary.Y1 := -128;
   vBoundary.Y2 := -128;
   vActionCode := Act;
   vHotKey := HK;
end; {cons HotkeyIOOBJ.Init}

function HotkeyIOOBJ.Select(K:word; X,Y:byte):tAction;
{}
begin
   Select := vActionCode;
end; {HotkeyIOOBJ.Select}

function HotkeyIOOBJ.IsHotKey(HK:word):boolean;
{}
begin
   if HK = vHotKey then
   begin
      EscapingForm := (vActionCode = Escaped);
      FormHelpCalled := (vActionCode = Help);
      IsHotkey := true
   end
   else
     IsHotKey := false;
end; {HotkeyIOOBJ.IsHotKey}

destructor HotkeyIOOBJ.Done;
{}
begin
   ItemIOOBJ.Done;
end; {dest HotkeyIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                        }
{     C o n t r o l K e y s I O O B J   M E T H O D S    }
{                                                        }
{||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor ControlKeysIOOBJ.Init;
{}
begin
   ItemIOOBJ.Init;
   vFinKey:= 324;
   vNexkey:= 9;
   vPreKey:= 271;
   vEscKey:= 27;
end; {ControlKeysIOOBJ.Init}

procedure ControlKeysIOOBJ.SetKeys(Next,Prev,Fin,Esc:Word);
{}
begin
   vFinKey:= Fin;
   vNexkey:= Next;
   vPreKey:= Prev;
   vEscKey:= Esc;
end; {ControlKeysIOOBJ.SetKeys}

function ControlKeysIOOBJ.IsHotkey(HK:word):boolean;
{}
begin
   if (Hk=vEscKey) then
      EscapingForm := true;
   IsHotKey := (   (HK=vFinKey)
                or (HK=vNexKey)
                or (HK=vPreKey)
                or (Hk=vEscKey)
               );
end; {ControlKeysIOOBJ.IsHotkey}

function ControlKeysIOOBJ.Select(K:word; X,Y:byte):tAction;
{}
begin
   if AlphabetTOT^.IsLower(K) then
      K := ord(AlphabetTOT^.GetUpcase(chr(K)));
   if (K = vFinKey) then
      Select := Finished
   else if (K = vNexkey) then
      Select := NextField
   else if (K = vPreKey) then
      Select := PrevField
   else if (K = vEscKey) then
      Select := Escaped
   else
      Select := None;
end; {ControlKeysIOOBJ.Select}

destructor ControlKeysIOOBJ.Done;                            
{}
begin
   ItemIOOBJ.Done;
end; {ControlKeysIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                      }
{     V i s i b l e F i e l d O B J   M E T H O D S    }
{                                                      }
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor VisibleIOOBJ.Init;
{}
begin
  ItemIOOBJ.Init;
  vActive := true;
  vLblPtr := nil;
  vMsgPtr := nil;
end; {VisibleIOOBJ.Init}

function VisibleIOOBJ.Visible: boolean;
{}
begin
   Visible := true;
end; {VisibleIOOBJ.Visible}

procedure VisibleIOOBJ.SetLabel(Lbl:string);
{}
var L : word;
begin
   L := succ(length(Lbl));
   if MaxAvail >= L then
   begin
      getmem(vLblPtr,L);
      move(Lbl[0],vLblPtr^,L);
   end;
end; {VisibleIOOBJ.SetLabel}

function VisibleIOOBJ.OnTarget(X,Y: byte):boolean;
{}
var LabelLen: byte;
begin
   if vLblPtr = nil then
      LabelLen := 0
   else
   begin
      move(vLblPtr^,LabelLen,1);
      if LabelLen > 1 then
         inc(LabelLen);
   end;
   OnTarget :=     (X >= vBoundary.X1 - LabelLen)
               and (X <= vBoundary.X2)
               and (Y >= vBoundary.Y1)
               and (Y <= vBoundary.Y2)
               and vActive;
end; {VisibleIOOBJ.OnTarget}

procedure VisibleIOOBJ.SetMessage(X,Y:byte; Msg:string);
{}
var L : word;
begin
   L := succ(length(Msg));
   if MaxAvail >= L then
   begin
      getmem(vMsgPtr,L);
      move(Msg[0],vMsgPtr^,L);
      vMsgX := X;
      vMsgY := Y;
   end;
end; {VisibleIOOBJ.SetMessage}

procedure VisibleIOOBJ.WriteLabel(Status:tStatus);
{}
var
  Temp: string;
  Norm,Hi,L: byte;
begin
   if vLblPtr <> nil then
   begin
      move(vLblPtr^,L,1);
      if L > 0 then
      begin
         move(vLblPtr^,Temp,succ(L));
         AssignColors(IOTOT^.vLabel,IOTOT^.vField,Status,Hi,Norm);
         if (Hi = 0) or (Norm = 0) then
            Screen.WritePlain(pred(vBoundary.X1) - length(Temp),vBoundary.Y1,Temp)
         else
            Screen.WriteHi(pred(vBoundary.X1)-length(strip('A',Screen.vHimarker,Temp)),vBoundary.Y1,Hi,Norm,Temp);
      end;
   end;
end; {VisibleIOOBJ.WriteLabel}

procedure VisibleIOOBJ.WriteMessage;
{}
var
  Temp: string;
  Col,L: byte;
begin
   if vMsgPtr <> nil then
   begin
      move(vMsgPtr^,L,1);
      if L > 0 then
      begin
         move(vMsgPtr^,Temp,succ(L));
         Col := IOTOT^.vMessage;
         if Col = 0 then
            Screen.WritePlain(vMsgX,vMsgY,Temp)
         else
            Screen.WriteAt(vMsgX,vMsgY,Col,Temp);
      end;
   end;
end; {VisibleIOOBJ.WriteMessage}

function VisibleIOOBJ.Suspend:boolean;
{}
var Col,L: byte;
begin
   Display(Norm);
   WriteLabel(Norm);
   if vMsgPtr <> Nil then   {clear the message}
   begin
      move(vMsgPtr^,L,1);
      if L > 0 then
      begin
         Col := IOTOT^.vMessage;
         if Col = 0 then
            Screen.WritePlain(vMsgX,vMsgY,replicate(L,' '))
         else
            Screen.WriteAt(vMsgX,vMsgY,Col,replicate(L,' '));

      end;
   end;
   Suspend := true;
end; {VisibleIOOBJ.Suspend}

destructor VisibleIOOBJ.Done;
{}
var Len : byte;
begin
   ItemIOOBJ.Done;
   if vLblPtr <> Nil then
   begin
      Move(vLblPtr^,Len,1);
      FreeMem(vLblPtr,succ(Len));    {1.00e}
   end;
   if vMsgPtr <> Nil then
   begin
      Move(vMsgPtr^,Len,1);
      FreeMem(vMsgPtr,succ(Len));    {1.00e}
   end;
end; {desc VisibleIOOBJ.Done}

{||||||||||||||||||||||||||||||||||||||||}
{                                        }
{     S t r i p O B J   M E T H O D S    }
{                                        }
{||||||||||||||||||||||||||||||||||||||||}

constructor StripIOOBJ.Init(X1,Y1:byte;Tit:string;Act:tAction);
{}
begin
   VisibleIOOBJ.Init;
   vBoundary.X1 := X1;
   vBoundary.Y1 := Y1;
   vBoundary.X2 := X1 + pred(length(Strip('A','~',Tit)));
   vBoundary.Y2 := Y1;
   vTitle := Tit;
   vActionCode := Act;
end; {StripIOOBJ.Init}

function StripIOOBJ.IsHotKey(HK:word):boolean;
{}
begin
   IsHotKey := (HK = vHotKey) and (vActive);   {1.00a}
   if HK = vHotKey then
   begin
      EscapingForm := (vActionCode = Escaped);
      FormHelpCalled := (vActionCode = Help);
   end;
end; {StripIOOBJ.IsHotKey}

function StripIOOBJ.OnTarget(X,Y: byte):boolean;
{}
Var BullsEye: boolean;
begin
   BullsEye := VisibleIOOBJ.OnTarget(X,Y);
   if BullsEye then
   begin
      EscapingForm := (vActionCode = Escaped);
      FormHelpCalled := (vActionCode = Help);
   end;
   OnTarget := BullsEye;
end; {ItemIOOBJ.HotKey}

procedure StripIOOBJ.Display(Status:tStatus);
{}
var
   Nor,High: Byte;
begin
   AssignColors(IOTOT^.vButton,IOTOT^.vField,Status,High,Nor);
   with vBoundary do
   begin
      Screen.WriteHi(X1,Y1,High,Nor,vTitle);
      if Status = HiStatus then
         GotoXY(X1 + (X2-X1) div 2,Y1 + (Y2 - Y1) div 2);
   end;
end; {StripIOOBJ.Display}

function StripIOOBJ.Select(K:word; X,Y:byte):tAction;
{}
begin
   Display(HiStatus);
   WriteMessage;
   if AlphabetTOT^.IsLower(K) then
      K := ord(AlphabetTOT^.GetUpcase(chr(K)));
   if ((K <> 0) and (K = vHotKey)) or (K = 513) then
      Select := vActionCode
   else
      Select := none;
end; {StripIOOBJ.Select}

function StripIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;
{}
begin
   if (InKey = 13) or (InKey = 513) then
      ProcessKey := vActionCode
   else
      Processkey := None;
end; {StripIOOBJ.ProcessKey}

destructor StripIOOBJ.Done;
{}
begin
   VisibleIOOBJ.Done;
end; {StripIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||}
{                                            }
{     S t r i p 3 d O B J   M E T H O D S    }
{                                            }
{||||||||||||||||||||||||||||||||||||||||||||}
constructor Strip3dIOOBJ.Init(X1,Y1:byte;Tit:string;Act:tAction);
{}
begin
   StripIOOBJ.Init(X1,Y1,Tit,Act);
end; {Strip3dIOOBJ.Init}

procedure Strip3dIOOBJ.Display(Status:tStatus);
{}
var High,Nor,A: byte;
begin
   StripIOOBJ.Display(Status);
   A := Screen.ReadAttr(succ(vBoundary.X1),succ(vBoundary.Y1));
   if Monitor^.ColorOn then {color System}
      A := Cattr(black,battr(A))
   else
      A := Cattr(darkgray,battr(A));
   Screen.WriteAT(succ(vBoundary.X1),succ(vBoundary.Y1),A,
                  replicate(succ(vBoundary.X2-vBoundary.X1),char(223)));
   Screen.WriteAT(succ(vBoundary.X2),vBoundary.Y1,A,char(220));
end; {Strip3dIOOBJ.Display}

destructor Strip3dIOOBJ.Done;
{}
begin
   StripIOOBJ.Done;
end; {desc Strip3dIOOBJ.Done}

{||||||||||||||||||||||||||||||||||||||||||}
{                                          }
{     B u t t o n O B J   M E T H O D S    }
{                                          }
{||||||||||||||||||||||||||||||||||||||||||}

constructor ButtonIOOBJ.Init(X1,Y1:byte;Tit:string;Act:tAction);
{}
var L : byte;
begin
   StripIOOBJ.Init(X1,Y1,Tit,Act);
   L := length(Strip('A','~',Tit));
   vBoundary.X2 := succ(X1 + L);
   vBoundary.Y2 := Y1 + 2;
end; {ButtonIOOBJ.Init}

procedure ButtonIOOBJ.Display(Status:tStatus);
{}
var
   High,Nor,Style: Byte;
begin
   AssignColors(IOTOT^.vButton,IOTOT^.vField,Status,High,Nor);
   if Status = HiStatus then
      Style := 5
   else
      Style := 1;
   with vBoundary do
   begin
      Screen.FillBox(X1,Y1,X2,Y2,Nor,Style);
      Screen.WriteHi(succ(X1),succ(Y1),High,Nor,vTitle);
      if Status = HiStatus then
         GotoXY(X1 + (X2-X1) div 2,Y1 + (Y2 - Y1) div 2);
   end;
end; {ButtonIOOBJ.Display}

destructor ButtonIOOBJ.Done;
{}
begin
   StripIOOBJ.Done;
end; {desc ButtonIOOBJ.Done}

{||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                }
{     M u l t i L i n e O B J   M E T H O D S    }
{                                                }
{||||||||||||||||||||||||||||||||||||||||||||||||}

constructor MultiLineIOOBJ.Init(X1,Y1,width,depth:byte;Title:string);
{}
begin
   VisibleIOOBJ.Init;
   vTitle:= Title;
   vBoundary.X1 := X1;
   vBoundary.Y1 := Y1;
   vBoundary.X2 := pred(X1+width);
   vBoundary.Y2 := pred(Y1+depth);
   SetBoxOn(False);
end; {MultiLineIOOBJ.Init}

procedure MultiLineIOOBJ.SetBoxOn(On:boolean);
{}
begin
   if On then
   begin
      vBorder.X1 := succ(vBoundary.X1);
      vBorder.X2 := pred(vBoundary.X2);
      if vTitle = '' then
         vBorder.Y1 := succ(vBoundary.Y1)
      else
         vBorder.Y1 := (vBoundary.Y1+2);
      vBorder.Y2 := pred(vBoundary.Y2);
   end
   else
   begin
      vBorder.X1 := vBoundary.X1;
      vBorder.X2 := vBoundary.X2;
      if vTitle = '' then
         vBorder.Y1 := vBoundary.Y1
      else
         vBorder.Y1 := succ(vBoundary.Y1);
      vBorder.Y2 := vBoundary.Y2;
   end;
   vRows := vBorder.Y2 - pred(vBorder.Y1);
end; {MultiLineIOOBJ.SetBoxOn}

procedure MultiLineIOOBJ.Display(Status:tStatus);
{}
var
  High,Nor: byte;
  Style: byte;
  I : integer;
begin
   AssignColors(IOTOT^.vLabel,IOTOT^.vField,Status,High,Nor);
   if Status = HiStatus then
      Style := 2
   else
      Style := 1;
   with Screen do
   begin
      if vTitle <> '' then
         WriteHi(vBoundary.X1,vBoundary.Y1,High,Nor,vTitle);
      if vBoundary.X1 < vBorder.X1 then  {box}
         with vBorder do
            Box(pred(X1),pred(Y1),succ(X2),succ(Y2),Nor,Style);
   end;
end; {MultiLineIOOBJ.Display}

procedure MultiLineIOOBJ.Activate;
{}
var
   Action: tAction;
begin
   repeat
      Action := Select(0,0,0);
      Display(HiStatus);
      WriteLabel(HiStatus);
      with Key do 
      repeat
         GetInput;
         if LastKey = 27 then
            Action := Escaped
         else
            Action := ProcessKey(LastKey,LastX,LastY);
      until Action in [Finished,Escaped,Enter,NextField,PrevField,Stop1..Stop9];
   until Suspend;
end; {MultiLineIOOBJ.Activate}

destructor MultiLineIOOBJ.Done;
{}
begin
   VisibleIOOBJ.Done;
end; {MultiLineIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||}
{                                        }
{     G r o u p O B J   M E T H O D S    }
{                                        }
{||||||||||||||||||||||||||||||||||||||||}
constructor GroupIOOBJ.Init(X1,Y1,width,depth:byte;Title:string);
{}
begin
   MultiLineIOOBJ.Init(X1,Y1,width,depth,Title);
   vItemStack := nil;
   vActiveItem := 0;
   vTotalItems := 0;
   vSubHotkeysActive := false;
end; {GroupIOOBJ.Init}

procedure GroupIOOBJ.SetSubHotkeysActive(On:boolean);
{}
begin
   vSubHotkeysActive := On;
end; {GroupIOOBJ.SetSubHotkeysActive}

procedure GroupIOOBJ.WriteItem(Item:byte; IsActive:boolean);
{}
var
  Temp: GroupItemPtr;
  High,Nor:byte;
  Status: tStatus;
  Len : byte;
  Str : string;
begin
   if IsActive then          {1.00l}
      Status := HiStatus
   else if vActive then
      Status := Norm
   else
      Status := Off;
   AssignColors(IOTOT^.vGroup,IOTOT^.vField,Status,High,Nor);
   Temp := NodePtr(Item);
   if (Temp = nil) or (Temp^.StrPtr = nil) then
      exit
   else
   begin
      move(Temp^.StrPtr^,Len,1);
      if Len > 0 then
         move(Temp^.StrPtr^,Str,succ(Len))
      else
         Str := '';
      if Temp^.Selected then
         Str := vOnStr+' '+Str
      else
         Str := vOffStr+' '+Str;
      Str := Padleft(Str,vBorder.X2 
                        - pred(vBorder.X1)
                        + length(Str) 
                        - length(strip('A',Screen.vHiMarker,Str)),
                        ' ');
      Screen.WriteHi(vBorder.X1,vBorder.Y1+pred(Item),High,Nor,Str);
      if IsActive then
         Screen.GotoXY(succ(vBorder.X1),vBorder.Y1+pred(Item));
   end;
end; {GroupIOOBJ.WriteItem}

procedure GroupIOOBJ.Display(Status:tStatus);
{}
var
  BorderCol : byte;
  Style: byte;
  I : integer;
begin
   MultiLineIOOBJ.Display(Status);
   for I := 1 to vTotalItems do
      WriteItem(I,((I=vActiveItem) and (Status=HiStatus)));
end; {GroupIOOBJ.Display}

function GroupIOOBJ.Select(K:word; X,Y:byte):tAction;
{}
begin
   Display(HiStatus);
   Select := none;
end; {StripIOOBJ.Select}

function GroupIOOBJ.HotKeyItem(HK:word): integer;
{}
var 
   Counter:integer;
   Temp: GroupItemPtr;
   Found : boolean;
begin
   if vSubHotkeysActive then
   begin
      if AlphabetTOT^.IsLower(HK) then
         HK := ord(AlphabetTOT^.GetUpcase(chr(HK)));
      Found := false;
      Counter := 1;
      Temp := vItemStack;
      while (Temp <> nil) and (Found = false) do
      begin
         Found := (Temp^.HK = HK);
         if not Found then
         begin
            inc(Counter);
            Temp := Temp^.NextNode;
         end;
      end;
      if Found then
         HotKeyItem := Counter
      else
         HotKeyItem := 0;
   end
   else
     HotkeyItem := 0;
end; {GroupIOOBJ.HotKeyItem}

function GroupIOOBJ.IsHotkey(HK:word):boolean;
{}
var
  Found : boolean;
  Temp: GroupItemPtr;
begin
   Found := (HK = vHotkey) and vActive;   {1.00p}
   if (Found = false) and vActive then    {1.00p}
      Found := (HotKeyItem(HK) > 0);
   IsHotkey := found;   
end;  {GroupIOOBJ.IsHotkey}

function GroupIOOBJ.EndNode: GroupItemPtr;
{returns a pointer to the last item in the list}
var
   Temp : GroupItemPtr;
begin
   Temp := vItemStack;
   while (Temp <> nil) and (Temp^.NextNode <> nil) do
      Temp := Temp^.NextNode;
   EndNode := Temp;
end; {GroupIOOBJ.EndNode}

procedure GroupIOOBJ.AddItem(Str:string;HK:word;Selected:boolean);
{}
var Temp: GroupItemPtr;
begin
   if MaxAvail < SizeOf(vItemStack^) + succ(Length(Str)) then
      exit
   else
   begin
      if vItemStack = Nil then
      begin
         getmem(vItemStack,sizeof(vItemStack^));
         vActiveItem := 1;
         vItemStack^.PrevNode := Nil;
         Temp := vItemStack;
      end
      else
      begin
         Temp := EndNode;
         getmem(Temp^.NextNode, sizeof(Temp^));
         Temp^.NextNode^.PrevNode := Temp;
         Temp := Temp^.NextNode;
      end;
      Temp^.NextNode := nil;
      inc(vTotalItems);
      getmem(Temp^.StrPtr,succ(length(Str)));
      move(Str[0],Temp^.StrPtr^,succ(length(Str)));
      Temp^.HK := HK;
      Temp^.Selected := Selected;
      if HK <> 0 then
         vSubHotKeysActive := true;
   end;
end; {GroupIOOBJ.AddItem}

function GroupIOOBJ.HitItem(X,Y:byte):byte;
{returns the item number of the item falling on line Y, else returns 0}
var
  B: integer;
begin
    B := Y - pred(vBorder.Y1);
    if (B > vTotalItems) or (B < 0) or (X < vBorder.X1) or (X> vBorder.X2) then
       HitItem := 0
    else
       HitItem := B;
end; {GroupIOOBJ.HitItem}

function GroupIOOBJ.NodePtr(Item:byte): GroupItemPtr;
{}
var
  Temp: GroupItemPtr;
  I: integer;
begin
   Temp := vItemStack;
   if Item > 1 then
      for I := 2 to Item do
         if Temp <> Nil then
            Temp := Temp^.NextNode;
   NodePtr := Temp;
end; {GroupIOOBJ.NodePtr}

destructor GroupIOOBJ.Done;
{}
var 
  Temp: GroupItemPtr;
  Len: byte;
begin
   MultiLineIOOBJ.Done;
   Temp := EndNode;
   while Temp <> Nil do
   begin
      if Temp^.StrPtr <> Nil then
      begin
         Move(Temp^.StrPtr^,Len,1);
         FreeMem(Temp^.StrPtr,succ(Len)); {1.00f}
      end;
      if Temp^.PrevNode = nil then
      begin
         FreeMem(Temp,sizeof(temp^));
         Temp := nil;
      end
      else
      begin
         Temp := Temp^.PrevNode;
         FreeMem(Temp^.NextNode,sizeof(temp^));
      end;
   end;
end; {desc GroupIOOBJ.Done}

{||||||||||||||||||||||||||||||||||||||||}
{                                        }
{     C h e c k O B J   M E T H O D S    }
{                                        }
{||||||||||||||||||||||||||||||||||||||||}

constructor CheckIOOBJ.Init(X1,Y1,width,depth:byte;Title:string);
{}
begin
   GroupIOOBJ.Init(X1,Y1,width,depth,Title);
   vOnstr := '[X]';
   vOffStr := '[ ]';
end; {CheckIOOBJ.Init}

function CheckIOOBJ.Select(K:word; X,Y:byte):tAction;
{}
var
  Temp: GroupItemPtr;
  New: byte;
begin
   Display(HiStatus);
   WriteMessage;
   New := HotKeyItem(K);
   if New > 0 then
   begin
      if vActiveItem <> New then
         WriteItem(vActiveItem,false);
      vActiveItem := New;
      Temp := NodePtr(vActiveItem);
      vActiveItem := New;
      Temp^.Selected := Not Temp^.Selected;
      WriteItem(vActiveItem,true);
   end;
   if K = 513 then
   begin
      New := HitItem(X,Y);
      if New > 0 then
      begin
         WriteItem(vActiveItem,false);
         vActiveItem := New;
         Temp := NodePtr(vActiveItem);
         Temp^.Selected := Not Temp^.Selected;
         WriteItem(vActiveItem,true);
      end;
   end;
   Select := none;
end; {CheckIOOBJ.Select}

function CheckIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;
{}
var
  Temp: GroupItemPtr;
  New : byte;
begin
   New := HotKeyItem(InKey);
   if New > 0 then
   begin
      if New <> vActiveItem then
      begin
          WriteItem(vActiveItem,false);
          vActiveItem := New;
      end;
      Temp := NodePtr(vActiveItem);
      Temp^.Selected := Not Temp^.Selected;
      WriteItem(vActiveItem,true);
   end
   else
      case InKey of
         32:  {space bar}
         begin
            Temp := NodePtr(vActiveItem);
            Temp^.Selected := Not Temp^.Selected;
            WriteItem(vActiveItem,true);
         end;
         513: {mouse enter}
         begin
            New := HitItem(X,Y);
            if New > 0 then
            begin
               WriteItem(vActiveItem,false);
               vActiveItem := New;
               Temp := NodePtr(vActiveItem);
               Temp^.Selected := Not Temp^.Selected;
               WriteItem(vActiveItem,true);
            end;
         end;
         336,592: {down arrow}  {1.00c}
         begin
            WriteItem(vActiveItem,false);
            if vActiveItem < vTotalItems then
               inc(vActiveItem)
            else
               vActiveItem := 1;
            WriteItem(vActiveItem,true);
         end;
         328,584: {up arrow}
         begin
            WriteItem(vActiveItem,false);
            if vActiveItem > 1 then
               dec(vActiveItem)
            else
               vActiveItem := vTotalItems;
            WriteItem(vActiveItem,true);
         end;
      end; {case}
   if InKey = 13 then
      ProcessKey := NextField
   else
      ProcessKey := None;
end; {CheckIOOBJ.ProcessKey}

procedure CheckIOOBJ.SetValue(Item:byte;Selected:boolean);
{}
var Temp: GroupItemPtr;
begin
   Temp := NodePtr(Item);
   if Temp <> nil then
      Temp^.Selected := Selected;
end; {CheckIOOBJ.SetValue}

function CheckIOOBJ.GetValue(Item:byte):boolean;
{}
var
  Temp: GroupItemPtr;
begin
   Temp := NodePtr(Item);
   if Temp <> nil then
      GetValue := Temp^.Selected
   else
      GetValue := false;
end; {CheckIOOBJ.GetValue}

destructor CheckIOOBJ.Done;
{}
begin
   GroupIOOBJ.Done;
end; {dest CheckIOOBJ.Done}

{||||||||||||||||||||||||||||||||||||||||}
{                                        }
{     R a d i o O B J   M E T H O D S    }
{                                        }
{||||||||||||||||||||||||||||||||||||||||}

constructor RadioIOOBJ.Init(X1,Y1,width,depth:byte;Title:string);
{}
begin
   GroupIOOBJ.Init(X1,Y1,width,depth,Title);
   vOnstr :=  '(ù)';
   vOffStr := '( )';
end; {RadioIOOBJ.Init}

procedure RadioIOOBJ.SetValue(Item:byte);
{}
var I : Integer;
begin
   for I := 1 to vTotalItems do
      NodePtr(I)^.Selected := (I=Item);
end; {RadioIOOBJ.SetValue}

function RadioIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;
{}
var
  Temp: GroupItemPtr;
  I : integer;
  New: byte;
begin
   New := HotKeyItem(InKey);
   if New <> 0 then
   begin
      if New <> vActiveItem then
      begin
         vActiveItem := New;
          Temp := NodePtr(vActiveItem);
          if not Temp^.Selected then
          begin
             SetValue(vActiveItem);
             for I := 1 to vTotalItems do
                WriteItem(I,(I=vActiveItem));
          end;
      end;
   end
   else
      case InKey of
         32:  {space bar}
         begin
         (*
            Temp := NodePtr(vActiveItem);
            if not Temp^.Selected then
            begin
               SetValue(vActiveItem);
               for I := 1 to vTotalItems do
                  WriteItem(I,(I=vActiveItem));
            end;
           *)
         end;
         513: {mouse enter}
         begin
            New := HitItem(X,Y);
            if New > 0 then
            begin
               vActiveItem := New;
               Temp := NodePtr(vActiveItem);
               if not Temp^.Selected then
               begin
                  SetValue(vActiveItem);
                  for I := 1 to vTotalItems do
                     WriteItem(I,(I=vActiveItem));
               end;
            end;
         end;
         336,592: {down arrow} {1.00c}
         begin
            SetValue(0);              {1.00i}
            WriteItem(vActiveItem,false);
            if vActiveItem < vTotalItems then
               inc(vActiveItem)
            else
               vActiveItem := 1;
            SetValue(vActiveItem);    {1.00i}
            WriteItem(vActiveItem,true);
         end;
         328,584: {up arrow}
         begin
            SetValue(0);              {1.00i}
            WriteItem(vActiveItem,false);
            if vActiveItem > 1 then
               dec(vActiveItem)
            else
               vActiveItem := vTotalItems;
            SetValue(vActiveItem);    {1.00i}
            WriteItem(vActiveItem,true);
         end;
      end; {case}
   if InKey = 13 then
      ProcessKey := NextField
   else
      ProcessKey := None;
end; {RadioIOOBJ.ProcessKey}

function RadioIOOBJ.Select(K:word; X,Y:byte):tAction;
{}
var
  Temp: GroupItemPtr;
  New: byte;
  I : integer;
begin
   vActiveItem := GetValue;
   Display(HiStatus);
   WriteMessage;
   I := HotKeyItem(K);
   if I > 0 then
   begin
      vActiveItem := I;
      Temp := NodePtr(vActiveItem);
      if not Temp^.Selected then
      begin
         SetValue(vActiveItem);
         for I := 1 to vTotalItems do
            WriteItem(I,(I=vActiveItem));
      end;
   end;
   if K = 513 then
   begin
      New := HitItem(X,Y);
      if New > 0 then
      begin
         vActiveItem := New;
         Temp := NodePtr(vActiveItem);
         if not Temp^.Selected then
         begin
            SetValue(vActiveItem);
            for I := 1 to vTotalItems do
               WriteItem(I,(I=vActiveItem));
         end;
      end;
   end;
   Select := none;
end; {RadioIOOBJ.Select}

function RadioIOOBJ.GetValue: byte;
{}
var I : integer;
begin
   I := 1;
   While (NodePtr(I)^.Selected = false) and (I < vTotalItems) do
     inc(I);
   GetValue := I;
end; {RadioIOOBJ.GetValue}

destructor RadioIOOBJ.Done;
{}
begin
   GroupIOOBJ.Done;
end; {dest RadioIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||}
{                                          }
{     A c t i o n O B J   M E T H O D S    }
{                                          }
{||||||||||||||||||||||||||||||||||||||||||}
constructor FormOBJ.Init;
{}
begin
   vItemStack := nil;
   vActiveItem := nil;
   vCharHook := NoCharHook;
   vLeaveHook := NoLeaveHook;
   vEnterHook := NoEnterHook;
   vHelpHook := NoHelpHook;
end; {cons FormOBJ.Init}

function FormOBJ.EndNode: pItemNode;
{returns a pointer to the last item in the last}
var
   Temp : pItemNode;
begin
   Temp := vItemStack;
   while (Temp <> nil) and (Temp^.NextNode <> nil) do
      Temp := Temp^.NextNode;
   EndNode := Temp;
end; {FormOBJ.EndNode}

procedure FormOBJ.AddItem(var NewItem: ItemIOOBJ);
{}
var
   Temp : pItemNode;
begin
   if vItemStack = nil then
   begin
      GetMem(vItemStack,sizeOf(vItemStack^));
      vItemStack^.Item := @NewItem;
      vItemStack^.NextNode := nil;
      vItemStack^.PrevNode := nil;
      vActiveItem := vItemStack;
   end
   else
   begin
      Temp := EndNode;
      GetMem(Temp^.NextNode,sizeof(Temp^));
      Temp^.NextNode^.PrevNode := Temp;
      Temp := Temp^.NextNode;
      Temp^.Item := @NewItem;
      Temp^.NextNode := nil;
   end;
end; {FormOBJ.AddItem}

procedure FormOBJ.SetCharHook(Func:CharFunc);
{}
begin
   vCharHook := Func;
end; {FormOBJ.SetCharHook}

procedure FormOBJ.SetLeaveHook(Func:LeaveFieldFunc);
{}
begin
   vLeaveHook := Func;
end; {FormOBJ.SetLeaveHook}

procedure FormOBJ.SetEnterHook(Func:EnterFieldFunc);
{}
begin
   vEnterHook := Func;
end; {FormOBJ.SetEnterHook}

procedure FormOBJ.SetHelpHook(Proc:HelpProc);
{}
begin
   vHelpHook := Proc;
end; {FormOBJ.SetHelpHook}

procedure FormOBJ.DisplayItems;
{}
var
   Temp: pItemNode;
begin
   Temp := vItemStack;
   while Temp <> Nil do
   begin
      if Temp^.Item^.vActive then
      begin
         if Temp = vActiveItem then
         begin
            Temp^.Item^.Display(HiStatus);
            Temp^.Item^.WriteLabel(HiStatus);
         end
         else
         begin
            Temp^.Item^.Display(Norm);
            Temp^.Item^.WriteLabel(Norm);
         end;
      end
      else
      begin
         Temp^.Item^.Display(Off);
         Temp^.Item^.WriteLabel(Off);
      end;
      Temp := Temp^.NextNode;
   end;
end; {FormOBJ.DisplayItems}

function FormOBJ.IDItemPtr(ID:word):pItemNode;
{returns a pointer to the item which has the specified ID --
 if no item is found the function returns nil}
var
  Temp: pItemNode;
  proceed: boolean;
begin
   Temp := vItemStack;
   Proceed := true;
   while (Temp <> Nil) and Proceed do
   begin
      if Temp^.Item^.vID = ID then
         Proceed := false
      else
         Temp := Temp^.NextNode;
   end;
   IDItemPtr := Temp;
end; {FormOBJ.IDItemPtr}

procedure FormOBJ.SetActiveItem(ID:word);
{}
begin
   vActiveItem := IDItemPtr(ID);
   if vActiveItem = nil then
      vActiveItem := vItemStack;
end; {FormOBJ.SetActiveItem}

function FormOBJ.HotkeyItemPtr(Hotkey:word):pItemNode;
{returns a pointer to the item which can be selected with the hotkey --
 if no item is found the function returns nil}
var
  Temp: pItemNode;
  proceed: boolean;
begin
   if Hotkey = 0 then    {1.10b}
   begin
      HotkeyItemPtr := nil;
      exit;
   end;
   if AlphabetTOT^.IsLower(HotKey) then
      HotKey := ord(AlphabetTOT^.GetUpcase(chr(HotKey)));
   if vActiveItem^.Item^.IsHotKey(Hotkey) then
      HotKeyItemPtr := vActiveItem
   else
   begin
      Proceed := true;
      Temp := vItemStack;
      while (Temp <> Nil) and Proceed do
      begin
         if Temp^.Item^.IsHotKey(Hotkey) then
            Proceed := false
         else
            Temp := Temp^.NextNode;
      end;
      HotkeyItemPtr := Temp;
   end;
end; {FormOBJ.HotkeyItemPtr}

function FormOBJ.HotSpotItemPtr(X,Y:byte):pItemNode;
{returns a pointer to the item which can has been clicked on with the mouse --
 if no item is found the function returns nil}
var
  Temp: pItemNode;
  proceed: boolean;
begin
   if vActiveItem^.Item^.OnTarget(X,Y) then   {1.00b}
      Temp := vActiveItem
   else
   begin
      Temp := vItemStack;
      Proceed := true;
      while (Temp <> Nil) and Proceed do
      begin
         if Temp^.Item^.OnTarget(X,Y) then
            Proceed := false
         else
            Temp := Temp^.NextNode;
      end;
   end;
   HotSpotItemPtr := Temp;
end; {FormOBJ.HotSpotItemPtr}

procedure FormOBJ.BroadcastSignal(TheSig:tSignal; SignalSource: pItemNode);
{recursive signal passer - an item which is handling a signal may raise
 an additional signal}
var
  ItemPtr: pItemNode;
  NewSig: tSignal;
begin
   ItemPtr := SignalSource;
   repeat
      {move on to next node}
      if ItemPtr^.NextNode <> nil then
         ItemPtr := ItemPtr^.NextNode
      else
         ItemPtr := vItemStack;
      NewSig.ID := 0;  {do nothing}
      ItemPtr^.Item^.HandleSignal(TheSig,NewSig);
      if NewSig.ID <> 0 then
         BroadcastSignal(NewSig,ItemPtr);
      if TheSig.ID = 0 then
      begin
         SignalSource^.Item^.ShutdownSignal(TheSig);
         if TheSIG.ID = 0 then
            exit
         else
            BroadcastSignal(TheSig,SignalSource);
      end;
   until ItemPtr = SignalSource;
   SignalSource^.Item^.ShutdownSignal(TheSig);
end; {FormOBJ.BroadcastSignal}

procedure FormOBJ.HelpTask(ID:word);
{}
begin
   vHelpHook(ID);
end; {FormOBJ.HelpTask}

function FormOBJ.CharTask(var K:word;var X,Y:byte;var FieldID:word):tAction;
{}
begin
   CharTask := vCharHook(K,X,Y,FieldID);
end; {FormOBJ.CharTask}

function FormOBJ.EnterTask(var NewID:word; OldID:word): tAction;
{}
begin
   EnterTask := vEnterHook(NewID,OldID);
end; {FormOBJ.EnterTask}

function FormOBJ.LeaveTask(var FieldID:word): tAction;
{}
begin
   LeaveTask := vLeaveHook(FieldID);
end; {FormOBJ.LeaveTask}

procedure FormOBJ.AdjustKey(var Key:word;var X,Y: byte);
{abstract}
begin end;

function FormOBJ.Go: tAction;
{}
var
   HookAction,
   Task : tAction;
   NewItemPtr: pItemNode;
   LastActiveItemID,ID,K,W: word;
   X,Y:byte;
   Mvisible:boolean;

   procedure ProcessTask;
   {}
   var TheSig: tSignal;
   begin
      case Task of
         NextField: begin
                       NewItemPtr := vActiveItem;
                       repeat
                          if NewItemPtr^.NextNode <> Nil then
                             NewItemPtr := NewItemPtr^.NextNode
                          else
                             NewItemPtr := vItemStack;
                        until NewItemPtr^.Item^.vActive;
                    end;
         PrevField: begin
                       NewItemPtr := vActiveItem;
                       repeat
                          if NewItemPtr^.PrevNode <> Nil then
                             NewItemPtr := NewItemPtr^.PrevNode
                          else
                             NewItemPtr := EndNode;
                        until NewItemPtr^.Item^.vActive;
                    end;
         Refresh: DisplayItems;
         Signal: begin
                    vActiveItem^.Item^.RaiseSignal(TheSig);
                    if TheSig.ID <> 0 then
                       BroadcastSignal(TheSig,vActiveItem);
                 end;
         Help: begin
                  HelpTask(LastActiveItemID);
                  if LastActiveItemID <> 0 then
                  begin
                     if LastActiveItemID <> HelpID then
                        if vActiveItem^.Item^.Suspend then
                           vActiveItem := IDItemPtr(LastActiveItemID);
                  end;
                  Task := vActiveItem^.Item^.Select(0,X,Y);
               end;
      end; {case}
   end; {ProcessTask}

   procedure ProcessChar;
   {}
   var Bypassing, Ignore : boolean;
   begin
      Key.GetInput;
      K := Key.LastKey;
      X := Key.LastX;
      Y := key.LastY;
      Ignore := false;
      AdjustKey(K,X,Y);
      if K = 600 then
         HookAction := Escaped
      else
      begin
         ID := vActiveItem^.Item^.vID;
         HookAction := CharTask(K,X,Y,ID);
      end;
      Case HookAction of
         Escaped,
         Finished,
         Stop1..Stop9 : begin
                          Task := HookAction;
                          exit;
                        end;
         Refresh: DisplayItems;
      end; {case}
      if ID <> vActiveItem^.Item^.vID then {hook changed the active field}
         NewItemPtr := IDItemPtr(ID)
      else
         NewItemPtr := HotKeyItemPtr(K);
      if NewItemPtr = nil then {no hotkey pressed}
      begin
         if (K = 513) or (K=523) then  {mouse Pressed}
         begin
            NewItemPtr := HotSpotItemPtr(X,Y);
            if NewItemPtr = vActiveItem then
            begin
               Task := vActiveItem^.Item^.ProcessKey(K,X,Y);
               ProcessTask;
               Ignore := true;
            end;
            if NewItemPtr = nil then
               Ignore := true
            else
               delay(175);         {avoids Mouse multi-select effect} {1.00m}
         end
         else
         begin
            Task := vActiveItem^.Item^.ProcessKey(K,X,Y);
            ProcessTask;
         end;
      end;
      if (NewItemPtr <> Nil) and (Ignore = false) then
      begin
         ByPassing := false;
         repeat
            if EscapingForm then
            begin
               Task := Escaped;
            end
            else if FormHelpCalled then
            begin
               HelpTask(vActiveItem^.Item^.vID);
               Task := none;
               FormHelpCalled := false;
            end
            else
            begin
               if Bypassing or vActiveItem^.Item^.Suspend then
               begin
                  {Leave Hook}
                  if (vActiveItem^.Item^.vActive)
                  and (Bypassing = false) then {don't Hook if Bypassing}
                  begin
                     ID := vActiveItem^.Item^.vID;
                     HookAction := LeaveTask(ID);
                     Case HookAction of
                        Escaped,
                        Finished,
                        Stop1..Stop9 : begin
                             Task := HookAction;
                             exit;
                           end;
                        Refresh: begin                           {1.00n}
                             DisplayItems;
                             vActiveItem^.Item^.Display(Norm);
                             vActiveItem^.Item^.WriteLabel(Norm); {1.10a -- thanks Peter!}
                           end;
                     end; {case}
                     if ID = StayPut then {1.00h}
                     begin
                        Task := None;
                        vActiveItem^.Item^.Display(HiStatus);         {1.00o}
                        exit;
                     end else if ID <> vActiveItem^.Item^.vID then {hook changed the active field}
                        NewItemPtr := IDItemPtr(ID);
                  end;
                  {Change active fields}
                  if NewItemPtr^.Item^.vActive then
                  begin
                     vActiveItem := NewItemPtr;
                     {Enter Hook}
                     ID := vActiveItem^.Item^.vID;
                     HookAction := EnterTask(ID,LastActiveItemID);
                     Case HookAction of
                        Escaped,
                        Finished,
                        Stop1..Stop9: begin
                                         Task := HookAction;
                                         exit;
                                      end;
                        Refresh: DisplayItems;
                     end; {case}
                     if ID <> vActiveItem^.Item^.vID then {hook changed the active field}
                     begin
                        ByPassing := true;
                        NewItemPtr := IDItemPtr(ID);
                        Task := None;
                     end
                     else
                     begin
                        ByPassing := false;
                        W := vActiveItem^.Item^.vID;
                        if ((W <> 0) and (W <> HelpID))
                        or ((W = HelpID) and ((K <> 513) and (K <> vActiveItem^.Item^.vHotKey))) then
                           LastActiveItemID := W;
                        Task := vActiveItem^.Item^.Select(K,X,Y);
                     end;
                  end
                  else
                  begin                {1.00d}
                     {No Enter Hook for inactive tasks}
                     Task := NewItemPtr^.Item^.Select(K,X,Y);
                     if not (Task in [Finished,Escaped,Stop1..Stop9]) then {1.00g}
                        ByPassing := true;
                  end;
                  ProcessTask;
               end
               else    {suspension failed due to validation error}
                  Task := None; {don't leave field}
            end;
         until (Bypassing = false) and ((Task in [NextField,PrevField]) = false);
      end;
   end; {ProcessChar}

begin
   EscapingForm := false;
   FormHelpCalled := false;
   DisplayItems;
   Mvisible := Mouse.Visible;
   if not MVisible then
      Mouse.Show;
   {No Enter Hook at initial start-up}
   if not vActiveItem^.Item^.Visible then
   begin
      vActiveItem := vItemStack;
      while (vActiveItem <> Nil) and (vActiveItem^.Item^.Visible = false) do
         vActiveItem := vActiveItem^.NextNode;
   end;
   if vActiveItem = nil then {no fields to edit}
   begin
      Go := None;  {1.00a}
   end
   else
   begin
      Task := vActiveItem^.Item^.Select(0,0,0);
      LastActiveItemID := vActiveItem^.Item^.vID;
      Task := None;
      Repeat
         ProcessChar;
      Until (Task in [Finished,Escaped,Stop1..Stop9]);
      Mouse.WaitForRelease;     {1.10a}
      if Task <> Escaped then
        if vActiveItem^.Item^.Suspend then;
      Go := Task;
   end;
   if not MVisible then
      Mouse.Hide;
   EscapingForm := false;
   FormHelpCalled := false;
end; {FormOBJ.Go}

function FormOBJ.StopID:word;
{1.00j}
begin
   If vActiveItem = nil then
      StopID := 0
   else
      StopID := vActiveItem^.Item^.vID;
end; {FormOBJ.StopID}

destructor FormOBJ.Done;
{frees all allocated memory for the linked list}
var
  Temp1, Temp2: pItemNode;
begin
   if vItemStack <> nil then
   begin
      Temp1 := vItemStack;
      Temp2 := Temp1^.NextNode;
      while Temp2 <> nil do
      begin
          Freemem(Temp1,sizeof(Temp1^));
          Temp1 := Temp2;
          Temp2 := Temp1^.NextNode;
      end;
      Freemem(Temp1,sizeof(Temp1^));
   end;
end; {destructor FormOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                }
{     W i n A c t i o n O B J   M E T H O D S    }
{                                                }
{||||||||||||||||||||||||||||||||||||||||||||||||}

constructor WinFormOBJ.Init;
{}
begin
   New(vWinPtr,Init);
   FormOBJ.Init;
end; {WinFormOBJ.Init}

procedure WinFormOBJ.AdjustKey(var Key:word;var X,Y: byte);
{}
var WX,WY: byte;
    TempX,TempY: integer;
begin
   vWinPtr^.WinKey(Key,X,Y);
   TempX := X;
   TempY := Y;
   WX := vWinPtr^.vBorder.X1;
   WY := vWinPtr^.vBorder.Y1;
   if (Key > 600) or (TempX < WX) or (TempY < WY) then
   begin
      TempX := 0;
      TempY := 0;
   end
   else
   begin
       Case vWinPtr^.vStyle of
       0: begin
          dec(TempX,pred(WX));
          dec(TempY,pred(WY));
       end;
       6: begin
          dec(TempX,pred(WX));
          dec(TempY,WY + 2);
       end;
       else begin
          dec(TempX,WX);
          dec(TempY,WY);
       end;
       end; {case}
   end;
   if TempX > 0 then
      X := TempX
   else
      X := 0;
   if TempY > 0 then
      Y := TempY
   else
      Y := 0;
end; {WinFormOBJ.AdjustKey}

(*
function WinFormOBJ.Win: MoveWinPtr;
{}
begin
   Win := vWinPtr;
end; {WinFormOBJ.Win}
*)

procedure WinFormOBJ.Draw;
{}
begin
   vWinPtr^.Draw;
end; {WinFormOBJ.DisplayItems}

destructor WinFormOBJ.Done;
{}
begin
   Dispose(vWinPtr,Done);
   FormOBJ.Done;
end; {WinFormOBJ.Done}

{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure IO1Init;
{initilizes objects and global variables}
begin
   new(IOTOT,Init);
end; {IO1Init}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
  {$IFDEF MEMORYDEBUG} writeln('TOTIO1 init sees ',memavail); {$ENDIF}
   IO1Init;
{$ENDIF}
end.
