Program DemoBrowseArray;

Uses DOS,CRT,
     totFAST, totINPUT, totLINK, totLIST, totSTR;
const
   DefaultFile = 'c:\autoexec.bat';
var
   BWin: BrowseFileOBJ;
   RetCode: integer;
   Filename: string;

begin
   Screen.Clear(white,'°'); {paint the screen}
   if ParamCount = 0 then
      FileName := DefaultFile
   else
      FileName := ParamStr(1);
   with BWin do
   begin
      Init;
      Retcode := AssignFile(Filename);
      if Retcode in [0,2] then
         Go
      else
      begin
         Writeln('Unable to find file: ',Filename,'.');
         Key.DelayKey(2000);
      end;
      Done;
   end;
end.
