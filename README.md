# TPLibs
Turbo Pascal 7-compatible libraries and utilities

These are libs and utils that I've found to greatly speed up the development process retrocoding in Turbo Pascal.  They include:

  * TTOT - My modified version of the Technojocks Object Toolkit.  I've done a ton of bugfixing:
    * Original version was hard-coded to 80-column screens, now supports any size screen
    * Methods have been de-normalized where applicable to reduce generated code size and speed execution (the tradeoff is that some immutable properties are now mutable, so don't do anything obviously stupid and you'll be fine)
    * TOTFAST.ASM was optimized so that it now truly does avoid CGA "snow"; it also now has a functional snow on/off variable (it was mistakenly ignored in the original code)
  * EXELINKR - J.E. Hoffmann's excellent XLINK file linker/joiner.  Demoscene Represent!
  * spwno413 - Ralf Brown's amazing SPAWNO swapping library
  * STREAM16 - Duncan Murdoch's Turbo Pascal stream extensions
  * CGA - My attempt at a CGA library, created before the ludicrous CGA hacking performed by VileR and reenigne and visible in 8088 MPH.  It is more useful as a reference than as a functional library.

Of the above, only TTOT is modified on a semi-regular basis as bugs/enhancements are processed; the others are provided here for convenience for anyone attempting to compile some of my other projects.
