Program ExtendedDemoFive;
{EXTDEM5 - this program shows how to use the
           RecordListOBJ object from the extLINK unit.

           In this example, the information is stored
           in a sequential file. In real life, it
           would often be a database.}


Uses DOS,CRT,
     totFAST, totINPUT, totIO2, totLIST, extLINK, totSTR, totLINK;

var
  RecList: RecordDLLOBJ;
  ListWin: BrowseLinkOBJ;

procedure BuildTheList(Filename:string);
{loads in the data from disk - could also be from d/b}
var 
  F: file of RecordInfo;
  Rec: RecordInfo;
  Ecode: integer;
begin
   assign(F,filename);
   {$I-}
   reset(F);
   {$I+}
   if ioresult <> 0 then
   begin
      writeln('The file ',filename,' cannot be located.');
      writeln('Demo aborting. Run demo from directory containing file.');
      halt(1);
   end;
   Ecode := 0;
   RecList.Init;
   while not eof(F) and (Ecode = 0) do
   begin
      Read(F,Rec);
      with Rec do
      begin
         FirstName:= padleft(FirstName,15,' ');
         LastName:= padleft(LastName,15,' ');
         Company:= padleft(Company,20,' ');
      end;
      Ecode := RecList.Add(Rec);
   end;
   close(F);
end; {BuildtheList}

begin {Main program}
   BuildTheList('EXTDEM5.DBF');
   Screen.Clear(white,'°'); {paint the screen}
   Key.SetFast;
   with FMTNumberTOT do
   begin
      SetJustification(JustRight);
      SetPrefixSuffix('$','');
   end;
   with ListWin do
   begin
      Init;
      Win^.SetTitle(' Total Records: '+inttostr(RecList.TotalNodes)+' ');
      AssignList(RecList);
      Go;
   end;
end.
