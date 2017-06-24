program DemoIOTwo;
{demIO2 - full field input}

Uses DOS, CRT,
     totFAST, totIO1, totIO2;

Var
   Name: LateralIOOBJ;
   Phone: PictureIOOBJ;
   Price: FixedRealIOOBJ;
   Keys: ControlkeysIOOBJ;
   Manager: FormOBJ;
   Result: tAction;

procedure InitVars;
{}
begin
   with Name do
   begin
      Init(35,5,20,40);
      SetLabel('Vendor Name');
   end;
   with Phone do
   begin
      Init(35,7,'(###) ###-####');
      SetLabel('Tel');
      SetRules(JumpIfFull);
   end;
   with Price do
   begin
      Init(35,9,8,2);
      SetLabel('Unit Price');
      SetValue(250.0);
      SetMinMax(0.1,12250.0);
      SetRules(EraseDefault);
   end;
   Keys.Init;
end; {InitVars}

begin
   ClrScr;
   Screen.TitledBox(15,3,65,11,76,79,78,2,' Quicky Input Demo ');
   Screen.WriteCenter(25,white,'Press TAB to switch fields and press ESC or F10 to end');
   InitVars;
   with Manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(Name);
      AddItem(Phone);
      AddItem(Price);
      Result := Go;
      if Result = Finished then
         {update the database..}
      else
         {call Esc routine};
   end;
end.

