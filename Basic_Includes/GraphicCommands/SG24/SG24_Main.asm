; Graphics commands for screen mode SG24
; Resolution of 64x192x4 colours
ScreenWidth_SG24    EQU 64
ScreenHeight_SG24   EQU 192
BytesPerRow_SG24    EQU ScreenWidth_SG24/2
Screen_Size_SG24    EQU $1800
;
; DoSetYX_SG24 a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate
;
SET_SG24:
DoSetYX_SG24:
            PSHS        D
            STA         Y_SG24      ; Save Y location
            STB         X_SG24      ; Save the X location
            BSR         GoSet_SG24
            PULS        D,PC

;   SEMI 8 , 12 , 24   SET(X,Y,C) & POINT(X,Y)  USES D,U
; SET(X,Y,C) STARTS AT (SET_SG24): POINT(X,Y) STARTS AT (POINT_SG24)
Y_SG24       FCB         0,0         ; Y LOCATION SG24(0-63),SG24(0-96),SG24(0-191)
X_SG24       FCB         0           ; X LOCATION (0-63)
C_SG24       FCB         0           ; C FOR COLOR (0-8)
TEMP_SG24    FCB         0			; TEMP STORAGE

; DoSet_SG24 a dot on screen
; Enter with:
; A = y coordinate
; B = x coordinate

DoSet_SG24:
        STA     Y_SG24      ; Save Y location
        STB     X_SG24      ; Save the X location
        LDA     LineColour    ; Get the Set colour
        STA     C_SG24        ; Save the Colour to be used
;       FIND BYTE ADDRESS WHERE PIXEL LIVES
GoSet_SG24  LDD         Y_SG24       ; GET Y COORD CLR B            
            LSRA                    ; Y
            RORB                    ; TIMES
            LSRA                    ; 32            
            RORB                    ; 
            ADDB        X_SG24       ; ADD X COORD
            LSRA                    ;            
            RORB                    ; D = Y*32 + INT(X/2)
			ADDA		BEGGRP		; D = BASE ADDRESS + Y*32 + INT(X/2)
            TFR         D,U         ; U POINTS TO PIXEL ADDRESS
;      GET PIXEL AND COLOR INFO
			LDA			,U			; GET OLD ADDRESS
			BMI			LP0_SG24		; NOT TEXT?
			LDA			#128		; GET BLACK PIXELS
			STA			,U			; SET TEXT TO BLACK PIXELS
LP0_SG24    LDA 		X_SG24       ; GET X COORD
			LSRA 					; REMAINDER OF X/2 IN CARRY BIT
			LDA			#5			; LOAD ODD PIXEL %0101
			BCS			LP1_SG24		; IF ODD, SKIP MAKING IT EVEN
			LSLA					; LOAD EVEN PIXEL %1010
LP1_SG24	LDB         C_SG24       ; LOAD COLOR
			BNE 		LP2_SG24    	; BRANCH IF COLOR=(1-8)			
;		RESET(X,Y) WHEN COLOR IS 0=BLACK
			COMA					; FLIP PIXEL BITS
			ANDA		,U			; CLEAR NEW PIXEL
			STA			,U 			; RESET(X,Y)
			RTS 					; RETURN
;		SET(X,Y,C)			
LP2_SG24     ORA			,U			; ADD NEW PIXELS TO OLD PIXELS
			ANDA		#15			; CHOP OFF OLD COLOR INFO
			STA			TEMP_SG24	; TEMP STORE NEW & OLD PIXELS
			ADDB        #7          ; (C-1)+8 CALCULATE COLOR BITS
            LSLB                    ; *2
            LSLB                    ; *2
            LSLB                    ; *2    (C-1)*16+8*16
            LSLB                    ; *2    (C-1)*16+128		
            ADDB        TEMP_SG24    ; B=COLOR + NEW & OLD PIXEL
			STB			,U   		; SET(X,Y,C)
            RTS                     ; RETURN
;   SEMI 8 , 12 , 24   POINT(X,Y)  (RETURNS COLOR # IN REGISTER B)   USES D,U
;   COLOR # IN REGISTER B: TEXT=-1 , BLACK=0 , (1-8) FOR THE 8 COLORS

; Get the point on screen and return with it in B
POINT_SG24:
        STA     Y_SG24
        STB     X_SG24

;       FIND BYTE ADDRESS WHERE PIXEL LIVES
DoPOINT_SG24:
		  	LDD         Y_SG24       ; GET Y COORD CLR B            
            LSRA                    ; Y
            RORB                    ; TIMES
            LSRA                    ; 32            
            RORB                    ; 
            ADDB        X_SG24       ; ADD X COORD
            LSRA                    ;            
            RORB                    ; D = Y*32 + INT(X/2)
			ADDA		BEGGRP		; D = BASE ADDRESS + Y*32 + INT(X/2)
            TFR         D,U         ; U POINTS TO PIXEL ADDRESS
;      GET COLOR #     
			LDB			,U 			;GET OLD PIXEL INFO
			BMI 		LP3_SG24		;BRANCH IF NOT TEXT
			LDB 		#255        ; IS TEXT B=-1			
			RTS       				; RETURN 		
LP3_SG24		LDB			X_SG24       ; GET X COORD 
            LSRB 					; REMAINDER OF X/2 IN CARRY BIT
			LDB			#5			; LOAD ODD PIXEL %0101
			BCS			LP4_SG24		; IF ODD, SKIP MAKING IT EVEN
			LSLB					; LOAD EVEN PIXEL %1010
LP4_SG24		ANDB 		,U  		; SEE IF PIXEL IS SET
			BEQ         LP5_SG24		; IF NOT SET THEN RETURN B=0
			LDB 		,U          ; GET OLD PIXEL INFO			
			LSRB                    ; /2
            LSRB                    ; /2
            LSRB                    ; /2    
            LSRB                    ; /2
			SUBB		#7			; ADJUST COLOR BY -7  B=COLOR #			
LP5_SG24		RTS                     ; RETURN B

; Colour the screen Colour B
GCLS_SG24:
        LDX     #SG24_ColourTable
        LDA     B,X
        LDB     B,X
        LDX     BEGGRP
        LEAU    Screen_Size_SG24,X ; Screen Size
        STU     GCLSComp_SG24+1 ; Self mod end address
!       STD     ,X++
GCLSComp_SG24:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS
SG24_ColourTable:
        FCB     $80     ; 0
        FCB     $8F     ; 1
        FCB     $9F     ; 2
        FCB     $AF     ; 3
        FCB     $BF     ; 4
        FCB     $CF     ; 5
        FCB     $DF     ; 6
        FCB     $EF     ; 7
        FCB     $FF     ; 8