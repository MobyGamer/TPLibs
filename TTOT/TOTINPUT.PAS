{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10a                            }

Unit totINPUT;
{$I TOTFLAGS.INC}

{
 Development Notes:
       1.00a  3/28/91   Add Mouse method SetForceOff to stop Toolkit
                        making the mouse visible;
       1.00b  5/23/91   Corrected ret codes with Mouse method 1
       1.00c  6/02/91   Changed Shiftpressed check for XT's
       1.00d  7/23/91   Replaced CRT Readkey with interrupt to better
                        support extended clone keyboards.
       1.00e  8/17/91   Allowed keyboard stuffing in the idle hook.
       1.00f  2/03/92   Added SetSlowdelay method
       1.00g  3/09/92   Added support for vSetLeft
       1.10   12/15/92  DPMI Update
       1.10a  02/29/93  Corrected extended keyboard recognition problem
       1.10b  05/03/93  Improved Double-Click reponse on fast systems --
                        thanks Arnold!
                        Added MouseOBJ.WaitForRelease method
}


INTERFACE

{$IFDEF DPMI}
uses DOS,CRT,WINAPI;
{$ELSE}
uses DOS,CRT;
{$ENDIF}

Const
    StuffBufferSize = 30;

Type

InputIdleProc    = procedure;
InputPressedProc = procedure(var W:word);
CharProc         = procedure(W:word);
CaseFunc         = function(Ch:char):char;
CharSet = set of char;

pAlphabetOBJ = ^AlphabetOBJ;
AlphabetOBJ = object
   vUpper: CharSet;
   vLower: CharSet;
   vPunctuation: CharSet;
   vUpCaseFunc: CaseFunc;
   vLoCaseFunc: CaseFunc;
   {methods...}
   constructor Init;
   procedure   AssignUpCaseFunc(Func:caseFunc);
   procedure   AssignLoCaseFunc(Func:caseFunc);
   procedure   SetUpper(Letters:CharSet);
   procedure   SetLower(Letters:CharSet);
   procedure   SetPunctuation(Letters:CharSet);
   function    IsUpper(K:word): boolean;
   function    IsLower(K:word): boolean;
   function    IsLetter(K:word): boolean;
   function    IsPunctuation(K:word): boolean;
   function    GetUpCase(Ch:char):char;
   function    GetLoCase(Ch:char):char;
   destructor  Done;
end; {AlphabetOBJ}

pMouseOBJ = ^MouseOBJ;
MouseOBJ = object
   vInstalled: boolean;    {is the system equipped with a mouse}
   vButtons: byte;         {how many buttons on mouse}
   vLeftHanded: boolean;   {is right button Enter?}
   vIntr: integer;         {mouse interrupt number}
   vVisible: boolean;      {is mouse cursor visible?}
   vForceNoMouse: boolean; {uses monochrome color schemes}
   {methods}
   constructor Init;
   procedure   SetLeft(On:boolean);
   function    LeftHanded:boolean;
   function    AdjustedButton(Button:integer):integer;
   procedure   SetForceOff(On:boolean);
   procedure   Reset;
   function    Installed:boolean;
   procedure   CheckInstalled;
   procedure   Show;
   procedure   Hide;
   procedure   Move(X,Y : integer);
   procedure   Confine(X1,Y1,X2,Y2:integer);
   function    Released(Button: integer; var X,Y: byte): byte;
   function    Pressed(Button: integer; var X,Y: byte): byte;
   function    InZone(X1,Y1,X2,Y2: byte):boolean;
   procedure   Location(var X,Y : byte);
   procedure   Status(var L,C,R:boolean; var X,Y : byte);
   procedure   WaitForRelease;
   function    Visible: boolean;
   procedure   SetMouseCursorStyle(OrdChar,Attr:byte);
   function    GetButtons: byte;
   destructor  Done;
end; {MouseOBJ}

pKeyOBJ = ^KeyOBJ;
KeyOBJ = object
   vMouseMethod: byte;        {0-no mouse, 1-cursor emulation, 2-freefloating mouse}
   vBuffer: array[1..StuffBufferSize] of word;
   vBufferHead: word;         {next character from buffer}
   vBufferTail:word;          {last valid character in buffer}
   vLastkey: word;            {the last key pressed}
   vLastX:byte;               {location of mouse when button pressed}
   vLastY:byte;               {                -"-                  }
   vClick: boolean;           {click after every keypress?}
   vHorizSensitivity: byte;   {no of characters}
   vVertSensitivity: byte;    {      -"-       }
   vWaitForDouble: boolean;
   vIdleHook: InputIdleProc;
   vPressedHook: InputPressedProc;
   vExtended : boolean;       {is it an extended keyboard}
   vButtons : byte;
   vSlowdelay: integer;       {time to wait for double click}
   vLastPress: longint;
   {methods...}
   constructor Init;
   procedure   SetSlowDelay(Del:integer);
   procedure   AssignIdleHook(PassedProc: InputIdleProc);
   procedure   AssignPressedHook(PassedProc: InputPressedProc);
   function    Extended: boolean;
   procedure   SetCaps(On:boolean);
   procedure   SetNum(On:boolean);
   procedure   SetScroll(On:boolean);
   function    GetCaps:boolean;
   function    GetNum:boolean;
   function    GetScroll:boolean;
   procedure   SetRepeatRate(Delay,Rate:byte);
   procedure   SetFast;
   procedure   SetSlow;
   procedure   SetMouseMethod(Method:byte);
   procedure   SetClick(On: boolean);
   procedure   SetDouble(On:boolean);
   function    GetDouble:boolean;
   procedure   Click;
   procedure   SetHoriz(Sensitivity:byte);
   procedure   SetVert(Sensitivity:byte);
   procedure   GetInput;
   function    LastKey: word;
   function    LastChar: char;
   function    LastX: byte;
   function    LastY: byte;
   function    ExtendedKey(var K:byte):boolean;
   function    ReadKey: char;
   function    GetKey: word;
   procedure   FlushBuffer;
   procedure   StuffBuffer(W:word);
   procedure   StuffBufferStr(Str:string);
   function    Keypressed: boolean;
   procedure   DelayKey(Mills:longint);
   function    AltPressed:boolean;
   function    CtrlPressed:boolean;
   function    LeftShiftPressed: boolean;
   function    RightShiftPressed: boolean;
   function    ShiftPressed: boolean;
   destructor  Done;
end; {KeyOBJ}

procedure NoInputIdleHook;
procedure NoInputPressedHook(var W:word);
function  Altkey(K: word): word;
procedure inputINIT;

VAR
   AlphabetTOT: ^AlphabetOBJ;
   Mouse: MouseOBJ;
   Key:   KeyOBJ;

IMPLEMENTATION
var
   KeyStatusBits : ^word; {1.10}

{|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                               }
{     U N I T   P R O C E D U R E S   &   F U N C T I O N S     }
{                                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||}

{$F+}
 procedure NoInputIdleHook;
 {empty procs}
 begin end; {NoInputIdleHook}

 procedure NoInputPressedHook(var W:word);
 {empty procs}
 begin end; {NoInputPressedHook}

 function EnglishUpCase(Ch:char):char;
 {}
 begin
    EnglishUpCase := upcase(Ch);
 end; {EnglishUpCase}
(*
 inline($58/$3C/$61/$72/$39/$3C/$7A/$76/$33/$3C/$84/$75/$02/$B0/$8E
 /$3C/$94/$75/$02/$B0/$99/$3C/$81/$75/$02/$B0/$9A
 /$3C/$87/$75/$02/$B0/$80/$3C/$86/$75/$02/$B0/$BF
 /$3C/$82/$75/$02/$B0/$90/$3C/$91/$75/$02/$B0/$92
 /$3C/$A4/$75/$02/$B0/$A5/$EB/03/90/$2C/$20);
*)
 function EnglishLoCase(Ch:char):char;
 {}
 begin
   if Ch in ['A'..'Z'] then
      EnglishLoCase := chr(ord(Ch) + 32)
   else
      EnglishLoCase := Ch;
 end; {EnglishLoCase}
 (*
 inline($58/$3C/$41/$72/$39/$3C/$5A/$76/$33/$3C/$8E/$75/$02/$B0/$B4
 /$3C/$99/$75/$02/$B0/$94/$3C/$9A/$75/$02/$B0/$81
 /$3C/$8D/$75/$02/$B0/$87/$3C/$8F/$75/$02/$B0/$86
 /$3C/$9D/$75/$02/$B0/$82/$3C/$92/$75/$02/$B0/$91
 /$3C/$A5/$75/$02/$B0/$A4/$EB/03/90/$04/$20);
 *)
{$F-}

function Altkey(K: word): word;
{returns the Alt keycode equivalent of a number or letter}
var AK: word;
begin
   Case K of
      65:AK:=286; 66:AK:=304; 67:AK:=302; 68:AK:=288; 69:AK:=274; 70:AK:=289;
      71:AK:=290; 72:AK:=291; 73:AK:=279; 74:AK:=292; 75:AK:=293; 76:AK:=294;
      77:AK:=306; 78:AK:=305; 79:AK:=280; 80:AK:=281; 81:AK:=272; 82:AK:=275;
      83:AK:=287; 84:AK:=276; 85:AK:=278; 86:AK:=303; 87:AK:=273; 88:AK:=301;
      89:AK:=277; 90:AK:=300; 48:AK:=385;
   else if (K >= 49) and (K <= 57) then
           AK := K + 327
        else 
           AK := 0;
   end; {case}
   AltKey := AK;
end; {AltKey}
{|||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                 }
{     A l p h a b e t O B J    M E T H O D S      }
{                                                 }
{|||||||||||||||||||||||||||||||||||||||||||||||||}
constructor AlphabetOBJ.Init;
{}
begin
   vUpper := ['A'..'Z'];
   vLower := ['a'..'z'];
   vPunctuation := [',',';',':','.',' '];
   AssignUpcaseFunc(EnglishUpcase);
   AssignLocaseFunc(EnglishLocase);
end; {AlphabetOBJ.Init}

procedure AlphabetOBJ.AssignUpCaseFunc(Func:caseFunc);
{}
begin
   vUpCaseFunc := Func;
end; {AlphabetOBJ.AssignUpCaseFunc}

procedure AlphabetOBJ.AssignLoCaseFunc(Func:caseFunc);
{}
begin
   vLoCaseFunc := Func;
end; {AlphabetOBJ.AssignLoCaseFunc}

procedure AlphabetOBJ.SetUpper(Letters:CharSet);
{}
begin
   vUpper := Letters;
end; {AlphabetOBJ.SetUpper}

procedure AlphabetOBJ.SetLower(Letters:CharSet);
{}
begin
   vLower := Letters;
end; {AlphabetOBJ.SetLower}

procedure AlphabetOBJ.SetPunctuation(Letters:CharSet);
{}
begin
   vPunctuation := Letters;
end; {AlphabetOBJ.SetPunctuation}

function AlphabetOBJ.IsUpper(K:word): boolean;
{}
begin
   if K > 255 then
     IsUpper := false
   else
     IsUpper := chr(K) in vUpper;
end; {AlphabetOBJ.IsUpper}

function AlphabetOBJ.IsLower(K:word): boolean;
{}
begin
   if K > 255 then
     IsLower := false
   else
     IsLower := chr(K) in vLower;
end; {AlphabetOBJ.IsLower}

function AlphabetOBJ.IsLetter(K:word): boolean;
{}
begin
   if K > 255 then
     IsLetter := false
   else
     IsLetter := (chr(K) in vUpper) or (chr(K) in vLower);
end; {AlphabetOBJ.IsLetter}

function AlphabetOBJ.IsPunctuation(K:word): boolean;
{}
begin
   if K > 255 then
     IsPunctuation := false
   else
   IsPunctuation := chr(K) in vPunctuation;
end; {AlphabetOBJ.IsPunctuation}

function AlphabetOBJ.GetUpCase(Ch:char):char;
{}
begin
   GetUpCase := vUpCaseFunc(Ch);
end; {AlphabetOBJ.GetUpCase}

function AlphabetOBJ.GetLoCase(Ch:char):char;
{}
begin
   GetLoCase := vLoCaseFunc(Ch);
end;{AlphabetOBJ.GetLoCase}

destructor AlphabetOBJ.Done;
{}
begin
end; {AlphabetOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     M o u s e O B J    M E T H O D S      }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
constructor MouseOBJ.Init;
{}
begin
  {$IFDEF INITTRACE}writeln('totinput:mouseobj.init');{$ENDIF}
  CheckInstalled;
  vForceNoMouse := false; {1.00a}
  vLeftHanded := true;  {1.00g}
  If vInstalled then
  begin
     vIntr := $33;
     vVisible := false;
     Reset;
  end
  else
     vVisible := false;
end; {MouseOBJ.Init}

procedure MouseOBJ.CheckInstalled;
{}
var
  MouseInterruptPtr : pointer;

    Function InterruptLoaded:boolean;
    var
      Reg: registers;
      foop:^longint;
    begin
       {$IFDEF INITTRACE}writeln('totinput:interruptloaded');{$ENDIF}
       {trixfix: DOS 2.x doesn't pre-populate interrupts to $3f with IRET,
       so trying to do this on DOS 2.x locks up the system.}
       foop:=ptr(0,$33*4);
       if foop^<>0 then begin
         Reg.Ax := 0;
         Intr($33,Reg);
         InterruptLoaded :=  Reg.Ax <> 0;
       end else begin
         InterruptLoaded:=false;
       end;
    end;

begin
  {$IFDEF INITTRACE}writeln('totinput:checkinstalled');{$ENDIF}
   MouseInterruptPtr := ptr($0000,$00CC);
   vButtons := 0;
   if (MouseInterruptPtr = nil)
   or (byte(MouseInterruptPtr) = $CF) then
      vInstalled := false          {don't call interrupt if vector is zero}
   else
      vInstalled := Interruptloaded;
end; {MouseOBJ.CheckInstalled}

procedure MouseOBJ.SetForceOff(On:boolean); {1.00a}
{}
begin
   vForceNoMouse := On;
end; {MouseOBJ.SetForceOff}

procedure MouseOBJ.Reset;
{}
var Regs : registers;
begin
   if Installed then
   begin
      Regs.Ax := $00;
      Intr(vIntr,Regs);
      vButtons := Regs.Bx;
      vVisible := false;
   end;
end; {MouseOBJ.Reset}

function MouseOBJ.Installed:boolean;
{}
begin
    Installed := vInstalled;   {1.00b}
end; {MouseOBJ.Installed}

procedure MouseOBJ.Show;
{}
var Regs : registers;
begin
   if (Installed) and (not vVisible) and (not vForceNoMouse) then
   begin
      Regs.Ax := $01;
      Intr(vIntr,Regs);
      vVisible := true;
   end;
end; {MouseOBJ.Show}

procedure MouseOBJ.Hide;
{}
var Regs : registers;
begin
   if Installed and vVisible then
   begin
      Regs.Ax := $02;
      Intr(vIntr,Regs);
      vVisible := false;
   end;
end; {MouseOBJ.Hide}

procedure MouseOBJ.Move(X,Y : integer);
{X and Y are character positions not pixel positions}
var Regs : registers;
begin
   if Installed then
   begin
      with Regs do
      begin
         Ax := $04;
         Cx := pred(X*8);   {8 pixels per character}
         Dx := pred(Y*8);   {         "-"          }
      end; {with}
      Intr(vIntr,Regs);
   end;
end; {MouseOBJ.Move}

procedure MouseOBJ.Confine(X1,Y1,X2,Y2:integer);
{}
var Regs : registers;
begin
   if Installed then
      with Regs do
      begin
         {horizontal}
         Ax := $07;
         Cx := pred(X1*8);
         Dx := pred(X2*8);
         intr(vIntr,Regs);
         {vertical}
         Ax := $08;
         Cx := pred(Y1*8);
         Dx := pred(Y2*8);
         intr(vIntr,Regs);
      end;
end; {MouseOBJ.Confine}

function MouseOBJ.AdjustedButton(Button:integer):integer;
{}
begin
   if vLeftHanded or (Button > 2) then
      AdjustedButton := Button
   else if Button = 0 then
      AdjustedButton := 1
   else
      AdjustedButton := 0;
end; {MouseOBJ.AdjustedButton}

function MouseOBJ.Released(Button: integer; var X,Y: byte): byte;
{}
var Regs : registers;
begin
   if Installed then
      with Regs do
      begin
         Ax := 6;
         Bx := AdjustedButton(Button);
         intr(vIntr,Regs);
         Released := Bx;
         X := succ(Cx div 8);
         Y := succ(Dx div 8);
      end;
end; {MouseOBJ.Released}

function MouseOBJ.Pressed(Button: integer; var X,Y: byte): byte;
{}
var Regs : registers;
begin
   if Installed then
      with Regs do
      begin
         Ax := 5;
         Bx := AdjustedButton(Button);
         intr(vIntr,Regs);
         Pressed := Bx;
         X := succ(Cx div 8);
         Y := succ(Dx div 8);
      end;
end; {MouseOBJ.Pressed}

function MouseOBJ.InZone(X1,Y1,X2,Y2: byte):boolean;
{}
var X,Y: byte;
begin
   if Installed and vVisible then
   begin
      Location(X,Y);
      InZone := (X >= X1) and (X <= X2) and (Y >= Y1) and (Y <= Y2);
   end
   else
      InZone := false;
end; {MouseOBJ.InZone}

procedure MouseOBJ.Location(var X,Y : byte);
{}
var Regs : registers;
begin
   if Installed then
      with Regs do
      begin
         Ax := 3;
         intr(vIntr,Regs);
         X := succ(Cx div 8);
         Y := succ(Dx div 8);
      end; {with}
end; {MouseOBJ.Location}

procedure MouseOBJ.Status(var L,C,R:boolean; var X,Y : byte);
{}
var Regs : registers;
begin
   if Installed then
   begin
      with Regs do
      begin
         Ax := 3;
         intr(vIntr,Regs);
         X := succ(Cx div 8);
         Y := succ(Dx div 8);
         if vLeftHanded then
         begin
            L := ((BX and $01) = $01);
            R := ((BX and $02) = $02);
         end
         else
         begin
            R := ((BX and $01) = $01);
            L := ((BX and $02) = $02);
         end;
         C := ((BX and $04) = $04);
      end; {with}
   end
   else
   begin
      L := false;
      C := false;
      R := false;
      X := 1;
      Y := 1;
   end;
end; {MouseOBJ.Status}

procedure MouseOBJ.WaitForRelease;  {1.10b}
{Waits for all mouse buttons to be released and clears the
 pressed history}
var
  L,M,R: boolean;
  X,Y,P: byte;
begin
   repeat
      Status(L,M,R,X,Y);
   until not L and not M and not R;
   P := Released(0,X,Y);
   P := Released(1,X,Y);
   if vButtons > 2 then
      P := Released(2,X,Y);
end; {MouseOBJ.WaitForRelease}

procedure MouseOBJ.SetMouseCursorStyle(OrdChar,Attr: byte);
var
  Reg: registers;
begin
   if Installed then
   begin
      Reg.Ax := 10;
      Reg.Bx := 0;        {software text cursor}
      if Attr = 0 then
         Reg.CX := $7700
      else
         Reg.Cx := $00;
      Reg.Dl := OrdChar;
      Reg.Dh := Attr;
      Intr($33,Reg);
   end;
end; {MouseOBJ.SetMouseCursorStyle}

function MouseOBJ.Visible:boolean;
{}
begin
   Visible := vVisible;
end; {MouseOBJ.Visible}

function MouseOBJ.GetButtons: byte;
{}
begin
   GetButtons := vButtons;
end; {MouseOBJ.GetButtons}

procedure MouseOBJ.SetLeft(On:boolean);
{}
begin
   vLeftHanded := On;
end; {MouseOBJ.SetLeft}

function MouseOBJ.LeftHanded:boolean; {1.00g}
begin
   LeftHanded := vLeftHanded;
end; {MouseOBJ.LeftHanded}

destructor MouseOBJ.Done;
{}
begin end;
{|||||||||||||||||||||||||||||||||||||||}
{                                       }
{     K e y O B J    M e t h o d s      }
{                                       }
{|||||||||||||||||||||||||||||||||||||||}
constructor KeyOBJ.Init;
{}
var
   ExtStatus: pointer;  {1.10}
{$IFDEF DPMI}
   Sel:word;  {DPMI selector}
{$ENDIF}
begin
   {$IFDEF INITTRACE}writeln('totinput:keyobj.init');{$ENDIF}
   ExtStatus := ptr($0000,$0496);
{$IFDEF DPMI}                     {1.10a}
   vExtended := true;
   Sel := AllocSelector(0);
   if SetSelectorBase(sel,longint(hiword(longint(ExtStatus))) shl 4+loword(longint(ExtStatus))) <> 0 then
   begin
      SetSelectorLimit(sel,4);
      ExtStatus := ptr(sel,0);
      vExtended := (byte(ExtStatus^) <> 0);
   end;
   FreeSelector(sel);
{$ELSE}
   vExtended := (byte(ExtStatus^) <> 0);
{$ENDIF}
   vIdleHook := NoInputIdleHook;
   vPressedHook := NoInputPressedHook;
   vBufferHead := 1;
   vBufferTail := 1;
   vHorizSensitivity := 1;
   vVertSensitivity := 1;
   vClick := false;
   vLastKey := 0;
   vWaitForDouble := false;
   vButtons := 0;
   vSlowDelay := 350;    {was 200}
   vLastPress := 0;
   SetMouseMethod(2);
end; {KeyOBJ.Init}

procedure KeyOBJ.SetSlowDelay(Del:integer);  {1.00f}
{}
begin
   if Del >= 0 then
     vSlowDelay := Del;
end; {KeyOBJ.SetSlowDelay}

procedure KeyOBJ.AssignIdleHook(PassedProc: InputIdleProc);
{}
begin
   vIdleHook := PassedProc;
end; {KeyOBJ.AssignIdleHook}

procedure KeyOBJ.AssignPressedHook(PassedProc: InputPressedProc);
{}
begin
   vPressedHook := PassedProc;
end; {KeyOBJ.AssignPressedHook}

function KeyOBJ.Extended:boolean;
{}
begin
    Extended := vExtended;
end; {KeyOBJ.Extended}

procedure KeyOBJ.SetCaps(On:boolean);
{}
begin
   If On then
      KeyStatusBits^ := (KeyStatusBits^ or $40)
   else
      KeyStatusBits^ := (KeyStatusBits^ and $BF);
end; {KeyOBJ.SetCaps}

procedure KeyOBJ.SetNum(On:boolean);
{}
begin
   If On then
      KeyStatusBits^ := (KeyStatusBits^ or $20)
   else
      KeyStatusBits^ := (KeyStatusBits^ and $DF);
end; {KeyOBJ.SetNum}

procedure KeyOBJ.SetScroll(On:boolean);
{}
begin
   If On then
      KeyStatusBits^  := (KeyStatusBits^  or $10)
   else
      KeyStatusBits^  := (KeyStatusBits^  and $EF);
end; {KeyOBJ.SetScroll}

function KeyOBJ.GetCaps:boolean;
{}
var CapsOnW : word;
begin
   CapsOnW := swap(KeyStatusBits^ );
   GetCaps := (CapsOnW and $4000) <> 0;
end; {KeyOBJ.GetCaps}

function KeyOBJ.GetNum:boolean;
{}
var NumOnW : word;
begin
   NumOnW := swap(KeyStatusBits^ );
   GetNum := (NumOnW and $2000) <> 0;
end; {KeyOBJ.GetNum}

function KeyOBJ.GetScroll:boolean;
{}
var ScrollOnW : word;
begin
   ScrollOnW := swap(KeyStatusBits^ );
   GetScroll := (ScrollOnW and $1000) <> 0;
end; {KeyOBJ.GetScroll}

procedure KeyOBJ.SetRepeatRate(Delay,Rate:byte);
{}
var Regs : registers;
begin
  with Regs do
  begin
     Ah := 3;
     Al := 5;
     Bl := Rate;
     Bh := pred(Delay);
     Intr($16,Regs);
  end;
end; {KeyOBJ.SetRepeatRate}

procedure KeyOBJ.SetFast;
{}
begin
   SetRepeatRate(1,0);
end; {KeyOBJ.SetFast}

procedure KeyOBJ.SetSlow;
{}
begin
   SetRepeatRate(2,$14);
end; {KeyOBJ.SetSlow}

procedure KeyOBJ.SetMouseMethod(Method:byte);
{}
begin
   if (Method in [1,2]) and Mouse.Installed then
   begin
      vMouseMethod := Method;
      vButtons := Mouse.GetButtons;
   end
   else
      vMouseMethod := 0;
end; {KeyOBJ.SetMouseMethod}

procedure KeyOBJ.SetHoriz(Sensitivity:byte);
{}
begin
   vHorizSensitivity := Sensitivity;
end; {KeyOBJ.SetHoriz}

procedure KeyOBJ.SetVert(Sensitivity:byte);
{}
begin
   vVertSensitivity := Sensitivity;
end; {KeyOBJ.SetHoriz}

procedure KeyOBJ.SetClick(On: boolean);
{}
begin
   vClick := On;
end; {KeyOBJ.SetClick}

procedure KeyOBJ.SetDouble(On:boolean);
{}
begin
   vWaitForDouble := On;
end; {KeyOBJ.SetDouble}

function KeyOBJ.GetDouble:boolean;
{}
begin
   GetDouble := vWaitForDouble;
end; {KeyOBJ.GetDouble}

procedure KeyOBJ.Click;
{}
begin
   Sound(1000);
   Sound(50);
   delay(5);
   nosound;
end; {KeyOBJ.Click}

function KeyOBJ.ExtendedKey(var K:byte):boolean;  {1.00d}
{}
var Regs:Registers;
begin
   with Regs do
   begin
      if vExtended then
        Ah := $10
      else
        Ah := $0;
      intr($16,Regs);
      if (Al = 0) or (Al = 224) then
      begin
         K := Ah;
         ExtendedKey := true;
      end
      else
      begin
         K := al;
         ExtendedKey := false;
      end;
   end;
end; {KeyOBJ.ExtendedKey}

function KeyOBJ.ReadKey: char;          {1.00d}
{CREDITS: Yanick Poirier and the folks in the Pascal International Echo - Thanks!
 Replaces DOS Readkey, to improve extended keyboard support on clones}
const ch:char = #0;
var K:byte;
begin
   if Ch = #0 then
   begin
      if ExtendedKey(K) then
      begin
         Readkey := Ch;
         Ch := chr(K);
      end
      else
      begin
         ReadKey := chr(K);
         Ch := #0;
      end;    
   end
   else
   begin
      Readkey := Ch;
      Ch := #0; 
   end;
end; {KeyOBJ.ReadKey}

procedure KeyOBJ.GetInput;
{waits for a keypress or mouse activity}
Const
   H = 40;
   V = 13;
   QwikDelay = 20;
Var
   L,C,R : boolean;
   Action: boolean;
   Finished: boolean;
   ThisPress: Longint;
   Temp, TempX,TempY,X,Y: byte;
   Ch : char;
   KeyWord : word;
   InitDelay: longint;
   LeftPresses, RightPresses, CenterPresses: word;
   ButtonCombinations: byte;

   function ReadFromBuffer:boolean;  {1.00e}
   {}
   begin
      if vBufferHead <> vBufferTail then  {read from object buffer}
      begin
         Keyword := vBuffer[vBufferHead];
         if vBufferHead < StuffBufferSize then
            Inc(vBufferHead)
         else
            vBufferHead := 1;
         ReadFromBuffer := true;
      end
      else
        ReadFromBuffer := false;
   end;

begin
   if vWaitForDouble then
      InitDelay := vSlowdelay div 55  {for backward compatibility}
   else
      InitDelay := 5;
   if not ReadFromBuffer then
   begin
      if vMouseMethod = 1 then
         Mouse.Move(H,V);
      Action := false;
      Finished := false;
      repeat
         vIdleHook;   {call the users idle hook procedure}
         if ReadFromBuffer then             {1.00e}
            Finished := true
         else if vMouseMethod > 0 then
         begin
{$IFDEF DPMI}                                             {1.10}
            ThisPress := MemL[Seg0040:$006C];   {get time}
{$ELSE}
            ThisPress := MemL[$0040:$006C];   {get time}
{$ENDIF}
            Keyword := 0;
            Mouse.Status(L,C,R,X,Y);
            if L or R or C then {a button is being depressed}
            begin
               Finished := true;
               { Next is the mouse speed up effect }
               if ((ThisPress - vLastPress) <= Initdelay) then
               begin
                  LeftPresses := Mouse.Released(0,TempX,TempY);
                  RightPresses := Mouse.Released(1,TempX,TempY);
                  if vButtons > 2 then
                     CenterPresses := Mouse.Released(2,TempX,TempY)
                  else
                     CenterPresses := 0;
                  {Check for mouse combinations}
                  ButtonCombinations :=   ord(LeftPresses > 0)
                                        + 2*ord(RightPresses > 0)
                                        + 4*ord(CenterPresses > 0);
                  case ButtonCombinations of
                     1: Keyword := 513;  {left button}
                     2: Keyword := 514;  {right button}
                     3: Keyword := 516;  {left+right}
                     4: Keyword := 515;  {center button}
                     5: Keyword := 517;  {left+center}
                     6: Keyword := 518;  {center+right}
                     7: Keyword := 519;  {all three buttons}
                  end;
                  if (vLastX = X) and (vLastY = Y) then
                     if LeftPresses > 0 then
                        if vLastkey = 513 then Keyword := 523      {double left}
                     else if RightPresses > 0 then
                        if vlastkey = 514 then Keyword := 524      {double right}
                     else if CenterPresses > 0 then
                        if vLastkey = 515 then Keyword := 525;     {double center}
               end
               else
               begin
                  delay(QwikDelay);
                  Temp := Mouse.Pressed(0,TempX,TempY);   {clear the mouse buffers}
                  Temp := Mouse.Pressed(1,TempX,TempY);
                  Temp := Mouse.Pressed(2,TempX,TempY);
                  Temp := Mouse.Released(0,TempX,TempY);
                  Temp := Mouse.Released(1,TempX,TempY);
                  Temp := Mouse.Released(2,TempX,TempY);
               end;
               vLastPress := ThisPress;
               If Keyword = 0 then
               begin
                  if L then
                     Keyword := 513
                  else
                    if R then
                       Keyword := 514
                    else
                       Keyword := 515;
               end;
            end;
            if vMouseMethod = 1 then
            Case keyword of
            513,523,515,516,517,519,523,525: keyword := 13;
            514,518,524: keyword := 27;
            else
            begin
               Mouse.Location(X,Y);
               if Y - V > vVertSensitivity then
               begin
                  Keyword :=  592;   {mouse down}        {1.00b}
                  Finished := true;
               end
               else if V - Y > vVertSensitivity then
               begin
                  Keyword :=  584;   {mouse up}
                  Finished := true;
               end
               else if X - H > vHorizSensitivity then
               begin
                  Keyword :=  587;   {mouse right}
                  Finished := true;
               end
               else if H - X > vHorizSensitivity then
               begin
                  Keyword :=  589;   {mouse left}
                  Finished := true;
               end
            end;
            end; {case}
         end; {if}
         If KeyPressed or Finished then
            Action := true;
      until Action;
      if not finished then
      begin
        Ch := ReadKey;
        if Ch = #0 then
        begin
            Ch := Readkey;
            Keyword := 256+ord(Ch);
            if (KeyWord >= 327) and (Keyword <= 339) then
            begin
               if AltPressed then
                  inc(Keyword,80)
               else if (ShiftPressed and vExtended) then  {1.00c}
                  inc(Keyword,100)
               else if CtrlPressed then
                  inc(Keyword,120);
            end;
        end
        else
           KeyWord := ord(Ch);
      end;

   end;
   vPressedHook(Keyword);
   vLastKey := Keyword;
   vLastX := X;
   vLastY := Y;
   if vClick then
      Click;
end; {KeyOBJ.GetInput}

function KeyOBJ.Lastkey: word;
{}
begin
   LastKey := vLastKey;
end; {KeyOBJ.Lastkey}

function KeyOBJ.GetKey: word;
{}
begin
   GetInput;
   GetKey := vLastKey;
end; {KeyOBJ.GetKey}

function KeyOBJ.LastChar: char;
{}
begin
   if vLastKey < 256 then
      LastChar := chr(LastKey)
   else
      LastChar := #0;
end; {KeyOBJ.LastChar}

function KeyOBJ.LastX: byte;
{}
begin
   LastX := vLastX;
end; {KeyOBJ.LastX}

function KeyOBJ.LastY: byte;
{}
begin
   LastY := vLastY;
end; {KeyOBJ.LastY}

procedure KeyOBJ.FlushBuffer;
{}
var Regs: registers;
begin
   vBufferTail := VBufferHead; {empty program buffer}
   with Regs do
   begin
      Ax := ($0c shl 8) or 6;
      Dx := $00ff;
   end;
   Intr($21,Regs);
end; {KeyOBJ.FlushBuffer}

procedure KeyOBJ.StuffBuffer(W:word);
{adds word to program keyboard buffer}
begin
   if (vBufferTail + 1 = vBufferHead)
   or ((vBufferTail = StuffBufferSize) and (vBufferHead = 1)) then
      exit; {buffer full}     
   vBuffer[vBufferTail] := W;
   if vBufferTail < StuffBufferSize then
      inc(vBufferTail)
   else
      vBufferTail := 1;
end; {KeyOBJ.StuffBuffer}

procedure KeyOBJ.StuffBufferStr(Str:string);
{}
var I,L : byte;
begin
   if Str <> '' then
   begin
      I := 1;
      L := length(Str);
      if L > StuffBufferSize then
         L := StuffBufferSize;
      while I <= L do
      begin
         StuffBuffer(ord(Str[I]));
         inc(I);
      end;
   end; 
end; {KeyOBJ.StuffBufferStr}

function KeyOBJ.Keypressed: boolean;   {1.00d}
{}
var Regs:Registers;
begin
   if (vBufferTail <> vBufferHead) then
      KeyPressed := true
   else
   begin
      if vExtended then
         Regs.Ah := $11
      else
         Regs.Ah := $01;
      intr($16,Regs);
      KeyPressed := (Regs.Flags and FZero) <> $40;
   end;
end; {KeyOBJ.KeyPressed}

procedure KeyOBJ.DelayKey(Mills:longint);
{}
var
  EndTime: longint;
  Now: longint;

   procedure SetNull;
   begin
      vLastKey := 0;
      vLastX := 0;
      vLastY := 0;
   end;

begin
   if Mills <= 0 then
      SetNull
   else
   begin
{$IFDEF DPMI}
      EndTime := MemL[seg0040:$006C] + trunc( (Mills/1000)*18.2);
      Repeat
         Now := MemL[seg0040:$006C];
      until Keypressed or (Now >= EndTime);
{$ELSE}
      EndTime := MemL[$40:$6C] + trunc( (Mills/1000)*18.2);
      Repeat
         Now := MemL[$40:$6C];
      until Keypressed or (Now >= EndTime);
{$ENDIF}
      if KeyPressed then
         GetInput
      else
         SetNull;
   end;
end; {KeyOBJ.DelayKey}

function KeyOBJ.AltPressed:boolean;
var
  AltW : word;
begin
   AltW := swap(KeyStatusBits^ );
   AltPressed := (AltW and $0800) <> 0;
end; {KeyOBJ.AltPressed}

function KeyOBJ.CtrlPressed:boolean;
var
  CtrlW : word;
begin
   CtrlW := swap(KeyStatusBits^ );
   CtrlPressed := (CtrlW and $0400) <> 0;
end; {KeyOBJ.CtrlPressed}

function KeyOBJ.LeftShiftPressed: boolean;
{}
var LSW : word;
begin
   LSW := swap(KeyStatusBits^ );
   LeftShiftPressed := (LSW and $0200) <> 0;
end; {LeftShiftPressed}

function KeyOBJ.RightShiftPressed: boolean;
{}
var RSW : word;
begin
   RSW := swap(KeyStatusBits^ );
   RightShiftPressed := (RSW and $0100) <> 0;
end; {RightShiftPressed}

function KeyOBJ.ShiftPressed: boolean;
{}
var SW : word;
begin
   SW := swap(KeyStatusBits^ );
   ShiftPressed := ((SW and $0200) <> 0) or ((SW and $0100) <> 0);
end; {ShiftPressed}

destructor KeyOBJ.Done;
{}
begin end; {of desc KeyOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure InputInit;
{initilizes objects and global variables}
begin
{$IFDEF DPMI}
   KeyStatusBits := ptr(seg0040,$0017);
{$ELSE}
   KeyStatusBits := ptr($0040,$0017);
{$ENDIF}
   new(AlphabetTOT,Init);
   Mouse.Init;
   Key.Init;
end;

{end of unit - add intialization routines below}
{$IFNDEF OVERLAY}
begin
   {$IFDEF INITTRACE}writeln('inputinit');{$ENDIF}
   InputInit;
{$ENDIF}
end.
