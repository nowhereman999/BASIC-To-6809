; Good values for a screen with 225 rows
FIRQ_Delay0     EQU     38
FIRQ_Delay1     EQU     21
FIRQ_Delay2     EQU     21
FIRQ_Delay3     EQU     255
; Delay0 scanline is at 225 and ends at row  55  (bottom of the sprite is from 168 to 226)
; Delay1 scanline is at  56 and ends at row 111  (bottom of the sprite is from   0 to  55)
; Delat2 scanline is at 112 and ends at row 167  (bottom of the sprite is from  56 to 111)
; Delay3 scanline is at 168 and ends at row 224  (bottom of the sprite is from 112 to 167)
CheckSprite0    EQU     226     ; If lower than this value and hasn't been drawn then draw it
CheckSprite1    EQU     55      ; If lower than this value and hasn't been drawn then draw it
CheckSprite2    EQU     111     ; If lower than this value and hasn't been drawn then draw it
CheckSprite3    EQU     167     ; If lower than this value and hasn't been drawn then draw it

