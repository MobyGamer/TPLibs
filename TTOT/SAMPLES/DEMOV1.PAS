program DemoOverlay1;

Uses OVERLAY, DOS, CRT,
     OV1Init, totSYS, totLOOK, totINPUT, totFAST, totWIN,
     totIO1, totMSG;

{$O totSYS}
{$O totLOOK}
{$O totINPUT}
{$O totFAST}
{$O totWIN}
{$O totIO1}
{$O totMSG}

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
