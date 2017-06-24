Unit ExtFast;
{Illustrates how you can replace the Toolkit screen writing routines. In
 this case, the object MonoWriteOBJ intercepts all color attributes and 
 replaces them with White-on-Black.}

{$I TOTFLAGS.INC}

INTERFACE

uses DOS, CRT, totFAST;

TYPE

MonoWriteOBJ = object (WriteOBJ)
   constructor Init;
   procedure   WriteAT(X,Y,attr:byte;Str:string);                     VIRTUAL;
   procedure   ChangeAttr(X,Y,Att:byte;Len:word);                     VIRTUAL;
   procedure   Clear(Att:byte;Ch:char);                               VIRTUAL;
   destructor  Done;                                                  VIRTUAL;
end; {MonoWriteOBJ}

IMPLEMENTATION

constructor MonoWriteOBJ.Init;
{}
begin
   WriteOBJ.Init;
   TextColor(white);
   Textbackground(black);
end; {MonoWriteOBJ.Init}

procedure MonoWriteOBJ.WriteAT(X,Y,attr:byte;Str:string);
{}
begin
   WriteOBJ.WriteAT(X,Y,white,Str);
end; {MonoWriteOBJ.WriteAT}

procedure MonoWriteOBJ.ChangeAttr(X,Y,Att:byte;Len:word);
{}
begin
   WriteOBJ.ChangeAttr(X,Y,white,Len);
end; {MonoWriteOBJ.ChangeAttr}

procedure MonoWriteOBJ.Clear(Att:byte;Ch:char);
{}
begin
   WriteOBJ.Clear(white,Ch);
end; {MonoWriteOBJ.Clear}

destructor MonoWriteOBJ.Done;
{}
begin
   WriteOBJ.Done;
end; {MonoWriteOBJ.Done}

end.
