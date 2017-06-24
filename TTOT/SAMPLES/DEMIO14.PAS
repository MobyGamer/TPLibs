program DemoIOFourteen;
{demIO14 - single LinkIOOBJ input}
                   
Uses DOS, CRT,
     totFAST, totIO1, totIO2, totLINK;

Var
   MyList: StrDLLOBJ;
   ListField: LinkIOOBJ;

procedure FillList;
{}
var Retcode: integer;
begin
   with MyList do
   begin
      Init;
      Retcode := Add('Monitor');
      Retcode := Add('Keyboard');
      Retcode := Add('Mouse');
      Retcode := Add('Light Pen');
      Retcode := Add('Microphone');
      Retcode := Add('LCD O/H Panel');
      Retcode := Add('Modem');
      Retcode := Add('Printer');
      Retcode := Add('CD Rom');
      Retcode := Add('Toolkit');
   end;
end; {FillList}

begin
   ClrScr;
   FillList;
   with ListField do
   begin
      Init(35,5,15,6,'Peripherals');
      AssignList(MyList);
      Activate;
      gotoxy(1,20);
      writeln('You chose item: ',GetValue,' - ',
              MyList.GetStr(MyList.NodePtr(GetValue),0,0));
      Done;
      MyList.Done;
   end;
end.

