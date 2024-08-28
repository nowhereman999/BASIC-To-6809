* Code module vidset2.asm
* Setting CoCo 1/2 hires graphics modes
* Normal start of text screen 			$0400
* Preferred start of 1st graphics screen page	$0E00
*
* PMODE Type,Where to start this graphics screen
* Enter with:
* A = PMODE #   
* B = PMODE SCREEN #

PMODE	  	RMB  1		* PMODE value
Screen_Number	FCB  0		* Screen number to start at
HORBYT		RMB  1		* Number of bytes per horizontal line
PageSize	RMB  1		* MSB of the Size of the screen page
BAKCOL		RMB  1		* Background color
FORCOL		FCB  1		* Foreground color (default to 1)
BEGGRP		RMB  2		* Start address of the screen page
ENDGRP		RMB  2		* End address of the screen page
CSSVAL		RMB  1		* CSS value
PSETJump	RMB  2		* Jump address for PSET
LINEJump	RMB  2		* Jump address for LINE
CIRCLEJump	RMB  2		* Jump address for CIRCLE
PAINTJump	RMB  2		* Jump address for PAINT

; Variables
x0              RMB 2
y0              RMB 2
decision        RMB 2
x_Center        RMB 2
y_Center        RMB 2
radius          RMB 2

; LINE Variables
stepY      RMB    2
stepX      RMB    2
startX     RMB    2
startY     RMB    2
endX       RMB    2
endY       RMB    2
deltaX     RMB    2
deltaY     RMB    2
error0     RMB    2
error2     RMB    2


* Enters with A = PMODE # and B is the screen number
DoPMODE:
        STA     PMODE		; Save the PMODE value
	DECB			; Decrement screen number
	BMI	>   		; Don't update the screen number if it is negative
	STB	Screen_Number   ; Update the Screen # to draw on
!       ASLA                    ; MULT MODE BY 2 - TABLE HAS 2 BYTES PER ENTRY
        LDU     #L9706+1        ; LOOKUP TABLE
        LDB     A,U             ; Get THE AMOUNT OF MEMORY REQUIRED FOR ONE GRAPHIC PAGE
	STB	PageSize	* Save the Pagesize value
        LEAU    -1,U            ; POINT U TO PREVIOUS BYTE IN TABLE
        LDB     A,U             ; GET THE NUMBER OF BYTES/HORIZONTAL LINE
        STB     HORBYT          ; AND SAVE IT IN HORBYT
        LSRA                    ; RESTORE PMODE VALUE
        STA     PMODE		; SAVE IT
        CLRA                    ; BACKGROUND COLOR
        STA     BAKCOL          ; SET BACKGROUND COLOR TO ZERO
        LDA     #$03            ; FOREGROUND COLOR
        STA     FORCOL          ; SET FOREGROUND COLOR
* Set the Video Start Address
	LDA	PageSize	; Get the Pagesize value
	LDB     Screen_Number   ; Get the Screen # to draw on
	MUL                     ; D = A * B
	EXG	A,B		; Fix value so its * $100
	ADDA    #$0E            ; Add the Preferred start of 1st graphics screen page ($E00)
	STD     BEGGRP		; Save the Video Start Address
	ADDA	PageSize	; Add the Pagesize value
	STD	ENDGRP		; Save the Video End Address
* Set the Jump location for commands depending on the PMODE value
* (saves time looking up which PMODE the command is using every time it's called)
	LDB     PMODE		; Get the PMODE value
	LSLB                    ; Multiply by 2
	LDX     #JumpPointerTable ; LOOKUP TABLE
	ABX                     ; X=X+B, it now points to the correct table entry
	LDU	#PSETJump	; Point at the Jump locations
!	LDD     ,X		; Get the Jump address for the PMODE value
	STD	,U++		; Save the Jump address for the PMODE value
	LEAX	LINE0-PSET0,X	; Point at the next Jump address
	CMPX    #PAINT0+LINE0-PSET0	; Compare X to the end of the table
	BLO	<
	RTS

JumpPointerTable:
	FDB     PSET0,PSET1,PSET2,PSET3,PSET4
	FDB     LINE0,LINE1,LINE2,LINE3,LINE4
	FDB     CIRCLE0,CIRCLE1,CIRCLE2,CIRCLE3,CIRCLE4
	FDB     PAINT0,PAINT1,PAINT2,PAINT3,PAINT4
	


* Screen mode and Screen # to show
* Enter with:
* A = Screen Mode (0 or 1) where 0 = Text Screen, 1 = Graphics Screen
* B = Colour set  (0 or 1) where 0 = Colours 1,   1 = Colours 2
DoScreen:
	TSTB                    ; Test B
	BMI     >		; if negative then no Colour set change
	BEQ	@SaveCSS	; IF B = 0, use B as is
	LDB 	#$08		; ELSE use B as 8
@SaveCSS:
	STB 	CSSVAL		; Save the CSSVAL for setting the VDG CSS settings
!	TSTA                    ; Test A
	BNE     L95CF           ; BRANCH IF GRAPHIC MODE, OTHERWISE SET UP ALPHA GRAPHIC MODE
; THIS CODE WILL RESET THE DISPLAY PAGE REGISTER IN THE
; SAM CHIP TO 2 ($400) AND RESET THE SAMS VDG CONTROL
; REGISTER TO 0 (ALPHA-NUMERICS). IN ADDITION, IT WILL
; RESET THE VDG CONTROL PINS TO ALPHA-GRAPHICS MODE.
; SET UP THE SAM AND VDG TO GRAPHICS MODE
L95AC
        PSHS    X,B,A           ; SAVE REGISTERS
        LDX   	#SAMREG+8       ; POINT X TO THE MIDDLE OF THE SAM CNTL REG
        STA     10,X            ;
        STA     $08,X           ;
        STA     $06,X           ;
        STA     $04,X           ; RESET SAM DISPLAY PAGE TO $400
        STA     $02,X           ;
        STA     $01,X           ;
        STA     -2,X            ;
        STA     -4,X            ;
        STA     -6,X            ; RESET SAMS VDG TO ALPHA-NUMERIC MODE
        STA     -8,X            ;
        LDA     PIA1+2          ; GET DATA FROM PIA1, PORT B
        ANDA    #$07            ; FORCE ALL BITS TO ZERO, KEEP ONLY CSS DATA
        STA     PIA1+2          ; PUT THE VDG INTO ALPHA-GRAPHICS MODE
        PULS    A,B,X,PC        ; RETURN
L95CF
	PSHS    X,B,A
        LDA     PMODE		; GET CURRENT PMODE VALUE
        ADDA    #$03            ; ADD 3 - NOW 3-7 ONLY 5 OF 8 POSSIBLE MODES USED
        LDB     #$10            ; $10 OFFSET BETWEEN PMODES
        MUL                     ;  GET PMODE VALUES FOR VDG GM0, GM1, GM2
        ORB     #$80            ; FORCE BIT 7 HIGH (VDG A/G CONTROL)
        ORB     CSSVAL          ; OR IN THE VDG CSS DATA
        LDA     PIA1+2          ; GET PIA1, PORT B
        ANDA    #$07            ; MASK OFF THE VDG CONTROL DATA
        PSHS    A               ; SAVE IT
        ORB     ,S+             ; OR IT WITH THE VDG VALUES CALCULATED ABOVE
        STB     PIA1+2          ; STORE IT INTO THE PIA
        LDA     BEGGRP		; GET MSB OF START OF GRAPHIC PAGE
        LSRA                    ;  DIVIDE BY 2 - ACCA CONTAINS HOW MANY 512 BYTE
				; BLOCKS IN STARTING ADDR
        JSR     >L960F          ; GO SET SAM CONTROL REGISTER
        LDA     PMODE		; GET PMODE VALUE
        ADDA    #$03            ; ADD IN BIAS TO ADJUST TO PMODE THE SAM REGISTER WANTS
        CMPA    #$07            ; WAS PMODE 4?
        BNE     L95F7           ; NO
        DECA                    ;  DECREMENT ACCA IF PMODE 4 (SAME VDG AS PMODE3)
L95F7   BSR     L95FB           ; SET THE SAMS VDG REGISTER
        PULS    A,B,X,PC        ; RESTORE REGISTERS AND RETURN

L95FB:  
	LDB     #$03            ; 3 BITS IN SAM VDG CONTROL REGISTER
; ENTER WITH DATA TO GO IN VDG REGISTER IN BOTTOM 3 BITS OF ACCA
        LDX     #SAMREG         ; POINT X TO SAM CONTROL REGISTER
L9600   RORA                    ;  PUT A BIT INTO CARRY FLAG
	BCC     L9607           ; BRANCH IF BIT WAS A ZERO
        STA     $01,X           ; SET SAM REGISTER BIT
        BRA     L9609           ; DO NEXT BIT
L9607   STA     ,X              ; CLEAR SAM REGISTER
L9609   LEAX    $02,X           ; NEXT BIT IN REGISTER
        DECB                    ;  DONE ALL BITS?
        BNE     L9600           ; NO
        RTS
L960F   LDB     #$07            ; 7 BITS IN SAM DISPLAY PAGE REGISTER
	LDX     #SAMREG+6       ; POINT X TO SAM DISPLAY PAGE REGISTER
        BRA     L9600           ; GO SET THE REGISTER
L9616   LDA     PIA1+2          ; GET PIA1, PORT B
        ANDA    #$F7            ; MASK OFF VDG CSS CONTROL BIT
        ORA     CSSVAL          ; OR IN CSS COLOR DATA
        STA     PIA1+2          ; RESTORE IT IN PIA1
        RTS

* Clear the graphics screen in with Colour B
DoPCLS:
L9536           LDA         #$55            ; CONSIDER EACH BYTE AS 4 GROUPS OF 2 BIT SUB-NIBBLES
                MUL                         ; MULT BY COLOR
                TFR         B,A
                TFR         D,U
                LDX         BEGGRP          ; GET STARTING ADOR
L953B           STD         ,X++            ; SET BYTE TO PROPER COLOR
                CMPX        ENDGRP          ; AT END OF GRAPHIC PAGE?
                BNE         L953B           ; NO
                RTS
		
; EVALUATE AN EXPRESSION AND CONVERT IT TO A PROPER COLOR CODE
; DEPENDING ON THE PMODE AND CSS; ILLEGAL FUNCTION CALL IF > 8 -
; RETURN COLOR VALUE IN ACCB; CSS VALUE IN ACCA
;L955A           JSR         EVALEXPB        ; EVALUATE EXPRESSION
;L955D           CMPB        #$09            ; ONLY ALLOW 0-8
;                LBCC        LB44A           ; ILLEGAL FUNCTION CALL IF BAD COLOR
GetColourBCSSA:
                CLRA                        ; VDG CSS VALUE FOR FIRST COLOR SET
                CMPB        #$05            ; FIRST OR SECOND COLOR SET?
                BLO         L956C           ; BRANCH IF FIRST SET
                LDA         #$08            ; VDG CSS VALUE FOR SECOND COLOR SET
                SUBB        #$04            ; MAKE 5-8 BECOME 1-4
L956C           PSHS        A               ; SAVE VDG CSS VALUE ON THE STACK
                LDA         PMODE           ; GET PMODE
                RORA                        ; 4 COLOR OR 2 COLOR
                BCC         L957B           ; 2 COLOR
                TSTB                        ; WAS COLOR = 0
                BNE         L9578           ; NO
L9576           LDB         #$04            ; IF SO, MAKE IT 4
L9578           DECB                        ; CONVERT 1-4 TO 0-3
L9579           PULS        A,PC            ; PUT VDG CSS VALUE IN ACCA AND RETURN
L957B           RORB                        ; CHECK ONLY THE LSB OF COLOR IF IN 2 COLOR MODE
                BLO         L9576           ; BRANCH IF ODD - FORCE ACCB TO 3
                CLRB                        ; FORCE ACCB = 0 IF EVEN
                BRA         L9579           ; RETURN

; TABLE OF HOW MANY BYTES/GRAPHIC ROW AND HOW MUCH RAM
; FOR ONE HI RES SCREEN FOR THE PMODES. ROWS FIRST,
; BYTES (IN 256 BYTE BLOCKS) SECOND.
L9706 	FCB     $10,$06         ; PMODE 0
L9708   FCB     $20,$0C         ; PMODE 1
L970A   FCB     $10,$0C         ; PMODE 2
L970C   FCB     $20,$18         ; PMODE 3
L970E   FCB     $20,$18         ; PMODE 4
