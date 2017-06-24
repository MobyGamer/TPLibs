program DemoMenuNineA;
{DEMMN9A - life without EZPull}
USES  DOS, CRT,
      totMENU, totFAST;

var
  MenuAbout,MenuFile,MenuEdit,MenuSearch,MenuRun,MenuCompile,
  MenuDebug,MenuOptions,MenuWindow,MenuHelp,
  SubmenuEnv,SubmenuWatch: MenuOBJ;
  Menu: PullMenuOBJ;
  Choice: word;

procedure CreateSubMenus;
{}
begin
   with SubMenuEnv do 
   begin
      Init;
      SetForPull;
      AddFullItem(' ~P~references... ',8061,80,'Specify desktop settings',nil);
      AddFullItem(' ~E~ditor...      ',8062,69,'Specify editor settings',nil);
      AddFullItem(' ~M~ouse...       ',8063,77,'Specify mouse settings',nil);
      AddFullItem(' ~S~tartup...     ',8064,83,'Permanently change default startup options',nil);
      AddFullItem(' ~C~olors...      ',8065,67,'Customize IDE colors for windows, menus, etc.',nil);
   end;
   with SubMenuWatch do
   begin
      Init;
      SetForPull;
      AddFullItem(' ~A~dd watch...       ',7021,65,'Insert a watch expression into the Watch window',nil);
      AddFullItem(' ~D~elete watch       ',7022,68,'Remove the current watch expression from the Watch window',nil);
      AddFullItem(' ~E~dit watch...      ',7023,69,'Edit the current watch expression in the Watch window',nil);
      AddFullItem(' ~R~emove all watches ',7024,82,'Delete all watch expressions from the Watch window',nil);
   end;
end; {CreateSubMenus}

procedure CreateMainMenuBar;
{}
begin
   with Menu do
   begin
      Init;
      AddFullItem(' ð ',1,0,'System Commands',@MenuAbout);
      AddFullItem(' ~F~ile ',2,70,'File management commands (Open, New, Save, etc.)',@MenuFile);
      AddFullItem(' ~E~dit ',3,69,'Cut-and-paste editing commands',@MenuEdit);
      AddFullItem(' ~S~earch ',4,83,'Text and error search commands',@MenuSearch);
      AddFullItem(' ~R~un ',5,82,'Execute or single-step through a program',@MenuRun);
      AddFullItem(' ~C~ompile ',6,67,'Compile to disk or memory',@MenuCompile);
      AddFullItem(' ~D~ebug ',7,68,'Evaluate expressions, modify data, set breakpoints and watches',@MenuDebug);
      AddFullItem(' ~O~ptions ',8,79,'Set defaults for compiler, editor, mouse, debugger, etc.',@MenuOptions);
      AddFullItem(' ~W~indow ',9,87,'Open, arrange, and list windows',@MenuWindow);
      AddFullItem(' ~H~elp ',10,72,'Get online help',@MenuHelp);
   end;
end; {CreateMainMenuBar}

procedure CreateMenus;
{}
var
  Mtxt: Array[1..84] of string[90];
begin
   with MenuAbout do
   begin
      Init;
      SetForPull;
      AddFullItem(' ~A~bout...        ',101,65,'Show version and copyright information',nil);
      AddFullItem(' ~R~efresh display ',102,82,'Redraw the screen',nil);
      AddFullItem(' ~C~lear desktop   ',103,67,'Close all windows on the desktop, clear history lists',nil);
   end;
   with MenuFile do
   begin
      Init;
      SetForPull;
      AddFullItem(' ~O~pen...   F3  ',201,79,'Locate and open a file in an edit window',nil);
      AddFullItem(' ~N~ew           ',202,78,'Create a new file in a new Edit window',nil);
      AddFullItem(' ~S~ave      F2  ',203,83,'Save the file in the active Edit window',nil);
      AddFullItem(' S~a~ve as...    ',204,65,'Save the current file under a different name',nil);
      AddFullItem(' Save a~l~l      ',205,76,'Save all modified files',nil);
      AddItem( '-');
      AddFullItem( ' ~C~hange dir... ',206,67,'Choose a new default directory',nil);
      AddFullItem( ' ~P~rint         ',207,80,'Print the contents of the active Edit window',nil);
      AddFullItem( ' ~G~et info...   ',208,71,'Show status information',nil);
      AddFullItem( ' ~D~OS shell     ',209,68,'Temporarily exit to DOS',nil);
      AddFullItem( ' E~x~it          ',9999,88,'Exit Turbo Pascal',nil);
   end;
   with MenuEdit do
   begin
      Init;
      SetForPull;
      AddFullItem( ' ~R~estore line     ',301,82,'Cancel edits to the current line in active Edit window',nil);
      SetStatus(1,false);
      AddItem('-');
      AddFullItem( ' Cu~t~    Shift-Del ',302,84,'Remove the selected text and put it in the Clipboard',nil);
      SetStatus(3,false);
      AddFullItem( ' ~C~opy    Ctrl-Ins ',303,67,'Copy the selected text into the Clipboard',nil);
      SetStatus(4,false);
      AddFullItem( ' ~P~aste  Shift-Ins ',304,80,'Insert selected text from the Clipboard',nil);
      SetStatus(5,false);
      AddFullItem( ' Copy e~x~ample     ',305,88,'Copy example from the Help window into the ClipBoard',nil);
      SetStatus(6,false);
      AddFullItem( ' ~S~how clipboard   ',306,83,'Open the Clipboard window',nil);
      AddItem('-');
      AddFullItem( ' C~l~ear   Ctrl-Del ',307,76,'Delete the selected text',nil);
      SetStatus(9,false);
   end;
   with MenuSearch do
   begin
      Init;
      SetForPull;
      AddFullItem( ' ~F~ind...             ',401,70,'Search for text',nil);
      AddFullItem( ' ~R~eplace...          ',402,82,'Search for text and replace it with new text',nil);
      AddFullItem( ' ~S~earch again        ',403,83,'Repeat the last Find or Replace command',nil);
      AddFullItem( ' ~G~oto line number... ',404,71,'Move the cursor to a specified line number',nil);
      AddFullItem( ' ~F~ind procedure...   ',405,70,'Search for a procedure or function while debugging',nil);
      AddFullItem( ' Find e~r~ror...       ',406,82,'Move the cursor to the position of a runtime error',nil);
   end;
   with MenuRun do
   begin
      Init;
      SetForPull;
      AddFullItem( ' ~R~un            Ctrl-F9 ',501,82,'Run the current program',nil);
      AddFullItem( ' ~P~rogram reset  Ctrl-F2 ',502,80,'Halt debugging session and release memory',nil);
      SetStatus(2,false);
      AddFullItem( ' ~G~o to cursor        F4 ',503,71,'Run program from the run bar to the cursor position',nil);
      AddFullItem( ' ~T~race into          F7 ',504,84,'Execute next statement, stopping within the current proc',nil);
      AddFullItem( ' ~S~tep over           F8 ',505,83,'Execute next statement, skipping over the current proc',nil);
      AddFullItem( ' P~a~rameters...          ',506,65,'Set command line parameters to be passed to the program',nil);
   end;
   with MenuCompile do
   begin
      Init;
      SetForPull;
      AddFullItem( ' ~C~ompile  Alt-F9 ',601,67,'Compile source file',nil);
      AddFullItem( ' ~M~ake         F9 ',602,77,'Rebuild source file and all modified files',nil);
      AddFullItem( ' ~B~uild           ',603,66,'Rebuild source file and all files',nil);
      AddFullItem( ' ~D~estination     ',604,68,'Specify whether file is compiled to memory or disk',nil);
      AddFullItem( ' ~P~rimary file... ',605,80,'Define the file that is the focus of make and Build',nil);
   end;
   with MenuDebug do
   begin
      Init;
      SetForPull;
      AddFullItem( ' ~E~valute/modify...  Ctrl-F4 ',701,69,
                   'Evaluate a variable or expression and display or modify the value',nil);
      AddFullItem( ' ~W~atches                   ',702,87,
                   'Add, delete and edit expressions in the watch window',@SubMenuWatch);
      AddFullItem( ' ~T~oggle breakpoint  Ctrl-F8 ',703,84,
                   'Set or clear an unconditional breakpoint at the cursor position',nil);
      AddFullItem( ' ~B~reakpoints...    ',704,66,
                   'Set conditional breakpoints, view and edit breakpoints',nil);
   end;
   with MenuOptions do
   begin
      Init;
      SetForPull;
      AddFullItem( ' ~C~ompiler            ',801,67,'Set default compiler directives and condl. defines',nil);
      AddFullItem( ' ~M~emory sizes...     ',802,77,'Set default stack and heap sizes for generated programs',nil);
      AddFullItem( ' ~L~inker...           ',803,76,'Set linker options',nil);
      AddFullItem( ' De~b~ugger...         ',804,66,'Set debugger options',nil);
      AddFullItem( ' ~D~irectories...      ',805,68,'Set paths for units, include files, OBJs anfd generated files',nil);
      AddItem('-');
      AddFullItem( ' ~E~nvironment        ',806,69,'Specify environment settings',@SubMenuEnv);
      AddItem('-');
      AddFullItem( ' ~S~ave options...     ',807,83,'Save all the settings you''ve made in the Options menu',nil);
      AddFullItem( ' ~R~etrieve options... ',808,82,'Load options file previously created with Save Options',nil);
   end;
   with MenuWindow do
   begin
      Init;
      SetForPull;
      AddFullItem( ' ~S~ize/Move   Ctrl-F5 ',901,83,'Change the size or position of the active window',nil);
      AddFullItem( ' ~Z~oom             F5 ',902,90,'Enlarge or restore the size of the active window',nil);
      AddFullItem( ' ~T~ile                ',903,84,'Arrange windows on desktop by tiling',nil);
      AddFullItem( ' C~a~scade             ',904,65,'Arrange windows on desktop by cascading',nil);
      AddFullItem( ' ~N~ext             F6 ',905,78,'Make the next window active',nil);
      AddFullItem( ' ~P~revious   Shift-F6 ',906,80,'Make the previous window active',nil);
      AddFullItem( ' ~C~lose        Alt-F3 ',907,67,'Close the active window',nil);
      AddItem('-');
      AddFullItem( ' ~W~atch               ',908,87,'Open the watch window',nil);
      AddFullItem( ' ~R~egister            ',909,82,'Open the Register window',nil);
      AddFullItem( ' ~O~utput              ',910,79,'Open the Output window',nil);
      AddFullItem( ' Call stac~k~  Ctrl-F3 ',911,75,'Show the procedures the program called to reach this point',nil);
      AddFullItem( ' ~U~ser screen  Alt-F5 ',912,85,'Switch to the full-screen user output',nil);
      AddItem('-');
      AddFullItem( ' ~L~ist...       Alt-0 ',913,76,'Show a list of all open windows',nil);
   end;
   with MenuHelp do
   begin
      Init;
      SetForPull;
      AddFullItem( ' ~C~ontents               ',1001,67,'Show table of contents of online Help',nil);
      AddFullItem( ' ~I~ndex         Shift-F1 ',1002,73,'Show index for online Help',nil);
      AddFullItem( ' ~T~opic Search   Ctrl-F1 ',1003,84,'Display help on the word at the cursor',nil);
      AddFullItem( ' ~P~revious Topic  Alt-F1 ',1004,80,'Redisplay the last-viewed online Help screen',nil);
      AddFullItem( ' ~H~elp on Help           ',1005,72,'How to use online Help',nil);
   end;
end; {CreateMenus}

procedure AssignSpecialkeys;
{}
begin
   with Menu do
   begin
      SetSpecialKey(317,201); {F3}
      SetSpecialKey(316,203); {F2}
      SetSpecialKey(301,9999); {Alt-X}
      SetSpecialKey(263,302); {Shift-Del}
      SetSpecialKey(260,303); {Ctrl-Ins}
      SetSpecialKey(291,304); {Shift-Ins}
      SetSpecialKey(262,307); {Ctrl-Del}
      SetSpecialKey(358,501); {Ctrl-F9}
      SetSpecialKey(351,502); {Ctrl-F2}
      SetSpecialKey(318,503); {F4}
      SetSpecialKey(321,504); {F7}
      SetSpecialKey(322,505); {F8}
      SetSpecialKey(368,601); {Alt-F9}
      SetSpecialKey(323,602); {F9}
      SetSpecialKey(353,701); {Ctrl-F4}
      SetSpecialKey(357,703); {Ctrl-F8}
      SetSpecialKey(354,901); {Ctrl-F5}
      SetSpecialKey(319,902); {F5}
      SetSpecialKey(320,905); {F6}
      SetSpecialKey(345,906); {Shift-F6}
      SetSpecialKey(362,907); {Alt-F3}
      SetSpecialKey(352,911); {Ctrl-F3}
      SetSpecialKey(364,912); {Alt-F5}
      SetSpecialKey(385,913); {Alt-0}
      SetSpecialKey(340,1002); {Shift-F1}
      SetSpecialKey(350,1003); {Ctrl-F1}
      SetSpecialKey(360,1004); {Alt-F1}
   end;
end; {AssignSpecialKeys}

procedure DisposeMenus;
{}
begin
  MenuAbout.Done;
  MenuFile.Done;
  MenuEdit.Done;
  MenuSearch.Done;
  MenuRun.Done;
  MenuCompile.Done;
  MenuDebug.Done;
  MenuOptions.Done;
  MenuWindow.Done;
  MenuHelp.Done;
  SubmenuEnv.Done;
  SubmenuWatch.Done;
  Menu.Done;
end; {DisposeMenus}

begin
   Screen.PartClear(1,2,80,24,white,'°'); {paint the screen}
   Screen.PartClear(1,1,80,1,31,' ');
   Screen.PartClear(1,25,80,25,31,' ');
   Screen.WritePlain(9,25,'³');
   CreateMenus;
   CreateMainMenuBar;
   CreateSubMenus;
   AssignSpecialkeys;
   Choice := Menu.Push(13,0,0);   {Pass Enter to make menu pull down}
   DisposeMenus;
   GotoXY(25,15);
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice);
end.