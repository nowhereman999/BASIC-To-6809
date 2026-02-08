; Line commands
; Enter with:
; x at 5,S
; y at 4,S
; x1 at 3,S
; y1 at 2,S
LINE_FG1C:
        CLRA
        LDY     ,S              ; Y = return address
        LDB     5,S             ; Load the starting x coordinate from stack
        STD     startX          ; Store in startX
        LDB     4,S             ; Load the starting y coordinate from stack
        STD     startY          ; Store in startY
        LDB     3,S             ; Load the ending x coordinate from stack
        STD     endX            ; Store in endX
        LDB     2,S             ; Load the ending y coordinate from stack
        STD     endY            ; Store in endY
        LEAS    6,S             ; Fix the stack

; Test for a horizontal line
        CMPB    startY+1        ; Compare the starting y coordinate with the ending y coordinate
        LBNE    LineNotHorizontal_FG1C  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDB     endX+1          ; B = ending x coordinate
        CMPB    startX+1        ; Compare with starting x coordinate
        BHI     >               ; If positive then go draw a line normally
        LBEQ    LineDrawDot1_FG1C    ; If zero then go SET one single pixel
        LDA     startX+1          ; Otherwise flip the startx and endx coordinates
        LDB     endX+1          ; and store them in the variables
        STA     endX+1          ;
        STB     startX+1        ;

ReadyToDoHorizontalLine_FG1C:
* See if we have more than 8 pixels to draw
!       LDB     endX+1
        SUBB    startX+1        ;
        CMPB    #8              ; If we have more then 8 pixels to draw then go draw the line normally
        LBLS    LineNotHorizontal_FG1C  ; If the size is <= 8 then go draw the line normally

; Draw a horizontal Line
        LDA     startX+1        ; A=X starting position
        ANDA    #%00000011      ; Keep only the last 2 bits range of 0 to 3      
        ADDA    #3              ; Add 3
        PSHS    A               ; Save the # of pixels to draw for this horizontal line
        ADDB    ,S+             ; Length of the line + bits
        LDA     endX+1          ; A=X ending value
        ANDA    #%00000011      ; Keep only the last 2 bits range of 0 to 3    
        PSHS    A               ; Save the # of pixels to draw for this horizontal line
        SUBB    ,S+             ; B=B-end pixels
; Turn pixels into bytes
        LSRB                    ; B=B/2
        LSRB                    ; B=B/4, we now have the number of bytes to draw
        DECB
        PSHS    B               ; Save the # of bytes to draw for this horizontal line
        LDA     startY+1        ; A=Y value
        LDB     startX+1        ; B=X value
        ANDB    #%00111111      ; Make sure it's 63 or less
        LSRB
        LSRB
        PSHS    B
        LDB     #16
        MUL
        ORB     ,S+             ; Shift A right 4 times & B right 2 times, fix the stack
        ADDD    BEGGRP          ; Add the Video Start Address
LineHorizontalSET_FG1C:
        TFR     D,X             ; X = location to start drawing at
; Get the colour pattern in A
        LDA     LineColour      ; Get the colour to draw
        BEQ     >               ; If zero use it as is
        DECA
        BEQ     @Ais1           ; A = 1
        DECA
        BEQ     @Ais2           ; A = 2
        LDA     #%11111111      ; A = 3 Pixel pattern
        BRA     >
@Ais2:
        LDA     #%10101010
        BRA     >
@Ais1:
        LDA     #%01010101      ; A = 4 Pixel pattern
!       PSHS    A               ; save the pixel pattern on the stack
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000011      ; B = B & %00000011, get the starting bit of the x coordinate
        LDU     #LineDrawSetTableStart_FG1C
        ANDA    B,U             ; Clear the bits not needed
        LDB     B,U             
        COMB                    ; B = bits to keep
        ANDB    ,X              ; Keep the bits not to be erased
        PSHS    B               ; Save it on the stack
        ORA     ,S+             ; Combine them, increment the stack
        STA     ,X+             ; Update the screen and move to the next byte position
        PULS    D               ; A= Colour pattern, B = number of bytes to draw on screen
!       STA     ,X+             ; draw 4 pixels
        DECB                    ; Decrement the # of Bytes to draw
        BNE     <
* Draw the pixels on the right side of the line
        LDU     #LineDrawSetTableEnd_FG1C
        LDB     endX+1          ; B = ending x coordinate
        ANDB    #%00000011      ; B = B & %00000011, get the ending bit of the x coordinate
        ANDA    B,U             ; Clear the bits not used by A
        PSHS    A               ; Save A on the stack
        LDB     B,U             ; B = the pixels to set from the table   
        COMB                    ; Flip the bits
        ANDB    ,X              ; Keep the pixels to the right of the end of the line
        ORB     ,S+             ; Merge the pixels, fix the stack
        STB     ,X              ; Store the byte
        JMP     ,Y              ; Return

LineDrawSetTableStart_FG1C:
        FCB     %11111111       ; Pixel 0
        FCB     %00111111       ; Pixel 1
        FCB     %00001111       ; Pixel 2
        FCB     %00000011       ; Pixel 3

LineDrawSetTableEnd_FG1C:
        FCB     %11000000       ; Pixel 0
        FCB     %11110000       ; Pixel 1
        FCB     %11111100       ; Pixel 2
        FCB     %11111111       ; Pixel 3

; PSET(startX , startY , 1)
LineDrawDot1_FG1C:
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_FG1C        ; Plot the pixel
        JMP     ,Y              ; Return

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal_FG1C:
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
LINELoop_FG1C:
; PSET(startX , startY , 1)
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_FG1C        ; Plot the pixel

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
        BRA     LINELoop_FG1C       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop_FG1C       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S
BOX_FG1C:
        PULS    Y               ; Y = return address
        PULS    D               ; Get BoxEndY & BoxEndX
        STA     BoxEndY         ; Store in BoxEndY
        STB     BoxEndX         ; Store in BoxEndX
        PULS    D               ; Get BoxStartY & BoxStartX
        STA     BoxStartY       ; Store in BoxStartY
        STB     BoxStartX       ; Store in BoxStartX

; Enter with:
; A = y coordinate
; B = x coordinate

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

; Draw the top line of the box
        INC     BoxEndX         ; Make sure we can handle an end value of 255 properly
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_FG1C      ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
; Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_FG1C           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_FG1C           ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxEndX         ; B = BoxEndX
        DECB
!       JSR     SET_FG1C           ; Go draw the pixel on screen
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
BoxFill_FG1C:
        PULS    Y               ; Y = return address
        PULS    D               ; Get BoxEndY & BoxEndX
        STA     BoxEndY         ; Store in BoxEndY
        STB     BoxEndX         ; Store in BoxEndX
        PULS    D               ; Get BoxStartY & BoxStartX
        STA     BoxStartY       ; Store in BoxStartY
        STB     BoxStartX       ; Store in BoxStartX

; Enter with:
; A = y coordinate
; B = x coordinate

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
        INC     BoxEndX         ; Make sure we can handle an end value of 255 properly
        LDA     BoxStartY       ; A = BoxStartY
        STA     ,-S             ; Save the y coordinate in the stack
BFillLoop_FG1C:
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_FG1C           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_FG1C       ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return
        