; Add two 4-byte values on the stack (32-bit)
; Assumes each 32-bit value is stored big-endian: [b3 b2 b1 b0] (b0 = LSB)
;
; On entry (before PULS):
;   ,S      = return address
;   2,S..5,S  = Value1 (4 bytes)
;   6,S..9,S  = Value2 (4 bytes)
;
; On exit:
;   Result replaces Value2, Value1 is dropped
;   ,S..3,S = result (4 bytes), then returns
;
; Clobbers: A,B,Y,CC
Add_4ByteTo4Byte:
	PULS	Y	    ; Y now has the return address and stack now points at the correct place
	LDD 	2,S    	; Load Value1 bytes 1 and 0 into D (A:B)
	ADDD 	6,S   	; Add Value2 bytes 1 and 0 to D, sets carry if overflow
	STD 	6,S    	; Store result to Value2 bytes 1 and 0
	LDD 	,S    	; Load Value1 bytes 3 and 2 into D (A:B)
	ADCB 	5,S   	; Add Value2 byte 2 to B with carry
	ADCA 	4,S   	; Add Value2 byte 3 to A with carry
	STD 	4,S    	; Store result to Value2 bytes 3 and 2
	LEAS 	4,S   	; Adjust stack pointer, S now points to the 4-byte result
	JMP	    ,Y	    ; Return (,S now has the resulting value)



; Subtract two 4-byte values on the stack (32-bit)
; Computes: Value1 @ 4,S - Value2 @ ,S
; Assumes each 32-bit value is big-endian: [b3 b2 b1 b0] (b0 = LSB)
;
; Entry (before PULS):
;   ,S        = return address
;   2,S..5,S  = Value2 (4 bytes)
;   6,S..9,S  = Value1 (4 bytes)
;
; Exit:
;   Result overwrites Value2, Value1 is dropped
;   ,S..3,S   = result (4 bytes)
;
; Clobbers: A,B,Y,CC
Subtract_4ByteFrom4Byte:
	PULS	Y	    ; Y now has the return address and stack now points at the correct place
	LDD 	6,S   	; Load Value1 bytes 1 and 0 (least significant 16 bits) into D (A:B)
	SUBD 	2,S   	; Subtract Value2 bytes 1 and 0 from D, sets carry if borrow
	STD 	6,S   	; Store result to Value2 bytes 1 and 0
	LDD 	4,S   	; Load Value1 bytes 3 and 2 into D (A:B)
	SBCB 	1,S   	; Subtract Value2 byte 2 from B with borrow
	SBCA 	,S    	; Subtract Value2 byte 3 from A with borrow
	STD 	4,S   	; Store result to Value1 bytes 3 and 2
	LEAS 	4,S   	; Adjust stack pointer, S now points to the 4-byte result
	JMP	    ,Y	    ; Return (,S now has the resulting value)

; Subroutine to negate a 32-bit number at address in X
Negate_32:
; Invert each byte
    COM     ,X
    COM     1,X
    COM     2,X
    COM     3,X
; + 1
; Propogate if needed
    INC     3,X
    BNE     >               ; If <> zero, don't propagate carry, done
    INC     2,X
    BNE     >               ; If <> zero, don't propagate carry, done
    INC     1,X
    BNE     >               ; If <> zero, don't propagate carry, done
    INC     ,X
    BNE     >               ; If <> zero, don't propagate carry, done
!   RTS

; Subroutine to negate a 64-bit number at address in X
Negate_64A:
    LDB     #7
@DoNeg:
    CLRA                    ; Clear the initial carry
!   LDA     #0
    SBCA    B,X
    STA     B,X
    DECB
    BPL     <
    RTS

; 32-bit Multiplication on 6809
; Inputs: ,S (4 bytes), 8,S (4 bytes)
; Output: S=S+4, 4 byte (32 bit) value is at ,S also full 64 bit value is @ RESULT
;
; Case 1: Two Signed Integers
;	JSR	Mul_Signed_Both_32
; Case 2: Signed × UnSigned
;	JSR	Mul_MultiplicandSigned_32
; Case 3: UnSigned × Signed
;	JSR	Mul_MultiplierSigned_32
; Case 4: Two Unsigned Integers
;	JSR	Mul_UnSigned_Both_32
;
; Case 1: Two Signed Integers
Mul_Signed_Both_32:
	PULS	D			; Get return address off the stack
	STD	    Mul_Return_32+1		; Self mod return address
; Check sign of multiplicand - Value1
	LDA 	4,S        	; Load Value 1 MSB
    TSTA                	; Test sign bit
	BPL 	A_POSITIVE_32@  ; Branch if positive
    LDA 	#1
	STA 	Sign_Value1     ; Set Sign_Value1 = 1 (negative)
    LEAX	4,S		; Point at Value1
	JSR 	Negate_32       ; Negate, make it positive
    BRA 	>
A_POSITIVE_32@:
	CLR 	Sign_Value1     ; Set Sign_Value1 = 0 (positive)
; Check sign of multiplier - Value2
!  	LDA 	,S         	; Load Value 2 MSB
    TSTA
    BPL 	B_POSITIVE_32@  ; Branch if positive
	LDA 	#1
    STA 	Sign_Value2     ; Set Sign_Value2 = 1 (negative)
	LEAX	,S		; Point at Value2
    JSR 	Negate_32       ; Negate NUM2 make it positive
	BRA 	>		; Skip forward
B_POSITIVE_32@:
    CLR 	Sign_Value2    	; Set Sign_Value2 = 0 (positive)
!	JSR	    Mul_UnSigned_32	; Do the 32 bit unsigned multiplication
	LDA	    Sign_Value1	; A = Sign of Value 1
	EORA	Sign_Value2	; XOR A with the sign of Value 2
	BEQ	    >		; If A = 0 then result will be positive, leave it as it is
	LDX	    #RESULT		; Make Result a negative
	JSR 	Negate_64A      ; Negate the big number
!	BRA	    Mul_FixStack_32 ; Return

; Case 2: Signed × UnSigned
Mul_MultiplicandSigned_32:
	PULS	D			; Get return address off the stack
	STD	    Mul_Return_32+1		; Self mod return address
; Check sign of multiplicand - Value1
	LDA 	8,S        	; Load Value 1 MSB
    TSTA                	; Test sign bit
	BPL 	A_POSITIVE_32@  ; Branch if positive
    LDA 	#1
	STA 	Sign_Value1     ; Set Sign_Value1 = 1 (negative)
    LEAX	8,S		; Point at Value1
	JSR 	Negate_32       ; Negate NUM1 make it positive
    BRA 	>
A_POSITIVE_32@:
	CLR 	Sign_Value1     ; Set Sign_Value1 = 0 (positive)
!	JSR	    Mul_UnSigned_32	; Do the 32 bit unsigned multiplication
	TST	    Sign_Value1	; Check sign of Value1
	BEQ	    >		; If Sign = 0 then result will be positive, leave it as it is
	LDX	    #RESULT		; Make Result a negative
	JSR 	Negate_64A      ; Negate the big number
!	BRA	    Mul_FixStack_32 ; Return

; Case 3: UnSigned × Signed
Mul_MultiplierSigned_32:
	PULS	D			; Get return address off the stack
	STD	    Mul_Return_32+1		; Self mod return address
; Check sign of multiplier - Value2
	LDA 	,S        	; Load Value 2 MSB
    TSTA                	; Test sign bit
	BPL 	A_POSITIVE_32@  ; Branch if positive
    LDA 	#1
	STA 	Sign_Value2     ; Set Sign_Value2 = 1 (negative)
    LEAX	,S		; Point at Value2
	JSR 	Negate_32       ; Negate NUM1 make it positive
    BRA 	>
A_POSITIVE_32@:
	CLR 	Sign_Value2     ; Set Sign_Value1 = 0 (positive)
!	JSR	    Mul_UnSigned_32	; Do the 32 bit unsigned multiplication
	TST	    Sign_Value2	; Check sign of Value2
	BEQ 	>		; If Sign = 0 then result will be positive, leave it as it is
	LDX	    #RESULT		; Make Result a negative
	JSR 	Negate_64A      ; Negate the big number
!	BRA	    Mul_FixStack_32 ; Return

; Case 4: Two Unsigned Integers
Mul_UnSigned_Both_32:
	PULS	D			; Get return address off the stack
	STD	    Mul_Return_32+1		; Self mod return address
	BSR	    Mul_UnSigned_32		; Do the 32 bit unsigned integer multiplication

Mul_FixStack_32:
; 1) Fix the stack
; 2) Copy Result on the stack
; 3) Return
	LEAS	4,S			; Move stack forward 8 bytes
	LDD	    RESULT+4
	STD	    ,S
	LDD	    RESULT+6
	STD	    2,S
Mul_Return_32:
	JMP	    >$FFFF
	
; Main multiplication routine
; Do ,S * 4,S
; result is stored in RAM @ RESULT which is an 8 byte value
Mul_UnSigned_32:
    opt     c
    opt     ct
    opt     cc       * show cycle count, add the counts, clear the current count
    ; Zero the 64-bit RESULT
    LDX     #RESULT
    LDD	    #$0000
    STD     ,X
    STD     2,X
    STD     4,X
    STD     6,X
	LEAU	6,S	        ; U = Point at Value 1
	LEAY	2,S	        ; Y = Point at Value 2
; Outer loop: i from 7 to 0
    LDB     #3
    STB 	I_INDEX	; Start from index 3
@I_LOOP:
; Load Ai = NUM1[i]
    LDA     I_INDEX
    LDA     A,U             ; A = Ai
    STA     @J_LOOP+1       ; save Ai (self mod below)
;
    LDB     #3
    STB 	J_INDEX	        ; Start from index 3
@J_LOOP:
    LDA     #$FF            ; holds Ai between loads (self mod above)
; Load Bj = NUM2[j]
    LDB     J_INDEX
    LDB     B,Y             ; B = Bj
;
; D = Ai * Bj  (A=high, B=low)
    MUL                      ; D = A*B
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

; ===== Direct-page temps (fast) =====
N32         RMB 4      ; current N (unsigned magnitude), big-endian
Q32         RMB 4      ; quotient
Q10         RMB 4      ; q*10
Q8          RMB 4      ; q*8
CNT         RMB 1      ; digit count (1..10)
SIGNCH      RMB 1      ; ' ' or '-'
N32BUF      RMB 10     ; digits LSD-first (ASCII)

; ------------------------------------------------------------
; U32_TO_DECSTR
; Input : unsigned 32-bit at ,S..3,S (big-endian)
; Output: replaces it with: ,S=len, 1,S=' ' or '-', 2,S..digits
; Uses  : Mul_UnSigned_32: multiplies two unsigned 32-bit, returns 64-bit @ RESULT
; Clobbers: A,B,D,X,Y,U
; ------------------------------------------------------------
U32_TO_DECSTR:
    PULS    D,X,U               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
; Copy input 32-bit from stack into N32 and remove it from stack
    STX     N32
    STU     N32+2
    BRA     @Pos
;
; ------------------------------------------------------------
; S32_TO_DECSTR
; Input : signed 32-bit at ,S..3,S (big-endian)
; Output: replaces it with: ,S=len, 1,S=' ' or '-', 2,S..digits
; Uses  : Negate_32 (negates 32-bit @ ,X)
;         Mul_UnSigned_32: multiplies two unsigned 32-bit, returns 64-bit @ RESULT
; Clobbers: A,B,D,X,Y,U
; ------------------------------------------------------------
S32_TO_DECSTR:
    PULS    D,X,U               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
; Copy input 32-bit from stack into N32 and remove it from stack
        STX     N32
        STU     N32+2
; Sign handling (signed 32-bit)
        LDA     N32             ; MSB
        BPL     @Pos
        LDA     #'-'
        STA     SIGNCH
        LDX     #N32
        JSR     Negate_32        ; N32 = abs(N32) as unsigned magnitude
        BRA     @Conv
@Pos:
        LDA     #' '
        STA     SIGNCH
@Conv:
        CLR     CNT
@Loop:
; ---- q = n / 10 using reciprocal multiply ----
; Push multiplicand n (N32) then multiplier $CCCCCCCD, call Mul_UnSigned_32
        LDD     N32
        LDX     N32+2
        LDY     #$CCCC
        LDU     #$CCCD
        PSHS    D,X,Y,U        ; now next 4 bytes = $CCCCCCCD
        JSR     Mul_UnSigned_32  ; RESULT (8 bytes) now at RESULT (big-endian)
; Copy high32(product) into Q32, discard 64-bit product from stack
        LDU     #RESULT
        PULU    D,X
        LDU     #Q32+4
        PSHU    D,X
        LEAS    8,S
; Q32 >>= 3   (because q = high32 >> 3)
        LSR     Q32
        ROR     Q32+1
        ROR     Q32+2
        ROR     Q32+3
        LSR     Q32
        ROR     Q32+1
        ROR     Q32+2
        ROR     Q32+3
        LSR     Q32
        ROR     Q32+1
        ROR     Q32+2
        ROR     Q32+3
; ---- Q10 = q * 10 = (q<<3) + (q<<1) ----
; Q10 = Q32
        LDD     Q32
        STD     Q10
        LDD     Q32+2
        STD     Q10+2
; Q10 <<= 1   (q*2)
        ASL     Q10+3
        ROL     Q10+2
        ROL     Q10+1
        ROL     Q10
; Q8 = Q32
        LDD     Q32
        STD     Q8
        LDD     Q32+2
        STD     Q8+2
; Q8 <<= 3    (q*8)
        ASL     Q8+3
        ROL     Q8+2
        ROL     Q8+1
        ROL     Q8
        ASL     Q8+3
        ROL     Q8+2
        ROL     Q8+1
        ROL     Q8
        ASL     Q8+3
        ROL     Q8+2
        ROL     Q8+1
        ROL     Q8
; Q10 = Q10 + Q8  (q*2 + q*8 = q*10)
        LDA     Q10+3
        ADDA    Q8+3
        STA     Q10+3
        LDA     Q10+2
        ADCA    Q8+2
        STA     Q10+2
        LDA     Q10+1
        ADCA    Q8+1
        STA     Q10+1
        LDA     Q10
        ADCA    Q8
        STA     Q10
; ---- remainder r = n - q*10  (0..9) ----
; do subtraction in-place in N32 (we don’t need old n after digit)
        LDA     N32+3
        SUBA    Q10+3
        STA     N32+3
        LDA     N32+2
        SBCA    Q10+2
        STA     N32+2
        LDA     N32+1
        SBCA    Q10+1
        STA     N32+1
        LDA     N32
        SBCA    Q10
        STA     N32
; digit = N32+3 (0..9)
        LDA     N32+3
        ADDA    #'0'
; store digit LSD-first in N32BUF
        LDB     CNT
        LDU     #N32BUF
        STA     B,U
        INC     CNT
; n = q (copy Q32 -> N32)
        LDD     Q32
        STD     N32
        LDD     Q32+2
        STD     N32+2
; loop until q == 0
        LDA     N32
        ORA     N32+1
        ORA     N32+2
        ORA     N32+3
        LBNE    @Loop
; ---- push digits (LSD-first) so stack ends up MSD-first in memory ----
        LDB     CNT
;        LDX     #N32BUF
@PushDigits:
        LDA     ,U+
        PSHS    A
        DECB
        BNE     @PushDigits
; push sign then length
        LDA     SIGNCH
        PSHS    A
        LDA     CNT
        INCA                    ; length = digits + 1(sign)
        PSHS    A
@Return:
    JMP     >$FFFF          ; Return, self modified jump address

; Print a 32 bit signed number @ 2,S
PRINT_32Bit:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
    LDD     2,S             ; Get LSW
    BNE     >               ; If <> 0 then skip ahead
    LDD     ,S              ; Get MSW
    BEQ     @PrintZero      ; Go print 0 and exit
!   LDA     ,S              ; Check the sign
    BPL     PRINT_Un32Bit1  ; Print unsigned 32 bit number
    LDA	    #'-'
    JSR     PrintA_On_Screen
    LEAX    ,S
    JSR     Negate_32       ; Make 32 bit number @ X a postive
    BRA     PRINT_Un32Bit2  ; Print the positive number
; Print an 32 bit unsigned number @ 2,S
PRINT_Un32Bit:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
    LDD     ,S              ; Get MSW
    BNE     >               ; If <> 0 then skip ahead 
    LDD     2,S             ; Get LSW
    BEQ     @PrintZero      ; Go print 0 and exit
PRINT_Un32Bit1:
!   LDA	    #' '
    JSR     PrintA_On_Screen
; At this point D is a positive number
PRINT_Un32Bit2:
    PULS    D,X
    STD     DividendTemp
    STX     DividendTemp+2
    LDD     #$0000          ; Erase the lower unneeded 32 bits of DividentTemp
    STD     DividendTemp+4
    STD     DividendTemp+6
    JSR     PrintDecAt_DividendTemp_32 ; Print the 32 bit number stored at DividendTemp
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
@PrintZero:
    LEAS    4,S             ; Fix the stack
    JSR     PrintZero       ; Go print 0 and exit
    BRA     @Return         ; Exit

; 32 bit Integer division Signed and UnSigned
; How to use the 32-Bit divide code below:
;;
; Code does division of Value1/Value2 where:
; Value1 is stored at 4,S (Dividend)
; Value2 is stored at ,S  (Divisor)
; After Division the stack is moved forward 8 bytes and the result (Quotient) is stored at ,S
;
; These are the routines to call depending on your needs:
; Signed Divisor, Unsigned Dividend:
;	JSR	Div_DivisorSigned_Rounding_32
;	JSR	Div_DivisorSigned_NoRounding_32
;
; Signed Dividend, Unsigned Divisor:
;	JSR	Div_DividendSigned_Rounding_32
;	JSR	Div_DividendSigned_NoRounding_32
;
; If both values are UnSigned
;	JSR	Div_UnSigned_Rounding_32
;	JSR	Div_UnSigned_NoRounding_32
;
; If both values are Signed
;	JSR	Div_Signed_Both_Rounding_32
;	JSR	Div_Signed_Both_NoRounding_32
;
; *******************************************************************************************************
; Signed Divisor, Unsigned Dividend:
; The quotient's sign must match the divisor's sign and the remainder is positive
Div_DivisorSigned_Rounding_32:
	LDA	    #$FF			    ; If = 0 then no rounding will be done
	BRA	    DoDivisorSigned_32
Div_DivisorSigned_NoRounding_32:
	CLRA				        ; If = 0 then no rounding will be done
DoDivisorSigned_32:
	STA	    RoundFlag		    ; If = 0 then no rounding will be done
	PULS	D			        ; Get return address off the stack
	STD	    Div_Return_32+1		; Self mod return address
	JSR	    Div_Setup_32		; Setup Divisor(Value2) & Dividend(Value1) off the stack
; Figure out if Divisor is signed, if not simply do regular unsigned version
	LDA	    4,S			        ; Get the Divisor's sign byte (MSB)
	BPL	    ReadyDoUnsignedDiv_32	; Go do a regular unsigned divide (everything will be positive)

; If we get here the Divisor is negative, we need to:
; 1) Make the Divisor positive (negate it)
; 2) Do unsigned division
; 3) Make the quotient negative
; 4) Leave the remainder as positive
    LDX 	#Temp_Divisor		; X points at the divisor
	JSR 	Negate_32       	; Negate 32 bit value at X
	JSR	    UnSigned_Div_32		; Do Unsigned 32 bit division
    LDX 	#Quotient		    ; X points at the Quotient
	JSR 	Negate_32       	; Negate 32 bit value at X (make it negative again)
	BRA	    DivFixStack_32		; Fix the Stack and return

; Signed Dividend, Unsigned Divisor:
; The quotient's sign matches the dividend's sign and the remainder also matches the dividend's sign 
Div_DividendSigned_Rounding_32:
	LDA	    #$FF			    ; If = 0 then no rounding will be done
	BRA	    DoDividendSigned_32
Div_DividendSigned_NoRounding_32:
	CLRA				        ; If = 0 then no rounding will be done
DoDividendSigned_32:
	STA	    RoundFlag		    ; If = 0 then no rounding will be done
	PULS	D			        ; Get return address off the stack
	STD	    Div_Return_32+1		; Self mod return address
	BSR	    Div_Setup_32		; Setup Divisor(Value2) & Dividend(Value1) off the stack
; Figure out if Dividend is signed, if not simply do regular unsigned version
	LDA	    ,S			            ; Get the Dividend's sign byte (MSB)
	BPL	    ReadyDoUnsignedDiv_32	; Go do a regular unsigned divide (everything will be positive)

; If we get here the Dividend is negative, we need to:
; 1) Make the Dividend positive (negate it)
; 2) Do unsigned division
; 3) Make the quotient negative
; 4) Make the remainder a negative
    LDX 	#Temp_Dividend		; X points at the Dividend
	JSR 	Negate_32       	; Negate 32 bit value at X
	JSR	    UnSigned_Div_32	    ; Do Unsigned 32 bit division
    LDX 	#Quotient		    ; X points at the Quotient
	JSR 	Negate_32       	; Negate 32 bit value at X (make it negative again)
    LDX 	#Remainder		    ; X points at the Remainder
	JSR 	Negate_32       	; Negate 32 bit value at X (make it negative, to match the Dividend)
	BRA	    DivFixStack_32      ; Fix the Stack and return

; If both values are UnSigned & you want the result rounded
Div_UnSigned_Rounding_32:
	LDA	    #$FF			    ; If = 0 then no rounding will be done
	BRA	    DoUnSignedDiv_32
; If both values are UnSigned & you don't want the result rounded
Div_UnSigned_NoRounding_32:
	CLRA				        ; If = 0 then no rounding will be done
DoUnSignedDiv_32:
	STA	    RoundFlag		    ; If = 0 then no rounding will be done
	PULS    D			        ; Get return address off the stack
	STD	    Div_Return_32+1		; Self mod return address
	BSR	    Div_Setup_32		; Setup Divisor(Value2) & Dividend(Value1) off the stack
ReadyDoUnsignedDiv_32:
	JSR	    UnSigned_Div_32		; Do Unsigned 32 bit division
	BRA	    DivFixStack_32		; Fix the Stack and return

; If both values are Signed & you want the result rounded
Div_Signed_Both_Rounding_32:
	LDA	    #$FF			    ; If = 0 then no rounding will be done
	BRA	    DoSignedDiv_32
; If both values are Signed & you don't want the result rounded
Div_Signed_Both_NoRounding_32:
	CLRA				        ; If = 0 then no rounding will be done
DoSignedDiv_32:
	STA	    RoundFlag		    ; If = 0 then no rounding will be done
	PULS	D			        ; Get return address off the stack
	STD	    Div_Return_32+1		; Self mod return address
	BSR	    Div_Setup_32		; Setup Divisor(Value2) & Dividend(Value1) off the stack
	JSR	    Signed_Div_Both_32
	BRA	    DivFixStack_32

; 1) Fix the stack
; 2) Copy Quotient on the stack
; 3) Return
DivFixStack_32:
	LEAS	4,S			        ; Move stack forward 4 bytes
	LDD	    Quotient
	STD	    ,S
	LDD	    Quotient+2
	STD	    2,S
Div_Return_32:
	JMP	    >$FFFF			    ; Self modified return address

Div_Setup_32:
	LDD	    2,S		            ; Get Value2 (Divisor)
	STD	    Temp_Divisor	    ; Save as Temp_Divisor
	LDD	    4,S		            ; Get Value2 (Divisor)
	STD	    Temp_Divisor+2	    ; Save as Temp_Divisor

	LDD	    6,S		            ; Get Value1 (Dividend)
	STD	    Temp_Dividend	    ; Save as Temp_Dividend
	LDD	    8,S		            ; Get Value1 (Dividend)
	STD	    Temp_Dividend+2	    ; Save as Temp_Dividend
	RTS

; Inputs: Temp_Dividend, Temp_Divisor
; Outputs: Quotient, Remainder
UnSigned_Div_32:
;
; Check for division by zero 
    LDD     Temp_Divisor+2      ; Divisor
    BNE     Div_NotZero_32      ; If non-zero, proceed
    LDD     Temp_Divisor	    ; Divisor MSW
    BNE     Div_NotZero_32      ; If non-zero, proceed
; Divisor is zero, set quotient to max (0xFFFFFFFFFFFFFFFF) 
    LDX     #Quotient 
    LDD     #$FFFF 
    STD     ,X++ 
    STD     ,X++ 
	RTS

Div_NotZero_32:
; 1) Copy dividend to DividendTemp storage
    LDX     #Temp_Dividend
	LDU	    #DividendTemp
	LDB	    #4
!	LDA	    ,X+
	STA	    ,U+
	DECB
	BNE	    <
	CLRA

; 2) Initialize quotient to zero
    LDX     #Quotient
    STD     ,X
    STD     2,X

; 3) Initialize remainder to zero
    LDX     #Remainder
    STD     ,X
    STD     2,X

; 4) Loop over 32 bits
    LDY     #32             ; bit-count
Div32_Loop_32:
; 4a) Shift dividend = DIVTMP left by 1
	LDX     #Temp_Dividend
    ASL     3,X      	    ; clear carry & shift left, low byte, to high byte
    ROL     2,X
    ROL     1,X
    ROL     ,X

; 4b) Shift remainder left by 1, bring in carry
    LDX     #Remainder       
    ROL     3,X      	    ; Shift remainder left by 1, bring in carry
    ROL     2,X
    ROL     1,X
    ROL     ,X

; 4c) Shift quotient left by 1
    LDX     #Quotient 	; 
    ASL     3,X      	; clear carry & shift left, low byte, to high byte
    ROL     2,X
    ROL     1,X
    ROL     ,X

; 4d) Compare remainder vs divisor
	LDX	    #Remainder
	LDU	    #Temp_Divisor
	LDD	    ,X
	CMPD	,U
    BHI     Do_Subtract_32        ; remainder.H > divisor.H
    BNE     No_Subtract_32        ; remainder.H < divisor.H
	LDD	    2,X
	CMPD	2,U
    BLO     No_Subtract_32        ; remainder.L < divisor.L

Do_Subtract_32:
; Subtract divisor from remainder
	LDD	    2,X
	SUBD	2,U
	STD	    2,X
	LDB	    1,X
	SBCB	1,U
	LDA	    ,X
	SBCA	,U
	STD	    ,X

; Set quotient LSB to 1
;	LDA	Quotient+3
;   ORA     #1
;	STA	Quotient+3
	INC	Quotient+3

No_Subtract_32:
; 4e) Loop
    LEAY    -1,Y
    BNE     Div32_Loop_32

; Done Unsigned 32 bit division
	LDA	    RoundFlag	; If = 0 then no rounding will be done
	BEQ	    Div_Done_32 ; Exit, no Rounding wanted

; Handle rounding:
; Copy Remainder to DividendTemp
        LDX     #Remainder
        LDU     #DividendTemp
        LDB     #4
Copy_Loop@:
        LDA     ,X+
        STA     ,U+
        DECB
        BNE     Copy_Loop@

        ; Shift DividendTemp left by 1 (multiply by 2)
        LDX     #DividendTemp
        ASL     3,X                 ; shift LSB
        ROL     2,X
        ROL     1,X
        ROL     ,X                  ; shift MSB, carry out

        BCS     Round_Up_32            ; if carry set, remainder * 2 >= 2^32 > divisor

        ; Compare DividendTemp (shifted remainder) with Temp_Divisor
        LDX     #DividendTemp
        LDU     #Temp_Divisor
        LDD     ,X
        CMPD    ,U
        BHI     Round_Up_32            ; if greater, round up
        BLO     Div_Done_32                ; if less, no rounding
        LDD     2,X
        CMPD    2,U
        BLO     Div_Done_32 		; if >=, round up otherwise No rounding

Round_Up_32:
        ; Increment quotient by 1
        LDX     #Quotient
        INC     3,X
        BNE     Div_Done_32
        INC     2,X
        BNE     Div_Done_32
        INC     1,X
        BNE     Div_Done_32
        INC     ,X
Div_Done_32:
        RTS

; Main routine for signed 32-bit division
Signed_Div_Both_32:
; Copy DIVIDEND to Temp_Dividend
;    LDX #DIVIDEND	
    LEAX    6,S	        ; X points at the Dividend
    LDU     #Temp_Dividend
    LDB     #4
!   LDA     ,X+
    STA     ,U+
    DECB
    BNE     <

; Copy DIVISOR to Temp_Divisor
;    LDX #DIVISOR
    LEAX    2,S	; X points at the Divisor
    LDU     #Temp_Divisor
    LDB     #4
!   LDA     ,X+
    STA     ,U+
    DECB
    BNE     <

; Check sign of DIVIDEND
    LDA     Temp_Dividend       ; Load MSB
    TSTA                        ; Test sign bit
    BPL     A_POSITIVE_32       ; Branch if positive
    LDA     #1
    STA     Sign_Dividend       ; Set Sign_Dividend = 1 (negative)
    LDX     #Temp_Dividend
    JSR     Negate_32           ; Negate Temp_Dividend to get |DIVIDEND|
    BRA     CHECK_DIVISOR_32
A_POSITIVE_32:
    CLR     Sign_Dividend       ; Set Sign_Dividend = 0 (positive)

CHECK_DIVISOR_32:
; Check sign of DIVISOR
    LDA     Temp_Divisor        ; Load MSB
    TSTA
    BPL     B_POSITIVE_32       ; Branch if positive
    LDA     #1
    STA     Sign_Divisor        ; Set Sign_Divisor = 1 (negative)
    LDX     #Temp_Divisor
    JSR     Negate_32           ; Negate Temp_Divisor to get |DIVISOR|
    BRA     DO_DIVISION_32
B_POSITIVE_32:
    CLR     Sign_Divisor        ; Set Sign_Divisor = 0 (positive)

DO_DIVISION_32:
; Call the unsigned 32-bit division routine
; Inputs: Temp_Dividend, Temp_Divisor
; Outputs: Quotient, Remainder
    JSR     UnSigned_Div_32 	; Do unsigned 32 bit division

; Adjust quotient sign: negate if Sign_Dividend XOR Sign_Divisor = 1
    LDA     Sign_Dividend
    EORA    Sign_Divisor        ; XOR signs
    BEQ     ADJUST_REMAINDER_32 ; If signs are same, quotient stays positive
    LDX     #Quotient
    JSR     Negate_32           ; Negate Quotient

ADJUST_REMAINDER_32:
; Adjust remainder sign: negate if Sign_Dividend = 1
    LDA     Sign_Dividend
    BEQ     Signed_DONE_32      ; If dividend positive, remainder stays positive
    LDX     #Remainder
    JSR     Negate_32           ; Negate REMAINDER

Signed_DONE_32:
    RTS

; Convert 32-bit (un)signed integer (big-endian) to decimal and print to CoCo video RAM
; Input: X points to 8-byte big-endian unsigned integer in RAM ([X] = MSB, [X+7] = LSB)
; Output: Decimal string printed to video RAM using routine PrintA_On_Screen
;
; Memory locations
; DividendTemp = Temporary storage for 8-byte number
;
PRINT_Signed_Decimal_32:
	LDA	    ,X
	BPL	    PRINT_UnSigned_Decimal_32	; If positive then print number as it is
	PSHS    X
    LDA	    #'-'
    JSR     PrintA_On_Screen
	JSR     Negate_32       ; Negate 32 bit value at X (make it positive)
	BSR	    PRINT_UnSigned_Decimal_NoSpace_32
	PULS    X
	JMP     Negate_32       ; Negate 64 bit value at X (make it negative again) & return

; Print 32 bit signed numer at X in Decimal
PRINT_UnSigned_Decimal_32:
    LDA	    #' '
    JSR     PrintA_On_Screen
PRINT_UnSigned_Decimal_NoSpace_32:
    LDY     #DividendTemp         ; Y points to DividendTemp
    LDB     #4              ; 4 bytes to copy
Copy_Loop@:
    LDA     ,X+             ; Read byte from [X] (big-endian: [X] is MSB)
    STA     ,Y+             ; Store to DividendTemp
    DECB
    BNE     Copy_Loop@

; Print the 32 bit number stored at DividendTemp
PrintDecAt_DividendTemp_32:
    LDY     #0              ; Y = digit count
CONVERT_LOOP@:
; Check if DividendTemp is zero
    LDX     #DividendTemp
    LDB     #4
    CLRA
CHECK_ZERO@:
    ORA     ,X+
    DECB
    BNE     CHECK_ZERO@
    TSTA
    BEQ     >               ; If all bytes zero, conversion done
    JSR     DIVIDE_32_BY_10	; DividendTemp updated (quotient), B = remainder (0-9)
    ADDB    #$30            ; Convert remainder to ASCII
    PSHS    B               ; Push digit onto stack
    LEAY    1,Y             ; Increment digit count
    CMPY    #10             ; 10 digits max for 32 bit number
    BEQ	    @POP_LOOP       ; Print the digits
    BRA     CONVERT_LOOP@   ; Keep converting
!   CMPY	#$0000          ; check for zero digits
    BNE     @POP_LOOP       ; Print the digits
; If = 0 then no digits, print '0'
@PrintZero:
    LDA     #' '
    JSR     PrintA_On_Screen
    LDA     #'0             ; ASCII '0'
    JMP     PrintA_On_Screen ; Print A and return
@POP_LOOP:
    PULS    A               ; Pop digit from stack
    JSR     PrintA_On_Screen
    LEAY    -1,Y            ; Decrement digit count
    BNE     @POP_LOOP
    RTS	                    ; Return

; Subroutine: Divide 32-bit number at DividendTemp by 10
; Input: DividendTemp (4 bytes, big-endian)
; Output: DividendTemp updated (quotient), B = remainder (0-9)
; Clobbers: A, B, U, X
DIVIDE_32_BY_10:
    LDU     #DividendTemp   ; U points to DividendTemp
    LDB     #4              ; 4 bytes
    PSHS    B               ; Push counter
    CLR     ,-S             ; Push remainder (0)
DIV_LOOP@:
    LDA     ,S              ; Load remainder
    LDB     ,U              ; Load current byte
; D = remainder:byte
    JSR     DIV16_BY_10     ; Divide D by 10, A = D / 10, B = remainder
    STA     ,U+             ; Store quotient byte
    STB     ,S              ; Update remainder
    DEC     1,S             ; Decrement counter
    BNE     DIV_LOOP@
    PULS	U,PC	        ; Fix the stack and return

; Random32 - get a random 32 bit number from 1 to 32 bit value on the stack
Random32:
    PULS    D
    STD     @Return+1
    LDA     #4
!   JSR     RandomFast8Bit  ; Get a random # in B from zero to 255
    PSHS    B
    DECA
    BNE     <
    JSR	    Mul_UnSigned_Both_32 ; Result is on the stack, full 64 bit value is @ RESULT
    INC     RESULT+3        ; Add 1 to RESULT
    BNE     >
    INC     RESULT+2
    BNE     >
    INC     RESULT+1
    BNE     >
    INC     RESULT
!   LDU     #RESULT
    PULU    D,X
    STD     ,S
    STX     2,S
@Return:
    JMP     >$FFFF          ; Return
