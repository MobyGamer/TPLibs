# TPLibs
Turbo Pascal 7-compatible libraries and utilities

These are libs and utils that I've found to greatly speed up the development process retrocoding in Turbo Pascal.  They include:

  * TTOT - My modified version of the Technojocks Object Toolkit.  I've done a ton of bugfixing:
    * Original version was hard-coded to 80-column screens, now supports any size screen
    * Methods have been de-normalized where applicable to reduce generated code size and speed execution (the tradeoff is that some immutable properties are now mutable)
  * EXELINKR - The CoExistance's excellent file linker/joiner
  * spwno413 - Ralf Brown's amazing SPAWNO swapping library
  * STREAM16 - Duncan Murdoch's Turbo Pascal stream extensions
