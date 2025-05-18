CircleScale_SG4     EQU 170     ; 128 too wide, 96 wider, 192 pretty good, 225 too tall

* Circle command
* Enter with:
* x Center is at 4,S
* y Center is at 3,S
* radius is at 2,S
; CIRCLE routine to draw a circle centered at (x_Center, y_Center) with radius r
CIRCLE_SG4:
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
CircleLoop_SG4:     
        LDD     x0        
        CMPD    y0         ; Compare D with the value on the stack, fix the stack
        BLE     >
        RTS
!       BSR     PlotPoints_SG4
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
        BRA     CircleLoop_SG4          ; Loop until x <= y
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
        BRA     CircleLoop_SG4      ; Loop until x <= y

PlotPoints_SG4:
; Plot (x + x_Center, y + y_Center)
        LDA     y0+1
        LDB     #CircleScale_SG4    ; seems to scale better
        MUL                         ; Multiply A * B
        ADDA    y_Center+1
        LDB     x0+1
        ADDB    x_Center+1
        BSR     DoSetYXCheck_SG4    ; Plot the pixel
; Plot (x_Center - x, y + y_Center)
        LDA     y0+1
        LDB     #CircleScale_SG4    ; seems to scale better
        MUL                         ; Multiply A * B
        ADDA    y_Center+1
        LDB     x_Center+1
        SUBB    x0+1
        BSR     DoSetYXCheck_SG4    ; Plot the pixel
; Plot (x + x_Center, -y + y_Center)
        LDA     y0+1
        LDB     #CircleScale_SG4    ; seems to scale better
        MUL                         ; Multiply A * B
        NEGA
        ADDA    y_Center+1
        LDB     x0+1
        ADDB    x_Center+1
        BSR     DoSetYXCheck_SG4    ; Plot the pixel
; Plot (x_Center - x, -y + y_Center)
        LDA     y0+1
        LDB     #CircleScale_SG4    ; seems to scale better
        MUL                         ; Multiply A * B
        NEGA
        ADDA    y_Center+1
        LDB     x_Center+1
        SUBB    x0+1
        BSR     DoSetYXCheck_SG4    ; Plot the pixel
; Plot (y + x_Center, x + y_Center)
        LDA     x0+1
        LDB     #CircleScale_SG4    ; seems to scale better
        MUL                         ; Multiply A * B
        ADDA    y_Center+1
        LDB     y0+1
        ADDB    x_Center+1
        BSR     DoSetYXCheck_SG4    ; Plot the pixel
; Plot (x_Center - y, x + y_Center)
        LDA     x0+1
        LDB     #CircleScale_SG4    ; seems to scale better
        MUL                         ; Multiply A * B
        ADDA    y_Center+1
        LDB     x_Center+1
        SUBB    y0+1
        BSR     DoSetYXCheck_SG4    ; Plot the pixel
; Plot (y + x_Center, -x + y_Center)
        LDA     x0+1
        LDB     #CircleScale_SG4    ; seems to scale better
        MUL                         ; Multiply A * B
        NEGA
        ADDA    y_Center+1
        LDB     y0+1
        ADDB    x_Center+1
        BSR     DoSetYXCheck_SG4    ; Plot the pixel
; Plot (x_Center - y, -x + y_Center)
        LDA     x0+1
        LDB     #CircleScale_SG4    ; seems to scale better
        MUL                         ; Multiply A * B
        NEGA
        ADDA    y_Center+1
        LDB     x_Center+1
        SUBB    y0+1
; Fall through to plot last pixel and return
;
; Do the set command, but check to make sure Y & X co-ordinates are not beyond the screen
DoSetYXCheck_SG4:
        TSTA
    	BPL     >
        CLRA
!       CMPA    #ScreenHeight_SG4-1
        BLE     >
        LDA     #ScreenHeight_SG4-1
!       TSTB
        BPL     >
        CLRB
!       CMPB    #ScreenWidth_SG4-1
        BLE     >
        LDB     #ScreenWidth_SG4-1
!       JMP     SET_SG4