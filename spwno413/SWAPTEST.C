/********************************************************************/
/*   SPAWNO v4.0   EMS/XMS/disk swapping replacement for spawn...() */
/*   (c) Copyright 1991 Ralf Brown  All Rights Reserved		    */
/*								    */
/*   This file SWAPTEST.C is donated to the public domain, but the  */
/*   remainder of SPAWNO remains copyrighted.			    */
/*								    */
/*   Changes for MSC compatibility provided by Gene McManus.	    */
/********************************************************************/

/*  Available #defines:
	NO_SPAWNO	assume file will be linked only with runtime library
	STD_SPAWN	use replacements for standard functions from SPAWNO lib
	ENVIRON		pass current environment rather than original environment
	ADD_MEM		allocate ADD_MEM KB additional memory to SWAPTEST

    Recompiling:
	TCC -m{x} SWAPTEST SPAWN{x}.LIB
*/

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <ctype.h>
#ifndef M_I86
#include <alloc.h>
#endif /* M_I86 */
#include <process.h>
#include "spawno.h"

/* #define STD_SPAWN	   /* comment out to use parallel spawn..o() funcs */
/* #define NO_SPAWNO	   /* uncomment to use compiler's library */
/* #define ADD_MEM 300	   /* uncomment to allocate additional 300K memory */

#ifndef M_I86	/* allow for differences between TC & MSC */
#define ALLOC allocmem
#define FREE  freemem
#define OK    -1
#else
#define ALLOC _dos_allocmem
#define FREE  _dos_freemem
#define OK    0
#endif /* M_I86 */

#ifdef NO_SPAWNO
#  ifndef STD_SPAWN
#    define STD_SPAWN
#  endif
#endif

#ifdef STD_SPAWN
#  ifdef ENVIRON
#    define SPAWNlp spawnlpe
#    define SPAWNvp spawnvpe
#  else
#    define SPAWNlp spawnlp
#    define SPAWNvp spawnvp
#  endif
#  define SPAWN_ARG1 P_WAIT
#else /* STD_SPAWN */
#  ifdef ENVIRON
#    define SPAWNlp spawnlpeo
#    define SPAWNvp spawnvpeo
#  else
#    define SPAWNlp spawnlpo
#    define SPAWNvp spawnvpo
#  endif
#  define SPAWN_ARG1 swap_dir
#endif /* STD_SPAWN */

#ifndef ENVIRON
unsigned int _heaplen = 128 ;	/* limit heap if we don't build an environment */
#endif /* ENVIRON */

int verbose = 0 ;

void usage(void)
{
   fputs("Usage: SWAPTEST <runs> <where> <size> [command [args]]\n",stderr) ;
   fputs("\twhere\t<runs> is the number of times to recursively invoke\n",stderr) ;
   fputs("\t\t\tSWAPTEST before invoking the specified command.\n",stderr) ;
   fputs("\t\t<where> indicates where to swap, one or more of [D]isk,\n",stderr) ;
   fputs("\t\t\t[E]MS, [X]MS, and ex[T]ended\n",stderr) ;
   fputs("\t\t<size> specifies the minimum number of bytes to keep resident.\n",stderr) ;
   exit(1) ;
}

#ifdef NO_SPAWNO
void init_SPAWNO(const char *overlay_path,int swap_types)
{
   (void) overlay_path ;
   (void) swap_types ;
}
#endif /* NO_SPAWNO */

int main(int argc, char **argv)
{
   unsigned int seg1, seg2, seg3, seg4 ;
   unsigned int recursions_left ;
   char *argptr ;
   char *comspec = getenv("COMSPEC") ;
   char *swap_dir = getenv("SWAPDIR") ;
   int swap_types = 0 ;
   char num[12] ;
   int retval ;
#ifdef ENVIRON
   char *scratch ;
#endif

   if (argc < 4)
      usage() ;
/***** process the commandline arguments *****/
   if (argv[0] == NULL || argv[0][0] == '\0')
      argv[0] = "SWAPTEST" ;
   recursions_left = (unsigned int) atol(argv[1]) ;
   argptr = argv[2] ;
   while (*argptr)
      {
      switch(toupper(*argptr))
	 {
	 case 'V': verbose = 1 ;
		   break ;
	 case 'D': swap_types |= SWAP_DISK ;
		   break ;
	 case 'E': swap_types |= SWAP_EMS ;
		   break ;
	 case 'X': swap_types |= SWAP_XMS ;
		   break ;
	 case 'T': swap_types |= SWAP_EXT ;
		   break ;
	 default:  /* do nothing */
		   break ;
	 }
      argptr++ ;
      }
#ifndef NO_SPAWNO
   /* determine the number of paragraphs to keep resident given the number of */
   /* bytes requested by the user */
   __spawn_resident = ((unsigned int) atol(argv[3]) + 15) / 16 ;
#endif /* ndef NO_SPAWNO */
   if (swap_dir == NULL)
      swap_dir = "." ;          /* default swap directory is current dir */
   if (comspec == NULL)
      comspec = "COMMAND" ;	/* default program to run is COMMAND.COM */
   init_SPAWNO(swap_dir,swap_types) ;
#ifdef ENVIRON
   /* Turbo C's malloc() [called by putenv()] can't deal with other memory  */
   /* blocks immediately beyond the main program's, so allocate some memory */
   /* now to force the break higher */
   scratch = malloc(2000) ;
#endif /* ENVIRON */
#ifdef ADD_MEM
   {
   int i, j ;
   char *tmp ;

   if (verbose) printf("Allocating %dK additional memory\n",ADD_MEM) ;
   for (i = 0 ; i < ADD_MEM ; i++)     /* allocate extra memory to increase */
      {				       /* space needed for swapping */
      tmp = malloc(1024) ;
      for (j = 0 ; j < 1024 ; j++)     /* initialize memory to a known pattern */
	 tmp[j] = 1023 - j ;
      }
   }
#endif /* ADD_MEM */
/***** allocate several blocks of memory *****/
   if (ALLOC(2048,&seg1) != OK)	  /* 32K */
      {
      printf("First memory allocation failed.\n") ;
      abort() ;
      }
   if (verbose) printf("seg1 = %4.4X\n",seg1) ;
   if (ALLOC(64,&seg2) != OK)	  /* 1K */
      {
      printf("Second memory allocation failed.\n") ;
      abort() ;
      }
   if (verbose) printf("seg2 = %4.4X\n",seg2) ;
   if (ALLOC(4100,&seg3) != OK)	  /* 64+K */
      {
      printf("Third memory allocation failed.\n") ;
      abort() ;
      }
   if (verbose) printf("seg3 = %4.4X\n",seg3) ;
   if (ALLOC(128,&seg4) != OK)	  /* 2K */
      {
      printf("Fourth memory allocation failed.\n") ;
      abort() ;
      }
   if (verbose) printf("seg4 = %4.4X\n",seg4) ;
/***** deallocate one of our blocks to create a "hole" *****/
   FREE(seg2) ;
   if (verbose) printf("freed seg2\n") ;
#ifdef ENVIRON
   free(scratch) ;
#endif /* ENVIRON */
/***** now figure out which program to spawn and spawn it *****/   
   printf("SWAPTEST %u\n",recursions_left) ;
   if (recursions_left)
      {
      ultoa(recursions_left-1,num,10) ;
      argv[1] = num ;
#ifdef STD_SPAWN
      retval = spawnvp(P_WAIT,argv[0],argv) ;
#else
      retval = spawnvpo(swap_dir,argv[0],argv) ;
#endif /* STD_SPAWN */
      }
   else
      {
#ifdef ENVIRON
      putenv("SWAPTEST=YES") ;
#endif /* ENVIRON */
      if (argc > 4)
	 retval = SPAWNvp(SPAWN_ARG1,argv[4],argv+4
#ifdef ENVIRON
					     ,environ
#endif /* ENVIRON */
			 ) ; 
      else
	 retval = SPAWNlp(SPAWN_ARG1,comspec,comspec,(char *)NULL
#ifdef ENVIRON
							 ,environ
#endif /* ENVIRON */
			 ) ;
      }
   if (retval == -1)
      printf("errno = %d, _doserrno = %d.",errno,_doserrno) ;
   else
      printf("spawn return code = %d.",retval) ;
/***** check memory integrity on return by freeing the *****/
/***** memory we allocated earlier *****/
   if (FREE(seg1))
      printf("\nfreemem(seg1) failed!") ;
   if (FREE(seg4))
      printf("\nfreemem(seg4) failed!") ;
   if (FREE(seg3))
      printf("\nfreemem(seg3) failed!") ;
/***** allocate one big block of memory *****/
   if (ALLOC(6340,&seg1) != OK)
      abort() ;
   if (verbose) printf("\n6340 paragraphs allocated at %4.4X",seg1) ;
   if (FREE(seg1))
      printf("\nfinal freemem failed!") ;
   printf("\t Ending SWAPTEST %u\n",recursions_left) ;
   return 0 ;	      /* successful */
}

