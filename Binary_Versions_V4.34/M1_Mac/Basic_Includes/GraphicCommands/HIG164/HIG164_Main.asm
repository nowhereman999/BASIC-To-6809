; Graphics commands for screen mode HIG164
; Resolution of 640x225x4 colours
ScreenWidth_HIG164    EQU 160
ScreenHeight_HIG164   EQU 225
BytesPerRow_HIG164    EQU ScreenWidth_HIG164
Screen_Size_HIG164    EQU $8CA0

;
; A=y value, B=x value
DoSet_HIG164:
SET_HIG164:
        PSHS    D
        STB     @Addx+2         ; Save the x co-ordinate (self mod below)
        LDB     #BytesPerRow_HIG164
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
POINT_HIG164:
        STB     @Addx+2         ; Save the x co-ordinate (self mod below)
        LDB     #BytesPerRow_HIG164
        MUL
@Addx
        ADDD    #$00FF          ; (Self mod above) add in the x co-ordinate
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X points at the screen location for this pixel
        LDB     ,X              ; Get the pixel colour
        RTS

; Colour the screen Colour B
GCLS_HIG164:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG164,X ; Screen Size
        STU     GCLSComp_HIG164+1 ; Self mod end address
        TFR     B,A     ; A = B
!       STD     ,X++
GCLSComp_HIG164:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS