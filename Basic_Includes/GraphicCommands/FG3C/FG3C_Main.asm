; Graphics commands for screen mode FG3C
; Resolution of 128x96x4 colours
ScreenWidth_FG3C    EQU 128
ScreenHeight_FG3C   EQU 96
BytesPerRow_FG3C    EQU ScreenWidth_FG3C/4
Screen_Size_FG3C    EQU $0C00
;
; Enter with:
; A = y coordinate
; B = x coordinate
;
SET_FG3C:
DoSet_FG3C:
        PSHS    D               ; Save x & y coordinate on the stack
        ANDB    #%01111111      ; Make sure it's 127 or less
        LSRA
        BCC     >
        ORB     #%10000000
!       LSRA
        RORB
        LSRA
        RORB                    ; Shift A right 3 times & B right 2 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,U             ; U now has the location of the pixel to draw
        LDB     1,S             ; B = the pixel number
        ANDB    #%00000011      ; B = Pixel value (0 to 3)
        LDA     ,U              ; Get existing pixels in this byte from the screen
        LDX     #PixelTable0_FG3C ; U points to the table of pixels to erase
        ANDA    B,X             ; Clear out the our pixel
        LDX     #PixelTable1_FG3C ; U points to the table of pixel values
        LSLB
        LSLB                    ; X = pixel number * 4
        ABX                     ; Move X in the table
        LDB     LineColour      ; B = colour value of 0,1,2 or 3 
        ORA     B,X             ; Or original Byte value with the pixel the user wants to set
        STA     ,U              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return

PixelTable0_FG3C:
        FCB     %00111111 Pixel 0
        FCB     %11001111 Pixel 1
        FCB     %11110011 Pixel 2
        FCB     %11111100 Pixel 3
PixelTable1_FG3C:
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
POINT_FG3C:
        PSHS    B               ; Save x value
        ANDB    #%01111111      ; Make sure it's 127 or less
        LSRA
        BCC     >
        ORB     #%10000000
!       LSRA
        RORB
        LSRA
        RORB                    ; Shift A right 3 times & B right 2 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,U             ; U now has the location of the pixel to draw
        LDA     ,S+             ; A = the pixel number
        ANDA    #%00000011      ; A = Pixel value (0 to 3)
        LDX     #PixelTableClear_FG3C ; X points to the table of pixel values
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

PixelTableClear_FG3C:
        FCB     %11000000
        FCB     %00110000
        FCB     %00001100
        FCB     %00000011

; Colour the screen Colour B
; B = 0,1,2 or 3
GCLS_FG3C:
        LDX     BEGGRP
        LEAU    Screen_Size_FG3C,X ; Screen Size
        STU     GCLSComp_FG3C+1 ; Self mod end address
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
GCLSComp_FG3C:
        CMPX    #$FFFF          ; Self modded end address
        BNE     <
        RTS
