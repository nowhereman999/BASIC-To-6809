CircleScale_HIG159    EQU 120
* Circle command
* Enter with:
* x Center is at 4,S
* y Center is at 3,S
* radius is at 2,S
; CIRCLE routine to draw a circle centered at (x_Center, y_Center) with radius r
CIRCLE_HIG159:
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
CircleLoop_HIG159:     
        LDD     x0        
        CMPD    y0         ; Compare D with the value on the stack, fix the stack
        BLE     >
        RTS
!       BSR     PlotPoints_HIG159
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
        BRA     CircleLoop_HIG159          ; Loop until x <= y
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
        BRA     CircleLoop_HIG159       ; Loop until x <= y

PlotPoints_HIG159:
; Plot (x + x_Center, y + y_Center)
        LDD     x0
        ADDD    x_Center
        TFR     D,X
        LDA     y0+1
        LDB     #CircleScale_HIG159
        MUL
        ADDA    y_Center+1
        JSR     DoSetYXCheck_HIG159              ; Plot the pixel
; Plot (-x + x_Center, y + y_Center)
        LDD     x_Center
        SUBD    x0
        TFR     D,X
        LDA     y0+1
        LDB     #CircleScale_HIG159
        MUL
        ADDA    y_Center+1
        JSR     DoSetYXCheck_HIG159              ; Plot the pixel
; Plot (x + x_Center, -y + y_Center)
        LDD     x0
        ADDD    x_Center
        TFR     D,X
        LDA     y0+1
        LDB     #CircleScale_HIG159
        MUL
        NEGA
        ADDA    y_Center+1
        JSR     DoSetYXCheck_HIG159              ; Plot the pixel
; Plot (-x + x_Center, -y + y_Center)
        LDD     x_Center
        SUBD    x0
        TFR     D,X
        LDA     y0+1
        LDB     #CircleScale_HIG159
        MUL
        NEGA
        ADDA    y_Center+1
        BSR     DoSetYXCheck_HIG159              ; Plot the pixel
; Plot (y + x_Center, x + y_Center)
        LDD     y0
        ADDD    x_Center
        PSHS    D               ; save the x value
        LDX     x0
        LDD     #CircleScale_HIG159     ; Scale factor
        PSHS    D,X
        JSR     MUL16           ; Do D * X, D has the High 16 bits of the product and X has the Low 16 bits of the product
        PULS    D               ; get low 16 bit number in D and fix the stack
        ADDA    y_Center+1
        PULS    X               ; restore x value
        BSR     DoSetYXCheck_HIG159              ; Plot the pixel
; Plot (-y + x_Center, x + y_Center)
        LDD     x_Center
        SUBD    y0
        PSHS    D               ; save the x value
        LDX     x0
        LDD     #CircleScale_HIG159     ; Scale factor
        PSHS    D,X
        JSR     MUL16           ; Do D * X, D has the High 16 bits of the product and X has the Low 16 bits of the product
        PULS    D               ; get low 16 bit number in D and fix the stack
        ADDA    y_Center+1
        PULS    X               ; restore x value
        JSR     DoSetYXCheck_HIG159      ; Plot the pixel
; Plot (y + x_Center, -x + y_Center)
        LDD     y0
        ADDD    x_Center
        PSHS    D               ; save the x value
        LDX     x0
        LDD     #CircleScale_HIG159     ; Scale factor
        PSHS    D,X
        JSR     MUL16           ; Do D * X, D has the High 16 bits of the product and X has the Low 16 bits of the product
        PULS    D               ; get low 16 bit number in D and fix the stack
        NEGA
        ADDA    y_Center+1
        PULS    X               ; restore x value
        BSR     DoSetYXCheck_HIG159              ; Plot the pixel
; Plot (-y + x_Center, -x + y_Center)
        LDD     x_Center
        SUBD    y0
        PSHS    D               ; save the x value
        LDX     x0
        LDD     #CircleScale_HIG159     ; Scale factor
        PSHS    D,X
        JSR     MUL16           ; Do D * X, D has the High 16 bits of the product and X has the Low 16 bits of the product
        PULS    D               ; get low 16 bit number in D and fix the stack
        NEGA
        ADDA    y_Center+1
        PULS    X               ; restore x value
        JMP     DoSetYXCheck_HIG159              ; Plot the pixel, and return

;
; Circle Command comes here
; Do the set command, but check to make sure Y & X co-ordinates are not beyond the screen
DoSetYXCheck_HIG159:
!       CMPA    #ScreenHeight_HIG159-1
        BLS     @GoodA
; If we get here the value is not in screen's range
		CMPA	#255-((255-ScreenHeight_HIG159-1)/2) 
		BLS		>			; If we are <= the midpoint beyond the screen size then use max value
		CLRA				; otherwise make it zero
		BRA		@GoodA
!       LDA     #ScreenHeight_HIG159-1
@GoodA
		CMPX	#0
		BPL		>		; Are we a positive value?
		LDX		#$0000	; If not make it 0
		BRA		@GoodX
!	    CMPX    #ScreenWidth_HIG159-1 ; are we screen edge or less
        BLE     @GoodX	; if so we are good as is
        LDX     #ScreenWidth_HIG159-1	; otherwise make it screen edge
@GoodX  JMP     SET_HIG159    ; go set the pixel
