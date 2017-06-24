/********************************************************************/
/*   SPAWNO v4.0   EMS/XMS/disk swapping replacement for spawn...() */
/*   (c) Copyright 1990, 1991 Ralf Brown  All Rights Reserved	    */
/*								    */
/*   May be freely copied provided that this copyright notice is    */
/*   not altered or removed.					    */
/********************************************************************/

#ifndef __SPAWNO_H
#define __SPAWNO_H

#include <stdarg.h>

#ifdef M_I86	      /* MSC 5.x */
#  ifndef _Cdecl
#    define _Cdecl cdecl
#  endif
#endif /* M_I86 */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */
void _Cdecl init_SPAWNO(const char *overlay_path, int swap_types) ;
int _Cdecl spawnvo(const char *overlay_path, const char *name, const char **args) ;
int _Cdecl spawnvpo(const char *overlay_path, const char *name, const char **args) ;
int _Cdecl spawnveo(const char *overlay_path, const char *name, const char **args,const char **env) ;
int _Cdecl spawnvpeo(const char *overlay_path, const char *name, const char **args,const char **env) ;
int _Cdecl spawnlo(const char *overlay_path, const char *name, ...) ;
int _Cdecl spawnlpo(const char *overlay_path, const char *name, ...) ;
int _Cdecl spawnleo(const char *overlay_path, const char *name, ...) ;
int _Cdecl spawnlpeo(const char *overlay_path, const char *name, ...) ;
int _Cdecl systemo(const char *overlay_path, const char *command) ;

  /* This function is normally called only by the spawn..() and spawn..o()  */
  /* functions								    */
int pascal __spawnv(const char *overlay_path,const char *name,const char **args,unsigned int env) ;

#ifdef __cplusplus
}
#endif /* __cplusplus */

  /* This variable is used by the functions which override the standard     */
  /* spawn..() functions; you should set it at the beginning of main().     */
  /* It points at a string containing a list of directories to be used when */
  /* swapping to disk, separated by semicolons.  If you use multiple	    */
  /* directories, they should be on different drives since for directories  */
  /* other than the root, inability to swap to one directory implies	    */
  /* inability to swap to all others on the same drive. 		    */
extern const char *pascal ___spawn_swap_dirs ;

  /* The following variable determines whether SPAWNO is allowed to use XMS */
  /* memory if available.  Set to 0 to disable XMS, 1 (default) to enable   */
extern char _Cdecl __spawn_xms ;

  /* The next variable determines whether SPAWNO is allowed to use EMS	    */
  /* memory if available and XMS is either unavailable or disabled.  Set to */
  /* 0 to disable EMS, 1 (default) to enable.				    */
extern char _Cdecl __spawn_ems ;

  /* The next variable determines whether SPAWNO is allowed to use non-XMS  */
  /* extended memory if available.  Set to 0 to disable extended memory,    */
  /* 1 (default) to enable.						    */
extern char _Cdecl __spawn_ext ;

  /* Specify whether to swap the program's memory blocks in the upper       */
  /* memory area under MSDOS 5.0 (requires DOS=UMB in CONFIG.SYS)	    */
extern char _Cdecl __spawn_swap_UMA ;

  /* Specify whether INT 23h and INT 24h handlers should be deactivated by  */
  /* SPAWNO.  You will normally want to deactivate the handlers unless you  */
  /* have elected to keep part of your program in memory while swapped.     */
  /* Set to 1 to preserve the INT 23h and INT 24h handlers, 0 (default) to  */
  /* disable the handlers.						    */
extern char _Cdecl __spawn_keepints ;

  /* This variable specifies the number of paragraphs to keep resident      */
  /* while swapped out (default 0 means minimum possible)		    */
extern unsigned int _Cdecl __spawn_resident ;

  /* The last variable specifies how many paragraphs of the stack to keep   */
  /* in memory while swapped out (default = 3, minimum = 2)		    */
  /* Note: the minimum value of 2 will only work on bare DOS; the more	    */
  /*  TSRs that hook INT 21h and chain with a simulated interrupt rather    */
  /*  than a far jump, the more paragraphs of stack must remain resident--  */
  /*  roughly one extra paragraph for every two such TSRs.		    */
extern unsigned int _Cdecl __spawn_res_stack ;

  /* Manifest constants for calling init_SPAWNO() */
#define SWAP_DISK 0
#define SWAP_XMS  1
#define SWAP_EMS  2
#define SWAP_EXT  4
#define SWAP_ANY 0xFF

#endif /* __SPAWNO_H */

/*=- End of SPAWNO.H -=*/
