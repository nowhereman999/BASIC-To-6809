CircleScale_HIG131    EQU 230   ; 64 way too wide, 196 still too wide
* Circle command
* Enter with:
* x Center is at 4,S
* y Center is at 3,S
* radius is at 2,S
; CIRCLE routine to draw a circle centered at (x_Center, y_Center) with radius r
CIRCLE_HIG131:
        LDA     LineColour      ; Get the line colour
        BNE     @Colour1        ; If it's not zero then draw white
        LDD     #DoReSetYXCheck_HIG131     ; Get address of RESET for black pixels
        BRA     >
@Colour1:
        LDD     #DoSetYXCheck_HIG131       ; Get address of SET for white pixels
!       STD     SelfModC1_HIG131+1 ; Selfmod the jump address
        STD     SelfModC2_HIG131+1 ; Selfmod the jump address
        STD     SelfModC3_HIG131+1 ; Selfmod the jump address
        STD     SelfModC4_HIG131+1 ; Selfmod the jump address
        STD     SelfModC5_HIG131+1 ; Selfmod the jump address
        STD     SelfModC6_HIG131+1 ; Selfmod the jump address
        STD     SelfModC7_HIG131+1 ; Selfmod the jump address
        STD     SelfModC8_HIG131+1 ; Selfmod the jump address
        CLRA
        LDB     9,S             ; Load x coordinate (x_Center) from stack
        STD     x_Center        ; Store in x_Center
        LDB     8,S             ; Load y coordinate (y_Center) from stack
        STD     y_Center        ; Store in y_Center
        LDB     7,S             ; Load radius (r) from stack
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
CircleLoop_HIG131:     
        LDD     x0        
        CMPD    y0         ; Compare D with the value on the stack, fix the stack
        BLE     >
        RTS
!       BSR     PlotPoints_HIG131
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
        BRA     CircleLoop_HIG131          ; Loop until x <= y
; else:
; decision = decision+ 4 * x + 6
!       LDD     x0
        LSLB
        ROLA
        LSLB
        ROLA                    ; D = 4 * x
        ADDD    #6
        ADDD    decision
        STD     decision
        BRA     CircleLoop_HIG131      ; Loop until x <= y

PlotPoints_HIG131:
; Plot (x + x_Center, y + y_Center)
        LDA     y0+1
        LDB     #CircleScale_HIG131 ; seems to scale better
        MUL                     ; Multiply A * B
        ADDA    y_Center+1
        LDB     x0+1
        ADDB    x_Center+1
SelfModC1_HIG131:
        JSR     DoSetYXCheck_HIG131        ; Plot the pixel
; Plot (-x + x_Center, y + y_Center)
        LDA     y0+1
        LDB     #CircleScale_HIG131 ; seems to scale better
        MUL                     ; Multiply A * B
        ADDA    y_Center+1
        LDB     x_Center+1
        SUBB    x0+1
SelfModC2_HIG131:
        JSR     DoSetYXCheck_HIG131        ; Plot the pixel
; Plot (x + x_Center, -y + y_Center)
        LDA     y0+1
        LDB     #CircleScale_HIG131 ; seems to scale better
        MUL                     ; Multiply A * B
        NEGA        
        ADDA    y_Center+1
        LDB     x0+1
        ADDB    x_Center+1
SelfModC3_HIG131:
        JSR     DoSetYXCheck_HIG131        ; Plot the pixel
; Plot (-x + x_Center, -y + y_Center)
        LDA     y0+1
        LDB     #CircleScale_HIG131 ; seems to scale better
        MUL                     ; Multiply A * B
        NEGA    
        ADDA    y_Center+1
        LDB     x_Center+1
        SUBB    x0+1
SelfModC4_HIG131:
        JSR     DoSetYXCheck_HIG131        ; Plot the pixel
; Plot (y + x_Center, x + y_Center)
        LDA     x0+1
        LDB     #CircleScale_HIG131 ; seems to scale better
        MUL                     ; Multiply A * B
        ADDA    y_Center+1
        LDB     y0+1
        ADDB    x_Center+1
SelfModC5_HIG131:
        JSR     DoSetYXCheck_HIG131        ; Plot the pixel
; Plot (-y + x_Center, x + y_Center)
        LDA     x0+1
        LDB     #CircleScale_HIG131 ; seems to scale better
        MUL                     ; Multiply A * B
        ADDA    y_Center+1
        LDB     x_Center+1
        SUBB    y0+1
SelfModC6_HIG131:
        JSR     DoSetYXCheck_HIG131        ; Plot the pixel
; Plot (y + x_Center, -x + y_Center)
        LDA     x0+1
        LDB     #CircleScale_HIG131 ; seems to scale better
        MUL                     ; Multiply A * B
        NEGA
        ADDA    y_Center+1
        LDB     y0+1
        ADDB    x_Center+1
SelfModC7_HIG131:
        JSR     DoSetYXCheck_HIG131        ; Plot the pixel
; Plot (-y + x_Center, -x + y_Center)
        LDA     x0+1
        LDB     #CircleScale_HIG131 ; seems to scale better
        MUL
        NEGA                   ; Multiply A * B
        ADDA    y_Center+1
        LDB     x_Center+1
        SUBB    y0+1
SelfModC8_HIG131:
        JMP     DoSetYXCheck_HIG131            ; Plot the pixel, and return

; Circle Command comes here
; Do the set command, but check to make sure Y & X co-ordinates are not beyond the screen
DoSetYXCheck_HIG131:
!       CMPA    #ScreenHeight_HIG131-1
        BLS     @GoodA
; If we get here the value is not in screen's range
	CMPA	#255-((255-ScreenHeight_HIG131-1)/2) 
	BLS	>			; If we are <= the midpoint beyond the screen size then use max value
	CLRA				; otherwise make it zero
	BRA	@GoodA
!       LDA     #ScreenHeight_HIG131-1
@GoodA  JMP     SET_HIG131    ; go set the pixel

; Circle Command comes here
; Do the set command, but check to make sure Y & X co-ordinates are not beyond the screen
DoReSetYXCheck_HIG131:
!       CMPA    #ScreenHeight_HIG131-1
        BLS     @GoodA
; If we get here the value is not in screen's range
	CMPA	#255-((255-ScreenHeight_HIG131-1)/2) 
	BLS	>			; If we are <= the midpoint beyond the screen size then use max value
	CLRA				; otherwise make it zero
	BRA	@GoodA
!       LDA     #ScreenHeight_HIG131-1
@GoodA  JMP     RESET_HIG131    ; go reset the pixel

