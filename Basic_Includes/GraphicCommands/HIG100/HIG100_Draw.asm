; Draw command
; Start of draw commands is at _StrVar_PF00 and terminated with a zero
;
; Variables used
DrawBlankFlag           FCB     0             ; Flag 0 = draw, any other value will skip drawing
RelativeMoveFlag        FCB     0             ; Flag to signify if we are doing a relative move or not
DrawDestination         FCB     96,32         ; y,x co-ordinates of the Draw Destination
DrawStart               FCB     96,32         ; y,x co-ordinates of the Draw Start
ScaleFlag               FCB     0             ; Flag to see if we are scaling the draw command
ScaleValue              FCB     4             ; Scale value for the draw command
AngleValue              FCB     0             ; Angle value for the draw command
NoUpdateFlag            FCB     0             ; Flag to see if we are doing a no update move or not

DrawHIG100:
        LDX     #_StrVar_PF00+1 ; Get the start of the draw command string
        LDU     #_StrVar_PF00+1 ; Get the start of the draw command string
        LDB     _StrVar_PF00    ; Get the string length in B
; Remove spaces
!       LDA     ,X+             ; Get the next character
        CMPA    #' '            ; Check for a space
        BEQ     @Skip           ; Skip over spaces
        STA     ,U+             ; Save the byte
@Skip:  DECB                    ; Decrement the string length
        BNE     <
        LDD     #';'*$100+00
        STD     ,U              ; Mark the end of the string with a ; zero
        LDX     #_StrVar_PF00+1 ; Point X at the start of the draw command string
DrawMainLoop4:
        LDA     ,X+             ; Get the next character
DrawBack4:
        BEQ     DrawDone4       ; If we get a zero we are done
        SUBA    #'A'            ; A is the first entry = 0
        LSLA                    ; two bytes per entry in the Jump table
        LDU     #DrawCommandJump4 ; Point U at the Draw Command Jump table
        JMP     [A,U]           ; Jump to the correct routine based on the character

DrawU4Pre:
        CLRA                    ; Set A to zero to handle the U (Up) command
        BRA     DoURDLJump4     ; Go do the Jump based on the Angle
DrawR4Pre:
        LDA     #2              ; Set A to 2 to handle the R (Right) command
        BRA     DoURDLJump4     ; Go do the Jump based on the Angle
DrawD4Pre:
        LDA     #4              ; Set A to 4 to handle the D (Down) command
        BRA     DoURDLJump4     ; Go do the Jump based on the Angle
DrawL4Pre:
        LDA     #6              ; Set A to six to handle the L (Left) command
        BRA     DoURDLJump4     ; Go do the Jump based on the Angle
DrawE4Pre:
        CLRA                    ; Set A to zero to handle 2 o'clock
        BRA     DoEFGHJump4     ; Go do the Jump based on the Angle
DrawF4Pre:
        LDA     #2              ; Set A to 2 to handle 4 o'clock
        BRA     DoEFGHJump4     ; Go do the Jump based on the Angle
DrawG4Pre:
        LDA     #4              ; Set A to 4 to handle 8 o'clock
        BRA     DoEFGHJump4     ; Go do the Jump based on the Angle
DrawH4Pre:
        LDA     #6              ; Set A to six to handle 10 o'clock
        BRA     DoEFGHJump4     ; Go do the Jump based on the Angle

DrawDone4:
        RTS                     ; Return from the Draw command

; Handle Angle for the draw command
; 0 is normal
; 1 is 90 degree turn clockwise
; 2 is 180 degree turn clockwise
; 3 is 270 degree turn clockwise
DoURDLJump4:
        LDU     #DrawURDLJumpTable4
        BRA     >
DoEFGHJump4:
        LDU     #DrawEFGHJumpTable4
!       ADDA    AngleValue      ; Get the angle value
        JMP     [A,U]           ; Jump to the correct routine based on the angle
DrawURDLJumpTable4:
                ; Up  , Right, Down , Left
        FDB     DrawU4,DrawR4,DrawD4,DrawL4
        FDB     DrawR4,DrawD4,DrawL4,DrawU4
        FDB     DrawD4,DrawL4,DrawU4,DrawR4
        FDB     DrawL4,DrawU4,DrawR4,DrawD4
; E,F,G,H jump table based on the angle
DrawEFGHJumpTable4:
                ;2'oclock 4     8     10
        FDB     DrawE4,DrawF4,DrawG4,DrawH4
        FDB     DrawF4,DrawG4,DrawH4,DrawE4
        FDB     DrawG4,DrawH4,DrawE4,DrawF4
        FDB     DrawH4,DrawE4,DrawF4,DrawG4

; Draw command jump table
DrawCommandJump4:
        FDB     DrawA4,DrawB4,DrawC4,DrawD4Pre,DrawE4Pre,DrawF4Pre,DrawG4Pre,DrawH4Pre,DrawDone4,DrawDone4,DrawDone4
        FDB     DrawL4Pre,DrawM4,DrawN4,DrawDone4,DrawDone4,DrawDone4,DrawR4Pre,DrawS4,DrawDone4,DrawU4Pre,DrawDone4,DrawDone4,DrawX4

; Do the Blank command
DrawB4:
        STA     DrawBlankFlag   ; Set the flag to say we are drawing a blank line
        LDA     ,X+
        CMPA    #';'            ; Check for a semi-colon
        BEQ     DrawMainLoop4   ; If so then we are done with the command
        BRA     DrawBack4       ; Go handle the next character
; Do the Move command
DrawM4:
        CLR     RelativeMoveFlag   ; Clear the flag
; Get the x co-ordinate
        BSR     GetNumberinDrawCommand   ; Get the number from the string
        PSHS    B               ; Save the x co-ordinate on the stack
; Get the y co-ordinate
        LEAX    1,X             ; Point X at the next character (after the comma)
        BSR     GetNumberinDrawCommand   ; Get the number from the string
        TFR     B,A             ; Copy the y co-ordinate in A
        LDB     ,S+             ; Get the x co-ordinate off the stack & fix the stack
        TST     RelativeMoveFlag   ; Check the flag to see if we are doing a relative move
        BEQ     AbsoluteMove4   ; If not then do an absolute move
;Doing a relative move
        ADDA    DrawStart       ; Add the number to the start y & x co-ordinates
        ADDB    DrawStart+1     ; Add the number to the start y & x co-ordinates
        STD     DrawDestination ; Save the New destination y & x co-ordinates
        LDA     ScaleFlag
        BEQ     >               ; If Flag is FLASE then skip ahead
        BSR     DrawLineScale4  ; Go scale the line scaled version is saved in DrawDestination (y & x co-ordinates)
!       LDA     AngleValue      ; Get the angle value
        BNE     DoAngle4        ; If <>zero then we are drawing the line on an angle
        BRA     DrawLine4       ; Go draw the line
AbsoluteMove4:
        STD     DrawDestination ; Save the New destination y & x co-ordinates
        BRA     DrawAbsolute    ; Go draw the line at the abolute location
; Do the Up command
DrawU4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D (actually only need value in B)
        TSTB
        BNE     >               ; skip ahead if we are not zero
        INCB                    ; Make the amount to move a one
!       NEGB                    ; Make B a neagative (y value is going up the screen)
        ADDB    DrawStart       ; Add the number to the current y co-ordinate
        STB     DrawDestination ; Save the destination y co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the Down command
DrawD4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D (actually only need value in B)
        TSTB
        BNE     >               ; skip ahead if we are not zero
        INCB                    ; Make the amount to move a one
!       ADDB    DrawStart       ; Add the number to the current y co-ordinate
        STB     DrawDestination ; Save the destination y co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the Left command
DrawL4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D (actually only need value in B) B)
        TSTB
        BNE     >               ; skip ahead if we are not zero
        INCB                    ; Make the amount to move a one
!       NEGB                    ; Make B a neagative (x value is going left on screen)
        ADDB    DrawStart+1     ; Add the number to the current x co-ordinate
        STB     DrawDestination+1 ; Save the destination x co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the Right command
DrawR4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D (actually only need value in B) B)
        TSTB
        BNE     >               ; skip ahead if we are not zero
        INCB                    ; Make the amount to move a one
!       ADDB    DrawStart+1     ; Add the number to the current x co-ordinate
        STB     DrawDestination+1 ; Save the destination x co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the 45 degree (Up & Right) command
DrawE4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D (actually only need value in B) B)
        TSTB
        BNE     >               ; skip ahead if we are not zero
        INCB                    ; Make the amount to move a one
!       TFR     B,A             ; Copy B to A
        NEGA                    ; Move the y value up
        ADDA    DrawStart       ; Add the number to the current y co-ordinate
        ADDB    DrawStart+1     ; Add the number to the current x co-ordinate
        STD     DrawDestination ; Save the destination y & x co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the 135 degree (Down and Right) command
DrawF4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D (actually only need value in B) B)
        TSTB
        BNE     >               ; skip ahead if we are not zero
        INCB                    ; Make the amount to move a one
!       TFR     B,A             ; Copy B to A
        ADDA    DrawStart       ; Add the number to the current y co-ordinate
        ADDB    DrawStart+1     ; Add the number to the current x co-ordinate
        STD     DrawDestination ; Save the destination y & x co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the 225 degree (Down and Left) command
DrawG4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D (actually only need value in B) B)
        TSTB
        BNE     >               ; skip ahead if we are not zero
        INCB                    ; Make the amount to move a one
!       TFR     B,A             ; Copy B to A
        ADDA    DrawStart       ; Add the number to the current y & x co-ordinate
        SUBB    DrawStart+1     ; Subtract the number to the current x co-ordinate
        NEGB                    ; Flip the x value
        STD     DrawDestination ; Save the destination y & x co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the 315 degree (Up & Left) command
DrawH4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D (actually only need value in B) B)
        TSTB
        BNE     >               ; skip ahead if we are not zero
        INCB                    ; Make the amount to move a one
!       TFR     B,A             ; Copy B to A
        SUBA    DrawStart       ; Subtract the number to the current y & x co-ordinate
        SUBB    DrawStart+1     ; Subtract the number to the current x co-ordinate
        NEGA                    ; Flip the y value
        NEGB                    ; Flip the x value
        STD     DrawDestination ; Save the destination y & x co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the N no update command
DrawN4:
        STA     NoUpdateFlag    ; NoUpdateFlag is now true, so the next line will return where it started
        LDA     ,X+              ; Get the next character from the string
        CMPA    #';'            ; Is it a ;
        BEQ     >               ; If so skip ahead
        LEAX    -1,X            ; Move back one character
!       BRA     DrawMainLoop4   ; go get next command
; Do the Scale command
DrawS4:
        BSR     GetNumberinDrawCommand  ; Get the number from the string in D (actually only need value in B) B)
        STB     ScaleValue      ; Save the new scale value
        SUBB    #4              ; scale value = scale value - 4
        STB     ScaleFlag       ; If B was 4 it's now zero which will mean no scaling needed, any other value will be scaled
        BRA     DrawMainLoop4   ; go get next command
; Do then Angle command
; Relative moves are effected, non relative moves are not effected by angle
DrawA4:
        BSR     GetNumberinDrawCommand  ; Get the number from the string in D (actually only need value in B) B)
        ANDB    #%00000011      ; only keep a value of 0-3
        LSLB                    ; Angle * 2
        LSLB                    ; Angle * 4
        LSLB                    ; Angle * 8, it now points at the correct row in the jump table
        STB     AngleValue      ; Save the new angle value
        BRA     DrawMainLoop4   ; go get next command
; Do the Colour command
DrawC4:
        BSR     GetNumberinDrawCommand  ; Get the number from the string in D (actually only need value in B) B)
        STB     LineColour      ; Save the new colour value
        BRA     DrawMainLoop4   ; go get next command
; Do the X command
DrawX4:
; Figure out how to handle more strings...

        BRA     DrawMainLoop4   ; go get next command

; Draw the line from DrawStart to DrawDestination
; Then make DrawStart = DrawDestination
DrawLine4:
        LDA     ScaleFlag
        BEQ     >               ; If Flag is FLASE then skip ahead
        BSR     DrawLineScale4  ; Go scale the line scaled version is saved in DrawDestination (y & x co-ordinates)
DrawAbsolute:
!       LDA     DrawBlankFlag   ; Get the flag to see if we are drawing a blank line or not, 0 = draw, any other value will skip drawing
        BEQ     DoDrawLine4     ; If not then draw the line
        CLR     DrawBlankFlag   ; Clear the flag so next time it will draw the line
        LDA     NoUpdateFlag    ; NoUpdateFlag is now true, so the next line will return where it started
        BEQ     >               ; If Flag is FLASE then we update the Start location
        CLR     NoUpdateFlag    ; Make it zero for next time
        BRA     DrawMainLoop4   ; go get next command
; Update position but don't draw anything, we still need to scale the movement
!       LDD     DrawDestination ; Get the destination y & x co-ordinate
        STD     DrawStart       ; Save as the new start y & x co-ordinate
        BRA     DrawMainLoop4   ; go get next command
DoDrawLine4:
        PSHS    X               ; Save the pointer to our draw string
        LDD     DrawStart       ; Get start y & x co-ordinate
        PSHS    D               ; Save the start y & x co-ordinate
        LDD     DrawDestination ; Get the destination y & x co-ordinate
        PSHS    D               ; Save the destination y & x co-ordinate
        TST     NoUpdateFlag    ; NoUpdateFlag is now true, so the next line will return where it started
        BEQ     >               ; If Flag is FLASE then we update the Start location
        CLR     NoUpdateFlag    ; Make it zero for next time
        LDD     DrawStart       ; Get start y & x co-ordinate
        STD     DrawDestination ; Get the destination y & x co-ordinate
        BRA     NoUpdateStart   ; go Draw the line, but leave the start as it is
!       STD     DrawStart       ; Save the destination as the new start y & x co-ordinate
NoUpdateStart:
        LDY     #LINE_HIG100    ; Y points at the routine to draw the line
        JSR     DoCC3Graphics   ; Prep for CoCo 3 graphics and then JSR ,Y and restore & return
        PULS    X               ; Restore the pointer to our draw string
        BRA     DrawMainLoop4   ; go get next command

DrawLineScale4:
; scale the y co-ordinate
        LDA     ScaleValue      ; Get the scale value
        LDB     DrawDestination ; Get the destination y co-ordinate
        SUBB    DrawStart       ; Subtract the start y co-ordinate
        BMI     >               ; If the result is negative then we are going up
; Y value is positive, drawing downwards by B
        MUL                     ; Multiply the scale value by B
        LSRA
        RORB                    ; Divide by 2
        LSRA
        RORB                    ; Divide by 4, B now has our value
        ADDB    DrawStart       ; Add the start y co-ordinate
        STB     DrawDestination ; Save the destination y co-ordinate
        BRA     ScaleX4         ; Go scale the x co-ordinate
; Y value is negative, drawing upwards by B
!       NEGB                    ; Make B positive
        MUL                     ; Multiply the scale value by B
        LSRA
        RORB                    ; Divide by 2
        LSRA
        RORB                    ; Divide by 4, B now has our value
        PSHS    B               ; Save the scaled y co-ordinate
        LDB     DrawStart       ; Add the start y co-ordinate
        SUBB    ,S+              ; Subtract the scaled y co-ordinate, fix the stack
        STB     DrawDestination ; Save the destination y co-ordinate
; Scale the x co-ordinate
ScaleX4:
        LDA     ScaleValue      ; Get the scale value
        LDB     DrawDestination+1 ; Get the destination x co-ordinate
        SUBB    DrawStart+1       ; Subtract the start x co-ordinate
        BMI     >               ; If the result is negative then we are going left
; x value is positive, drawing downwards by B
        MUL                     ; Multiply the scale value by B
        LSRA
        RORB                    ; Divide by 2
        LSRA
        RORB                    ; Divide by 4, B now has our value
        ADDB    DrawStart+1       ; Add the start x co-ordinate
        STB     DrawDestination+1 ; Save the destination x co-ordinate
        RTS                     ; Return        
; x value is negative, drawing upwards by B
!       NEGB                    ; Make B positive
        MUL                     ; Multiply the scale value by A
        LSRA
        RORB                    ; Divide by 2
        LSRA
        RORB                    ; Divide by 4, B now has our value
        PSHS    B               ; Save the scaled x co-ordinate
        LDB     DrawStart+1     ; Get the start x co-ordinate
        SUBB    ,S+              ; Subtract the scaled x co-ordinate, fix the stack
        STB     DrawDestination+1 ; Save the destination x co-ordinate
        RTS                     ; Return    

; Do Angle of a relative line
DoAngle4:
; Destination = Original point (x, y) = (125, 105)
; Start = Center (cx, cy) = (100, 100)
        LDA     AngleValue      ; Get the angle value
        SUBA    #8              ; Subtract 8
        BNE     >               ; Skip ahead
; Do Angle 1 - 90 degrees
; New x = Start x - (Destination y - Start y)
; New y = Start y + (Destination x - Start x)
        LDD     DrawDestination ; Get the destination y & x co-ordinates
        SUBA    DrawStart       ; Subtract the start y co-ordinate
        SUBB    DrawStart+1     ; Subtract the start x co-ordinate
        PSHS    D               ; Save the result
        LDD     DrawStart       ; Get the start y & x co-ordinates
        SUBB    ,S+             ; Subtract the result from the y calculation
        ADDA    ,S+             ; Add the result to the x calculation
        STD     DrawDestination ; Save the destination y,x co-ordinates
        BRA     DrawLine4       ; Go draw the line
!       SUBA    #8              ; Subtract 8
        BNE     >               ; Skip ahead and do angle 3 (270 degrees)
; Do Angle 2 - 180 degrees
; New x = Start x - (Destination x - Start x)
; New y = Start y - (Destination y - Start y)
        LDD     DrawDestination ; Get the destination y & x co-ordinates
        SUBA    DrawStart       ; Subtract the start y co-ordinate
        SUBB    DrawStart+1     ; Subtract the start x co-ordinate
        PSHS    D               ; Save the result
        LDD     DrawStart       ; Get the start y & x co-ordinates
        SUBA    ,S+             ; Subtract the result from the y calculation
        SUBB    ,S+             ; Add the result to the x calculation
        STD     DrawDestination ; Save the destination y,x co-ordinates
        BRA     DrawLine4       ; Go draw the line
; Do Angle 3 - 270 degrees
; New x = Start x + (Destination y - Start y)
; New y = Start y - (Destination x - Start x)
!       LDD     DrawDestination ; Get the destination y & x co-ordinates
        SUBA    DrawStart       ; Subtract the start y co-ordinate
        SUBB    DrawStart+1     ; Subtract the start x co-ordinate
        PSHS    D               ; Save the result
        LDD     DrawStart       ; Get the start y & x co-ordinates
        ADDB    ,S+             ; Subtract the result from the y calculation
        SUBA    ,S+             ; Add the result to the x calculation
        STD     DrawDestination ; Save the destination y,x co-ordinates
        BRA     DrawLine4       ; Go draw the line

; Get a number from the draw command
; IF the number starts with a + or - then we are doing a relative move
GetNumberinDrawCommand:
        LDU     #DecNumber      ; U points at the string location to be converted to a number
        LDA     ,X              ; Get the next character
        CMPA    #'A'            ; Check for a Letter
        BLO     @GetNext
        CMPA    #'Z'
        BHI     @GetNext
        LDD     #$0001          ; If no number given then value is 1
        RTS                     ; Return
@GetNext:
        LDA     ,X+             ; Get the next character
        CMPA    #'+'            ; Check for a +
        BEQ     RealtiveMove4   ; if a + then we do a relative move
        STA     ,U+             ; Save the character in the string
        CMPA    #'-'            ; Check for a -
        BEQ     RealtiveMove4   ; if a - then we do a relative move
        CMPA    #'0'            ; Check for a 0
        BLO     @ReachedEndOfNumber ; Found the end of the number
        CMPA    #'9'            ; Check for a 9
        BLS     @GetNext         ; Keep going if it's a number
@ReachedEndOfNumber:
        CMPA    #';'            ; Check for a ;
        BEQ     >               ; If it's a ; then we have reached the end of the number
        LEAX    -1,X            ; Move back one character, we don't have semi colons between letters
!       CLR     ,-U             ; Clear the last byte to signify the end of the ascii number
        JMP     DecToD          ; Convert a ascii numbers to a signed integer in D and return
; Flag the move is relative to where it already is
RealtiveMove4:
        STA     RelativeMoveFlag ; Save the flag
        BRA     @GetNext         ; Go get the next character


