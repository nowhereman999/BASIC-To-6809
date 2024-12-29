* Circle command
* Enter with:
* x Center is at 4,S
* y Center is at 3,S
* radius is at 2,S
; CIRCLE routine to draw a circle centered at (x_Center, y_Center) with radius r
CIRCLE_FG3C:
        CLRA
        LDB     4,S             ; Load x coordinate (x_Center) from stack
        STD     x_Center        ; Store in x_Center
        LDB     3,S             ; Load y coordinate (y_Center) from stack
        STD     y_Center        ; Store in y_Center
        LDB     2,S             ; Load radius (r) from stack
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
CircleLoop_FG3C:     
        LDD     x0        
        CMPD    y0         ; Compare D with the value on the stack, fix the stack
        BLE     >
        RTS
!       BSR     PlotPoints_FG3C
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
        BRA     CircleLoop_FG3C          ; Loop until x <= y
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
        BRA     CircleLoop_FG3C      ; Loop until x <= y

PlotPoints_FG3C:
        ; Plot (x + x_Center, y + y_Center)
        LDB     x0+1
        ADDB    x_Center+1
        LDA     y0+1
        ADDA    y_Center+1
        BSR     DoSetYXCheck_FG3C            ; Plot the pixel
        ; Plot (-x + x_Center, y + y_Center)
        LDB     x_Center+1
        SUBB    x0+1
        LDA     y0+1
        ADDA    y_Center+1
        BSR     DoSetYXCheck_FG3C            ; Plot the pixel
        ; Plot (x + x_Center, -y + y_Center)
        LDB     x0+1
        ADDB    x_Center+1
        LDA     y_Center+1
        SUBA    y0+1
        BSR     DoSetYXCheck_FG3C            ; Plot the pixel
        ; Plot (-x + x_Center, -y + y_Center)
        LDB     x_Center+1
        SUBB    x0+1
        LDA     y_Center+1
        SUBA    y0+1
        BSR     DoSetYXCheck_FG3C            ; Plot the pixel
        ; Plot (y + x_Center, x + y_Center)
        LDB     y0+1
        ADDB    x_Center+1
        LDA     x0+1
        ADDA    y_Center+1
        BSR     DoSetYXCheck_FG3C            ; Plot the pixel
        ; Plot (-y + x_Center, x + y_Center)
        LDB     x_Center+1
        SUBB    y0+1
        LDA     x0+1
        ADDA    y_Center+1
        BSR     DoSetYXCheck_FG3C            ; Plot the pixel
        ; Plot (y + x_Center, -x + y_Center)
        LDB     y0+1
        ADDB    x_Center+1
        LDA     y_Center+1
        SUBA    x0+1
        BSR     DoSetYXCheck_FG3C            ; Plot the pixel
        ; Plot (-y + x_Center, -x + y_Center)
        LDB     x_Center+1
        SUBB    y0+1
        LDA     y_Center+1
        SUBA    x0+1
; Fall through to plot last pixel and return
;
; Circle Command comes here
; Do the set command, but check to make sure Y & X co-ordinates are not beyond the screen
DoSetYXCheck_FG3C:
!           CMPA    #ScreenHeight_FG3C-1
            BLS     @GoodA
; If we get here the value is not in screen's range
			CMPA	#255-((255-ScreenHeight_FG3C-1)/2) 
			BLS		>			; If we are <= the midpoint beyond the screen size then use max value
			CLRA				; otherwise make it zero
			BRA		@GoodA
!           LDA     #ScreenHeight_FG3C-1
@GoodA      CMPB    #ScreenWidth_FG3C-1
            BLS     @GoodB
; If we get here the value is not in screen's range
			CMPB	#255-((255-ScreenWidth_FG3C-1)/2) 
			BLS		>			; If we are <= the midpoint beyond the screen size then use max value
			CLRB				; otherwise make it zero
			BRA		@GoodB
!           LDB     #ScreenWidth_FG3C-1
@GoodB      JMP     SET_FG3C    ; go set the pixel
