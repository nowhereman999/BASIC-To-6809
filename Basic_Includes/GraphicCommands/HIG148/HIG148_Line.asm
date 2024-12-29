
* Line commands
* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
LINE_HIG148:
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

        LDA     LineColour      ; Get the line colour
        BNE     DoLINE_HIG148     ; If it's not zero then draw white line
RESETLINE_HIG148:
        LDU     #RESET_HIG148     ; Self mod address of RESET routine
        BRA     >
DoLINE_HIG148:
        LDU     #SET_HIG148       ; Self mod address of SET routine
!       STU     LineDrawDot2_HIG148+1  ; Address where to draw the dot

; Test for a horizontal line
        CMPB    startY+1        ; Compare the starting y coordinate with the ending y coordinate
        BNE     LineNotHorizontal_HIG148  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDX     endX            ; B = ending x coordinate
        CMPX    startX          ; Compare with starting x coordinate
        BHI     >               ; If positive then go draw a line normally
        BEQ     LineDrawDot1_HIG148    ; If zero then go SET one single pixel
        LDU     startX          ; Otherwise flip the startx and endx coordinates
        STU     endX            ;
        STX     startX          ;
* See if we have more then 16 pixels to draw
!       LDD     endX
        SUBD    startX          ;
        CMPD    #16             ; If we have more then 16 pixels to draw then go draw the line normally
        BLS     LineNotHorizontal_HIG148  ; If the size is <= 16 then go draw the line normally

; Turn pixels into bytes
        LSRA
        RORB
        LSRB
        LSRB                    ; B=D/8, we now have the number of bytes to draw
        DECB
        PSHS    B               ; Save the # of pixels to draw for this horizontal line

; Draw the bits at the beginning that aren't a complete byte
        LDA     startY+1        ; A=Y value
        LDB     #BytesPerRow_HIG148 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     startX
        LSRA
        RORB
        LSRB
        LSRB                    ; B=D/8, we now have the number of bytes to draw
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)

* Fill the pixels on the left side of the line then draw bytes
        LDA     LineColour      ; Get the line colour
        BNE     LineHorizontalSET_HIG148     ; If it's not zero then draw white line

* Do the RESET version of a Horizontal line
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the starting bit of the x coordinate
        LDU     #LineDrawSetTableStart_HIG148
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
        LDU     #LineDrawSetTableEnd_HIG148
        LDA     B,U             ; A = the pixels to set from the table
        ANDA    ,X              ; OR the byte with the pixel on screen
        STA     ,X              ; Store the byte byte
        JMP     ,Y              ; Return

* Do the SET version
LineHorizontalSET_HIG148:
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the starting bit of the x coordinate
        LDU     #LineDrawSetTableStart_HIG148
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
        LDU     #LineDrawSetTableEnd_HIG148
        LDA     B,U             ; A = the pixels to set from the table
        COMA                    ; flip the bits
        ORA     ,X              ; OR the byte with the pixel on screen
        STA     ,X              ; Store the byte byte
        JMP     ,Y              ; Return

LineDrawSetTableStart_HIG148:
        FCB     %11111111       ; Pixel 0 Set
        FCB     %01111111       ; Pixel 1 Set
        FCB     %00111111       ; Pixel 2 Set
        FCB     %00011111       ; Pixel 3 Set
        FCB     %00001111       ; Pixel 4 Set
        FCB     %00000111       ; Pixel 5 Set
        FCB     %00000011       ; Pixel 6 Set
        FCB     %00000001       ; Pixel 7 Set
        FCB     %00000000       ; 
LineDrawSetTableEnd_HIG148:

; PSET(startX , startY , 1)
LineDrawDot1_HIG148:
        LDX     startX          ; X = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     ,U              ; Plot the pixel (X points at the PSET or PRESET routines)
        JMP     ,Y              ; Return

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal_HIG148:
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
LINELoop_HIG148:
; PSET(startX , startY , 1)
        LDX     startX          ; X = x coordinate
        LDA     startY+1        ; A = y coordinate
LineDrawDot2_HIG148:
        JSR     SET_HIG148        ; Plot the pixel

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
        BRA     LINELoop_HIG148       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop_HIG148       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S

BOX_HIG148:
        LDA     LineColour      ; Get the line colour
        BNE     DoBOX_HIG148      ; If it's not zero then draw white Box
PRESETBOX_HIG148:
        LDD     #RESET_HIG148        ; Self mod address of PRESET routine
        BRA     >
DoBOX_HIG148:
        LDD     #SET_HIG148          ; Self mod address of PSET routine
!       STD     BoxDrawDot0_HIG148+1
        STD     BoxDrawDot1_HIG148+1
        STD     BoxDrawDot2_HIG148+1
        STD     BoxDrawDot3_HIG148+1

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

;        PULS    Y               ; Y = return address
;        LDU     7,S
;        STU     BoxStartY       ; Store in BoxStartY & BoxStartX
;        LDU     5,S
;        STU     BoxEndY         ; Store in BoxEndY & BoxEndX
;        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
;        LEAS    4,S             ; Fix the stack
;        PSHS    A,X,U           ; Restore them where they need to be

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
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot0_HIG148:
!       JSR     SET_HIG148      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot1_HIG148:
!       JSR     SET_HIG148      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot2_HIG148:
!       JSR     SET_HIG148      ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxEndX         ; B = BoxEndX
BoxDrawDot3_HIG148:
!       JSR     SET_HIG148      ; Go draw the pixel on screen
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

BoxFill_HIG148:
        LDA     LineColour      ; Get the line colour
        BNE     DoBoxFill_HIG148  ; If it's not zero then fill a white Box
PRESETBoxFill_HIG148:
        LDD     #RESET_HIG148          ; Self mod address of PSET routine
        BRA     >
DoBoxFill_HIG148:
        LDD     #SET_HIG148          ; Self mod address of PSET routine
!       STD     BoxFillDrawDot0_HIG148+1

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

;        PULS    Y               ; Y = return address
;        LDU     7,S
;        STU     BoxStartY       ; Store in BoxStartY & BoxStartX
;        LDU     5,S
;        STU     BoxEndY         ; Store in BoxEndY & BoxEndX
;        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
;        LEAS    4,S             ; Fix the stack
;        PSHS    A,X,U           ; Restore them where they need to be

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
BFillLoop_HIG148:
        LDX     BoxStartX       ; B = BoxStartX
BoxFillDrawDot0_HIG148:
!       JSR     SET_HIG148      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_HIG148 ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return
