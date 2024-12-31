* Line commands
* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
LINE_SG6:
        LDA     LineColour      ; Get the colour requested
        STA     C_SG6           ; Save the colour for the line command to use
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
LineNotHorizontal4_SG6:
        LDD     endX     
        SUBD    startX     
        BPL     >               ; If positive simply skip over changing D's value
        PSHS    D               ; Save D on the stack
        LDD     #$0000          ; D=0
        SUBD    ,S++            ; D=0-D, fix the stack
!       STD     deltaX          ; Save Numeric variable
; deltaY = ABS(endY -startY)
        LDD     endY     
        SUBD    startY     
        BPL     >               ; If positive simply skip over changing D's value
        PSHS    D               ; Save D on the stack
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
LINELoop4_SG6:
; PSET(startX , startY , 1)
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        STA     Y_SG6       ; save the y co-ordinate
        STB     X_SG6       ; save the x co-ordinate
        JSR     SET_SG6     ; Go draw the pixel

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
        BRA     LINELoop4_SG6       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop4_SG6       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
BOX_SG6:
        LDA     LineColour      ; Get the colour requested
        STA     C_SG6           ; Save the colour for the line command to use

        PULS    Y               ; Y = return address
        PULS    D               ; A = End y , B = End x
        STA     BoxEndY
        STB     BoxEndX
        PULS    D               ; A = Start y, B = Start x
        STA     BoxStartY
        STB     BoxStartX

; IF BoxEndX < BoxStartX THEN
;        LDA     BoxStartX   
        CMPB    BoxEndX         ; Compare A with BoxEndX
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
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
BoxDrawDot0_SG6:
!       JSR     DoSetSaveAB_SG6 ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDB     BoxStartX       ; B = BoxStartX
BoxDrawDot1_SG6:
!       JSR     DoSetSaveAB_SG6 ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxStartX       ; B = BoxStartX
BoxDrawDot2_SG6:
!       JSR     DoSetSaveAB_SG6           ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxEndX         ; B = BoxEndX
BoxDrawDot3_SG6:
!       JSR     DoSetSaveAB_SG6           ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
        JMP     ,Y              ; Return

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
BoxFill_SG6:
        LDA     LineColour      ; Get the colour requested
        STA     C_SG6           ; Save the colour for the line command to use

        PULS    Y               ; Y = return address
        PULS    D               ; A = End y , B = End x
        STA     BoxEndY
        STB     BoxEndX
        PULS    D               ; A = Start y, B = Start x
        STA     BoxStartY
        STB     BoxStartX

; IF BoxEndX < BoxStartX THEN
        CMPB    BoxEndX         ; Compare A with BoxEndX
        BLS     >               ; If <=, then skip ahead
; D = BoxEndX                   ; otherwise flip them
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
        LDA     BoxStartY       ; A = BoxStartY
        PSHS    A               ; Save the y coordinate in the stack
BFillLoop_SG6:
        LDB     BoxStartX       ; B = BoxStartX
BoxFillDrawDot0_SG6:
!       JSR     DoSetSaveAB_SG6     ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_SG6   ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return
