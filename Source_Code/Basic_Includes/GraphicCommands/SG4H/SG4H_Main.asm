* Set the width and height of the SG4H screen
ScreenWidth_SG4H     EQU 64
ScreenHeight_SG4H    EQU 32
BytesPerRow_SG4H     EQU ScreenWidth_SG4H/2
Screen_Size_SG4H     EQU $0C00

; Line Box & BoxFill commands come here, Colour of pixels has already been set
; Value of A & B need to return unchanged
DoSetSaveAB_SG4H:
            PSHS    D
            STA     Y_SG4H       ; save the y co-ordinate
            STB     X_SG4H       ; save the x co-ordinate
            BSR     SET_SG4H     ; go set the pixel
            PULS    D,PC

; SG4 HYBRID & SG6 HYBRID GRAPHICS MODES: SET(X,Y,C) & POINT(X,Y)  USES D,U
; SG4 HYBRID REQUIRES SG4H GRAPHICS MODE: SG6 HYBRID REQUIRES SG12 GRAPHICS MODE
; SET(X,Y,C) STARTS AT (SET_SG4H) & POINT(X,Y) STARTS AT (POINT_SG4H)
Y_SG4H      FCB         0,0         ; Y LOCATION SG4H(0-31),SG4H(0-47)
X_SG4H      FCB         0           ; X LOCATION (0-63)
C_SG4H      FCB         0           ; C FOR COLOR (0-8)
TEMP_SG4H   FCB         0			; TEMP STORAGE

; Set command from Compiler will come here, x and y have been checked for boundaries
; and LineColour will have the colour to set the pixel
DoSet_SG4H:
            STA     Y_SG4H       ; save the y co-ordinate
            STB     X_SG4H       ; save the x co-ordinate
            LDA     LineColour  ; get the colour
            STA     C_SG4H       ; save the colour requested
; Fall through to do the SET routine
;       FIND BYTE ADDRESS WHERE PIXEL LIVES
SET_SG4H   
            LDD         Y_SG4H      ; GET Y COORD CLR B            
            LSRA                    ; Y
            RORB                    ; TIMES 64            
            ADDB        X_SG4H      ; ADD X COORD
            LSRA                    ;            
            RORB                    ; D = Y*64 + INT(X/2)
			ADDA		BEGGRP		; D = BASE ADDRESS + Y*32 + INT(X/2)
            TFR         D,U         ; U HOLDS ADDRESS
;      GET PIXEL AND COLOR INFO
			LDA			,U			; GET OLD ADDRESS
			BMI			LP0_SG4H	; NOT TEXT?
			LDA			#128		; GET BLACK PIXELS
			STA			,U			; SET PIXELS TO BLACK
LP0_SG4H    LDA 		X_SG4H      ; GET X COORD
			LSRA 					; REMAINDER OF X/2 IN CARRY BIT
			LDA			#5			; LOAD ODD PIXEL %0101
			BCS			LP1_SG4H	; IF ODD, SKIP MAKING IT EVEN
			LSLA					; LOAD EVEN PIXEL %1010
LP1_SG4H	LDB         C_SG4H      ; LOAD COLOR
			BNE 		LP2_SG4H   	; BRANCH IF COLOR=(1-8)			
;		RESET(X,Y) WHEN COLOR IS 0=BLACK
			COMA					; FLIP PIXEL BITS
			ANDA		,U			; CLEAR NEW PIXEL
			STA			,U 			; RESET(X,Y)    TOP PART OF PIXEL
			STA			32,U    	; RESET(X,Y+1) BOTTOM PART OF PIXEL
			RTS 					; RETURN
;		SET(X,Y,C)			
LP2_SG4H    ORA			,U			; ADD NEW PIXELS TO OLD PIXELS
			ANDA		#15			; CHOP OFF OLD COLOR INFO
			STA			TEMP_SG4H	; TEMP STORE NEW & OLD PIXELS
			ADDB        #7          ; (C-1)+8
            LSLB                    ; *2
            LSLB                    ; *2
            LSLB                    ; *2    (C-1)*16+8*16
            LSLB                    ; *2    (C-1)*16+128		
            ADDB        TEMP_SG4H   ; B=COLOR + NEW & OLD PIXEL
			STB			,U   		; SET(X,Y,C)  TOP PART OF PIXEL
			STB 		32,U 		; SET(X,Y+1,C)  BOTTOM PART OF PIXEL
            RTS                     ; RETURN

;   SG4 HYBRID & SG6 HYBRID  POINT(X,Y) (RETURNS COLOR # IN REGISTER B) USES D,U
;   COLOR # IN REGISTER B: TEXT=-1 , BLACK=0 , (1-8) FOR THE 8 COLORS
;       FIND BYTE ADDRESS WHERE PIXEL LIVES
POINT_SG4H:
        STA     Y_SG4H
        STB     X_SG4H
;   SEMI 8 , 12 , 24   POINT(X,Y)  (RETURNS COLOR # IN REGISTER B)   USES D,X,U
;       FIND BYTE ADDRESS WHERE PIXEL LIVES
DoPOINT_SG4H:  
			LDD         Y_SG4H      ; GET Y COORD CLR B            
            LSRA                    ; Y
            RORB                    ; TIMES * 64            
            ADDB        X_SG4H       ; ADD X COORD
            LSRA                    ;            
            RORB                    ; D = Y*64 + INT(X/2)
			ADDA		BEGGRP		; D = BASE ADDRESS + Y*64 + INT(X/2)
            TFR         D,U         ; U HOLDS ADDRESS
;      GET COLOR #     
			LDB			,U 			;GET OLD PIXEL INFO
			BMI 		LP3_SG4H	;BRANCH IF NOT TEXT
			LDB 		#255        ; IS TEXT B=-1			
			RTS       				; RETURN 		
LP3_SG4H	LDB			X_SG4H      ; GET X COORD 
            LSRB 					; REMAINDER OF X/2 IN CARRY BIT
			LDB			#5			; LOAD ODD PIXEL %0101
			BCS			LP4_SG4H	; IF ODD, SKIP MAKING IT EVEN
			LSLB					; LOAD EVEN PIXEL %1010
LP4_SG4H	ANDB 		,U  		; SEE IF PIXEL IS SET
			BEQ         LP5_SG4H	; IF NOT SET THEN RETURN B=0
			LDB 		,U          ; GET OLD PIXEL INFO			
			LSRB                    ; /2
            LSRB                    ; /2
            LSRB                    ; /2    
            LSRB                    ; /2
			SUBB		#7			; ADJUST COLOR BY -7  B=COLOR #
LP5_SG4H	RTS                     ; RETURN B

; Colour the screen Colour B
GCLS_SG4H:
        STB     C_SG4H       ; save the colour requested
        LDA     #ScreenHeight_SG4H-1
@LoopA
        LDB     #ScreenWidth_SG4H-1
!       JSR     DoSetSaveAB_SG4H
        DECB
        BPL     <
        DECA
        BPL     @LoopA
        RTS