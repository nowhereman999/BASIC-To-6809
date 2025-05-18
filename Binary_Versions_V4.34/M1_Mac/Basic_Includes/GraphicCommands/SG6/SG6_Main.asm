* Set the width and height of the SG6 screen
* Only has colours 0 = black & colours 1 & 2
ScreenWidth_SG6     EQU 64
ScreenHeight_SG6    EQU 48
BytesPerRow_SG6     EQU ScreenWidth_SG6/2
Screen_Size_SG6     EQU $200
;
; SET(X,Y,C) & POINT(X,Y) FOR SEMIGRAPHICS 6  (SG6)  USES D,X,U
; SET(X,Y,C) STARTS AT (SET_SG6): POINT(X,Y) STARTS AT (POINT_SG6)
Y_SG6       FCB         0,86        ; Y COORD  (0-47) , 1/3 FIXED POINT
X_SG6       FCB         0           ; X COORD  (0-63)
C_SG6       FCB         0           ; COLOR FOR PIXEL (0-2) BLACK=0
FRAC_SG6    FCB         0,3         ; FIXED POINT FRACTION , 3 MULTIPLIER
TABLE_SG6   FCB         160,144,136,132,130,129  ; TABLE FOR SET
            FCB         223,239,247,251,253,254  ; TABLE FOR RESET

; Line Box & BoxFill commands come here, Colour of pixels has already been set
; Value of A & B need to return unchanged
DoSetSaveAB_SG6:
            PSHS    D
            STA     Y_SG6       ; save the y co-ordinate
            STB     X_SG6       ; save the x co-ordinate
            BSR     SET_SG6     ; go set the pixel
            PULS    D,PC

; Set command from Compiler will come here, x and y have been checked for boundaries
; and LineColour will have the colour to set the pixel
DoSet_SG6:
            STA     Y_SG6       ; save the y co-ordinate
            STB     X_SG6       ; save the x co-ordinate
            LDA     LineColour  ; get the colour
            STA     C_SG6       ; save the colour requested
; Fall through to do the SET routine

SET_SG6     LDU         #TABLE_SG6  ; POINT TO PIXEL TABLE
;    FIND BYTE ADDRESS WHERE PIXEL LIVES            
            LDD         -6,U        ; A=Y COORD (0-47): B= 1/3            
            MUL                     ; REG A = INT(Y/3) will be (0-15)
            STB         -2,U        ; STORE FRAC FOR LATER
            CLRB                    ; REG D = INT(Y/3) * 256
            LSRA                    ;
            RORB                    ; REG D = INT(Y/3) * 128
            LSRA                    ;
            RORB                    ; REG D = INT(Y/3) * 64
            ADDB        -4,U        ; LD X : REG D = INT(Y/3) * 64 + X
            LSRA                    ;
            RORB                    ; REG D = INT(Y/3) * 32 + INT(X/2)
            ADDA        BEGGRP      ; REG D = BASE ADDRESS + INT(Y/3) * 32 INT(X/2)
            TFR         D,X         ; REG X = BASE ADDRESS + INT(Y/3) * 32 INT(X/2)

;    LOAD BYTE ADDRESS WITH NEW PIXEL + OLD PIXELS    
            LDD         -2,U        ; A=FRAC  B=3
            MUL                     ; A=REMAINDER 
            LDB         -4,U        ; LD X COORD
            LSRB                    ; STORE (X AND 1) IN CARRY FLAG
            ROLA                    ; REMAINDER * 2    + (X AND 1)
            LDB         ,X          ; GET OLD PIXELS
            BMI         LP1_SG6     ; BRANCH IF NOT TEXT
            LDB         #128        ; OK TEXT, MAKE 6 PIXELS BLACK
            STB         ,X          ; PUT BACK ON SCREEN
LP1_SG6     LDB         -3,U        ; GET COLOR (0-2)
            BNE         LP2_SG6     ; IF C=(1-2) THEN SET PIXEL
;     RESET(X,Y)
            ADDA        #6          ; ADJUST TABLE FOR RESET VALUES
            LDB         ,X          ; GET OLD PIXELS            
            ANDB        A,U         ; REMOVE RESET PIXEL INFO
            STB         ,X          ; RESET PIXEL TO BLACK
            RTS                     ; RETURN             
;     SET(X,Y,C)
LP2_SG6     DECB                    ; SHIFT FROM COLOR(1-2) TO ACTUAL BIT COLOR(0-1)
            BNE         LP3_SG6     ; IF COLOR=1 GO SET BIT 6
            LDB         #191        ; LOAD CLEAR BIT 6 MASK
            ANDB        ,X          ; RESET COLOR TO 0 OF OLD PIXEL            
            BRA         LP4_SG6     ;
LP3_SG6     LDB         #64         ; GET BIT 6
            ORB         ,X          ; SET COLOR TO 1 OF OLD PIXEL        
LP4_SG6     ORB         A,U         ; COMBINE OLD WITH NEW PIXELS         
            STB         ,X          ; PUT NEW PIXEL ON SCREEN            
            RTS                     ; RETURN

;     POINT(X,Y) FOR SEMIGRAPHICS 6  (SG6)    REGISTER B RETURNS COLOR VALUE
Y2_SG6      FCB         0,86        ; Y COORD  (0-47) , 1/3 FIXED POINT
X2_SG6      FCB         0           ; X COORD  (0-63)
FRAC2_SG6   FCB         0,3         ; FIXED POINT FRACTION , 3 MULTIPLIER
TABLE2_SG6  FCB         32,16,8,4,2,1  ; PIXELS 5-0        


POINT_SG6:
            STA     Y2_SG6       ; save the y co-ordinate
            STB     X2_SG6       ; save the x co-ordinate
            LDU     #TABLE2_SG6 ; POINT TO PIXEL TABLE
;       FIND BYTE ADDRESS WHERE PIXEL LIVES            
            LDD         -5,U        ; LD YL : A=Y COORD (0-47): B= 1/3            
            MUL                     ; REG A = INT(Y/3) will be (0-15)
            STB         -2,U        ; ST FRAC : STORE FRAC FOR LATER
            CLRB                    ; REG D = INT(Y/3) * 256
            LSRA                    ;
            RORB                    ; REG D = INT(Y/3) * 128
            LSRA                    ;
            RORB                    ; REG D = INT(Y/3) * 64
            ADDB        -3,U        ; LD XL : REG D = INT(Y/3) * 64 + X
            LSRA                    ;
            RORB                    ; REG D = INT(Y/3) * 32 + INT(X/2)
            ADDA        BEGGRP      ; REG D = BASE ADDRESS + INT(Y/3) * 32 INT(X/2)
            TFR         D,X         ; REG X = BASE ADDRESS + INT(Y/3) * 32 INT(X/2)
;    FIND COLOR OF PIXEL AT X,Y COORD AND STORE IN REGISTER B
            LDD         -2,U        ; A=FRAC  B=3
            MUL                     ; A=REMAINDER 
            LDB         -3,U        ; GET X
            LSRB                    ; STORE (X AND 1) IN CARRY FLAG
            ROLA                    ; REMAINDER * 2    + (X AND 1)            
            LDB         ,X          ; GET OLD PIXELS            
            BMI         LP5_SG6     ; GO RESET PIXEL AND REMOVE TEXT IF BIT 7 IS 0
            LDB         #255        ; IF ALPHA THEN RETURN -1
            BRA         LP6_SG6     ; 
LP5_SG6     ANDB        A,U         ; SEE IF OLD PIXEL IS BLACK
            BEQ         LP6_SG6     ; GO RETURN 0
            LDB         ,X          ; GET OLD PIXELS
            ANDB        #64         ; GET COLOR BIT 6
            BEQ         LP7_SG6     ; IF BIT 6=0,RETURN 1
            LDB         #1          ; ELSE RETURN 2
LP7_SG6     INCB                    ; ADJUST TO CORRECT COLOR #
LP6_SG6     RTS                     ; RETURN  REG B= COLOR CODES:ALPHA=-1,BLACK=0,BLUE=1,RED=2

; Colour the screen Colour B
GCLS_SG6:
        STB     C_SG6       ; save the colour requested
        LDA     #ScreenHeight_SG6-1
@LoopA
        LDB     #ScreenWidth_SG6-1
!       JSR     DoSetSaveAB_SG6
        DECB
        BPL     <
        DECA
        BPL     @LoopA
        RTS