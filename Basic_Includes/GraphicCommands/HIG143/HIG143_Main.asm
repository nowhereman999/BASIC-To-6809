; Graphics commands for screen mode HIG143
; Resolution of 320x200x4 colours
ScreenWidth_HIG143    EQU 320
ScreenHeight_HIG143   EQU 200
BytesPerRow_HIG143    EQU ScreenWidth_HIG143/4
Screen_Size_HIG143    EQU $3E80
;
; Enter with:
; A = y coordinate
; X = x coordinate
;
; Make sure the values of y is between 0 and 191 or bad things will happen
;
; x location is 0 to 159 (80 bytes) per row
; y location is 0 to 199 (200 rows)
;
;
;80 bytes per row
; y * 80 + x
; A=y value, X=x value
; Line colour will have it's colour in the high nibble and the low nibble at this point
SET_HIG143:
DoSet_HIG143:
        PSHS    A,X             ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_HIG143 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        EXG     D,U             ; X has the row to start on
        LDD     1,S             ; Get the x co-ordinate
        LSRA
        RORB
        LSRB                    ; B = D/4 
        LEAU    D,U             ; U now has the value of y * 80 + x/4 (we now have our screen location)
        LDB     2,S             ; B = the pixel number
        ANDB    #%00000011      ; B = Pixel value (0 to 3)
        LDA     ,U              ; Get existing pixels in this byte from the screen
        LDX     #PixelTable0_HIG143 ; U points to the table of pixels to erase
        ANDA    B,X             ; Clear out the our pixel
        LDX     #PixelTable1_HIG143 ; U points to the table of pixel values
        LSLB
        LSLB                    ; X = pixel number * 4
        ABX                     ; Move X in the table
        LDB     LineColour      ; B = colour value of 0,1,2 or 3 
        ORA     B,X             ; Or original Byte value with the pixel the user wants to set
        STA     ,U              ; Write new byte to the screen
        PULS    A,X,PC            ; Restore D,X & U and return

PixelTable0_HIG143:
        FCB     %00111111 Pixel 0
        FCB     %11001111 Pixel 1
        FCB     %11110011 Pixel 2
        FCB     %11111100 Pixel 3
PixelTable1_HIG143:
        FCB     %00000000 Pixel 0, Colour 0
        FCB     %01000000 Pixel 0, Colour 1
        FCB     %10000000 Pixel 0, Colour 2
        FCB     %11000000 Pixel 0, Colour 3
        FCB     %00000000 Pixel 1, Colour 0
        FCB     %00010000 Pixel 1, Colour 1
        FCB     %00100000 Pixel 1, Colour 2
        FCB     %00110000 Pixel 1, Colour 3
        FCB     %00000000 Pixel 2, Colour 0
        FCB     %00000100 Pixel 2, Colour 1
        FCB     %00001000 Pixel 2, Colour 2
        FCB     %00001100 Pixel 2, Colour 3
        FCB     %00000000 Pixel 3, Colour 0
        FCB     %00000001 Pixel 3, Colour 1
        FCB     %00000010 Pixel 3, Colour 2
        FCB     %00000011 Pixel 3, Colour 3

; POINT get the value of a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
; Returns with:
; B = Colour value of the point
POINT_HIG143:
        PSHS    X               ; Save x coordinate on the stack
        LDB     #BytesPerRow_HIG143 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        EXG     D,X             ; X has the row to start on, D now has the x co-ordinate
        LSRA
        RORB
        LSRB                    ; B=D/4
        ABX                     ; X now has the value of Y = Y * 80 + X/4 (we now have our screen location)
        LDA     1,S             ; A = the pixel number
        ANDA    #%00000011      ; A = Pixel value (0 to 3)
        LDU     #PixelTableClear_HIG143 ; U points to the table of pixel values
        LDB     ,X              ; Get existing pixels in this byte from the screen
        ANDB    A,U             ; AND original Byte value with the pixel the user wants to get the value of
        BEQ     @GotB
        BITB    #%01010101
        BEQ     @Bis2
        BITB    #%10101010
        BEQ     @Bis1
        LDB     #3
        BRA     @GotB
@Bis1   LDB     #1
        BRA     @GotB
@Bis2   LDB     #2
@GotB   PULS    X,PC             ; Restore X & return

PixelTableClear_HIG143:
        FCB     %11000000
        FCB     %00110000
        FCB     %00001100
        FCB     %00000011

; Colour the screen Colour B
; B = 0,1,2 or 3
GCLS_HIG143:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG143,X ; Screen Size
        STU     GCLSComp_HIG143+1 ; Self mod end address
        ANDB    #%00000011
        BEQ     @GotB
        DECB
        BNE     >
        LDB     #%01010101      ; 1
        BRA     @GotB
!       DECB
        BNE     >
        LDB     #%10101010      ; 2
        BRA     @GotB
!       LDB     #%11111111
@GotB   TFR     B,A             ; A = B
!       STD     ,X++
GCLSComp_HIG143:
        CMPX    #$FFFF          ; Self modded end address
        BNE     <
        RTS
