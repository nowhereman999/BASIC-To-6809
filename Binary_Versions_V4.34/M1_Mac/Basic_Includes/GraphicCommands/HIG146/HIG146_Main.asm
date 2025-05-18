; Graphics commands for screen mode HIG146
; Resolution of 320x200x16 colours
ScreenWidth_HIG146    EQU 320
ScreenHeight_HIG146   EQU 200
BytesPerRow_HIG146    EQU ScreenWidth_HIG146/2
Screen_Size_HIG146    EQU $7D00
;
; Enter with:
; A = y coordinate
; X = x coordinate
;
; Make sure the values of y is between 0 and 191 or bad things will happen
;
; x location is 0 to 319 (160 bytes) per row
; y location is 0 to 199 (200 rows)
;
; 160 bytes per row
; y * 160 + x
; A=y value, X=x value
; Line colour will have it's colour in the high nibble and the low nibble at this point
SET_HIG146:
DoSet_HIG146:
        PSHS    X               ; Save x coordinate on the stack
        LDB     #BytesPerRow_HIG146 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        EXG     D,X             ; X has the row to start on, D now has the x co-ordinate
        LSRA
        RORB                    ; B = D/2
        ABX                     ; X now has the value of Y * 160 + X/2 (we now have our screen location)
        LDB     1,S
        ANDB    #%00000001
        BNE     SetOddPixel_HIG146 ; Go colour the Odd Pixel
; Set the even pixel
        LDA     #%00001111
        ANDA    ,X              ; Get the odd pixel value on screen
        STA     ,X              ; Save only the odd pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%11110000      ; Save the even pixel
        ORA     ,X
        STA     ,X              ; Write new byte to the screen
        PULS    X,PC            ; Restore D,X & U and return
; Set the odd pixel
SetOddPixel_HIG146:
        LDA     #%11110000
        ANDA    ,X              ; Get the even pixel value on screen
        STA     ,X              ; Save only the even pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%00001111      ; Save the odd pixel
        ORA     ,X              ; Combine the pixels
        STA     ,X              ; Write new byte to the screen
        PULS    X,PC            ; Restore D,X & U and return

BoxSet_HIG146:
        PSHS    A,X             ; Save y & x coordinate on the stack
        LDB     #BytesPerRow_HIG146 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        EXG     D,X             ; X has the row to start on, D now has the x co-ordinate
        LSRA
        RORB                    ; B = D/2
        ABX                     ; X now has the value of Y * 160 + X/2 (we now have our screen location)
        LDB     2,S
        ANDB    #%00000001
        BNE     BoxSetOdd_HIG146 ; Go colour the Odd Pixel
; Set the even pixel
        LDA     #%00001111
        ANDA    ,X              ; Get the odd pixel value on screen
        STA     ,X              ; Save only the odd pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%11110000      ; Save the even pixel
        ORA     ,X
        STA     ,X              ; Write new byte to the screen
        PULS    A,X,PC          ; Restore A,X and return
; Set the odd pixel
BoxSetOdd_HIG146:
        LDA     #%11110000
        ANDA    ,X              ; Get the even pixel value on screen
        STA     ,X              ; Save only the even pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%00001111      ; Save the odd pixel
        ORA     ,X              ; Combine the pixels
        STA     ,X              ; Write new byte to the screen
        PULS    A,X,PC          ; Restore A,X and return

; POINT get the value of a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
; Returns with:
; B = Colour value of the point
POINT_HIG146:
        PSHS    X               ; Save x coordinate on the stack
        LDB     #BytesPerRow_HIG146 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        EXG     D,X             ; X has the row to start on, D now has the x co-ordinate
        LSRA
        RORB                    ; B = D/2
        ABX                     ; X now has the value of y * 160 + x/2 (we now have our screen location)
        LDB     ,X
        LDA     1,S             ; Get the value Check if it's even or odd, fix the stack
        ANDA    #%00000001
        BNE     GetOddPixel_HIG146 ; Go get the colour the Odd Pixel
; Get the even pixel
        LSRB
        LSRB
        LSRB
        LSRB                    ; Got the value in B
        PULS    X,PC            ; restore X & return
GetOddPixel_HIG146:
        ANDB    #%00001111      ; Got the value in B
        PULS    X,PC            ; restore X & return

; Colour the screen Colour B
GCLS_HIG146:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG146,X ; Screen Size
        STU     GCLSComp_HIG146+1 ; Self mod end address
        ANDB    #%00001111      ; Keep the right nibble value
        PSHS    B               ; Save it on the stack
        LSLB
        LSLB
        LSLB
        LSLB                    ; Move the bits left, now they are in the high nibble
        ORB     ,S+             ; B now has the value in the high nibble and the low nibble
@GotB   TFR     B,A             ; A = B
!       STD     ,X++
GCLSComp_HIG146:
        CMPX    #$FFFF          ; Self modded end address
        BNE     <
        RTS

