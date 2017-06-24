program DemoIOTwentyOne;
{demIO21 - This example illustrates how you could use the
 Toolkit to develop a database application}

Uses DOS, CRT,
     totFAST, totREAL, totIO1, totIO2, totIO3, totSTR, totDATE, totMSG;

Const
   MsgX=1;
   MsgY=25;
Type                   
Comments = array[1..7] of string[50];

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
   Info: Comments;
end;

Var
  ActiveRecord: RecordInfo;
  Browsing: boolean;
  Totalrecords: longint;
  RecordNumber:integer;
  Result: tAction;
  {Now the input fields}
  NextBut,PrevBut,EditBut,AddBut,SaveBut, QuitBut,HelpBut: Strip3DIOOBJ;
  FirstLastField,
  CompanyField,
  Addr1Field,
  Addr2Field,
  CityField,
  StateField,
  CountryField: StringIOOBJ;
  ZipField,
  TelField: PictureIOOBJ;
  OrderDateField: DateIOOBJ;
  OrderQuantityField: IntIOOBJ;
  UnitPriceField: FixedRealIOOBJ;
  InfoField: WWArrayIOOBJ;
  Controlkeys: ControlKeysIOOBJ;
  Manager: FormOBJ;

{|||||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                         }
{     D a t a b a s e   A c c e s s   R o u t i n e s     }
{                                                         }
{|||||||||||||||||||||||||||||||||||||||||||||||||||||||||}

function LoadRecord(RecNo:longint; var Rec:RecordInfo):boolean;
{This function would be responsible for getting the information from
 the data base file, and might return a boolean to indicate if the 
 operation was a success. 

 In this template, the function simply loads TechnoJock's details
 in the record.}
begin
   fillchar(Rec,sizeof(Rec),#0);
   with Rec do
   case RecNo of
      1: begin
         FirstLast :=  'Bob Ainsbury';
         Company := 'TechnoJock Sofware, Inc.';
         Addr1 := 'PO Box 820927';
         Addr2 := '';
         City :=  'Houston';
         State := 'TX';
         Zip := '77282';
         Country := '';
         Tel := '7134936354';
         OrderDate := GregtoJul(2,11,1991);
         OrderQuantity := 7;
         UnitPrice := 89.95;
         Info[1] := 'Just a few comments about the good balance ';
         Info[2] := 'between ease of use and power. He intends to ';
         Info[3] := 'use the Toolkit to build an employee system. ';
      end;
      2: begin
         FirstLast :=  'Joe Cholesterol';
         Company := 'The Heffer Restaurant';
         Addr1 := '1101 Old Spanish Trail';
         Addr2 := 'The Heights';
         City :=  'El Paso';
         State := 'TX';
         Zip := '73008';
         Country := '';
         Tel := '6884946324';
         OrderDate := GregtoJul(2,13,1991);
         OrderQuantity := 1;
         UnitPrice := 89.95;
         Info[1] := 'Joe said he wants to use the Toolkit to keep ';
         Info[2] := 'track of his beef in the meat lockers. ';
      end;
      3: begin
         FirstLast :=  'Mr T Vision';
         Company := 'Borland International';
         Addr1 := '1800 Green Hills Road';
         Addr2 := 'PO Box 660001';
         City :=  'Scotts Valley';
         State := 'CA';
         Zip := '950670001';
         Country := '';
         OrderDate := GregtoJul(2,20,1991);
         OrderQuantity := 11;
         UnitPrice := 89.95;
         Info[1] := 'No comments';
      end;
   end; {case}
   LoadRecord := true;
end; {LoadRecord}

function AddRecord(Rec:RecordInfo): boolean;
{Saves a new record to the database, and returns true
 if successful. In this template, there is no disk access.}
begin
   {your record saving code would go here}
   AddRecord := true;
end; {AddRecord}
  
function ModifyRecord(RecNo:longint; Rec:RecordInfo):boolean;
{Changes the value of a record in the database, and returns true
 if successful. In this template, there is no disk access.}
begin
   ModifyRecord := true;
end; {ModifyRecord}
{|||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                 }
{     S c r e e n   F o r m   R o u t i n e s     }
{                                                 }
{|||||||||||||||||||||||||||||||||||||||||||||||||}
procedure RecordToForm;
{Updates the form objects with the contents of the record - a more efficient
 way would be to use MOVE, but let's not get too fancy for the demo}
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
      InfoField.AssignList(Info,7,50);
      InfoField.WrapFull; 
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
   end;
end; {FormToRecord}

procedure InitFields;
{Initializes all of the field objects}
begin
  with NextBut do
  begin
     Init(69,5,'  ~N~ext  ',Stop1);
     SetID(100);
     SetHotkey(305);
     SetMessage(MsgX,MsgY,'View the next record in the database');
  end;
  with PrevBut do
  begin
     Init(69,7,'  ~P~rev  ',Stop2);
     SetID(101);
     SetHotkey(281);
     SetMessage(MsgX,MsgY,'View the previous record in the database');
  end;
  with EditBut do
  begin
     Init(69,9,'  ~E~dit  ',Stop3);
     SetID(102);
     SetHotkey(274);
     SetMessage(MsgX,MsgY,'Modify the contents of this record');
  end;
  with AddBut do
  begin
     Init(69,11,'  ~A~dd   ',Stop4);
     SetID(103);
     SetHotkey(286);
     SetMessage(MsgX,MsgY,'Add a new record to the database');
  end;
  with SaveBut do
  begin
     Init(69,13,'  ~S~ave  ',Stop5);
     SetID(104);
     SetHotkey(287);
     SetMessage(MsgX,MsgY,'Save the new record to the database');
  end;
  with QuitBut do
  begin
     Init(69,15,'  ~Q~uit  ',Finished);
     SetID(105);
     SetHotkey(272);
     SetMessage(MsgX,MsgY,'Stop this nonsense and go home');
  end;
  with HelpBut do
  begin
     Init(69,17,'  ~H~elp  ',Help);
     SetID(HelpID);
     SetHotkey(291);
     SetMessage(MsgX,MsgY,'Seek further guidance from the machine!');
  end;
  with FirstLastField do
  begin
     Init(20,4,40);
     SetID(1);
     SetForceCase(true);
     SetCase(Upper);
     SetLabel('Customer Name');
     SetMessage(MsgX,MsgY,'Name in FIRST M. LAST format');
  end;
  with CompanyField do
  begin
     Init(20,5,40);
     SetID(2);
     SetLabel('Company');
     SetMessage(MsgX,MsgY,'Enter the FULL company name');
  end;
  with Addr1Field do
  begin
     Init(20,6,40);
     SetID(3);
     SetLabel('Address');
     SetMessage(MsgX,MsgY,'Street address only no PO BOXES!');
  end;
  with Addr2Field do
  begin
     Init(20,7,40);
     SetID(4);
     SetMessage(MsgX,MsgY,'Add second line if necessary.');
  end;
  with CityField do
  begin
     Init(20,8,25);
     SetID(5);
     SetLabel('City');
     SetMessage(MsgX,MsgY,'Enter the City name');
  end;
  with StateField do
  begin
     Init(20,9,20);
     SetID(6);
     SetForceCase(true);
     SetCase(Upper);
     SetLabel('State');
     SetMessage(MsgX,MsgY,'Enter the State, Province or County');
  end;
  with ZipField do
  begin
     Init(50,9,'#####-####');
     SetID(7);
     SetLabel('Zip');
     SetMessage(MsgX,MsgY,'Enter the 9 digit ZIP or postal code');
  end; 
  with CountryField do
  begin
     Init(20,10,30);
     SetID(8);
     SetForceCase(true);
     SetCase(Upper);
     SetLabel('Country');
     SetMessage(MsgX,MsgY,'Leave empty for USA customers');
  end;
  with TelField do
  begin
     Init(20,12,'(###) ###-####');
     SetID(9);
     SetLabel('Telephone');
     SetMessage(MsgX,MsgY,'Leave empty for international customers');
  end;
  with OrderDateField do
  begin
     Init(20,14,MMDDYY);
     SetID(10);
     SetLabel('Order date');
     SetRules(EraseDefault);
     SetMessage(MsgX,MsgY,'Enter date in format MM/DD/YY');
  end;
  with OrderQuantityField do
  begin
     Init(40,14,2);
     SetID(11);
     SetMinMax(1,15);
     SetLabel('Quantity');
     SetRules(EraseDefault);
     SetMessage(MsgX,MsgY,'Enter number of units ordered');
  end;
  with UnitPriceField do
  begin
     Init(54,14,3,2);
     SetID(12);
     SetMinMax(10.0,499.99);
     SetLabel('Price');
     SetRules(EraseDefault);
     SetMessage(MsgX,MsgY,'Enter price per item');
  end;
  with InfoField do
  begin
     Init(7,16,54,7,'Comments');
     SetID(13);
     SetMessage(MsgX,MsgY,'Enter any comments (especially praise)');
  end;
  Controlkeys.Init;
  with Manager do
  begin
     Init;
     AddItem(Controlkeys);
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
     AddItem(InfoField);
     AddItem(NextBut);
     AddItem(PrevBut);
     AddItem(EditBut);
     AddItem(AddBut);
     AddItem(SaveBut);
     AddItem(QuitBut);
     AddItem(HelpBut);
   end;
end; {InitFields}

procedure SetForBrowse(On:boolean);
{DeActivates all the edit files and enables browsing files, or vica versa}
begin
   FirstLastField.SetActiveStatus(not On);
   CompanyField.SetActiveStatus(not On);
   Addr1Field.SetActiveStatus(not On);
   Addr2Field.SetActiveStatus(not On);
   CityField.SetActiveStatus(not On);
   StateField.SetActiveStatus(not On);
   ZipField.SetActiveStatus(not On);
   CountryField.SetActiveStatus(not On);
   TelField.SetActiveStatus(not On);
   OrderDateField.SetActiveStatus(not On);
   OrderQuantityField.SetActiveStatus(not On);
   UnitPriceField.SetActiveStatus(not On);
   InfoField.SetActiveStatus(not On);
   NextBut.SetActiveStatus(On);
   PrevBut.SetActiveStatus(On);
   EditBut.SetActiveStatus(On);
   AddBut.SetActiveStatus(On);
   SaveBut.SetActiveStatus(not On);
   if On then
      Manager.SetActiveItem(100)
   else
      Manager.SetActiveItem(1);
end; {SetForBrowse}
{|||||||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                       }
{     S c r e e n   D i s p l a y   R o u t i n e s     }
{                                                       }
{|||||||||||||||||||||||||||||||||||||||||||||||||||||||}
procedure DisplayRecordNumber;
{}
begin
   Screen.WriteAt(2,2,CAttr(lightgray,battr(IOTOT^.LabelCol(3))),
                  'Record: '+IntToStr(RecordNumber)+'  ');
end; {DisplayRecordNumber}

procedure DisplayStatus;
{}
begin
   if Browsing then
      Screen.WritePlain(67,3,'Browse Mode')
   else
      Screen.WritePlain(67,3,'Edit Mode  ');
end; {DisplayStatus}

procedure SetUpScreen;
{}
begin
   with Screen do
   begin
      {use the color settings used in the IO form}
      TitledBox(1,1,80,24,
                IOTOT^.LabelCol(3),
                IOTOT^.LabelCol(4),
                IOTOT^.LabelCol(3),
                1,' TechnoJock''s Database Demo ');
      PartClear(1,25,80,25,IOTOT^.FieldCOL(2),' ');
      SmartVertLine(65,1,24,IOTOT^.LabelCol(3),1);
   end;
end; {SetUpScreen}

procedure SaveIt;
{mock up of a save}
var Msg : MessageOBJ;
begin
   with Msg do
   begin
      Init(1,' Record Saved ');
      WinForm^.Win^.SetColors(23,31,30,28);
      AddLine('');
      AddLine(' In a real application, your edits would now ');
      AddLine(' be saved in the database. Just imagine that ');
      AddLine(' it happened!');
      AddLine('');
      AddLine(' We will now go back into database browse mode. ');
      AddLine('');
      Show;
      Done;
   end;
   RecordNumber := 1;
   Browsing := true;
   SetForBrowse(browsing);
   if LoadRecord(RecordNumber,ActiveRecord) then
      RecordToForm;
end; {Saveit}
{||||||||||||||||||||||||||||||||||}
{                                  }
{     M a i n    P r o g r a m     }
{                                  }
{||||||||||||||||||||||||||||||||||}

begin
   RecordNumber := 1;
   TotalRecords := 3;  {normally you would get this data by polling the d/b}
   Browsing := true;
   InitFields;
   if LoadRecord(RecordNumber,ActiveRecord) then
      RecordToForm;
   SetForBrowse(browsing);
   SetUpScreen;
   repeat
      DisplayRecordNumber;
      DisplayStatus;
      Result := Manager.Go;
      case Result of
         Stop1: begin
            if RecordNumber < TotalRecords then
               Inc(RecordNumber)
            else
               RecordNumber := 1;
            if LoadRecord(RecordNumber,ActiveRecord) then
               RecordToForm;
         end;
         Stop2: begin
            if RecordNumber > 1 then
               dec(RecordNumber)
            else
               RecordNumber := TotalRecords;
            if LoadRecord(RecordNumber,ActiveRecord) then
               RecordToForm;
         end;
         Stop3: begin
            Browsing := false;
            SetForBrowse(Browsing);
         end;
         Stop4: begin
            Browsing := false;
            SetForBrowse(Browsing);
            RecordNumber := succ(TotalRecords);
            Fillchar(ActiveRecord,sizeof(ActiveRecord),#0);
            with ActiveRecord do
            begin
               OrderDate := TodayInJul;
               OrderQuantity := 11;
               UnitPrice := 89.95;
            end;
            RecordToForm;
         end;
         Stop5: begin
            SaveIt;
         end;
      end; {case}
   until Result in [Finished,Escaped];
   clrscr;
   {dispose of objects if not end of prog}
end.

