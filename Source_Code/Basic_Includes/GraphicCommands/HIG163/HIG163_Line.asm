* Line commands
* Enter with:
* x at 10,S
* y at 9,S
* x1 at 8,S
* y1 at 7,S

LINE_HIG163:
        CLRA
        LDY     ,S              ; Y = return address
        LDB     10,S            ; Load the starting x coordinate from stack
        STD     startX          ; Store in startX
        LDB     9,S             ; Load the starting y coordinate from stack
        STD     startY          ; Store in startY
        LDB     8,S             ; Load the ending x coordinate from stack
        STD     endX            ; Store in endX
        LDB     7,S             ; Load the ending y coordinate from stack
        STD     endY            ; Store in endY
; Fix the stack
        LDA     2,S             ; Get the CC
        LDX     3,S             ; Get D
        LDU     5,S             ; Get Return address for CoCo 3 graphics screen setup code (DoCC3Graphics)
        LEAS    11,S            ; Move the stack pointer
        PSHS    A,X,U

; Test for a horizontal line
        CMPB    startY+1        ; Compare the starting y coordinate with the ending y coordinate
        BNE     LineNotHorizontal_HIG163  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDB     endX+1          ; B = ending x coordinate
        CMPB    startX+1        ; Compare with starting x coordinate
        BHI     LineHorizontalSET_HIG163    ; If A is positive then go draw a line normally
        BEQ     LineDrawDot1_HIG163    ; If A is zero then go PSET one single pixel
        LDA     startX+1          ; Otherwise flip the startx and endx coordinates
        LDB     endX+1          ; and store them in the variables
        STA     endX+1          ;
        STB     startX+1        ;

LineHorizontalSET_HIG163:
        LDA     startY+1        ; A=Y value
        LDB     #BytesPerRow_HIG163
        MUL
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X points at the correct row
        LDB     startX+1        ; B=X value
        ABX                     ; X points at the screen location for this pixel
        LDB     endX+1          ; B = endX
        SUBB    startX+1        ; B = endX - startX = length of the line
        INCB
        LDA     LineColour      ; Get the colour of the pixel
!       STA     ,X+
        DECB
        BNE     <
        JMP     ,Y              ; Return

; PSET(startX , startY , 1)
LineDrawDot1_HIG163:
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_HIG163        ; Plot the pixel
        JMP     ,Y              ; Return

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal_HIG163:
        LDD     endX     
        SUBD    startX     
        BPL     >               ; If positive simply skip over changing D's value
        STD     ,--S            ; Save D on the stack
        LDD     #$0000          ; D=0
        SUBD    ,S++            ; D=0-D, fix the stack
!       STD     deltaX          ; Save Numeric variable
; deltaY = ABS(endY -startY)
        LDD     endY     
        SUBD    startY     
        BPL     >               ; If positive simply skip over changing D's value
        STD     ,--S            ; Save D on the stack
        LDD     #$0000          ; D=0
        SUBD    ,S++            ; D=0-D, fix the stack
!       STD     deltaY     ; Save Numeric variable
; Determine the direction of the step
; stepX = if startX < endX then 1 else - 1
; IF startX < endX THEN
        LDD     startX   
        CMPD    endX            ; Compare D with the the Right Operand
        BLT     >               ; If Less than, then skip ahead
        LDD     #-1             ; stepX = -1 
        STD     stepX           ; Save Numeric variable
        BRA     @IFDone         ; Jump to END IF line
!       LDD     #1              ; stepX = 1    
        STD     stepX           ; Save Numeric variable
@IFDone                         ; END IF line

; stepY = if startY < endY then 1 else - 1
; IF startY < endY THEN
        LDD     startY   
        CMPD    endY            ; Compare D with the the Right Operand
        BLT     >               ; If Less than, then skip ahead
        LDD     #-1             ; stepY = -1
        STD     stepY           ; Save Numeric variable
        BRA     @IFDone         ; Jump to END IF line
!       LDD     #1              ; stepY = 1    
        STD     stepY           ; Save Numeric variable
@IFDone                         ; END IF line

; Initialize the error term
; error0 = deltaX -deltaY
        LDD     deltaX   
        SUBD    deltaY     
        STD     error0          ; Save Numeric variable
; Loop until we reach the end coordinates
; Draw a pixel at the current coordinates
LINELoop_HIG163:
; PSET(startX , startY , 1)
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
LineDrawDot2_HIG163:
        JSR     SET_HIG163        ; Plot the pixel

; Check if we have reached the end coordinates
; IF startX = endX AND startY = endY THEN Return
        LDD     startX   
        CMPD    endX            ; Compare D with the value on the stack, fix the stack
        BNE     >               ; If They are not equal then skip ahead
        LDD     startY   
        CMPD    endY            ; Compare D with the value on the stack, fix the stack
        BNE     >               ; If They are not equal then skip ahead
        JMP     ,Y              ; Return
!                               ; END IF line
; Calculate twice the error term
; error2 = 2 * error0    
        LDD     error0   
        LSLB
        ROLA                    ; D = D * 2
        STD     error2          ; Save Numeric variable
; Adjust the x - coordinate and the error term if necessary
; IF error2 > -deltaY THEN
; IF -deltaY <= error2 THEN
        LDD     #$0000          ; Clear D
        SUBD    deltaY          ; Going to use the negative verison of deltaY
        CMPD    error2   
        BLE     >               ; If Less than or equal, then skip ahead
        BRA     @IFDone         ; Jump to END IF line
; error0 = error0 -deltaY
!       LDD     error0   
        SUBD    deltaY     
        STD     error0          ; Save Numeric variable
; startX = startX + stepX
        LDD     startX   
        ADDD    stepX     
        STD     startX          ; Save Numeric variable
@IFDone                         ; END IF line

; Adjust the y - coordinate and the error term if necessary
; IF error2 < deltaX THEN
        LDD     error2   
        CMPD    deltaX          ; Compare D with the value on the stack, fix the stack
        BLT     >               ; If Less than, then skip ahead
;        BRA     @IFDone         ; Jump to END IF line
        BRA     LINELoop_HIG163       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
; error0 = error0 + deltaX
!       LDD     error0   
        ADDD    deltaX     
        STD     error0          ; Save Numeric variable
; startY = startY + stepY
        LDD     startY   
        ADDD    stepY     
        STD     startY          ; Save Numeric variable
@IFDone                         ; END IF line

; GOTO LINELoop
        BRA     LINELoop_HIG163       ; GOTO 10

* Enter with:
* x at 10,S
* y at 9,S
* x1 at 8,S
* y1 at 7,S
* Return address 0,S & 1,S
BOX_HIG163:
        LDY     ,S               ; Y = return address
        LDB     8,S             ; Load the ending x coordinate from stack
        STB     BoxEndX         ; Store in BoxEndX
        LDB     7,S             ; Load the ending y coordinate from stack
        STB     BoxEndY         ; Store in BoxEndY

        LDB     10,S            ; Load the starting x coordinate from stack
        STB     BoxStartX          ; Store in startX
        LDB     9,S             ; Load the starting y coordinate from stack
        STB     BoxStartY          ; Store in startY

; Fix the stack
        LDA     2,S             ; Get the CC
        LDX     3,S             ; Get D
        LDU     5,S             ; Get Return address for CoCo 3 graphics screen setup code (DoCC3Graphics)
        LEAS    11,S            ; Move the stack pointer
        PSHS    A,X,U

; Enter with:
; A = y coordinate
; B = x coordinate

; IF BoxEndX < BoxStartX THEN
        LDA     BoxStartX   
        CMPA    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
; D = BoxEndX
        LDB     BoxEndX  
; BoxEndX = BoxStartX
        STB     BoxStartX   
        STA     BoxEndX         ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDA     BoxStartY   
        CMPA    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
; D = BoxEndY
        LDB     BoxEndY  
; BoxEndY = BoxStartY
        STB     BoxStartY   
        STA     BoxEndY         ; Save Numeric variable
; END IF
!                               ; END IF line


        LDA     BoxEndY         ; A = BoxEndY
        SUBA    BoxStartY       ; A = BoxEndY - BoxStartY
        PSHS    A               ; Save # of rows to fill
;
        LDA     BoxStartY       ; A = BoxStartY
        LDB     #BytesPerRow_HIG163
        MUL
        ADDD    #128            ; move the pointer forward so we can use STA  B,X
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X points at the screen location for this pixel
        LDB     BoxStartX       ; B = BoxStartX
        ABX
;
        LDB     BoxEndX         ; B = BoxEndX
        SUBB    BoxStartX       ; B = EndX-StartX
        SUBB    #128            ; change the offset to work with X offset
        PSHS    B
;
        LDA     LineColour      ; Get the colour of the pixel
        LDB     ,S
; Draw Top line
!       STA     B,X
        DECB
        CMPB    #127
        BNE     <
        LEAX    BytesPerRow_HIG163,X    ; Move down a row
        TST     1,S
        BEQ     @DoneBox                ; Single row to do
        DEC     1,S
; Do sides only
@Loop   LDB     ,S
        STA     B,X
        STA     -128,X
        LEAX    BytesPerRow_HIG163,X    ; Move down a row
        DEC     1,S
        BNE     @Loop
; Draw bottom line
        LDB     ,S
!       STA     B,X
        DECB
        CMPB    #127
        BNE     <
@DoneBox:
        LEAS    2,S             ; Fix the stack
        JMP     ,Y              ; Return

* Enter with:
* x at 10,S
* y at 9,S
* x1 at 8,S
* y1 at 7,S
* Return address 0,S & 1,S
BoxFill_HIG163:
        LDY     ,S               ; Y = return address
        LDB     8,S             ; Load the ending x coordinate from stack
        STB     BoxEndX         ; Store in BoxEndX
        LDB     7,S             ; Load the ending y coordinate from stack
        STB     BoxEndY         ; Store in BoxEndY

        LDB     10,S            ; Load the starting x coordinate from stack
        STB     BoxStartX          ; Store in startX
        LDB     9,S             ; Load the starting y coordinate from stack
        STB     BoxStartY          ; Store in startY

; Fix the stack
        LDA     2,S             ; Get the CC
        LDX     3,S             ; Get D
        LDU     5,S             ; Get Return address for CoCo 3 graphics screen setup code (DoCC3Graphics)
        LEAS    11,S            ; Move the stack pointer
        PSHS    A,X,U

; Enter with:
; A = y coordinate
; B = x coordinate

; IF BoxEndX < BoxStartX THEN
        LDA     BoxStartX   
        CMPA    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
; D = BoxEndX
        LDB     BoxEndX  
; BoxEndX = BoxStartX
        STB     BoxStartX   
        STA     BoxEndX         ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDA     BoxStartY   
        CMPA    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
; D = BoxEndY
        LDB     BoxEndY  
; BoxEndY = BoxStartY
        STB     BoxStartY   
        STA     BoxEndY         ; Save Numeric variable
; END IF
!                               ; END IF line
        LDA     BoxEndY         ; A = BoxEndY
        SUBA    BoxStartY       ; A = BoxEndY - BoxStartY
        INCA
        PSHS    A               ; Save # of rows to fill

        LDA     BoxStartY       ; A = BoxStartY
        LDB     #BytesPerRow_HIG163
        MUL
        ADDD    #128            ; move the pointer forward so we can use STA  B,X
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X points at the screen location for this pixel
        LDB     BoxStartX       ; B = BoxStartX
        ABX

        LDB     BoxEndX         ; B = BoxEndX
        SUBB    BoxStartX       ; B = EndX-StartX
        SUBB    #128            ; change the offset to work with X offset
        PSHS    B

        LDA     LineColour      ; Get the colour of the pixel
@Loop   LDB     ,S
!       STA     B,X
        DECB
        CMPB    #127
        BNE     <
        LEAX    BytesPerRow_HIG163,X    ; Move down a row
        DEC     1,S
        BNE     @Loop
        LEAS    2,S             ; Fix the stack
        JMP     ,Y              ; Return
