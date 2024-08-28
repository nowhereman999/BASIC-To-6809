; Clear the 32x16 normal boot up screen
; Enter with:
; B = value to fill screen with
; Clobbers all the registers
;
; Why not stack blast :)
CLS_B:  TFR     B,A           ; A = B
        TFR     D,X           ; X = D
        LEAY    ,X            ; Y = X
        LDU     #$0600        ; Set User stack to the Starting point
!       PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        CMPU    #$420         ; Are we just about done?
        BNE     <             ; Keep looping if not
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D             ; Push D on screen
        STU     CURPOS        ; Save U which is now $400 in the CURSOR position
        RTS                   ; Return
        