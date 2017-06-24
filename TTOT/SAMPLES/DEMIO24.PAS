program DemoIOTwentyFour;
{demIO24 - Leave Fields hooks}

{Using a leave field hook to validate input and not allowing
 the user to leave the active field until the value is correct.}

Uses DOS, CRT,
     totFAST, totREAL, totINPUT, totIO1, totIO2, totIO3, 
     totSTR, totDATE, totMSG;
var
  Field1, Field2: IntIOOBJ;
  Keys: ControlKeysIOOBJ;
  Manager: FormOBJ;

{$F+}
function LeaveFieldTrap(var ID:word):tAction;
{}
var 
   Action:tAction;
   HelpTxt:  MessageOBJ;
begin
   Action := None;
   if ((ID = 1) and (Field1.IsNull=false) and (Odd(Field1.GetValue)))
   or ((ID = 2) and (Field2.IsNull=false) and (not Odd(Field2.GetValue))) 
   then
   begin
      with HelpTxt do
      begin
         Init(1,' Error ');
         AddLine('');
         if ID = 1 then
            Addline(' You must enter an EVEN number ')
         else 
            Addline(' You must enter an ODD number ');
         AddLine('');
         Show;
         Done;
      end;
      ID := StayPut;
      Action := Refresh;
   end;
   LeaveFieldTrap := Action;
end; {EnterFieldTrap}
{$F-}


procedure InitVars;
{}
begin
   with Field1 do
   begin
      Init(40,4,5);
      SetLabel('Enter an EVEN number');
      SetID(1);
   end;
   with Field2 do
   begin
      Init(40,6,5);
      SetLabel('Enter an  ODD number');
      SetID(2);
   end;
   Keys.Init;
end; {InitVars}

procedure DisposeVars;
{}
begin
   Field1.Done;
   Field2.Done;
   Keys.Done;
end; {DisposeVars}

begin
   InitVars;
   ClrScr;
   Screen.FillBox(10,2,70,10,79,1);
   Screen.WriteCenter(9,79,' Press Tab to change fields. F10 to finish. ');
   with Manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(Field1);
      AddItem(Field2);
      SetLeaveHook(LeaveFieldTrap);
      if Go <> Finished then
      begin
         GotoXY(1,20);
         writeln('You escaped!');
      end;
      DisposeVars;
      Done;
   end;
end.