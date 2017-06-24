{============================================================================}
{ (c) Copyright 1991 Ralf Brown    All Rights Reserved			     }
{ This file is part of the SPAWNO package and may be redistributed as a part }
{ of, and under the same terms as, that package.			     }
{============================================================================}

Program SPAWNO_TEST (output) ;

{$M 4096,0,200000 }
(* can't set max heap to 655360, because SPAWNO needs 384 bytes available from
   DOS for a stack *)

uses spawno ;

var
   retval : integer ;
   comspec : string ;

begin
   writeln('SPAWNO test') ;
   init_spawno('.',swap_all,20,0) ;
      (* note: init_spawno does not attempt to use environment variables to
	 determine the directories to use for swapping; you must do that
	 manually if you do not wish to hardcode the paths *)
   comspec := 'c:\command.com' ;
   retval := spawn(comspec,'',0) ;
   writeln('Done with ',comspec) ;
   if (retval = -1)
      then writeln('Error code = ',spawno_error)
      else writeln('Return code = ',retval) ;
end.

