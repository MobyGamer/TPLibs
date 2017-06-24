program DemoMessageFour;
{demms4 - two strip-buttons}

Uses DOS, CRT,
     totFAST, totMSG, totIO1;

Var
   MsgWin : PromptOBJ;
   ActionCode: tAction;

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
      ActionCode := Show;
      Done;
   end;
end.
