Program Create_Telephone_Labels;

  { This demo program written using substantial portions of the   }
  { Technojock Object Toolkit in order to demonstrate how various }
  { objects and their methods can be integrated.                  }
  {                                                               }
  { Copyright 1991 by George Bean                                 }

Uses Dos, Crt, Printer,

         TOTDATE,
         TOTDIR,
         TOTFAST,
         TOTINPUT,
         TOTIO1,
         TOTIO2,
         TOTIO3,
         TOTLINK,
         TOTLIST,
         TOTLOOK,
         TOTMISC,
         TOTMSG,
         TOTREAL,
         TOTSTR,
         TOTSYS,
         TOTWIN;

Var ExitWindow             : PromptOBJ;
    PreviewMsg             : MessageOBJ;
    LabelType, Fmtype      : RadioIOOBJ;
    Manager                : FormOBJ;
    IncludeExten           : CheckIOOBJ;
    Screen1                : ScreenOBJ;
    Result, ExitCode       : tAction;
    Preview, Cancel, Print : Strip3DIOOBJ;
    Keys                   : ControlKeysIOOBJ;
    AmountToPrint          : IntIOOBJ;
    MainPhone,
    FirstPhone, LastPhone,
    FirstExten, LastExten  : PictureIOOBJ;
    FP_Int,     LP_Int,
    FE_Int,     LE_Int,
    CurrentExt, X          : Integer;

Procedure DisposeVars;
Begin
  LabelType.Done;
  FmType.Done;
  IncludeExten.Done;
  MainPhone.Done;
  FirstPhone.Done;
  LastPhone.Done;
  FirstExten.Done;
  LastExten.Done;
  Preview.Done;
  Cancel.Done;
  Print.Done;
  Manager.Done;
End;

Procedure InitForm;
Begin
  IOTOT^.SetColField(113,7,15,120);
  IOTOT^.SetColLabel(48,62,63,62);
  With LabelType Do
  Begin
    Init(10,9,15,3,'');
    SetID(1);
    AddItem('~S~tandard',83,True);
    AddItem('~D~ID',68,False);
    AddItem('~E~xt Only',69,False);
    SetMessage(19,22,' to point, SPACE BAR to select label type');
  End;
  With MainPhone Do
  Begin
    Init(50,9,'(###) ###-####');
    SetLabel(' ~M~ain Number ');
    SetHotKey(77);
    SetID(2);
    SetActiveStatus(True);
    SetMessage(22,22,'Enter the TEN DIGIT telephone number');
  End;
  Keys.Init;
  With FirstPhone Do
  Begin
    Init(50,11,'(###) ###-####');
    SetLabel('  ~F~irst DID  ');
    SetHotKey(70);
    SetID(3);
    SetMessage(19,22,'Enter the First TEN DIGIT telephone number');
  End;
  With LastPhone Do
  Begin
    Init(50,13,'(###) ###-####');
    SetLabel('   ~L~ast DID  ');
    SetHotKey(76);
    SetID(4);
    SetMessage(19,22,'Enter the Last TEN DIGIT telephone number');
  End;
  With FirstExten Do
  Begin
    Init(50,15,'#####');
    SetLabel('  Firs~t~ Ext  ');
    SetHotKey(84);
    SetID(5);
    SetMessage(23,22,'Enter the FIRST extension to print');
  End;
  With LastExten Do
  Begin
    Init(50,17,'#####');
    SetLabel('   L~a~st Ext  ');
    SetHotKey(65);
    SetID(6);
    SetMessage(23,22,'Enter the LAST extension to print');
  End;
  With IncludeExten Do
  Begin
    Init(10,13,15,1,'');
    SetID(7);
    AddItem('~I~nclude Ext',73,True);
    SetMessage(18,22,'Press SPACE BAR to include extension number');
  End;
  With AmountToPrint Do
  Begin
    Init(21,18,4);
    InitFormat;
    SetMinMax(0,9999);
    SetLabel('  Amount  ');
    SetMessage(20,22,'Enter the number of labels to be printed');
  End;
  With FmType Do
  Begin
    Init(10,15,15,3,'');
    AddItem('Ext ~O~ver',79,False);
    AddItem('Ext ~U~nder',85,True);
    SetMessage(18,22,' to point, SPACE BAR to select label format');
  End;
  Preview.Init(24,20,' Pre~v~iew ',Stop1);
  Preview.SetHotkey(86);
  Print.Init(37,20,' ~P~rint ',Finished);
  Print.SetHotkey(80);
  Cancel.Init(48,20,' ~C~ancel ',Escaped);
  Cancel.SetHotkey(67);
End;

Procedure DoMenuSelection;
Begin
  With Manager Do
  Begin
    Init;
    Screen.ShadFillBox(5,7,75,23,78,2);
    Screen.WriteBetween(5,75,7,79,'  L A B E L    D E S C R I P T I O N  ');
    AddItem(LabelType);
    AddItem(IncludeExten);
    AddItem(MainPhone);
    AddItem(FirstPhone);
    AddItem(LastPhone);
    AddItem(FirstExten);
    AddItem(LastExten);
    AddItem(FmType);
    AddItem(AmountToPrint);
    AddItem(Preview);
    AddItem(Print);
    AddItem(Cancel);
    AddItem(Keys);
    Result := Go;
  End;
End;

Procedure PrintLabels;
Begin
  Write(LST,#27#71);     { Set LQ mode }
  Case LabelType.GetValue Of
    1 : Begin    { Standard Labels }
          If IncludeExten.GetValue(1) Then
          Begin
            If ( FmType.GetValue = 1 ) Then
            Begin   { Standard with ext over }
              CurrentExt := StrToInt(FirstExten.GetValue);
              Repeat
                Writeln(LST,'   Ext ',CurrentExt);
                Writeln(LST,MainPhone.GetPicValue);
                Writeln(LST);
                Inc(CurrentExt);
              Until CurrentExt = ( StrToInt(LastExten.GetValue) + 1 );
            End
            Else
            Begin   { Standard with ext under }
              CurrentExt := StrToInt(FirstExten.GetValue);
              Repeat
                Writeln(LST,MainPhone.GetPicValue);
                Writeln(LST,'   Ext ',CurrentExt);
                Writeln(LST);
                Inc(CurrentExt);
              Until CurrentExt = ( StrToInt(LastExten.GetValue) + 1 );
            End;
          End
          Else     { Did not include extension }
          Begin
            For X := 1 to AmountToPrint.GetValue Do
            Begin
              Writeln(LST,MainPhone.GetPicValue);
              Writeln(LST);
              Writeln(LST);
            End;
          End;
        End;
    2 : Begin      { DID Labels }
          FP_Int := StrToInt(Copy(FirstPhone.GetValue,7,4));
          LP_Int := StrToInt(Copy(LastPhone.GetValue,7,4));
          FE_Int := StrToInt(FirstExten.GetValue);
          LE_Int := StrToInt(LastExten.GetValue);
          If IncludeExten.GetValue(1) Then
          Begin
            If ( FmType.GetValue = 1 ) Then
            Begin   { DID with Ext over }
              For X := FP_Int to LP_Int Do
              Begin
                Writeln(LST,'   Ext ',FE_Int);
                Writeln(LST,Copy(FirstPhone.GetPicValue,1,10),X);
                Writeln(LST);
                Inc(FE_Int);
              End;
            End
            Else
            Begin   { DID with Ext under }
              For X := FP_Int to LP_Int Do
              Begin
                Writeln(LST,Copy(FirstPhone.GetPicValue,1,10),X);
                Writeln(LST,'   Ext ',FE_Int);
                Writeln(LST);
                Inc(FE_Int);
              End;
            End;
          End
          Else
          Begin
            For X := FP_Int to LP_Int Do
            Begin
              Writeln(LST,Copy(FirstPhone.GetPicValue,1,10),X);
              Writeln(LST);
              Writeln(LST);
            End;
          End;
        End;
    3 : Begin      { Extension Only }
          FE_Int := StrToInt(FirstExten.GetValue);
          LE_Int := StrToInt(LastExten.GetValue);
          For X := FE_Int to LE_Int Do
          Begin
            Writeln(LST,'   Ext ',X);
            Writeln(LST);
            Writeln(LST);
          End;
        End;
  End; { Case }
  Write(LST,#27#72);  { Cancel LQ mode }
End;

Begin
  Screen.Clear(3,'²');
  LookTOT^.SetWindow(31,23,30,30);
  ShadowTOT^.SetShadowStyle(DownRight,7,'°');
  Screen.ShadFillBox(5,2,75,4,31,4);
  Screen.WriteBetween(5,75,3,30,'T E L E P H O N E      L A B E L      D E S I G N E R');
  InitForm;
  Repeat
    DoMenuSelection;
    Case Result Of
      Finished : Begin     { OK to Print }
                   PrintLabels;
                 End;
      Stop1    : Begin     { Preview first and last label }
                   Screen1.Init;
                   Screen1.Save;
                   Screen.PartClear(5,7,77,24,3,'²');
                   If ( LabelType.GetValue = 3 ) Then   { Extension Only }
                   Begin
                     Screen.ShadFillBox(14,8,31,10,78,1);
                     Screen.ShadFillBox(50,8,67,10,78,1);
                   End
                   Else
                   If IncludeExten.GetValue(1) Then  { Yes, Include Extension }
                   Begin
                     Screen.ShadFillBox(14,8,31,11,78,1);
                     Screen.ShadFillBox(50,8,67,11,78,1);
                   End
                   Else                              { No, Exclude Extension }
                   Begin
                     Screen.ShadFillBox(14,8,31,10,78,1);
                     Screen.ShadFillBox(50,8,67,10,78,1);
                   End;
                   Case LabelType.GetValue Of
                     1 : Begin    { Standard Labels }
                           If IncludeExten.GetValue(1) Then
                           Begin
                             If ( FmType.GetValue = 1 ) Then
                             Begin
                               Screen.WriteAT(19,9,79,'Ext '+FirstExten.GetValue);
                               Screen.WriteAT(55,9,79,'Ext '+LastExten.GetValue);
                               Screen.WriteAT(16,10,79,MainPhone.GetPicValue);
                               Screen.WriteAT(52,10,79,MainPhone.GetPicValue);
                             End
                             Else
                             Begin
                               Screen.WriteAT(16,9,79,MainPhone.GetPicValue);
                               Screen.WriteAT(52,9,79,MainPhone.GetPicValue);
                               Screen.WriteAT(19,10,79,'Ext '+FirstExten.GetValue);
                               Screen.WriteAT(55,10,79,'Ext '+LastExten.GetValue);
                             End;
                           End
                           Else     { Did not include extension }
                           Begin
                             Screen.WriteAT(16,9,79,MainPhone.GetPicValue);
                             Screen.WriteAT(52,9,79,MainPhone.GetPicValue);
                           End;
                         End;
                     2 : Begin      { DID Labels }
                           If IncludeExten.GetValue(1) Then
                           Begin
                             If ( FmType.GetValue = 1 ) Then
                             Begin
                               Screen.WriteAT(19,9,79,'Ext '+FirstExten.GetValue);
                               Screen.WriteAT(55,9,79,'Ext '+LastExten.GetValue);
                               Screen.WriteAT(16,10,79,FirstPhone.GetPicValue);
                               Screen.WriteAT(52,10,79,LastPhone.GetPicValue);
                             End
                             Else
                             Begin
                               Screen.WriteAT(16,9,79,FirstPhone.GetPicValue);
                               Screen.WriteAT(52,9,79,LastPhone.GetPicValue);
                               Screen.WriteAT(19,10,79,'Ext '+FirstExten.GetValue);
                               Screen.WriteAT(55,10,79,'Ext '+LastExten.GetValue);
                             End;
                           End
                           Else
                           Begin
                             Screen.WriteAT(16,9,79,FirstPhone.GetPicValue);
                             Screen.WriteAT(52,9,79,LastPhone.GetPicValue);
                           End;
                         End;
                     3 : Begin      { Extension Only }
                           Screen.WriteAT(19,9,79,'Ext '+FirstExten.GetValue);
                           Screen.WriteAT(55,9,79,'Ext '+LastExten.GetValue);
                         End;
                   End; { Case }
                   Screen.ShadFillBox(25,15,55,20,78,1);
                   Screen.WriteAT(27,16,71,'These labels represent the');
                   Screen.WriteAT(27,17,71,'first and last labels that');
                   Screen.WriteAT(27,18,71,'will be printed......');
                   Screen.WriteAT(30,20,79,' ENTER to continue. ');
                   Readln;
                   Screen1.Display;
                   Screen1.Done;
                 End;
      Escaped  : Begin     { Terminate program }
                   With ExitWindow Do
                   Begin
                     Init(1,' A L E R T ');
                     AddLine('');
                     AddLine(' You have chosen to leave the ');
                     AddLine('   Telephone Label Designer');
                     AddLine('');
                     AddLine('        Please confirm');
                     AddLine('');
                     SetOption(1,' ~P~roceed ',80,Finished);
                     SetOption(2,' ~A~bort ',65,Escaped);
                     ExitCode := Show;
                     Done;
                   End;
                 End;
    End;  { Case of Result }
  Until ExitCode = Finished;
  DisposeVars;
  Clrscr;
End.
