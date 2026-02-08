; DIM A(7,6,10,15), since these are zero based we must use 8,7,11,16 for calculations below
; To understand this a little better, what if my array is A(2,3,6,5)
; Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
; Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers)
; Since values are stored on the stack in reverse order
; Offset = (((d4 * NumElements4 + d3) * NumElements3 + d2) * NumElements2 + d1) * size of each element (2 for 16 bit integers)
; With a two dimensional array:
; Offset = (d2 * NumElements2 + d1) * size of each element (2 for 16 bit integers)

; Enter with:
; A = BytesPerEntry
; B = Number of Array Dimensions
; X = Start of the array data
; On the stack are a bunch of 8 bit numbers, d4,d3,d2,...
BytesPerEntry           FCB   1     ; Number of bytes per entry needed for this array
ArrayDimCounter         FCB   1     ; Save Dimensions counter here
ArrayLocation           FDB   $0000 ; Temp storage for where in memory the element is
ArrayStart              FDB   $0000 ; Save the start address of this array

;pop d3
;pop d2
;pop d1
;
;scale = 1
;index = d3
;
;scale = scale * 9     ' N3
;index = index + d2 * scale
;
;scale = scale * 8     ' N2
;index = index + d1 * scale
;
;byteOffset = index * bytesPerElement

ArrayGetAddress8bit:
	PULS	X		            ; Get RETURN address off the stack
      STX   @Return+1               ; Self mod return address below
      STD   BytesPerEntry           ; Save A into BytesPerEntry, Save B into ArrayDimCounter
      PULS  A                       ; Get the last dx value
      STA   @Index                  ; Save it as initial Index
      STU   ArrayStart              ; Save the start address of this array (Element Scale is before this location)
      LDB   ,-U                     ; D = Scale for the first number
      BRA   @First                  ; Save from doing first MUL
; ,S = d4, 2,S d3, ...  
!     LDA   @Scale                  ; Get the existing Scale
      LDB   ,-U                     ; D = Scale for this number
      MUL                           ; B = New scale is on the stack
@First:
      STB   @Scale                  ; Save the new scale
      PULS  A                       ; A = dx
      MUL                           ; B = Scale * dx
      ADDB  @Index                  ; B = Index + (dx * scale)
      STB   @Index                  ; Save the new index
      DEC   ArrayDimCounter         ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got our location
      LDB   BytesPerEntry           ; B = BytesPerEntry
      LDA   @Index                  ; A = Index
      MUL                           ; D = Final Index
      ADDD  ArrayStart              ; Add the start address of the Array
      PSHS  D                       ; save Location on stack 
@Return:
      JMP   >$FFFF                  ; jump to Self mod location; 8 Bit array value with only one element (size of BytePerEntry in A)
;
ArrayGetAddress16bit:
	PULS	X		            ; Get RETURN address off the stack
      STX   @Return+1               ; Self mod return address below
      STD   BytesPerEntry           ; Save A into BytesPerEntry, Save B into ArrayDimCounter
      PULS  D                       ; Get the last dx value
      STD   @Index                  ; Save it as initial Index
      STU   ArrayStart              ; Save the start address of this array (Element Scale is before this location)
      LDX   ,--U                    ; D = Scale for this number
      PSHS  X                       : Save the scale on the stack
      BRA   @First16                ; Save from doing first MUL16
; ,S = d4, 2,S d3, ...  
!     LDD   @Scale                  ; Get the existing Scale
      PSHS  D                       ; Push Scale on the stack
      LDD   ,--U                    ; D = Scale for this number
      PSHS  D                       : Save the scale on the stack
      JSR   MUL16                   ; D = MSWORD ,S & X = LSWORD of ,S * 2,S (new scale is on the stack)
@First16:
      STX   @Scale                  ; Save the new scale
      JSR   MUL16                   ; Scale * dx, D = MSWORD ,S & X = LSWORD of ,S * 2,S (new scale is on the stack)
      LDD   ,S++                    ; get Scale * dx, fix the stack
      ADDD  @Index                  ; Add (dx * scale)
      STD   @Index                  ; Save the new index
      DEC   ArrayDimCounter         ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got our location
      CLRA
      LDB   BytesPerEntry           ; D = BytesPerEntry
      PSHS  D                       ; Push on the stack
      LDD   @Index                  ; D = Index
      PSHS  D                       ; Push on the stack
      JSR   MUL16                   ; D = MSWORD ,S & X = LSWORD of ,S * 2,S
      LDD   ,S++                    ; D = The result and fix the stack
      ADDD  ArrayStart              ; Add the start address of the Array
      PSHS  D                       ; save Location on stack 
      BRA   @Return                 ; Return
;
@Scale      FDB   $0000                  ; Start wit ha scale of 1
@Index      FDB   $0000            ; Save it as initial Index


StrArrayLoadElem8bit:
	PULS	X		            ; Get RETURN address off the stack
      STX   @Return+1               ; Self mod return address below
      STD   BytesPerEntry           ; Save A into BytesPerEntry, Save B into ArrayDimCounter
      PULS  A                       ; Get the last dx value
      STA   @Index                  ; Save it as initial Index
      STU   ArrayStart              ; Save the start address of this array (Element Scale is before this location)
      LDB   ,-U                     ; B = Scale for the first number
      BRA   @First                  ; Save from doing first MUL
; ,S = d4, 2,S d3, ...  
!     LDA   @Scale                  ; Get the existing Scale
      LDB   ,-U                     ; B = Scale for this number
      MUL                           ; B = New scale is on the stack
@First:
      STB   @Scale                  ; Save the new scale
      PULS  A                       ; A = dx
      MUL                           ; B = Scale * dx
      ADDB  @Index                  ; B = Index + (dx * scale)
      STB   @Index                  ; Save the new index
      DEC   ArrayDimCounter         ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got our location
;
      LDB   BytesPerEntry           ; B = BytesPerEntry
      LDA   @Index                  ; A = Index
      MUL                           ; D = Final Index
      ADDD  ArrayStart              ; Add the start address of the Array
@GotLocation:
      TFR   D,X                     ; X = Location
      LDB   ,X+                     ; Get the number of bytes that are needed to represent this number
      ABX                           ; Move X to the end of the number
      INCB
!     LDA   ,-X                     ; Decrement X and get the value in memory
      PSHS  A                       ; Put it on the stack
      DECB                          ; Decrement the counter
      BNE   <                       ; Loop
@Return:
      JMP   >$FFFF                  ; jump to Self mod location
StrArrayLoadElem16bit:
	PULS	X		            ; Get RETURN address off the stack
      STX   @Return+1               ; Self mod return address below
      STD   BytesPerEntry           ; Save A into BytesPerEntry, Save B into ArrayDimCounter
      PULS  D                       ; Get the last dx value
      STD   @Index                  ; Save it as initial Index
      STU   ArrayStart              ; Save the start address of this array (Element Scale is before this location)
      LDX   ,--U                    ; D = Scale for this number
      PSHS  X                       : Save the scale on the stack
      BRA   @First16                ; Save from doing first MUL16
; ,S = d4, 2,S d3, ...  
!     LDD   @Scale                  ; Get the existing Scale
      PSHS  D                       ; Push Scale on the stack
      LDD   ,--U                    ; D = Scale for this number
      PSHS  D                       : Save the scale on the stack
      JSR   MUL16                   ; D = MSWORD ,S & X = LSWORD of ,S * 2,S (new scale is on the stack)
@First16:
      STX   @Scale                  ; Save the new scale
      JSR   MUL16                   ; Scale * dx, D = MSWORD ,S & X = LSWORD of ,S * 2,S (new scale is on the stack)
      LDD   ,S++                    ; get Scale * dx, fix the stack
      ADDD  @Index                  ; Add (dx * scale)
      STD   @Index                  ; Save the new index
      DEC   ArrayDimCounter         ; Decrement the dim counter
      BNE   <                       ; Keep looping until we've got our location
      CLRA
      LDB   BytesPerEntry           ; D = BytesPerEntry
      PSHS  D                       ; Push on the stack
      LDD   @Index                  ; D = Index
      PSHS  D                       ; Push on the stack
      JSR   MUL16                   ; D = MSWORD ,S & X = LSWORD of ,S * 2,S
      LDD   ,S++                    ; D = The result and fix the stack
      ADDD  ArrayStart              ; Add the start address of the Array
      BRA   @GotLocation            ; Save the string on the stack
;
@Scale      FDB   $0000                  ; Start wit ha scale of 1
@Index      FDB   $0000            ; Save it as initial Index
