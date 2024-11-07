*** THIS ROUTINE WILL CHECK SYNTAX AND CHECK FOR LEGAL VALUES
*** OF SET, RESET & POINT HORIZONTAL AND VERTICAL PARAMETERS
*** AND RETURN THEIR ABSOLUTE SCREEN ADDRESS IN THE X REGISTER
*** WHICH OF THE FOUR PIXELS OF THE GRAPHIC BLOCK SELECTED
*** IS RETURNED IN GRBLOK.
* Speed improvement by using a table lookup for the screen address supplied by Tazman (Scott Cooper)

GRBLOK       RMB    1              ; Graphics Block value

* Get the SET,RESET or POINT screen location
* Enter with ,S = HOR COORD (0 to 63), B = VERT COORD (0 to 31)
* Returns with X = SCREEN ADDRESS and 
GetSRPLocation:
            LDU    ,S++           Get the return address off the stack
            PSHS   B              SAVE VERT COORD
            LSLB					; DOUBLE Y COORD
	        LDX    #YTABLE			; POINT TO (1024 + INT(Y/2)*32) TABLE
            LDX    B,X 			; X = 1024 + INT(Y/2)*32
			LDB    1,S 			; X COORD
            LSRB 					; INT(X/2)
			ABX 					; X = 1024 + INT(Y/2)*32 + INT(X/2)             
            PULS   A,B            GET VER COORD TO ACCA, HOR COORD TO ACCB
            ANDA   #1             KEEP ONLY LSB OF VER COORD
            RORB                  LSB OF HOR COORD TO CARRY FLAG
            ROLA                  LSB OF HOR TO BIT 0 OF ACCA
            LDB    #$10           MAKE A BIT MASK - TURN ON BIT 4
!           LSRB                  SHIFT IT RIGHT ONCE
            DECA                  SHIFTED IT ENOUGH?
            BPL    <              NO
            STB    GRBLOK         ACCB=8 FOR UPPER LEFT PIXEL, =4 FOR UPPER RIGHT PIXEL =2 FOR LOWER LEFT, =1 FOR LOWER RIGHT
            JMP    ,U             Return
;GRBLOK      RMB    1			 
YTABLE		FDB	   $0400,$0400,$0420,$0420,$0440,$0440,$0460,$0460,$0480,$0480,$04A0,$04A0,$04C0,$04C0,$04E0,$04E0
			FDB    $0500,$0500,$0520,$0520,$0540,$0540,$0560,$0560,$0580,$0580,$05A0,$05A0,$05C0,$05C0,$05E0,$05E0
			
* Do the Set function
* Enter with B = the Colour value from 0 to 8
* X = the screen address
DoSet:
SET          DECB                  CHANGE COLOR NUMBERS FROM 0-8 TO (-1 TO 7)
             BMI    >              BRANCH IF SET (X,Y,0)
             LDA    #$10           $10 OFFSET BETWEEN DIFFERENT COLORS
             MUL                   MULT BY COLOR FOR TOTAL OFFSET
             BRA    LA89D          GO SAVE THE COLOR
!            LDB    ,X             GET CURRENT CHAR FROM SCREEN
             BPL    LA89C          BRANCH IF NOT GRAPHIC
             ANDB   #$70           SAVE ONLY THE COLOR INFO
             FCB    $21            SKP1 - SKIP THE NEXT BYTE
LA89C        CLRB                  RESET ASCII BLOCK TO ZERO COLOR
LA89D        PSHS   B              SAVE COLOR INFO
             LDA    ,X             GET CURRENT CHARACTER FROM SCREEN
             BMI    >              BRANCH IF GRAPHIC
             CLRA                  RESET ASCII CHARACTER TO ALL PIXELS OFF
!            ANDA   #$0F           SAVE ONLY PIXEL ON/OFF INFO
             ORA    GRBLOK         OR WITH WHICH PIXEL TO TURN ON
             ORA    ,S+            OR IN THE COLOR
LA8AC        ORA    #$80           FORCE GRAPHIC
             STA    ,X             DISPLAY IT ON THE SCREEN
             RTS

* Do the Reset function
* X = the screen address
DoReset:
             CLRA                  * ACCA=ZERO GRAPHIC BLOCK - FOR USE IN CASE YOU'RE
*                                 TRYING TO RESET A NON GRAPHIC BLOCK
             LDB    ,X             GET CURRENT CHAR FROM SCREEN
             BPL    LA8AC          BRANCH IF NON-GRAPHIC
             COM    GRBLOK         INVERT PIXEL ON/OFF MASK
             ANDB   GRBLOK         AND IT WITH CURRENT ON/OFF DATA
             STB    ,X             DISPLAY IT
             RTS
* Do the Point function
* X = the screen address
DoPoint      LDB    #$FF           INITIAL VALUE OF ON/OFF FLAG = OFF (FALSE)
             LDA    ,X             GET CURRENT GRAPHIC CHARACTER
             BPL    PNonGraphic    BRANCH IF NON-GRAPHIC (ALWAYS FALSE)
             ANDA   GRBLOK         AND CURR CHAR WITH THE PIXEL IN QUESTION
             BEQ    >              BRANCH IF THE ELEMENT IS OFF
             LDB    ,X             GET CURRENT CHARACTER
             LSRB                  * SHIFT RIGHT
             LSRB                  * SHIFT RIGHT
             LSRB                  * SHIFT RIGHT
             LSRB                  * SHIFT RIGHT - NOW THE HIGH NIBBLE IS IN THE LOW NIBBLE
             ANDB   #7             KEEP ONLY THE COLOR INFO
!            INCB                  ACCB=0 FOR NO COLOR, =1 TO 8 OTHERWISE
PNonGraphic:
             CLRA                  * D has the value of the color
             RTS
