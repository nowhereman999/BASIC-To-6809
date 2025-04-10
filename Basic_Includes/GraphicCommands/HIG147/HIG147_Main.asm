; Graphics commands for screen mode HIG147
; Resolution of 320x225x16 colours
ScreenWidth_HIG147    EQU 320
ScreenHeight_HIG147   EQU 225
BytesPerRow_HIG147    EQU ScreenWidth_HIG147/2
Screen_Size_HIG147    EQU $8CA0
;
; Enter with:
; A = y coordinate
; X = x coordinate
;
; Make sure the values of y is between 0 and 191 or bad things will happen
;
; x location is 0 to 319 (160 bytes) per row
; y location is 0 to 224 (225 rows)
;
; 160 bytes per row
; y * 160 + x
; A=y value, X=x value
; Line colour will have it's colour in the high nibble and the low nibble at this point
SET_HIG147:
DoSet_HIG147:
        PSHS    X               ; Save x coordinate on the stack
        LDB     #BytesPerRow_HIG147 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        EXG     D,X             ; X has the row to start on, D now has the x co-ordinate
        LSRA
        RORB                    ; B = D/2
        ABX                     ; X now has the value of Y * 160 + X/2 (we now have our screen location)
        LDB     1,S
        ANDB    #%00000001
        BNE     SetOddPixel_HIG147 ; Go colour the Odd Pixel
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
SetOddPixel_HIG147:
        LDA     #%11110000
        ANDA    ,X              ; Get the even pixel value on screen
        STA     ,X              ; Save only the even pixel on screen
        LDA     LineColour      ; Get the colour we want to set the pixel too
        ANDA    #%00001111      ; Save the odd pixel
        ORA     ,X              ; Combine the pixels
        STA     ,X              ; Write new byte to the screen
        PULS    X,PC            ; Restore D,X & U and return

BoxSet_HIG147:
        PSHS    A,X             ; Save y & x coordinate on the stack
        LDB     #BytesPerRow_HIG147 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        EXG     D,X             ; X has the row to start on, D now has the x co-ordinate
        LSRA
        RORB                    ; B = D/2
        ABX                     ; X now has the value of Y * 160 + X/2 (we now have our screen location)
        LDB     2,S
        ANDB    #%00000001
        BNE     BoxSetOdd_HIG147 ; Go colour the Odd Pixel
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
BoxSetOdd_HIG147:
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
POINT_HIG147:
        PSHS    X               ; Save x coordinate on the stack
        LDB     #BytesPerRow_HIG147 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        EXG     D,X             ; X has the row to start on, D now has the x co-ordinate
        LSRA
        RORB                    ; B = D/2
        ABX                     ; X now has the value of y * 160 + x/2 (we now have our screen location)
        LDB     ,X
        LDA     1,S             ; Get the value Check if it's even or odd, fix the stack
        ANDA    #%00000001
        BNE     GetOddPixel_HIG147 ; Go get the colour the Odd Pixel
; Get the even pixel
        LSRB
        LSRB
        LSRB
        LSRB                    ; Got the value in B
        PULS    X,PC            ; restore X & return
GetOddPixel_HIG147:
        ANDB    #%00001111      ; Got the value in B
        PULS    X,PC            ; restore X & return

; Colour the screen Colour B
GCLS_HIG147:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG147,X ; Screen Size
        STU     GCLSComp_HIG147+1 ; Self mod end address
        ANDB    #%00001111      ; Keep the right nibble value
        PSHS    B               ; Save it on the stack
        LSLB
        LSLB
        LSLB
        LSLB                    ; Move the bits left, now they are in the high nibble
        ORB     ,S+             ; B now has the value in the high nibble and the low nibble
@GotB   TFR     B,A             ; A = B
!       STD     ,X++
GCLSComp_HIG147:
        CMPX    #$FFFF          ; Self modded end address
        BNE     <
        RTS

