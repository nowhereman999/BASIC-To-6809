; Line commands
; Enter with:
; x at 5,S
; y at 4,S
; x1 at 3,S
; y1 at 2,S
LINE_IA:
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

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
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
LINELoop_IA:
; PSET(startX , startY , 1)
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     SET_IA        ; Plot the pixel

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
        BRA     LINELoop_IA       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop_IA       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S
BOX_IA:
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
!       JSR     SET_IA      ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
; Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_IA           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_IA           ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxEndX         ; B = BoxEndX
        DECB
!       JSR     SET_IA           ; Go draw the pixel on screen
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
BoxFill_IA:
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
BFillLoop_IA:
        LDB     BoxStartX       ; B = BoxStartX
!       JSR     SET_IA           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BNE     <               ; If <>, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_IA       ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return
