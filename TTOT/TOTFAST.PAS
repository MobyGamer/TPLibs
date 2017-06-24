{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10t                            }

Unit totFAST;
{$I TOTFLAGS.INC}

{
 Development History:
             Mar 15 91  1.00a   Changed DesqView checks
             May  3 91  1.00b   Read Char checks
             May  3 91  1.00c   Changed virtual write and writeln
             Jun  2 91  1.00d   Corrected WriteOBJ CRT calls
             Jul 10 91  1.00e   Corrected WriteCenter method, and CursOff
             Nov 06 91  1.00f   Real correction of WriteCenter
             Feb 05 92  1.00g   Corrected cursor restores after saves
             Feb 26 17  trixfix Extensive fixups and enhancements (req.TP 7.0)

trixfix notes: In the interest of speed and code size, several functions
from this unit were removed and the entire library's codebase was rewritten
to use the object's variables instead.  This is backwards from proper OOP
practice, but greatly slims down the generated code.

}

Interface

Uses objects, DOS, CRT, totSYS, totLOOK, totINPUT; {trixfix}

Type
  
  StrScreen = String [255];   {alter as necessary}
  StrVisible = String [80];   {alter as necessary}
  tDirection = (Up, Down, Left, Right, Vert, Horiz);
  tCoords = Record
              X1, Y1, X2, Y2: ShortInt;
            End;
  tByteCoords = Record
                  X1, Y1, X2, Y2: Byte;
                End;
  ShadowPosition = (UpLeft, UpRight, DownLeft, DownRight);
  
  WritePtr = ^WriteOBJ;
  pWriteOBJ = ^WriteOBJ;
  WriteOBJ = Object (TObject)
               vWidth: Byte;           {how wide is screen}
               vScreenPtr: Pointer;    {memory location of screen data}
               vWindow: tByteCoords;   {active screen area}
               vWindowOn: Boolean;     {is window area active}
               vWindowIgnore: Boolean; {ignore window settings}
               vTempX: Byte;
               vTempY: Byte;
               {methods...}
               Constructor Init;
               Procedure   SetScreen (Var P: Pointer; W: Byte);
               Function    WindowOff: Boolean;
               Procedure   SetWinIgnore (On: Boolean);
               Procedure   WindowOn;
               Procedure   WindowCoords (Var Coords: tByteCoords);
               Function    WindowActive: Boolean;
               Function    WindowInEffect: Boolean;
               Function    WinX: Byte;
               Function    WinY: Byte;
               Procedure   GetWinCoords (Var X1, Y1, X2, Y2: Byte);
               Procedure   GetCursorPos;
               Procedure   SetCursorPos;
               Procedure   WriteAT (X, Y, Attr: Byte; Str: String);       Virtual;
               Procedure   WritePlain (X, Y: Byte; Str: String);          Virtual;
               Procedure   Write (Str: String);                          Virtual;
               Procedure   WriteLn (Str: String);                        Virtual;
               Procedure   GotoXY (X, Y: Word);                          Virtual;
               Function    WhereX: Word;                                 Virtual;
               Function    WhereY: Word;                                 Virtual;
               Procedure   SetWindow (X1, Y1, X2, Y2: Byte);             Virtual;
               Procedure   ResetWindow;                                 Virtual;
               Procedure   ChangeAttr (X, Y, ATT: Byte; Len: Word);       Virtual;
               Procedure   MoveFromScreen (Var Source, Dest; Len: Word); Virtual;
               Procedure   MoveToScreen (Var Source, Dest; Len: Word);   Virtual;
               Procedure   Clear (ATT: Byte; CH: Char);                   Virtual;
               Destructor  Done;                                        Virtual;
             End; {WriteOBJ}
  
  ScreenPtr = ^ScreenOBJ;
  pScreenOBJ = ^ScreenOBJ;
  ScreenOBJ = Object (TObject)
                vWidth: Byte;           {how wide is screen}
                vDepth: Byte;           {how many lines}
                vScreenPtr: Pointer;    {memory location of screen data}
                vCursX: Byte;           {cursor location}
                vCursY: Byte;           {      -"-      }
                vCursTop: Byte;         {cursor size}
                vCursBot: Byte;         {    -"-    }
                oWritePtr: WritePtr;    {screen writing and moving object}
                vHiMarker: Char;        {character to indicate attribute change}
                vVisible: Boolean;      {is the screen mapped to visible display}
                vOnScreen: Boolean;
                {methods...}
                Constructor Init;
                Procedure   SetHiMarker (M: Char);
                (*Function    HiMarker: Char;*)
                Procedure   AssignWriteOBJ (Var Wri: WriteOBJ);
                Procedure   SetWindow (X1, Y1, X2, Y2: Byte);
                Procedure   SetWinIgnore (On: Boolean);
                Procedure   ResetWindow;
                Function    WindowOff: Boolean;
                Procedure   WindowOn;
                Procedure   WindowCoords (Var Coords: tByteCoords);
                Function    WindowActive: Boolean;
                Function    OnScreen: Boolean;
                Function    CharHeight: Integer;
                Procedure   CursReset;
                Procedure   CursSave;
                Procedure   GotoXY (X, Y: Word);
                Procedure   CursSize (T, B: Byte);
                Function    WhereX: Word;
                Function    WhereY: Word;
                (*Function    CursTop: Byte;*)
                (*Function    CursBot: Byte;*)
                Procedure   CursHalf;
                Procedure   CursFull;
                Procedure   CursOn;
                Procedure   CursOff;
                Procedure   Exists; 
                Procedure   MoveToScreen (Var Source, Dest; Length: Word);
                Procedure   MoveFromScreen (Var Source, Dest; Length: Word);
                Procedure   Save;
                Procedure   Create (X, Y, Attr: Byte);
                Function    Width: Byte;
                Function    Depth: Byte;
                (*Function    ScreenPtr: Pointer;*)
                Procedure   Display;
                Procedure   PartDisplay (X1, Y1, X2, Y2, X, Y: Byte);
                Procedure   PartSlideDisplay (X1, Y1, X2, Y2: Byte; Way: tDirection);
                Procedure   SlideDisplay (Way: tDirection);
                Procedure   PartSave (X1, Y1, X2, Y2: Byte; Var Dest);
                Procedure   PartRestore (X1, Y1, X2, Y2: Byte; Var Source);
                Procedure   CopyScreenBlock (X1, Y1, X2, Y2, X, Y: Byte);
                Procedure   MoveScreenBlock (X1, Y1, X2, Y2, X, Y: Byte);
                Procedure   Scroll (Way: tDirection; X1, Y1, X2, Y2: Byte);
                Procedure   Write (Str: String);
                Procedure   WriteLn (Str: String);
                Procedure   WriteAT (X, Y, Attr: Byte; Str: String);
                Procedure   WriteHi (X, Y, AttrHi, Attr: Byte; Str: String);
                Procedure   WritePlain (X, Y: Byte; Str: String);
                Procedure   WriteCap (X, Y, AttrCap, Attr: Byte; Str: String);
                Procedure   WriteClick (X, Y, Attr: Byte; Str: String);
                Procedure   WriteCenter (Y, Attr: Byte; Str: String);
                Procedure   WriteBetween (X1, X2, Y, Attr: Byte; Str: String);
                Procedure   WriteRight (X, Y, Attr: Byte; Str: String);
                Procedure   WriteVert (X, Y, Attr: Byte; Str: String);
                Procedure   Attrib (X1, Y1, X2, Y2, Attr: Byte);
                Procedure   TrixShadowAttrib (X1, Y1, X2, Y2, Attr: Byte);
                Procedure   Clear (ATT: Byte; CH: Char);
                Procedure   PartClear (X1, Y1, X2, Y2, ATT: Byte; CH: Char);
                Procedure   ClearText (X1, Y1, X2, Y2: Byte);
                Procedure   ReadWord (X, Y: Byte; Var Attr: Byte; Var CH: Char);
                Function    ReadChar (X, Y: Byte): Char;
                Function    ReadAttr (X, Y: Byte): Byte;
                Function    ReadStr (X1, X2, Y: Byte): String;
                Procedure   BoxEngine (X1,Y1,X2,Y2,LeftPad,RightPad,Battr,Tattr,Mattr,style:Byte;Filled:Boolean;Title:String);
                Procedure   TitleEngine (X1, Y1, X2, Y2, LeftPad, RightPad, Battr, Tattr: Byte; Str, Title: String);
                Procedure   Box (X1, Y1, X2, Y2, Attr, style: Byte);
                Procedure   FillBox (X1, Y1, X2, Y2, Attr, style: Byte);
                Procedure   ShadFillBox (X1, Y1, X2, Y2, Attr, style: Byte);
                Procedure   TitledBox (X1, Y1, X2, Y2, Battr, Tattr, Mattr, style: Byte; Title: String);
                Procedure   HorizLine (X1, X2, Y, Attr, Style: Byte);
                Procedure   VertLine (X, Y1, Y2, Attr, Style: Byte);
                Procedure   SmartVertLine (X, Y1, Y2, Attr, Style: Byte);
                Procedure   SmartHorizLine (X1, X2, Y, Attr, Style: Byte);
                Procedure   WriteHScrollBar (X1, X2, Y, Attr: Byte; Current, Max: LongInt);
                Procedure   WriteVScrollBar (X, Y1, Y2, Attr: Byte; Current, Max: LongInt);
                Destructor  Done; Virtual;
              End; {ScreenOBJ}

  pScrollOBJ = ^ScrollOBJ;
  ScrollOBJ = Object (TObject)
                vUpArrowChar: Char;
                vDownArrowChar: Char;
                vLeftArrowChar: Char;
                vRightArrowChar: Char;
                vElevatorChar: Char;
                vBackgroundChar: Char;
                {methods...}
                Constructor Init;
                Procedure   SetDefaults;
                Procedure   SetScrollChars (U, D, L, R, E, B: Char);
                (*Function    UpChar: Char;
                Function    DownChar: Char;
                Function    LeftChar: Char;
                Function    RightChar: Char;
                Function    ElevatorChar: Char;
                Function    BackgroundChar: Char;*)
                Destructor  Done; Virtual;
              End; {ScrollOBJ}

  pShadowOBJ = ^ShadowOBJ;
  ShadowOBJ = Object (TObject)
                vShadPos: ShadowPosition;   {where is shadow}
                vShadAttr: Byte;            {shadow attribute}
                vShadChar: Char;            {shadow character - ' ' is see-through}
                vShadWidth: Byte;           {shadow width in characters}
                vShadDepth: Byte;           {shadow depth in characters}
                {methods...}
                Constructor Init;
                Procedure   SetDefaults;
                Procedure   SetShadowStyle (ShadP: ShadowPosition; ShadA: Byte; ShadC: Char);
                Procedure   SetShadowSize (ShadW, ShadD: Byte);
                (*Function    ShadWidth: Byte;
                Function    ShadDepth: Byte;
                Function    ShadAttr: Byte;
                Function    ShadChar: Char;
                Function    ShadPos: ShadowPosition;*)
                Procedure   DrawShadow (Border: tCoords);
                Procedure   DrawShadowXY (X1, Y1, X2, Y2: Integer);
                Procedure   OuterCoords (Border: tCoords; Var Outer: tCoords);
                Procedure   OuterXY (Var X1, Y1, X2, Y2: Integer);
                Destructor  Done; Virtual;
              End; {ShadowOBJ}

Var
  Screen: ScreenOBJ;
  ScrollTOT:^ScrollOBJ;
  ShadowTOT:^ShadowOBJ;
  SnowProne: Byte;

Function  CAttr (F, B: Byte): Byte;
Function  FAttr (A: Byte): Byte;
Function  BAttr (A: Byte): Byte;
Function  Replicate (N: Byte; Character: Char): String;
Procedure fastINIT;
Procedure fastDONE; {trixfix}

Implementation
Const
  TitPos: String [6] = '<+>^|_';  {characters signifying box title position}
  WinCursX: Byte = 1;
  WinCursY: Byte = 1;
  {|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
  {                                                               }
  {     U N I T   P R O C E D U R E S   &   F U N C T I O N S     }
  {                                                               }
  {|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||}

  Procedure Error (Err: Byte);
  {temp routine to display error - replace with object}
Const
  Header = 'totFAST error:';
Var
  Msg: String;
Begin
  Case Err Of
    1: Msg := 'Not enough RAM to init screen';
    2: Msg := 'Can''t write to inactive screen';
    3: Msg := 'Not enough RAM for screen copy';
    Else  Msg := 'Unknown Error';
  End; {case}
  WriteLn (Header, Msg);
  Halt;
End; {Error}

Function CAttr (F, B: Byte): Byte;
{converts foreground(F) and background(B) colors to combined Attribute byte}
Begin
  CAttr := (B ShL 4) Or F;
End;  {CAttr}

Function FAttr (A: Byte): Byte;
{returns the foreground color from an attribute Byte}
Begin
  FAttr := A And 15;
End; {FAttr}

Function BAttr (A: Byte): Byte;
{returns the background color from an attribute Byte}
Begin
  BAttr := (A And $70) ShR 4;
End; {FAttr}

Function Replicate (N: Byte; Character: Char): String;
{returns a string with Character repeated N times}
Var tempstr: String;
Begin
  If N = 0
  Then TempStr := ''
  Else Begin
    FillChar (tempstr, N + 1, Character);
    Tempstr [0] := Chr (N);
  End;
  Replicate := Tempstr;
End; {replicate}

{$L totFAST}
{$F+}
  Procedure AsmWrite (Var scrptr; Wid, Col, Row, Attr: Byte; St: String); External;
  Procedure AsmPWrite (Var scrptr; Wid, Col, Row: Byte; St: String); External;
  Procedure AsmAttr (Var scrptr; Wid, Col, Row, Attr, Len: Byte); External;
  Procedure AsmMoveFromScreen (Var Source, Dest; Length: Word); External;
  Procedure AsmMoveToScreen (Var Source, Dest; Length: Word); External;
{$IFNDEF OVERLAY}
   {$F-}
{$ENDIF}

{|||||||||||||||||||||||||||||||||||||||||}
{                                         }
{     W r i t e O B J   M E T H O D S     }
{                                         }
{|||||||||||||||||||||||||||||||||||||||||}
Constructor WriteOBJ.Init;
{}
Begin
  Inherited Init; {trixfix}
  vWindowOn := False;
  vWindowIgnore := False;
End; {WriteOBJ.Init}

Procedure WriteOBJ.SetScreen (Var P: Pointer; W: Byte);
{}
Begin
  vScreenPtr := P;
  vWidth := W;
End; {WriteOBJ.SetScreen}

Procedure WriteOBJ.SetWindow (X1, Y1, X2, Y2: Byte);
{}
Begin
  If Monitor^.BaseofScreen = vScreenPtr Then  {1.00d}
  Begin
    GetCursorPos;   {1.00g}
    CRT.Window (X1, Y1, X2, Y2);
    SetCursorPos;
  End;
  vWindow.X1 := X1;
  vWindow.Y1 := Y1;
  vWindow.X2 := X2;
  vWindow.Y2 := Y2;
  vWindowOn := True;
End; {WriteOBJ.SetWindow}

Procedure WriteOBJ.GetWinCoords (Var X1, Y1, X2, Y2: Byte);
{}
Begin
  X1 :=  vWindow.X1;
  Y1 :=  vWindow.Y1;
  X2 :=  vWindow.X2;
  Y2 :=  vWindow.Y2;
End; {WriteOBJ.GetWinCoords}

Procedure WriteOBJ.ResetWindow;
{}
Var H, W: Byte;
Begin
  W := Monitor^.Width;
  H := Monitor^.Depth;
  If Monitor^.BaseofScreen = vScreenPtr Then  {1.00d}
  Begin {trixfix}
    getcursorpos;
    CRT.Window (1, 1, W, H);
    SetCursorPos;
  End;
  vWindow.X1 := 1;
  vWindow.Y1 := 1;
  vWindow.X2 := W;
  vWindow.Y2 := H;
  vWindowOn := False;
End; {WriteOBJ.ResetWindow}

Function WriteOBJ.WindowOff: Boolean;
{}
Begin
  If vWindowOn Then
  Begin
    vWindowOn := False;
    WinCursX := WhereX;
    WinCursY := WhereY;
    If Monitor^.BaseofScreen = vScreenPtr Then  {1.00d}
    Begin
      GetCursorPos;  {1.00g}
      CRT.Window (1, 1, Monitor^.Width, Monitor^.Depth);
      SetCursorPos;  {1.00g}
    End;
    WindowOff := True;
  End
  Else
    WindowOff := False;
End; {WriteOBJ.WindowOff}

Procedure WriteOBJ.WindowOn;
{}
Begin
  vWindowOn := True;
  Window (vWindow.X1, vWindow.Y1, vWindow.X2, vWindow.Y2);
  GotoXY (WinCursX, WinCursY);
End; {WriteOBJ.WindowOn}

Procedure WriteOBJ.WindowCoords (Var Coords: tByteCoords);
{}
Begin
  Coords := vWindow;
End; {WriteOBJ.WindowCoords}

Function WriteOBJ.WindowActive: Boolean;
{}
Begin
  WindowActive := vWindowOn;
End; {WriteOBJ.WindowActive}

Function WriteOBJ.WindowInEffect: Boolean;
{}
Begin
  WindowInEffect := vWindowOn And Not vWindowIgnore;
End; {WriteOBJ.WindowActive}

Procedure WriteOBJ.SetWinIgnore (On: Boolean);
{}
Begin
  vWindowIgnore := On;
End; {WriteOBJ.SetWinIgnore}

Function WriteOBJ.WinX: Byte;
{}
Begin
  If vWindowOn And Not vWindowIgnore Then
    WinX := vWindow.X1
  Else
    WinX := 1;
End; {WriteOBJ.WinX}

Function WriteOBJ.WinY: Byte;
{}
Begin
  If vWindowOn And Not vWindowIgnore Then
    WinY := vWindow.Y1
  Else
    WinY := 1;
End; {WriteOBJ.WinY}

Procedure WriteOBJ.WriteAT (X, Y, Attr: Byte; Str: String);
{}
Begin
  If Not vWindowOn Or vWindowIgnore Then
    ASMWrite (vScreenPtr^, vWidth, X, Y, Attr, Str)
  Else
  Begin
    Str := Copy (Str, 1, vWindow.X2 - Pred (X) - Pred (vWindow.X1) );
    If Y + Pred (vWindow.Y1) <= vWindow.Y2 Then
      ASMWrite (vScreenPtr^, vWidth, Pred (vWindow.X1) + X,
      Pred (vWindow.Y1) + Y,
      Attr, Str);
  End;
End; {WriteOBJ.WriteAT}

Procedure WriteOBJ.WritePlain (X, Y: Byte; Str: String);
{}
Begin
  If Not vWindowOn Or vWindowIgnore Then
    ASMPWrite (vScreenPtr^, vWidth, X, Y, Str)
  Else
  Begin
    Str := Copy (Str, 1, vWindow.X2 - Pred (X) - Pred (vWindow.X1) );
    If Y + Pred (vWindow.Y1) <= vWindow.Y2 Then
      ASMPWrite (vScreenPtr^, vWidth, Pred (vWindow.X1) + X,
      Pred (vWindow.Y1) + Y,
      Str);
  End;
End; {WriteOBJ.WritePlain}

Procedure WriteOBJ.Write (Str: String);
{}
Begin
  If Monitor^.BaseofScreen = vScreenPtr Then
    System.Write (Str)
  Else
  Begin
    
  End;
End; {WriteOBJ.Write}

Procedure WriteOBJ.WriteLn (Str: String);
{}
Begin
  System.WriteLn (Str);
End; {WriteOBJ.WriteLn}

Procedure WriteOBJ.GetCursorPos;
{}
Var Regs: Registers;
Begin
  With Regs Do
  Begin
    AH := 3;
    BH := 0;
  End;
  Intr ($10, Regs);
  vTempY := Regs.DH;
  vTempX := Regs.DL;
End; {WriteOBJ.GetCursorPos}

Procedure WriteOBJ.SetCursorPos;
{}
Var
  Regs: Registers;
Begin
  With Regs Do
  Begin
    AH := 2;
    BH := 0;
    DH := vTempY;
    DL := vTempX;
  End;
  Intr ($10, Regs);
End; {WriteOBJ.SetCursorPos}

Procedure WriteOBJ.GotoXY (X, Y: Word);
{}
Var Regs: Registers;
Begin
  If vWindowOn And vWindowIgnore Then
  Begin
    With Regs Do
    Begin
      AH := 2;
      DH := Pred (Y);
      DL := Pred (X);
      BH := 0;
    End;
    Intr ($10, Regs);
  End
  Else
    CRT.GotoXY (X, Y);
End; {WriteOBJ.GotoXY}

Function  WriteOBJ.WhereX: Word;
{}
Begin
  WhereX := CRT.WhereX;
End; {WriteOBJ.WhereX}

Function  WriteOBJ.WhereY: Word;
{}
Begin
  WhereY := CRT.WhereY;
End; {WriteOBJ.WhereY}

Procedure WriteOBJ.ChangeAttr (X, Y, ATT: Byte; Len: Word);
{}
Begin
  If Not vWindowOn Or vWindowIgnore Then
    ASMAttr (vScreenPtr^, vWidth, X, Y, ATT, Len)
  Else
  Begin
    Inc (X, Pred (vWindow.X1) );
    Inc (Y, Pred (vWindow.Y1) );
    If (X <= vWindow.X2) And (Y <= vWindow.Y2) Then
    Begin
      If X + Len > vWindow.X2 Then
        Len := vWindow.X2 - Pred (X);
      ASMAttr (vScreenPtr^, vWidth, X, Y, ATT, Len)
    End;
  End;
End; {WriteOBJ.ChangeAttr}

Procedure WriteOBJ.MoveFromScreen (Var Source, Dest; Len: Word);
{}
Begin
  ASMMoveFromScreen (Source, Dest, Len);
End; {WriteOBJ.MoveFromScreen}

Procedure WriteOBJ.MoveToScreen (Var Source, Dest; Len: Word);
{}
Begin
  ASMMoveToScreen (Source, Dest, Len);
End; {WriteOBJ.MoveToScreen}

Procedure WriteOBJ.Clear (ATT: Byte; CH: Char);
{}
Var
  I: Integer;
  S: String;
Begin
  With vWindow Do
  Begin
    S := Replicate (Succ (X2 - X1), CH);
    For I := 1 To Succ (Y2 - Y1) Do
    Begin
      ChangeAttr (X1, Y1, ATT, Succ (X2 - X1) );
      WritePlain (1, I, S);
    End;
  End;
End; {WriteOBJ.Clear}

Destructor WriteOBJ.Done;
{}
Begin
  Inherited Done; {trixfix}
End; {WriteOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     S c r e e n O B J   M E T H O D S     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
Constructor ScreenOBJ.Init;
{}
Begin
  Inherited Init; {trixfix}
  vScreenPtr := Nil;
  vHiMarker := '~';
  vVisible := False;
  vOnScreen := False;
  New (oWritePtr, Init);
  oWritePtr^.SetScreen (vScreenPtr, vWidth);
  ResetWindow;
End; {ScreenOBJ.Init}

Procedure ScreenOBJ.SetHiMarker (M: Char);
{}
Begin
  vHiMarker := M;
End; {ScreenOBJ.SetHiMarker}

(*Function ScreenOBJ.HiMarker: Char;
{}
Begin
  Himarker := vHiMarker;
End; {ScreenOBJ.Himarker}
*)

Procedure ScreenOBJ.AssignWriteOBJ (Var Wri: WriteOBJ);
{}
Begin
  Dispose (oWritePtr, Done);
  oWritePtr := @Wri;
  oWritePtr^.SetScreen (vScreenPtr, vWidth);
End; {ScreenOBJ.AssignWriteOBJ}

Procedure ScreenOBJ.SetWindow (X1, Y1, X2, Y2: Byte);
{}
Begin
  oWritePtr^.SetWindow (X1, Y1, X2, Y2);
End; {ScreenOBJ.SetWindow}

Procedure ScreenOBJ.SetWinIgnore (On: Boolean);
{}
Begin
  oWritePtr^.SetWinIgnore (On);
End; {ScreenOBJ.SetWinIgnore}

Procedure ScreenOBJ.ResetWindow;
{}
Begin
  oWritePtr^.ResetWindow;
End; {ScreenOBJ.ResetWindow}

Function ScreenOBJ.WindowOff: Boolean;
{}
Begin
  WindowOff := oWritePtr^.WindowOff;
End; {ScreenOBJ.WindowOff}

Procedure ScreenOBJ.WindowOn;
{}
Begin
  oWritePtr^.WindowOn;
End; {ScreenOBJ.WindowOn}

Procedure ScreenOBJ.WindowCoords (Var Coords: tByteCoords);
{}
Begin
  oWritePtr^.WindowCoords (Coords);
End; {ScreenOBJ.WindowCoords}

Function ScreenOBJ.WindowActive: Boolean;
{}
Begin
  WindowActive := oWritePtr^.WindowActive;
End; {ScreenOBJ.WindowActive}
{|||||||||||||||||||||||||||||||||}
{     C U R S O R   S T U F F     }
{|||||||||||||||||||||||||||||||||}
Function ScreenOBJ.OnScreen: Boolean;
{is this instance the visible screen}
Begin
  OnScreen := vOnScreen;
End; {ScreenOBJ.OnScreen}

Function ScreenOBJ.CharHeight: Integer;
{get height of text mode characters for cursor manipulation}
Var
  Regs: Registers;
Begin
  If OnScreen Then
  Begin
    Case Monitor^.DisplayType Of
      Mono: CharHeight := 14;
      EGACol,
      CGA: CharHeight := 8;
      Else
        With Regs Do
        Begin
          AH := $11;
          AL := $30;
          BX := $0;
          Intr ($10, Regs);
          CharHeight := CX;
        End; {with}
    End;  {case}
  End
  Else        {virtual screen assume normal mode}
  Begin
    If Monitor^.DisplayType = Mono Then
      CharHeight := 14
    Else
      CharHeight := 8;
  End;
End; {ScreenOBJ.CharHeight}

Procedure ScreenOBJ.CursReset;
{}
Begin
  GotoXY (1, 1);
  CursOn;
End; {ScreenOBJ.CursReset}

Procedure ScreenOBJ.CursSave;
{updates instance with visible Cursor details}
Var Reg: Registers;
Begin
  With Reg Do
  Begin
    AX := $0F00; {get page in Bx}
    Intr ($10, reg);
    AX := $0300;
    Intr ($10, reg);
    vCursX := Lo (DX) + 1;
    vCursY := Hi (DX) + 1;
    vCursTop := Hi (CX) And $0F;
    vCursBot := Lo (CX) And $0F;
  End;
End; {ScreenOBJ.CursSave}

Procedure ScreenOBJ.CursSize (T, B: Byte);
{}
Var Reg: Registers;
Begin
  If OnScreen Then {writing to a visible screen}
  Begin
    With reg Do
    Begin
      AX := $0100;
      If (T = 0) And (B = 0) Then
        CX := $2020         {Thanks Yaron!! 1.00e}
      Else
      Begin
        (*  
        If you have an odd video bios and cursor changes
        are strange, enable this next line.
        mem[$40:$87]:= mem[$40:$87] or $01; {get cursor ownership from BIOS}
        *)
        CH := T;
        CL := B;
      End;
      Intr ($10, Reg);
    End;
  End;
  vCursTop := T;
  vCursBot := B;
End; {ScreenOBJ.CursSize}

Function ScreenOBJ.WhereX: Word;
{}
Begin
  If OnScreen Then {writing to a visible screen}
    WhereX := oWritePtr^.WhereX
  Else
    WhereX := vCursX;
End; {ScreenOBJ.WhereX}

Function ScreenOBJ.WhereY: Word;
{}
Begin
  If OnScreen Then {writing to a visible screen}
    WhereY := oWritePtr^.WhereY
  Else
    WhereY := vCursY;
End; {ScreenOBJ.WhereY}

Procedure ScreenOBJ.GotoXY (X, Y: Word);
{}
Begin
  If OnScreen Then {writing to a visible screen}
    oWritePtr^.GotoXY (X, Y)
  Else
  Begin
    vCursX := X;
    vCursY := Y;
  End;
End; {ScreenOBJ.CursGotoXY}

(*Function ScreenOBJ.CursTop: Byte;
{}
Begin
  CursTop := vCursTop;
End; {ScreenOBJ.CursTOP}*)

(*Function ScreenOBJ.CursBot: Byte;
{}
Begin
  CursBot := vCursBot;
End; {ScreenOBJ.CursBot}*)

Procedure ScreenOBJ.CursHalf;
{}
Var CharSize: Byte;
Begin
  CharSize := CharHeight;
  CursSize (CharSize Div 2, Pred (CharSize) );
End; {ScreenOBJ.CursHalf}

Procedure ScreenOBJ.CursFull;
{}
Var CharSize: Byte;
Begin
  CharSize := CharHeight;
  CursSize (0, CharSize);
End; {ScreenOBJ.CursFull}

Procedure ScreenOBJ.CursOn;
{}
Var CharSize: Byte;
Begin
  CharSize := CharHeight;
  CursSize (CharSize-3, CharSize-2);
End; {ScreenOBJ.CursOn}

Procedure ScreenOBJ.CursOff;
{}
Begin
  CursSize (0, 0);
End; {ScreenOBJ.CursOff}
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{     S C R E E N    S A V E    &    R E S T O R E     }
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
Procedure ScreenOBJ.Exists;
{makes sure there is a screen on the heap}
Begin
  If vScreenPtr = Nil Then
    Error (2);
End; {ScreenOBJ.Exists}

Procedure ScreenOBJ.Create (X, Y, Attr: Byte);
{}
Var MemoryNeeded: LongInt;
Begin
  MemoryNeeded := X * Y * 2;
  If MaxAvail < MemoryNeeded Then
    Error (1)
  Else
  Begin
    If (X = 0) And (Y = 0) Then    {map to physical screen}
    Begin
      vWidth := Monitor^.Width;
      (*
      vDepth:= 50;              {set to max for extended line displays}
      *)
      vDepth := Monitor^.Depth;
      vVisible := True;
      vScreenPtr := Monitor^.BaseOfScreen; {1.00a}
      oWritePtr^.SetScreen (vScreenPtr, vWidth);
      vOnScreen := True;
      CursSave;
      ResetWindow;
    End
    Else
    Begin
      vWidth := X;
      vDepth := Y;
      GetMem (vScreenPtr, MemoryNeeded);
      oWritePtr^.SetScreen (vScreenPtr, vWidth);
      SetWindow (1, 1, X, Y);
      Clear (Attr, ' ');
      CursReset;
    End;
  End;
End; {ScreenOBJ.Create}

Procedure ScreenOBJ.MoveFromScreen (Var Source, Dest; Length: Word);
{}
Begin
  oWritePtr^.MoveFromScreen (Source, Dest, Length);
End; {ScreenOBJ.MoveFromScreen}

Procedure ScreenOBJ.MoveToScreen (Var Source, Dest; Length: Word);
{}
Begin
  oWritePtr^.MoveToScreen (Source, Dest, Length);
End; {ScreenOBJ.MoveToScreen}

Procedure ScreenOBJ.Save;
{saves current screen to instance}
{trixfix - reformatted for better debugging}
Var
  MemoryNeeded: LongInt;
  MVisible: Boolean;
  WinCoords: tByteCoords;
Begin
  If vScreenPtr <> Nil
  Then FreeMem (vScreenPtr, Width * Depth * 2);
  MemoryNeeded := Monitor^.Width * Monitor^.Depth * 2;
  If MaxAvail < MemoryNeeded
  Then Error (1)
  Else Begin
    vWidth := Monitor^.Width;
    vDepth := Monitor^.Depth;
    GetMem (vScreenPtr, MemoryNeeded);
    MVisible := Mouse.Visible;
    If MVisible
    Then Mouse.Hide;
    MoveFromScreen (Monitor^.BaseOfScreen^, vScreenPtr^, vWidth * vDepth);
    CursSave;
    oWritePtr^.SetScreen (vScreenPtr, vWidth);
    Screen.WindowCoords (WinCoords);
    With WinCoords Do
      SetWindow (X1, Y1, X2, Y2);
    If MVisible
    Then Mouse.Show;
  End;
End; {ScreenOBJ.Save}

Function ScreenOBJ.Width: Byte;
{}
Begin
  Width := vWidth;
End; {ScreenOBJ.Width}

Function ScreenOBJ.Depth: Byte;
{}
Begin
  If vVisible Then
  Begin
    Depth := Monitor^.Depth
  End
  Else
    Depth := vDepth;
End; {ScreenOBJ.Depth}

(*Function ScreenOBJ.ScreenPtr: Pointer;
{}
Begin
  ScreenPtr := vScreenPtr;
End; {ScreenOBJ.ScrPtr}*)

Procedure ScreenOBJ.Display;
{}
Var
  Wid, Dep: Byte;
  MVisible: Boolean;
  WinCoords: tByteCoords;
Begin
  {$IFNDEF FINAL}
  Exists;
  {$ENDIF}
  MVisible := Mouse.Visible;
  If MVisible Then
    Mouse.Hide;
  If Width = Monitor^.Width Then  {one big move}
    MoveToScreen (vScreenPtr^, Monitor^.BaseOfScreen^, width * Monitor^.Depth)
  Else
  Begin
    Wid := Monitor^.Width;
    If Wid > vWidth Then
      Wid := vWidth;
    Dep := Monitor^.Depth;
    If Dep > vDepth Then
      Dep := vDepth;
    PartDisplay (1, 1, Wid, Dep, 1, 1);
  End;
  {now restore cursor details}
  WindowCoords (WinCoords);
  With WinCoords Do
    Screen.SetWindow (X1, Y1, X2, Y2);
  Screen.GotoXY (WhereX, WhereY);
  Screen.CursSize (vCursTop, vCursBot);
  If MVisible Then           (* Change to restore Mouse Details *)
    Mouse.Show;
End; {ScreenOBJ.Display}

Procedure ScreenOBJ.PartDisplay (X1, Y1, X2, Y2, X, Y: Byte);
{}
Var
  MonitorWidth,
  ScreenWidth,
  SectionWidth  : Byte;
  I             : Integer;
  VisibleAdr,
  VirtualAdr    : Word;
  VisiblePtr,
  VirtualPtr    : Pointer;
  MVisible: Boolean;
Begin
  If X2 > vWidth Then
    X2 := vWidth;
  If Y2 > vDepth Then
    Y2 := vDepth;
  SectionWidth := Succ (X2 - X1);
  MonitorWidth := Monitor^.Width;
  ScreenWidth := Width;
  VirtualPtr := vScreenPtr;
  VisiblePtr := Monitor^.BaseOfScreen;
  MVisible := Mouse.Visible;
  If MVisible Then
    Mouse.Hide;
  For I :=  Y1 To Y2 Do
  Begin
    VisibleAdr := Pred (Y + I - Y1) * MonitorWidth * 2 + Pred (X) * 2;
    VirtualAdr := Pred (I) * ScreenWidth * 2 + Pred (X1) * 2;
    MoveToScreen (Mem [Seg (VirtualPtr^): Ofs (VirtualPtr^) + VirtualAdr],
    Mem [Seg (VisiblePtr^): Ofs (VisiblePtr^) + VisibleAdr],
    Sectionwidth);
  End;
  If MVisible Then
    Mouse.Show;
End; {ScreenOBJ.PartDisplay}

Procedure ScreenOBJ.PartSlideDisplay (X1, Y1, X2, Y2: Byte; Way: tDirection);
{}
Var
  I: Integer;
Begin
  Case Way Of
    Up   :
          Begin
            For I := Y2 Downto Y1 Do
            Begin
              PartDisplay (X1, Y1, X2, Y1 + Y2 - I, X1, I);
              Delay (50);
            End;
          End;
    Down :
          Begin
            For I := Y1 To Y2 Do
            Begin
              PartDisplay (X1, Y1 + Y2 - I, X2, Y2, X1, Y1);
              Delay (50);  {savor the moment!}
            End;
          End;
    Left :
          Begin
            For I := X1 To X2 Do
            Begin
              PartDisplay (X1, Y1, I, Y2, X1 + X2 - I, Y1);
            End;
          End;
    Right:
          Begin
            For I := X2 Downto X1 Do
            Begin
              PartDisplay (I, Y1, X2, Y2, X1, Y1);
            End;
          End;
    Vert:  For I := Y1 To Y1 + (Y2 - Y1) Div 2 Do
    Begin
      PartDisplay (X1, I, X2, I, X1, I);
      PartDisplay (X1, Y2 + Y1 - I, X2, Y2 + Y1 - I, X1, Y2 + Y1 - I);
      Delay (50);
    End;
    Horiz: For I := X1 To X1 + Succ (X2 - X1) Div 2 Do
    Begin
      PartDisplay (I, Y1, I, Y2, I, Y1);
      PartDisplay ( (X2) + X1 - I, Y1, (X2) + X1 - I, Y2, (X2) + X1 - I, Y1);
      Delay (10);
    End;
  End; {case}
End; {ScreenOBJ.PartSlideDisplay}

Procedure ScreenOBJ.SlideDisplay (Way: tDirection);
{}
Var
  WinCoords: tByteCoords;
  X,Y: Byte;
Begin
  X := Monitor^.Width; If X > vWidth Then X := vWidth;
  Y := Monitor^.Depth; If Y > vDepth Then Y := vDepth;
  PartSlideDisplay (1, 1, X, Y, Way);
  {now restore cursor details}
  X := WhereX;
  Y := WhereY;
  Screen.SetWindow (1, 1, Monitor^.Width, Monitor^.Depth); {1.00g}
  Screen.GotoXY (X, Y);
  Screen.CursSize (vCursTop, vCursBot);
  WindowCoords (WinCoords);
  With WinCoords Do
    Screen.SetWindow (X1, Y1, X2, Y2);
End; {ScreenOBJ.SlideDisplay}

Procedure ScreenOBJ.PartSave (X1, Y1, X2, Y2: Byte; Var Dest);
{transfers data from active virtual screen to Dest}
Var
  I, wid: Byte;
  ScreenAdr: Integer;
  MVisible: Boolean;
Begin
  wid := Succ (X2 - X1);
  MVisible := Mouse.Visible;
  If MVisible Then
    Mouse.Hide;
  For I :=  Y1 To Y2 Do
  Begin
    {ScreenAdr:= Pred(I)*160 + Pred(X1)*2;}
    ScreenAdr := Pred (I) * (vwidth * 2) + Pred (X1) * 2; {trixfix}
    MoveFromScreen (Mem [Seg (vScreenPtr^): Ofs (vScreenPtr^) + ScreenAdr],
    Mem [Seg (Dest): Ofs (dest) + (I - Y1) * wid * 2],
    wid);
  End;
  If MVisible Then
    Mouse.Show;
End; {ScreenOBJ.PartSave}

Procedure ScreenOBJ.PartRestore (X1, Y1, X2, Y2: Byte; Var Source);
{restores data from Source and transfers to active virtual screen
 - used internally}
Var
  I, wid: Byte;
  ScreenAdr: Integer;
  MVisible: Boolean;
Begin
  wid := Succ (X2 - X1);
  MVisible := Mouse.Visible;
  If MVisible Then
    Mouse.Hide;
  For I :=  Y1 To Y2 Do
  Begin
    {ScreenAdr:= Pred(I)*160 + Pred(X1)*2;}
    ScreenAdr := Pred (I) * (vwidth * 2) + Pred (X1) * 2; {trixfix}
    MoveToScreen (Mem [Seg (Source): Ofs (Source) + (I - Y1) * wid * 2],
    Mem [Seg (vScreenPtr^): Ofs (vScreenPtr^) + ScreenAdr],
    wid);
  End;
  If MVisible Then
    Mouse.Show;
End; {ScreenOBJ.PartRestore}

Procedure ScreenOBJ.CopyScreenBlock (X1, Y1, X2, Y2, X, Y: Byte);
{copies text and attributes from one part of screen to another}
Var
  S: Word;
  SPtr: Pointer;
  MVisible: Boolean;
Begin
  S := Succ (Y2 - Y1) * Succ (X2 - X1) * 2;
  If MaxAvail < S Then
    Error (3)
  Else
  Begin
    MVisible := Mouse.Visible;
    If MVisible Then
      Mouse.Hide;
    GetMem (SPtr, S);
    PartSave (X1, Y1, X2, Y2, SPtr^);
    PartRestore (X, Y, X + X2 - X1, Y + Y2 - Y1, SPtr^);
    FreeMem (SPtr, S);
    If MVisible Then
      Mouse.Show;
  End;
End; {ScreenOBJ.CopyScreenBlock}

Procedure ScreenOBJ.MoveScreenBlock (X1, Y1, X2, Y2, X, Y: Byte);
{Moves text and attributes from one part of screen to another,
 replacing with Replace_Char}
Const
  Replace_Char = ' ';
Var
  S: Word;
  SPtr: Pointer;
  I: Integer;
  ST: String;
  MVisible: Boolean;
Begin
  S := Succ (Y2 - Y1) * Succ (X2 - X1) * 2;
  If MaxAvail < S Then
    Error (3)
  Else
  Begin
    MVisible := Mouse.Visible;
    If MVisible Then
      Mouse.Hide;
    GetMem (SPtr, S);
    PartSave (X1, Y1, X2, Y2, SPtr^);
    St := Replicate (Succ (X2 - X1), Replace_Char);
    For I := Y1 To Y2 Do
      WritePlain (X1, I, St);
    PartRestore (X, Y, X + X2 - X1, Y + Y2 - Y1, SPtr^);
    FreeMem (SPtr, S);
    If MVisible Then
      Mouse.Show;
  End;
End; {ScreenOBJ.MoveScreenBlock}

Procedure ScreenOBJ.Scroll (Way: tDirection; X1, Y1, X2, Y2: Byte);
{used for screen scrolling, uses Copy & Plainwrite for speed}
Const
  Replace_Char = ' ';
Var
  I: Integer;
Begin
  Case Way Of
    Up  :
         Begin
           CopyScreenBlock (X1, Succ (Y1), X2, Y2, X1, Y1);
           WritePlain (X1, Y2, replicate (Succ (X2 - X1), Replace_Char) );
         End;
    Down:
         Begin
           CopyScreenBlock (X1, Y1, X2, Pred (Y2), X1, Succ (Y1) );
           WritePlain (X1, Y1, replicate (Succ (X2 - X1), Replace_Char) );
         End;
    Left:
         Begin
           CopyScreenBlock (Succ (X1), Y1, X2, Y2, X1, Y1);
           For I := Y1 To Y2 Do
             WritePlain (X2, I, Replace_Char);
         End;
    Right:
          Begin
            CopyScreenBlock (X1, Y1, Pred (X2), Y2, Succ (X1), Y1);
            For I := Y1 To Y2 Do
              WritePlain (X1, I, Replace_Char);
          End;
  End; {case}
End; {ScreenOBJ.Scroll}
{||||||||||||||||||||||||||||||||||||}
{     S C R E E N    W R I T E S     }
{||||||||||||||||||||||||||||||||||||}
Procedure ScreenOBJ.Write (Str: String);
{write at the cursor position using the default attributes, and
 moves cursor to end of string}
Var 
  NewX: Integer; {1.00c}
  X, Y: Byte;
  MVisible: Boolean;
Begin
  {$IFNDEF FINAL}
  Exists;
  {$ENDIF}
  MVisible := Mouse.Visible And vOnScreen;  {1.00c}
  X := WhereX + Pred (oWritePtr^.WinX);
  Y := WhereY + Pred (oWritePtr^.WinY);
  If MVisible And Mouse.InZone (X, Y, X + Length (Str), Y) Then
  Begin
    Mouse.Hide;
    oWritePtr^.Write (Str);
    Mouse.Show;
  End
  Else If vOnScreen Then {1.00c}
    oWritePtr^.Write (Str)
  Else
  Begin
    oWritePtr^.WritePlain (vCursX, vCursY, Str);
    NewX := vCursX + Length (Str);
    vCursX := NewX Mod vWidth;
    Inc (vCursY, NewX Div vWidth);
  End;
End; {ScreenOBJ.Write}

Procedure ScreenOBJ.WriteLn (Str: String);
{write at the cursor position using the default attributes, and
 moves cursor to next line}
Var
  X, Y: Integer;
  MVisible: Boolean;
Begin
  {$IFNDEF FINAL}
  Exists;
  {$ENDIF}
  MVisible := Mouse.Visible And vOnScreen;  {1.00c}
  X := WhereX + Pred (oWritePtr^.WinX);
  Y := WhereY + Pred (oWritePtr^.WinY);
  If MVisible And Mouse.InZone (X, Y, X + Length (Str), Y) Then
  Begin
    Mouse.Hide;
    oWritePtr^.WriteLn (Str);
    Mouse.Show;
  End
  Else If vOnScreen Then {1.00c}
    oWritePtr^.WriteLn (Str)
  Else
  Begin
    oWritePtr^.WritePlain (vCursX, vCursY, Str);
    vCursX := 1;
    Inc (vCursY);
  End;
End; {ScreenOBJ.WriteLn}

Procedure ScreenOBJ.WriteAT (X, Y, Attr: Byte; Str: String);
{}
Var
  MVisible: Boolean;
  GlobalX, GlobalY: Byte;
Begin
  {$IFNDEF FINAL}                  
  Exists;                       
  {$ENDIF}
  If Attr = 0 Then
    WritePlain (X, Y, Str)
  Else
  Begin
    MVisible := Mouse.Visible And vOnScreen;  {1.00c}
    GlobalX := X + Pred (oWritePtr^.WinX);
    GlobalY := Y + Pred (oWritePtr^.WinY);
    If MVisible And Mouse.InZone (GlobalX, GlobalY, GlobalX + Length (Str), GlobalY) Then
    Begin
      Mouse.Hide;
      oWritePtr^.WriteAT (X, Y, Attr, Str);
      Mouse.Show;
    End
    Else
      oWritePtr^.WriteAT (X, Y, Attr, Str);
  End;
End; {ScreenOBJ.WriteAT}

Procedure ScreenOBJ.WriteHi (X, Y, AttrHi, Attr: Byte; Str: String);
{}
Var 
  P: Byte;
  Hi: Boolean;
  
Procedure WriteBit (Str: String);
     Begin
       If Hi Then
         WriteAt (X, Y, AttrHi, Str)
       Else
         WriteAt (X, Y, Attr, Str);
     End;

Begin
  Hi := False;
  P := Pos (vHiMarker, Str);
  While P <> 0 Do
  Begin
    If P > 1 Then
      WriteBit (Copy (Str, 1, Pred (P) ) );
    Delete (Str, 1, P);
    Inc (X, Pred (P) );
    P := Pos (vHiMarker, Str);
    Hi := Not Hi;
  End;
  WriteBit (Str);
End; {ScreenOBJ.WriteHi}

Procedure ScreenOBJ.WritePlain (X, Y: Byte; Str: String);
{}
Var
  MVisible: Boolean;
  GlobalX, GlobalY: Byte;
Begin
  {$IFNDEF FINAL}
  Exists;
  {$ENDIF}
  MVisible := Mouse.Visible And vOnScreen;  {1.00c}
  GlobalX := X + Pred (oWritePtr^.WinX);
  GlobalY := Y + Pred (oWritePtr^.WinY);
  If MVisible And Mouse.InZone (GlobalX, GlobalY, GlobalX + Length (Str), GlobalY) Then
  Begin
    Mouse.Hide;
    oWritePtr^.WritePlain (X, Y, Str);
    Mouse.Show;
  End
  Else
    oWritePtr^.WritePlain (X, Y, Str);
End; {ScreenOBJ.WritePlain}

Procedure ScreenOBJ.WriteCap (X, Y, AttrCap, Attr: Byte; Str: String);
{Writes a string with the first capital letter in a different color}
Var
  CapPos: Byte;
Begin
  If Str <> '' Then
  Begin
    WriteAt (X, Y, Attr, Str);   {write whole string in default cols}
    CapPos := 1;
    While (CapPos <= Length (Str) )
          And   ( (Str [CapPos] In [#65..#90] ) = False) 
    Do
      Inc (CapPos);
    If CapPos <= Length (Str) Then
      WriteAt (X + Pred (CapPos), Y, AttrCap, Str [CapPos] );
  End;
End; {ScreenOBJ.WriteCap}

Procedure ScreenOBJ.WriteClick (X, Y, Attr: Byte; Str: String);
{writes text to the screen with a click!}
Var
  I: Integer;
  L: Byte;
Begin
  L := Length (Str);
  If OnScreen Then
    For I := L Downto 1 Do
    Begin
      WriteAt (X, Y, Attr, Copy (Str, I, Succ (L - I) ) );
      Sound (500); Delay (20); NoSound; Delay (30);
    End
  Else
    WriteAt (X, Y, Attr, Str); {don't click if not visible}
End; {ScreenOBJ.WriteClick}

Procedure ScreenOBJ.WriteCenter (Y, Attr: Byte; Str: String);
{trixfix} {40-col needs truncation or it errors out}
Var
  X1, Y1, X2, Y2: Byte;
  X: Integer;
Begin
  If oWritePtr^.WindowInEffect Then Begin
    oWritePtr^.GetWinCoords (X1, Y1, X2, Y2);
    X := (Succ (X2 - X1) - Length (Str) ) Div 2;
  End Else Begin
    If Length (Str) >= width Then Byte (Str [0] ) := width - 1;
    X :=  (Width - Length (Str) ) Div 2;
  End;
  Inc (X);                      {1.00e/f}
  If X < 1
  Then X := 1;
  WriteAt (X, Y, Attr, Str);
End; {ScreenOBJ.WriteCenter}

Procedure ScreenOBJ.WriteBetween (X1, X2, Y, Attr: Byte; Str: String);
{}
Var X: Integer;
Begin
  If Length (Str) >= X2 - X1 + 1 Then
    WriteAt (X1, Y, Attr, Str)
  Else
  Begin
    X := X1 + (X2 - X1 + 1 - Length (Str) ) Div 2 ;
    WriteAt (X, Y, Attr, Str);
  End;
End; {ScreenOBJ.WriteBetween}

Procedure ScreenOBJ.WriteRight (X, Y, Attr: Byte; Str: String);
{writes a right-justified string to the screen}
Var X1: Integer;
Begin
  X1 := Succ (X - Length (Str) );
  If X1 < 1 Then
    X1 := 1;
  WriteAT (X1, Y, Attr, Str);
End; {ScreenOBJ.WriteRight}

Procedure ScreenOBJ.WriteVert (X, Y, Attr: Byte; Str: String);
{}
Var
  L: Byte;
  I: Integer;
Begin
  L := Length (Str);
  If L > Succ (Monitor^.Depth) - Y Then
    L := Succ (Monitor^.Depth) - Y;
  For I := 1 To L Do
    WriteAt (X, Y - 1 + I, Attr, Str [I] );
End; {ScreenOBJ.WriteVert}

Procedure ScreenOBJ.Attrib (X1, Y1, X2, Y2, Attr: Byte);
{changes color attrib at specified coords}
Var
  I: Integer;
  X: Byte;
  MVisible: Boolean;
Begin
  {$IFNDEF FINAL}
  Exists;
  {$ENDIF}
  MVisible := Mouse.Visible;
  If MVisible Then
    Mouse.Hide;
  X := Succ (X2 - X1);
  For I := Y1 To Y2 Do
    oWritePtr^.ChangeAttr (X1, I, Attr, X);
  If MVisible Then
    Mouse.Show;
End; {ScreenOBJ.Attrib}

Procedure ScreenOBJ.TrixShadowAttrib (X1, Y1, X2, Y2, Attr: Byte);
{"shadows" the color attrib at specified coords by un-setting the hi bit
in the foreground attribute.This is a much more realistic shadow
than just overwriting whatever is there.}
Var
  I: Integer;
  X: Byte;
  a, f, b: Byte;
Begin
  {$IFNDEF FINAL}
  Exists;
  {$ENDIF}
  If Mouse.Visible
  Then Mouse.Hide;
  X := Succ (X2 - X1);
  For I := Y1 To Y2 Do Begin
    {if background less than 8, set to 0; otherwise, dim by 8
    if foreground less than 8, set to 8; otherwise, dim by 8}
    a := ReadAttr (X1, I);
    b := a ShR 4;
    f := a And $0F;
    If b < 8 Then b := 0 Else b := b - 8;
    If f < 8 Then f := 8 Else f := f - 8;
    a := (b ShL 4) Or f;
    oWritePtr^.ChangeAttr (X1, I, a, X);
  End;
  If Not Mouse.Visible
  Then Mouse.Show;
End;

Procedure ScreenOBJ.Clear (ATT: Byte; CH: Char);
{}
Begin
  PartClear (1, 1, Width, Depth, ATT, CH);
End; {ScreenOBJ.Clear}

Procedure ScreenOBJ.PartClear (X1, Y1, X2, Y2, ATT: Byte; CH: Char);
{}
{trixfix I guess the original idea was for screen effects, but this is
just slow, so going to speed it up a little}
Var
  I: Integer;
  S: String;
Begin
  {Attrib (X1, Y1, X2, Y2, ATT);}
  S := Replicate (Succ (X2 - X1), CH);
  For I := Y1 To Y2 Do
    {WritePlain (X1, I, S);}
    WriteAt (X1, I, ATT, S);
End; {ScreenOBJ.PartClear}

Procedure ScreenOBJ.ClearText (X1, Y1, X2, Y2: Byte);
{}
Var
  I: Integer;
  S: String;
Begin
  S := Replicate (Succ (X2 - X1), ' ');
  For I := Y1 To Y2 Do
    WritePlain (X1, I, S);
End; {ScreenOBJ.ClearText}

Procedure ScreenOBJ.ReadWord (X, Y: Byte; Var Attr: Byte; Var CH: Char);
{updates vars Attr and Ch with attribute and character bytes in screen
 location (X,Y) of the active screen}
Type
  ScreenWordRec = Record
                    CH  : Char;
                    Attr: Byte;
                  End;
Var
  VisiblePtr: Pointer;
  VisibleAdr: Word;
  SW: ScreenWordRec;
Begin
  X := X + Pred (oWritePtr^.WinX);
  Y := Y + Pred (oWritePtr^.WinY);
  VisiblePtr := vScreenPtr;                {1.00b}
  VisibleAdr := Pred (Y) * Monitor^.Width * 2 + Pred (X) * 2;
  MoveFromScreen (mem [Seg (VisiblePtr^): Ofs (VisiblePtr^) + VisibleAdr],
  mem [Seg (SW): Ofs (SW) ], 1);
  Attr := SW.Attr;
  CH  := SW.CH;
End; {ScreenOBJ.ReadWord}

Function ScreenOBJ.ReadChar (X, Y: Byte): Char;
Var
  A: Byte;
  C: Char;
Begin
  ReadWord (X, Y, A, C);
  ReadChar := C;
End; {ScreenOBJ.ReadChar}

Function ScreenOBJ.ReadAttr (X, Y: Byte): Byte;
Var
  A: Byte;
  C: Char;
Begin
  ReadWord (X, Y, A, C);
  ReadAttr := A;
End; {ScreenOBJ.ReadAttr}

Function ScreenOBJ.ReadStr (X1, X2, Y: Byte): String;
Var
  I: Integer;
  Str: String;
Begin
  Str := '';
  For I := X1 To X2 Do
    Str := Str + ReadChar (I, Y);
  ReadStr := Str;
End; {ScreenOBJ.ReadStr}

Procedure ScreenOBJ.TitleEngine (X1, Y1, X2, Y2, LeftPad, RightPad, Battr, Tattr: Byte;
                                Str, Title: String);
{}
Var
  TitVert: Byte; {0-top, 1-dropbox, 2-bottom}
  TitHoriz: Byte; {0-left, 1-center, 2-right}
  MaxWidth: Integer;
  X, Y: Byte;
Begin
  If (Title [2] In [TitPos [1], TitPos [2], TitPos [3] ] )
     And (Title [1] In [TitPos [4], TitPos [5], TitPos [6] ] ) 
  Then {swap 'em}
  Begin
    Insert (Title [2], Title, 1);
    Delete (Title, 3, 1);
  End;
  If Title [1] = TitPos [1] Then
    TitHoriz := 0
  Else If Title [1] = TitPos [3] Then
    TitHoriz := 2
  Else
    TitHoriz := 1;
  If Title [1] In [TitPos [1], TitPos [2], TitPos [3] ] Then
    Delete (Title, 1, 1);
  If Title = '' Then Exit;
  If (Title [1] = TitPos [5] ) And (Y2 - Y1 > 1) Then
    TitVert := 1
  Else If Title [1] = TitPos [6] Then
    TitVert := 2
  Else
    TitVert := 0;
  If Title [1] In [TitPos [4], TitPos [5], TitPos [6] ] Then
    Delete (Title, 1, 1);
  If Title = '' Then Exit;
  {check title is narrow enough to fit}
  If TitVert = 1 Then 
    MaxWidth :=  Pred (X2 - X1)
  Else
    MaxWidth := X2 - X1 - 3;
  If TitVert = 0 Then
    Dec (MaxWidth, LeftPad + RightPad);
  If MaxWidth <= 0 Then
    Title := ''
  Else
    Delete (Title, Succ (MaxWidth), 255);  {truncate title}
  Case Titvert Of
    0:
      Begin
        Case TitHoriz Of
          0: WriteAt (Succ (X1) + LeftPad, Y1, Tattr, Title);
          1: WriteBetween (Succ (X1) + LeftPad, Pred (X2) - RightPad, Y1, Tattr, Title);
          Else WriteRight (Pred (X2) - RightPad, Y1, Tattr, Title);
        End; {case}
      End;
    1:
      Begin
        WriteAt (X1, Y1 + 2, Battr, Str [8] +
        replicate (Pred (X2 - X1), Str [2] ) +
        Str [5] );
        Case TitHoriz Of
          0: WriteAt (Succ (X1), Succ (Y1), Tattr, Title);
          1: WriteBetween (X1, X2, Succ (Y1), Tattr, Title);
          Else WriteRight (Pred (X2), Succ (Y1), Tattr, Title);
        End; {case}
      End;
    2:
      Begin
        Case TitHoriz Of
          0: WriteAt (Succ (X1), Y2, Tattr, Title);
          1: WriteBetween (X1, X2, Y2, Tattr, Title);
          Else WriteRight (Pred (X2), Y2, Tattr, Title);
        End; {case}
      End;
  End; {case}
End; {ScreenOBJ.TitleEngine}

Procedure ScreenOBJ.BoxEngine (X1, Y1, X2, Y2, LeftPad, RightPad, Battr, Tattr, MAttr, style: Byte;
                              Filled: Boolean;
                              Title: String);
{Used internally by Box and FBox}
Const
  Style1: String [10] = 'ÚÄ¿³´ÙÀÃ³Ä';
  Style2: String [10] = 'ÉÍ»º¹¼ÈÌºÍ';
  Style3: String [10] = 'ÖÄ·º¶½ÓÇºÄ';
  Style4: String [10] = 'ÕÍ¸³µ¾ÔÆ³Í';
  Style5: String [10] = 'ÚÄ·³µ¼ÔÆºÍ';
Var
  Line,
  FLine,
  Str: String;
  I: Integer;
Begin
  If Style = 6 Then
  Begin
    PartClear (X1, Y1, X2, Y2, Mattr, ' ');
    WriteAT (X1, Y1, BAttr, replicate (X2 - Pred (X1), Char (223) ) );
    WriteAT (X1, Y1 + 2, BAttr, replicate (X2 - Pred (X1), {'_'} 'Ä') );
    WriteBetween (X1, X2, Succ (Y1), Tattr, Title);
  End
  Else
  Begin
    Case Style Of
      0: Str := '          ';
      1: Str := Style1;
      2: Str := Style2;
      3: Str := Style3;
      4: Str := Style4;
      5: Str := Style5;
      Else Str := Replicate (10, Chr (style) );
    End;
    WriteAt (X1, Y1, Battr, Str [1] );
    Line := replicate (Pred (X2 - X1), Str [2] );
    WriteAt (X1 + 1, Y1, Battr, Line);
    WriteAt (X2, Y1, Battr, Str [3] );
    For I := Y1 + 1 To Y2 - 1 Do
    Begin
      WriteAt (X1, I, Battr, Str [4] );
      WriteAt (X2, I, Battr, Str [9] );
    End;
    If Filled Then
      PartClear (Succ (X1), Succ (Y1), Pred (X2), Pred (Y2), MAttr, ' ');
    WriteAt (X1, Y2, Battr, Str [7] );
    Line := replicate (Pred (X2 - X1), Str [10] );
    WriteAt (X1 + 1, Y2, Battr, Line);
    WriteAt (X2, Y2, Battr, Str [6] );
    {now the title:extract the first two character positions, and draw it}
    If Title <> '' Then
      TitleEngine (X1, Y1, X2, Y2, LeftPad, RightPad, Battr, Tattr, Str, Title);
  End;
End; {BoxEngine}

Procedure ScreenOBJ.Box (X1, Y1, X2, Y2, Attr, style: Byte);
{draws box and leaves internal area as is}
Begin
  BoxEngine (X1, Y1, X2, Y2, 0, 0, Attr, Attr, Attr, Style, False, '');
End; {ScreenOBJ.Box}

Procedure ScreenOBJ.FillBox (X1, Y1, X2, Y2, Attr, style: Byte);
{draws box and erases internal area}
Begin
  BoxEngine (X1, Y1, X2, Y2, 0, 0, Attr, Attr, Attr, Style, True, '');
End; {ScreenOBJ.FillBox}

Procedure ScreenOBJ.ShadFillBox (X1, Y1, X2, Y2, Attr, style: Byte);
{draws box and erases internal area}
Begin
  BoxEngine (X1, Y1, X2, Y2, 0, 0, Attr, Attr, Attr, Style, True, '');
  ShadowTOT^.DrawShadowXY (X1, Y1, X2, Y2);
End; {ScreenOBJ.ShadFillBox}

Procedure ScreenOBJ.TitledBox (X1, Y1, X2, Y2, Battr, Tattr, MAttr, style: Byte; Title: String);
{}
Begin
  BoxEngine (X1, Y1, X2, Y2, 0, 0, Battr, Tattr, MAttr, Style, True, title);
End; {ScreenOBJ.TitledFillBox}

Procedure ScreenOBJ.HorizLine (X1, X2, Y, Attr, Style: Byte);
Var
  I: Integer;
  LineChar: Char;
Begin
  Case Style Of
    0  : LineChar := ' ';
    2, 4: LineChar := 'Í';
    1, 3: LineChar := 'Ä';
    Else LineChar := Chr (Style);
  End; {case}
  WriteAt (X1, Y, Attr, replicate (X2 - X1 + 1, LineChar) )
End;   {ScreenOBJ.HorizLine}

Procedure ScreenOBJ.VertLine (X, Y1, Y2, Attr, Style: Byte);
{}
Var
  I: Integer;
  LineChar: Char;
Begin
  Case Style Of
    0  : LineChar := ' ';
    2, 4: LineChar := 'º';
    1, 3: LineChar := '³';
    Else LineChar := Chr (Style);
  End; {case}
  For I := Y1 To Y2 Do
    WriteAt (X, I, Attr, LineChar)
End; {ScreenOBJ.VertLine}

Procedure ScreenOBJ.SmartVertLine (X, Y1, Y2, Attr, Style: Byte);
{draws box character and adjust any lines it overlays}
Var
  I: Integer;
  LineStr: String [19];
  TestCh,
  CH: Char;
  StringOffset: Byte;

Function AdjacentChar (X, Y: Byte): Char;
    {}
    Begin
      If (X < 1) Or (X > width) Then
        AdjacentChar := ' '
      Else
        AdjacentChar := ReadChar (X, Y);
    End; {AdjacentChar}

    Function LineCh (X, Y: Byte): Char;
    {}
    Const
      LeftSingle: String [13] = 'ÄÂ¿Å´ÁÙÒ·×¶Ð½';
      LeftDouble: String [13] = 'ÍË»Î¹Ê¼Ñ¸ØµÏ¾';
      RightSingle: String [13] = 'ÚÄÂÃÅÀÁÖÒÇ×ÓÐ';
      RightDouble: String [13] = 'ÉÍËÌÎÈÊÕÑÆØÔÏ';
    Var
      LineStyle: Char;
    Begin
      LineStyle := AdjacentChar (Pred (X), Y);
      If Pos (LineStyle, RightSingle) > 0 Then
        LineStyle := 'Ä'
      Else If Pos (LineStyle, RightDouble) > 0 Then
        LineStyle := 'Í'
      Else
        LineStyle := ' ';
      Case LineStyle Of
        'Ä': If Pos (AdjacentChar (Succ (X), Y), leftSingle) > 0 Then
          CH := LineStr [2 + StringOffset]
        Else
          CH := LineStr [3 + StringOffset];
        'Í': If Pos (AdjacentChar (Succ (X), Y), LeftDouble) > 0 Then
          CH := LineStr [4 + StringOffset]
        Else
          CH := LineStr [5 + StringOffset];
        Else  TestCh := AdjacentChar (Succ (X), Y);
        If Pos (TestCh, LeftSingle) > 0 Then
          CH := LineStr [6 + StringOffset]
        Else If Pos (TestCh, LeftDouble) > 0  Then
          CH := LineStr [7 + StringOffset]
        Else
          CH := LineStr [1];
      End; {case}
      LineCh := CH;
    End; {LineCh}

Begin
  If Style In [2, 4] Then
    LineStr := 'ºÒ·Ë»ÖÉ×¶Î¹ÇÌÐ½Ê¼ÓÈ'
  Else
    LineStr := '³Â¿Ñ¸ÚÕÅ´ØµÃÆÁÙÏ¾ÀÔ';
  {draw first character}
  StringOffSet := 0;
  WriteAt (X, Y1, Attr, LineCh (X, Y1) );
  StringOffSet := 6;
  For I := Succ (Y1) To Pred (Y2) Do
    WriteAt (X, I, Attr, LineCh (X, I) );
  StringOffSet := 12;
  WriteAt (X, Y2, Attr, LineCh (X, Y2) );
End; {ScreenOBJ.SmartVertLine}

Procedure ScreenOBJ.SmartHorizLine (X1, X2, Y, Attr, Style: Byte);
{draws box character and adjust any lines it overlays}
Var
  I: Integer;
  LineStr: String [19];
  TestCh,
  CH: Char;
  StringOffset: Byte;
  
Function AdjacentChar (X, Y: Byte): Char;
    {}
    Begin
      If (Y < 1) Or (Y > depth) Then
        AdjacentChar := ' '
      Else
        AdjacentChar := ReadChar (X, Y);
    End; {AdjacentChar}

    Function LineCh (X, Y: Byte): Char;
    {}
    Const
      DownSingle: String [13] = 'ÚÂ¿³ÃÅ´ÕÑ¸ÆØµ';
      
      DownDouble: String [13] = 'ÉË»ºÌÎ¹ÖÒ·Ç×¶';
      
      UpSingle:  String [13] = '³ÃÅ´ÀÁÙÆØµÔÏ¾';
      
      UpDouble:  String [13] = 'ºÌÎ¹ÈÊ¼Ç×¶ÓÐº';
    Var
      LineStyle: Char;
    Begin
      LineStyle := AdjacentChar (X, Pred (Y) );
      If Pos (LineStyle, DownSingle) > 0 Then
        LineStyle := '³'
      Else If Pos (LineStyle, DownDouble) > 0 Then
        LineStyle := 'º'
      Else                    
        LineStyle := ' ';
      Case LineStyle Of
        '³': If Pos (AdjacentChar (X, Succ (Y) ), UpSingle) > 0 Then
          CH := LineStr [2 + StringOffset]
        Else
          CH := LineStr [3 + StringOffset];
        'º': If Pos (AdjacentChar (X, Succ (Y) ), UpDouble) > 0 Then
          CH := LineStr [4 + StringOffset]
        Else
          CH := LineStr [5 + StringOffset];
        Else  TestCh := AdjacentChar (X, Succ (Y) );
        If Pos (TestCh, UpSingle) > 0 Then
          CH := LineStr [6 + StringOffset]
        Else If Pos (TestCh, UpDouble) > 0 Then
          CH := LineStr [7 + StringOffset]
        Else
          CH := LineStr [1];
      End; {case}
      LineCh := CH;
    End; {LineCh}

Begin
  If Style In [2, 4] Then
    LineStr := 'ÍÆÔÌÈÕÉØÏÎÊÑËµ¾¹¼¸» '
  Else
    LineStr := 'ÄÃÀÇÓÚÖÅÁ×ÐÂÒ´Ù¶½¿·';
  {draw first character}
  StringOffSet := 0;
  WriteAt (X1, Y, Attr, LineCh (X1, Y) );
  StringOffSet := 6;
  For I := Succ (X1) To Pred (X2) Do
    WriteAt (I, Y, Attr, LineCh (I, Y) );
  StringOffSet := 12;
  WriteAt (X2, Y, Attr, LineCh (X2, Y) );
End; {ScreenOBJ.SmartHorizLine}

Procedure ScreenOBJ.WriteHScrollBar (X1, X2, Y, Attr: Byte; Current, Max: LongInt);
{}
Var 
  X, LineLength: Integer;
Begin
  WriteAT (X1, Y, Attr, ScrollTOT^.vLeftArrowChar);
  WriteAT (X2, Y, Attr, ScrollTOT^.vRightArrowChar);
  WriteAT (Succ (X1), Y, Attr, replicate (Pred (X2 - X1), ScrollTOT^.vBackgroundChar) );
  If (Current > 0) And (Max >= Current) Then
  Begin
    LineLength := X2 - Succ (X1);
    If LineLength > 0 Then
    Begin
      X := (Current * LineLength) Div Max;
      If Current >= Max Then
        X := Pred (LineLength);
      If (X < 0) Or (Current = 1) Then
        X := 0;
      WriteAT (Succ (X1) + X, Y, Attr, ScrollTOT^.vElevatorChar);
    End;
  End;
End; {ScreenOBJ.WriteHScrollBar}

Procedure ScreenOBJ.WriteVScrollBar (X, Y1, Y2, Attr: Byte; Current, Max: LongInt);
{}
Var 
  BC: Char;
  I, Y, LineLength: Integer;
Begin
  WriteAT (X, Y1, Attr, ScrollTOT^.vUpArrowChar);
  WriteAT (X, Y2, Attr, ScrollTOT^.vDownArrowChar);
  BC := ScrollTOT^.vBackgroundChar;
  For I := Succ (Y1) To Pred (Y2) Do
    WriteAT (X, I, Attr, BC);
  If (Current > 0) And (Max >= Current) Then
  Begin
    LineLength := Y2 - Succ (Y1);
    If LineLength > 0 Then
    Begin
      Y := (Current * LineLength) Div Max;
      If Current >= Max Then
        Y := Pred (LineLength);
      If (Y < 0) Or (Current = 1) Then
        Y := 0;
      WriteAT (X, Succ (Y1) + Y, Attr, ScrollTOT^.vElevatorChar);
    End;
  End;
End; {ScreenOBJ.WriteVScrollBar}

Destructor ScreenOBJ.Done;
{}
Var MemoryUsed: LongInt;
Begin
  If Not OnScreen Then
  Begin
    MemoryUsed := Width * Depth * 2;
    FreeMem (vScreenPtr, MemoryUsed);
  End;
  If oWritePtr <> Nil Then Begin {trixfix}
    Dispose (oWritePtr, Done);
    oWritePtr := Nil;
  End;
  Inherited Done; {trixfix}
End;  {ScreenOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     S c r o l l O B J   M E T H O D S     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
Constructor ScrollOBJ.Init;
{}
Begin
  Inherited Init; {trixfix}
  SetDefaults;
End; {ScrollOBJ.Init}

Procedure ScrollOBJ.SetDefaults;
{}
Begin
  SetScrollChars ('', '', Char (27), Char (26), '', '°');
End;  {of ScrollOBJ.SetDefaults}

Procedure ScrollOBJ.SetScrollChars (U, D, L, R, E, B: Char);
{}

Begin
  vUpArrowChar := U;
  vDownArrowChar := D;
  vLeftArrowChar := L;
  vRightArrowChar := R;
  vElevatorChar := E;
  vBackgroundChar := B;
End;  {of ScrollOBJ.SetScrollChars}

(*Function ScrollOBJ.UpChar: Char;
{}
Begin
  UpChar := vUpArrowChar;
End; {ScrollOBJ.UpChar}

Function ScrollOBJ.DownChar: Char;
{}
Begin
  DownChar := vDownArrowChar;
End; {ScrollOBJ.DownChar}

Function ScrollOBJ.LeftChar: Char;
{}
Begin
  LeftChar := vLeftArrowChar;
End; {ScrollOBJ.LeftChar}

Function ScrollOBJ.RightChar: Char;
{}
Begin
  RightChar := vRightArrowChar;
End; {ScrollOBJ.RightChar}

Function ScrollOBJ.ElevatorChar: Char;
{}
Begin
  ElevatorChar := vElevatorChar;
End; {ScrollOBJ.ElevatorChar}

Function ScrollOBJ.BackgroundChar: Char;
{}
Begin
  BackgroundChar := vBackgroundChar;
End; {ScrollOBJ.BackgroundChar}*)

Destructor ScrollOBJ.Done;
Begin
  Inherited Done; {trixfix}
End;
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     S h a d o w O B J   M E T H O D S     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
Constructor ShadowOBJ.Init;
{}
Begin
  Inherited Init; {trixfix}
  SetDefaults;
End; {ShadowOBJ.Init}

Procedure ShadowOBJ.SetDefaults;
{}
Begin
  vShadWidth := 2;
  vShadDepth := 1;
  vShadPos := DownRight;
  vShadAttr := 7;
  vShadChar := ' ';
End; {ShadowOBJ.SetDefaults}

Procedure ShadowOBJ.DrawShadow (Border: tCoords);
{}
Var
  Outer: tCoords;
  
Procedure DrawPartofShadow (X1, Y1, X2, Y2: Byte);
  Begin
    If (X1 > X2) Or (Y1 > Y2) Then Exit;
    If vShadChar = ' ' Then {attribute change}
      {Screen.Attrib(X1,Y1,X2,Y2,vShadAttr)}
      Screen.TrixShadowAttrib (X1, Y1, X2, Y2, vShadAttr)
    Else
      Screen.PartClear (X1, Y1, X2, Y2, vShadAttr, vShadChar);
  End; {of sub proc DrawPartofShadow}

Begin
  OuterCoords (Border, Outer);
  Case vShadPos Of
    UpLeft:
           Begin
             DrawPartofShadow (Outer.X1, Outer.Y1, Pred (Border.X1), Border.Y2 - vShadDepth);
             DrawPartofShadow (Border.X1, Outer.Y1, Border.X2 - vShadWidth, Pred (Border.Y1) );
           End;
    UpRight:
            Begin
              DrawPartofShadow (Border.X1 + vShadWidth, Outer.Y1, Outer.X2, Pred (Border.Y1) );
              DrawPartofShadow (Succ (Border.X2), Border.Y1, Outer.X2, Border.Y2 - vShadDepth);
            End;
    DownLeft:
             Begin
               DrawPartofShadow (Outer.X1, Border.Y1 + vShadDepth, Pred (Border.X1), Outer.Y2);
               DrawPartofShadow (Border.X1, Succ (Border.Y2), Border.X2 - vShadWidth, Outer.Y2);
             End;
    DownRight:
              Begin
                DrawPartofShadow (Border.X1 + vShadWidth, Succ (Border.Y2), Outer.X2, Outer.Y2);
                DrawPartofShadow (Succ (Border.X2), Border.Y1 + vShadDepth, Outer.X2, Border.Y2);
              End;
  End; {case}
End; {ShadowOBJ.DrawShadow}

Procedure ShadowOBJ.DrawShadowXY (X1, Y1, X2, Y2: Integer);
{}
Var
  Border: tCoords;
Begin
  Border.X1 := X1;
  Border.Y1 := Y1;
  Border.X2 := X2;
  Border.Y2 := Y2;
  DrawShadow (Border);
End; {ShadowOBJ.DrawShadowXY}

Procedure ShadowOBJ.SetShadowStyle (ShadP: ShadowPosition; ShadA: Byte; ShadC: Char);
{}
Begin
  vShadPos :=  ShadP;
  vShadAttr :=  ShadA;
  vShadChar :=  ShadC;
End; {ShadowOBJ.SetShadowStyle}

Procedure ShadowOBJ.SetShadowSize (ShadW, ShadD: Byte);
{}
Begin
  vShadWidth := ShadW;
  vShadDepth := ShadD;
End; {ShadowOBJ.SetShadowSize}

(*Function ShadowOBJ.ShadWidth: Byte;
{}
Begin
  ShadWidth := vShadWidth;
End; {ShadowOBJ.ShadWidth}

Function ShadowOBJ.ShadDepth: Byte;
{}
Begin
  ShadDepth := vShadDepth;
End; {ShadowOBJ.ShadDepth}

Function ShadowOBJ.ShadAttr: Byte;
{}
Begin
  ShadAttr := vShadAttr;
End; {ShadowOBJ.ShadAttr}

Function ShadowOBJ.ShadChar: Char;
{}
Begin
  ShadChar := vShadChar;
End; {ShadowOBJ.ShadChar}

Function ShadowOBJ.ShadPos: ShadowPosition;
{}
Begin
  ShadPos := vShadPos;
End; {ShadowOBJ.ShadPos}*)

(*
Procedure ShadowOBJ.OuterCoords (Border: tCoords; Var Outer: tCoords);
{}
Begin
  Case vShadPos Of
    UpLeft:
           Begin
             Outer.X1 := Border.X1 - vShadWidth;
             Outer.Y1 := Border.Y1 - vShadDepth;
             Outer.X2 := Border.X2;
             Outer.Y2 := Border.Y2;
           End;
    UpRight:
            Begin
              Outer.X1 := Border.X1;
              Outer.Y1 := Border.Y1 - vShadDepth;
              Outer.X2 := Border.X2 + vShadWidth;
              Outer.Y2 := Border.Y2;
            End;
    DownLeft:
             Begin
               Outer.X1 := Border.X1 - vShadWidth;
               Outer.Y1 := Border.Y1;
               Outer.X2 := Border.X2;
               Outer.Y2 := Border.Y2 + vShadDepth;
             End;
    DownRight:
              Begin
                Outer.X1 := Border.X1;
                Outer.Y1 := Border.Y1;
                Outer.X2 := Border.X2 + vShadWidth;
                Outer.Y2 := Border.Y2 + vShadDepth;
              End;
  End; {case}
  If Outer.X1 < 1 Then Outer.X1 := 1;
  If Outer.Y1 < 1 Then Outer.Y1 := 1;
  If Outer.X2 > Screen.Width Then Outer.X2 := Screen.Width;
  If Outer.Y2 > Screen.Depth Then Outer.Y2 := Screen.Depth;
End; {ShadowOBJ.OuterCoords}
*)

Procedure ShadowOBJ.OuterCoords (Border: tCoords; Var Outer: tCoords);
{}
Begin
  with Outer do begin
    Case vShadPos Of
      UpLeft:Begin
        X1 := Border.X1 - vShadWidth;
        Y1 := Border.Y1 - vShadDepth;
        X2 := Border.X2;
        Y2 := Border.Y2;
      End;
      UpRight:Begin
        X1 := Border.X1;
        Y1 := Border.Y1 - vShadDepth;
        X2 := Border.X2 + vShadWidth;
        Y2 := Border.Y2;
      End;
      DownLeft:Begin
        X1 := Border.X1 - vShadWidth;
        Y1 := Border.Y1;
        X2 := Border.X2;
        Y2 := Border.Y2 + vShadDepth;
      End;
      DownRight:Begin
        X1 := Border.X1;
        Y1 := Border.Y1;
        X2 := Border.X2 + vShadWidth;
        Y2 := Border.Y2 + vShadDepth;
      End;
    End; {case}
    If X1 < 1 Then X1 := 1;
    If Y1 < 1 Then Y1 := 1;
    If X2 > Screen.Width Then X2 := Screen.Width;
    If Y2 > Screen.Depth Then Y2 := Screen.Depth;
  end;
End; {ShadowOBJ.OuterCoords}

Procedure ShadowOBJ.OuterXY (Var X1, Y1, X2, Y2: Integer);
{}
Var Temp1, Temp2: tCoords;
Begin
  Temp1.X1 := X1;
  Temp1.Y1 := Y1;
  Temp1.X2 := X2;
  Temp1.Y2 := Y2;
  OuterCoords (Temp1, Temp2);
  X1 := Temp2.X1;
  Y1 := Temp2.Y1;
  X2 := Temp2.X2;
  Y2 := Temp2.Y2;
End; {ShadowOBJ.OuterXY}

Destructor ShadowOBJ.Done;
Begin
  Inherited Done; {trixfix}
End;

{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}

Procedure FastInit;
{initilizes objects and global variables}
Begin
  If Monitor = Nil Then Halt (1); {totsys:monitor is a dependency}
  Screen.Init;
  Screen.Create (0, 0, 0);
  New (ScrollTOT, Init);
  New (ShadowTOT, Init);
  SnowProne := Byte (Monitor^.SnowProne); {trixfix}
End; {FastInit}

Procedure FastDone;
{de-initilizes objects and global variables in case the screenmode changes}
Begin
  Dispose (ShadowTOT, done);
  Dispose (ScrollTOT, done);
  Screen.done;
End; {FastInit}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
Begin
  {$IFDEF INITTRACE} WriteLn ('fastinit'); {$ENDIF}
  FastInit;
  {$ENDIF}
End.

