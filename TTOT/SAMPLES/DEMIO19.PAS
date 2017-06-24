program DemoIONineteen;
{demIO19 - full field input with a char hook}

Uses DOS, CRT,
     totFAST, totIO1, totIO2, totMSG, totMISC, totSTR;

Var
   Name: LateralIOOBJ;
   Phone: PictureIOOBJ;
   Price: FixedRealIOOBJ;
   Keys: ControlkeysIOOBJ;
   Manager: FormOBJ;
   Result: tAction;

{$F+}
function ShowTime(var K:word; var X,Y:byte; var ID:word):tAction;
{}
var Msg:  MessageOBJ;
begin
   if K = 276 then {Alt-T}
   begin
      with Msg do
      begin
         Init(1,'The Time M''Lord');
         Addline('');
         AddLine(padcenter(CurrentTime,25,' '));
         AddLine('');
         Show;
         Done;
      end;
      K := 0;
   end;
   ShowTime := none;
end; {ShowTime}
{$F-}

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
   Screen.WriteCenter(25,white,'Press TAB to switch fields and press ESC or F10 or Alt-T');
   InitVars;
   with Manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(Name);
      AddItem(Phone);
      AddItem(Price);
      SetCharHook(ShowTime);
      Result := Go;
      if Result = Finished then
         {update the database..}
      else
         {call Esc routine};
   end;
end.

