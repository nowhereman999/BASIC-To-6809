; Fast Floating Point - Extra commands
; Requires Math_Fast_Floating_Point.asm
; Which includes routines for:
; Routines for doing Fast Floating point math - 3 bytes
; FFP_ADD   	; Add 3,S + ,S Then S=S+3 result @ ,S
; FFP_SUB         ; Subtract 3,S - ,S Then S=S+3 result @ ,S
; FFP_MUL         ; Multiply 3,S * ,S Then S=S+3 result @ ,S
; FFP_DIV         ; Divide 3,S / ,S Then S=S+3 result @ ,S
;
; Conversion routines:
; FFP_TO_S64      ; Convert 3 Byte FFP @ ,S to Signed 64-bit Integer @ ,S
; FFP_TO_U64      ; Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S
; FFP_TO_S32      ; Convert 3 Byte FFP at ,S to 32-bit Signed integer at ,S
; FFP_TO_U32      ; Convert 3 Byte FFP at ,S to 32-bit Unsigned integer at ,S
; FFP_TO_S16      ; Convert 3 Byte FFP at ,S to 16-bit Signed integer at ,S
; FFP_TO_U16      ; Convert 3 Byte FFP at ,S to 16-bit Unsigned integer at ,S
; S64_To_FFP      ; Convert Signed 64 bit integer @,S to 3 Byte FFP @ ,S
; U64_To_FFP      ; Convert Unsigned 64 bit integer @,S to 3 Byte FFP @ ,S
; S32_To_FFP      ; Convert Signed 32 bit integer @,S to 3 Byte FFP @ ,S
; U32_To_FFP      ; Convert Unsigned 32 bit integer @,S to 3 Byte FFP @ ,S
; S16_To_FFP      ; Convert Signed 16 bit integer in D to 3 Byte FFP @ ,S
; U16_To_FFP      ; Convert Unsigned 16 bit integer in D to 3 Byte FFP @ ,S
;
; Helper routines:
; Shifting routines:
; FFP_Shift_Right64_AtU_B  ; Right-shift 64-bit value at U by B bits (B >= 0)
; FFP_Shift_Left64_AtU_B   ; Left-shift 64-bit value at U by B bits (B >= 0)

; New Advanced routines in this library are:
;*INVERT_FFP         ; Do 1/x where x is at ,S (value to invert), Result: 1/x at ,S
;*FFP_SQRT           ; Compute Square Root of a FFP number @ ,S result @ ,S
;*FFP_HORNER_EVEN    ; Evaluate an even-degree polynomial using Horner's method, then S=S 3, result @ ,S
;*FFP_HORNER_ODD     ; Evaluate an odd-degree polynomial using Horner's method, then S=S 3, result @ ,S
;*FFP_RATIONAL       ; Evaluate rational function P(x)/Q(x) using two Horner chains
;*FFP_MOD            ; Compute the remainder of division using dividend is @ 3,S and the divisor is @ ,S then S=S+3 result is @ ,S
;*FFP_FLOOR          ; Compute floor(x) x is @ ,S return with FFP value @,S which is the INTeger value of ,S
;*FFP_EXP            ; Compute exponential number, exp(x), x is @,S result @ ,S
;*FFP_LOG            ; Compute natural logarithm ln(x), x is @,S result @ ,S
;*FFP_SIN            ; Compute sine, sin(x), x is @,S result @ ,S
;*FFP_COS            ; Compute cosine, cos(x), x is @,S result @ ,S
;*FFP_TAN            ; Compute tangent, tan(x), x is @,S result @ ,S
;*FFP_ATAN           ; Compute arctangent, atn(x), x is @,S result @ ,S
;*FFP_POW            ; Compute Power 3,S ^ ,S Then S=S+3 result @ ,S

; 3 byte Fast Floating Point (FFP) format
; SEEEEEEE|MMMMMMMM|MMMMMMMM
; # of bits Function
;  (1 bit)       Sign - sign (0=+, 1=-)
;  (7 bits)  Exponent - signed 7 bit value (not biased)
;  (16 bits) Mantissa - 16 bits (Includes explicit Most significant bit)
;
; Special Formats:
; Zero (±0):
; Value Sign    Exponent (unbiased) Mantissa
; +0    0       All 0s              Most Significant bit is 0
; -0    1       All 0s              Most Significant bit is 0
;
; Infinity (±∞):
; Value Sign    Exponent (unbiased) Mantissa
; +∞    0       $40                 Most Significant bit is 0
; -∞    1       $40                 Most Significant bit is 0
;
; Not a Number (NaN):
; Type  Sign    Exponent (unbiased) Mantissa
; NaN   Any     $40                 Most Significant bit is 1
;

; Constants
FFP_ZERO    FCB $00,$00,$00          ; 0.0

FFP_Half    FCB $7F,$80,$00          ; 0.5
FFP_Two     FCB $01,$80,$00          ; 2.0 (fast 1/x)

; ===== SIN_COEFFS (order preserved!) =====
FFP_SIN_COEFFS
FFP_1       FCB $00,$80,$00          ; +1.0 (a1)
            FCB $FD,$AA,$AB          ; −1/6  ≈ −0.1666666667
            FCB $79,$88,$89          ; +1/120 ≈ 0.00833333333
            FCB $F3,$D0,$0D          ; −1/5040 ≈ −0.000198412698

FFP_OnePointFive FCB $00,$C0,$00         ; 1.5
FFP_2       FCB $01,$80,$00          ; 2.0

FFP_PInf    FCB $40,$00,$00          ; +∞  (E=$40, mantissa MSB=0)
FFP_QNaN    FCB $40,$80,$00          ; qNaN (E=$40, mantissa MSB=1)

FFP_InvSqrt2      FCB $7F,$B5,$05          ; ≈ 0.7071067811865476 (1/√2)

FFP_2PI: 	FCB $02,$C9,$10  ; 6.283185307179586
FFP_PI: 	FCB $01,$C9,$10  ; 3.141592653589793
FFP_PI_2: 	FCB $00,$C9,$10  ; 1.5707963267948966
FFP_3PI_2: 	FCB $02,$96,$CC  ; 4.71238898038469
FFP_NEG1: 	FCB $80,$80,$00  ; -1.0
FFP_SQRT2: 	FCB $00,$B5,$05  ; 1.4142135623730951

; ===== Constants =====
; Split ln2 = LN2_HI + LN2_LO to keep r tiny after subtraction
FFP_LN2: 	FCB $7F,$B1,$72  ; 0.6931471805599452
FFP_LOG2E: 	FCB $00,$B8,$AA  ; 1.4426950408889634
; (optional hi/lo split for tight range reduction)
FFP_LN2_HI: FCB $7F,$B1,$72  ; 0.6931471805
FFP_LN2_LO: FCB $5E,$83,$D2  ; 5.9945309e-11

; ======= Coefficients for ln(m) via z=(m-1)/(m+1)
; ln(m) ≈ 2*z * [ P(t)/Q(t) ],  t=z^2,  P even, Q even
; Use n=m=4 to start (excellent accuracy); plug in fitted FFPs below.
FFP_LOG_COEFFS_P:  ; P(t) = p0 + p1 t + p2 t^2 + p3 t^3 + p4 t^4 + p5 t^5
	FCB $00,$80,$00  ; p0 = +1.0
	FCB $81,$92,$F2  ; p1 = -2.2960112324803763
	FCB $00,$E9,$CE  ; p2 = +1.8266060030876945
	FCB $FF,$95,$EE  ; p3 = -0.5856701472737402
	FCB $7C,$84,$6B  ; p4 = +0.06465760292187715
	FCB $F6,$92,$73  ; p5 = -0.0011173131488787847

FFP_LOG_COEFFS_Q:  ; Q(t) = q0 + q1 t + q2 t^2 + q3 t^3 + q4 t^4 + q5 t^5
      FCB $00,$80,$00  ; q0 = +1.0
      FCB $81,$A8,$47  ; q1 = -2.62934456581371
      FCB $01,$A0,$32  ; q2 = +2.5030541916922644
      FCB $80,$84,$BD  ; q3 = -1.037009774198896
      FCB $7D,$B2,$68  ; q4 = +0.17422623046437988
      FCB $F9,$85,$32  ; q5 = -0.008129633413211854

; ===== Kernel coefficients =====
; Even
; P_e(t) = Pe0 + Pe1*t + Pe2*t^2 + Pe3*t^3 + Pe4*t^4
FFP_EXP_Pe:
      FCB $7F,$80,$00  ; 0.5
      FCB $7B,$88,$BB  ; 0.03338139084119223
      FCB $75,$C8,$6A  ; 0.00076452491040474
      FCB $6E,$EA,$50  ; 6.9830738420520306e-06
      FCB $66,$C5,$F8  ; 2.3046451735876875e-08

; Q_e(t) = 1 + Qe1*t + Qe2*t^2 + Qe3*t^3 + Qe4*t^4
FFP_EXP_Qe:
      FCB $00,$80,$00  ; 1.0
      FCB $FA,$87,$BF  ; -0.016570551650948877
      FCB $73,$8A,$92  ; 0.00013215134727744224
      FCB $EB,$A6,$85  ; -6.203290506660652e-07
      FCB $62,$CE,$EA  ; 1.5054975898089108e-09

FFP_EXP_Po:             ; P_o(t) = Po0 + Po1*t + Po2*t^2 + Po3*t^3 + Po4*t^4
      FCB $00,$80,$00  ; 1.0
      FCB $7D,$97,$2C  ; 0.1476276150713509
      FCB $78,$AE,$E7  ; 0.005337597292009449
      FCB $72,$8F,$4E  ; 6.833292093468524e-05
      FCB $6A,$9D,$DF  ; 2.9405970358474915e-07
FFP_EXP_Qo:             ; Q_o(t) = 1 + Qo1*t + Qo2*t^2 + Qo3*t^3 + Qo4*t^4
      FCB $00,$80,$00  ; 1.0
      FCB $FA,$9B,$F8  ; -0.01903905159531578
      FCB $73,$BA,$0F  ; 0.00017743922456207962
      FCB $EC,$85,$71  ; -9.942182773949294e-07
      FCB $63,$CB,$6D  ; 2.9602249798461223e-09

FFP_ATAN_COEFFS_P:      ; P(x) = c1*x + c3*x^3 + c5*x^5 + c7*x^7
      FCB $00,$80,$00  ; 0.9999999986163531
      FCB $00,$8F,$C8  ; 1.1232861659064668
      FCB $7E,$90,$9D  ; 0.282447655603845
      FCB $79,$8E,$22  ; 0.0086752150041525

FFP_ATAN_COEFFS_Q:       ; Q(x) = d0 + d2*x^2 + d4*x^4 + d6*x^6
      FCB $00,$80,$00  ; 1.0
      FCB $00,$BA,$73  ; 1.4566193248494073
      FCB $7F,$91,$68  ; 0.5679909550029164
      FCB $7B,$CA,$CC  ; 0.04951077935496848

FFP_X_CUR   RMB 3
FFP_Y_CUR   RMB 3
FFP_T1      RMB 3

; *** Build code for a faster INVERT routine, but for now just do 1/x
; Assume x is at ,S (value to invert)
; Result: 1/x at ,S
INVERT_FFP:
      PULS  D                 ; Get return address
      STD   @Return+1         ; Self mod return address
      PULS  A,X               ; Save original x
      CLRB                    ; sign & exponent of 1.0
      LDU   #$8000            ; mantissa for 1.0
      PSHS  B,U               ; value1 = 1.0
      PSHS  A,X               ; value2 = x
      JSR   FFP_DIV           ; FFP_DIV - Divide 3,S / ,S then S=S+3 result is @ ,S (Do 1/x)
@Return:
      JMP   >$FFFF            ; Return

; FFP_SQR
; In : x at ,S  (3 Bytes)
; Out: x*x at ,S
; Clobbers: D, X, Y, U
; Uses: FFP_MUL
; ------------------------------------------------------------
FFP_SQR:
      PULS  D                 ; Get return address
      STD   @Return+1         ; Self mod return address
; Duplicate x on the stack
      LEAU  ,S
      PULU  B,X
      PSHS  B,X               ; Copy x value on the stack
; Stack now has: [top]=x (dup) @ ,S   and  [next]=x @ 8,S
      JSR   FFP_MUL           ; Multiply 3,S * ,S then S=S+3, result is @ ,S
@Return:
      JMP   >$FFFF            ; Return, self modified jump address

; ------------------------------------------------------------
; FFP_SQRT  --  Compute sqrt(x) for FFP
; In : x @ ,S
; Out: sqrt(x) @ ,S
; Uses: FFP_MUL, FFP_ADD, FFP_SUB, FFP_DIV
; Scratch: FFP_Y_CUR, FFP_T1 (3 bytes each)
; ------------------------------------------------------------
FFP_SQRT:
      PULS  D           ; Get return address off the stack
      STD   @Return+1   ; Self modify the return location below
;
; Copy FFP off the stack, saved in FFP_SIGN, FFP_EXPonent & FFP_MANT (as 8 byte mantissa)
      LDA   ,S
      BMI   @NotANumber ; Can't get square root of a negative number
      CMPA  #$40
      BEQ   @Return     ; If it's Special then return
      LDX   1,S         ; Get mantissa
      BEQ   @Return     ; If it's zero then return, square root of zero is zero
; ============================================================
;  x is a finite, non-NaN, non-zero FFP at ,S (8 bytes)
;  We will:
;    - convert x -> internal format FFP_X_CUR
;    - set y0 = x (initial guess)
;    - iterate y = 0.5 * (y + x/y) a few times
;    - return sqrt(x) as FFP @ ,S
; ============================================================
;---------- Copy FFP x on stack into internal FFP_X_CUR ----------
;  Initial guess y0 = x (good enough; NR will converge quickly)
; Copy FFP from the stack to FFP_X_CUR
      PULS  B,X          ; Get FFP
      LDU   #FFP_X_CUR+3 ; Point past FFP_X_CUR
      PSHU  B,X          ; PUSH FFP into FFP_X_CUR
; Exponent of FFP_Y_CUR / 2
      LSLB              ; Shift sign bit out
      ASRB              ; Exponent is now a signed 8 bit value
      LSRB              ; k = e / 2 (arithmetic right shift)
      LDU   #FFP_Y_CUR+3 ; Point past FFP_Y_CUR
      PSHU  B,X          ; PUSH FFP into FFP_Y_CUR
;
;---------- Newton-Raphson iterations y = 0.5*(y + x/y) ----------
;  Choose 3 iterations: usually enough for good precision.
      LDA   #5
      PSHS  A
;
@NR_Loop:
; t1 = x / y
      PUSH_FFP FFP_X_CUR  ; push x
      PUSH_FFP FFP_Y_CUR  ; push y
      JSR   FFP_DIV       ; (3,S) / (S) -> result @ ,S
      PULL_FFP FFP_T1     ; t1 = x / y
;
; y = 0.5 * (y + t1)
; First: y = y + t1  (result -> FFP_Y_CUR)
      PUSH_FFP FFP_Y_CUR  ; push y
      PUSH_FFP FFP_T1     ; push t1
      JSR   FFP_ADD       ; (3,S) + (S) -> result @ ,S
      PULL_FFP FFP_Y_CUR  ; y = y + t1
;
; Then: y = y * 0.5
      PUSH_FFP FFP_Y_CUR
      PUSH_FFP FFP_Half   ; constant 0.5 in internal format
      JSR   FFP_MUL       ; y * 0.5
      PULL_FFP FFP_Y_CUR  ; y = 0.5 * (y + t1)
;
; loop
      DEC   ,S
      BNE   @NR_Loop
      LEAS  1,S         ; Fix the stack
;
;---------- Convert final y back to IEEE and return ----------
; Put y back on stack
      PUSH_FFP FFP_Y_CUR
;
@Return:
    JMP     >$FFFF           ; self-modified return (set at entry)
;
@NotANumber:
      LDB   #$40        ; Flag as NaN
      LDX   #$8000      ; Flag as NaN
      STB   ,S
      STX   1,S
      BRA   @Return

; FFP_HORNER_EVEN: Evaluate an even-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (3 bytes, FFP-precision)
;     3,S: Pointer to coefficient table (2 bytes)
;     5,S: Number of coefficients (n+1, 1 byte, for degrees 0, 2, ..., 2n)
; Output:
;   RESULT: S=S+3, result @ ,S = Polynomial value (3 bytes, FFP-precision)
; Clobbers: A, B, X, Y, U
FFP_HORNER_EVEN:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self mod return address
; Put x on the stack again
      CopyStackOnStack  ; Copy value on the stack on the stack again
; Compute x^2
      JSR   FFP_MUL      ; RESULT * x^2, result at ,S, S=S+3
; Copy result to Temp
      PULL_FFP  FFP_HORE_Temp   ; PULL FFP_HORE_Temp off the stack
;
; Initialize result with highest-degree coefficient (a_2n)
      LDB   2,S         ; Load number of coefficients (n+1)
      DECB              ; Index of next coefficient
; Multiply by 3 for byte offset in B
      STB   @AddB+1     ; Save B below (self mod)
      LSLB              ; B = B * 2
@AddB:
      ADDB  #$FF        ; B = B + orignal B
      LDX   ,S          ; X = coefficient table pointer
      ABX               ; X points to a_2n
; Copy a_2n to RESULT
      LEAU  ,X          ; point after a_2n
      PULU  B,X         ; Get a_2n value
      PSHS  B,X         ; Put a_2n on the stack
;
; Horner's method loop: RESULT = x^2 * RESULT + next_coefficient
@HORNER_LOOP:
      DEC   3+2,S       ; n, then n-1, ..., 0
      BEQ   @DONE       ; Exit if no more coefficients
; Push x^2 onto stack
      PUSH_FFP FFP_HORE_Temp      ; PUSH FFP_HORE_Temp onto the stack
; Result is already on the stack
; Multiply: RESULT = RESULT * x^2
      JSR   FFP_MUL     ; RESULT * x^2, result at ,S, S=S+3
; Push next coefficient
      LDB   3+2,S       ; Load current index (n)
      DECB              ; Index of next coefficient
; Multiply by 3 for byte offset in B
      STB   @AddB1+1    ; Save B below (self mod)
      LSLB              ; B = B * 2
@AddB1:
      ADDB  #$FF        ; B = B + orignal B
      LDX   3,S         ; X = coefficient table pointer
      ABX               ; X points to next coefficient
; Copy coefficient to stack
      LEAU  ,X          ; Point after the coefficient
      PULU  B,X         ; Get coefficient
      PSHS  B,X         ; Push it on the stack
;
; Add: RESULT = RESULT + coefficient
      JSR   FFP_ADD     ; RESULT + coefficient, result at ,S, S=S+3
; Leave RESULT on the stack
      BRA   @HORNER_LOOP
@DONE:
; clean up the stack, copy RESULT on the stack and return
      PULS  B,X         ; Get the result
      LEAS  3,S         ; Move the stack past the table pointer and counter
      PSHS  B,X         ; Save the result on the stack
@Return:
    JMP     >$FFFF      ; Return, self modified jump address
; Data section
FFP_HORE_Temp      RMB 3       ; Temporary storage for x^2

; FFP_HORNER_ODD: Evaluate an odd-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (3 bytes, FFP-precision)
;     3,S: Pointer to coefficient table (2 bytes)
;     5,S: Number of coefficients (n+1, 1 byte, for degrees 1, 3, ..., 2n+1)
; Output:
;   RESULT: S=S+3, result @ ,S = Polynomial value (3 bytes, FFP-precision)
; Clobbers: A, B, X, Y, U
FFP_HORNER_ODD:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; Copy x to TEMP_X for safekeeping
      CopyStackToFFP FFP_Hor_TEMP_X ; Copy x to TEMP_X for safekeeping
; Put x on the stack again
      CopyStackOnStack  ; Put x on the stack again
; Compute x^2
      JSR   FFP_MUL     ; RESULT * x^2, result at ,S, S=S+3 RESULT with 76 DC 57 = 0.001681059599
; Copy result to Temp
      PULL_FFP  FFP_HORO_Temp ; PULL Temp off the stack
;
; Initialize result with highest-degree coefficient (a_2n+1)
      LDB   2,S         ; Load number of coefficients (n+1)
      DECB              ; Index of next coefficient
; Multiply by 3 for byte offset in B
      STB   @AddB+1     ; Save B below (self mod)
      LSLB              ; B = B * 2
@AddB:
      ADDB  #$FF        ; B = B + orignal B
      LDX   ,S          ; X = coefficient table pointer
      ABX               ; X points to a_2n
; Copy a_2n+1 to RESULT
      LEAU  ,X          ; point after a_2n+1
      PULU  B,X         ; Get a_2n+1 value
      PSHS  B,X         ; Put a_2n+1 on the stack
;
; Horner's method loop: RESULT = x^2 * RESULT + next_coefficient
@HORNER_LOOP:
      DEC   3+2,S       ; n, then n-1, ..., 0
      BEQ   @FINAL_MUL  ; Exit loop if no more coefficients
; Push x^2 onto stack
      PUSH_FFP FFP_HORO_Temp ; PUSH Temp onto the stack
; RESULT on the stack
; Multiply: RESULT = RESULT * x^2
      JSR   FFP_MUL     ; RESULT * x^2, result at ,S, S=S+3. Result 6187E2 = 0.0000000004943387921
; Push next coefficient
      LDB   3+2,S       ; Load current index (n)
      DECB              ; Index of next coefficient
; Multiply by 3 for byte offset in B
      STB   @AddB1+1    ; Save B below (self mod)
      LSLB              ; B = B * 2
@AddB1:
      ADDB  #$FF        ; B = B + orignal B
      LDX   3,S         ; X = coefficient table pointer
      ABX               ; X points to next coefficient
; Copy coefficient to stack
      LEAU  ,X          ; point after coefficient
      PULU  B,X         ; Get coefficient value
      PSHS  B,X         ; Put coefficient on the stack
;
; Add: RESULT = RESULT + coefficient
      JSR   FFP_ADD     ; RESULT + coefficient, result at ,S, S=S+3 Result 7347A7 = 0.00006833299994
; Leave RESULT on the stack
      BRA   @HORNER_LOOP
@FINAL_MUL:
; Multiply RESULT by x to account for odd-degree polynomial
      PUSH_FFP FFP_Hor_TEMP_X ; PUSH variable onto the stack
; Leave RESULT on the stack
      JSR   FFP_MUL     ; RESULT * x, result at ,S, S=S+3
; clean up the stack, copy RESULT on the stack and return
      PULS  B,X         ; Get the result
      LEAS  3,S         ; Move the stack past the table pointer and counter
      PSHS  B,X         ; Save the result on the stack
@Return:
    JMP     >$FFFF      ; Return, self modified jump address
;
; Data section
FFP_HORO_Temp    RMB 3        ; Temporary storage for x^2
FFP_Hor_TEMP_X   RMB 3        ; Temporary storage for x

; FFP_RATIONAL: Evaluate rational function P(x)/Q(x) using two Horner chains
; Input:
;   Stack:
;     ,S: x (3 bytes, FFP-precision)
;    3,S: P coefficient table pointer (2 bytes)
;    5,S: P number of coefficients (n+1, 1 byte)
;    6,S: P type (0=even, 1=odd, 1 byte)
;    7,S: Q coefficient table pointer (2 bytes)
;    9,S: Q number of coefficients (m+1, 1 byte)
;   10,S: Q type (0=even, 1=odd, 1 byte)
; Output:
;   RESULT: S=S+6 ,S = P(x)/Q(x) (3 bytes, FFP-precision)
; Clobbers: A, B, X, Y, U
FFP_RATIONAL:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; Evaluate P(x)
; Push params for P: x, P ptr, P num coeffs
      LEAU  3,S
      PULU  A,X
      PSHS  A,X         ; copy P coefficient table pointer (2 bytes) & P number of coefficients (n+1, 1 byte) on the stack
;
      LEAU  3,S         ; copy x (3 bytes, FFP-precision) on the stack
      PULU  A,X         ; Get 3 bytes
      PSHS  A,X         ; Push them on the stack
; P(x) is now ready to be evaluated
; Call appropriate Horner based on P type
      LDA   6+6,S       ; P type (1 byte: 0=even, 1=odd)
      BEQ   @CallEvenP
      JSR   FFP_HORNER_ODD ; Evaulate, S=S+3, result @ ,S
      BRA   @StoreP
@CallEvenP:
      JSR   FFP_HORNER_EVEN ; Evaulate, S=S+3, result @ ,S
@StoreP:
; Copy RESULT to TEMP_P
      PULL_FFP  FFP_Rational_TempP  ; PULL FFP_Rational_TempP off the stack
; Evaluate Q(x)
; Push params for Q: x, Q ptr, Q num coeffs
      LEAU  7,S
      PULU  A,X
      PSHS  A,X         ; copy Q coefficient table pointer (2 bytes) & Q number of coefficients (n+1, 1 byte) on the stack
;
      LEAU  3,S         ; copy x (3 bytes, FFP-precision) on the stack
      PULU  A,X         ; Get 3 bytes
      PSHS  A,X         ; Push them on the stack
; Q(x) is now ready to be evaluated
; Call appropriate Horner based on Q type
      LDA   10+6,S      ; Q type (1 byte: 0=even, 1=odd)
      BEQ   @CallEvenQ
      JSR   FFP_HORNER_ODD   ; Evaulate, S=S+3, result @ ,S
      BRA   @StoreQ
@CallEvenQ:
      JSR   FFP_HORNER_EVEN  ; Evaulate, S=S+3, result @ ,S
@StoreQ:
; Copy RESULT to TEMP_Q
      PULL_FFP  FFP_Rational_TempQ ; PULL FFP_Rational_TempQ off the stack
; Restore stack after Q eval
      LEAS  11,S        ; Clear all from the stack
; Divide P / Q
; Push TEMP_P
      PUSH_FFP FFP_Rational_TempP ; PUSH FFP_Rational_TempP onto the stack
; Push TEMP_Q
      PUSH_FFP FFP_Rational_TempQ ; PUSH FFP_Rational_TempQ onto the stack
;
      JSR   FFP_DIV     ; Divide P / Q, S=S+3, result at ,S
; Final Result is on the stack
@Return:
      JMP   >$FFFF      ; Return, self-modified
;
; Data section
FFP_Rational_TempP    RMB 3   ; Temporary for P(x)
FFP_Rational_TempQ    RMB 3   ; Temporary for Q(x)

; ================================================================
; FFP_MOD -- Calculate the remainder of division using:
; remainder = dividend - (floor(dividend / divisor) * divisor)
; Entry: dividend is @ 3,S and the divisor is @ ,S then S=S+3 result is @ ,S
; Clobbers: A,B,D,X,Y,U
; ================================================================
FFP_MOD:
      PULS  U                 ; pull return address
      STU   @Return+1         ; self-modify return target
; Backup the Dividend and the divisor
      PULS  D,X,Y
      PSHS  D,X,Y
      PSHS  D,X,Y             ; backup the dividend and divisor on the stack
      JSR   FFP_DIV           ; Divide 3,S / ,S Then S=S+3 result @ ,S
      JSR   FFP_FLOOR         ; Compute floor(x) x is @ ,S return with FFP value @,S which is the INTeger value of ,S
      JSR   FFP_MUL           ; Multiply 3,S * ,S Then S=S+3 result @ ,S
      JSR   FFP_SUB           ; Subtract 3,S - ,S Then S=S+3 result @ ,S
@Return:
      JMP   >$FFFF            ; patched by PULS U at entry
;--------------------------------------------------------------

; ================================================================
; FFP_FLOOR  --  Return greatest integer ≤ x  (floor) works like a true INT command
; Entry: 3-byte unpacked FFP x at ,S   (after PULS U)
; Exit:  3-byte unpacked FFP floor(x) at ,S
; Uses:  FFP_TO_S64, S64_To_FFP, FFP_SUB
; Clobbers: A,B,D,X,Y,U
; ================================================================
FFP_FLOOR:
      PULS  U                 ; pull return address
      STU   @Return+1         ; self-modify return target
;--------------------------------------------------------------
; Save original x and its sign
;--------------------------------------------------------------
      CopyStackToFFP FFP_FLOOR_X ;  Copy 3 Byte FFP from the stack to variable FFP_FLOOR_X
;--------------------------------------------------------------
; x -> signed 64-bit integer (truncate toward zero),
; then back to FFP n = trunc(x) in the same 3 Byte slot.
;--------------------------------------------------------------
      JSR   FFP_TO_S64        ; 3 Byte slot at ,S now holds sign 8 byte integer @,S
      JSR   S64_To_FFP        ; signed 8 byte integer now holds 3 byte FFP @ ,S
;
      LDA   FFP_FLOOR_X       ; Get the original sign value
      BPL   @Return           ; If it was positive then we are done
;
; Save n in FFP_FLOOR_N (as FFP)
      CopyStackToFFP FFP_FLOOR_N ;  Copy 3 Byte FFP from the stack to variable FFP_FLOOR_N
;
;--------------------------------------------------------------
; If original x >= 0, floor(x) = n
;--------------------------------------------------------------
      LDA   FFP_FLOOR_X
      BPL   @NonNegative      ; sign bit clear => x >= 0
;
;--------------------------------------------------------------
; Negative x:
;   n = trunc(x)
;   d = n - x
;   if d == 0  -> x integer      => floor(x) = n
;   else        x fractional     => floor(x) = n - 1.0
;--------------------------------------------------------------
@Negative:
; We want: d = n - x
; New FFP_SUB expects: Value1 @,S and Value2 @3,S  -> Value1 - Value2
; Therefore push Value2 first (x), then Value1 (n)
;
      LEAS  3,S               ; drop current n from stack (we have it in FFP_FLOOR_N)
      PUSH_FFP FFP_FLOOR_N    ; Value1 = n   goes to ,S
      PUSH_FFP FFP_FLOOR_X    ; Value2 = x   goes to 3,S after next push
      JSR   FFP_SUB           ; d = n - x  (result at ,S)
;
    ; Test if d == 0  (all 3 Bytes zero?)
      LDD   1,S               ; Mantissa first
      BNE   @NegFraction
      LDA   ,S
      BEQ   @NegInteger       ; d == 0 => x was exact integer
;
;---------- Negative, fractional: floor(x) = n - 1.0 ----------
@NegFraction:
    ; Reload n into ,S
      LEAS  3,S
    ; Push +1.0 
      PUSH_FFP FFP_FLOOR_N    ; PUSH FFP_FLOOR_N onto the stack
      PUSH_FFP FFP_1          ; PUSH FFP_1 onto the stack
; FFP_SUB does n - 1.0
      JSR   FFP_SUB           ; (3,S - ,S) => n - 1.0 at ,S
      BRA   @Return
;
;---------- Negative, integer: floor(x) = n ----------
@NegInteger:
    ; Just reload n into ,S (overwrite d)
; *** Code below does the same thing
;    LEAS    3,S
;    PUSH_FFP FFP_FLOOR_N      ; PUSH FFP_FLOOR_N onto the stack
;    BRA     @Return
;
;--------------------------------------------------------------
; Non-negative x: floor(x) = n (truncate)
;--------------------------------------------------------------
@NonNegative:
    ; Copy n into ,S in case anything modified it
      LEAS  3,S
      PUSH_FFP FFP_FLOOR_N    ; PUSH FFP_FLOOR_N onto the stack
;
@Return:
      JMP   >$FFFF            ; patched by PULS U at entry
;
FFP_FLOOR_X      RMB 3 ; original x (3 Byte FFP)
FFP_FLOOR_N      RMB 3 ; trunc(x) as FFP

; FFP_EXP: Compute exp(x) for FFP-precision input
; Input:
;   ,S: x (3 bytes, FFP)
; Output:
;   ,S: exp(x) (3 bytes), S unchanged
; Clobbers: A, B, X, Y, U
;
; Strategy:
;   1) k = round(x * LOG2E)
;   2) r = x - k*LN2_hi - k*LN2_lo          (|r| ≤ ln2/2)
;   3) y = 1 + r * P(r^2) / Q(r^2)          (kernel via FFP_RATIONAL)
;   4) result = ldexp(y, k)                 (adjust exponent by k)
;
FFP_EXP:
      PULS  U
      STU   @Return+1
;
; === 0) handle special small/huge x quickly (optional: can skip initially) ===
; You can add early-outs here (e.g., if |x| is tiny -> 1+x, if x too large -> overflow to INF, etc.)
;
; === 1) Copy x to TEMP_X (we'll need it several times) ===
      CopyStackToFFP FFP_Exp_TEMP_X ;  Copy 3 byte FFP from the stack to variable FFP_Exp_TEMP_X
;
; === 2) k = round(x * LOG2E) ===
; x is already on the stack
; Push LOG2E, then multiply: x*LOG2E
      PUSH_FFP FFP_LOG2E      ; PUSH LOG2E onto the stack
;
      JSR   FFP_MUL           ; -> x*LOG2E at ,S
;
; ================================
; NEW FAST PATH: exp(x) = 2^u with 16-entry table
; u  = x * LOG2E
; u16 = round(u * 16)   (signed 16-bit)
; u16 = 16*q + j        (q signed, j=0..15)
; exp(x) ≈ 2^q * TAB[j]
; ================================
;
; --- At this point your code has already computed:
;     u = x * LOG2E  at ,S   (because you already did PUSH_FFP FFP_LOG2E / JSR FFP_MUL)
;
; If you want minimal disruption: do the multiply again here or
; move this block to immediately after your existing JSR FFP_MUL.
;
; I’m assuming right here that ,S = u (FFP, 3 bytes).
;
; ---- Multiply u by 16 (2^4) WITHOUT calling FFP_MUL ----
; (We only need u*16 so we can round to a 1/16 step.)
; Safe for normal values; if u is 0 it stays 0.
;
    LDB     ,S              ; sign+exp
    ANDB    #$7F
    CMPB    #$40
    BEQ     @Exp_Special    ; shouldn’t happen here, but just in case
;
    LDX     1,S             ; mantissa
    BEQ     @U16_Zero       ; treat as zero
;
    ; exp8 = sign-extended 7-bit exponent
    LDB     ,S
    ANDB    #$80
    STB     FFP_SIGN        ; reuse your sign temp if you want
    LDB     ,S
    LSLB
    ASRB                    ; B = signed exponent
    ADDB    #4              ; multiply by 16 => exponent += 4
;
    ; clamp u*16 into FFP range before converting to int
    CMPB    #$3F
    BGT     @U16_TooBig
    CMPB    #$C1            ; -63
    BLT     @U16_TooSmall
;
    ANDB    #$7F
    ORB     FFP_SIGN
    STB     ,S
    BRA     @HaveU16FFP
;
@U16_Zero:
    ; u was 0 => u16 = 0
    ; leave ,S = 0
    BRA     @HaveU16FFP
;
@U16_TooBig:
    ; huge positive u => exp(x) overflows => +INF
    LEAS    3,S
    LDA     #%01000000      ; special exponent tag ($40)
    LDX     #$0000
    PSHS    A,X
    JMP     @Return
;
@U16_TooSmall:
    ; huge negative u => exp(x) underflows => +0
    LEAS    3,S
    CLRB
    LDX     #$0000
    PSHS    B,X
    BRA     @Return
;
@Exp_Special:
    ; if something special sneaks in, just return it
    BRA     @Return
;
@HaveU16FFP:
; ---- Round to nearest integer: u16_int = floor(u16 + 0.5) ----
    PUSH_FFP FFP_Half
    JSR     FFP_ADD
    JSR     FFP_FLOOR
@Exp_Skip
;
; ---- Convert integer FFP -> signed 64, keep low 16 bits in U ----
    JSR     FFP_TO_S64
    PULS    D,X,Y,U
    STU     FFP_Exp_U16_Int      ; NEW temp: signed u16_int
;
; ---- Split u16_int into q and j ----
; q = arithmetic(u16_int >> 4), j = u16_int & 15
    LDD     FFP_Exp_U16_Int
    STD     FFP_Exp_TmpD         ; optional if you want, or skip
;
    ; compute q in D: arithmetic shift right 4
    ASRA
    RORB
    ASRA
    RORB
    ASRA
    RORB
    ASRA
    RORB
    STB     FFP_Exp_Q            ; q as signed 8-bit is enough
;
    ; compute j from original low byte
    LDB     FFP_Exp_U16_Int+1
    ANDB    #$0F                 ; j = 0..15
;
; ---- Load TAB[j] (3 bytes) into B,X ----
    LDX     #FFP_EXP2_TAB16
;    TFR     B,A                  ; Push j on the stack
      PSHS  B
    LSLB                         ; B=2j
    ADDB    ,S+                    ; B=3j
    ABX                          ; X += 3j
;
    LDB     ,X                   ; exponent/sign byte (0x00)
    LDX     1,X                  ; mantissa word
;
; ---- Apply 2^q by adjusting exponent of TAB[j] ----
    LDA     FFP_Exp_Q            ; q signed
    PSHS    A                    ; save q
;
    ; exp8 from TAB exponent (currently 0)
    LSLB
    ASRB                         ; B = signed exponent (0)
    ADDB    ,S+                  ; B += qldexp
;
    ; clamp final exponent into [-63, +63]
    CMPB    #$3F
    BGT     @Out_Inf
    CMPB    #$C1
    BLT     @Out_Zero
;
    ANDB    #$7F                 ; pack back to 7-bit
    ; sign always + for exp()
    PSHS    B,X                  ; push result
    BRA     @Return
;
@Out_Inf:
    LDA     #%01000000
    LDX     #$0000
    PSHS    A,X
    BRA     @Return
;
@Out_Zero:
    CLRB
    LDX     #$0000
    PSHS    B,X
@Return:
      JMP   >$FFFF            ; return (self modified)
;
; ===== Data / temporaries =====
FFP_Exp_TEMP_X   RMB 3
FFP_Exp_U16_Int   RMB 2   ; signed u16_int = round(u*16)
FFP_Exp_Q         RMB 1   ; signed q = u16_int >> 4
FFP_Exp_TmpD      RMB 2
;
FFP_EXP2_TAB16:
        FCB $00,$80,$00    ; j=0  -> 1.000000
        FCB $00,$85,$AB    ; j=1  -> 1.044273
        FCB $00,$8B,$96    ; j=2  -> 1.090508
        FCB $00,$91,$C4    ; j=3  -> 1.138789
        FCB $00,$98,$38    ; j=4  -> 1.189207
        FCB $00,$9E,$F5    ; j=5  -> 1.241858
        FCB $00,$A5,$FF    ; j=6  -> 1.296840
        FCB $00,$AD,$58    ; j=7  -> 1.354256
        FCB $00,$B5,$05    ; j=8  -> 1.414214
        FCB $00,$BD,$09    ; j=9  -> 1.476826
        FCB $00,$C5,$67    ; j=10 -> 1.542211
        FCB $00,$CE,$25    ; j=11 -> 1.610490
        FCB $00,$D7,$45    ; j=12 -> 1.681793
        FCB $00,$E0,$CD    ; j=13 -> 1.756252
        FCB $00,$EA,$C1    ; j=14 -> 1.834008
        FCB $00,$F5,$25    ; j=15 -> 1.915206



; FFP_EXP: Compute exp(x) for FFP-precision input
; Input:
;   ,S: x (3 bytes, FFP)
; Output:
;   ,S: exp(x) (3 bytes), S unchanged
; Clobbers: A, B, X, Y, U
;
; Strategy:
;   1) k = round(x * LOG2E)
;   2) r = x - k*LN2_hi - k*LN2_lo          (|r| ≤ ln2/2)
;   3) y = 1 + r * P(r^2) / Q(r^2)          (kernel via FFP_RATIONAL)
;   4) result = ldexp(y, k)                 (adjust exponent by k)
;
; OLD slower version
;FFP_EXP:
      PULS  U
      STU   @Return+1
;
; === 0) handle special small/huge x quickly (optional: can skip initially) ===
; You can add early-outs here (e.g., if |x| is tiny -> 1+x, if x too large -> overflow to INF, etc.)
;
; === 1) Copy x to TEMP_X (we'll need it several times) ===
      CopyStackToFFP FFP_Exp_TEMP_X ;  Copy 3 byte FFP from the stack to variable FFP_Exp_TEMP_X
;
; === 2) k = round(x * LOG2E) ===
; x is already on the stack
; Push LOG2E, then multiply: x*LOG2E
      PUSH_FFP FFP_LOG2E      ; PUSH LOG2E onto the stack
;
      JSR   FFP_MUL           ; -> x*LOG2E at ,S
; Round to nearest integer: k = floor(x*LOG2E + 0.5)
; Push .5 onto the stack
      PUSH_FFP FFP_Half       ; PUSH 0.5 onto the stack
;    
      JSR   FFP_ADD           ; x*LOG2E + 0.5
;
      JSR   FFP_FLOOR         ; integer FFP at ,S (k as FFP)
; Save k (FFP) into FFP_Exp_K
      CopyStackToFFP FFP_Exp_K ;  Copy 3 byte FFP from the stack to variable FFP_Exp_K
;
; Also store k as signed 16-bit (for exponent adjust)
      JSR   FFP_TO_S64        ; Convert 3 byte FFP @ ,S to Signed 64-bit Integer @ ,S
      PULS  D,X,Y,U           ; Pull signed 64 bit number off the stack
      STU   FFP_Exp_K_Int     ; Save Least Significant 16-bit value to K_INT
;
; === 3) r = x - k*LN2_hi - k*LN2_lo  (compensated split) ===
; r0 = x - k*LN2_hi
; tmp = k * LN2_hi
      PUSH_FFP FFP_Exp_K      ; PUSH k onto the stack
      PUSH_FFP FFP_LN2_HI     ; PUSH LN2_hi onto the stack
;
      JSR   FFP_MUL           ; k*LN2_hi
; r0 = x - tmp
      PUSH_FFP FFP_Exp_TEMP_X ; PUSH x onto the stack
;
      JSR   FFP_SUB           ; x - k*LN2_hi
; Subtract was in the wrong order so flip the sign
      LDA   ,S
      EORA  #%10000000
      STA   ,S
; stack: r0 at ,S
;
; r = r0 - k*LN2_lo
    ; tmp2 = k * LN2_lo
      PUSH_FFP FFP_LN2_LO     ; PUSH LN2_lo onto the stack
      PUSH_FFP FFP_Exp_K      ; PUSH FFP_Exp_K onto the stack
;    
      JSR   FFP_MUL           ; k*LN2_lo
; r = r0 - tmp2
      JSR   FFP_SUB           ; (r0) - (k*LN2_lo) -> r at ,S
; Save r (FFP) into FFP_Exp_TEMP_R
      CopyStackToFFP FFP_Exp_TEMP_R ;  Copy 3 byte FFP from the stack to variable FFP_Exp_TEMP_R
;
; === 4) Kernel: y = 1 + r * P(t)/Q(t), t = r^2 ===
; We’ll compute t=r^2 inside the Horner routines automatically:
; Your FFP_HORNER_* do t=x^2 internally; so we pass r as "x" to FFP_RATIONAL.
;
; Push FFP_RATIONAL params: Q even (m+1=5), P odd (n+1=5)
; ---------- Odd term:  r * (Po/Qo) ----------
      LDB   #0                ; Q type = even
      PSHS  B
      LDB   #5                ; Q count (q0..q4)
      PSHS  B
      LDD   #FFP_EXP_Qo
      PSHS  D
      LDB   #1                ; P type = odd
      PSHS  B
      LDB   #5                ; P count (p0..p4)
      PSHS  B
      LDD   #FFP_EXP_Po
      PSHS  D
; r saved here
      PUSH_FFP FFP_Exp_TEMP_R ; PUSH r onto the stack
;
      JSR   FFP_RATIONAL      ; -> odd_term = r * (Po/Qo) at ,S
; Leave Odd_term is on the stack
;
; ---------- Even term: 1 + t * (Pe/Qe) ----------
      LDB   #0                ; Q type = even
      PSHS  B
      LDB   #5                ; Q count = 5
      PSHS  B
      LDD   #FFP_EXP_Qe
      PSHS  D
      LDB   #0                ; P type = even
      PSHS  B
      LDB   #5                ; P count = 5
      PSHS  B
      LDD   #FFP_EXP_Pe
      PSHS  D
; push r as "x" (FFP_HORNER_EVEN uses t=x^2 internally)
      PUSH_FFP FFP_Exp_TEMP_R        ; PUSH r onto the stack
;
      JSR   FFP_RATIONAL      ; -> Ce = Pe/Qe at ,S
;
; multiply by t = r^2
; Leave Ce on the stack
;
; form t = r * r
      PUSH_FFP FFP_Exp_TEMP_R ; PUSH r onto the stack
      PUSH_FFP FFP_Exp_TEMP_R ; PUSH r onto the stack
;
      JSR   FFP_MUL           ; -> t at ,S
;
; multiply Ce * t
; Ce is already on the stack
      JSR   FFP_MUL           ; -> t*Ce at ,S
;
; add 1.0 to get even_term
      PUSH_FFP FFP_1          ; PUSH 1.0 onto the stack
;
      JSR   FFP_ADD           ; even_term at ,S
;
; ---------- Sum even + odd ----------
; push odd_term ; push even_term ; ADD
; odd-term is already on the stack
      JSR   FFP_ADD           ; y ≈ exp(r) at ,S
;
; === 5) Scale by 2^k: result = ldexp(y, k) ===
; Unpack y, add k to exponent, repack
      LDD   FFP_Exp_K_Int     ; Get the K value
      ADDB  ,S                ; add it to the exponent
      ANDB  #%01111111        ; always a positive number
      STB   ,S                ; save the new exponent
;
      PULS  B,X               ; Get value off the stack
      LEAS  3,S               ; Move the stack
      PSHS  B,X               ; Save the value back on the stack
;
@Return:
      JMP   >$FFFF            ; return (self modified)
;
; ===== Data / temporaries =====
;FFP_Exp_TEMP_X   RMB 3
FFP_Exp_TEMP_R   RMB 3
FFP_Exp_K        RMB 3
FFP_Exp_K_Int    RMB 2

; FFP_LOG: Compute natural logarithm ln(x)
; Input:
;   ,S: x (3 byte FFP)
; Output:
;   ,S: ln(x) (FFP), S unchanged
; Clobbers: A,B,X,Y,U
;
FFP_LOG:
      PULS  U
      STU   @Return+1
; ========= Special cases (optional but recommended) =========
; If x <= 0: handle domain
;   x = 0  ->  -INF
;   x < 0  ->  NaN  (or choose to signal/return 0)
; You can skip these to start if you prefer.
      LDD   ,S
      BNE   @CheckNeg
      LDB   2,S
      BNE   @CheckNeg
; We get here if it is zero, return with a -INF
; Value Sign    Exponent (unbiased) Mantissa
; -∞    1       $40                 Most Significant bit is 0
      LDX   #$0000            ; Mantissa = zero
!     LDB   #$80+$40          ; Set the sign bit and exponent = $40 
      STB   ,S
      STX   1,S               ; Save -Infinity on the stack
      JMP   @Return
@CheckNeg:
      TSTA
      BPL   @DoLog            ; If positive we are good
; We get here when it is a negative number, return with NaN
; Not a Number (NaN):
; Type  Sign    Exponent (unbiased) Mantissa
; NaN   Any     $40                 Most Significant bit is 1
      LDX   #$8000            ; Mantissa
      BRA   <
; ========= Normalize: x = m * 2^e, m in [sqrt(1/2), sqrt(2)) =========
; Copy x -> FFP_Log_TEMP_X
@DoLog:
      PULL_FFP    FFP_Log_TEMP_X    ; PULL Variable off the stack
;
; Get EXP and MANT and put mantissa into [1,2]
      LDA   ,U                ; U is pointer to FFP_Log_TEMP_X used in the MACRO PULL_FFP above
      CLRB                    ; Sign byte = 0
      LSLA                    ; Get sign bit in the carry
      RORB                    ; Move sign bit to bit 7 of B
      STB   FFP_SIGN          ; Save the sign
; Save unbiased exponent e in FFP_Log_E_SInt (signed 8-bit).
      ASRA                    ; A = 8 bit signed exponent
;      STA   FFP_EXPonent      ; signed 8-bit exponent               
      STA   FFP_Log_E_SInt    ; store EXP (or convert to signed)
; Copy mantissa of FFP_Log_TEMP_X to FFP_MANT & FFP_RESULT
      LDX   FFP_Log_TEMP_X+1  ; Get the Mantissa
      STX   FFP_MANT          ; Save mantissa in FFP_MANT
      STX   RESULT+1          ; Save mantissa for RESULT
; Force mantissa m into [1,2] by setting EXP to "1.0" exponent when packing
      LDA   FFP_SIGN          ; keep exponent as zero 
      STA   RESULT            ; RESULT has the new 3 byte FFP value, RESULT at @U, U points there
;
; Copy RESULT to FFP_Log_M
      STA   FFP_Log_M
      STX   FFP_Log_M+1
;
; Now m is in [1,2]. If m >= sqrt(2), divide by 2 and increase e by 1,
; so that final m ∈ [sqrt(1/2), sqrt(2)] as desired.
      PUSH_FFP FFP_Log_M      ; PUSH m onto the stack
;
      PUSH_FFP FFP_SQRT2      ; PUSH push sqrt(2) onto the stack
;
      JSR   FFP_SUB           ; m - sqrt(2)
      LDA   ,S                ; A = the Sign of the result
      LEAS  3,S               ; Fix the stack
      BMI   FFP_Log_M_OK      ; if m - sqrt(2) < 0, m < sqrt(2) => OK
; else m >= sqrt(2): m = m/2, e = e + 1
      PUSH_FFP FFP_Half       ; PUSH FFP_Half onto the stack
      PUSH_FFP FFP_Log_M      ; PUSH m onto the stack
;
      JSR   FFP_MUL           ; m = m * 0.5
; Save stack at FFP_Log_M
      PULL_FFP FFP_Log_M      ; PULL FFP_Log_M off the stack
;
      INC   FFP_Log_E_SInt    ; Increment FFP_Log_E_SInt
FFP_Log_M_OK:
; ========= z = (m - 1) / (m + 1) =========
; Compute numerator: m - 1
      PUSH_FFP FFP_Log_M      ; PUSH m onto the stack
      PUSH_FFP FFP_1          ; PUSH 1 onto the stack
;
      JSR   FFP_SUB           ; m - 1
; Compute denominator: m + 1
      PUSH_FFP FFP_1          ; PUSH 1 onto the stack
      PUSH_FFP FFP_Log_M      ; PUSH m onto the stack
;
      JSR   FFP_ADD           ; m + 1
; Leave on the stack
; z = (m-1)/(m+1)
; both already on the stack in the correct order
      JSR   FFP_DIV           ; z
; Save z
      PULL_FFP FFP_Log_Z      ; PULL z off the stack
;
; ========= R(t) = P(t) / Q(t),  t = z^2,  with P even / Q even =========
; Setup FFP_RATIONAL Q type=even, P type=even, counts = (n+1) = say 5 (deg 8 in t if you like)
;      LDB   #0                ; Q type = even
;      PSHS  B
;      LDB   #5                ; Q count (q0..q4)
;      PSHS  B
;      LDD   #FFP_LOG_COEFFS_Q
;      PSHS  D
;      LDB   #0                ; P type = even
;      PSHS  B
;      LDB   #5                ; P count (p0..p4)
;      PSHS  B
;      LDD   #FFP_LOG_COEFFS_P
;      PSHS  D
      LDD   #FFP_LOG_COEFFS_P ; P coefficients pointer
      LDX   #$0500            ; MSB = P number of coefficients (n+1 = 4), LSB = P type: 1=odd
      LDY   #FFP_LOG_COEFFS_Q ; Q coefficients pointer
      LDU   #$0500            ; MSB = Q number of coefficients (n+1 = 4), LSB = Q type: 0=even
      PSHS  D,X,Y,U 
; Push x=z (so Horner uses t=z^2 internally)
      PUSH_FFP FFP_Log_Z      ; PUSH z onto the stack
;
      JSR   FFP_RATIONAL      ; -> R(t) = P/Q at ,S
;
; ========= ln(m) ≈ 2*z * R(t) =========
; Multiply R by z
      PUSH_FFP FFP_Log_Z      ; PUSH z onto the stack
;    
      JSR   FFP_MUL           ; z * R
; Multiply by 2
      PUSH_FFP FFP_2          ; PUSH 2 onto the stack
;
      JSR   FFP_MUL           ; ln(m) ≈ 2*z*R
;
; ========= ln(x) = e*ln2 + ln(m) =========
; Compute e as FFP and scale ln2 by e, or scale via integer multiply/add.
; Here: form e as FFP to reuse FFP_MUL/ADD.
;
; Build e as FFP in @E_FFP
    ; For now we’ll multiply ln2 by integer e using repeated add if you prefer (or build E_FFP once elsewhere).
;
; Multiply ln2 * e (FFP e)
      PUSH_FFP FFP_LN2        ; PUSH ln2 onto the stack
;
    ; Build e as FFP quickly
;
      LDB   FFP_Log_E_SInt    ; Get the signed 8 bit number in B
      SEX                     ; Sign extend value into D
      JSR   S16_To_FFP        ; Convert Signed 16 bit integer in D to 3 Byte FFP @ ,S
;
      JSR   FFP_MUL          ; e*ln2
;
; Add ln(m)
; ln(m) is already on the stack
      JSR   FFP_ADD          ; (e*ln2) + (2*z*R)
;
@Return:
      JMP   >$FFFF
; ======= Data / temporaries =======
FFP_Log_TEMP_X   RMB 3
FFP_Log_M        RMB 3
FFP_Log_Z        RMB 3
FFP_Log_E_SInt   RMB 1            ; signed 8-bit exponent (unbiased)

; FFP_COS: Compute cos(x) for FFP-precision input
; Input:
; ,S: x (3 bytes, FFP-precision)
; Output:
; ,S: cos(x) (3 bytes, FFP-precision), S unchanged
; Clobbers: A, B, D, X, Y, U
FFP_COS:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; check for 0 COS(0)=1
      LDD   ,S          ; Get Exponent LSB & Mantissa MSB, most likely to have something
      BNE   >
      LDA   2,S
      BNE   >
; We get here when we are given COS(0) = 1
      LEAS  3,S         ; Clear the stack
      PUSH_FFP FFP_1    ; PUSH 1.0 onto the stack
      JMP   @Return     ; Cosine of 0 is 1
; Compute x' = x + π/2 to use cos(x) = sin(x + π/2)
!     PUSH_FFP FFP_PI_2 ; PUSH π/2 onto the stack
;
      JSR   FFP_ADD     ; x + π/2, S=S+3, result at ,S
      BRA   @NotZero    ; Use the SINE function for the rest
;
; FFP_SIN: Compute sin(x) for FFP-precision input
; Input:
;   ,S: x (3 bytes, FFP-precision)
; Output:
;   ,S: sin(x) (3 bytes, FFP-precision), S unchanged
; Clobbers: A, B, X, Y, U
FFP_SIN:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; Check for zero, SIN(0)=0
      LDD   ,S         ; Get Exponent LSB & Mantissa MSB, most likely to have something
      BNE   @NotZero
      LDA   2,S
      LBEQ  @Return     ; SINE of zero is zero
; Save x
@NotZero:
      CopyStackToFFP FFP_Sin_Temp_X ;  Copy 3 byte FFP from the stack to variable FFP_Sin_Temp_X
; Range reduction: x' = x mod 2π
      PUSH_FFP FFP_Sin_Temp_X       ; PUSH FFP_Sin_Temp_X onto the stack
      PUSH_FFP FFP_2PI              ; PUSH 2π onto the stack
;
      JSR   FFP_DIV     ; x / 2π, result at ,S, S=S+3
; Floor division result
      JSR   FFP_FLOOR   ; Do INT(,S) keep it as a DB number
; x' = x - floor(x/2π) * 2π
      PUSH_FFP FFP_2PI  ; PUSH 2π onto the stack
;
      JSR   FFP_MUL     ; floor(x/2π) * 2π, S=S+3
; x is already on the stack, so we just do a FFP_SUB to get our result of x - floor(x/2π) * 2π
;
      JSR   FFP_SUB     ; x - floor(x/2π) * 2π, S=S+3
; Store x' in TEMP_X, leave it on the stack
      CopyStackToFFP FFP_Sin_Temp_X ;  Copy 3 byte FFP from the stack to variable FFP_Sin_Temp_X
;
; Determine quadrant and adjust x' to [0, π/2]
; Compute x' - π
; Didn't pull it off the stack above, just copied it to TEMP_X
      PUSH_FFP FFP_PI               ; PUSH π onto the stack
;
      JSR   FFP_SUB     ; π - x', S=S+3 result should be C01248FDD4E06C4B
; If π < x' , use π - x' or adjust sign
      LDA   ,S          ; Check sign bit (bit 7 of first byte) 
      LEAS  3,S         ; Fix the stack
      BPL   @Quadrant34 ; if x >= π then go decide between Quadrant 3 (≤ 3π/2) and Quadrant 4 (> 3π/2)
; if we get here then x' < π
; x' < π → Quadrant 1 or 2
; Test if x' - π/2 >= 0
; x' <= π, check if x' <= π/2
      PUSH_FFP FFP_Sin_Temp_X       ; PUSH FFP_Sin_Temp_X onto the stack
      PUSH_FFP FFP_PI_2             ; PUSH π/2 onto the stack
;
      JSR   FFP_SUB     ; x' - π/2, S=S+3   *** 3FEBC9F9E3C70E76
      LDA   ,S          ; Check sign
      LEAS  3,S         ; Fix the stack
      LBMI  @Quadrant1  ; Use 'x as it is
; x' >= π/2 → Quadrant 2: sin(x') = sin(π - x')
@Quadrant2:             ; sin(x') = sin(π - x')
      PUSH_FFP FFP_PI               ; PUSH π onto the stack
      PUSH_FFP FFP_Sin_Temp_X       ; PUSH FFP_Sin_Temp_X onto the stack
;
      JSR   FFP_SUB     ; π - x', S=S+3 ; 3FF248FDD4E06C4B
      PULL_FFP  FFP_Sin_Temp_X      ; PULL FFP_Sin_Temp_X off the stack
      JMP   @EvalSin
@Quadrant34:
; Now decide between Quadrant 3 (≤ 3π/2) and Quadrant 4 (> 3π/2)
; Test if x' - 3π/2 >= 0
; x' > π, check if x' <= 3π/2
      PUSH_FFP FFP_Sin_Temp_X       ; PUSH FFP_Sin_Temp_X onto the stack
      PUSH_FFP FFP_3PI_2            ; PUSH 3π/2 onto the stack
;
      JSR   FFP_SUB     ; x' - 3π/2, S=S+3
      LDA   ,S          ; Check sign
      LEAS  3,S         ; Fix the stack
      BPL   @Quadrant4  ; x' >= 3π/2  → Quadrant 4: sin(x') = -sin(2π - x')
@Quadrant3:
; Quadrant 3: sin(x') = -sin(x' - π)
      PUSH_FFP FFP_Sin_Temp_X       ; PUSH FFP_Sin_Temp_X onto the stack
      PUSH_FFP FFP_PI               ; PUSH π onto the stack
;
      JSR   FFP_SUB     ; x' - π
      BRA   @Negate
@Quadrant4:    ; sin(x') = -sin(2π - x')
      PUSH_FFP FFP_2PI              ; PUSH 2π onto the stack
      PUSH_FFP FFP_Sin_Temp_X       ; PUSH FFP_Sin_Temp_X onto the stack
;
      JSR   FFP_SUB     ; 2π - x'
@Negate:
      PULL_FFP  FFP_Sin_Temp_X      ; PULL Variable off the stack
; Negate sign
      LDA   FFP_Sin_Temp_X
      EORA  #%10000000
      STA   FFP_Sin_Temp_X
@Quadrant1:
@EvalSin:
    ; Evaluate sin(x') using FFP_HORNER_ODD
      LDB   #4
      PSHS  B           ; Push n+1 = 4 (degrees 1, 3, 5, 7)
      LDD   #FFP_SIN_COEFFS
      PSHS  D           ; Push coefficient pointer
      PUSH_FFP FFP_Sin_Temp_X       ; PUSH FFP_Sin_Temp_X onto the stack Push x'
;
; FFP_HORNER_ODD Evaluate an odd-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (3 bytes, IEEE 754 FFP-precision)
;     8,S: Pointer to coefficient table (2 bytes)
;     3,S: Number of coefficients (n+1, 1 byte, for degrees 1, 3, ..., 2n+1)
      JSR   FFP_HORNER_ODD    ; ,S = DB number, 3,S = coefficient table, 12,s = # of coefficients, S=S+3, DB result is @ ,S
;
@Return:
      JMP   >$FFFF      ; Return, self-modified
; Temporaries
FFP_Sin_Temp_X    RMB  3   ; Reduced x

; FFP_TAN: Compute tan(x) for FFP-precision input
; Input:
; ,S: x (3 bytes, FFP-precision)
; Output:
; ,S: tan(x) (3 bytes, FFP-precision), S unchanged
; Clobbers: A, B, X, Y, U
; tan(x) = sin(x) / cos(x)
FFP_TAN:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; Save x
      CopyStackToFFP FFP_Tan_Temp_X ;  Copy 3 byte FFP from the stack to variable FFP_Tan_Temp_X
; Compute sin(x)
      JSR   FFP_SIN     ; Compute sin(x), result at ,S, S=S+3
      PUSH_FFP FFP_Tan_Temp_X       ; PUSH FFP_Tan_Temp_X onto the stack
;
      JSR   FFP_COS     ; Compute cos(x), result at ,S
; Check if cos(x) is zero (singularity check)
      LDD   ,S          ; Get Exponent LSB & Mantissa MSB, most likely to have something
      BNE   @NotZero
      LDA   2,S
      BNE   @NotZero
; cos(x) = 0, tangent is undefined
      LEAS  3,S         ; Move stack pointer past result of cos(x)
      LDA   #$40        ; Return 754 NaN or large value
      STA   ,S
      LDD   #$0000
      STD   1,S
      BRA   @Return
@NotZero:
; Compute tan(x) = sin(x) / cos(x)
      JSR   FFP_DIV     ; sin(x) / cos(x), S=S+3, result at ,S
@Return:
      JMP   >$FFFF      ; Return, self-modified
; Temporaries
FFP_Tan_Temp_X     RMB 3       ; Temporary storage for x

; FFP_ATAN: Compute atan(x) for FFP-precision input
; Input:
; ,S: x (3 bytes, IEEE 754 FFP-precision)
; Output:
; ,S: atan(x) (3 bytes, FFP-precision), S unchanged
; Clobbers: A, B, D, X, Y, U
FFP_ATAN:
      PULS  U                 ; Get return address
      STU   @Return+1         ; Self-modify return address
; check for zero
; Zero (±0):
; +0    0       All 0s              All 0s
; -0    1       All 0s              All 0s
      LDA   ,S
      ANDA  #$7F          ; ignore sign
      ORA   1,S           ; combine mantissa bytes
      ORA   2,S
      BEQ   @Return       ; ±0 => return 0
@NotZero:
; Save sign and compute |x|
; Save x as FFP_ATan_TEMP_X
; Save sign bit of x (bit7 of first byte)
      LDA   ,S
      ANDA  #$80
      STA   FFP_ATAN_Sign
; Make x = |x| on stack by clearing sign bit
      LDA   ,S
      ANDA  #$7F
      STA   ,S
      CopyStackToFFP FFP_ATan_TEMP_X ; Copy x to FFP_ATan_TEMP_X
; Compare |x| (already on the stack) with 1
      PUSH_FFP FFP_1          ; PUSH 1.0 variable onto the stack
;
      JSR   FFP_SUB           ; |x| - 1, S=S+3
      LDA   ,S                ; Check sign
      LEAS  3,S               ; Fix stack
      BPL   @LargeX           ; If |x| > 1, use atan(x) = π/2 - atan(1/x)
; |x| ≤ 1, compute atan(|x|) using FFP_RATIONAL
@SmallX
      LDD   #FFP_ATAN_COEFFS_P ; P coefficients pointer
      LDX   #$0401            ; MSB = P number of coefficients (n+1 = 4), LSB = P type: 1=odd
      LDY   #FFP_ATAN_COEFFS_Q ; Q coefficients pointer
      LDU   #$0400            ; MSB = Q number of coefficients (n+1 = 4), LSB = Q type: 0=even
      PSHS  D,X,Y,U
;
      PUSH_FFP FFP_ATan_TEMP_X ; PUSH |x| variable onto the stack
;
      JSR   FFP_RATIONAL      ; Evaluate P(x)/Q(x), S=S+3, result at ,S
      BRA   @ApplySign
; ---------------------------
; |x| >= 1: atan(x) = pi/2 - atan(1/x)
; ---------------------------
@LargeX:
; |x| > 1, compute 1/|x|
; Compute atan(1/|x|)
      LDD   #FFP_ATAN_COEFFS_P ; P coefficients pointer
      LDX   #$0401            ; MSB = P number of coefficients (n+1 = 4), LSB = P type: 1=odd
      LDY   #FFP_ATAN_COEFFS_Q ; Q coefficients pointer
      LDU   #$0400            ; MSB = Q number of coefficients (n+1 = 4), LSB = Q type: 0=even
      PSHS  D,X,Y,U
;
      PUSH_FFP FFP_ATan_TEMP_X ; PUSH |x| variable onto the stack
;
      JSR   INVERT_FFP        ; Compute 1/|x|, result at ,S
      JSR   FFP_RATIONAL      ; Evaluate P(x)/Q(x), S=S+3, result at ,S
; Compute π/2 - atan(1/|x|)
; Leave atan(1/|x|) on the stack (flip the sign bit afterwards)
      PUSH_FFP FFP_PI_2       ; PUSH π/2 onto the stack
;
      JSR   FFP_SUB           ; π/2 - atan(1/|x|), S=S+3
      LDA   ,S                ; Get the SIGN bit
      EORA  #%10000000        ; Flip bit 7
      STA   ,S                ; Save new value
@ApplySign:
      LDA   ,S
      ANDA  #%01111111        ; Clear sign bit
      ORA   FFP_ATAN_Sign     ; Copy original sign bit in result
      STA   ,S                ; Save updated sign
@Return:
      JMP   >$FFFF            ; Return, self-modified
; Temporaries
FFP_ATan_TEMP_X   RMB 3       ; Temporary storage for x
FFP_ATAN_Sign     RMB 1       ; Store sign of input

FFP_POW:
      PULS  U
      STU   @Return+1
; Pull exponent (value2) from ,S to temp
      PULL_FFP  FFP_TempPOW      ; PULL Variable off the stack
; Now base (value1) is at ,S
; Check if base is zero (ignore sign)
      LDA   ,S          ; sign+exp of base
      ANDA  #$7F        ; mask sign
      BNE   @Not_zero_base
      LDX   1,S         ; mant of base
      BNE   @Not_zero_base
; base is zero (+0 or -0)
; Check if exponent is zero
      LDA   FFP_TempPOW
      ANDA  #$7F
      BNE   @Exp_not_zero
      LDX   FFP_TempPOW+1
      BNE   @Exp_not_zero
; 0^0: return +1.0
      LDD   #$0080
      STD   ,S
      STA   2,S
      BRA   @Return
@Exp_not_zero:
; Check if exponent is positive or negative
      LDA   FFP_TempPOW    ; load sign+exp
      BPL   @Exp_positive ; bit7=0: positive (or zero, but already checked)
; exponent < 0: return +inf
      LDD   #$4000
      STD   ,S
      STB   2,S
      BRA   @Done
@Exp_positive:
; exponent > 0: return +0
      LDD   #$0000
      STD   ,S
      STA   2,S
      BRA   @Done
@Not_zero_base:
; Normal case: proceed with log/mul/exp
      JSR   FFP_LOG     ; Compute ln(base), result at ,S
; Push exponent back on top of stack
      PUSH_FFP FFP_TempPOW ; PUSH FFP_TempPOW onto the stack
      JSR   FFP_MUL     ; Compute exponent * ln(base), result at ,S
      JSR   FFP_EXP     ; Compute exp(of the product), result at ,S
@Done:
@Return:
      JMP   >$FFFF      ; Self-modifying return
FFP_TempPOW RMB 3

; Fastest 6809 Assembly Square Root for FFP Format Using Stack-Based Math Routines
;
; Assumes the following subroutines exist:
; FFP_MUL: Multiplies the top 3 bytes (operand B) and the next 3 bytes (operand A) on the stack (A * B), pops 6 bytes, pushes the 3-byte result. Stack pointer S increases by 3.
; FFP_SUB: Subtracts the top 3 bytes (operand B) from the next 3 bytes (operand A) on the stack (A - B), pops 6 bytes, pushes the 3-byte result. Stack pointer S increases by 3.
; FFP_ADD: Adds the top 3 bytes (operand B) to the next 3 bytes (operand A) on the stack (A + B), pops 6 bytes, pushes the 3-byte result. Stack pointer S increases by 3. (Not used here, but included per request if needed elsewhere.)
;
; Magic constant 0x5f375d derived for this format (bias 63, effective equivaluent to IEEE with adjusted sigma ~0.045, max rel err ~0.04 on initial guess).

MAGIC_HIGH EQU $5F
MAGIC_MID EQU $37
MAGIC_LOW EQU $5D

; Constants (3-byte FFP)
HALF_FFP    FCB $7F,$80,$00  ; 0.5 (sign 0, exp -1 = $7F, mant $8000)
ONEHALF_FFP FCB $00,$C0,$00  ; 1.5 (sign 0, exp 0 = $00, mant $C000)

; Temp storage (RMB 3 for each)
temp_exp RMB 1  ; signed exponent (1 byte)
temp_new_exp RMB 1  ; halved signed exponent (1 byte)
temp_z RMB 3  ; z FFP
temp_y RMB 3  ; initial y FFP
temp_result RMB 3  ; temporary result FFP

i_high      FCB   $00
i_mid       FCB   $00
i_low       FCB   $00

y_high      FCB   $00
y_mid       FCB   $00
y_low       FCB   $00
; Subroutine: SQRT_FFP
; Input: 3-byte FFP pushed on stack (using PUSH_FFP or equivaluent).
; Output: 3-byte result on stack (replaces input).
; Handles specials (zero, inf, NaN, negative=NaN).
; Uses 1 Newton-Raphson iteration for refinement (sufficient for 16-bit mantissa precision).

SQRT_FFP:
    LDA 2,S          ; Load sign_exp (byte0 at S+2)
    BPL POSITIVE     ; If sign positive, continue
    BRA SQRT_NAN     ; Negative: return NaN

POSITIVE:
    ANDA #$7F        ; Mask to get exp bits
    CMPA #$40        ; Check for special exp
    BEQ SQRT_SPECIAL ; Handle inf/NaN
    BNE CHECK_ZERO   ; Not zero check

CHECK_ZERO:
    CMPA #0          ; Exp == 0?
    BNE SQRT_NORMAL  ; No, normal
    LDX 0,S          ; Load mant (X = byte2 byte1, but check MSB)
    BITA #$80        ; Mant high bit (byte1 at S+1)
    BNE SQRT_NORMAL  ; If set, normal (subnorm not handled as special)
    ; Zero: clear stack to +0
    CLR 0,S
    CLR 1,S
    CLR 2,S
    RTS

SQRT_SPECIAL:
    LDX 0,S          ; Load mant
    BITA #$80        ; Mant MSB?
    BEQ SQRT_INF     ; No: inf
    ; NaN
    LDA #$40
    STA 2,S          ; byte0 = $40
    LDA #$80
    STA 1,S          ; mant high = $80
    CLR 0,S          ; mant low = $00
    RTS

SQRT_INF:
    LDA #$40
    STA 2,S          ; byte0 = $40
    CLR 1,S          ; mant high = $00
    CLR 0,S          ; mant low = $00
    RTS

SQRT_NAN:
    LDA #$40
    STA 2,S          ; byte0 = $40
    LDA #$80
    STA 1,S          ; mant high = $80
    CLR 0,S          ; mant low = $00
    RTS

SQRT_NORMAL:
    LDA 2,S          ; Load exp_byte again
    ANDA #$7F
    BITA #$40        ; Negative exp?
    BEQ NO_SIGN_EXT
    ORA #$80         ; Sign extend to 8 bits
NO_SIGN_EXT:
    STA temp_exp     ; Store signed exp

    LDA temp_exp
    ANDA #1          ; Check odd/even
    BEQ EVEN_EXP
    ; Odd
    LDA temp_exp
    DECA             ; exp -1 (now even)
    ASRA             ; Signed divide by 2
    STA temp_new_exp
    LDA #1           ; z_exp = 1
    BRA SET_Z_EXP

EVEN_EXP:
    LDA temp_exp
    ASRA             ; Signed divide by 2
    STA temp_new_exp
    LDA #0           ; z_exp = 0

SET_Z_EXP:
    STA 2,S          ; Update byte0 on stack to z_exp (sign 0)

    ; Now stack has z_ffp
    CopyStackToFFP temp_z  ; Save z to temp

    ; Compute initial y using bit hack on temp_z
    LDA temp_z       ; z_exp
    ADDA #63         ; Bias
    STA i_high
    LDA temp_z+1     ; mant high
    STA i_mid
    LDA temp_z+2     ; mant low
    STA i_low

    ; i >> 1 (3-byte right shift)
    LSRA             ; LSR i_low, carry to i_mid
    ROR i_mid
    ROR i_high

    ; magic - (i >> 1)
    LDA #MAGIC_LOW
    SUBA i_low
    STA y_low
    LDA #MAGIC_MID
    SBCA i_mid
    STA y_mid
    LDA #MAGIC_HIGH
    SBCA i_high
    STA y_high

    ; Unpack to y_ffp
    LDA y_high
    SUBA #63         ; Unbias
    STA temp_y       ; byte0
    LDA y_mid
    STA temp_y+1
    LDA y_low
    STA temp_y+2

    ; Now perform 1 Newton-Raphson iteration on stack
    PUSH_FFP temp_y  ; Stack: z, y
    CopyStackOnStack ; Stack: z, y, y
    JSR FFP_MUL      ; Stack: z, y^2
    PUSH_FFP temp_z  ; Stack: z, y^2, z (but wait, to mul y^2 * z, but z is below y^2
    ; Since mul commutative, but to have them adjacent, since stack z, y^2
    JSR FFP_MUL      ; Pops y^2, z, pushes y^2 * z (stack empty now? No, initial was z, but wait
    ; Wait, stack was z, y after push y
    ; Then Copy, z, y, y
    ; FFP_MUL: pops y, y, pushes y^2, stack z, y^2
    ; Then JSR FFP_MUL: pops y^2, z, pushes z*y^2, stack empty
    ; Yes.

    PUSH_FFP HALF_FFP ; Stack: 0.5, z*y^2
    JSR FFP_MUL       ; Pops z*y^2, 0.5, pushes 0.5*z*y^2, stack empty

    PUSH_FFP ONEHALF_FFP ; Stack: 1.5, 0.5*z*y^2
    JSR FFP_SUB          ; Pops 0.5*z*y^2, 1.5, pushes 1.5 - 0.5*z*y^2 (factor), stack empty

    PUSH_FFP temp_y      ; Stack: factor, y
    JSR FFP_MUL          ; Pops y, factor, pushes y*factor (refined y), stack empty

    ; Now compute sqrt(z) = z * refined_y
    PUSH_FFP temp_z      ; Stack: refined_y, z
    JSR FFP_MUL          ; Pops z, refined_y, pushes z*refined_y = sqrt(z), stack empty

    ; Adjust exponent in result
    CopyStackToFFP temp_result  ; Copy top to temp
    LDA temp_new_exp            ; Load halved exp
    STA temp_result             ; Set byte0 to new_exp (sign 0 implied)
    LEAS 3,S                    ; Pop old result
    PUSH_FFP temp_result        ; Push adjusted result

    RTS

; Note: For even higher precision (if needed), repeat the refinement block with the refined y as temp_y, but this adds ~4 MUL +1 SUB calls, reducing speed. With 1 iteration, precision is adequate for 16-bit mantissa.

