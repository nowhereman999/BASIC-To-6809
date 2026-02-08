
* Paint/Flood fill a region of the screen
; Enter with:
; 2,S & 3,S = Destination Colour and Source Colour": GoSub AO
; 4,S & 5,S = y & x co-ordinates": GoSub AO
;
PAINT_HIG130:
; Set up starting coordinates in X and Y
        PULS    Y               ; Y = return address
        LDD     2+3,S           ; Destination Colour and Source Colour
        STD     Destination     ; Save the Destination Colour and Source Colour
        STA     LineColour      ; Save the line colour
        LDD     4+3,S           ; get the y & x co-ordinates
        STA     PaintY+1        ; Save the y co-ordinate
        STB     currentX+1      ; Save the x co-ordinate

        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
        LEAS    4,S             ; Fix the stack
        PSHS    A,X,U           ; Restore them where they need to be
        PSHS    Y               ; Save the return address

        LDA     Destination     ; Save the Destination Colour and Source Colour
        CMPA    SourceColour    ; Are they both the same?
        BNE     >
        RTS                     ; return if they are the same
        
!       CLRA
        STA     PaintY          ; Clear MSB of the y co-ordinate
        STA     currentX        ; Save the x co-ordinate
        LDU     PaintY          ; U = PaintY
        LDX     currentX        ; X = currentX

; Initialize stack with starting coordinates
; StackPointer = 0
        STS     PaintStack      ; Save the starting stack address
        PSHS    X,U             ; Save the Y co-ordinates & the X co-ordinate starting point on screen

; WHILE StackPointer > 0
PaintWhileLoop1_HIG130:           ; Start of WHILE/WEND loop
        CMPS    PaintStack      ; Compare the stack pointer with the stack address
        LBEQ    PaintWend_01_HIG130    ; If Equal, then jump to the end of the WHILE/WEND loop

        PULS    X,U             ; Restore the X co-ordinates & the Y co-ordinate starting point on screen
        STU     PaintY          ; Save Numeric variable
; Move to the left boundary of the fill area
; WHILE currentX > = 0 AND PPOINT(currentX , y) = oldColor
;
; currentX = x        
        STX     currentX        ; Save Numeric variable
; Move to the left boundary of the fill area
; WHILE currentX > = 0 AND PPOINT(currentX , y) = SourceColour
PaintWhileLoop2_HIG130                ; Start of WHILE/WEND loop
        LDX     currentX 
        BMI     PaintWend_02_HIG130   ; If the result is a false then goto the end of the WHILE/WEND loop
        LDA     PaintY+1
        LDB     currentX+1
        JSR     POINT_HIG130          ; Return with the colour value on screen in B
        CMPB    SourceColour        ; Compare the existing colour with the Border Colour
        BNE     PaintWend_02_HIG130   ; If they are not equal then goto the end of the WHILE/WEND loop (paint the line to the right)
; currentX = currentX - 1
; If they are equal then move to the next pixel to check
        LDD     currentX     
        SUBD    #1     
        STD     currentX            ; Save Numeric variable
; WEND
        BRA    PaintWhileLoop2_HIG130 ; Goto the start of this WHILE/WEND loop

PaintWend_02_HIG130                   ; End of WHILE/WEND loop
; currentX = currentX + 1
        LDD     currentX     
        ADDD    #1     
        STD     currentX        ; Save Numeric variable

; ' Fill the line to the right and push boundary pixels
; spanAbove = false
        LDD     #FALSE    
        STD     spanAbove   ; Save Numeric variable
; spanBelow = false
        LDD     #FALSE    
        STD     spanBelow   ; Save Numeric variable

; WHILE currentX < SCREEN_WIDTH AND PPOINT(currentX , y) = SourceColour
PaintWhileLoop3_HIG130                ; Start of WHILE/WEND loop
        LDX     currentX
        CMPX    #ScreenWidth_HIG130   ; Check if X is less than ScreenWidth
        LBHS    PaintWend_03_HIG130   ; If the result is a false then goto the end of the WHILE/WEND loop

        LDA     PaintY+1
        LDB     currentX+1
        JSR     POINT_HIG130     ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour       ; Compare the old color with the new color
        LBNE    PaintWend_03_HIG130  ; If they are not equal then goto the end of the WHILE/WEND loop

; SET(currentX , y , FillColour)
        LDA     PaintY+1
        LDB     currentX+1
        JSR     SET_HIG130       ; Plot the pixel

; IF spanAbove = false AND y > 0 AND PPOINT(currentX , y -1) = SourceColour THEN
        LDX     spanAbove       ; Get the spanAbove value
        BNE     PaintELSE_02_HIG130        ; If result is <> zero = FALSE then jump to ELSE/Next line

        LDX     PaintY          ; Get the Y co-ordinate
        BLE     PaintELSE_02_HIG130        ; If the result is <= 0 then jump to ELSE/Next line

        LDA     PaintY+1
        DECA                    ; Decrement the Y co-ordinate
        LDB     currentX+1
        JSR     POINT_HIG130      ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour        ; Compare the old color with the new color
        BNE     PaintELSE_02_HIG130        ; If they are not equal then goto the end of the WHILE/WEND loop

; ' push(stack , currentX , y - 1)
        LDX     currentX 
        LDU     PaintY          ; Get the Y co-ordinate
        LEAU    -1,U            ; Decrement the Y co-ordinate
        PSHS    X,U             ; Save the memory location to write the value that this array equals

; spanAbove = true
        LDD     #TRUE     
        STD     spanAbove   ; Save Numeric variable
        BRA     PaintIFDone_02_HIG130    ; Jump to END IF line
; ELSE
PaintELSE_02_HIG130                              ; If result is zero = FALSE then jump to ELSE/Next line
; IF spanAbove = true AND y > 0 AND PPOINT(currentX , y -1) < > SourceColour THEN
        LDX     spanAbove       ; Get the spanAbove value
        BEQ     PaintIFDone_03_HIG130      ; If result is zero = FALSE then jump to END IF line

        LDX     PaintY          ; Get the Y co-ordinate
        BLE     PaintIFDone_03_HIG130      ; If result is <= 0 then jump to END IF line

        LDA     PaintY+1
        DECA                    ; Decrement the Y co-ordinate
        LDB     currentX+1
        JSR     POINT_HIG130      ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour        ; Compare the old color with the new color
        BEQ     PaintIFDone_03_HIG130      ; If result is = then jump to END IF line

; spanAbove = false
        LDD     #FALSE    
        STD     spanAbove   ; Save Numeric variable
; END IF
PaintIFDone_03_HIG130                              ; END IF line
; END IF
PaintIFDone_02_HIG130                              ; END IF line
; IF spanBelow = false AND y < SCREEN_HEIGHT -1 AND PPOINT(currentX , y + 1) = SourceColour THEN
        LDX     spanBelow   
        BNE     PaintELSE_04_HIG130        ; If result is <> zero then jump to ELSE/Next line

        LDX     #ScreenHeight_HIG130
        LEAX    -1,X            ; Decrement the screen height comaprison value
        CMPX    PaintY          ; Check if X is with the y co-ordinate
        BLS     PaintELSE_04_HIG130        ; If the result is a false then jump to ELSE/Next line

        LDA     PaintY+1
        INCA                    ; Decrement the Y co-ordinate
        LDB     currentX+1
        JSR     POINT_HIG130      ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour        ; Compare the old color with the new color
        BNE     PaintELSE_04_HIG130        ; If the result is <> then jump to ELSE/Next line

; ' push(stack , currentX , y + 1)
        LDX     currentX 
        LDU     PaintY          ; Get the Y co-ordinate
        LEAU    1,U             ; Increment the Y co-ordinate
        PSHS    X,U             ; Save the memory location to write the value that this array equals

; spanBelow = true
        LDD     #TRUE     
        STD     spanBelow   ; Save Numeric variable
; ELSE
        BRA     PaintIFDone_04_HIG130    ; Jump to END IF line
PaintELSE_04_HIG130                              ; If result is zero = FALSE then jump to ELSE/Next line
; IF spanBelow = true AND y < SCREEN_HEIGHT -1 AND PPOINT(currentX , y + 1) < > SourceColour THEN
        LDX     spanBelow       ; Get the spanBelow value
        BEQ     PaintIFDone_05_HIG130      ; If result is zero = FALSE then jump to END IF line

        LDX     #ScreenHeight_HIG130
        LEAX    -1,X            ; Decrement the screen height comaprison value
        CMPX    PaintY          ; Check if X is with the y co-ordinate
        BLS     PaintIFDone_05_HIG130      ; If result is >= then jump to END IF line

        LDA     PaintY+1
        INCA                    ; Decrement the Y co-ordinate
        LDB     currentX+1
        JSR     POINT_HIG130      ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour        ; Compare the old color with the new color
        BEQ     PaintIFDone_05_HIG130      ; If the result is = then jump to ELSE/Next line

; spanBelow = false
        LDD     #FALSE    
        STD     spanBelow   ; Save Numeric variable
; END IF
PaintIFDone_05_HIG130                              ; END IF line
; END IF
PaintIFDone_04_HIG130                              ; END IF line
; currentX = currentX + 1
        LDD     currentX 
        ADDD    #1
        STD     currentX ; Save Numeric variable
; WEND
        LBRA    PaintWhileLoop3_HIG130  ; Goto the start of this WHILE/WEND loop
PaintWend_03_HIG130                       ; End of WHILE/WEND loop
; WEND
        LBRA    PaintWhileLoop1_HIG130  ; Goto the start of this WHILE/WEND loop
PaintWend_01_HIG130                       ; End of WHILE/WEND loop

DonePaint_HIG130:
        LDS     PaintStack      ; Restore the stack address
        RTS      ; Return
        