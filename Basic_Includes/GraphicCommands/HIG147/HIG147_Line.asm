; Line commands
; Enter with:
; x at 5,S
; y at 4,S
; x1 at 3,S
; y1 at 2,S
LINE_HIG147:
        CLRA
        PULS    Y               ; Y = return address
        LDX     6+3,S           ; Load the starting x coordinate from stack
        STX     startX          ; Store in startX
        LDB     5+3,S           ; Load the starting y coordinate from stack
        STD     startY          ; Store in startY
        LDX     3+3,S           ; Load the ending x coordinate from stack
        STX     endX            ; Store in endX
        LDB     2+3,S           ; Load the ending y coordinate from stack
        STD     endY            ; Store in endY
        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
        LEAS    6,S             ; Fix the stack
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
        BNE     LineNotHorizontal_HIG147  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDX     endX            ; B = ending x coordinate
        CMPX    startX          ; Compare with starting x coordinate
        BHI     >               ; If positive then go draw a line normally
        BEQ     LineDrawDot1_HIG147    ; If zero then go SET one single pixel
        LDU     startX          ; Otherwise flip the startx and endx coordinates
        STU     endX            ;
        STX     startX          ;

ReadyToDoHorizontalLine_HIG147:
* See if we have more than 4 pixels to draw
!       LDD     endX
        SUBD    startX          ;
        CMPD    #4
        BLS     LineNotHorizontal_HIG147  ; If the size is <= 4 then go draw the line normally
        TFR     D,X

; Draw a horizontal Line
        LDA     endX+1          ; A=X ending value
        LSRA
        BCC     >
        LEAX    -1,X
!       TFR     X,D
        SUBD    #1
        LSRA
        RORB                    ; B=B/2, we now have the number of bytes to draw
        PSHS    B               ; Save the # of bytes to draw for this horizontal line
; Turn pixels into bytes
        LDA     startY+1        ; A=Y value
        LDB     #BytesPerRow_HIG147 ; MUL A by the number of bytes per row
        MUL       
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     startX          ; D=X value
        LSRA
        RORB
        ABX                     ; X now has the value of Y = Y * 160 + X/2 (we now have our screen location)
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

; SET(startX , startY , LineColour)
LineDrawDot1_HIG147:
        LDX     startX          ; X = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_HIG147      ; Plot the pixel
        JMP     ,Y              ; Return

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal_HIG147:
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
LINELoop_HIG147:
; PSET(startX , startY , 1)
        LDX     startX          ; X = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_HIG147      ; Plot the pixel

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
        BRA     LINELoop_HIG147       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop_HIG147       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S
BOX_HIG147:
        PULS    Y               ; Y = return address
        LDX     6+3,S           ; Load the starting x coordinate from stack
        STX     BoxStartX       ; Store in startX
        LDB     5+3,S           ; Load the starting y coordinate from stack
        STB     BoxStartY       ; Store in startY
        LDX     3+3,S           ; Load the ending x coordinate from stack
        STX     BoxEndX         ; Store in endX
        LDB     2+3,S           ; Load the ending y coordinate from stack
        STB     BoxEndY         ; Store in endY
        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
        LEAS    6,S             ; Fix the stack
        PSHS    A,X,U           ; Restore them where they need to be

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
        LDX     BoxStartX   
        CMPX    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
        LDD     BoxEndX  
        STX     BoxEndX         ; Save Numeric variable
        STD     BoxStartX       ; Save Numeric variable
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDB     BoxStartY   
        CMPB    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
        LDA     BoxEndY  
        STB     BoxEndY         ; Save Numeric variable
        STA     BoxStartY       ; Save Numeric variable
; END IF
!                               ; END IF line

* Draw the top line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot0_HIG147:
!       JSR     BoxSet_HIG147   ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot1_HIG147:
!       JSR     BoxSet_HIG147   ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot2_HIG147:
!       JSR     BoxSet_HIG147   ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxEndX         ; B = BoxEndX
BoxDrawDot3_HIG147:
!       JSR     BoxSet_HIG147   ; Go draw the pixel on screen
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

BoxFill_HIG147:
        PULS    Y               ; Y = return address
        LDX     6+3,S           ; Load the starting x coordinate from stack
        STX     BoxStartX       ; Store in startX
        LDB     5+3,S           ; Load the starting y coordinate from stack
        STB     BoxStartY       ; Store in startY
        LDX     3+3,S           ; Load the ending x coordinate from stack
        STX     BoxEndX         ; Store in endX
        LDB     2+3,S           ; Load the ending y coordinate from stack
        STB     BoxEndY         ; Store in endY
        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
        LEAS    6,S             ; Fix the stack
        PSHS    A,X,U           ; Restore them where they need to be

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
        LDX     BoxStartX   
        CMPX    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
        LDD     BoxEndX  
        STX     BoxEndX         ; Save Numeric variable
        STD     BoxStartX       ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDB     BoxStartY   
        CMPB    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
        LDA     BoxEndY  
        STB     BoxEndY         ; Save Numeric variable
        STA     BoxStartY       ; Save Numeric variable
; END IF
!                               ; END IF line

* Draw the top line of the box
        LDA     BoxStartY       ; A = BoxStartY
        STA     ,-S             ; Save the y coordinate in the stack
BFillLoop_HIG147:
        LDX     BoxStartX       ; B = BoxStartX
!       JSR     BoxSet_HIG147   ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_HIG147 ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return
