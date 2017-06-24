;                  Copyright 1991 TechnoJock Software, Inc. 
;                             All Rights Reserved           
;                            Restricted by License          

;                                 FastTOP.ASM 

;                               Version Alpha 2

%Title "TOT Toolkit screen writing and memory moving routines"

;       IDEAL

SEGMENT DATA byte public

        EXTRN   SnowProne : BYTE

ENDS DATA


SEGMENT CODE byte public

        ASSUME  CS:CODE, DS:DATA

        PUBLIC  AsmWrite, AsmPWrite, AsmAttr
        PUBLIC  ASMMoveFromScreen, ASMMoveToScreen

;  |||||||||||||||||||||||||||||||
;  |     A d j u s t E S D I     |
;  |||||||||||||||||||||||||||||||

;   Local routine that computes the offset from the top left of
;   the screen. You must set ES:DI to point to start of screen 
;   before calling.

AdjustESDI      PROC NEAR

        XOR     DX,DX                   ;set DX to 0
        MOV     CL,DL                   ;CL = 0
        MOV     BH,DL                   ;BH = 0
        MOV     AH,DL                   ;AH = 0
        DEC     CH                      ;set CH to number of full rows
        MUL     CH                      ;AX <- CH * AL  i.e. rows * width
        SHL     AX,1                    ;*2 for char and attr
        ADD     DI,AX                   ;add rows*width*2 to DI 
        DEC     BX                      ;decrease cols by 1
        SHL     BX,1                    ;multiply cols by 2
        ADD     DI,BX                   ;add cols to DI
        XOR     AX,AX                   ;set AX to zero
        RET                             ;Return

AdjustESDI      ENDP

;||||||||||||||||||||||||||||
;|     A S M w r i t e      |
;||||||||||||||||||||||||||||

;  Turbo passed parameters

AWSt            EQU     DWORD PTR [BP+6]
AWAttr          EQU     BYTE PTR [BP+10]
AWRow           EQU     BYTE PTR [BP+12]
AWCol           EQU     BYTE PTR [BP+14]
AWWidth         EQU     BYTE PTR [BP+16]
AWScreenStart   EQU     DWORD PTR [BP+18]

AsmWrite       PROC FAR

        PUSH    BP                      ;Save BP
        MOV     BP,SP                   ;Set up stack frame
        PUSH    DS                      ;Save DS
        MOV     CH,AWRow                ;CH = Row
        MOV     BL,AWCol                ;BL = Column
        MOV     AL,AWWidth              ;AL = screen width
        LES     DI,AWScreenStart        ;Set up ES:DI to start of screen
        CALL    AdjustESDI              ;move ES:DI to X,Y coord for write
        MOV     CL,SnowProne            ;Need to wait?
        LDS     SI,AWSt                 ;DS:SI points to St[0]
        CLD                             ;Set SI inc. direction to forward
        LODSB                           ;AX = Length(St); DS:SI -> St[1]
        XCHG    AX,CX                   ;CX = Length; AL = WaitForRetrace
        JCXZ    AWExit                  ;exit if CX = 0, i.e. string empty
        MOV     AH,AWAttr               ;AH = display attribute
        RCR     AL,1                    ;If WaitForRetrace is False...
        JNC     AWMono                  ; use "AWMono" routine
        MOV     DX,03DAh                ;Point DX to CGA status port
AWGetNext:
        LODSB                           ;Load next character into AL
        MOV     BX,AX                   ;Store video word in BX
        CLI                             ;hold interrupts
AWWaitNoH:
        IN      AL,DX                   ;get retrace situation
        TEST    AL,8                    ;retracing?
        JNZ     AWStore                 ;If so, go
        RCR     AL,1                    ;Else, wait for end of
        JC      AWWaitNoH               ; horizontal retrace
AWWaitH:
        IN      AL,DX                   ;get retrace situation
        RCR     AL,1                    ;Wait for horizontal
        JNC     AWWaitH                 ; retrace
AWStore:
        MOV     AX,BX                   ;Move word back to AX...
        STOSW                           ; and then to screen
        STI                             ;OK to interrupt now
        LOOP    AWGetNext               ;Get next character
        JMP     AWExit                  ;wind up
AWMono:
        LODSB                           ;Load next character into AL
        STOSW                           ;Move video word into place
        LOOP    AWMono                  ;Get next character
AWExit:
        POP     DS                      ;clean up and go home
        MOV     SP,BP                   ;
        POP     BP                      ;
        RET     16                      ;16 bytes for passed paremeters 
                                        ;(minimum is 2 bytes per param)

AsmWrite       ENDP

;||||||||||||||||||||||||||||||
;|     A S M P w r i t e      |
;||||||||||||||||||||||||||||||

;  Turbo passed parameters

PWSt            EQU     DWORD PTR [BP+6]
PWRow           EQU     BYTE PTR [BP+10]
PWCol           EQU     BYTE PTR [BP+12]
PWWidth         EQU     BYTE PTR [BP+14]
PWScreenStart   EQU     DWORD PTR [BP+16]

AsmPWrite      PROC FAR

        PUSH    BP                      ;Save BP
        MOV     BP,SP                   ;Set up stack frame
        PUSH    DS                      ;Save DS
        MOV     CH,PWRow                ;CH = Row
        MOV     BL,PWCol                ;BL = Column
        MOV     AL,PWWidth              ;AL = screen width
        LES     DI,PWScreenStart        ;Set up ES:DI to start of screen
        CALL    AdjustESDI              ;move ES:DI to X,Y coord for write
        MOV     CL,Snowprone            ;Need to wait?               
        LDS     SI,PWSt                 ;DS:SI points to St[0]
        CLD                             ;Set direction to forward
        LODSB                           ;AX = Length(St); DS:SI -> St[1]
        XCHG    AX,CX                   ;CX = Length; AL = Wait
        JCXZ    PWExit                  ;exit if string empty
        RCR     AL,1                    ;If WaitForRetrace is False...
        JNC     PWNoWait                ; use PWNoWait routine
        MOV     DX,03DAh                ;Point DX to CGA status port
PWGetNext:
        LODSB                           ;Load next character into AL
        MOV     AH,AL                   ;Store char in AH
        CLI                             ;hold interrupts
PWWaitNoH:
        IN      AL,DX                   ; get retrace situation
        TEST    AL,8                    ;Check for vertical retrace
        JNZ     PWStore                 ; In progress? go
        RCR     AL,1                    ;Else, wait for end of
        JC      PWWaitNoH               ; horizontal retrace
PWWaitH:
        IN      AL,DX                   ;Get 6845 status again
        RCR     AL,1                    ;Wait for horizontal
        JNC     PWWaitH                 ; retrace
PWStore:
        MOV     AL,AH                   ;Move char back to AL...
        STOSB                           ; and then to screen
        STI                             ;OK to interrupt now
        INC     DI                      ;Skip attribute bytes
        LOOP    PWGetNext               ;Get next character
        JMP     PWExit                  ;Done
PWNoWait:
        MOVSB                           ;Move character to screen
        INC     DI                      ;Skip attribute bytes
        LOOP    PWNoWait                ;Get next character
PWExit:
        POP     DS                      ;Clean up and go home
        MOV     SP,BP                   ;
        POP     BP                      ;
        RET     14                      ;

AsmPWrite      ENDP

;||||||||||||||||||||||||||
;|     A S M a t t r      |
;||||||||||||||||||||||||||

;  Turbo passed parameters

ANumber        EQU     WORD PTR [BP+6]
AAttr          EQU     BYTE PTR [BP+8]
ARow           EQU     BYTE PTR [BP+10]
ACol           EQU     BYTE PTR [BP+12]
PWWidth        EQU     BYTE PTR [BP+14]
PWScreenStart  EQU     DWORD PTR [BP+16]


ASMattr PROC FAR

        PUSH    BP                      ;Save BP
        MOV     BP,SP                   ;Set up stack frame
        MOV     CH,PWRow                ;CH = Row
        MOV     BL,PWCol                ;BL = Column
        MOV     AL,PWWidth              ;AL = screen width
        LES     DI,PWScreenStart        ;Set up ES:DI to start of screen
        CALL    AdjustESDI              ;move ES:DI to X,Y coord for write
        INC     DI                      ;Skip character
        CLD                             ;Set direction to forward
        MOV     CX,ANumber              ;CX = Number to change
        JCXZ    AExit                   ;If zero, exit
        MOV     AL,AAttr                ;AL = Attribute
        CMP     SnowProne,1             ;Get wait state
        JNE     ANoWait                 ;If WaitForRetrace is False
                                        ; use ANoWait routine
        MOV     AH,AL                   ;Store attribute in AH
        MOV     DX,03DAh                ;Point DX to CGA status port
AGetNext:
        CLI                             ;No interrupts now
AWaitNoH:
        IN      AL,DX                   ;get retrace situation
        TEST    AL,8                    ;check for vertical retrace
        JNZ     AGo                     ;In progress? Go
        RCR     AL,1                    ;Wait for end of horizontal
        JC      AWaitNoH                ; retrace
AWaitH:
        IN      AL,DX                   ; get retrace situation
        RCR     AL,1                    ;Wait for horizontal
        JNC     AWaitH                  ; retrace
AGo:
        MOV     AL,AH                   ;Move Attr back to AL...
        STOSB                           ; and then to screen
        STI                             ;Allow interrupts
        INC     DI                      ;Skip characters
        LOOP    AGetNext                ;Look for next opportunity
        JMP     AExit                   ;Done
ANoWait:
        STOSB                           ;Change the attribute
        INC     DI                      ;Skip characters
        LOOP    ANoWait                 ;Get next character
AExit:                                  
        MOV     SP,BP                   ;Clean up and go home
        POP     BP                      ;
        RET     14                      ;

AsmAttr ENDP


;||||||||||||||||||||||||||||||||||||||||||||||
;|     A S M M o v e F r o m S c r e e n      |
;||||||||||||||||||||||||||||||||||||||||||||||

;  Turbo passed parameters

MFLength        EQU     WORD PTR [BP+6]
MFDest          EQU     DWORD PTR [BP+8]
MFSource        EQU     DWORD PTR [BP+12]

ASMMoveFromScreen  PROC FAR

        PUSH    BP                      ;Save BP
        MOV     BP,SP                   ;Set up stack frame
        MOV     BX,DS                   ;Save DS in BX
        MOV     AL,Snowprone            ;Grab before changing DS
        LES     DI,MFDest               ;ES:DI points to Dest
        LDS     SI,MFSource             ;DS:SI points to Source
        MOV     CX,MFLength             ;CX = Length
        CLD                             ;Set direction to forward
        RCR     AL,1                    ;Check WaitForRetrace
        JNC     MFNoWait                ;False? Use MFNoWait routine
        MOV     DX,03DAh                ;Point DX to CGA status port
MFNext:
        CLI                             ;No interrupts now
MFWaitNoH:
        IN      AL,DX                   ;Get 6845 status
        TEST    AL,8                    ;Check for vertical retrace
        JNZ     MFGo                    ;In progress? go
        RCR     AL,1                    ;Wait for end of horizontal
        JC      MFWaitNoH               ; retrace
MFWaitH:
        IN      AL,DX                   ;Get 6845 status again
        RCR     AL,1                    ;Wait for horizontal
        JNC     MFWaitH                 ; retrace
MFGo:
        LODSW                           ;Load next video word into AX
        STI                             ;Allow interrupts
        STOSW                           ;Store video word in Dest
        LOOP    MFNext                  ;Get next video word
        JMP     MFExit                  ;All Done
MFNoWait:
        REP     MOVSW                   ;That's it!
MFExit:
        MOV     DS,BX                   ;Restore DS
        MOV     SP,BP                   ;Restore SP
        POP     BP                      ;Restore BP
        RET     10                      ;Remove parameters and return

ASMMoveFromScreen  ENDP

;|||||||||||||||||||||||||||||||||||||||||||
;|     A S M M o v e T o  S c r e e n      |
;|||||||||||||||||||||||||||||||||||||||||||

;  Turbo passed parameters

MTLength        EQU     WORD PTR [BP+6]
MTDest          EQU     DWORD PTR [BP+8]
MTSource        EQU     DWORD PTR [BP+12]

ASMMoveToScreen    PROC FAR

        PUSH    BP                      ;Save BP
        MOV     BP,SP                   ;Set up stack frame
        PUSH    DS                      ;Save DS
        MOV     AL,SnowProne            ;Grab before changing DS
        LES     DI,MTDest               ;ES:DI points to Dest
        LDS     SI,MTSource             ;DS:SI points to Source
        MOV     CX,MTLength             ;CX = Length
        CLD                             ;Set direction to forward
        RCR     AL,1                    ;Check WaitForRetrace
        JNC     MTNoWait                ;False? Use MTNoWait routine
        MOV     DX,03DAh                ;Point DX to CGA status port
MTGetNext:
        LODSW                           ;Load next video word into AX
        MOV     BX,AX                   ;Store video word in BX
        CLI                             ;No interrupts now
MTWaitNoH:
        IN      AL,DX                   ;Get 6845 status
        TEST    AL,8                    ;Check for vertical retrace
        JNZ     MTGo                    ;In progress? Go
        RCR     AL,1                    ;Wait for end of horizontal
        JC      MTWaitNoH               ; retrace
MTWaitH:
        IN      AL,DX                   ;Get 6845 status again
        RCR     AL,1                    ;Wait for horizontal
        JNC     MTWaitH                 ; retrace
MTGo:
        MOV     AX,BX                   ;Move word back to AX...
        STOSW                           ; and then to screen
        STI                             ;Allow interrupts
        LOOP    MTGetNext               ;Get next video word
        JMP     MTExit                  ;All done
MTNoWait:
        REP     MOVSW                   ;That's all!
MTExit:
        POP     DS                      ;Restore DS
        MOV     SP,BP                   ;Restore SP
        POP     BP                      ;Restore BP
        RET     10                      ;Remove parameters and return

ASMMoveToScreen    ENDP

ENDS    CODE

        END
