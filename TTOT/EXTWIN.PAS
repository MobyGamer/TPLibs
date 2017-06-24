Unit ExtWin;
{Illustrates how you can extend the Toolkit StretchWinOBJ to provide
 a window for displaying virtual screens}

{$I TOTFLAGS.INC}
INTERFACE

uses DOS, CRT, totFAST, totWIN, totINPUT;

TYPE
VirtualWinOBJ = object (StretchWinOBJ)
   vScreen: ScreenPtr;
   vTopLine: integer;
   vFirstChar: integer;
   vScreenWidth: byte;
   vScreenDepth: byte;
   {Methods...}
   constructor Init;
   procedure   SetScreenXY(X,Y:byte);
   procedure   AssignVirtualScreen(var Scr:ScreenOBJ);
   procedure   RefreshWindow;
   procedure   ScrollDown;
   procedure   ScrollUp;
   procedure   ScrollLeft;
   procedure   ScrollRight;
   procedure   ScrollTop;
   procedure   ScrollBottom;
   procedure   ScrollHome;
   procedure   ScrollEnd;
   procedure   ScrollJump(Vert:boolean; X,Y:byte);
   procedure   ScrollPgUp;
   procedure   ScrollPgDn;
   procedure   Go;
   procedure   StretchRefresh;                                 VIRTUAL;
   procedure   Winkey(var K:word;var X,Y:byte);                VIRTUAL;
   procedure   Draw;                                           VIRTUAL;
   destructor  Done;                                           VIRTUAL;
end; {VirtualWinOBJ}

IMPLEMENTATION

constructor VirtualWinOBJ.Init;
{Initializes the window, and sets the ScreanOBJ pointer to nil}
begin
   StretchWinOBJ.Init;
   SetScrollable(true,true);
   vScreen := nil;
   vSmartStretch := true;
end; {VirtualWinOBJ.Init}

procedure VirtualWinOBJ.SetScreenXY(X,Y:byte);
{Sets the upper-left coordinates of the visible part of virtual screen}
begin
   if X <= vScreenWidth then
      vFirstChar := X;
   if Y <= vScreenDepth then
      vTopLine := Y;
end; {VirtualWinOBJ.SetScreenXY}

procedure VirtualWinOBJ.RefreshWindow;
{Grabs the info from the virtual display and shows it in window}
var  WinOff: boolean;
begin
   WinOff := Screen.Windowoff;
   StretchRefresh; 
   if not WinOff then
      Screen.WindowOn;
   {now update the scroll bar elevators}
   DrawHorizBar(vFirstChar,vScreenWidth);
   DrawVertBar(vTopLine,vScreenDepth);
end; {VirtualWinOBJ.RefreshWindow}

procedure VirtualWinOBJ.StretchRefresh;
{This procedure is called by RefreshWindow, as well as
 StretchWinOBJ.Stretch. In both cases, the Window 
 settings are turned off}
var 
  W,D,Z:byte;
  I:integer;
  Pad: string;
begin
    with vBorder do
    begin
       W := pred(X2-X1);
       D := pred(Y2-Y1);
       vScreen^.PartDisplay(vFirstChar,vTopLine,
                            vFirstChar+pred(W),vTopLine+pred(D),
                            succ(X1),succ(Y1));
       if succ(vScreenWidth-vFirstChar) < W then
       begin
          Pad := replicate(W - pred(vScreenWidth-vFirstChar)-1,' ');
          Z :=  succ(X1) + vScreenWidth-vFirstChar;
          for I := succ(Y1) to pred(Y2) do
              Screen.WriteAt(Z,I,vBodyAttr,Pad);
       end;
       if succ(vScreenDepth-vTopLine) < D then
       begin
          Pad := replicate(pred(X2-X1),' ');
          Z :=  Y1 + vScreenDepth-vTopLine+2;
          for I := Z to pred(Y2) do
              Screen.WriteAt(succ(X1),I,vBodyAttr,Pad);
       end;
    end;
end; {VirtualWinOBJ.StretchRefresh}

procedure VirtualWinOBJ.AssignVirtualScreen(var Scr:ScreenOBJ);
{Updates vScreen to point to the user specified ScreenOBJ instance, 
 and sets the intital display position to topleft.}
begin
   vScreen := @Scr;
   vTopLine := 1;
   vFirstChar := 1;
   vScreenWidth := vScreen^.Width;
   vScreenDepth := vScreen^.Depth;
end; {VirtualWinOBJ.AssignVirtualScreen}

procedure VirtualWinOBJ.ScrollDown;
{}
begin
   if vTopLine < vScreenDepth then
   begin
      inc(vTopLine);
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollDown}

procedure VirtualWinOBJ.ScrollUp;
{}
begin
   if vTopLine > 1 then
   begin
      dec(vTopLine);
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollUp}

procedure VirtualWinOBJ.ScrollLeft;
{}
begin
   if vFirstChar > 1 then
   begin
      dec(vFirstChar);
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollLeft}

procedure VirtualWinOBJ.ScrollRight;
{}
begin
   if vFirstChar  < vScreenWidth then
   begin
      inc(vFirstChar);
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollRight}

procedure VirtualWinOBJ.ScrollTop;
{}
begin
   if vTopLine <> 1 then
   begin
      vTopLine := 1;
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollTop}

procedure VirtualWinOBJ.ScrollBottom;
{}
begin
   if vTopLine + vBorder.Y2 - vBorder.Y1 - 2 < vScreenDepth then
   begin
      vTopLine := vScreenDepth - (vBorder.Y2 - vBorder.Y1 - 2);
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollBottom}

procedure VirtualWinOBJ.ScrollHome;
{}
begin
   if vFirstChar > 1 then
   begin
      vFirstChar := 1;
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollHome}

procedure VirtualWinOBJ.ScrollEnd;
{}
begin
   if vFirstChar + vBorder.X2 - vBorder.X1 - 2 < vScreenWidth then
   begin
      vFirstChar := vScreenWidth - (vBorder.X2 - vBorder.X1 - 2);
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollEnd;}

procedure VirtualWinOBJ.ScrollJump(Vert:boolean; X,Y:byte);
{}
var I:integer;
begin
   if Vert then
   begin
      if X = 1 then
         ScrollTop
      else   
      begin
         I := (X * vScreenDepth);
         vTopLine :=  I div Y;
         RefreshWindow;
      end;
   end
   else
   begin
      if X = 1 then
         ScrollHome
      else   
      begin
         I := (X * vScreenWidth);
         vFirstChar :=  I div Y;
         RefreshWindow;
      end;
   end;   
end; {VirtualWinOBJ.Scroll}

procedure VirtualWinOBJ.ScrollPgUp;
{}
begin
   if vTopLine > 1 then
   begin
      vTopLine := vTopLine - pred(vBorder.Y2-vBorder.Y1);
      if vTopLine < 1 then
         vTopLine := 1;
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollPgUp}

procedure VirtualWinOBJ.ScrollPgDn;
{}
begin
   if vTopLine < vScreenDepth then
   begin
      vTopLine := vTopLine + pred(vBorder.Y2-vBorder.Y1);
      if vTopLine > vScreenDepth then
         vTopLine := vScreenDepth;
      RefreshWindow;
   end;
end; {VirtualWinOBJ.ScrollPgDn}

procedure VirtualWinOBJ.Winkey(var K:word;var X,Y:byte);
{process keystroke and updates window}
begin
   StretchWinOBJ.WinKey(K,X,Y);   {pass key to StretcWinOBJ for stretch and move}
   case K of
      602:RefreshWindow;          {resized}
      328,610: ScrollUp;          {scroll up}
      336,611: ScrollDown;        {scroll down}
      331,612: ScrollLeft;        {scroll left}
      333,613: ScrollRight;       {scroll right}
      614: ScrollJump(true,X,Y);  {vertical jump}
      615: ScrollJump(false,X,Y); {horizontal jump}
      388: ScrollTop;             {Ctrl-PgUp}
      374: ScrollBottom;          {Ctrl-PgDn}
      335: ScrollEnd;             {End}
      327: ScrollHome;            {Home}
      329: ScrollPgUp;            {PgUp}
      337: ScrollPgDn;            {PgDn}
   end; {case}
end; {VirtualWinOBJ.Winkey}

procedure VirtualWinOBJ.Draw;
{Draws the window and the contents.}
begin
   if vUnderneathPtr = nil then
      StretchWinOBJ.Draw;
   RefreshWindow;
end; {VirtualWinOBJ.Draw}

procedure VirtualWinOBJ.Go;
{Keeps getting user input until users escapes or closes window.}
var
   K: word;
   X,Y: byte;
begin
   Draw;
   Screen.CursOff;
   repeat
      with Key do
      begin
         K := GetKey;
         X := LastX;
         Y := LastY;
      end;
      WinKey(K,X,Y);
   until (K = 27) or (K = 600);
end; {VirtualWinOBJ.Go}

destructor VirtualWinOBJ.Done;
{}
begin
   StretchWinOBJ.Done
end; {VirtualWinOBJ.Done}

end.