 IFNDEF LOCATE_FG6R_DEFINED
LOCATE_FG6R_DEFINED EQU 1
LOCATE_FG6R:
* Update the 42 column PRINT #-4 cursor.  X is a character column
* from 0 to 41, and Y is a character row from 0 to 23.
        LDD     x0              ; Get the x value in D
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #41             ; Check if it's beyond the right side
        BLE     >               ; Skip ahead if good
        LDD     #41             ; Make it the right most 6 bit column
!       PSHS    D               ; Save the 42 column x cell

        LDD     y0              ; Get the y value in D
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #23             ; Check if it's beyond the bottom row
        BLE     >               ; Skip ahead if good
        LDD     #23             ; Make it the bottom 6 bit row
!       LDA     #42             ; A = 42 columns per row
        MUL                     ; D = 42 * B
        ADDD    ,S++            ; Add the x cell and fix the stack
        STD     GraphicCURPOS6  ; Update the 42 column graphics cursor

* Make sure x and y values are not beyond the screen
        LDD     x0              ; Get the x value in D
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #BytesPerRow_FG6R-1 ; Check if it's beyond the right side of the screen
        BLE     >               ; Skip ahead if good
        LDD     #BytesPerRow_FG6R-1 ; Make it the right most column
!       STD     x0              ; Save the x value

        LDD     y0              ; Get the y value in D
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #ScreenHeight_FG6R-FontHeight          ; Check if it's beyond the bottom of the screen
        BLE     >               ; Skip ahead if good
        LDD     #ScreenHeight_FG6R-FontHeight          ; Make it the bottom row

!       LDA     #BytesPerRow_FG6R ; A= bytes per row
        MUL                     ; D = bytes per row * B, D now has the correct row to start at
        LDX     BEGGRP          ; X now has the screen start location
        LEAX    D,X             ; X = X + D, X now has the correct row to start at
        LDB     x0+1            ; Get the x value in B
        ABX                     ; X now has the correct screen position to start at
        STX     GraphicCURPOS   ; Update the location of the cursor
        RTS                     ; Return to the calling routine
 ENDIF
