LOCATE_SG24:
* Make sure x and y values are not beyond the screen
        LDD     x0              ; Get the x value in D
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #BytesPerRow_SG24-1 ; Check if it's beyond the right side of the screen
        BLE     >               ; Skip ahead if good
        LDD     #BytesPerRow_SG24-1 ; Make it the right most column
!       STD     x0              ; Save the x value

        LDD     y0              ; Get the y value in D
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #ScreenHeight_SG24/2-FontHeight          ; Check if it's beyond the bottom of the screen
        BLE     >               ; Skip ahead if good
        LDD     #ScreenHeight_SG24/2-FontHeight          ; Make it the bottom row

!       LSLB                    ; Multiply by 2
        LSLB                    ; Multiply by 4
        PSHS    B               ; Save the y value on the stack
        LSLB                    ; Multiply by 8
        ADDB    ,S+             ; Multiply by 12
        LDA     #BytesPerRow_SG24 ; A= bytes per row
        MUL                     ; D = bytes per row * B, D now has the correct row to start at
        LDX     BEGGRP          ; X now has the screen start location
        LEAX    D,X             ; X = X + D, X now has the correct row to start at
        LDB     x0+1            ; Get the x value in B
        ABX                     ; X now has the correct screen position to start at
        STX     GraphicCURPOS   ; Update the location of the cursor
        RTS                     ; Return to the calling routine
