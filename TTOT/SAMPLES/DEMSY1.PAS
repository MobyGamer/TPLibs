Program DemoSystemOne;
{DEMSY1}

USES DOS,CRT, TOTSYS;

var
   Equip: EquipObj;
   Mem: MemObj;
   OS: OSObj;
   Lines: byte;
begin
  ClrScr;
  Monitor^.SetCondensed;
  if Monitor^.ColorOn then
     writeln('This system is color')
  else
     writeln('This system is monochrome');
  with Equip do
  begin
     Init;
     Writeln('Machine ID: ',ComputerID);
     Writeln('Parallel Ports: ',ParallelPorts);
     Writeln('Serial Ports: ',SerialPorts);
     Writeln('Floppy Drives: ',Floppydrives);
     Writeln('ROM date: ',RomDate);
     Writeln('Game Adapter: ',GameAdapter);
     Writeln('Serial printer: ',Serialprinter);
     Writeln('Math Coprocessor: ',MathChip);
     Writeln;
  end;

  with Mem do
  begin
     Init;
     Writeln('Base memory: ',Basememory,'k');
     Writeln('Avail Extended memory: ',ExtMemAvail,'k');
     if EMMInstalled then
     begin
        Writeln('Total Expanded memory: ',MaxExpMem,'k');
        Writeln('Avail Expanded memory: ',ExpMemAvail,'k');
        Writeln('Expanded memory manager version: '+EMMversion);
     end
     else
        Writeln('Expanded memory not installed: ');
     writeln;
  end;

  with OS do
  begin
     Init;
     Writeln('Operating System Version: '+OSversion);
     Writeln('Country Code: ',Country);
     write('Currency String: ',Currency,' ');
     case CurrencyFmt of
        0: writeln('(String leads currency, no space)');
        1: writeln('(String follows currency, no space)');
        2: writeln('(String leads currency, one space)');
        3: writeln('(String follows currency, one space)');
        4: writeln('(String replaces decimal separator)');
     end; {case}
     writeln('Currency Decimal Places: ',CurrencyDecPlaces);
     write('Thousands Separator: ','''',ThousandsSep,'''');
     writeln(' Decimal Separator: ','''',DecimalSep,'''');
     case DateFmt of
        USA: writeln('Date Format: MM DD YY');
        Europe: writeln('Date Format: DD MM YY');
        Japan: writeln('Date Format: YY MM DD');
     end; {case}
     write('Date separator: ','''',DateSep,'''');
     writeln(' Time separator: ','''',TimeSep,'''');
     if TimeFmt = 0 then
        writeln('Time is displayed on a 12 hour clock')
     else
        writeln('Time is displayed on a 24 hour clock');
  end;
  write('                            press any key ...');
  Repeat until keypressed;
  if Lines > 25 then
     Monitor^.Set25;
end.
