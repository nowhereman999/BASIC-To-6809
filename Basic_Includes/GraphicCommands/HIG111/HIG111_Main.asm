; Graphics commands for screen mode HIG111
; Resolution of 80x225x16 colours
ScreenWidth_HIG111    EQU 80
ScreenHeight_HIG111   EQU 225
BytesPerRow_HIG111    EQU ScreenWidth_HIG111/2
Screen_Size_HIG111    EQU $2328
;
; Do SET
; Enter with:
; A = y coordinate, B = x coordinate
;
SET_HIG111:
DoSet_HIG111:
        PSHS    D               ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_HIG111 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDB     1,S
        LSRB
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        LDB     1,S
        ANDB    #%00000001
        BNE     SetOddPixel_HIG111 ; Go colour the Odd Pixel
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
SetOddPixel_HIG111:
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
POINT_HIG111:
        PSHS    B               ; Save x coordinate on the stack
        LSRB
        PSHS    B
        LDB     #BytesPerRow_HIG111 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        ADDB    ,S+
        ADCA    #0              ; D now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        STD     Point1_HIG111+1   ; Self mod location below
Point1_HIG111:
        LDB     >$FFFF          ; B = The colour of the Even and Odd pixel
        LDA     ,S+             ; Get the value Check if it's even or odd, fix the stack
        ANDA    #%00000001
        BNE     GetOddPixel_HIG111 ; Go get the colour the Odd Pixel
; Get the even pixel
        LSRB
        LSRB
        LSRB
        LSRB                    ; Got the value in B
        RTS                     ; return
GetOddPixel_HIG111:
        ANDB    #%00001111      ; Got the value in B
        RTS                     ; return

; Colour the screen Colour B
GCLS_HIG111:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG111,X ; Screen Size
        STU     GCLSComp_HIG111+1 ; Self mod end address
        ANDB    #%00001111
        PSHS    B  
        LSLB
        LSLB
        LSLB
        LSLB
        ORB     ,S+
        TFR     B,A             ; A = B
!       STD     ,X++
GCLSComp_HIG111:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS