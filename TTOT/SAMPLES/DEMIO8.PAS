program DemoIOEight;
{demIO8 - number field input}
Uses DOS, CRT,
     totFAST, totIO1, totIO2, totSTR;

var
  Field1, Field2: IntIOOBJ;
  Field3, Field4: RealIOOBJ;
  Field5:         FixedRealIOOBJ;
  Field6:         HexIOOBJ;
  Keys: ControlKeysIOOBJ;
  Manager: FormOBJ;

procedure InitVars;
{}
begin
   with Field1 do
   begin
      Init(40,3,5);
      SetLabel('Field 1  (IntIOOBJ)');
      SetMessage(30,25,'Default settings');
   end;
   with Field2 do
   begin
      Init(40,5,5);
      InitFormat;
      SetLabel('Field 2  (IntIOOBJ)');
      SetValue(69);
      SetRules(EraseDefault+JumpIfFull);
      SetMessage(5,25,'InitFormat; SetValue(69); SetRules(EraseDefault+JumpIfFull);');
   end;
   with Field3 do
   begin
      Init(40,7,10);
      SetLabel('Field 3 (RealIOOBJ)');
      SetMessage(30,25,'Default settings');
   end;
   with Field4 do
   begin
      Init(40,9,15);
      InitFormat;
      FormatPtr^.SetSeparators('*',',','.');
      FormatPtr^.SetPrefixSuffix('','FR');
      FormatPtr^.SetJustification(JustRight);
      SetLabel('Field 4 (RealIOOBJ)');
      SetCursor(CursLeft);
      SetMessage(5,25,'InitFormat; FormatPtr^... SetCursor(CursLeft);');
   end;
   with Field5 do
   begin
      Init(40,11,8,2);
      SetLabel('Field 5 (FixedRealIOOBJ)');
      SetMessage(30,25,'Default settings');
   end;
   with Field6 do
   begin
      Init(40,13,5);
      SetLabel('Field 6  (HEXIOOBJ)');
      SetMessage(30,25,'Default settings');
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
   Keys.Done;
end; {DisposeVars}

begin
   InitVars;
   ClrScr;
   Screen.FillBox(10,2,70,15,79,1);
   Screen.WriteCenter(15,79,' Press Tab to change fields. F10 to finish. ');
   with Manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(Field1);
      AddItem(Field2);
      AddItem(Field3);
      AddItem(Field4);
      AddItem(Field5);
      AddItem(Field6);
      if Go = Finished then
      begin
         GotoXY(1,18);
         writeln('Your input was:');
         writeln('Field 1: ',Field1.GetValue);
         writeln('Field 2: ',Field2.GetValue);
         writeln('Field 3: ',Field3.GetValue);
         writeln('Field 4: ',Field4.GetValue);
         writeln('Field 5: ',Field5.GetValue);
         writeln('Field 6: ',Field6.GetValue);
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