; Draw command
; Start of draw commands is at _StrVar_PF00 and terminated with a zero
;
; Variables used
DrawBlankFlag           FCB     0             ; Flag 0 = draw, any other value will skip drawing
RelativeMoveFlag        FCB     0             ; Flag to signify if we are doing a relative move or not
DrawDestination         FCB     8,16          ; y,x co-ordinates of the Draw Destination
DrawStart               FCB     8,16          ; y,x co-ordinates of the Draw Start
ScaleFlag               FCB     0             ; Flag to see if we are scaling the draw command
ScaleValue              FCB     4             ; Scale value for the draw command
AngleValue              FCB     0             ; Angle value for the draw command
NoUpdateFlag            FCB     0             ; Flag to see if we are doing a no update move or not

DrawEA:
        INCLUDE         "../DrawMain.asm"
        JSR     LINE_EA         ; Draw the line
        PULS    X               ; Restore the pointer to our draw string
        JMP     DrawMainLoop4   ; go get next command
