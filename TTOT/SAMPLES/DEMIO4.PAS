program DemoIOFour;
{demIO4 - using hotkeys, labels, and messages}

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
      SetLabel('Vendor ~N~ame');
      SetHotkey(305); {Alt-N}
      SetMessage(22,11,'Enter the vendor''s name, 40 chars Max');
   end;
   with Phone do
   begin
      Init(35,7,'(###) ###-####');
      SetLabel('~T~el');
      SetHotkey(276); {Alt-T}
      SetMessage(22,11,'Enter the vendor''s phone number');
   end;
   with Price do
   begin
      Init(35,9,8,2);
      SetLabel('Unit ~P~rice');
      SetHotKey(281); {Alt-P}
      SetMessage(22,11,'Enter the unit price in dollars');
   end;
   Keys.Init;
end; {InitVars}

begin
   ClrScr;
   Screen.TitledBox(15,3,65,12,76,79,78,2,' Quicky Input Demo ');
   Screen.WriteCenter(25,white,'Press TAB to switched fields and press ESC or F10 to end');
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

