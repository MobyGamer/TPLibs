Unit ExtDem2;

{A demonstration of the value of VIRTUAL methods - refer to chapter 16}

INTERFACE

Uses DOS,CRT, totSTR;

TYPE
PrintOBJ = object 
   constructor Init;
   procedure   PrintChar(Ch:char);         VIRTUAL;
   procedure   PrintStr(Str:string);
   procedure   PrintInt(Int:integer);
   destructor  Done;                       VIRTUAL;
end; {PrintOBJ}

NewPrintOBJ = object (PrintOBJ)
   vPort: string[4];
   constructor Init;
   procedure   SetPort(Prt:string);
   procedure   PrintChar(Ch:char);         VIRTUAL;
   destructor  Done;                       VIRTUAL;
end; {NewPrintOBJ}

IMPLEMENTATION

{\\\\\\\\\\\\\\\ PrintOBJ \\\\\\\\\\\\\\\\\\\\}
constructor PrintOBJ.Init;
{no data to initialize}
begin 
end; {PrintOBJ.Init}

procedure PrintOBJ.PrintChar(Ch:char);
{}
var
  Lst: text;
begin
   Assign(Lst,'LPT1');
   Rewrite(Lst);
   Write(Lst,Ch);
   Close(Lst);
end; {PrintOBJ.PrintChar}

procedure PrintOBJ.PrintStr(Str:string);
{}
var I : integer;
begin
   for I := 1 to length(Str) do
       PrintChar(Str[I]);
end; {PrintOBJ.PrintStr}

procedure PrintOBJ.PrintInt(Int:integer);
{}
var I:integer; Str:string;
begin
   Str := IntToStr(Int);
   for I := 1 to length(Str) do
       PrintChar(Str[I]);
end; {PrintOBJ.PrintInt}

destructor PrintOBJ.Done;
{no data to dispose of}
begin
end; {PrintOBJ.Done}
{\\\\\\\\\\\\\\\ PrintOBJ \\\\\\\\\\\\\\\\\\\\}
constructor NewPrintOBJ.Init;
{}
begin 
   PrintOBJ.Init;
   vPort := 'LPT1';
end; {NewPrintOBJ.Init}

procedure NewPrintOBJ.PrintChar(Ch:char);
{}
var
  Lst: text;
begin
   Assign(Lst,vPort);
   Rewrite(Lst);
   Write(Lst,Ch);
   Close(Lst);
end; {NewPrintOBJ.PrintChar}

procedure NewPrintOBJ.SetPort(Prt:string);
{}
begin
   vPort := Prt;
end; {NewPrintOBJ.SetPort}

destructor NewPrintOBJ.Done;
{}
begin
   PrintOBJ.Done
end; {NewPrintOBJ.Done}                                               

end.