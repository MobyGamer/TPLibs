program DemoOverlay1;
{demov - be sure that the OVERLAYINIT compiler directive is enabled
 in the TOTFLAGS.INC file before compiling}

{$I TOTFLAGS.INC}

Uses DOS, CRT,
     totSYS, totLOOK, totINPUT, totFAST, totWIN, totIO1, totMSG;

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
      Show;
      Done;
   end;
end.

