program DemoMenuSeven;
{DEMMN7 - using EZPull objects}
USES  DOS, CRT,
      totMENU, totFAST;

var
  Menu: EZPullArrayOBJ;
  Choice: word;

procedure CreateMenu;
{}
var
  Mtxt: Array[1..84] of string[90];
begin
   MTxt[1] := '\ ð "System Commands';
   MTxt[2] := ' ~A~bout...        "Show version and copyright information"100';
   MTxt[3] := ' ~R~efresh display "Redraw the screen"101';
   MTxt[4] := ' ~C~lear desktop   "Close all windows on the desktop, clear history lists"102';
   MTxt[5] := '\ ~F~ile "File management commands (Open, New, Save, etc.)';
   MTxt[6] := ' ~O~pen...       "Locate and open a file in an edit window"201';
   MTxt[7] := ' ~N~ew           "Create a new file in a new Edit window"202';
   MTxt[8] := ' ~S~ave          "Save the file in the active Edit window"203';
   MTxt[9] := ' S~a~ve as...    "Save the current file under a different name"204';
   MTxt[10] := ' Save a~l~l      "Save all modified files"205';
   MTxt[11] := '-';
   MTxt[12] := ' ~C~hange dir... "Choose a new default directory"206';
   MTxt[13] := ' ~P~rint         "Print the contents of the active Edit window"207';
   MTxt[14] := ' ~G~et info...   "Show status information"208';
   MTxt[15] := ' ~D~OS shell     "Temporarily exit to DOS"209';
   MTxt[16] := ' E~x~it          "Exit Turbo Pascal"9999';
   MTxt[17] := '\ ~E~dit "Cut-and-paste editing commands"';
   MTxt[18] := '_ ~R~estore line   "Cancel edits to the current line in active Edit window"301';
   MTxt[19] := '-';
   MTxt[20] := '_ Cu~t~            "Remove the selected text and put it in the Clipboard"302';
   MTxt[21] := '_ ~C~opy           "Copy the selected text into the Clipboard"303';
   MTxt[22] := '_ ~P~aste          "Insert selected text from the Clipboard"304';
   MTxt[23] := '_ Copy e~x~ample   "Copy example from the Help window into the ClipBoard"305';
   MTxt[24] := ' ~S~how clipboard "Open the Clipboard window"306';
   MTxt[25] := '-';
   MTxt[26] := '_ C~l~ear          "Delete the selected text';
   MTxt[27] := '\ ~S~earch "Text and error search commands';
   MTxt[28] := ' ~F~ind...             "Search for text"401';
   MTxt[29] := ' ~R~eplace...          "Search for text and replace it with new text"402';
   MTxt[30] := ' ~S~earch again        "Repeat the last Find or Replace command"403';
   MTxt[31] := ' ~G~oto line number... "Move the cursor to a specified line number"404';
   MTxt[32] := ' ~F~ind procedure...   "Search for a procedure or function while debugging"405';
   MTxt[33] := ' Find e~r~ror...       "Move the cursor to the position of a runtime error"406';
   MTxt[34] := '\ ~R~un "Execute or single-step through a program';
   MTxt[35] := ' ~R~un           "Run the current program"501';
   MTxt[36] := '_ ~P~rogram reset "Halt debugging session and release memory"502';
   MTxt[37] := ' ~G~o to cursor  "Run program from the run bar to the cursor position"503';
   MTxt[38] := ' ~T~race into    "Execute next statement, stopping within the current proc"504';
   MTxt[39] := ' ~S~tep over     "Execute next statement, skipping over the current proc"505';
   MTxt[40] := ' P~a~rameters... "Set command line parameters to be passed to the program"506';
   MTxt[41] := '\ ~C~ompile "Compile to disk or memory';
   MTxt[42] := ' ~C~ompile         "Compile source file"601';
   MTxt[43] := ' ~M~ake            "Rebuild source file and all modified files"602';
   MTxt[44] := ' ~B~uild           "Rebuild source file and all files"603';
   MTxt[45] := ' ~D~estination     "Specify whether file is compiled to memory or disk"604';
   MTxt[46] := ' ~P~rimary file... "Define the file that is the focus of make and Build"605';
   MTxt[47] := '\ ~D~ebug "Evaluate expressions, modify data, set breakpoints and watches';
   MTxt[48] := ' ~E~valute/modify    "Evaluate a variable or expression and display or modify the value"701';
   MTxt[49] := ' ~W~atches           "Add, delete and edit expressions in the watch window"702';
   MTxt[50] := ' ~T~oggle breakpoint "Set or clear an unconditional breakpoint at the cursor position"703';
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
   MTxt[64] := ' ~S~ize/Move   "Change the size or position of the active window"901';  
   MTxt[65] := ' ~Z~oom        "Enlarge or restore the size of the active window"902';
   MTxt[66] := ' ~T~ile        "Arrange windows on desktop by tiling"903';
   MTxt[67] := ' C~a~scade     "Arrange windows on desktop by cascading"904';
   MTxt[68] := ' ~N~ext        "Make the next window active"905';
   MTxt[69] := ' ~P~revious    "Make the previous window active"906';
   MTxt[70] := ' ~C~lose       "Close the active window"907';
   MTxt[71] := '-';
   MTxt[72] := ' ~W~atch       "Open the watch window"908';
   MTxt[73] := ' ~R~egister    "Open the Register window"909';
   MTxt[74] := ' ~O~utput      "Open the Output window"910';
   MTxt[75] := ' Call stac~k~  "Show the procedures the program called to reach this point"911';
   MTxt[76] := ' ~U~ser screen "Switch to the full-screen user output"912';
   MTxt[77] := '-';
   MTxt[78] := ' ~L~ist...     "Show a list of all open windows"913';
   MTxt[79] := '\ ~H~elp "Get online help';
   MTxt[80] := ' ~C~ontents       "Show table of contents of online Help"1001';
   MTxt[81] := ' ~I~ndex          "Show index for online Help"1002';
   MTxt[82] := ' ~T~opic Search   "Display help on the word at the cursor"1003';
   MTxt[83] := ' ~P~revious Topic "Redisplay the last-viewed online Help screen"1004';
   MTxt[84] := ' ~H~elp on Help   "How to use online Help"1005';
   with Menu do
   begin
      Init;
      AssignList(MTxt,84,90);
   end;
end; {CreateMenu}

begin
   Screen.PartClear(1,2,80,24,white,'°'); {paint the screen}
   Screen.PartClear(1,1,80,1,31,' ');
   Screen.PartClear(1,25,80,25,31,' ');
   Screen.WritePlain(9,25,'³');
   CreateMenu;
   with Menu do
   begin
      Choice := Push(13,0,0);   {Pass Enter to make menu pull down}
      Done;
   end;
   GotoXY(25,15);
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice)
      ;
end.     