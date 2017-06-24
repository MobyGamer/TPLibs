{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10t                            }

Unit totIO2;
{$I TOTFLAGS.INC}

{
 Development Notes:
          2/23/91   1.00a    Fixed '-' '+' character validation on
                             RealIOOBJ and FixedRealIOOBJ
          3/29/91   1.00b    Added SetValue to LinkIOOBJ
          4/08/91   1.00c    Problem entering negative exponents in RealIOOBJ
          5/20/91   1.00d    Corrected right justification on IntIOOBJ and RealIOOBJ
                    1.00e    Stopped cursor move when list field not selected
          5/23/91   1.00f    Added reaction to Mouse method 1
          6/11/91   1.00g    Corrected EraseDefault in FixedRealIOOBJ
          7/2/91    1.00h    Added IsNull methods to descendants of SingleLineIOOBJ
          7/23/91   1.00i    Corrected treatment of right-justified strings

          9/04/91   1.00j    Added SetNull methods to descendants of SingleLineIOOBJ
         10/03/91   1.00k    Removed #027 dependancy in CharIOOOBJ and FixedRealIOOBJ
         11/19/91   1.00l    Corrected Cursor movement problem with Erase
         02/03/92   1.00m    Changed decimal calc in E notation real fields
         06/23/92   1.00n    Fixed CharOK for Pictures during EraseDefault,
                             added PosCursor to SetValue, and changed
                             vFirstKey logic for null chars.
         09/28/92   1.00o    Corrected EraseDefault setting when mouse use
                             to change field. Updated cursor logic in fixed
                             real when erase default active.
         01/04/93   1.10     Added MoveCursor to Display
         05/03/93   1.10a    Modified LISTIOOBJ.getValue to return 0 (INC file)
         03/24/17   1.10t    Changed info methods to variables to improve speed/size
}

INTERFACE

uses DOS, CRT,
     totSYS, totLOOK, totFAST, totSTR, totINPUT, totWIN,
     totIO1, totMSG,  totLINK, totReal, totDATE;

CONST
   NumberError: array[1..2] of string[60] =
   (' The number you entered is out of range. ',
   ' Enter a number in the following range: ');
   DateError: array[1..6] of string[60] =
   (' The date you entered is invalid. ',
    ' Enter a date in the format:',
    ' The date you entered is too early. ',
    ' The earliest acceptable date is: ',
    ' The date you entered is too late. ',
    ' The latest acceptable date is: ');

TYPE
pSingleLineIOOBJ = ^SingleLineIOOBJ;
SingleLineIOOBJ = object (VisibleIOOBJ)
   vInsert: boolean;      {is field initially in insert mode}
   vRules: byte;          {erasedefault, jumpiffull..... etc.}
   vFirstKey: boolean;    {has the user entered a key yet}
   vDispChar: char;       {character displayed when key is pressed}
   vPad : Char;           {character used to pad empty part of field}
   {methods ...}
   constructor Init;
   procedure   SetIns(InsOn:boolean);
   procedure   SetRules(Rules:byte);
   procedure   SetDispChar(Ch:char);
   procedure   SetPadChar(Pad:char);
   procedure   SetFieldAttr(Status:tStatus; var Attr:byte; var Str:string);
   procedure   InsertAction(InsOn:boolean);                     VIRTUAL;
   destructor  Done;                                            VIRTUAL;
end;  {SingleLineIOOBJ}

pCharIOOBJ = ^CharIOOBJ;
CharIOOBJ = object (SingleLineIOOBJ)
   vFieldLen: byte;
   vMaxlen : byte;
   vInputStr: StrScreen;
   vCursor: tCursPos;     {cursleft cursright cursprevious}
   vCursorStr: byte;      {position of cursor in string}
   vJust: tJust;          {left center right}
   {methods ...}
   constructor Init(X,Y,FieldLen: byte);
   procedure   SetJust(Just:tJust);
   procedure   SetCursor(Curs: tCursPos);
   procedure   ClearMessage;
   function    IsNull:boolean;
   procedure   SetNull;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;         VIRTUAL;
   function    CharOK(var Ch:char): boolean;                    VIRTUAL;
   procedure   Erase;                                           VIRTUAL;
   procedure   CursorEnd;                                       VIRTUAL;
   procedure   CursorHome;                                      VIRTUAL;
   procedure   CursorLeft;                                      VIRTUAL;
   procedure   CursorRight;                                     VIRTUAL;
   procedure   DeleteChar;                                      VIRTUAL;
   procedure   Backspace;                                       VIRTUAL;
   procedure   MoveCursor;                                      VIRTUAL;
   function    ProcessEnter:tAction;                            VIRTUAL;
   procedure   ReDisplay(Status:tStatus);                       VIRTUAL;
   procedure   InitCursor;                                      VIRTUAL; {1.00n}
   procedure   PosCursor;                                       VIRTUAL;
   procedure   Display(Status:tStatus);                         VIRTUAL;
   procedure   ProcessChar(Ch:char);                            VIRTUAL;
   procedure   Activate;                                        VIRTUAL;
   function    Select(K:word; X,Y:byte): tAction;               VIRTUAL;
   function    Suspend:boolean;                                 VIRTUAL;
   destructor  Done;                                            VIRTUAL;
end; {object CharIOOBJ}

pStringIOOBJ = ^StringIOOBJ;
StringIOOBJ = object (CharIOOBJ)
   vCase: tCase;            {lower upper proper}
   vForceCase: boolean;     {adjust case of characters during input}
   {methods ...}
   constructor Init(X,Y,FieldLen: byte);
   procedure   SetCase(Cas:tCase);
   procedure   SetForceCase(On:boolean);
   procedure   SetValue(Str:string);
   function    GetValue: string;
   procedure   ReDisplay(Status:tStatus);                   VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {StringIOOBJ}

pPictureIOOBJ = ^PictureIOOBJ;
PictureIOOBJ = object (StringIOOBJ)
   vPicture: string[80];
   vCursorScr: byte;          {position of cursor including format characters}
   vAllowChar: string[40];    {allowable characters}
   vDisAllowChar: string[40]; {disallowed characters}
   {methods ...}
   constructor Init(X,Y: byte;Pic:string);
   function    InputChars: byte;
   function    CursorOffset(InputPos:byte):byte;
   procedure   SetAllowChar(Str:string);
   procedure   SetDisallowChar(Str:string);
   function    GetValue: string;
   function    GetPicValue: string;
   function    CharOK(var Ch:char):boolean;                 VIRTUAL;
   procedure   Erase;                                       VIRTUAL;
   procedure   CursorEnd;                                   VIRTUAL;
   procedure   CursorHome;                                  VIRTUAL;
   procedure   CursorLeft;                                  VIRTUAL;
   procedure   CursorRight;                                 VIRTUAL;
   procedure   DeleteChar;                                  VIRTUAL;
   procedure   Backspace;                                   VIRTUAL;
   procedure   PosCursor;                                   VIRTUAL;
   procedure   InitCursor;                                  VIRTUAL;
   procedure   MoveCursor;                                  VIRTUAL;
   procedure   ReDisplay(Status:tStatus);                   VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {PictureIOOBJ}

pLateralIOOBJ = ^LateralIOOBJ;
LateralIOOBJ = object (StringIOOBJ)
   vStartChar: byte;         {the number of the first visible character}
   {methods ...}
   constructor Init(X,Y,FieldLen,MaxLen: byte);
   function    CursorOffset(InputPos:byte):byte;
   procedure   SetNull;
   function    GetValue: string;
   procedure   Erase;                                       VIRTUAL;
   procedure   CursorEnd;                                   VIRTUAL;
   procedure   CursorHome;                                  VIRTUAL;
   procedure   CursorLeft;                                  VIRTUAL;
   procedure   CursorRight;                                 VIRTUAL;
   procedure   DeleteChar;                                  VIRTUAL;
   procedure   Backspace;                                   VIRTUAL;
   procedure   PosCursor;                                   VIRTUAL;
   procedure   InitCursor;                                  VIRTUAL;
   procedure   MoveCursor;                                  VIRTUAL;
   procedure   ReDisplay(Status:tStatus);                   VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {LateralIOOBJ}

pListIOOBJ = ^ListIOOBJ;
ListIOOBJ = object (MultiLineIOOBJ)
   vTopPick: integer;         {number of first pick in window}
   vTotPicks: integer;        {total number of picks}
   vListAssigned: boolean;    {is data assigned to list}
   vScrollBarOn: boolean;     {is the vertical scrollbar required}
   vBoxBorder: boolean;       {is the list enclosed in a box}
   vActivePick: integer;      {the offset of the active pick from the top}
   vActiveField: boolean;     {is field highlighted}
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte;Title:string);
   procedure   WriteItem(Item:integer; Selected:boolean);
   procedure   DisplayAllPicks;
   procedure   RefreshScrollbar;
   function    HitItem(Y:byte):byte;
   procedure   ScrollJump(Y:byte);
   procedure   ScrollUp;
   procedure   ScrollDown;
   procedure   ScrollPgUp;
   procedure   ScrollPgDn;
   procedure   ScrollEnd;
   procedure   ScrollHome;
   procedure   AdjustMouseKey(var InKey: word;X,Y:byte);
   function    TargetPick(X,Y:byte): longint;
   procedure   MouseChoose(X,Y:byte);
   function    GetValue: integer;
   procedure   SetValue(Hi:integer); {1.00b}
   procedure   ShowItemDetails(HiPick: integer);            VIRTUAL;
   function    SelectPick(InKey:word;X,Y:byte): tAction;    VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;            VIRTUAL;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;     VIRTUAL;
   procedure   Display(Status:tStatus);                     VIRTUAL;
   function    Suspend:boolean;                             VIRTUAL;
   function    GetString(Pick:integer): string;             VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {ListIOOBJ}

pArrayIOOBJ = ^ArrayIOOBJ;
ArrayIOOBJ = object (ListIOOBJ)
   vArrayPtr: pointer;
   vStrLength: byte;
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte;Title:string);
   procedure   AssignList(var StrArray; Total:Longint; StrLength:byte);
   function    GetString(Pick:integer): string;             VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {ArrayIOOBJ}

pLinkIOOBJ = ^LinkIOOBJ;
LinkIOOBJ = object (ListIOOBJ)
   vLinkList: ^DLLOBJ;
   {methods ...}
   constructor Init(X1,Y1,width,depth:byte;Title:string);
   procedure   AssignList(var LinkList: DLLOBJ);
   function    GetString(Pick:integer): string;             VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {LinkIOOBJ}

pIntIOOBJ = ^IntIOOBJ;
IntIOOBJ = object (CharIOOBJ)
   vMin: longint;
   vMax: longint;
   vFmtPtr: pFmtNumberOBJ;
   {methods...}
   constructor Init(X,Y,Len: byte);
   procedure   InitFormat;
   function    FormatPtr: pFmtNumberOBJ;
   function    GetValue: longint;
   procedure   SetValue(Val:longint);
   procedure   SetMinMax(Min,Max: longint);
   function    CharOK(var Ch:char):boolean;                 VIRTUAL;
   procedure   ReDisplay(Status:tStatus);                   VIRTUAL;
   function    Suspend:boolean;                             VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {object IntIOOBJ}

pRealIOOBJ = ^RealIOOBJ;
RealIOOBJ = object (CharIOOBJ)
   vMin: Extended;
   vMax: Extended;
   vENotation: boolean;
   vFmtPtr: pFmtNumberOBJ;
   {methods...}
   constructor Init(X,Y,Len:byte);
   procedure   InitFormat;
   function    FormatPtr: pFmtNumberOBJ;
   function    GetValue: extended;
   procedure   SetMinMax(Min,Max:extended);
   procedure   SetValue(Val:extended);
   procedure   SetENotation(On:Boolean);
   function    CharOK(var Ch:char):boolean;                 VIRTUAL;
   procedure   ReDisplay(Status:tStatus);                   VIRTUAL;
   function    Suspend:boolean;                             VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {RealIOOBJ}

pFixedRealIOOBJ = ^FixedRealIOOBJ;
FixedRealIOOBJ = object (SingleLineIOOBJ)
   vMin: Extended;
   vMax: Extended;
   vDP: byte;
   vWholeP: byte;
   vMaxlen : byte;
   vCursorPos: byte;
   vWholeStr: StrVisible;
   vDPStr: string[20]; {max significance of Turbo reals}
   vFmtPtr: pFmtNumberOBJ;
   {methods...}
   constructor Init(X,Y,Whole,DP:byte);
   procedure   InitFormat;
   function    FormatPtr: pFmtNumberOBJ;
   function    IsNull:boolean;
   procedure   SetNull;
   procedure   Erase;
   procedure   CursorEnd;
   procedure   CursorHome;
   procedure   CursorLeft;
   procedure   CursorRight;
   procedure   DeleteChar;
   procedure   Backspace;
   function    GetValue: extended;
   procedure   SetMinMax(Min,Max:extended);
   procedure   SetValue(Val:extended);
   procedure   ProcessChar(Ch:char);
   function    ProcessEnter:tAction;
   procedure   Condense;
   procedure   PeriodHit;
   procedure   PlusHit;
   procedure   MinusHit;
   procedure   MoveCursor;
   procedure   Display(Status:tStatus);                         VIRTUAL;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;         VIRTUAL;
   procedure   Activate;                                        VIRTUAL;
   function    Select(K:word; X,Y:byte): tAction;               VIRTUAL;
   function    Suspend:boolean;                                 VIRTUAL;
   destructor  Done;                                            VIRTUAL;
end; {FixedRealIOOBJ}

pDateIOOBJ = ^DateIOOBJ;
DateIOOBJ = object (PictureIOOBJ)
   vDateFmt: tdate;
   vMin: longint;
   vMax: longint;
   {methods...}
   constructor Init(X,Y:byte;DateFmt:tDate);
   procedure   SetMinMax(Min,Max:longint);
   procedure   SetValue(Date:longint);
   function    GetValue: longint;
   function    Suspend:boolean;                                 VIRTUAL;
   destructor  Done;                                            VIRTUAL;
end; {DateIOOBJ}

pHexIOOBJ = ^HexIOOBJ;
HexIOOBJ = object (PictureIOOBJ)
   vMin: longint;
   vMax: longint;
   {methods...}
   constructor Init(X,Y,Len:byte);
   procedure   SetMinMax(Min,Max:longint);
   procedure   SetValue(Val:longint);
   function    GetValue: longint;
   function    Suspend:boolean;                                 VIRTUAL;
   destructor  Done;                                            VIRTUAL;
end; {HexIOOBJ}

procedure IO2Init;

var
  FmtNumberTOT: FmtNumberOBJ;
  
IMPLEMENTATION

procedure ValidationMessage(Line1,Line2,Line3,Line4:string);
{}
var
   Msg: MessageOBJ;
begin
   with Msg do
   begin
      Init(2,' Invalid Input! ');
      AddLine('');
      AddLine(' '+Line1);
      AddLine(' '+Line2);
      AddLine(' '+Line3);
      AddLine(' '+Line4);
      AddLine('');
      Show;
      Done;
   end; {with}
end; {ValidationMessage}
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                      }
{     S i n g l e L i n e I O O B J   M E T H O D S    }
{                                                      }
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor SingleLineIOOBJ.Init;
{}
begin
   VisibleIOOBJ.Init;
   vDispChar := ' ';
   vInsert := IOTOT^.vInsert;
   vRules := IOTOT^.vRules;
   vPad := IOTOT^.vInputPad;
end; {SingleLineIOOBJ.Init}

procedure SingleLineIOOBJ.InsertAction(InsOn:boolean);
{}
begin
   if InsOn then
      Screen.CursHalf
   else
      Screen.CursOn;
end; {SingleLineIOOBJ.ChangeMode}

procedure SingleLineIOOBJ.SetIns(InsOn:boolean);
{}
begin
   vInsert := InsOn;
end; {SingleLineIOOBJ.SetIns}

procedure SingleLineIOOBJ.SetRules(Rules:byte);
{}
begin
   vRules := Rules;
end; {SetRules}

procedure SingleLineIOOBJ.SetPadChar(Pad:char);
{}
begin
   vPad := Pad;
end; {SingleLineIOOBJ.SetPadChar}

procedure SingleLineIOOBJ.SetFieldAttr(Status:tStatus; var Attr:byte; var Str:string);
{}
begin
   case Status of
   HiStatus:    Attr := IOTOT^.FieldCol(2);
   Norm:  Attr := IOTOT^.FieldCol(1);
   Off:   Attr := IOTOT^.FieldCol(4);
   end; {case}
   if (vDispChar <> ' ') then
      Str := Replicate(length(Str),vDispChar);
end; {SingleLineIOOBJ.SetFieldAttr}

procedure SingleLineIOOBJ.SetDispChar(Ch:char);
{}
begin
   vDispChar := Ch;
end; {SingleLineIOOBJ.SetDispChar}

destructor SingleLineIOOBJ.Done;
{}
begin
   VisibleIOOBJ.Done;
end; {SingleLineIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||}
{                                          }
{     C h a r I O O B J   M E T H O D S    }
{                                          }
{||||||||||||||||||||||||||||||||||||||||||}
constructor CharIOOBJ.Init(X,Y,FieldLen: byte);
{}
var
  W : byte;
begin
   SingleLineIOOBJ.Init;
   vInputStr := '';
   vCursor := IOTOT^.vCursorLoc;
   vCursorStr := 1;
   vJust := IOTOT^.vInputJust;
{$IFDEF CHECK}
   W := Monitor^.Width;
   if X > W then
      vBoundary.X1 := 1
   else
      vBoundary.X1 := X;
   vBoundary.Y1 := Y;
   vBoundary.Y2 := vBoundary.Y1;
   if pred(vBoundary.X1 + FieldLen) > W then
      vFieldLen := succ(W - vBoundary.X1)
   else
      vFieldLen := FieldLen;
   vBoundary.X2 := pred(vBoundary.X1 + FieldLen);
{$ELSE}
   vBoundary.X1 := X;
   vBoundary.X2 := pred(vBoundary.X1 + FieldLen);
   vBoundary.Y1 := Y;
   vBoundary.Y2 := vBoundary.Y1;
   vFieldlen := FieldLen;
{$ENDIF}
   vMaxlen := vFieldLen;
end; {cons CharIOOBJ.Init}

function CharIOOBJ.IsNull:boolean; {1.00h}
{}
begin
   IsNull := vInputStr = '';
end; {CharIOOBJ.IsNull}

procedure CharIOOBJ.SetNull;   {1.00j}
{}
begin
   vInputStr := '';
   vCursorStr := 1;
end; {CharIOOBJ.SetNull}

procedure CharIOOBJ.SetCursor(Curs:tCursPos);
{}
begin
   vCursor := Curs;
end; {CharIOOBJ.SetCurs}

procedure CharIOOBJ.SetJust(Just:tJust);
{}
begin
   vJust := Just;
end; {CharIOOBJ.SetJust}

procedure CharIOOBJ.CursorHome;
{}
begin
   vCursorStr := 1;
   ReDisplay(HiStatus);        {1.00i}
end; {CharIOOBJ.CursorHome}

procedure CharIOOBJ.CursorEnd;
{}
begin
   if (vCursorStr <= length(vInputStr)) then
      vCursorStr := succ(length(vInputStr));
end; {CharIOOBJ.CursorEnd}

procedure CharIOOBJ.CursorLeft;
{}
begin
   if vCursorStr > 1 then
      dec(vCursorStr);
end; {CharIOOBJ.CursorLeft}

procedure CharIOOBJ.CursorRight;
{}
begin
   if (vCursorStr <= length(vInputStr)) then
      if (vCursorStr <= vMaxLen) then
         inc(vCursorStr);
end; {CharIOOBJ.CursorRight}

procedure CharIOOBJ.Erase;
{}
begin
   vInputStr := '';
   vCursorStr := 1;
   Display(HiStatus);
   MoveCursor;                        {1.00l}
end; {CharIOOBJ.Erase}

procedure CharIOOBJ.DeleteChar;
{}
begin
  delete(vInputStr,vCursorStr,1);
  ReDisplay(HiStatus);                {1.00i}
end; {CharIOOBJ.DeleteChar}

procedure CharIOOBJ.BackSpace;
{}
begin
   if vCursorStr > 1 then
   begin
      CursorLeft;
      DeleteChar;
      ReDisplay(HiStatus)
   end;
end; {CharIOOBJ.BackSpace}

function CharIOOBJ.ProcessEnter:tAction;
{}
begin
   ProcessEnter := Enter;
end; {CharIOOBJ.ProcessEnter}

procedure CharIOOBJ.MoveCursor;
{}
begin
   Screen.GotoXY(pred(vBoundary.X1)+vCursorStr,vBoundary.Y1);
end; {CharIOOBJ.MoveCursor}

procedure CharIOOBJ.InitCursor;
{}
begin
   if vCursor = CursLeft then
      vCursorStr := 1
   else
      vCursorStr := succ(length(vInputStr));
end; {CharIOOBJ.InitCursor}

procedure CharIOOBJ.PosCursor;
{}
begin
   case vCursor of
      CursLeft:  vCursorStr := 1;
      CursRight: vCursorStr := succ(length(vInputStr));
      CursPrev:  {do nothing};
   end; {case}
end; {CharIOOBJ.PosCursor}

procedure CharIOOBJ.ReDisplay(Status:tStatus);
{abstract}
begin end;

procedure CharIOOBJ.Display(Status:tStatus);
{}
begin
   PosCursor;
   if Status = hiStatus then
      MoveCursor; {1.10}
   ReDisplay(Status);
end; {CharIOOBJ.Display}

function CharIOOBJ.CharOK(var Ch:char): boolean;
{}
begin
   CharOK := true;
end; {CharIOOBJ.CharOK}

procedure CharIOOBJ.ProcessChar(Ch:char);
{}

   procedure EraseOld;
   {}
   begin
      if vFirstKey and ((vRules and EraseDefault) = EraseDefault) then
         Erase;
   end; {EraseOld}

begin
   if ( ( (vInsert and (length(vInputStr) >= vMaxlen))
          or
          (vCursorStr > vMaxLen)
        )
        and
        ((vFirstKey and ((vRules and EraseDefault) = EraseDefault))=false)
      ) then
      Ding
   else
   begin
      if CharOK(Ch) then
         EraseOld
      else
      begin
         Ding;
         exit
      end;
      if not vInsert then
         Delete(vInputStr,vCursorStr,1);
      insert(Ch,vInputStr,vCursorStr);
      CursorRight;
      ReDisplay(HiStatus);
   end;
end; {CharIOOBJ.ProcessChar}

function CharIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;
{}
begin
   Case InKey of
      8: BackSpace;
      288: Erase;  {Alt-D}
      339: DeleteChar;
      327: CursorHome;
      335: CursorEnd;
      331: CursorLeft;
      333: CursorRight;
      338: begin
              vInsert := not vInsert;
              InsertAction(vInsert);
           end;
      32..255: ProcessChar(chr(InKey));    {characters}
   end; {case}
   case InKey of
      523,13: ProcessKey := ProcessEnter;
      (* 1.00k
      27: ProcessKey := Escaped;
      *)
      else 
      begin
         if  ((vRules and JumpIfFull) = JumpIfFull)
         and (length(vInputStr) >= vMaxlen)
         and ( (Inkey >= 32) and (InKey <= 255)) 
         and (vCursorStr > vMaxLen) then
            ProcessKey := NextField
         else
            ProcessKey := None;
      end;
   end;
   if (Inkey > 0) and (Inkey < 255) then  {1.00n}
      vFirstKey := false;
   MoveCursor;
end; {CharIOOBJ.ProcessKey}

procedure CharIOOBJ.Activate;
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
      until Action in [Finished,Escaped,Enter];
   until (Action = Escaped) or Suspend;
end; {CharIOOBJ.Activate}

function CharIOOBJ.Select(K:word; X,Y:byte): tAction;
{}
begin
   Display(HiStatus);
   WriteLabel(HiStatus);
   WriteMessage;
   vFirstKey := true;
   InsertAction(vInsert);
   PosCursor;
   MoveCursor;
   Select := None;
end; {CharIOOBJ.Select}

procedure CharIOOBJ.ClearMessage;
{}
var Col,L: byte;
begin
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
end; {CharIOOBJ.ClearMessage}

function CharIOOBJ.Suspend:boolean;
{}
begin
   ReDisplay(Norm);
   WriteLabel(Norm);
   ClearMessage;
   Suspend := true;
end; {CharIOOBJ.Suspend}

destructor CharIOOBJ.Done;
{}
begin
   SingleLineIOOBJ.Done;
end; {CharIOOBJ.Done}

{||||||||||||||||||||||||||||||||||||||||||||||}
{                                              }
{     S t r F i e l d O B J   M E T H O D S    }
{                                              }
{||||||||||||||||||||||||||||||||||||||||||||||}
constructor StringIOOBJ.Init(X,Y,FieldLen: byte);
{}
begin
   CharIOOBJ.Init(X,Y,FieldLen);
   vCase := IOTOT^.vCase;
   vForceCase := IOTOT^.vForceCase;
end; {StringIOOBJ.Init}

procedure StringIOOBJ.SetValue(Str:string);
{}
begin
   vInputStr := Str;
   if vCursorStr > succ(length(Str)) then
      vCursorStr :=  succ(length(Str));
   InitCursor;
end; {StringIOOBJ.SetValue}

procedure StringIOOBJ.SetCase(Cas:tCase);
{}
begin
   vCase := Cas;
end; {StringIOOBJ.SetCase}

procedure StringIOOBJ.SetForceCase(On:boolean);
{}
begin
   vForceCase := On;
end; {StringIOOBJ.SetForceCase}

function StringIOOBJ.GetValue: string;
{}
begin
   GetValue := vInputStr;
end; {StringIOOBJ.GetValue}

procedure StringIOOBJ.ReDisplay(Status:tStatus);
{}
var
  A: byte;
  AdjStr: String;
begin
   if (Status <> HiStatus)
   or ((Status = HiStatus) and vForceCase) then
      vInputStr := AdjCase(vCase,vInputStr);
   if (vDispChar = ' ') then
      AdjStr := vInputStr
   else
      AdjStr := Replicate(length(vInputStr),vDispChar);
   if Status = HiStatus then
   begin
     SetFieldAttr(Status,A,AdjStr);
     Screen.WriteAt(vBoundary.X1,vBoundary.Y1,A,padleft(AdjStr,vFieldlen,vPad));
   end
   else
   begin
      SetFieldAttr(Status,A,AdjStr);  {was norm}
      AdjStr := Pad(vJust,AdjStr,vFieldLen,vPad);
      Screen.WriteAt(vBoundary.X1,vBoundary.Y1,A,AdjStr);
   end;
end; {StringIOOBJ.ReDisplay}

destructor StringIOOBJ.Done;
{}
begin
   CharIOOBJ.Done;
end; {StringIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                    }
{     P i c S t r F i e l d O B J   M E T H O D S    }
{                                                    }
{||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor PictureIOOBJ.Init(X,Y: byte;Pic:string);
{}
begin
   StringIOOBJ.Init(X,Y,length(Pic));
   vPicture := Pic;
   vFieldLen := InputChars;
   vMaxlen := vFieldlen;
   vAllowChar := '';
   vDisAllowChar := '';
   SetIns(IOTOT^.vInsert);
end; {PictureIOOBJ.Init}

function PictureIOOBJ.InputChars: byte;
{}
var
  Counter : byte;
  I : integer;
begin
  Counter := 0;
  for I := 1 to length(vPicture) do
      if vPicture[I] in FmtChars then
         Inc(Counter);
  InputChars := counter;
end; {PictureIOOBJ.InputChars}

procedure PictureIOOBJ.SetAllowChar(Str:string);
{}
begin
   vAllowChar := Str;
end; {PictureIOOBJ.SetAllowChar}

procedure PictureIOOBJ.SetDisAllowChar(Str:string);
{}
begin
   vDisAllowChar := Str;
end; {PictureIOOBJ.SetDisAllowChar}

procedure PictureIOOBJ.ReDisplay(Status:tStatus);
{}
var
  A,B,Len: byte;
  Counter,I: integer;
  AdjStr,
  TempStr : string;
begin
   AdjStr := vInputStr;
   SetFieldAttr(Status,A,AdjStr);
   if Status <> HiStatus Then
   begin
      vInputStr := AdjCase(vCase,vInputStr);
      TempStr := PicFormat(AdjStr,vPicture,vPad);
      Screen.WriteAt(vBoundary.X1,vBoundary.Y1,A,TempStr);
   end
   else
   begin
     B := IOTot^.FieldCol(3);
     Counter := 0;
     Len := length(vInputStr);
     for I := 1 to length(vPicture) do
     begin
        if (vPicture[I] in FmtChars) then
        begin
           inc(Counter);
           if Counter <= Len then
              Screen.WriteAt(vBoundary.X1 + pred(I),vBoundary.Y1,A,vInputStr[Counter])
           else
              Screen.WriteAt(vBoundary.X1 + pred(I),vBoundary.Y1,A,vPad);
        end
        else
           Screen.WriteAt(vBoundary.X1 + pred(I),vBoundary.Y1,B,vPicture[I]);
     end;
   end;
end; {PictureIOOBJ.ReDisplay}

function PictureIOOBJ.CursorOffset(InputPos:byte):byte;
{}
var
   Counter: byte;
   CharPos: byte;
   L : byte;
begin
   Counter := 0;
   CharPos := 0;
   L := length(vPicture);
   repeat
      inc(Counter);
      if vPicture[Counter] in FmtChars then
         inc(CharPos);
   until (CharPos = InputPos) or (Counter > L);
   CursorOffset := Counter + pred(vBoundary.X1);
end; {PictureIOOBJ.CursorOffset}

procedure PictureIOOBJ.InitCursor;
{}
begin
   StringIOOBJ.InitCursor;
   vCursorScr := CursorOffset(vCursorStr);
end; {Picture.InitCursor}

procedure PictureIOOBJ.PosCursor;
{}
begin
   StringIOOBJ.PosCursor;
   vCursorScr := CursorOffset(vCursorStr);
end; {PictureIOOBJ.PosCursor}

procedure PictureIOOBJ.Erase;
{}
begin
   vInputStr := '';
   vCursorStr := 1;
   PosCursor;
   Display(HiStatus);
end; {PictureIOOBJ.Erase}

procedure PictureIOOBJ.CursorHome;
{}
begin
   vCursorStr := 1;
   vCursorScr := CursorOffset(vCursorStr);
end; {PictureIOOBJ.CursorHome}

procedure PictureIOOBJ.CursorEnd;
{}
begin
   if (vCursorStr <= length(vInputStr)) then
   begin
      vCursorStr := succ(length(vInputStr));
      vCursorScr := CursorOffset(vCursorStr);
   end;
end; {PictureIOOBJ.CursorEnd}

procedure PictureIOOBJ.CursorLeft;
{}
begin
   if vCursorStr > 1 then
   begin
      dec(vCursorStr);
      Repeat
         dec(vCursorScr);
      Until vPicture[succ(vCursorScr - vBoundary.X1)] in FmtChars;
   end;
end; {PictureIOOBJ.CursorLeft}

procedure PictureIOOBJ.CursorRight;
{}
begin
   if (vCursorStr <= length(vInputStr)) then
   begin
      Inc(vCursorStr);
      Repeat
         Inc(vCursorScr);
      Until (succ(vCursorScr-vBoundary.X1) > length(vPicture))
         or (vPicture[succ(vCursorScr - vBoundary.X1)] in FmtChars);
   end;
end; {PictureIOOBJ.CursorRight}

procedure PictureIOOBJ.DeleteChar;
{}
begin
  delete(vInputStr,vCursorStr,1);
  ReDisplay(HiStatus);
end; {PictureIOOBJ.DeleteChar}

procedure PictureIOOBJ.BackSpace;
{}
begin
   if vCursorStr > 1 then
   begin
      CursorLeft;
      DeleteChar;
      ReDisplay(HiStatus)
   end;
end; {PictureIOOBJ.BackSpace}

function PictureIOOBJ.CharOK(var Ch:char):boolean;
{}
var
   PicChar : char;
begin
   if ((vAllowChar <> '') and (pos(Ch,vAllowChar) = 0))
   or ((vDisAllowChar <> '') and (pos(Ch,vDisAllowChar) > 0)) then
      CharOK := false
   else
   begin
      if vFirstKey and ((vRules and EraseDefault) = EraseDefault) then {1.00n}
         PicChar := vPicture[CursorOffset(1)-pred(vBoundary.X1)]
      else
         PicChar := vPicture[succ(vCursorScr - vBoundary.X1)];
      if PicChar = '!' then
         Ch := upcase(Ch);
      CharOK :=  ((Ch in ['0'..'9',FmtNumberTOT.GetDecimal,'-']) and (PicChar = '#'))
              or ((AlphabetTOT^.IsLetter(ord(Ch)) or AlphabetTOT^.IsPunctuation(ord(Ch))) and (PicChar = '@'))
              or (PicChar in ['*','!']);
      end;
end; {PictureIOOBJ.CharOK}

procedure PictureIOOBJ.MoveCursor;
{}
begin
   Screen.GotoXY(vCursorScr,vBoundary.Y1);
end; {PictureIOOBJ.MoveCursor}

function PictureIOOBJ.GetValue:string;
{}
begin
   GetValue := vInputStr;
end; {PictureIOOBJ.GetValue}

function PictureIOOBJ.GetPicValue:string;
{}
begin
   GetPicValue := PicFormat(vInputStr,vPicture,' ');
end; {PictureIOOBJ.GetPicValue}

destructor PictureIOOBJ.Done;
{}
begin
   CharIOOBJ.Done;
end; {PictureIOOBJ.Done}

{||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                }
{     L a t e r a l I O O B J   M E T H O D S    }
{                                                }
{||||||||||||||||||||||||||||||||||||||||||||||||}

constructor LateralIOOBJ.Init(X,Y,FieldLen,MaxLen: byte);
{}
begin
   StringIOOBJ.Init(X,Y,FieldLen);
   vStartChar := 1;
{$IFDEF CHECK}
   if Maxlen < vFieldlen then
      vMaxlen := vFieldLen
   else
      vMaxLen := MaxLen;
{$ELSE}
   vMaxLen := MaxLen;
{$ENDIF}
end; {LateralIOOBJ.Init}

procedure LateralIOOBJ.ReDisplay(Status:tStatus);
{}
var
  A: byte;
  AdjStr,
  TempStr : string;
begin
   if (Status <> HiStatus)
   or ((Status = HiStatus) and vForceCase) then
      vInputStr := AdjCase(vCase,vInputStr);
   case Status of
     HiStatus:    A:= IOTOT^.FieldCol(2);
     Norm:  A:= IOTOT^.FieldCol(1);
     Off:   A:= IOTOT^.FieldCol(4);
   end; {case}
   if (vDispChar = ' ') then
      AdjStr := vInputStr
   else
      AdjStr := Replicate(length(vInputStr),vDispChar);
   if Status <> HiStatus then
      vInputStr := AdjCase(vCase,vInputStr);
   TempStr := TruncFormat(AdjStr,vStartChar,vFieldLen,vPad);
   Screen.WriteAt(vBoundary.X1,vBoundary.Y1,A,TempStr);
end; {LateralIOOBJ.ReDisplay}

function LateralIOOBJ.CursorOffset(InputPos:byte):byte;
{}
begin
   CursorOffset := succ(InputPos - vStartChar)
end; {LateralIOOBJ.CursorOffset}

procedure LateralIOOBJ.InitCursor;
{}
begin
   if vCursor = CursLeft then
   begin
      vCursorStr := 1;
      vStartChar := 1;
   end
   else
   begin
      vCursorStr := succ(length(vInputStr));
      if vCursorStr - vStartChar > vFieldLen then
         vStartChar := vCursorStr - vFieldLen;
   end;
end; {LateralIOOBJ.InitCursor}

procedure LateralIOOBJ.PosCursor;
{}
begin
   case vCursor of
      CursLeft:  begin
                    vCursorStr := 1;
                    vStartChar := 1;
                 end;
      CursRight: begin
                    vCursorStr := succ(length(vInputStr));
                    if vCursorStr - vStartChar > vFieldLen then
                       vStartChar := vCursorStr - vFieldLen;
                 end;
      CursPrev:  {do nothing};
   end; {case}
end; {LateralIOOBJ.PosCursor}

procedure LateralIOOBJ.CursorHome;
{}
begin
   vCursorStr := 1;
   if vStartChar <> 1 then
   begin
      vStartChar := 1;
      ReDisplay(HiStatus);
   end;
end; {LateralIOOBJ.CursorHome}

procedure LateralIOOBJ.CursorEnd;
{}
begin
   if (vCursorStr <= length(vInputStr)) then
   begin
      vCursorStr := succ(length(vInputStr));
      if (vCursorStr - vStartChar) > vFieldLen then
      begin
         vStartChar := vCursorStr - vFieldLen;
         ReDisplay(HiStatus);
      end;
   end;
end; {LateralIOOBJ.CursorEnd}

procedure LateralIOOBJ.CursorLeft;
{}
begin
   if vCursorStr > 1 then
   begin
      if vCursorStr = vStartChar then
      begin
         dec(vStartChar);
         dec(vCursorStr);
         ReDisplay(HiStatus)
      end
      else
         dec(vCursorStr);
   end;
end; {LateralIOOBJ.CursorLeft}

procedure LateralIOOBJ.CursorRight;
{}
begin
   if (vCursorStr <= length(vInputStr)) then
   begin
      if vCursorStr - vStartChar = vFieldLen then
      begin
         inc(vStartChar);
         inc(vCursorStr);
         ReDisplay(HiStatus);
      end
      else
         inc(vCursorStr);
   end;
end; {LateralIOOBJ.CursorRight}

procedure LateralIOOBJ.SetNull;   {1.00j}
{}
begin
   StringIOOBJ.SetNull;
   vStartChar := 1;
end; {LateralIOOBJ.SetNull}

procedure LateralIOOBJ.Erase;
{}
begin
   SetNull;
   PosCursor;
   Display(HiStatus);
end; {LateralIOOBJ.Erase}

procedure LateralIOOBJ.DeleteChar;
{}
begin
  delete(vInputStr,vCursorStr,1);
  ReDisplay(HiStatus);
end; {LateralIOOBJ.DeleteChar}

procedure LateralIOOBJ.BackSpace;
{}
begin
   if vCursorStr > 1 then
   begin
      CursorLeft;
      DeleteChar;
      ReDisplay(HiStatus)
   end;
end; {LateralIOOBJ.BackSpace}

procedure LateralIOOBJ.MoveCursor;
{}
begin
   Screen.GotoXY(pred(vBoundary.X1)+vCursorStr - pred(vStartChar),vBoundary.Y1);
end; {LateralIOOBJ.MoveCursor}

function LateralIOOBJ.GetValue:string;
{}
begin
   GetValue := vInputStr;
end; {LateralIOOBJ.GetValue}

destructor LateralIOOBJ.Done;
{}
begin
   CharIOOBJ.Done;
end; {StringFieldOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                }
{     L i s t F i e l d O B J   M E T H O D S    }
{                                                }
{||||||||||||||||||||||||||||||||||||||||||||||||}
{$I totIO2.INC}
{||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                  }
{     A r r a y F i e l d O B J   M E T H O D S    }
{                                                  }
{||||||||||||||||||||||||||||||||||||||||||||||||||}

constructor ArrayIOOBJ.Init(X1,Y1,width,depth:byte;Title:string);
{}
begin
   ListIOOBJ.Init(X1,Y1,width,depth,Title);
end; {ArrayIOOBJ.Init}

procedure ArrayIOOBJ.AssignList(var StrArray; Total:Longint; StrLength:byte);
{}
begin
   vArrayPtr := @StrArray;
   vStrLength := StrLength;
   vTotPicks := Total;
   vListAssigned := true;
end; {ArrayIOOBJ.AssignList}

function ArrayIOOBJ.GetString(Pick:integer): string;
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
end; {ArrayIOOBJ.GetString}

destructor ArrayIOOBJ.Done;
{}
begin
   ListIOOBJ.Done;
end; {ArrayIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                }
{     L i s t F i e l d O B J   M E T H O D S    }
{                                                }
{||||||||||||||||||||||||||||||||||||||||||||||||}
constructor LinkIOOBJ.Init(X1,Y1,width,depth:byte;Title:string);
{}
begin
   ListIOOBJ.Init(X1,Y1,width,depth,Title);
end; {LinkIOOBJ.Init}

procedure LinkIOOBJ.AssignList(var LinkList: DLLOBJ);
{}
begin
   vLinkList := @LinkList;
   vTotPicks := LinkList.TotalNodes;
   vListAssigned := true;
end;  {LinkIOOBJ.AssignList}

function LinkIOOBJ.GetString(Pick:integer): string;
{}
var
  TempPtr : DLLNodePtr;
begin
   TempPtr := vLinkList^.NodePtr(Pick);
   if TempPtr <> Nil then
      vLinkList^.ShiftActiveNode(TempPtr,Pick);
   GetString := vLinkList^.GetStr(TempPtr,1,vBorder.X2 - vBorder.X1);
end; {LinkIOOBJ.GetString}

destructor LinkIOOBJ.Done;
{}
begin
   ListIOOBJ.Done;
end; {LinkIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||}
{                                        }
{     I n t I O O B J   M E T H O D S    }
{                                        }
{||||||||||||||||||||||||||||||||||||||||}
constructor IntIOOBJ.Init(X,Y,Len:byte);
{}
begin
   CharIOOBJ.Init(X,Y,Len);
   vMin := 0;
   vMax := 0;
   vFmtPtr := Nil;
end; {IntIOOBJ.Init}

function IntIOOBJ.FormatPtr: pFmtNumberOBJ;
{}
begin
   FormatPtr := vFmtPtr;
end; {IntIOOBJ.FormatPtr}

procedure IntIOOBJ.InitFormat;
{}
begin
   if vFmtPtr <> nil then
      Dispose(vFmtPtr,Done);
   new(vFmtPtr,Init);
   vFmtPtr^ := FmtNumberTOT;
end; {IntIOOBJ.InitFormat}

procedure IntIOOBJ.SetMinMax(Min,Max:longint);
{}
begin
{$IFDEF CHECK}
   if Min > Max then
   begin
     vMax := Min;
     vMin := Max;
   end
   else
   begin
     vMax := Max;
     vMin := Min;
   end;
{$ELSE}
   vMax := Max;
   vMin := Min;
{$ENDIF}
end; {IntIOOBJ.SetMinMax}

procedure IntIOOBJ.SetValue(Val:longint);
{}
begin
   if  ((vRules and SuppressZero) = SuppressZero)
   and (Val = 0) then
      vInputStr := ''
   else
      vInputStr := IntToStr(Val);
   InitCursor;  {1.00n}
{$IFDEF CHECK}
   if VMax <> vMin then
   begin
      if Val < vMin then
         vMin := Val
      else if Val > vMax then
      begin
         vMax := Val;
         vMaxLen := length(IntToStr(vMax));
      end;
   end;
{$ENDIF}
end;  {IntIOOBJ.SetValue}

function IntIOOBJ.GetValue:longint;
{}
begin
   if ValidInt(vInputStr) then
      GetValue := StrToLong(vInputStr)
   else
      GetValue := 0;
end;  {IntIOOBJ.GetValue}

function IntIOOBJ.CharOK(var Ch:char):boolean;
{}
begin
   if (Ch = '+') and ((pos('+',vInputStr)>0) or (vCursorStr > 1))
   or (Ch = '-') and ((pos('-',vInputStr)>0) or (vCursorStr > 1)) then
      CharOK := false
   else
      CharOK :=    (Ch in  ['0'..'9'])
             or (  (Ch='-') and ((vMin=vMax) or (vMin < 0)))
             or (  (Ch='+') and ((vMin=vMax) or (vMax > 0)))
end; {IntIOOBJ.CharOK}

procedure IntIOOBJ.ReDisplay(Status:tStatus);
{}
var
  A: byte;
  AdjStr: String;
  L: longint;
begin
   if (Status = Norm)  then              {1.00d}
   begin
      if (vFmtPtr <> Nil) then
      begin
         L := GetValue;
         Screen.WriteAt(vBoundary.X1,vBoundary.Y1,
                        IOTOT^.FieldCol(1),
                        vFmtPtr^.FormattedLong(L,vMaxLen));
      end
      else
      begin
         AdjStr := vInputStr;
         AdjStr := Pad(vJust,AdjStr,vFieldLen,vPad);
         Screen.WriteAt(vBoundary.X1,vBoundary.Y1,
                        IOTOT^.FieldCol(1),AdjStr);
      end;
   end
   else
   begin
      AdjStr := vInputStr;
      SetFieldAttr(Status,A,AdjStr);
      Screen.WriteAt(vBoundary.X1,vBoundary.Y1,A,padleft(vInputStr,vMaxlen,vPad));
   end;
end; {IntIOOBJ.ReDisplay}

function IntIOOBJ.Suspend:boolean;
{}
var
  L : longint;
begin
   L := GetValue;
   if  (((vRules and AllowNull) = AllowNull) and (vInputStr = '') = false)
   and (vMax <> vMin)
   and ((ValidInt(vInputStr) = false) or (L > vMax) or (L < vMin))
   then   {Invalid}
   begin
      ValidationMessage(NumberError[1],
                        NumberError[2],
                        '',
                        IntToStr(vMin)+' - '+IntToStr(vMax));
      Suspend := false;
      vFirstKey := true;
   end
   else
   begin
      ReDisplay(Norm);
      WriteLabel(Norm);
      ClearMessage;
      Suspend := true;
   end;
end; {IntIOOBJ.Suspend}

destructor IntIOOBJ.Done;
{}
begin
   CharIOOBJ.Done;
   if vFmtPtr <> nil then
      Dispose(vFmtPtr,Done);
end; {IntIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||}
{                                          }
{     R e a l I O O B J   M E T H O D S    }
{                                          }
{||||||||||||||||||||||||||||||||||||||||||}
constructor RealIOOBJ.Init(X,Y,Len:byte);
{}
begin
   CharIOOBJ.Init(X,Y,Len);
   vENotation := false;
   vMax := 0;
   vMin := 0;
   vFmtPtr := Nil;
end; {RealIOOBJ.Init}

function RealIOOBJ.FormatPtr: pFmtNumberOBJ;
{}
begin
   FormatPtr := vFmtPtr;
end; {RealIOOBJ.FormatPtr}

procedure RealIOOBJ.InitFormat;
{}
begin
   if vFmtPtr <> nil then
      Dispose(vFmtPtr,Done);
   new(vFmtPtr,Init);
   vFmtPtr^ := FmtNumberTOT;
end; {RealIOOBJ.InitFormat}

procedure RealIOOBJ.SetMinMax(Min,Max:extended);
{}
begin
{$IFDEF CHECK}
   if Min > Max then
   begin
     vMax := Min;
     vMin := Max;
   end
   else
   begin
     vMax := Max;
     vMin := Min;
   end;
{$ELSE}
   vMax := Max;
   vMin := Min;
{$ENDIF}
end; {RealIOOBJ.SetMinMax}

procedure RealIOOBJ.SetValue(Val:extended);
{}
begin
   if  ((vRules and SuppressZero) = SuppressZero)
   and (Val = 0.0) then
      vInputStr := ''
   else
   begin
      if vENotation then                                     {1.00m}
         vInputStr := RealtoSciStr(Val,Decimals(vFieldLen))
      else
         vInputStr := copy(RealToStr(Val,Floating),1,vFieldLen);
   end;
   InitCursor;  {1.00n}
{$IFDEF CHECK}
   if vMax <> vMin then
   begin
      if Val < vMin then
         vMin := Val
      else if Val > vMax then
         vMax := Val;
   end;
{$ENDIF}
end;  {RealIOOBJ.SetValue}

function RealIOOBJ.GetValue:extended;
{}
begin
   if ValidReal(vInputStr) then
      GetValue := StrToReal(vInputStr)
   else
      GetValue := 0;
end;  {RealIOOBJ.GetValue}

procedure RealIOOBJ.SetENotation(On:Boolean);
{}
begin
   vEnotation := On;
end; {RealIOOBJ.SetENotation}

function RealIOOBJ.CharOK(var Ch:char):boolean;
{}
var DC : char;
begin
   DC := FmtNumberTOT.GetDecimal;
   if ((Ch = DC) and (pos(DC,vInputStr)>0)) 
   or ((Ch = '-') and (pos('-',vInputStr)>0) and (vENotation=false))
   or ((Ch = '+') and (pos('+',vInputStr)>0))
   then
      CharOK := false
   else
      CharOK :=    (Ch in  ['0'..'9','+',DC])
                or (  (Ch in ['E','e']) and vENotation)
                or (  (Ch='-') and ((vMin=vMax) or (vMin < 0) or vENotation))    {1.00a}
                or (  (Ch='+') and ((vMin=vMax) or (vMax > 0)));
end; {RealIOOBJ.CharOK}

procedure RealIOOBJ.ReDisplay(Status:tStatus);
{}
var
  A: byte;
  AdjStr: String;
  E: extended;
begin
   if (Status = Norm) then
   begin
      if (vFmtPtr <> Nil) then
      begin
         E := GetValue;
         Screen.WriteAt(vBoundary.X1,vBoundary.Y1,
                        IOTOT^.FieldCol(1),
                        vFmtPtr^.FormattedReal(E,Floating,vMaxLen))
      end
      else
      begin
         AdjStr := vInputStr;
         AdjStr := Pad(vJust,AdjStr,vFieldLen,vPad);
         Screen.WriteAt(vBoundary.X1,vBoundary.Y1,
                        IOTOT^.FieldCol(1),AdjStr);
      end;
   end
   else
   begin
      AdjStr := vInputStr;
      SetFieldAttr(Status,A,AdjStr);
      Screen.WriteAt(vBoundary.X1,vBoundary.Y1,A,padleft(vInputStr,vMaxlen,vPad));
   end;
end; {RealIOOBJ.ReDisplay}

function RealIOOBJ.Suspend:boolean;
{}
var
  E : extended;
  MsgStr: string;
begin
   E := GetValue;
   if  (((vRules and AllowNull) = AllowNull) and (vInputStr = '') = false)
   and (vMax <> vMin)
   and ((ValidReal(vInputStr) = false) or (E > vMax) or (E < vMin))
   then   {Invalid}
   begin
      if vENotation then
         MsgStr := RealtoSciStr(vMin,Floating)+' - '+RealtoSciStr(vMax,Floating)
      else
         MsgStr := RealToStr(vMin,Floating)+' - '+RealToStr(vMax,Floating);
      ValidationMessage(NumberError[1],
                        NumberError[2],
                        '',
                        MsgStr);
      Suspend := false;
   end
   else
   begin
      ReDisplay(Norm);
      WriteLabel(Norm);
      ClearMessage;
      Suspend := true;
   end;
end; {RealIOOBJ.Suspend}

destructor RealIOOBJ.Done;
{}
begin
   CharIOOBJ.Done;
   if vFmtPtr <> nil then
      Dispose(vFmtPtr,Done);
end; {RealIOOBJ.Done}

{||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                    }
{     F i x e d R e a l I O O B J   M E T H O D S    }
{                                                    }
{||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor FixedRealIOOBJ.Init(X,Y,Whole,DP:byte);
{}
begin
   SingleLineIOOBJ.Init;
   vMax := 0;
   vMin := 0;
   vDP := DP;
   vWholeP := Whole;
   if vDP > 0 then
      vMaxlen := succ(vWholeP) + vDP
   else
      vMaxlen := vWholeP;
   vBoundary.X1 := X;
   vBoundary.X2 := pred(vBoundary.X1 + vMaxlen);
   vBoundary.Y1 := Y;
   vBoundary.Y2 := vBoundary.Y1;
   vCursorPos := 1;
   vPad := ' ';
   vWholeStr:= replicate(vWholeP,vPad);
   vDPStr :=  replicate(vDP,vPad);
   vFmtPtr := Nil;
end; {FixedRealIOOBJ.Init}

function FixedRealIOOBJ.IsNull:boolean; {1.00h}
{}
begin
   IsNull := (vWholeStr = replicate(vWholeP,vPad))
             and
             (vDPStr =  replicate(vDP,vPad));
end; {FixedRealIOOBJ.IsNull}

procedure FixedRealIOOBJ.SetNull;   {1.00j}
{}
begin
   vCursorPos := 1;
   vWholeStr:= replicate(vWholeP,vPad);
   vDPStr :=  replicate(vDP,vPad);
end; {FixedRealIOOBJ.SetNull}

function FixedRealIOOBJ.FormatPtr: pFmtNumberOBJ;
{}
begin
   FormatPtr := vFmtPtr;
end; {FixedRealIOOBJ.FormatPtr}

procedure FixedRealIOOBJ.InitFormat;
{}
begin
   if vFmtPtr <> nil then
      Dispose(vFmtPtr,Done);
   New(vFmtPtr,Init);
   vFmtPtr^ := FmtNumberTOT;
end; {FixedRealIOOBJ.InitFormat}

procedure FixedRealIOOBJ.SetMinMax(Min,Max:extended);
{}
begin
{$IFDEF CHECK}
   if Min > Max then
   begin
     vMax := Min;
     vMin := Max;
   end
   else
   begin
     vMax := Max;
     vMin := Min;
   end;
{$ELSE}
   vMax := Max;
   vMin := Min;
{$ENDIF}
end; {FixedRealIOOBJ.SetMinMax}

procedure FixedRealIOOBJ.SetValue(Val:extended);
{}
var
  TempStr : string;
  P : Byte;
begin
   vDPStr := replicate(vDP,vPad);
   if ((vRules and SuppressZero) = SuppressZero)
   and (Val = 0.0) then
      vWholeStr := replicate(vWholeP,vPad)
   else
   begin
     TempStr := RealToStr(Val,vDP);
     P := Pos('.',TempStr);
     if (P = 0) or (vDP = 0) then
        vWholeStr := padright(TempStr,vWholeP,vPad)
     else
     begin
        vWholeStr := padright(copy(TempStr,1,pred(P)),vWholeP,vPad);
        vDPStr := padleft(copy(TempStr,succ(P),vDP),vDP,vPad);
     end;
   end;
   vCursorPos := 1;     {1.00n}
   MoveCursor;
{$IFDEF CHECK}
   if vMin <> vMax then
   begin
      if Val < vMin then
         vMin := Val
      else if Val > vMax then
         vMax := Val;
   end;
{$ENDIF}
end;  {FixedRealIOOBJ.SetValue}

procedure FixedRealIOOBJ.Condense;
{}
begin
   if vWholeStr [1] = '-' then
   begin
      delete(vWholeStr,1,1);
      vWholeStr := '-'+padright(Strip('A',vPad,vWholeStr),pred(vWholeP),vPad);
   end
   else
      vWholeStr := padright(Strip('A',vPad,vWholeStr),vWholeP,vPad);
   vDPStr := padleft(Strip('A',vPad,vDPStr),vDP,'0');
end; {FixedRealIOOBJ.Condense}

function FixedRealIOOBJ.GetValue:extended;
{}
var ValStr: string;
begin
   Condense;
   ValStr := vWholeStr+'.'+vDPStr;
   ValStr := strip('A',vPad,ValStr);
   if ValidReal(ValStr) then
      GetValue := StrToReal(ValStr)
   else
      GetValue := 0;
end;  {FixedRealIOOBJ.GetValue}

procedure FixedRealIOOBJ.PeriodHit;
{}
begin
   Condense;
   if vDP > 0 then
      vCursorPos := vWholeP + 2
   else
      vCursorPos := vWholeP;
   Display(HiStatus);
end; {FixedRealIOOBJ.PeriodHit}

procedure FixedRealIOOBJ.PlusHit;
{}
var P: byte;
begin
   if vFirstKey and ((vRules and EraseDefault) = EraseDefault) then {1.00g}
      Erase;
   P := pos('-',vWholeStr);
   if P > 0 then
   begin
      delete(vWholeStr,P,1);
      insert(vPad,vWholeStr,P);
      Display(HiStatus);
   end;
end; {FixedRealIOOBJ.PlusHit}

procedure FixedRealIOOBJ.MinusHit;
{}
var P: byte;
begin
   if (vMin >= 0.0) and (vMin <> vMax) then   {1.00a}
      ding
   else
   begin
      if vFirstKey and ((vRules and EraseDefault) = EraseDefault) then {1.00g}
         Erase;
      P := pos('-',vWholeStr);
      if P = 0 then
      begin
         P := pos(vPad,vWholeStr);
         if P = 0 then
            ding
         else
         begin
            delete(vWholeStr,P,1);
            vWholeStr := '-'+vWholeStr;
         end;
         Display(HiStatus);
         if vCursorPos = 1 then
            CursorRight;
      end;
   end;
end; {FixedRealIOOBJ.MinusHit}

procedure FixedRealIOOBJ.CursorHome;
{}
begin
   vCursorPos := 1;
   Display(HiStatus);
end; {FixedRealIOOBJ.CursorHome}

procedure FixedRealIOOBJ.CursorEnd;
{}
begin
   vCursorPos := vMaxlen;
end; {FixedRealIOOBJ.CursorEnd}

procedure FixedRealIOOBJ.CursorLeft;
{}
begin
   if vCursorPos > 1 then
      dec(vCursorPos);
   if (vCursorPos = succ(vWholeP)) then
      dec(vCursorPos);
end; {FixedRealIOOBJ.CursorLeft}

procedure FixedRealIOOBJ.CursorRight;
{}
begin
   if vCursorPos < vMaxlen then
      inc(vCursorPos);
   if (vCursorPos = succ(vWholeP)) then
      inc(vCursorPos);
end; {FixedRealIOOBJ.CursorRight}

procedure FixedRealIOOBJ.Erase;
{}
begin
   SetNull;
   Display(HiStatus);
end; {FixedRealIOOBJ.Erase}

procedure FixedRealIOOBJ.DeleteChar;
{}
var P : byte;
begin
  if vCursorPos  <= vWholeP then
  begin
     P := vCursorPos-(vWholeP-length(vWholeStr));
     delete(vWholeStr,P,1);
     insert(vPad,vWholeStr,P);
  end
  else
  begin
     P := vCursorPos - succ(vWholeP);
     delete(vDPStr,P,1);
     insert(vPad,vDPStr,P);
  end;
  Display(HiStatus);
end; {FixedRealIOOBJ.DeleteChar}

procedure FixedRealIOOBJ.BackSpace;
{}
begin
   if vCursorPos > 1 then
   begin
      CursorLeft;
      DeleteChar;
      Display(HiStatus)
   end;
end; {FixedRealIOOBJ.BackSpace}

function FixedRealIOOBJ.ProcessEnter:tAction;
{}
begin

   ProcessEnter := Enter;
end; {FixedRealIOOBJ.ProcessEnter}

procedure FixedRealIOOBJ.MoveCursor;
{}
begin
   Screen.GotoXY(pred(vBoundary.X1)+vCursorPos,vBoundary.Y1);
end; {FixedRealIOOBJ.MoveCursor}

procedure FixedRealIOOBJ.Display(Status:tStatus);
{}
var
  A: byte;
  AdjStr: String;
  E: Extended;
begin
   if (Status <> HiStatus) and (vFmtPtr <> nil) then
   begin
      E := GetValue;
      Screen.WriteAt(vBoundary.X1,vBoundary.Y1,
                     IOTOT^.FieldCol(1),
                     vFmtPtr^.FormattedReal(E,vDP,vMaxLen))
   end
   else
   begin
      AdjStr := vWholeStr;
      if vDP > 0 then
         AdjStr := AdjStr + FmtNumberTOT.GetDecimal+vDPStr;
      SetFieldAttr(Status,A,AdjStr);
      Screen.WriteAt(vBoundary.X1,vBoundary.Y1,A,AdjStr);
   end;
end; {FixedRealIOOBJ.Display}

procedure FixedRealIOOBJ.ProcessChar(Ch:char);
{}
var
  P,WholePos,DPPos: byte;

   procedure EraseOld;
   {}
   begin
      if vFirstKey and ((vRules and EraseDefault) = EraseDefault) then
         Erase;
   end; {EraseOld}

begin
   if Ch in ['0'..'9'] then
      EraseOld
   else
   begin
      Ding;
      exit
   end;
   WholePos := vCursorPos-(vWholeP-length(vWholeStr));
   if vCursorPos > vWholeP then  {entering decimals}
      DPPos := vCursorPos - succ(vWholeP)
   else
      DPPos := 0;
   if not vInsert then
   begin
      if DPPOS > 0 then  {entering decimals}
      begin
         delete(vDPStr,DPPos,1);
         insert(Ch,vDPStr,DPPos);
      end
      else  {entering whole numbers}
      begin
         delete(vWholeStr,WholePos,1);
         insert(Ch,vWholeStr,WholePos);
      end;
   end
   else
   begin
      if DPPos > 0 then  {entering decimals}
      begin
         if vDPStr[DPPos] = vPad then
         begin
            delete(vDPStr,DPPos,1);
            insert(Ch,vDPStr,DPPos);
         end
         else
         begin
            P := PosAfter(vPad,vDPStr,DPPos);
            if P = 0 then   {push a character off the end}
               delete(vDPStr,length(vDPStr),1)
            else
               delete(vDPStr,P,1);
            insert(Ch,vDPStr,DPPos);
         end;
      end
      else  {entering whole numbers}
      begin
         if vWholeStr[WholePos] in [vPad,'-'] then
         begin
            delete(vWholeStr,WholePos,1);
            insert(Ch,vWholeStr,WholePos);
         end
         else
         begin
            P := LastPosBefore(vPad,vWholeStr,WholePos);
            if P = 0 then
               P := pos(vPad,vWholeStr);
            if P = 0 then   {no room for another character}
            begin
               Ding;
               exit;
            end
            else
            begin
               delete(vWholeStr,P,1);
               insert(Ch,vWholeStr,WholePos);
               if WholePos = vWholeP then
               begin
                  Display(HiStatus);  {don't cursor right}
                  exit;
               end;
            end;
         end;
      end;
   end;
   CursorRight;
   Display(HiStatus);
end; {FixedRealIOOBJ.ProcessChar}

function FixedRealIOOBJ.ProcessKey(InKey:word;X,Y:byte):tAction;
{}
begin
   if InKey = ord(FmtNumberTOT.GetDecimal) then
      PeriodHit
   else
   Case InKey of
      8: BackSpace;
      339: DeleteChar;
      327: CursorHome;
      335: CursorEnd;
      331: CursorLeft;
      333: CursorRight;
      338: begin
              vInsert := not vInsert;
              InsertAction(vInsert);
           end;
      ord('+'): PlusHit;
      ord('-'): MinusHit;
      32..255: ProcessChar(chr(InKey));    {characters}
   end; {case}
   case InKey of
      13: ProcessKey := ProcessEnter;
      (* 1.00k
      27: ProcessKey := Escaped;
      *)
      else ProcessKey := None;
   end; {case}
   if (Inkey > 0) and (Inkey < 256) then  {1.00n,o}
      vFirstKey := false;
   MoveCursor;
end; {FixedRealIOOBJ.ProcessKey}

procedure FixedRealIOOBJ.Activate;
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
            if LastKey = 27 then  {1.00k}
               Action := Escaped
            else
               Action := ProcessKey(LastKey,LastX,LastY);
         until Action in [Finished,Escaped,Enter];
   until Suspend;
end; {FixedRealIOOBJ.Activate}

function FixedRealIOOBJ.Select(K:word; X,Y:byte): tAction;
{}
begin
   Display(HiStatus);
   WriteLabel(HiStatus);
   InsertAction(vInsert);
   WriteMessage;
   vFirstKey := true;
   if ((vRules and EraseDefault) = EraseDefault) then {1.00o}
      vCursorPos := 1;
   MoveCursor;
   Select := None;
end; {FixedRealIOOBJ.Select}

function FixedRealIOOBJ.Suspend:boolean;
{}
var Col,L: byte;
    ValStr: string;
    E : extended;
begin
   E := GetValue;
   Condense;
   ValStr := vWholeStr+'.'+vDPStr;
   ValStr := strip('A',vPad,ValStr);
   if  (((vRules and AllowNull) = AllowNull) and (getValue=0) = false)
   and (vMax <> vMin)
   and ((ValidReal(ValStr) = false) or (E > vMax) or (E < vMin))
   then   {Invalid}
   begin
      ValidationMessage(NumberError[1],
                        NumberError[2],
                        '',
                        RealToStr(vMin,vDP)+' - '+RealToStr(vMax,vDP));
	  vFirstKey := true;
      Suspend := false;
   end
   else
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
   end;
end; {FixedRealIOOBJ.Suspend}

destructor FixedRealIOOBJ.Done;
{}
begin
   SingleLineIOOBJ.Done;
   if vFmtPtr <> nil then
      Dispose(vFmtPtr,Done);
end; {FixedRealIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||}
{                                          }
{     D a t e I O O B J   M E T H O D S    }
{                                          }
{||||||||||||||||||||||||||||||||||||||||||}
constructor DateIOOBJ.Init(X,Y:byte;DateFmt:tDate);
{}
var 
  Pic:string[10];
  Sep:char;
begin
   vDateFmt := DateFmt;
   Sep := DateTOT^.GetSeparator;
   Case vDateFmt of
      MMDDYY,
      DDMMYY,
      YYMMDD:   Pic := '##'+Sep+'##'+Sep+'##';
      MMDDYYYY,
      DDMMYYYY: Pic := '##'+Sep+'##'+Sep+'####';
      MMYY:     Pic := '##'+Sep+'##';
      MMYYYY:   Pic := '##'+Sep+'####';
      YYYYMMDD: Pic := '####'+Sep+'##'+Sep+'##';
   end; {case}
   PictureIOOBJ.Init(X,Y,Pic);
   vMin := 0;
   vMax := 0;
end; {DateIOOBJ.Init}

procedure DateIOOBJ.SetMinMax(Min,Max:longint);
{}
begin
{$IFDEF CHECK}
   if Min > Max then
   begin
     vMax := Min;
     vMin := Max;
   end
   else
   begin
     vMax := Max;
     vMin := Min;
   end;
{$ELSE}
   vMax := Max;
   vMin := Min;
{$ENDIF}
end; {DateIOOBJ.SetMinMax}

procedure DateIOOBJ.SetValue(Date:longint);
{}
begin
   PictureIOOBJ.Setvalue(StripDateStr(JultoStr(Date,vDateFmt),vDateFmt));
end; {DateIOOBJ.SetValue}

function DateIOOBJ.GetValue: longint;
{}
begin
   if vInputStr = '' then
      GetValue := StrToJul('01/01/1980',DDMMYYYY)
   else
      GetValue := StrtoJul(vInputStr,vDateFmt);
end; {DateIOOBJ.GetValue}

function DateIOOBJ.Suspend:boolean;
{}
var
  L : longint;
  OK : boolean;
begin
   L := GetValue;
   OK := ValidDateStr(vInputStr,vDateFmt);
   if (((vRules and AllowNull) = AllowNull) and (vInputStr = '') = false)
   and ( (OK = false)
         or ((vMax <> vMin) and ((L > vMax) or (L < vMin)))
       )
   then   {Invalid}
   begin
      if (OK = false) then
         ValidationMessage(DateError[1],
                           DateError[2],
                            '',
                            '      '+DateFormat(vDateFmt))
      else if (L < vMin) then
         ValidationMessage(DateError[3],
                           DateError[4],
                            '',
                            '   '+JulToStr(vMin,vDateFmt))
      else
         ValidationMessage(DateError[5],
                           DateError[6],
                            '',
                            '   '+JulToStr(vMax,vDateFmt));
      Suspend := false;
   end
   else
   begin
      ReDisplay(Norm);
      WriteLabel(Norm);
      ClearMessage;
      Suspend := true;
   end;
end; {DateIOOBJ.Suspend}

destructor DateIOOBJ.Done;
{}
begin
   PictureIOOBJ.Done;
end; {DateIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||}
{                                        }
{     H E X I O O B J   M E T H O D S    }
{                                        }
{||||||||||||||||||||||||||||||||||||||||}
constructor HEXIOOBJ.Init(X,Y,Len:byte);
{}
begin
   PictureIOOBJ.Init(X,Y,replicate(len,'*'));
   SetAllowChar('0123456789aAbBcCdDeEfF');
   vMin := 0;
   vMax := 0;
end; {HEXIOOBJ.Init}

procedure HEXIOOBJ.SetMinMax(Min,Max:longint);
{}
begin
{$IFDEF CHECK}
   if Min > Max then
   begin
     vMax := Min;
     vMin := Max;
   end
   else
   begin
     vMax := Max;
     vMin := Min;
   end;
{$ELSE}
   vMax := Max;
   vMin := Min;
{$ENDIF}
end; {HEXIOOBJ.SetMinMax}

procedure HEXIOOBJ.SetValue(Val:longint);
{}
begin
   PictureIOOBJ.SetValue(InttoHEXStr(Val));
end; {HEXIOOBJ.SetValue}

function HEXIOOBJ.GetValue: longint;
{}
begin
   GetValue := HEXStrtoLong(vInputStr);
end; {HEXIOOBJ.GetValue}

function HEXIOOBJ.Suspend:boolean;
{}
var
  L : longint;
begin
   L := GetValue;
   if (((vRules and AllowNull) = AllowNull) and (vInputStr = '') = false)
   and (vMax <> vMin)
   and ((L > vMax) or (L < vMin))
   then   {Invalid}
   begin
      ValidationMessage(NumberError[1],
                        NumberError[2],
                        '',
                        IntToHEXStr(vMin)+' - '+IntToHEXStr(vMax));
      Suspend := false;
   end
   else
   begin
      ReDisplay(Norm);
      WriteLabel(Norm);
      ClearMessage;
      Suspend := true;
   end;
end; {HEXIOOBJ.Suspend}

destructor HEXIOOBJ.Done;
{}
begin
   PictureIOOBJ.Done;
end; {HEXIOOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure IO2Init;
{initilizes objects and global variables}
begin
   FmtNumberTOT.Init;
end; {IO2Init}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
   IO2Init;
{$ENDIF}
end.
