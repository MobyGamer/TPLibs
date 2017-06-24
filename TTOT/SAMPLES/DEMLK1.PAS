Program DemoLinkOne;
{DEMLK1 - creating a linked list}

Uses CRT,
     totLink;

var
  GirlFriends: StrDLLOBJ;
  Retcode: integer;
  I: integer;

begin
   ClrScr;
   with GirlFriends do
   begin
		 Init;
		 Retcode := Add('Erica');
		 if Retcode <> 0 then exit;
		 Retcode := Add('Theresa');
		 if Retcode <> 0 then exit;
		 Retcode := Add('Lynn');
		 if Retcode <> 0 then exit;
		 Retcode := Add('Donna');
		 if Retcode <> 0 then exit;
		 Retcode := Add('Godzilla');
		 if Retcode <> 0 then exit;
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
	 end;
end.
