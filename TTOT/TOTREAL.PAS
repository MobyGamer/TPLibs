{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totReal;
{$I TOTFLAGS.INC}

INTERFACE

{$IFNDEF FLOAT}
    {$IFNDEF FLOATEM}
        Type   single = real;
               double = real;
               extended = real;
               comp = real;
    {$ENDIF}
{$ENDIF}

procedure RealInit;

IMPLEMENTATION
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure RealInit;
begin
end;

{end of unit - add intialization routines below}
{$IFNDEF OVERLAY}
begin
   RealInit;
{$ENDIF}
end.
end.
