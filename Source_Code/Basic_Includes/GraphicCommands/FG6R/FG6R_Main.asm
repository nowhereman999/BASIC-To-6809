; Graphics commands for screen mode FG6R
; Resolution of 256x192x2 colours
ScreenWidth_FG6R    EQU 256
ScreenHeight_FG6R   EQU 192
BytesPerRow_FG6R    EQU ScreenWidth_FG6R/8
Screen_Size_FG6R    EQU $1800
;
; SET a dot on screen
; A=y value, B=x value
DoSet_FG6R:
        TST     LineColour      ; Get the Set colour
        BEQ     RESET_FG6R      ; If it's not zero then draw white dot
SET_FG6R:
        PSHS    D               ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_FG6R ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDB     1,S
        LSRB
        LSRB
        LSRB                    ; B=B/8
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)

        LDB     1,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTable_FG6R ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ORA     B,U             ; Or original Byte value with the pixel the user wants to set
        STA     ,X              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return

PixelTable_FG6R:
        FCB     %10000000 Pixel 0
        FCB     %01000000 Pixel 1
        FCB     %00100000 Pixel 2
        FCB     %00010000 Pixel 3
        FCB     %00001000 Pixel 4
        FCB     %00000100 Pixel 5
        FCB     %00000010 Pixel 6
        FCB     %00000001 Pixel 7

; PRESET a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
;
; Make sure values of y are between 0 and 191 or bad things will happen
;
; x location is 0 to 159 (20 bytes) per row
; y location is 0 to 191 (192 rows)
;
; A=Y value, B=X value
;
; Byte to draw pixel on screen
; = 1111 1xxx = 31 is the byte
; = xxxx x111 = pixel value
;
; A=y value, B=x value
RESET_FG6R:
        PSHS    D               ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_FG6R ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDB     1,S
        LSRB
        LSRB
        LSRB                    ; B=B/8
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        LDB     1,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTableClear_FG6R ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ANDA    B,U             ; AND original Byte value with the pixel the user wants to cleared
        STA     ,X              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return

PixelTableClear_FG6R:
        FCB     %01111111 Pixel 0
        FCB     %10111111 Pixel 1
        FCB     %11011111 Pixel 2
        FCB     %11101111 Pixel 3
        FCB     %11110111 Pixel 4
        FCB     %11111011 Pixel 5
        FCB     %11111101 Pixel 6
        FCB     %11111110 Pixel 7

; POINT get the value of a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
; Returns with:
; B = Colour value of the point
* PMODE 4 POINT command
POINT_FG6R:
        PSHS    B               ; Save x value
        LDB     #BytesPerRow_FG6R ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDB     ,S
        LSRB
        LSRB
        LSRB                    ; B=B/8
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        LDA     ,S+             ; A = the pixel number
        ANDA    #%00000111      ; A = Pixel value (0 to 7)
        LDU     #PixelTable_FG6R ; U points to the table of pixel values
        LDB     ,X              ; Get existing pixels in this byte from the screen
        ANDB    A,U             ; AND original Byte value with the pixel the user wants to get the value of
        BEQ     >
        LDB     #1              ; If the value is <> 0 make it 1
!       RTS                     ; Restore A,X & U and return

; Colour the screen Colour B
GCLS_FG6R:
        LDX     BEGGRP
        LEAU    Screen_Size_FG6R,X ; Screen Size
        STU     GCLSComp_FG6R+1 ; Self mod end address
        TSTB
        BEQ     >
        LDB     #$FF
!       TFR     B,A     ; A = B
!       STD     ,X++
GCLSComp_FG6R:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS