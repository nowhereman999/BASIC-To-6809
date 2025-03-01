* Set the width and height of the EA screen
ScreenWidth_EA     EQU 32
ScreenHeight_EA    EQU 16
BytesPerRow_EA     EQU ScreenWidth_EA
Screen_Size_EA     EQU $200
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
SET_EA:
DoSet_EA:
        PSHS    D               ; Save x & y coordinate on the stack
        LDB     #ScreenWidth_EA ; B = the width of the screen
        MUL                     ; D = A * B
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the row of the pixel to draw
        LDB     1,S             ; B = x coordinate
        ABX                     ; X now has the pixel to draw

        LDA     LineColour      ; A = colour value of 0 to 8
        LDU     #EA_ColourTable ; U points at the colour table
        LDA     A,U             ; A = colour value of 0 to 8
        STA     ,X              ; DISPLAY IT ON THE SCREEN
        PULS    D,PC            ; restore x & y coordinate and return

; Do the Point function
; Enter with:
; A = y coordinate
; B = x coordinate
; Exit with B = the pixel colour, or -1 if a text character
POINT_EA:
        PSHS    B               ; Save x coordinate on the stack
        LDB     #ScreenWidth_EA ; B = the width of the screen
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
GCLS_EA:
        LDX     #EA_ColourTable
        LDA     B,X
        LDB     B,X
        LDX     BEGGRP
        LEAU    Screen_Size_EA,X ; Screen Size
        STU     GCLSComp_EA+1 ; Self mod end address
!       STD     ,X++
GCLSComp_EA:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS
EA_ColourTable:
        FCB     $80     ; 0
        FCB     $BF     ; 1
        FCB     $BF     ; 2
        FCB     $BF     ; 3
        FCB     $BF     ; 4
        FCB     $FF     ; 5
        FCB     $FF     ; 6
        FCB     $FF     ; 7
        FCB     $FF     ; 8
