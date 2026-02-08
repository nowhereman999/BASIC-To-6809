; Draw command
; Start of draw commands is at _StrVar_PF00 and terminated with a zero
;
; Variables used
DrawBlankFlag           FCB     0             ; Flag 0 = draw, any other value will skip drawing
RelativeMoveFlag        FCB     0             ; Flag to signify if we are doing a relative move or not
DrawStartY              FDB     96            ; y co-ordinate of the Draw Start
DrawStartX              FDB     320           ; x co-ordinate of the Draw Start
DrawDestinationY        FDB     96            ; y co-ordinate of the Draw Destination
DrawDestinationX        FDB     320           ; x co-ordinate of the Draw Destination
ScaleFlag               FCB     0             ; Flag to see if we are scaling the draw command
ScaleValue              FCB     4             ; Scale value for the draw command
AngleValue              FCB     0             ; Angle value for the draw command
NoUpdateFlag            FCB     0             ; Flag to see if we are doing a no update move or not

DrawHIG154:
        INCLUDE         "../DrawMainHIGBig.asm"
        LDY     #LINE_HIG154    ; Y points at the routine to draw the line
        JSR     DoCC3Graphics   ; Prep for CoCo 3 graphics and then JSR ,Y and restore & return
        PULS    X               ; Restore the pointer to our draw string
        JMP     DrawMainLoop4   ; go get next command