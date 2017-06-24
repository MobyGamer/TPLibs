Program DemoWriteOne;
{DEMWR1}

USES DOS,CRT, totFAST;

begin
   ClrScr;
   with Screen do
   begin
      SnowProne:=1;
      WriteCenter(1,CAttr(white,red),'TechnoJock''s Object Toolkit');
      WriteCenter(2,79,'Write Demo One');
      WriteAT(5,5,lightgreen,'Written using WriteAT');
      WriteHi(5,7,white,cyan,'Written with the Write~Hi~ method');
      WriteRight(80,9,yellow,'Written with WriteRight');
      WriteCap(5,11,white,cyan,'Written with WriteCap');
      WriteCap(5,13,white,cyan,'also written with WriteCap');
      WriteVert(40,5,12,'Writevert');
      WriteBetween(1,40,15,lightgreen,'Left Half');
      WriteBetween(41,80,15,lightgreen,'Right Half');
      WritePlain(5,17,'This is written with WritePlain');
      GotoXY(5,19);
      Write('Good Old Write! ');
      Writeln('And ...');
      Writeln('Good old Writeln');
      Writeln('');
      System.Writeln('This ','is',' Turbo''s Writeln');
      WriteClick(33,24,white,'That''s all Folks!');
      GotoXY(1,25);
   end;
end.
