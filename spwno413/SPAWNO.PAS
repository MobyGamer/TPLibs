{============================================================================}
{ (c) Copyright 1991 Ralf Brown    All Rights Reserved			     }
{ This file is part of the SPAWNO package and may be redistributed as a part }
{ of, and under the same terms as, that package.			     }
{============================================================================}

{
20171208 Jim Leonard modifications:
- Added additional error result codes defined in the source but
  left out of the pascal version for some reason
- Added human-parsable text strings for error result codes
}

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
   enotfound    = 2 ; enotfoundErrmsg   = 'file not found';
   enopath      = 3 ; enopathErrmsg     = 'path not found';
   emfile       = 4 ; emfileErrmsg      = 'too many open files';
   eaccess      = 5 ; eaccessErrmsg     = 'access denied';
   ebadf        = 6 ; ebadfErrmsg       = 'invalid file handle';
   econtr       = 7 ; econtrErrmsg      = 'MCBs destroyed';
   enomem       = 8 ; enomemErrmsg      = 'out of memory';
   einvdat     = 13 ; einvdatErrmsg     = 'invalid data';
   enodev      = 15 ; enodevErrmsg      = 'invalid drive/device';
   einval      = 19 ; einvalErrmsg      = 'invalid argument';
   e2big       = 20 ; e2bigErrmsg       = 'environment too big';
   ewritefault = 29 ; ewritefaultErrmsg = 'write error';

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

