

                      Appendix A  Video BIOS Summary



     All computers in the IBM PC and PS/2 family have a BIOS (Basic
     Input/Output System) in ROM. The ROM BIOS contains a set of assembly-
     language routines that provide a low-level programming interface for
     accessing various hardware features, including disk drives, the system
     timer, serial I/O ports, a parallel printer, and, of course, the video
     hardware. By building a video BIOS in ROM into every machine, IBM has
     attempted to provide a common software interface for the various
     machines, despite substantial hardware differences among the IBM PC,
     the PC/XT, the PC/AT, and the PS/2s.

     To a large extent, this endeavor succeeded. Transporting programs
     between IBM PCs with different hardware tends to be easier when the
     programs access the hardware only by calling ROM BIOS routines. This
     is particularly true of programs that manipulate the video display.
     When you consider the many video display configurations available, you
     might regard the BIOS as a sort of "lowest common denominator" for the
     software developer.

     Still, you might not always choose to use ROM BIOS routines for video
     output for several reasons. For one, ROM BIOS video support routines
     are not very fast. When performance is critical, you probably will not
     use them. The speed of the routines is rarely important for tasks
     performed infrequently, such as loading a character set into RAM or
     changing a video display mode. On the other hand, in displaying
     graphics images or producing animation effects, using the BIOS can
     substantially decrease performance.

     Many other tasks are better performed by your operating system rather
     than the BIOS. For example, when you call the BIOS to write characters
     to the screen, you bypass any operating system processing of those
     characters. The BIOS routines know nothing about input/output
     redirection, windowing, or other functions the operating system
     provides.

     Clearly, the video ROM BIOS is essential to IBM PC video programming,
     but the extent to which your programs use it is a matter for your
     judgment.


Hardware Supported by ROM Video BIOS



MDA and CGA

     The ROM BIOS on the motherboard of every IBM/PC, PC/XT, and PC/AT
     supports both the MDA and the CGA. Also, the PS/2 Model 30's video
     BIOS supports an MDA, in addition to its integrated MCGA. When you
     power a PC on, the vector for interrupt 10H is initialized to point to
     the video service routine in ROM.

     IBM's technical documentation frequently refers to the motherboard ROM
     BIOS  in the PCs and PS/2s as the "planar" BIOS. The planar BIOS
     routines start at F000:E000 in the CPU's address space.


EGA

     IBM's EGA contains its own set of video drivers in ROM, located at
     C000:0000. The EGA's cold boot routines initialize interrupt 10H to
     point to its service routine in the EGA ROM BIOS. The EGA BIOS uses
     the interrupt 42H vector to point to the motherboard video service
     routine. Because the EGA's interrupt 10H routines access the
     motherboard BIOS routines whenever necessary through INT 42H, you
     rarely need to execute this interrupt explicitly.


MCGA

     The video ROM BIOS in the PS/2 Models 25 and 30 supports the
     integrated MCGA subsystem in these computers. The Model 30's ROM BIOS
     supports the concurrent use of an MDA, but a CGA cannot be used in the
     same machine because its I/O port assignments and video memory usage
     conflict with those of the MCGA.


VGA

     Video ROM routines in the PS/2 Models 50, 60, and 80, starting at
     E000:0000, support the VGA exclusively. The other video adapters
     described in this book cannot be installed in these computers because
     they are incompatible with the PS/2 MicroChannel bus.


VGA Adapter

     The VGA Adapter's video ROM BIOS routines start at C000:0000. The BIOS
     routines on the VGA Adapter are the same as those in the PS/2 Model
     50, 60, and 80 video BIOS, except for minor differences related to the
     different hardware implementations of the adapter and the integrated
     VGA subsystem.


Interrupt 10H


     The BIOS video routines are written in assembly language and accessed
     by performing 80x86 interrupt 10H. The INT 10H interface is designed
     for assembly-language programs, but you can call the BIOS routines
     directly from programs written in languages such as C or Pascal if
     your language compiler provides a way to execute the interrupt.

     You select a BIOS video support routine by loading a function number
     into register AH. To pass parameters to the BIOS routine, place their
     values in the 80x86 registers before executing INT 10H. Values that
     the BIOS routines return to your program are left in registers as
     well.

     The IBM PC motherboard BIOS routines explicitly preserve the contents
     of registers DS, ES, BX, CX, DX, SI, and DI (unless they are used for
     parameter passing). The EGA, MCGA, and VGA BIOS routines also preserve
     register BP.

       ÉÍÍÍ»     If you are using the IBM PC or PC/XT planar BIOS, preserve
       º T º     register BP across INT 10H calls to the BIOS. For example:
       º I º           push bp                ; preserve BP
       º P º           int  10h               ; call the BIOS
       ÈÍÍÍ¼           pop  bp                ; restore BP


     As a rule, BIOS video input/output routines do not validate data, nor
     do they return status codes or error flags. Thus, your programs should
     never attempt to access an invalid video buffer address, select a
     video page in a video mode that does not support them, or access
     hardware not installed in your system. The BIOS routines do not
     reliably detect any of these errors.


Video BIOS Data Areas


Video Display Data Area

     The BIOS routines maintain several dynamic variables in an area of
     memory called the Video Display Data Area. Figure A-1 contains a
     summary of these variables' addresses, their symbolic names, and their
     contents.


Address             Name           Type      Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0040:0049           CRT_MODE       Byte      Current BIOS video mode number
0040:004A           CRT_COLS       Word      Number of displayed character
                                               columns
0040:004C           CRT_LEN        Word      Size of video buffer in bytes
0040:004E           CRT_START      Word      Offset of start of video
                                               buffer
0040:0050           CURSOR_POSN    Word      Array of eight words
                                               containing the cursor
                                               position for each of eight
                                               possible video pages. The
                                               high-order byte of each word
                                               contains the character row,
                                               the low-order byte the
                                               character column.
0040:0060           CURSOR_MODE    Word      Starting and ending lines for
                                               alphanumeric cursor. The
                                               high-order byte contains the
                                               starting (top) line; the
                                               low- order byte contains the
                                               ending (bottom) line.
0040:0062           ACTIVE_PAGE    Byte      Currently displayed video page
                                               number
0040:0063           ADDR_6845      Word      I/O port address of CRT
                                               Controller's Address
                                               register (3B4H for
                                               monochrome, 3D4H for color).
0040:0065           CRT_MODE_SE    T         Byte Current value for Mode
                                               Control register (3B8H on
                                               MDA, 3D8H on CGA). On the
                                               EGA and VGA, the value
                                               emulates those used on the
                                               MDA and CGA.
0040:0066           CRT_PALETTE    Byte      Current value for the CGA
                                               Color Select register
                                               (3D9H). On the EGA and VGA,
                                               the value emulates those
                                               used on the MDA and CGA.
0040:0084           ROWS           Byte      Number of displayed character
                                               rows - 1
0040:0085           POINTS         Word      Height of character matrix
0040:0087           INFO           Byte      (See Figure A-1a)
0040:0088           INFO_3         Byte      (See Figure A-1b)
0040:0089           Flags          Byte      Miscellaneous flags (see
                                               Figure A-1c)
0040:008A           DCC            Byte      Display Combination Code table
                                               index
0040:00A8           SAVE_PTR       Dword     Pointer to BIOS Save Area (see
                                               Figure A-3)
     Figure A-1.  BIOS Video Display Data Area.


Bit       Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
7         Reflects bit 7 of video mode number passed to INT 10H
          function 0
6-5       Amount of video RAM:
                     00b - 64K
                     01b - 128K
                     10b - 192K
                     11b - 256K
4         (reserved)
3         1 - video subsystem is inactive
2         (reserved)
1         1 - video subsystem is attached to monochrome display
0         1 - alphanumeric cursor emulation is enabled
     Figure A-1a.  Mapping of INFO byte at 0040:0087 in the EGA and VGA
     Video Display Data Area.


Bit       Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
7         Input from feature connector on FEAT1 (bit 6 of Input Status
            register 0) in response to output on FC1 (bit 1 of Feature
            Control register)
6         Input from feature connector on FEAT0 (bit 5 of Input Status
            register 0) in response to output on FC1 (bit 1 of Feature
            Control register)
5         Input from feature connector on FEAT1 (bit 6 of Input Status
            register 0) in response to output on FC0 (bit 0 of Feature
            Control register)
4         Input from feature connector on FEAT0 (bit 5 of Input Status
            register 0) in response to output on FC0 (bit 0 of Feature
            Control register)
3         Configuration switch 4 (1 - off, 0 - on)
2         Configuration switch 3 (1 - off, 0 - on)
1         Configuration switch 2 (1 - off, 0 - on)
0         Configuration switch 1 (1 - off, 0 - on)
     Figure A-1b.  Mapping of INFO_3 byte at 0040:0088 in the EGA and VGA
     Video Display Data Area. Bits 4 through 7 reflect the power-on status
     of the feature connector. Bits 0 through 3 reflect the settings of the
     four EGA configuration switches. (The switch values are emulated by
     the VGA BIOS, depending on the type of display attached.)


Bit       Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
7         Alphanumeric scan lines (with bit 4):
          bit 7   bit 4
          0       0       350-line mode
          0       1       400-line mode
          1       0       200-line mode
          1       1       (reserved)
6         1 - display switching is enabled
          0 - display switching is disabled
5         (reserved)
4         (see bit 7)
3         1 - default palette loading is disabled
          0 - default palette loading is enabled
2         1 - using monochrome monitor
          0 - using color monitor
1         1 - gray scale summing is enabled
          0 - gray scale summing is disabled
0         1 - VGA active
          0 - VGA not active
     Figure A-1c.  Mapping of Flags byte at 0040:0089 in MCGA and VGA Video
     Display Data Area.


     Video BIOS routines update the values in the Video Display Data Area
     to reflect the status of the video subsystem. If you alter the video
     environment without invoking an INT 10H routine, be sure you update
     the relevant variables in the Video Display Data Area. Failing to do
     so can cause the BIOS video routines to malfunction.


Save Areas

     The ROM BIOS routines on the EGA, the MCGA, and the VGA support a set
     of save areas, which are dynamic tables of video hardware and BIOS
     information. The video BIOS can use these save areas to supplement the
     Video Display Data Area. You can also use them to override the usual
     video BIOS defaults for character sets, palette programming, and other
     configuration functions.

     The video BIOS save areas are linked by a set of doubleword
     (segment:offset) pointers (see Figure A-2). Use the variable SAVE_PTR
     (at 0040:00A8 in the Video Display Data Area) to locate the save
     areas. SAVE_PTR contains the address of the SAVE POINTER table (see
     Figure A-3). This table contains addresses of as many as seven data
     structures, each with a different format and a different set of data
     pertaining to operation of the video hardware or of the video BIOS
     routines.

     The fifth address in the SAVE POINTER table is that of the SECONDARY
     SAVE POINTER table (see Figure A-4), which only the VGA's BIOS uses.
     This table also contains the addresses of several data structures with
     contents relating to the functioning of the video hardware and the
     BIOS.


     ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     ³        PTR         ³
     ÀÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÙ
               
     ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     ³                    ÃÄÄÄÄÄVideo Parameter table
     ³ SAVE POINTER Table ÃÄÄÄÄÄParameter Save Area
     ³                    ÃÄÄÄÄÄAlphanumeric Character Set Override
     ³                    ÃÄÄÄÄÄGraphics Character Set Override
     ³                    ÃÄÄÄÄÄ¿
     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     ³
               ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               
     ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     ³   SECONDARY SAVE   ÃÄÄÄÄÄDisplay Combination Code
     ³   POINTER Table    ÃÄÄÄÄÄ2nd Alphanumeric Character Set Override
     ³     (VGA only)     ÃÄÄÄÄÄUser Palette Profile Table
     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Figure A-2.  Video BIOS Save Areas.


Offset    Type             Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         Dword            Address of Video Parameter table
4         Dword            Address of Parameter Save Area (EGA, VGA only)
8         Dword            Address of Alphanumeric Character Set Override
0CH       Dword            Address of Graphics Character Set Override
10H       Dword            Address of SECONDARY SAVE POINTER table
                             (VGA only)
14H       Dword            (reserved)
18H       Dword            (reserved)
     Figure A-3.  SAVE POINTER table (EGA, MCGA, VGA).


Offset      Type           Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0           Word           Length of SECONDARY SAVE POINTER table in
                             bytes
2           Dword          Address of Display Combination Code table
6           Dword          Address of second Alphanumeric Character
                             Set Override
0AH         Dword          Address of User Palette Profile table
0EH         Dword          (reserved)
12H         Dword          (reserved)
16H         Dword          (reserved)
     Figure A-4.  SECONDARY SAVE POINTER table (VGA only).


     Apart from the SAVE POINTER and SECONDARY SAVE POINTER tables, the
     only data structures provided in the ROM BIOS are the Video Parameter
     table and, on the VGA, the Display Combination Code table. Thus, the
     only initialized addresses in the SAVE POINTER table are those of the
     Video Parameter table and of the SECONDARY SAVE POINTER table. The
     only initialized address in the SECONDARY SAVE POINTER table belongs
     to the Display Combination Code table. Remaining addresses are
     initialized to 0.


Video Parameter Table

     This data structure contains configuration parameters that the video
     BIOS video mode set routines use. The table contains entries for each
     available video mode. Its structure differs on the various models of
     the EGA, the MCGA, and the VGA. Figure A-5 is a typical entry in the
     VGA Video Parameter table. Formats for table entries in the EGA and
     MCGA BIOS are similar.


Offset    Type             Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         Byte             Value for CRT_COLS
1         Byte             Value for ROWS
2         Byte             Value for POINTS
3         Word             Value for CRT_LEN
5         4-byte array     Values for Sequencer registers 1-4
9         Byte             Value for Miscellaneous Output register
0AH       25-byte array    Values for CRTC registers 0-18H
23H       20-byte array    Values for Attribute Controller registers 0-13H
37H       9-byte array     Values for Graphics Controller registers 0-8
     Figure A-5.  Format of a VGA Video Parameter table entry. The VGA
     Video Parameter table comprises 29 such entries.


Parameter Save Area

     When present, this table contains the values of the EGA or the VGA
     Graphics Controller palette registers (00H through 0FH) and the
     Overscan register (11H), as shown in Figure A-6. The video BIOS
     updates the Parameter Save Area whenever it updates the corresponding
     Attribute Controller registers.


Offset    Type             Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         16-byte array    Current contents of Graphics Controller
                             Palette registers
10H       Byte             Current contents of Graphics Controller
                             Overscan register
11H-0FFH  (reserved)
     Figure A-6.  Parameter Save Area. This area is 256 bytes in size.


       ÉÍÍÍ»     When a User Palette Profile (see Figure A-10 later in
       º T º     this discussion) overrides the default palette register
       º I º     values, the Parameter Save Area is updated with default
       º P º     values, not those in the User Palette Profile.
       ÈÍÍÍ¼


Alphanumeric Character Set Override


     This data structure (see Figure A-7) indicates an alphanumeric
     character set to be used instead of the BIOS default character set.
     The character set is loaded whenever the video BIOS is called to
     select one of the video modes that the data structure specifies.


Offset    Type             Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         Byte             Length in bytes of each character definition
1         Byte             Character generator RAM bank
2         Word             Number of characters defined
4         Word             First character code in table
6         Dword            Address of character definition table
0AH       Byte             Number of displayed character rows
0BH       Byte array       Applicable video modes
          Byte             0FFH (end of list of video modes)
     Figure A-7.  Alphanumeric Character Set Override.


     On the VGA, you can specify a second 256-character set by creating a
     second Alphanumeric Character Set Override data structure and storing
     its address in the SECONDARY SAVE POINTER table.


Graphics Character Set Override

     This data structure (see Figure A-8) overrides the default BIOS
     character set selection whenever the video BIOS sets up one of the
     specified video modes.


Offset    Type             Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         Byte             Number of displayed character rows
1         Word             Length in bytes of each character definition
3         Dword            Address of character definition table
7         Byte array       Applicable video modes
          Byte             0FFH (end of list of video modes)
     Figure A-8.  Graphics Character Set Override.


Display Combination Code Table

     Figure A-9 lists all combinations of video subsystems that the video
     BIOS supports. The description of INT 10H function 1AH in this
     appendix explains how this table is used.

       ÉÍÍÍ»     The MCGA video BIOS contains a Display Combination Code
       º T º     table in ROM to support INT 10H function 1AH. However, the
       º I º     MCGA BIOS does not support a SECONDARY SAVE POINTER table,
       º P º     so you can't modify its DCC table.
       ÈÍÍÍ¼


Offset    Type             Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         Byte             Number of entries in table
1         Byte             DCC table version number
2         Byte             Maximum display type code
3         Byte             (reserved)
4         Word array       Each pair of bytes in the array describes a
                             valid display combination (see INT 10H
                             function 1AH)
     Figure A-9.  Display Combination Code table.


User Palette Profile Table

     This data structure contains user-specified overrides for the default
     Attribute Controller Palette and Overscan register values, for the
     default values in the 256 video DAC color registers, and for the
     default value in the CRTC Underline Location register (see Figure A-
     10). Only the VGA video BIOS supports this table.


Offset    Type             Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         Byte             Underlining:  1 - Enable in all alphanumeric
                                               modes
                                         0 - Enable in monochrome
                                               alphanumeric mode
                                        -1 - Disable in all alphanumeric
                                               modes
1         Byte             (reserved)
2         Word             (reserved)
4         Word             Number of Attribute Controller registers in
                             table
6         Word             First Attribute Controller register number
8         Dword            Address of Attribute Controller register
                             table
0CH       Word             Number of video DAC Color registers in
                             table
0EH       Word             First video DAC Color register number
10H       Dword            Address of video DAC Color register table
14H       Byte array       Applicable video modes
          Byte             0FFH (end of list of video modes)
     Figure A-10.  User Palette Profile table.


Video BIOS Save Area Programming

     To use a data structure supported in the SAVE POINTER and SECONDARY
     SAVE POINTER tables, place the data structure in RAM and update the
     appropriate SAVE POINTER or SECONDARY SAVE POINTER addresses to point
     to it. Because the default SAVE POINTER and SECONDARY SAVE POINTER
     tables are located in ROM, you must copy these tables to RAM and
     update SAVE_PTR (0040:00A8) appropriately before you can modify them.

     Listings A-1 and A-2 demonstrate two uses of the video BIOS save
     areas. The routine in Listing A-1 provides a parameter save area for
     the EGA or VGA BIOS. Once the parameter save area is established, its
     first 17 bytes are updated with the contents of the Attribute
     Controller's 16 palette registers and its Overscan register each time
     the video BIOS writes to them.


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

     Listing A-1.  Using a Parameter Save Area to keep track of EGA or VGA
     palette registers.

                TITLE   'Listing A-1'
                NAME    EstablishPSA
                PAGE    55,132

;
; Name:         EstablishPSA
;
; Function:     Establish a Parameter Save Area for the EGA or VGA video BIOS.
;               This save area will reflect the current values of the Attribute
;               Controller's Palette and Overscan registers.
;
; Caller:       Microsoft C:
;
;                       void EstablishPSA();
;

SAVE_PTR        EQU     0A8h

DGROUP          GROUP   _DATA

_TEXT           SEGMENT byte public 'CODE'
                ASSUME  cs:_TEXT,ds:DGROUP,es:DGROUP

                PUBLIC  _EstablishPSA
_EstablishPSA   PROC    near

                push    bp
                mov     bp,sp
                push    si
                push    di

; preserve previous SAVE_PTR

                push    ds
                pop     es              ; ES -> DGROUP
                mov     di,offset DGROUP:Old_SAVE_PTR

                mov     ax,40h
                mov     ds,ax           ; DS -> video BIOS data area
                mov     si,SAVE_PTR     ; DS:SI -> SAVE_PTR

                mov     cx,4
                rep     movsb

; copy SAVE POINTER table to RAM

                lds     si,es:Old_SAVE_PTR      ; DS:SI -> SAVE POINTER table
                mov     di,offset DGROUP:SP_TABLE1
                mov     cx,7*4          ; number of bytes to move
                rep     movsb

; update SAVE_PTR with the address of the new SAVE POINTER table

                mov     ds,ax           ; DS -> video BIOS data area
                mov     si,SAVE_PTR
                mov     word ptr [si],offset DGROUP:SP_TABLE1
                mov     [si+2],es

; update SAVE POINTER table with address of Parameter Save Area

                push    es
                pop     ds      ; DS -> DGROUP

                mov     word ptr SP_TABLE1[4],offset DGROUP:PSA
                mov     word ptr SP_TABLE1[6],ds

; restore registers and exit

                pop     di
                pop     si
                mov     sp,bp
                pop     bp
                ret

_EstablishPSA   ENDP

_TEXT           ENDS


_DATA           SEGMENT word public 'DATA'

Old_SAVE_PTR    DD      ?               ; previous value of SAVE_PTR

SP_TABLE1       DD      7 dup(?)        ; RAM copy of SAVE POINTER table

PSA             DB      256 dup(0)      ; Parameter Save Area

_DATA           ENDS

                END

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


     Listing A-2 shows how to specify the palette values to be used when
     the video BIOS routines are invoked to establish a new video mode.
     First, place the values in a table whose address is stored in a User
     Palette Profile data structure. Then place the address of this data
     structure in the SECONDARY SAVE POINTER table. (Since this example
     uses the SECONDARY SAVE POINTER table, you can run it only on the
     VGA.)


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

     Listing A-2.  Using a User Palette Profile to override the
     default VGA palette.

                TITLE   'Listing A-2'
                NAME    EstablishUPP
                PAGE    55,132

;
; Name:         EstablishUPP
;
; Function:     Establish a User Palette Profile Save Area for the VGA video BIOS.
;               This save area overrides the usual default palette values for a
;               specified list of video modes.
;
; Caller:       Microsoft C:
;
;                       void EstablishUPP();
;

SAVE_PTR        EQU     0A8h

DGROUP          GROUP   _DATA

_TEXT           SEGMENT byte public 'CODE'
                ASSUME  cs:_TEXT,ds:DGROUP,es:DGROUP

                PUBLIC  _EstablishUPP
_EstablishUPP   PROC    near

                push    bp
                mov     bp,sp
                push    si
                push    di

; preserve previous SAVE_PTR

                push    ds
                pop     es              ; ES -> DGROUP
                mov     di,offset DGROUP:Old_SAVE_PTR

                mov     ax,40h
                mov     ds,ax           ; DS -> video BIOS data area
                mov     si,SAVE_PTR     ; DS:SI -> SAVE_PTR

                mov     cx,4
                rep     movsb

; copy SAVE POINTER table to RAM

                lds     si,es:Old_SAVE_PTR      ; DS:SI -> SAVE POINTER table
                mov     di,offset DGROUP:SP_TABLE1
                mov     cx,7*4          ; number of bytes to move
                rep     movsb

; update SAVE_PTR with the address of the new SAVE POINTER table

                mov     ds,ax           ; DS -> video BIOS data area
                mov     si,SAVE_PTR
                mov     word ptr [si],offset DGROUP:SP_TABLE1
                mov     [si+2],es

; copy SECONDARY SAVE POINTER table to RAM

                lds     si,es:SP_TABLE1[16]     ; DS:SI -> SEC SAVE POINTER table
                mov     di,offset DGROUP:SP_TABLE2
                mov     cx,[si]
                rep     movsb

; update new SAVE POINTER table with address of new SECONDARY SAVE POINTER table

                push    es
                pop     ds      ; DS -> DGROUP

                mov     word ptr SP_TABLE1[16],offset DGROUP:SP_TABLE2
                mov     word ptr SP_TABLE1[18],ds

; update SECONDARY SAVE POINTER with address of User Palette Profile

                mov     word ptr SP_TABLE2[10],offset DGROUP:UPP
                mov     word ptr SP_TABLE2[12],ds

; restore registers and exit

                pop     di
                pop     si
                mov     sp,bp
                pop     bp
                ret

_EstablishUPP   ENDP

_TEXT           ENDS


_DATA           SEGMENT word public 'DATA'

Old_SAVE_PTR    DD      ?               ; previous value of SAVE_PTR

SP_TABLE1       DD      7 dup(?)        ; copy of SAVE POINTER table

SP_TABLE2       DW      ?               ; copy of SECONDARY SAVE POINTER table
                DD      6 dup(?)

UPP             DB      0               ; underlining flag
                DB      0               ; (reserved)
                DW      0               ; (reserved)
                DW      17              ; # of palette & overscan registers
                DW      0               ; first register specified in table
                DW      DGROUP:PalTable ; pointer to palette table
                DW      seg DGROUP
                DW      0               ; number of video DAC color regs
                DW      0               ; first video DAC register
                DD      0               ; pointer to video DAC color table
                DB      3,0FFh          ; list of applicable video modes

PalTable        DB      30h,31h,32h,33h,34h,35h,36h,37h ; a custom palette
                DB      00h,01h,02h,03h,04h,05h,14h,07h
                DB      01h                             ; overscan reg

_DATA           ENDS

                END


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


       ÉÍÍÍ»     Generally, your application should restore SAVE_PTR to its
       º T º     original value when the SAVE POINTER tables and save areas
       º I º     are no longer needed. If you want to preserve these tables
       º P º     in RAM for use by subsequent applications, use the MS-DOS
       ÈÍÍÍ¼     "Terminate-but-Stay-Resident" function (INT 21H function
                 31H) so that the RAM containing the tables is not freed
                 when the program that creates them terminates.


Interrupt 1DH Vector

     This interrupt vector contains the address of a table of video
     initialization values (see Figure A-11). These values are useful only
     for the MDA and the CGA; however, the table is maintained for
     compatibility among all PCs and PS/2s.


Offset    Type             Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         16-byte array    CRTC registers for 40-by-25 alphanumeric
                             mode (CGA)
10H       16-byte array    CRTC registers for 80-by-25 alphanumeric
                             mode (CGA)
20H       16-byte array    CRTC registers for 320-by-200 4-color or
                             640-by-200 2-color graphics modes (CGA)
30H       16-byte array    CRTC registers for 80-by-25 monochrome
                             (MDA)
40H       Word             Video buffer length (40-by-25 alphanumeric
                             mode)
42H       Word             Video buffer length (80-by-25 alphanumeric
                             mode)
44H       Word             Video buffer length (CGA graphics modes)
46H       Word             Video buffer length (CGA graphics modes)
48H       8-byte array     Number of displayed character columns for
                             video BIOS modes 0 through 7
50H       8-byte array     Values for CRT Mode Control register 3x8H
                             for video BIOS modes 0 through 7
     Figure A-11.  MDA and CGA Video Initialization table. This table's
     address is stored in the vector for INT 1DH.


IBM PC and PS/2 Video BIOS Functions (INT 10H Interface)


     The following pages provide detailed descriptions of each BIOS
     function available through software interrupt 10H. The descriptions
     are intended to complement the function summaries and assembly-
     language source code listings in IBM's technical literature. The
     accompanying source code fragments represent typical programming
     examples that you can modify for your own purposes.

     This summary includes information on the ROM BIOS routines found on
     the motherboard, the EGA, the MCGA, and the VGA. However, not all the
     routines are available or function identically on all computers in the
     IBM PC and PS/2 family.

     All information in this chapter is based on IBM technical
     specifications and on the following dated versions of the video ROM:

     þ  IBM PC motherboard ROM: 10/27/82

     þ  IBM PC/AT motherboard ROM: 6/10/85

     þ  IBM EGA ROM: 9/13/84

     þ  IBM PS/2 Model 30 (MCGA) ROM: 9/2/86

     þ  IBM PS/2 Model 60 (VGA) ROM: 2/13/87

     þ  IBM PS/2 (VGA) Display Adapter ROM: 10/27/86



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 0: Select Video Mode

Caller registers:

     AH   =    0
     AL   =    video mode number:
               0      40-by-25 16-color alphanumeric, color burst disabled
               1      40-by-25 16-color alphanumeric, color burst enabled
               2      80-by-25 16-color alphanumeric, color burst disabled
               3      80-by-25 16-color alphanumeric, color burst enabled
               4      320-by-200 4-color graphics, color burst enabled
               5      320-by-200 4-color graphics, color burst disabled
               6      640-by-200 2-color graphics, color burst enabled
               7      80-by-25 monochrome alphanumeric (MDA, Hercules, EGA,
                         and VGA only)
               8      160-by-200 16-color graphics (PCjr only)
               9      320-by-200 16-color graphics (PCjr only)
               0AH    640-by-200 4-color graphics (PCjr only)
               0BH    Reserved (used by EGA BIOS function 11H)
               0CH    Reserved (used by EGA BIOS function 11H)
               0DH    320-by-200 16-color graphics (EGA and VGA only)
               0EH    640-by-200 16-color graphics (EGA and VGA only)
               0FH    640-by-350 monochrome graphics (EGA and VGA only)
               10H    640-by-350 16-color graphics (VGA, EGA with at least
                         128 KB)
                      640-by-350 4-color graphics (64 KB EGA)
               11H    640-by-480 2-color graphics (MCGA, VGA only)
               12H    640-by-480 16-color graphics (VGA only)
               13H    320-by-200 256-color graphics (MCGA and VGA only)

Returned values:

     (none)

Video Display Data Area updates:

     0040:0049  CRT_MODE
     0040:004A  CRT_COLS
     0040:004C  CRT_LEN
     0040:004E  CRT_START
     0040:0050  CURSOR_POSN
     0040:0060  CURSOR_MODE
     0040:0062  ACTIVE_PAGE
     0040:0063  ADDR_6845
     0040:0065  CRT_MODE_SET
     0040:0066  CRT_PALETTE
     0040:0084  ROWS
     0040:0085  POINTS
     0040:0087  INFO
     0040:0088  INFO_3

     INT 10H function 0 puts the video subsystem in the video mode you
     specify with the value in register AL. Function 0 programs the CRT
     Controller, selects a default color palette, and optionally clears the
     video buffer. You can modify several default tasks that function 0
     performs by setting flags in the Video Display Data Area (see INT 10H
     function 12H) or by providing character set or palette attribute
     overrides in BIOS save areas.

     Video mode numbers 0BH and 0CH are reserved for the EGA BIOS support
     routine for RAM-loadable character sets, in which video memory map 2
     is selectively enabled so a table of character definitions can be
     loaded.

     On the EGA, the MCGA, and the VGA, composite video displays are not
     supported, and there is no color burst signal to control. Thus, mode 0
     is the same as mode 1, mode 2 = mode 3, and mode 4 = mode 5.

     If you use this BIOS routine to request a video mode your system
     hardware does not support, the results are unreliable. In particular,
     if you select mode 7 (monochrome alphanumeric) with a CGA, the
     motherboard BIOS programs the CGA's CRT Controller with parameters
     appropriate for an MDA, which results in incomprehensible noise on the
     CGA screen. The third example below shows how to solve this problem by
     setting bits 4 and 5 of EQUIP_FLAG (0040:0010) to indicate which
     subsystem the BIOS is to use.

     On the EGA, the MCGA, and the VGA, if bit 7 of the requested video
     mode number in AL is set to 1, the video buffer is not cleared when
     the new video mode is selected. Thus, a program can alternate between
     two video subsystems without losing the contents of their video
     buffers.

     The following example selects 320-by-200 4-color graphics mode.

        mov  ax,0004        ; AH := 0 (INT 10H function number)
                            ; AL := 4 (video mode number)
        int  10h

     This routine shows how to change modes on the EGA without clearing
     the video buffer.

        mov  ax,000EH       ; select a video mode (in this case,
                            ;  640x200 16-color mode)
        or   al,10000000b   ; set bit 7
        int  10h

     To select video modes in a system containing both a CGA and an MDA,
     use a routine such as the following.

        mov  ax,40h

        mov  es,ax
        and  byte ptr es:[10h],11001111b  ; zero bits 4 and 5 of EQUIP_FLAG
        or   byte ptr es:[10h],00110000b  ; set bits 4 and 5:
                                          ;  11b - monochrome
                                          ;  10b - color (80x25)
                                          ;  01b - color (40x25)
                                          ;  00b - (unused)
        mov  ax,0007
        int  10h                          ; select monochrome mode 7

        and  byte ptr es:[10],11001111b   ; zero those bits
        or   byte ptr es:[10],00100000b   ; bits for 80x25 16-color
        mov  ax,0003
        int  10h                          ; select 80x25 16-color mode 3



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 1: Set Alphanumeric Cursor Size

Caller registers:

     AH   =    1
     CH   =    top line of cursor
     CL   =    bottom line of cursor

Returned values:

     (none)

Video Display Data Area update:

     0040:0060  CURSOR_MODE

     INT 10H function 1 programs the CRT Controller to display the
     specified alphanumeric cursor. It programs the CRT Controller's Cursor
     Start and Cursor End registers so that the alphanumeric cursor appears
     between the specified lines in the character matrix. The contents of
     register CX are copied into CURSOR_MODE.


     If the value in CH is 20H the alphanumeric cursor is disabled.

     On the EGA and the VGA, if bit 0 of the INFO byte (0040:0087) is set
     to 0, the BIOS processes the top and bottom line values passed in CH
     and CL relative to an eight-line character matrix. Chapter 3
     discusses this "cursor emulation" in detail.

     Use INT 10H function 1 only in alphanumeric video modes.

     To select a full-height cursor in video mode 3 (80-by-25 16-color
     alphanumeric mode) on a CGA:

        mov  cx,0007h   ; CH := 0 (top line)
                        ; CL := 7 (bottom line of the 8x8 character matrix)
        mov  ah,1       ; AH := 1 (INT 10H function number)
        int  10h

     On an EGA with a 350-line monitor, video mode 3 is a 350-line
     alphanumeric mode with an 8-by-14 character matrix. Nevertheless, the
     above code normally runs unchanged in this situation, because the BIOS
     "emulates" the corresponding 200-line CGA mode and programs the Cursor
     Start and End registers accordingly.



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 2: Set Cursor Location

Caller registers:

     AH   =    2
     BH   =    video page
     DH   =    character row
     DL   =    character column

Returned values:

     (none)

Video Display Data Area update:

     0040:0050  CURSOR_POSN

     INT 10H function 2 updates the BIOS Video Display Data Area, giving a
     new cursor position. If the value in BH references the currently
     displayed video page, this routine also programs the CRT Controller to
     update the displayed cursor position.

     To set the cursor position to column 10, row 5, in 80-by-25 16-color
     mode:

        mov  ah,2           ; AH := 2 (INT 10H function number)
        mov  bh,1           ; BH := video page
        mov  dh,5           ; DH := row
        mov  dl,10          ; DL := column
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Function 3: Return Cursor Status

Caller registers:

     AH   =    3
     BH   =    video page number

Returned values:

     CH   =    top line of cursor
     CL   =    bottom line of cursor
     DH   =    character row
     DL   =    character column

Video Display Data Area updates:

     (none)

     INT 10H function 3 returns the character cursor location for the
     specified video page. The character row and column values are copied
     from CURSOR_POSN in the Video Display Data Area.

     The values returned in CH and CL are copied from CURSOR_MODE, also in
     the Video Display Data Area. They are meaningful only in alphanumeric
     modes.

     To determine the current cursor location (and size in an alphanumeric
     mode) in video page 0:

        mov  ah,3           ; AH := 3 (INT 10H function number)
        mov  bh,0           ; BH := 0 (video page)
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 4: Return Light Pen Position

Caller registers:

     AH   =    4

Returned values:

     AH   =    1 if valid light pen position returned
          =    0 if no light pen position returned
     BX   =    pixel x-coordinate
     CH   =    pixel y-coordinate (CGA and EGA video modes 4, 5, and 6)
     CX   =    pixel y-coordinate (EGA except modes 4, 5, and 6)
     DH   =    character row
     DL   =    character column

Video Display Data Area updates:

     (none)

     INT 10H function 4 gets the current position of the light pen from the
     CRT Controller's Light Pen High and Light Pen Low registers.

     If the light pen switch is not set, or if the light pen latch has not
     been triggered (that is, if the CRTC's Light Pen High and Light Pen
     Low registers do not contain a valid light pen address), function 4
     returns 0 in register AH. Otherwise, function 4 sets AH to 1, leaves
     the light pen position in registers BX, CX, and DX, and resets the
     light pen trigger.


     When function 4 returns, BX contains the calculated pixel x-coordinate
     at which the light pen was triggered. Since the CRTC returns the light
     pen position as a byte address, the value in BX is only as
     accurate as the number of pixels in each byte of the video buffer. (In
     640-by-200 2-color mode, each byte of the video buffer represents
     eight pixels; function 4 thus returns the pixel x-coordinates
     of every eighth pixel.) The light pen position is calculated relative
     to the start of the displayed portion of the video buffer (CRT_START).

     INT 10H function 4 returns the pixel y-coordinate in either CH (in the
     motherboard BIOS) or CX (in all video modes in the EGA BIOS except
     modes 4, 5, and 6). For example, in 320-by-200 4-color graphics mode,
     the pixel y-coordinate is always returned in CH, but in 80-by-25
     16-color alphanumeric mode, the value is returned in CH on a CGA but
     in CX on an EGA.

     The values that function 4 returns in DH and DL represent the
     character row and column at which the light pen was triggered.

     INT 10H function 4 always returns AH = 0 on the MCGA and the VGA,
     which do not support light pens.

     To determine the light pen status in any video mode, call INT 10H
     function 4:

        mov  ah,4           ; AH := 4 (INT 10H function number)
        int  10h

     For example, if you trigger the light pen near the center of the
     display in 640-by-350 16-color mode, the values returned by this
     function might be:

     AH   =    1     (valid light pen results were returned)
     BX   =  320     (x-coordinate of first pixel at the byte
                     address where the pen was triggered)
     CX   =  175     (pixel y-coordinate)
     DH   =   12     (character row)
     DL   =   40     (character column)



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 5: Select Video Page

Caller registers:

     AH   =    5
     AL   =    video page number

Returned values:

     (none)

Video Display Data Area updates:

     0040:004E  CRT_START
     0040:0062  ACTIVE_PAGE

     INT 10H function 5 selects which portion of the video buffer is
     displayed on the CGA, the EGA, the MCGA, and the VGA. It works by
     programming the CRTC Start Address registers. You can use the function
     in 40-by-25 or 80-by-25 alphanumeric video modes (BIOS modes 0, 1, 2,
     and 3) in any of these subsystems.

     On the CGA, the entire 16 KB video buffer is used in both 320-by-200
     and 640-by-200 graphics modes, so no video paging is possible. Calls
     to function 5 are ignored in these modes.

     On the MCGA, the EGA, and the VGA, video pages are available in both
     alphanumeric and graphics modes up to the limits of video RAM.
     However, the BIOS routine does not check whether video RAM is
     sufficient to support a requested video page; if the requested video
     page lies outside the video buffer, the resulting display is unusable.

     The BIOS maintains a current cursor location for as many as eight
     video pages in CURSOR_POSN. When you invoke Function 5, the BIOS moves
     the cursor to where it was located the last time the requested video
     page was displayed.

     The following routine sets the displayed portion of the CGA's video
     buffer to start at B800:1000 (video page 1) in 80-by-25 alphanumeric
     mode:

        mov  ax,0501h       ; AH := 5 (INT 10H function number)
                            ; AL := 1 (video page number)
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 6: Scroll Up

Caller registers:
     AH   =    6
     AL   =    number of lines to scroll
     BH   =    attribute
     CH   =    upper left corner row
     CL   =    upper left corner column
     DH   =    lower right corner row
     DL   =    lower right corner column

Returned values:

     (none)

Video Display Data Area updates:

     (none)

     INT 10H function 6 performs a row-by-row upward scroll of characters
     in a designated area of the active video page. You specify the number
     of rows of characters to scroll in AL. The rectangular area
     in which the scroll is to be performed is defined by its upper left
     corner, specified in CH and CL, and its lower right corner, specified
     in DH and DL.

     The attribute you specify in BH is used for all blank lines inserted
     in the bottom of the scrolled area. In alphanumeric modes, this
     attribute is formatted in the usual manner, with the background
     attribute in the high nibble and the foreground attribute in the low
     nibble. In graphics modes, the format of the attribute in BH depends
     on the mode.

     In 640-by-200 2-color and 320-by-200 4-color modes, the value in BH
     represents a 1-byte pixel pattern. The byte represents eight 1-bit
     pixels in 640-by-200 2-color mode or four 2-bit pixels in 320-by-200
     4-color mode. The pixel pattern is replicated throughout all lines
     that function 6 blanks in the scroll area. In all other EGA, MCGA, and
     VGA graphics modes, the value in BH determines the value of all pixels
     in the blanked lines.

     In 320-by-200 4-color mode on the EGA, the MCGA, and the VGA, function
     6 always scrolls video page 0, regardless of which video page is
     currently displayed.

     Specifying 0 as the number of rows to scroll in AL causes the entire
     scroll area to be blanked.

     In 80-by-25 16-color alphanumeric mode, you can scroll the entire
     screen up one line with the following sequence:

        mov  ax,601h        ; AH := 6 (INT 10H function number)
                            ; AL := 1 (number of lines to scroll up)
        mov  bh,7           ; BH := 7 (attribute)
        mov  cx,0           ; CH := upper left corner:  row 0
                            ; CL := upper left corner:  column 0
        mov  dx,184Fh       ; DH := lower right corner:  row 24 (18H)
                            ; DL := lower right corner:  column 79 (4FH)
        int  10h

     In the same video mode, you could clear only the top three lines of
     the display with a background attribute of 1 (blue on a CGA) and a
     foreground attribute of 7 (white) using this routine:

        mov  ax,600h        ; AH := INT 10H function number
                            ; AL := 0 (clear the scroll area)
        mov  bh,17h         ; BH := attribute (background 1, foreground 7)
        mov  cx,0           ; CH,CL := upper left corner at (0,0)
        mov  dx,024Fh       ; DH,DL := lower right corner at (2,79)
        int  10h

     To get the same result in 640-by-350 16-color graphics mode on the
     EGA, you set the value in BH to indicate a pixel value instead of an
     alphanumeric attribute:

        mov  ax,600h
        mov  bh,1           ; BH := pixel value
        mov  cx,0
        mov  dx,024Fh
        int  10h

     In 640-by-200 2-color mode, the following call to INT 10H function 6
     fills the display with vertical stripes of alternating pixel values:

        mov  ax,600h
        mov  bh,10101010b   ; BH := pixel pattern
        mov  cx,0
        mov  dx,184Fh
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 7: Scroll Down

Caller registers:

     AH   =    7
     AL   =    number of lines to scroll
     BH   =    attribute
     CH   =    upper left corner row
     CL   =    upper left corner column
     DH   =    lower right corner row
     DL   =    lower right corner column

Returned values:

     (none)

Video Display Data Area updates:

     (none)

     INT 10H function 7 performs a row-by-row downward scroll of characters
     in a designated area of the active video page. Except for the direc-
     tion of the scroll, this BIOS function is identical to function 6.




ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 8: Return Character Code and Attribute at Cursor

Caller registers:

     AH   =    8
     BH   =    video page

Returned values:

     AH   =    attribute (alphanumeric modes only)
     AL   =    ASCII code

Video Display Data Area updates:

     (none)

     INT 10H function 8 returns the ASCII code of the character at the
     current cursor position in the video page that BH specifies. In
     alphanumeric modes, this is done by reading a single word from the
     video buffer. In graphics modes, the routine compares the character
     matrix at the cursor position to the bit patterns in the current
     graphics character definition table.

     In graphics modes, the PC/XT and PC/AT BIOS uses the ROM character
     definitions at F000:FA6E; the EGA, MCGA, and VGA BIOS uses the
     definitions designated by the interrupt 43H vector. For ASCII codes
     80-0FFH in CGA-compatible graphics modes 4, 5, and 6, the BIOS uses
     the characters defined in the table indicated by the interrupt 1FH
     vector.

     To determine the character code for a character in a graphics mode,
     the BIOS routine regards nonzero pixels as foreground pixels. It is
     the pattern of foreground (nonzero) and background (zero) pixels that
     is compared to the bit patterns in the table. If the pixel pattern in
     the video buffer matches a bit pattern in the character definition
     table, the BIOS determines the character's ASCII code from the bit
     pattern's location in the table. If the pixel pattern in the video
     buffer does not match any bit pattern in the table, the BIOS routine
     returns 0 in AL.

     In 320-by-200 4-color mode on the EGA, the MCGA, and the VGA, this
     function works properly only in video page 0.

     The following code fragment reads the character in the screen's upper
     left corner:

        mov  ah,0Fh         ; AH := 0FH (INT 10H function number)
        int  10h            ; leaves BH = active video page
        mov  ah,2           ; AH := 2 (INT 10H function number)
        mov  dx,0           ; DH,DL := row 0, column 0
        int  10h            ; sets cursor position to (0,0)
        mov  ah,8           ; AH := 8 (INT 10H function number)
        int  10h            ; leaves AL = ASCII code



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 9: Write Character and Attribute at Cursor

Caller registers:

     AH   =    9
     AL   =    ASCII code
     BH   =    background pixel value (320-by-200 256-color mode) or video
               page (all other modes)
     BL   =    foreground pixel value (graphics modes) or attribute value
               (alphanumeric modes)
     CX   =    repetition factor

Returned values:

     (none)

Video Display Data Area updates:

     (none)

     INT 10H function 9 writes a character one or more times into the video
     buffer without moving the cursor. You must specify a repetition factor
     of 1 or greater in CX. The BIOS writes a string composed of the
     character in AL into the buffer. The length of the string is
     determined by the repetition factor in CX.

     In alphanumeric modes, both the ASCII code and the corresponding
     attribute byte are updated for each character written into the video
     buffer. In graphics modes, each character is written into the buffer
     in a rectangular area the size of the character matrix. The value in
     BL is used for the character's foreground pixels. In 320-by-200 256-
     color graphics mode, the value in BH specifies the character's
     background pixel value; in all other graphics modes, BH designates a
     video page, so the character's background pixels are 0. In all
     graphics modes except 320-by-200 256-color mode, the character is
     XORed into the buffer if bit 7 of BL is set to 1.

     INT 10H function 9 does not compare the repetition factor with the
     number of displayed character columns. In alphanumeric modes, this may
     not matter; the video buffer map is such that a string too long to be
     displayed in one row of characters wraps to the next row. In graphics
     modes, however, a string should be no longer than the remainder of the
     current character row.

     You must specify a video page in register BH in alphanumeric modes as
     well as in native EGA graphics modes, but the value in BH is ignored
     by the EGA, the MCGA, and the VGA BIOS in 320-by-200 4-color graphics
     mode.

     The following routine writes a string of 20 asterisks to the upper
     left corner of the display in 80-by-25 16-color mode. The foreground
     value in each character's attribute byte is set to 7, and the
     background value is set to 1. The cursor is positioned with a call to
     INT 10H function 2 before the string is written with function 9.

        mov  ah,2           ; AH := 2 (INT 10H function number)
        mov  bh,0           ; BH := video page
        mov  dx,0           ; DH := cursor row
                            ; DL := cursor column
        int  10h            ; set cursor position to (0,0)
        mov  ah,9           ; AH := 9 (INT 10H function number)
        mov  al,'*'         ; AL := ASCII code
        mov  bl,17h         ; BL := attribute byte
        mov  cx,20          ; CX := repetition factor
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 0AH: Write Character(s) at Cursor Position

Caller registers:

     AH   =    0AH
     AL   =    ASCII code
     BH   =    background pixel value (320-by-200 256-color mode) or video
               page (all other modes)
     BL   =    foreground pixel value (graphics modes only)
     CX   =    repetition factor

Returned values:

     (none)

Video Display Data Area updates:

     (none)

     INT 10H function 0AH is the same as INT 10H function 9, with this
     exception: In alphanumeric video modes, only the character code is
     written into the video buffer. The character's attribute remains
     unchanged in the buffer.

     This example clears one character row from the cursor position to its
     end. Before calling function 0AH, the example determines the active
     video page and the number of displayed character columns with a call
     to INT 10H function 0FH, and the cursor position using INT 10H
     function 3.

        mov  ah,0Fh         ; AH := 0FH (INT 10H function number)
        int  10h            ; leaves AH = number of columns,
                            ;        BH = active video page
        mov  al,ah
        xor  ah,ah          ; AX := number of columns
        push ax
        mov  ah,3           ; AH := 3 (INT 10H function number)
        int  10h            ; leaves DH,DL = cursor position
        pop  cx             ; CX := displayed character columns
        sub  cl,dl          ; CX := number of remaining chars in line
        xor  bl,bl          ; BL := foreground pixel value
        mov  ax,0A20h       ; AH := 0AH (INT 10H function number)
                            ; AL := 20H (ASCII blank character)
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 0BH: Set Overscan Color, Select 4-Color Palette

Caller registers:

     AH   =    0BH
     BH   =    0 to set border or background color
          =    1 to select 4-color palette
     BL   =    color value (if BH = 0)
               palette value (if BH = 1)

Returned values:

     (none)

Video Display Data Area update:

     0040:0066  CRT_PALETTE

     INT 10H function 0BH comprises two subfunctions selected according to
     the value in BH. Function 0BH is intended for use only in 320-by-200
     4-color mode and in CGA alphanumeric modes, but you can use it with
     caution in other video modes.


     BH = 0
     When BH = 0 on the CGA and the MCGA, the BIOS loads the low-order five
     bits of the value in BL into the Color Select register (3D9H). In 320-
     by-200 4-color graphics mode, bits 0-3 determine the background color
     (the color displayed for pixels of value 0) as well as the border
     color. In 640-by-200 and 640-by-480 2-color modes, bits 0-3 specify
     the color of foreground (nonzero) pixels. On the CGA, these same four
     bits also determine the border color in alphanumeric modes.

     Bit 4 of the Color Select register selects between normal and high-
     intensity colors in CGA and MCGA graphics modes (see Chapter 4). For
     compatibility, the BIOS for the EGA and the VGA emulates this effect
     by using a palette of high-intensity colors when bit 4 of BL is set.

     In 200-line modes on the EGA and VGA, the value in BL is placed in
     the Attribute Controller's Overscan Color register (11H). This sets
     the border color. If either subsystem is in a graphics mode, the same
     value is also stored in palette register 0. This establishes the same
     color for all pixels of value 0.

     Don't use function 0BH with BL = 0 in other EGA and VGA video modes.
     In some modes, the BIOS routine stores incorrect color values in the
     Palette and Overscan registers, while in others it does nothing at
     all. You should use INT 10H function 10H to program the Attribute
     Controller on the EGA and VGA.

     Once the color register or Attribute Controller has been programmed,
     the BIOS routine copies bit 5 of CRT_PALETTE in the Video Display Area
     to bit 0 of register BL, and transfers control to the routine for
     BH = 1.


     BH = 1
     When BH = 1, the low-order bit of the value in BL determines which of
     two 4-color palettes is used for 320-by-200 4-color mode (see Figure
     A-12). On the CGA and the MCGA, this bit is copied into bit 5 of the
     Color Select register (3D9H). On the EGA and the VGA, the bit
     determines which set of color values is loaded into the Attribute
     Controller's Palette registers. The colors correspond to the CGA's
     320-by-200 4-color palettes. (See Chapter 4 for more details.)


Pixel Value            Color Displayed
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
(bit 0 of BL = 0)
1                      Green
2                      Red
3                      Yellow


(bit 0 of BL = 1)
1                      Cyan
2                      Violet
3                      White
     Figure A-12.  Function 0BH 4-color palettes.


     Function 0BH with BH = 1 has no effect in alphanumeric modes. In
     graphics modes other than 320-by-200 4-color mode, however, the Color
     Select register (on the CGA and the MCGA) is loaded or the palette
     registers (on the EGA and the VGA) are updated as if 320-by-200 4-
     color mode were in effect. For this reason, you should use this
     subfunction cautiously in graphics modes other than 320-by-200 4-color
     mode.

     The following example has three different effects, depending on the
     current video mode. In 200-line alphanumeric modes, it sets the border
     color; in 320-by-200 4-color mode it sets both border and background
     colors; and in CGA or MCGA 2-color graphics modes, it sets the
     foreground color.

        mov  ah,0BH         ; AH := 0BH (INT 10H function number)
        mov  bh,0           ; BH := subfunction number
        mov  bl,BorderColor ; BL := color value
        int  10h

     To select a 4-color palette in 320-by-200 4-color mode, call function
     0BH with  BH = 1:

        mov  ah,0Bh
        mov  bh,1           ; BH := subfunction number
        mov  bl,0           ; bit 0 of BL := 0 (red-green-yellow palette)
        int  10h

     In 320-by-200 4-color mode, select a high-intensity set of colors by
     calling function 0BH with BH = 0 and with bit 4 of BL set to 1:

        mov  ah,0Bh
        mov  bh,0
        mov  bl,10h         ; bit 4 selects high-intensity palette
                            ; bits 3-0 select border/background color
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 0CH: Store Pixel Value

Caller registers:

     AH   =    0CH
     AL   =    pixel value
     BH   =    video page
     CX   =    x-coordinate
     DX   =    y-coordinate

Returned values:

     (none)

Video Display Data Area updates:

     (none)

     INT 10H function 0CH updates the value of a pixel at a specified
     location in the video buffer. In all graphics modes except 320-by-200
     256-color mode, if the high-order bit of the value in AL is set to 1,
     the value in AL is XORed into the video buffer. Otherwise, the value
     in AL becomes the pixel's new value.

     On the EGA, the MCGA, and the VGA, the value in BH is used to select
     among available video pages in the current video mode. However, the
     value in BH is ignored in 320-by-200 4-color mode.

     To set the value of a pixel in a 350-line graphics mode on an EGA with
     only 64 KB of video RAM, you must account for the chaining of memory
     maps to bit planes (as discussed in Chapter 4). In this situation,
     the BIOS routine expects you to specify the pixel value in AL using
     only its odd-numbered bits. Thus, the four possible pixel values
     should be specified as 0 (0000B), 1 (0001B), 4 (0100B), and 5 (0101B)
     instead of 0, 1, 2, and 3.

     The following routine shows how you would set the value of the pixel
     at (200,100) to 1 in any graphics mode:

        mov  ah,0Ch         ; AH := 0CH (INT 10H function number)
        mov  al,1           ; AL := pixel value
        mov  cx,200         ; CX := x-coordinate
        mov  dx,100         ; DX := y-coordinate
        int  10h

     To XOR a pixel value into the video buffer, set bit 7 of AL to 1
     before executing interrupt 10H, as in the following procedure:

        mov  ah,0Ch
        mov  al,1
        mov  cx,200
        mov  dx,100
        or   al,10000000b   ; set bit 7 to indicate XOR
        int  10h

     This code fragment illustrates the special situation that arises in a
     350-line video mode on an IBM EGA with only 64 KB of video RAM. The
     code sets the value of the pixel at (75,50) to 3.

        mov  ah,0Ch
        mov  al,0101b       ; AL := pixel value of 3 (11B)
                            ; represented in odd bits only
        mov  cx,75
        mov  dx,50
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 0DH: Return Pixel Value

Caller registers:

     AH   =    0DH
     BH   =    video page
     CX   =    x-coordinate
     DX   =    y-coordinate

Returned values:

     AL   =    pixel value

Video Display Data Area updates:

     (none)

     INT 10H function 0DH returns the value of a pixel at a specified
     location in the video buffer.

     On an EGA in 320-by-200 4-color mode, the function ignores the video
     page value specified in BH.

     IBM's EGA BIOS (9/13/84 version) contains a bug in INT 10H function
     0DH. In 350-line graphics modes on an IBM EGA with only 64 KB of video
     RAM, the value returned in AL is incorrect. Apparently, the BIOS
     routine calculates the pixel's byte offset in the video buffer without
     properly accounting for the mapping of even addresses to even bit
     planes and odd addresses to odd bit planes.

     To determine the value of the pixel at (100,100), you could execute
     the following sequence of instructions:

        mov  ah,0Dh         ; AH := 0DH (INT 10H function number)
        mov  bh,0           ; BH := video page (0 in this example)
        mov  cx,100         ; CX := x-coordinate
        mov  dx,100         ; DX := y-coordinate
        int  10h            ; leaves AL = pixel value



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 0EH: Display Character in Teletype Mode

Caller registers:

     AH   =    0EH
     AL   =    ASCII code
     BH   =    video page (PC BIOS versions dated 10/19/81 and earlier)
     BL   =    foreground pixel value (graphics modes only)

Returned values:

     (none)

Video Display Data Area update:

     0040:0050  CURSOR_POSN

     INT 10H function 0EH calls INT 10H function 0AH to display the
     character you pass in register AL. Unlike function 0AH, however,
     function 0EH moves the cursor, and ASCII codes 7 (bell), 8
     (backspace), 0DH (carriage return), and 0AH (linefeed) are treated as
     cursor control commands instead of displayable characters. Function
     0EH always updates the active (currently displayed) video page except
     as noted above.

     If the character is displayed in the rightmost character column,
     function 0EH advances the cursor to the start of the next character
     row. If necessary, function 0EH calls INT 10H function 06H to scroll
     the screen. In alphanumeric modes, the attribute of the displayed
     character is used for the scroll. In graphics modes, the scroll
     attribute is always 0.

     In alphanumeric modes, the attribute byte at the position where the
     character is written determines the character's foreground and
     background attributes. For this reason, you should probably fill the
     video buffer with the desired alphanumeric attributes before using
     function 0EH.

     In graphics modes, the character is written into the video buffer in a
     rectangular area the size of the character matrix. The character's
     pixels have the value BL specifies, and the remaining background
     pixels have a value of 0. Because the value in BL is passed through to
     INT 10H function 0AH, you can set bit 7 so that the character is XORed
     into the video buffer.

     NOTE: Unfortunately, function 0EH does not expand tab characters
     (ASCII code 9) into blanks.

     The following routine shows how you might use function 0EH to display
     a string of characters.

        mov  cx,StringLength        ; CX := number of bytes in string
        jcxz L02                    ; do nothing if null string
        mov  si,StringAddr          ; DS:SI := address of string
        mov  bl,GraphicsAttribute   ; BL := attribute (graphics modes only)
L01:    lodsb                       ; AL := next character in string
        mov  ah,0Eh                 ; AH := 0EH (INT 10H function number)
        int  10h
        loop L01
L02:    .
        .
        .



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 0FH: Return Current Video Status

Caller register:

     AH   =    0FH

Returned values:

     AH   =    number of displayed character columns
     AL   =    video mode number
     BH   =    active video page

Video Display Data Area updates:

     (none)

     INT 10H function 0FH returns information about the current video mode
     and the width of the displayed portion of the video buffer. The number
     of character columns (returned in AH) and the number of the current
     video page (returned in BH) are copied from CRT_COLS and ACTIVE_PAGE
     in the Video Display Data Area.

     The value returned in AL is copied from CRT_MODE in the Video Display
     Data Area. It corresponds to the video display modes tabulated for
     function 0. On the EGA and the VGA, bit 7 of the value in AL is
     derived from bit 7 of the INFO byte. (INT 10H function 0 sets bit 7 of
     the INFO byte whenever you use function 0 to select a video mode
     without clearing the video buffer.)

     This example shows how to determine the current position of the
     displayed cursor. Before calling INT 10H function 3 to find out the
     cursor position, the example uses function 0FH to determine the
     currently displayed video page.

        mov  ah,0Fh         ; AH := 0FH (INT 10H function number)
        int  10h            ; leaves BH = active video page
        mov  ah,3           ; AH := 3 (INT 10H function number)
        int  10h            ; leaves DH,DL = cursor position



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 10H: Set Palette Registers, Set Intensity/Blink Attribute

Caller registers:

     AH   =    10H

Update a specified palette register:

     AL   =    0
     BH   =    color value
     BL   =    palette register number

Specify the overscan (border) color:

     AL   =    1
     BH   =    color value

Update all 16 palette registers plus the Overscan register:

     AL    =    2
     ES:DX =    address of 17-byte table

Select Background Intensity or Blink attribute:

     AL   =    3
     BL   =    0 for background intensity (blink disabled)
          =    1 for blink

Read a specified palette register:

     AL   =    7
     BL   =    palette register number

     Returned value:
     BH   =    contents of specified palette register

Read the contents of the Overscan register:

     AL   =    8

     Returned value:
     BH   =    contents of Overscan register

Read all 16 palette registers plus the Overscan register:

     AL    =    9
     ES:DX =    address of 17-byte table

     Returned values:
     Bytes 00H through 0FH of table contain palette register values.
     Byte 10H of table contains Overscan register value.

Update the specified video DAC Color register:

     AL   =    10H
     BX   =    color register number
     CH   =    green value
     CL   =    blue value
     DH   =    red value

Update a block of video DAC color registers:

     AL    =    12H
     BX    =    first register to update
     CX    =    number of registers to update
     ES:DX =    address of table of red-green-blue values

Set Attribute Controller Color Select State:

     AL   =    13H
     BL   =    0 to set Mode Control register bit 7, 1 to set Color Select
                 register
     BH   =    value for bit 7 (if BL = 0) or value for Color Select
                 register (if BL = 1)

Read specified video DAC Color register:

     AL   =    15H
     BX   =    color register number

     Returned values:
     CH   =    green
     CL   =    blue
     DH   =    red

Read a block of video DAC color registers:

     AL    =    17H
     BX    =    first register to read
     CX    =    number of registers to read
     ES:DX =    address of table of red-green-blue values

     Returned values:
     Bytes 0 through 3n - 1 (where n is the number of registers passed in
     CX) contain the red-green-blue values read from the specified block of
     color registers.

Update video DAC Mask register:

     AL   =    18H
     BL   =    new mask value

Read video DAC Mask register:

     AL   =    19H

     Returned value:
     BL   =    value read from video DAC Mask register

Read Attribute Controller Color Select register:

     AL   =    1AH

     Returned values:
     BL   =    bit 7 of Mode Control register
     BH   =    bits 2 through 3 of Color Select register (if BL = 0)
               bits 0 through 3 of Color Select register (if BL = 1)

Perform gray-scaling on a block of video DAC color registers:

     AL   =    1BH
     BX   =    first color register in block
     CX   =    number of color registers

Video Display Data Area updates:

     0040:0065  CRT_MODE_SET
     0040:0066  CRT_PALETTE

     INT 10H function 10H exists only in the EGA, MCGA, and VGA BIOS. The
     function comprises 16 subfunctions that are selected according to the
     value in AL. Figure A-13 shows the support that the various
     subsystems provide for these subfunctions. All subfunctions work in
     both alphanumeric and graphics modes.

     Subfunctions 0 through 9 support attribute and palette programming.
     Subfunctions 10H through 1BH support the video DAC on the MCGA and the
     VGA.


     AL = 0
     When AL = 0 on the EGA and the VGA, function 10H updates the value in
     one of the palette registers in the Attribute Controller. The routine
     loads the value in BH into the register that BL specifies.

     Although this subfunction's intended purpose is to load a color value
     into a palette register, the BIOS routine does not validate the
     register number in BL. Thus, you can also use it to update the
     Attribute Controller's Mode Control, Overscan, Color Plane Enable, and
     Horizontal Pel Panning registers.

     On the MCGA, when BH = 7 and BL = 12H, the BIOS routine sets bit 3 of
     the Video DAC Mask register (3C6H) to 0. This causes the BIOS to
     regard bit 3 of all 4-bit pixel values or alphanumeric attributes as a
     "don't care" bit in reference to the Video DAC color registers, so
     only the first eight registers can be referenced. This is useful in
     displaying two 256-character sets in an alphanumeric mode (see Chapter
     10). The MCGA BIOS ignores all other values in BH or BL.


Subfunction           EGA           MCGA         VGA
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0                     x             x            x
1                     x                          x
2                     x                          x
3                     x             x            x
4 (reserved)
5 (reserved)
6 (reserved)
7                                                x
8                                                x
9                                                x
10H                                 x            x
11H (reserved)
12H                                 x            x
13H                                              x
14H (reserved)
15H                                 x            x
16H (reserved)
17H                                 x            x
18H                                 x            x
19H                                 x            x
1AH                                              x
1BH                                 x            x
     Figure A-13.  INT 10H Function 10H support in EGA, MCGA, and VGA BIOS.


     AL = 1
     When AL = 1 on the EGA and the VGA, the BIOS copies the value in BH
     into the Attribute Controller's Overscan register (11H).


     AL = 2
     When AL = 2 on the EGA and the VGA, the BIOS expects ES:DX to contain
     the address of a 17-byte table of values for the 16 Palette registers
     (bytes 0 through 15) and for the Overscan register (byte 16). The
     routine copies these values into the corresponding registers in the
     Attribute Controller.


     AL = 3
     When AL = 3 on the EGA and the VGA, the value in BL determines the
     value of bit 3 of the Attribute Controller's Mode Control register
     (10H). If BL = 0, bit 3 of the Mode Control register value is set to
     0, disabling the blinking attribute. If BL is 1, bit 3 is set to 1 to
     enable blinking.

     When AL = 3 on the MCGA, bit 5 of the Color Control register (3D8H) is
     set to reflect the value in BL. If BL = 0, bit 5 is set to 0 to
     disable blinking. If BL is 1,  bit 5 is set to 1.


     AL = 7
     When AL = 7 on the VGA, the value in the Attribute Controller Palette
     register that BL specified is returned in BH. Because the BIOS does
     not check the specified register number, this subfunction may be used
     to return the contents of any VGA Attribute Controller register.


     AL = 8
     When AL = 8 on the VGA, the contents of the Attribute Controller's
     Overscan register are returned in BH.


     AL = 9
     When AL = 9 on the VGA, the contents of all 16 palette registers and
     the Overscan register are returned to a 17-byte table whose address
     was passed to the BIOS in the register pair ES:DX.


     AL = 10H
     When AL = 10H on the MCGA and the VGA, the video DAC color register
     that BX specifies is updated with the red, green, and blue values
     specified in DH, CH, and CL. Only the low-order six bits of each of
     the three color values are significant.

     If gray-scale summing is enabled, the value stored in the color
     register is the gray-scale value that corresponds to the specified
     color values (see INT 10H function 12H with BL = 33H).


     AL = 12H
     When AL = 12H on the MCGA and the VGA, a block of consecutive video
     DAC color registers is updated from the table whose address is passed
     in ES:DX. The value in BX (00H through 0FFH) indicates the first color
     register to update, and CX contains the number of registers affected.
     The BIOS routine performs no error checking; if the sum of the values
     in BX and CX is greater than 256 (100H), the routine wraps around and
     updates the first color register(s) in the video DAC.

     If gray-scale summing is enabled, the values stored in the color
     registers are the gray-scale values that correspond to the color
     values in the table (see INT 10H function 12H with BL = 33H).

     You must format the table in three-byte groups. Each group must
     contain a red color value in the first byte, a green value in the
     second byte, and a blue value in the third byte. Only the low-order
     six bits of each color value are significant.


     AL = 13H
     On the VGA, when AL = 13H, the ROM BIOS updates the Attribute
     Controller's Mode Control register (10H) and the Color Select register
     (14H) to enable grouping of the 256 video DAC color registers into
     blocks of 16 or 64 registers each, as discussed in Chapter 3.

     When BL = 0, the BIOS uses the value passed in BH to update bit 7 of
     the Mode Control register. When BH = 1, bit 7 is set to 1. This causes
     the BIOS to use bits 0 and 1 of the Color Select register in
     place of bits 4 and 5 of the palette register values. When BH = 0,
     bit 7 is set to 0, and all six low-order bits of the values in the
     palette registers are significant.

     When BL = 1, the value in BH is stored in the appropriate bit fields
     in the Color Select register. If bit 7 of the Mode Control register is
     1, bits 0 through 3 of the value in BH are copied into bits 0 through
     3 of the Color Select register. If bit 7 of the Mode Control register
     is 0, bits 0 through 1 of BH are copied into bits 2 through 3 of the
     Color Select register.


     AL = 15H
     When AL = 15H on the MCGA and the VGA, the contents of the video DAC
     color register specified in BX are returned in registers DH (red), CH
     (green), and CL (blue). Only the low-order six bits of each of the
     color values are significant.


     AL = 17H
     When AL = 17H on the MCGA and the VGA, the values from a block of
     adjacent video DAC color registers are copied to the table whose
     address is passed in ES:DX. The value in BX (00H through 0FFH)
     indicates the first color register to be read, and CX contains the
     number of registers affected. The BIOS routine performs no error
     checking; the sum of the values in BX and CX should not exceed 256
     (100H).

     The table must contain three bytes for every color register read.
     Color values for each register are stored sequentially in the table in
     three-byte groups. The first byte of each group contains the color
     register's red value, the second its green value, and the third its
     blue value.


     AL = 18H
     On the MCGA and the VGA, when AL = 18H, the value in BL is copied into
     the video DAC Mask register (3C6H).


     AL = 19H
     On the MCGA and the VGA, when AL = 19H, the value in the video DAC
     Mask register (3C6H) is returned in BL.

     NOTE: The BIOS on the VGA Adapter does not support subfunctions 18H
     and 19H. Also, IBM's BIOS Interface Technical Reference does not
     document these subfunctions, so they might not be supported in future
     BIOS releases.


     AL = 1AH
     On the VGA, when AL = 1AH, the current values of bit 7 of the
     Attribute Controller's Mode Control register (10H) and bits 0 through
     3 of the Color Select register (14H) are returned in BL and BH
     respectively. If bit 7 of the Mode Control register is 1, the value in
     BH represents bits 0 through 3 of the Color Select register. If bit 7
     of the Mode Control register is 0, only bits 2 through 3 are returned
     as bits 0 through 1 of BH.


     AL = 1BH
     On the MCGA and the VGA, when AL = 1BH, gray-scale summing is
     performed on a block of consecutive video DAC color registers. BX
     indicates the first color register affected. CX specifies the number
     of registers to update.


     The following example uses INT 10H function 10H to update the color
     value in a single palette register:

        mov  ax,1000h       ; AH := 10H (INT 10H function number)
                            ; AL := 0
        mov  bh,6           ; BH := new color value (yellow)
        mov  bl,7           ; BL := palette register number
        int  10h

     To update the Overscan register and change the displayed border color,
     call function 10H with AL = 1:

        mov  ax,1001h       ; AH := 10H
                            ; AL := 1
        mov  bh,1           ; BH := color value for overscan
        int  10h

     To load all 16 palette registers and the Overscan register from a
     table, call function 10H with AL = 2:

        mov  ax,1002h               ; AH := 10H
                                    ; AL := 2
        mov  dx,seg PaletteTable
        mov  es,dx
        mov  dx,offset PaletteTable ; ES:DX -> table of palette register
                                    ;           values
        int  10h
        .
        .
        .
PaletteTable db    00h,01h,02h,03h,04h,05h,06h,07h ; palette registers 0-7
             db    38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh ; palette regs 8-0FH
             db    00h                             ; Overscan reg

     To disable the blinking attribute, call function 10H with AL = 3 and
     BL = 0:

        mov  ax,1003h       ; AH := 10H
                            ; AL := 3
        mov  bl,0           ; BL := 0 (disable blinking)
        int  10h

     The following fragment performs gray-scale summing on the first 16
     video DAC color registers. The remaining 240 registers are unaffected.

        mov  ax,101Bh       ; AH := 10H
                            ; AL := 1BH
        mov  bx,0           ; BX := first color register affected
        mov  cx,16          ; CX := number of color registers
        int  10h



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 11H: Character Generator Interface

Caller registers:

     AH    =    11H

Load alphanumeric character definitions.

     User-specified character definition table:
     AL    =    0
     BH    =    points (bytes per character definition)
     BL    =    table in character generator RAM
     CX    =    number of characters defined in table
     DX    =    ASCII code of first character defined
     ES:BP =    address of user-specified table

     ROM BIOS 8-by-14 character definitions:
     AL    =    1
     BL    =    table in character generator RAM

     ROM BIOS 8-by-8 character definitions:
     AL    =    2
     BL    =    table in character generator RAM

     ROM BIOS 8-by-16 character definitions:
     AL    =    4
     BL    =    table in character generator RAM

Select displayed character definition tables.

     AL    =    3
     BL    =    value for Character Map Select register (EGA, VGA)
           =    character generator RAM table numbers (MCGA)

Load alphanumeric character definitions and program the CRT Controller.

     User-specified character definition table:
     AL    =    10H
     BH    =    points
     BL    =    table in character generator RAM
     CX    =    number of characters defined in table
     DX    =    ASCII code of first character defined
     ES:BP =    address of user-specified table

     ROM BIOS 8-by-14 character definitions:
     AL    =    11H
     BL    =    table in character generator RAM

     ROM BIOS 8-by-8 character definitions:
     AL    =    12H
     BL    =    table in character generator RAM

     ROM BIOS 8-by-16 character definitions:
     AL    =    14H
     BL    =    table in character generator RAM

Load graphics character definitions.

     User-specified 8-by-8 character definition table for interrupt 1FH
     vector:
     AL    =    20H
     ES:BP =    address of user-specified character definition table

     User-specified character definition table:
     AL    =    21H
     BL    =    0  (character rows per screen specified in DL)
           =    1  14 character rows per screen
           =    2  25 character rows per screen
           =    3  43 character rows per screen
     CX    =    points (bytes per character definition)
     DL    =    character rows per screen (when BL = 0)
     ES:BP =    address of user-specified character definition table

     ROM BIOS 8-by-14 character definitions:
     AL    =    22H
     BL    =    character rows per screen (as above)
     DL    =    (as above)

     ROM BIOS 8-by-8 character definitions:
     AL    =    23H
     BL    =    character rows per screen (as above)
     DL    =    (as above)

     ROM BIOS 8-by-16 character definitions:
     AL    =    24H
     BL    =    character rows per screen (as above)
     DL    =    (as above)

Get current character generator information.

     AL    =    30H
     BH    =    0  Contents of interrupt 1FH vector
           =    1  Contents of interrupt 43H vector
           =    2  Address of ROM 8-by-14 character table
           =    3  Address of ROM 8-by-8 character table
           =    4  Address of second half of ROM 8-by-8 character table
           =    5  Address of ROM 9-by-14 alternate character table
           =    6  Address of ROM 8-by-16 character table
           =    7  Address of ROM 9-by-16 alternate character table

     Returned values:
     CX    =    POINTS (height of character matrix)
     DL    =    ROWS (displayed character rows - 1)
     ES:BP =    address of character definition table

Video Display Data Area updates:

     0040:004C  CRT_LEN
     0040:0060  CURSOR_MODE
     0040:0084  ROWS
     0040:0085  POINTS

     INT 10H function 11H comprises a gamut of subfunctions that support
     both the alphanumeric and the graphics character generators on the
     EGA, the MCGA, and the VGA. You choose a subfunction with the value
     you specify in AL. The contents of the other registers depend on the
     subfunction.


     AL = 0, 1, 2, or 4
     You can use subfunctions 0, 1, 2, and 4 to load a table of character
     definitions into video RAM for use by the character generator.
     (Chapter 10 describes this in detail.) All four subfunctions are
     available on the VGA. On the EGA, the BIOS ignores subfunction 4. The
     MCGA BIOS does not contain an 8-by-14 character definition table, so
     calls with AL = 1 are treated as calls with AL = 4.

     On the MCGA, character definitions in character generator RAM are not
     displayed until they are loaded into the character generator's
     internal font pages (see Chapter 10). To accomplish this through the
     video BIOS, follow each call to function 11H performed with AL = 0, 1,
     2, or 4 with a call to function 11H with AL = 3.

     The MCGA's CRTC can only display characters that are 2, 4, 6, 8, 10,
     12, 14, or 16 lines high. Thus, BH should specify one of these values.
     Also, for compatibility with the VGA BIOS, the MCGA BIOS routine
     extends character definitions for 14-line characters into definitions
     for 16-line characters by duplicating the 14th line of each character
     definition.


     AL = 3
     On the EGA and the VGA, when AL = 3, function 11H loads the value
     passed in BL into the Sequencer's Character Map Select register. On
     the EGA and the MCGA, bits 0 and 1 of BL indicate which of four 256-
     character tables is used when bit 3 of a character's attribute byte is
     0. Bits 2 and 3 of BL indicate which table is used when bit 3 of a
     character's attribute is 1. On the VGA, bits 0, 1, and 4 specify one
     of eight tables to be used when a character's attribute bit 3 is 0,
     and bits 2, 3, and 5 specify the table used when attribute bit 3 is 1.

     If both bit fields in BL specify the same character definition table,
     only that table is loaded and displayed.

     AL = 10H, 11H, 12H, or 14H
     Subfunctions 10H, 11H, 12H, and 14H are analogous to subfunctions 0,
     1, 2, and 4 in that they load an alphanumeric character definition
     table into video RAM. The difference is that, for these subfunctions
     on the EGA and the VGA, the BIOS reprograms the CRT Controller to
     accommodate the height of the character matrix. On the MCGA, calls to
     function 11H with AL = 10H, 11H, 12H, and 14H are treated as calls to
     functions 0, 1, 2, and 4 respectively.

     NOTE: Disable alphanumeric cursor emulation before using these
     subfunctions on the EGA. The EGA BIOS cursor emulation routine does
     not always produce a satisfactory alphanumeric cursor. (Chapter 3
     discusses this in detail.)


     AL = 20H
     If AL = 20H, the address in ES:BP is copied into the interrupt 1FH
     vector at 0000:007C. This vector points to a table of 8-by-8 character
     definitions for ASCII codes 80H through FFH. This character definition
     table is used by the BIOS in CGA-compatible 320-by-200 4-color and
     640-by-200 2-color graphics modes.


     AL = 21H, 22H, 23H, or 24H
     Subfunctions 21H, 22H, 23H, and 24H are analogous to subfunctions 0,
     1, 2, and 4 respectively. The BIOS updates the interrupt 43H vector
     and the Video Display Data Area variables POINTS and ROWS with values
     that describe the specified graphics character definitions.

     The BIOS does not reprogram the CRT Controller when it loads graphics-
     mode character definition tables.


     AL = 30H
     If AL = 30H, INT 10H function 11H returns information about the
     character generator's current status. The value in POINTS in the Video
     Display Data Area is copied into register CX, the value of ROWS is
     returned in DL, and the address of one of eight character definition
     tables is returned in ES:BP. The value in BH indicates which table's
     address is returned.

     NOTE: If you call this subfunction on the EGA with BH equal to 6 or 7,
     or on the MCGA with BH equal to 5 or 7, the address returned in ES:BP
     is undefined.

     To select an 80-by-43 alphanumeric mode on a 350-line display, invoke
     INT 10H function 11H to load the ROM 8-by-8 character set and
     reprogram the CRTC to display 43 character rows. (Dividing 350 lines
     by 8 lines per character gives 43 character rows.) The following
     example assumes that the EGA is already in an 80-by-25 alphanumeric
     mode (BIOS mode number 3 or 7).

        mov  ax,40h
        mov  es,ax

        push es:[87h]               ; preserve INFO
        or   byte ptr es:[87h],1    ; disable cursor emulation
        mov  ax,1112h               ; AH := 11H (INT 10H function number)
                                    ; AL := 12H (subfunction:  load 8x8
                                    ;  alphanumeric characters, reprogram
                                    ;  CRTC)
        mov  bl,0                   ; BL := table 0 in character generator
                                    ;  RAM
        int  10h
        pop  es:[87h]               ; restore INFO



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 12H: Video Subsystem Configuration (Alternate Select)

Caller registers:

     AH    =    12H

Return video configuration information:

     BL    =    10H

     Returned values:
     BH    =    default BIOS video mode
                0  Color
                1  Monochrome
     BL    =    amount of EGA video RAM
                0  64 KB
                1  128 KB
                2  192 KB
                3  256 KB
     CH    =    feature bits
     CL    =    configuration switch setting

Select alternate Print Screen routine:

     BL    =    20H

Select scan lines for alphanumeric modes:

     BL    =    30H
     AL    =    0  200 scan lines
                1  350 scan lines
                2  400 scan lines

     Returned value:
     AL    =    12H

Select default palette loading:

     BL    =    31H
     AL    =    0  Enable default palette loading
           =    1  Disable default palette loading

     Returned value:
     AL    =    12H

CPU access to video RAM:

     BL    =    32H
     AL    =    0  Enable CPU access to video RAM and I/O ports
           =    1  Disable CPU access to video RAM and I/O ports

     Returned value:
     AL    =    12H

Gray-scale summing:

     BL    =    33H
     AL    =    0  Enable gray-scale summing
           =    1  Disable gray-scale summing

     Returned value:
     AL    =    12H

Cursor emulation:

     BL    =    34H
     AL    =    0  Enable cursor emulation
           =    1  Disable cursor emulation

     Returned value:
     AL    =    12H

PS/2 video display switching:

     BL    =    35H
     AL    =    0  Initial adapter video off
                1  Initial planar video on
                2  Switch active video off
                3  Switch inactive video on
     ES:DX =    address of 128-byte save area (for AL = 0, 2, or 3)

     Returned value:
     AL    =    12H

Video refresh control:

     BL    =    36H
     AL    =    0  Enable refresh
                1  Disable refresh

     Returned value:
     AL    =    12H

Video Display Data Area updates:

     (see below)

     INT 10H function 12H comprises nine subfunctions selected using the
     value in BL.


     BL = 10H
     When BL = 10H on the EGA and the VGA, this BIOS routine returns
     information about the configuration of the video subsystem. This
     information is copied from INFO and INFO_3 in the Video Display Data
     Area. These variables are initialized in the BIOS power-on startup
     code.

     The value returned in BH reflects whether the video subsystem is
     configured for a color (BH = 0) or monochrome (BH = 1) video mode.
     Bits 0 and 1 in BL indicate how much video RAM is present. The values
     returned in CH and CL are derived from the INFO_3 byte. Bits 4 through
     7 of INFO_3 (input from the EGA feature connector) are copied to bits
     0 through 3 of CH. Bits 0 through 3 of INFO_3 (configuration switch
     settings) are copied to bits 0 through 3 of CL.


     BL = 20H
     When BL = 20H on the MCGA, the EGA, and the VGA, the BIOS points the
     interrupt 5 vector at 0000:0014 to an alternate Print Screen routine
     contained in the video ROM BIOS. The difference between this routine
     and the default planar BIOS routine is that the video ROM version uses
     the Video Display Data Area variable ROWS to determine the number of
     character rows to print. The PC/XT and PC/AT planar BIOS versions
     always print 25 rows.


     BL = 30H
     When BL = 30 on the VGA, the BIOS routine updates bits 0-3 of the
     INFO_3 byte (0040:0088) and bits 7 and 4 of the Flags byte at
     0040:0089. INT 10H function 0 refers to INFO_3 and the Flags byte to
     determine whether to configure the video subsystem for a 200-line,
     350-line, or 400-line mode when it establishes an alphanumeric video
     mode. You can thus select among 200-line, 350-line, and 400-line
     alphanumeric modes by first executing INT 10H function 12H with BL =
     30H and AL = 0, 1, or 2, and then calling INT 10H function 0 to set
     the video mode.

     This function normally returns the value 12H in AL. If the VGA is
     inactive (bit 3 of INFO is set to 1), the function returns with
     AL = 0.


     BL = 31H
     When BL = 31H on the MCGA or VGA, the BIOS routine updates bit 3 of
     the Flags byte at 0040:0089 to indicate whether ROM BIOS default
     palette values should be loaded when a video mode is selected using
     INT 10H function 0. If the value 0 is passed in AL, bit 3 of the Flags
     byte is set to 0 to enable default palette setting. If AL = 1, bit 3
     is set to 1 to disable default palette setting.

     When a valid value is passed in AL, the function returns with AL =
     12H.

     BL = 32H
     When BL = 32H on the MCGA or the VGA, the value in AL specifies
     whether CPU access to the video buffer and I/O ports is enabled (AL =
     0) or disabled (AL = 1). Although the hardware interface for control
     of video addressing differs on the MCGA, the VGA, and the VGA Adapter,
     this BIOS function is the same in all three subsystems (see Chapter
     2).

     When a valid value is passed in AL, the function returns with AL =
     12H.

     NOTE: Although the EGA video BIOS does not support this function, you
     can control CPU addressing of video RAM on the EGA by updating bit 1
     of the Miscellaneous Output register (3C2H).


     BL = 33H
     When BL = 33H on the MCGA or the VGA, the BIOS routine updates bit 1
     of the Flags byte at 0040:0089 to indicate whether red-green-blue
     color values should be averaged to gray-scale values when INT 10H
     functions 0 and 10H update the video DAC color registers. If the value
     0 is passed in AL, bit 1 of the Flags byte is set to 1 to enable gray-
     scale summing. If AL = 1, bit 1 is set to 0 to disable gray-scale
     summing.

     When a valid value is passed in AL, the function returns with 
     AL = 12H.


     BL = 34H
     When BL = 34H on the VGA, the BIOS routine updates bit 0 of INFO
     (0040:0087) to indicate whether BIOS cursor emulation is in effect. If
     the value 0 is passed in AL, bit 0 of INFO is set to 0 to enable
     cursor emulation. If AL = 1, bit 0 is set to 1 to disable cursor
     emulation.

     When a valid value is passed in AL, the function returns with 
     AL = 12H.


     BL = 35H
     INT 10H function 1AH with BL = 35H provides a set of routines that
     support switching between two PS/2 video subsystems in the same
     computer. In a computer that contains two different PS/2-compatible
     video subsystems, calls to this function let a program separately
     access the video BIOS on a video adapter and the video BIOS on a PS/2
     motherboard.

     When you boot a PS/2 that contains a PS/2-compatible video adapter,
     the adapter subsystem is always the active subsystem by default. To
     use the PS/2's planar (motherboard) subsystem, you must use the
     display switch interface to disable the adapter subsystem and enable
     the planar subsystem.

     You can specify four related subfunctions for function 12H with 
     BL = 35H, using the value passed in register AL. The four subfunctions
     are designed to be called in pairs. Subfunctions 0 and 1 should be
     called once each to initialize the BIOS display switch interface and
     to establish a default video mode for the planar video subsystem.
     Subsequent calls to subfunctions 2 and 3 then let you switch between
     the two video subsystems.

     When AL = 0, the adapter BIOS initializes the display switch
     interface. First, the adapter BIOS calls the motherboard BIOS to set
     bit 6 of the Flags byte at 0040:0089 to 1 to indicate that the
     interface is supported. Next, the current Video Display Data Area and
     video interrupt vectors are preserved in the 128-byte buffer whose
     address is passed in ES:DX, and the video interrupt vectors are
     redirected to the motherboard BIOS. Finally, the adapter's video
     buffer and control port addressing are disabled (see INT 10H function
     12H, BL = 32H).

     When AL = 1, the motherboard BIOS establishes a default 80-by-25
     alphanumeric mode on the planar video subsystem.

     When AL = 2 and bit 6 of the Flags byte is 1, the contents of the
     Video Display Data Area and video interrupt vectors are copied to the
     128-byte buffer whose address is passed in ES:DX, and the video
     interrupt vectors are redirected to the currently inactive BIOS. Then
     video buffer and control port addressing are disabled for the
     currently active subsystem. A call to this subfunction should normally
     be followed by a call with AL = 3.

     When AL = 3 and bit 6 of the Flags byte is 1, the contents of the
     Video Display Data Area and interrupt vectors are restored from the
     buffer whose address is in ES:DX. (This buffer should contain
     information previously saved by a call with AL = 0 or AL = 2.) Then
     video buffer and control port addressing are enabled, using the
     restored video information.

     When a valid value is passed in AL, and when both the adapter BIOS and
     the planar BIOS support the display switch interface, each of the four
     subfunctions returns with AL = 12H.

     NOTE: The PS/2 Model 30 BIOS (dated 12/12/86 and earlier) and the PS/2
     Model 25 BIOS (dated 6/26/87) contain a bug that makes the display
     switch interface unusable. The problem should be corrected in later
     BIOS versions.


     BL = 36H
     When BL = 36H on the VGA, the value in AL specifies whether the BIOS
     routine enables (AL = 0) or disables (AL = 1) video refresh.
     (Temporarily disabling video refresh can speed software that performs
     repeated video memory accesses.) Bit 5 of the VGA's Sequencer Clocking
     Mode register (01H) controls whether video refresh is enabled or
     disabled. When the value 0 is passed in AL, bit 5 is set to 0 to
     enable video refresh; when AL is 1, bit 5 is set to 1 to disable video
     refresh.

     The function always returns with AL = 12H.

     To obtain EGA configuration information, call INT 10H function 12H
     with BL = 10H:

        mov  ah,12h
        mov  bl,10h
        int  10h

     To vector the EGA BIOS alternate Print Screen routine, call INT 10H
     function 12H with BL = 20H:

        mov  ah,12h
        mov  bl,20h
        int  10h

     To implement display switching between a VGA Adapter and the MCGA in a
     PS/2 Model 30:

; save areas for video BIOS display switch interface

VGAsave   db   128 dup(?)     ; save area for VGA
MCGAsave  db   128 dup(?)     ; save area for MCGA

; initialize display switching (execute this code only once)

     mov  ax,1200h            ; AH := 12H (INT 10H function number)
                              ; AL := 0
     mov  bl,35h              ; BL := 35H (display switch interface)
     mov  dx,seg VGAsave
     mov  es,dx
     mov  dx,offset VGAsave   ; ES:DX -> save area for VGA BIOS info
     int  10h
     cmp  al,12h
     jne  Error               ; exit if display switching not supported

     mov  ax,1201h
     mov  bl,35h
     int  10h                 ; disable adapter, enable planar video

; switch from planar (MCGA) to adapter (VGA) subsystem

     mov  ax,1202h            ; AL := 2 (switch active
                              ;  video off)
     mov  bl,35h
     mov  dx,seg VGAsave
     mov  es,dx
     mov  dx,offset VGAsave   ; ES:DX -> save area for
                              ;  currently active subsystem
     int  10h

     mov  ax,1203h            ; AL := 3 (switch inactive

                              ;  video on)
     mov  bl,35h
     mov  dx,offset MCGAsave  ; ES:DX -> save area for
                              ;  subsystem to be made active
     int  10h

; (to switch from adapter to planar, interchange VGAsave and
;  MCGAsave in the calls with AL = 2 and AL = 3)




ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 13H: Display Character String

Caller registers:

     AH    =    13H
     AL    =    0  BL contains attribute for string. Cursor position
                   not updated.
           =    1  BL contains attribute for string. Cursor position
                   updated.
           =    2  String contains embedded attribute bytes. Cursor
                   position not updated.
           =    3  String contains embedded attribute bytes. Cursor
                   position updated.
     BH    =    video page
     BL    =    attribute
     CX    =    string length
     DH    =    character row
     DL    =    character column
     ES:BP =    address of start of string

Returned values:

     (none)

Video Display Data Area updates:

     0040:0050  CURSOR_POSN

     INT 10H function 13H writes a character string into the video buffer.
     Bell, backspace, linefeed, and carriage-return characters embedded in
     the string are treated as commands rather than displayable characters.
     If the string cannot be displayed in one row of characters, function
     13H wraps the string around to the start of the next line. Function
     13H also scrolls the screen upward as necessary.

     The string is copied from the address you specify in ES:BP to the
     location in the video buffer indicated by registers DH and DL
     (character row and column) and register BH (video page). You must also
     specify the number of characters in the string in register CX.

     Function 13H comprises four subfunctions that are selected according
     to the value in AL. These four subfunctions allow you to select the
     method of specifying display attributes for characters in the string
     and to control the cursor's final position after the string is
     displayed.

     You can specify the attribute used for each character either in BL
     (AL = 0 or 1) or by pairing each character code with its attribute in
     the string itself (AL = 2 or 3). Also, you can indicate whether the
     cursor will stay in place after the string is written (AL = 0 or 2) or
     will move to the character position just past the end of the string
     (AL = 1 or 3).

     In all graphics modes except 320-by-200 256-color mode, setting bit 7
     of the attribute value in BL to 1 causes the BIOS to XOR the string
     into the video buffer.

     The video page specified in BH must be 0 in 320-by-200 4-color mode.

     NOTE: On the PC/AT, the EGA, and the MCGA, linefeed and carriage-
     return characters are always written to the currently displayed video
     page, regardless of the value you specify in BH. If you write a string
     containing any of these control characters to a video page not
     currently displayed, function 13H writes them to the wrong video page.

     The following routine writes the string "Hello, World" into the video
     buffer in video page 0 at row 12, column 34. An attribute value of 7
     is used for all characters in the string.

        mov  ax,1300h               ; AH := 13H (INT 10H function number)
                                    ; AL := 0 (attribute specified in BL,
                                    ;  don't move the cursor)
        mov  bh,0                   ; BH := video page
        mov  bl,7                   ; BL := attribute
        mov  cx,12                  ; CX := number of characters to display
        mov  dh,12                  ; DH := row 12
        mov  dl,34                  ; DL := column 34
        mov  bp,seg HelloString
        mov  es,bp
        mov  bp,offset HelloString  ; ES:BP := string address
        int  10h
        .
        .

        .
HelloString  db      'Hello, World'

     This example displays the digits 1 through 7 in the upper left corner
     of video page 0. The attribute used for each digit corresponds to the
     digit:

        mov  ax,1303h               ; AH := 13H (INT 10H function number)
                                    ; AL := 3 (string contains embedded
                                    ;  attribute bytes, move cursor to end
                                    ;  of string)
        mov  bh,0                   ; BH := video page
        mov  cx,7                   ; CX := number of characters to display
        mov  dx,0                   ; DH := row 0
                                    ; DL := column 0
        mov  bp,seg StringData
        mov  es,bp
        mov  bp,offset StringData   ; ES:BP := address of string
        int  10h
        .
        .
        .
StringData   db      '1',1,'2',2,'3',3,'4',4,'5',5,'6',6,'7',7



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 14H: (PC Convertible only)


Function 15H: (PC Convertible only)


Function 16H: (reserved)


Function 17H: (reserved)


Function 18H: (reserved)



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 19H: (reserved)


Function 1AH: Video Display Combination

Caller registers:

     AH    =    1AH

Return video display combination:

     AL    =    0

     Returned values:
     AL    =    1AH
     BL    =    active display
     BH    =    inactive display

Set video display combination:

     AL    =    1
     BL    =    active display
     BH    =    inactive display

     Returned value:
     AL    =    1AH

Video Display Data Area update:

     0040:008A  DCC byte

     INT 10H function 1AH returns or updates the video BIOS video display
     combination status. This status is represented in the DCC byte at
     0040:008A in the Video Display Data Area. This byte contains an index
     into the ROM BIOS Display Combination Code table, which contains a
     list of byte pairs that specify valid combinations of one or two video
     subsystems. Video subsystems are designated by the following values.

     FFH       Unrecognized video subsystem
       0        No display
       1       MDA with monochrome display
       2       CGA with color display
       3       (reserved)
       4       EGA with color display
       5       EGA with monochrome display
       6       Professional Graphics Controller
       7       VGA with analog monochrome display
       8       VGA with analog color display
       9       (reserved)
     0AH       MCGA with digital color display
     0BH       MCGA with analog monochrome display
     0CH       MCGA with analog color display

     AL = 0
     When AL = 0 on the MCGA or the VGA, the video BIOS routine uses the
     value in the DCC byte as an index into its Display Combination Code
     table and copies the 2-byte table entry into BH and BL. If two video
     subsystems are present, one subsystem must be monochrome and the other
     color; the BIOS routine determines which is active by examining bits 4
     through 5 of EQUIP_FLAG (0040:0010).


     AL = 1
     When AL = 1 on the MCGA or the VGA, the BIOS routine scans the Display
     Combination Code table for the combination specified in BH and BL. If
     the specified combination is found in the table, the DCC byte is
     updated with the appropriate index into the table. If the specified
     combination is not found, 0FFH is stored in the DCC byte.

     When a valid value (0 or 1) is passed in AL, INT 10H function 1AH
     returns with AL = 1AH.

     The following sequence returns the display combination in registers BH
     and BL.

        mov  ax,1A00h               ; AH := 1AH (INT 10H function number)
                                    ; AL := 0
        int  10h
        cmp  al,1AH
        jne  ErrorExit              ; jump if function not supported
                                    ; at this point BL = active display
                                    ; BH = inactive display

     If this sequence is executed on a PS/2 Model 30 with an analog
     monochrome display attached to the MCGA and a monochrome display
     attached to an MDA, the values returned are:

      AL    =    1AH
      BL    =    0BH  (active display = MCGA with analog monochrome)
      BH    =      1  (inactive display = MDA with digital monochrome) 



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 1BH: Video BIOS Functionality/State Information

Caller registers:

     AH    =    1BH
     BX    =    implementation type (must be 0)
     ES:DI =    address of 64-byte buffer

Returned values:


     ES:DI =    buffer updated with function and state information
     AL    =    1BH

Video Display Data Area updates:

    (none)

     INT 10H function 1BH returns a table of video BIOS state information
     on the MCGA and the VGA. The table contains dynamic information (shown
     in Figure A-14) that is determined when function 1BH is invoked, as
     well as static information (shown in Figure A-15) describing the
     capabilities of the video BIOS itself.

     The dynamic information is copied into the 64-byte buffer whose
     address is passed to the BIOS routine in ES:DI. The 32-bit address of
     the static information table is returned as bytes 0 through 3 of the
     dynamic information table.

     When called with BX = 0, INT 10H function 1BH always returns with
     AL = 1BH.


Offset    Data Type        Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         Dword            Address of static functionality table
4         Byte             Video mode
5         Word             Number of displayed character columns
7         Word             Length of displayed portion of video buffer
                             in bytes
9         Word             Start address of upper left corner of video
                             buffer
0BH       16-byte array    Table of cursor locations (column, row) for
                             eight video pages
1BH       Byte             Cursor end line
1CH       Byte             Cursor start line
1DH       Byte             Active video page
1EH       Word             I/O port for CRTC Address register
20H       Byte             CRT_MODE_SET (current value of 3x8H register)
21H       Byte             CRT_PALETTE (current value of 3x9H register)
22H       Byte             Number of displayed character rows
23H       Word             POINTS (height of displayed character matrix)
25H       Byte             Active display combination code
26H       Byte             Inactive display combination code
27H       Word             Number of displayed colors (0 for monochrome)
29H       Byte             Number of video pages supported
2AH       Byte             Raster scan lines:
                             0: 200 lines
                             1: 350 lines
                             2: 400 lines
                             3: 480 lines
2BH       Byte             Alphanumeric character table used when attribute
                              bit 3 is 0 (VGA only)
2CH       Byte             Alphanumeric character table used when attribute
                             bit 3 is 1 (VGA only)
2DH       Byte             Miscellaneous state information (bits are set
                             to 1 if state is true)
                           Bit 0: all modes active on all video subsystems
                             (always 0 on MCGA)
                           Bit 1: gray-scale summing enabled
                           Bit 2: monochrome display attached
                           Bit 3: default palette loading disabled
                           Bit 4: cursor emulation enabled
                           Bit 5: blinking attribute enabled
                           (bits 6-7 reserved)
2EH       Byte             (reserved)
2FH       Byte             (reserved)
30H       Byte             (reserved)
31H       Byte             Video RAM available
                             0: 64K
                             1: 128K
                             2: 192K
                             3: 256K
32H       Byte             Save area status (bits are set to 1 if state
                             is true)
                           Bit 0: two alphanumeric character sets are
                             active (VGA only)
                           Bit 1: dynamic save area is active
                           Bit 2: alphanumeric character set override is
                             active
                           Bit 3: graphics character set override is active
                           Bit 4: palette override is active
                           Bit 5: display combination code extension is
                             active
                           (bits 6-7 reserved)
33H through 3FH            (reserved)
     Figure A-14.  Dynamic video state table returned by INT 10H
     function 1BH.


Offset    Data Type      Description
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0         Byte           Video modes supported (bits = 1 if a mode is
                           supported)
                           Bit 0: mode 0
                           Bit 1: mode 1
                           Bit 2: mode 2
                           Bit 3: mode 3
                           Bit 4: mode 4
                           Bit 5: mode 5
                           Bit 6: mode 6
                           Bit 7: mode 7
1         Byte           Video modes supported (bits = 1 if a mode is
                           supported)
                           Bit 0: mode 8
                           Bit 1: mode 9
                           Bit 2: mode 0AH
                           Bit 3: mode 0BH
                           Bit 4: mode 0CH
                           Bit 5: mode 0DH
                           Bit 6: mode 0EH
                           Bit 7: mode 0FH
2         Byte           Video modes supported (bits = 1 if a mode is
                           supported)
                           Bit 0: mode 10H
                           Bit 1: mode 11H
                           Bit 2: mode 12H
                           Bit 3: mode 13H
                           Bit 4: (reserved)
                           Bit 5: (reserved)
                           Bit 6: (reserved)
                           Bit 7: (reserved)
3         Byte           (reserved)
4         Byte           (reserved)
5         Byte           (reserved)
6         Byte           (reserved)
7         Byte           Scan lines available in alphanumeric modes
                           (bits = 1 if supported)
                           Bit 0: 200 lines
                           Bit 1: 350 lines
                           Bit 2: 400 lines
8         Byte           Maximum number of displayable alphanumeric
                           character sets
9         Byte           Number of available alphanumeric character
                           definition tables in character generator RAM
0AH       Byte           Miscellaneous video BIOS capabilities (bits = 1
                           if available)
                           Bit 0: all modes on all monitors (INT 10H
                             function 0) (Note: This bit is always 0 on
                             MCGA)
                           Bit 1: gray-scale summing (INT 10H function 10H
                             and 12H)
                           Bit 2: character set loading (INT 10H function
                             11H)
                           Bit 3: default palette loading (INT 10H
                             function 0)
                           Bit 4: cursor emulation (INT 10H function 1)
                           Bit 5: 64-color palette (INT 10H function 10H)
                           Bit 6: video DAC loading (INT 10H function 10H)
                           Bit 7: control of video DAC via Attribute
                             Controller Color Select (INT 10H function 10H)

0BH       Byte           Miscellaneous video BIOS capabilities (bits = 1
                           if available)
                           Bit 0: light pen support (INT 10H function 4)
                           Bit 1: save/restore video state (INT 10H
                             function 1CH)
                           Bit 2: blinking/background intensity (INT 10H
                             function 10H)
                           Bit 3: Display Combination Code (INT 10H
                             function 1AH)
                           (bits 4-7 reserved)
0CH       Byte           (reserved)
0DH       Byte           (reserved)
0EH       Byte           Save area capabilities
                           Bit 0: multiple alphanumeric character sets
                           Bit 1: dynamic save area
                           Bit 2: alphanumeric character set override
                           Bit 3: graphics character set override
                           Bit 4: palette override
                           Bit 5: Display Combination Code extension
                           (bits 6-7 reserved)
0FH       Byte           (reserved)
     Figure A-15.  Static functionality table. This table's address is
     returned by INT 10H function 1BH. The table describes the capabilities
     of the ROM BIOS in the video subsystem.


     The following sequence returns video BIOS state information in the
     buffer whose address is passed in ES:DI.

        mov     ax,1B00h                ; AH := 1BH (INT 10H function
                                        ;         number)
                                        ; AL := 0
        mov     bx,0                    ; BX := 0 (Implementation type)
        mov     di,seg StateTable
        mov     es,di
        mov     di,offset StateTable    ; ES:DI -> buffer
        int     10h
        cmp     al,1BH
        jne     ErrorExit               ; jump if function not supported
        .
        .                               ; at this point StateTable contains
        .                               ;  the dynamic information table
StateTable db 64 dup(?)



ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function 1CH: Save or Restore Video State

Caller registers:

     AH    =    1CH

Return save/restore buffer size:

     AL    =    0
     CX    =    requested states
                Bit 0:       video hardware state
                Bit 1:       video BIOS data areas
                Bit 2:       video DAC state
                Bits 3-0FH:  reserved

     Returned values:
     AL    =    1CH
     BX    =    buffer size in 64-byte blocks

Save requested state(s):

     AL    =    1
     CX    =    requested states (as above)
     ES:BX =    buffer address

Restore requested state(s):

     AL    =    2
     CX    =    requested states (as above)
     ES:BX =    buffer address

Video Display Data Area updates:

     (see below)

     INT 10H function 1CH, supported only on the VGA, lets you save and
     restore the state of the video hardware and video ROM BIOS. INT 10H
     function 1CH comprises three subfunctions selected by the value passed
     in AL. For each subfunction, you must set the low-order three bits in
     CX to indicate the combination of video subsystem states you wish to
     save or restore. You must also pass the address of a save/restore
     buffer in ES:BX whenever you use function 1CH to save or restore the
     video state.


     AL = 0
     When AL = 0, function 1CH returns the size of the buffer required to
     store the state information for states requested in CX. The value
     returned in BX is in 64-byte blocks. 

     Function 1CH returns AL = 1CH when called with AL = 0 and at least one
     of the low-order three bits in CX set to 1.


     AL = 1
     When AL = 1, function 1CH copies the state information requested in CX
     into the buffer whose address is passed in ES:BX.


     AL = 2
     When AL = 2, function 1CH restores the video hardware state, the BIOS
     state, or both using information saved in the buffer whose address is
     passed in ES:BX.

     NOTE: The BIOS routine may modify the current video state as it
     executes function 1CH. If you plan not to change the video state after
     saving it with function 1CH, restore the video state immediately
     afterward (using function 1CH with  AL = 2) to ensure that it isn't
     inadvertently modified.

     The following sequence runs under MS-DOS version 2.0 or later. It
     calls MS-DOS INT 21H function 48H to allocate RAM for a save/restore
     buffer. It then calls INT 10H function 1CH to save the current video
     state.

        mov  ax,1C00h               ; AH := 1CH (INT 10H function number)
                                    ; AL := 0
        mov  cx,111b                ; CX := 111b (all three video states)
        int  10h
        cmp  al,1Ch
        jne  ErrorExit              ; jump if function not supported
        shl  bx,1                   ; convert number of 64-byte blocks
        shl  bx,1                   ;  to number of 16-byte blocks
        mov  ah,48h                 ; AH := 48H (MS-DOS INT 21H function
                                    ;        number)
        int  21h                    ; AX := segment of allocated buffer
        jc   ErrorExit              ; jump if error
        mov  es,ax
        xor  bx,bx                  ; ES:BX -> buffer
        mov  cx,111b                ; CX := 111b (all three video states)
        mov  ax,1C01h               ; AH := INT 10H function number
                                    ; AL := 1
        int  10h                    ; save video state in buffer
