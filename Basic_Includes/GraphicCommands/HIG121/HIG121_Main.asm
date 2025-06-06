; Graphics commands for screen mode HIG121
; Resolution of 128x192x2 colours
ScreenWidth_HIG121    EQU 128
ScreenHeight_HIG121   EQU 192
BytesPerRow_HIG121    EQU ScreenWidth_HIG121/8
Screen_Size_HIG121    EQU $0C00
;
; Do SET
; Enter with:
; A = y coordinate, B = x coordinate
;
DoSet_HIG121:
        TST     LineColour      ; Get the Set colour
        BEQ     RESET_HIG121      ; If it's not zero then draw white dot
SET_HIG121:
        PSHS    D               ; Save x & y coordinate on the stack
        LSRA
        BCC     >
        ORB     #%10000000
!       LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the pixel to draw
        LDB     1,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTable_HIG121 ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ORA     B,U             ; Or original Byte value with the pixel the user wants to set
        STA     ,X              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return

PixelTable_HIG121:
        FCB     %10000000 Pixel 0
        FCB     %01000000 Pixel 1
        FCB     %00100000 Pixel 2
        FCB     %00010000 Pixel 3
        FCB     %00001000 Pixel 4
        FCB     %00000100 Pixel 5
        FCB     %00000010 Pixel 6
        FCB     %00000001 Pixel 7
; Enter with:
; A = y coordinate
; B = x coordinate
RESET_HIG121:
        PSHS    D               ; Save x & y coordinate on the stack
        LSRA
        BCC     >
        ORB     #%10000000
!       LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the pixel to draw
        LDB     1,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTableClear_HIG121 ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ANDA    B,U             ; AND original Byte value with the pixel the user wants to cleared
        STA     ,X              ; Write new byte to the screen
        PULS    D,PC            ; Restore D,X & U and return

PixelTableClear_HIG121:
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
POINT_HIG121:
        PSHS    B               ; Save x value
        LSRA
        BCC     >
        ORB     #%10000000
!       LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the pixel to draw
        LDA     ,S+             ; A = the pixel number
        ANDA    #%00000111      ; A = Pixel value (0 to 7)
        LDU     #PixelTable_HIG121 ; U points to the table of pixel values
        LDB     ,X              ; Get existing pixels in this byte from the screen
        ANDB    A,U             ; AND original Byte value with the pixel the user wants to get the value of
        BEQ     >
        LDB     #1              ; If the value is <> 0 make it 1
!       RTS                     ; Restore A,X & U and return

; Colour the screen Colour B
GCLS_HIG121:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG121,X ; Screen Size
        STU     GCLSComp_HIG121+1 ; Self mod end address
        TSTB
        BEQ     >
        LDB     #$FF
!       TFR     B,A     ; A = B
!       STD     ,X++
GCLSComp_HIG121:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS