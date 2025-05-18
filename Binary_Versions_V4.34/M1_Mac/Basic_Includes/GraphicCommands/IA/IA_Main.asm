* Set the width and height of the IA screen
ScreenWidth_IA     EQU 32
ScreenHeight_IA    EQU 16
BytesPerRow_IA     EQU ScreenWidth_IA
Screen_Size_IA     EQU $200
;
; Do the Set function
;
; Enter with:
; A = y coordinate
; B = x coordinate
; LineColour = the colour to set the pixel
; Semi graphic 4 Pixel location in a screen byte
; -----
; |8|4|
; -----
; |2|1|
; -----
; 
SET_IA:
DoSet_IA:
        PSHS    D               ; Save x & y coordinate on the stack
        LDB     #ScreenWidth_IA ; B = the width of the screen
        MUL                     ; D = A * B
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the row of the pixel to draw
        LDB     1,S             ; B = x coordinate
        ABX                     ; X now has the pixel to draw

        LDA     LineColour      ; A = colour value of 0 to 8
        LDU     #IA_ColourTable ; U points at the colour table
        LDA     A,U             ; A = colour value of 0 to 8
        STA     ,X              ; DISPLAY IT ON THE SCREEN
        PULS    D,PC            ; restore x & y coordinate and return

; Do the Point function
; Enter with:
; A = y coordinate
; B = x coordinate
; Exit with B = the pixel colour, or -1 if a text character
POINT_IA:
        PSHS    B               ; Save x coordinate on the stack
        LDB     #ScreenWidth_IA ; B = the width of the screen
        MUL                     ; D = A * B
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the row of the pixel to draw
        LDB     ,S+             ; B = x coordinate, fix the stack
        ABX                     ; X now has the pixel to draw
        LDB     ,X              ; B = value of the character
        CMPB    #$7F            ; Is it a text character?
        BLS     >               ; If it's a text character then return -1
        CMPB    #$80            ; $80 = 0
        BNE     @NotZero       ; If it's not zero then it's a pixel
        CLRB
        RTS
@NotZero:
        LSRB                    ; B = B / 2
        LSRB                    ; B = B / 4
        LSRB                    ; B = B / 8
        LSRB                    ; B = B / 16 - B is now 8 to 15
        SUBB    #$07            ; B = B - 7
        RTS
!       LDB     #-1             ; B = -1
        RTS

; Colour the screen Colour B
GCLS_IA:
        LDX     #IA_ColourTable
        LDA     B,X
        LDB     B,X
        LDX     BEGGRP
        LEAU    Screen_Size_IA,X ; Screen Size
        STU     GCLSComp_IA+1 ; Self mod end address
!       STD     ,X++
GCLSComp_IA:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS
IA_ColourTable:
        FCB     $80     ; 0
        FCB     $8F     ; 1
        FCB     $9F     ; 2
        FCB     $AF     ; 3
        FCB     $BF     ; 4
        FCB     $CF     ; 5
        FCB     $DF     ; 6
        FCB     $EF     ; 7
        FCB     $FF     ; 8
