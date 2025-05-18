; Graphics commands for screen mode HIG134
; Resolution of 256x200x4 colours
ScreenWidth_HIG134    EQU 256
ScreenHeight_HIG134   EQU 200
BytesPerRow_HIG134    EQU ScreenWidth_HIG134/4
Screen_Size_HIG134    EQU $3200
;
; Enter with:
; A = y coordinate
; B = x coordinate
;
; Make sure the values of y is between 0 and 191 or bad things will happen
;
; x location is 0 to 159 (64 bytes) per row
; y location is 0 to 191 (192 rows)
;
; A=Y value, B=X value
;
; Byte to draw pixel on screen
; = 1111 11xx = 31 is the byte
; = xxxx xx11 = pixel value
;
;     A       B
; 10101010 x1010101
;
; A needs to be shifted 3 times
; 00010101 010xxxxx
; B needs to be shifted 2 times
; xxxxxxxx xxx10101
;
; 64 bytes per row
; y * 64 + x
; A=y value, B=x value
; Line colour will have it's colour in the high nibble and the low nibble at this point
SET_HIG134:
DoSet_HIG134:
        PSHS    D               ; Save x & y coordinate on the stack
        LSRB
        LSRB
        PSHS    B  
        LDB     #BytesPerRow_HIG134 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        ADDB    ,S+
        ADCA    #0              ; add the carry
        TFR     D,U             ; U now has the location of the pixel to draw
        LDB     1,S             ; B = the pixel number
        ANDB    #%00000011      ; B = Pixel value (0 to 3)
        LDA     ,U              ; Get existing pixels in this byte from the screen
        LDX     #PixelTable0_HIG134 ; U points to the table of pixels to erase
        ANDA    B,X             ; Clear out the our pixel
        LDX     #PixelTable1_HIG134 ; U points to the table of pixel values
        LSLB
        LSLB                    ; X = pixel number * 4
        ABX                     ; Move X in the table
        LDB     LineColour      ; B = colour value of 0,1,2 or 3 
        ORA     B,X             ; Or original Byte value with the pixel the user wants to set
        STA     ,U              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return

PixelTable0_HIG134:
        FCB     %00111111 Pixel 0
        FCB     %11001111 Pixel 1
        FCB     %11110011 Pixel 2
        FCB     %11111100 Pixel 3
PixelTable1_HIG134:
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
* PMODE 4 POINT command
POINT_HIG134:
        PSHS    B               ; Save x coordinate on the stack
        LSRB
        LSRB
        PSHS    B  
        LDB     #BytesPerRow_HIG134 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        ADDB    ,S+
        ADCA    #0              ; add the carry
        TFR     D,U             ; U now has the location of the pixel to draw

        LDA     ,S+             ; A = the pixel number
        ANDA    #%00000011      ; A = Pixel value (0 to 3)
        LDX     #PixelTableClear_HIG134 ; X points to the table of pixel values
        LDB     ,U              ; Get existing pixels in this byte from the screen
        ANDB    A,X             ; AND original Byte value with the pixel the user wants to get the value of
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
@GotB   RTS                    ; Restore A,X & U and return

PixelTableClear_HIG134:
        FCB     %11000000
        FCB     %00110000
        FCB     %00001100
        FCB     %00000011

; Colour the screen Colour B
; B = 0,1,2 or 3
GCLS_HIG134:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG134,X ; Screen Size
        STU     GCLSComp_HIG134+1 ; Self mod end address
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
GCLSComp_HIG134:
        CMPX    #$FFFF          ; Self modded end address
        BNE     <
        RTS

