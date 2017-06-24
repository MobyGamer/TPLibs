program DemoIOEighteen;
{demIO18 - an extension of demio17 using a moveable dialog box}

Uses DOS, CRT,
     totFAST, totIO1, totIO2, totSTR;

var
  Search: LateralIOOBJ;
  Field1: CheckIOOBJ;
  Field2,
  Field3,
  Field4: RadioIOOBJ;
  OK,Cancel: Strip3dIOOBJ;
  Keys: ControlKeysIOOBJ;
  Manager: WinFormOBJ;
  Result: tAction;

procedure InitVars;
{}
begin
   with Search do
   begin
      Init(10,2,40,60);
      SetLabel('~S~earch');
      SetHotKey(287); {Alt-S}
   end;
   with Field1 do
   begin
      Init(3,4,25,4,'Options');
      AddItem('~C~ase sensitive',302,false);
      AddItem('~W~hole words only',273,false);
      AddItem('~R~egular expression',275,false);
   end;
   with Field2 do
   begin
      Init(3,8,25,3,'Scope');
      AddItem('~G~lobal',290,true);
      AddItem('Selected ~t~ext',276,false);
   end;
   with Field3 do
   begin
      Init(33,4,17,3,'Direction');
      AddItem('Forwar~d~',288,true);
      AddItem('~B~ackward',304,false);
   end;
   with Field4 do
   begin
      Init(33,8,17,3,'Origin');
      AddItem('~F~rom cursor',289,false);
      AddItem('~E~ntire scope',274,true);
   end;
   OK.Init(6,12,'   ~O~K   ',Finished);
   OK.SetHotkey(280);
   Cancel.Init(20,12,' C~a~ncel ',Escaped);
   Cancel.SetHotkey(286);
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
   Keys.Done;
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
      AddItem(Search);
      AddItem(Field1);
      AddItem(Field2);
      AddItem(Field3);
      AddItem(Field4);
      AddItem(OK);
      AddItem(Cancel);
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