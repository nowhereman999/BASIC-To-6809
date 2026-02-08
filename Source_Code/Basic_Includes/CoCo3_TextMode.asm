
TextScreenPOS       FDB     $0000
TextColorTable:
RGB_Colours     EQU     -1
    IF RGB_Colours
* Colour Info        xxRGBrgb
Black   EQU  $00
        FCB   %00000000         * Black
LightBlue  EQU  $01
        FCB   %00011011         * LightBlue
Blue    EQU  $02
        FCB   %00000001         * Blue
Green   EQU  $03
        FCB   %00010111         * LightGreen
Red     EQU  $04
        FCB   %00100111         * LightRed
Yellow  EQU  $05
        FCB   %00110111         * Yellow
LightGrey  EQU  $06
        FCB   %00111000         * LightGrey
White   EQU  $07
        FCB   %00111111         * White
    ELSE
Black   EQU  $00
        FCB   %00000000         * Black
LightBlue  EQU  $01
        FCB   %00011011         * LightBlue
Blue    EQU  $02
        FCB   %00011100         * Blue
Green   EQU  $03
        FCB   %00010001         * LightGreen
Red     EQU  $04
        FCB   %00010110         * LightRed
Yellow  EQU  $05
        FCB   %00110100         * Yellow
White  EQU  $06
        FCB   %00100000         * White
White   EQU  $07
        FCB   %00110000         * White
    ENDIF
* Text Attributes
Blink         EQU   %10000000
NoBlink       EQU   %00000000
Underline     EQU   %01000000
NoUnderline   EQU   %00000000
Foreground    EQU   %00001000   * Foreground (actual text colour) multiplier

AttributeByte   FCB     NoBlink+NoUnderline+Blue+Foreground*White ; Default White text on blue background

;TextPalette   RMB   16          * Save the palette for 80 column Text mode
