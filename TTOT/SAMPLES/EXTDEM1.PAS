Unit ExtDem1;

{A demonstration of how to improve an object using inheritance}

INTERFACE

Uses DOS,CRT, totSYS;

TYPE

NewEquipOBJ = object (EquipOBJ)
   constructor Init;
   function    CDROM: boolean;
   function    GameAdapter: boolean;
   destructor  Done;
end; {NewEquipOBJ}

IMPLEMENTATION

constructor NewEquipOBJ.Init;
{}
begin
   EquipOBJ.Init;
end; {NewEquipOBJ.Init}

function NewEquipOBJ.CDROM:boolean;
{If you know how to do this - please tell us!}
begin
   CDROM := false;
end; {NewEquipOBJ.CDROM}

function NewEquipOBJ.GameAdapter:boolean;
{}
begin
   GameAdapter := paramstr(1) = '/G';
end; {NewEquipOBJ.GameAdapter}

destructor NewEquipOBJ.Done;
{}
begin
   EquipOBJ.Done;
end; {NewEquipOBJ.Done}


end.