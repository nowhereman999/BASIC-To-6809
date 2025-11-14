* Set the width and height of the SG6H screen
ScreenWidth_SG6H     EQU 64
ScreenHeight_SG6H    EQU 48
BytesPerRow_SG6H     EQU ScreenWidth_SG6H/2
Screen_Size_SG6H     EQU $0C00
;
; Line Box & BoxFill commands come here, Colour of pixels has already been set
; Value of A & B need to return unchanged
DoSetSaveAB_SG6H:
            PSHS    D
            STA     Y_SG6H       ; save the y co-ordinate
            STB     X_SG6H       ; save the x co-ordinate
            BSR     SET_SG6H     ; go set the pixel
            PULS    D,PC

; SG4 HYBRID & SG6 HYBRID GRAPHICS MODES: SET(X,Y,C) & POINT(X,Y)  USES D,U
; SG4 HYBRID REQUIRES SG8 GRAPHICS MODE: SG6 HYBRID REQUIRES SG12 GRAPHICS MODE
; SET(X,Y,C) STARTS AT (SET_SG6H) & POINT(X,Y) STARTS AT (POINT_SG6H)
Y_SG6H      FCB         0,0         ; Y LOCATION SG4H(0-31),SG6H(0-47)
X_SG6H      FCB         0           ; X LOCATION (0-63)
C_SG6H      FCB         0           ; C FOR COLOR (0-8)
TEMP_SG6H   FCB         0			; TEMP STORAGE

; Set command from Compiler will come here, x and y have been checked for boundaries
; and LineColour will have the colour to set the pixel
DoSet_SG6H:
            STA     Y_SG6H       ; save the y co-ordinate
            STB     X_SG6H       ; save the x co-ordinate
            LDA     LineColour  ; get the colour
            STA     C_SG6H       ; save the colour requested
; Fall through to do the SET routine
;       FIND BYTE ADDRESS WHERE PIXEL LIVES
SET_SG6H   	LDD         Y_SG6H      ; GET Y COORD CLR B            
            LSRA                    ; Y
            RORB                    ; TIMES 64            
            ADDB        X_SG6H      ; ADD X COORD
            LSRA                    ;            
            RORB                    ; D = Y*64 + INT(X/2)
			ADDA		BEGGRP		; D = BASE ADDRESS + Y*32 + INT(X/2)
            TFR         D,U         ; U HOLDS ADDRESS
;      GET PIXEL AND COLOR INFO
			LDA			,U			; GET OLD ADDRESS
			BMI			LP0_SG6H	; NOT TEXT?
			LDA			#128		; GET BLACK PIXELS
			STA			,U			; SET PIXELS TO BLACK
LP0_SG6H    LDA 		X_SG6H      ; GET X COORD
			LSRA 					; REMAINDER OF X/2 IN CARRY BIT
			LDA			#5			; LOAD ODD PIXEL %0101
			BCS			LP1_SG6H	; IF ODD, SKIP MAKING IT EVEN
			LSLA					; LOAD EVEN PIXEL %1010
LP1_SG6H	LDB         C_SG6H      ; LOAD COLOR
			BNE 		LP2_SG6H   	; BRANCH IF COLOR=(1-8)			
;		RESET(X,Y) WHEN COLOR IS 0=BLACK
			COMA					; FLIP PIXEL BITS
			ANDA		,U			; CLEAR NEW PIXEL
			STA			,U 			; RESET(X,Y)    TOP PART OF PIXEL
			STA			32,U    	; RESET(X,Y+1) BOTTOM PART OF PIXEL
			RTS 					; RETURN
;		SET(X,Y,C)			
LP2_SG6H    ORA			,U			; ADD NEW PIXELS TO OLD PIXELS
			ANDA		#15			; CHOP OFF OLD COLOR INFO
			STA			TEMP_SG6H	; TEMP STORE NEW & OLD PIXELS
			ADDB        #7          ; (C-1)+8
            LSLB                    ; *2
            LSLB                    ; *2
            LSLB                    ; *2    (C-1)*16+8*16
            LSLB                    ; *2    (C-1)*16+128		
            ADDB        TEMP_SG6H   ; B=COLOR + NEW & OLD PIXEL
			STB			,U   		; SET(X,Y,C)  TOP PART OF PIXEL
			STB 		32,U 		; SET(X,Y+1,C)  BOTTOM PART OF PIXEL
            RTS                     ; RETURN
     

;   SG4 HYBRID & SG6 HYBRID  POINT(X,Y) (RETURNS COLOR # IN REGISTER B) USES D,U
;   COLOR # IN REGISTER B: TEXT=-1 , BLACK=0 , (1-8) FOR THE 8 COLORS
;       FIND BYTE ADDRESS WHERE PIXEL LIVES
POINT_SG6H:
        STA     Y_SG6H
        STB     X_SG6H
;   SEMI 8 , 12 , 24   POINT(X,Y)  (RETURNS COLOR # IN REGISTER B)   USES D,X,U
;       FIND BYTE ADDRESS WHERE PIXEL LIVES
DoPOINT_SG6H:  
			LDD         Y_SG6H      ; GET Y COORD CLR B            
            LSRA                    ; Y
            RORB                    ; TIMES * 64            
            ADDB        X_SG6H       ; ADD X COORD
            LSRA                    ;            
            RORB                    ; D = Y*64 + INT(X/2)
			ADDA		BEGGRP		; D = BASE ADDRESS + Y*64 + INT(X/2)
            TFR         D,U         ; U HOLDS ADDRESS
;      GET COLOR #     
			LDB			,U 			;GET OLD PIXEL INFO
			BMI 		LP3_SG6H	;BRANCH IF NOT TEXT
			LDB 		#255        ; IS TEXT B=-1			
			RTS       				; RETURN 		
LP3_SG6H	LDB			X_SG6H      ; GET X COORD 
            LSRB 					; REMAINDER OF X/2 IN CARRY BIT
			LDB			#5			; LOAD ODD PIXEL %0101
			BCS			LP4_SG6H	; IF ODD, SKIP MAKING IT EVEN
			LSLB					; LOAD EVEN PIXEL %1010
LP4_SG6H	ANDB 		,U  		; SEE IF PIXEL IS SET
			BEQ         LP5_SG6H	; IF NOT SET THEN RETURN B=0
			LDB 		,U          ; GET OLD PIXEL INFO			
			LSRB                    ; /2
            LSRB                    ; /2
            LSRB                    ; /2    
            LSRB                    ; /2
			SUBB		#7			; ADJUST COLOR BY -7  B=COLOR #
LP5_SG6H	RTS                     ; RETURN B

; Colour the screen Colour B
GCLS_SG6H:
        STB     C_SG6H       ; save the colour requested
        LDA     #ScreenHeight_SG6H-1
@LoopA
        LDB     #ScreenWidth_SG6H-1
!       JSR     DoSetSaveAB_SG6H
        DECB
        BPL     <
        DECA
        BPL     @LoopA
        RTS