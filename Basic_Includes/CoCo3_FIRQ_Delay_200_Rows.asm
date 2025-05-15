; Good values for a screen with 200 rows
FIRQ_Delay0     EQU     45
FIRQ_Delay1     EQU     20
FIRQ_Delay2     EQU     18
FIRQ_Delay3     EQU     255
; Delay0 scanline is at 200 and ends at row  49  (bottom of the sprite is from 150 to 199)
; Delay1 scanline is at  50 and ends at row  99  (bottom of the sprite is from   0 to  49)
; Delat2 scanline is at 100 and ends at row 149  (bottom of the sprite is from  50 to  99)
; Delay3 scanline is at 150 and ends at row 199  (bottom of the sprite is from 100 to 149)
CheckSprite0    EQU     199     ; If lower than this value and hasn't been drawn then draw it
CheckSprite1    EQU     49      ; If lower than this value and hasn't been drawn then draw it
CheckSprite2    EQU     99      ; If lower than this value and hasn't been drawn then draw it
CheckSprite3    EQU     149     ; If lower than this value and hasn't been drawn then draw it
