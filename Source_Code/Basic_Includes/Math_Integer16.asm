
Sign_Value1 	FCB 1 ; 	Short1_03 	; Sign of Value1 (0 = positive, 1 = negative)
Sign_Value2  	FCB 1 ; 	Short1_04 	; Sign of Value2 (0 = positive, 1 = negative)

; Multiply unsigned 16bit by unsigned 16bit on the stack - Fixed
; Enter with:
; ,S = Return address
; 2,S = Multiplicand
; 4,S = Multiplier
; Exits with:
; Stack moved forward and ,S = result (low 16 bits) also in X
; D = result (High 16 bit value)
; D has the High 16 bits of the product and X has the Low 16 bits of the product
MUL16:
    PULS    Y       ; Get the return address off the stack in Y
;
; CLEAR PARTIAL PRODUCT IN FOUR STACK BYTES
;
    LDD     #$0000
	PSHS	D		; CLEAR 2 EXTRA BYTES ON TOP OF STACK 
	PSHS	D		; PLUS 2 EXTRA BYTES ON TOP OF STACK 
;
; MULTIPLY LOW BYTE OF MULTIPLIER TIMES LOW BYTE 
; OF MULTIPLICAND
;
	LDA	    7,S		; GET LOW BYTE OF MULTIPLIER
	LDB	    5,S		; GET LOW BYTE OF MULTIPLICAND
	MUL			    ; MULTIPLY BYTES
    STD     2,S		; STORE LOW BYTE OF PRODUCT & HIGH BYTE OF PRODUCT
;
; MULTIPLY LOW BYTE OF MULTIPLIER TIMES HIGH BYTE
; OF MULTIPLICAND
;
	LDA	    7,S		; GET LOW BYTE OF MULTIPLIER
    LDB     4,S		; GET HIGH BYTE OF MULTIPLICAND
	MUL			    ; MULTIPLY BYTES
	ADDB	2,S		; ADD LOW BYTE OF PRODUCT TO PARTIAL PRODUCT
	STB	    2,S		; 
	ADCA	#0		; ADD HIGH BYTE OF PRODUCT PLUS CARRY TO PARTIAL PRODUCT
	STA	    1,S		; STORE HIGH BYTE OF PRODUCT
;	
;	MULTIPLY HIGH BYTE OF MULTIPLIER TIMES LOW BYTE
;	OF MULTIPLICAND
;
	LDD	    5,S		; GET LOW BYTE OF MULTIPLICAND & GET HIGH BYTE OF MULTIPLIER
	MUL			    ; MULTIPLY BYTES
	ADDB	2,S		; ADD LOW BYTE OF PRODUCT TO PARTIAL PRODUCT
	STB	    2,S		; 
	ADCA	1,S		; ADD HIGH BYTE OF PRODUCT PLUS CARRY TO PARTIAL PRODUCT
	STA	    1,S		; 
	BCC	    >		; BRANCH IF NO CARRY ELSE INCREMENT MOST SIGNIFICANT
;   BYTE OF PARTIAL PRODUCT
	INC	    ,S		; 
;
;	MULTIPLY HIGH BYTE OF MULTIPLIER TIMES HIGH BYTE
;	OF MULTIPLICAND
;
!	LDA	    6,S		; GET HIGH BYTE OF MULTIPLIER
	LDB	    4,S		; GET HIGH BYTE OF MULTIPLICAND
	MUL			    ; MULTIPLY BYTES
	ADDB	1,S		; ADD LOW BYTE OF PRODUCT TO PARTIAL PRODUCT
	ADCA	,S		; ADD HIGH BYTE OF PRODUCT PLUS CARRY TO PARTIAL PRODUCT
;
;	HIGH BYTES OF PRODUCT END UP IN D
;
; At this point D has the High 16 bits of the product and X has the Low 16 bits of the product
    LDX     2,S
	LEAS	6,S     ; Fix stack pointer
    STX     ,S      ; Save the Product Least Significant 16 bits on the stack
    JMP     ,Y      ; return

; ======================================================================
; Divide  Signed 16bit by Signed 16bit on the stack
;
; Enter with:
; ,S = Return address
; 2,S = Denominator (Divisor)
; 4,S = Numerator (Dividend)
; Exits with:
; Stack moved forward and ,S = result X has the remainder
DIV_S16:
    PULS    Y               ; Get the return address off the stack in Y
    PULS    D               ; D = Denominator
    STA     Temp1           ; Save the minus flag for D
    STD     Denominator     ; Save the Denominator & set the flags
    LBEQ    DivError        ; we are dividing by zero which can't be done so exit with D=$FFFF
    BPL     >               ; If D>0 then skip ahead we are good with a Positive number
    LDD     #$0000          ; Clear D
    SUBD    Denominator     ; D = 0 - Denominator
    STD     Denominator     ; Save the positive version of the Denominator
!   LDD     ,S
    STD     Numerator       ; Save the positive version of the Numerator
    BPL     >
; Make D a positive
    NEGA                    ; Make D a positive
    NEGB                    ; Make D a positive
    SBCA    #$00            ; Make D a positive
    STD     Numerator       ; Save the positive version of the Numerator
    LDA     #$FF            ; Flag D as a negative number
!   STA     Temp2           ; Save the minus flag for D, if it's a negative then it was negative before
    LDX     #16             ; 16 bits to go through
    LDD     #$0000          ; Clear D
@Div_Again:
    LSL     Numerator+1     ; Shift Bits in Numerator Left
    ROL     Numerator       ; Shift Bits in Numerator Left (pushing MSb bit to carry bit)
    ROLB                    ; Rotate A left and put carry bit in bit zero
    ROLA                    ; Rotate A left and put carry bit in bit zero
    CMPD    Denominator     ; See if A = Denominator
    BLO     >               ; If carry is set then skip ahead (BLO)
    INC     Numerator+1     ; Set bit zero of Numerator
    SUBD    Denominator     ; A = A - Denominator
!   LEAX    -1,X            ; Countdown bit counter
    BNE     @Div_Again       ; If we're not at zero then loop again
; D now has the remainder, Result of the division is in the Numerator
    TFR     D,X             ; X = the Remiander
    BRA     DivDone         ; Done


; Divide  Signed 16bit by Signed 16bit on the stack
;
; Enter with:
; ,S = Return address
; 2,S = Denominator (Divisor)
; 4,S = Numerator (Dividend)
; Exits with:
; Stack moved forward and ,S = result X has the remainder
DIV_S16_Rounding:
    PULS    Y               ; Get the return address off the stack in Y
    PULS    D               ; D = Denominator
    STA     Temp1           ; Save the minus flag for D
    STD     Denominator     ; Save the Denominator & set the flags
    BEQ     DivError        ; we are dividing by zero which can't be done so exit with D=$FFFF
    BPL     >               ; If D>0 then skip ahead we are good with a Positive number
    LDD     #$0000          ; Clear D
    SUBD    Denominator     ; D = 0 - Denominator
    STD     Denominator     ; Save the positive version of the Denominator
!   LDD     ,S
    STD     Numerator       ; Save the positive version of the Numerator
    BPL     >
; Make D a positive
    NEGA                    ; Make D a positive
    NEGB                    ; Make D a positive
    SBCA    #$00            ; Make D a positive
    STD     Numerator       ; Save the positive version of the Numerator
    LDA     #$FF            ; Flag D as a negative number
!   STA     Temp2           ; Save the minus flag for D, if it's a negative then it was negative before
    LDX     #16             ; 16 bits to go through
    LDD     #$0000          ; Clear D
@Div_Again:
    LSL     Numerator+1     ; Shift Bits in Numerator Left
    ROL     Numerator       ; Shift Bits in Numerator Left (pushing MSb bit to carry bit)
    ROLB                    ; Rotate A left and put carry bit in bit zero
    ROLA                    ; Rotate A left and put carry bit in bit zero
    CMPD    Denominator     ; See if A = Denominator
    BLO     >               ; If carry is set then skip ahead (BLO)
    INC     Numerator+1     ; Set bit zero of Numerator
    SUBD    Denominator     ; A = A - Denominator
!   LEAX    -1,X            ; Countdown bit counter
    BNE     @Div_Again      ; If we're not at zero then loop again
; D now has the remainder, Result of the division is in the Numerator
    TFR     D,U             ; U = the Remiander



* Let's round the result
    LDX     Numerator     ; Get the result in X
	ASLB
	ROLA		        ; Remainder =Remainder * 2
	BCS	    @IncX	      ; If the carry bit is set then we're over 16 bit value range so it must be rounded up
    CMPD    Denominator   ; Is Remainder * 2 < the Denominator?
    BLO     >             ; If so then skip ahead
@IncX:
	LEAX	1,X           ; X = X + 1
!   TFR     X,D           ; D now has the result
    STD     -2,S          ; Set the condition codes properly
    STX     Numerator     ; Save the result
    TFR     U,X           ; X has the remainder

;        
DivDone:
    CLRB
    LDA     Temp1           ; Get the minus flag for Denominator
    BPL     >
    INCB
!   LDA     Temp2           ; Get the minus flag for Numerator
    BPL     >
    INCB
!   ANDB    #$01            ; Check if B is an odd number
    BEQ     DivGetResult    ; If B is even then leave the flags alone
    LDD     #$0000          ; Clear D
    SUBD    Numerator       ; D = 0 - Result (make it negative)
    BRA     DivGoodD        ; Don't do a CMPX as this will change the condition codes, we might need to use the value of D in a comparison, after we exit
DivGetResult:
    LDD     Numerator       ; Get the result in D
DivGoodD:
    STD     ,S              ; Save the result on the stack
    TFR     X,D             ; D now has the remainder, fix the stack                ; EXIT
Div16_Return:
    JMP     ,Y              ; return
DivError:
    LDD     #$FFFF          ; we are dividing by zero which can't be done so exit with D=$FFFF
    STD     ,S              ; Save on the stack
    JMP     ,Y              ; return

* Div 16bit by 16bit (with Rounding)
; Enter with:
; ,S = Return address
; 2,S = Denominator (Divisor)
; 4,S = Numerator (Dividend)
; Exits with:
; Stack moved forward and ,S = result X has the remainder
DIV_U16_Rounding:
    PULS    Y               ; Get the return address off the stack in Y
    PULS    D               ; Get Denominator
    STD     Denominator     ; Save the Denominator & set the flags
    BEQ     DivError        ; we are dividing by zero which can't be done so exit with D=$FFFF
    LDD     ,S              ; Get Numerator, move the stack forward
    STD     Numerator       ; Save the positive version of the Numerator
    LDX     #16           ; 16 bits to go through
    LDD     #$0000        ; Clear D
Div_AgainR:
    LSL     Numerator+1   ; Shift Bits in Numerator Left
    ROL     Numerator     ; Shift Bits in Numerator Left (pushing MSb bit to carry bit)
    ROLB                  ; Rotate A left and put carry bit in bit zero
    ROLA                  ; Rotate A left and put carry bit in bit zero
    CMPD    Denominator   ; See if A = Denominator
    BLO     >             ; If carry is set then skip ahead (BLO)
    INC     Numerator+1   ; Set bit zero of Numerator
    SUBD    Denominator   ; A = A - Denominator
!   LEAX    -1,X          ; Countdown bit counter
    BNE     Div_AgainR    ; If we're not at zero then loop again
* Let's round the result
    LDX     Numerator     ; Get the result in X
	ASLB
	ROLA		        ; Remainder =Remainder * 2
	BCS	    @IncX	      ; If the carry bit is set then we're over 16 bit value range so it must be rounded up
    CMPD    Denominator   ; Is Remainder * 2 < the Denominator?
    BLO     >             ; If so then skip ahead
@IncX:
	LEAX	1,X           ; X = X + 1
!   TFR     X,D           ; D now has the result
    STD     -2,S          ; Set the condition codes properly
DivDoneR:
    STX     Numerator     ; Save the result in X
    BRA     DivGetResult  ; Put result on the stack and return


; Unsigned 16 bit by unsigned 16 bit division on the stack - Fixing
;
; Enter with:
; ,S = Return address
; 2,S = Denominator (Divisor)
; 4,S = Numerator (Dividend)
; Exits with:
; Stack moved forward and ,S = result X has the remainder
DIV_U16:
    PULS    Y               ; Get the return address off the stack in Y
    PULS    D               ; Get Denominator
    STD     Denominator     ; Save the Denominator & set the flags
    BEQ     DivError        ; we are dividing by zero which can't be done so exit with D=$FFFF
    LDD     ,S              ; Get Numerator, move the stack forward
    STD     Numerator       ; Save the positive version of the Numerator
    LDX     #16             ; 16 bits to go through
    LDD     #$0000          ; Clear D
@Div_Again:
    LSL     Numerator+1     ; Shift Bits in Numerator Left
    ROL     Numerator       ; Shift Bits in Numerator Left (pushing MSb bit to carry bit)
    ROLB                    ; Rotate A left and put carry bit in bit zero
    ROLA                    ; Rotate A left and put carry bit in bit zero
    CMPD    Denominator     ; See if D = Denominator
    BLO     >               ; If D is lower then skip ahead
    INC     Numerator+1     ; Set bit zero of Numerator
    SUBD    Denominator     ; A = A - Denominator
!   LEAX    -1,X            ; Countdown bit counter
    BNE     @Div_Again      ; If we're not at zero then loop again
; D now has the remainder, Result of the division is in the Numerator
    TFR     D,X             ; X = the Remiander
    BRA     DivGetResult    ; Put result on the stack and return

; ======================================================================
; U8_DIVMOD_TRUNC - Unsigned 8-bit division with remainder
; Input : B = dividend, A = divisor (1..255)
; Output: B = quotient, A = remainder
; Error : If A=0, C=1 and A=remainder=dividend, B=0
; Trashes: X, CC
; ------------------------------------------------------------
U8_DIVMOD_TRUNC:
    TSTA
    BNE     @ok
    ORCC    #$01        ; C=1 (div by zero)
    TFR     B,A         ; remainder = dividend
    CLRB                ; quotient = 0
    RTS                 ; Return
@ok:
    PSHS    A           ; save divisor at ,S
    CLRA                ; A = remainder = 0
    LDX     #8          ; 8 bits
@loop:
    ASLB                ; shift dividend bit into C
    ROLA                ; remainder = (remainder<<1) | C
    CMPA    ,S          ; remainder >= divisor ?
    BLO     @no_sub
    SUBA    ,S          ; remainder -= divisor
    ORB     #$01        ; set quotient bit (LSB)
@no_sub:
    LEAX    -1,X
    BNE     @loop
    LEAS    1,S         ; drop saved divisor
    ANDCC   #$FE        ; C=0 success
    RTS                 ; Return

; ------------------------------------------------------------
; U8_DIVMOD_ROUND - Unsigned 8-bit division with remainder,
;                   quotient rounded-to-nearest (half-up)
; Input : B = dividend, A = divisor (1..255)
; Output: B = rounded quotient
;         A = remainder of the UNROUNDED division
; Error : If A=0, C=1 and A=remainder=dividend, B=0
; Trashes: X, CC
; ------------------------------------------------------------
U8_DIVMOD_ROUND:
    TSTA
    BNE     @ok
    ORCC    #$01        ; C=1 div-by-zero
    TFR     B,A
    CLRB
    RTS                 ; Return
@ok:
    PSHS    A           ; save divisor (outer)
    BSR     U8_DIVMOD_TRUNC
; now: B=trunc quotient, A=remainder, divisor still saved on stack
    PSHS    A           ; save remainder at ,S
    LDA     1,S         ; load divisor from stack (divisor is under remainder)
    ADDA    #1
    LSRA                ; A = (divisor+1)/2  (round-half-up threshold)
    CMPA    ,S          ; compare threshold (A) with remainder (mem)
;        BLS     @round_up   ; if threshold <= remainder => round up
    BHI     @done_round ; No rounding needed
@round_up:
    INCB                ; rounded quotient = trunc quotient + 1
@done_round:
    PULS    A           ; restore remainder into A
    LEAS    1,S         ; drop saved divisor
    ANDCC   #$FE        ; C=0 success
    RTS                 ; Return

; ------------------------------------------------------------
; S8_DIVMOD_TRUNC - signed 8-bit division with remainder
; Input : B = dividend, A = divisor (1..255)
; Output: B = quotient, A = remainder
; Error : If A=0, C=1 and A=remainder=dividend, B=0
; Trashes: X, CC
; ------------------------------------------------------------
S8_DIVMOD_TRUNC:
    TSTA
    BNE     @ok
    ORCC    #$01        ; C=1 (div by zero)
    TFR     B,A         ; remainder = dividend
    CLRB                ; quotient = 0
    RTS                 ; Return
@ok:
    STD     Temp1       ; Save the signs of A & B
    BPL     >
    NEGA
!   TSTB
    BPL     >
    NEGB
!   BSR     U8_DIVMOD_TRUNC ; B=quot (unsigned), A=rem (unsigned), C=0
    BRA     FixSign8

; ------------------------------------------------------------
; U8_DIVMOD_ROUND - signed 8-bit division with remainder,
;                   quotient rounded-to-nearest (half-up)
; Input : B = dividend, A = divisor (1..255)
; Output: B = rounded quotient
;         A = remainder of the UNROUNDED division
; Error : If A=0, C=1 and A=remainder=dividend, B=0
; Trashes: X, CC
; ------------------------------------------------------------
S8_DIVMOD_ROUND:
    TSTA
    BNE     @ok
    ORCC    #$01        ; C=1 (div by zero)
    TFR     B,A         ; remainder = dividend
    CLRB                ; quotient = 0
    RTS                 ; Return
@ok:
    STD     Temp1       ; Save the signs of A & B
    BPL     >
    NEGA
!   TSTB
    BPL     >
    NEGB
!   BSR     U8_DIVMOD_ROUND ; B=quot (unsigned), A=rem (unsigned), C=0
FixSign8:
    PSHS    A
    LDA     Temp1
    EORA    Temp1+1
    PULS    A
    BPL     >
    NEGB                ; Qutoient is negative
; Sign of the remainder is the same as the dividend (numerator) 
!   TST     Temp1+1     ; get the sign of the numerator
    BPL     @MakePositive
; Make it Negative
    TSTA                ; Is the remainder already negative?
    BMI     @Done       ; If so we are done
    NEGA                ; Otherwise make it negative
@Done:
    RTS                 ; Return
@MakePositive:
    TSTA                ; Is the remainder already positive
    BPL     @Done       ; If so we are done
    NEGA                ; Otherwise make it positive 
    RTS                 ; Return

