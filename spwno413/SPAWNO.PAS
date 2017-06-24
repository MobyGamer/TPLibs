{============================================================================}
{ (c) Copyright 1991 Ralf Brown    All Rights Reserved			     }
{ This file is part of the SPAWNO package and may be redistributed as a part }
{ of, and under the same terms as, that package.			     }
{============================================================================}

UNIT SPAWNO ;

interface

const
   (* symbolic constants for specifying permissible swap locations *)
   (* add/or together the desired destinations *)
   swap_disk = 0 ;
   swap_xms = 1 ;
   swap_ems = 2 ;
   swap_ext = 4 ;
   swap_all = $FF ;     (* swap to any available destination *)

   (* error codes *)
   enotfound = 2 ;
   enopath = 3 ;
   eaccess = 5 ;
   enomem = 8 ;
   e2big = 20 ;
   ewritefault = 29 ;

var
   spawno_error : integer ; (* error code when SPAWN returns -1 *)

procedure init_SPAWNO(swap_dirs : string ; swap_types : integer ;
		      min_res : integer ; res_stack : integer) ;
	(* min_res = minimum number of paragraphs to keep resident
	   res_stack = minimum paragraphs of stack to keep resident
		       (0 = no change)
	 *)

function SPAWN(progname : string ; arguments : string ; envseg : integer) : integer ;

implementation

{$L SPAWNTP.OBJ}
procedure init_SPAWNO(swap_dirs : string ; swap_types : integer ;
		      min_res : integer ; res_stack : integer) ;
	external ;

function SPAWN(progname : string ; arguments : string ; envseg : integer) : integer ;
	external ;

end.

