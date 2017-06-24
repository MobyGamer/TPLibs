program DemoIOFive;
{demIO5 - string field input}

Uses DOS, CRT,
     totFAST, totIO1, totIO2, totSTR;

var
  Field1, Field2, Field7: StringIOOBJ;
  Field3, Field4: LateralIOOBJ;
  Field5, Field6: PictureIOOBJ;
  Keys: ControlKeysIOOBJ;
  Manager: FormOBJ;

procedure InitVars;
{}
begin
   with Field1 do
   begin
      Init(40,3,10);
      SetLabel('Field 1  (StringIOOBJ)');
      SetMessage(30,25,'Default settings');
   end;
   with Field2 do
   begin
      Init(40,5,10);
      SetLabel('Field 2  (StringIOOBJ)');
      SetCase(upper);
      SetValue('hello');
      SetRules(EraseDefault+JumpIfFull);
      SetMessage(5,25,'SetCase(upper); SetValue(''hello''); SetRules(EraseDefault+JumpIfFull);');
   end;
   with Field3 do
   begin
      Init(40,7,15,30);
      SetLabel('Field 3 (LateralIOOBJ)');
      SetMessage(30,25,'Default settings');
   end;
   with Field4 do
   begin
      Init(40,9,15,30);
      SetLabel('Field 4 (LateralIOOBJ)');
      SetCase(Upper);
      SetForcecase(True);
      SetCursor(CursLeft);
      SetMessage(5,25,'SetCase(Upper); SetForcecase(True); SetCursor(CursLeft);');
   end;
   with Field5 do
   begin
      Init(40,11,'(###) ###-####');
      SetLabel('Field 5 (PictureIOOBJ)');
      SetMessage(20,25,'(###) ###-#### with default settings');
   end;
   with Field6 do
   begin
      Init(40,13,'!!!***@@@###');
      SetLabel('Field 6 (PictureIOOBJ)');
      SetDisAllowChar('aAbBcC123@!');
      SetRules(EraseDefault);
      SetMessage(2,25,'!!!***@@@### with SetDisAllowChar(''aAbBcC123@!'') SetRules(EraseDefault)');
   end;
   with Field7 do
   begin
      Init(40,15,10);
      SetLabel('Field 7  (StringIOOBJ)');
      SetDispChar('#');
      SetMessage(30,25,'SetDispChar(''#'')');
   end;
   Keys.Init;
end; {InitVars}

procedure DisposeVars;
{}
begin
   Field1.Done;
   Field2.Done;
   Field3.Done;
   Field4.Done;
   Field5.Done;
   Field6.Done;
   Field7.Done;
   Keys.Done;
end; {DisposeVars}

begin
   InitVars;
   ClrScr;
   Screen.FillBox(10,2,70,17,79,1);
   Screen.WriteCenter(17,79,' Press Tab to change fields. F10 to finish. ');
   with manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(Field1);
      AddItem(Field2);
      AddItem(Field3);
      AddItem(Field4);
      AddItem(Field5);
      AddItem(Field6);
      AddItem(Field7);
      if Go = Finished then
      begin
         GotoXY(1,18);
         writeln('Your input was:');
         writeln('Field 1: ',Field1.GetValue);
         writeln('Field 2: ',Field2.GetValue);
         writeln('Field 3: ',Field3.GetValue);
         writeln('Field 4: ',Field4.GetValue);
         writeln('Field 5: ',Field5.GetValue);
         writeln('         ',Field5.GetPicValue);
         writeln('Field 6: ',Field6.GetValue);
         write('Field 7: ',Field7.GetValue);
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