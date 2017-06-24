{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

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
             Feb 26 17  trixfix Extensive fixups and enhancements (req. TP 7.0)
}

INTERFACE

uses objects, DOS, CRT, totSYS, totLOOK, totINPUT; {trixfix}

TYPE

StrScreen = string[255];   {alter as necessary}
StrVisible = string[80];   {alter as necessary}
tDirection = (Up, Down, Left, Right, Vert, Horiz);
tCoords = record
   X1,Y1,X2,Y2:shortint;
end;
tByteCoords = record
   X1,Y1,X2,Y2:byte;
end;
ShadowPosition = (UpLeft,UpRight,DownLeft,DownRight);

WritePtr = ^WriteOBJ;
pWriteOBJ = ^WriteOBJ;
WriteOBJ = object(TObject)
   vWidth: byte;           {how wide is screen}
   vScreenPtr: pointer;    {memory location of screen data}
   vWindow: tByteCoords;   {active screen area}
   vWindowOn: boolean;     {is window area active}
   vWindowIgnore: boolean; {ignore window settings}
   vTempX: byte;
   vTempY: byte;
   {methods...}
   constructor Init;
   procedure   SetScreen(var P:Pointer; W:byte);
   function    WindowOff: boolean;
   procedure   SetWinIgnore(On:Boolean);
   procedure   WindowOn;
   procedure   WindowCoords(var Coords: tByteCoords);
   function    WindowActive: boolean;
   function    WindowInEffect: boolean;
   function    WinX: byte;
   function    WinY: byte;
   procedure   GetWinCoords(var X1,Y1,X2,Y2:byte);
   procedure   GetCursorPos;
   procedure   SetCursorPos;
   procedure   WriteAT(X,Y,attr:byte;Str:string);                     VIRTUAL;
   procedure   WritePlain(X,Y:byte;Str:string);                       VIRTUAL;
   procedure   Write(Str:string);                                     VIRTUAL;
   procedure   WriteLn(Str:string);                                   VIRTUAL;
   procedure   GotoXY(X,Y: word);                                     VIRTUAL;
   function    WhereX: word;                                          VIRTUAL;
   function    WhereY: word;                                          VIRTUAL;
   procedure   SetWindow(X1,Y1,X2,Y2: byte);                          VIRTUAL;
   procedure   ResetWindow;                                           VIRTUAL;
   procedure   ChangeAttr(X,Y,Att:byte;Len:word);                     VIRTUAL;
   procedure   MoveFromScreen(var Source,Dest;Len:Word);              VIRTUAL;
   procedure   MoveToScreen(var Source,Dest; Len:Word);               VIRTUAL;
   procedure   Clear(Att:byte;Ch:char);                               VIRTUAL;
   destructor  Done;                                                  VIRTUAL;
end; {WriteOBJ}

ScreenPtr = ^ScreenOBJ;
pScreenOBJ = ^ScreenOBJ;
ScreenOBJ = object(TObject)
   vWidth: byte;           {how wide is screen}
   vDepth: byte;           {how many lines}
   vScreenPtr: pointer;    {memory location of screen data}
   vCursX: byte;           {cursor location}
   vCursY: byte;           {      -"-      }
   vCursTop: byte;         {cursor size}
   vCursBot: byte;         {    -"-    }
   oWritePtr: WritePtr;    {screen writing and moving object}
   vHiMarker: char;        {character to indicate attribute change}
   vVisible: boolean;      {is the screen mapped to visible display}
   vOnScreen:boolean;
   {methods...}
   constructor Init;
   procedure   SetHiMarker(M:char);
   function    HiMarker:char;
   procedure   AssignWriteOBJ(var Wri: WriteOBJ);
   procedure   SetWindow(X1,Y1,X2,Y2: byte);
   procedure   SetWinIgnore(On:Boolean);
   procedure   ResetWindow;
   function    WindowOff:boolean;
   procedure   WindowOn;
   procedure   WindowCoords(var Coords: tByteCoords);
   function    WindowActive: boolean;
   function    OnScreen:boolean;
   function    CharHeight: integer;
   procedure   CursReset;
   procedure   CursSave; 
   procedure   GotoXY(X,Y: word); 
   procedure   CursSize(T,B: byte);
   function    WhereX: word; 
   function    WhereY: word;
   function    CursTop: byte; 
   function    CursBot: byte;
   procedure   CursHalf;
   procedure   CursFull;
   procedure   CursOn;
   procedure   CursOff;
   procedure   Exists; 
   procedure   MoveToScreen(var Source, Dest; Length:word); 
   procedure   MoveFromScreen(var Source, Dest; Length:word);
   procedure   Save;
   procedure   Create(X,Y,Attr:byte);
   function    Width: byte;
   function    Depth: byte;
   function    ScreenPtr: pointer; 
   procedure   Display;
   procedure   PartDisplay(X1,Y1,X2,Y2,X,Y:byte);
   procedure   PartSlideDisplay(X1,Y1,X2,Y2:byte;Way:tDirection);
   procedure   SlideDisplay(Way: tDirection);
   procedure   PartSave (X1,Y1,X2,Y2:byte; VAR Dest);
   procedure   PartRestore (X1,Y1,X2,Y2:byte; VAR Source);
   procedure   CopyScreenBlock(X1,Y1,X2,Y2,X,Y:byte);
   procedure   MoveScreenBlock(X1,Y1,X2,Y2,X,Y:byte);
   procedure   Scroll(Way:tDirection;X1,Y1,X2,Y2:byte);
   procedure   Write(Str:string);
   procedure   WriteLn(Str:string);
   procedure   WriteAT(X,Y,attr:byte;Str:string);
   procedure   WriteHi(X,Y,AttrHi,Attr:byte;Str:string);
   procedure   WritePlain(X,Y:byte;Str:string); 
   procedure   WriteCap(X,Y,AttrCap,Attr:byte;Str:string);
   procedure   WriteClick(X,Y,attr:byte;Str:string);
   procedure   WriteCenter(Y,Attr:byte;Str:string);
   procedure   WriteBetween(X1,X2,Y,Attr:byte;Str:string);
   procedure   WriteRight(X,Y,Attr:byte;Str:string);
   procedure   WriteVert(X,Y,Attr:byte;Str:string);
   procedure   Attrib(X1,Y1,X2,Y2,Attr:byte);
   procedure   TrixShadowAttrib(X1,Y1,X2,Y2,Attr:byte);
   procedure   Clear(Att:byte;Ch:char);
   procedure   PartClear(X1,Y1,X2,Y2,Att:byte;Ch:char);
   procedure   ClearText(X1,Y1,X2,Y2:byte);
   procedure   ReadWord(X,Y:byte;var Attr:byte; var Ch : char);
   function    ReadChar(X,Y:byte):char;
   function    ReadAttr(X,Y:byte):byte;
   function    ReadStr(X1,X2,Y:byte):string;
   procedure   BoxEngine(X1,Y1,X2,Y2,LeftPad,RightPad,Battr,Tattr,Mattr,style:byte;
                         Filled:boolean;
                         Title:string); 
   procedure   TitleEngine(X1,Y1,X2,Y2,LeftPad,RightPad,Battr,Tattr:byte;Str,Title:string);
   procedure   Box(X1,Y1,X2,Y2,attr,style:byte);
   procedure   FillBox(X1,Y1,X2,Y2,attr,style:byte);
   procedure   ShadFillBox(X1,Y1,X2,Y2,attr,style:byte);
   procedure   TitledBox(X1,Y1,X2,Y2,Battr,Tattr,Mattr,style:byte;Title:string);
   procedure   HorizLine(X1,X2,Y,Attr,Style : byte);
   procedure   VertLine(X,Y1,Y2,Attr,Style:byte);
   procedure   SmartVertLine(X,Y1,Y2,Attr,Style:byte);
   procedure   SmartHorizLine(X1,X2,Y,Attr,Style:byte);
   procedure   WriteHScrollBar(X1,X2,Y,Attr: byte; Current,Max: longint);
   procedure   WriteVScrollBar(X,Y1,Y2,Attr: byte; Current,Max: longint);
   destructor  Done; VIRTUAL;
end; {ScreenOBJ}

pScrollOBJ = ^ScrollOBJ;
ScrollOBJ = object(TObject)
   vUpArrowChar: char;
   vDownArrowChar: char;
   vLeftArrowChar: char;
   vRightArrowChar: char;
   vElevatorChar: char;
   vBackgroundChar: char;
   {methods...}
   constructor Init;
   procedure   SetDefaults;
   procedure   SetScrollChars(U,D,L,R,E,B:char);
   function    UpChar: char;
   function    DownChar: char;
   function    LeftChar: char;
   function    RightChar: char;
   function    ElevatorChar: char;
   function    BackgroundChar: char;
   destructor  Done; VIRTUAL;
end; {ScrollOBJ}

pShadowOBJ = ^ShadowOBJ;
ShadowOBJ = object(TObject)
   vShadPos: ShadowPosition;   {where is shadow}
   vShadAttr: byte;            {shadow attribute}
   vShadChar: char;            {shadow character - ' ' is see-through}
   vShadWidth: byte;           {shadow width in characters}
   vShadDepth: byte;           {shadow depth in characters}
   {methods...}
   constructor Init;
   procedure   SetDefaults;
   procedure   SetShadowStyle(ShadP:ShadowPosition; ShadA:byte; ShadC: char);
   procedure   SetShadowSize(ShadW,ShadD:byte);
   function    ShadWidth: byte;
   function    ShadDepth: byte;
   function    ShadAttr: byte;
   function    ShadChar: char;
   function    ShadPos: ShadowPosition;
   procedure   DrawShadow(Border:tCoords);
   procedure   DrawShadowXY(X1,Y1,X2,Y2:integer);
   procedure   OuterCoords(Border:tCoords;var Outer:tCoords);
   procedure   OuterXY(var X1,Y1,X2,Y2: integer);
   destructor  Done; VIRTUAL;
end; {ShadowOBJ}

VAR
  Screen: ScreenOBJ;
  ScrollTOT: ^ScrollOBJ;
  ShadowTOT: ^ShadowOBJ;
  SnowProne : byte;

function  CAttr(F,B:byte):byte;
function  FAttr(A:byte): byte;
function  BAttr(A:byte): byte;
function  Replicate(N : byte; Character:char): string;
procedure fastINIT;
procedure fastDONE; {trixfix}

IMPLEMENTATION
Const
    TitPos:string[6] = '<+>^|_';  {characters signifying box title position}
    WinCursX: byte = 1;
    WinCursY: byte = 1;
{|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                               }
{     U N I T   P R O C E D U R E S   &   F U N C T I O N S     }
{                                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||}

procedure Error(Err:byte);
{temp routine to display error - replace with object}
const
   Header = 'totFAST error: ';
var
   Msg : string;
begin
   Case Err of
   1: Msg := 'Not enough memory to initialize screen';
   2: Msg := 'Cannot write to inactive screen';
   3: Msg := 'Not enough memory for screen move/copy';
   else  Msg := 'Unknown Error';
   end; {case}
   Writeln(Header,Msg);
   halt;
end; {Error}

function CAttr(F,B:byte):byte;
{converts foreground(F) and background(B) colors to combined Attribute byte}
begin
   CAttr := (B Shl 4) or F;
end;  {CAttr}

function FAttr(A:byte): byte;
{returns the foreground color from an attribute Byte}
begin
   FAttr := A and 15;
end; {FAttr}

function BAttr(A:byte): byte;
{returns the background color from an attribute Byte}
begin
   BAttr := (A and $70) shr 4;
end; {FAttr}

function Replicate(N : byte; Character:char): string;
{returns a string with Character repeated N times}
var tempstr: string;
begin
    If N = 0 then
       TempStr := ''
    else
    begin
       Fillchar(tempstr,N+1,Character);
       Tempstr[0] := chr(N);
    end;
    Replicate := Tempstr;
end; {replicate}

{$L totFAST}
{$F+}
  procedure AsmWrite(var scrptr; Wid,Col,Row,Attr:byte; St:String); external;
  procedure AsmPWrite(var scrptr; Wid,Col,Row:byte; St:String); external;
  procedure AsmAttr(var scrptr; Wid,Col,Row,Attr,Len:byte); external;
  Procedure AsmMoveFromScreen(var Source,Dest;Length:Word); external;
  Procedure AsmMoveToScreen(var Source,Dest; Length:Word); external;
{$IFNDEF OVERLAY}
   {$F-}
{$ENDIF}

{|||||||||||||||||||||||||||||||||||||||||}
{                                         }
{     W r i t e O B J   M E T H O D S     }
{                                         }
{|||||||||||||||||||||||||||||||||||||||||}
constructor WriteOBJ.Init;
{}
begin
   Inherited Init; {trixfix}
   vWindowOn := false;
   vWindowIgnore := false;
end; {WriteOBJ.Init}

procedure WriteOBJ.SetScreen(var P:Pointer; W:byte);
{}
begin
   vScreenPtr := P;
   vWidth := W;
end; {WriteOBJ.SetScreen}

procedure WriteOBJ.SetWindow(X1,Y1,X2,Y2: byte);
{}
begin
   if Monitor^.BaseofScreen = vScreenPtr then  {1.00d}
   begin
      GetCursorPos;   {1.00g}
      CRT.Window(X1,Y1,X2,Y2);
      SetCursorPos;
   end;
   vWindow.X1 :=  X1;
   vWindow.Y1 :=  Y1;
   vWindow.X2 :=  X2;
   vWindow.Y2 :=  Y2;
   vWindowOn := true;
end; {WriteOBJ.SetWindow}

procedure WriteOBJ.GetWinCoords(var X1,Y1,X2,Y2:byte);
{}
begin
   X1 :=  vWindow.X1;
   Y1 :=  vWindow.Y1;
   X2 :=  vWindow.X2;
   Y2 :=  vWindow.Y2;
end; {WriteOBJ.GetWinCoords}

procedure WriteOBJ.ResetWindow;
{}
var H,W: byte;
begin
   W := Monitor^.Width;
   H := Monitor^.Depth;
   if Monitor^.BaseofScreen = vScreenPtr then  {1.00d}
   begin {trixfix}
      getcursorpos;
      CRT.Window(1,1,W,H);
      setcursorpos;
   end;
   vWindow.X1 := 1;
   vWindow.Y1 := 1;
   vWindow.X2 := W;
   vWindow.Y2 := H;
   vWindowOn := false;
end; {WriteOBJ.ResetWindow}

function WriteOBJ.WindowOff:boolean;
{}
begin
   if vWindowOn then
   begin
      vWindowOn := false;
      WinCursX := WhereX;
      WinCursY := WhereY;
      if Monitor^.BaseofScreen = vScreenPtr then  {1.00d}
      begin
         GetCursorPos;  {1.00g}
         CRT.window(1,1,Monitor^.Width,Monitor^.Depth);
         SetCursorPos;  {1.00g}
      end;
      WindowOff := true;
   end
   else
      WindowOff := false;
end; {WriteOBJ.WindowOff}

procedure WriteOBJ.WindowOn;
{}
begin
   vWindowOn := true;
   window(vWindow.X1,vWindow.Y1,vWindow.X2,vWindow.Y2);
   GotoXY(WinCursX,WinCursY);
end; {WriteOBJ.WindowOn}

procedure WriteOBJ.WindowCoords(var Coords: tByteCoords);
{}
begin
   Coords := vWindow;
end; {WriteOBJ.WindowCoords}

function WriteOBJ.WindowActive: boolean;
{}
begin
   WindowActive := vWindowOn;
end; {WriteOBJ.WindowActive}

function WriteOBJ.WindowInEffect: boolean;
{}
begin
   WindowInEffect := vWindowOn and not vWindowIgnore;
end; {WriteOBJ.WindowActive}

procedure WriteOBJ.SetWinIgnore(On:Boolean);
{}
begin
   vWindowIgnore := On;
end; {WriteOBJ.SetWinIgnore}

function WriteOBJ.WinX: byte;
{}
begin
   if vWindowOn and not vWindowIgnore then
      WinX := vWindow.X1
   else
      WinX := 1;
end; {WriteOBJ.WinX}

function WriteOBJ.WinY: byte;
{}
begin
   if vWindowOn and not vWindowIgnore then
      WinY := vWindow.Y1
   else
      WinY := 1;
end; {WriteOBJ.WinY}

procedure WriteOBJ.WriteAT(X,Y,attr:byte;Str:string);
{}
begin
   if not vWindowOn or vWindowIgnore then
      ASMWrite(vScreenPtr^,vWidth,X,Y,attr,Str)
   else
   begin
      Str := copy(Str,1,vWindow.X2 - pred(X) - pred(vWindow.X1));
      if Y + pred(vWindow.Y1) <= vWindow.Y2 then
         ASMWrite(vScreenPtr^,vWidth,pred(vWindow.X1)+X,
                                        pred(vWindow.Y1)+Y,
                                        attr,Str);
   end;
end; {WriteOBJ.WriteAT}

procedure WriteOBJ.WritePlain(X,Y:byte;Str:string);
{}
begin
   if not vWindowOn or vWindowIgnore then
      ASMPWrite(vScreenPtr^,vWidth,X,Y,Str)
   else
   begin
      Str := copy(Str,1,vWindow.X2 - pred(X) - pred(vWindow.X1));
      if Y + pred(vWindow.Y1) <= vWindow.Y2 then
         ASMPWrite(vScreenPtr^,vWidth,pred(vWindow.X1)+X,
                                        pred(vWindow.Y1)+Y,
                                        Str);
   end;
end; {WriteOBJ.WritePlain}

procedure WriteOBJ.Write(Str:string);
{}
begin
   if Monitor^.BaseofScreen = vScreenPtr then
      System.Write(Str)
   else
   begin

   end;
end; {WriteOBJ.Write}

procedure WriteOBJ.WriteLn(Str:string);
{}
begin
   System.WriteLn(Str);
end; {WriteOBJ.WriteLn}

procedure WriteOBJ.GetCursorPos;
{}
var Regs: Registers;
begin
   with Regs do
   begin
      AH := 3;
      BH := 0;
   end;
   Intr($10,Regs);
   vTempY := Regs.DH;
   vTempX := Regs.DL;
end; {WriteOBJ.GetCursorPos}

procedure WriteOBJ.SetCursorPos;
{}
var
  Regs: Registers;
begin
   with Regs do
   begin
      AH := 2;
      BH := 0;
      DH := vTempY;
      DL := vTempX;
   end;
   Intr($10,Regs);
end; {WriteOBJ.SetCursorPos}

procedure WriteOBJ.GotoXY(X,Y: word);
{}
var Regs: Registers;
begin
   if vWindowOn and vWindowIgnore then
   begin
      with Regs do
      begin
         AH := 2;
         DH := pred(Y);
         DL := pred(X);
         BH := 0;
      end;
      Intr($10,Regs);
   end
   else
      CRT.GotoXY(X,Y);
end; {WriteOBJ.GotoXY}

function  WriteOBJ.WhereX: word;
{}
begin
   WhereX := CRT.WhereX;
end; {WriteOBJ.WhereX}

function  WriteOBJ.WhereY: word;
{}
begin
   WhereY := CRT.WhereY;
end; {WriteOBJ.WhereY}

procedure WriteOBJ.ChangeAttr(X,Y,Att:byte;Len:word);
{}
begin
   if not vWindowOn or vWindowIgnore then
      ASMAttr(vScreenPtr^,vWidth,X,Y,Att,Len)
   else
   begin
      inc(X,pred(vWindow.X1));
      inc(Y,pred(vWindow.Y1));
      if (X <= vWindow.X2) and (Y <= vWindow.Y2) then
      begin
         if X + Len > vWindow.X2 then
            Len := vWindow.X2 - pred(X);
         ASMAttr(vScreenPtr^,vWidth,X,Y,Att,Len)
      end;
   end;
end; {WriteOBJ.ChangeAttr}

procedure WriteOBJ.MoveFromScreen(var Source,Dest;Len:Word);
{}
begin
   ASMMoveFromScreen(Source,Dest,Len);
end; {WriteOBJ.MoveFromScreen}

procedure WriteOBJ.MoveToScreen(var Source,Dest; Len:Word);
{}
begin
   ASMMoveToScreen(Source,Dest,Len);
end; {WriteOBJ.MoveToScreen}

procedure WriteOBJ.Clear(Att:byte;Ch:char);                              
{}
var
   I : integer;
   S : string;
begin
   with vWindow do
   begin
       S := Replicate(Succ(X2-X1),Ch);
       for I := 1 to succ(Y2-Y1) do
       begin
          ChangeAttr(X1,Y1,Att,succ(X2-X1));
          WritePlain(1,I,S);
       end;
   end;
end; {WriteOBJ.Clear}

destructor WriteOBJ.Done;
{}
begin
   Inherited Done; {trixfix}
end; {WriteOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     S c r e e n O B J   M E T H O D S     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
constructor ScreenOBJ.Init;
{}
begin
   Inherited Init; {trixfix}
   vScreenPtr := nil;
   vHiMarker := '~';
   vVisible := false;
   vOnScreen := false;
   New(oWritePtr,Init);
   oWritePtr^.SetScreen(vScreenPtr,vWidth);
   ResetWindow;
end; {ScreenOBJ.Init}

procedure ScreenOBJ.SetHiMarker(M:char);
{}
begin
   vHiMarker := M;
end; {ScreenOBJ.SetHiMarker}

function ScreenOBJ.HiMarker:char;
{}
begin
   Himarker := vHiMarker;
end; {ScreenOBJ.Himarker}

procedure ScreenOBJ.AssignWriteOBJ(var Wri: WriteOBJ);
{}
begin
   Dispose(oWritePtr,Done);
   oWritePtr := @Wri;
   oWritePtr^.SetScreen(vScreenPtr,vWidth);
end; {ScreenOBJ.AssignWriteOBJ}

procedure ScreenOBJ.SetWindow(X1,Y1,X2,Y2: byte);
{}
begin
   oWritePtr^.SetWindow(X1,Y1,X2,Y2);
end; {ScreenOBJ.SetWindow}

procedure ScreenOBJ.SetWinIgnore(On:Boolean);
{}
begin
   oWritePtr^.SetWinIgnore(On);
end; {ScreenOBJ.SetWinIgnore}

procedure ScreenOBJ.ResetWindow;
{}
begin
   oWritePtr^.ResetWindow;
end; {ScreenOBJ.ResetWindow}

function ScreenOBJ.WindowOff:boolean;
{}
begin
   WindowOff := oWritePtr^.WindowOff;
end; {ScreenOBJ.WindowOff}

procedure ScreenOBJ.WindowOn;
{}
begin
   oWritePtr^.WindowOn;
end; {ScreenOBJ.WindowOn}

procedure ScreenOBJ.WindowCoords(var Coords: tByteCoords);
{}
begin
   oWritePtr^.WindowCoords(Coords);
end; {ScreenOBJ.WindowCoords}

function ScreenOBJ.WindowActive: boolean;
{}
begin
   WindowActive := oWritePtr^.WindowActive;
end; {ScreenOBJ.WindowActive}
{|||||||||||||||||||||||||||||||||}
{     C U R S O R   S T U F F     }
{|||||||||||||||||||||||||||||||||}
function ScreenOBJ.OnScreen: boolean;
{is this instance the visible screen}
begin
   OnScreen := vOnScreen;
end; {ScreenOBJ.OnScreen}

function ScreenOBJ.CharHeight: integer;
{get height of text mode characters for cursor manipulation}
var
   Regs: Registers;
begin
   if OnScreen then
   begin
      case Monitor^.DisplayType of
      Mono: CharHeight := 14;
      EGACol,
      CGA : CharHeight := 8;
      else
         with Regs do
         begin
            Ah := $11;
            Al := $30;
            BX := $0;
            Intr($10,Regs);
            CharHeight := CX;
         end; {with}
      end;  {case}
   end
   else        {virtual screen assume normal mode}
   begin
      if Monitor^.DisplayType = Mono then
         CharHeight := 14
      else
         CharHeight := 8;
   end;
end; {ScreenOBJ.CharHeight}

procedure ScreenOBJ.CursReset;
{}
begin
   GotoXY(1,1);
   CursOn;
end; {ScreenOBJ.CursReset}

procedure ScreenOBJ.CursSave;
{updates instance with visible Cursor details}
var Reg : registers;
begin
   with Reg do
   begin
      Ax := $0F00; {get page in Bx}
      intr($10,reg);
      Ax := $0300;
      intr($10,reg);
      vCursX := lo(Dx) + 1;
      vCursY := hi(Dx) + 1;
      vCursTop := Hi(Cx) and $0F;
      vCursBot := Lo(Cx) and $0F;
   end;
end; {ScreenOBJ.CursSave}

procedure ScreenOBJ.CursSize(T,B : byte);
{}
var Reg: registers;
begin
   if OnScreen then {writing to a visible screen}
   begin
      with reg do
      begin
         AX := $0100;
         if (T=0) and (B=0) then
            CX := $2020         {Thanks Yaron!! 1.00e}
         else
         begin
         (*  
         If you have an odd video bios and cursor changes
         are strange, enable this next line.
            mem[$40:$87] := mem[$40:$87] or $01; {get cursor ownership from BIOS}
         *)
            Ch := T;
            Cl := B;
         end;
         intr($10,Reg);
      end;
   end;
   vCursTop := T;
   vCursBot := B;
end; {ScreenOBJ.CursSize}

function ScreenOBJ.WhereX: word;
{}
begin
   if OnScreen then {writing to a visible screen}
      WhereX := oWritePtr^.WhereX
   else
      WhereX := vCursX;
end; {ScreenOBJ.WhereX}

function ScreenOBJ.WhereY: word;
{}
begin
   if OnScreen then {writing to a visible screen}
      WhereY := oWritePtr^.WhereY
   else
      WhereY := vCursY;
end; {ScreenOBJ.WhereY}

procedure ScreenOBJ.GotoXY(X,Y:word);
{}
begin
   if OnScreen then {writing to a visible screen}
      oWritePtr^.GotoXY(X,Y)
   else
   begin
      vCursX := X;
      vCursY := Y;
   end;
end; {ScreenOBJ.CursGotoXY}

function ScreenOBJ.CursTop: byte;
{}
begin
   CursTop := vCursTop;
end; {ScreenOBJ.CursTOP}

function ScreenOBJ.CursBot: byte;
{}
begin
   CursBot := vCursBot;
end; {ScreenOBJ.CursBot}

procedure ScreenOBJ.CursHalf;
{}
var Charsize: byte;
begin
   CharSize := CharHeight;
   CursSize(CharSize div 2, pred(CharSize));
end; {ScreenOBJ.CursHalf}

procedure ScreenOBJ.CursFull;
{}
var Charsize: byte;
begin
   CharSize := CharHeight;
   CursSize(0,CharSize);
end; {ScreenOBJ.CursFull}

procedure ScreenOBJ.CursOn;
{}
var Charsize: byte;
begin
   CharSize := CharHeight;
   CursSize(CharSize-3, CharSize-2);
end; {ScreenOBJ.CursOn}

procedure ScreenOBJ.CursOff;
{}
begin
   CursSize(0,0);
end; {ScreenOBJ.CursOff}
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{     S C R E E N    S A V E    &    R E S T O R E     }
{||||||||||||||||||||||||||||||||||||||||||||||||||||||}
procedure ScreenOBJ.Exists;
{makes sure there is a screen on the heap}
begin
   if ScreenPtr = nil then
      Error(2);
end; {ScreenOBJ.Exists}

procedure ScreenOBJ.Create(X,Y,Attr:byte);
{}
var MemoryNeeded: longint;
begin
   MemoryNeeded := X*Y*2;
   If MaxAvail < MemoryNeeded then
      Error(1)
   else
   begin
      If (X = 0) and (Y = 0) then    {map to physical screen}
      begin
         vWidth := Monitor^.Width;
         (*
         vDepth := 50;              {set to max for extended line displays}
         *)
         vDepth := Monitor^.Depth;
         vVisible := true;
         vScreenPtr := Monitor^.BaseOfScreen; {1.00a}
         oWritePtr^.SetScreen(vScreenPtr,vWidth);
         vOnScreen := true;
         CursSave;
         ResetWindow;
      end
      else
      begin
         vWidth := X;
         vDepth := Y;
         GetMem(vScreenPtr,MemoryNeeded);
         oWritePtr^.SetScreen(vScreenPtr,vWidth);
         SetWindow(1,1,X,Y);
         Clear(Attr,' ');
         CursReset;
      end;
   end;
end; {ScreenOBJ.Create}

procedure ScreenOBJ.MoveFromScreen(var Source, Dest; Length:word);
{}
begin
   oWritePtr^.MoveFromScreen(Source,Dest,Length);
end; {ScreenOBJ.MoveFromScreen}

procedure ScreenOBJ.MoveToScreen(var Source, Dest; Length:word);
{}
begin
   oWritePtr^.MoveToScreen(Source,Dest,Length);
end; {ScreenOBJ.MoveToScreen}

procedure ScreenOBJ.Save;
{saves current screen to instance}
{trixfix - reformatted for better debugging}
var
  MemoryNeeded: longint;
  MVisible: boolean;
  WinCoords: tByteCoords;
begin
  If ScreenPtr <> nil
    then Freemem(vScreenPtr,Width*Depth*2);
  MemoryNeeded := Monitor^.Width*Monitor^.Depth*2;
  If MaxAvail < MemoryNeeded
    then Error(1)
    else begin
      vWidth := Monitor^.Width;
      vDepth := Monitor^.Depth;
      GetMem(vScreenPtr,MemoryNeeded);
      MVisible := Mouse.Visible;
      if MVisible
        then Mouse.Hide;
      MoveFromScreen(Monitor^.BaseOfScreen^,ScreenPtr^,vWidth*vDepth);
      CursSave;
      oWritePtr^.SetScreen(vScreenPtr,vWidth);
      Screen.WindowCoords(WinCoords);
      with WinCoords do
        SetWindow(X1,Y1,X2,Y2);
      if MVisible
        then Mouse.Show;
    end;
end; {ScreenOBJ.Save}

function ScreenOBJ.Width: byte;
{}
begin
   Width := vWidth;
end; {ScreenOBJ.Width}

function ScreenOBJ.Depth: byte;
{}
begin
   if vVisible then
   begin
      Depth := Monitor^.Depth
   end
   else
      Depth := vDepth;
end; {ScreenOBJ.Depth}

function ScreenOBJ.ScreenPtr: pointer;
{}
begin
   ScreenPtr := vScreenPtr;
end; {ScreenOBJ.ScrPtr}

procedure ScreenOBJ.Display;
{}
var 
  Wid,Dep:byte;
  MVisible:boolean;
  WinCoords: tByteCoords;
begin
{$IFNDEF FINAL}
   Exists;
{$ENDIF}
   MVisible := Mouse.Visible;
   if MVisible then
      Mouse.Hide;
   if Width = Monitor^.Width then  {one big move}
      MoveToScreen(ScreenPtr^,Monitor^.BaseOfScreen^, width*Monitor^.Depth)
   else
   begin
      Wid := Monitor^.Width;
      if Wid > vWidth then
         Wid := vWidth;
      Dep := Monitor^.Depth;
      if Dep > vDepth then
         Dep := vDepth;
      PartDisplay(1,1,Wid,Dep,1,1);
   end;
   {now restore cursor details}
   WindowCoords(WinCoords);
   with WinCoords do
      Screen.SetWindow(X1,Y1,X2,Y2);
   Screen.GotoXY(WhereX,WhereY);
   Screen.CursSize(CursTop,CursBot);
   if MVisible then           (* Change to restore Mouse Details *)
      Mouse.Show;
end; {ScreenOBJ.Display}

procedure ScreenOBJ.PartDisplay(X1,Y1,X2,Y2,X,Y:byte);
{}
var
   MonitorWidth,
   ScreenWidth,
   SectionWidth   : byte;
   I              : integer;
   VisibleAdr,
   VirtualAdr     : word;
   VisiblePtr,
   VirtualPtr     : pointer;
   MVisible:boolean;
begin
   if X2 > vWidth then
      X2 := vWidth;
   if Y2 > vDepth then
      Y2 := vDepth;
   SectionWidth := succ(X2- X1);
   MonitorWidth := Monitor^.Width;
   ScreenWidth  := Width;
   VirtualPtr := ScreenPtr;
   VisiblePtr := Monitor^.BaseOfScreen;
   MVisible := Mouse.Visible;
   if MVisible then
      Mouse.Hide;
   For I :=  Y1 to Y2 do
   begin
       VisibleAdr := pred(Y+I-Y1)*MonitorWidth*2 + pred(X)*2;
       VirtualAdr := pred(I)*ScreenWidth*2 + Pred(X1)*2;
       MoveToScreen(Mem[Seg(VirtualPtr^):ofs(VirtualPtr^)+VirtualAdr],
                    Mem[Seg(VisiblePtr^):ofs(VisiblePtr^)+VisibleAdr],
                    Sectionwidth);
   end;
   if MVisible then
      Mouse.Show;
end; {ScreenOBJ.PartDisplay}

procedure ScreenOBJ.PartSlideDisplay(X1,Y1,X2,Y2:byte;Way:tDirection);
{}
var
   I : integer;
begin
   Case Way of
   Up    : begin
              for I := Y2 downto Y1 do
              begin
                  PartDisplay(X1,Y1,X2,Y1+Y2-I,X1,I);
                  Delay(50);
              end;
           end;
   Down  : begin
              for I := Y1 to Y2 do
              begin
                  PartDisplay(X1,Y1+Y2 -I,X2,Y2,X1,Y1);
                  Delay(50);  {savor the moment!}
              end;
           end;
   Left  : begin
              for I := X1 to X2 do
              begin
                  PartDisplay(X1,Y1,I,Y2,X1+X2-I,Y1);
              end;
           end;
   Right : begin
              for I := X2 downto X1 do
              begin
                  PartDisplay(I,Y1,X2,Y2,X1,Y1);
              end;
           end;
   Vert:   for I := Y1 to Y1 + (Y2 - Y1) div 2 do
           begin
              PartDisplay(X1,I,X2,I,X1,I);
              PartDisplay(X1,Y2+Y1-I,X2,Y2+Y1-I,X1,Y2+Y1-I);
              Delay(50);
           end;
   Horiz:  for I := X1 to X1 + succ(X2 -X1) div 2 do
           begin
              PartDisplay(I,Y1,I,Y2,I,Y1);
              PartDisplay((X2)+X1-I,Y1,(X2)+X1-I,Y2,(X2)+X1-I,Y1);
              Delay(10);
           end;
   end; {case}
end; {ScreenOBJ.PartSlideDisplay}

procedure ScreenOBJ.SlideDisplay(Way: tDirection);
{}
var
  WinCoords: tByteCoords;
  X,Y,Top,Bot : byte;
begin
   X := Monitor^.Width;
   if X > vWidth then
      X := vWidth;
   Y := Monitor^.Depth;
   if Y > vDepth then
      Y := vDepth;
   PartSlideDisplay(1,1,X,Y,Way);
   {now restore cursor details}
   X := WhereX;
   Y := WhereY;
   Top := CursTop;
   Bot := CursBot;
   Screen.SetWindow(1,1,Monitor^.Width,Monitor^.Depth); {1.00g}
   Screen.GotoXY(X,Y);
   Screen.CursSize(Top,Bot);
   WindowCoords(WinCoords);
   with WinCoords do
      Screen.SetWindow(X1,Y1,X2,Y2);
end; {ScreenOBJ.SlideDisplay}

procedure ScreenOBJ.PartSave (X1,Y1,X2,Y2:byte; VAR Dest);
{transfers data from active virtual screen to Dest}
var
   I,wid : byte;
   ScreenAdr: integer;
   MVisible: boolean;
begin
   wid := succ(X2- X1);
   MVisible := Mouse.Visible;
   if MVisible then
      Mouse.Hide;
   For I :=  Y1 to Y2 do
   begin
     {ScreenAdr := Pred(I)*160 + Pred(X1)*2;}
     ScreenAdr := Pred(I)*(vwidth * 2) + Pred(X1)*2; {trixfix}
     MoveFromScreen(Mem[seg(vScreenPtr^):ofs(vScreenPtr^)+ScreenAdr],
                    Mem[seg(Dest):ofs(dest)+(I-Y1)*wid*2],
                    wid);
   end;
   if MVisible then
      Mouse.Show;
end; {ScreenOBJ.PartSave}

procedure ScreenOBJ.PartRestore (X1,Y1,X2,Y2:byte; VAR Source);
{restores data from Source and transfers to active virtual screen
 - used internally}
var
   I,wid : byte;
   ScreenAdr: integer;
   MVisible: boolean;
begin
   wid := succ(X2- X1);
   MVisible := Mouse.Visible;
   if MVisible then
      Mouse.Hide;
   For I :=  Y1 to Y2 do
   begin
     {ScreenAdr := Pred(I)*160 + Pred(X1)*2;}
     ScreenAdr := Pred(I)*(vwidth * 2) + Pred(X1)*2; {trixfix}
     MoveToScreen(Mem[Seg(Source):ofs(Source)+(I-Y1)*wid*2],
                 Mem[seg(vScreenPtr^):ofs(vScreenPtr^)+ScreenAdr],
                 wid);
   end;
   if MVisible then
     Mouse.Show;
end; {ScreenOBJ.PartRestore}

procedure ScreenOBJ.CopyScreenBlock(X1,Y1,X2,Y2,X,Y:byte);
{copies text and attributes from one part of screen to another}
Var
   S : word;
   SPtr : pointer;
   MVisible: boolean;
begin
    S := succ(Y2-Y1)*succ(X2-X1)*2;
    If Maxavail < S then
       Error(3)
    else
    begin
       MVisible := Mouse.Visible;
       if MVisible then
          Mouse.Hide;
       GetMem(SPtr,S);
       PartSave(X1,Y1,X2,Y2,SPtr^);
       PartRestore(X,Y,X+X2-X1,Y+Y2-Y1,SPtr^);
       FreeMem(Sptr,S);
       if MVisible then
          Mouse.Show;
    end;
end; {ScreenOBJ.CopyScreenBlock}

procedure ScreenOBJ.MoveScreenBlock(X1,Y1,X2,Y2,X,Y:byte);
{Moves text and attributes from one part of screen to another,
 replacing with Replace_Char}
const
  Replace_Char = ' ';
Var
   S : word;
   SPtr : pointer;
   I : Integer;
   ST : string;
   MVisible: boolean;
begin
    S := succ(Y2-Y1)*succ(X2-X1)*2;
    If Maxavail < S then
       Error(3)
    else
    begin
       MVisible := Mouse.Visible;
       if MVisible then
          Mouse.Hide; 
       GetMem(SPtr,S);
       PartSave(X1,Y1,X2,Y2,SPtr^);
       St := Replicate(succ(X2-X1),Replace_Char);
       For I := Y1 to Y2 do
           WritePlain(X1,I,St);
       PartRestore(X,Y,X+X2-X1,Y+Y2-Y1,SPtr^);
       FreeMem(Sptr,S);
       if MVisible then
          Mouse.Show;
    end;
end; {ScreenOBJ.MoveScreenBlock}

procedure ScreenOBJ.Scroll(Way:tDirection;X1,Y1,X2,Y2:byte);
{used for screen scrolling, uses Copy & Plainwrite for speed}
const
  Replace_Char = ' ';
var
  I : integer;
begin
    Case Way of
    Up   : begin
               CopyScreenBlock(X1,succ(Y1),X2,Y2,X1,Y1);
               WritePlain(X1,Y2,replicate(succ(X2-X1),Replace_Char));
           end;
    Down : begin
               CopyScreenBlock(X1,Y1,X2,pred(Y2),X1,succ(Y1));
               WritePlain(X1,Y1,replicate(succ(X2-X1),Replace_Char));
           end;
    Left : begin
               CopyScreenBlock(succ(X1),Y1,X2,Y2,X1,Y1);
               For I := Y1 to Y2 do
                   WritePlain(X2,I,Replace_Char);
           end;
    Right: begin
               CopyScreenBlock(X1,Y1,pred(X2),Y2,succ(X1),Y1);
               For I := Y1 to Y2 do
                   WritePlain(X1,I,Replace_Char);
           end;
    end; {case}
end; {ScreenOBJ.Scroll}
{||||||||||||||||||||||||||||||||||||}
{     S C R E E N    W R I T E S     }
{||||||||||||||||||||||||||||||||||||}
procedure ScreenOBJ.Write(Str:string);
{write at the cursor position using the default attributes, and
 moves cursor to end of string}
var 
   NewX: integer; {1.00c}
   X,Y:byte;
   MVisible: boolean;
begin
{$IFNDEF FINAL}
   Exists;
{$ENDIF}
   MVisible := Mouse.Visible and vOnScreen;  {1.00c}
   X := WhereX + pred(oWritePtr^.WinX);
   Y := WhereY + pred(oWritePtr^.WinY);
   if MVisible and Mouse.InZone(X,Y,X+length(Str),Y) then
   begin
      Mouse.Hide;
      oWritePtr^.Write(Str);
      Mouse.Show;
   end
   else if vOnScreen then {1.00c}
      oWritePtr^.Write(Str)
   else
   begin
      oWritePtr^.WritePlain(vCursX,vCursY,Str);
      NewX := vCursX + length(Str);
      vCursX := NewX mod vWidth;
      inc(vCursY,NewX div vWidth);
   end;
end; {ScreenOBJ.Write}

procedure ScreenOBJ.WriteLn(Str:string);
{write at the cursor position using the default attributes, and
 moves cursor to next line}
var
   X,Y:integer;
   MVisible: boolean;
begin
{$IFNDEF FINAL}
   Exists;
{$ENDIF}
   MVisible := Mouse.Visible and vOnScreen;  {1.00c}
   X := WhereX + pred(oWritePtr^.WinX);
   Y := WhereY + pred(oWritePtr^.WinY);
   if MVisible and Mouse.InZone(X,Y,X+length(Str),Y) then
   begin
      Mouse.Hide;
      oWritePtr^.WriteLn(Str);
      Mouse.Show;
   end
   else if vOnScreen then {1.00c}
      oWritePtr^.WriteLn(Str)
   else
   begin
      oWritePtr^.WritePlain(vCursX,vCursY,Str);
      vCursX := 1;
      inc(vCursY);
   end;
end; {ScreenOBJ.WriteLn}

procedure ScreenOBJ.WriteAT(X,Y,attr:byte;Str:string);
{}
var
   MVisible: boolean;
   GlobalX,GlobalY: byte;
begin
{$IFNDEF FINAL}                  
   Exists;                       
{$ENDIF}
   if Attr = 0 then
      WritePlain(X,Y,Str)
   else   
   begin
      MVisible := Mouse.Visible and vOnScreen;  {1.00c}
      GlobalX := X + pred(oWritePtr^.WinX);
      GlobalY := Y + pred(oWritePtr^.WinY);
      if MVisible and Mouse.InZone(GlobalX,GlobalY,GlobalX+length(Str),GlobalY) then
      begin
         Mouse.Hide;
         oWritePtr^.WriteAT(X,Y,attr,Str);
         Mouse.Show;
      end
      else
         oWritePtr^.WriteAT(X,Y,attr,Str);
   end;
end; {ScreenOBJ.WriteAT}

procedure ScreenOBJ.WriteHi(X,Y,AttrHi,Attr:byte;Str:string);
{}
var 
  P:byte;
  Hi : Boolean;

     procedure WriteBit(Str:string);
     begin
        if Hi then
           WriteAt(X,Y,AttrHi,Str)
        else
           WriteAt(X,Y,Attr,Str);
     end;

begin
   Hi := False;
   P := Pos(vHiMarker,Str);
   While P <> 0 do
   begin
       if P > 1 then
          WriteBit(copy(Str,1,pred(P)));
       Delete(Str,1,P);
       inc(X,pred(P));
       P := Pos(vHiMarker,Str);
       Hi := not Hi;
   end;
   WriteBit(Str);
end; {ScreenOBJ.WriteHi}

procedure ScreenOBJ.WritePlain(X,Y:byte;Str:string);
{}
var
   MVisible: boolean;
   GlobalX,GlobalY: byte;
begin
{$IFNDEF FINAL}
   Exists;
{$ENDIF}
   MVisible := Mouse.Visible and vOnScreen;  {1.00c}
   GlobalX := X + pred(oWritePtr^.WinX);
   GlobalY := Y + pred(oWritePtr^.WinY);
   if MVisible and Mouse.InZone(GlobalX,GlobalY,GlobalX+length(Str),GlobalY) then
   begin
      Mouse.Hide;
      oWritePtr^.WritePlain(X,Y,Str);
      Mouse.Show;
   end
   else
      oWritePtr^.WritePlain(X,Y,Str);
end; {ScreenOBJ.WritePlain}

procedure ScreenOBJ.WriteCap(X,Y,AttrCap,Attr:byte;Str:string);
{Writes a string with the first capital letter in a different color}
var
  CapPos : byte;
begin
   If Str <> '' then
   begin
      WriteAt(X,Y,Attr,Str);   {write whole string in default cols}
      CapPos := 1;
      While (CapPos <= length(Str))
      and   ((Str[CapPos] in [#65..#90]) = false) do
         inc(CapPos);
      If CapPos <= length(Str) then
         WriteAt(X + pred(CapPos),Y,AttrCap,Str[CapPos]);
   end;
end; {ScreenOBJ.WriteCap}

procedure ScreenOBJ.WriteClick(X,Y,attr:byte;Str:string);
{writes text to the screen with a click!}
var
  I : Integer;
  L : byte;
begin
   L := length(Str);
   If OnScreen then
      for I := L downto 1 do
      begin
         WriteAt(X,Y,Attr,copy(Str,I,succ(L-I)));
         sound(500);delay(20);nosound;delay(30);
      end
   else
      WriteAt(X,Y,attr,Str); {don't click if not visible}
end; {ScreenOBJ.WriteClick}

procedure ScreenOBJ.WriteCenter(Y,Attr:byte;Str:string);
{trixfix} {40-col needs truncation or it errors out}
var
  X1,Y1,X2,Y2:byte;
  X:integer;
begin
  if oWritePtr^.WindowInEffect then begin
    oWritePtr^.GetWinCoords(X1,Y1,X2,Y2);
    X := (succ(X2-X1) - length(Str)) div 2;
  end else begin
    if length(str)>=width then byte(str[0]):=width-1;
    X :=  (Width - length(Str)) div 2;
  end;
  inc(X);                      {1.00e/f}
  if X < 1
    then X := 1;
  WriteAt(X,Y,attr,Str);
end; {ScreenOBJ.WriteCenter}

procedure ScreenOBJ.WriteBetween(X1,X2,Y,Attr:byte;Str:string);
{}
var X : integer;
begin
   if length(Str) >= X2 - X1 + 1 then
      WriteAt(X1,Y,attr,Str)
   else
   begin
       X := X1 + (X2 - X1 + 1 - length(Str)) div 2 ;
       WriteAt(X,Y,attr,Str);
   end;
end; {ScreenOBJ.WriteBetween}

procedure ScreenOBJ.WriteRight(X,Y,Attr:byte;Str:string);
{writes a right-justified string to the screen}
var X1 : integer;
begin
   X1 := succ(X-length(Str));
   if X1 < 1 then
      X1 := 1;
   WriteAT(X1,Y,attr,Str);
end; {ScreenOBJ.WriteRight}

procedure ScreenOBJ.WriteVert(X,Y,Attr:byte;Str:string);
{}
var
   L: byte;
   I: integer;
begin
   L := length(Str);
   If L > succ(Monitor^.Depth) - Y then
      L := succ(Monitor^.Depth) - Y;
   for I := 1 to L do
      WriteAt(X,Y-1+I,attr,Str[I]);
end; {ScreenOBJ.WriteVert}

procedure ScreenOBJ.Attrib(X1,Y1,X2,Y2,Attr:byte);
{changes color attrib at specified coords}
var
   I: integer;
   X: byte;
   MVisible: boolean;
begin
{$IFNDEF FINAL}
   Exists;
{$ENDIF}
   MVisible := Mouse.Visible;
   if MVisible then
      Mouse.Hide;
   X := Succ(X2-X1);
   for I := Y1 to Y2 do
      oWritePtr^.ChangeAttr(X1,I,Attr,X);
   if MVisible then
      Mouse.Show;
end; {ScreenOBJ.Attrib}

procedure ScreenOBJ.TrixShadowAttrib(X1,Y1,X2,Y2,Attr:byte);
{"shadows" the color attrib at specified coords by un-setting the hi bit
in the foreground attribute.  This is a much more realistic shadow
than just overwriting whatever is there.}
var
   I: integer;
   X: byte;
   a,f,b:byte;
begin
{$IFNDEF FINAL}
   Exists;
{$ENDIF}
   if Mouse.Visible
     then Mouse.Hide;
   X := Succ(X2-X1);
   for I := Y1 to Y2 do begin
     {if background less than 8, set to 0; otherwise, dim by 8
      if foreground less than 8, set to 8; otherwise, dim by 8}
     a:=ReadAttr(X1,I);
     b:=a SHR 4;
     f:=a AND $0F;
     if b<8 then b:=0 else b:=b-8;
     if f<8 then f:=8 else f:=f-8;
     a:=(b SHL 4) OR f;
     oWritePtr^.ChangeAttr(X1,I,a,X);
   end;
   if not Mouse.Visible
     then Mouse.Show;
end;

procedure ScreenOBJ.Clear(Att:byte;Ch:char);
{}
begin
    PartClear(1,1,Width,Depth,Att,Ch);
end; {ScreenOBJ.Clear}

procedure ScreenOBJ.PartClear(X1,Y1,X2,Y2,Att:byte;Ch:char);
{}
var
   I : integer;
   S : string;
begin
   Attrib(X1,Y1,X2,Y2,Att);
   S := Replicate(Succ(X2-X1),Ch);
   for I := Y1 to Y2 do
      WritePlain(X1,I,S);
end; {ScreenOBJ.PartClear}

procedure ScreenOBJ.ClearText(X1,Y1,X2,Y2:byte);
{}
var
   I : integer;
   S : string;
begin
   S := Replicate(Succ(X2-X1),' ');
   for I := Y1 to Y2 do
       WritePlain(X1,I,S);
end; {ScreenOBJ.ClearText}

procedure ScreenOBJ.ReadWord(X,Y:byte;var Attr:byte; var Ch : char);
{updates vars Attr and Ch with attribute and character bytes in screen
 location (X,Y) of the active screen}
Type
  ScreenWordRec = record
     Ch   : char;   
     Attr : byte;
  end;
var
   VisiblePtr: pointer;
   VisibleAdr : word;
   SW : ScreenWordRec;
begin
    X := X + pred(oWritePtr^.WinX);
    Y := Y + pred(oWritePtr^.WinY);
    VisiblePtr := vScreenPtr;                {1.00b}
    VisibleAdr := pred(Y)*Monitor^.Width*2 + pred(X)*2;
    MoveFromScreen(mem[Seg(VisiblePtr^):ofs(VisiblePtr^)+VisibleAdr],
                      mem[seg(SW):ofs(SW)],1);
    Attr := SW.Attr;
    Ch   := SW.Ch;
end; {ScreenOBJ.ReadWord}

function ScreenOBJ.ReadChar(X,Y:byte):char;
var
   A : byte;
   C : char;
begin
    ReadWord(X,Y,A,C);
    ReadChar := C;
end; {ScreenOBJ.ReadChar}

function ScreenOBJ.ReadAttr(X,Y:byte):byte;
var
   A : byte;
   C : char;
begin
   ReadWord(X,Y,A,C);
   ReadAttr := A;
end; {ScreenOBJ.ReadAttr}

function ScreenOBJ.ReadStr(X1,X2,Y:byte):string;
var
   I : integer;
   Str: string;
begin
    Str := '';
    for I := X1 to X2 do
        Str := Str + ReadChar(I,Y);
    ReadStr := Str;
end; {ScreenOBJ.ReadStr}

procedure ScreenOBJ.TitleEngine(X1,Y1,X2,Y2,LeftPad,RightPad,Battr,Tattr:byte; 
                                Str, Title: string);
{}
var
   TitVert: byte; {0-top, 1-dropbox, 2-bottom}
   TitHoriz:byte; {0-left, 1-center, 2-right}
   MaxWidth:integer;
   X,Y : byte;
begin
   if (Title[2] in [TitPos[1],TitPos[2],TitPos[3]])
   and (Title[1] in [TitPos[4],TitPos[5],TitPos[6]]) then {swap 'em}
   begin
      insert(Title[2],Title,1);
      delete(Title,3,1);
   end;
   if Title[1] = TitPos[1] then
      TitHoriz := 0
   else if Title[1] = TitPos[3] then
      TitHoriz := 2
   else
      TitHoriz := 1;
   if Title[1] in [TitPos[1],TitPos[2],TitPos[3]] then
      delete(Title,1,1);
   if Title = '' then exit;
   if (Title[1] = TitPos[5]) and (Y2-Y1 > 1) then
      TitVert := 1
   else if Title[1] = TitPos[6] then
      TitVert := 2
   else
      TitVert := 0;
   if Title[1] in [TitPos[4],TitPos[5],TitPos[6]] then
      delete(Title,1,1);
   if Title = '' then exit;
   {check title is narrow enough to fit}
   if TitVert = 1 then 
      MaxWidth :=  pred(X2-X1)
   else
      MaxWidth := X2-X1-3;
   if TitVert = 0 then
      dec(MaxWidth,LeftPad+RightPad);
   if MaxWidth <= 0 then
      Title := ''
   else
      delete(Title,succ(MaxWidth),255);  {truncate title}
   Case Titvert of
      0: begin
         Case TitHoriz of
            0 : WriteAt(succ(X1)+LeftPad,Y1,Tattr,Title);
            1 : WriteBetween(succ(X1)+LeftPad,pred(X2)-RightPad,y1,Tattr,Title);
            else WriteRight(pred(X2)-RightPad,Y1,Tattr,Title);
         end; {case}
      end;
      1: begin
         WriteAt(X1,Y1+2,Battr,str[8]+
                            replicate(pred(X2-X1),str[2])+
                            Str[5]);
         Case TitHoriz of
            0 : WriteAt(succ(X1),succ(Y1),Tattr,Title);
            1 : WriteBetween(X1,X2,succ(y1),Tattr,Title);
            else WriteRight(pred(X2),succ(Y1),Tattr,Title);
         end; {case}
      end;
      2: begin
         Case TitHoriz of
            0 : WriteAt(succ(X1),Y2,Tattr,Title);
            1 : WriteBetween(X1,X2,Y2,Tattr,Title);
            else WriteRight(pred(X2),Y2,Tattr,Title);
         end; {case}
      end;
   end; {case}
end; {ScreenOBJ.TitleEngine}

procedure ScreenOBJ.BoxEngine(X1,Y1,X2,Y2,LeftPad,RightPad,Battr,Tattr,MAttr,style:byte;
                              Filled: boolean;
                              Title: string);
{Used internally by Box and FBox}
const
   Style1:string[10] = 'ÚÄ¿³´ÙÀÃ³Ä';
   Style2:string[10] = 'ÉÍ»º¹¼ÈÌºÍ';
   Style3:string[10] = 'ÖÄ·º¶½ÓÇºÄ';
   Style4:string[10] = 'ÕÍ¸³µ¾ÔÆ³Í';
   Style5:string[10] = 'ÚÄ·³µ¼ÔÆºÍ';
var
   Line,
   FLine,
   Str: string;
   I: integer;
begin
   if Style = 6 then
   begin
      PartClear(X1,Y1,X2,Y2,Mattr,' ');
      WriteAT(X1,Y1,BAttr,replicate(X2-pred(X1),char(223)));
      WriteAT(X1,Y1+2,BAttr,replicate(X2-pred(X1),{'_'}'Ä'));
      WriteBetween(X1,X2,succ(Y1),Tattr,Title);
   end
   else
   begin
      case Style of
      0 : Str := '          ';
      1 : Str := Style1;
      2 : Str := Style2;
      3 : Str := Style3;
      4 : Str := Style4;
      5 : Str := Style5;
      else Str := Replicate(10,chr(style));
      end;
      WriteAt(X1,Y1,Battr,Str[1]);
      Line := replicate(pred(X2-X1),Str[2]);
      WriteAt(X1+1,Y1,Battr,Line);
      WriteAt(X2,Y1,Battr,Str[3]);
      for I := Y1+1 to Y2-1 do
      begin
         WriteAt(X1,I,Battr,Str[4]);
         WriteAt(X2,I,Battr,Str[9]);
      end;
      if Filled then
         PartClear(succ(X1),succ(Y1),pred(X2),pred(Y2),MAttr,' ');
      WriteAt(X1,Y2,Battr,Str[7]);
      Line := replicate(pred(X2-X1),Str[10]);
      WriteAt(X1+1,Y2,Battr,Line);
      WriteAt(X2,Y2,Battr,Str[6]);
      {now the title: extract the first two character positions, and draw it}
      if Title <> '' then
         TitleEngine(X1,Y1,X2,Y2,LeftPad,RightPad,Battr,Tattr,Str,Title);
   end;
end; {BoxEngine}

procedure ScreenOBJ.Box(X1,Y1,X2,Y2,attr,style:byte);
{draws box and leaves internal area as is}
begin
    BoxEngine(X1,Y1,X2,Y2,0,0,attr,attr,attr,Style,false,'');
end; {ScreenOBJ.Box}

procedure ScreenOBJ.FillBox(X1,Y1,X2,Y2,attr,style:byte);
{draws box and erases internal area}
begin
   BoxEngine(X1,Y1,X2,Y2,0,0,attr,attr,attr,Style,true,'');
end; {ScreenOBJ.FillBox}

procedure ScreenOBJ.ShadFillBox(X1,Y1,X2,Y2,attr,style:byte);
{draws box and erases internal area}
begin
   BoxEngine(X1,Y1,X2,Y2,0,0,attr,attr,attr,Style,true,'');
   ShadowTOT^.DrawShadowXY(X1,Y1,X2,Y2);
end; {ScreenOBJ.ShadFillBox}

procedure ScreenOBJ.TitledBox(X1,Y1,X2,Y2,Battr,Tattr,MAttr,style:byte;Title:string);
{}
begin
   BoxEngine(X1,Y1,X2,Y2,0,0,Battr,Tattr,MAttr,Style,true,title);
end; {ScreenOBJ.TitledFillBox}

procedure ScreenOBJ.HorizLine(X1,X2,Y,Attr,Style : byte);
var
  I : integer;
  LineChar : char;
begin
   case Style of
   0   : LineChar := ' ';
   2,4 : LineChar := 'Í';
   1,3 : LineChar := 'Ä';
   else LineChar := Chr(Style);
   end; {case}
   WriteAt(X1,Y,Attr,replicate(X2-X1+1,LineChar))
end;   {ScreenOBJ.HorizLine}

procedure ScreenOBJ.VertLine(X,Y1,Y2,Attr,Style:byte);
{}
var
    I : integer;
    LineChar : char;
begin
   case Style of
   0   : LineChar := ' ';
   2,4 : LineChar := 'º';
   1,3 : LineChar := '³';
   else LineChar := Chr(Style);
   end; {case}
   for I := Y1 to Y2 do
      WriteAt(X,I,Attr,LineChar)
end; {ScreenOBJ.VertLine}

procedure ScreenOBJ.SmartVertLine(X,Y1,Y2,Attr,Style:byte);
{draws box character and adjust any lines it overlays}
var
    I : integer;
    LineStr : string[19];
    TestCh,
    Ch : char;
    StringOffset : byte;

    function AdjacentChar(X,Y:byte): char;
    {}
    begin
       if (X < 1) or (X > width) then
          AdjacentChar := ' '
       else
          AdjacentChar := ReadChar(X,Y);
    end; {AdjacentChar}

    function LineCh(X,Y:byte): char;
    {}
    const
       LeftSingle: string[13] = 'ÄÂ¿Å´ÁÙÒ·×¶Ð½';       
       LeftDouble: string[13] = 'ÍË»Î¹Ê¼Ñ¸ØµÏ¾';
       RightSingle:string[13] = 'ÚÄÂÃÅÀÁÖÒÇ×ÓÐ';
       RightDouble:string[13] = 'ÉÍËÌÎÈÊÕÑÆØÔÏ';
    var
      LineStyle : char;
    begin
       LineStyle := AdjacentChar(pred(X),Y);
       if pos(LineStyle,RightSingle) > 0 then
          LineStyle := 'Ä'
       else if pos(LineStyle,RightDouble) > 0 then
          LineStyle := 'Í'
       else
          LineStyle := ' ';
       case LineStyle of
       'Ä': if pos(AdjacentChar(succ(X),Y),leftSingle) > 0 then
               Ch := LineStr[2+StringOffset]
            else
               Ch := LineStr[3+StringOffset];
       'Í': if pos(AdjacentChar(succ(X),Y),LeftDouble) > 0 then
               Ch := LineStr[4+StringOffset]
            else
               Ch := LineStr[5+StringOffset];
       else  TestCh := AdjacentChar(succ(X),Y);
             If pos(TestCh,LeftSingle) > 0 then
                Ch := LineStr[6+StringOffset]
             else if pos(TestCh,LeftDouble) > 0  then
                Ch := LineStr[7+StringOffset]
             else
                Ch := LineStr[1];
       end; {case}
       LineCh := Ch;
    end; {LineCh}

begin
   if Style in [2,4] then
      LineStr := 'ºÒ·Ë»ÖÉ×¶Î¹ÇÌÐ½Ê¼ÓÈ'
   else
      LineStr := '³Â¿Ñ¸ÚÕÅ´ØµÃÆÁÙÏ¾ÀÔ';
   {draw first character}
   StringOffSet := 0;
   WriteAt(X,Y1,attr,LineCh(X,Y1));
   StringOffSet := 6;
   for I := succ(Y1) to pred(Y2) do
      WriteAt(X,I,attr,LineCh(X,I));
   StringOffSet := 12;
   WriteAt(X,Y2,attr,LineCh(X,Y2));
end; {ScreenOBJ.SmartVertLine}

procedure ScreenOBJ.SmartHorizLine(X1,X2,Y,Attr,Style:byte);
{draws box character and adjust any lines it overlays}
var
    I : integer;
    LineStr : string[19];
    TestCh,
    Ch : char;
    StringOffset : byte;

    function AdjacentChar(X,Y:byte): char;
    {}
    begin
       if (Y < 1) or (Y > depth) then
          AdjacentChar := ' '
       else
          AdjacentChar := ReadChar(X,Y);
    end; {AdjacentChar}

    function LineCh(X,Y:byte): char;
    {}
    const
        DownSingle: string[13] = 'ÚÂ¿³ÃÅ´ÕÑ¸ÆØµ';

        DownDouble: string[13] = 'ÉË»ºÌÎ¹ÖÒ·Ç×¶';

        UpSingle:   string[13] = '³ÃÅ´ÀÁÙÆØµÔÏ¾';

        UpDouble:   string[13] = 'ºÌÎ¹ÈÊ¼Ç×¶ÓÐº';
    var
      LineStyle : char;
    begin
       LineStyle := AdjacentChar(X,pred(Y));
       If pos(LineStyle,DownSingle) > 0 then
          LineStyle := '³'
       else if pos(LineStyle,DownDouble) > 0 then
          LineStyle := 'º'
       else                    
          LineStyle := ' ';
       case LineStyle of
       '³': if pos(AdjacentChar(X,succ(Y)),UpSingle) > 0 then
               Ch := LineStr[2+StringOffset]
            else
               Ch := LineStr[3+StringOffset];
       'º': if pos(AdjacentChar(X,succ(Y)),UpDouble) > 0 then
               Ch := LineStr[4+StringOffset]
            else
               Ch := LineStr[5+StringOffset];
       else  TestCh := AdjacentChar(X,succ(Y));
             If pos(TestCh,UpSingle) > 0 then
                Ch := LineStr[6+StringOffset]
             else if pos(TestCh,UpDouble) > 0 then
                Ch := LineStr[7+StringOffset]
             else
                Ch := LineStr[1];
       end; {case}
       LineCh := Ch;
    end; {LineCh}

begin
   if Style in [2,4] then
      LineStr := 'ÍÆÔÌÈÕÉØÏÎÊÑËµ¾¹¼¸» '
   else
      LineStr := 'ÄÃÀÇÓÚÖÅÁ×ÐÂÒ´Ù¶½¿·';
   {draw first character}
   StringOffSet := 0;
   WriteAt(X1,Y,attr,LineCh(X1,Y));
   StringOffSet := 6;
   for I := succ(X1) to pred(X2) do
      WriteAt(I,Y,attr,LineCh(I,Y));
   StringOffSet := 12;
   WriteAt(X2,Y,attr,LineCh(X2,Y));
end; {ScreenOBJ.SmartHorizLine}

procedure ScreenOBJ.WriteHScrollBar(X1,X2,Y,Attr: byte; Current,Max: longint);
{}
var 
  X,LineLength : integer;
begin
   WriteAT(X1,Y,Attr,ScrollTOT^.LeftChar);
   WriteAT(X2,Y,Attr,ScrollTOT^.RightChar);
   WriteAT(succ(X1),Y,Attr,replicate(pred(X2-X1),ScrollTOT^.BackgroundChar));
   if (Current > 0) and (Max >= Current) then
   begin
     LineLength := X2 - succ(X1);
     if LineLength > 0 then
     begin
        X := (Current * LineLength) div Max;
        if Current >= Max then
           X := pred(LineLength);
        if (X < 0) or (Current = 1) then
           X := 0;
        WriteAT(succ(X1) + X,Y,Attr,ScrollTOT^.ElevatorChar);
     end;
   end;
end; {ScreenOBJ.WriteHScrollBar}

procedure ScreenOBJ.WriteVScrollBar(X,Y1,Y2,Attr: byte; Current,Max: longint);
{}
var 
  BC : char;
  I,Y,LineLength : integer;
begin
   WriteAT(X,Y1,Attr,ScrollTOT^.UpChar);
   WriteAT(X,Y2,Attr,ScrollTOT^.DownChar);
   BC := ScrollTOT^.BackgroundChar;
   for I := succ(Y1) to pred(Y2) do
       WriteAT(X,I,Attr,BC);
   if (Current > 0) and (Max >= Current) then
   begin
     LineLength := Y2 - succ(Y1);
     if LineLength > 0 then
     begin
        Y := (Current * LineLength) div Max;
        if Current >= Max then
           Y := pred(LineLength);
        if (Y < 0) or (Current = 1) then
           Y := 0;
        WriteAT(X,succ(Y1)+Y,Attr,ScrollTOT^.ElevatorChar);
     end;
   end;
end; {ScreenOBJ.WriteVScrollBar}

destructor ScreenOBJ.Done;
{}
var MemoryUsed: longint;
begin
   If not OnScreen then
   begin
      MemoryUsed := Width*Depth*2;
      freemem(vScreenPtr,MemoryUsed);
   end;
   if oWritePtr<>nil then begin {trixfix}
     dispose(oWritePtr,Done);
     oWritePtr:=nil;
   end;
   Inherited Done; {trixfix}
end;  {ScreenOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     S c r o l l O B J   M E T H O D S     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
constructor ScrollOBJ.Init;
{}
begin
   Inherited Init; {trixfix}
   SetDefaults;
end; {ScrollOBJ.Init}

procedure ScrollOBJ.SetDefaults;
{}
begin
   SetScrollChars('','',char(27),char(26),'','°');
end;  {of ScrollOBJ.SetDefaults}

procedure ScrollOBJ.SetScrollChars(U,D,L,R,E,B:char);
{}

begin
   vUpArrowChar := U;
   vDownArrowChar := D; 
   vLeftArrowChar := L; 
   vRightArrowChar := R;
   vElevatorChar := E;
   vBackgroundChar := B;
end;  {of ScrollOBJ.SetScrollChars}

function ScrollOBJ.UpChar:char;
{}
begin
   UpChar := vUpArrowChar;
end; {ScrollOBJ.UpChar}

function ScrollOBJ.DownChar:char;
{}
begin
   DownChar := vDownArrowChar;
end; {ScrollOBJ.DownChar}

function ScrollOBJ.LeftChar:char;
{}
begin
   LeftChar := vLeftArrowChar;
end; {ScrollOBJ.LeftChar}

function ScrollOBJ.RightChar:char;
{}
begin
   RightChar := vRightArrowChar;
end; {ScrollOBJ.RightChar}

function ScrollOBJ.ElevatorChar:char;
{}
begin
   ElevatorChar := vElevatorChar;
end; {ScrollOBJ.ElevatorChar}

function ScrollOBJ.BackgroundChar:char;
{}
begin
   BackgroundChar := vBackgroundChar;
end; {ScrollOBJ.BackgroundChar}

destructor ScrollOBJ.Done;
begin
   Inherited Done; {trixfix}
end;
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     S h a d o w O B J   M E T H O D S     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
constructor ShadowOBJ.Init;
{}
begin
   Inherited Init; {trixfix}
   SetDefaults;
end; {ShadowOBJ.Init}

procedure ShadowOBJ.SetDefaults;
{}
begin
   vShadWidth := 2;
   vShadDepth := 1;
   vShadPos := DownRight;
   vShadAttr := 7;
   vShadChar := ' ';
end; {ShadowOBJ.SetDefaults}

procedure ShadowOBJ.DrawShadow(Border:tCoords);
{}
var
  Outer: tCoords;

  procedure DrawPartofShadow(X1,Y1,X2,Y2:byte);
  begin
     if (X1 > X2) or (Y1 > Y2) then exit;
     if vShadChar = ' ' then {attribute change}
        {Screen.Attrib(X1,Y1,X2,Y2,vShadAttr)}
        Screen.TrixShadowAttrib(X1,Y1,X2,Y2,vShadAttr)
     else
        Screen.PartClear(X1,Y1,X2,Y2,vShadAttr,vShadChar);
  end; {of sub proc DrawPartofShadow}

begin
   OuterCoords(Border,Outer);
   case vShadPos of
   UpLeft:   begin
                DrawPartofShadow(Outer.X1,Outer.Y1,pred(Border.X1),Border.Y2-vShadDepth);
                DrawPartofShadow(Border.X1,Outer.Y1,Border.X2-vShadWidth,pred(Border.Y1));
             end;
   UpRight:  begin
                DrawPartofShadow(Border.X1+vShadWidth,Outer.Y1,Outer.X2,pred(Border.Y1));
                DrawPartofShadow(succ(Border.X2),Border.Y1,Outer.X2,Border.Y2-vShadDepth);
             end;
   DownLeft: begin
                DrawPartofShadow(Outer.X1,Border.Y1+vShadDepth,pred(Border.X1),Outer.Y2);
                DrawPartofShadow(Border.X1,succ(Border.Y2),Border.X2-vShadWidth,Outer.Y2);
             end;
   DownRight:begin
                DrawPartofShadow(Border.X1+vShadWidth,succ(Border.Y2),Outer.X2,Outer.Y2);
                DrawPartofShadow(succ(Border.X2),Border.Y1+vShadDepth,Outer.X2,Border.Y2);
             end;
   end; {case}
end; {ShadowOBJ.DrawShadow}

procedure ShadowOBJ.DrawShadowXY(X1,Y1,X2,Y2:integer);
{}
var
  Border: tCoords;
begin
   Border.X1 := X1;
   Border.Y1 := Y1;
   Border.X2 := X2;
   Border.Y2 := Y2;
   DrawShadow(Border);
end; {ShadowOBJ.DrawShadowXY}

procedure ShadowOBJ.SetShadowStyle(ShadP:ShadowPosition; ShadA:byte; ShadC:char);
{}
begin
   vShadPos  :=  ShadP;
   vShadAttr :=  ShadA;
   vShadChar :=  ShadC;
end; {ShadowOBJ.SetShadowStyle}

procedure ShadowOBJ.SetShadowSize(ShadW,ShadD:byte);
{}
begin
   vShadWidth := ShadW;
   vShadDepth := ShadD;
end; {ShadowOBJ.SetShadowSize}

function ShadowOBJ.ShadWidth: byte;
{}
begin
   ShadWidth := vShadWidth;
end; {ShadowOBJ.ShadWidth}

function ShadowOBJ.ShadDepth: byte;
{}
begin
   ShadDepth := vShadDepth;
end; {ShadowOBJ.ShadDepth}

function ShadowOBJ.ShadAttr: byte;
{}
begin
   ShadAttr := vShadAttr;
end; {ShadowOBJ.ShadAttr}

function ShadowOBJ.ShadChar: char;
{}
begin
   ShadChar := vShadChar;
end; {ShadowOBJ.ShadChar}

function ShadowOBJ.ShadPos: ShadowPosition;
{}
begin
   ShadPos := vShadPos;
end; {ShadowOBJ.ShadPos}

procedure ShadowOBJ.OuterCoords(Border:tCoords;var Outer:tCoords);
{}
begin
   Case vShadPos of
   UpLeft:   begin
                Outer.X1 := Border.X1-vShadWidth;
                Outer.Y1 := Border.Y1-vShadDepth;
                Outer.X2 := Border.X2;
                Outer.Y2 := Border.Y2;
             end;
   UpRight:  begin
                Outer.X1 := Border.X1;
                Outer.Y1 := Border.Y1-vShadDepth;
                Outer.X2 := Border.X2+vShadWidth;
                Outer.Y2 := Border.Y2;
             end;
   DownLeft: begin
                Outer.X1 := Border.X1-vShadWidth;
                Outer.Y1 := Border.Y1;
                Outer.X2 := Border.X2;
                Outer.Y2 := Border.Y2+vShadDepth;
             end;
   DownRight:begin
                Outer.X1 := Border.X1;
                Outer.Y1 := Border.Y1;
                Outer.X2 := Border.X2+vShadWidth;
                Outer.Y2 := Border.Y2+vShadDepth;
             end;
   end; {case}
   if Outer.X1 < 1 then Outer.X1 := 1;
   if Outer.Y1 < 1 then Outer.Y1 := 1;
   if Outer.X2 > Screen.Width then Outer.X2 := Screen.Width;
   if Outer.Y2 > Screen.Depth then Outer.Y2 := Screen.Depth;
end; {ShadowOBJ.OuterCoords}

procedure ShadowOBJ.OuterXY(var X1,Y1,X2,Y2: integer);
{}
var Temp1,Temp2:tCoords;
begin
   Temp1.X1 := X1;
   Temp1.Y1 := Y1;
   Temp1.X2 := X2;
   Temp1.Y2 := Y2;
   OuterCoords(Temp1,Temp2);
   X1 := Temp2.X1;
   Y1 := Temp2.Y1;
   X2 := Temp2.X2;
   Y2 := Temp2.Y2;
end; {ShadowOBJ.OuterXY}

destructor ShadowOBJ.Done;
begin
   Inherited Done; {trixfix}
end;

{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}

procedure FastInit;
{initilizes objects and global variables}
begin
    if Monitor=nil then halt(1); {totsys:monitor is a dependency}
    Screen.Init;
    Screen.Create(0,0,0);
    new(ScrollTOT,Init);
    new(ShadowTOT,Init);
    SnowProne:=byte(Monitor^.SnowProne); {trixfix}
end; {FastInit}

procedure FastDone;
{de-initilizes objects and global variables in case the screenmode changes}
begin
    dispose(ShadowTOT,done);
    dispose(ScrollTOT,done);
    Screen.done;
end; {FastInit}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
   {$IFDEF INITTRACE}writeln('fastinit');{$ENDIF}
   FastInit;
{$ENDIF}
end.

