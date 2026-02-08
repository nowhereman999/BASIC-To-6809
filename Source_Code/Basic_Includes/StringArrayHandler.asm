; DIM A(7,6,10,15), since these are zero based we must use 8,7,11,16 for calculations below
; To understand this a little better, what if my array is A(2,3,6,5)
; Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
; Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (x for strings)
;
; Enter with:
; A = BytesPerEntry
; B = Number of Array Dimensions
; X = Start of the array data
; On the stack are a bunch of 8 bit numbers, one per element
StrArrayLoadElem8bit:
	PULS	U		            ; Get RETURN address off the stack
      STU   @Return+1               ; Self mod return address below
      STD   StringLenPerEntry       ; Save A into StringLenPerEntry & B into StrArrayDimCounter
      STX   StrArrayStart           ; Save the start address of this array
      PULS  D                       ; A = d1, B = Number of Elements for dim 2
      MUL                           ; Multiply them
      ADDB  ,S+                     ; Add d2
      ADCA  #$00                    ; Add in the carry
      STD   StrArrayLocation        ; Save the current location
      DEC   StrArrayDimCounter      ; Decrement the dim counter
      BEQ   @GetLastPosition        ; If we reached zero then we've got our 2nd last location (must still * in string length byte)
!     LDD   StrArrayLocation        ; Get current calculated point
      PULS  A                       ; A = NumElements x
      MUL                           ; Multiply them
      ADDB  ,S+                     ; Add dx
      ADCA  #$00                    ; Add in the carry
      STD   StrArrayLocation        ; Save the current location
      DEC   StrArrayDimCounter      ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got out location
@GetLastPosition:
      LDB   StringLenPerEntry       ; Get the Length of strings
      CLRA                          ; Make it a 16 bit value
      LDX   StrArrayLocation        ; get the point in memory so far
      PSHS  D,X                     ; push them both on the stack
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; Get the reuslt in D, move the stack
      ADDD  StrArrayStart           ; Add the starting point in memory for this array
      TFR   D,X                     ; X points at the start of the string in RAM
      BSR   CopyStrAtXToStack       ; Copy string @ X to the stack
@Return:
      JMP   >$FFFF                  ; jump to Self mod location

; Copy string @ X to the stack
CopyStrAtXToStack:
	PULS	U		            ; Get RETURN address off the stack
      STU   @Return+1               ; Self mod return address below
      LDB   ,X+                     ; Get the length of the string in B, move X forward
      ABX                           ; Make X point at the end of the string
!     LDA   ,-X                     ; Get a byte of the source string
      PSHS  A                       ; Put it on the stack
      DECB                          ; Decrement the counter
      BNE   <                       ; Loop
      LDA   ,-X                     ; Get the length of the string
      PSHS  A                       ; Put it on the stack
@Return:
      JMP   >$FFFF                  ; jump to Self mod location

StrArrayLoadElem16bit:
	PULS	U		            ; Get RETURN address off the stack
      STU   @Return+1               ; Self mod return address below
      STD   StringLenPerEntry       ; Save A into StringLenPerEntry & B into StrArrayDimCounter
      STX   StrArrayStart           ; Save the start address of this array
; ,S = d1, 2,S = Number of Elements for dim 2
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; Get the low 16 bit result in D
      ADDD  ,S++                    ; Add d2
      STD   StrArrayLocation        ; Save the current location
      DEC   StrArrayDimCounter      ; Decrement the dim counter
      BEQ   @GetLastPosition        ; If we reached zero then we've got our 2nd last location (must still * in string length byte)
!     LDD   StrArrayLocation        ; Get current calculated point
      PSHS  D                       ; Save it on the stack
; Stack now has Current String Array location calc so far & NumElements X is next on the stack
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; Get the low 16 bit result in D, move the stack
      ADDD  ,S++                    ; Add dx
      STD   StrArrayLocation        ; Save the current location
      DEC   StrArrayDimCounter      ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got out location
@GetLastPosition:
      LDB   StringLenPerEntry       ; Get the Length of strings
      CLRA                          ; Make it a 16 bit value
      LDX   StrArrayLocation        ; get the point in memory so far
      PSHS  D,X                     ; push them both on the stack
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; Get the reuslt in D, move the stack
      ADDD  StrArrayStart           ; Add the starting point in memory for this array
      TFR   D,X                     ; X points at the start of the string in RAM
      BSR   CopyStrAtXToStack       ; Copy string @ X to the stack
@Return:
      JMP   >$FFFF                  ; jump to Self mod location

StringLenPerEntry       FCB   1     ; Length of the strings
StrArrayDimCounter      FCB   1     ; Save Dimensions counter here
StrArrayLocation        FDB   $0000 ; Temp storage for where in memory the element is, at each step
StrArrayStart           FDB   $0000 ; Save the start address of this array