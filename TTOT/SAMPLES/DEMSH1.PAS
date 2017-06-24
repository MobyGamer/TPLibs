program DemoShadow1;
{demsh1}

Uses DOS, CRT,
     totFAST;

begin         
   with Screen do
   begin
      Clear(white,'°'); {paint the screen}
      ShadFillBox(3,3,20,8,31,1);
      ShadowTOT^.SetShadowStyle(Upleft,lightgray,' ');
      ShadFillBox(3,12,20,19,47,2);
      ShadowTOT^.SetShadowStyle(Downleft,lightblue,' ');
      ShadowTOT^.SetShadowSize(4,1);
      ShadFillBox(35,2,70,10,94,3);
      ShadowTOT^.SetShadowStyle(DownLeft,white,'!');
      ShadFillBox(40,13,60,18,15,4);
      ShadowTOT^.SetDefaults;
      ShadFillBox(5,21,75,23,78,5);
   end; {with}
end.

