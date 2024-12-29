CircleScale_HIG123    EQU 64
;
* Circle command
* Enter with:
* x Center is at 4,S
* y Center is at 3,S
* radius is at 2,S
; CIRCLE routine to draw a circle centered at (x_Center, y_Center) with radius r
CIRCLE_HIG123:
        LDA     LineColour      ; Get the line colour
        BNE     @Colour1        ; If it's not zero then draw white
        LDD     #DoReSetYXCheck_HIG123     ; Get address of RESET for black pixels
        BRA     >
@Colour1:
        LDD     #DoSetYXCheck_HIG123       ; Get address of SET for white pixels
!       STD     SelfModC1_HIG123+1 ; Selfmod the jump address
        STD     SelfModC2_HIG123+1 ; Selfmod the jump address
        STD     SelfModC3_HIG123+1 ; Selfmod the jump address
        STD     SelfModC4_HIG123+1 ; Selfmod the jump address
        STD     SelfModC5_HIG123+1 ; Selfmod the jump address
        STD     SelfModC6_HIG123+1 ; Selfmod the jump address
        STD     SelfModC7_HIG123+1 ; Selfmod the jump address
        STD     SelfModC8_HIG123+1 ; Selfmod the jump address
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
CircleLoop_HIG123:     
        LDD     x0        
        CMPD    y0         ; Compare D with the value on the stack, fix the stack
        BLE     >
        RTS
!       BSR     PlotPoints_HIG123
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
        BRA     CircleLoop_HIG123          ; Loop until x <= y
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
        BRA     CircleLoop_HIG123      ; Loop until x <= y

PlotPoints_HIG123:
; Plot (x + x_Center, y + y_Center)
        LDB     x0+1
        LSRB                            ; Scale B
        ADDB    x_Center+1
        LDA     y0+1
        ADDA    y_Center+1
SelfModC1_HIG123:
        JSR     DoSetYXCheck_HIG123            ; Plot the pixel
; Plot (-x + x_Center, y + y_Center)
        LDB     x0+1
        LSRB                            ; Scale B
        NEGB
        ADDB    x_Center+1
        LDA     y0+1
        ADDA    y_Center+1
SelfModC2_HIG123:
        JSR     DoSetYXCheck_HIG123            ; Plot the pixel
; Plot (x + x_Center, -y + y_Center)
        LDB     x0+1
        LSRB                            ; Scale B
        ADDB    x_Center+1
        LDA     y_Center+1
        SUBA    y0+1
SelfModC3_HIG123:
        JSR     DoSetYXCheck_HIG123            ; Plot the pixel
; Plot (-x + x_Center, -y + y_Center)
        LDB     x0+1
        LSRB                            ; Scale B
        NEGB
        ADDB    x_Center+1
        LDA     y_Center+1
        SUBA    y0+1
SelfModC4_HIG123:
        JSR     DoSetYXCheck_HIG123            ; Plot the pixel
; Plot (y + x_Center, x + y_Center)
        LDB     y0+1
        LSRB                            ; Scale B
        ADDB    x_Center+1
        LDA     x0+1
        ADDA    y_Center+1
SelfModC5_HIG123:
        JSR     DoSetYXCheck_HIG123            ; Plot the pixel
; Plot (-y + x_Center, x + y_Center)
        LDB     y0+1
        LSRB                            ; Scale B
        NEGB
        ADDB    x_Center+1
        LDA     x0+1
        ADDA    y_Center+1
SelfModC6_HIG123:
        JSR     DoSetYXCheck_HIG123            ; Plot the pixel
; Plot (y + x_Center, -x + y_Center)
        LDB     y0+1
        LSRB                            ; Scale B
        ADDB    x_Center+1
        LDA     y_Center+1
        SUBA	x0+1    
SelfModC7_HIG123:
        JSR     DoSetYXCheck_HIG123            ; Plot the pixel
; Plot (-y + x_Center, -x + y_Center)
        LDB     y0+1
        LSRB                            ; Scale B
        NEGB
        ADDB    x_Center+1
        LDA     y_Center+1
        SUBA    x0+1
SelfModC8_HIG123:
        JMP     DoSetYXCheck_HIG123            ; Plot the pixel

;
; Circle Command comes here
; Do the set command, but check to make sure Y & X co-ordinates are not beyond the screen
DoSetYXCheck_HIG123:
!           CMPA    #ScreenHeight_HIG123-1
            BLS     @GoodA
; If we get here the value is not in screen's range
			CMPA	#255-((255-ScreenHeight_HIG123-1)/2) 
			BLS		>			; If we are <= the midpoint beyond the screen size then use max value
			CLRA				; otherwise make it zero
			BRA		@GoodA
!           LDA     #ScreenHeight_HIG123-1
@GoodA      CMPB    #ScreenWidth_HIG123-1
            BLS     @GoodB
; If we get here the value is not in screen's range
			CMPB	#255-((255-ScreenWidth_HIG123-1)/2) 
			BLS		>			; If we are <= the midpoint beyond the screen size then use max value
			CLRB				; otherwise make it zero
			BRA		@GoodB
!           LDB     #ScreenWidth_HIG123-1
@GoodB      JMP     SET_HIG123    ; go set the pixel

DoReSetYXCheck_HIG123:
!           CMPA    #ScreenHeight_HIG123-1
            BLS     @GoodA
; If we get here the value is not in screen's range
			CMPA	#255-((255-ScreenHeight_HIG123-1)/2) 
			BLS		>			; If we are <= the midpoint beyond the screen size then use max value
			CLRA				; otherwise make it zero
			BRA		@GoodA
!           LDA     #ScreenHeight_HIG123-1
@GoodA      CMPB    #ScreenWidth_HIG123-1
            BLS     @GoodB
; If we get here the value is not in screen's range
			CMPB	#255-((255-ScreenWidth_HIG123-1)/2) 
			BLS		>			; If we are <= the midpoint beyond the screen size then use max value
			CLRB				; otherwise make it zero
			BRA		@GoodB
!           LDB     #ScreenWidth_HIG123-1
@GoodB      JMP     RESET_HIG123    ; go set the pixel
