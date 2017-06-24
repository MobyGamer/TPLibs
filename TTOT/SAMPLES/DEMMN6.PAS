program DemoMenuSix;
{DEMMN6 - a simple pullmenu}
USES  DOS, CRT,
      totMENU, totFAST;

var
  Fmenu,
  Emenu: MenuOBJ;
  Pmenu: PullMenuOBJ;
  Choice: word;

procedure InitSubmenus;
{}
begin
   with Fmenu do
   begin
      Init;
      AddFullItem(' ~O~pen...       ',101,79,'',nil);
      AddFullItem(' ~N~ew           ',102,78,'',nil);
      AddFullItem(' ~S~ave...       ',103,83,'',nil);
      AddFullItem(' S~a~ve as       ',104,65,'',nil);
      AddFullItem(' Save a~l~l      ',105,79,'',nil);
      AddItem('-');
      AddFullItem(' ~C~hange dir ...',106,67,'',nil);
      AddFullItem(' ~P~rint         ',106,80,'',nil);
      AddFullItem(' ~G~et info...   ',107,71,'',nil);
      AddFullItem(' ~D~OS shell     ',108,68,'',nil);
      AddFullItem(' E~x~it          ',109,88,'',nil);
      SetForPull;
   end;
   with Emenu do
   begin
      Init;
      AddFullItem(' ~R~estore line   ',201,82,'',nil);
      AddItem('-');
      AddFullItem(' Cu~t~            ',202,84,'',nil);
      AddFullItem(' ~C~opy           ',203,67,'',nil);
      AddFullItem(' ~P~aste          ',204,80,'',nil);
      AddFullItem(' Copy ~E~xample   ',205,69,'',nil);
      SetStatus(6,false);
      AddFullItem(' ~S~how clipboard ',206,83,'',nil);
      AddItem('-');
      AddFullItem(' C~l~ear          ',207,76,'',nil);
      SetForPull;
   end;
end; {InitSubMenus}

begin
   Screen.Clear(white,'°'); {paint the screen}
   Screen.PartClear(1,1,80,1,31,' ');
   InitSubMenus;
   with Pmenu do
   begin
      Init;
      AddFullItem('   ~F~ile   ',1,70,'',@Fmenu);
      AddFullItem('   ~E~dit   ',2,69,'',@Emenu);
      AddItem('   Run   ');
      Choice := Activate;
      Done;
   end;
   GotoXY(25,15);
   if Choice = 0 then
      Writeln('You escaped')
   else
      Writeln('You selected menu item ',Choice);
end.     