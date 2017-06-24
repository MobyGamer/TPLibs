Program DemoInputThree;
{DEMIN3}

Uses CRT,
     totINPUT, totFAST, totMISC;


{$F+}
procedure ClockHook;
{}
begin
   with Screen do
   with Key do
   begin
      SetWinIgnore(true);
      if GetCaps then
         WritePlain(40,24,'CAPS')
      else
         WritePlain(40,24,'    ');
      if GetNum then
         WritePlain(45,24,'NUM')
      else
         WritePlain(45,24,'   ');
      if GetScroll then
         WritePlain(50,24,'SCROLL')
      else
         WritePlain(50,24,'      ');
      if KeyPressed then 
      begin
         SetWinIgnore(false);
         exit;
      end;
      if AltPressed then
         WritePlain(60,24,'Alt')
      else
         WritePlain(60,24,'   ');
      if CtrlPressed then
         WritePlain(65,24,'Ctrl')
      else
         WritePlain(65,24,'    ');
      if LeftShiftPressed then
         WritePlain(70,24,'L-')
      else
         WritePlain(70,24,'   ');
      if RightShiftPressed then
         WritePlain(75,24,'R-')
      else
         WritePlain(75,24,'   ');
      if KeyPressed then 
      begin
         SetWinIgnore(false);
         exit;
      end;
      WritePlain(1,24,CurrentTime);
      SetWinIgnore(false);
   end;
end; {ClockHook}
{$F-}

{$F+}
procedure MacroHook(var W:word);
{}
begin
   case W of
      286: begin
              Key.StuffBufferStr(' Apple '); {Alt-A}
              W := 0;
           end;
      304: begin
              Key.StuffbufferStr(' Bravo '); {Alt-B}
              W := 0;
           end;
      301: begin
              Key.StuffBuffer(27);           {Alt-X}
              W := 0;
           end;
      315: begin
              Key.StuffbufferStr(' No help! '); {F1}
              W := 0;
           end;
   end; {case}
end; {MacroHook}
{$F-}

begin                 
   with Screen do
   begin
      Clear(31,' ');
      PartClear(1,23,80,25,94,' ');
      WritePlain(5,1,'Press any alpha characters, or Alt-A,B for macros. Esc or Alt-X to quit');
      GotoXY(1,3);
      with Key do
      begin
         SetCaps(true);
         SetNum(true);
         SetScroll(true);
         AssignIdleHook(ClockHook);
         AssignPressedHook(MacroHook);
         Repeat
             GetInput;
             if AlphabetTot^.Isletter(Lastkey) then
                Write(char(LastKey));
         Until LastKey = 27;
         SetCaps(false);
         SetNum(false);
         SetScroll(false);
      end;
   end;
end.
