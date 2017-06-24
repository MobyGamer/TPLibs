PAGE 60, 132
TITLE 12 bit LZW Compression Scheme
LOCALS @@

Comment *

  This unit is a modified version of Wilbert van Leijen's LZW unit,
  to implement a stream type that automatically compresses data.
  The original documentation:

  This modules implements a 12-bit Lempel-Zev-Welch "crunch" (compress
  data) and "uncrunch" (restore data in its original form) routines.
  InBuffer and OutBuffer are untyped; you must pass pointers to arrays
  (0..MaxRange) of Char or Byte to it, whereby MaxRange is limited to
  2^16-16+1 = 65521 bytes.

  You must also supply the size of the input buffer.

  The LZW technique is well explained in the following reference:

    Terry A. Welch, "A Technique for High Performance Data Compression"
    IEEE Computer
    Vol. 17, no. 6 (June 1984), pp. 8-19

  Incorporate these routines as follows in a TP unit:

  [ deleted ]

  (C) Copyright Wilbert van Leijen, Amsterdam 1990.
  Released to the Public Domain under the condition that this program
  will not be sold for a profit except with written permission from
  the author.

  Stream additions (c) copyright D.J. Murdoch, 1991.
*

MaxStack   = 4096;                     ; Decompression stack size
TableSize  = MaxStack-1;               ; Upper bound of 12 bit tables
HalfFull   = MaxStack / 2
ProbeValue = 131;                      ; Preferably a prime number
True       = 1
False      = 0
EndList    = -1;                       ; Marks end of a list
NoPrev     = -2;                       ; Code for no previous character
Empty      = -3;                       ; Indicates empty

DataSize   = [BP+18]                   ; Number of bytes input
OutputSize = word ptr [BP+16]          ; Max number to output
InputBuf   = [BP+12]                   ; Input data buffer
OutputBuf  = [BP+8]                    ; Output data buffer
Tables     = [BP+4]                    ; Where the tables are

Table      STRUC

Collision  DB      MaxStack DUP(?)     ; Hash table entries
PrefixTable DW     MaxStack DUP(?)     ; Code for preceding stringf
SuffixTable DB     MaxStack DUP(?)     ; Code for current character
ChildTable DW      MaxStack DUP(?)     ; Next duplicate in collision list
CharStack  DB      MaxStack DUP(?)     ; Decompression stack
StackPtr   DW      ?                   ; Decompression stack depth
Prefix     DW      ?                   ; Previous code string
TableUsed  DW      ?                   ; # string table entries used
InputPos   DW      ?                   ; Index in input buffer
OutputPos  DW      ?                   ; Index in output buffer
LastHit    DW      ?                   ; Last empty slot in collision table
CodeBuf    DW      ?                   ; Temporary code buffer

SaveIP     DW      ?                   ; Saved registers between calls
SaveAX     DW      ?
SaveCX     DW      ?
SaveDX     DW      ?

NotFound   DB      ?                   ; Character combination found flag

Table      ENDS

;  CH register is set aside for final output character (= Suffix)

Code       SEGMENT Word Public
           ASSUME  CS:Code

           Public  Initialise
           Public  PutSignature
           Public  Crunch
           Public  FlushLZW
           Public  GetSignature
           Public  Uncrunch

;  Initialise variables, fill tables

Initialise PROC    near

           PUSH    BP
           MOV     BP,SP
           PUSH    DS               ; save DS
           LDS     BX,Tables        ; get DS:BX to point to the tables

           XOR     AX, AX
           MOV     [BX].InputPos, AX
           MOV     [BX].OutputPos, AX
           MOV     [BX].TableUsed, AX
           MOV     [BX].StackPtr, AX
           MOV     [BX].CodeBuf, Empty

;  Loop:
;    Clear collision table
;    Set prefix to 'no previous character' code
;    Set child nodes to 'end of list' code

           MOV     DX, Tablesize
@@1:       MOV     DI, DX
           MOV     [BX+DI+Collision], 0
           SHL     DI, 1
           MOV     [BX+DI+PrefixTable], NoPrev
           MOV     [BX+DI+ChildTable], EndList
           DEC     DX
           JNS     @@1

;  Loop:
;   Enter all single characters into the hash table

           MOV     DX, 255
           MOV     [BX].Prefix, NoPrev
@@2:       MOV     CH, DL
           CALL    MakeEntry
           DEC     DX
           JNS     @@2

           MOV     [BX].SaveCX,CX
           POP     DS
           POP     BP
           RETN    4
Initialise ENDP

;  Hash function:  'fold' number
;    AX := (Prefix shl 5 xor Suffix) and TableSize
;    uses CL,DX

HashNumber MACRO
           XOR     DX, DX
           MOV     DL, CH
           MOV     AX, [BX].Prefix
           MOV     CL, 5
           SHL     AX, CL
           XOR     AX, DX
           AND     AX, TableSize
           ENDM

;  Store a character combination in the hash table

MakeEntry  PROC    Near
           PUSH    DX
           HashNumber

;  Rehash is necessary if entry in the hash table is occupied

           MOV     DI, AX
           CMP     [BX+DI+Collision], False
           JE      @@6

;  Loop:
;    Advance index of ChildTable to last empty list

@@1:       MOV     DI, AX
           SHL     DI, 1
           CMP     [BX+DI+ChildTable], EndList
           JE      @@2
           MOV     AX, [BX+DI+ChildTable]
           JMP     Short @@1

;  If the hash table is less than 50% loaded
;    Increase index with the probing value

@@2:       CMP     [BX].TableUsed, HalfFull
           JAE     @@3
           MOV     SI, AX
           ADD     SI, ProbeValue
           AND     SI, TableSize
           JMP     Short @@4

;  Else deal with the clustering problem
;  A simple yet effective solution is to start probing at the
;  empty slot of the hash table found during the previous run

@@3:       MOV     SI, [BX].LastHit

;  Loop:
;    Probe hash table until an empty slot is found

@@4:       CMP     [BX+SI+Collision], False
           JE      @@5
           INC     SI
           AND     SI, TableSize
           JMP     Short @@4

;  Found an empty slot, save index in ChildTable
;  Store index in LastHit

@@5:       MOV     DI, AX
           SHL     DI, 1
           MOV     [BX+DI+ChildTable], SI
           MOV     DI, SI
           MOV     [BX].LastHit, SI

;  Return:
;    Indicate hash table slot's been occupied
;    Store character combination in PrefixTable, SuffixTable
;    Indicate 'end of list' in ChildTable
;    Bump table load counter

@@6:       MOV     [BX+DI+Collision], True
           MOV     [BX+DI+SuffixTable], CH
           SHL     DI, 1
           MOV     [BX+DI+ChildTable], EndList
           MOV     AX, [BX].Prefix
           MOV     [BX+DI+PrefixTable], AX
           INC     [BX].TableUsed
           POP     DX
           RETN
MakeEntry  ENDP

;  Lookup a character combination in the hash table

LookupStr  PROC    Near
           HashNumber
           XCHG    SI, AX

;  Search through list of hash collision entries for one that match
;  Loop
;    Entry is found if prefix and suffix match
;    If no match, advance index to entry in ChildTable
;  Until entry is found or no such list exists in ChildTable

@@1:       MOV     DI, SI
           MOV     AL, [BX+DI+SuffixTable]
           CMP     AL, CH
           JNE     @@2
           SHL     DI, 1
           MOV     AX, [BX+DI+PrefixTable]
           CMP     AX, [BX].Prefix
           JE      @@3

@@2:       MOV     DI, SI
           SHL     DI, 1
           MOV     SI, [BX+DI+ChildTable]
           CMP     SI, EndList
           JNE     @@1

;  Return index from ChildTable in AX

@@3:       XCHG    AX, SI
           RETN
LookupStr  ENDP

;  Retrieve next character from the input buffer

GetChar    MACRO
           LES     DI, InputBuf
           ADD     DI, [BX].InputPos
           MOV     AL, ES:[DI]
           INC     [BX].InputPos
           ENDM

;  Store next character in AL into the output buffer

PutChar    MACRO
           LES     DI, OutputBuf
           ADD     DI, [BX].OutputPos
           STOSB
           INC     [BX].OutputPos
           ENDM

;  Retrieve compressed code from input buffer

GetCode    PROC    Near

           MOV     SI, [BX].CodeBuf
;  Get first character and store it in a temporary buffer

           GetChar
           XOR     AH, AH
           MOV     DX, AX

;  If input code is empty

           CMP     SI, Empty
           JNE     @@1

;    Get next character
;    Return 8 bits from first character + 4 bits from second character
;    Save the remaining 4 bits of the second character for next time

           GetChar
           MOV     SI, AX
           MOV     CL, 4
           SHR     AX, CL
           MOV     DI, AX
           MOV     AX, DX
           SHL     AX, CL
           ADD     AX, DI
           JMP     @@2

;  Else
;    Get the last 4 bits from the input code + 8 bits from the second char

@@1:       MOV     AX, SI
           XCHG    AH, AL
           AND     AH, 0Fh
           ADD     AX, DX
           MOV     SI, Empty
@@2:
           MOV     [BX].CodeBuf,SI
           RETN
GetCode    ENDP

;  Store compressed code in the output buffer

PutCode    PROC    Near
           MOV     DI, [BX].CodeBuf
           MOV     DX, [BX].Prefix

;  If output code is empty

           CMP     DI, Empty
           JNE     @@1

;    Store first 8 bits in the output buffer
;    Save last 4 bits for the next time through

           MOV     AX, DX
           MOV     CL, 4
           SHR     AX, CL
           PutChar
           MOV     DI, DX
           JMP     @@2

;  Else
;    Put out last 4 bits of previous code + first 4 bits of this code
;    Next, put out last 8 bits of this code
;    Indicate output code as empty

@@1:       MOV     AX, DI
           MOV     CL, 4
           SHL     AX, CL
           ADD     AL, DH
           PutChar
           MOV     AL, DL
           PutChar
           MOV     DI, Empty
@@2:       MOV     [BX].CodeBuf,DI
           RETN
PutCode    ENDP

;  Start the compressor by putting 'LZ'

PutSignature PROC  Near
           PUSH    BP
           MOV     BP,SP
           PUSH    DS               ; save DS
           LDS     BX,Tables        ; get DS:BX to point to the tables

           MOV     [BX].OutputPos, 0

;  Get first character and store it in Suffix
;  There are no character combinations yet

           MOV     AL, 'L'
           MOV     CH, AL
           MOV     [BX].Prefix, NoPrev
           CALL    LookupStr
           MOV     [BX].Prefix, AX

;  Get next character

           MOV     AL, 'Z'
           MOV     CH, AL

           MOV     [BX].SaveCX,CX

           MOV     AL,True          ;  Return success
           POP     DS
           POP     BP
           RET     4
PutSignature ENDP


Crunch     PROC    Near
           PUSH    BP
           MOV     BP,SP
           PUSH    DS               ; save DS
           LDS     BX,Tables        ; get DS:BX to point to the tables
           MOV     CX,[BX].SaveCX   ; get saved registers
           MOV     [BX].InputPos, 0
           MOV     [BX].OutputPos, 0
           DEC     OutputSize       ; sometimes we write 2 bytes per loop,
                                    ; so reduce this for safety

;  Loop:
;    Process all characters from input buffer

@@1:       MOV     DX, [BX].InputPos
           MOV     AX, [BX].OutputPos
           CMP     DX, DataSize
           JAE     @@5
           CMP     AX, OutputSize
           JAE     @@5

;  Lookup the character combination
;  Store if not found and if empty slots are available in the hash table

           CALL    LookupStr
           MOV     DI, AX
           CMP     DI, EndList
           JNE     @@3
           PUSH    DI
           CMP     [BX].TableUsed, TableSize
           JA      @@2
           CALL    MakeEntry

;  Store code in the output buffer
;  If string is in table, keep looking for longer strings

@@2:       CALL    PutCode
           POP     DI
           MOV     [BX].Prefix, NoPrev
           XCHG    DX, DI
           CALL    LookupStr
           XCHG    DI, DX
           MOV     [BX].Prefix, AX
           JMP     Short @@4

;  Get next character

@@3:       MOV     [BX].Prefix, DI
@@4:       GetChar
           MOV     CH, AL
           JMP     Short @@1

@@5:       MOV     [BX].SaveCX,CX
           ; return number written in AX
           ; and number used in DX
           POP     DS
           POP     BP
           RET     14
Crunch     ENDP

;  Make sure the last code will be written out
;  If the output code <> Empty, store the last 4 pending bits

FlushLZW   Proc    Near
           PUSH    BP
           MOV     BP,SP
           PUSH    DS               ; save DS
           LDS     BX,Tables        ; get DS:BX to point to the tables
           MOV     CX,[BX].SaveCX   ; get saved registers
           MOV     [BX].InputPos, 0
           MOV     [BX].OutputPos, 0
@@5:       CALL    PutCode
           MOV     SI,[BX].CodeBuf
           CMP     SI, Empty
           JE      @@7
           MOV     AX, SI
           MOV     CL, 4
           SHL     AX, CL
           PutChar

;  Return the number of bytes written to the output buffer

@@7:       MOV     AX, [BX].OutputPos
           MOV     [BX].SaveCX,CX
           POP     DS
           POP     BP
           RET     8
FlushLZW   ENDP

;  Run through code extracting single characters from code string until
;  no more characters can be removed.  Push these onto the stack.
;  They will be entered in reverse order, and will come out in forwards order
;  when popped off

PushChar   PROC    Near
@@1:       MOV     DI, SI
           SHL     DI, 1
           CMP     [BX+DI+PrefixTable], NoPrev
           JNE     @@2
           RETN

@@2:       MOV     AL, [BX+SI+SuffixTable]
           INC     [BX].StackPtr
           MOV     DI, [BX].StackPtr
           MOV     [BX+DI+CharStack], AL
           SHL     SI, 1
           MOV     SI, [BX+SI+PrefixTable]
           JMP     Short @@1
PushChar   ENDP

;  While StackPtr > 0
;    Pop a character from the stack

PopChar    PROC    Near
           PutChar
           MOV     DI, [BX].StackPtr
           OR      DI, DI
           JE      @@1
           MOV     AL, [BX+DI+CharStack]
           DEC     [BX].StackPtr
           RETN

@@1:       MOV     AX, Empty
           RETN
PopChar    ENDP

; Check for correct start of buffer, and initialize registers

GetSignature PROC  Near
           PUSH    BP
           MOV     BP, SP
           PUSH    DS               ; save DS
           LDS     BX,Tables        ; get DS:BX to point to the tables

;  Get first string and check the corresponding character
;  Keep a copy of this code

           CALL    GetCode
           MOV     [BX].Prefix, AX
           MOV     SI, AX
           MOV     CH, [BX+SI+SuffixTable]
           CMP     CH, 'L'
           JNE     @@2

           CALL    GetCode
           MOV     [BX].SaveDX, AX

;  Do half a run through the old Uncrunch loop

;         (  skip size check )

           MOV     [BX].Notfound, False
           MOV     SI, AX

;         (  skip collision test, & PushChar call  )

           MOV     CH, [BX+SI+SuffixTable]
           CMP     CH, 'Z'
           JNE     @@2

;         (  do PopChar's MOV AX, Empty )
           MOV     [BX].SaveAX,Empty

           MOV     AL,True     ; Success!  We're ready for the loop.
           JMP     @@1

@@2:       MOV     AL,False    ; It failed!

@@1:       MOV     [BX].SaveCX,CX
           MOV     [BX].SaveIP,OFFSET MainLoop
           POP     DS
           POP     BP
           RET     14
GetSignature ENDP


UnCrunch   PROC    Near
           PUSH    BP
           MOV     BP,SP
           PUSH    DS               ; save DS
           LDS     BX,Tables        ; get DS:BX to point to the tables
           MOV     AX,[BX].SaveAX   ; get saved registers
           MOV     CX,[BX].SaveCX
           MOV     DX,[BX].SaveDX

           MOV     [BX].InputPos, 0 ; set up string pointers & sizes
           MOV     [BX].OutputPos, 0
           DEC     Word Ptr DataSize         ; sometimes we need to read two
           JMP     [BX].SaveIP

;  Loop:
;    Process all characters from input buffer

;  While the stack is not empty, remove and output all characters from
;  stack which are rest of characters in the string

@@1:       MOV     DI,[BX].OutputPos ; Check if there's room for more characters
           CMP     DI,OutputSize
           JB      @@3
           CALL    ExitLoop          ; Exit from Uncrunch

Mainloop:
@@3:       CMP     AX, Empty
           JE      @@4
           CALL    PopChar
           JMP     Short @@1

;  If code isn't known, store the follower character of last
;  character of string

@@4:       CMP     [BX].NotFound, False
           JE      @@5
           PUSH    AX
           MOV     AL, CL
           MOV     CH, AL
           PutChar
           POP     AX

;  Check whether there's enough space for another char

@@8:       MOV     DI,[BX].OutputPos
           CMP     DI,OutputSize
           JB      @@5

;  No space, so quit

           CALL    ExitLoop

;  If the hash table is not full
;    Enter code into table
;  Make current code the previous code
;  Get next code

@@5:       CMP     [BX].TableUsed, TableSize
           JA      @@6
           CALL    MakeEntry
@@6:       MOV     [BX].Prefix, DX
           CALL    GetCode
           XCHG    DX, AX

; Old top of loop

           MOV     AX, [BX].InputPos
           CMP     AX, DataSize
           JB      @@10

;  Out of data, so exit

           CALL    ExitLoop

;  Retrieve character from string
;  Keep a copy of it in CL

@@10:      MOV     [BX].NotFound, False
           MOV     SI, DX
           CMP     [BX+SI+Collision], False
           JNE     @@2
           MOV     AL, CH
           MOV     CL, AL
           MOV     SI, [BX].Prefix
           MOV     [BX].NotFound, True

;  Get first character from string

@@2:       CALL    PushChar
           MOV     AL, [BX+SI+SuffixTable]
           MOV     CH, AL
           CALL    PopChar

           JMP     @@1

UnCrunch   ENDP

ExitLoop   PROC    Near             ; allows exit from UnCrunch loop
                                    ; and resumption at several places.
           POP     [BX].SaveIP      ; Get address
           MOV     [BX].SaveAX,AX   ; Save registers
           MOV     [BX].SaveCX,CX
           MOV     [BX].SaveDX,DX

;  Return the number of bytes written to the output buffer in AX
;  and the number of bytes used in DX

           MOV     AX, [BX].OutputPos
           MOV     DX, [BX].InputPos

           POP     DS
           POP     BP
           RETN    14
ExitLoop   ENDP

Code       ENDS
           END
