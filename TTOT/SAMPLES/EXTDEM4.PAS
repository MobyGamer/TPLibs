Program ExtendedDemoFour;
{EXTDEM4 - this program shows how to use the VirtualWinOBJ
           object created in the unot EXTWIN. This demo
           builds a virtual screen, and fills it with an
           ASCII table.}

Uses DOS,CRT,
     totINPUT, totFAST, totSTR, extWIN;

var
   ASCIIdata: ScreenOBJ;
   AscWin: VirtualWinOBJ;

procedure BuildASCIIscreen;
{}
var
   I,J : integer;
   Str:string;
begin
   with ASCIIdata do
   begin
      Init;
      Create(65,32,71);
      for I := 0 to 31 do      
      begin
         Str := '';
         for J := 0 to 7 do
         begin
            Str := Str+' '+
                   padright(inttostr(I+32*J),3,'0')+
                   ' '+char(I+32*J)+' ';
            if J <> 7 then
               Str := Str + '³';
         end;
         WritePlain(1,succ(I),Str);
      end;
      for J := 0 to 7 do
          Attrib(6+J*8,1,6+J*8,32,78);
   end;      
end; {BuildASCIIscreen}

begin
   Screen.Clear(white,'°'); {paint the screen}
   Key.SetFast;
   BuildASCIIscreen;
   with AscWin do
   begin
      Init;
      SetTitle(' ASCII Table ');
      AssignVirtualScreen(ASCIIdata);
      Go;
      ASCIIdata.Done;
      Done;
   end;
end.
