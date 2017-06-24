program DemoIOSeventeen;
{demIO17 - an extension of demio12 with buttons}

Uses DOS, CRT,
     totFAST, totIO1, totIO2, totSTR;

var
  Field1: CheckIOOBJ;
  Field2,
  Field3,
  Field4: RadioIOOBJ;
  OK,Cancel: Strip3dIOOBJ;
  Keys: ControlKeysIOOBJ;
  Manager: FormOBJ;

procedure InitVars;
{}
begin
   with Field1 do
   begin
      Init(17,5,25,4,'Options');
      AddItem('~C~ase sensitive',67,false);
      AddItem('~W~hole words only',87,false);
      AddItem('~R~egular expression',82,false);
   end;
   with Field2 do
   begin
      Init(17,10,25,3,'Scope');
      AddItem('~G~lobal',71,true);
      AddItem('~S~elected text',83,false);
   end;
   with Field3 do
   begin
      Init(45,5,17,3,'Direction');
      AddItem('Forwar~d~',68,true);
      AddItem('~B~ackward',66,false);
   end;
   with Field4 do
   begin
      Init(45,10,17,3,'Origin');
      AddItem('~F~rom cursor',70,false);
      AddItem('~E~ntire scope',69,true);
   end;
   OK.Init(23,14,'   ~O~K   ',Finished);
   OK.SetHotkey(79);
   Cancel.Init(36,14,' C~a~ncel ',Escaped);
   Cancel.SetHotkey(65);
   Keys.Init;
end; {InitVars}

procedure DisposeVars;
{}
begin
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
   ClrScr;
   Screen.FillBox(14,2,65,16,79,1);
   Screen.WriteCenter(16,79,' Press Tab to change fields. ');
   with manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(Field1);
      AddItem(Field2);
      AddItem(Field3);
      AddItem(Field4);
      AddItem(OK);
      AddItem(Cancel);
      if Go = Finished then
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