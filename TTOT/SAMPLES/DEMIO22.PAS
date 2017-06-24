program DemoIOTwentyTwo;
{demIO22 - This example illustrates how you could use the
 Toolkit to develop a two-screen input form}

Uses DOS, CRT,
     totFAST, totREAL, totIO1, totIO2, totSTR, totDATE, totMSG;

Const
   MsgX=25;
   MsgY=19;

Type
RecordInfo = record
   FirstLast: string[40];
   Company: string[40];
   Addr1: string[40];
   Addr2: string[40];
   City: string[25];
   State: string[20];
   Zip: string[9];
   Country: string[30];
   Tel: string[20];
   OrderDate: longint;
   OrderQuantity: word;
   UnitPrice: extended;
   OtherGarbage: array[1..5] of string[40];
end;

var
  ActivePage:shortint;
  ActiveRecord: RecordInfo;
  Result: tAction;
  {Now the input fields}
  UpKey,DownKey,PgDnKey,PgUpKey,F1key: HotkeyIOOBJ;
  Page1But, Page2But, OKBut, CancelBut, HelpBut: Strip3DIOOBJ;
  FirstLastField,
  CompanyField,
  Addr1Field,
  Addr2Field,
  CityField,
  StateField,
  CountryField,
  Field2A,Field2B,Field2C,Field2D,Field2E: StringIOOBJ;
  ZipField,
  TelField: PictureIOOBJ;
  OrderDateField: DateIOOBJ;
  OrderQuantityField: IntIOOBJ;
  UnitPriceField: FixedRealIOOBJ;
  Controlkeys: ControlKeysIOOBJ;
  Page1,Page2: FormOBJ;

{$F+}
procedure ContexturalHelp(ID:word);
{A not too helpful help window!}
var HelpTxt:  MessageOBJ;
begin
   with HelpTxt do
   begin
      Init(1,' Help ');
      AddLine('');
      Addline(' You need help!!  It''s going ');
      Addline(' to be a long day. Just press ');
      if (ID in [101..104]) or (ID = HelpID) then
      begin
         Addline('enter to select the button, ');
         Addline('or TAB to change fields. ');
      end
      else
      begin
         Addline(' the keys and enter the');
         case ID of
           1: AddLine(' Customer''s name. ');
           2: AddLine(' Company name. ');
           3,4: AddLine(' Company''s street address. ');
           5: AddLine(' Company''s City. ');
           6: AddLine(' Company''s State. ');
           7: AddLine(' Company''s Zip. ');
           8: AddLine(' Company''s country details. ');
           9: AddLine(' telephone number. ');
          10: AddLine(' order date. ');
          11: AddLine(' order quantity. ');
          12: AddLine(' unit price. ');
          21: AddLine(' A data! ');
          22: AddLine(' B data! ');
          23: AddLine(' C data! ');
          24: AddLine(' D data! ');
          25: AddLine(' E data! ');
          else AddLine('something!');
         end; {Case}
      end;
      AddLine('');
      Show;
      Done;
   end;
end; {ContexturalHelp}
{$F-}

procedure RecordToForm;
{Updates the form objects with the contents of the record}
begin
   with ActiveRecord do
   begin
      FirstLastField.SetValue(FirstLast);
      CompanyField.SetValue(Company);
      Addr1Field.SetValue(Addr1);
      Addr2Field.SetValue(Addr2);
      CityField.SetValue(City);
      StateField.SetValue(State);
      CountryField.SetValue(Country);
      ZipField.SetValue(Zip);
      TelField.SetValue(Tel);
      OrderDateField.SetValue(OrderDate);
      OrderQuantityField.SetValue(OrderQuantity);
      UnitPriceField.SetValue(UnitPrice);
      Field2A.SetValue(OtherGarbage[1]);
      Field2B.SetValue(OtherGarbage[2]);
      Field2C.SetValue(OtherGarbage[3]);
      Field2D.SetValue(OtherGarbage[4]);
      Field2E.SetValue(OtherGarbage[5]);
   end;
end; {RecordToForm}

procedure FormToRecord;
{Updates the record with the values entered into the form}
begin
   with ActiveRecord do
   begin
      Firstlast := FirstLastField.GetValue;
      Company := CompanyField.GetValue;
      Addr1 := Addr1Field.GetValue;
      Addr2 := Addr2Field.GetValue;
      City := CityField.GetValue;
      State := StateField.GetValue;
      Country := CountryField.GetValue;
      Zip := ZipField.GetValue;
      Tel := TelField.GetValue;
      OrderDate := OrderDateField.GetValue;
      OrderQuantity := OrderQuantityField.GetValue;
      UnitPrice := UnitPriceField.GetValue;
      OtherGarbage[1] := Field2A.GetValue;
      OtherGarbage[2] := Field2B.GetValue;
      OtherGarbage[3] := Field2C.GetValue;
      OtherGarbage[4] := Field2D.GetValue;
      OtherGarbage[5] := Field2E.GetValue;
   end;
end; {FormToRecord}

procedure InitFields;
{Initializes all of the field objects}
begin
   F1Key.Init(315,help);
   PgDnKey.Init(337,Stop2);
   PgUpKey.Init(329,Stop3);
   UpKey.Init(328,PrevField);
   DownKey.Init(336,NextField);
   with Page1But do
   begin
     Init(10,23,'  Page ~1~   ',Stop1);
     SetID(101);
     SetHotkey(376);
     SetMessage(MsgX,MsgY,'Edit page one data');
   end;
   with Page2But do
   begin
     Init(10,23,'  Page ~2~   ',Stop1);
     SetID(102);
     SetHotkey(377);
     SetMessage(MsgX,MsgY,'Edit page two data');
   end;
   with OKBut do
   begin
     Init(25,23,'    ~O~K    ',Finished);
     SetID(103);
     SetHotkey(280);
     SetMessage(MsgX,MsgY,'Save input to database');
   end;
   with CancelBut do
   begin
     Init(40,23,'  ~C~ancel  ',Escaped);
     SetID(104);
     SetHotkey(302);
     SetMessage(MsgX,MsgY,'Abort and go home');
   end;
   with HelpBut do
   begin
     Init(55,23,'   ~H~elp   ',Help);
     SetID(HelpID);
     SetHotkey(291);
     SetMessage(MsgX,MsgY,'Seek further guidance from the machine!');
   end;
   with FirstLastField do
   begin
     Init(25,4,40);
     SetID(1);
     SetForceCase(true);
     SetCase(Upper);
     SetLabel('Customer Name');
     SetMessage(MsgX,MsgY,'Name in FIRST M. LAST format');
   end;
   with CompanyField do
   begin
     Init(25,5,40);
     SetID(2);
     SetLabel('Company');
     SetMessage(MsgX,MsgY,'Enter the FULL company name');
   end;
   with Addr1Field do
   begin
     Init(25,6,40);
     SetID(3);
     SetLabel('Address');
     SetMessage(MsgX,MsgY,'Street address only no PO BOXES!');
   end;
   with Addr2Field do
   begin
     Init(25,7,40);
     SetID(4);
     SetMessage(MsgX,MsgY,'Add second line if necessary.');
   end;
   with CityField do
   begin
     Init(25,8,25);
     SetID(5);
     SetLabel('City');
     SetMessage(MsgX,MsgY,'Enter the City name');
   end;
   with StateField do
   begin
     Init(25,9,20);
     SetID(6);
     SetForceCase(true);
     SetCase(Upper);
     SetLabel('State');
     SetMessage(MsgX,MsgY,'Enter the State, Province or County');
   end;
   with ZipField do
   begin
     Init(55,9,'#####-####');
     SetID(7);
     SetLabel('Zip');
     SetMessage(MsgX,MsgY,'Enter the 9 digit ZIP or postal code');
   end; 
   with CountryField do
   begin
     Init(25,10,30);
     SetID(8);
     SetForceCase(true);
     SetCase(Upper);
     SetLabel('Country');
     SetMessage(MsgX,MsgY,'Leave empty for USA customers');
   end;
   with TelField do
   begin
     Init(25,12,'(###) ###-####');
     SetID(9);
     SetLabel('Telephone');
     SetMessage(MsgX,MsgY,'Leave empty for international customers');
   end;
   with OrderDateField do
   begin
     Init(25,14,MMDDYY);
     SetID(10);
     SetLabel('Order date');
     SetRules(EraseDefault+AllowNull);
     SetMessage(MsgX,MsgY,'Enter date in format MM/DD/YY');
   end;
   with OrderQuantityField do
   begin
     Init(45,14,2);
          SetID(11);
     SetMinMax(1,15);
     SetLabel('Quantity');
     SetRules(EraseDefault+AllowNull);
     SetMessage(MsgX,MsgY,'Enter number of units ordered');
   end;
   with UnitPriceField do
   begin
     Init(59,14,3,2);
     SetID(12);
     SetMinMax(10.0,499.99);
     SetLabel('Price');
     SetRules(EraseDefault+AllowNull);
     SetMessage(MsgX,MsgY,'Enter price per item');
   end;
   with Field2A do
   begin
     Init(25,4,40);
     SetID(21);
     SetLabel('Field A');
     SetMessage(MsgX,MsgY,'Enter the Field A data');
   end;
   with Field2B do
   begin
     Init(25,7,40);
     SetID(22);
     SetLabel('Field B');
     SetMessage(MsgX,MsgY,'Enter the Field B data');
   end;
   with Field2C do
   begin
     Init(25,10,40);
     SetID(23);
     SetLabel('Field C');
     SetMessage(MsgX,MsgY,'Enter the Field C data');
   end;
   with Field2D do
   begin
     Init(25,13,40);
     SetID(24);
     SetLabel('Field D');
     SetMessage(MsgX,MsgY,'Enter the Field D data');
   end;
   with Field2E do
   begin
     Init(25,16,40);
     SetID(25);
     SetLabel('Field E');
     SetMessage(MsgX,MsgY,'Enter the Field E data');
   end;
   Controlkeys.Init;
   with Page1 do
   begin
     Init;
     AddItem(Controlkeys);
     AddItem(F1Key);
     AddItem(PgDnkey);
     AddItem(Upkey);
     AddItem(Downkey);
     AddItem(FirstLastField);
     AddItem(CompanyField);
     AddItem(Addr1Field);
     AddItem(Addr2Field);
     AddItem(CityField);
     AddItem(StateField);
     AddItem(ZipField);
     AddItem(CountryField);
     AddItem(TelField);
     AddItem(OrderDateField);
     AddItem(OrderQuantityField);
     AddItem(UnitPriceField);
     AddItem(Page2But);
     AddItem(OKBut);
     AddItem(CancelBut);
     AddItem(HelpBut);
     SetHelpHook(ContexturalHelp);
   end;
   with Page2 do
   begin
      Init;
      AddItem(Controlkeys);
      AddItem(PgUpKey);
      AddItem(UpKey);
      AddItem(DownKey);
      AddItem(F1Key);
      AddItem(Field2A);
      AddItem(Field2B);
      AddItem(Field2C);
      AddItem(Field2D);
      AddItem(Field2E);
      AddItem(Page1But);
      AddItem(OKBut);
      AddItem(CancelBut);
      AddItem(HelpBut);
      SetHelpHook(ContexturalHelp);
    end;
end; {InitFields}

procedure SetUpScreen;
{}
begin
   with Screen do
   begin
      {use the color settings used in the IO for}
      TitledBox(1,1,80,21,
                IOTOT^.LabelCol(3),
                IOTOT^.LabelCol(4),
                IOTOT^.LabelCol(3),
                1,' TechnoJock''s Two-Page Form Demo ');
      PartClear(1,22,80,25,IOTOT^.FieldCOL(2),' ');
   end;
end; {SetUpScreen}

procedure SwitchActivePage;
{}
begin
   Screen.PartClear(2,2,79,20,IOTOT^.FieldCOL(4),' ');
   if ActivePage = 1 then
   begin
      Page2.SetActiveItem(21);
      ActivePage := 2;
   end
   else
   begin
      Page1.SetActiveItem(1);
      ActivePage := 1;
   end;
   Screen.WritePlain(5,2,'Page '+IntToStr(ActivePage));
end; {SwitchActivePage}

begin  {main program}
   InitFields;
   SetUpScreen;
   ActivePage := 1;
   repeat
      if ActivePage = 1 then
         Result := Page1.Go
      else
         Result := Page2.Go;
      case Result of
        Stop1: SwitchActivePage;
        Stop2: SwitchActivePage;
        Stop3: SwitchActivePage;
        Finished: begin
           FormToRecord;
           {update database...etc.}
        end;    
      end;
   until Result in [Finished,Escaped];
   clrscr;
   {dispose of objects if not end of prog}
end.
