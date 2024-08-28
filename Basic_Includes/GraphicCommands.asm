; PSET a dot on screen screen
; Enter with:
; A = y coordinate
; B = x coordinate
;
; Make sure values of y are between 0 and 191 or bad things will happen
;
; Screen location for PMODE 4 screen
; x location is 0 to 255 (32 bytes) per row
; y location is 0 to 191 (192 rows)
;
; A=Y value, B=X value
;
; Byte to draw pixel on screen
; = 1111 1xxx = 31 is the byte
; = xxxx x111 = pixel value
;
; A=y value, B=x value
PSET0:
PSET1:
PSET2:
PSET3:
* PMODE 4 PSET command
PSET4:
PSET:
        PSHS    D,X,U           ; Save x & y coordinate on the stack
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the pixel to draw
        LDB     1,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTable4    ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ORA     B,U             ; Or original Byte value with the pixel the user wants to set
        STA     ,X              ; Write new byte to the screen
        PULS    D,X,U,PC        ; Restore D,X & U and return

PixelTable4:
        FCB     %10000000 Pixel 0
        FCB     %01000000 Pixel 1
        FCB     %00100000 Pixel 2
        FCB     %00010000 Pixel 3
        FCB     %00001000 Pixel 4
        FCB     %00000100 Pixel 5
        FCB     %00000010 Pixel 6
        FCB     %00000001 Pixel 7

; PRESET a dot on screen screen
; Enter with:
; A = y coordinate
; B = x coordinate
;
; Make sure values of y are between 0 and 191 or bad things will happen
;
; Screen location for PMODE 4 screen
; x location is 0 to 255 (32 bytes) per row
; y location is 0 to 191 (192 rows)
;
; A=Y value, B=X value
;
; Byte to draw pixel on screen
; = 1111 1xxx = 31 is the byte
; = xxxx x111 = pixel value
;
; A=y value, B=x value
PRESET0:
PRESET1:
PRESET2:
PRESET3:
* PMODE 4 PSET command
PRESET4:
        PSHS    D,X,U           ; Save x & y coordinate on the stack
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the pixel to draw
        LDB     1,S             ; Get B back which has the pixel number
        ANDB    #%00000111      ; B = Pixel value (0 to 7)
        LDU     #PixelTable4CLear  ; U points to the table of pixel values
        LDA     ,X              ; Get existing pixels in this byte from the screen
        ANDA    B,U             ; AND original Byte value with the pixel the user wants to cleared
        STA     ,X              ; Write new byte to the screen
        PULS    D,X,U,PC        ; Restore D,X & U and return

PixelTable4CLear:
        FCB     %01111111 Pixel 0
        FCB     %10111111 Pixel 1
        FCB     %11011111 Pixel 2
        FCB     %11101111 Pixel 3
        FCB     %11110111 Pixel 4
        FCB     %11111011 Pixel 5
        FCB     %11111101 Pixel 6
        FCB     %11111110 Pixel 7

; PPOINT get the value of a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
; Returns with:
; B = Colour value of the point
PPOINT0:
PPOINT1:
PPOINT2:
PPOINT3:
* PMODE 4 PPOINT command
PPOINT4:
        PSHS    A,X,U           ; Save x & y coordinate on the stack
        STB     ,-S             ; Save x value
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the pixel to draw
        LDA     ,S+             ; A = the pixel number
        ANDA    #%00000111      ; A = Pixel value (0 to 7)
        LDU     #PixelTable4    ; U points to the table of pixel values
        LDB     ,X              ; Get existing pixels in this byte from the screen
        ANDB    A,U             ; AND original Byte value with the pixel the user wants to get the value of
        BEQ     >
        LDB     #1              ; If the value is <> 0 make it 1
!       PULS    A,X,U,PC        ; Restore A,X & U and return

* Circle command
* Enter with:
* x Center is at 4,S
* y Center is at 3,S
* radius is at 2,S

CIRCLE0:
CIRCLE1:
CIRCLE2:
CIRCLE3:
CIRCLE4:

; CIRCLE routine to draw a circle centered at (x_Center, y_Center) with radius r
CIRCLE:
        CLRA
        LDB     4,S             ; Load x coordinate (x_Center) from stack
        STD     x_Center        ; Store in x_Center
        LDB     3,S             ; Load y coordinate (y_Center) from stack
        STD     y_Center        ; Store in y_Center
        LDB     2,S             ; Load radius (r) from stack
        STD     radius          ; Store in r
;
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
CircleLoop:     
        LDD     x0        
        CMPD    y0         ; Compare D with the value on the stack, fix the stack
        BLE     >
        RTS
!
        BSR     PlotPoints
; Update x
; x = x + 1
        LDD     x0
        ADDD    #1
        STD     x0

; Update decision parameter and y if necessary
;if decision> 0:
        LDD     decision
        CMPD    #0
        BMI     >
;   y = y - 1
        LDD     y0
        SUBD    #1
        STD     y0
;   decision= decision+ 4 * (x - y) + 10
        LDD     x0
        SUBD    y0
        LSLB
        ROLA
        LSLB
        ROLA            ; D = 4 * (x - y)
        ADDD    #10
        ADDD    decision
        STD     decision

        BRA     CircleLoop          ; Loop until x <= y
;        else:
;!            decision = decision+ 4 * x + 6
!
        LDD     x0
        LSLB
        ROLA
        LSLB
        ROLA                    ; D = 4 * x
        ADDD    #6
        ADDD    decision
        STD     decision

        BRA     CircleLoop      ; Loop until x <= y

PlotPoints:
        ; Plot (x + x_Center, y + y_Center)
        LDB     x0+1
        ADDB    x_Center+1
        LDA     y0+1
        ADDA    y_Center+1
        JSR     PSET            ; Plot the pixel
        ; Plot (-x + x_Center, y + y_Center)
        LDB     x0+1
        NEGB
        ADDB    x_Center+1
        LDA     y0+1
        ADDA    y_Center+1
        JSR     PSET            ; Plot the pixel
        ; Plot (x + x_Center, -y + y_Center)
        LDB     x0+1
        ADDB    x_Center+1
        LDA     y0+1
        NEGA
        ADDA    y_Center+1
        JSR     PSET            ; Plot the pixel
        ; Plot (-x + x_Center, -y + y_Center)
        LDB     x0+1
        NEGB
        ADDB    x_Center+1
        LDA     y0+1
        NEGA
        ADDA    y_Center+1
        JSR     PSET            ; Plot the pixel
        ; Plot (y + x_Center, x + y_Center)
        LDB     y0+1
        ADDB    x_Center+1
        LDA     x0+1
        ADDA    y_Center+1
        JSR     PSET            ; Plot the pixel
        ; Plot (-y + x_Center, x + y_Center)
        LDB     y0+1
        NEGB
        ADDB    x_Center+1
        LDA     x0+1
        ADDA    y_Center+1
        JSR     PSET            ; Plot the pixel
        ; Plot (y + x_Center, -x + y_Center)
        LDB     y0+1
        ADDB    x_Center+1
        LDA     x0+1
        NEGA
        ADDA    y_Center+1
        JSR     PSET            ; Plot the pixel
        ; Plot (-y + x_Center, -x + y_Center)
        LDB     y0+1
        NEGB
        ADDB    x_Center+1
        LDA     x0+1
        NEGA
        ADDA    y_Center+1
        JSR     PSET            ; Plot the pixel
        RTS

* Line commands
* Enter with:
* x at 5,S
* y at 4,S
* x1 at 3,S
* y1 at 2,S


PRESETLINE:
PRESETLINE0:
PRESETLINE1:
PRESETLINE2:
PRESETLINE3:
PRESETLINE4:
        LDX     #PRESET4          ; Self mode address of PSET routine
        BRA     >
LINE:
LINE0:
LINE1:
LINE2:
LINE3:
LINE4:
        LDX     #PSET4          ; Self mode address of PSET routine
!       STX     LineDrawDot2+1   ; Address where to draw the dot
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
        BNE     LineNotHorizontal4  ; If they aren't the same then go draw a line normally
; Get the number of bytes between pixels
        LDB     endX+1          ; B = ending x coordinate
        CMPB    startX+1        ; Compare with starting x coordinate
        BHI     >               ; If A is positive then go draw a line normally
        BEQ     LineDrawDot1    ; If A is zero then go PSET one single pixel
        LDA     startX+1          ; Otherwise flip the startx and endx coordinates
        LDB     endX+1          ; and store them in the variables
        STA     endX+1          ;
        STB     startX+1        ;
* See if we have more then 8 pixels to draw
!       LDB     endX+1
        SUBB    startX+1        ;
        CMPB    #16             ; If we have more then 16 pixels to draw then go draw the line normally
        BLS     LineNotHorizontal4  ; If the size is <= 16 then go draw the line normally

        LDA     startX+1        ; A=X starting value
        ANDA    #7              ; Mask off the last 3 bits      
        SUBA    #-7
        PSHS    A               ; Save the # of pixels to draw for this horizontal line
        ADDB    ,S+
        LDA     endX+1          ; A=X ending value
        ANDA    #7              ; Mask off the last 3 bits      
        PSHS    A               ; Save the # of pixels to draw for this horizontal line
        SUBB    ,S+

; Turn pixels into bytes
        LSRB                    ; B=B/2
        LSRB                    ; B=B/4
        LSRB                    ; B=B/8, we now have the number of bytes to draw
        DECB
        PSHS    B               ; Save the # of pixels to draw for this horizontal line

        LDA     startY+1        ; A=Y value
        LDB     startX+1        ; B=X value
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB                    ; Shift entire value right 3 times
        ADDD    BEGGRP          ; Add the Video Start Address
        PSHS    D               ; Save the location of the pixel to draw

* Fill the pixels on the left side of the line then draw bytes
        CMPX    LINE4+1         ; See if we are doing a PSET or PRESET
        BEQ     LineHorizontalPSET4   ; If PSET then we are good to go, skip ahead
* Do the PRESET version of a Horizontal line
        PULS    X               ; Restore the location to start drawing at
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the starting bit of the x coordinate
        SUBB    #8              ; subtract 8 from the starting bit, B now is a value from -8 to -1
        LDU     #LineDrawSetTableEnd4-1
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
        LDU     #LineDrawSetTableEnd4
        LDA     B,U             ; A = the pixels to set from the table
        ANDA    ,X              ; OR the byte with the pixel on screen
        STA     ,X              ; Store the byte byte
        JMP     ,Y              ; Return

* Do the PSET version
LineHorizontalPSET4:
        PULS    X               ; Restore the location to start drawing at
        LDB     startX+1        ; B = starting x coordinate
        ANDB    #%00000111      ; B = B & %00000111, get the starting bit of the x coordinate
        SUBB    #8              ; subtract 8 from the starting bit, B now is a value from -8 to -1
        LDU     #LineDrawSetTableEnd4-1
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
        LDU     #LineDrawSetTableEnd4
        LDA     B,U             ; A = the pixels to set from the table
        COMA                    ; flip the bits
        ORA     ,X              ; OR the byte with the pixel on screen
        STA     ,X              ; Store the byte byte
        JMP     ,Y              ; Return

LineDrawSetTableStart4:
        FCB     %11111111       ; Pixel 0 Set
        FCB     %01111111       ; Pixel 1 Set
        FCB     %00111111       ; Pixel 2 Set
        FCB     %00011111       ; Pixel 3 Set
        FCB     %00001111       ; Pixel 4 Set
        FCB     %00000111       ; Pixel 5 Set
        FCB     %00000011       ; Pixel 6 Set
        FCB     %00000001       ; Pixel 7 Set
        FCB     %00000000       ; 
LineDrawSetTableEnd4:


; PSET(startX , startY , 1)
LineDrawDot1:
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
        JSR     ,X              ; Plot the pixel (X points at the PSET or PRESET routines)
        JMP     ,Y              ; Return



; Calculate the absolute differences in the x and y coordinates
; deltaX = ABS(endX - startX)
LineNotHorizontal4:
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
LINELoop4:
; PSET(startX , startY , 1)
        LDB     startX+1        ; B = x coordinate
        LDA     startY+1        ; A = y coordinate
LineDrawDot2:
        JSR     PSET            ; Plot the pixel

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
        BRA     LINELoop4       ; Might as well jump to the top of the loop, that's where we'll end up anyway and it saves a few cycles
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
        BRA     LINELoop4       ; GOTO 10

* Enter with:
* x at 3,S
* y at 2,S
* x1 value in X
* y1 value in U
BoxStartY       RMB     1
BoxStartX       RMB     1
BoxEndY         RMB     1
BoxEndX         RMB     1

PRESETBOX0:
PRESETBOX1:
PRESETBOX2:
PRESETBOX3:
PRESETBOX4:
PRESETBOX:
        LDD     #PRESET4          ; Self mode address of PSET routine
        BRA     >
BOX0:
BOX1:
BOX2:
BOX3:
BOX4:
BOX:
        LDD     #PSET4          ; Self mode address of PSET routine
!       STD     BoxDrawDot0+1
        STD     BoxDrawDot1+1
        STD     BoxDrawDot2+1
        STD     BoxDrawDot3+1

        PULS    X,Y,U           ; X = return address, Y= End y & x, U= Start y & x
        STU     BoxStartY       ; Store in BoxStartY & BoxStartX
        STY     BoxEndY         ; Store in BoxEndY & BoxEndX
        LEAY    ,X              ; Y = return address

; PSET a dot on screen a PMODE 4 screen
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
        LDD     BoxStartY       ; A = BoxStartY, B = BoxStartX
BoxDrawDot0:
!       JSR     PSET4           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the bottom line of the box
        LDA     BoxEndY         ; A = BoxEndY
        LDB     BoxStartX       ; B = BoxStartX
BoxDrawDot1:
!       JSR     PSET4           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Left line of the box
        LDD     BoxStartY       ; A = BoxStartY, B = BoxStartX
BoxDrawDot2:
!       JSR     PSET4           ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping
* Draw the Right line of the box
        LDA     BoxStartY       ; A = BoxStartY
        LDB     BoxEndX         ; B = BoxEndX
BoxDrawDot3:
!       JSR     PSET4           ; Go draw the pixel on screen
        INCA                    ; Increment the y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     <               ; If <=, then keep looping

        JMP     ,Y              ; Return

* Enter with:
* Same as BOX: above

PRESETBoxFill0:
PRESETBoxFill1:
PRESETBoxFill2:
PRESETBoxFill3:
PRESETBoxFill4:
PRESETBoxFill:
        LDD     #PRESET4          ; Self mode address of PSET routine
        BRA     >

BoxFill0:
BoxFill1:
BoxFill2:
BoxFill3:
BoxFill4:
BoxFill:
        LDD     #PSET4          ; Self mode address of PSET routine
!       STD     BoxFillDrawDot0+1

        PULS    X,Y,U           ; X = return address, Y= End y & x, U= Start y & x
        STU     BoxStartY       ; Store in BoxStartY & BoxStartX
        STY     BoxEndY         ; Store in BoxEndY & BoxEndX
        LEAY    ,X              ; Y = return address

; PSET a dot on screen a PMODE 4 screen
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
        LDA     BoxStartY       ; A = BoxStartY
        STA     ,-S             ; Save the y coordinate in the stack
BFillLoop:
        LDB     BoxStartX       ; B = BoxStartX
BoxFillDrawDot0:
!       JSR     PSET4           ; Go draw the pixel on screen
        INCB                    ; Increment the x coordinate
        CMPB    BoxEndX         ; Compare the x coordinate with the end x coordinate
        BLS     <               ; If <=, then keep looping
        INC     ,S              ; Increment the y coordinate
        LDA     ,S              ; A = y coordinate
        CMPA    BoxEndY         ; Compare the y coordinate with the end y coordinate
        BLS     BFillLoop       ; If <=, then keep looping
        LEAS    1,S             ; Fix the stack
        JMP     ,Y              ; Return

* Paint or flood fill a region of the screen
; Enter with:
; X = Border Colour & Fill Colour
; A = y coordinate
; B = x coordinate
; Returns with:

* Don't change the order of PaintY & currentX, keep them together as they get loaded as LDD at times below
PaintY          RMB     2
currentX        RMB     2
oldColor        RMB     1
newColor        RMB     1
PaintStack      RMB     2

FALSE           EQU     0
TRUE            EQU     -1
ScreenWidth     RMB     2
ScreenHeight    RMB     2
spanAbove       RMB     2
spanBelow       RMB     2


PAINT0:
PAINT1:
PAINT2:
PAINT3:
* PMODE 4 screen
PAINT4:
PAINT:

        PSHS    D,X,Y,U         ; Save registers

; Set up starting coordinates in X and Y
        STA     PaintY+1        ; Save the y co-ordinate
        STB     currentX+1      ; Save the x co-ordinate
        CLRA
        STA     PaintY          ; Clear MSB of the y co-ordinate
        STA     currentX        ; Save the x co-ordinate
        STX     oldColor        ; Save the old color & new color
        LDU     PaintY          ; U= PaintY
        LDX     currentX        ; X= currentX

; Initialize stack with starting coordinates
        STS     PaintStack      ; Save the starting stack address
        PSHS    X,U             ; Save the Y co-ordinates & the X co-ordinate starting point on screen

; ' 80 paint(40 , 50) , 1 , 1
; SCREEN_WIDTH = 256
        LDD     #256          
        STD     ScreenWidth   ; Save Numeric variable
; SCREEN_HEIGHT = 192
        LDD     #192          
        STD     ScreenHeight   ; Save Numeric variable

; DIM xStack(255) , yStack(255)
; oldColor = PPOINT(x , y)  
        LDA     PaintY+1        
        LDB     currentX+1
        JSR     PPOINT4       ; Return with the colour value of the PPoint on screen in B
        STB     oldColor ; Save Numeric variable
; IF oldColor = newColor THEN
        CMPB    newColor       ; Compare the old color with the new color
        BEQ     DonePaint      ; If they are equal then jump to the DonePaint line, we are done
; RETURN
; END IF
; StackPointer = 0
; WHILE StackPointer > 0
PaintWhileLoop_01                              ; Start of WHILE/WEND loop
        CMPS    PaintStack      ; Compare the stack pointer with the stack address
        BEQ     PaintWend_01    ; If Equal, then jump to the end of the WHILE/WEND loop

        PULS    X,U             ; Restore the X co-ordinates & the Y co-ordinate starting point on screen
        STU     PaintY          ; Save Numeric variable
; currentX = x        
        STX     currentX        ; Save Numeric variable

; ' Move to the left boundary of the fill area
; WHILE currentX > = 0 AND PPOINT(currentX , y) = oldColor
PaintWhileLoop_02                              ; Start of WHILE/WEND loop
        LDX     currentX 
        BMI     PaintWend_02  ; If the result is a false then goto the end of the WHILE/WEND loop
        LDA     PaintY+1
        LDB     currentX+1
        JSR     PPOINT4       ; Return with the colour value of the PPoint on screen in B
        CMPB    oldColor       ; Compare the old color with the new color
        BNE     PaintWend_02  ; If they are not equal then goto the end of the WHILE/WEND loop
; currentX = currentX -1
        LDD     currentX     
        SUBD    #1     
        STD     currentX        ; Save Numeric variable
; WEND
        BRA    PaintWhileLoop_02  ; Goto the start of this WHILE/WEND loop
PaintWend_02                       ; End of WHILE/WEND loop
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

; WHILE currentX < SCREEN_WIDTH AND PPOINT(currentX , y) = oldColor
PaintWhileLoop_03                              ; Start of WHILE/WEND loop
        LDX     currentX
        CMPX    ScreenWidth   ; Check if X is less than ScreenWidth
        BHS     PaintWend_03   ; If the result is a false then goto the end of the WHILE/WEND loop

        LDA     PaintY+1
        LDB     currentX+1
        JSR     PPOINT4       ; Return with the colour value of the PPoint on screen in B
        CMPB    oldColor       ; Compare the old color with the new color
        BNE     PaintWend_03  ; If they are not equal then goto the end of the WHILE/WEND loop

; PSET(currentX , y , newColor)
        LDA     PaintY+1
        LDB     currentX+1
        JSR     PSET            ; Plot the pixel

; IF spanAbove = false AND y > 0 AND PPOINT(currentX , y -1) = oldColor THEN
        LDX     spanAbove       ; Get the spanAbove value
        BNE     PaintELSE_02        ; If result is <> zero = FALSE then jump to ELSE/Next line

        LDX     PaintY          ; Get the Y co-ordinate
        BLE     PaintELSE_02        ; If the result is <= 0 then jump to ELSE/Next line

        LDA     PaintY+1
        DECA                    ; Decrement the Y co-ordinate
        LDB     currentX+1
        JSR     PPOINT4         ; Return with the colour value of the PPoint on screen in B
        CMPB    oldColor        ; Compare the old color with the new color
        BNE     PaintELSE_02        ; If they are not equal then goto the end of the WHILE/WEND loop

; ' push(stack , currentX , y - 1)
        LDX     currentX 
        LDU     PaintY          ; Get the Y co-ordinate
        LEAU    -1,U            ; Decrement the Y co-ordinate
        PSHS    X,U             ; Save the memory location to write the value that this array equals

; spanAbove = true
        LDD     #TRUE     
        STD     spanAbove   ; Save Numeric variable
        BRA     PaintIFDone_02    ; Jump to END IF line
; ELSE
PaintELSE_02                              ; If result is zero = FALSE then jump to ELSE/Next line
; IF spanAbove = true AND y > 0 AND PPOINT(currentX , y -1) < > oldColor THEN
        LDX     spanAbove       ; Get the spanAbove value
        BEQ     PaintIFDone_03      ; If result is zero = FALSE then jump to END IF line

        LDX     PaintY          ; Get the Y co-ordinate
        BLE     PaintIFDone_03      ; If result is <= 0 then jump to END IF line

        LDA     PaintY+1
        DECA                    ; Decrement the Y co-ordinate
        LDB     currentX+1
        JSR     PPOINT4         ; Return with the colour value of the PPoint on screen in B
        CMPB    oldColor        ; Compare the old color with the new color
        BEQ     PaintIFDone_03      ; If result is = then jump to END IF line

; spanAbove = false
        LDD     #FALSE    
        STD     spanAbove   ; Save Numeric variable
; END IF
PaintIFDone_03                              ; END IF line
; END IF
PaintIFDone_02                              ; END IF line
; IF spanBelow = false AND y < SCREEN_HEIGHT -1 AND PPOINT(currentX , y + 1) = oldColor THEN
        LDX     spanBelow   
        BNE     PaintELSE_04        ; If result is <> zero then jump to ELSE/Next line

        LDX     ScreenHeight
        LEAX    -1,X            ; Decrement the screen height comaprison value
        CMPX    PaintY          ; Check if X is with the y co-ordinate
        BLS     PaintELSE_04        ; If the result is a false then jump to ELSE/Next line

        LDA     PaintY+1
        INCA                    ; Decrement the Y co-ordinate
        LDB     currentX+1
        JSR     PPOINT4         ; Return with the colour value of the PPoint on screen in B
        CMPB    oldColor        ; Compare the old color with the new color
        BNE     PaintELSE_04        ; If the result is <> then jump to ELSE/Next line

; ' push(stack , currentX , y + 1)
        LDX     currentX 
        LDU     PaintY          ; Get the Y co-ordinate
        LEAU    1,U             ; Increment the Y co-ordinate
        PSHS    X,U             ; Save the memory location to write the value that this array equals

; spanBelow = true
        LDD     #TRUE     
        STD     spanBelow   ; Save Numeric variable
; ELSE
        BRA     PaintIFDone_04    ; Jump to END IF line
PaintELSE_04                              ; If result is zero = FALSE then jump to ELSE/Next line
; IF spanBelow = true AND y < SCREEN_HEIGHT -1 AND PPOINT(currentX , y + 1) < > oldColor THEN
        LDX     spanBelow       ; Get the spanBelow value
        BEQ     PaintIFDone_05      ; If result is zero = FALSE then jump to END IF line

        LDX     ScreenHeight
        LEAX    -1,X            ; Decrement the screen height comaprison value
        CMPX    PaintY          ; Check if X is with the y co-ordinate
        BLS     PaintIFDone_05      ; If result is >= then jump to END IF line

        LDA     PaintY+1
        INCA                    ; Decrement the Y co-ordinate
        LDB     currentX+1
        JSR     PPOINT4         ; Return with the colour value of the PPoint on screen in B
        CMPB    oldColor        ; Compare the old color with the new color
        BEQ     PaintIFDone_05      ; If the result is = then jump to ELSE/Next line

; spanBelow = false
        LDD     #FALSE    
        STD     spanBelow   ; Save Numeric variable
; END IF
PaintIFDone_05                              ; END IF line
; END IF
PaintIFDone_04                              ; END IF line
; currentX = currentX + 1
        LDD     currentX 
        ADDD    #1
        STD     currentX ; Save Numeric variable
; WEND
        LBRA    PaintWhileLoop_03  ; Goto the start of this WHILE/WEND loop
PaintWend_03                       ; End of WHILE/WEND loop
; WEND
        LBRA    PaintWhileLoop_01  ; Goto the start of this WHILE/WEND loop
PaintWend_01                       ; End of WHILE/WEND loop

DonePaint:
        PULS    D,X,Y,U,PC      ; Restore registers and return



        