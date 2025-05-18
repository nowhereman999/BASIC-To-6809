; Good values for a screen with 192 rows
FIRQ_Delay0     EQU     46
FIRQ_Delay1     EQU     18
FIRQ_Delay2     EQU     18
FIRQ_Delay3     EQU     255
; Delay0 scanline is at 192 and ends at row  47  (bottom of the sprite is from 144 to 191)
; Delay1 scanline is at  48 and ends at row  95  (bottom of the sprite is from   0 to  47)
; Delat2 scanline is at  96 and ends at row 143  (bottom of the sprite is from  48 to  95)
; Delay3 scanline is at 144 and ends at row 191  (bottom of the sprite is from  96 to 143)
CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
CheckSprite1    EQU     47      ; If lower than this value and hasn't been drawn then draw it
CheckSprite2    EQU     95      ; If lower than this value and hasn't been drawn then draw it
CheckSprite3    EQU     143     ; If lower than this value and hasn't been drawn then draw it
