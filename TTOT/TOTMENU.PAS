{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10b                            }

Unit totMENU;
{$I TOTFLAGS.INC}

{
 Development Notes:
          Mar 10, 1991  1.00a   Enabled immediate selection
                                when no sub menu.
          Apr  4, 1991  1.00b   Modified EZPULL.Done
          Apr 22, 1991  1.00c   corrected '=' topic
          Apr 26, 1991  1.00d   corrected message clearing
          May  3, 1991  1.00e              ""
          May  7, 1991  1.00f   allowed setting of sub-menus XY
          May 23, 1991  1.00g   Added reaction to Mouse method 1
          Jun 24, 1991  1.00h   Cleared Lotus menu when sub called
          Jul 24, 1991  1.00i   Hide non-selectable items from mouse clicks
          Jan 23, 1992  1.00j   Checked active status in hotkey selection
          Oct  2, 1992  1.00k   Corrected menu clearing in LotusMenuOBJ
          Jan  4, 1993  1.10    Corrected Range Check error on Pullmenus
          May  3, 1993  1.10a   Restored menu message when sub-sub removed
          May  9, 1993  1.10b   Allowed for an empty drop-down.
                                Thanks to Arnold Gordijn!
}

INTERFACE

uses DOS, CRT,
     totLOOK, totSYS, totINPUT, totFAST, totWIN, totSTR, totIO1, totLINK;

CONST
   EscapeID = 65535;
   LeftID   = 65534;
   RightID  = 65533;
   DriftID  = 65532;

TYPE
BaseMenuPtr = ^BaseMenuOBJ;         
MenuItemPtr = ^MenuItem;
MenuItem = record
   NextNode: MenuItemPtr;
   TxtPtr: pointer;
   MsgPtr: pointer;
   HK: word;
   ID: word;
   Active: boolean;
   SubMenu:  BaseMenuPtr;
end;

pBaseMenuOBJ = ^BaseMenuOBJ;
BaseMenuOBJ = object
   vItemStack: MenuItemPtr;
   vTotalItems: byte;
   vActiveItem: byte;
   vGap: byte;
   vMsgX: byte;
   vMsgY: byte;
   vX: byte;
   vY: byte;
   vWidth: byte;
   vLastKey: word;
   vAllowEsc: boolean;
   vUsedInPull: boolean;
   vPickOff: boolean;
   vSubActive: boolean;
   vMenuHiHot: byte;
   vMenuHiNorm: byte;
   vMenuLoHot: byte;
   vMenuLoNorm: byte;
   vMenuOff: byte;
   vHelpHook:  HelpProc;
   vHelpKey: word;
   vMsgVisible: boolean;
   {methods...}
   constructor Init;
   procedure   AddFullItem(Txt:StrVisible; ID,HK:word; Msg:StrVisible; SubM:BaseMenuPtr);
   procedure   AddItem(Txt:StrVisible);
   procedure   SetTopic(Item:byte; Txt:StrVisible);
   procedure   SetHK(Item:byte; HK:word);
   procedure   SetMessage(Item:byte; Msg:StrVisible);
   procedure   SetID(Item:byte; ID:word);
   procedure   SetStatus(Item:byte; On:boolean);
   procedure   SetSubMenu(Item:byte;SubMenu:BaseMenuPtr);
   procedure   SetGap(G:byte);
   procedure   SetActiveItem(Item:byte);
   procedure   SetMessageXY(X,Y:byte);
   procedure   SetMenuXY(X,Y:byte);
   procedure   SetHelpKey(K:word);
   procedure   SetHelpHook(Proc:HelpProc);
   procedure   SetAllowEsc(On:boolean);
   procedure   SetColors(HiHot,HiNorm,LoHot,LoNorm,Off:byte);
   procedure   TurnPickOff;
   function    GetAllowEsc: boolean;
   function    GetText(Ptr:MenuItemPtr): StrVisible;
   function    GetMessage(Ptr:MenuItemPtr): StrVisible;
   function    GetID(Item:byte):word;
   function    GetActiveItem: byte;
   function    GetTotalItems: byte;
   function    GetPickOff: boolean;
   function    GetSubActive:boolean;
   procedure   DisplayAllItems;
   function    HotkeySelect(K:word): boolean;
   procedure   ChangeActiveItem(New:byte);
   function    FirstActiveItem: byte;
   function    AddPre(Txt:StrVisible;Hi:boolean):StrVisible;
   function    AddSuf(Txt:StrVisible;Hi:boolean):StrVisible;
   function    ItemPtr(Item:byte): MenuItemPtr;
   procedure   DisposeItems;
   procedure   ChangeMessage(Item:byte; Hi:boolean);
   function    LastKey: word;
   function    GetHelpID: word;
   function    ProcessKey(K:word; X,Y:byte):word;                VIRTUAL;
   function    MenuZone(X,Y:byte):boolean;                       VIRTUAL;
   procedure   SetForPull;                                       VIRTUAL;
   function    TargetPick(X,Y:byte): byte;                       VIRTUAL;
   procedure   DisplayItem(Item:byte;Hi,Msg:boolean);            VIRTUAL;
   procedure   Remove;                                           VIRTUAL;
   function    Activate: word;                                   VIRTUAL;
   procedure   DrawEngine(eX,eY:byte);                           VIRTUAL;
   procedure   HelpTask(ID:word);                                VIRTUAL;
   destructor  Done;                                             VIRTUAL;
   end; {BaseMenuOBJ}

pWinMenuOBJ = ^WinMenuOBJ;
WinMenuOBJ = object (BaseMenuOBJ)
   vStyle: byte;
   vWinSaved: boolean;
   vMenuBorder: byte;
   vMenuTitle: byte;
   vMenuIcons: byte;
   {methods...}
   constructor Init;
   procedure   SetStyleTitle(St:byte;Tit:StrVisible);
   procedure   Draw;
   procedure   MoveUp;
   procedure   MoveDown;
   procedure   MoveHome;
   procedure   MoveEnd;
   function    MousePressed(X,Y:byte):boolean;
   function    ProcessKey(K:word; X,Y:byte):word;                VIRTUAL;
   function    MenuZone(X,Y:byte):boolean;                       VIRTUAL;
   procedure   SetForPull;                                       VIRTUAL;
   function    TargetPick(X,Y:byte): byte;                       VIRTUAL;
   procedure   DisplayItem(Item:byte;Hi,Msg:boolean);            VIRTUAL;
   procedure   Remove;                                           VIRTUAL;
   function    Activate: word;                                   VIRTUAL;
   procedure   DrawEngine(eX,eY:byte);                           VIRTUAL;
   function    Win: WinPtr;                                      VIRTUAL;
   destructor  Done;                                             VIRTUAL;
end; {WinMenuOBJ}

SubMenuPtr = ^MenuOBJ;
pMenuOBJ = ^MenuOBJ;
MenuOBJ = object (WinMenuOBJ)
   vWin: WinPtr;
   {methods...}
   constructor Init;
   function    Win: WinPtr;                                      VIRTUAL;
   destructor  Done;                                             VIRTUAL;
end; {MenuOBJ}

pMoveMenuOBJ = ^MoveMenuOBJ;
MoveMenuOBJ = object (WinMenuOBJ)
   vWin: MoveWinPtr;
   {methods...}
   constructor Init;
   function    Win: WinPtr;                                      VIRTUAL;
   destructor  Done;                                             VIRTUAL;
end; {MoveMenuOBJ}

pBarMenuOBJ = ^BarMenuOBJ;
BarMenuOBJ = object (BaseMenuOBJ)
   {methods...}
   constructor Init;
   function    GetX(Item:byte): byte;
   procedure   DisplayItem(Item:byte;Hi,Msg:boolean);            VIRTUAL;
   procedure   DrawEngine(eX,eY:byte);                           VIRTUAL;
   destructor  Done;                                             VIRTUAL;
end; {BarMenuOBJ}

BarHotKeyPtr = ^BarHotKeyItem;
BarHotKeyItem = record
   HK:word;
   ID:word;
   NextNode: BarHotKeyPtr;
end; {BarHotKeyRecord}

pLotusMenuOBJ = ^LotusMenuOBJ;
LotusMenuOBJ = object (BarMenuOBJ)
   vHKStack: BarHotKeyPtr;
   vMenuBarVisible: boolean;
   {methods...}
   constructor Init;
   procedure   Draw;
   procedure   MoveLeft;
   procedure   MoveRight;
   procedure   MoveHome;
   procedure   MoveEnd;
   procedure   SetSpecialKey(HK:word;ID:word);
   function    HotKeyID(HK:word):word;
   function    GetHK(Item:byte):word;
   procedure   DisposeSpecialKeys;
   function    AltHKItem(K:word):word;
   function    MenuKey(K:word; X,Y:byte): boolean;
   function    MousePressed(X,Y:byte;var Choice:word):boolean;
   function    Push(K:word; X,Y:byte): word;
   function    ProcessKey(K:word; X,Y:byte):word;                VIRTUAL;
   function    TargetPick(X,Y:byte): byte;                       VIRTUAL;
   procedure   Remove;                                           VIRTUAL;
   function    Activate: word;                                   VIRTUAL;
   destructor  Done;                                             VIRTUAL;
end; {LotusMenuOBJ}

pPullMenuOBJ = ^PullMenuOBJ;
PullMenuOBJ = object (LotusMenuOBJ)
   vMenuDown: boolean;
   {methods...}
   constructor Init;
   procedure   MoveLeft;
   procedure   MoveRight;
   procedure   MoveHome;
   procedure   MoveEnd;
   function    MousePressed(X,Y:byte):boolean;
   function    Push(K:word; X,Y:byte): word;
   function    ProcessKey(K:word; X,Y:byte):word;                VIRTUAL;
   function    Activate: word;                                   VIRTUAL;
   destructor  Done;                                             VIRTUAL;
end; {PullMenuOBJ}

SubMenuListPtr = ^SubMenuList;
SubMenuList = record
   SubMenu: SubMenuPTR;
   NextMenu: SubMenuListPtr;
end;

pEZPullOBJ = ^EZPullOBJ;
EZPullOBJ = object
   vTopBar: pPullMenuOBJ;
   vSubMenuStack: SubMenuListPtr;
   vListAssigned: boolean;
   vTotalSubs: byte;
   {methods...}
   constructor Init;
   function    Activate: word;                                  
   procedure   BuildMenu;
   function    MainMenu:pPullMenuOBJ;
   function    SubMenu(MenuNumber: byte):SubMenuPtr; 
   function    Push(K:word; X,Y:byte): word;
   function    TotalStrings: word;                               VIRTUAL;
   function    GetString(Item: word): string;                    VIRTUAL; 
   destructor  Done;                                             VIRTUAL;
end; {EZPullOBJ}

pEZPullArrayOBJ = ^EZPullArrayOBJ;
EZPullArrayOBJ = object (EZPullOBJ)
   vTotalItems: byte;
   vArrayPtr: pointer;
   vStrLength: byte;
   {methods...}
   constructor Init;
   procedure   AssignList(var StrArray; Total:Longint; StrLength:byte);
   function    TotalStrings: word;                               VIRTUAL;
   function    GetString(Item: word): string;                    VIRTUAL;
   destructor  Done;                                             VIRTUAL;
end; {EZPullArrayOBJ}

pEZPullLinkOBJ = ^EZPullLinkOBJ;
EZPullLinkOBJ = object (EZPullOBJ)
   vLinkList: ^DLLOBJ;
   {methods...}
   constructor Init;
   procedure   AssignList(var LinkList: DLLOBJ);
   function    TotalStrings: word;                               VIRTUAL;
   function    GetString(Item: word): string;                    VIRTUAL;
   destructor  Done;                                             VIRTUAL;
end; {EZPullLinkOBJ}

procedure menuINIT;

IMPLEMENTATION
Const
   EZSeparator:char = '"';
   EZInActive: char = '_';
   EZNewBarItem: char = '\';

procedure Error(Err:byte);
{routine to display error}
const
   Header = 'totMENU error: ';
var
   Msg : string;
begin
   Case Err of
   1: Msg := 'Not enough memory to create menu';
   else  Msg := 'Unknown Error';
   end; {case}
   Writeln(Header,Msg);
   halt;
end; {Error}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     B a s e M e n u O B J   M E T H O D S     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
{$I TOTMENU.INC}
{|||||||||||||||||||||||||||||||||||||||||||||}
{                                             }
{     W i n M e n u O B J   M E T H O D S     }
{                                             }
{|||||||||||||||||||||||||||||||||||||||||||||}
constructor WinMenuOBJ.Init;
{}
begin
   BaseMenuOBJ.Init;
   vWinSaved := false;
   vStyle := 6;
   vGap := 2;
end; {WinMenuOBJ.Init}

procedure WinMenuOBJ.SetStyleTitle(St:byte;Tit:StrVisible);
{}
begin
   vStyle := St;
   Win^.SetTitle(Tit);
end; {WinMenuOBJ.SetStyle}

procedure WinMenuOBJ.SetForPull;
{}
begin
   SetStyleTitle(1,'');
   SetGap(0);
   Win^.SetClose(False);
   vUsedInPull := true;
   vMsgX := 11;
   vMsgY := Monitor^.Depth;
end; {WinMenuOBJ.SetForPull}

function WinMenuOBJ.Win: WinPtr;
{abstract} begin end;

function WinMenuOBJ.MenuZone(X,Y:byte): boolean;
{}
var 
   X1,Y1,X2,Y2,style: byte;
   InZone: boolean;
begin
   if (ItemPtr(vActiveItem) <> nil) and (ItemPtr(vActiveItem)^.SubMenu <> nil) then
      InZone := ItemPtr(vActiveItem)^.SubMenu^.MenuZone(X,Y)
   else
      InZone := false;
   if not InZone then
   begin
      Win^.GetSize(X1,Y1,X2,Y2,Style);
      InZone := vWinsaved and (X >= X1) and (X <= X2) and (Y >= Y1) and (Y <= Y2);
   end;
   MenuZone := InZone;
end; {WinMenuOBJ.MenuZone}

procedure WinMenuOBJ.DisplayItem(Item:byte;Hi,Msg:boolean);
{}
var               
   Hot,Norm: byte;
   Temp: MenuItemPtr;
   Txt: StrVisible;
   WinWasActive: boolean;

   procedure DrawLine(S:byte);
   {}
   const
     Single: string[2] = 'ô';
     Double: string[2] = 'Ƶ';
   var
     X1,Y1,X2,Y2,Style,Att: byte;
     Ends: string[2];
   begin
     Win^.GetSize(X1,Y1,X2,Y2,Style);
     if not (Style in [0,6]) then
     begin
        if S = 1 then
           Ends := Single
        else
           Ends := Double;
        Att := LookTOT^.MenuBor;
        WinWasActive := Screen.WindowOff;
        Y1 := Y1 + Item;
        Screen.WriteAt(X1,Y1,Att,Ends[1]);
        Screen.HorizLine(succ(X1),pred(X2),Y1,Att,S); {1.00c}
        Screen.WriteAt(X2,Y1,Att,Ends[2]);
        Screen.WindowOn;
     end;
   end; {DrawLine}

begin
   Temp := ItemPtr(Item);
   if Temp = nil then
      exit;
   Txt := GetText(Temp);
   if Txt = '-' then
      DrawLine(1)
   else if Txt = '=' then
      DrawLine(2)
   else
   begin 
      if Temp^.Active then
      begin
         if Hi then
         begin
            Hot := vMenuHiHot;
            Norm := vMenuHiNorm;
         end
         else
         begin
            Hot := vMenuLoHot;
            Norm := vMenuLoNorm;
         end;
      end
      else
      begin
         Hot := vMenuoff;
         Norm := vMenuoff;
      end; 
      Txt := AddPre(Txt,Hi);
      if Temp^.Submenu <> nil then
         Txt := Txt + #16;
      Txt := AddSuf(Txt,Hi);
      Screen.WriteHi(succ(vGap),Item,Hot,Norm,Txt);
      if Msg then               {clear or display message}
         ChangeMessage(Item,Hi);
      if Hi then
      begin
         Screen.gotoxy(succ(vGap),Item);
         vPickOff := false;
      end;
   end;
end; {WinMenuOBJ.DisplayItem}

procedure WinMenuOBJ.DrawEngine(eX,eY:byte);
{}
var
  Width,Depth: byte;
  X,Y: byte;
  Temp: MenuItemPtr;
begin
   Temp := ItemPtr(vActiveItem);                 {1.10b}
   if (Temp = nil) or (ItemPtr(vActiveItem)^.Active = false) then
      vActiveItem := FirstActiveItem;
   if not vWinSaved then
   begin
      vWinSaved := true;
      Width := 2*vGap+vWidth+ ord(LookTOT^.ListLeftChar <> #0)
                            + ord(LookTOT^.ListRightChar <> #0)
                            + 2*ord(vStyle<> 0);
      case vStyle of
      0: Depth := vTotalItems;
      6: Depth := vTotalItems + 4;
      else Depth := vTotalItems + 2;
      end; {case}
      if eX = 0 then {center menu}
         X := (Monitor^.Width - Width) div 2
      else if eX + Width > Monitor^.Width then
         X := Monitor^.Width - Width
      else
         X := eX;
      if eY = 0 then {center menu}
         Y := (Monitor^.Depth - Depth) div 2
      else if eY + Depth > Monitor^.Depth then
         Y := Monitor^.Depth - Depth
      else
         Y := eY;
      if (vX <> 0) and (vY <> 0) then            {1.00f}
         Win^.SetSize(vX,vY,pred(vX)+Width,pred(vY)+Depth,vStyle)
      else
         Win^.SetSize(X,Y,pred(X)+Width,pred(Y)+Depth,vStyle);
      Win^.Draw;
      Screen.Clear(vMenuLoNorm,' ');
      DisplayAllItems;
   end
   else if not vUsedInPull then
   begin
      Screen.Clear(vMenuLoNorm,' ');
      DisplayAllItems;
   end;
end; {WinMenuOBJ.DrawEngine}

procedure WinMenuOBJ.Draw;
{}
begin
   DrawEngine(vX,vY);
end; {WinMenuOBJ.Draw}

procedure WinMenuOBJ.Remove;
{}
begin
   if (ItemPtr(vActiveItem) <> nil)
   and (ItemPtr(vActiveItem)^.SubMenu <> nil) then
      ItemPtr(vActiveItem)^.SubMenu^.Remove;
   ChangeMessage(vActiveItem,false);
   vSubActive := false;
   vPickOff := true;
   Win^.Remove;
   vWinSaved := false;
end; {WinMenuOBJ.Remove}

procedure WinMenuOBJ.MoveUp;
{}
var 
  NewItem: byte;
  Txt: StrVisible;
begin
   if (vActiveItem > 0) and (vActiveItem <= vTotalItems) then {1.00b}
   begin
      NewItem := vActiveItem;
      repeat
         dec(NewItem);
         if NewItem = 0 then
            NewItem := vTotalItems;
         Txt := GetText(ItemPtr(NewItem));
      until (NewItem = vActiveItem)
      or    (     (Txt <> '')
              and (Txt <> '=')
              and (Txt <> '-')
              and (ItemPtr(NewItem)^.Active = true) );
      ChangeActiveItem(NewItem);
   end;
end; {WinMenuOBJ.MoveUp}

procedure WinMenuOBJ.MoveDown;
{}
var
  NewItem: byte;
  Txt: StrVisible;
begin
   if (vActiveItem > 0) and (vActiveItem <= vTotalItems) then {1.00b}
   begin
      NewItem := vActiveItem;
      repeat
         inc(NewItem);
         if NewItem > vTotalItems then
            NewItem := 1;
         Txt := GetText(ItemPtr(NewItem));
      until (NewItem = vActiveItem)
      or    (     (Txt <> '')
              and (Txt <> '=')
              and (Txt <> '-')
              and (ItemPtr(NewItem)^.Active = true) );
      ChangeActiveItem(NewItem);
   end;
end; {WinMenuOBJ.MoveDown}

procedure WinMenuOBJ.MoveHome;
{}
var
  NewItem: byte;
  Txt: StrVisible;
begin
   if vActiveItem <> 1 then
   begin
      NewItem := 1;
      Txt := GetText(ItemPtr(NewItem));
      if (ItemPtr(NewItem)^.Active = false) 
      or (Txt = '')
      or (Txt = '=')
      or (Txt = '-') then
      begin
         DisplayItem(vActiveItem,false,true);
         vActiveItem := 1;
         MoveDown;
      end
      else
        ChangeActiveItem(NewItem);
   end;
end; {WinMenuOBJ.MoveHome}

procedure WinMenuOBJ.MoveEnd;
{}
var 
  NewItem: byte;
  Txt: StrVisible;
begin
   if vActiveItem <> vTotalItems then
   begin
      NewItem := vTotalItems;
      Txt := GetText(ItemPtr(NewItem));
      if (ItemPtr(NewItem)^.Active = false) 
      or (Txt = '')
      or (Txt = '=')
      or (Txt = '-') then
      begin
         DisplayItem(vActiveItem,false,true);
         vActiveItem := vTotalItems;
         MoveUp;
      end
      else
         ChangeActiveItem(NewItem);
   end;
end; {WinMenuOBJ.MoveEnd}

function WinMenuOBJ.TargetPick(X,Y:byte): byte;
{}
var 
   X1,Y1,X2,Y2,Style: byte;
   Temp: MenuItemPtr;
   Txt: StrVisible;
begin
   TargetPick := 0;
   Win^.GetSize(X1,Y1,X2,Y2,Style);
   if ((Style=0) and (X in [X1..X2]) and (Y in [Y1..Y2]))
   or ((Style=6) and (X in [succ(X1)..pred(X2)]) and (Y in [Y1+3..pred(Y2)]))
   or ((Style <> 0) and (Style <> 6) and  (X in [succ(X1)..pred(X2)]) and (Y in [succ(Y1)..pred(Y2)]))
   then
   begin
      case Style of 
         0: dec(Y,pred(Y1));
         6: dec(Y,(Y1+2));
         else dec(Y,Y1);
      end; {case}
      Temp := ItemPtr(Y);
      if (Temp <> nil) then
      begin
         Txt := GetText(Temp);
         if (Temp^.Active = true) 
         and (Txt <> '')
         and (Txt <> '=')
         and (Txt <> '-') then
             TargetPick := Y;
      end;
   end;
end; {WinMenuOBJ.TargetPick}

function WinMenuOBJ.MousePressed(X,Y:byte):boolean;
{}
var 
   NewItem:byte;
   Left,Center,Right : boolean;
   X1,Y1,X2,Y2,style: byte;
begin
   NewItem := TargetPick(X,Y);
   if NewItem <> 0 then
   begin
      ChangeActiveItem(NewItem);
      Win^.GetSize(X1,Y1,X2,Y2,style);
      repeat
         Mouse.Status(Left,Center,Right,X,Y);
         if Left then
         begin
            if vUsedInPull 
            and ((X < X1) or (X > X2) or (Y < Y1) or (Y > Y2)) then
            begin
               MousePressed := false;
               TurnPickOff;
               exit;
            end;
            NewItem := TargetPick(X,Y);
            if NewItem <> 0 then
               ChangeActiveItem(NewItem);
         end;
      until not Left;
      MousePressed := true;
   end   
   else
      MousePressed := false;
end; {WinMenuOBJ.MousePressed}

function WinMenuOBJ.ProcessKey(K:word; X,Y:byte):word;
{}
var
   EscapeOn: boolean;
   Finished: boolean;
   HotKey: boolean;
   Sub: BaseMenuPtr;
   Choice: word;
   SubX,SubY: byte;
   X1,Y1,X2,Y2,style: byte;
begin
   if ItemPtr(vActiveItem) = nil then
      Sub := nil
   else
      Sub := ItemPtr(vActiveItem)^.SubMenu;
   if (Sub <> nil) and vSubActive then
   begin
      Choice := Sub^.ProcessKey(K,X,Y);
      if (Choice = DriftID) and vUsedInPull then
      begin
         Mouse.Location(X,Y);
         Win^.GetSize(X1,Y1,X2,Y2,style);
         if (X >= X1) and (X <= X2) and (Y >= Y1) and (Y <= Y2) then
            Choice := EscapeID;
      end;
      if (Choice = EscapeID) then
      begin
         Choice := 0;
         Sub^.Remove;
         vSubActive := false;
         ChangeMessage(vActiveItem,true); {1.10a}
      end;
   end
   else
   begin
      Finished := false; {assume not finished}
      HotKey := false;
      Choice := 0;
      if HotKeySelect(K) then
         HotKey := true
      else
      begin
         if K = vHelpKey then
            HelpTask(GetID(vActiveItem))
         else
            case K of
               600,
               27: if vAllowEsc then
                      Finished:= true;
               13: Finished := true;
               513: begin
                  if vUsedInPull then
                  begin
                     Win^.GetSize(X1,Y1,X2,Y2,style);
                     if (X < X1) or (X > X2) or (Y < Y1) or (Y > Y2) then
                     begin
                        Choice := DriftID;
                        TurnPickOff;
                     end
                     else
                        Finished := MousePressed(X,Y);
                  end
                  else
                     Finished := MousePressed(X,Y);
               end;
               328,584: MoveUp; {1.00g}
               336,592: MoveDown;
               327: MoveHome;
               335: MoveEnd;
               331,589: if vUsedinPull then
                       Choice := LeftID;
               333,587: if vUsedinPull then
                       Choice := RightID;
            end; {case}
      end;
      if Hotkey or (((K = 13) or (K=513)) and Finished) then
      begin
         if ItemPtr(vActiveItem) = nil then
            Sub := nil
         else
            Sub := ItemPtr(vActiveItem)^.SubMenu;
         if Sub <> Nil then
         begin
            EscapeOn := Sub^.GetAllowEsc;
            if not EscapeOn then
               Sub^.SetAllowEsc(true);
            SubX := succ(lo(windmin))+Screen.WhereX;
            SubY := succ(system.hi(windmin))+Screen.WhereY;
            if not vUsedInPull then
            begin
               inc(SubX,10);
               inc(SubY,2);
            end;
            ChangeMessage(vActiveItem,false);
            Sub^.DrawEngine(SubX,SubY);
            if vUsedInPull then
               vSubActive := true
            else
            begin
               Choice := Sub^.Activate;
               Sub^.Remove;
            end;
            if not EscapeOn then
               Sub^.SetAllowEsc(false);
         end
         else
         begin
            Choice := GetID(vActiveItem);
            if Choice = 0 then
               Choice := vActiveItem;
         end;
      end
      else if ((K = 27) or (K = 600)) and (Finished) then
         Choice := EscapeID;
   end;
   ProcessKey := Choice;
end; {WinMenuOBJ.ProcessKey}

function WinMenuOBJ.Activate: word;
{}
var
  K: word;
  X,Y: byte;
  Choice: word;
begin
   if not vWinSaved then
      Draw
   else
      ChangeMessage(vActiveItem,true);
   if Monitor^.ColorOn then
      Screen.CursOff;
   repeat
      with Key do
      begin
         GetInput;
         K := LastKey;
         X := LastX;
         Y := LastY;
      end;
      Win^.WinKey(K,X,Y);
      Choice := ProcessKey(K,X,Y);
   until (Choice <> 0);
   if Choice = EscapeID then
      Activate := 0
   else
      Activate := Choice;
   ChangeMessage(vActiveItem,false);
   vLastKey := Key.LastKey;
end; {WinMenuOBJ.Activate}

destructor WinMenuOBJ.Done;
{}
begin
   BaseMenuOBJ.Done;
end; {WinMenuOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||}
{                                       }
{     M e n u O B J   M E T H O D S     }
{                                       }
{|||||||||||||||||||||||||||||||||||||||}
constructor MenuOBJ.Init;
{}
begin
   WinMenuOBJ.Init;
   New(vWin,Init);
   vWin^.SetTitle('Menu');
   with LookTOT^ do
      vWin^.SetColors(MenuBor, MenuloNorm, MenuTit, MenuIcon);
end; {MenuOBJ.Init}

function MenuOBJ.Win: WinPtr;
{}
begin
   Win := vWin;
end; {MenuOBJ.Win}

destructor MenuOBJ.Done;
{}
begin
   WinMenuOBJ.Done;
   Dispose(vWin,Done);
end; {MenuOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     M o v e M e n u O B J   M E T H O D S     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
constructor MoveMenuOBJ.Init;
{}
begin
   WinMenuOBJ.Init;
   New(vWin,Init);
   vWin^.SetTitle('Menu');
   vWin^.SetTitle('Menu');
   with LookTOT^ do
      vWin^.SetColors(MenuBor, MenuloNorm, MenuTit, MenuIcon);
end; {MoveMenuOBJ.Init}

function MoveMenuOBJ.Win: WinPtr;
{}
begin
   Win := vWin;
end; {MoveMenuOBJ.Win}

destructor MoveMenuOBJ.Done;
{}
begin
   WinMenuOBJ.Done;
   Dispose(vWin,Done);
end; {MoveMenuOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||}
{                                             }
{     B a r M e n u O B J   M E T H O D S     }
{                                             }
{|||||||||||||||||||||||||||||||||||||||||||||}
constructor BarMenuOBJ.Init;
{}
begin
   BaseMenuOBJ.Init;
   vX := 1;
   vY := 1;
   vGap := 0;
end; {BarMenuOBJ.Init}

function BarMenuOBJ.GetX(Item:byte): byte;
{}
var 
   I : integer;
   X : byte;
begin
   if Item = 1 then
      GetX := vX
   else
   begin
      X := vX + pred(Item)*vGap;
      for I := 1 to pred(Item) do
         inc(X,length(strip('A',Screen.vHiMarker,GetText(ItemPtr(I)))));
      GetX := X;
   end;
end; {BarMenuOBJ.GetX}

procedure BarMenuOBJ.DisplayItem(Item:byte;Hi,Msg:boolean);
{}
var
   Hot,Norm: byte;
   X: byte;
   Temp: MenuItemPtr;
   Txt: StrVisible;
   WinWasActive: boolean;
begin
   WinWasActive := Screen.WindowOff;
   Temp := ItemPtr(Item);
   if Temp^.Active then
      begin
         if Hi then
         begin
            Hot := vMenuHiHot;
            Norm := vMenuHiNorm;
         end
         else
         begin
            Hot := vMenuLoHot;
            Norm := vMenuLoNorm;
         end;
      end
      else
      begin
         Hot := vMenuoff;
         Norm := vMenuoff;
      end;
   Txt := GetText(Temp);
   Txt := AddPre(Txt,Hi);
   Txt := AddSuf(Txt,Hi);
   X := GetX(Item);
   Screen.WriteHi(X,vY,Hot,Norm,Txt);
   if Msg then               {clear or display message}
      ChangeMessage(Item,Hi);
   if WinWasActive then
      Screen.WindowOn;
   if Hi then
      Screen.gotoxy(X,vY);
end; {BarMenuOBJ.DisplayItem}

procedure BarMenuOBJ.DrawEngine(eX,eY:byte); 
{}
begin
   Screen.SetWinIgnore(true);
   Screen.PartClear(vX,vY,GetX(vTotalItems)+
                          length(strip('A',Screen.vHiMarker,GetText(ItemPtr(vTotalItems)))),
                    vY,LookTOT^.MenuLoNorm,' ');
   Screen.SetWinIgnore(false);
   DisplayAllItems;
end; {BarMenuOBJ.DrawEngine}

destructor BarMenuOBJ.Done;
{}
begin
   BaseMenuOBJ.Done;
end; {BarMenuOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                 }
{     L o t u s M e n u O B J   M E T H O D S     }
{                                                 }
{|||||||||||||||||||||||||||||||||||||||||||||||||}
constructor LotusMenuOBJ.Init;
{}
begin
   BarMenuOBJ.Init;
   vHKStack := nil;
   vMsgX := 1;
   vMsgY := 2;
   vMenuBarVisible := false;
end; {LotusMenuOBJ.Init}

procedure LotusMenuOBJ.Draw;
{}
var I: integer;
begin
   vMenuBarVisible := true;
   Screen.PartClear(vX,vY,GetX(vTotalItems)+
                    length(strip('A',Screen.vHiMarker,GetText(ItemPtr(vTotalItems)))),
                    vY,LookTOT^.MenuLoNorm,' ');
   for I := 1 to vTotalItems do
       DisplayItem(I,false,false);
end; {LotusMenuOBJ.Draw}

procedure LotusMenuOBJ.SetSpecialKey(HK:word;ID:word);
{}
var Temp: BarHotKeyPtr;
begin
   if MemAvail >= sizeof(vHKStack^) then
   begin
      if vHKStack = nil then
      begin
         getmem(vHkStack,sizeof(vHKStack^));
         Temp := vHKStack;
      end
      else
      begin
         Temp := vHKStack;
         while Temp^.NextNode <> nil do
             Temp := Temp^.NextNode;
         getmem(Temp^.NextNode,sizeof(vHKStack^));
         Temp := Temp^.NextNode;
      end;
      Temp^.HK := HK;
      Temp^.ID := ID;
      Temp^.NextNode := nil;
   end;
end; {LotusMenuOBJ.SetSpecialKey}

function LotusMenuOBJ.HotKeyID(HK:word):word;
{}
var Temp: BarHotKeyPtr;
begin
   Temp := vHKStack;
   while (Temp <> nil) and (HK <> Temp^.HK) do
      Temp := Temp^.NextNode;
   if Temp = nil then
      HotKeyID := 0 
   else
      HotKeyID := Temp^.ID;
end; {LotusMenuOBJ.HotKeyID}

function LotusMenuOBJ.GetHK(Item:byte):word;
{}
var Temp: MenuItemPtr;
begin
   Temp := ItemPtr(Item);
   if Temp <> nil then
      GetHK := Temp^.HK
   else
      GetHK := 0;
end; {LotusMenuOBJ.GetHK}

function LotusMenuOBJ.AltHKItem(K:word):word;
{}
var
  I : integer;
begin
   I := 1;
   if (K >= 97) and (K <= 122) then
      dec(K,32);
   while (I <= vTotalItems) and (AltKey(GetHK(I)) <> K) do
     inc(I);
   if (I > vTotalItems) or (ItemPtr(I)^.Active = false) then
      AltHKItem := 0
   else
      AltHKItem := I;
end; {LotusMenuOBJ.AltHKItem}

function LotusMenuOBJ.MenuKey(K:word; X,Y:byte): boolean;
{returns true if the key is recognized by the
 menu as a hotkey}
var Temp: word;
begin
   if (K = 513) and (TargetPick(X,Y) > 0) then
      MenuKey := true
   else
   begin
      Temp := AltHkItem(K);
      if Temp = 0 then
         Temp := HotKeyID(K);
      Menukey := (Temp <> 0);
   end;
end; {LotusMenuOBJ.MenuKey}

procedure LotusMenuOBJ.Remove;                 
{}
begin
   vMenuBarVisible := false;
   Screen.ClearText(vX,vY,Monitor^.Width,vY);
   ChangeMessage(vActiveItem,false);
end; {LotusMenuOBJ.Remove}

procedure LotusMenuOBJ.MoveLeft;
{}
var NewItem: byte;
begin
   NewItem := vActiveItem;
   repeat
      dec(NewItem);
      if NewItem < 1 then
         NewItem := vTotalItems;
   until (ItemPtr(NewItem)^.Active = true)
   or (NewItem = vActiveItem);
   ChangeActiveItem(NewItem);
end; {LotusMenuOBJ.MoveLeft}

procedure LotusMenuOBJ.MoveRight;
{}
var NewItem: byte;
begin
   NewItem := vActiveItem;
   repeat
      inc(NewItem);
      if NewItem > vTotalItems then
         NewItem := 1;
   until (ItemPtr(NewItem)^.Active = true)
   or (NewItem = vActiveItem);
   ChangeActiveItem(NewItem);
end; {LotusMenuOBJ.MoveRight}

procedure LotusMenuOBJ.MoveHome;
{}
var NewItem: byte;
begin
   if vActiveItem <> 1 then
   begin
      NewItem := 1;
      if (ItemPtr(NewItem)^.Active = false) then
      begin
         DisplayItem(vActiveItem,false,true);
         vActiveItem := 1;
         MoveRight;
      end
      else
         ChangeActiveItem(NewItem);
   end;
end; {LotusMenuOBJ.MoveHome}

procedure LotusMenuOBJ.MoveEnd;
{}
var NewItem: byte;
begin
   if vActiveItem <> vTotalItems then
   begin
      NewItem := vTotalItems;
      if (ItemPtr(NewItem)^.Active = false) then
      begin
         DisplayItem(vActiveItem,false,true);
         vActiveItem := vTotalItems;
         MoveLeft;
      end
      else
         ChangeActiveItem(NewItem);
   end;
end; {LotusMenuOBJ.MoveEnd}
                       
function LotusMenuOBJ.TargetPick(X,Y:byte): byte;
{}
var I : integer;
begin
   TargetPick := 0;
   if (Y = vY) and (X >= vX) then {at least on right line}
   begin
      I := 0;
      while I < vTotalItems do
      begin
         inc(I);
         if X <= GetX(I) + length(strip('A',Screen.vHiMarker,GetText(ItemPtr(I)))) then
         begin
            TargetPick := I;
            if ItemPtr(I)^.Active = false then {1.00i}
               TargetPick := 0;
            exit;
         end;   
      end;
   end;
end; {LotusMenuOBJ.TargetPick}

function LotusMenuOBJ.MousePressed(X,Y:byte;var Choice:word):boolean;
{}
var 
  NewItem:byte;
  Left,Center,Right : boolean;
  Cleared: boolean;
begin
   NewItem := TargetPick(X,Y);
   if NewItem <> 0 then
   begin
      ChangeActiveItem(NewItem);
      Cleared := false;
      repeat
         Mouse.Status(Left,Center,Right,X,Y);
         if Left then
         begin
            NewItem := TargetPick(X,Y);
            if NewItem <> 0 then
            begin
               if (NewItem = vActiveItem) and cleared then
                   DisplayItem(vActiveItem,true,true)
               else
                  ChangeActiveItem(NewItem);
               Cleared := false;
            end
            else if not Cleared then
            begin
               DisplayItem(vActiveItem,false,true);
               Cleared := true;
            end;
         end;
      until not Left;
      if TargetPick(X,Y) <> 0 then
         MousePressed := true
      else
      begin
         MousePressed := false;
         Choice := DriftID
      end;
   end   
   else
      MousePressed := false;
end; {LotusMenuOBJ.MousePressed}

function LotusMenuOBJ.ProcessKey(K:word; X,Y:byte):word;
{}
var
   EscapeOn: boolean;
   Finished: boolean;
   HotKey: boolean;
   Sub: BaseMenuPtr;
   Choice: word;
begin
   Finished := false; {assume not finished}
   HotKey := false;
   Choice := AltHKItem(K);
   if Choice = 0 then
   begin
      if HotKeySelect(K) then
         HotKey := true
      else
      begin
         if K = 513 then
            Finished := MousePressed(X,Y,Choice)
         else if K = vHelpKey then
            HelpTask(GetID(vActiveItem))
         else
            case K of
               600,
               27: if vAllowEsc then
                      Finished:= true;
               13: Finished := true;
               331,589: MoveLeft;  {1.00g}
               333,587: MoveRight;
               327: MoveHome;
               335: MoveEnd;
            end; {case}
      end;
      if Hotkey or (((K = 13) or (K=513)) and Finished) then
      begin
         Sub := ItemPtr(vActiveItem)^.SubMenu;
         if Sub <> Nil then
         begin
            EscapeOn := Sub^.GetAllowEsc;
            if not EscapeOn then
               Sub^.SetAllowEsc(true);
            ChangeMessage(vActiveItem,false);
            DisplayItem(vActiveItem,false,true); {1.00k}
            Remove;   {1.00h}
            Sub^.DrawEngine(succ(lo(windmin))+Screen.WhereX,
                            succ(system.hi(windmin))+Screen.WhereY);
            Choice := Sub^.Activate;
            Sub^.Remove;
            if Choice = 0 then
               DrawEngine(0,0);
            if not EscapeOn then
               Sub^.SetAllowEsc(false);
         end
         else
         begin
            Choice := GetID(vActiveItem);
            if Choice = 0 then
               Choice := vActiveItem;
         end;
      end 
      else if ((K = 27) or (K = 600)) and (Finished) then
         Choice := EscapeID;
   end;
   ProcessKey := Choice; 
end; {LotusMenuOBJ.ProcessKey}

function LotusMenuOBJ.Activate: word;         
{}
begin
   Activate := Push(0,0,0);
end; {LotusMenuOBJ.Activate}

function LotusMenuOBJ.Push(K:word; X,Y: byte): word;         
{}
var
  Choice: word;
  FirstIteration,
  MVisible: boolean;
  CX,CY,CT,CB: byte;
begin
   MVisible := Mouse.Visible;
   if Monitor^.ColorOn then
      with Screen do
      begin
         CursSave;
         CX := WhereX;
         CY := WhereY;
         CT := vCursTop;
         CB := vCursBot;
         CursOff;
      end;
   DrawEngine(0,0);
   if not MVisible then
      Mouse.Show;
   FirstIteration := true;
   repeat
      if (FirstIteration = false) or ((K=0) and (X=0) and (Y=0)) then
         with Key do
         begin
            GetInput;
            K := LastKey;
            X := LastX;
            Y := LastY;
         end;
         Choice := ProcessKey(K,X,Y);
      FirstIteration := false;
   until (Choice <> 0);
   if Choice = EscapeID then
      Push := 0
   else
      Push := Choice;
   DisplayItem(vActiveItem,false,true);
   vLastKey := Key.LastKey;
   if not MVisible then
      Mouse.Hide;
   if Monitor^.ColorOn then
      with Screen do
      begin
         GotoXY(CX,CY);
         CursSize(CT,CB);
      end;
end; {LotusMenuOBJ.Push}

procedure LotusMenuOBJ.DisposeSpecialKeys;
{}
var Temp1, Temp2:BarHotKeyPtr;
begin
   if vHKStack <> nil then
   begin
      Temp1 := vHkStack;
      Temp2 := vHkStack;
      while Temp2 <> nil do
      begin
          Temp1 := Temp2;
          Temp2 := Temp2^.NextNode;
          freemem(Temp1,sizeof(Temp1^));
      end; 
      vHKStack := nil;
   end;
end; {LotusMenuOBJ.DisposeSpecialKeys}

destructor LotusMenuOBJ.Done;
{}
begin
   BarMenuOBJ.Done;
   DisposeSpecialKeys;
end; {LotusMenuOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     P u l l M e n u O B J   M E T H O D S     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
constructor PullMenuOBJ.Init;
{}
begin
   LotusMenuOBJ.Init;
   vMenuDown := false;
   vX := 2;
   vY := 1;
   vMsgX := 11;
   vMsgY := Monitor^.Depth;
end; {PullMenuOBJ.Init}

procedure PullMenuOBJ.MoveLeft;
{}
var Sub: BaseMenuPtr;
begin
   Sub := ItemPtr(vActiveItem)^.SubMenu;
   if vMenuDown and (Sub <> nil) then
      Sub^.Remove;
   LotusMenuOBJ.MoveLeft;
end; {PullMenuOBJ.MoveLeft}

procedure PullMenuOBJ.MoveRight;
{}
var Sub: BaseMenuPtr;
begin
   Sub := ItemPtr(vActiveItem)^.SubMenu;
   if vMenuDown and (Sub <> nil) then
      Sub^.Remove;
   LotusMenuOBJ.MoveRight;
end; {PullMenuOBJ.MoveRight}

procedure PullMenuOBJ.MoveHome;
{}
var Sub: BaseMenuPtr;
begin
   Sub := ItemPtr(vActiveItem)^.SubMenu;
   if vMenuDown and (Sub <> nil) then
      Sub^.Remove;
   LotusMenuOBJ.MoveHome;
end; {PullMenuOBJ.MoveHome}

procedure PullMenuOBJ.MoveEnd;
{}
var Sub: BaseMenuPtr;
begin
   Sub := ItemPtr(vActiveItem)^.SubMenu;
   if vMenuDown and (Sub <> nil) then
      Sub^.Remove;
   LotusMenuOBJ.MoveEnd;
end; {PullMenuOBJ.MoveEnd}

function PullMenuOBJ.MousePressed(X,Y:byte):boolean;
{}
var 
  NewItem:byte;
  Sub: BaseMenuPtr;
begin
   NewItem := TargetPick(X,Y);
   if (NewItem <> 0) then
   begin
      Sub := ItemPtr(vActiveItem)^.SubMenu;
      if (NewItem <> vActiveItem) then
      begin
         if vMenuDown and (Sub <> nil) then
               Sub^.Remove;
         ChangeActiveItem(NewItem);
      end
      else if vMenuDown and (Sub <> nil) and (Sub^.GetPickOff = false) then {turn off sub pick}
      begin
           Sub^.TurnPickOff;
           ChangeMessage(vActiveItem,true);
      end;
      MousePressed := true;
   end   
   else
      MousePressed := false;
end; {PullMenuOBJ.MousePressed}

function PullMenuOBJ.ProcessKey(K:word; X,Y:byte):word;
{}
var
   Choice : word;
   Sub: BaseMenuPtr;
   Hotkey, L,C,R,Temp: boolean;
   LastActiveItem : byte;
   Xval,Yval : integer; {1.1}
begin
   Hotkey := false;
   Choice := AltHKItem(K);
   LastActiveItem := vActiveItem;
   {HotKeyHook}
   Sub := ItemPtr(vActiveItem)^.SubMenu;
   if Choice <> 0 then
   begin
      if (Choice <> vActiveItem) then
      begin
         if vMenuDown and (Sub <> nil) then
            Sub^.Remove;
         ChangeActiveItem(Choice);
      end;
      Sub := ItemPtr(vActiveItem)^.SubMenu;
      if Sub <> nil then
      begin
         Choice := 0;
         vMenuDown := true;
         vSubActive := true;
      end
      else
      begin
         Choice := GetID(vActiveItem);
         if Choice = 0 then
            Choice := vActiveItem;
      end;
   end
   else     {no hotkey pressed}
   begin
      if (K = 513) and (TargetPick(X,Y) <> 0) then
      begin
         vMenuDown := true;
         vSubActive := true;
         if not vMsgVisible then
            ChangeMessage(vActiveItem,true);
         Sub := ItemPtr(TargetPick(X,Y))^.SubMenu;   {1.00a}
      end;
      if Sub = nil then
         vSubActive := false
      else if vMenuDown then
         vSubActive := true;
      if (vSubActive) then
      begin
         if (K <> 513) then
         begin
            Choice := Sub^.ProcessKey(K,X,Y);
            if Choice = LeftID then
            begin
               MoveLeft;
               Choice := 0;
            end
            else if choice = RightID then
            begin
               MoveRight;
               Choice := 0;
            end

         end
         else {if (K=513) then }
         begin
            if Sub^.MenuZone(X,Y) then
            begin
               {clear main message}
               ChangeMessage(vActiveItem,false);
               Choice := Sub^.ProcessKey(K,X,Y)
            end
            else
            begin
               Temp := MousePressed(X,Y);
               if not Temp then
               begin
                  Mouse.Status(L,C,R,X,Y);
                  if not L then
                     Choice := EscapeID
                  else
                     ChangeMessage(VActiveItem,true);
               end;
            end;
         end;
      end
      else  {not sub active}
      begin
         if HotKeySelect(K) then
         begin
            HotKey := true;
            Sub := ItemPtr(vActiveItem)^.SubMenu;       {1.00a}
         end
         else
         begin
            case K of
               513: Temp := MousePressed(X,Y);
               331,589: MoveLeft;  {1.00g}
               333,587: MoveRight;
               327: MoveHome;
               335: MoveEnd;
            end; {case}
         end;
         if ((K= 27) and vAllowEsc) then
            Choice := EscapeID
         else if HotKey or (K = 13) or (K=513) then
         begin
            if Sub <> nil then
            begin
               vMenuDown := true;
               ChangeMessage(vActiveItem,false);                      {1.00d}
               Sub^.DrawEngine(pred(Screen.WhereX),succ(Screen.WhereY));
               if K = 13 then
                  vSubActive := true
               else
                  vSubActive := false;
            end
            else
            begin
               Mouse.Status(L,C,R,X,Y);
               if (K = 13) or ((K=513) and (L=false)) or Hotkey then  {1.00a}
               begin
                  Choice := GetID(vActiveItem);
                  if Choice = 0 then
                     Choice := vActiveItem;
               end;
            end;
         end;
      end;
   end;
   Sub := ItemPtr(vActiveItem)^.SubMenu;
   if vMenuDown and (Sub <> nil) then
   begin
      if (LastActiveItem <> vActiveItem) and (K<> 513) and (Hotkey = false) then {1.00e}
         ChangeMessage(vActiveItem,false);
      Yval := succ(Screen.WhereY);
      if (YVal < 0) or (YVal > 255) then
         YVal := 255;
      XVal := pred(Screen.WhereX);
      Sub^.DrawEngine(XVal,YVal);
   end;
   if (K = 513) then
   begin
      Mouse.Status(L,C,R,X,Y);
      if not L then
      begin
         if (Sub <> nil) and (Sub^.GetSubActive = false) then
         begin
            ChangeMessage(vActiveItem,false);
            Sub^.DisplayItem(Sub^.GetActiveItem,true,true);
         end;
      end;
   end;
   ProcessKey := Choice;
end; {PullMenuOBJ.ProcessKey}

function PullMenuOBJ.Activate: word;         
{}
begin
   Activate := Push(0,0,0);
end; {PullMenuOBJ.Activate}

function PullMenuOBJ.Push(K:word; X,Y:byte): word;
{}
var
   Choice: word;
   MVisible: boolean;
   FirstIteration: boolean;
   CX,CY,CT,CB:byte;
begin
   vSubActive := false;
   vMenuDown := false;
   MVisible := Mouse.Visible;
   if Monitor^.ColorOn then
      with Screen do
      begin
         CursSave;
         CX := WhereX;
         CY := WhereY;
         CT := vCursTop;
         CB := vCursBot;
         CursOff;
      end;
   if not vMenuBarVisible then
      DrawEngine(0,0);
   if not MVisible then
      Mouse.Show;
   FirstIteration := true;
   repeat
      if (FirstIteration = false) or ((K=0) and (X=0) and (Y=0)) then
         with Key do
         begin
            GetInput;
            K := LastKey;
            X := LastX;
            Y := LastY;
         end;
      if (K = vHelpKey) and (vMenuDown = false) then
      begin
         HelpTask(GetHelpID);
         Choice := 0;
      end
      else 
      begin
         Choice := HotKeyID(K);
         (*
         Choice := 0;
         *)
         if Choice = 0 then
            Choice := ProcessKey(K,X,Y);
      end;
      FirstIteration := false;
   until (Choice <> 0) and (Choice <> DriftID);
   if Choice = EscapeID then
      Push := 0
   else
      Push := Choice;
   ChangeMessage(vActiveItem,false);
   if vSubActive and (ItemPtr(vActiveItem)^.SubMenu <> nil) then
      ItemPtr(vActiveItem)^.SubMenu^.Remove;
   DisplayItem(vActiveItem,false,false);
   vLastKey := Key.LastKey;
   if not MVisible then
      Mouse.Hide;
   if Monitor^.ColorOn then
      with Screen do
      begin
         GotoXY(CX,CY);
         CursSize(CT,CB);
      end;
end; {PullMenuOBJ.Push}

destructor PullMenuOBJ.Done;
{}
begin
   LotusMenuOBJ.Done;
end; {PullMenuOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     E Z P u l l O B J   M E T H O D S     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
constructor EZPullOBJ.Init;
{}
begin
   new(vTopBar,Init);
   vSubMenuStack := nil;
   vListAssigned := false;
   vTotalSubs := 0;
end; {EZPullOBJ.Init}

function EZPullOBJ.MainMenu:pPullMenuOBJ;
{}
begin
   MainMenu := vTopBar;
end; {EZPullOBJ.MainMenu}

function EZPullOBJ.SubMenu(MenuNumber: byte):SubMenuPtr;
{}
var 
  Temp: SubMenuListPtr;
  I : integer;
begin
   if (MenuNumber < 1) or (MenuNumber > vTotalSubs) then
      Submenu := nil
   else
   begin
      Temp := vSubMenuStack;
      for I := 2 to MenuNumber do
         if Temp <> nil then
            Temp := Temp^.NextMenu;
      SubMenu := Temp^.SubMenu;
   end;
end; {EZPullOBJ.SubMenu}

function EZPullOBJ.Activate: word;       
{}
begin
   if vListAssigned = false then
      Activate := 0
   else
      Activate := MainMenu^.Activate;
end; {EZPullOBJ.Activate}

function EZPullOBJ.Push(K:word; X,Y:byte): word;       
{}
begin
   if vListAssigned = false then
      Push := 0
   else
      Push := MainMenu^.Push(K,X,Y);
end; {EZPullOBJ.Activate}

procedure EZPullOBJ.BuildMenu;
{}
var
   Txt: StrVisible;
   Msg: StrVisible;
   HK: word;
   SpecialHK: word;
   ID: word;
   Active: boolean;
   I: integer;

   procedure ParseItemInfo(Str:String;BakID:word);
   {}
   var 
      P : byte;
      IDStr: StrVisible;
   begin
      Txt := '';
      Msg := '';
      HK := 0;
      SpecialHK := 0;
      Active := true;
      P := pos(EZSeparator,Str);
      if P = 0 then
         Txt := Str
      else
      begin
         Txt := copy(Str,1,pred(p));
         Msg := copy(Str,succ(P),255);
         P := pos(EZSeparator,Msg);
         if P <> 0 then
         begin
            IDStr := copy(Msg,succ(P),255);
            delete(Msg,P,255);
            P := pos(EZSeparator,IDStr);
            if P = 0 then
               ID := StrToInt(IDStr)
            else
            begin
               ID := StrtoInt(copy(IDStr,1,pred(P)));
               SpecialHK := StrtoInt(copy(IDStr,succ(P),255));
            end;
         end
         else
            ID := BakID;
      end;
      if (Txt <> '') and (Txt[1] = EZInActive) then
      begin
         Active := false;
         delete(Txt,1,1);
      end;
      P := pos(Screen.vHiMarker,Txt);
      if P <> 0 then
         HK := ord(upcase(Txt[succ(p)]));
   end; {ParseItemInfo}

   procedure BuildMenuBar;
   {}
   var 
     Str:string;
     I : integer;
   begin
      Str := GetString(1);
      if (Str = '') then
         Str := 'Guess';
      if (Str[1] = EZNewBarItem) then
         delete(Str,1,1);
      ParseItemInfo(Str,1);
      Mainmenu^.AddFullItem(Txt,ID,HK,Msg,nil);
      if SpecialHK <> 0 then
         Mainmenu^.SetSpecialKey(SpecialHK,ID);
      if not Active then
         Mainmenu^.SetStatus(1,false);
      inc(vTotalSubs);  
      for I := 2 to TotalStrings do
      begin
         Str := GetString(I);
         if (Str <> '') and (Str[1] = EZNewBarItem) then
         begin
            delete(Str,1,1);
            ParseItemInfo(Str,I);
            Mainmenu^.AddFullItem(Txt,ID,HK,Msg,nil);
            if SpecialHK <> 0 then
               Mainmenu^.SetSpecialKey(SpecialHK,ID);
            if not Active then
               Mainmenu^.SetStatus(I,false);
            inc(vTotalSubs);  
         end;
      end;
   end; {BuildMenuBar}

   procedure BuildSubMenuList;
   {}
   var 
     I: integer;
     Temp: SubMenuListPtr; 
   begin
      if MemAvail < vTotalSubs*sizeof(SubMenuList) then
         Error(1)
      else
      begin
         getmem(vSubMenuStack,sizeof(vSubMenuStack^));
         vSubMenuStack^.NextMenu := nil;
         vSubMenuStack^.SubMenu := nil;
         Temp := vSubMenuStack;
         for I := 2 to vTotalSubs do
         begin
            getmem(Temp^.NextMenu,sizeof(vSubMenuStack^));
            Temp := Temp^.Nextmenu;
            Temp^.SubMenu := nil;
         end;
         Temp^.NextMenu := nil;
      end;
   end; {BuildSubMenuList}

   procedure CreateSubMenu(SubCounter:byte);
   {}
   var 
      Temp: SubMenuListPtr;
      I : integer;
   begin
      Temp := vSubMenuStack;
      for I := 2 to SubCounter do
          Temp := Temp^.NextMenu;
      new(Temp^.Submenu,Init);
      Temp^.Submenu^.SetForPull;
   end; {CreateSubMenu}

   procedure BuildSubMenus;
   {}
   var 
     Str:string;
     I : integer;
     SubCreated: boolean;
     SubCounter: byte;
     PickCounter : byte;
   begin
      SubCreated := false;
      SubCounter := 1;
      for I := 2 to TotalStrings do
      begin
         Str := GetString(I);
         if (Str <> '') then
         begin
            if (Str[1] = EZNewBarItem) then
            begin
               with SubMenu(SubCounter)^ do
                  SetActiveItem(FirstActiveItem);
               SubCreated := false;
               inc(SubCounter);
            end
            else
            begin
               if not SubCreated then
               begin
                  SubCreated := true;
                  CreateSubMenu(SubCounter);
                  PickCounter := 0;
               end;
               ParseItemInfo(Str,I);
               SubMenu(SubCounter)^.AddFullItem(Txt,ID,HK,Msg,nil);
               inc(PickCounter);
               if SpecialHK <> 0 then
                  Mainmenu^.SetSpecialKey(SpecialHK,ID);
               if not Active then
                  SubMenu(SubCounter)^.SetStatus(PickCounter,false);
            end;
         end;
      end;
   end; {BuildSubMenus}

begin
   BuildMenuBar;
   BuildSubMenuList;
   BuildSubMenus;
   for I := 1 to  vTotalSubs do
      if SubMenu(I) <> nil then
         Mainmenu^.SetSubMenu(I,SubMenu(I));
end; {EZPullOBJ.BuildMenu}

function EZPullOBJ.GetString(Item: word):string;
{abstract}
begin
   GetString := '';
end; {EZPullOBJ.GetString}

function EZPullOBJ.TotalStrings: word;
{abstract} 
begin 
   TotalStrings := 0;
end; {EZPullOBJ.TotalStrings}

destructor EZPullOBJ.Done;       {1.00b}          
{}
var 
  Temp1,Temp2: SubMenuListPtr;
  I: integer;
begin
   Temp1 :=  vSubMenuStack;
   while (Temp1 <> nil) do
   begin
       Temp2 := Temp1^.NextMenu;
       if (Temp1^.SubMenu <> nil) then
       begin
          Dispose(Temp1^.SubMenu,Done);
       end;
       freemem(Temp1,sizeof(Temp1^));
       Temp1 := Temp2;
   end;
   dispose(vTopBar,Done);
end; {EZPullOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                     }
{     E Z P u l l A r r a y O B J   M E T H O D S     }
{                                                     }
{|||||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor EZPullArrayOBJ.Init;
{}
begin
   EZPullOBJ.Init;
end; {EZPullArrayOBJ.Init}

procedure EZPullArrayOBJ.AssignList(var StrArray; Total:Longint; StrLength:byte);
{}
begin
   vArrayPtr := @StrArray;
   vStrLength := StrLength;
   vTotalItems := Total;
   vListAssigned := true;
   BuildMenu;
end; {EZPullArrayOBJ.AssignList}

function EZPullArrayOBJ.TotalStrings: word;                               
{}
begin
   TotalStrings := vTotalItems;
end; {EZPullArrayOBJ.TotalStrings}

function EZPullArrayOBJ.GetString(Item: word): string;                    
{}
var
  W : longint;
  TempStr : String;
  ArrayOffset: word;
begin
   {move array string to Temp}
   W := pred(Item) * succ(vStrLength);
   ArrayOffset := Ofs(vArrayPtr^) + W;
   Move(Mem[Seg(vArrayPtr^):ArrayOffset],TempStr,1);
   Move(Mem[Seg(vArrayPtr^):succ(ArrayOffset)],TempStr[1],ord(TempStr[0]));
   GetString := TempStr;
end; {EZPullArrayOBJ.GetString}

destructor EZPullArrayOBJ.Done;
{}
begin
   EZPullOBJ.Done;
end; {EZPullArrayOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                   }
{     E Z P u l l L i n k O B J   M E T H O D S     }
{                                                   }
{|||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor EZPullLinkOBJ.Init;
{}
begin
   EZPullOBJ.Init;
end; {EZPullLinkOBJ.Init}

procedure EZPullLinkOBJ.AssignList(var LinkList: DLLOBJ);
{}
begin
   vLinkList := @LinkList;
   vListAssigned := true;
   BuildMenu;
end; {EZPullLinkOBJ.AssignList}

function EZPullLinkOBJ.TotalStrings: word;              
{}
begin
   TotalStrings := vLinkList^.TotalNodes;
end; {EZPullLinkOBJ.TotalStrings}

function EZPullLinkOBJ.GetString(Item: word): string;   
{}
var TempPtr : DLLNodePtr;
begin
   TempPtr := vLinkList^.NodePtr(Item);
   if TempPtr <> Nil then
      vLinkList^.ShiftActiveNode(TempPtr,Item);
   GetString := vLinkList^.GetStr(TempPtr,0,255);
end; {EZPullLinkOBJ.GetString}

destructor EZPullLinkOBJ.Done;                            
{}
begin
   EZPullOBJ.Done;
end; {EZPullLinkOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure MenuInit;
{initilizes objects and global variables}
begin
end; {MenuInit}

{end of unit - add intialization routines below}
{$IFNDEF OVERLAY}
begin
  {$IFDEF MEMORYDEBUG} writeln('TOTMENU init sees ',memavail); {$ENDIF}
   MenuInit;
{$ENDIF}
end.


