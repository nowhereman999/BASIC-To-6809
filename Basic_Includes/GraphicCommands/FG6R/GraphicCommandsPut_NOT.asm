; Put graphics on screen
; Enter with:
; U = Address of source buffer 
; x at 5,S
; y at 4,S
; x1 at 3,S
; y1 at 2,S
PUT_NOT:
        CLRA                    ; 16 bit values where MSB is zero (0 to 255)
        LDB     5,S             ; Load the starting x coordinate from stack
        STD     startX          ; Store in startX
        LDX     #PutLeftValues
        ANDB    #%00000111      ; B = 0 to 7
        LDB     B,X
        STB     PutNOTFirst1NOT0+1   ; Self modify value to keep left bits (below) 
        STB     PutNOTFirst2NOT1+1   ; Self modify value to keep left bits (below) 
        STB     PutNOTFirst3NOT1+1   ; Self modify value to keep left bits (below)   
        COMB
        STB     PutNOTFirst2NOT0+1   ; Self modify value to keep left bits (below)  
        STB     PutNOTFirst3NOT0+1   ; Self modify value to keep left bits (below)   
        STB     +1   ; Self modify value to keep left bits (below)    

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
        STB     PutNOTLast2NOT1+1   ; Self modify value to keep left bits (below)   
        STB     PutNOTLast3NOT1+1   ; Self modify value to keep left bits (below)    
        PSHS    B                   ; Save B
        COMB                        ; Flip the bits
        STB     PutNOTLast2NOT0+1   ; Self modify value to keep left bits (below) 
        STB     PutNOTLast3NOT0+1   ; Self modify value to keep left bits (below)  
        PULS    B                   ; Restore B
        ORB     PutNOTFirst1NOT0+1   ; OR the right bits with the left bits 
        STB     PutNOTFirst1NOT1+1   ; Self modify value to keep left bits & right bits(below) 
        COMB                        ; Flip the bits
        STB     PutNOTFirst1NOT0+1   ; Self modify value to keep left bits & right bits(below) 

        LDB     2,S             ; Load the ending y coordinate from stack
        STD     endY            ; Store in endY
        LDD     ,S              ; Y = return address
        LEAS    4,S             ; Fix the stack
        STD     ,S              ; Save the return address

        LDA     startY+1        ; A = Y co-ordinate
        LDB     startX+1        ; B = X co-ordinate
; A = Y co-ordinate NOT B = X co-ordinate
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
        STB     PUTDoAddNOT+1   ; Save the BRAnch location below (self mod where to begin adding)
        LDD     #$0000          ; D = 0
PUTDoAddNOT:
        BRA     <PUTPositisonZeroNOT ; This address will be self modified above to jump to the correct add line below
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
        ADDD    ,S              ; D=D+size of data
PUTPositisonZeroNOT:
        LEAS    2,S             ; Fix the stack
        LEAU    D,U             ; U = U + D, U now points at the correct rotated pixel version of the data

        LDB     1,S             ; B = the number of bytes to put per row
        CMPB    #2              ; Check if there are 2 bytes to put per row
        BHI     PutDoRowNOT3Init ; Branch if there are more than 2 bytes to put per row
        DECB
        BNE     PutDoRowNOT2    ; Branch if there are 2 bytes to put per row

PutDoRowNOT1:
;handle the first column
        LDA     ,X              ; Get value from the screen
        COMA                    ; flip the bits
PutNOTFirst1NOT0:
        ANDA    #%11111000      ; Keep the inside bits (already complimented value) (Self modified above)
        PSHS    A               ; Save the value on the stack
        LDA     ,X              ; Get the value from the graphics byte on the screen
PutNOTFirst1NOT1:
        ANDA    #%00000111      ; Keep the bits to the left and right (Self modified above)
        ORA     ,S+             ; merge them together, fix the stack
        STA     ,X              ; Store the value of the graphics byte to the screen
        DEC     ,S              ; Decrement the number of rows to put
        BEQ     >               ; If all rows are copied then go skip ahead
        LDB     #32             ; B = 32, the number of bytes to copy per row
        ABX                     ; X = X + B (move to the start of the next row)
        BRA     PutDoRowNOT1 
; Bytes have been copied to the screen
!       PULS    D,PC            ; Fix the stack and return

PutDoRowNOT2:
;handle the first column
        LDA     ,X              ; Get value from the screen
        COMA                    ; flip the bits
PutNOTFirst2NOT0:
        ANDA    #%11111000      ; Keep the inside bits (already complimented value) (Self modified above)
        PSHS    A               ; Save the value on the stack
        LDA     ,X              ; Get the value from the graphics byte on the screen
PutNOTFirst2NOT1:
        ANDA    #%11100000      ; Keep only the bits to the left (Self modified above)
        ORA     ,S+             ; OR the masked value from the screen with the value of inverted buffer, fix stack
        STA     ,X+             ; Store the value of the graphics byte to the screen

; handle the last column
        LDA     ,X              ; Get value from the screen
        COMA                    ; flip the bits
PutNOTLast2NOT0:
        ANDA    #%11111000      ; Keep the inside bits (already complimented value) (Self modified above)
        PSHS    A               ; Save the value on the stack
        LDA     ,X              ; Get the value from the graphics byte on the screen
PutNOTLast2NOT1:
        ANDA    #%11100000      ; Keep only the bits to the left (Self modified above)
        ORA     ,S+             ; OR the masked value from the screen with the value of inverted buffer, fix stack
        STA     ,X              ; Store the value of the graphics byte to the screen
        DEC     ,S              ; Decrement the number of rows to put
        BEQ     >               ; If all rows are copied then go skip ahead
        LDB     #31             ; B = 31, the number of bytes to copy per row
        ABX                     ; X = X + B (move to the start of the next row)
        BRA     PutDoRowNOT2        ; Loop until all rows are copied
; Bytes have been copied to the screen
!       PULS    D,PC            ; Fix the stack and return

PutDoRowNOT3Init:
        LDA     ,S              ; A = the number of rows to put
        EXG     A,B
        STD     ,S              ; Swap them to make it a little faster below
PutDoRowNOT3:
        LDB     ,S              ; B = the number of bytes to put per row
;handle the first column
        LDA     ,X              ; Get value from the screen
        COMA                    ; flip the bits
PutNOTFirst3NOT0:
        ANDA    #%11111000      ; Keep the inside bits (already complimented value) (Self modified above)
        PSHS    A               ; Save the value on the stack
        LDA     ,X              ; Get the value from the graphics byte on the screen
PutNOTFirst3NOT1:
        ANDA    #%11100000      ; Keep only the bits to the left (Self modified above)
        ORA     ,S+             ; OR the masked value from the screen with the value of inverted buffer, fix stack
        STA     ,X+             ; Store the value of the graphics byte to the screen
        SUBB    #2              ; Check if there are 2 bytes to put per row
;copy the inner columns as they are
!       COM     ,X+             ; Store the value of the graphics byte to the screen
        DECB                    ; Decrement the number of bytes to put per row
        BNE     <               ; Loop until all bytes are copied
; handle the last column
        LDA     ,X              ; Get value from the screen
        COMA                    ; flip the bits
PutNOTLast3NOT0:
        ANDA    #%11111000      ; Keep the inside bits (already complimented value) (Self modified above)
        PSHS    A               ; Save the value on the stack
        LDA     ,X              ; Get the value from the graphics byte on the screen
PutNOTLast3NOT1:
        ANDA    #%11100000      ; Keep only the bits to the left (Self modified above)
        ORA     ,S+             ; OR the masked value from the screen with the value of inverted buffer, fix stack
        STA     ,X              ; Store the value of the graphics byte to the screen
        DEC     1,S             ; Decrement the number of rows to put
        BEQ     >               ; If all rows are copied then go skip ahead
;        LDB     ,Y              ; B = the number of bytes stored per row
;        SUBB    ,S              ; B = B - the number of bytes needed to copy per row
;        LEAU    B,U             ; U = U + B
        LDB     #33
        SUBB    ,S              ; B = 33 - the number of bytes to copy per row
        ABX                     ; X = X + B (move to the start of the next row)
        BRA     PutDoRowNOT3       ; Loop until all rows are copied
; Bytes have been copied to the screen
!       PULS    D,PC            ; Fix the stack and return
