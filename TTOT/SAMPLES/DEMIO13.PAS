program DemoIOThirteen;
{demIO13 - single ArrayIOOBJ input}
                   
Uses DOS, CRT,
     totFAST, totIO1, totIO2;

Var
   MyList: array[1..10] of string[20];
   ListField: ArrayIOOBJ;

procedure FillArray;
{}
begin
   MyList[1] := 'Monitor';
   MyList[2] := 'Keyboard';
   MyList[3] := 'Mouse';
   MyList[4] := 'Light Pen';
   MyList[5] := 'Microphone';
   MyList[6] := 'LCD O/H Panel';
   MyList[7] := 'Modem';
   MyList[8] := 'Printer';
   MyList[9] := 'CD Rom';
   MyList[10] := 'Toolkit';
end; {FillArray}

begin
   ClrScr;
   FillArray;
   with ListField do
   begin
      Init(35,5,15,6,'Peripherals');
      AssignList(MyList,10,20);
      Activate;
      gotoxy(1,20);
      writeln('You chose item: ',GetValue,' - ',MyList[GetValue]);
      Done;
   end;
end.

