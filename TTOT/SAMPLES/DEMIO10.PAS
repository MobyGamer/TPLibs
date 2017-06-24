program DemoIOTen;
{demIO8 - date field input}
Uses DOS, CRT,
     totFAST, totIO1, totIO2, totDate;

var
  Field1, Field2,
  Field3, Field4: DateIOOBJ;
  Keys: ControlKeysIOOBJ;
  Manager: FormOBJ;

procedure InitVars;
{}
begin
   with Field1 do
   begin
      Init(40,3,MMDDYY);
      SetLabel('Field 1   (MMDDYY)');
      SetMessage(30,25,'Default settings');
   end;
   with Field2 do
   begin
      Init(40,5,MMDDYY);
      SetLabel('Field 2   (MMDDYY)');
      SetValue(TodayInJul);
      SetRules(EraseDefault+JumpIfFull);
      SetMessage(5,25,'SetValue(TodayInJul); SetRules(EraseDefault+JumpIfFull);');
   end;
   with Field3 do
   begin
      Init(40,7,DDMMYYYY);
      SetLabel('Field 3 (DDMMYYYY)');
      SetMessage(30,25,'Default settings');
   end;
   with Field4 do
   begin
      Init(40,9,DDMMYYYY);
      SetLabel('Field 4 (DDMMYYYY)');
      SetMinMax(GregtoJul(3,1,1992),GregtoJul(3,31,1992));
      SetCursor(CursLeft);
      SetMessage(23,25,'SetCursor(CursLeft); SetMinMax ...');
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
   Keys.Done;
end; {DisposeVars}

begin
   InitVars;
   ClrScr;
   Screen.FillBox(10,2,70,11,79,1);
   Screen.WriteCenter(11,79,' Press Tab to change fields. F10 to finish. ');
   with Manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(Field1);
      AddItem(Field2);
      AddItem(Field3);
      AddItem(Field4);
      if Go = Finished then
      begin
         GotoXY(1,18);
         writeln('Your input was:');
         writeln('Field 1: ',FancyDateStr(Field1.GetValue,true,true));
         writeln('Field 2: ',FancyDateStr(Field2.GetValue,true,true));
         writeln('Field 3: ',FancyDateStr(Field3.GetValue,true,true));
         writeln('Field 4: ',FancyDateStr(Field4.GetValue,true,true));
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