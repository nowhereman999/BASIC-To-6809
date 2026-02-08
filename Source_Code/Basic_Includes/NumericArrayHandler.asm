; DIM A(7,6,10,15), since these are zero based we must use 8,7,11,16 for calculations below
; To understand this a little better, what if my array is A(2,3,6,5)
; Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
; Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers)
; Since values are stored on the stack in reverse order
; Offset = (((d4 * NumElements4 + d3) * NumElements3 + d2) * NumElements2 + d1) * size of each element (2 for 16 bit integers)
; With a two dimensional array:
; Offset = (d2 * NumElements2 + d1) * size of each element (2 for 16 bit integers)
;
; Enter with:
; A = BytesPerEntry
; B = Number of Array Dimensions
; X = Start of the array data
; On the stack are a bunch of 8 bit numbers, d4,d3,d2,...
BytesPerEntry           FCB   1     ; Number of bytes per entry needed for this array
NumArrayDimCounter      FCB   1     ; Save Dimensions counter here
NumArrayLocation        FDB   $0000 ; Temp storage for where in memory the element is
NumArrayStart           FDB   $0000 ; Save the start address of this array
NumArrayGetAddress8bit:
	PULS	U		            ; Get RETURN address off the stack
      STU   @Return+1               ; Self mod return address below
      STD   BytesPerEntry           ; Save A into BytesPerEntry, Save B into NumArrayDimCounter
      LEAU  ,X                      ; U points at the NumElements table +1, so it points at Number of Elements for Dim 2
      STX   NumArrayStart           ; Save the start address of this array
      LDA   ,S+                     ; get d2, move the stack
      LDB   ,-U                     ; move down a byte and load B with NumElements2
      MUL                           ; Multiply them
      ADDB  ,S+                     ; Add d1, move the stack
      STD   NumArrayLocation        ; Save the current location (clears MSB)
      DEC   NumArrayDimCounter      ; Decrement the dim counter
      BEQ   @GotLocation            ; If we reached zero then we've got our location
!     LDB   NumArrayLocation+1      ; Get current calculated point
      LDA   ,-U                     ; A = NumElementsx
      MUL                           ; Multiply them
      ADDB  ,S+                     ; Add dx and move the stack
      STB   NumArrayLocation+1      ; Save the current location
      DEC   NumArrayDimCounter      ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got our location
@GotLocation:
      LDB   BytesPerEntry           ; Get the number of bytes that are needed to represent this number
      DECB
      BNE   >                       ; If it wasn't 1 then skip ahead
      LDD   NumArrayLocation        ; Get calculated location
      ADDD  NumArrayStart           ; D = calculated loaction + Array Start address
      PSHS  D                       ; save Location where to save the array value on stack 
      BRA   @Return                 ; Return
!     LDX   NumArrayStart           ; Get the start address of this array
      PSHS  X                       ; Save the start address of this array
      LDB   BytesPerEntry           ; Get the number of bytes that are needed to represent this number
      CLRA
      LDX   NumArrayLocation        ; Get calculated location, so far
      PSHS  D,X
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; get the calculated address
      ADDD  ,S                      ; Add the start address of the array, D now points to the location in ram where the numer starts
      STD   ,S                      ; save Location where to save the array value on stack 
@Return:
      JMP   >$FFFF                  ; jump to Self mod location
NumArrayGetAddress16bit:
	PULS	U		            ; Get RETURN address off the stack
      STU   @Return+1               ; Self mod return address below
      STD   BytesPerEntry           ; Save A into BytesPerEntry, Save B into NumArrayDimCounter
      LEAU  ,X                      ; U points at the NumElements table +1, so it points at Number of Elements for Dim 2
      STX   NumArrayStart           ; Save the start address of this array
; ,S = d4, 2,S d3
      LDD   ,--U                    ; move down a byte and load D with NumElements4
      PSHS  D                       ; Save NumElements4 as 16 bit on the stack, d4 is already on the stack
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; Get the low 16 bit result in D, fix the stack
      ADDD  ,S++                    ; Add d1, move the stack
      STD   NumArrayLocation        ; Save the current location
      DEC   NumArrayDimCounter      ; Decrement the dim counter
      BEQ   @GotLocation            ; If we reached zero then we've got our location!     LDD   StrArrayLocation        ; Get current calculated point
!     LDD   NumArrayLocation        ; Get current calculated point
      PSHS  D                       ; Save it on the stack
      LDD   ,--U                    ; D = NumElementsx
      PSHS  D                       ; Save it on the stack
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; Get the low 16 bit result in D, fix the stack
      ADDD  ,S++                    ; Add dx, move the stack
      STD   NumArrayLocation        ; Save the current location
      DEC   NumArrayDimCounter      ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got our location
      BRA   @GotLocation

NumArrayLoadElem8bit:
	PULS	U		            ; Get RETURN address off the stack
      STU   @Return+1               ; Self mod return address below
      STD   BytesPerEntry           ; Save A into BytesPerEntry, Save B into NumArrayDimCounter
      LEAU  ,X                      ; U points at the NumElements table +1, so it points at Number of Elements for Dim 2
      STX   NumArrayStart           ; Save the start address of this array
      LDA   ,S+                     ; get d2, move the stack
      LDB   ,-U                     ; move down a byte and load B with NumElements2
      MUL                           ; Multiply them
      ADDB  ,S+                     ; Add d1, move the stack
      STD   NumArrayLocation        ; Save the current location (clears MSB)
      DEC   NumArrayDimCounter      ; Decrement the dim counter
      BEQ   @GotLocation            ; If we reached zero then we've got our location
!     LDB   NumArrayLocation+1      ; Get current calculated point
      LDA   ,-U                     ; A = NumElementsx
      MUL                           ; Multiply them
      ADDB  ,S+                     ; Add dx and move the stack
      STB   NumArrayLocation+1      ; Save the current location
      DEC   NumArrayDimCounter      ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got our location
@GotLocation:
      LDX   NumArrayStart           ; Get the start address of this array
      LDB   BytesPerEntry           ; Get the number of bytes that are needed to represent this number
      DECB
      BNE   >                       ; If it wasn't 1 then skip ahead
      LDD   NumArrayLocation        ; Get calculated location
      LDB   D,X                     ; get byte at calculated loaction + Array Start address
      PSHS  B                       ; save byte 
      BRA   @Return                 ; Return
!     PSHS  X                       ; Save the start address of this array
      LDB   BytesPerEntry           ; Get the number of bytes that are needed to represent this number
      CLRA
      LDX   NumArrayLocation        ; Get calculated location, so far
      PSHS  D,X
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; get the calculated address
      ADDD  ,S++                    ; Add the start address of the array, D now points to the location in ram where the numer starts
      TFR   D,X                     ; X now points at the number in RAM
      LDB   BytesPerEntry           ; Get the number of bytes that are needed to represent this number
      ABX                           ; Move X to the end of the number
!     LDA   ,-X                     ; Decrement X and get the value in memory
      PSHS  A                       ; Put it on the stack
      DECB                          ; Decrement the counter
      BNE   <                       ; Loop
@Return:
      JMP   >$FFFF                  ; jump to Self mod location
NumArrayLoadElem16bit:
	PULS	U		            ; Get RETURN address off the stack
      STU   @Return+1               ; Self mod return address below
      STD   BytesPerEntry           ; Save A into BytesPerEntry, Save B into NumArrayDimCounter
      LEAU  ,X                      ; U points at the NumElements table +1, so it points at Number of Elements for Dim 2
      STX   NumArrayStart           ; Save the start address of this array
; ,S = d4, 2,S d3
      LDD   ,--U                    ; move down a byte and load D with NumElements4
      PSHS  D                       ; Save NumElements4 as 16 bit on the stack, d4 is already on the stack
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; Get the low 16 bit result in D, fix the stack
      ADDD  ,S++                    ; Add d1, move the stack
      STD   NumArrayLocation        ; Save the current location
      DEC   NumArrayDimCounter      ; Decrement the dim counter
      BEQ   @GotLocation            ; If we reached zero then we've got our location!     LDD   StrArrayLocation        ; Get current calculated point
!     LDD   NumArrayLocation        ; Get current calculated point
      PSHS  D                       ; Save it on the stack
      LDD   ,--U                    ; D = NumElementsx
      PSHS  D                       ; Save it on the stack
      JSR   MUL16                   ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
      LDD   ,S++                    ; Get the low 16 bit result in D, fix the stack
      ADDD  ,S++                    ; Add dx, move the stack
      STD   NumArrayLocation        ; Save the current location
      DEC   NumArrayDimCounter      ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got our location
      BRA   @GotLocation

      