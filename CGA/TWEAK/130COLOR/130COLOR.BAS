100 '130 color graphics by Larry McMillin
110 'Derived from LOWRES.BAS [PC World, April 1985]
120 DEFINT A-Z          :KEY OFF        :CLS
130 DIM COLOUR(135,1), ORDER(15), CHOICE(19)
140 LOCATE 1,1          :PRINT "130 Colour Demonstration"
150 LOCATE 5,1,1        :PRINT "Now assembling colors...";
160 '
170 'Color/Graphics Adapter definitions
180 MODEREG=&H3D8       :COLORREG=&H3D9         'control registers
190 MODESAVE=&H465      :COLORSAVE=&H466        'BIOS saves the regs here
200 CRTREG=&H3D4        :CRTDATA=&H3D5          '6845 CRT controller regs
210 HIRES=1             :VIDEO=8                'Mode register bits
220 '
230 'Create a list of the 136 colors.  This includes 6 colors that are
240 '50-50 mixtures of primary colors, but excludes foreground/background
250 'combinations that duplicate background/foreground combinations
260 C=0
270 FOR I=0 TO 255
280     BG=I\16         :FG=I MOD 16    :IF FG<BG THEN 300
290     COLOUR(C,0)=BG  :COLOUR(C,1)=FG :C=C+1
300 NEXT
310 '
320 'Select 19 colors from the list for this demonstration
330 FOR I=1 TO 19       :READ CHOICE(I) :NEXT
340 DATA 1,16,24,17,2,10,39,119,133,89,68,128,81,87,126,58,4,19,20
350 '
360 'Build an index to organize the colors in the matrix
370 FOR I=0 TO 15       :READ ORDER(I)  :NEXT
380 DATA 0,8,1,9,3,11,2,10,6,14,4,12,5,13,7,15
390 '
400 'Set up Color/Graphics Adapter for 80- by 100-block graphics
410 DEF SEG=0   :MODE=0
420 POKE MODESAVE,MODE  :OUT MODEREG,MODE
430 POKE COLORSAVE,0    :OUT COLORREG,0
440 '
450 'Load new parameters into 6845 CRT controller
460 FOR REGISTER= 0 TO 11
470     READ REGDATA
480     OUT CRTREG,REGISTER     :OUT CRTDATA,REGDATA
490 NEXT
500 '
510 'Initial data for 6845 (80 x 100 characters)
520 DATA 113    :'register 0 - horizontal total
530 DATA  80    :'register 1 - horizontal displayed
540 DATA  90    :'register 2 - horizontal sync position
550 DATA  10    :'register 3 - horizontal sync width
560 DATA 127    :'register 4 - vertical total
570 DATA   6    :'register 5 - vertical adjust
580 DATA 100    :'register 6 - vertical displayed
590 DATA 112    :'register 7 - vertical sync position
600 DATA   2    :'register 8 - interlace mode (non-interlace)
610 DATA   1    :'register 9 - maximum scan line address
620 DATA  32    :'register 10 - cursor start (disables cursor display)
630 DATA   0    :'register 11 - cursor end
640 '
650 'Set mode for 80 column color enable
660 MODE=HIRES+VIDEO
670 POKE MODESAVE,MODE  :OUT MODEREG,MODE
680 '
690 'Clear screen; Set all characters to 177, attributes to 0
700 DEF SEG=&HB800
710 FOR ADDR=0 TO 16000 STEP 2  :POKE ADDR,177  :POKE ADDR+1,0  :NEXT
720 '
730 'Draw a matrix of colors
740 FOR I=1 TO 31
750     FOR J=1 TO 63
760             X=I     :Y=J
770             BG=ORDER(I\2 MOD 16)
780             FG=ORDER(J\4 MOD 16)
790             GOSUB 960
800     NEXT
810 NEXT
820 '
830 'Draw diagonal lines using selected colors
840 FOR I=0 TO 75
850     PICK=CHOICE(1+(I\1 MOD 19))
860     BG=COLOUR(PICK,0)       :FG=COLOUR(PICK,1)
870     X=40+I MOD 19           :Y=I
880     GOSUB 960
890 NEXT
900 '
910 'Wait for keypress, restore text mode, end program
915 FOR  I=0 TO 135     :LPRINT I":"COLOUR(I,0);COLOUR(I,1),    :NEXT
920 WHILE INKEY$=""     :WEND
930 SCREEN 2    :SCREEN 0,0,0   :END
940 '==================================================================
950 'Subroutine to plot PIXCOL at (X,Y)
960 PIXEL=2*X+(Y*160)   :PIXELADDR=(PIXEL AND &HFFFE)+1
970 POKE PIXELADDR,BG*16+FG     :RETURN
