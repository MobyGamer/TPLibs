program tot_Browse;

  { This demo program written using substantial portions of the   }
  { Technojock Object Toolkit in order to demonstrate how various }
  { objects and their methods can be integrated.                  }
  {                                                               }
  { Copyright 1991 by George L. Butts  Small Systems Development  }
  {                                    Springfield, Oregon        }
  { This and other programs utilizing TOT can be found on         }
  { The Buffer Board, a public BBS specializing in support of     }
  { programmers at (503) 747-7636  300-14400 Baud  24 hours       }

  uses
    Dos, Crt, totLink, totList, totInput, totDir, totIO1, totFast,
    totMsg, Printer, totMisc, totDate, totStr, totWin, totLook;

  var
    MyScreen    : WinObj;
    OldX        : Byte;
    OldY        : Byte;
    FileList    : StrDLLObj;
    LineNo      : Word;
    PageNo      : Word;
    WinActive   : Boolean;
    InFile      : Text;
    Line        : String;
    RetCode     : Integer;
    I           : Integer;
    FName       : String;
    BrowseList  : BrowseLinkObj;
    DirWin      : DirWinObj;
    Result      : tAction;

{$F+}
  procedure Error_Message( Line : String );
    Var
      MsgWin  : ButtonMessageObj;
    begin
      With MsgWin do
        begin
          Init(1,' Error ' );
          AddLine('');
          AddLine( Line );
          AddLine('');
          Show;
          Done;
        end;
    end;

  Procedure LoadFile( FName : String; Var LList : StrDLLObj );
    begin
      Assign( InFile , FName );
      Reset( InFile );
      With LList do
        begin
          Init;
          RetCode := 0;
          While (NOT EOF(InFile)) AND (RetCode = 0) do
            begin
              ReadLn(InFile,Line);
              RetCode := Add(Line);
            end;
        end;
      If RetCode = 2
        then
          Error_Message( 'Unable to Load Entire File' );
      Close(InFile);
    end;

  Procedure SelectFile( Var FName : String; Var Result : tAction );
    begin
      DirWin.Init;
      DirWin.Win^.SetColors(112,112,113,112);   { Set the Directory window colors}
      DirWin.SetFileDetails('','*.pas',Archive);
      With IOTot^ do
        begin
          SetColLabel(120,113,112,113);
          SetColList(63,23,31,127);
          SetColField(23,31,23,23);
          SetColButton(23,26,31,26);
          SetColMsg(116);
        end;
      Result := DirWin.Go;
      If Result = Finished
        then
          FName := DirWin.GetChosenFile
        else
          FName := '';
      DirWin.Done;
    end;

  Procedure Display_Date_Time;
    begin
      with Screen do
      begin
         SetWinIgnore(true);
         WriteAt(2,25,112,FancyDateStr(TodayInJul,False,False));
         WriteRight(79,25,112,CurrentTime);
         SetWinIgnore(false);
      end;
    end;

  Procedure Display_Interface;
    begin
      With MyScreen do
        begin
          LookTot^.SetWindow(112,112,113,113);
          Init;
          SetSize(1,1,80,25,0);
          Setcolors(23,23,23,23);
          SetClose(False);
          SetRemove(True);
          Draw;
          With Screen do
            begin
              CursOff;
              Box(1,2,80,24,23,1);
              Attrib(1,1,80,1,112);
              Attrib(1,25,80,25,112);
              WriteBetween(1,80,1,112,'t o t B r o w s e');
            end;
        end;
    end;


  Procedure NewPage;
    begin
      Inc(PageNo);
      WriteLn(Lst);
      WriteLn(Lst,PadLeft(SetProper(FileName(FName)) + '.' +
                  SetProper(FileExt(FName)),20,' ') +
                  PadCenter(FancyDateStr(TodayInJul,True,False),35,' ') +
                  PadRight(CurrentTime,20,' ') );
      WriteLn(Lst,Replicate(75,'_'));
      WriteLn(Lst);
      LineNo := 4;
    end;

  Procedure FinishPage;
    begin
      WriteLn(Lst,Replicate(75,'_'));
      WriteLn(Lst,'Small Systems Development' + Replicate(42,' ') + 'Page: '
                   + PadRight(IntToStr(PageNo),2,' ') );
      WriteLn(Lst,Chr(12));
    end;

  Procedure Print_Line( Line : String );
    begin
      Inc(LineNo);
      If LineNo = 62
        then
          begin
            FinishPage;
            NewPage;
          end;
      WriteLn(Lst, Squeeze('R',Line,76) );
    end;

  Procedure Print_File_Listing;
    Var
      I  : Word;
    begin
      NewPage;
      With FileList do
        begin
          For I := 1 to TotalNodes do
            Print_Line( GetStr(NodePtr(I),0,0) );
        end;
      For I := LineNo to 61 do
        WriteLn(Lst);
      FinishPage;
    end;

  Procedure KeyPressedProcedure( Var KeyVal : Word );
    begin
      Case KeyVal of
        317 : begin     {  F3 - Load a different File }
                SelectFile( FName , Result );
                If Result = Finished
                  then
                    begin
                      LoadFile( FName , FileList );
                      BrowseList.AssignList(FileList);
                      BrowseList.SetTopPick(2);
                      KeyVal := 329;
                    end;
              end;
        321 : begin     {  F7 - Print File            }
                Print_File_Listing;
              end;
      end;
    end;
{$F-}


  begin
    OldX := WhereX;
    OldY := WhereY;
    PageNo := 0;
    LineNo := 0;
    Key.AssignIdleHook( Display_Date_Time );
    Key.setFast;
    Shadowtot^.SetShadowSize(0,0);
    Display_Interface;
    SelectFile( FNAme , Result );
    If FName <> ''
      then
        begin
          LoadFile( FName , FileList );
          Key.AssignPressedHook( KeypressedProcedure );
          With BrowseList do
            begin
              Init;
              Win^.SetAllowStretch(False);
              Win^.SetBoundary(1,2,80,24);
              Win^.SetSize(1,2,80,24,1);
              Win^.SetMinSize(80,23);
              Win^.SetColors(31,31,31,18);
              AssignList( FileList );
              Go;
              Done;
            end;
          FileList.Done;
        end;
    MyScreen.Done;
    ResetStartUpMode;
  end.
