; Graphics commands for screen mode HIG110
; Resolution of 80x200x16 colours
ScreenWidth_HIG110    EQU 80
ScreenHeight_HIG110   EQU 200
BytesPerRow_HIG110    EQU ScreenWidth_HIG110/2
Screen_Size_HIG110    EQU $1F40
;
; Do SET
; Enter with:
; A = y coordinate, B = x coordinate
;
SET_HIG110:
DoSet_HIG110:
        PSHS    D               ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_HIG110 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDB     1,S
        LSRB
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        LDB     1,S
        ANDB    #%00000001
        BNE     SetOddPixel_HIG110 ; Go colour the Odd Pixel
; Set the even pixel
        LDA     #%00001111
        ANDA    ,X              ; Get the odd pixel value on screen
        STA     ,X              ; Save only the odd pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%11110000      ; Save the even pixel
        ORA     ,X
        STA     ,X              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return
; Set the odd pixel
SetOddPixel_HIG110:
        LDA     #%11110000
        ANDA    ,X              ; Get the even pixel value on screen
        STA     ,X              ; Save only the even pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%00001111      ; Save the odd pixel
        ORA     ,X              ; Combine the pixels
        STA     ,X              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return

; POINT get the value of a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
; Returns with:
; B = Colour value of the point
POINT_HIG110:
        PSHS    B               ; Save x coordinate on the stack
        LSRB
        PSHS    B
        LDB     #BytesPerRow_HIG110 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        ADDB    ,S+
        ADCA    #0              ; D now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        STD     Point1_HIG110+1   ; Self mod location below
Point1_HIG110:
        LDB     >$FFFF          ; B = The colour of the Even and Odd pixel
        LDA     ,S+             ; Get the value Check if it's even or odd, fix the stack
        ANDA    #%00000001
        BNE     GetOddPixel_HIG110 ; Go get the colour the Odd Pixel
; Get the even pixel
        LSRB
        LSRB
        LSRB
        LSRB                    ; Got the value in B
        RTS                     ; return
GetOddPixel_HIG110:
        ANDB    #%00001111      ; Got the value in B
        RTS                     ; return

; Colour the screen Colour B
GCLS_HIG110:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG110,X ; Screen Size
        STU     GCLSComp_HIG110+1 ; Self mod end address
        ANDB    #%00001111
        PSHS    B  
        LSLB
        LSLB
        LSLB
        LSLB
        ORB     ,S+
        TFR     B,A             ; A = B
!       STD     ,X++
GCLSComp_HIG110:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS