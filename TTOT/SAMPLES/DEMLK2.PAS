Program DemoLinkTwo;
{DEMLK2 - creating a linked list}

Uses CRT,
     totLink;

var
   GirlFriends: StrDLLOBJ;
   Retcode: integer;
   I : integer;

begin                 
   ClrScr;
   with GirlFriends do
   begin
      Init;
      if maxavail > 200 then
      begin
         Retcode := Add('Erica');
         Retcode := Add('Theresa');
         Retcode := Add('Lynn');
         Retcode := Add('Donna');
         Retcode := Add('Godzilla');
         writeln('Total nodes: ',TotalNodes);
         writeln('Active node number: ',ActiveNodeNumber);
         for I := 1 to TotalNodes do
             writeln(GetStr(NodePtr(I),0,0));
         writeln;
         RetCode := InsertBefore(NodePtr(4),'Joyce');
         writeln('Total nodes: ',TotalNodes);
         writeln('Active node number: ',ActiveNodeNumber);
         SwapNodes(NodePtr(5),NodePtr(2));
         Retcode := Change(StartNodePtr,'Ekka');
         for I := 1 to TotalNodes do
             writeln(GetStr(NodePtr(I),0,0));
         writeln;
         writeln('Sorted:');
         Sort(1,true);
         for I := 1 to TotalNodes do
             writeln(GetStr(NodePtr(I),0,0));
      end;
   end;
end.
