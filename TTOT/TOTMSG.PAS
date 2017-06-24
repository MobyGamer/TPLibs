{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totMSG;
{$I TOTFLAGS.INC}

{
 Development History:
             Jul 10 91  1.00a   Changed button centering algorithm
}

INTERFACE

uses DOS, CRT, totSYS, totINPUT, totFAST, totIO1, totWIN, totSTR;

CONST
   MaxButtons = 10;

TYPE
MsgNodePtr = ^MsgNode;
MsgNode = record
   Txt : pointer;
   Next: MsgNodePtr;
end; {MsgNode}

ButtonDetails = record
  Txt: stringbut;
  Code: tAction;
  HK: word;
  Len : byte;
end; {ButtonDetails}

pBaseMessageOBJ = ^BaseMessageOBJ;
BaseMessageOBJ = object
   vTxtStack: MsgNodePtr;
   vManager: WinFormOBJ;
   vTotLines: byte;
   vStyle: byte;
   vWidth : byte;
   vButtonDepth: byte;
   vMinWidth: byte;
   vTotButtons: byte;
   vButtons: array[1..MaxButtons] of pItemIOOBJ;
   {methods ...}
   constructor Init(Style:byte;Tit:string);
   procedure   AddLine(Str:string);
   function    MsgTxt(LineNo:byte): string;
   function    WinForm: WinFormPtr;
   procedure   AssignButton(var Button:ItemIOOBJ);
   procedure   CalcSize;
   function    Show: tAction;
   destructor  Done;                                     VIRTUAL;
end; {BaseMessageOBJ}

pMessageOBJ = ^MessageOBJ;
MessageOBJ = object (BaseMessageOBJ)
   vButtonText : stringbut;
   vButtonHK: word;
   {methods ...}
   constructor Init(Style:byte;Tit:string);
   procedure   SetOption(Str:string;Hotkey:word);
   procedure   Show;
   destructor  Done;                                     VIRTUAL;
end; {MessageOBJ}

pButtonMessageOBJ = ^ButtonMessageOBJ;
ButtonMessageOBJ = object (MessageOBJ)
   {methods ...}
   constructor Init(Style:byte;Tit:string);
   procedure   Show;
   destructor  Done;                                     VIRTUAL;
end; {ButtonMessageOBJ}

pPromptOBJ = ^PromptOBJ;
PromptOBJ = object (BaseMessageOBJ)
   vButtonInfo : array [1..3] of ButtonDetails;
   vTotPrompts: byte;
   {methods ...}
   constructor Init(Style:byte;Tit:string);
   procedure   SetOption(ID:byte; Str:stringbut;HotKey:word; Act:tAction);
   procedure   LoadButtonRecord(Rec:byte;Str:stringbut;Hotkey:word;Act:tAction);
   function    Show: tAction;
   destructor  Done;                                     VIRTUAL;
end; {PromptOBJ}

pButtonPromptOBJ = ^ButtonPromptOBJ;
ButtonPromptOBJ = object (promptOBJ)
   {methods ...}
   constructor Init(Style:byte;Tit:string);
   function    Show: tAction;
   destructor  Done;                                     VIRTUAL;
end; {ButtonPromptOBJ}

procedure MsgInit;

IMPLEMENTATION

{|||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                   }
{    B a s e M e s s a g e O B J   M E T H O D S    }
{                                                   }
{|||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor BaseMessageOBJ.Init(Style:byte;Tit:string);
{}
begin
   vTotLines := 0;
   vStyle := Style;
   vTxtStack := Nil;
   vWidth := length(Tit) + 10;
   vMinWidth := 10;
   vTotButtons := 0;
   vButtonDepth := 1;
   with vManager do
   begin
      Init;
      vWinPtr^.SetTitle(Tit);
   end; 
end; {BaseMessageOBJ.Init}

procedure BaseMessageOBJ.AddLine(Str:string);
{}          
var L : byte;
    Temp: MsgNodePtr;
begin
   L := succ(length(Str));
   if vTxtStack = Nil then
   begin
      getmem(vTxtStack,sizeof(vTxtStack^));
      vTxtStack^.Next := nil;
      if Str <> '' then
      begin
         getmem(vTxtStack^.Txt,L);
         move(Str[0],vTxtStack^.Txt^,L);
      end
      else
         vTxtStack^.Txt := nil;
   end
   else
   begin
      Temp := vTxtStack;
      while Temp^.Next <> nil do
         Temp := Temp^.Next;
      getmem(Temp^.Next,sizeof(Temp^.Next^));
      Temp := Temp^.Next;
      Temp^.Next := nil;
      if Str <> '' then
      begin
         getmem(Temp^.Txt,L);
         move(Str[0],Temp^.Txt^,L);
      end
      else
         Temp^.Txt := nil;
   end;
   inc(vTotLines);
end; {BaseMessageOBJ.AddLine}

function BaseMessageOBJ.MsgTxt(LineNo:byte): string;
{}
var
   Temp: MsgNodePtr;
   I:integer;
   L : byte;
   Str: string;
begin
   Temp := vTxtStack;
   for I := 2 to LineNo do
      if Temp <> nil then
         Temp := Temp^.Next;
   if (Temp <> Nil) and (Temp^.Txt <> nil) then
   begin
      move(Temp^.Txt^,L,1);
      move(Temp^.Txt^,Str[0],succ(L));
   end
   else
      Str := '';
   MsgTxt := Str;
end; {BaseMessageOBJ.MsgTxt}

procedure BaseMessageOBJ.AssignButton(var Button:ItemIOOBJ);
{}
begin
   if vTotButtons < MaxButtons then
   begin
      inc(vTotButtons);
      vButtons[vTotButtons] := @Button
   end;
end; {BaseMessageOBJ.AssignButton}

procedure BaseMessageOBJ.CalcSize;
{}
var
   X1,Y1,X2,Y2: shortint;
   Height: byte;
   I : integer;
   Str : string;
begin
   for I := 1 to vTotLines do
   begin
      Str := MsgTxt(I);
      if length(Str) > vWidth then
         vWidth := length(Str);
   end;
   if vWidth < vMinWidth then
      vWidth := vMinWidth
   {else if vWidth > 80 then
      vWidth := 76;}
   else if vWidth > Monitor^.Width then {trixfix} {40-col}
      vWidth := Monitor^.Width-4;
   if (vStyle <> 0) then
      vWidth := vWidth + 2;
   X1 := (Monitor^.Width - vWidth) div 2;
   X2 := X1 + pred(vWidth);
   case vStyle of
      0: Height := vTotLines;
      6: Height := vTotLines + 3;
      else Height := vTotLines + 2;
   end; {case}
   inc(Height,succ(vButtondepth));
   Y1 := (Monitor^.Depth - Height) div 2;
   Y2 := Y1 + pred(Height);
   vManager.vWinPtr^.SetSize(X1,Y1,X2,Y2,vStyle);
end; {BaseMessageOBJ.CalcSize}

function BaseMessageOBJ.Show:tAction;
{}
var
   I : integer;
   S : string;
begin
   for I := 1 to vTotButtons do
      vManager.AddItem(vButtons[I]^);
   vManager.Draw;
   for I := 1 to vTotLines do
   begin
      S := MsgTxt(I);
      if S <> '' then
         case S[1] of
            '^': begin
               delete(S,1,1);
               Screen.WriteCenter(I,vManager.vWinPtr^.vBodyAttr,S);
            end;
            '"': begin
               delete(S,1,1);
               Screen.WriteRight(vWidth - 2*ord(vStyle<>0),I,
                                 vManager.vWinPtr^.vBodyAttr,S);
            end;
            else   Screen.WritePlain(1,I,S);
         end;  {case}
   end;
   Show := vManager.Go;
   delay(100);
   vManager.Done;
end; {BaseMessageOBJ.Show}

function BaseMessageOBJ.WinForm: WinFormPtr;
{}
begin
   WinForm := @vManager;
end; {BaseMessageOBJ.WinForm}

destructor BaseMessageOBJ.Done;
{}
var
  L: byte;
  TempA,TempB: MsgNodePtr;
  I : integer;
begin
   TempA := vTxtStack;
   while TempA <> nil do
   begin
       TempB := TempA;
       TempA := TempB^.Next;
       if TempB^.Txt <> Nil then
       begin
          move(TempB^.Txt^,L,1);
          freemem(TempB^.Txt,succ(L)); {dispose of text}
       end;
       freemem(TempB,sizeof(tempB^));
   end;
end; {BaseMessageOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||}
{                                            }
{     M e s s a g e O B J   M E T H O D S    }
{                                            }
{||||||||||||||||||||||||||||||||||||||||||||}
constructor MessageOBJ.Init(Style:byte;Tit:string);
{}
begin
   BaseMessageOBJ.Init(Style,Tit);
   vButtonText := '  ~O~K  ';
   vButtonHK :=  79;
end; {MessageOBJ.Init}
   
procedure MessageOBJ.SetOption(Str:string;HotKey: word);
{}
begin
   vButtonText := Str;
   vButtonHK := HotKey;
end; {MessageOBJ.SetOptionText}

procedure MessageOBJ.Show;
{}
var
   OK: Strip3dIOOBJ;
   EscHK: HotKeyIOOBJ;
   HK: HotKeyIOOBJ;
   TempAct: tAction;
begin
   vMinWidth := length(vButtonText) + 4;
   CalcSize;
   OK.Init(succ((vWidth - length(vButtonText)))div 2 ,succ(vTotLines),vButtonText,Finished); {1.00a}
   EscHK.Init(27,Finished);
   OK.SetHotkey(vButtonHK);
   AssignButton(OK);
   AssignButton(EscHK);
   TempAct := BaseMessageOBJ.Show;
   OK.Done;
   EscHK.Done;
end; {MessageOBJ.Show}

destructor MessageOBJ.Done;
{}
begin
   BaseMessageOBJ.Done
end; {MessageOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                        }
{     B u t t o n M e s s a g e O B J   M E T H O D S    }
{                                                        }
{||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor ButtonMessageOBJ.Init(Style:byte;Tit:string);
{}
begin
   MessageOBJ.Init(Style,Tit);
   vButtonDepth := 2;
end; {ButtonMessageOBJ.Init}
   
procedure ButtonMessageOBJ.Show;
{}
var
   OK: ButtonIOOBJ;
   EscHK: HotKeyIOOBJ;
   TempAct: tAction;
begin
   CalcSize;
   OK.Init(succ((vWidth - length(vButtonText))div 2) ,succ(vTotLines), {1.00a}
             vButtonText,Finished);
   OK.SetHotkey(vButtonHK);
   EscHK.Init(27,Finished);
   AssignButton(OK);
   AssignButton(EscHK);
   TempAct := BaseMessageOBJ.Show;
   EscHk.Done;
end; {ButtonMessageOBJ.Show}

destructor ButtonMessageOBJ.Done;
{}
begin
   MessageOBJ.Done
end; {ButtonMessageOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||}
{                                          }
{     P r o m p t O B J   M E T H O D S    }
{                                          }
{||||||||||||||||||||||||||||||||||||||||||}
constructor PromptOBJ.Init(Style:byte;Tit:string);
{}
begin
   BaseMessageOBJ.Init(Style,Tit);
   SetOption(1,'   ~O~K   ',79,Finished);        {1.00a}
   SetOption(2,' ~C~ancel ',67,Escaped);
   vTotPrompts := 2;
end; {PromptOBJ.Init}
   
procedure PromptOBJ.LoadButtonRecord(Rec:byte;Str:stringbut;
                                     Hotkey:word;Act:tAction);
{}
begin
   with vButtonInfo[Rec] do
   begin
      Txt := Str;
      Code := Act;
      Len := length(Strip('A','~',Str));
      HK := Hotkey;
   end;
end; {PromptOBJ.LoadButtonRecord}

procedure PromptOBJ.SetOption(ID:byte; Str:stringbut;HotKey:word; Act:tAction);
{}
begin
   if ID in [1..3] then
      LoadButtonRecord(ID,Str,HotKey,Act);
   if ID = 3 then
      vTotPrompts := 3;
end; {PromptOBJ.SetOptions}

function PromptOBJ.Show: tAction;
{}
type 
   But = record
      Button: Strip3dIOOBJ;
      XCoord: byte;
   end;
var
   MoveKeys: ControlKeysIOOBJ;
   Buttons : array[1..3] of But;
   Temp: byte;
   I : integer;
begin
   Temp := 0;
   for I := 1 to vTotprompts do
     inc(Temp,vButtonInfo[I].Len);
   vMinWidth := Temp + succ(vTotPrompts) + 3; {1.00a}
   CalcSize;
   Temp := (vWidth - Temp) div succ(vTotPrompts);
   Buttons[1].XCoord := Temp;
   for I := 2 to vTotPrompts do
      Buttons[I].XCoord := Temp + Buttons[pred(I)].XCoord + vButtonInfo[pred(I)].Len;
   for I := 1 to vTotPrompts do
   begin
      with Buttons[I] do
      begin
        Button.Init(XCoord,succ(vTotLines),vButtonInfo[I].Txt,vButtonInfo[I].Code);
        if vButtonInfo[I].HK <> 0 then
          Button.Sethotkey(vButtonInfo[I].HK);
       AssignButton(Button);
      end; 
   end;
   MoveKeys.Init;
   AssignButton(MoveKeys);
   Show := BaseMessageOBJ.Show;
   for I := 1 to vTotPrompts do
      Buttons[I].Button.Done;
   MoveKeys.Done;
end; {PromptOBJ.Show}

destructor PromptOBJ.Done; 
{}
begin
    BaseMessageOBJ.Done;
end; {PromptOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                      }
{     B u t t o n P r o m p t O B J   M E T H O D S    }
{                                                      }
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor ButtonPromptOBJ.Init(Style:byte;Tit:string);
{}
begin
   PromptOBJ.Init(Style,Tit);
   vButtonDepth := 2;
end; {ButtonPromptOBJ.Init}
   
function ButtonPromptOBJ.Show: tAction;
{}
type 
   But = record
      Button: ButtonIOOBJ;
      XCoord: byte;
   end;
var
   MoveKeys: ControlKeysIOOBJ;
   Buttons : array[1..3] of But;
   Temp: byte;
   I : integer;
begin
   Temp := 0;
   for I := 1 to vTotprompts do
     inc(Temp,vButtonInfo[I].Len+2);
   vMinWidth := Temp + succ(vTotPrompts);
   CalcSize;
   Temp := (vWidth - Temp) div succ(vTotPrompts);
   Buttons[1].XCoord := Temp;
   for I := 2 to vTotPrompts do
      Buttons[I].XCoord := Temp + Buttons[pred(I)].XCoord + vButtonInfo[pred(I)].Len + 2;
   for I := 1 to vTotPrompts do
   begin
      with Buttons[I] do
      begin
        Button.Init(XCoord,succ(vTotLines),vButtonInfo[I].Txt,vButtonInfo[I].Code);
        if vButtonInfo[I].HK <> 0 then
          Button.Sethotkey(vButtonInfo[I].HK);
       AssignButton(Button);
      end; 
   end;
   MoveKeys.Init;
   AssignButton(MoveKeys);
   Show := BaseMessageOBJ.Show;
   for I := 1 to vTotPrompts do
      Buttons[I].Button.Done;
   MoveKeys.Done;
end; {ButtonPromptOBJ.Show}

destructor ButtonPromptOBJ.Done;
{}
begin
   PromptOBJ.Done
end; {ButtonPromptOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure MsgInit;
{initilizes objects and global variables}
begin
end;

{end of unit - add intialization routines below}
{$IFNDEF OVERLAY}
begin
  {$IFDEF MEMORYDEBUG} writeln('TOTMSG init sees ',memavail); {$ENDIF}
   MsgInit;
{$ENDIF}
end.



