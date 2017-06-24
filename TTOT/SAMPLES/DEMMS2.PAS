program DemoMessageTwo;
{demms2 - using a box-button}

Uses DOS, CRT,
     totFAST, totMSG;

Var
   MsgWin : ButtonMessageOBJ;

begin
   Screen.Clear(white,'°'); {paint the screen}
   with MsgWin do
   begin
      Init(1,' Message ');
      AddLine('');
      AddLine('The message unit provides a');
      AddLine('very easy way of displaying');
      AddLine('pop-up messages in a move-');
      AddLine('able window.');
      AddLine('');
      Show;
      Done;
   end;
end.

