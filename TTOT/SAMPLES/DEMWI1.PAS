program DemoWindowOne;
{DEMWI1 - simple window}

Uses DOS,CRT,
     totFAST, totINPUT, totWIN;

var
  MyWindow: WinOBJ;
  K: word;
  X,Y: byte;
begin
   Screen.Clear(white,'°'); {paint the screen}
   with MyWindow do
   begin
      Init;
      Draw;
      Screen.WriteLn('Hello Mum');
      Repeat
         WinGetKey(K,X,Y);
      until (K = 600) or (K= 27);
      Done;
   end;
end.
