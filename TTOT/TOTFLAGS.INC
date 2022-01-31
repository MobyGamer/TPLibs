(*
TOTFLAGS.INC is included in all TOT units. You can add any global compiler
directives, etc. to this file.

     The TOT conditional defines are

          FINAL - enable this directive when you are building the production
                  version of your program. The activated settings are designed
                  to reduce program code size, and increase execution speed.

          FLOAT - Enable this directive if your program will be using extended
                  real types, i.e. singlee, double, extended and comp. When
                  this directive is not enforced, all real types are set to
                  be plain reals. programs compiled in this state will
                  only run on machines fitted with a math coprocessor

        FLOATEM - This is the same as FLOAT except the program will run
                  on systems that are not equipped with a math coprocessor.
                  In case you were wondering, the compiler directive is an
                  abbreviation for FLOAT EMULATION.

    OVERLAYINIT - This directive should normally be used when you want
                  to overlay Toolkit units. Refer to the file OVERLAY.DOC
                  for further information.

        OVERLAY - Use this directive if you want to overlay any of the
                  toolkit units and perform individual unit initialization.
                  Be sure to call the unitINIT proc in your
                  main program, e.g. IOINIT. The unitINIT procedures
                  perform any necessary unit initialization.

    To active a compile directive, you must use the $DEFINE keyword. For
    example, to enable full floating point math emulation in your program
    include the following statement in the "DEFINES AREA" below:

                     {$DEFINE FLOATEM}
*)

{+++++++++++++++++++++++++++    DEFINES   AREA   +++++++++++++++++++++++++++}

{$DEFINE FINAL}

{{$DEFINE INITTRACE}

{{ $ DEFINE FLOAT}
{{ $ DEFINE FLOATEM}

{$DEFINE OVERLAYINIT}
{{$DEFINE OVERLAY}

{$IFDEF DPMI}
  {$UNDEF OVERLAYINIT}
  {$UNDEF OVERLAY}
{$ENDIF}

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}





{General compiler directives}

{$V-}   {no string length checking}

{$IFDEF FINAL}
    {$S-,R-,L-,D-}
{$ELSE}
    {$S+}
    {$R+}
    {$L+}
    {$D+}
    {$DEFINE CHECK}
{$ENDIF}

{$IFDEF OVERLAYINIT}
    {$F+}
    {$O+}
{$ELSE}
   {$IFDEF OVERLAY}
    {$F+}
    {$O+}
   {$ENDIF}
{$ENDIF}

{Note the floating point type casting is in the totReal unit}

{$IFDEF FLOAT}
    {$IFDEF FLOATEM}
        {$N+,E+}
    {$ELSE}
        {$N+,E-}
    {$ENDIF}
{$ELSE}
    {$N-,E-}
{$ENDIF}
