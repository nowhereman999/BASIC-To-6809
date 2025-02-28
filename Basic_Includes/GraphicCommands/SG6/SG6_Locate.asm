LOCATE_SG6:
* Make sure x and y values are not beyond the screen
        LDD     x0              ; Get the x value in D
        LSLB                    ; Multiply by 2
        ADDB    x0+1            ; B=B*3 (3 bytes per character)
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #27 ; Check if it's beyond the right side of the screen
        BLE     >               ; Skip ahead if good
        LDD     #27             ; Make it the right most column
!       STD     x0              ; Save the x value

        LDD     y0              ; Get the y value in D
;        LSLB                    ; Multiply by 2 (2 rows per character)
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #12             ; Check if it's beyond the bottom of the screen
        BLE     >               ; Skip ahead if good
        LDD     #12             ; Make it the bottom row

!       LDA     #BytesPerRow_SG6 ; A= bytes per row
        MUL                     ; D = bytes per row * B, D now has the correct row to start at
        LDX     BEGGRP          ; X now has the screen start location
        LEAX    D,X             ; X = X + D, X now has the correct row to start at
        LDB     x0+1            ; Get the x value in B
        ABX                     ; X now has the correct screen position to start at
        STX     GraphicCURPOS   ; Update the location of the cursor
        RTS                     ; Return to the calling routine
