program DemoMessageFive;
{demms5 - two strip-buttons with specific text}

Uses DOS, CRT,
     totFAST, totMSG, totIO1;

Var
   MsgWin : PromptOBJ;
   ActionCode: tAction;

begin
   Screen.Clear(white,'°'); {paint the screen}
   with MsgWin do
   begin
      Init(1,' Warning ');
      AddLine('');
      AddLine(' The file already exists on disk, and ');
      AddLine(' the contents will be over-written.');
      AddLine('');
      SetOption(1,' ~P~roceed ',80,Finished);
      SetOption(2,' ~A~bort ',65,Escaped);
      ActionCode := Show;
      Done;
   end;
end.
