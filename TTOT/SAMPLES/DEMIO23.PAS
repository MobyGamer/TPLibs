program DemoIOTwentyThree;
{demIO23 - DAMN that TAB key!}

{This example illustrates how you could use a character hook to
 provide cursor jumping between fields - rather then pressing the
 TAB key.}

Uses DOS, CRT,
     totFAST, totREAL, totINPUT, totIO1, totIO2, totIO3, 
     totSTR, totDATE, totMSG;

VAR
   Controlkeys: ControlKeysIOOBJ;
   UpKey,DownKey,LeftKey,RightKey,EnterKey: HotkeyIOOBJ;
   Field1,
   Field2,
   Field3,
   Field4,
   Field5,
   Field6,
   Field7,
   Field8,
   Field9: StringIOOBJ;
   Manager: FormOBJ;
   Result: tAction;

{$F+}
function EnterFieldTrap(var NextID:word; PrevID:word):tAction;
{Intercepts field changes and checks key that was pressed. If necessary
 the Toolkit is redirected to a different fielf}
var MoveKey: word;

    procedure GotoField(U,D,L,R:word);
    {}
    begin
       case Movekey of
       328: NextID := U;
       336: NextID := D;
       371: NextID := L;
       else NextID := R;
       end; {case}
    end;
begin
   MoveKey := Key.Lastkey;
   if (MoveKey = 328) 
   or (MoveKey = 336)  
   or (MoveKey = 371)
   or (MoveKey = 372)
   or (MoveKey = 13) then
      case PrevID of
      1: GotoField(9,4,9,2);     {up,down,left,right}
      2: GotoField(7,5,1,3);
      3: GotoField(5,6,2,4);
      4: GotoField(1,7,3,5);
      5: GotoField(2,3,4,6);
      6: GotoField(3,8,5,7);
      7: GotoField(4,2,6,8);
      8: GotoField(6,9,7,9);
      9: GotoField(8,1,8,1);
      end;
   EnterFieldTrap := none; 
end; {EnterFieldTrap}
{$F-}

procedure InitVars;
{}
begin
   UpKey.Init(328,PrevField);
   DownKey.Init(336,NextField);
   LeftKey.Init(371,PrevField);
   RightKey.Init(372,NextField);
   EnterKey.Init(13,NextField);
   Field1.Init(15,5,10);
   Field1.SetLabel('Field 1');
   Field1.SetID(1);
   Field2.Init(40,5,10);
   Field2.SetLabel('Field 2');
   Field2.SetID(2);
   Field3.Init(65,5,10);
   Field3.SetLabel('Field 3');
   Field3.SetID(3);
   Field4.Init(15,8,10);
   Field4.SetLabel('Field 4');
   Field4.SetID(4);
   Field5.Init(40,8,10);
   Field5.SetLabel('Field 5');
   Field5.SetID(5);
   Field6.Init(65,8,10);
   Field6.SetLabel('Field 6');
   Field6.SetID(6);
   Field7.Init(15,11,10);
   Field7.SetLabel('Field 7');
   Field7.SetID(7);
   Field8.Init(65,11,10);
   Field8.SetLabel('Field 8');
   Field8.SetID(8);
   Field9.Init(15,14,60);
   Field9.SetLabel('Field 9');
   Field9.SetID(9);
   Controlkeys.Init;
   with Manager do
   begin
      Init;
      AddItem(Controlkeys);
      AddItem(UpKey);
      AddItem(DownKey);
      AddItem(LeftKey);
      AddItem(RightKey);
      AddItem(EnterKey);
      AddItem(Field1);
      AddItem(Field2);
      AddItem(Field3);
      AddItem(Field4);
      AddItem(Field5);
      AddItem(Field6);
      AddItem(Field7);
      AddItem(Field8);
      AddItem(Field9);
   end;
end; {InitVars}

procedure SetUpScreen;
{}
begin
   with Screen do
   begin
      {use the color settings used in the IO form}
      TitledBox(1,1,80,25,
                IOTOT^.LabelCol(3),
                IOTOT^.LabelCol(4),
                IOTOT^.LabelCol(3),
                1,' TechnoJock''s Hate-that-TAB Demo ');
      WriteCenter(24,79,'To change fields press:      Ctrl'+chr(027)
                        +'  Ctrl'+chr(026)
                        +'  Enter, or the dreaded TAB');
   end;
end; {SetUpScreen}

begin
   InitVars;
   SetUpScreen;
   Manager.SetEnterHook(EnterFieldTrap);
   Result := Manager.Go;
   Clrscr;
end.