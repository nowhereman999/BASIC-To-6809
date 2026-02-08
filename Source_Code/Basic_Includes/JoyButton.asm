
; Get the joystick button values
; Enter with B = Button # (0-3)
; Where:
; B = 0   Right Button 1 (or single-button joystick)
; B = 1   Right Button 2
; B = 2   Left Button 1 (or single-button joystick)
; B = 3   Left Button 2
; Exits with B=0 if button is not pressed or with B=1 if button is pressed
BUTTON:         TFR         B,A             ; SAVE BUTTON NUMBER IN ACCA
                CLRB                        ;
                COMB                        ; NOW ACCB = $FF
                LDX         #$FF00          ; POINT TO THE KEYBOARD STROBE PIO
                STB         $02,X           ; SET THE COLUMN STROBE TO $FF - ALLOW ONLY BUTTONS TO BE CHECKED
                LDB         ,X              ; READ THE KEYBOARD ROWS
                CMPB        #$0F            ; THE BUTTONS ARE ON THE BOTTOM FOUR ROWS
                BEQ         NoButtons       ; BRANCH IF NO BUTTONS DOWN
                LDX         #Button1R       ; POINT TO THE BUTTON MASKING ROUTINES
                ASLA                        ;
                ASLA                        ;  MULT ACCA BY FOUR - FOUR BYTES/EACH MASKING ROUTINE
                JMP         A,X             ; JUMP TO THE APPROPRIATE MASKING ROUTINE
; MASK OFF ALL BUT BUTTON 1, RIGHT JOYSTICK
Button1R:       ANDB        #$01
                BRA         ButtonSet
; MASK OFF ALL BUT BUTTON 1, LEFT JOYSTICK
                ANDB        #$04
                BRA         ButtonSet
; MASK OFF ALL BUT BUTTON 2, RIGHT JOYSTICK
                ANDB        #$02
                BRA         ButtonSet
; MASK OFF ALL BUT BUTTON 2, LEFT JOYSTICK
                ANDB        #$08
ButtonSet:      BNE         NoButtons       ; BRANCH IF MASKED BUTTON NOT DOWN
                LDD         #1              ; IF BUTTON DOWN, RETURN A VALUE OF ONE
                BRA         ButtonDone
NoButtons       CLRA                        ;
                CLRB                        ;  RETURN A ZERO IF BUTTON IS NOT DOWN
ButtonDone      RTS