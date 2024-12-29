* Line commands
* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
LINE_HIG129:
        CLRA
        PULS    Y               ; Y = return address
        LDB     5+3,S           ; Load the starting x coordinate from stack
        STD     startX          ; Store in startX
        LDB     4+3,S           ; Load the starting y coordinate from stack
        STD     startY          ; Store in startY
        LDB     3+3,S           ; Load the ending x coordinate from stack
        STD     endX            ; Store in endX
        LDB     2+3,S           ; Load the ending y coordinate from stack
        STD     endY            ; Store in endY
        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
        LEAS    4,S             ; Fix the stack
        PSHS    A,X,U           ; Restore them where they need to be

; 16 colours - copy colour to the high nibble
        LDA     LineColour
        ANDA    #%00001111      ; Keep the right nibble value
        STA     ,-S             ; Save it on the stack
        LSLA
        LSLA
        LSLA
        LSLA                    ; Move the bits left, now they are in the high nibble
        ORA     ,S+             ; A now has the value in the high nibble and the low nibble
        STA     LineColour

; Test for a horizontal line
        CMPB    startY+1        ; Compare the starting y coordinate with the ending y coordinate
        BNE     LineNotHorizontal_HIG129  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDB     endX+1          ; B = ending x coordinate
        CMPB    startX+1        ; Compare with starting x coordinate
        BHI     >               ; If positive then go draw a line normally
        BEQ     LineDrawDot1_HIG129    ; If zero then go SET one single pixel
        LDA     startX+1          ; Otherwise flip the startx and endx coordinates
        LDB     endX+1          ; and store them in the variables
        STA     endX+1          ;
        STB     startX+1        ;

ReadyToDoHorizontalLine_HIG129:
* See if we have more than 4 pixels to draw
!       LDB     endX+1
        SUBB    startX+1        ;
        CMPB    #5
        BLS     LineNotHorizontal_HIG129  ; If the size is <= 4 then go draw the line normally

; Draw a horizontal Line
        LDA     endX+1          ; A=X ending value
        LSRA
        BCC     >
        DECB
!       DECB
        LSRB                    ; B=B/2, we now have the number of bytes to draw
        PSHS    B               ; Save the # of bytes to draw for this horizontal line

; Turn pixels into bytes
        LDA     startY+1        ; A=Y value
        LDB     #BytesPerRow_HIG129 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDB     startX+1        ; B=X value
        LSRB
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000001      ; Are we an even pixel
        BEQ     @EvenPixel      ; Skip ahead if so
; Odd pixel is where we are starting
        LDB     ,X
        ANDB    #%11110000      ; Keep the Even pixel, Erase the Odd pixel
        STB     ,X
        LDB     LineColour
        ANDB    #%00001111      
        ORB     ,X              ; Put them together
        BRA     >
@EvenPixel:
        LDB     LineColour
!       STB     ,X+             ; Write it on the screen
        LDA     LineColour
        PULS    B               ; A= Colour pattern, B = number of bytes to draw on screen
!       STA     ,X+             ; draw 4 pixels
        DECB                    ; Decrement the # of Bytes to draw
        BNE     <

        LDB     endX+1          ; B = ending x coordinate
        LSRB
        BCS     @OddPixel       
; Even pixel is what we have to draw
        LDB     ,X
        ANDB    #%00001111      ; Keep Erase the Even pixel, Keep the Odd pixel
        STB     ,X
        LDB     LineColour
        ANDB    #%11110000
        ORB     ,X              ; Put them together
        BRA     >
@OddPixel:
        LDB     LineColour
!       STB     ,X              ; Write it on the screen
        JMP     ,Y              ; Return

; PSET(startX , startY , 1)
LineDrawDot1_HIG129:
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_HIG129        ; Plot the pixel
        JMP     ,Y              ; Return

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal_HIG129:
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
LINELoop_HIG129:
; PSET(startX , startY , 1)
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_HIG129        ; Plot the pixel

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
        BRA     LINELoop_HIG129       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop_HIG129       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S
BOX_HIG129:
        PULS    Y               ; Y = return address
        LDD     7,S
        STA     BoxStartY       ; Store in BoxStartY 
        STB     BoxStartX       ; Store in BoxStartX
        LDD     5,S
        STA     BoxEndY         ; Store in BoxEndY
        STB     BoxEndX         ; Store in BoxEndX
        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
        LEAS    4,S             ; Fix the stack
        PSHS    A,X,U           ; Restore them where they need to be

; Enter with:
; A = y coordinate
; B = x coordinate

; 16 colours - copy colour to the high nibble
        LDA     LineColour
        ANDA    #%00001111      ; Keep the right nibble value
        PSHS    A               ; Save it on the stack
        LSLA
        LSLA
        LSLA
        LSLA                    ; Move the bits left, now they are in the high nibble
        ORA     ,S+             ; A now has the value in the high nibble and the low nibble
        STA     LineColour

; IF BoxEndX < BoxStartX THEN
        LDA     BoxStartX   
        CMPA    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
        LDB     BoxEndX  
        STB     BoxStartX   
        STA     BoxEndX         ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDA     BoxStartY   
        CMPA    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
        LDB     BoxEndY  
        STB     BoxStartY   
        STA     BoxEndY         ; Save Numeric variable
; END IF
!                               ; END IF line

* Draw the top line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_HIG129      ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_HIG129      ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_HIG129      ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxEndX         ; B = BoxEndX
!       JSR     SET_HIG129      ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
        JMP     ,Y              ; Return

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S
BoxFill_HIG129:
        PULS    Y               ; Y = return address
        LDD     7,S
        STA     BoxStartY       ; Store in BoxStartY 
        STB     BoxStartX       ; Store in BoxStartX
        LDD     5,S
        STA     BoxEndY         ; Store in BoxEndY
        STB     BoxEndX         ; Store in BoxEndX
        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
        LEAS    4,S             ; Fix the stack
        PSHS    A,X,U           ; Restore them where they need to be

; Enter with:
; A = y coordinate
; B = x coordinate

; 16 colours - copy colour to the high nibble
        LDA     LineColour
        ANDA    #%00001111      ; Keep the right nibble value
        PSHS    A               ; Save it on the stack
        LSLA
        LSLA
        LSLA
        LSLA                    ; Move the bits left, now they are in the high nibble
        ORA     ,S+             ; A now has the value in the high nibble and the low nibble
        STA     LineColour

; IF BoxEndX < BoxStartX THEN
        LDA     BoxStartX   
        CMPA    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
        LDB     BoxEndX  
        STB     BoxStartX   
        STA     BoxEndX         ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDA     BoxStartY   
        CMPA    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
        LDB     BoxEndY  
        STB     BoxStartY   
        STA     BoxEndY         ; Save Numeric variable
; END IF
!                               ; END IF line

        LDB     BoxEndX
        SUBB    BoxStartX        ;
        CMPB    #8               ; If we have more then 8 pixels to draw then go draw the BoxFill normally
        BLS     Normal_BFillLoop_HIG129  ; If the size is <= 8 then go draw the BoxFill normally
        PSHS    Y                ; Make RTS be the return address
        LDY     #LineReturn_HIG129 ; Make the end of the line routine return below
        LDA     BoxStartX
        STA     startX+1   
        LDA     BoxEndX 
        STA     endX+1

        LDB     BoxStartY   
!       STB     startY+1         ; Store in startY
        STB     endY+1           ; Store in endY
        JMP     ReadyToDoHorizontalLine_HIG129 ; Draw a horizontal line
LineReturn_HIG129:
        LDB     startY+1         ; Increment the startY
        INCB
        CMPB    BoxEndY  
        BLS     <
        RTS                      ; Return

Normal_BFillLoop_HIG129:
* Draw the top line of the box
        LDA     BoxStartY       ; A = BoxStartY
        STA     ,-S             ; Save the y coordinate in the stack
BFillLoop_HIG129:
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_HIG129        ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_HIG129       ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return
