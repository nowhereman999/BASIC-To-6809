CircleScale_SG6H     EQU 80              ; 64 too tall   ; 32 is way too tall  ; 96 not tall enough
;
* Circle command
* Enter with:
* x Center is at 4,S
* y Center is at 3,S
* radius is at 2,S

; CIRCLE routine to draw a circle centered at (x_Center, y_Center) with radius r
CIRCLE_SG6H:
        LDA     LineColour      ; Get the colour requested
        STA     C_SG6H           ; Save the colour for the circle command to use
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
CircleLoop_SG6H:     
        LDD     x0        
        CMPD    y0         ; Compare D with the value on the stack, fix the stack
        BLE     >
        RTS
!
        BSR     PlotPoints_SG6H
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

        BRA     CircleLoop_SG6H          ; Loop until x <= y
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
        BRA     CircleLoop_SG6H      ; Loop until x <= y

PlotPoints_SG6H:
        ; Plot (x + x_Center, y + y_Center)
        LDB     x0+1
        ADDB    x_Center+1
        LDA     y0+1
        ADDA    y_Center+1
        BSR     DoSetYXCheck_SG6H            ; Plot the pixel
        ; Plot (-x + x_Center, y + y_Center)
        LDB     x_Center+1
        SUBB    x0+1
        LDA     y0+1
        ADDA    y_Center+1
        BSR     DoSetYXCheck_SG6H            ; Plot the pixel
        ; Plot (x + x_Center, -y + y_Center)
        LDB     x0+1
        ADDB    x_Center+1
        LDA     y_Center+1
        SUBA    y0+1
        BSR     DoSetYXCheck_SG6H            ; Plot the pixel
        ; Plot (-x + x_Center, -y + y_Center)
        LDB     x_Center+1
        SUBB    x0+1
        LDA     y_Center+1
        SUBA    y0+1
        BSR     DoSetYXCheck_SG6H            ; Plot the pixel
        ; Plot (y + x_Center, x + y_Center)
        LDB     y0+1
        ADDB    x_Center+1
        LDA     x0+1
        ADDA    y_Center+1
        BSR     DoSetYXCheck_SG6H            ; Plot the pixel
        ; Plot (-y + x_Center, x + y_Center)
        LDB     x_Center+1
        SUBB    y0+1
        LDA     x0+1
        ADDA    y_Center+1
        BSR     DoSetYXCheck_SG6H            ; Plot the pixel
        ; Plot (y + x_Center, -x + y_Center)
        LDB     y0+1
        ADDB    x_Center+1
        LDA     y_Center+1
        SUBA    x0+1
        BSR     DoSetYXCheck_SG6H            ; Plot the pixel
        ; Plot (-y + x_Center, -x + y_Center)
        LDB     x_Center+1
        SUBB    y0+1
        LDA     y_Center+1
        SUBA    x0+1
; Fall through to plot last pixel and return
;
; Circle Command comes here
; Do the set command, but check to make sure Y & X co-ordinates are not beyond the screen
DoSetYXCheck_SG6H:
            TSTA
            BPL     >
            CLRA
!           CMPA    #ScreenHeight_SG6H-1
            BLE     >
            LDA     #ScreenHeight_SG6H-1
!           STA     Y_SG6H 		; save the y co-ordinate
            TSTB
            BPL     >
            CLRB
!           CMPB    #ScreenWidth_SG6H-1
            BLE     >
            LDB     #ScreenWidth_SG6H-1
!           STB     X_SG6H      ; save the x co-ordinate
            JMP     SET_SG6H    ; go set the pixel

