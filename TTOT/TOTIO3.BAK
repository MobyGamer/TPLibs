{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totIO3;
{$I TOTFLAGS.INC}

{
 Development Notes:
          5/23/91   1.00a    Added reaction to Mouse method 1
          5/29/91   1.00b    Corrected DEL when no chars in list
          7/23/91   1.00c    Corrected DEL when empty lines
          2/06/91   1.00d    Adjusted cursor when list/array assigned
          10/02/92  1.00e    Corrected backspace on empty linked list
}

INTERFACE

uses DOS, CRT,
     totSYS, totLOOK, totFAST, totSTR, totINPUT, totLINK, totIO1;

TYPE

pWordwrapIOOBJ = ^WordwrapIOOBJ;
WordwrapIOOBJ = object(MultiLineIOOBJ)
   vTopLine: integer;         {number of first line in window}
   vTotLines: integer;        {total number of lines}
   vListAssigned: boolean;    {is data assigned}
   vScrollBarOn: boolean;     {is the vertical scrollbar required}
   vBoxBorder: boolean;       {is the data enclosed in a box}
   vCursorX: byte;            {position of cursor in Str}
   vCursorY: byte;            {line no. of cursor - from top}
   vMaxLines: integer;        {limit on total number of lines}
   vLineStr: string;          {copy of line being edited}
   vInsert: boolean;          {is field initially in insert mode}
   vWidth: byte;              {maximum width of an input string}
   vEndKey: word;             {key to jump to next field}
   vAllowEdit: boolean;       {can user change the text}
   {methods ...}
   constructor Init(X1,Y1,width,lines:byte;Title:string);
   procedure   WriteLine(OffSet:integer;Status:tStatus);
   procedure   SetEndKey(K:word);
   procedure   SetAllowEdit(On:boolean);
   procedure   DisplayAllLines(Status:tStatus);
   procedure   RefreshScrollBar(Status:tStatus);
   procedure   MoveCursor;
   procedure   CursorJump(Line:integer);
   procedure   CursorUp;
   procedure   CursorDown;
   procedure   CursorLeft;
   procedure   CursorRight;
   procedure   CursorPgUp;
   procedure   CursorPgDn;
   procedure   CursorHome;
   procedure   CursorEnd;
   procedure   CursorTop;
   procedure   CursorBottom;
   procedure   DeleteChar;
   procedure   Backspace;
   procedure   ProcessEnter;
   function    GetNextLinesLeadingSpaces(var StrOne,StrTwo: string;var LastLine: boolean): byte;
   procedure   GetNextLinesFullWords(var StrOne,StrTwo: string;var LastLine: boolean;Line:integer);
   procedure   PushWordsToNextLine(var StrOne,StrTwo: string;var LastLine: boolean;Line:integer);
   procedure   WrapFrom(Line: integer);
   procedure   AdjustMouseKey(var InKey: word;X,Y:byte);
   procedure   MouseChoose(X,Y:byte);
   procedure   ProcessChar(Ch:char);
   procedure   SetIns(InsOn:boolean);
   procedure   WrapFull;                                    VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;            VIRTUAL;
   function    ProcessKey(InKey:word;X,Y:byte):tAction;     VIRTUAL;
   procedure   Display(Status:tStatus);                     VIRTUAL;
   function    Suspend:boolean;                             VIRTUAL;
   function    GetString(Line:integer): string;             VIRTUAL;
   procedure   SetString(Line:integer;Str: string);         VIRTUAL;
   procedure   DeleteLine(Line:integer);                    VIRTUAL;
   procedure   InsertLine(Line:integer);                    VIRTUAL;
   procedure   InsertAction(InsOn:boolean);                 VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end;

pWWArrayIOOBJ = ^WWArrayIOOBJ;
WWArrayIOOBJ = object (WordwrapIOOBJ)
   vArrayPtr: pointer;
   vStrLength: byte;
   {methods ...}
   constructor Init(X1,Y1,width,lines:byte;Title:string);
   procedure   AssignList(var StrArray; Total:Longint; StrLength:byte);
   function    GetString(Line:integer): string;             VIRTUAL;
   procedure   SetString(Line:integer;Str: string);         VIRTUAL;
   procedure   DeleteLine(Line:integer);                    VIRTUAL;
   procedure   InsertLine(Line:integer);                    VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {WWArrayIOOBJ}

pWWLinkIOOBJ = ^WWLinkIOOBJ;
WWLinkIOOBJ = object (WordwrapIOOBJ)
   vLinkList: ^StrDLLOBJ;
   vWrapping: boolean;
   {methods ...}
   constructor Init(X1,Y1,width,lines:byte;Title:string);
   procedure   AssignList(var LinkList: StrDLLOBJ; Max:integer);
   procedure   WrapFull;                                    VIRTUAL;
   function    GetString(Line:integer): string;             VIRTUAL;
   procedure   SetString(Line:integer;Str: string);         VIRTUAL;
   procedure   DeleteLine(Line:integer);                    VIRTUAL;
   procedure   InsertLine(Line:integer);                    VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {WWLinkIOOBJ}

procedure IO3Init;

IMPLEMENTATION
{||||||||||||||||||||||||||||||||||||||||||||}
{                                            }
{     W W F i e l d O B J   M E T H O D S    }
{                                            }
{||||||||||||||||||||||||||||||||||||||||||||}
constructor WordwrapIOOBJ.Init(X1,Y1,width,lines:byte;Title:string);
{}
begin
   MultiLineIOOBJ.Init(X1,Y1,width,lines,Title);
   vTopLine := 1;
   vTotLines := 0;
   vListAssigned := false;
   vScrollBarOn := false;
   vCursorX := 1;
   vCursorY := 1;
   vInsert := IOTOT^.InputIns;
   vEndKey := 324; {F10}
   vAllowEdit := true;
end; {WordwrapIOOBJ.Init}

procedure WordwrapIOOBJ.SetEndKey(K:word);
{}
begin
   vEndKey := K;
end; {WordwrapIOOBJ.SetEndKey}

procedure WordwrapIOOBJ.SetAllowEdit(On:boolean);
{}
begin
   vAllowEdit := On;
end; {WordwrapIOOBJ.SetAllowEdit}

procedure WordwrapIOOBJ.WriteLine(OffSet:integer;Status:tStatus);
{}
var 
  Str : string;
  A: byte;
begin
   if vListAssigned then
   begin
      Str := GetString(pred(vTopLine)+OffSet);
      Case Status of
         HiStatus: A := IOTOT^.FieldCol(2);
         Norm: A := IOTOT^.FieldCol(1);
         else A := IOTOT^.FieldCol(4);
      end; {case}
      Screen.WriteAT(vBorder.X1,vBorder.Y1+pred(Offset),A,
                     padleft(Str,vBorder.X2-vBorder.X1,' '));
   end;
end; {WordwrapIOOBJ.WriteLine}

procedure WordwrapIOOBJ.DisplayAllLines(Status:tStatus);
{}
var I: integer;
begin
   for I := 1 to vRows do
       WriteLine(I,Status);
   if vCursorX > length(vLineStr) then
      CursorEnd
   else
      MoveCursor;
end; {WordwrapIOOBJ.DisplayAllLines}

function WordwrapIOOBJ.Select(K:word; X,Y:byte): tAction;
{}
begin
   vScrollBarOn := (vTotLines > vRows);
   Display(HiStatus);
   WriteMessage;
   MoveCursor;
   Select := none;
end; {WordwrapIOOBJ.Select}

procedure WordwrapIOOBJ.MoveCursor;
{}
begin
   Screen.GotoXY(pred(vBorder.X1+vCursorX),pred(vBorder.Y1+vCursorY));
end; {WordwrapIOOBJ.MoveCursor}

procedure WordwrapIOOBJ.CursorJump(Line:integer);
{}
var
  Tot: integer;
begin
   Tot := vBorder.Y2 - succ(vBorder.Y1);
   Line := Line - vBorder.Y1;
      if vTotLines <= vRows then  {all Lines on display}
      begin
         SetString(pred(vTopLine)+vCursorY,vLineStr);
         vCursorY := (Line * vTotLines) div Tot;
         vLineStr := GetString(pred(vTopLine)+vCursorY);
         CursorHome;
         MoveCursor;
      end
      else
      begin
         SetString(pred(vTopLine)+vCursorY,vLineStr);
         vTopLine := (Line * vTotLines) div Tot;
         vCursorY := 1;
         vCursorX := 1;
         MoveCursor;
         vLineStr := GetString(pred(vTopLine)+vCursorY);
         DisplayAllLines(HiStatus);
      end;
end; {WordwrapIOOBJ.Cursor}

procedure WordwrapIOOBJ.CursorUp;
{}
begin
   if vCursorY = 1 then
   begin
      if vTopLine > 1 then
      begin
         SetString(vTopLine,vLineStr);
         dec(vTopLine);
         vLineStr := GetString(vTopLine);
         DisplayAllLines(HiStatus);
      end;
   end
   else
   begin
      SetString(pred(vTopLine)+vCursorY,vLineStr);
      dec(vCursorY);
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      if vCursorX > length(vLineStr) then
         CursorEnd
      else
         MoveCursor;
   end;
end; {WordwrapIOOBJ.CursorUp}

procedure WordwrapIOOBJ.CursorDown;
{}
begin
   if pred(vTopLine) + vCursorY < vTotLines then
   begin
      if vCursorY < vRows then
      begin
         SetString(pred(vTopLine)+vCursorY,vLineStr);
         inc(vCursorY);
         vLineStr := GetString(pred(vTopLine)+vCursorY);
         if vCursorX > length(vLineStr) then
            CursorEnd
         else
            MoveCursor;
      end
      else
      begin
         SetString(pred(vTopLine)+vCursorY,vLineStr);
         inc(vTopLine);
         vLineStr := GetString(pred(vTopLine)+vCursorY);
         DisplayAllLines(HiStatus);
      end;
   end;
end; {WordwrapIOOBJ.CursorDown}

procedure WordwrapIOOBJ.CursorLeft;
{}
begin
   if vCursorX > 1 then
   begin
      dec(vCursorX);
      MoveCursor;
   end
   else if (vTopLine > 1) or (vCursorY > 1) then
   begin
      CursorUp;
      CursorEnd;
   end;
end; {WordwrapIOOBJ.CursorLeft}

procedure WordwrapIOOBJ.CursorRight;
{}
begin
   if vCursorX <= length(vLineStr) then
   begin
      inc(vCursorX);
      MoveCursor;
   end
   else
   begin
      if pred(vTopLine) + vCursorY < vTotLines then
      begin
         CursorDown;
         CursorHome;
      end;
   end;
end; {WordwrapIOOBJ.CursorRight}

procedure WordwrapIOOBJ.CursorPgUp;
{}
begin
   if vTopLine > 1 then
   begin
      SetString(pred(vTopLine)+vCursorY,vLineStr);
      vTopLine := vTopLine - vRows;
      if vTopLine < 1 then
         vTopLine := 1;
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      DisplayAllLines(HiStatus);
   end
   else if vCursorY <> 1 then
   begin
      SetString(pred(vTopLine)+vCursorY,vLineStr);
      vCursorY := 1;
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      MoveCursor;
   end;
end; {WordwrapIOOBJ.CursorPgUp}

procedure WordwrapIOOBJ.CursorPgDn;
{}
begin
   if pred(vTopLine + vRows) < vTotLines then
   begin
      SetString(pred(vTopLine)+vCursorY,vLineStr);
      vTopLine := vTopLine + vRows;
      vCursorY := 1;
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      DisplayAllLines(HiStatus);
   end
   else if vCursorY + pred(vTopLine) < vTotLines then
   begin
      SetString(pred(vTopLine)+vCursorY,vLineStr);
      vCursorY := vRows;
      if vCursorY + pred(vTopLine) > vTotLines then
         vCursorY := vTotLines - pred(vTopLine);
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      if vCursorX > length(vLineStr) then
         CursorEnd
      else
         MoveCursor;
   end;
end; {WordwrapIOOBJ.CursorPgDn}

procedure WordwrapIOOBJ.CursorHome;
{}
begin
   vCursorX := 1;
   MoveCursor;
end; {WordwrapIOOBJ.CursorHome}

procedure WordwrapIOOBJ.CursorEnd;
{}
begin
   vCursorX := succ(length(vLineStr));
   MoveCursor;
end; {WordwrapIOOBJ.CursorEnd}

procedure WordwrapIOOBJ.CursorTop;
{}
begin
   if (vCursorY <> 1) or (vTopLine <> 1) then
   begin
      SetString(pred(vTopLine)+vCursorY,vLineStr);
      vCursorY := 1;
      vTopLine := 1;
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      DisplayAllLines(HiStatus);
   end;
   CursorHome;
end; {WordwrapIOOBJ.CursorTop}

procedure WordwrapIOOBJ.CursorBottom;
{}
begin
   if vTopLine + pred(vRows) >= vTotLines then
      CursorPgDn
   else
   begin
      SetString(pred(vTopLine)+vCursorY,vLineStr);
      vTopLine := vTotLines - pred(vRows);
      vCursorY := vRows;
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      DisplayAllLines(HiStatus);
   end;
end; {WordwrapIOOBJ.CursorBottom}

procedure WordwrapIOOBJ.InsertAction(InsOn:boolean);
{}
begin
   if InsOn then
      Screen.CursHalf
   else
      Screen.CursOn;
end; {WordwrapIOOBJ.ChangeMode}

procedure WordwrapIOOBJ.SetIns(InsOn:boolean);
{}
begin
   vInsert := InsOn;
end; {WordwrapIOOBJ.SetIns}

procedure WordwrapIOOBJ.DeleteChar;
{}
var I : integer;
begin
  if not (     (vLineStr = '')  {1.00b}
           and (vCursorY = 1)
           and (vTopLine = 1)
         ) then
  begin
     if vLineStr = '' then
     begin
        DeleteLine(pred(vTopLine)+vCursorY);
        vLineStr := GetString(pred(vTopLine)+vCursorY);
        for I := vCursorY to vRows do
           WriteLine(I,HiStatus);
        if vCursorY <> 1 then
        begin
           CursorLeft;
           WrapFrom(Pred(vTopLine) + vCursorY);
        end;
     end
     else
     begin
        delete(vLineStr,vCursorX,1);
        SetString(pred(vTopLine)+vCursorY,vLineStr);
        WrapFrom(Pred(vTopLine) + pred(vCursorY));
     end;
  end;
end; {WordwrapIOOBJ.DeleteChar}

procedure WordwrapIOOBJ.BackSpace;
{}
begin
   if  not (    (vCursorX = 1)
            and (vCursorY = 1)
            and (vTopLine = 1)
           ) then
   begin
      CursorLeft;
      DeleteChar;
   end;
end; {WordwrapIOOBJ.BackSpace}

procedure WordwrapIOOBJ.ProcessEnter;
{splits the line at the cursor, and inserts a blank line}
var
  StrOne, CarryOver: string;
  I : Integer;
begin
  if pred(vTopLine) + vCursorY < pred(vMaxLines) then
  begin
     CarryOver := copy(vLineStr,vCursorX,length(vLineStr)-pred(vCursorX));
     delete(vLineStr,vCursorX,succ(length(vLineStr)-vCursorX));
     SetString(pred(vTopLine)+vCursorY,vLineStr);
     InsertLine(vTopLine+vCursorY);
     if succ(vTopLine + vCursorY) > vTotLines then
        InsertLine(succ(vTopLine+vCursorY));
     if vCursorY + 2 > vRows then
     begin
       if vCursorY = vRows then
          inc(vTopLine,2)
       else
          Inc(vTopLine);
       vCursorY := vRows;
       DisplayAllLines(HiStatus);
     end
     else
     begin
        vCursorY := vCursorY+2;
        for I := 1 to vCursorY do
            WriteLine(I,HiStatus);
     end;
     vCursorX := 1;
     MoveCursor;
     vLineStr := GetString(pred(vTopLine)+vCursorY);
     insert(CarryOver,vLineStr,1);
     WrapFrom(Pred(vTopLine) + vCursorY);
  end;
end; {WordwrapIOOBJ.ProcessEnter}

function WordwrapIOOBJ.GetNextLinesLeadingSpaces(var StrOne,StrTwo: string;
                                              var LastLine: boolean): byte;
var Counter : byte;
begin
   counter := 0;
   while (StrTwo <> '')
     and (StrTwo[1] = ' ')
     and (length(StrOne) < vWidth) do
   begin
       StrOne := StrOne + ' ';
       Delete(StrTwo,1,1);
       LastLine := false;
       inc(Counter);
   end;
   GetNextLinesLeadingSpaces := counter;
end; {WordwrapIOOBJ.GetNextLinesLeadingSpaces}

procedure WordwrapIOOBJ.GetNextLinesFullWords(var StrOne,StrTwo: string;
                                           var LastLine: boolean; Line: integer);
var
  WordSize: byte;
  RoomLeft: integer;
  Finished: boolean;
  BytesMoved: byte;
begin
   Finished := false;
   BytesMoved := 0;
   repeat
      inc(BytesMoved,GetNextLinesLeadingSpaces(StrOne,StrTwo,LastLine));
      RoomLeft := vWidth - length(StrOne);
      if RoomLeft > 0 then
      begin
         WordSize := pos(' ',StrTwo);
         if WordSize = 0 then
            WordSize := length(StrTwo);
         if (WordSize > 0) and (WordSize <= RoomLeft) then
         begin
             StrOne := StrOne + copy(StrTwo,1,WordSize);
             delete(StrTwo,1,WordSize);
             inc(BytesMoved,WordSize);
             if StrTwo = '' then  {shift up the next line}
             begin
                DeleteLine(succ(Line));
                StrTwo := GetString(Succ(Line));
             end;
             if StrTwo = '' then
                LastLine := true
             else
                LastLine := false;
         end
         else
            Finished := true;
      end
      else
         Finished := true;
   until Finished;
   if (BytesMoved > 0) and (succ(Line) = pred(vTopLine) + vCursorY) then {move cursor}
   begin
      if vCursorX > BytesMoved then
         dec(vCursorX,BytesMoved)
      else
      begin
         CursorUp;
         vCursorX := length(StrOne) - pred(BytesMoved);
      end;
      MoveCursor;
   end;
end; {WordwrapIOOBJ.GetNextLinesFullWords}

procedure WordwrapIOOBJ.PushWordsToNextLine(var StrOne,StrTwo: string;
                                         var LastLine: boolean;Line:integer);
{}
var Counter : integer;
begin
   Counter := length(StrOne);
   repeat
      dec(Counter);
   until (Counter = 0) or ((StrOne[Counter] = ' ') and (Counter <= vWidth));
   {check for STRTWO = ''}
   if StrTwo = '' then {insert a new line}
   begin
      InsertLine(succ(Line));
   end;
   if (Counter = 0) and (length(StrOne)>vWidth) then {no spaces so split word}
      Counter := vWidth;
   insert(copy(StrOne,succ(Counter),length(StrOne)-Counter),StrTwo,1);
   delete(StrOne,succ(Counter),length(StrOne)-Counter);
   if length(StrTwo) > vWidth then
      Lastline := false;
end; {WordwrapIOOBJ.PushWordsToNextLine}

procedure WordwrapIOOBJ.WrapFrom(Line:integer);
{}
var
  StrOne,StrTwo: string;
  LastLine: boolean;
  I : integer;
begin
   if Line < 1 then
      Line := 1;
   if Line >= vMaxLines then {nowhere to wrap!}
   begin
      if Line = pred(vTopLine) + vCursorY then
      begin
         if length(vLineStr) > vWidth then
            vLineStr := copy(vLineStr,1,vWidth);
         SetString(vCursorY,vLineStr);
         WriteLine(vCursorY,HiStatus);
      end;
   end
   else
   begin
      if Line = pred(vTopLine) + vCursorY then  {active line}
         StrOne := vLineStr
      else
         StrOne := GetString(Line);
      if succ(Line) =pred(vTopLine) + vCursorY then
         StrTwo := vLineStr
      else
         StrTwo := GetString(succ(Line));
      repeat
         LastLine:= true;
         if length(StrOne) > vWidth then   {line must be truncated}
         begin
            PushWordsToNextLine(StrOne,StrTwo,LastLine,Line);
            SetString(Line,StrOne);
            if not LastLine then
            begin
               Inc(Line);
               StrOne := StrTwo;
               if succ(Line) = pred(vTopLine) + vCursorY then
                  StrTwo := vLineStr
               else
                  StrTwo := GetString(succ(Line));
            end
            else
               SetString(succ(Line),StrTwo);
         end
         else                             {line might be expanded}
         begin
            if StrTwo = '' then
            begin
               Lastline := true;
               SetString(Line,StrOne);
            end
            else
            begin
               LastLine := false;
               if StrOne <> '' then
                  GetNextLinesFullWords(StrOne,StrTwo,LastLine,Line);
              (*
               SetString(Line,StrOne);
               SetString(succ(Line),StrTwo);
               if not LastLine then
               begin
                  Inc(Line);
                  StrOne := StrTwo;
                  StrTwo := GetString(succ(Line));
               end;
               *)
               SetString(Line,StrOne);
               if not LastLine then
               begin
                  Inc(Line);
                  StrOne := StrTwo;
                  StrTwo := GetString(succ(Line));
               end
               else
                  SetString(succ(Line),StrTwo);
            end;
         end;
      Until LastLine;
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      if (vCursorY > 1) and (Line >= vTopLine) then
         WriteLine(pred(vCursorY),HiStatus);
      for I := vCursorY to vRows do
         WriteLine(I,HiStatus)
   end;
end; {WordwrapIOOBJ.WrapFrom}

procedure WordwrapIOOBJ.WrapFull;
{Call this method to word wrap an object before displaying it. This saves
 you the chore of inititally wordwrapping the default text.}
var
  StrOne,StrTwo: string;
  LastLine: boolean;   {no used but must be passed to other methods}
  Line : integer;
begin
   if vListAssigned then
   begin
      Line := 1;
      LastLine := false;
      StrOne := GetString(1);
      StrTwo := GetString(2);
      repeat
          if length(StrOne) > vWidth then
            PushWordsToNextLine(StrOne,StrTwo,LastLine,Line)
          else
             if StrOne <> '' then
                GetNextLinesFullWords(StrOne,StrTwo,LastLine,Line);
          SetString(Line,StrOne);
          Inc(Line);
          if Line <= vMaxLines then
          begin
             StrOne := StrTwo;
             StrTwo := GetString(succ(Line));
          end;
      until Line = vMaxLines;
      SetString(Line,copy(StrOne,1,vWidth));
      vLineStr := GetString(pred(vTopLine)+vCursorY);
   end;
end;  {WordwrapIOOBJ.WrapFull}

procedure WordwrapIOOBJ.ProcessChar(Ch:char);
{}
var
  NewX : byte;
  Finished : boolean;
begin
   if not ((vCursorX > vWidth) and (vCursorY + pred(vTopLine) = vMaxLines)) then
   if vInsert then
   begin
      Insert(Ch,vLineStr,vCursorX);
      if  (Ch = ' ')
      and (pos(' ',vLineStr) = vCursorX)
      and (vCursorY <> 1) then {just entered first space on line}
      begin
         CursorRight;
         Wrapfrom(pred(vTopLine)+pred(vCursorY));
      end
      else
      begin
         if length(vLineStr) > vWidth then
         begin
            WrapFrom(pred(vTopLine)+vCursorY);
            if vCursorX > length(vLineStr) then
            begin
               NewX := vCursorX - pred(length(vLineStr));
               CursorHome;
               CursorDown;
               vCursorX := NewX;
               MoveCursor;
            end
            else
               CursorRight;
         end
         else
         begin
            Screen.WriteAT(vBorder.X1,vBorder.Y1+pred(vCursorY),
                           IOTOT^.FieldCol(2),
                           padleft(vLineStr,vWidth,' '));
            CursorRight;
         end;
      end;
   end
   else  {overtype mode}
   begin
         if vLineStr = '' then
             vLineStr := Ch
         else if (vCursorX <= length(vLineStr)) then
            vLineStr[vCursorX] := Ch
         else
            vLineStr := vLineStr + Ch;
      if  ((Ch = ' ')
           and (pos(' ',vLineStr) = vCursorX)
           and (vCursorY <> 1))
      or (vCursorX > vWidth) then {just entered first space on line}
      begin
         Wrapfrom(pred(vTopLine)+pred(vCursorY));
         if vCursorX > length(vLineStr) then
         begin
            NewX := vCursorX - pred(length(vLineStr));
            CursorHome;
            CursorDown;
            vCursorX := NewX;
            MoveCursor;
         end
         else
            CursorRight;
      end
      else
      begin
         Screen.WriteAT(vBorder.X1,vBorder.Y1+pred(vCursorY),IOTOT^.FieldCol(2),
                        padleft(vLineStr,vBorder.X2-vBorder.X1,' '));
         CursorRight;
      end;
   end;
end;  {WordwrapIOOBJ.ProcessChar}

procedure WordwrapIOOBJ.AdjustMouseKey(var InKey: word;X,Y:byte);
{}
begin
   if (X = vBorder.X2) and (vScrollBarOn) then {probably on scroll bar}
   begin
      if Y = vBorder.Y2 then
         InKey := 611
      else if Y = vBorder.Y1 then
         InKey := 610
      else if (Y > vBorder.Y1) and (Y < vBorder.Y2) then
         Inkey := 614;
   end;
end; {WordwrapIOOBJ.AdjustMouseKey}

procedure WordwrapIOOBJ.MouseChoose(X,Y:byte);
{moves cursor to hit location}
begin
   if (X >= vBorder.X1)
   and (X < vBorder.X2 - ord(not vScrollBarOn))
   and (Y >= vBorder.Y1)
   and (Y <= vBorder.Y2) then
   begin
      vCursorX := X - pred(vBorder.X1);
      SetString(pred(vTopLine)+vCursorY,vLineStr);
      vCursorY := Y - pred(vBorder.Y1);
      vLineStr := GetString(pred(vTopLine)+vCursorY);
      if vCursorX > length(vLineStr) then
         CursorEnd;
      MoveCursor;
   end;
end; {WordwrapIOOBJ.MouseChoose}

function WordwrapIOOBJ.ProcessKey(InKey:word;X,Y:byte): tAction;
{}
begin
   if InKey = 513 then
      AdjustMousekey(Inkey,X,Y);
   case InKey of
      610,328,584: CursorUp;   {1.00a}
      611,336,592: CursorDown;
      513: MouseChoose(X,Y);
      337: CursorPgDn;
      329: CursorPgUp;
      335: CursorEnd;
      327: CursorHome;
      388: CursorTop;     {^PgUp}
      374: CursorBottom;  {^PgDn}
      333,587: CursorRight;
      331,589
      : CursorLeft;
      614: begin          {vertical scroll bar}
              if Y = succ(vBorder.Y1) then
                 CursorTop
              else if Y = pred(vBorder.Y2) then
                 CursorBottom
              else
                 CursorJump(Y); {vertical scroll bar}
           end;
      else if vAllowEdit then
         case InKey of
            8:       BackSpace;
            339:     DeleteChar;
            338: begin
                    vInsert := not vInsert;
                    if  (vCursorX > 1)
                    and (vCursorX > length(vLineStr))
                    and not vInsert then {cannot be past end in overtype mode}
                       CursorLeft;
                    InsertAction(vInsert);
                 end;
            13: ProcessEnter;
            32..255: ProcessChar(chr(InKey));    {characters}
         end; {sub case}
   end; {case}
   vScrollBarOn := (vTotLines > vRows);
   RefreshScrollBar(HiStatus);
   if InKey = vEndKey then
      Processkey := NextField
   else
      ProcessKey := None;
end; {WordwrapIOOBJ.ProcessKey}

procedure WordwrapIOOBJ.RefreshScrollBar(Status:tStatus);
{}
var Col:byte;
begin
   Case Status of
      HiStatus: Col := IOTOT^.FieldCol(2);
      Norm: Col := IOTOT^.FieldCol(1);
      else Col := IOTOT^.FieldCol(4);
   end; {case}
   with vBorder do
   if vScrollBarOn then
      Screen.WriteVScrollBar(X2,Y1,Y2,Col,pred(vTopLine+vCursorY),vTotLines)
   else
      Screen.WriteVert(X2,Y1,Col,replicate(succ(Y2-Y1),' '));
end; {WordwrapIOOBJ.RefreshScrollBar}

procedure WordwrapIOOBJ.Display(Status:tStatus);
{}
var I : integer;
begin
   MultiLineIOOBJ.Display(Status);
   for I := 1 to vRows do
      WriteLine(I,Status);
   RefreshScrollBar(Status);
end; {WordwrapIOOBJ.Display}

function WordwrapIOOBJ.Suspend:boolean;
{}
begin
   vScrollBarOn := false;
   SetString(pred(vTopLine)+vCursorY,vLineStr);
   Suspend := VisibleIOOBJ.Suspend;
end; {WordwrapIOOBJ.Suspend}

function WordwrapIOOBJ.GetString(Line:integer): string;
{abstract}
begin end;

procedure WordwrapIOOBJ.SetString(Line:integer;Str: string);
{abstract}
begin end;

procedure WordwrapIOOBJ.DeleteLine(Line:integer);
{abstract}
begin end;

procedure WordwrapIOOBJ.InsertLine(Line:integer);
{abstract}
begin end;

destructor WordwrapIOOBJ.Done;
{}
begin
   MultiLineIOOBJ.Done;
end; {WordwrapIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||||}
{                                            }
{     W W A r r a y O B J   M E T H O D S    }
{                                            }
{||||||||||||||||||||||||||||||||||||||||||||}
constructor WWArrayIOOBJ.Init(X1,Y1,width,lines:byte;Title:string);
{}
begin
   WordwrapIOOBJ.Init(X1,Y1,width,lines,Title);
end; {WWArrayIOOBJ.Init}

procedure WWArrayIOOBJ.AssignList(var StrArray; Total:Longint; StrLength:byte);
{}
begin
   vArrayPtr := @StrArray;
   vStrLength := StrLength;
   vWidth := StrLength;
   vMaxLines := Total;
   vTotLines := Total;
   vListAssigned := true;
   vLineStr := GetString(1);
   vCursorX := 1;   {1.00d}
   vCursorY := 1;
end; {WWArrayIOOBJ.AssignList}

function WWArrayIOOBJ.GetString(Line:integer): string;
{}
var
  W : word;
  TempStr : String;
  ArrayOffset: word;
begin
   if (Line > 0) and (Line <= vTotLines) then
   begin
      W := pred(Line) * succ(vStrLength);
      ArrayOffset := Ofs(vArrayPtr^) + W;
      Move(Mem[Seg(vArrayPtr^):ArrayOffset],TempStr,1);
      Move(Mem[Seg(vArrayPtr^):succ(ArrayOffset)],TempStr[1],ord(TempStr[0]));
   end
   else
      TempStr := '';
   GetString := TempStr;
end; {WWArrayIOOBJ.GetString}

procedure WWArrayIOOBJ.SetString(Line:integer;Str: string);
{}
var
  W : word;
  ArrayOffset: word;
begin
   if (Line > 0) and (Line <= vTotLines) then
   begin
      W := pred(Line) * succ(vStrLength);
      ArrayOffset := Ofs(vArrayPtr^) + W;
      Move(Str[0],Mem[Seg(vArrayPtr^):ArrayOffset],succ(length(Str)));
   end;
end; {WWArrayIOOBJ.SetString}

procedure WWArrayIOOBJ.DeleteLine(Line:integer);
{}
var
  Null : char;
  W : word;
  ArrayOffset: word;
begin
   if (Line > 0) and (Line <= vTotLines) then
   begin
      W := pred(Line) * succ(vStrLength);
      ArrayOffset := Ofs(vArrayPtr^) + W;
      Move(Mem[Seg(vArrayPtr^):ArrayOffset+succ(vStrLength)],
           Mem[Seg(vArrayPtr^):ArrayOffset],
           (vTotLines - Line)*succ(vStrlength));
      {empty last line}
      W := pred(vTotLines) * succ(vStrLength);
      ArrayOffset := Ofs(vArrayPtr^) + W;
      Null := char(0);
      Move(Null,Mem[Seg(vArrayPtr^):ArrayOffset],1);
   end;
end; {WWArrayIOOBJ.DeleteLine}

procedure WWArrayIOOBJ.InsertLine(Line:integer);
{}
var
  Null : char;
  W : word;
  ArrayOffset: word;
begin
   if (Line > 0) and (Line <= vTotLines) then
   begin
      W := pred(Line) * succ(vStrLength);
      ArrayOffset := Ofs(vArrayPtr^) + W;
      Move(Mem[Seg(vArrayPtr^):ArrayOffset],
           Mem[Seg(vArrayPtr^):ArrayOffset+succ(vStrLength)],
           (vTotLines - Line)*succ(vStrlength));
      {empty new line}
      Null := char(0);
      Move(Null,Mem[Seg(vArrayPtr^):ArrayOffset],1);
   end;
end; {WWArrayIOOBJ.InsertLine}

destructor WWArrayIOOBJ.Done;
{}
begin
   WordwrapIOOBJ.Done;
end; {WWArrayIOOBJ.Done}
{||||||||||||||||||||||||||||||||||||||||||}
{                                          }
{     W W L i n k O B J   M E T H O D S    }
{                                          }
{||||||||||||||||||||||||||||||||||||||||||}
constructor WWLinkIOOBJ.Init(X1,Y1,width,lines:byte;Title:string);
{}
begin
   WordwrapIOOBJ.Init(X1,Y1,width,lines,Title);
   vWidth := pred(vBorder.X2 - vBorder.X1);
   vWrapping := false;
end; {WWLinkIOOBJ.Init}

procedure WWLinkIOOBJ.AssignList(var LinkList:StrDLLOBJ; Max:integer);
{}
begin
   vLinkList := @LinkList;
   vMaxLines := Max;
   vTotLines := LinkList.TotalNodes;
   vListAssigned := true;
   vLineStr := GetString(1);
   vScrollBarOn := (vTotLines > vRows);
   vCursorX := 1;   {1.00d}
   vCursorY := 1;
end; {WWLinkIOOBJ.AssignList}

function WWLinkIOOBJ.GetString(Line:integer): string;
{}
var
  TempPtr : DLLNodePtr;
begin
   TempPtr := vLinkList^.NodePtr(Line);
   if TempPtr <> Nil then
      vLinkList^.ShiftActiveNode(TempPtr,Line);
   if vWrapping then
      GetString := vLinkList^.GetStr(TempPtr,1,255)
   else
      GetString := vLinkList^.GetStr(TempPtr,1,vWidth)
end; {WWLinkIOOBJ.GetString}

procedure WWLinkIOOBJ.SetString(Line:integer;Str: string); {1.00e}
{}
var
  Ecode: integer;
  NP : DllNodePtr;
begin
   NP := vLinkList^.NodePtr(Line);
   if NP = nil then
      ECode := vLinkList^.Add(Str)
   else
      ECode := vLinkList^.Change(NP,Str);
end; {WWLinkIOOBJ.SetString}

procedure WWLinkIOOBJ.DeleteLine(Line:integer);
{}
begin
   vLinkList^.DelNode(vLinkList^.NodePtr(Line));
   dec(vTotLines);
   vLinkList^.ShiftActiveNode(vLinkList^.NodePtr(1),1);  {1.00c}
end; {WWLinkIOOBJ.DeleteLine}

procedure WWLinkIOOBJ.InsertLine(Line:integer);
{}
var
  Null: string;
  ECode: integer;
begin
   Null := '';
   Ecode := vLinkList^.InsertBefore(vLinkList^.NodePtr(Line),Null);
   if Ecode = 3 then {add a new line to end of list}
      Ecode := vLinkList^.Add(Null);
   vTotLines := vLinkList^.TotalNodes;
end; {WWLinkIOOBJ.InsertLine}

procedure WWLinkIOOBJ.WrapFull;
{}
begin
   vWrapping := true;
   WordwrapIOOBJ.WrapFull;
   with vLinkList^ do
      ShiftActiveNode(EndNodePtr,TotalNodes);
   vWrapping := false;
   vTotLines := vLinkList^.TotalNodes;
   vScrollBarOn := (vTotLines > vRows);
end; {WWLinkIOOBJ.WrapFull}

destructor WWLinkIOOBJ.Done;
{}
begin
   WordwrapIOOBJ.Done;
end; {WWLinkIOOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure IO3Init;
{initilizes objects and global variables}
begin

end; {IO3Init}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
   IO3Init;
{$ENDIF}
end.
