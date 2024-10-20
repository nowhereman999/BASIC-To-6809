; Get graphics on screen and put it in a buffer
; Enter with:
; U = Address of destination buffer 
; x at 5,S
; y at 4,S
; x1 at 3,S
; y1 at 2,S
GET:
        CLRA                    ; 16 bit values where MSB is zero (0 to 255)
        LDB     5,S             ; Load the starting x coordinate from stack
        STD     startX          ; Store in startX
        LDB     4,S             ; Load the starting y coordinate from stack
        STD     startY          ; Store in startY
        LDB     3,S             ; Load the ending x coordinate from stack
        STD     endX            ; Store in endX
        LDB     2,S             ; Load the ending y coordinate from stack
        STD     endY            ; Store in endY

        LDD     ,S              ; D = return address
        LEAS    4,S             ; Fix the stack
        STD     ,S              ; Save the return address

; Set X to point at the top left of the object to get on screen
        LDA     startY+1        ; A = Y co-ordinate
        LDB     startX+1        ; B = X co-ordinate
; A = Y co-ordinate and B = X co-ordinate
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the top left bytes to store
        LEAX    -1,X            ; Because we copy from B to 1 not zero 

; Setup ,S = number of bytes to copy per row and 1,S = number of rows to copy
; ,Y = number of bytes to copy per row and 1,Y = number of rows to copy
        LDB     endY+1
        SUBB    startY+1        ; B = the number of rows to copy to the get buffer
        INCB                    ; B = B + 1
        LEAY    ,U              ; Y = the get buffer location
        STB     1,U             ; Save the number of rows to get
        PSHS    B               ; Save the number of rows to get

        LDB     endX+1
        SUBB    startX+1        ; B = the number of pixels to get per row
        LSRB
        LSRB
        LSRB
        BNE     >
        INCB
!       ADDB    #2              ; B = B + 2 (the number of bytes to get per row)
        STB     ,U+             ; Save the number of bytes to get per row (U points at the start of the array -1, as below B only gets to 1 with STA B,U)
        PSHS    B               ; Save the number of bytes to get per row

; Find out how many pixels we need to mask off the right side of the object
        PSHS    X               ; Save the location of the top left bytes to get
GetMaskOffRightbits:
        LDA     endX+1          ; B = X co-ordinate
        ANDA    #%00000111      ; B = B & 7 
!       LDX     #PutLeftValues+1
        LDA     A,X
        STA     GetANDRightbits+1 ; Self modify the value below
        PULS    X               ; X = the location of the top left bytes to get

; Mask right bits off the right side of the object
; ,S = number of bytes to copy per row and 1,S = number of rows to copy
; ,Y = number of bytes to copy per row and 1,Y = number of rows to copy
GetStartNewRow:
        CLR     B,U             ; Clear the extra byte for each row, the extra byte is because we save rotated right versions into this byte
        DECB
        LDA     B,X             ; A = value of the right most graphics byte on screen
GetANDRightbits:
        ANDA    #%11111111      ; AND the value (self modified above) mask right bits off
        STA     B,U             ; Store the value of the mask graphics byte to the get buffer
        DECB                    ; Decrement the number of bytes to get per row
        BEQ     GetGotRow       ; skip ahead if all bytes of the row are copied
!       LDA     B,X             ; A = value of the graphics byte
        STA     B,U             ; Store the value of the graphics byte to the get buffer
        DECB                    ; Decrement the number of bytes to get per row
        BNE     <               ; Loop until all bytes are copied
GetGotRow:
        DEC     1,S             ; Decrement the number of rows to get
        BEQ     >               ; If all rows are copied then go skip ahead
        LEAX    32,X            ; X = X + 32 (move down to the next row)
        LDB     ,S              ; B = the number of bytes to get per row
        LEAU    B,U             ; U = U + D (move forward in the buffer)
        BRA     GetStartNewRow  ; Loop until all bytes are copied
!
        LDB     ,S              ; B = the number of bytes to get per row
        INCB                    ; U needs to be moved past the last cleared byte
        LEAU    B,U             ; U = U + B (move forward in the buffer, to the start where the shifted versions will be stored)
        LDB     1,Y             ; B = the number of rows to get
        STB     1,S             ; Save the number of rows to get

; Find out how many pixels we need to shift the data left
        LDB     startX+1        ; B = X co-ordinate
        ANDB    #%00000111      ; B = B & 7 
        BEQ     MakeShiftedVersions     ; If B = 0 then skip ahead, we don't have to shift the data left
        PSHS    B               ; Save the number of bits to shift

GetShiftBigLoop:
        LEAX    1,Y             ; X = Y + 1 (move X to the start of the data)
        LDB     1,Y             ; Get the number of rows to do
        STB     2,S             ; Save the number of rows to do
; ,S = number of bits to shift 1,S = number of bytes to copy per row and 2,S = number of rows to copy
; ,Y = number of bytes to copy per row and 1,Y = number of rows to copy
        LDB     1,S             ; B = the number of bytes to get per row
GetShiftLeft:
        CLRA                    ; Carry = 0
!       LDA     B,X             ; Get a byte in the buffer
        ROLA                    ; Shift the byte left
        STA     B,X             ; Save the new byte
        DECB                    ; move to the byte on the left
        BNE     <               ; Loop until all bits are shifted
        DEC     2,S             ; Decrement the row counter
        BEQ     GETRowIsShifted ; If all rows are copied then go skip ahead
        LDB     1,S             ; B = the number of bytes to get per row
        ABX                     ; X = X + B (move forward in the buffer)
        BRA     GetShiftLeft    ; Loop until all bytes are copied
GETRowIsShifted:
        DEC     ,S              ; decrement the number of times to shift the data
        BNE     GetShiftBigLoop    ; Loop until all rows are shifted the correct amount
        LEAS    1,S             ; Fix the stack
   
; Iterate seven more times rotating the pixels to the right once each iteration
;  ,S = Number of times to rotate (7)
; 1,S = number of bytes to copy per row
; 2,S = number of rows to copy
; ,Y = number of bytes to copy per row and 1,Y = number of rows to copy
MakeShiftedVersions:
        LDB     #7              ; B = 7, rotate 7 times
        PSHS    B               ; Save the number of times to rotate
        LEAX    2,Y             ; X = start of the non rotated pixels
GetRoatatedLoop:
        LDD     ,Y              ; A = bytes to get per row, B = the number of rows to get
        STD     1,S             ; Save the number of rows and the number of bytes to get per row
GetRotatedLoopNewRow:
        LDB     1,S             ; B = the number of bytes to get per row
        LDA     ,X+             ; A = the value of the last byte
        LSRA                    ; Shift the bits to the right
        STA     ,U+             ; Store the value of the graphics byte to the get buffer
        DECB                    ; Decrement the number of bytes to get per row
!       LDA     ,X+             ; A = the value of the last byte
        RORA                    ; Shift the bits to the right include the carry bit on the left most bit
        STA     ,U+             ; Store the value of the graphics byte to the get buffer
        DECB                    ; Decrement the number of bytes to get per row
        BNE     <               ; Loop until all bytes are copied for this row
        DEC     2,S             ; Decrement the number of rows to get
        BNE     GetRotatedLoopNewRow    ; Loop until all rows are copied
        DEC     ,S              ; Decrement the number of times to rotate
        BNE     GetRoatatedLoop ; Loop until all rotations are done
; Bytes have been copied to the get buffer
        PULS    B,Y,PC          ; Fix the stack and return

; Put graphics on screen
; Enter with:
; U = Address of source buffer 
; x at 5,S
; y at 4,S
; x1 at 3,S
; y1 at 2,S
PUT_PSET:
        CLRA                    ; 16 bit values where MSB is zero (0 to 255)
        LDB     5,S             ; Load the starting x coordinate from stack
        STD     startX          ; Store in startX
        LDX     #PutLeftValues
        ANDB    #%00000111      ; B = 0 to 7
        LDB     B,X
        STB     PutANDFirst1+1   ; Self modify value to keep left bits (below) 
        STB     PutANDFirst2+1   ; Self modify value to keep left bits (below) 
        STB     PutANDFirst3+1   ; Self modify value to keep left bits (below)        

        LDB     4,S             ; Load the starting y coordinate from stack
        STD     startY          ; Store in startY
        LDB     3,S             ; Load the ending x coordinate from stack
        INCB
        BNE     >
        DECB
!       STD     endX            ; Store in endX
        LDX     #PutRightValues
        ANDB    #%00000111      ; B = 0 to 7
        LDB     B,X
        STB     PutANDLast2+1   ; Self modify value to keep left bits (below)  
        STB     PutANDLast3+1   ; Self modify value to keep left bits (below)      
        ORB     PutANDFirst1+1   ; OR the right bits with the left bits 
        STB     PutANDFirst1+1   ; Self modify value to keep left bits & right bits(below) 

        LDB     2,S             ; Load the ending y coordinate from stack
        STD     endY            ; Store in endY
        LDD     ,S              ; Y = return address
        LEAS    4,S             ; Fix the stack
        STD     ,S              ; Save the return address

        LDA     startY+1        ; A = Y co-ordinate
        LDB     startX+1        ; B = X co-ordinate
; A = Y co-ordinate and B = X co-ordinate
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the top left bytes to store on screen

        LEAY    ,U              ; Y = U (number of bytes saved for each row)

        LDB     startX+1        ; B = starting pixel
        ANDB    #%00000111      ; B = 0 to 7 (the number of bits to shift the pixels to the right)
        PSHS    B               ; Save the number of bits to shift the pixels to the right
        LDB     endX+1
        SUBB    startX+1        ; B = width in pixels
        ADDB    ,S+             ; B = width + pixel # to start, fix the stack
        LSRB
        LSRB
        LSRB
        INCB
        PSHS    B               ; Save the number of bytes to write per row
        LDB     ,U++            ; Get the number of bytes saved per row, move U forward

        LDA     1,Y             ; Get the number of rows to write
        PSHS    A               ; Save the number of rows to write

        MUL                     ; D = A * B (number of bytes of data per copy of the roated pixels)
        PSHS    D               ; Save the number of bytes to write
        LDB     startX+1        ; B = X co-ordinate
        ANDB    #%00000111      ; B = 0 to 7 (the number of bits to shift the pixels to the right)
        LSLB                    ; B = B * 2 (0 to 14)
        NEGB                    ; B = -B (-14 to 0)
        ADDB    #14             ; B = B + 14 (0 to 14)
        STB     PUTDoAdd+1      ; Save the BRAnch location below (self mod where to begin adding)
        LDD     #$0000          ; D = 0
PUTDoAdd:
        BRA     <PUTPositisonZero ; This address will be self modified above to jump to the correct add line below
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
PUTPositisonZero:
        LEAS    2,S             ; Fix the stack
        LEAU    D,U             ; U = U + D, U now points at the correct rotated pixel version of the data

        LDB     1,S             ; B = the number of bytes to put per row
        CMPB    #2              ; Check if there are 2 bytes to put per row
        BHI     PutDoRow3Init   ; Branch if there are more than 2 bytes to put per row
        DECB
        BNE     PutDoRow2       ; Branch if there are 2 bytes to put per row

PutDoRow1:
;handle the first column
        LDA     ,X             ; Get the value from the graphics byte on the screen
PutANDFirst1:
        ANDA    #%11110000      ; Keep the bits to the left and right (Self modified above)
        ORA     ,U              ; OR the masked value from the screen with the value of the graphics byte
        STA     ,X              ; Store the value of the graphics byte to the screen
        DEC     ,S              ; Decrement the number of rows to put
        BEQ     >               ; If all rows are copied then go skip ahead
        LEAU    3,U             ; U = U + B
        LDB     #32
        ABX                     ; X = X + B (move to the start of the next row)
        BRA     PutDoRow1        ; Loop until all rows are copied
; Bytes have been copied to the screen
!       PULS    D,PC            ; Fix the stack and return

PutDoRow2:
;handle the first column
        LDA     ,X              ; Get the value from the graphics byte on the screen
PutANDFirst2:
        ANDA    #%11100000      ; Keep only the bits to the left (Self modified above)
        ORA     ,U+             ; OR the masked value from the screen with the value of the graphics byte
        STA     ,X+             ; Store the value of the graphics byte to the screen
; handle the last column
        LDA     ,X              ; Get the value from the graphics byte on the screen
PutANDLast2:
        ANDA    #%00011111      ; Keep only the bits to the right (Self modified above)
        ORA     ,U              ; OR the masked value from the screen with the value of the graphics byte
        STA     ,X              ; Store the value of the graphics byte to the screen
        DEC     ,S              ; Decrement the number of rows to put
        BEQ     >               ; If all rows are copied then go skip ahead
        LEAU    2,U             ; U = U + B
        LDB     #31
        ABX                     ; X = X + B (move to the start of the next row)
        BRA     PutDoRow2        ; Loop until all rows are copied
; Bytes have been copied to the screen
!       PULS    D,PC            ; Fix the stack and return

PutDoRow3Init:
        LDA     ,S              ; A = the number of rows to put
        EXG     A,B
        STD     ,S              ; Swap them to make it a little faster below
PutDoRow3:
        LDB     ,S              ; B = the number of bytes to put per row
;handle the first column
        LDA     ,X              ; Get the value from the graphics byte on the screen
PutANDFirst3:
        ANDA    #%11100000      ; Keep only the bits to the left (Self modified above)
        ORA     ,U+             ; OR the masked value from the screen with the value of the graphics byte
        STA     ,X+             ; Store the value of the graphics byte to the screen
        SUBB    #2              ; Check if there are 2 bytes to put per row
;copy the inner columns as they are
!       LDA     ,U+             ; Get value from the graphics byte
        STA     ,X+             ; Store the value of the graphics byte to the screen
        DECB                    ; Decrement the number of bytes to put per row
        BNE     <               ; Loop until all bytes are copied
; handle the last column
        LDA      ,X             ; Get the value from the graphics byte on the screen
PutANDLast3:
        ANDA    #%00011111      ; Keep only the bits to the right (Self modified above)
        ORA     ,U+             ; OR the masked value from the screen with the value of the graphics byte
        STA     ,X              ; Store the value of the graphics byte to the screen
        DEC     1,S             ; Decrement the number of rows to put
        BEQ     >               ; If all rows are copied then go skip ahead
        LDB     ,Y              ; B = the number of bytes stored per row
        SUBB    ,S              ; B = B - the number of bytes needed to copy per row
        LEAU    B,U             ; U = U + B
        LDB     #33
        SUBB    ,S              ; B = 33 - the number of bytes to copy per row
        ABX                     ; X = X + B (move to the start of the next row)
        BRA     PutDoRow3       ; Loop until all rows are copied
; Bytes have been copied to the screen
!       PULS    D,PC            ; Fix the stack and return

*** Don't change the order of these tables as part of the GET routine needs the start of the PutRightValues directly 
*** after the end of the PutLeftValues
PutLeftValues:
        FCB     %00000000       ; 0
        FCB     %10000000       ; 1
        FCB     %11000000       ; 2
        FCB     %11100000       ; 3
        FCB     %11110000       ; 4
        FCB     %11111000       ; 5
        FCB     %11111100       ; 6
        FCB     %11111110       ; 7      
PutRightValues:
        FCB     %11111111       ; 0
        FCB     %01111111       ; 1
        FCB     %00111111       ; 2
        FCB     %00011111       ; 3
        FCB     %00001111       ; 4
        FCB     %00000111       ; 5
        FCB     %00000011       ; 6
        FCB     %00000001       ; 7
        
