program TOTDEMO;
{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.00a                            }
{$M 16000,250000,250000}
{$I TOTFLAGS.INC}

{
    This is the main demo program, designed to show the capabilities
    of TechnoJock's Object Toolkit. The majority of the Toolkit demos
    are educational and illustrative, rather than flashy! This file
    combines many of the smaller demo programs and adds a touch of
    glamor. (If you're from New York, don't worry about the glamor!)
}

{  COMPILATION PROBLEMS:

   Memory:  1) Enable the FINAL directive in TOTFLAGS.INC
            2) Set Compile destination to disk
            3) Set Link to disk
            4) Set Link Mapfile off
            5) Trim your config.sys and remove TSRs
            6) Disable integrated and standalone debugging

            If you still have problems, run the command line
            compiler: TPC or TPCX

   File not found:   Update the Unit, Include and OBJ Options
                     Directories to point to the Toolkit
                     directory.

   Unit File Format Error:  Select Compile Build to force recompilation
                            of all Toolkit units.

}

uses DOS, CRT,
     totSYS, totINPUT, totFAST, totWIN, totMSG, totLINK,
     totLIST, totDIR, totIO1, totIO2, totIO3, totMENU,
     totSTR, totDATE, totMISC,
     extWIN;
var  MainMenu: MoveMenuOBJ;
     Choice: byte;
     SaveScreen: ScreenOBJ;

procedure Error(Line1,Line2:string);
{}
var PopUp:MessageOBJ;
begin
   with PopUp do
   begin
      Init(1,' Error ');
      AddLine('');
      AddLine(Line1);
      AddLine(Line2);
      AddLine('');
      Show;
      Done;
   end;
end; {Error}
{||||||||||||||||||||||||||||||||||}
{                                  }
{     I n t r o   S c r e e n      }
{                                  }
{||||||||||||||||||||||||||||||||||}
procedure Sparkle;
{}
var
  tempX,tempC:byte;
  I : integer;
begin
   with Key do
      with Screen do
      begin
          delay(1000);
          for I := 5 to 11 do
          begin
              if keypressed then exit;
              Attrib(5,I,78,I,yellow);
              delay(75);
          end;
          delay(500);
          for I := 13 to 18 do
          begin
              if keypressed then exit;
              Attrib(5,I,78,I,lightgreen);
              delay(75);
          end;
          for I := 1 to 80 do
          begin
              if keypressed then exit;
              Attrib(I,20,I,20,lightcyan);
              delay(15);
          end;
          repeat
               tempX := Random(27);
               TempC := Random(6);
               Inc(TempC,9);
               Attrib(27+tempX,2,27+tempX,2,TempC);
               TempX := Random(40);
               Attrib(20+tempX,20,20+tempX,20,TempC);
               delay(50);
          until Keypressed;
      end;
end; {Sparkle}

procedure Banner;
{}
var StartUp: ScreenOBJ;
begin
   with StartUp do
   begin
      Init;
      Create(80,25,white);
      Box(25,1,55,3,white,1);
      WriteAt(27,2,7,'TechnoJock''s Object Toolkit');
      WriteAT(5,5,15,'This program demonstrates the power of TechnoJock''s Object Toolkit for');
      WriteAT(5,6,15,'Borland''s Turbo Pascal v5.5 and v6.0 (on IBM and true compatibles).');
      WriteAT(5,7,15,'If you experience any difficulty using the product, please call or');
      WriteAt(5,8,15,'write to us. More information about the Toolkit is located in the');
      WriteAt(5,9,15,'README.COM file and in the documentation.');
      WriteAt(5,11,15,'For further information, contact:');
      WriteAt(30,13,15,'TechnoJock Software, Inc.');
      WriteAt(30,14,15,'P.O. Box 820927');
      WriteAT(30,15,15,'Houston, TX 77282');
      WriteAT(30,17,15,'Voice (713) 493-6354');
      WriteAT(30,18,15,'Fax   (713) 493-5872');
      WriteCenter(23,15,'Copyright (c) 1991 TechnoJock Software, Inc.');
      WriteCenter(24,15,'Restricted by License');
      SlideDisplay(down);
   end;
   Screen.CursOff;
   Screen.WriteRight(80,25,7,'Press any key to continue...');
   if not Key.Keypressed then
      Screen.WriteClick(20,20,white,'"In the Software business since Tuesday"');
   if Monitor^.ColorOn then
      Sparkle;
   Key.GetInput;
end; {Banner}

procedure Introduction;
{}
var
  PopUp: PromptOBJ;
  Result: tAction;
begin
   Screen.Clear(white,'°'); {paint the screen}
   with PopUp do
   begin
      Init(1,' TechnoJock''s Object Toolkit ');
      AddLine('');
      AddLine('   This is a demo of the Object Toolkit from   ');
      AddLine('   TechnoJock Software, Inc. Please do not ');
      AddLine('   run this demo while intoxicated! ');
      AddLine('');
      AddLine('       Would you like to see the demo? ');
      AddLine('');
      SetOption(1,'  Oh ~Y~es  ',89,Finished);
      SetOption(2,'  Hell ~N~o  ',78,Escaped);
      Result := Show;
      Done;
      if Result = Escaped then
      begin
         Writeln('Be like that!');
         halt;
      end;
   end;
   Banner;
end; {Introduction}
{|||||||||||||||||||||||||||||}
{                             }
{     M e n u   S t u f f     }
{                             }
{|||||||||||||||||||||||||||||}
procedure SetUpMenu;
{}
begin
   with MainMenu do
   begin
      Init;
      SetStyleTitle(6,' TechnoJock''s Object Toolkit ');
      SetMessageXY(0,24);
      SetGap(5);
      Win^.SetClose(false);
      Win^.SetBoundary(1,1,80,23);
      AddItem('');
      AddFullItem(' ~I~ntroduction               ',1,73,
                  'Displays a screen describing the main Toolkit features',nil);
      AddFullItem(' ~F~orm Input                 ',2,70,
                  'Get an idea of the power of the Toolkit''s form management facility',nil);
      AddFullItem(' Display ~D~irectories        ',3,68,
                  'Use the Toolkit''s directory display objects',nil);
      AddFullItem(' ~B~rowse Lists, etc.         ',4,66,
                  'Use the Toolkit''s browse and list objects',nil);
      AddFullItem(' Display ~M~enus              ',5,77,
                  'View Pull-down and Lotus-style menus',nil);
      AddFullItem(' ~S~trings and Dates          ',6,83,
                  'A description of some of the other fine units!',nil);
      AddFullItem(' ~H~ardware                   ',7,72,
                  'Using the totSYS unit to determine system hardware',nil);
      AddFullItem(' I~n~ternational Features     ',8,78,
                  'A description of the Toolkit''s international aspects',nil);
      AddFullItem(' ~V~iewing the "read me" file ',9,86,
                  'Displays all the late breaking news about the Toolkit',nil);
      AddFullItem(' ~P~rinting the documentation ',10,80,
                  'Information on how to print the User''s Manual',nil);
      AddFullItem(' P~u~rchasing the Toolkit     ',11,85,
                  'How to buy a copy of the Toolkit', nil);
      AddItem('');
      AddFullItem(' ~Q~uit                       ',99,81,
                  'Go do summat else',nil);
   end;
   Screen.PartClear(1,1,80,22,white,'°'); {paint the screen}
   Screen.PartClear(1,23,80,25,30,' ');
end; {SetUpMenu}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n    1    }
{                         }
{|||||||||||||||||||||||||}
procedure IntroOption;
{uses a scrollable virtual window to display the text}
var
  InfoData: ScreenOBJ;
  InfoWin: VirtualWinOBJ;
begin
   with InfoData do
   begin
      Init;
      Create(80,46,71);
      WriteAt(1,1,75,'What is the Object Toolkit?');
      WritePlain(5,3,'TechnoJock''s Object Toolkit (or simply the Toolkit) is a library of');
      WritePlain(5,4,'objects, procedures and functions for Pascal programmers. While writing');
      WritePlain(5,5,'a PC program, most people spend 80% or more of their time writing the');
      WritePlain(5,6,'program''s user interface, and only 20% on the "meat" of the applica-');
      WritePlain(5,7,'tion. The Toolkit is designed to provide a wealth of professional user');
      WritePlain(5,8,'interface tools which can eliminate up to 80% of your development work.');
      WritePlain(5,9,'For example, to display a sorted directory listing in a moveable window');
      WritePlain(5,10,'takes a mere three lines of code.');
      WritePlain(5,12,' The interface tools include such features as efficient screen writing,');
      WritePlain(5,13,'window management, menu management, full screen user input, list dis-');
      WritePlain(5,14,'playing, directory listing and much more. These tools give programs a');
      WritePlain(5,15,'truly professional appearance, and use the latest interface style with');
      WritePlain(5,16,'pop-up dialog boxes, scroll-bars and malleable windows, all with full');
      WritePlain(5,17,'mouse and keyboard support.');
      WritePlain(5,19,'As well as needing a user interface, many programs have to manipulate');
      WritePlain(5,20,'strings, access files, check attached hardware, and the like. The Tool-');
      WritePlain(5,21,'kit also provides a rich set of routines to help with these common');
      WritePlain(5,22,'tasks.');
      WritePlain(5,24,'If you are new to object oriented programming, you are in luck, for the');
      WritePlain(5,25,'Toolkit provides a great way for you to learn this powerful facility');
      WritePlain(5,26,'without requiring that you be a rocket scientist!');
      WriteAt(1,28,75,'Required Software & Hardware');
      WritePlain(5,30,'The Toolkit is designed to work with v5.5 (or later) of Borland Inter-');
      WritePlain(5,31,'national''s Turbo Pascal compiler for the IBM PC. To compile programs');
      WritePlain(5,32,'developed using the Toolkit, you will need Turbo Pascal v5.5 or later');
      WritePlain(5,33,'(or a 100% compatible Pascal compiler), and MS/PC-DOS (version 2.0 or');
      WritePlain(5,34,'later).');
      WriteAt(1,36,75,'Window Tips');
      WriteAt(1,38,78,' - To zoom the window, click on the [] icon or press F5.');
      WriteAt(1,40,78,' - To stretch the window, hold the left mouse button on the lower right');
      WriteAt(1,41,78,'   corner and drag the window, or press Alt-F5 then use the cursor keys and ');
      WriteAt(1,42,78,'   press Enter.');
      WriteAt(1,44,78,' - To move the window, hold the left mouse button on the top of the');
      WriteAt(1,45,78,'   window and drag the window, or press Ctrl-F5 then use the cursor keys and');
      WriteAt(1,46,78,'   press Enter.');
   end;
   with Screen do
   begin
      PartClear(1,1,80,21,white,'°');
      PartClear(1,22,80,25,white,' ');
      WriteAt(2,23,7,'The information displayed in the window was written to a virtual screen. The');
      WriteAT(2,24,7,'window can be stretched and moved. Press PgDn to see how.');
   end;
   with InfoWin do
   begin
      Init;
      SetBoundary(1,1,80,22);
      SetSize(4,2,77,19,1);
      AssignVirtualScreen(InfoData);
      Go;
   end;
   InfoData.Done;
   InfoWin.Done;
end; {IntroOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n    2    }
{                         }
{|||||||||||||||||||||||||}
procedure FormOption;
{This is a copy of demIO3.pas which displays every input field type!}
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
   with Screen do
   begin
      TitledBox(1,1,80,23,76,79,78,2,' The Works! ');
      WriteCenter(23,79,'Press TAB to switched fields and press ESC or F10 to end');
      PartClear(1,24,80,25,23,' ');
      WritePlain(5,24,'This demo shows many of the different form input field types. Run the');
      WritePlain(5,25,'demo programs DEMIO21, DEMIO22, DEMIO23 for some more powerful examples!');
   end;
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
   end;
end; {FormOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n    3    }
{                         }
{|||||||||||||||||||||||||}
procedure DirectoryOption;
{}
var
  PopUp: MessageOBJ;
  DirOne: ListDirSortOBJ;
  DirTwo: DirWinOBJ;
  Result: tAction;
  X1,Y1,X2,Y2,Style:byte;
begin
   Screen.PartClear(1,1,80,21,white,'°');
   Screen.PartClear(1,22,80,25,white,' ');
   with PopUp do
   begin
      Init(1,' Directory Listings ');
      AddLine('');
      AddLine(' The Toolkit provides two different objects for');
      AddLine(' displaying directories. The ListDirOBJ family of');
      AddLine(' objects displays files in a multi-column list, and');
      AddLine(' the user may optionally select multiple files. The ');
      AddLine(' DirWinOBJ is designed to choose a single file.');
      AddLine('');
      AddLine(' Both object types will be demonstrated.');
      AddLine('');
      Show;
      Done;
   end;
   with Screen do
   begin
      WriteAt(7,23,7,'Select multiple files by clicking the mouse or pressing the space bar.');
      WriteAT(7,24,7,'Change directories by selecting a subdirectory or ''..''. F10 to quit.');
   end;
   with DirOne do
   begin
      Init;
      ReadFiles('*.*',anyfile);
      Win^.SetTitle(' Press S or Right Button for Sort Options ');
      Go;
      Win^.Remove;
      Done;
   end;
   with Screen do
   begin
      PartClear(1,22,80,25,white,' ');
      WriteAt(7,23,7,'Press TAB to change fields. Enter a file name or mask, select a file');
      WriteAT(7,24,7,'from the list or change directories by double-clicking or press Enter.');
   end;
   with DirTwo do
   begin
      Init;
      Win^.GetSize(X1,Y1,X2,Y2,Style);
      Win^.SetSize(X1,1,X2,Y2-pred(Y1),Style);
      Result := Go;
      Done;
   end;
end; {DirectoryOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n   4     }
{                         }
{|||||||||||||||||||||||||}
procedure BrowseListOption;
{}
var
  Filename:string;
  Filer: BrowseFileOBJ;
  ListWin: ListLinkOBJ;
  ItemList: StrDLLOBJ;
  F:text;
  Line:string;
  Result: integer;
begin
   Screen.PartClear(1,1,80,22,white,'°');
   Screen.PartClear(1,23,80,25,white,' ');
   if exist('totdemo.pas') then
      Filename := 'totdemo.pas'
   else if exist('c:\autoexec.bat') then
      Filename := 'c:\autoexec.bat'
   else
     Filename := '';
   if Filename <> '' then
      with Filer do
      begin
        Init;
        Result := AssignFile(Filename);
        Win^.SetBoundary(1,1,80,23);
        Win^.SetSize(10,3,70,18,1);
        Screen.WriteAT(10,24,7,'The Toolkit can browse string arrays, linked lists, and text files.');
        Screen.WriteAT(10,25,7,'In this case, the file '+filename+' is being browsed.');
        Go;
        Done;
      end
   else
     Error(' The file browse demo cannot locate totdemo.pas',
           ' or c:\autoexec.bat. Too bad, it''s a great demo! ');
   {Now the list demo}
   Screen.PartClear(1,23,80,25,white,' ');
   if exist('demls4.txt') then
      with ItemList do
      begin
         Init;
         {$I-}
         Assign(F,'demls4.txt');
         Reset(F);
         {$I+}
         if not IOResult = 0 then
            Result := Add('File not found')
         else
         begin
            while not eof(F) do
            begin
               Readln(F,Line);
               Result := Add(Line);
            end;
            close(F);
         end;
         with ListWin do
         begin
            Init;
            AssignList(ItemList);
            SetColWidth(15);
            Win^.SetTitle(' Items from file DEMLS4.TXT ');
            Win^.SetSize(10,3,72,18,1);
            Win^.SetBoundary(1,1,80,23);
            Screen.WriteAT(5,24,7,'The Toolkit can list string arrays and linked lists in multiple columns.');
            Screen.WriteAT(5,25,7,'In this case, a 500 item linked list is being displayed.');
            Go;
            ListWin.Done;
         end;
         ItemList.Done;
      end
   else
     Error(' The list demo routine cannot locate demls4.txt. ',
           ' Too bad, it''s a great demo!');
end; {BrowseListOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n   5     }
{                         }
{|||||||||||||||||||||||||}
procedure PopUpMenu;
{}
var Msg:MessageOBJ;
begin
   with Msg do
   begin
      Init(1,' Pop-Up Menus ');
      AddLine('');
      AddLine(' You are using pop-up menus right now!');
      AddLine(' Pop-up menus are single menu lists which ');
      AddLine(' can be displayed on static or moveable');
      AddLine(' windows. Run the demos DEMMN1, DEMMN2 and ');
      AddLine(' DEMMN3 for further examples.');
      AddLine('');
      Show;
      Done;
   end;
end; {PopUpMenu}

procedure LotusMenu;
{}
var
  Main,
  Worksheet,
  Range: LotusMenuOBJ;
  Choice: word;

  procedure Pretend;
  begin
     Screen.Clear(31,' '); {paint the screen}
     Screen.WriteAt(1,4,48,replicate(80,' '));
     Screen.WriteCenter(4,48,'Not 1-2-3!');
     Screen.PartClear(1,5,4,25,48,' ');
  end; {Pretend}

begin
   Pretend;
   with Worksheet do
   begin
      Init;
      AddFullItem('~G~lobal',100,71,'Global stuff',nil);
      AddFullItem('~I~nsert',101,73,'Insert stuff',nil);
      AddFullItem('~D~elete',102,68,'Delete stuff',nil);
      AddFullItem('~C~olumn',103,67,'Column stuff',nil);
      AddFullItem('~E~rase',104,69,'Erase stuff',nil);
      AddFullItem('~T~itles',105,84,'Titles stuff',nil);
      AddFullItem('~W~indow',106,87,'Window stuff',nil);
      AddFullItem('~S~tatus',107,83,'Status stuff',nil);
      AddFullItem('~P~age',108,80,'Page stuff',nil);
      AddFullItem('~H~ide',109,72,'Hide things',nil);
      SetActiveItem(1);
      SetGap(1);
   end;
   with Range do
   begin
      Init;
      AddFullItem('~F~ormat',200,70,'Format stuff',nil);
      AddFullItem('~L~abel',201,76,'Label stuff',nil);
      AddFullItem('~E~rase',202,69,'Erase stuff',nil);
      AddFullItem('~N~ame',203,78,'Name stuff',nil);
      AddFullItem('~J~ustify',204,74,'Justify stuff',nil);
      AddFullItem('~P~rot',205,80,'Protect stuff',nil);
      AddFullItem('~U~nprot',206,85,'Unprotect stuff',nil);
      AddFullItem('~I~nput',207,73,'Input stuff',nil);
      AddFullItem('~V~alue',208,86,'Value stuff',nil);
      AddFullItem('~T~rans',209,84,'Transpose stuff',nil);
      AddFullItem('~S~earch',209,83,'Search for things',nil);
      SetActiveItem(1);
      SetGap(1);
   end;
   with Main do
   begin
      Init;
      AddFullItem('~W~orksheet',1,87,'Worksheet and global operations',@Worksheet);
      AddFullItem('~R~ange',2,82,'Commands for manipulating data ranges',@Range);
      AddFullItem('~C~opy',3,67,'Cell and range copying commands',nil);
      AddFullItem('~M~ove',4,77,'Cell and range moving commands',nil);
      AddFullItem('~F~ile',5,70,'File loading and saving operations',nil);
      AddFullItem('~P~rint',6,80,'Graph and spreadsheet printing',nil);
      AddFullItem('~G~raph',7,71,'Spreadsheet charting',nil);
      AddFullItem('~D~ata',8,68,'Database operations',nil);
      AddFullItem('~S~ystem',9,83,'Drop to the Operating System',nil);
      AddFullItem('~Q~uit',99,81,'Miller Time!',nil);
      SetActiveItem(1);
      SetGap(1);
      Choice := Activate;
      Done;
      Worksheet.Done;
      Range.Done;
   end;
end; {LotusMenu}

procedure PullDownMenu;
{}
var
  Env,Watch: MenuOBJ;
  Menu: EZPullArrayOBJ;
  Choice: word;

   procedure CreateSubMenus;
   {}
   begin
      with Env do
      begin
         Init;
         SetForPull;
         AddFullItem(' ~P~references... ',8061,80,'Specify desktop settings',nil);
         AddFullItem(' ~E~ditor...      ',8062,69,'Specify editor settings',nil);
         AddFullItem(' ~M~ouse...       ',8063,77,'Specify mouse settings',nil);
         AddFullItem(' ~S~tartup...     ',8064,83,'Permanently change default startup options',nil);
         AddFullItem(' ~C~olors...      ',8065,67,'Customize IDE colors for windows, menus, etc.',nil);
      end;
      with Watch do
      begin
         Init;
         SetForPull;
         AddFullItem(' ~A~dd watch...       ',7021,65,'Insert a watch expression into the Watch window',nil);
         AddFullItem(' ~D~elete watch       ',7022,68,'Remove the current watch expression from the Watch window',nil);
         AddFullItem(' ~E~dit watch...      ',7023,69,'Edit the current watch expression in the Watch window',nil);
         AddFullItem(' ~R~emove all watches ',7024,82,'Delete all watch expressions from the Watch window',nil);
      end;
   end; {CreateSubMenus}

   procedure CreateMenu;
   {}
   var
     Mtxt: Array[1..84] of string[100];
   begin
      MTxt[1] := '\ ð "System Commands';
      MTxt[2] := ' ~A~bout...        "Show version and copyright information"100';
      MTxt[3] := ' ~R~efresh display "Redraw the screen"101';
      MTxt[4] := ' ~C~lear desktop   "Close all windows on the desktop, clear history lists"102';
      MTxt[5] := '\ ~F~ile "File management commands (Open, New, Save, etc.)';
      MTxt[6] := ' ~O~pen...   F3  "Locate and open a file in an edit window"201"317';
      MTxt[7] := ' ~N~ew           "Create a new file in a new Edit window"202';
      MTxt[8] := ' ~S~ave      F2  "Save the file in the active Edit window"203"316';
      MTxt[9] := ' S~a~ve as...    "Save the current file under a different name"204';
      MTxt[10] := ' Save a~l~l      "Save all modified files"205';
      MTxt[11] := '-';
      MTxt[12] := ' ~C~hange dir... "Choose a new default directory"206';
      MTxt[13] := ' ~P~rint         "Print the contents of the active Edit window"207';
      MTxt[14] := ' ~G~et info...   "Show status information"208';
      MTxt[15] := ' ~D~OS shell     "Temporarily exit to DOS"209';
      MTxt[16] := ' E~x~it          "Exit Turbo Pascal"9999';
      MTxt[17] := '\ ~E~dit "Cut-and-paste editing commands"';
      MTxt[18] := '_ ~R~estore line     "Cancel edits to the current line in active Edit window"301';
      MTxt[19] := '-';
      MTxt[20] := '_ Cu~t~    Shift-Del "Remove the selected text and put it in the Clipboard"302';
      MTxt[21] := '_ ~C~opy    Ctrl-Ins "Copy the selected text into the Clipboard"303"9999';
      MTxt[22] := '_ ~P~aste  Shift-Ins "Insert selected text from the Clipboard"304"291';
      MTxt[23] := '_ Copy e~x~ample     "Copy example from the Help window into the ClipBoard"305';
      MTxt[24] := ' ~S~how clipboard   "Open the Clipboard window"306';
      MTxt[25] := '-';
      MTxt[26] := '_ C~l~ear   Ctrl-Del "Delete the selected text"307"262';
      MTxt[27] := '\ ~S~earch "Text and error search commands';
      MTxt[28] := ' ~F~ind...             "Search for text"401';
      MTxt[29] := ' ~R~eplace...          "Search for text and replace it with new text"402';
      MTxt[30] := ' ~S~earch again        "Repeat the last Find or Replace command"403';
      MTxt[31] := ' ~G~oto line number... "Move the cursor to a specified line number"404';
      MTxt[32] := ' ~F~ind procedure...   "Search for a procedure or function while debugging"405';
      MTxt[33] := ' Find e~r~ror...       "Move the cursor to the position of a runtime error"406';
      MTxt[34] := '\ ~R~un "Execute or single-step through a program';
      MTxt[35] := ' ~R~un            Ctrl-F9 "Run the current program"501"358';
      MTxt[36] := '_ ~P~rogram reset  Ctrl-F2 "Halt debugging session and release memory"502"351';
      MTxt[37] := ' ~G~o to cursor        F4 "Run program from the run bar to the cursor position"503"318';
      MTxt[38] := ' ~T~race into          F7 "Execute next statement, stopping within the current proc"504"321';
      MTxt[39] := ' ~S~tep over           F8 "Execute next statement, skipping over the current proc"505"322';
      MTxt[40] := ' P~a~rameters...          "Set command line parameters to be passed to the program"506';
      MTxt[41] := '\ ~C~ompile "Compile to disk or memory';
      MTxt[42] := ' ~C~ompile  Alt-F9 "Compile source file"601"368';
      MTxt[43] := ' ~M~ake         F9 "Rebuild source file and all modified files"602"323';
      MTxt[44] := ' ~B~uild           "Rebuild source file and all files"603';
      MTxt[45] := ' ~D~estination     "Specify whether file is compiled to memory or disk"604';
      MTxt[46] := ' ~P~rimary file... "Define the file that is the focus of make and Build"605';
      MTxt[47] := '\ ~D~ebug "Evaluate expressions, modify data, set breakpoints and watches';
      MTxt[48] := ' ~E~valute/modify...  Ctrl-F4 "Evaluate a variable or expression and display or modify the value"701"353';
      MTxt[49] := ' ~W~atches                   "Add, delete and edit expressions in the watch window"702';
      MTxt[50] := ' ~T~oggle breakpoint  Ctrl-F8 "Set or clear an unconditional breakpoint at the cursor position"703"357';
      MTxt[51] := ' ~B~reakpoints...    "Set conditional breakpoints, view and edit breakpoints"704';
      MTxt[52] := '\ ~O~ptions "Set defaults for compiler, editor, mouse, debugger, etc.';
      MTxt[53] := ' ~C~ompiler            "Set default compiler directives and condl. defines"801';
      MTxt[54] := ' ~M~emory sizes...     "Set default stack and heap sizes for generated programs"802';
      MTxt[55] := ' ~L~inker...           "Set linker options"803';
      MTxt[56] := ' De~b~ugger...         "Set debugger options"804';
      MTxt[57] := ' ~D~irectories...      "Set paths for units, include files, OBJs anfd generated files"805';
      MTxt[58] := '-';
      MTxt[59] := ' ~E~nvironment        "Specify environment settings"806';
      MTxt[60] := '-';
      MTxt[61] := ' ~S~ave options...     "Save all the settings you''ve made in the Options menu"807';
      MTxt[62] := ' ~R~etrieve options... "Load options file previously created with Save Options"808';
      MTxt[63] := '\ ~W~indow "Open, arrange, and list windows';
      MTxt[64] := ' ~S~ize/Move   Ctrl-F5 "Change the size or position of the active window"901"354';
      MTxt[65] := ' ~Z~oom             F5 "Enlarge or restore the size of the active window"902"319';
      MTxt[66] := ' ~T~ile                "Arrange windows on desktop by tiling"903';
      MTxt[67] := ' C~a~scade             "Arrange windows on desktop by cascading"904';
      MTxt[68] := ' ~N~ext             F6 "Make the next window active"905"320';
      MTxt[69] := ' ~P~revious   Shift-F6 "Make the previous window active"906"345';
      MTxt[70] := ' ~C~lose        Alt-F3 "Close the active window"907"362';
      MTxt[71] := '-';
      MTxt[72] := ' ~W~atch               "Open the watch window"908';
      MTxt[73] := ' ~R~egister            "Open the Register window"909';
      MTxt[74] := ' ~O~utput              "Open the Output window"910';
      MTxt[75] := ' Call stac~k~  Ctrl-F3 "Show the procedures the program called to reach this point"911"352';
      MTxt[76] := ' ~U~ser screen  Alt-F5 "Switch to the full-screen user output"912"364';
      MTxt[77] := '-';
      MTxt[78] := ' ~L~ist...       Alt-0 "Show a list of all open windows"913"385';
      MTxt[79] := '\ ~H~elp "Get online help';
      MTxt[80] := ' ~C~ontents               "Show table of contents of online Help"1001';
      MTxt[81] := ' ~I~ndex         Shift-F1 "Show index for online Help"1002"340';
      MTxt[82] := ' ~T~opic Search   Ctrl-F1 "Display help on the word at the cursor"1003"350';
      MTxt[83] := ' ~P~revious Topic  Alt-F1 "Redisplay the last-viewed online Help screen"1004"360';
      MTxt[84] := ' ~H~elp on Help           "How to use online Help"1005';
      with Menu do
      begin
         Init;
         AssignList(MTxt,84,100);
      end;
   end; {CreateMenu}

begin
   Screen.PartClear(1,2,80,24,white,'°'); {paint the screen}
   Screen.PartClear(1,1,80,1,31,' ');
   Screen.PartClear(1,25,80,25,31,' ');
   Screen.WritePlain(9,25,'³');
   CreateMenu;
   CreateSubMenus;
   with Menu do
   begin
      SubMenu(7)^.SetSubMenu(2,@Watch);
      SubMenu(8)^.SetSubMenu(7,@Env);
      Choice := Push(289,0,0);   {Pass Alt-F to make menu pull down on File}
      Done;
      Env.Done;
      Watch.Done;
   end;
end; {PullDownMenu}

procedure MenuOption;
{}
var
  MenuScreen: ScreenOBJ;
  SubMenu: MoveMenuOBJ;
  Choice: Integer;
begin
   Screen.Attrib(1,1,80,22,lightgray);
   MenuScreen.Init;
   MenuScreen.Save;
   with Submenu do
   begin
      Init;
      AddItem('');
      AddFullItem(' ~P~op-Up Menus        ',1,80,'Describes Pop-Up menus',nil);
      AddFullItem(' ~L~otus-style Menus   ',2,76,'Displays a Lotus-style menu',nil);
      AddFullItem(' P~u~ll-down Menus     ',3,85,'Display an IDE style pull-down menu',nil);
      AddItem('');
      AddFullItem(' ~R~eturn to main menu ',99,82,'Leave the menu section',nil);
      SetMenuXY(40,12);
      SetGap(5);  {1.00a}
      Win^.SetClose(false);
      Win^.SetBoundary(1,1,80,23);
      repeat
         MenuScreen.Display;
         Choice := Activate;
         MenuScreen.Save;
         Screen.ResetWindow;
         case Choice of
            1:PopUpMenu;
            2:LotusMenu;
            3:PullDownMenu;
         end; {case}
      until Choice in [0,99];
      MenuScreen.Done;
      Done;
   end;
   Mouse.Show;
end; {MenuOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n   6     }
{                         }
{|||||||||||||||||||||||||}
procedure StringDateOption;
{}
var DemoStr:string;
begin
   with Screen do
   begin
      TitledBox(1,1,80,25,27,30,23,2,' String and Date and Units ');
      WritePlain(3,3,'There are too many units to describe in detail in this demo program.');
      WritePlain(3,4,'However, listed below are some examples which take advantage of the');
      WritePlain(3,5,'Toolkit''s string and date units:');
      DemoStr := '  TechnoJock''s Object Toolkit string demo   ';
      WriteAt(5,7,23,'Source String: ');
      WriteAt(30,7,27,'"'+DemoStr+'"');
      WriteAt(3,9,23,'SetUpper:');
      WriteAt(30,9,30,'"'+SetUpper(DemoStr)+'"');
      WriteAt(3,10,23,'SetLower:');
      WriteAt(30,10,30,'"'+SetLower(DemoStr)+'"');
      WriteAt(3,11,23,'SetProper:');
      WriteAt(30,11,30,'"'+SetProper(DemoStr)+'"');
      WriteAt(3,12,23,'Total words:');
      WriteAt(30,12,lightgreen,IntToStr(WordCnt(DemoStr)));
      WriteAt(3,13,23,'Posn. Word 3:');
      WriteAt(30,13,lightgreen,IntToStr(PosWord(3,DemoStr)));
      WriteAt(3,14,23,'Words 3..5 are:');
      WriteAt(30,14,30,'"'+ExtractWords(3,3,DemoStr)+'"');
      WriteAt(3,15,23,'Strip Leading spaces:');
      WriteAt(30,15,30,'"'+Strip('L',' ',DemoStr)+'"');
      WriteAt(3,16,23,'Strip Trailing spaces:');
      WriteAt(30,16,30,'"'+Strip('R',' ',DemoStr)+'"');
      WriteAt(3,17,23,'Strip Lng. & Tng. spaces:');
      WriteAt(30,17,30,'"'+Strip('B',' ',DemoStr)+'"');
      WriteAt(3,18,23,'Strip All spaces:');
      WriteAt(30,18,30,'"'+Strip('A',' ',DemoStr)+'"');
      WriteAt(3,20,27,'Today is: '+FancyDateStr(TodayInJul,true,true));
      WriteAt(3,21,27,'The start of the year is '+JulToStr(StartOfYear(TodayInJul),MMDDYYYY));
      WriteAt(3,22,27,'The end of the year is '+JulToStr(EndOfYear(TodayInJul),MMDDYYYY));
      WriteAt(3,23,27,'30 days from now is '+FancydateStr(TodayInJul+30,true,true));
      WriteRight(78,25,27,' Press any key to continue ... ');
   end;
   Key.GetInput;
end; {StringDateOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n   7     }
{                         }
{|||||||||||||||||||||||||}
procedure HardwareOption;
{}
var
  PopUp:MessageOBJ;
  Equip: EquipOBJ;
begin
   with PopUp do
   begin
      Init(1,' Hardware ');
      AddLine('');
      AddLine(' The totSYS unit provides information about the hardware ');
      AddLine(' installed on the host computer. Listed below is some of ');
      AddLine(' the information available about your computer: ');
      AddLine('');
      if Monitor^.ColorOn then
         AddLine('          This system is color')
      else
         AddLine('          This system is monochrome');
      with Equip do
      begin
         Init;
         AddLine('          Machine ID: '+inttostr(ComputerID));
         AddLine('          Parallel Ports: '+inttostr(ParallelPorts));
         AddLine('          Serial Ports: '+inttostr(SerialPorts));
         AddLine('          Floppy Drives: '+inttostr(Floppydrives));
         AddLine('          ROM date: '+RomDate);
         if GameAdapter then
            AddLine('          Game Adapter: TRUE')
         else
            AddLine('          Game Adapter: FALSE');
         if SerialPrinter then
            AddLine('          Serial printer: TRUE')
         else
            AddLine('          Serial printer: FALSE');
         if MathChip then
            AddLine('          Math Coprocessor: TRUE')
         else
            AddLine('          Math Coprocessor: FALSE');
         Equip.Done;
      end;
      AddLine('');
      SetOption('  ~S~mart Huh!  ',83);
      Show;
      Done;
   end;
end; {HardwareOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n   8     }
{                         }
{|||||||||||||||||||||||||}
procedure InternationalOption;
{}
var
  OS: OSOBJ;
  Str:string;
begin
   with Screen do
   begin
      TitledBox(1,1,80,25,27,30,23,2,' String and Date and Units ');
      WritePlain(3,3,'Many international users have helped us to make the Toolkit useful in');
      WritePlain(3,4,'non-English speaking countries (including Australia!). Listed below');
      WritePlain(3,5,'are some of the international-related features:');
      WriteAT(3,7,31,'DOS Settings');
      WritePlain(7,8,'The totSYS unit includes OSOBJ for determining the DOS configuration.');
      WritePlain(7,9,'Listed below are some of the items about your system:');
      with OS do
      begin
         Init;
         WriteAt(20,10,30,'Operating System Version: '+OSversion);
         WriteAt(20,11,30,'Country Code: '+inttostr(Country));
         Str := 'Currency String: '+Currency+' ';
         case CurrencyFmt of
            0: Str := Str+'(String leads currency, no space)';
            1: Str := Str+'(String follows currency, no space)';
            2: Str := Str+'(String leads currency, one space)';
            3: Str := Str+'(String follows currency, one space)';
            4: Str := Str+'(String replaces decimal separator)';
         end; {case}
         WriteAT(20,12,30,Str);
         WriteAT(20,13,30,'Currency Decimal Places: '+inttostr(CurrencyDecPlaces));
         WriteAT(20,14,30,'Thousands Separator: '''+ThousandsSep+'''');
         WriteAT(20,15,30,'Decimal Separator: '''+DecimalSep+'''');
         case DateFmt of
            USA: WriteAT(20,16,30,'Date Format: MM DD YY');
            Europe: WriteAT(20,16,30,'Date Format: DD MM YY');
            Japan: WriteAT(20,16,30,'Date Format: YY MM DD');
         end; {case}
         Done;
      end;
      WriteAT(3,17,31,'KeyBoard Input');
      WritePlain(7,18,'All characters may be entered including extended ASCII characters.');
      WritePlain(7,19,'The totINPUT unit provides objects for controlling which characters');
      WritePlain(7,20,'are upper- and lower-case, as well as letting you control how their');
      WritePlain(7,21,'case is changed. You can even change the days and months to another lang.');
      WriteAT(3,22,31,'Toolkit Messages');
      WritePlain(7,23,'The messages displayed to users during input validation can be ');
      WritePlain(7,24,'customized for any language. Refer to the README file for more info.');
      WriteRight(78,25,27,' Press any key to continue ... ');
   end;
   Key.GetInput;
end; {InternationalOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n   9     }
{                         }
{|||||||||||||||||||||||||}
procedure ReadmeOption;
{}
var
 Filename:string;
 Retcode : integer;
begin
   if exist('README.COM') then
      filename :=  'README.COM'
   else if exist('..\tot\README.COM') then
      filename :=  '..\tot\README.COM'
   else
      filename := '';
   if filename <> '' then
      Retcode := RunEXECOM(filename,'')
   else
      Error(' Argh! I cannot locate the file README.COM. Exit to ',
            ' DOS, find the file and execute it manually');
end; {ReadmeOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n   10    }
{                         }
{|||||||||||||||||||||||||}
procedure PrintOption;
{}
var
   PopUp:MessageOBJ;
begin
   with PopUp do
   begin
      Init(1,' Printing the Documentation ');
      AddLine('');
      AddLine(' If you have not yet purchased the Toolkit, you might');
      AddLine(' want to print the documentation to help you evaluate ');
      AddLine(' the product. The complete documentation is available - ');
      AddLine(' all 20 chapters plus the flash cards. That''s more than');
      AddLine(' 350 pages in total.');
      AddLine('');
      AddLine(' The files end with a TXT extension, and include formfeed');
      AddLine(' characters at least every 60 lines. To print them, copy');
      AddLine(' the files to the printer port, or import them into a word ');
      AddLine(' processor. You can even use the IDE to print them by ');
      AddLine(' marking a block and pressing Ctrl-KP.');
      AddLine('');
      Show;
      Done;
   end;
end; {PrintOption}
{|||||||||||||||||||||||||}
{                         }
{     O p t i o n   11    }
{                         }
{|||||||||||||||||||||||||}
procedure PurchaseOption;
{}
begin
   with Screen do
   begin
      TitledBox(1,1,80,25,27,30,23,2,' How to buy the Toolkit ');
      WritePlain(7,3,'If you have not yet purchased the Toolkit, you are welcome to use it');
      WritePlain(7,4,'for a few weeks to see if you like it. If you want to continue to use');
      WritePlain(7,5,'The Toolkit, you must buy your own copy - just like you bought Turbo ');
      WritePlain(7,6,'Pascal. Not only will you be able to use the Toolkit in your programs,');
      WritePlain(7,7,'you will receive two bound professional manuals, a quick reference');
      WritePlain(7,8,'card, the latest version of the product, and you''ll get technical');
      WritePlain(7,9,'support.');
      WritePlain(7,11,'Included in the Toolkit files should be a file REGISTER.DOC. This file');
      WritePlain(7,12,'provides all the information you need to order your copy. If this file');
      WritePlain(7,13,'is missing, or you have any questions or comments, please don''t ');
      WritePlain(7,14,'hesitate to contact us. ');
      WriteAT(25,16,30,'TechnoJock Software, Inc.');
      WriteAT(25,17,30,'PO Box 820927');
      WriteAT(25,18,30,'Houston TX 77282');
      WriteAT(25,19,30,'USA');
      WriteAT(25,21,30,'Voice (713) 493-6354');
      WriteAT(25,22,30,'Fax   (713) 493-5872');
      WriteAT(25,23,30,'Compuserve 74017,227');
      WriteAT(25,24,30,'MCI Mail: TECHNOJOCK');
      WriteRight(78,25,27,' Press any key to continue ... ');
   end;
   Key.GetInput;
end; {PurchaseOption}
{|||||||||||||||||||||||||||||||||}
{                                 }
{     M a i n   P r o g r a m     }
{                                 }
{|||||||||||||||||||||||||||||||||}

begin  {main program}
   if MemAvail < 20000 then
   begin
      ResetStartUpMode;
      writeln('OOPS. You don''t have enough memory to run the demo!');
      writeln('Try running the program from the DOS prompt.');
      halt(1);
   end;
   Screen.Clear(white,' ');
   SaveScreen.Init;
   Key.SetFast;
   Introduction;
   SetUpMenu;
   SaveScreen.Save;
   repeat
      SaveScreen.Display;
      Choice := MainMenu.Activate;
      SaveScreen.Save;
      Screen.ResetWindow;
      case Choice of
         1: IntroOption;
         2: FormOption;
         3: DirectoryOption;
         4: BrowseListOption;
         5: MenuOption;
         6: StringDateOption;
         7: HardwareOption;
         8: InternationalOption;
         9: ReadmeOption;
         10: PrintOption;
         11: PurchaseOption;
      end; {case}
   until Choice in [0,99];
   Mouse.Hide;
   SaveScreen.Done;
   ResetStartUpMode;
end.
