program DemoMessageEight;
{demms8 - three box-buttons}

Uses DOS, CRT,
     totFAST, totMSG, totIO1;

Var
   MsgWin : ButtonPromptOBJ;
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
		 SetOption(3,' ~H~elp ',72,Stop1);
      ActionCode := Show;
      Done;
   end;
end.
