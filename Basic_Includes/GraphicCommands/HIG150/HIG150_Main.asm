; Graphics commands for screen mode HIG150
; Resolution of 512x225x2 colours
ScreenWidth_HIG150    EQU 512
ScreenHeight_HIG150   EQU 225
BytesPerRow_HIG150    EQU ScreenWidth_HIG150/8
Screen_Size_HIG150    EQU $3840
;
; SET a dot on screen
; Enter with:
; A = y coordinate
; X = x coordinate
;
; x location is 0 to 319 (64 bytes) per row
; y location is 0 to 224 (225 rows)
;
; Byte to draw pixel on screen
; = 0111 1xxx = 15 is the byte
; = xxxx x111 = pixel value
;
; A=y value, X=x value
DoSet_HIG150:
        TST     LineColour      ; Get the Set colour
        BEQ     RESET_HIG150      ; If it's not zero then draw white dot
SET_HIG150:
        PSHS    A,X             ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_HIG150 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     1,S
        LSRA
        RORB
        LSRA
        RORB
        LSRB                    ; B=D/8
        ABX                     ; X now has the value of Y = Y * 64 + X=X/8 (we now have our screen location)

        LDB     2,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTable_HIG150 ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ORA     B,U             ; Or original Byte value with the pixel the user wants to set
        STA     ,X              ; Write new byte to the screen
        PULS    A,X,PC            ; Restore D,X & U and return

PixelTable_HIG150:
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
; X = x coordinate

; A=y value, X=x value
RESET_HIG150:
        PSHS    A,X             ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_HIG150 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     1,S
        LSRA
        RORB
        LSRA
        RORB
        LSRB                    ; B=D/8
        ABX                     ; X now has the value of Y = Y * 64 + X=X/8 (we now have our screen location)
        LDB     2,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTableClear_HIG150 ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ANDA    B,U             ; AND original Byte value with the pixel the user wants to cleared
        STA     ,X              ; Write new byte to the screen
        PULS    A,X,PC            ; Restore D,X & U and return

PixelTableClear_HIG150:
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
; X = x coordinate
; Returns with:
; B = Colour value of the point
* PMODE 4 POINT command
POINT_HIG150:
        PSHS    X               ; Save x coordinate on the stack
        LDB     #BytesPerRow_HIG150 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     ,S
        LSRA
        RORB
        LSRA
        RORB
        LSRB                    ; B=D/8
        ABX                     ; X now has the value of Y = Y * 64 + X=X/8 (we now have our screen location)
        LDA     1,S             ; A = the pixel number, retore the stack
        ANDA    #%00000111      ; A = Pixel value (0 to 7)
        LDU     #PixelTable_HIG150 ; U points to the table of pixel values
        LDB     ,X              ; Get existing pixels in this byte from the screen
        ANDB    A,U             ; AND original Byte value with the pixel the user wants to get the value of
        BEQ     >
        LDB     #1              ; If the value is <> 0 make it 1
!       PULS    X,PC            ; Restore A,X & U and return
        
; Colour the screen Colour B
GCLS_HIG150:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG150,X ; Screen Size
        STU     GCLSComp_HIG150+1 ; Self mod end address
        TSTB
        BEQ     >
        LDB     #$FF
!       TFR     B,A     ; A = B
!       STD     ,X++
GCLSComp_HIG150:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS