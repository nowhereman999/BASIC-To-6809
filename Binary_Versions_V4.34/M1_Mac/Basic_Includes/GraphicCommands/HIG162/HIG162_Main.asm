; Graphics commands for screen mode HIG162
; Resolution of 640x225x4 colours
ScreenWidth_HIG162    EQU 128
ScreenHeight_HIG162   EQU 225
BytesPerRow_HIG162    EQU ScreenWidth_HIG162
Screen_Size_HIG162    EQU $8CA0

;
; A=y value, B=x value
DoSet_HIG162:
SET_HIG162:
        PSHS    D
        STB     @Addx+2         ; Save the x co-ordinate (self mod below)
        LDB     #BytesPerRow_HIG162
        MUL
@Addx
        ADDD    #$00FF          ; (Self mod above) add in the x co-ordinate
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X points at the screen location for this pixel
        LDA     LineColour      ; Get the colour of the pixel
        STA     ,X
        PULS    D,PC

; POINT get the value of a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
; Returns with:
; B = Colour value of the point
POINT_HIG162:
        STB     @Addx+2         ; Save the x co-ordinate (self mod below)
        LDB     #BytesPerRow_HIG162
        MUL
@Addx
        ADDD    #$00FF          ; (Self mod above) add in the x co-ordinate
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X points at the screen location for this pixel
        LDB     ,X              ; Get the pixel colour
        RTS

; Colour the screen Colour B
GCLS_HIG162:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG162,X ; Screen Size
        STU     GCLSComp_HIG162+1 ; Self mod end address
        TFR     B,A     ; A = B
!       STD     ,X++
GCLSComp_HIG162:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS