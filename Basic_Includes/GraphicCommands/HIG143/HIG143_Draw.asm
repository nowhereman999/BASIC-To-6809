; Draw command
; Start of draw commands is at _StrVar_PF00 and terminated with a zero
;
; Variables used
DrawBlankFlag           FCB     0             ; Flag 0 = draw, any other value will skip drawing
RelativeMoveFlag        FCB     0             ; Flag to signify if we are doing a relative move or not
DrawStartY              FDB     100           ; y co-ordinate of the Draw Start
DrawStartX              FDB     160           ; x co-ordinate of the Draw Start
DrawDestinationY        FDB     100           ; y co-ordinate of the Draw Destination
DrawDestinationX        FDB     160           ; x co-ordinate of the Draw Destination
ScaleFlag               FCB     0             ; Flag to see if we are scaling the draw command
ScaleValue              FCB     4             ; Scale value for the draw command
AngleValue              FCB     0             ; Angle value for the draw command
NoUpdateFlag            FCB     0             ; Flag to see if we are doing a no update move or not

DrawHIG143:
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
        TFR     D,U             ; U has the x co-ordinate
; Get the y co-ordinate
        LEAX    1,X             ; Point X at the next character (after the comma)
        BSR     GetNumberinDrawCommand   ; Get the number from the string
;        TFR     B,A             ; Copy the y co-ordinate in A
; D has the y co-ordinate
;        LDB     ,S+             ; Get the x co-ordinate off the stack & fix the stack
        TST     RelativeMoveFlag   ; Check the flag to see if we are doing a relative move
        BEQ     AbsoluteMove4   ; If not then do an absolute move
;Doing a relative move
        ADDD    DrawStartY      ; Add the number to the start y co-ordinate
        STD     DrawDestinationY ; Save the New destination y co-ordinate
        TFR     U,D             ; D = the x co-ordinate
        ADDD    DrawStartX      ; Add the number to the start x co-ordinate
        STD     DrawDestinationX  ; Save the New destination  x co-ordinate
        LDA     ScaleFlag
        BEQ     >               ; If Flag is FLASE then skip ahead
        BSR     DrawLineScale4  ; Go scale the line scaled version is saved in DrawDestinationY(y & x co-ordinates)
!       LDA     AngleValue      ; Get the angle value
        BNE     DoAngle4        ; If <>zero then we are drawing the line on an angle
        BRA     DrawLine4       ; Go draw the line
AbsoluteMove4:
        STD     DrawDestinationY ; Save the New destination y co-ordinate
        STU     DrawDestinationX  ; Save the New destination x co-ordinate
        BRA     DrawAbsolute    ; Go draw the line at the abolute location
; Do the Up command
DrawU4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D
        CMPD    #$0000
        BNE     >               ; skip ahead if we are not zero
        LDD     #$0001          ; Make D a one
!       NEGA                    ; Make D a neagative (y value is going up the screen)
        NEGB                    ; Make D a neagative (y value is going up the screen)
        SBCA    #$00            ; Make D a neagative (y value is going up the screen)
        ADDD    DrawStartY      ; Add the number to the current y co-ordinate
        STD     DrawDestinationY ; Save the destination y co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the Down command
DrawD4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D
        CMPD    #$0000
        BNE     >               ; skip ahead if we are not zero
        LDD     #$0001          ; Make D a one
!       ADDD    DrawStartY      ; Add the number to the current y co-ordinate
        STD     DrawDestinationY ; Save the destination y co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the Left command
DrawL4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D
        CMPD    #$0000
        BNE     >               ; skip ahead if we are not zero
        LDD     #$0001          ; Make D a one
!       NEGA                    ; Make D a neagative (x value is going left)
        NEGB                    ; Make D a neagative (x value is going left)
        SBCA    #$00            ; Make D a neagative (x value is going left)
        ADDD    DrawStartX      ; Add the number to the current x co-ordinate
        STD     DrawDestinationX  ; Save the destination x co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the Right command
DrawR4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D
        CMPD    #$0000
        BNE     >               ; skip ahead if we are not zero
        LDD     #$0001          ; Make D a one
!       ADDD    DrawStartX      ; Add the number to the current x co-ordinate
        STD     DrawDestinationX  ; Save the destination x co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the 45 degree (Up & Right) command
DrawE4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D
        CMPD    #$0000
        BNE     >               ; skip ahead if we are not zero
        LDD     #$0001          ; Make D a one, the amount to move
!       PSHS    D               ; Save amount to move on the stack
        NEGA                    ; Make D a neagative (y value is going up the screen)
        NEGB                    ; Make D a neagative (y value is going up the screen)
        SBCA    #$00            ; Make D a neagative (y value is going up the screen)
        ADDD    DrawStartY      ; Add the number to the current y co-ordinate
        STD     DrawDestinationY ; Save the destination y co-ordinate
        PULS    D               ; Get amount to move
        ADDD    DrawStartX      ; Add the number to the current x co-ordinate
        STD     DrawDestinationX  ; Save the destination xx co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the 135 degree (Down and Right) command
DrawF4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D
        CMPD    #$0000
        BNE     >               ; skip ahead if we are not zero
        LDD     #$0001          ; Make D a one, the amount to move
!       PSHS    D               ; Save amount to move on the stack
        ADDD    DrawStartY      ; Add the number to the current y co-ordinate
        STD     DrawDestinationY ; Save the destination y co-ordinate
        PULS    D               ; Get amount to move
        ADDD    DrawStartX      ; Add the number to the current x co-ordinate
        STD     DrawDestinationX  ; Save the destination xx co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the 225 degree (Down and Left) command
DrawG4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D
        CMPD    #$0000
        BNE     >               ; skip ahead if we are not zero
        LDD     #$0001          ; Make D a one, the amount to move
!       PSHS    D               ; Save amount to move on the stack
        ADDD    DrawStartY      ; Add the number to the current y co-ordinate
        STD     DrawDestinationY ; Save the destination y co-ordinate
        PULS    D               ; Get amount to move
        NEGA                    ; Make D a neagative (flip the x value)
        NEGB                    ; Make D a neagative (flip the x value)
        SBCA    #$00            ; Make D a neagative (flip the x value)
        ADDD    DrawStartX      ; Add the negative number to the current x co-ordinate
        STD     DrawDestinationX  ; Save the destination xx co-ordinate
        BRA     DrawLine4       ; Go draw the line
; Do the 315 degree (Up & Left) command
DrawH4:
        BSR     GetNumberinDrawCommand   ; Get the number from the string in D
        CMPD    #$0000
        BNE     >               ; skip ahead if we are not zero
        LDD     #$0001          ; Make D a one, the amount to move
!       NEGA                    ; Make D a neagative
        NEGB                    ; Make D a neagative
        SBCA    #$00            ; Make D a neagative)
        PSHS    D               ; Save amount to move on the stack
        ADDD    DrawStartY      ; Add the number to the current y co-ordinate
        STD     DrawDestinationY ; Save the destination y co-ordinate
        PULS    D               ; Get amount to move
        ADDD    DrawStartX      ; Add the number to the current x co-ordinate
        STD     DrawDestinationX  ; Save the destination xx co-ordinate
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

; Draw the line from DrawStartYto DrawDestination
; Then make DrawStartY= DrawDestination
DrawLine4:
        LDA     ScaleFlag
        BEQ     >               ; If Flag is FLASE then skip ahead
        BSR     DrawLineScale4  ; Go scale the line scaled version is saved in DrawDestinationY & X
DrawAbsolute:
!       LDA     DrawBlankFlag   ; Get the flag to see if we are drawing a blank line or not, 0 = draw, any other value will skip drawing
        BEQ     DoDrawLine4     ; If not then draw the line
        CLR     DrawBlankFlag   ; Clear the flag so next time it will draw the line
        LDA     NoUpdateFlag    ; NoUpdateFlag is now true, so the next line will return where it started
        BEQ     >               ; If Flag is FLASE then we update the Start location
        CLR     NoUpdateFlag    ; Make it zero for next time
        BRA     DrawMainLoop4   ; go get next command
; Update position but don't draw anything, we still need to scale the movement
!       LDD     DrawDestinationY ; Get the destination y co-ordinate
        STD     DrawStartY      ; Save as the new start y co-ordinate
        LDD     DrawDestinationX  ; Get the destination x co-ordinate
        STD     DrawStartX        ; Save as the new start x co-ordinate
        BRA     DrawMainLoop4   ; go get next command
DoDrawLine4:
        PSHS    X               ; Save the pointer to our draw string
        LDD     DrawStartX      ; Get start x co-ordinate
        PSHS    D               ; Save the start x co-ordinate
        LDB     DrawStartY+1    ; Get start y co-ordinate
        PSHS    B               ; Save the start y co-ordinate
        LDD     DrawDestinationX  ; Get the destination x co-ordinate
        PSHS    D               ; Save the destination x co-ordinate
        LDD     DrawDestinationY ; Get destination y co-ordinate
        PSHS    B               ; Save the destination y co-ordinate

        TST     NoUpdateFlag    ; NoUpdateFlag is now true, so the next line will return where it started
        BEQ     >               ; If Flag is FLASE then we update the Start location
        CLR     NoUpdateFlag    ; Make it zero for next time
        LDD     DrawStartY      ; Get start y co-ordinate
        STD     DrawDestinationY ; Set the destination y co-ordinate
        LDD     DrawStartX        ; Get start x co-ordinate
        STD     DrawDestinationX  ; Set the destination x co-ordinate
        BRA     NoUpdateStart   ; go Draw the line, but leave the start as it is
!       STD     DrawStartY      ; Save the destination as the new start y co-ordinate
        LDD     DrawDestinationX  ; Get the destination x co-ordinate
        STD     DrawStartX      ; Save the destination as the new start x co-ordinate
NoUpdateStart:
        LDY     #LINE_HIG143    ; Y points at the routine to draw the line
        JSR     DoCC3Graphics   ; Prep for CoCo 3 graphics and then JSR ,Y and restore & return
        PULS    X               ; Restore the pointer to our draw string
        BRA     DrawMainLoop4   ; go get next command

DrawLineScale4:
        PSHS    X
; scale the y co-ordinate
        LDD     DrawDestinationY ; Get the destination y co-ordinate
        SUBD    DrawStartY      ; Subtract the start y co-ordinate
;        BMI     >               ; If the result is negative then we are going up
; Y value is positive, drawing downwards by D
        BSR     DrawScaleD      ; Scale value in D return with value in D
        ADDD    DrawStartY      ; Add the start y co-ordinate
        STD     DrawDestinationY ; Save the destination y co-ordinate
; Scale the x co-ordinate
ScaleX4:
        LDD     DrawDestinationX  ; Get the destination x co-ordinate
        SUBD    DrawStartX        ; Subtract the start x co-ordinate
;        BMI     >               ; If the result is negative then we are going left
; x value is positive, drawing downwards by D
        BSR     DrawScaleD      ; Scale value in D return with value in D
        ADDD    DrawStartX        ; Add the start x co-ordinate
        STD     DrawDestinationX  ; Save the destination x co-ordinate
        PULS    X,PC            ; Restore X & Return        

; MULTIPLY HOR OR VER DIFFERENCE BY SCALE FACTOR.
; DIVIDE PRODUCT BY 4 AND RETURN VALUE IN ACCD
; Enter with D as the value to be scaled
; Result is in D
DrawScaleD:     TFR         D,X             ; X = D
                LDB         ScaleValue      ; GET DRAW SCALE AND BRANCH IF ZERO - THIS WILL CAUSE A
                BEQ         L9DC8           ; ZERO DEFAULT TO FULL SCALE
                CLRA                        ;  CLEAR MS BYTE
                EXG         D,X             ; EXCHANGE DIFFERENCE AND SCALE FACTOR
                STA         ,-S             ; SAVE MS BYTE OF DIFFERENCE ON STACK (SIGN INFORMATION)
                BPL         L9DB6           ; BRANCH IF POSITIVE DIFFERENCE
                BSR         L9DC3           ; NEGATE ACCD
L9DB6           BSR         L9FB5           ; MULT DIFFERENCE BY SCALE FACTOR
                TFR         U,D             ; SAVE 2 MS BYTES IN ACCD
                LSRA                        ;
                RORB                        ;
L9DBD           LSRA                        ;
                RORB                        ;  DIVIDE ACCD BY 4 - EACH SCALE INCREMENT IS 1/4 FULL SCALE
                TST         ,S+             ; =CHECK SIGN OF ORIGINAL DIFFERENCE AND
                BPL         L9DC7           ; =RETURN IF POSITIVE
; NEGATE ACCUMULATOR D
L9DC3           NEGA                        ;
L9DC4           NEGB                        ;
                SBCA        #$00            ; NEGATE ACCUMULATOR D IF ACCA=0
L9DC7           RTS
L9DC8           TFR         X,D             ; TRANSFER UNCHANGED DIFFERENCE TO ACCD
                RTS
; MULTIPLY (UNSIGNED) TWO 16 BIT NUMBERS TOGETHER -
; ENTER WITH ONE NUMBER IN ACCD, THE OTHER IN X
; REG. THE 4 BYTE PRODUCT WILL BE STORED IN 4,S-7,S
; (Y, U REG ON THE STACK). I.E. (AA AB) X (XH XL) =
; 256*AA*XH+16*(AA*XL+AB*XH)+AB*XL. THE 2 BYTE
; MULTIPLIER AND MULTIPLICAND ARE TREATED AS A 1
; BYTE INTEGER PART (MSB) WITH A 1 BYTE FRACTIONAL PART (LSB)
L9FB5           PSHS        U,Y,X,B,A       ; SAVE REGISTERS AND RESERVE STORAGE SPACE ON THE STACK
                CLR         $04,S           ; RESET OVERFLOW FLAG
                LDA         $03,S           ; =
                MUL                         ;  =
                STD         $06,S           ; CALCULATE ACCB*XL, STORE RESULT IN 6,S
                LDD         $01,S           ;
                MUL                         ;  CALCULATE ACCB*XH
                ADDB        $06,S           ; =
                ADCA        #$00            ; =
                STD         $05,S           ; ADD THE CARRY FROM THE 1ST MUL TO THE RESULT OF THE 2ND MUL
                LDB         ,S              ;
                LDA         $03,S           ;
                MUL                         ;  CALCULATE ACCA*XL
                ADDD        $05,S           ; =
                STD         $05,S           ; ADD RESULT TO TOTAL OF 2 PREVIOUS MULTS
                BCC         L9FD4           ; BRANCH IF NO OVERFLOW
                INC         $04,S           ; SET OVERFLOW FLAG (ACCD > $FFFF)
L9FD4           LDA         ,S              ;
                LDB         $02,S           ;
                MUL                         ;  CALCULATE ACCA*XH
                ADDD        $04,S           ; =
                STD         $04,S           ; ADD TO PREVIOUS RESULT
                PULS        A,B,X,Y,U,PC    ; RETURN RESULT IN U,Y

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
        LDD     DrawDestinationY ; Get the destination y
        SUBD    DrawStartY      ; destinat y - Start y
        PSHS    D               ; Save it
        LDD     DrawStartX      ; Get the start x co-ordinate
        SUBD    ,S++            ; D = Start x - stack, fix the stack
        PSHS    D               ; Save new Destination x on the stack
        LDD     DrawDestinationX  ; Get the destination x
        SUBD    DrawStartX        ; destinat x - Start x
        ADDD    DrawStartY      ; D = D + start y co-ordinate
        STD     DrawDestinationY ; Save the destination y co-ordinates
        PULS    D               ; get new Destination x
        STD     DrawDestinationX  ; Save the new destination x co-ordinates
        BRA     DrawLine4       ; Go draw the line

!       SUBA    #8              ; Subtract 8
        BNE     >               ; Skip ahead and do angle 3 (270 degrees)
; Do Angle 2 - 180 degrees
; New x = Start x - (Destination x - Start x)
; New y = Start y - (Destination y - Start y)
        LDD     DrawDestinationX  ; Get the destination x
        SUBD    DrawStartX        ; Destination x - Start x
        PSHS    D               ; Save it
        LDD     DrawStartX      ; Get the start x co-ordinate
        SUBD    ,S++            ; D = Start x - stack, fix the stack
        STD     DrawDestinationX  ; Save the destination x co-ordinates
        LDD     DrawDestinationY ; Get the destination y
        SUBD    DrawStartY      ; destination y - Start y
        PSHS    D               ; Save it
        LDD     DrawStartY      ; D = start y co-ordinate
        SUBD    ,S++            ; D = start y - stack, fix stack
        STD     DrawDestinationY ; Save the destination y co-ordinates
        BRA     DrawLine4       ; Go draw the line
; Do Angle 3 - 270 degrees
; New x = Start x + (Destination y - Start y)
; New y = Start y - (Destination x - Start x)
!       LDD     DrawDestinationY ; Get the destination y
        SUBD    DrawStartY      ; Destination y - Start y
        ADDD    DrawStartX      ; Addt the start x co-ordinate
        PSHS    D               ; Save new Destination x on the stack
        LDD     DrawDestinationX  ; Get the destination x
        SUBD    DrawStartX        ; destination x - Start x
        PSHS    D               ; Save it
        LDD     DrawStartY      ; D = start y co-ordinate
        SUBD    ,S++            ; D = start y - stack, fix stack
        STD     DrawDestinationY ; Save the destination y co-ordinates
        PULS    D               ; get new Destination x
        STD     DrawDestinationX  ; Save the new destination x co-ordinates
        BRA     DrawLine4       ; Go draw the line
; Get a number from the draw command
; If the number starts with a + or - then we are doing a relative move
GetNumberinDrawCommand:
        PSHS    U
        LDU     #DecNumber      ; U points at the string location to be converted to a number
        LDA     ,X              ; Get the next character
        CMPA    #'A'            ; Check for a Letter
        BLO     @GetNext
        CMPA    #'Z'
        BHI     @GetNext
        LDD     #$0001          ; If no number given then value is 1
        PULS    U,PC            ; Restore U & Return
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
        JSR     DecToD          ; Convert a ascii numbers to a signed integer in D and return
        PULS    U,PC            ; Restore U & Return
; Flag the move is relative to where it already is
RealtiveMove4:
        STA     RelativeMoveFlag ; Save the flag
        BRA     @GetNext         ; Go get the next character
