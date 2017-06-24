Program DemoInputFour;
{DEMIN4}

Uses CRT,
     totINPUT, totFAST, totSTR;

Var
  Ch : char;
  L,C,R,OldL,OldC,OldR: boolean;
  X,Y,OldX,OldY: byte;

begin                 
   Clrscr;
   with Mouse do
   begin
      if not Installed then
      begin
         Writeln('This demo will only function on systems equipped with a mouse');
      end
      else
      begin
         WriteLn('You have a ',GetButtons,' button mouse!');
         Writeln('Press: C to confine the mouse');
         Writeln('       U to unconfine the mouse');
         Writeln('       L to change the mouse cursor');
         Writeln('       R to reset mouse');
         Writeln('       H to hide the mouse');
         Writeln('       S to show the mouse');
         Writeln('       any mouse button');
         Writeln('       Esc to quit');
         Screen.FillBox(15,10,65,20,30,1);
         Show;
         repeat
            with Screen do
            repeat
               Status(L,C,R,X,Y);
               if OldL <> L then
                  if L then
                     WriteAT(20,11,30,'Left Button')
                  else
                     WriteAT(20,11,30,'           ');
               if OldR <> R then
                  if R then
                     WriteAT(20,12,30,'Right Button')
                  else
                     WriteAT(20,12,30,'            ');
               if OldC <> C then
                  if C then
                     WriteAT(20,13,30,'Middle Button')
                  else
                     WriteAT(20,13,30,'             ');
               if OldX <> X then
                  WriteAT(20,15,30,inttostr(X)+' ');
               if OldY <> Y then
                   WriteAT(20,16,30,inttostr(Y)+' ');
               OldL := L;
               OldR := R;
               OldC := C;
               OldX := X;
               OldY := Y;
            until Key.KeyPressed;
            Key.GetInput;
            case upcase(Key.LastChar) of
               'C': Confine(15,10,65,20);
               'U': Confine(1,1,80,25);
               'L': SetMouseCursorStyle(random(200)+56,0);
               'H': Hide;
               'S': Show;
               'R': begin
                       Hide;
                       Reset;
                       Show;
                    end;
            end; {case}
         until Key.LastKey = 27;
         Hide;
      end;
      GotoXY(1,23);
   end;
end.
