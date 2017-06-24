program DemoWindowThree;
{DEMWI3 - WinOBJ settings}

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
      SetSize(5,5,25,10,3);
      SetTitle(' Greetings ');
      SetClose(false);
      SetRemove(false);
      SetColors(94,95,89,80);
      Draw;
      Screen.WritePlain(1,1,'Hello Mum');
      Repeat
         WinGetKey(K,X,Y);
      until (K=27);
      Done;
   end;
end.
