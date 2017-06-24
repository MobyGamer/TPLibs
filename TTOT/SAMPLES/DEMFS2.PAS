Program DemoFastTwo;
{DEMFS2}

USES DOS,CRT,
     totSYS, totINPUT, totFAST;

var 
  WasOn: boolean;
  Dep : byte;
begin
   Monitor^.SetCondensed;
   Dep := Monitor^.Depth;
   Mouse.Show;
   Mouse.Confine(1,1,80,Dep);    {tell mouse how far it can go}
   ShadowTot^.SetShadowSize(2,2);
   with Screen do
   begin
      Clear(31,' ');
      ShadFillBox(2,2,40,Dep-10,65,2);
      ShadFillBox(35,20,75,dep-3,112,1);
      Writecenter(Dep,31,'Press any key to exit');
      GotoXY(1,dep);
   end;
   Key.GetInput;
   Mouse.Hide;
   Monitor^.Set25;
end.
