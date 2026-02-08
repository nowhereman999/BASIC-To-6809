; Add two 8 byte Integer values on the stack
; ,S = Value 1 + Value 2
; Enter with two 8 byte Integer values on the stack
; signed or unsigned doesn't matter
;
; Entry:
;   ,S           = return Address
;   2,S to 9,S   = Value 1 (8 bytes)  [b7 b6 b5 b4 b3 b2 b1 b0]
;   10,S to 17,S = Value 2 (8 bytes)  [b7 b6 b5 b4 b3 b2 b1 b0]
; Exit:
;   ,S after return will have the resulting 8 byte Integer value
;   (result overwrites Value2, Value1 is dropped)
;
; Clobbers: A,B,Y,CC
;
Add_8ByteTo8Byte:
        PULS    Y           ; pull return address, now:
                            ; ,S..7,S   = Value1
                            ; 8,S..15,S = Value2
        ; ---- Add low 16 bits: (b1:b0) ----
        LDD     6,S         ; Value1 b1:b0
        ADDD    14,S        ; + Value2 b1:b0
        STD     14,S        ; store into Value2 b1:b0
        ; ---- Next 16 bits: (b3:b2) with carry ----
        LDD     4,S         ; Value1 b3:b2
        ADCB    13,S        ; + Value2 b2 + carry
        ADCA    12,S        ; + Value2 b3 + carry
        STD     12,S        ; store into Value2 b3:b2
        ; ---- Next 16 bits: (b5:b4) with carry ----
        LDD     2,S         ; Value1 b5:b4
        ADCB    11,S        ; + Value2 b4 + carry
        ADCA    10,S        ; + Value2 b5 + carry
        STD     10,S        ; store into Value2 b5:b4
        ; ---- High 16 bits: (b7:b6) with carry ----
        LDD     ,S          ; Value1 b7:b6
        ADCB    9,S         ; + Value2 b6 + carry
        ADCA    8,S         ; + Value2 b7 + carry
        STD     8,S         ; store into Value2 b7:b6
        ; Drop Value1, leave result on top of stack
        LEAS    8,S         ; now ,S..7,S = result (former Value2)
        JMP     ,Y          ; return

; Subtract two 8 byte Integer values on the stack
; Value 1 @ 8,S - Value 2 @ ,S
; Enter with return add and two 8 byte Integer values on the stack
; signed or unsigned doesn't matter
;
; Entry:
;   ,S            = return Address
;   2,S to 9,S    = Value 2 (8 bytes)  [b7 b6 b5 b4 b3 b2 b1 b0]
;   10,S to 17,S  = Value 1 (8 bytes)  [b7 b6 b5 b4 b3 b2 b1 b0]
; Exit:
;   ,S after return will have the resulting 8 byte Integer value
;   (result overwrites Value2, Value1 is dropped)
;
; Clobbers: A,B,Y,CC
;
Subtract_8ByteFrom8Byte:
        PULS    Y           ; pull return address, now:
                            ; ,S..7,S   = Value2
                            ; 8,S..15,S = Value1
        ; ---- Sub low 16 bits: (b1:b0) ----
        LDD     14,S        ; Value1 b1:b0
        SUBD    6,S         ; - Value2 b1:b0
        STD     14,S        ; store into Value2 b1:b0
        ; ---- Next 16 bits: (b3:b2) with borrow ----
        LDD     12,S        ; Value1 b3:b2
        SBCB    5,S         ; - Value2 b2 - borrow
        SBCA    4,S         ; - Value2 b3 - borrow
        STD     12,S        ; store into Value2 b3:b2
        ; ---- Next 16 bits: (b5:b4) with borrow ----
        LDD     10,S        ; Value1 b5:b4
        SBCB    3,S         ; - Value2 b4 - borrow
        SBCA    2,S         ; - Value2 b5 - borrow
        STD     10,S        ; store into Value2 b5:b4
        ; ---- High 16 bits: (b7:b6) with borrow ----
        LDD     8,S         ; Value1 b7:b6
        SBCB    1,S         ; - Value2 b6 - borrow
        SBCA    ,S          ; - Value2 b7 - borrow
        STD     8,S         ; store into Value2 b7:b6
        ; Drop Value1, leave result on top of stack
        LEAS    8,S         ; now ,S..7,S = result (former Value2)
        JMP     ,Y          ; return

; 64 bit Integer division Signed and UnSigned
; How to use the 64-Bit divide code below:
;
; Code does division of Value1/Value2 where:
; Value1 is stored at 8,S (Dividend)
; Value2 is stored at ,S  (Divisor)
; After Division the stack is moved forward 8 bytes and the result (Quotient) is stored at ,S
;
; These are the routines to call depending on your needs:
; Signed Divisor, Unsigned Dividend:
;	JSR	Div_DivisorSigned_Rounding_64
;	JSR	Div_DivisorSigned_NoRounding_64
;
; Signed Dividend, Unsigned Divisor:
;	JSR	Div_DividendSigned_Rounding_64
;	JSR	Div_DividendSigned_NoRounding_64
;
; If both values are UnSigned
;	JSR	Div_UnSigned_Rounding_64
;	JSR	Div_UnSigned_NoRounding_64
;
; If both values are Signed
;	JSR	Div_Signed_Both_Rounding_64
;	JSR	Div_Signed_Both_NoRounding_64
;
; *******************************************************************************************************
; Signed Divisor, Unsigned Dividend:
; The quotient's sign must match the divisor's sign and the remainder is positive
Div_DivisorSigned_Rounding_64:
	LDA	#$FF			; If = 0 then no rounding will be done
	BRA	DoDivisorSigned_64
Div_DivisorSigned_NoRounding_64:
	CLRA				; If = 0 then no rounding will be done
DoDivisorSigned_64:
	STA	RoundFlag		; If = 0 then no rounding will be done
	PULS	D			; Get return address off the stack
	STD	Div_Return_64+1		; Self mod return address
	JSR	Div_Setup_64		; Setup Divisor(Value2) & Dividend(Value1) off the stack
; Figure out if Divisor is signed, if not simply do regular unsigned version
	LDA	8,S			; Get the Divisor's sign byte (MSB)
	BPL	ReadyDoUnsignedDiv_64	; Go do a regular unsigned divide (everything will be positive)

; If we get here the Divisor is negative, we need to:
; 1) Make the Divisor positive (negate it)
; 2) Do unsigned division
; 3) Make the quotient negative
; 4) Leave the remainder as positive
    	LDX 	#Temp_Divisor		; X points at the divisor
    	JSR 	Negate_64       	; Negate 64 bit value at X
	JSR	UnSigned_Div_64		; Do Unsigned 64 bit division
    	LDX 	#Quotient		; X points at the Quotient
    	JSR 	Negate_64       	; Negate 64 bit value at X (make it negative again)
	BRA	DivFixStack_64		; Fix the Stack and return

; Signed Dividend, Unsigned Divisor:
; The quotient's sign matches the dividend's sign and the remainder also matches the dividend's sign 
Div_DividendSigned_Rounding_64:
	LDA	#$FF			; If = 0 then no rounding will be done
	BRA	DoDividendSigned_64
Div_DividendSigned_NoRounding_64:
	CLRA				; If = 0 then no rounding will be done
DoDividendSigned_64:
	STA	RoundFlag		; If = 0 then no rounding will be done
	PULS	D			; Get return address off the stack
	STD	Div_Return_64+1		; Self mod return address
	BSR	Div_Setup_64		; Setup Divisor(Value2) & Dividend(Value1) off the stack
; Figure out if Dividend is signed, if not simply do regular unsigned version
	LDA	,S			; Get the Dividend's sign byte (MSB)
	BPL	ReadyDoUnsignedDiv_64	; Go do a regular unsigned divide (everything will be positive)

; If we get here the Dividend is negative, we need to:
; 1) Make the Dividend positive (negate it)
; 2) Do unsigned division
; 3) Make the quotient negative
; 4) Make the remainder a negative
    	LDX 	#Temp_Dividend		; X points at the Dividend
    	JSR 	Negate_64       	; Negate 64 bit value at X
	JSR	UnSigned_Div_64		; Do Unsigned 64 bit division
    	LDX 	#Quotient		; X points at the Quotient
    	JSR 	Negate_64       	; Negate 64 bit value at X (make it negative again)
    	LDX 	#Remainder		; X points at the Remainder
    	JSR 	Negate_64       	; Negate 64 bit value at X (make it negative, to match the Dividend)
	BRA	DivFixStack_64		; Fix the Stack and return

; If both values are UnSigned & you want the result rounded
Div_UnSigned_Rounding_64:
	LDA	#$FF			; If = 0 then no rounding will be done
	BRA	DoUnSignedDiv_64
; If both values are UnSigned & you don't want the result rounded
Div_UnSigned_NoRounding_64:
	CLRA				; If = 0 then no rounding will be done
DoUnSignedDiv_64:
	STA	RoundFlag		; If = 0 then no rounding will be done
	PULS	D			; Get return address off the stack
	STD	Div_Return_64+1		; Self mod return address
	BSR	Div_Setup_64		; Setup Divisor(Value2) & Dividend(Value1) off the stack
ReadyDoUnsignedDiv_64:
	JSR	UnSigned_Div_64		; Do Unsigned 64 bit division
	BRA	DivFixStack_64		; Fix the Stack and return

; If both values are Signed & you want the result rounded
Div_Signed_Both_Rounding_64:
	LDA	#$FF			; If = 0 then no rounding will be done
	BRA	DoSignedDiv_64
; If both values are Signed & you don't want the result rounded
Div_Signed_Both_NoRounding_64:
	CLRA				; If = 0 then no rounding will be done
DoSignedDiv_64:
	STA	RoundFlag		; If = 0 then no rounding will be done
	PULS	D			; Get return address off the stack
	STD	Div_Return_64+1		; Self mod return address
	BSR	Div_Setup_64		; Setup Divisor(Value2) & Dividend(Value1) off the stack
	JSR	Signed_Div_Both_64
	BRA	DivFixStack_64

; 1) Fix the stack
; 2) Copy Quotient on the stack
; 3) Return
DivFixStack_64:
	LEAS	8,S			; Move stack forward 8 bytes
	LDD	Quotient
	STD	,S
	LDD	Quotient+2
	STD	2,S
	LDD	Quotient+4
	STD	4,S
	LDD	Quotient+6
	STD	6,S
Div_Return_64:
	JMP	>$FFFF			; Self modified return address

Div_Setup_64:
	LDD	10,S		; Get Value1 (Dividend)
	STD	Temp_Dividend	; Save as Temp_Dividend
	LDD	12,S		; Get Value1 (Dividend)
	STD	Temp_Dividend+2	; Save as Temp_Dividend
	LDD	14,S		; Get Value1 (Dividend)
	STD	Temp_Dividend+4	; Save as Temp_Dividend
	LDD	16,S		; Get Value1 (Dividend)
	STD	Temp_Dividend+6	; Save as Temp_Dividend

	LDD	2,S		; Get Value2 (Divisor)
	STD	Temp_Divisor	; Save as Temp_Divisor
	LDD	4,S		; Get Value2 (Divisor)
	STD	Temp_Divisor+2	; Save as Temp_Divisor
	LDD	6,S		; Get Value2 (Divisor)
	STD	Temp_Divisor+4	; Save as Temp_Divisor
	LDD	8,S		; Get Value2 (Divisor)
	STD	Temp_Divisor+6	; Save as Temp_Divisor
	RTS

UnSigned_Div_64:
;—————— Entry Point ———————————————————————————————
        ;-- assume DIVD_H:L and DIVS_H:L have been pre-loaded --
        ;-- on return QUOT_H:L = dividend ÷ divisor,
        ;     REMR_H:L = dividend mod divisor --

        ; Check for division by zero 
        LDD     Temp_Divisor+6	; Divisor LSW
        BNE     Div_NotZero_64 	; If non-zero, proceed
        LDD     Temp_Divisor+4  ; Divisor
        BNE     Div_NotZero_64   ; If non-zero, proceed
        LDD     Temp_Divisor+2  ; Divisor
        BNE     Div_NotZero_64   ; If non-zero, proceed
        LDD     Temp_Divisor	; Divisor MSW
        BNE     Div_NotZero_64 ; If non-zero, proceed
        ; Divisor is zero, set quotient to max (0xFFFFFFFFFFFFFFFF) 
        LDX     #Quotient 
        LDD     #$FFFF 
        STD     ,X++ 
        STD     ,X++ 
        STD     ,X++ 
        STD     ,X++ 	
	RTS

Div_NotZero_64:
        ; 1) Copy dividend to DividendTemp storage
        LDX     #Temp_Dividend
	    LDU	    #DividendTemp
	    LDB	    #8
!	    LDA	    ,X+
	    STA	    ,U+
	    DECB
	    BNE	    <
	    CLRA

        ; 2) Initialize quotient to zero
        LDX     #Quotient
        STD     ,X
        STD     2,X
        STD     4,X
        STD     6,X

        ; 3) Initialize remainder to zero
        LDX     #Remainder
        STD     ,X
        STD     2,X
        STD     4,X
        STD     6,X   

        ; 4) Loop over 64 bits
        LDY     #64                 ; bit-count
Div64_Loop_64:
        ; 4a) Shift dividend = DIVTMP left by 1
	    LDX     #Temp_Dividend      ; 
        ASL     7,X      	; clear carry & shift left, low byte, to high byte
        ROL     6,X
        ROL     5,X
        ROL     4,X
        ROL     3,X
        ROL     2,X
        ROL     1,X
        ROL     ,X

        ; 4b) Shift remainder left by 1, bring in carry
        LDX     #Remainder      ; 
        ROL     7,X      	; Shift remainder left by 1, bring in carry
        ROL     6,X
        ROL     5,X
        ROL     4,X
        ROL     3,X
        ROL     2,X
        ROL     1,X
        ROL     ,X

        ; 4c) Shift quotient left by 1
        LDX     #Quotient 	; 
        ASL     7,X      	; clear carry & shift left, low byte, to high byte
        ROL     6,X
        ROL     5,X
        ROL     4,X
        ROL     3,X
        ROL     2,X
        ROL     1,X
        ROL     ,X

        ; 4d) Compare remainder vs divisor
	    LDX	    #Remainder
	    LDU	    #Temp_Divisor
	    LDD	    ,X
	    CMPD	,U
        BHI     Do_Subtract_64        ; remainder.H > divisor.H
        BNE     No_Subtract_64        ; remainder.H < divisor.H
	    LDD	    2,X
	    CMPD	2,U
        BHI     Do_Subtract_64        ; remainder.H > divisor.H
        BNE     No_Subtract_64        ; remainder.H < divisor.H
	    LDD	    4,X
	    CMPD	4,U
        BHI     Do_Subtract_64        ; remainder.H > divisor.H
        BNE     No_Subtract_64        ; remainder.H < divisor.H
	    LDD	    6,X
	    CMPD	6,U
        BLO     No_Subtract_64        ; remainder.L < divisor.L

Do_Subtract_64:
        ; Subtract divisor from remainder
	    LDD	    6,X
	    SUBD	6,U
	    STD	    6,X

	    LDB	    5,X
	    SBCB	5,U
	    LDA	    4,X
	    SBCA	4,U
	    STD	    4,X
 
 	    LDB	    3,X
	    SBCB	3,U
	    LDA	    2,X
	    SBCA	2,U
	    STD	    2,X

    	LDB	    1,X
	    SBCB	1,U
	    LDA	    ,X
	    SBCA	,U
	    STD	    ,X

        ; Set quotient LSB to 1
;	LDA	Quotient+7
;       ORA     #1
;	STA	Quotient+7
    	INC	    Quotient+7

No_Subtract_64:
        ; 4e) Loop
        LEAY    -1,Y
        LBNE    Div64_Loop_64

; Done Unsigned 64 bit division
    	LDA	    RoundFlag	; If = 0 then no rounding will be done
	    BEQ	    Div_Done_64	; Exit, no Rounding wanted

; Handle rounding:

        ; Copy Remainder to DividendTemp
        LDX     #Remainder
        LDU     #DividendTemp
        LDB     #8
Copy_Loop@:
        LDA     ,X+
        STA     ,U+
        DECB
        BNE     Copy_Loop@

        ; Shift DividendTemp left by 1 (multiply by 2)
        LDX     #DividendTemp
        ASL     7,X                 ; shift LSB
        ROL     6,X
        ROL     5,X
        ROL     4,X
        ROL     3,X
        ROL     2,X
        ROL     1,X
        ROL     ,X                  ; shift MSB, carry out

        BCS     Round_Up_64            ; if carry set, remainder * 2 >= 2^64 > divisor

        ; Compare DividendTemp (shifted remainder) with Temp_Divisor
        LDX     #DividendTemp
        LDU     #Temp_Divisor
        LDD     ,X
        CMPD    ,U
        BHI     Round_Up_64            ; if greater, round up
        BLO     Div_Done_64                ; if less, no rounding
        LDD     2,X
        CMPD    2,U
        BHI     Round_Up_64
        BLO     Div_Done_64
        LDD     4,X
        CMPD    4,U
        BHI     Round_Up_64
        BLO     Div_Done_64
        LDD     6,X
        CMPD    6,U
        BLO     Div_Done_64 		; if >=, round up otherwise No rounding

Round_Up_64:
        ; Increment quotient by 1
        LDX     #Quotient
        INC     7,X
        BNE     Div_Done_64
        INC     6,X
        BNE     Div_Done_64
        INC     5,X
        BNE     Div_Done_64
        INC     4,X
        BNE     Div_Done_64
        INC     3,X
        BNE     Div_Done_64
        INC     2,X
        BNE     Div_Done_64
        INC     1,X
        BNE     Div_Done_64
        INC     ,X
Div_Done_64:
        RTS

; Main routine for signed 64-bit division
Signed_Div_Both_64:
    ; Copy DIVIDEND to Temp_Dividend
;    LDX #DIVIDEND	
    LEAX    10,S	; X points at the Dividend
    LDU #Temp_Dividend
    LDB #8
COPY_DIVIDEND_64:
    LDA ,X+
    STA ,U+
    DECB
    BNE COPY_DIVIDEND_64

    ; Copy DIVISOR to Temp_Divisor
;    LDX #DIVISOR
    LEAX    2,S	; X points at the Divisor
    LDU #Temp_Divisor
    LDB #8
COPY_DIVISOR_64:
    LDA ,X+
    STA ,U+
    DECB
    BNE COPY_DIVISOR_64

    ; Check sign of DIVIDEND
    LDA Temp_Dividend        ; Load MSB
    TSTA                ; Test sign bit
    BPL A_POSITIVE_64      ; Branch if positive
    LDA #1
    STA Sign_Dividend          ; Set Sign_Dividend = 1 (negative)
    LDX #Temp_Dividend
    JSR Negate_64       ; Negate Temp_Dividend to get |DIVIDEND|
    BRA CHECK_DIVISOR_64
A_POSITIVE_64:
    CLR Sign_Dividend          ; Set Sign_Dividend = 0 (positive)

CHECK_DIVISOR_64:
    ; Check sign of DIVISOR
    LDA Temp_Divisor         ; Load MSB
    TSTA
    BPL B_POSITIVE_64      ; Branch if positive
    LDA #1
    STA Sign_Divisor          ; Set Sign_Divisor = 1 (negative)
    LDX #Temp_Divisor
    JSR Negate_64       ; Negate Temp_Divisor to get |DIVISOR|
    BRA DO_DIVISION_64
B_POSITIVE_64:
    CLR Sign_Divisor          ; Set Sign_Divisor = 0 (positive)

DO_DIVISION_64:
    ; Call the unsigned 64-bit division routine
    ; Inputs: Temp_Dividend, Temp_Divisor
    ; Outputs: Quotient, REMAINDER
    JSR UnSigned_Div_64 	; Do unsigned 64 bit division

    ; Adjust quotient sign: negate if Sign_Dividend XOR Sign_Divisor = 1
    LDA Sign_Dividend
    EORA Sign_Divisor         ; XOR signs
    BEQ ADJUST_REMAINDER_64 ; If signs are same, quotient stays positive
    LDX #Quotient
    JSR Negate_64       ; Negate Quotient

ADJUST_REMAINDER_64:
    ; Adjust remainder sign: negate if Sign_Dividend = 1
    LDA Sign_Dividend
    BEQ Signed_DONE_64            ; If dividend positive, remainder stays positive
    LDX #Remainder
    JSR Negate_64       ; Negate REMAINDER

Signed_DONE_64:
    RTS

; Subroutine to negate a 128-bit number at address in X
Negate_128:
    LDB     #15
    BRA     @DoNeg
; Subroutine to negate a 64-bit number at address in X
Negate_64:
    LDB     #7
@DoNeg:
    CLRA                    ; Clear the initial carry
!   LDA     #0
    SBCA    B,X
    STA     B,X
    DECB
    BPL     <
    RTS

; 64-bit Multiplication on 6809
; Inputs: ,S (8 bytes), 8,S (8 bytes)
; Output: S=S+8, 8 byte (64 bit) value is at ,S also 128 bit value is @ RESULT
;
; Case 1: Two Signed Integers
;	JSR	Mul_Signed_Both_64
; Case 2: Signed × UnSigned
;	JSR	Mul_MultiplicandSigned_64
; Case 3: UnSigned × Signed
;	JSR	Mul_MultiplierSigned_64
; Case 4: Two Unsigned Integers
;	JSR	Mul_UnSigned_Both_64
;
; Case 1: Two Signed Integers
Mul_Signed_Both_64:
	PULS	D			; Get return address off the stack
	STD	Mul_Return_64+1		; Self mod return address
; Check sign of multiplicand - Value1
    LDA 	8,S        	; Load Value 1 MSB
	TSTA                	; Test sign bit
    BPL 	A_POSITIVE_64@  ; Branch if positive
	LDA 	#1
    STA 	Sign_Value1     ; Set Sign_Value1 = 1 (negative)
	LEAX	8,S		; Point at Value1
    JSR 	Negate_64       ; Negate NUM1 make it positive
	BRA 	>
A_POSITIVE_64@:
	CLR 	Sign_Value1     ; Set Sign_Value1 = 0 (positive)
; Check sign of multiplier - Value2
!   LDA 	,S         	    ; Load Value 2 MSB
	TSTA
    BPL 	B_POSITIVE_64@  ; Branch if positive
	LDA 	#1
    STA 	Sign_Value2     ; Set Sign_Value2 = 1 (negative)
    LEAX	,S		        ; Point at Value2
	JSR 	Negate_64       ; Negate NUM2 make it positive
    BRA 	>		        ; Skip forward
B_POSITIVE_64@:
	CLR 	Sign_Value2    	; Set Sign_Value2 = 0 (positive)
!	JSR	    Mul_UnSigned_64	; Do the 64 bit unsigned multiplication
	LDA	    Sign_Value1	    ; A = Sign of Value 1
	EORA	Sign_Value2	    ; XOR A with the sign of Value 2
	BEQ	    >		        ; If A = 0 then result will be positive, leave it as it is
	LDX	    #RESULT		    ; Make Result a negative
	JSR 	Negate_128      ; Negate the big number
!	BRA	    Mul_FixStack_64 ; Return

; Case 2: Signed × UnSigned
Mul_MultiplicandSigned_64:
	PULS	D			    ; Get return address off the stack
	STD	Mul_Return_64+1		; Self mod return address
; Check sign of multiplicand - Value1
    LDA 	8,S        	    ; Load Value 1 MSB
	TSTA                	; Test sign bit
    BPL 	A_POSITIVE_64@  ; Branch if positive
    LDA 	#1
	STA 	Sign_Value1     ; Set Sign_Value1 = 1 (negative)
    LEAX	8,S		        ; Point at Value1
    JSR 	Negate_64       ; Negate NUM1 make it positive
    BRA 	>
A_POSITIVE_64@:
	CLR 	Sign_Value1     ; Set Sign_Value1 = 0 (positive)
!	JSR	    Mul_UnSigned_64	; Do the 64 bit unsigned multiplication
	TST	    Sign_Value1	    ; Check sign of Value1
	BEQ	    >		        ; If Sign = 0 then result will be positive, leave it as it is
	LDX	    #RESULT		    ; Make Result a negative
	JSR 	Negate_128      ; Negate the big number
!	BRA	    Mul_FixStack_64 ; Return

; Case 3: UnSigned × Signed
Mul_MultiplierSigned_64:
	PULS	D			    ; Get return address off the stack
	STD	Mul_Return_64+1		; Self mod return address
; Check sign of multiplier - Value2
	LDA 	,S        	    ; Load Value 2 MSB
    TSTA                	; Test sign bit
	BPL 	A_POSITIVE_64@  ; Branch if positive
    LDA 	#1
	STA 	Sign_Value2     ; Set Sign_Value2 = 1 (negative)
    LEAX	,S		        ; Point at Value2
	JSR 	Negate_64       ; Negate NUM1 make it positive
    BRA 	>
A_POSITIVE_64@:
	CLR 	Sign_Value2     ; Set Sign_Value1 = 0 (positive)
!	JSR	    Mul_UnSigned_64	; Do the 64 bit unsigned multiplication
	TST	    Sign_Value2	    ; Check sign of Value2
	BEQ	    >		        ; If Sign = 0 then result will be positive, leave it as it is
	LDX	    #RESULT		    ; Make Result a negative
	JSR 	Negate_128      ; Negate the big number
!	BRA	    Mul_FixStack_64 ; Return

; Case 4: Two Unsigned Integers
Mul_UnSigned_Both_64:
	PULS	D			    ; Get return address off the stack
	STD	    Mul_Return_64+1	; Self mod return address
	BSR	    Mul_UnSigned_64 ; Do the 64 bit unsigned integer multiplication

Mul_FixStack_64:
; 1) Fix the stack
; 2) Copy Result on the stack
; 3) Return
	LEAS	8,S			    ; Move stack forward 8 bytes
	LDD	    RESULT+8
	STD	    ,S
	LDD	    RESULT+10
	STD     2,S
	LDD	    RESULT+12
	STD	    4,S
	LDD	    RESULT+14
	STD	    6,S
Mul_Return_64:
	JMP	    >$FFFF
	
; Main multiplication routine
; Multiplies two 64-bit unsigned numbers (8 bytes each) to produce a 128-bit result
; NUM1 = 10,S (8 bytes, big-endian)
; NUM2 = 2,S (8 bytes, big-endian)
; RESULT = 128-bit result (16 bytes, big-endian)
; Trashes: A,B,X,U,Y,CC (no promises kept), uses stack for a few pushes
; Cost : 64 MULs, O(64) carry ripples worst-case
Mul_UnSigned_64:
    ; Zero the 128-bit RESULT
    LDU     #RESULT+16
    LDD     #$0000
    LDX     #$0000
    LEAY    ,X
    PSHU    D,X,Y
    PSHU    D,X,Y
    PSHU    D,X
	LEAU	10,S	; U = Point at Value 1
	LEAY	2,S	    ; Y = Point at Value 2
; Outer loop: i from 7 to 0
    LDB     #7
    STB 	I_INDEX	; Start from index 7
@I_LOOP:
    ; Load Ai = NUM1[i]
    LDA     I_INDEX
    LDA     A,U             ; A = Ai
    STA     @J_LOOP+1       ; save Ai (self mod below)
;
    LDB     #7
    STB 	J_INDEX	        ; Start from index 7
@J_LOOP:
    LDA     #$FF            ; holds Ai between loads (self mod above)
    ; Load Bj = NUM2[j]
    LDB     J_INDEX
    LDB     B,Y             ; B = Bj
;
    ; D = Ai * Bj  (A=high, B=low)
    MUL                     ; D = A*B
    PSHS    B
;
; X = &RESULT[k] where k = i + j
    LDX     #RESULT
    LDB     I_INDEX
    ADDB    J_INDEX            ; B = i + j
    ABX                      ; X = RESULT + (i+j)
    PULS    B
;
    ADDD    ,X                 ; B += RESULT[k]
    STD     ,X
    BCC     @no_carry_low      ; if no carry from low-byte add, skip ripple
;
@carry_low:
    INC     ,-X
    BNE     @done_carry_low
    CMPX    #RESULT
    BHI     @carry_low
@done_carry_low:
@no_carry_low:
;
    ; j--
    DEC   J_INDEX
    BPL   @J_LOOP
;
    ; i--
    DEC   I_INDEX
    BPL   @I_LOOP
;
    RTS


; Subroutine: Find position of highest set bit in 64-bit number at X
; Returns: A = position (0-63, or 255 if zero)
FIND_MSB_64_For_Single:
    CLRB
!   LDA     B,X
    BNE     @FOUND_MSB
    INCB
    CMPB    #8
    BNE     <
@FOUND_MSB:
    SUBB    #7
    NEGB
    PSHS    B               ; Save byte index
    LDB     #7               ; Bit position within byte
@FIND_BIT_LOOP:
    TSTA
    BMI     @MSB_FOUND
    ASLA
    DECB
    BPL     @FIND_BIT_LOOP
@MSB_FOUND:
    LDA     ,S           ; Get byte index
    ASLA                 ; Multiply by 8
    ASLA
    ASLA
    PSHS    B
    ADDA    ,S++         ; Add bit position, Fix the stack
    RTS

; Print a 64 bit signed number @ 2,S
PRINT_64Bit:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
    LDD     ,S              ; Get MSW
    BNE     >
    LDD     2,S
    BNE     >
    LDD     4,S
    BNE     >
    LDD     6,S
    BEQ     @PrintZero      ; Go print 0 and exit
!   LDA     ,S
    BPL     PRINT_Un64Bit1  ; Print unsigned 8 bit number
    LDA	    #'-'
    JSR     PrintA_On_Screen
    LEAX    ,S              ; X = 2,S
    JSR 	Negate_64       ; Negate 64 bit value at X
; At this point 2,S is a positive number
    BRA     PRINT_Un64Bit2  ; Print the positive number
; Print an 64 bit number unsigned number @ 2,S
PRINT_Un64Bit:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
    LDD     ,S
    BNE     >
    LDD     2,S
    BNE     >
    LDD     4,S
    BNE     >
    LDD     6,S
    BNE     >
    BEQ     @PrintZero      ; Go print 0 and exit
PRINT_Un64Bit1:
!   LDA     #' '
    JSR     PrintA_On_Screen
PRINT_Un64Bit2:
    PULS    D,X,Y,U
    STD     DividendTemp
    STX     DividendTemp+2
    STY     DividendTemp+4
    STU     DividendTemp+6
    JSR     PrintDecAt_DividendTemp ; Print the 64 bit number stored at DividendTemp, and return
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
@PrintZero:
    LEAS    8,S             ; Fix the stack
    JSR     PrintZero       ; Go print 0 and exit
    BRA     @Return         ; Exit

; ============================================================
; Signed 64-bit to decimal string on the stack
; Uses reciprocal multiply: q = floor(n/10) = (high64(n * M) >> 3)
; where M = 0xCCCCCCCCCCCCCCCD
; ============================================================

                ; --------- RAM temps ----------
@N64             rmb     8       ; magnitude (unsigned), big-endian
@Q64             rmb     8       ; quotient
@Q10             rmb     8       ; q*10
@Q8              rmb     8       ; q*8
@CNT             rmb     1       ; digit count (1..20)
@SIGNCH          rmb     1       ; ' ' or '-'
@BUF64           rmb     20      ; digits LSD-first (ASCII)
;
; ------------------------------------------------------------
; U64_TO_DECSTR
; Input : Unsigned 64-bit at ,S..7,S (big-endian)
; Output: replaces it with: ,S=len, 1,S=' ' or '-', 2,S..digits
; Calls : Mul_UnSigned_64 (NUM1=10,S, NUM2=2,S, RESULT=16 bytes)
; ------------------------------------------------------------
U64_TO_DECSTR:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
; Copy input from stack to @N64, then remove it from stack
    PULS    D,X,Y,U
    STU     @N64+6
    LDU     #@N64+6
    PSHU    D,X,Y
    BRA     @S64_Pos
;
; ------------------------------------------------------------
; S64_TO_DECSTR
; Input : signed 64-bit at ,S..7,S (big-endian)
; Output: replaces it with: ,S=len, 1,S=' ' or '-', 2,S..digits
; Calls : Negate_64 (negates 64-bit @ ,X)
;         Mul_UnSigned_64 (NUM1=10,S, NUM2=2,S, RESULT=16 bytes)
; ------------------------------------------------------------
S64_TO_DECSTR:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
; Copy input from stack to @N64, then remove it from stack
    PULS    D,X,Y,U
    STU     @N64+6
    LDU     #@N64+6
    PSHU    D,X,Y
                ; Sign check
                LDA     @N64
                BPL     @S64_Pos
                LDA     #'-'
                STA     @SIGNCH
                LDX     #@N64
                JSR     Negate_64
                BRA     @S64_Conv
@S64_Pos:
                LDA     #' '
                STA     @SIGNCH
@S64_Conv:
                CLR     @CNT
@S64_Loop:
                ; ------------------------------------------------
                ; q = (high64(@N64 * 0xCCCCCCCCCCCCCCCD) >> 3)
                ; Mul_UnSigned_64 expects:
                ;   NUM1 = 10,S (8 bytes)
                ;   NUM2 =  2,S (8 bytes)
                ; So push NUM1 first, then NUM2.
                ; ------------------------------------------------
;
                ; Push NUM1 = @N64 (8 bytes), low words first
                LDD     @N64+6
                PSHS    D
                LDD     @N64+4
                PSHS    D
                LDD     @N64+2
                PSHS    D
                LDD     @N64
                PSHS    D
                ; Push NUM2 = 0xCCCCCCCCCCCCCCCD (8 bytes), low words first
                LDD     #$CCCD
                PSHS    D
                LDD     #$CCCC
                PSHS    D
                LDD     #$CCCC
                PSHS    D
                LDD     #$CCCC
                PSHS    D
                JSR     Mul_UnSigned_64
                LEAS    16,S            ; discard the two 64-bit operands we pushed
                ; Copy high64(product) into @Q64: RESULT[0..7]
                LDD     RESULT
                STD     @Q64
                LDD     RESULT+2
                STD     @Q64+2
                LDD     RESULT+4
                STD     @Q64+4
                LDD     RESULT+6
                STD     @Q64+6
                ; @Q64 >>= 3 (big-endian right shifts)
                LSR     @Q64
                ROR     @Q64+1
                ROR     @Q64+2
                ROR     @Q64+3
                ROR     @Q64+4
                ROR     @Q64+5
                ROR     @Q64+6
                ROR     @Q64+7
                LSR     @Q64
                ROR     @Q64+1
                ROR     @Q64+2
                ROR     @Q64+3
                ROR     @Q64+4
                ROR     @Q64+5
                ROR     @Q64+6
                ROR     @Q64+7
                LSR     @Q64
                ROR     @Q64+1
                ROR     @Q64+2
                ROR     @Q64+3
                ROR     @Q64+4
                ROR     @Q64+5
                ROR     @Q64+6
                ROR     @Q64+7
                ; ------------------------------------------------
                ; @Q10 = q*10 = (q<<1) + (q<<3)
                ; ------------------------------------------------
                ; @Q10 = @Q64
                LDD     @Q64
                STD     @Q10
                LDD     @Q64+2
                STD     @Q10+2
                LDD     @Q64+4
                STD     @Q10+4
                LDD     @Q64+6
                STD     @Q10+6
                ; @Q10 <<= 1
                ASL     @Q10+7
                ROL     @Q10+6
                ROL     @Q10+5
                ROL     @Q10+4
                ROL     @Q10+3
                ROL     @Q10+2
                ROL     @Q10+1
                ROL     @Q10
                ; @Q8 = @Q64
                LDD     @Q64
                STD     @Q8
                LDD     @Q64+2
                STD     @Q8+2
                LDD     @Q64+4
                STD     @Q8+4
                LDD     @Q64+6
                STD     @Q8+6
                ; @Q8 <<= 3
                ASL     @Q8+7
                ROL     @Q8+6
                ROL     @Q8+5
                ROL     @Q8+4
                ROL     @Q8+3
                ROL     @Q8+2
                ROL     @Q8+1
                ROL     @Q8
;
                ASL     @Q8+7
                ROL     @Q8+6
                ROL     @Q8+5
                ROL     @Q8+4
                ROL     @Q8+3
                ROL     @Q8+2
                ROL     @Q8+1
                ROL     @Q8
;
                ASL     @Q8+7
                ROL     @Q8+6
                ROL     @Q8+5
                ROL     @Q8+4
                ROL     @Q8+3
                ROL     @Q8+2
                ROL     @Q8+1
                ROL     @Q8
                ; @Q10 = @Q10 + @Q8  (ADCA chain)
                LDA     @Q10+7
                ADDA    @Q8+7
                STA     @Q10+7
                LDA     @Q10+6
                ADCA    @Q8+6
                STA     @Q10+6
                LDA     @Q10+5
                ADCA    @Q8+5
                STA     @Q10+5
                LDA     @Q10+4
                ADCA    @Q8+4
                STA     @Q10+4
                LDA     @Q10+3
                ADCA    @Q8+3
                STA     @Q10+3
                LDA     @Q10+2
                ADCA    @Q8+2
                STA     @Q10+2
                LDA     @Q10+1
                ADCA    @Q8+1
                STA     @Q10+1
                LDA     @Q10
                ADCA    @Q8
                STA     @Q10
                ; ------------------------------------------------
                ; remainder r = n - q*10 (stored back in @N64)
                ; ------------------------------------------------
                LDA     @N64+7
                SUBA    @Q10+7
                STA     @N64+7
                LDA     @N64+6
                SBCA    @Q10+6
                STA     @N64+6
                LDA     @N64+5
                SBCA    @Q10+5
                STA     @N64+5
                LDA     @N64+4
                SBCA    @Q10+4
                STA     @N64+4
                LDA     @N64+3
                SBCA    @Q10+3
                STA     @N64+3
                LDA     @N64+2
                SBCA    @Q10+2
                STA     @N64+2
                LDA     @N64+1
                SBCA    @Q10+1
                STA     @N64+1
                LDA     @N64
                SBCA    @Q10
                STA     @N64
                ; digit = low byte (0..9)
                LDA     @N64+7
                ADDA    #'0'
                ; @BUF64[@CNT] = digit (LSD-first)
                LDB     @CNT
                LDX     #@BUF64
                STA     B,X
                INC     @CNT
                ; n = q  (copy @Q64 -> @N64)
                LDD     @Q64
                STD     @N64
                LDD     @Q64+2
                STD     @N64+2
                LDD     @Q64+4
                STD     @N64+4
                LDD     @Q64+6
                STD     @N64+6
                ; loop until n == 0
                LDA     @N64
                ORA     @N64+1
                ORA     @N64+2
                ORA     @N64+3
                ORA     @N64+4
                ORA     @N64+5
                ORA     @N64+6
                ORA     @N64+7
                LBNE    @S64_Loop
                ; Push digits so they appear MSD..LSD in memory
                LDB     @CNT
S64_PushDigits:
                LDA     ,X+
                PSHS    A
                DECB
                BNE     S64_PushDigits
                ; push sign then length
                LDA     @SIGNCH
                PSHS    A
                LDA     @CNT
                INCA                    ; +1 for sign
                PSHS    A
@Return:
    JMP     >$FFFF          ; Return, self modified jump address

; Random64 - Get a random 64 bit number from 1 to 64 bit value on the stack
Random64:
    PULS    D
    STD     @Return+1
    LDA     #8
!   JSR     RandomFast8Bit  ; Get a random # in B from zero to 255
    PSHS    B
    DECA
    BNE     <
    JSR	    Mul_UnSigned_Both_64 ; Result is on the stack, full 128 bit value is @ RESULT
    INC     RESULT+7        ; Add 1 to result
    BNE     >
    INC     RESULT+6
    BNE     >
    INC     RESULT+5
    BNE     >
    INC     RESULT+4
    BNE     >
    INC     RESULT+3
    BNE     >
    INC     RESULT+2
    BNE     >
    INC     RESULT+1
    BNE     >
    INC     RESULT
!   LEAS    8,S     ; Over write value on the stack
    LDU     #RESULT ; Copy MSbytes of RESULT on the stack
    PULU    D,X,Y
    LDU     ,U
    PSHS    D,X,Y,U
@Return:
    JMP     >$FFFF          ; Return
