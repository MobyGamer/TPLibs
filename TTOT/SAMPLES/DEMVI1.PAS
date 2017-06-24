Program DemoVirtualOne;

Uses CRT, totFast;

Var
  Screen1,
  Screen2,
  Screen3 : ScreenObj;   {screen objects}
  HeadCol,
  MsgCol,
  NormCol : byte;

procedure Pause;
{}
var Ch : char;
begin
   Ch := ReadKey;
end; {of proc pause}

procedure Initialize;
{}
begin
   Screen1.Init;
   Screen2.Init;
   Screen3.Init;
   HeadCol := CAttr(yellow,blue);
   MsgCol  := CAttr(yellow,red);
   NormCol := CAttr(white,blue);
end; {proc Initialize}

procedure IntroScreen;
{}
const 
    Tab = 8;
begin
   HeadCol := CAttr(yellow,blue);
   MsgCol  := CAttr(yellow,red);
   NormCol := CAttr(white,blue);
   with Screen do {manipulate the visible screen}
   begin
      Clear(NormCol,' ');
      WriteCenter(1,HeadCol,'TechnoJock''s Object Toolkit');
      WriteCenter(2,HeadCol,'Copyright 1991 TechnoJock Software, Inc.');
      WritePlain(Tab,5,'The totFAST unit includes the object ScreenOBJ. The interface');
      WritePlain(Tab,6,'section of the unit includes an instance of ScreenOBJ called');
      WritePlain(Tab,7,'SCREEN. You can create other instances of ScreenOBJ and these');
      WritePlain(Tab,8,'are effectively virtual screens created on the heap. At any');
      WritePlain(Tab,9,'time, the visible screen can be saved to a ScreenOBJ instance,');
      WritePlain(Tab,10,'or a ScreenOBJ instance can be displayed on the visible screen.');
      WritePlain(Tab,12,'You can write to the visible screen with SCREEN methods, or');
      WritePlain(Tab,13,'write to a virtual screen by calling the methods of any other');
      WritePlain(Tab,14,'instance.');
      WritePlain(Tab,16,'While you have been reading this screen, 3 other screens have');
      WritePlain(Tab,17,'been created. Press any key to see these screens slide onto');
      WritePlain(Tab,18,'the display.');
      WriteRight(80,25,MsgCol,'Press any key to continue ....');
   end;
end; {of proc IntroScreen}

procedure BuildScreen2;
{}
const 
   Tab = 8; Tab1 = 10;
begin
   HeadCol := CAttr(yellow,red);
   MsgCol  := CAttr(yellow,red);
   NormCol := CAttr(white,red);
   with Screen2 do
   begin
      Create(80,25,NormCol);
      WriteCenter(1,HeadCol,'Screen Writing');
      WritePlain(Tab,5,'The ScreenOBJ object boasts a large number of screen writing');
      WritePlain(Tab,6,'methods, including the following:');
      WriteHi(Tab1,8,MsgCol,NormCol,'~Write~ writes at cursor position in default color');
      WriteHi(Tab1,9,MsgCol,NormCol,'~WriteHi~ writes at X,Y using highlights');
      WriteHi(Tab1,10,MsgCol,NormCol,'~WritePlain~ writes at X,Y using existing attribute');
      WriteHi(Tab1,11,MsgCol,NormCol,'~WriteAt~ writes at X,Y using a specified color');
      WriteHi(Tab1,12,MsgCol,NormCol,'~WriteCap~ writes highlighting first capital letter');
      WriteHi(Tab1,13,MsgCol,NormCol,'~WriteClick~ writes with a tactile click!');
      WriteHi(Tab1,14,MsgCol,NormCol,'~WriteCenter~ writes text centered on screen');
      WriteHi(Tab1,15,MsgCol,NormCol,'~WriteBetween~ writes centered between two X coords');
      WriteHi(Tab1,16,MsgCol,NormCol,'~WriteRight~ writes right justified');
      WriteHi(Tab1,17,MsgCol,NormCol,'~WriteVert~ writes in a vertical column ');
      WritePlain(Tab,19,'Other methods provide full control of the cursor, the');
      WritePlain(Tab,20,'ability to read characters from any location on a screen');
      WritePlain(Tab,21,'and objects for controlling the physical display');
      WritePlain(Tab,22,'attributes, e.g. set into condensed display. Press any');
      WritePlain(Tab,23,'key to see the box and line drawing capabilities.');
      GotoXY(57,23);
   end;
end; {of proc BuildScreen2}

procedure BuildScreen3;
{}
const 
   Tab = 8;
begin
   HeadCol := CAttr(yellow,blue);
   MsgCol  := CAttr(yellow,red);
   NormCol := CAttr(white,blue);
   with Screen3 do
   begin
      Create(80,25,NormCol);
      TitledBox(1,1,80,25,NormCol,HeadCol,NormCol,4,'|Box drawing');
      WritePlain(Tab,4,'The ScreenOBJ objects includes some very easy-to-use box drawing');
      WritePlain(Tab,5,'methods. Boxes can be draw as a frame or filled, and optionally');
      WritePlain(Tab,6,'draw titles at the top, in a drop box, or at the bottom of the box.');
      TitledBox(Tab,8,39,15,MsgCol,MsgCol,MsgCol,3,' Centered ');
      TitledBox(Tab+5,10,44,17,MsgCol,MsgCol,MsgCol,1,'< Left ');
      TitledBox(Tab+10,12,49,19,MsgCol,MsgCol,MsgCol,2,'> Right ');
      TitledBox(53,8,75,19,MsgCol,MsgCol,MsgCol,1,'| In a Drop Box ');
      WritePlain(Tab,21,'There are also methods for drawing single and double lines');
      WritePlain(Tab,22,'that automatically draw "junctions" when another line is ');
      WritePlain(Tab,23,'met or crossed. Press any key to see the smart line facility.');
      CursOff;
   end;
end; {of proc BuildScreen3}


begin
   Initialize;
   IntroScreen;
   BuildScreen2;
   BuildScreen3;
   Pause;
   Screen1.Save;
   Screen2.SlideDisplay(horiz);
   Pause;
   Screen3.SlideDisplay(vert);
   Pause;
   with Screen do
   begin
      SmartHorizLine(1,80,14,white,1);
      SmartVertLine(35,8,19,white,2);
      SmartVertLine(64,10,19,white,2);
      WriteCenter(25,Cattr(black,white),'That''s all Folks!');
   end;
   Pause;
   Screen1.Done;
   Screen2.Done;
   Screen3.Done;
   ClrScr;
   Screen.CursOn;
end.
