program DemoIOThree;
{demIO3 - every input field type!}

Uses DOS, CRT,
     totFAST, totIO1, totIO2, totIO3, totDATE, totINPUT;

Var
   MyList: array [1..10] of string[20];
   Comments: array [1..8] of string[35];

   Str: StringIOOBJ;
   Lat: LateralIOOBJ;
   Pic: PictureIOOBJ;
   Int: IntIOOBJ;
   Rea: RealIOOBJ;
   Fix: FixedRealIOOBJ;
   Hx:  HexIOOBJ;
   Dat: DateIOOBJ;
   Check: CheckIOOBJ;
   Radio: RadioIOOBJ;
   WW: WWArrayIOOBJ;
   Lis: ArrayIOOBJ;
   AltX: HotkeyIOOBJ;
   Keys: ControlkeysIOOBJ;
   Strip: StripIOOBJ;
   Strip3D: Strip3dIOOBJ;
   Butt: ButtonIOOBJ;

   Manager: FormOBJ;
   Result: tAction;

procedure FillArrays;
{}
begin
   MyList[1] := 'French Fries';
   MyList[2] := 'Baked Potato';
   MyList[3] := 'Potato Salad';
   MyList[4] := 'Coleslaw';
   MyList[5] := 'Salad';
   MyList[6] := 'Rice';
   MyList[7] := 'Bark Chips';
   MyList[8] := 'Tofu';
   MyList[9] := 'Mixed Vegetables';
   MyList[10] := 'Beer';
   fillchar(Comments,sizeof(Comments),#0);
   Comments[1] := 'This is the finest Pizza I have ';
   Comments[2] := 'ever tasted. I also thought ';
   Comments[3] := 'the head waiter was ';
   Comments[4] := 'charming. ';
end; {FillArrays}

procedure InitVars;
{}
begin
   Str.Init(20,3,10);
   Str.SetLabel('StringIOOBJ');
   Lat.Init(20,4,20,40);
   Lat.SetLabel('LateralIOOBJ');
   Pic.Init(20,5,'(###) ###-####');
   Pic.SetLabel('PictureIOOBJ');
   Int.Init(20,6,10);
   Int.SetLabel('IntIOOBJ');
   Rea.Init(20,7,10);
   Rea.SetLabel('RealIOOBJ');
   Fix.Init(20,8,8,4);
   Fix.SetLabel('FixedRealIOOBJ');
   Hx.Init(20,9,5);
   Hx.SetLabel('HexIOOBJ');
   Dat.Init(20,10,MMDDYY);
   Dat.SetLabel('DateIOOBJ');
   with Check do
   begin
      Init(5,12,20,5,'CheckIOOBJ');
      AddItem('Pepperoni',0,false);
      AddItem('Mushrooms',0,true);
      AddItem('Peppers',0,false);
      AddItem('Dolphin',0,true);
   end;
   with Radio Do
   begin
      Init(5,18,20,4,'RadioIOOBJ');
      AddItem('Thin Crust',0,false);
      AddItem('Deep Pan',0,false);
      AddItem('Hand Tossed!',0,true);
   end;
   Lis.Init(30,12,22,8,'ArrayIOOBJ');
   Lis.AssignList(MyList,10,20);
   WW.Init(40,6,37,5,'WWArrayIOOBJ');
   WW.AssignList(Comments,8,35);
   WW.WrapFull;
   Strip.Init(60,13,'   ~O~K   ',Finished);
   Strip.SetHotKey(280); {Alt-O}
   Strip3d.Init(60,15,' ~C~ancel ',Escaped);
   Strip3d.SetHotKey(302); {Alt-C}
   Butt.Init(60,17,' ~B~utton ',Stop1);
   Butt.SetHotKey(304); {Alt-B}
   AltX.Init(301,Stop2);
   Keys.Init;
end; {InitVars}

begin                          
   ClrScr;
   Screen.TitledBox(1,1,80,25,76,79,78,2,' The Works! ');
   Screen.WriteCenter(25,white,'Press TAB to switched fields and press ESC or F10 to end');
   FillArrays;
   InitVars;
   with Manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(Str);
      AddItem(Lat);
      AddItem(Pic);
      AddItem(Int);
      AddItem(Rea);
      AddItem(Fix);
      AddItem(Hx);
      AddItem(Dat);
      AddItem(Check);
      AddItem(Radio);
      AddItem(Lis);
      AddItem(WW);
      AddItem(Strip);
      AddItem(Strip3d);
      AddItem(Butt);
      AddItem(AltX);
      Mouse.Show;
      Key.SetDouble(False);
      Result := Go;
      Mouse.Hide;
      if Result = Finished then
         {update the database..}
      else
         {call Esc routine};
   end;
end.

