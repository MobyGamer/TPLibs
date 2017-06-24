program DemoIOTwenty;
{demIO20 - an extension of demio18 adding help}

Uses DOS, CRT,
     totFAST, totIO1, totIO2, totSTR, totMSG;

var
  Search: LateralIOOBJ;
  Field1: CheckIOOBJ;
  Field2,
  Field3,
  Field4: RadioIOOBJ;
  OK,Cancel,HelpBut: Strip3dIOOBJ;
  F1key: HotkeyIOOBJ;
  Keys: ControlKeysIOOBJ;
  Manager: WinFormOBJ;
  Result: tAction;

{$F+}
procedure HelpRoutine(ID:word);
{}
var HelpTxt:  MessageOBJ;
begin
   with HelpTxt do
   begin
      Init(1,' Help ');
      AddLine('');
      Addline(' Just imagine that this is some ');
      Addline(' extraordinary help about field ');
      AddLine(padcenter(inttoStr(ID),32,' '));
      AddLine('');
      Show;
      Done;
   end;
end; {HelpRoutine}
{$F-}

procedure InitVars;
{}
begin
   with Search do
   begin
      Init(10,2,40,60);
      SetLabel('~S~earch');
      SetHotKey(287); {Alt-S}
      SetID(1);
   end;
   with Field1 do
   begin
      Init(3,4,25,4,'Options');
      AddItem('~C~ase sensitive',302,false);
      AddItem('~W~hole words only',273,false);
      AddItem('~R~egular expression',275,false);
      SetID(2);
   end;
   with Field2 do
   begin
      Init(3,8,25,3,'Scope');
      AddItem('~G~lobal',290,true);
      AddItem('Selected ~t~ext',276,false);
      SetID(3);
   end;
   with Field3 do
   begin
      Init(33,4,17,3,'Direction');
      AddItem('Forwar~d~',288,true);
      AddItem('~B~ackward',304,false);
      SetID(4);
   end;
   with Field4 do
   begin
      Init(33,8,17,3,'Origin');
      AddItem('~F~rom cursor',289,false);
      AddItem('~E~ntire scope',274,true);
      SetID(5);
   end;
   OK.Init(6,12,'   ~O~K   ',Finished);
   OK.SetHotkey(280);
   OK.SetID(6);
   Cancel.Init(20,12,' C~a~ncel ',Escaped);
   Cancel.SetHotkey(286);
   Cancel.SetID(7);
   HelpBut.Init(34,12,'  ~H~elp  ',Help);
   HelpBut.SetHotkey(291);
   HelpBut.SetID(HelpID);
   F1Key.Init(315,Help);
   Keys.Init;
end; {InitVars}

procedure DisposeVars;
{}
begin
   Search.Done;
   Field1.Done;
   Field2.Done;
   Field3.Done;
   Field4.Done;
   OK.Done;
   Cancel.Done;
   HelpBut.Done;
   Keys.Done;
   F1key.Done;
end; {DisposeVars}

begin
   InitVars;
   Screen.Clear(white,'°'); {paint the screen}
   with Manager do
   begin
      Init;
      Win^.SetSize(14,2,65,16,1);
      Win^.SetTitle(' Press Tab to change fields. ');
      AddItem(Keys);
      AddItem(F1Key);
      AddItem(Search);
      AddItem(Field1);
      AddItem(Field2);
      AddItem(Field3);
      AddItem(Field4);
      AddItem(OK);
      AddItem(Cancel);
      AddItem(HelpBut);
      SetHelpHook(HelpRoutine);
      Draw;
      Result := Go;
      Win^.Remove;
      if Result = Finished then
      begin
         GotoXY(1,18);
      end
      else
      begin
         GotoXY(1,20);
         writeln('You escaped!');
      end;
      DisposeVars;
      Done;
   end;
end.