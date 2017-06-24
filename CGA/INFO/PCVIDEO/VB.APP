

                    Appendix B  Printing the Screen



     Many computer users find it convenient to "snapshot" the current
     contents of the video display. Although all members of the IBM PC and
     PS/2 series come with a short ROM BIOS routine that dumps the contents
     of the video buffer to a printer, you may need to write your own video
     snapshot program to supplement the ROM routine. This appendix
     discusses how to use the BIOS screen dump utility, as well as why and
     how to write your own.


Alphanumeric Modes


     You invoke the motherboard ROM's alphanumeric screen dump routine by
     executing software interrupt 5. (The ROM BIOS keyboard handler issues
     this interrupt when you press Shift-PrtSc.) This routine copies the
     contents of the currently displayed video page to the printer in
     80-by-25 or 40-by-25 alphanumeric mode. The routine prints only the
     ASCII character codes, ignoring the attribute bytes in the video
     buffer.


EGA, MCGA, VGA

     The EGA, the MCGA, and the VGA ROM BIOS contain a more flexible
     version of the INT 5 screen dump routine. That version uses the Video
     Display Data Area value ROWS (0040:0084) to determine how many rows of
     characters to print. (The motherboard ROM version always prints 25
     rows.) An IBM PC/XT or PC/AT uses the motherboard version by default.
     To make the EGA or VGA ROM BIOS routine accessible through interrupt
     5, call INT 10H function 12H with BL = 20H. This points the interrupt
     5 vector to the more flexible routine.


Block Graphics Characters

     Because most printers are designed to work with many different
     computers, not just IBM PCs, manufacturers do not always design their
     printers to print the same 256 ASCII characters that the video
     hardware displays in alphanumeric modes. In particular, the characters
     used for block graphics are not always available on PC-compatible
     printers. These characters may print differently than they are
     displayed or they may not print at all.


Graphics Modes


     The ROM BIOS does not support screen dumps in graphics modes, so in
     these modes you must use some other program to print the video
     buffer's contents.


GRAPHICS

     GRAPHICS is a RAM-resident graphics-mode screen dump program that
     Microsoft supplies as part of MS-DOS under the name GRAPHICS.COM or
     GRAPHICS.EXE. This program establishes a memory-resident screen dump
     program for CGA graphics modes (320-by-200 4-color and 640-by-200
     2-color) when executed. The program uses an IBM- or Epson-compatible
     dot-matrix printer for output.

     The RAM-resident portion of GRAPHICS traps interrupt 5 and tests the
     current video mode. If a graphics mode is active, it performs the
     screen dump. Otherwise, the BIOS interrupt 5 routine gets control and
     performs the alphanumeric-mode screen dump. Thus, once GRAPHICS.COM or
     GRAPHICS.EXE has been executed, you can obtain a graphics-mode screen
     dump by pressing Shift-PrtSc, just as you would in alphanumeric video
     modes.


Writing a Screen Dump Routine

     If you want screen snapshots in native EGA, VGA, or MCGA graphics
     modes or on a Hercules adapter, or if GRAPHICS produces unsatisfactory
     output on your printer, you can write your own screen dump routine.
     Listing B-1 is an example of a simple routine for CGA graphics modes.
     ScreenDumpCGA can be incorporated into an assembly-language program or
     a high-level-language program by calling it with the appropriate
     register values and memory model. (See Chapter 13 for more on this
     topic.) You might also build ScreenDumpCGA into a Terminate-but-Stay-
     Resident program that, like GRAPHICS, chains into the interrupt 5
     vector and executes whenever Shift-PrtSc is pressed.


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

     Listing B-1.  A simple screen dump routine for the
     CGA.

                TITLE   'Listing B-1'
                NAME    ScreenDumpCGA
                PAGE    55,132

;
; Name:         ScreenDumpCGA
;
; Function:     Screen Dump for CGA 640x200 2-color and 320x200 4-color modes
;
; Caller:       (undefined)
;
; Notes:        The main procedure of this program, ScreenDumpCGA, may be
;               called from an application program or as part of a TSR
;               (Terminate-but-Stay Resident) handler for interrupt 5.
;

STDPRN          =       4               ; MS-DOS standard printer handle


DGROUP          GROUP   _DATA

_TEXT           SEGMENT byte public 'CODE'
                ASSUME  cs:_TEXT,ds:DGROUP

;
; PrintLine
;
;       Writes one line of characters to the standard printer device.  Ignores
;       errors.
;

PrintLine       PROC    near            ; Caller:       DS:DX -> data
                                        ;               CX = # of bytes
                mov     bx,STDPRN
                mov     ah,40h          ; INT 21h function 40h:  Write
                int     21h
                ret

PrintLine       ENDP

;
; PrinterGraphics
;
;       Puts the printer in its "graphics mode."  This routine must be
;       customized for different printers.
;

PrinterGraphics PROC    near            ; Configures Epson MX-80 printer
                                        ;  for 480 dots/line

                mov     dx,offset DGROUP:EpsonGraphics
                mov     cx,3
                call    PrintLine
                ret

PrinterGraphics ENDP

;
; PrinterDefault
;
;       Puts the printer in its default (non-graphics) mode.  Again, this
;       routine must be customized for different printers.
;

PrinterDefault  PROC    near            ; Configures Epson MX-80 for default
                                        ;  alphanumeric output

                mov     dx,offset DGROUP:EpsonReset
                mov     cx,2
                call    PrintLine
                ret

PrinterDefault  ENDP

;
; ChopZeroes
;
;       Chops trailing zeros from the printer output buffer.
;

ChopZeroes      PROC    near            ; Caller:       ES:DI -> buffer
                                        ;               CX = buffer length
                                        ; Returns:      CX = adjusted length

                jcxz    L01             ; exit if buffer is empty

                add     di,cx
                dec     di              ; ES:DI -> last byte in buffer

                xor     al,al           ; AL := 0 (byte to scan for)

                std                     ; scan backwards
                repe    scasb
                cld                     ; restore direction flag
                je      L01             ; jump if buffer filled with zeroes

                inc     cx              ; adjust length past last nonzero byte

L01:            ret

ChopZeroes      ENDP

;
; PrintPixels
;
;       Prints one row of pixels on an Epson MX-80.
;

PrintPixels     PROC    near            ; Caller:       DI = offset of buffer
                                        ;               CX = buffer length

                push    ds
                pop     es              ; ES := DS

                push    di              ; preserve buffer offset
                call    ChopZeroes
                push    cx              ; preserve length

                mov     word ptr DataHeader+2,cx  ; store buffer length
                                                  ;  in output data header
                mov     dx,offset DGROUP:DataHeader
                mov     cx,4
                call    PrintLine       ; print data header

                pop     cx              ; CX := buffer length
                pop     dx              ; DX := buffer offset
                call    PrintLine       ; print the pixels

                mov     dx,offset DGROUP:CRLF
                mov     cx,2
                call    PrintLine

                ret

PrintPixels     ENDP

;
; TranslatePixels
;
;       Copies one printable row of pixels from the video buffer to the
;       print buffer.  This routine can be modified at will to change the
;       scaling or orientation of the printed image, to interpolate gray-
;       scale values for color pixels, etc.
;
;       This routine formats the printer buffer for output to an Epson
;       MX-80.  The page is printed sideways, with two horizontal printed pixels
;       for each vertical pixel in the video buffer.  Since the CGA screen
;       is 200 pixels high, the printed output is 400 pixels wide.
;

TranslatePixels PROC    near            ; Caller:       SI = video buffer offset
                                        ;               ES:DI -> print buffer

                push    ds              ; preserve DS
                mov     ds,VideoBufSeg  ; DS:SI -> video buffer

                add     di,398          ; ES:DI -> 2 bytes before end of buffer

                mov     cx,200          ; CX := # of vertical pixels
                mov     bx,2000h+1      ; BX := 1st video buffer increment
                mov     dx,81-2000h     ; DX := 2nd video buffer increment

                std                     ; fill the print buffer backwards

L11:            lodsb                   ; AL := 8 pixels from video buffer
                mov     ah,al           ; AX := 8 doubled pixels
                stosw                   ; write them to print buffer

                add     si,bx           ; increment to next interleave of
                xchg    bx,dx           ;  video buffer

                loop    L11

                cld                     ; clear direction flag
                pop     ds              ; restore DS
                ret

TranslatePixels ENDP

;
; ScreenDumpCGA
;

ScreenDumpCGA   PROC    near            ; Caller:       DS = DGROUP

                call    PrinterGraphics ; configure the printer for graphics

                push    ds
                pop     es              ; DS,ES := DGROUP

                xor     si,si           ; SI := offset of start of video buffer

L21:            push    si
                mov     di,offset DGROUP:PrintBuf
                call    TranslatePixels ; copy one printable row of pixels

                mov     cx,400
                mov     di,offset DGROUP:PrintBuf
                call    PrintPixels     ; print them

                pop     si
                inc     si
                cmp     si,80           ; loop across all 80 columns in
                jb      L21             ;  the video buffer
                                
                call    PrinterDefault  ; restore the printer to its default
                                        ;  state
                ret

ScreenDumpCGA   ENDP

_TEXT           ENDS


_DATA           SEGMENT word public 'DATA'

PrintBuf        DB      400 dup(?)      ; print output buffer

VideoBufSeg     DW      0B800h

EpsonGraphics   DB      1Bh,33h,18h
EpsonReset      DB      1Bh,40h
DataHeader      DB      1Bh,4Bh,00h,00h
CRLF            DB      0Dh,0Ah

_DATA           ENDS

                END


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


     ScreenDumpCGA copies pixels from the video buffer into an inter-
     mediate print buffer. It formats the print buffer so that its contents
     can be sent directly to the printer (an Epson MX-80 in this example).
     Since the video buffer can be accessed randomly, ScreenDumpCGA reads
     pixels from it in an order that is conveniently transmitted to the
     printer.

     The heart of ScreenDumpCGA is the subroutine TranslatePixels. This
     routine maps pixels from the video buffer into the print buffer. In
     this example, the routine is short and fast, because it uses a simple
     transformation to convert video buffer pixels to printer pixels.
     Because the Epson MX-80 prints vertically oriented groups of pixels
     (see Figure B-1), the easiest way to print an image from  the
     horizontally mapped video buffer is to rotate it by 90 degrees.

     To customize ScreenDumpCGA, concentrate on how best to map pixels from
     the video buffer to your printer. Change the TranslatePixels routine
     to scale or rotate the pixels differently, or modify ScreenDumpCGA to
     change the order in which the contents of the video buffer are copied
     to the printer.


              * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ³
              * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ³  ³
     Printed  * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ³  ³  ³
     pixels   * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ³  ³  ³  ³
              * ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ³  ³  ³  ³  ³
              * ÄÄÄÄÄÄÄÄÄÄ¿  ³  ³  ³  ³  ³  ³
              * ÄÄÄÄÄÄÄ¿  ³  ³  ³  ³  ³  ³  ³
                        ³  ³  ³  ³  ³  ³  ³  ³
                        ³  ³  ³  ³  ³  ³  ³  ³
                        0  1  2  3  4  5  6  7 ÄÄÄÄÄÄÄÄBit number

     Figure B-1.  Pixel mapping for a typical dot-matrix graphics printer.
     As the print head moves across the page, it prints eight rows of
     pixels at a time. Each byte of data transmitted to the printer
     controls 8 vertical pixels as shown.


     For example, you could modify ScreenDumpCGA and TranslatePixels  to
     dump the contents of the EGA or VGA video buffer in 640-by-350 16-
     color mode as in Listing B-2. The modified routine prints all nonzero
     pixels in the video buffer as black dots. Note how the Graphics
     Controller's read mode 1 simplifies this task in TranslatePixels.


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

     Listing B-2.  An EGA screen printing routine.

                TITLE   'Listing B-2'
                NAME    ScreenDumpEGA
                PAGE    55,132

;
; Name:         ScreenDumpEGA
;
; Function:     Screen Dump for EGA 640x350 16-color mode
;
; Caller:       (undefined)
;
; Notes:        The main procedure of this program, ScreenDumpEGA, may be
;               called from an application program or as part of a TSR
;               (Terminate-but-Stay Resident) handler for interrupt 5.
;

STDPRN          =       4               ; MS-DOS standard printer handle


DGROUP          GROUP   _DATA

_TEXT           SEGMENT byte public 'CODE'
                ASSUME  cs:_TEXT,ds:DGROUP

;
; PrintLine
;
;       Writes one line of characters to the standard printer device.  Ignores
;       errors.
;

PrintLine       PROC    near            ; Caller:       DS:DX -> data
                                        ;               CX = # of bytes
                mov     bx,STDPRN
                mov     ah,40h          ; INT 21h function 40h:  Write
                int     21h
                ret

PrintLine       ENDP

;
; PrinterGraphics
;
;       Puts the printer in its "graphics mode."  This routine must be
;       customized for different printers.
;

PrinterGraphics PROC    near            ; Configures Epson MX-80 printer
                                        ;  for 480 dots/line

                mov     dx,offset DGROUP:EpsonGraphics
                mov     cx,3
                call    PrintLine
                ret

PrinterGraphics ENDP

;
; PrinterDefault
;
;       Puts the printer in its default (non-graphics) mode.  Again, this
;       routine must be customized for different printers.
;

PrinterDefault  PROC    near            ; Configures Epson MX-80 for default
                                        ;  alphanumeric output

                mov     dx,offset DGROUP:EpsonReset
                mov     cx,2
                call    PrintLine
                ret

PrinterDefault  ENDP

;
; ChopZeroes
;
;       Chops trailing zeros from the printer output buffer.
;

ChopZeroes      PROC    near            ; Caller:       ES:DI -> buffer
                                        ;               CX = buffer length
                                        ; Returns:      CX = adjusted length

                jcxz    L01             ; exit if buffer is empty

                add     di,cx
                dec     di              ; ES:DI -> last byte in buffer

                xor     al,al           ; AL := 0 (byte to scan for)

                std                     ; scan backwards
                repe    scasb
                cld                     ; restore direction flag
                je      L01             ; jump if buffer filled with zeroes

                inc     cx              ; adjust length past last nonzero byte

L01:            ret

ChopZeroes      ENDP

;
; PrintPixels
;
;       Prints one row of pixels on an Epson MX-80.
;

PrintPixels     PROC    near            ; Caller:       DI = offset of buffer
                                        ;               CX = buffer length

                push    ds
                pop     es              ; ES := DS

                push    di              ; preserve buffer offset
                call    ChopZeroes
                push    cx              ; preserve length

                mov     word ptr DataHeader+2,cx  ; store buffer length
                                                  ;  in output data header
                mov     dx,offset DGROUP:DataHeader
                mov     cx,4
                call    PrintLine       ; print data header

                pop     cx              ; CX := buffer length
                pop     dx              ; DX := buffer offset
                call    PrintLine       ; print the pixels

                mov     dx,offset DGROUP:CRLF
                mov     cx,2
                call    PrintLine

                ret

PrintPixels     ENDP

;
; TranslatePixels
;
;       Copies one printable row of pixels from the video buffer to the
;       print buffer.  This routine can be modified at will to change the
;       scaling or orientation of the printed image, to interpolate gray-
;       scale values for color pixels, etc.
;
;       This routine formats the printer buffer for output to an Epson
;       MX-80.  The page is printed sideways, so the printed output is
;       350 pixels wide.
;

TranslatePixels PROC    near            ; Caller:       SI = video buffer offset
                                        ;               ES:DI -> print buffer

                push    ds              ; preserve DS
                mov     ds,VideoBufSeg  ; DS:SI -> video buffer

                add     di,349          ; ES:DI -> last byte in print buffer

                mov     cx,350          ; CX := # of vertical pixels

; set up the Graphics Controller for read mode 1

                mov     dx,3CEh         ; Graphics Controller I/O port
                mov     ax,805h         ; AH := 00001000b (read mode 1)
                                        ; AL := Mode register number
                out     dx,ax

                mov     ax,002          ; AH := 0 (color compare value)
                out     dx,ax           ; AL := Color Compare register number

                mov     ax,0F07h        ; AH := 00001111b (color don't care mask)
                out     dx,ax           ; AL := Color Don't Care register number

; fill the print buffer; all nonzero pixels in the video buffer are printed

                std                     ; fill the print buffer backwards

L11:            lodsb                   ; AL := 8-pixel color compare value
                                        ;  (bits = 0 if pixel <> 0)
                not     al              ; AL := 8 printable pixels
                stosb                   ; store in print buffer

                add     si,81           ; increment to next row in video buffer
                loop    L11

                cld                     ; clear direction flag

; restore Graphics Controller default state

                mov     ax,5            ; AH := read mode 0, write mode 0
                out     dx,ax           ; AL := Mode register number

                mov     ax,7            ; AH := 0 (color don't care mask)
                out     dx,ax           ; AL := Color Don't Care register number

                pop     ds              ; restore DS
                ret

TranslatePixels ENDP

;
; ScreenDumpEGA
;

ScreenDumpEGA   PROC    near            ; Caller:       DS = DGROUP

                call    PrinterGraphics ; configure the printer for graphics

                push    ds
                pop     es              ; DS,ES := DGROUP

                xor     si,si           ; SI := offset of start of video buffer

L21:            push    si
                mov     di,offset DGROUP:PrintBuf
                call    TranslatePixels ; copy one printable row of pixels

                mov     cx,350
                mov     di,offset DGROUP:PrintBuf
                call    PrintPixels     ; print them

                pop     si
                inc     si
                cmp     si,80           ; loop across all 80 columns in
                jb      L21             ;  the video buffer
                                
                call    PrinterDefault  ; restore the printer to its default
                                        ;  state
                ret

ScreenDumpEGA   ENDP

_TEXT           ENDS


_DATA           SEGMENT word public 'DATA'

PrintBuf        DB      350 dup(?)      ; print output buffer

VideoBufSeg     DW      0A000h

EpsonGraphics   DB      1Bh,33h,18h
EpsonReset      DB      1Bh,40h
DataHeader      DB      1Bh,4Bh,00h,00h
CRLF            DB      0Dh,0Ah

_DATA           ENDS

                END


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


RAM-Based Alphanumeric Character Definitions

     You can also modify the graphics-mode screen dump routine to print
     RAM-based characters used in alphanumeric modes on the EGA, MCGA, VGA,
     HGC+, and InColor Card. The technique is to use the character codes
     stored in the displayed portion of the video buffer to index the bit
     patterns in character definition RAM. The bit pattern that defines
     each character can then be used as a dot pattern for the printer.

     As an example, Listing B-3 shows how this can be done for the
     characters defined in the default character definition table in memory
     map 2 on the EGA or VGA. The routine prints each column of characters
     in the video buffer by filling the buffer (PrintBuf) with the bit
     patterns that define each of the characters. Memory map 0 (containing
     the character codes) and map 2 (containing the character definitions)
     are addressed separately in the subroutine TranslatePixels by
     programming the Sequencer and Graphics Controller as discussed in
     Chapter 10.


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

     Listing B-3.  Using RAM-based character definition tables to print
     the character set.

                TITLE   'Listing B-3'
                NAME    ScreenDumpAlpha
                PAGE    55,132

;
; Name:         ScreenDumpAlpha
;
; Function:     Screen Dump for EGA alphanumeric modes with 350-line resolution
;
; Caller:       (undefined)
;
; Notes:        The main procedure of this program, ScreenDumpAlpha, may be
;               called from an application program or as part of a TSR
;               (Terminate-but-Stay Resident) handler for interrupt 5.
;

STDPRN          =       4               ; MS-DOS standard printer handle


DGROUP          GROUP   _DATA

_TEXT           SEGMENT byte public 'CODE'
                ASSUME  cs:_TEXT,ds:DGROUP,es:DGROUP

;
; PrintLine
;
;       Writes one line of characters to the standard printer device.  Ignores
;       errors.
;

PrintLine       PROC    near            ; Caller:       DS:DX -> data
                                        ;               CX = # of bytes
                mov     bx,STDPRN
                mov     ah,40h          ; INT 21h function 40h:  Write
                int     21h
                ret

PrintLine       ENDP

;
; PrinterGraphics
;
;       Puts the printer in its "graphics mode."  This routine must be
;       customized for different printers.
;

PrinterGraphics PROC    near            ; Configures Epson MX-80 printer
                                        ;  for 480 dots/line

                mov     dx,offset DGROUP:EpsonGraphics
                mov     cx,3
                call    PrintLine
                ret

PrinterGraphics ENDP

;
; PrinterDefault
;
;       Puts the printer in its default (non-graphics) mode.  Again, this
;       routine must be customized for different printers.
;

PrinterDefault  PROC    near            ; Configures Epson MX-80 for default
                                        ;  alphanumeric output

                mov     dx,offset DGROUP:EpsonReset
                mov     cx,2
                call    PrintLine
                ret

PrinterDefault  ENDP

;
; ChopZeroes
;
;       Chops trailing zeros from the printer output buffer.
;

ChopZeroes      PROC    near            ; Caller:       ES:DI -> buffer
                                        ;               CX = buffer length
                                        ; Returns:      CX = adjusted length

                jcxz    L01             ; exit if buffer is empty

                add     di,cx
                dec     di              ; ES:DI -> last byte in buffer

                xor     al,al           ; AL := 0 (byte to scan for)

                std                     ; scan backwards
                repe    scasb
                cld                     ; restore direction flag
                je      L01             ; jump if buffer filled with zeroes

                inc     cx              ; adjust length past last nonzero byte

L01:            ret

ChopZeroes      ENDP

;
; PrintPixels
;
;       Prints one row of pixels on an Epson MX-80.
;

PrintPixels     PROC    near            ; Caller:       DI = offset of buffer
                                        ;               CX = buffer length

                push    ds
                pop     es              ; ES := DS

                push    di              ; preserve buffer offset
                call    ChopZeroes
                push    cx              ; preserve length

                mov     word ptr DataHeader+2,cx  ; store buffer length
                                                  ;  in output data header
                mov     dx,offset DGROUP:DataHeader
                mov     cx,4
                call    PrintLine       ; print data header

                pop     cx              ; CX := buffer length
                pop     dx              ; DX := buffer offset
                call    PrintLine       ; print the pixels

                mov     dx,offset DGROUP:CRLF
                mov     cx,2
                call    PrintLine

                ret

PrintPixels     ENDP

;
; TranslatePixels
;
;       Copies one printable row of pixels from the first character definition
;       table in map 2 to the print buffer.
;
;       This routine formats the printer buffer for output to an Epson
;       MX-80.  The page is printed sideways, so the printed output is
;       350 pixels wide.
;

TranslatePixels PROC    near            ; Caller:       SI = video buffer offset
                                        ;               ES:DI -> print buffer

                push    ds              ; preserve DS
                mov     ds,VideoBufSeg  ; DS:SI -> video buffer

                add     di,es:PrintBufSize
                dec     di              ; ES:DI -> last byte in print buffer

                mov     dx,3CEh         ; Graphics Controller I/O port

; fill the print buffer

                mov     cx,es:Rows      ; CX := number of character rows

L11:            push    cx              ; preserve CX and SI
                push    si

                mov     ax,0004h        ; AH := value for Read Map Select reg
                                        ; AL := Read Map Select reg number
                out     dx,ax           ; select map 0 (character codes)

                lodsb                   ; AX := next char code in video buffer
                mov     cl,5
                shl     ax,cl           ; AX := AX * 32
                mov     si,ax           ; SI := offset of character definition
                                        ;  in map 2
                mov     ax,0204h
                out     dx,ax           ; select map 2 (bit patterns)

                mov     cx,es:Points    ; CX := size of character definition

L12:            cld
                lodsb                   ; AL := 8-bit pattern from character
                                        ;  definition table
                                        ; SI := SI + 1
                std
                stosb                   ; store bit pattern in print buffer
                                        ; DI := DI - 1
                loop    L12             ; loop down character definition

                pop     si              ; restore SI and CX
                pop     cx

                add     si,es:Columns   ; DS:SI -> next row of characters
                loop    L11             ; loop down character rows

                cld                     ; clear direction flag

                pop     ds              ; restore DS
                ret

TranslatePixels ENDP

;
; ScreenDumpAlpha
;

ScreenDumpAlpha PROC    near            ; Caller:       DS = DGROUP

                call    PrinterGraphics ; configure the printer for graphics

                call    CGenModeSet     ; address EGA memory maps in parallel:
                                        ;  map 0 contains character codes
                                        ;  map 2 contains character definitions

; copy screen dimensions from Video Display Data Area

                mov     ax,40h
                mov     es,ax           ; ES -> video BIOS data area

                mov     al,es:[84h]     ; AX := ROWS
                inc     ax
                mov     Rows,ax
                mov     ax,es:[4Ah]     ; AX := CRT_COLS
                add     ax,ax           ; * 2 for proper buffer addressing
                mov     Columns,ax
                mov     ax,es:[85h]     ; AX := POINTS
                mov     Points,ax
                mul     Rows            ; AX := ROWS * POINTS
                mov     PrintBufSize,ax

; print the screen

                push    ds
                pop     es              ; DS,ES := DGROUP

                xor     si,si           ; SI := offset of start of video buffer

L21:            push    si
                mov     di,offset DGROUP:PrintBuf
                call    TranslatePixels ; copy one printable row of pixels

                mov     cx,PrintBufSize
                mov     di,offset DGROUP:PrintBuf
                call    PrintPixels     ; print them

                pop     si
                add     si,2            ; increment to next character column
                cmp     si,Columns      ; loop across all character columns
                jb      L21
                                
                call    CGenModeClear   ; restore previous alphanumeric mode

                call    PrinterDefault  ; restore the printer to its default
                                        ;  state
                ret

ScreenDumpAlpha ENDP

;
; CGenModeSet (from Chapter 10)
;

CGenModeSet     PROC    near

                push    si              ; preserve these registers
                push    cx

                cli                     ; disable interrupts
                mov     dx,3C4h         ; Sequencer port address
                mov     si,offset DGROUP:SetSeqParms
                mov     cx,4

L31:            lodsw                   ; AH := value for Sequencer register
                                        ; AL := register number
                out     dx,ax           ; program the register
                loop    L31
                sti                     ; enable interrupts

                mov     dl,0CEh         ; DX := 3CEH (Graphics Controller port
                                        ;               address)
                mov     si,offset DGROUP:SetGCParms
                mov     cx,3

L32:            lodsw                   ; program the Graphics Controller
                out     dx,ax
                loop    L32

                pop     cx              ; restore registers and return
                pop     si
                ret             

CGenModeSet     ENDP


;
; CGenModeClear (from Chapter 10)
;

CGenModeClear   PROC    near

                push    si              ; preserve these registers
                push    cx

                cli                     ; disable interrupts
                mov     dx,3C4h         ; Sequencer port address
                mov     si,offset DGROUP:ClearSeqParms
                mov     cx,4

L41:            lodsw                   ; AH := value for Sequencer register
                                        ; AL := register number
                out     dx,ax           ; program the register
                loop    L41
                sti                     ; enable interrupts

                mov     dl,0CEh         ; DX := 3CEH (Graphics Controller port
                                        ;               address)
                mov     si,offset DGROUP:ClearGCParms
                mov     cx,3

L42:            lodsw                   ; program the Graphics Controller
                out     dx,ax
                loop    L42

                mov     ah,0Fh          ; AH := INT 10H function number
                int     10h             ; get video mode

                cmp     al,7
                jne     L43             ; jump if not monochrome mode

                mov     ax,0806h        ; program Graphics Controller
                out     dx,ax           ;  to start map at B000:0000

L43:            pop     cx              ; restore registers and return
                pop     si
                ret             

CGenModeClear   ENDP

_TEXT           ENDS


_DATA           SEGMENT word public 'DATA'

PrintBuf        DB      400 dup(?)      ; print output buffer

VideoBufSeg     DW      0A000h

EpsonGraphics   DB      1Bh,33h,18h
EpsonReset      DB      1Bh,40h
DataHeader      DB      1Bh,4Bh,00h,00h
CRLF            DB      0Dh,0Ah

Columns         DW      ?               ; number of displayed character columns
Rows            DW      ?               ; number of displayed character rows
Points          DW      ?               ; vertical size of character matrix
PrintBufSize    DW      ?               ; Rows * Points

SetSeqParms     DW      0100h           ; parameters for CGenModeSet
                DW      0402h
                DW      0704h
                DW      0300h

SetGCParms      DW      0204h
                DW      0005h
                DW      0006h

ClearSeqParms   DW      0100h           ; parameters for CGenModeClear
                DW      0302h
                DW      0304h
                DW      0300h

ClearGCParms    DW      0004h
                DW      1005h
                DW      0E06h

_DATA           ENDS

                END


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
