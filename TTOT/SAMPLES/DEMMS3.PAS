program DemoMessageThree;
{demms3 - using SetOption to change button text}

Uses DOS, CRT,
     totFAST, totMSG;

Var
   MsgWin : MessageOBJ;

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
      SetOption(' A very ~l~ong button ',76);
      Show;
      Done;
   end;
end.

