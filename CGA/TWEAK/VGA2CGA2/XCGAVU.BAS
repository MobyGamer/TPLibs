CGXNAME$ = COMMAND$:                    'get name from Command line
ON ERROR GOTO NoFile

OPEN CGXNAME$ + ".CGX" FOR INPUT AS 1:  'make sure it exists
CLOSE

GOSUB SetXCGA                           'trigger 160x100x16 mode
DEF SEG = &HB800                        'change DSEG to screen
BLOAD CGXNAME$ + ".CGX", 0              'dump picture to screen
a$ = INPUT$(1)
SCREEN 2: SCREEN 0: END                 'restore text mode and exit

NoFile: BEEP:
        PRINT "Cannot find " + CGXNAME$
        END


SetXCGA:

'WARNING: Changing these registers settings may cause a CRASH !

DEF SEG = 0
POKE &H465, 0: OUT &H3D8, 0:
POKE &H466, 0: OUT &H3D9, 0
OUT &H3D4, 0: OUT &H3D5, 113
OUT &H3D4, 1: OUT &H3D5, 80
OUT &H3D4, 2: OUT &H3D5, 90
OUT &H3D4, 3: OUT &H3D5, 10
OUT &H3D4, 4: OUT &H3D5, 127
OUT &H3D4, 5: OUT &H3D5, 6
OUT &H3D4, 6: OUT &H3D5, 100
OUT &H3D4, 7: OUT &H3D5, 112
OUT &H3D4, 8: OUT &H3D5, 2
OUT &H3D4, 9: OUT &H3D5, 1
OUT &H3D4, 10: OUT &H3D5, 32
OUT &H3D4, 11: OUT &H3D5, 0
POKE &H465, 9: OUT &H3D8, 9
RETURN

