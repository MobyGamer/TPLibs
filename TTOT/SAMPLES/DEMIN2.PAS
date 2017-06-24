Program DemoInputTwo;
{DEMIN2}

Uses
     totINPUT, totFAST;

begin                 
   with Screen do
   begin
       Clear(31,' ');
       PartClear(1,23,80,25,94,' ');
       WritePlain(10,5,'Press Num, Scroll, Caps Lock, or hold down the Alt,');
       WritePlain(10,6,'Ctrl, Left/Right Shift keys. The active keys will be');
       WritePlain(10,7,'display at the foot of the display.');
       WritePlain(10,9,'Any other key quits.');
       with Key do
       begin
          SetCaps(true);
          SetNum(true);
          SetScroll(true);
          repeat
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
          until KeyPressed;
          SetCaps(false);
          SetNum(false);
          SetScroll(false);
       end;
   end;
end.
