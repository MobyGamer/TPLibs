
{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10t                            }

Unit totWIN;
{$I TOTFLAGS.INC}

{
 Development History:
             Mar 15 91  1.00a   Changed DesqView checks.
             Mar 29 91  1.00b   Added method SetWinRestrict to control
                                whether screen coords are set to within
                                window border.
             Apr  4 91  1.00c   Fixed window coordinate problem when a
                                window is stretched.
             Apr 23 91  1.00d   Enabled SetAllowMove for all window
                                types.
             Feb 03 92  1.00e   Captured 600 as Key Lastkey
             Feb 24 93  1.10a   Change Winkey to check vRemove
             Mar 05 93  1.10b   Changed memory check in Window Move
             May 03 93  1.10c   Set cursor to 1,1 when Window drawn
                                to avoid a range check error.
                                Wait for Mouse Release when closing
             Jun 08 93  1.10d   Added checks of vRemove before removing
                                windows (Thanks Bill).
}

{
 Development Notes:
                600 = Close Window
                601 = Moved
                602 = Resized
                610 = Scroll Up One
                611 = Scroll Down One
                612 = Scroll Left one
                613 = Scroll Right one
                614 = Vertical Scroll Bar
                615 = Horizontal Scroll Bar
}

INTERFACE

uses DOS, CRT, totSYS, totLOOK, totINPUT, totFAST, totMISC, objects;

TYPE

WinPtr = ^WinOBJ;
pWinOBJ = ^WinOBJ;
WinOBJ = object (TObject)
   vBorder: tCoords;
   vOuter: tCoords;
   vClose: boolean;            {is close icon active}
   vUnderneathPtr: pointer;    {ptr to saved screen}
   vSavedSize: longint;        {amount of memory saved}
   vTitle: string;             {window title}
   vBorderAttr: byte;          {border attribute}
   vTitleAttr: byte;           {title attribute}
   vBodyAttr: byte;            {main text attribute}
   vIconsAttr: byte;           {close and zoom icon attribute}
   vStyle: byte;               {border style}
   vRemove: boolean;           {remove the window when done}
   vCursX: byte;               {saved cursor location}
   vCursY: byte;               {saved       -"-      }
   vCursTop: byte;             {saved cursor size}
   vCursBot: byte;             {saved     -"-    }
   vOldWin: tByteCoords;       {previous window coords}
   vOldWinConfine: boolean;    {were window coords active}
   vMVisible: boolean;         {was mouse visible}
   vFillWin: boolean;          {clear window core when redrawn}
   vWinRestrict: boolean;      {are windows coords relative to border}
   {methods...}
   constructor Init;
   procedure   SetSize(X1,Y1,X2,Y2,Style:byte);
   procedure   SetTitle(Title:string);
   procedure   SetColors(Border,Body,Title,Icons: byte);
   procedure   SetRemove(On:boolean);
   procedure   SetClose(On:boolean);
   procedure   SetWinRestrict(On:boolean);
   procedure   SetWindow;
   procedure   GetSize(var X1,Y1,X2,Y2,Style:byte);
   (*
   function    GetX:byte;
   function    GetY:byte;
   function    GetStyle: byte;
   function    GetBorderAttr: byte;
   function    GetTitleAttr: byte;
   function    GetBodyAttr: byte;
   function    GetIconsAttr: byte;
   function    GetRemoveStatus: boolean;
   *)
   procedure   Save;
   procedure   PartSave(X1,Y1,X2,Y2:byte; var Dest);
   procedure   PartRestore(X1,Y1,X2,Y2:byte; var Source);
   procedure   ComputeSavedCoords;
   procedure   DrawCore;
   procedure   GrowDraw;
   procedure   Remove;
   procedure   WinGetKey(var K:word;var X,Y:byte);
   procedure   SetBoundary(X1,Y1,X2,Y2:byte);                  VIRTUAL;
   procedure   WinKey(var K:word;var X,Y:byte);                VIRTUAL;
   procedure   Draw;                                           VIRTUAL;
   destructor  Done;                                           VIRTUAL;
end; {WinOBJ}

MoveWinPtr = ^MoveWinOBJ;
pMoveWinOBJ = ^MoveWinOBJ;
MoveWinOBJ = object (WinOBJ)
   vBoundary: tCoords;       {max area in which window can move}
   vMoveKey: word;
   vAllowMove: boolean;
   {methods...}
   constructor Init;
   procedure   SetMoveKey(K:word);
   procedure   SetAllowMove(On:boolean);
   procedure   BuildBackground(var BackScr: ScreenOBJ);
   procedure   RemoveShadow(var OriginalScreen: ScreenOBJ);
   procedure   RefreshUnderneath(BackScr: ScreenOBJ);
   procedure   WMove(UsingMouse:boolean;OldX,OldY:byte);
   procedure   WinKey(var K:word;var X,Y:byte);                VIRTUAL;
   procedure   SetBoundary(X1,Y1,X2,Y2:byte);                  VIRTUAL;
   destructor  Done;                                           VIRTUAL;
end; {MoveWinOBJ}

pScrollWinOBJ = ^ScrollWinOBJ;
ScrollWinOBJ = object (MoveWinOBJ)
   vScrollV: boolean;       {show vertical scroll bar}
   vScrollH: boolean;       {show horizontal scroll bar}
   {methods ...}
   constructor Init;
   procedure   SetScrollable(Vert,Horiz:boolean);
   procedure   DrawHorizBar(Current,Max: longint);
   procedure   DrawVertBar(Current,Max: longint);
   procedure   Winkey(var K:word;var X,Y:byte);                VIRTUAL;
   procedure   Draw;                                           VIRTUAL;
   destructor  Done;                                           VIRTUAL;
end; {ScrollWinOBJ}

StretchWinPtr = ^StretchWinOBJ;
pStretchWinOBJ = ^StretchWinOBJ;
StretchWinOBJ = object (ScrollWinOBJ)
   vZoomed: boolean;        {is window zoomed at present}
   vPreZoom: tCoords;        {size of window in Unzoomed state}
   vMinWidth: byte;         {min width of SmartWin}
   vMinDepth: byte;         {min depth of SmartWin}
   vStretchKey:word;        {keycode for manual stretch}
   vZoomKey:word;           {keycode for zoom}
   vAllowStretch: boolean;  {is user allowed to stretch}
   vSmartStretch: boolean;  {refresh window during stretch}
   {methods ...}
   constructor Init;
   procedure   SetMinSize(Width,depth:byte);
   procedure   Stretch(UsingMouse:boolean;OldX,OldY:byte);
   procedure   SetAllowStretch(On:boolean);
   procedure   ToggleZoom;
   procedure   Refresh;
   procedure   StretchRefresh;                                 VIRTUAL;
   procedure   Winkey(var K:word;var X,Y:byte);                VIRTUAL;
   procedure   Draw;                                           VIRTUAL;
   destructor  Done;                                           VIRTUAL;
end; {StretchWinOBJ}

procedure WinInit;

IMPLEMENTATION

{|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                               }
{     U N I T   P R O C E D U R E S   &   F U N C T I O N S     }
{                                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||}

procedure Error(Err:byte);
{routine to display error}
const
   Header = 'WinTOT error: ';
var
   Msg : string;
begin
   Case Err of
   1: Msg := 'Not enough memory to create window';
   2: Msg := 'Invalid window dimensions';
   3: Msg := 'Not enough memory to create SmartWin';
   else  Msg := 'Unknown Error';
   end; {case}
   Writeln(Header,Msg);
{Maybe Add non-fatal compiler directive}
   halt;
end; {Error}

{||||||||||||||||||||||||||||||||||||}
{                                    }
{    W i n O B J   M E T H O D S     }
{                                    }
{||||||||||||||||||||||||||||||||||||}

constructor WinOBJ.Init;
{}
begin
   {SetSize(10,5,70,20,1);}
   SetSize(5,5,35,20,1); {trixfix} {make compatible with 40x25}
   SetTitle('');
   SetRemove(true);
   with LookTOT^ do
       SetColors(WinBorder,WinBody,WinTitle,WinIcons);
   vUnderneathPtr := Nil;
   vMVisible := true;
   vClose := true;
   vFillWin := true;
   vWinRestrict := true;
end; {of const WinOBJ.Init}

procedure WinOBJ.SetSize(X1,Y1,X2,Y2,Style:byte);
{}
begin
{$IFDEF CHECK} {trixfix We don't want this aborting because user can always resize later}
(*   if (X2 < X1 + 2)
   or (Y2 < Y1 + 2)
   or (Y2 > Screen.Depth)
   or (X2 > Screen.Width) then
      Error(2);*)
{$ENDIF}
   vBorder.X1 := X1;
   vBorder.Y1 := Y1;
   vBorder.X2 := X2;
   vBorder.Y2 := Y2;
   vStyle := Style;
end; {WinOBJ.SetSize}

procedure WinOBJ.GetSize(var X1,Y1,X2,Y2,Style:byte);
{}
begin
   X1 := vBorder.X1;
   Y1 := vBorder.Y1;
   X2 := vBorder.X2;
   Y2 := vBorder.Y2;
   Style := vStyle;
end; {WinOBJ.GetSize}

(*
function WinOBJ.GetX:byte;
{}
begin
   GetX := vBorder.X1;
end; {WinOBJ.GetX}

function WinOBJ.GetY:byte;
{}
begin
   GetY := vBorder.Y1;
end; {WinOBJ.GetY}

function WinOBJ.GetStyle:byte;
{}
begin
   GetStyle := vStyle;
end; {WinOBJ.GetStyle}

function WinOBJ.GetBorderAttr: byte;
{}
begin
   GetBorderAttr := vBorderAttr;
end; {WinOBJ.GetBorderAttr}

function WinOBJ.GetTitleAttr: byte;
{}
begin
   GetTitleAttr := vTitleAttr;
end; {WinOBJ.GetTitleAttr}

function WinOBJ.GetBodyAttr: byte;
{}
begin
   GetBodyAttr := vBodyAttr;
end; {WinOBJ.GetBodyAttr}

function WinOBJ.GetIconsAttr: byte;
{}
begin
   GetIconsAttr := vIconsAttr;
end; {WinOBJ.GetIconsAttr}
*)

procedure WinOBJ.SetRemove(On:boolean);
{}
begin
   vRemove := On;
end; {Window.SetRemove}

procedure WinOBJ.SetClose(On:boolean);
{}
begin
   vClose := On;
end; {WinOBJ.SetClose}

procedure WinOBJ.SetWinRestrict(On:boolean);
{}
begin
   vWinRestrict := On;
end; {WinOBJ.SetWinRestrict}

(*
function WinOBJ.GetRemoveStatus: boolean;
{}
begin
   GetRemoveStatus := vRemove;
end; {WinOBJ.GetRemoveStatus}
*)

procedure WinOBJ.SetTitle(Title:string);
{}
begin
   vTitle := Title;
end; {WinOBJ.SetTitle}

procedure WinOBJ.SetColors(Border,Body,Title,Icons: byte);
{}
begin
   if Border <> 0 then
      vBorderAttr := Border;
   if Title <> 0 then
      vTitleAttr := Title;
   if Body <> 0 then
      vBodyAttr := Body;
   if Icons <> 0 then
      vIconsAttr := Icons;
end; {WinOBJ.SetColors}

procedure WinOBJ.SetBoundary(X1,Y1,X2,Y2:byte);
{abstract}
begin end;

procedure WinOBJ.ComputeSavedCoords;
{checks shodow position and style and computes saved screen coords}
begin
   ShadowTOT^.OuterCoords(vBorder,vOuter);
end; {WinOBJ.ComputeSavedCoords}

procedure WinOBJ.SetWindow;
{}
begin
   if vWinRestrict then {1.00b}
      with vBorder do
      case vStyle of
         0: Screen.SetWindow(X1,Y1,X2,Y2);
         6: Screen.SetWindow(succ(X1),Y1+3,pred(X2),Y2);
         else Screen.SetWindow(succ(X1),succ(y1),pred(X2),pred(Y2));
      end; {case}
end; {WinOBJ.SetWindow}

procedure WinOBJ.Save;
{}
var
  MemoryNeeded: longint;
begin
   ComputeSavedCoords;
   MemoryNeeded := succ(vOuter.X2-vOuter.X1)*succ(vOuter.Y2-vOuter.Y1)*2;
   if MaxAvail < MemoryNeeded then
      Error(1)
   else
   begin
      if vUnderneathPtr <> nil then
      begin
         freemem(vUnderneathPtr,vSavedSize);
         vUnderneathPtr := nil;
      end;
      getmem(vUnderneathPtr,MemoryNeeded);
      PartSave(vOuter.X1,vOuter.Y1,vOuter.X2,vOuter.Y2,vUnderneathPtr^);
      vSavedSize := MemoryNeeded;
      vCursX := Screen.WhereX;
      vCursY := Screen.WhereY;
      Screen.CursSave;
      vCursTop:= Screen.vCursTop;
      vCursBot:= Screen.vCursBot;
      Screen.WindowCoords(vOldWin);
      vOldWinConfine := Screen.WindowActive;
   end;
end; {WinOBJ.Save}

procedure WinOBJ.DrawCore;
{}
begin
   if (vStyle in [1..5]) and vClose then
   begin
      with vBorder do
      begin
         Screen.BoxEngine(X1,Y1,X2,Y2,4,4,vBorderAttr,vTitleAttr,vBodyAttr,
                          vStyle,vFillWin,vTitle);
         Screen.WriteAT(X1+2,Y1,vBorderAttr,'[ ]');
         Screen.WriteAT(X1+3,Y1,vIconsAttr,'þ');
      end;
   end
   else
      with vBorder do
         Screen.BoxEngine(X1,Y1,X2,Y2,0,0,vBorderAttr,vTitleAttr,vBodyAttr,
                          vStyle,vFillWin,vTitle);
   if (vStyle = 6) and vClose then
      with vBorder do
         Screen.WriteAT(X1+3,Y1,vIconsAttr,'þ');
end; {WinOBJ.DrawCore}

procedure WinOBJ.Draw;
{}
var WasOn: boolean;
begin
   vMVisible := Mouse.Visible;
   Save;
   WasOn := Screen.WindowOff;
   ShadowTOT^.DrawShadow(vBorder);
   DrawCore;
   SetWindow;
   GotoXY(1,1);        {1.10c}
   if not vMVisible then
      Mouse.Show;
end; {WinOBJ.Draw}

procedure WinOBJ.GrowDraw;
{}
var
  I,TX1,TY1,TX2,TY2,Ratio : integer;
  WasOn: boolean;
begin
   Save;
   vMVisible := Mouse.Visible;
   WasOn := Screen.WindowOff;
   with vBorder do
   begin
      if 2*(Y2 -Y1 +1) > X2 - X1 + 1 then
         Ratio :=   2
      else
         Ratio :=  1;
      TX2 := (X2 - X1) div 2 + X1 + 2;
      TX1 := TX2 - 3;                 {needs a box 3 by 3 minimum}
      TY2 := (Y2 - Y1) div 2 + Y1 + 2;
      TY1 := TY2 - 3;
      if (X2-X1) < 3 then
      begin
         TX2 := X2;
         TX1 := X1;
      end;
      if (Y2-Y1) < 3 then
      begin
         TY2 := Y2;
         TY1 := Y1;
      end;
      repeat
         Screen.PartClear(TX1,TY1,TX2,TY2,vBodyAttr,' ');
         if TX1 >= X1 + (1*Ratio) then 
            TX1 := TX1 - (1*Ratio) 
         else 
            TX1 := X1;
         if TY1 > Y1  then 
            TY1 := TY1 - 1;
         if TX2 + (1*Ratio) <= X2 then 
            TX2 := TX2 + (1*Ratio) 
         else 
            TX2 := X2;
         if TY2 + 1 <= Y2 then 
            TY2 := TY2 + 1;
         delay(10);
      Until (TX1 = X1) and (TY1 = Y1) and (TX2 = X2) and (TY2 = Y2);
      DrawCore;
   end;
   ShadowTOT^.DrawShadow(vBorder);
   SetWindow;
   if not vMVisible then
      Mouse.Show;
end; {WinOBJ.GrowDraw}

procedure WinOBJ.PartSave(X1,Y1,X2,Y2:byte; var Dest);
{}
var
   I,w : byte;
   Wid : word;
   ScreenAdr: integer;
   Pntr: pointer;
   Mvisible: boolean;
begin
   w := succ(X2- X1);
   Pntr := Screen.vScreenPtr;
   Mvisible := Mouse.Visible;
   Wid := Monitor^.Width*2;
   if MVisible then
      Mouse.Hide;
   for I :=  Y1 to Y2 do
   begin
      ScreenAdr := Pred(I)*Wid + Pred(X1)*2;
      Screen.MoveFromScreen(Mem[seg(Pntr^):ofs(Pntr^)+ScreenAdr],
                        Mem[seg(Dest):ofs(dest)+(I-Y1)*w*2],
                        w);
   end;
   if MVisible then
      Mouse.Show;
end; {WinOBJ.PartSave}

procedure WinOBJ.PartRestore(X1,Y1,X2,Y2:byte; var Source);
{}
var
   I,w : byte;
   Wid: word;
   ScreenAdr: integer;
   Pntr: pointer;
   Mvisible: boolean;
begin
   w := succ(X2- X1);
   Pntr := Screen.vScreenPtr;
   Wid := Monitor^.Width*2;
   MVisible := Mouse.Visible;
   if MVisible then
      Mouse.Hide;
   for I :=  Y1 to Y2 do
   begin
      ScreenAdr := Pred(I)*Wid + Pred(X1)*2;
      Screen.MoveToScreen(Mem[seg(Source):ofs(Source)+(I-Y1)*w*2],
                      Mem[seg(Pntr^):ofs(Pntr^)+ScreenAdr],
                      w);
   end;
   if MVisible then
      Mouse.Show;
end; {WinOBJ.PartRestore}

procedure WinOBJ.Remove;
{}
begin
   if vUnderneathPtr <> Nil then
   begin
      Mouse.Hide;
      PartRestore(vOuter.X1,vOuter.Y1,vOuter.X2,vOuter.Y2,vUnderneathPtr^);
      freemem(vUnderneathPtr,vSavedSize);
      vUnderneathPtr := nil;
      if vOldWinConfine then
         with vOldWin do
            Screen.SetWindow(X1,Y1,X2,Y2)
      else
         Screen.ResetWindow;
      Screen.GotoXY(vCursX,vCursY);
      Screen.CursSize(vCursTop,vCursBot);
      if vMVisible then
         Mouse.Show;
   end;
end; {WinOBJ.Remove}

procedure WinOBJ.WinGetKey(var K:word;var X,Y:byte);
{}
begin
   with key do
   begin
      Key.GetInput;
      K := Key.LastKey;
      X := Key.LastX;
      Y := Key.LastY;
      WinKey(K,X,Y);
   end;
end; {WinOBJ.WinGetKey}

procedure WinOBJ.WinKey(var K:word;var X,Y:byte);      
{}
begin 
   if  (K = 513) and (Y = vBorder.Y1) 
   and (X = vBorder.X1 + 3) and vClose then
   begin
      if vRemove then  {1.10a}
         Remove;
      K := 600;  {Closed}
      Key.vLastKey := K;  {1.00e}
   end;
end; {WinOBJ.WinKey}

destructor WinOBJ.Done;
{}
begin
    if (vRemove) and (vUnderneathPtr <> Nil)  then
       Remove;
    if vUnderneathPtr <> Nil then
       freemem(vUnderneathPtr,vSavedSize);
end; {WinOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||}
{                                            }
{    M o v e W i n O B J   M E T H O D S     }
{                                            }
{||||||||||||||||||||||||||||||||||||||||||||}
constructor MoveWinOBJ.Init;
{}
begin
   WinOBJ.Init;
   vAllowMove := true;
   vMoveKey := LookTOT^.WinMoveKey;
   SetBoundary(1,1,Monitor^.Width,Monitor^.Depth);
end; {MoveWinOBJ.Init}

procedure MoveWinOBJ.SetMoveKey(K:word);
{}
begin
   vMoveKey := K; {1.00d}
end; {MoveWinOBJ.SetMoveKey}

procedure MoveWinOBJ.SetBoundary(X1,Y1,X2,Y2:byte);
{}
begin
   vBoundary.X1 := X1;
   vBoundary.Y1 := Y1;
   vBoundary.X2 := X2;
   vBoundary.Y2 := Y2;
end; {MoveWinOBJ.SetBoundary}

procedure MoveWinOBJ.BuildBackground(var BackScr: ScreenOBJ);
{saves the screen and replaces the contents of the screen
 where the window lies with the image saved behind the window.
}
var
   I,w : byte;
   Wid : word;
   ImageAdr: integer;
   Pntr: pointer;
begin
   BackScr.Save;    {save current screen}
   w := succ(vOuter.X2- vOuter.X1);
   Pntr := BackScr.vScreenPtr;
   Wid := Monitor^.Width*2;
   for I :=  vOuter.Y1 to vOuter.Y2 do
   begin
      ImageAdr := Pred(I)*Wid + Pred(vOuter.X1)*2;
      Move(Mem[seg(vUnderneathPtr^):ofs(vUnderneathPtr^)+(I-vOuter.Y1)*w*2],
           Mem[seg(Pntr^):ofs(Pntr^)+ImageAdr],
           w*2);
   end;
end; {MoveWinOBJ.BuildBackground}

procedure MoveWinOBJ.RefreshUnderneath(BackScr: ScreenOBJ);
{Takes image from saved screen and moves it to the window's saved
 image at UnderneathPtr.
}
var
   I,w : byte;
   Wid : word;
   ImageAdr: integer;
   Pntr: pointer;
begin
   {dispose of window memory, and get required memory}
   freemem(vUnderneathPtr,vSavedSize);
   w := succ(vOuter.X2- vOuter.X1);
   vSavedSize := succ(vOuter.Y2 - vOuter.Y1)*W*2;
   getmem(vUnderneathPtr,vSavedSize);
   Pntr := BackScr.vScreenPtr;
   Wid := Monitor^.Width*2;
   for I :=  vOuter.Y1 to vOuter.Y2 do
   begin
      ImageAdr := Pred(I)*Wid + Pred(vOuter.X1)*2;
      Move(Mem[seg(Pntr^):ofs(Pntr^)+ImageAdr],
           Mem[seg(vUnderneathPtr^):ofs(vUnderneathPtr^)+(I-vOuter.Y1)*w*2],
           w*2);
   end;
end; {MoveWinOBJ.RefreshUnderneath}

procedure MoveWinOBJ.RemoveShadow(var OriginalScreen: ScreenOBJ);
{}
begin
   if vOuter.X1 < vBorder.X1 then   {shadowleft}
      OriginalScreen.PartDisplay(vOuter.X1,vOuter.Y1,pred(vBorder.X1),vOuter.Y2,vOuter.X1,vOuter.Y1);
   if vOuter.X2 > vBorder.X2 then   {shadowright}
      OriginalScreen.PartDisplay(succ(vBorder.X2),vOuter.Y1,vOuter.X2,vOuter.Y2,succ(vBorder.X2),vOuter.Y1);
   if vOuter.Y1 < vBorder.Y1 then   {shadowUp}
      OriginalScreen.PartDisplay(vOuter.X1,vOuter.Y1,vOuter.X2,pred(vBorder.Y1),vOuter.X1,vOuter.Y1);
   if vOuter.Y2 > vBorder.Y2 then  {shadowDown}
      OriginalScreen.PartDisplay(vOuter.X1,succ(vBorder.Y2),vOuter.X2,vOuter.Y2,vOuter.X1,succ(vBorder.Y2));
end; {MoveWinOBJ.RemoveShadow}

procedure MoveWinOBJ.WMove(UsingMouse:boolean;OldX,OldY:byte);
var
   Mvisible,
   WasOn,
   Left,Center,Right : boolean;
   X,Y : Byte;
   DeltaX, DeltaY : shortint;
   ScrPtr,
   OldPtr,
   SmartWinImagePtr : pointer;
   Wid: word;
   CTop,CBot,CX,CY:byte;
   W,D: byte;
   OldLocation : tCoords;
   OriginalScreen: ScreenOBJ;

  procedure CaptureSmartWin;
  {saves image of window}
  var I : integer;
  begin
     with vBorder do
     begin
        getmem(SmartWinImagePtr,W*D*2);
        Screen.PartSave(X1,Y1,X2,Y2,SmartWinImagePtr^);
     end;
  end; {CaptureSmartWin}

  procedure RestoreSmartWin;
  {}
  begin
     with vBorder do
        Screen.PartRestore(X1,Y1,X2,Y2,SmartWinImagePtr^);
  end; {RestoreSmartWin}

  procedure DisposeSmartWin;
  {}
  begin
     freemem(SmartWinImagePtr,W*D*2);
  end; {DisposeSmartWin}

  procedure FastRestore(X1,Y1,X2,Y2:byte);
  {}
  var
     I,w : byte;
     ScreenAdr: integer;
   begin
      if (X1 > X2) or (Y1 > Y2) then
         exit;
      w := succ(X2 - X1);
      for I :=  Y1 to Y2 do
      begin
         ScreenAdr := Pred(I)*Wid + Pred(X1)*2;
         Screen.MoveToScreen(Mem[seg(OldPtr^):ofs(OldPtr^)+ScreenAdr],
                             Mem[seg(ScrPtr^):ofs(ScrPtr^)+ScreenAdr],
                              w);
      end;
   end; {FastRestore}

begin
   with vBorder do
   begin
      W := succ(X2 - X1);
      D := succ(Y2 - Y1);
   end;
   if MaxAvail < W*D*2 + Screen.Width*Screen.Depth*2 then {1.10b}
   begin
      Beep;
      Exit;
   end;
   with Screen do
   begin
      CursSave;
      CX := Screen.WhereX;
      CY := Screen.WhereY;
      CTop := vCursTop;
      CBot := vCursBot;
      CursOff;
   end;
   OriginalScreen.Init;
   MVisible := Mouse.Visible;
   if MVisible then
      Mouse.Hide;
   BuildBackground(OriginalScreen);
   ScrPtr :=  Monitor^.BaseOfScreen;         {1.00a}
   OldPtr := OriginalScreen.vScreenPtr;
   Wid := Monitor^.Width*2;
   CaptureSmartWin;
   RemoveShadow(OriginalScreen);
   repeat
      if UsingMouse then
      begin
         Mouse.Show;
         Mouse.Status(Left,Center,Right,X,Y);
      end
      else
      begin
         with Key do
         begin
            OldX := 20;
            OldY := 20;
            Y := 20;
            X := 20;
            GetInput;
            Case Key.LastKey of
               328: dec(Y); {up}
               336: inc(Y); {down}
               333: inc(X); {right}
               331: dec(X); {left}
            end; {case}
            Left := true;
         end;
      end;
      if Left and ( (X <> OldX) or (Y <> OldY) ) then  {move window}
      begin
         OldLocation := vOuter;
         if (X <> OldX) then
         begin
            DeltaX := X - OldX;
            if  (DeltaX + vBorder.X1 >= vBoundary.X1)
            and (DeltaX + vBorder.X2 <= vBoundary.X2) then
            begin
               vBorder.X1 := vBorder.X1 + DeltaX;
               vBorder.X2 := vBorder.X2 + DeltaX;
            end
            else DeltaX := 0;
         end
         else
            DeltaX := 0;
         if (Y <> OldY) then
         begin
            DeltaY := Y - OldY;
            if  (DeltaY + vBorder.Y1 >= vBoundary.Y1)
            and (DeltaY + vBorder.Y2 <= vBoundary.Y2) then
            begin
               vBorder.Y1 := vBorder.Y1 + DeltaY;
               vBorder.Y2 := vBorder.Y2 + DeltaY;
            end
            else
              DeltaY := 0;
         end
         else
            DeltaY := 0;
         ComputeSavedCoords;
         Mouse.Hide;
         RestoreSmartWin;
         if DeltaX > 0 then {viewport moved right}
            FastRestore(OldLocation.X1,vOuter.Y1,pred(vBorder.X1),vOuter.Y2)
         else if DeltaX < 0 then {viewport moved left}
            FastRestore(succ(vBorder.X2),vBorder.Y1,OldLocation.X2,vOuter.Y2);
         if DeltaY > 0 then {Viewport moved down}
            FastRestore(OldLocation.X1,OldLocation.Y1,vBorder.X2,pred(vBorder.Y1))
         else if deltaY < 0 then {Viewport moved up}
            FastRestore(OldLocation.X1,succ(vBorder.Y2),vBorder.X2,OldLocation.Y2);
         if DeltaX < 0 then    {moved left}
         begin
             if (DeltaY > 0) then
                FastRestore(succ(vBorder.X1),OldLocation.Y1,Oldlocation.X2,pred(vBorder.Y1))
             else
                FastRestore(succ(vBorder.X2),succ(vOuter.Y2),Oldlocation.X2,OldLocation.Y2);
         end;
         OldX := X;
         OldY := Y;
         {Mouse.Move(X,Y);}
      end; {if}
   until (UsingMouse and (Left = false)) or (((Key.LastKey =13) or (Key.LastKey =27)) and (UsingMouse = false));
   Mouse.Hide;
   WasOn := Screen.WindowOff;
   ShadowTOT^.DrawShadow(vBorder);
   Screen.WindowOn;
   if MVisible then
      Mouse.Show;
   {now save new background behind window}
   RefreshUnderneath(OriginalScreen);
   SetWindow;
   Screen.GotoXY(CX,CY);
   Screen.CursSize(CTop,CBot);
   OriginalScreen.Done;
   DisposeSmartWin;
end; {MoveWinOBJ.Move}

procedure MoveWinOBJ.SetAllowMove(On:boolean);
{}
begin
   vAllowMove := On;
end; {MoveWinOBJ.SetAllowMove}

procedure MoveWinOBJ.WinKey(var K:word;var X,Y:byte);
{}
begin
   if (K = vMoveKey) and (vAllowMove) then
      WMove(false,X,Y)
   else if  (K = 513) and (Y = vBorder.Y1) and
   (X >= vBorder.X1) and (X <= vBorder.X2) then
   begin
      if (X = vBorder.X1 + 3) and vClose then
      begin
         if vRemove then  {1.10d}
            Remove;
         K := 600;  {Closed}
         Key.vLastKey := K;  {1.00e}
         Mouse.WaitForRelease;  {1.10c}
      end
      else if vAllowMove then
      begin
         WMove(true,X,Y);
         K := 601;  {Moved}
      end;
   end;
end; {MoveWinOBJ.WinKey}

destructor MoveWinOBJ.Done;
{}
begin
   WinOBJ.Done;
end; {MoveWinOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                }
{    S c r o l l W i n O B J   M E T H O D S     }
{                                                }
{||||||||||||||||||||||||||||||||||||||||||||||||}
constructor ScrollWinOBJ.Init;
{}
begin
   MoveWinOBJ.Init;
   vScrollV := false;
   vScrollH := false;
end; {ScrollWinOBJ.Init}

procedure ScrollWinOBJ.SetScrollable(Vert,Horiz:boolean);
{}
begin
   vScrollV := Vert;
   vScrollH := Horiz;
end; {ScrollWinOBJ.SetScrollable}

procedure ScrollWinOBJ.DrawHorizBar(Current,Max: longint);
{}
var
  WasOn: boolean;
  CursX,CursY : byte;
begin
   if (vStyle in [1..5]) and (vScrollH) then
   begin
      CursX := Screen.WhereX;
      CursY := Screen.WhereY;
      WasOn := Screen.WindowOff;
      with vBorder do
         Screen.WriteHScrollBar(succ(X1),pred(X2),Y2,vBorderAttr,Current,Max);
      SetWindow;
      Screen.GotoXY(CursX,CursY);
   end; 
end; {ScrollWinOBJ.DrawHorizBar}

procedure ScrollWinOBJ.DrawVertBar(Current,Max: longint);
{}
var
   WasOn: boolean;
   CursX,CursY : byte;
begin
   if (vStyle in [1..5]) and (vScrollV) then
   begin
      CursX := Screen.WhereX;
      CursY := Screen.WhereY;
      WasOn := Screen.WindowOff;
      with vBorder do
         Screen.WriteVScrollBar(X2,succ(Y1),pred(Y2),vBorderAttr,Current,Max);
      SetWindow;
      Screen.GotoXY(CursX,CursY);
   end;
end; {ScrollWinOBJ.DrawVertBar}

procedure ScrollWinOBJ.WinKey(var K:word;var X,Y:byte);
{ RetCodes
610 = Scroll Up One
611 = Scroll Down One
612 = Scroll Left one
613 = Scroll Right one
614 = Vertical Scroll Bar
615 = Horizontal Scroll Bar
}
begin
   if (K = vMoveKey) and (vAllowMove) then {1.00d}
      WMove(false,X,Y)
   else if  (K = 513) then
   begin
      if (Y = vBorder.Y1) and
      (X >= vBorder.X1) and (X <= vBorder.X2) then
      begin
         if (X = vBorder.X1 + 3) and vClose then
         begin
            if vRemove then  {1.10d}
               Remove;
            K := 600;  {Closed}
            Key.vLastKey := K;  {1.00e}
         end
         else if vAllowMove then {1.00d}
         begin
            WMove(true,X,Y);
            K := 601;  {Moved}
         end;
      end
      else if vScrollV and (X = vBorder.X2) then
      begin
          if  Y = succ(vBorder.Y1) then
             K := 610
          else if Y =  pred(vBorder.Y2)  then
             K := 611
          else if  (Y > succ(vBorder.Y1))
             and (Y < pred(vBorder.Y2)) then {scroll bar}
             begin
                {adjust X to represent no of characters down scroll bar}
                {adjust Y to return total length of scroll bar}
                K := 614;
                X := Y - succ(vBorder.Y1);
                Y := vBorder.Y2 - vBorder.Y1 - 3;
             end;
      end
      else  if vScrollH and (Y = vBorder.Y2) then
      begin
         if X = succ(vBorder.X1) then
            K := 612
         else if X = pred(vBorder.X2) then
            K := 613
         else if  (X > succ(vBorder.X1))
            and (X < pred(vBorder.X2)) then
            begin
               K := 615;
               X := X - succ(vBorder.X1);
               Y := vBorder.X2 - vBorder.X1 - 3;
            end;
      end;
   end;
end; {ScrollWinOBJ.WinKey}

procedure ScrollWinOBJ.Draw;
{}
begin
   if not (vStyle in [1..5]) then
      vStyle := 1;
   MoveWinOBJ.Draw;
end; {ScrollWinOBJ.Draw}

destructor ScrollWinOBJ.Done;
{}
begin
   MoveWinOBJ.Done;
end; {ScrollWinOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                  }
{    S t r e t c h W i n O B J   M E T H O D S     }
{                                                  }
{||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor StretchWinOBJ.Init;
{}
begin
   ScrollWinOBJ.Init;
   vZoomed := false;
   vPreZoom := vBorder;
   vMinWidth := 10;
   vMinDepth := 5;
   vStretchKey:= LookTOT^.vWinStretchKey;
   vZoomKey:= LookTOT^.vWinZoomKey;
   vAllowStretch := true;
   vSmartStretch := false;
end; {StretchWinOBJ.Init}

procedure StretchWinOBJ.SetAllowStretch(On:boolean);
{}
begin
   vAllowStretch := On;
end; {StretchWinOBJ.SetAllowStretch}

procedure StretchWinOBJ.SetMinSize(Width,depth:byte);
{}
begin
   vMinWidth := width;
   vMinDepth := depth;
end; {StretchWinOBJ.SetMinSize}

procedure StretchWinOBJ.ToggleZoom;
{zooms or unzooms a window}
begin
   vZoomed := not vZoomed;
   Remove;             {remove the window}
   if vUnderneathPtr <> Nil then
      FreeMem(vUnderneathPtr,succ(vOuter.X2-vOuter.X1)*succ(vOuter.Y2-vOuter.Y1)*2);
   if not vZoomed then
      vBorder := vPreZoom  {set zone coords back to the old coords}
   else
   begin
      vPreZoom := vBorder;  {save the un-zoomed coordinates}
      vBorder := vBoundary; {set window coords to the maximum}
   end;      
   ComputeSavedCoords;
   Draw;        
end; {StretchWinOBJ.ToggleZoom}

procedure StretchWinOBJ.StretchRefresh;
{abstract} begin end;

procedure StretchWinOBJ.Stretch(UsingMouse:boolean;OldX,OldY:byte);
{}
const
   BorderChar = 'Û';
   Col = white;
var
   Mvisible,
   WasOn: boolean;
   Left,Center,Right : boolean;
   CTop,CBot,CX,CY:byte;
   NewX,NewY,
   X,Y : Byte;
   OriginalScreen: ScreenOBJ;
   BackScreen: ScreenOBJ;
   OldWin: tByteCoords;                   {1.00c}
   OldWinConfine: boolean;

     procedure ChangePerimeter;
     {}
     var
       I : integer;
     begin
        if NewX <> vBorder.X2 then
        with vBorder do
        begin
           OriginalScreen.PartDisplay(X2,Y1,X2,Y2,X2,Y1);
           if NewX < X2 then
           begin
              OriginalScreen.PartDisplay(succ(NewX),Y1,X2,Y2,succ(NewX),Y1);
              OriginalScreen.PartDisplay(succ(NewX),Y2,X2,Y2,succ(NewX),Y2);
           end;
        end;
        if NewY <> vBorder.Y2 then
        with vBorder do
        begin
           OriginalScreen.PartDisplay(X1,Y2,X2,Y2,X1,Y2);
           if NewY < Y2 then
           begin
              OriginalScreen.PartDisplay(X1,succ(NewY),X2,Y2,X1,succ(NewY));
              OriginalScreen.PartDisplay(X2,succ(NewY),X2,Y2,X2,succ(NewY));
           end;
        end;
        {draw new perimiter}
        with vBorder do
        begin
           X2 := NewX;
           Y2 := NewY;
           Screen.Box(X1,Y1,X2,Y2,white,ord(BorderChar));
        end;
     end;
begin
   if MaxAvail < 4*Screen.Width*Screen.Depth then
   begin
      Beep;
      exit;
   end;
   WasOn := Screen.WindowOff;
   OriginalScreen.Init;
   MVisible := Mouse.Visible;
   if MVisible then
      Mouse.Hide;
   OriginalScreen.Save;
   BackScreen.Init;
   BuildBackground(BackScreen);
   if vSmartStretch then
      with OriginalScreen do
         move(Backscreen.vScreenPtr^,vScreenPtr^,Depth*Width*2);
   if vUnderneathPtr <> Nil then
   begin
       FreeMem(vUnderneathPtr,vSavedSize);
       vUnderneathPtr := Nil;
   end;
   OldWin := vOldWin;                    {1.00c}
   OldWinConfine := vOldWinConfine;
   with vBorder do
   begin
      Screen.Box(X1,Y1,X2,Y2,col,ord(BorderChar));
      OldX := X2;
      OldY := Y2;
   end;
   RemoveShadow(OriginalScreen);
   with Screen do
   begin
      CursSave;
      CX := Screen.WhereX;
      CY := Screen.WhereY;
      CTop := vCursTop;
      CBot := vCursBot;
      CursOff;
   end;
   Repeat
      if UsingMouse then
      begin
         Mouse.Show;
         Mouse.Status(Left,Center,Right,X,Y);
      end
      else
      begin
         with Key do
         begin
            OldX := vBorder.X2;
            OldY := vBorder.Y2;
            Y := OldY;
            X := OldX;
            GetInput;
            Case Key.LastKey of
               328: dec(Y); {up}
               336: inc(Y); {down}
               333: inc(X); {right}
               331: dec(X); {left}
            end; {case}
         end;
         Left := true;
      end;
      if Left and ( (X <> OldX) or (Y <> OldY) ) then  {stretch window}
      begin
         if (succ(X - vBorder.X1 ) < vMinWidth) then  {too small}
            NewX := pred(vBorder.X1 + vMinWidth)
         else
         if (X > vBoundary.X2) then                 {out of bounds}
            NewX := vBoundary.X2
         else
            NewX := X;
         if (succ(Y - vBorder.Y1 ) < vMinDepth) then  {too small}
            NewY := pred(vBorder.Y1 + vMinDepth)
         else
         if (Y > vBoundary.Y2) then                 {out of bounds}
            NewY := vBoundary.Y2
         else
            NewY := Y;
         ChangePerimeter;
         if vSmartStretch then
            StretchRefresh;
         OldX := NewX;
         OldY := NewY;
      end; {if}
   until (UsingMouse and (Left = false)) or (((Key.LastKey =13) or (Key.LastKey = 27)) and (UsingMouse = false));
   ComputeSavedCoords;
   { draw the new image }
   BackScreen.Display;
   OriginalScreen.Done;
   BackScreen.Done;
   vZoomed := (vBorder.X1 = vBoundary.X1)
               and (vBorder.Y1 = vBoundary.Y1)
               and (vBorder.X2 = vBoundary.X2)
               and (vBorder.Y2 = vBoundary.Y2);
   SetWindow;
   Draw;
   vOldWin := OldWin;                      {1.00c}
   vOldWinConfine := OldWinConfine;
   Screen.GotoXY(CX,CY);
   Screen.CursSize(CTop,CBot);
   if MVisible then
      Mouse.Show;
end; {StretchWinOBJ.Stretch}

procedure StretchWinOBJ.Winkey(var K:word;var X,Y:byte);
{}
begin
   if (K = vStretchKey) and vAllowStretch then
   begin
      Stretch(false,X,Y);
      K := 602;
   end
   else if (K = 513) and (X = vBorder.X2) and (Y = vBorder.Y2) and vAllowStretch then
   begin
      Stretch(true,X,Y);
      K := 602;
   end
   else if (((K = 513) and (X = vBorder.X2 - 3) and (Y = vBorder.Y1))
        or (K = vZoomKey)) and vAllowStretch then
   begin
      ToggleZoom;
      K := 602;
   end
   else
      ScrollWinOBJ.WinKey(K,X,Y);
end; {StretchWinOBJ.Winkey}

procedure StretchWinOBJ.Refresh;
{}
var WasOn: boolean;
begin
   WasOn := Screen.WindowOff;
   ShadowTOT^.DrawShadow(vBorder);
   if vClose then
   begin
      with vBorder do
      begin
         Screen.BoxEngine(X1,Y1,X2,Y2,4,4,vBorderAttr,vTitleAttr,vBodyAttr,vStyle,true,vTitle);
         Screen.WriteAT(X1+2,Y1,vBorderAttr,'[ ]');
         Screen.WriteAT(X1+3,Y1,vIconsAttr,'þ');
      end;
   end
   else
      with vBorder do
         Screen.BoxEngine(X1,Y1,X2,Y2,0,4,vBorderAttr,vTitleAttr,vBodyAttr,vStyle,true,vTitle);
   if vAllowStretch then
   begin
      Screen.WriteAT(vBorder.X2-4,vBorder.Y1,vBorderAttr,'[ ]');
      if not vZoomed then
         Screen.WriteAT(vBorder.X2-3,vBorder.Y1,vIconsAttr,'')
      else
         Screen.WriteAT(vBorder.X2-3,vBorder.Y1,vIconsAttr,'');
   end;
   SetWindow;
end; {StretchWinOBJ.Refresh}

procedure StretchWinOBJ.Draw;
{}
begin
   if not (vStyle in [1..5]) then
      vStyle := 1;
   Save;
   vMVisible := Mouse.Visible;
   Refresh;
   if not vMVisible then
      Mouse.Show;
end; {StretchWinOBJ.Draw}

destructor StretchWinOBJ.Done;
{}
begin
   ScrollWinOBJ.Done;
end; {StretchWinOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure WinInit;
{initilizes objects and global variables}
begin
end;

{end of unit - add intialization routines below}
{$IFNDEF OVERLAY}
begin
   WinInit;
{$ENDIF}
end.
