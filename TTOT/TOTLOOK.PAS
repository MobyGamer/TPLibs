{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totLOOK;
{$I TOTFLAGS.INC}

{
 Development Notes:

}

INTERFACE

USES CRT, totSYS;

Type

pLookOBJ = ^LookOBJ;
LookOBJ = object
   vWinBorder: byte;
   vWinBody: byte;
   vWinTitle: byte;
   vWinIcons: byte;
   vWinMoveKey: word;
   vWinStretchKey: word;
   vWinZoomKey: word;
   vMenuBorder: byte;
   vMenuTitle: byte;
   vMenuIcon: byte; 
   vMenuHiHot: byte;                                               
   vMenuHiNorm: byte;
   vMenuLoHot: byte; 
   vMenuLoNorm: byte;
   vMenuInActive: byte;
   vListEndKey: word;
   vListEscKey: word;
   vListToggleKey: word;
   vListTagKey: word;
   vListUntagKey: word;
   vListLeftChar: char;
   vListRightChar: char;
   vListToggleOnChar: char;
   vListToggleOffChar: char;
   {methods...}
   constructor Init;
   procedure SetWindow(Border,Body,Icons,Title:byte);
   procedure SetWinKeys(Move,Stretch,Zoom:word);
   procedure SetListKeys(Endkey,Esc,Toggle,Tag,UnTag:word);
   procedure SetListChars(LeftChar,RightChar,ToggleOnChar,ToggleOffChar: char);
   procedure SetMenu(Bor,Tit,Icon,HiHot,HiNorm,LoHot,LoNorm,Off:byte);
   procedure SetDefaults;
   function  WinBorder: byte;
   function  WinBody: byte;
   function  WinTitle: byte;
   function  WinIcons: byte;
   function  WinMoveKey: word;
   function  WinStretchKey: word;
   function  WinZoomKey: word;
   function  ListEndKey: word;
   function  ListEscKey: word;
   function  ListToggleKey: word;
   function  ListTagKey: word;
   function  ListUnTagKey: word;
   function  ListLeftChar: char;
   function  ListRightChar: char;
   function  ListToggleOnChar: char;
   function  ListToggleOffChar: char;
   function  MenuBor: byte;
   function  MenuTit: byte;
   function  MenuIcon: byte;
   function  MenuHiHot: byte;
   function  MenuHiNorm: byte;
   function  MenuLoHot: byte;
   function  MenuLoNorm: byte;
   function  MenuOff: byte;
   destructor Done;
end; {LookOBJ}

var
  LookTOT:  ^LookOBJ;

procedure DING;
procedure LOOKinit;

IMPLEMENTATION

procedure DING;
begin
   sound(2000);delay(100);nosound;
end; {Ding}
{|||||||||||||||||||||||||||||||||||||||}
{                                       }
{     L o o k O B J   M E T H O D S     }
{                                       }
{|||||||||||||||||||||||||||||||||||||||}
constructor LookOBJ.Init;
{}
begin
   SetDefaults;
end; {LookOBJ.Init}

procedure LookOBJ.SetWindow(Border,Body,Icons,Title:byte);
{}
begin
   vWinBorder := Border;
   vWinBody := Body;
   vWinIcons := Icons; 
   vWinTitle := Title; 
end; {LookOBJ.SetWarning}

procedure LookOBJ.SetWinKeys(Move,Stretch,Zoom:word);
{}
begin
   vWinMoveKey   := Move;
   vWinStretchKey:= Stretch;
   vWinZoomKey   := Zoom;
end; {LookOBJ.SetWinKeys}

procedure LookOBJ.SetListKeys(Endkey,Esc,Toggle,Tag,UnTag:word);
{}
begin
   vListEndKey   := Endkey;
   vListEscKey   := Esc;
   vListToggleKey:= Toggle;
   vListTagKey   := Tag;
   vListUnTagKey := UnTag;
end; {LookOBJ.SetListKeys}

procedure LookOBJ.SetListChars(LeftChar,RightChar,ToggleOnChar, ToggleOffChar: char);
{}
begin
   vListLeftChar   := LeftChar;
   vListRightChar  := RightChar;
   vListToggleOnChar := ToggleOnChar;
   vListToggleOffChar := ToggleOffChar;
end; {LookOBJ.SetListChars}

procedure LookOBJ.SetMenu(Bor,Tit,Icon,HiHot,HiNorm,LoHot,LoNorm,Off:byte);
{}
begin
   vMenuBorder := Bor;
   vMenuTitle := Tit; 
   vMenuIcon := Icon;
   vMenuHiHot := HiHot;
   vMenuHiNorm := HiNorm;
   vMenuLoHot := LoHot;
   vMenuLoNorm :=  LoNorm;
   vMenuInActive := Off;
end; {of proc LookOBJ.SetMenu}

procedure LookOBJ.SetDefaults;
{}
begin
   if Monitor^.ColorOn then {color System}
   begin
      vWinBorder := 76;       {lightred on red}
      vWinBody := 79;         {white on red}
      vWinIcons := 67;        {lightcyan on red}
      vWinTitle := 78;        {yellow on red}
      vMenuBorder := 23;      {lightgray on blue}
      vMenuTitle := 30;       {yellow on blue}
      vMenuIcon := 27;        {lightcyan on blue}
      vMenuHiHot := 78;       {yellow on red}
      vMenuHiNorm := 79;      {white on red}
      vMenuLoHot := 30;       {yellow on blue}
      vMenuLoNorm := 31;      {white on blue}
      vMenuInActive := 23;    {lightgray on blue}
      SetListChars(#0,#0,chr(251),' ');
   end
   else                    {monochrome}
   begin
      vWinBorder := 112;      {black on lightgray}
      vWinBody := 112;
      vWinIcons := 112;
      vWinTitle := 112;
      vMenuBorder := 112;
      vMenuTitle := 112;
      vMenuIcon := 112;
      vMenuHiHot := 7;        {lightgray on black}
      vMenuHiNorm := 15;      {white on black}
      vMenuLoHot := 15;       {white on black}
      vMenuLoNorm := 112;     {black on lightgray}
      vMenuInActive := 8;     {darkgray on black}
      SetListChars(Chr(16),chr(17),chr(251),' ');
   end;
   vWinMoveKey   := 354;      {Ctrl-F5}
   vWinStretchKey:= 364;      {Alt-F5}
   vWinZoomKey   := 319;      {F5}
   vListEndKey   := 324;      {F10}
   vListEscKey   := 27;       {Esc}
   vListToggleKey:= 32;       {space bar}
   vListTagKey   := 276;      {Alt-T}
   vListUnTagKey := 278;      {Alt-U}
end; {LookOBJ.SetDefaults}

function LookOBJ.WinBorder: byte;
{}
begin
   WinBorder := vWinBorder;
end; {of func LookOBJ.WinBorder}

function LookOBJ.WinBody: byte;
{}
begin
   WinBody := vWinBody;
end; {of func LookOBJ.WinBody}

function LookOBJ.WinIcons: byte;
{}
begin
   WinIcons := vWinIcons;
end; {of func LookOBJ.WinIcons}

function LookOBJ.WinTitle: byte;
{}
begin
   WinTitle := vWinTitle;
end; {LookOBJ.WinTitle}

function LookOBJ.WinMoveKey: word;
{}
begin
   WinMoveKey := vWinMoveKey;
end; {LookOBJ.WinMoveKey}

function LookOBJ.WinStretchKey: word;
{}
begin
   WinStretchKey := vWinStretchKey;
end; {LookOBJ.WinStretchKey}

function LookOBJ.WinZoomKey: word;
{}
begin
   WinZoomKey := vWinZoomKey;
end; {LookOBJ.WinZoomKey}

function LookOBJ.ListEndKey: word;
{}
begin
   ListEndKey := vListEndKey;
end; {LookOBJ.ListEndKey}

function LookOBJ.ListEscKey: word;
{}
begin
   ListEscKey := vListEscKey;
end; {LookOBJ.ListEscKey}

function LookOBJ.ListToggleKey: word;
{}
begin
   ListToggleKey := vListToggleKey;
end; {LookOBJ.ListToggleKey}

function LookOBJ.ListTagKey: word;
{}
begin
   ListTagKey := vListTagKey;
end; {LookOBJ.ListTagKey}

function LookOBJ.ListUnTagKey: word;
{}
begin
   ListUnTagKey := vListUnTagKey;
end; {LookOBJ.ListUnTagKey}

function LookOBJ.ListLeftChar: char;
{}
begin
   ListLeftChar := vListLeftChar;
end; {LookOBJ.ListLeftChar}

function LookOBJ.ListRightChar: char;
{}
begin
   ListRightChar := vListRightChar;
end; {LookOBJ.ListRightChar}

function LookOBJ.ListToggleOnChar: char;
{}
begin
   ListToggleOnChar := vListToggleOnChar;
end; {LookOBJ.ListToggleOnChar}

function LookOBJ.ListToggleOffChar: char;
{}
begin
   ListToggleOffChar := vListToggleOffChar;
end; {LookOBJ.ListToggleOffChar}

function LookOBJ.MenuBor: byte;
{}
begin
   MenuBor := vMenuBorder;
end; {of func LookOBJ.MenuBor}

function LookOBJ.MenuTit: byte;
{}
begin
   MenuTit := vMenuTitle;
end; {of func LookOBJ.MenuTit}

function LookOBJ.MenuIcon: byte;
{}
begin
   MenuIcon := vMenuIcon;
end; {of func LookOBJ.MenuIcon}

function LookOBJ.MenuHiHot: byte;
{}
begin
   MenuHiHot := vMenuHiHot;
end; {of func LookOBJ.MenuHiHot}

function LookOBJ.MenuHiNorm: byte;
{}
begin
   MenuHiNorm := vMenuHiNorm;
end; {of func LookOBJ.MenuHiNorm}

function LookOBJ.MenuLoHot: byte;
{}
begin
   MenuLoHot := vMenuLoHot;
end; {of func LookOBJ.MenuLoHot}

function LookOBJ.MenuLoNorm: byte;
{}
begin
   MenuLoNorm := vMenuLoNorm;
end; {of func LookOBJ.MenuLoNorm}

function LookOBJ.MenuOff: byte;
{}
begin
   MenuOff := vMenuInActive;
end; {of func LookOBJ.MenuOff}

destructor LookOBJ.Done;
begin end;
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure LookInit;
{initilizes objects and global variables}
begin
   new(LookTOT,Init);
end; {procedure LookInit}

{end of unit - add intialization routines below}
{$IFNDEF OVERLAY}
begin
   {$IFDEF INITTRACE}writeln('lookinit');{$ENDIF}
   LookInit;
{$ENDIF}
end.

