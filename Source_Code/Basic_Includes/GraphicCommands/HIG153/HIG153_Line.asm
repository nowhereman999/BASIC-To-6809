; Line commands
; Enter with:
; x at 5,S
; y at 4,S
; x1 at 3,S
; y1 at 2,S
LINE_HIG153:
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

; Test for a horizontal line
        CMPB    startY+1        ; Compare the starting y coordinate with the ending y coordinate
        LBNE    LineNotHorizontal_HIG153  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDX     endX            ; B = ending x coordinate
        CMPX    startX          ; Compare with starting x coordinate
        BHI     >               ; If positive then go draw a line normally
        LBEQ    LineDrawDot1_HIG153    ; If zero then go SET one single pixel
        LDU     startX          ; Otherwise flip the startx and endx coordinates
        STU     endX            ;
        STX     startX          ;

ReadyToDoHorizontalLine_HIG153:
* See if we have more then 16 pixels to draw
!       LDD     endX
        SUBD    startX          ;
        CMPD    #8             
        LBLS    LineNotHorizontal_HIG153  ; If the size is <= 8 then go draw the line normally
        PSHS    D               ; Save the length of the line
; Draw a horizontal Line
        CLRA
        LDB     startX+1        ; A=X starting position
        ANDB    #%00000011      ; Keep only the last 2 bits range of 0 to 3      
        ADDB    #3              ; Add 3
;        PSHS    D               ; Save the # of pixels to draw for this horizontal line
        ADDD    ,S++            ; Length of the line + bits
        PSHS    D               ; Save new length
        CLRA
        LDB     endX+1          ; A=X ending value
        ANDB    #%00000011      ; Keep only the last 2 bits range of 0 to 3    
        PSHS    D               ; Save the # of pixels to draw for this horizontal line
        LDD     2,S
        SUBD    ,S             ; B=B-end pixels
        LEAS    4,S             ; Fix the stack
; Turn pixels into bytes
        LSRA
        RORB                    ; B=B/2
        LSRB                    ; B=B/4, we now have the number of bytes to draw
        DECB
        PSHS    B               ; Save the # of bytes to draw for this horizontal line
        LDA     startY+1        ; A=Y value

        LDB     #BytesPerRow_HIG153 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     startX          ; X=X value
        LSRA
        RORB
        LSRB                    ; B=D/4
        ABX                     ; X now has the value of y * 80 + X/4 (we now have our screen location)

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
        LDU     #LineDrawSetTableStart_HIG153
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
        LDU     #LineDrawSetTableEnd_HIG153
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

LineDrawSetTableStart_HIG153:
        FCB     %11111111       ; Pixel 0
        FCB     %00111111       ; Pixel 1
        FCB     %00001111       ; Pixel 2
        FCB     %00000011       ; Pixel 3

LineDrawSetTableEnd_HIG153:
        FCB     %11000000       ; Pixel 0
        FCB     %11110000       ; Pixel 1
        FCB     %11111100       ; Pixel 2
        FCB     %11111111       ; Pixel 3

; PSET(startX , startY , 1)
LineDrawDot1_HIG153:
        LDX     startX          ; X = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_HIG153      ; Plot the pixel
        JMP     ,Y              ; Return

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal_HIG153:
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
LINELoop_HIG153:
; PSET(startX , startY , 1)
        LDX     startX          ; X = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_HIG153      ; Plot the pixel

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
        BRA     LINELoop_HIG153       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop_HIG153       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S
BOX_HIG153:
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

; IF BoxEndX < BoxStartX THEN
        LDX     BoxStartX   
        CMPX    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
; D = BoxEndX
        LDD     BoxEndX  
; BoxEndX = BoxStartX
        STX     BoxEndX         ; Save Numeric variable
; BoxStartX = D      
        STD     BoxStartX       ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDB     BoxStartY   
        CMPB    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
; D = BoxEndY
        LDA     BoxEndY  
; BoxEndY = BoxStartY   
        STB     BoxEndY         ; Save Numeric variable
; BoxStartY = D      
        STA     BoxStartY       ; Save Numeric variable
; END IF
!                               ; END IF line

* Draw the top line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot0_HIG153:
!       JSR     SET_HIG153      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot1_HIG153:
!       JSR     SET_HIG153      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot2_HIG153:
!       JSR     SET_HIG153      ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxEndX         ; B = BoxEndX
BoxDrawDot3_HIG153:
!       JSR     SET_HIG153      ; Go draw the pixel on screen
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
BoxFill_HIG153:
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

; PSET a dot on screen a PMODE 4 screen
; Enter with:
; A = y coordinate
; B = x coordinate

; IF BoxEndX < BoxStartX THEN
        LDX     BoxStartX   
        CMPX    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
; D = BoxEndX
        LDD     BoxEndX  
; BoxEndX = BoxStartX   
        STX     BoxEndX         ; Save Numeric variable
; BoxStartX = D      
        STD     BoxStartX       ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDB     BoxStartY   
        CMPB    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
; D = BoxEndY
        LDA     BoxEndY  
; BoxEndY = BoxStartY   
        STB     BoxEndY         ; Save Numeric variable
; BoxStartY = D      
        STA     BoxStartY       ; Save Numeric variable
; END IF
!                               ; END IF line

* Draw the top line of the box
        LDA     BoxStartY       ; A = BoxStartY
        STA     ,-S             ; Save the y coordinate in the stack
BFillLoop_HIG153:
        LDX     BoxStartX       ; B = BoxStartX
!       JSR     SET_HIG153      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_HIG153 ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return
