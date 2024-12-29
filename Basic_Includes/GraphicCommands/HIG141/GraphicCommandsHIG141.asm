; Graphics commands for screen mode HIG141
; Resolution of 320x225x2 colours
ScreenWidth_HIG141    EQU 320
ScreenHeight_HIG141   EQU 225
BytesPerRow_HIG141    EQU ScreenWidth_HIG141/8
Screen_Size_HIG141    EQU $1F40
;
; SET a dot on screen
; Enter with:
; A = y coordinate
; X = x coordinate
;
; x location is 0 to 319 (40 bytes) per row
; y location is 0 to 224 (225 rows)
;
; Byte to draw pixel on screen
; = 0111 1xxx = 15 is the byte
; = xxxx x111 = pixel value
;
; A=y value, X=x value
DoSet_HIG141:
        TST     LineColour      ; Get the Set colour
        BEQ     RESET_HIG141      ; If it's not zero then draw white dot
SET_HIG141:
        PSHS    A,X             ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_HIG141 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     1,S
        LSRA
        RORB
        LSRB
        LSRB                    ; B=D/8
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)

        LDB     2,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTable_HIG141 ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ORA     B,U             ; Or original Byte value with the pixel the user wants to set
        STA     ,X              ; Write new byte to the screen
        PULS    A,X,PC            ; Restore D,X & U and return

PixelTable_HIG141:
        FCB     %10000000 Pixel 0
        FCB     %01000000 Pixel 1
        FCB     %00100000 Pixel 2
        FCB     %00010000 Pixel 3
        FCB     %00001000 Pixel 4
        FCB     %00000100 Pixel 5
        FCB     %00000010 Pixel 6
        FCB     %00000001 Pixel 7

; PRESET a dot on screen
; Enter with:
; A = y coordinate
; X = x coordinate
;
; Make sure values of y are between 0 and 191 or bad things will happen
;
; x location is 0 to 159 (40 bytes) per row
; y location is 0 to 224 (225 rows)
;
; A=y value, X=x value
RESET_HIG141:
        PSHS    A,X             ; Save x & y coordinate on the stack
        LDB     #BytesPerRow_HIG141 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     1,S
        LSRA
        RORB
        LSRB
        LSRB                    ; B=D/8
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        LDB     2,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTableClear_HIG141 ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ANDA    B,U             ; AND original Byte value with the pixel the user wants to cleared
        STA     ,X              ; Write new byte to the screen
        PULS    A,X,PC            ; Restore D,X & U and return

PixelTableClear_HIG141:
        FCB     %01111111 Pixel 0
        FCB     %10111111 Pixel 1
        FCB     %11011111 Pixel 2
        FCB     %11101111 Pixel 3
        FCB     %11110111 Pixel 4
        FCB     %11111011 Pixel 5
        FCB     %11111101 Pixel 6
        FCB     %11111110 Pixel 7

; POINT get the value of a dot on screen
; Enter with:
; A = y coordinate
; X = x coordinate
; Returns with:
; B = Colour value of the point
* PMODE 4 POINT command
POINT_HIG141:
        PSHS    X               ; Save x coordinate on the stack
        LDB     #BytesPerRow_HIG141 ; MUL A by the number of bytes per row
        MUL      
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X has the row to start on
        LDD     ,S
        LSRA
        RORB
        LSRB
        LSRB                    ; B=D/8
        ABX                     ; X now has the value of Y = Y * 20 + X=X/2 (we now have our screen location)
        LDA     1,S             ; A = the pixel number, retore the stack
        ANDA    #%00000111      ; A = Pixel value (0 to 7)
        LDU     #PixelTable_HIG141 ; U points to the table of pixel values
        LDB     ,X              ; Get existing pixels in this byte from the screen
        ANDB    A,U             ; AND original Byte value with the pixel the user wants to get the value of
        BEQ     >
        LDB     #1              ; If the value is <> 0 make it 1
!       PULS    X,PC            ; Restore A,X & U and return

* Circle command
* Enter with:
* x Center is at 4,S
* y Center is at 3,S
* radius is at 2,S
; CIRCLE routine to draw a circle centered at (x_Center, y_Center) with radius r
CIRCLE_HIG141:
        LDA     LineColour      ; Get the line colour
        BNE     @Colour1        ; If it's not zero then draw white
        LDD     #RESET_HIG141     ; Get address of RESET for black pixels
        BRA     >
@Colour1:
        LDD     #SET_HIG141       ; Get address of SET for white pixels
!       STD     SelfModC1_HIG141+1 ; Selfmod the jump address
        STD     SelfModC2_HIG141+1 ; Selfmod the jump address
        STD     SelfModC3_HIG141+1 ; Selfmod the jump address
        STD     SelfModC4_HIG141+1 ; Selfmod the jump address
        STD     SelfModC5_HIG141+1 ; Selfmod the jump address
        STD     SelfModC6_HIG141+1 ; Selfmod the jump address
        STD     SelfModC7_HIG141+1 ; Selfmod the jump address
        STD     SelfModC8_HIG141+1 ; Selfmod the jump address

        LDD     10,S             ; Load x coordinate (x_Center) from stack
        STD     x_Center        ; Store in x_Center
        CLRA
        LDB     9,S             ; Load y coordinate (y_Center) from stack
        STD     y_Center        ; Store in y_Center
        LDD     7,S             ; Load radius (r) from stack
        STD     radius          ; Store in r
; x = 0
        LDD     #0
        STD     x0              ; x=0
; y = radius
        LDD     radius
        STD     y0              ; y=r
; d = 3 - 2 * radius
        LDD     #3
        SUBD    radius
        SUBD    radius               
        STD     decision          

; WHILE x < = y
CircleLoop_HIG141:     
        LDD     x0        
        CMPD    y0         ; Compare D with the value on the stack, fix the stack
        BLE     >
        RTS
!       BSR     PlotPoints_HIG141
; Update x, x = x + 1
        LDD     x0
        ADDD    #1
        STD     x0

; Update decision parameter and y if necessary
; if decision> 0:
        LDD     decision
        CMPD    #0
        BMI     >
; y = y - 1
        LDD     y0
        SUBD    #1
        STD     y0
; decision= decision+ 4 * (x - y) + 10
        LDD     x0
        SUBD    y0
        LSLB
        ROLA
        LSLB
        ROLA            ; D = 4 * (x - y)
        ADDD    #10
        ADDD    decision
        STD     decision
        BRA     CircleLoop_HIG141          ; Loop until x <= y
; else:
; decision = decision+ 4 * x + 6
!       LDD     x0
        LSLB
        ROLA
        LSLB
        ROLA                            ; D = 4 * x
        ADDD    #6
        ADDD    decision
        STD     decision
        BRA     CircleLoop_HIG141       ; Loop until x <= y

PlotPoints_HIG141:
; Plot (x + x_Center, y + y_Center)
        LDD     x0
        ADDD    x_Center
        TFR     D,X
        LDA     y0+1
        ADDA    y_Center+1
SelfModC1_HIG141:        
        JSR     SET_HIG141              ; Plot the pixel
; Plot (-x + x_Center, y + y_Center)
        LDD     x_Center
        SUBD    x0
        TFR     D,X
        LDA     y0+1
        ADDA    y_Center+1
SelfModC2_HIG141:
        JSR     SET_HIG141              ; Plot the pixel
; Plot (x + x_Center, -y + y_Center)
        LDD     x0
        ADDD    x_Center
        TFR     D,X
        LDA     y0+1
        NEGA
        ADDA    y_Center+1
SelfModC3_HIG141:
        JSR     SET_HIG141              ; Plot the pixel
; Plot (-x + x_Center, -y + y_Center)
        LDD     x_Center
        SUBD    x0
        TFR     D,X
        LDA     y0+1
        NEGA
        ADDA    y_Center+1
SelfModC4_HIG141:
        JSR     SET_HIG141              ; Plot the pixel
; Plot (y + x_Center, x + y_Center)
        LDD     y0
        ADDD    x_Center
        TFR     D,X
        LDD     x0
        ADDD    y_Center
        TFR     B,A                     ; A = B
SelfModC5_HIG141:
        JSR     SET_HIG141              ; Plot the pixel
; Plot (-y + x_Center, x + y_Center)
        LDD     x_Center
        SUBD    y0
        TFR     D,X
        LDD     x0
        ADDD    y_Center
        TFR     B,A                     ; A = B
SelfModC6_HIG141:
        JSR     SET_HIG141              ; Plot the pixel
; Plot (y + x_Center, -x + y_Center)
        LDD     y0
        ADDD    x_Center
        TFR     D,X
        LDD     y_Center
        SUBD    x0
        TFR     B,A                     ; A = B
SelfModC7_HIG141:
        JSR     SET_HIG141              ; Plot the pixel
; Plot (-y + x_Center, -x + y_Center)
        LDD     x_Center
        SUBD    y0
        TFR     D,X
        LDD     y_Center
        SUBD    x0
        TFR     B,A                     ; A = B
SelfModC8_HIG141:
        JSR     SET_HIG141              ; Plot the pixel
        RTS

* Line commands
* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
LINE_HIG141:
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
        BNE     DoLINE_HIG141     ; If it's not zero then draw white line
RESETLINE_HIG141:
        LDU     #RESET_HIG141     ; Self mod address of RESET routine
        BRA     >
DoLINE_HIG141:
        LDU     #SET_HIG141       ; Self mod address of SET routine
!       STU     LineDrawDot2_HIG141+1  ; Address where to draw the dot

; Test for a horizontal line
        CMPB    startY+1        ; Compare the starting y coordinate with the ending y coordinate
        BNE     LineNotHorizontal_HIG141  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDX     endX            ; B = ending x coordinate
        CMPX    startX          ; Compare with starting x coordinate
        BHI     >               ; If positive then go draw a line normally
        BEQ     LineDrawDot1_HIG141    ; If zero then go SET one single pixel
        LDU     startX          ; Otherwise flip the startx and endx coordinates
        STU     endX            ;
        STX     startX          ;
* See if we have more then 16 pixels to draw
!       LDD     endX
        SUBD    startX          ;
        CMPD    #16             ; If we have more then 16 pixels to draw then go draw the line normally
        BLS     LineNotHorizontal_HIG141  ; If the size is <= 16 then go draw the line normally

; Turn pixels into bytes
        LSRA
        RORB
        LSRB
        LSRB                    ; B=D/8, we now have the number of bytes to draw
        DECB
        PSHS    B               ; Save the # of pixels to draw for this horizontal line

; Draw the bits at the beginning that aren't a complete byte
        LDA     startY+1        ; A=Y value
        LDB     #BytesPerRow_HIG141 ; MUL A by the number of bytes per row
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
        BNE     LineHorizontalSET_HIG141     ; If it's not zero then draw white line

* Do the RESET version of a Horizontal line
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the starting bit of the x coordinate
        LDU     #LineDrawSetTableStart_HIG141
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
        LDU     #LineDrawSetTableEnd_HIG141
        LDA     B,U             ; A = the pixels to set from the table
        ANDA    ,X              ; OR the byte with the pixel on screen
        STA     ,X              ; Store the byte byte
        JMP     ,Y              ; Return

* Do the SET version
LineHorizontalSET_HIG141:
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the starting bit of the x coordinate
        LDU     #LineDrawSetTableStart_HIG141
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
        LDU     #LineDrawSetTableEnd_HIG141
        LDA     B,U             ; A = the pixels to set from the table
        COMA                    ; flip the bits
        ORA     ,X              ; OR the byte with the pixel on screen
        STA     ,X              ; Store the byte byte
        JMP     ,Y              ; Return

LineDrawSetTableStart_HIG141:
        FCB     %11111111       ; Pixel 0 Set
        FCB     %01111111       ; Pixel 1 Set
        FCB     %00111111       ; Pixel 2 Set
        FCB     %00011111       ; Pixel 3 Set
        FCB     %00001111       ; Pixel 4 Set
        FCB     %00000111       ; Pixel 5 Set
        FCB     %00000011       ; Pixel 6 Set
        FCB     %00000001       ; Pixel 7 Set
        FCB     %00000000       ; 
LineDrawSetTableEnd_HIG141:

; PSET(startX , startY , 1)
LineDrawDot1_HIG141:
        LDX     startX          ; X = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     ,U              ; Plot the pixel (X points at the PSET or PRESET routines)
        JMP     ,Y              ; Return

; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal_HIG141:
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
LINELoop_HIG141:
; PSET(startX , startY , 1)
        LDX     startX          ; X = x coordinate
        LDA     startY+1        ; A = y coordinate
LineDrawDot2_HIG141:
        JSR     SET_HIG141        ; Plot the pixel

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
        BRA     LINELoop_HIG141       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop_HIG141       ; GOTO 10

* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S
* Return address 0,S & 1,S

BOX_HIG141:
        LDA     LineColour      ; Get the line colour
        BNE     DoBOX_HIG141      ; If it's not zero then draw white Box
PRESETBOX_HIG141:
        LDD     #RESET_HIG141        ; Self mod address of PRESET routine
        BRA     >
DoBOX_HIG141:
        LDD     #SET_HIG141          ; Self mod address of PSET routine
!       STD     BoxDrawDot0_HIG141+1
        STD     BoxDrawDot1_HIG141+1
        STD     BoxDrawDot2_HIG141+1
        STD     BoxDrawDot3_HIG141+1

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
BoxDrawDot0_HIG141:
!       JSR     SET_HIG141      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot1_HIG141:
!       JSR     SET_HIG141      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Left line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxStartX       ; X = BoxStartX
BoxDrawDot2_HIG141:
!       JSR     SET_HIG141      ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDX     BoxEndX         ; B = BoxEndX
BoxDrawDot3_HIG141:
!       JSR     SET_HIG141      ; Go draw the pixel on screen
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

BoxFill_HIG141:
        LDA     LineColour      ; Get the line colour
        BNE     DoBoxFill_HIG141  ; If it's not zero then fill a white Box
PRESETBoxFill_HIG141:
        LDD     #RESET_HIG141          ; Self mod address of PSET routine
        BRA     >
DoBoxFill_HIG141:
        LDD     #SET_HIG141          ; Self mod address of PSET routine
!       STD     BoxFillDrawDot0_HIG141+1

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
BFillLoop_HIG141:
        LDX     BoxStartX       ; B = BoxStartX
BoxFillDrawDot0_HIG141:
!       JSR     SET_HIG141      ; Go draw the pixel on screen
        LEAX    1,X             ; Increment the x coordinate
        CMPX    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop_HIG141 ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return

* Paint/Flood fill a region of the screen
; Enter with:
; 2,S & 3,S = Destination Colour and Source Colour": GoSub AO
; 4,S & 5,S = y & x co-ordinates": GoSub AO
;
PAINT_HIG141:
; Set up starting coordinates in X and Y
        PULS    Y               ; Y = return address
        LDD     2+3,S           ; Destination Colour and Source Colour
        STD     Destination     ; Save the Destination Colour and Source Colour
        STA     LineColour      ; Save the line colour
        CLRA
        LDB     4+3,S           ; get the y & x co-ordinates
        STD     PaintY          ; Save the y co-ordinate
        LDX     5+3,S           ; Get the x co-ordinate
        STX     currentX        ; Save the x co-ordinate

        PULS    A,X,U           ; Get the CC & D & return address from the stack in A & X & U
        LEAS    5,S             ; Fix the stack
        PSHS    A,X,U           ; Restore them where they need to be
        PSHS    Y               ; Save the return address

        LDA     Destination     ; Save the Destination Colour and Source Colour
        CMPA    SourceColour    ; Are they both the same?
        BNE     >
        RTS                     ; return if they are the same
        
!       CLRA
        LDU     PaintY          ; U = PaintY
        LDX     currentX        ; X = currentX

; Initialize stack with starting coordinates
; StackPointer = 0
        STS     PaintStack      ; Save the starting stack address
        PSHS    X,U             ; Save the Y co-ordinates & the X co-ordinate starting point on screen

; WHILE StackPointer > 0
PaintWhileLoop1_HIG141:           ; Start of WHILE/WEND loop
        CMPS    PaintStack      ; Compare the stack pointer with the stack address
        BEQ     PaintWend_01_HIG141    ; If Equal, then jump to the end of the WHILE/WEND loop

        PULS    X,U             ; Restore the X co-ordinates & the Y co-ordinate starting point on screen
        STU     PaintY          ; Save Numeric variable
; Move to the left boundary of the fill area
; WHILE currentX > = 0 AND PPOINT(currentX , y) = oldColor
;
; currentX = x        
        STX     currentX        ; Save Numeric variable
; Move to the left boundary of the fill area
; WHILE currentX > = 0 AND PPOINT(currentX , y) = SourceColour
PaintWhileLoop2_HIG141                ; Start of WHILE/WEND loop
        LDX     currentX 
        BMI     PaintWend_02_HIG141   ; If the result is a false then goto the end of the WHILE/WEND loop
        LDA     PaintY+1
        LDX     currentX
        JSR     POINT_HIG141          ; Return with the colour value on screen in B
        CMPB    SourceColour        ; Compare the existing colour with the Border Colour
        BNE     PaintWend_02_HIG141   ; If they are not equal then goto the end of the WHILE/WEND loop (paint the line to the right)
; currentX = currentX - 1
; If they are equal then move to the next pixel to check
        LDD     currentX     
        SUBD    #1     
        STD     currentX            ; Save Numeric variable
; WEND
        BRA    PaintWhileLoop2_HIG141 ; Goto the start of this WHILE/WEND loop

PaintWend_02_HIG141                   ; End of WHILE/WEND loop
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
PaintWhileLoop3_HIG141                ; Start of WHILE/WEND loop
        LDX     currentX
        CMPX    #ScreenWidth_HIG141   ; Check if X is less than ScreenWidth
        BHS     PaintWend_03_HIG141   ; If the result is a false then goto the end of the WHILE/WEND loop

        LDA     PaintY+1
        LDX     currentX
        JSR     POINT_HIG141     ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour       ; Compare the old color with the new color
        BNE     PaintWend_03_HIG141  ; If they are not equal then goto the end of the WHILE/WEND loop

; SET(currentX , y , FillColour)
        LDA     PaintY+1
        LDX     currentX
        JSR     SET_HIG141       ; Plot the pixel

; IF spanAbove = false AND y > 0 AND PPOINT(currentX , y -1) = SourceColour THEN
        LDX     spanAbove       ; Get the spanAbove value
        BNE     PaintELSE_02_HIG141        ; If result is <> zero = FALSE then jump to ELSE/Next line

        LDX     PaintY          ; Get the Y co-ordinate
        BLE     PaintELSE_02_HIG141        ; If the result is <= 0 then jump to ELSE/Next line

        LDA     PaintY+1
        DECA                    ; Decrement the Y co-ordinate
        LDX     currentX
        JSR     POINT_HIG141      ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour        ; Compare the old color with the new color
        BNE     PaintELSE_02_HIG141        ; If they are not equal then goto the end of the WHILE/WEND loop

; ' push(stack , currentX , y - 1)
        LDX     currentX 
        LDU     PaintY          ; Get the Y co-ordinate
        LEAU    -1,U            ; Decrement the Y co-ordinate
        PSHS    X,U             ; Save the memory location to write the value that this array equals

; spanAbove = true
        LDD     #TRUE     
        STD     spanAbove   ; Save Numeric variable
        BRA     PaintIFDone_02_HIG141    ; Jump to END IF line
; ELSE
PaintELSE_02_HIG141                              ; If result is zero = FALSE then jump to ELSE/Next line
; IF spanAbove = true AND y > 0 AND PPOINT(currentX , y -1) < > SourceColour THEN
        LDX     spanAbove       ; Get the spanAbove value
        BEQ     PaintIFDone_03_HIG141      ; If result is zero = FALSE then jump to END IF line

        LDX     PaintY          ; Get the Y co-ordinate
        BLE     PaintIFDone_03_HIG141      ; If result is <= 0 then jump to END IF line

        LDA     PaintY+1
        DECA                    ; Decrement the Y co-ordinate
        LDX     currentX
        JSR     POINT_HIG141      ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour        ; Compare the old color with the new color
        BEQ     PaintIFDone_03_HIG141      ; If result is = then jump to END IF line

; spanAbove = false
        LDD     #FALSE    
        STD     spanAbove   ; Save Numeric variable
; END IF
PaintIFDone_03_HIG141                              ; END IF line
; END IF
PaintIFDone_02_HIG141                              ; END IF line
; IF spanBelow = false AND y < SCREEN_HEIGHT -1 AND PPOINT(currentX , y + 1) = SourceColour THEN
        LDX     spanBelow   
        BNE     PaintELSE_04_HIG141        ; If result is <> zero then jump to ELSE/Next line

        LDX     #ScreenHeight_HIG141
        LEAX    -1,X            ; Decrement the screen height comaprison value
        CMPX    PaintY          ; Check if X is with the y co-ordinate
        BLS     PaintELSE_04_HIG141        ; If the result is a false then jump to ELSE/Next line

        LDA     PaintY+1
        INCA                    ; Decrement the Y co-ordinate
        LDX     currentX
        JSR     POINT_HIG141      ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour        ; Compare the old color with the new color
        BNE     PaintELSE_04_HIG141        ; If the result is <> then jump to ELSE/Next line

; ' push(stack , currentX , y + 1)
        LDX     currentX 
        LDU     PaintY          ; Get the Y co-ordinate
        LEAU    1,U             ; Increment the Y co-ordinate
        PSHS    X,U             ; Save the memory location to write the value that this array equals

; spanBelow = true
        LDD     #TRUE     
        STD     spanBelow   ; Save Numeric variable
; ELSE
        BRA     PaintIFDone_04_HIG141    ; Jump to END IF line
PaintELSE_04_HIG141                              ; If result is zero = FALSE then jump to ELSE/Next line
; IF spanBelow = true AND y < SCREEN_HEIGHT -1 AND PPOINT(currentX , y + 1) < > SourceColour THEN
        LDX     spanBelow       ; Get the spanBelow value
        BEQ     PaintIFDone_05_HIG141      ; If result is zero = FALSE then jump to END IF line

        LDX     #ScreenHeight_HIG141
        LEAX    -1,X            ; Decrement the screen height comaprison value
        CMPX    PaintY          ; Check if X is with the y co-ordinate
        BLS     PaintIFDone_05_HIG141      ; If result is >= then jump to END IF line

        LDA     PaintY+1
        INCA                    ; Decrement the Y co-ordinate
        LDX     currentX
        JSR     POINT_HIG141      ; Return with the colour value of the PPoint on screen in B
        CMPB    SourceColour        ; Compare the old color with the new color
        BEQ     PaintIFDone_05_HIG141      ; If the result is = then jump to ELSE/Next line

; spanBelow = false
        LDD     #FALSE    
        STD     spanBelow   ; Save Numeric variable
; END IF
PaintIFDone_05_HIG141                              ; END IF line
; END IF
PaintIFDone_04_HIG141                              ; END IF line
; currentX = currentX + 1
        LDD     currentX 
        ADDD    #1
        STD     currentX ; Save Numeric variable
; WEND
        LBRA    PaintWhileLoop3_HIG141  ; Goto the start of this WHILE/WEND loop
PaintWend_03_HIG141                       ; End of WHILE/WEND loop
; WEND
        LBRA    PaintWhileLoop1_HIG141  ; Goto the start of this WHILE/WEND loop
PaintWend_01_HIG141                       ; End of WHILE/WEND loop

DonePaint_HIG141:
        LDS     PaintStack      ; Restore the stack address
        RTS      ; Return
        
; Colour the screen Colour B
GCLS_HIG141:
        LDX     BEGGRP
        LEAU    Screen_Size_HIG141,X ; Screen Size
        STU     GCLSComp_HIG141+1 ; Self mod end address
        TSTB
        BEQ     >
        LDB     #$FF
!       TFR     B,A     ; A = B
!       STD     ,X++
GCLSComp_HIG141:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS