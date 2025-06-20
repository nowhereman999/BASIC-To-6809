
* Line commands
* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
LINE_HIG131:
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

        LDA     LineColour      ; Get the line colour
        BNE     DoLINE_HIG131     ; If it's not zero then draw white line
RESETLINE_HIG131:
        LDX     #RESET_HIG131     ; Self mod address of RESET routine
        BRA     >
DoLINE_HIG131:
        LDX     #SET_HIG131       ; Self mod address of SET routine
!       STX     LineDrawDot2_HIG131+1  ; Address where to draw the dot

; Test for a horizontal line
        CMPB    startY+1        ; Compare the starting y coordinate with the ending y coordinate
        BNE     LineNotHorizontal_HIG131  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDB     endX+1          ; B = ending x coordinate
        CMPB    startX+1        ; Compare with starting x coordinate
        BHI     >               ; If positive then go draw a line normally
        BEQ     LineDrawDot1_HIG131    ; If zero then go SET one single pixel
        LDA     startX+1          ; Otherwise flip the startx and endx coordinates
        LDB     endX+1          ; and store them in the variables
        STA     endX+1          ;
        STB     startX+1        ;
* See if we have more then 16 pixels to draw
!       LDB     endX+1
        SUBB    startX+1        ;
        CMPB    #16             ; If we have more then 16 pixels to draw then go draw the line normally
        BLS     LineNotHorizontal_HIG131  ; If the size is <= 16 then go draw the line normally
        
; Turn pixels into bytes
        LDA     startX+1
        ANDA    #%00000111
        PSHS    A
        ADDB    ,S+
        LSRB                    ; B=B/2
        LSRB                    ; B=B/4
        LSRB                    ; B=B/8, we now have the number of bytes to draw
        DECB
        PSHS    B               ; Save the # of pixels to draw for this horizontal line

; Draw the bits at the beginning that aren't a complete byte
        LDA     startY+1        ; A=Y value
        LDB     #BytesPerRow_HIG131 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDB     startX+1        ; B=X value
        LSRB
        LSRB
        LSRB                    ; B=B/8
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)

* Fill the pixels on the left side of the line then draw bytes
        LDA     LineColour      ; Get the line colour
        BNE     LineHorizontalSET_HIG131     ; If it's not zero then draw white line

* Do the RESET version of a Horizontal line
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the starting bit of the x coordinate
        LDU     #LineDrawSetTableStart_HIG131
        LDA     B,U             ; A = the pixels to reset from the table
        COMA
        ANDA    ,X              ; OR the byte with the pixel on screen
        STA     ,X+             ; Store the byte move to the next byte
        PULS    B               ; Restore the # of pixels to draw for this horizontal line
        CLRA                    ; A = $00 (all 8 pixels reset)
!       STA     ,X+             ; draw 8 pixels
        DECB                    ; Decrement the # of Bytes to draw
        BNE     <
* Draw the pixels on the right side of the line
        LDB     endX+1          ; B = ending x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the ending bit of the x coordinate
        SUBB    #8              ; subtract 8 from the ending bit, B now is a value from -8 to -1
        LDU     #LineDrawSetTableEnd_HIG131
        LDA     B,U             ; A = the pixels to set from the table
        ANDA    ,X              ; OR the byte with the pixel on screen
        STA     ,X              ; Store the byte byte
        JMP     ,Y              ; Return

* Do the PSET version
LineHorizontalSET_HIG131:
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the starting bit of the x coordinate
        LDU     #LineDrawSetTableStart_HIG131
        LDA     B,U             ; A = the pixels to set from the table
        ORA     ,X              ; OR the byte with the pixel on screen
        STA     ,X+             ; Store the byte move to the next byte
        PULS    B               ; Restore the # of pixels to draw for this horizontal line
        LDA     #$FF            ; A = $FF (all 8 pixels set)
!       STA     ,X+             ; draw 8 pixels
        DECB                    ; Decrement the # of Bytes to draw
        BNE     <
* Draw the pixels on the right side of the line
        LDB     endX+1          ; B = ending x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the ending bit of the x coordinate
        SUBB    #8              ; subtract 8 from the ending bit, B now is a value from -8 to -1
        LDU     #LineDrawSetTableEnd_HIG131
        LDA     B,U             ; A = the pixels to set from the table
        COMA                    ; flip the bits
        ORA     ,X              ; OR the byte with the pixel on screen
        STA     ,X              ; Store the byte byte
        JMP     ,Y              ; Return

LineDrawSetTableStart_HIG131:
        FCB     %11111111       ; Pixel 0 Set
        FCB     %01111111       ; Pixel 1 Set
        FCB     %00111111       ; Pixel 2 Set
        FCB     %00011111       ; Pixel 3 Set
        FCB     %00001111       ; Pixel 4 Set
        FCB     %00000111       ; Pixel 5 Set
        FCB     %00000011       ; Pixel 6 Set
        FCB     %00000001       ; Pixel 7 Set
        FCB     %00000000       ; 
LineDrawSetTableEnd_HIG131:

; PSET(startX , startY , 1)
LineDrawDot1_HIG131:
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     ,X              ; Plot the pixel (X points at the PSET or PRESET routines)
        JMP     ,Y              ; Return

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal_HIG131:
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
LINELoop_HIG131:
; PSET(startX , startY , 1)
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
LineDrawDot2_HIG131:
        JSR     SET_HIG131        ; Plot the pixel

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
        BRA     LINELoop_HIG131       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop_HIG131       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S
BOX_HIG131:
        LDA     LineColour      ; Get the line colour
        BNE     DoBOX_HIG131      ; If it's not zero then draw white Box
PRESETBOX_HIG131:
        LDD     #RESET_HIG131        ; Self mod address of PRESET routine
        BRA     >
DoBOX_HIG131:
        LDD     #SET_HIG131          ; Self mod address of PSET routine
!       STD     BoxDrawDot0_HIG131+1
        STD     BoxDrawDot1_HIG131+1
        STD     BoxDrawDot2_HIG131+1
        STD     BoxDrawDot3_HIG131+1
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

; IF BoxEndX < BoxStartX THEN
        LDA     BoxStartX   
        CMPA    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
; D = BoxEndX
        LDA     BoxEndX  
; BoxEndX = BoxStartX
        LDB     BoxStartX   
        STB     BoxEndX         ; Save Numeric variable
; BoxStartX = D      
        STA     BoxStartX       ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDA     BoxStartY   
        CMPA    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
; D = BoxEndY
        LDA     BoxEndY  
; BoxEndY = BoxStartY
        LDB     BoxStartY   
        STB     BoxEndY         ; Save Numeric variable
; BoxStartY = D      
        STA     BoxStartY       ; Save Numeric variable
; END IF
!                               ; END IF line

; Draw the top line of the box
        INC     BoxEndX         ; Make sure we can handle an end value of 255 properly
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
BoxDrawDot0_HIG131:
!       JSR     SET_HIG131      ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
; Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDB     BoxStartX       ; B = BoxStartX
BoxDrawDot1_HIG131:
!       JSR     SET_HIG131           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
BoxDrawDot2_HIG131:
!       JSR     SET_HIG131           ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxEndX         ; B = BoxEndX
        DECB
BoxDrawDot3_HIG131:
!       JSR     SET_HIG131           ; Go draw the pixel on screen
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

BoxFill_HIG131:
        LDA     LineColour      ; Get the line colour
        BNE     DoBoxFill_HIG131  ; If it's not zero then fill a white Box
PRESETBoxFill_HIG131:
        LDD     #RESET_HIG131          ; Self mod address of PSET routine
        BRA     >
DoBoxFill_HIG131:
        LDD     #SET_HIG131          ; Self mod address of PSET routine
!       STD     BoxFillDrawDot0_HIG131+1
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

; IF BoxEndX < BoxStartX THEN
        LDA     BoxStartX   
        CMPA    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
; D = BoxEndX
        LDA     BoxEndX  
; BoxEndX = BoxStartX
        LDB     BoxStartX   
        STB     BoxEndX         ; Save Numeric variable
; BoxStartX = D      
        STA     BoxStartX       ; Save Numeric variable
; END IF
!                               ; END IF line
; IF BoxEndY < BoxStartY THEN
        LDA     BoxStartY   
        CMPA    BoxEndY         ; Compare A with BoxEndY
        BLS     >               ; If <=, then skip ahead
; D = BoxEndY
        LDA     BoxEndY  
; BoxEndY = BoxStartY
        LDB     BoxStartY   
        STB     BoxEndY         ; Save Numeric variable
; BoxStartY = D      
        STA     BoxStartY       ; Save Numeric variable
; END IF
!                               ; END IF line

* Draw the top line of the box
        INC     BoxEndX         ; Make sure we can handle an end value of 255 properly
        LDA     BoxStartY       ; A = BoxStartY
        STA     ,-S             ; Save the y coordinate in the stack
BFillLoop_HIG131:
        LDB     BoxStartX       ; B = BoxStartX
BoxFillDrawDot0_HIG131:
!       JSR     SET_HIG131           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_HIG131       ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return
