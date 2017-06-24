Program DemoBrowseArrayThree;
{DEMBR3 - not you may need to execute this program from DOS since,
 it uses over 300k of heap space to illustrate the speed of browsing
 huge lists}
Uses DOS,CRT,
     totFAST, totLINK, totLIST, totSTR;

var
   BWin: BrowseLinkOBJ;
   LL : StrDLLOBJ;

procedure CreateLinkedList;
{}
var
  I, Retcode : integer;
begin
   with LL do
   begin
      Init;
      for I := 1 to 500 do
         Retcode := Add('This is line '+IntToStr(I)+': '+replicate(200,char(random(255))));
   end; {with}
end; {CreateLinkedList}

begin
   Screen.Clear(white,'°'); {paint the screen}
   CreateLinkedList;
   with BWin do
   begin
      Init;
      AssignList(LL);
      Win^.SetTitle('List Browse Demo');
      Go;
      Done;
      LL.Done;
   end;
end.
