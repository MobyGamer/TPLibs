Program DemoInputOne;
{DEMIN1}

Uses CRT,
     totINPUT;

begin                 
   Clrscr;
   Writeln('Press any key or mouse button combination. (Esc to quit)');
   Key.SetDouble(true);
   repeat
      Key.GetInput;
      GotoXY(1,2);
      Write('You press key: ',Key.LastKey,'    ');
   until Key.LastKey = 27;
end.
