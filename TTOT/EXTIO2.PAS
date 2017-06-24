Unit ExtIO2;
{Illustrates how you can extend the Toolkit IO objects. A boolean
 field is created.}

{$I TOTFLAGS.INC}
INTERFACE

uses DOS, CRT, totFAST, totIO1, totSTR, totInput;

TYPE

pHotkeyIOOBJ = ^HotkeyIOOBJ;
HotSpotIOOBJ = object (ItemIOOBJ)
   vActionCode: tAction;
   {methods ...}
   constructor Init(X1,Y1,X2,Y2: byte;Act:tAction);
   function    OnTarget(X,Y: byte):boolean;                 VIRTUAL;
   function    Select(K:word; X,Y:byte):tAction;            VIRTUAL;
   destructor  Done;                                        VIRTUAL;
end; {HotSpotIOOBJ}


IMPLEMENTATION

constructor HotSpotIOOBJ.Init(X1,Y1,X2,Y2: byte;Act:tAction);
{}
begin
   ItemIOOBJ.Init;
   vBoundary.X1 := X1;
   vBoundary.Y1 := Y1;
   vBoundary.X2 := X2;
   vBoundary.Y2 := Y2;
   vActionCode := Act;
end; {HotSpotIOOBJ.Init}

function HotSpotIOOBJ.OnTarget(X,Y: byte):boolean;
{}
begin
   Ontarget :=     (X >= vBoundary.X1)
               and (X <= vBoundary.X2)
               and (Y >= vBoundary.Y1)
               and (Y <= vBoundary.Y2);
end; {HotSpotIOOBJ.HotKey}

function HotSpotIOOBJ.Select(K:word; X,Y:byte):tAction;
{}
begin
   Select := vActionCode;
end; {HotSpotIOOBJ.Select}

destructor HotSpotIOOBJ.Done;
{}
begin
   ItemIOOBJ.Done;
end; {HotSpotIOOBJ.Done}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
{$ENDIF}
end.