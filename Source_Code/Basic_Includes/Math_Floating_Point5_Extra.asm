; Floating Point 5 byte version - Extra commands
; Requires Math_Fast_Floating_Point.asm
; Which includes routines for:

; Math functions included in this library:
; FP5_SUB         ; Subtract, do 5,S - ,S Then S=S+5 result @ ,S
; FP5_ADD   	; Add 5,S + ,S Then S=S+5 result @ ,S
; FP5_MUL         ; Multiply 5,S * ,S Then S=S+5 result @ ,S
; FP5_DIV         ; Divide 5,S / ,S Then S=S+5 result @ ,S
;
; Conversion routines:
; FP5_TO_S64      ; Convert 5 Byte FP5 @ ,S to Signed 64-bit Integer @ ,S
; FP5_TO_U64      ; Convert 5 Byte FP5 @ ,S to Unsigned 64-bit Integer @ ,S
; FP5_TO_S32      ; Convert 5 Byte FP5 at ,S to 32-bit Signed integer at ,S
; FP5_TO_U32      ; Convert 5 Byte FP5 at ,S to 32-bit Unsigned integer at ,S
; FP5_TO_S16      ; Convert 5 Byte FP5 at ,S to 16-bit Signed integer at ,S
; FP5_TO_U16      ; Convert 5 Byte FP5 at ,S to 16-bit Unsigned integer at ,S
; S64_To_FP5      ; Convert Signed 64 bit integer @,S to 5 Byte FP5 @ ,S
; U64_To_FP5      ; Convert Unsigned 64 bit integer @,S to 5 Byte FP5 @ ,S
; S32_To_FP5      ; Convert Signed 32 bit integer @,S to 5 Byte FP5 @ ,S
; U32_To_FP5      ; Convert Unsigned 32 bit integer @,S to 5 Byte FP5 @ ,S
; S16_To_FP5      ; Convert Signed 16 bit integer in D to 5 Byte FP5 @ ,S
; U16_To_FP5      ; Convert Unsigned 16 bit integer in D to 5 Byte FP5 @ ,S
;
; Helper routines:
; FP5_CMP_Stack   ; Compare FP5 Value1 @ 5,S with Value2 @ ,S sets the 6809 flags Z, N, and C
; Print_FP5       ; Print FP5 value @,S
; FP5_TO_DECSTR   ; Replaces FP5 # on the stack with a decimal ASCII string version where: ,S=len, 1,S=' ' or '-', 2,S..digits
; NumericString_To_FP5 ; Convert numeric ASCII string on stack to 5-byte FP5
;
; RandomFP5_Zero  ; Generate a random number @,S in the range of > 0 and < 1
; RandomFP5       ; Gets a random number where random # is 1 to X where X is the FP5 value on the stack, then S=S+5 result @,S
;
; FP5_Round_U ; Round 40 bit value at U down to 32 bits and bump FP5_EXPonent if needed
;
; Shifting routines:
; FP5_Shift_Right32_AtU_B  ; Shift the 32-bit number at U Right by B bits, U is unchanged
;
; FP5_Shift_Right64_AtU_B  ; Right-shift 64-bit value at U by B bits (B >= 0)
; FP5_Shift_Left64_AtU_B   ; Left-shift 64-bit value at U by B bits (B >= 0)

; New Advanced routines in this library are:
;*INVERT_FP5         ; Do 1/x where x is at ,S (value to invert), Result: 1/x at ,S
;*FP5_SQRT           ; Compute Square Root of a FP5 number @ ,S result @ ,S
;*FP5_MOD            ; Compute the remainder of division using dividend is @ 3,S and the divisor is @ ,S then S=S+3 result is @ ,S
;*FP5_FLOOR          ; Compute floor(x) x is @ ,S return with FP5 value @,S which is the INTeger value of ,S
;*FP5_EXP            ; Compute exponential number, exp(x), x is @,S result @ ,S
;*FP5_LOG            ; Compute natural logarithm ln(x), x is @,S result @ ,S
;*FP5_HORNER_EVEN    ; Evaluate an even-degree polynomial using Horner's method, result @ ,S
;*FP5_HORNER_ODD     ; Evaluate an odd-degree polynomial using Horner's method, result @ ,S
;*FP5_RATIONAL       ; Evaluate rational function P(x)/Q(x) using two Horner chains
;*FP5_SIN            ; Compute sine, sin(x), x is @,S result @ ,S
;*FP5_COS            ; Compute cosine, cos(x), x is @,S result @ ,S
;*FP5_TAN            ; Compute tangent, tan(x), x is @,S result @ ,S
;*FP5_ATAN           ; Compute arctangent, atn(x), x is @,S result @ ,S
;FP5_POW            ; Compute Power 5,S ^ ,S Then S=S+5 result @ ,S

; 5 byte Floating Point (FP5) format
; SEEEEEEE|MMMMMMMM|MMMMMMMM|MMMMMMMM|MMMMMMMM
; # of bits Function
;  (1 bit)       Sign - sign (0=+, 1=-)
;  (7 bits)  Exponent - signed 7 bit value (not biased)
;  (32 bits) Mantissa - 32 bits (Includes explicit Most significant bit)
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
FP5_ZERO    FCB $00,$00,$00,$00,$00 ; 0.0

FP5_Half    FCB $7F,$80,$00,$00,$00 ; 0.5
FP5_Two     FCB $01,$80,$00,$00,$00 ; 2

; ===== SIN_COEFFS (order preserved!) =====
FP5_SIN_COEFFS
FP5_1       FCB $00,$80,$00,$00,$00 ; 1.0
            FCB $FD,$AA,$AA,$AA,$AB ; -1/6 ≈ -0.166666666666667
            FCB $79,$88,$88,$88,$89 ; 1/120 ≈ 0.00833333333333333
            FCB $F3,$D0,$0D,$00,$D0 ; -1/5040 ≈ -0.000198412698412698

FP5_OnePointFive FCB $00,$C0,$00,$00,$00 ; 1.5
FP5_2       FCB $01,$80,$00,$00,$00 ; 2.0

FP5_PInf    FCB $40,$00,$00,$00,$00 ; +∞  (E=$40, mantissa MSB=0)
FP5_QNaN    FCB $40,$80,$00,$00,$00 ; qNaN (E=$40, mantissa MSB=1)

FP5_InvSqrt2      FCB $7F,$B5,$04,$F3,$34 ; (1/√2) ≈ 0.707106781186548
FP5_2PI: 	FCB $02,$C9,$0F,$DA,$A2 ; 6.28318530717959
FP5_PI: 	FCB $01,$C9,$0F,$DA,$A2 ; 3.14159265358979
FP5_PI_2: 	FCB $00,$C9,$0F,$DA,$A2 ; 1.5707963267949
FP5_3PI_2: 	FCB $02,$96,$CB,$E3,$FA ; 4.71238898038469
FP5_NEG1: 	FCB $80,$80,$00,$00,$00 ; -1.0
FP5_SQRT2: 	FCB $00,$B5,$04,$F3,$34 ; √2 = 1.4142135623731

; ===== Constants =====
; Split ln2 = LN2_HI + LN2_LO to keep r tiny after subtraction
FP5_LN2: 	FCB $7F,$B1,$72,$17,$F8 ; 0.693147180559945
FP5_LOG2E: 	FCB $00,$B8,$AA,$3B,$29 ; 1.44269504088896
; (optional hi/lo split for tight range reduction)
;FP5_LN2_HI: FCB $7F,$B1,$72,$17,$F8 ; 0.6931471805
;FP5_LN2_LO: FCB $5E,$83,$D2,$35,$7B ; 5.9945309E-11

; LN2_HI = 0x7F B1 72 00 00
FP5_LN2_HI:  FCB $7F,$B1,$72,$00,$00
; LN2_LO = LN2 - LN2_HI = 6136 / 2^32 = 1.428648829460144e-6
; Exact FP5 encoding:
FP5_LN2_LO:  FCB $6C,$BF,$C0,$00,$00

; ======= Coefficients for ln(m) via z=(m-1)/(m+1)
; ln(m) ≈ 2*z * [ P(t)/Q(t) ],  t=z^2,  P even, Q even
; Use n=m=4 to start (excellent accuracy); plug in fitted FP5s below.
FP5_LOG_COEFFS_P:  ; P(t) = p0 + p1 t + p2 t^2 + p3 t^3 + p4 t^4 + p5 t^5
	FCB $00,$80,$00,$00,$00 ; p0 = +1.0
	FCB $81,$92,$F1,$D9,$19 ; p1 = -2.2960112324803763
	FCB $00,$E9,$CE,$39,$BB ; p2 = +1.8266060030876945
      FCB $FF,$95,$EE,$7A,$91 ; p3 = -0.5856701472737402
	FCB $7C,$84,$6B,$34,$90 ; p4 = +0.06465760292187715
	FCB $F6,$92,$72,$CE,$DE ; p5 = -0.0011173131488787847

FP5_LOG_COEFFS_Q:  ; Q(t) = q0 + q1 t + q2 t^2 + q3 t^3 + q4 t^4 + q5 t^5
      FCB $00,$80,$00,$00,$00 ; q0 = +1.0
      FCB $81,$A8,$47,$2E,$6E ; q1 = -2.62934456581371
      FCB $01,$A0,$32,$0A,$35 ; q2 = +2.5030541916922644
      FCB $80,$84,$BC,$BC,$7D ; q3 = -1.037009774198896
      FCB $7D,$B2,$68,$5C,$68 ; q4 = +0.17422623046437988
      FCB $F9,$85,$32,$27,$69 ; q5 = -0.008129633413211854

; ===== Kernel coefficients =====
; Even
; P_e(t) = Pe0 + Pe1*t + Pe2*t^2 + Pe3*t^3 + Pe4*t^4
FP5_EXP_Pe:
      FCB $7F,$80,$00,$00,$00 ; 0.5
      FCB $7B,$88,$BA,$EC,$DF ; 0.03338139084119223
      FCB $75,$C8,$6A,$65,$F3 ; 0.00076452491040474
      FCB $6E,$EA,$50,$25,$C6 ; 6.9830738420520306e-06
      FCB $66,$C5,$F7,$AE,$EE ; 2.3046451735876875e-08

; Q_e(t) = 1 + Qe1*t + Qe2*t^2 + Qe3*t^3 + Qe4*t^4
FP5_EXP_Qe:
      FCB $00,$80,$00,$00,$00 ; 1.0
      FCB $FA,$87,$BE,$F7,$2D ; -0.0165705516509488
      FCB $73,$8A,$92,$1B,$6F ; 0.00013215134727744224
      FCB $EB,$A6,$84,$B0,$11 ; -0.000000620329050666065
      FCB $62,$CE,$E9,$FC,$C5 ; 1.5054975898089108e-09

FP5_EXP_Po:             ; P_o(t) = Po0 + Po1*t + Po2*t^2 + Po3*t^3 + Po4*t^4
      FCB $00,$80,$00,$00,$00 ; 1.0
      FCB $7D,$97,$2B,$B1,$8B ; 0.1476276150713509
      FCB $78,$AE,$E7,$02,$E7 ; 0.005337597292009449
      FCB $72,$8F,$4D,$F5,$24 ; 6.833292093468524e-05
      FCB $6A,$9D,$DF,$42,$07 ; 2.9405970358474915e-07

FP5_EXP_Qo:             ; Q_o(t) = 1 + Qo1*t + Qo2*t^2 + Qo3*t^3 + Qo4*t^4
      FCB $00,$80,$00,$00,$00 ; 1.0
      FCB $FA,$9B,$F7,$C8,$FE ; -0.0190390515953157
      FCB $73,$BA,$0E,$FA,$AA ; 0.00017743922456207962
      FCB $EC,$85,$71,$14,$74 ; -0.000000994218277394929
      FCB $63,$CB,$6C,$D4,$1E ; 2.9602249798461223e-09

FP5_ATAN_COEFFS_P:      ; P(x) = c1*x + c3*x^3 + c5*x^5 + c7*x^7
      FCB $7F,$FF,$FF,$FF,$FA ; 0.9999999986163531
      FCB $00,$8F,$C7,$D7,$51 ; 1.1232861659064668
      FCB $7E,$90,$9C,$FA,$A7 ; 0.282447655603845
      FCB $79,$8E,$22,$7D,$2F ; 0.0086752150041525

FP5_ATAN_COEFFS_Q:       ; Q(x) = d0 + d2*x^2 + d4*x^4 + d6*x^6
      FCB $00,$80,$00,$00,$00 ; 1.0
      FCB $00,$BA,$72,$80,$85 ; 1.4566193248494073
      FCB $7F,$91,$67,$DA,$F0 ; 0.5679909550029164
      FCB $7B,$CA,$CB,$D0,$A2 ; 0.04951077935496848

FP5_X_CUR   RMB 5
FP5_Y_CUR   RMB 5
FP5_T1      RMB 5

; *** Build code for a faster INVERT routine, but for now just do 1/x
; Assume x is at ,S (value to invert)
; Result: 1/x at ,S
INVERT_FP5:
      PULS  D                 ; Get return address
      STD   @Return+1         ; Self mod return address
      PULS  A,X,Y             ; Save original x
      LDU   #$0000            ; mantissa for 1.0
      PSHS  U                 ; value1 = 1.0
      CLRB                    ; sign & exponent of 1.0
      LDU   #$8000            ; mantissa for 1.0
      PSHS  B,U
      PSHS  A,X,Y             ; value2 = x
      JSR   FP5_DIV           ; FP5_DIV - Divide 5,S / ,S then S=S+5 result is @ ,5 (Do 1/x)
@Return:
      JMP   >$FFFF            ; Return

; FP5_SQR
; In : x at ,S  (3 Bytes)
; Out: x*x at ,S
; Clobbers: D, X, Y, U
; Uses: FP5_MUL
; ------------------------------------------------------------
FP5_SQR:
      PULS  D                 ; Get return address
      STD   @Return+1         ; Self mod return address
; Duplicate x on the stack
      LEAU  ,S
      PULU  B,X,Y
      PSHS  B,X,Y             ; Copy x value on the stack
; Stack now has: [top]=x (dup) @ ,S   and  [next]=x @ 8,S
      JSR   FP5_MUL           ; Multiply 5,S * ,S then S=S+5, result is @ ,S
@Return:
      JMP   >$FFFF            ; Return, self modified jump address

; ------------------------------------------------------------
; FP5_SQRT  --  Compute sqrt(x) for FP5
; In : x @ ,S
; Out: sqrt(x) @ ,S
; Uses: FP5_MUL, FP5_ADD, FP5_SUB, FP5_DIV
; Scratch: FP5_Y_CUR, FP5_T1 (5 bytes each)
; ------------------------------------------------------------
FP5_SQRT:
      PULS  D           ; Get return address off the stack
      STD   @Return+1   ; Self modify the return location below
;
; Copy FP5 off the stack, saved in FP5_SIGN, FP5_EXPonent & FP5_MANT (as 4 byte mantissa)
      LDA   ,S
      BMI   @NotANumber ; Can't get square root of a negative number
      CMPA  #$40
      BEQ   @Return     ; If it's Special then return
      LDX   1,S         ; Get mantissa
      BEQ   @Return     ; If it's zero then return, square root of zero is zero
; ============================================================
;  x is a finite, non-NaN, non-zero FP5 at ,S (5 bytes)
;  We will:
;    - convert x -> internal format FP5_X_CUR
;    - set y0 = x (initial guess)
;    - iterate y = 0.5 * (y + x/y) a few times
;    - return sqrt(x) as FP5 @ ,S
; ============================================================
;---------- Copy FP5 x on stack into internal FP5_X_CUR ----------
;  Initial guess y0 = x (good enough; NR will converge quickly)
; Copy FP5 from the stack to FP5_X_CUR
      PULS  B,X,Y        ; Get FP5
      LDU   #FP5_X_CUR+5 ; Point past FP5_X_CUR
      PSHU  B,X,Y        ; PUSH FP5 into FP5_X_CUR
; Exponent of FP5_Y_CUR / 2
      LSLB              ; Shift sign bit out
      ASRB              ; Exponent is now a signed 8 bit value
      LSRB              ; k = e / 2 (arithmetic right shift)
      LDU   #FP5_Y_CUR+5 ; Point past FP5_Y_CUR
      PSHU  B,X,Y       ; PUSH FP5 into FP5_Y_CUR
;
;---------- Newton-Raphson iterations y = 0.5*(y + x/y) ----------
;  Choose 3 iterations: usually enough for good precision.
      LDA   #3
      PSHS  A
;
@NR_Loop:
; t1 = x / y
      PUSH_FP5 FP5_X_CUR  ; push x
      PUSH_FP5 FP5_Y_CUR  ; push y
      JSR   FP5_DIV       ; (5,S) / (S) -> result @ ,S
      PULL_FP5 FP5_T1     ; t1 = x / y
;
; y = 0.5 * (y + t1)
; First: y = y + t1  (result -> FP5_Y_CUR)
      PUSH_FP5 FP5_Y_CUR  ; push y
      PUSH_FP5 FP5_T1     ; push t1
      JSR   FP5_ADD       ; (5,S) + (S) -> result @ ,S
      PULL_FP5 FP5_Y_CUR  ; y = y + t1
;
; Then: y = y * 0.5
      PUSH_FP5 FP5_Y_CUR
      PUSH_FP5 FP5_Half   ; constant 0.5 in internal format
      JSR   FP5_MUL       ; y * 0.5
      PULL_FP5 FP5_Y_CUR  ; y = 0.5 * (y + t1)
;
; loop
      DEC   ,S
      BNE   @NR_Loop
      LEAS  1,S         ; Fix the stack
;
;---------- Convert final y back to IEEE and return ----------
; Put y back on stack
      PUSH_FP5 FP5_Y_CUR
;
@Return:
      JMP   >$FFFF
;
@NotANumber:
      LDB   #$40        ; Flag as NaN
      LDX   #$8000      ; Flag as NaN
      LDU   #$0000      ; Flag as NaN
      STB   ,S
      STX   1,S
      STU   3,S
      BRA   @Return


; ================================================================
; FP5_MOD -- Calculate the remainder of division using:
; remainder = dividend - (floor(dividend / divisor) * divisor)
; Entry: dividend is @ 5,S and the divisor is @ ,S then S=S+5 result is @ ,S
; Clobbers: A,B,D,X,Y,U
; ================================================================
FP5_MOD:
      PULS  U                 ; pull return address
      STU   @Return+1         ; self-modify return target
; Backup the Dividend and the divisor
;      PULS  D,X,Y,U
;      PSHS  D,X,Y
;      PSHS  D,X,Y             ; backup the dividend and divisor on the stack
;
; Copying 10 bytes from the stack back onto the stack
    LEAU    2,S         ; U points to stack+2
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
    LDD     8,S         ; Get the first 2 bytes of data
    PSHS    D           ; Push them on the stack
;
      JSR   FP5_DIV           ; (5,S) / (S) -> result @ ,S
      JSR   FP5_FLOOR         ; Compute floor(x) x is @ ,S return with FP5 value @,S which is the INTeger value of ,S
      JSR   FP5_MUL           ; Multiply 5,S * ,S then S=S+5, result is @ ,S
      JSR   FP5_SUB           ; Subtract, do 5,S - ,S Then S=S+5 result @ ,S
@Return:
      JMP   >$FFFF            ; patched by PULS U at entry
;--------------------------------------------------------------


; ================================================================
; FP5_FLOOR  --  Return greatest integer ≤ x  (floor) works like a true INT command
; Entry: 5-byte unpacked FP5 x at ,S
; Exit:  5-byte unpacked FP5 floor(x) at ,S
; Uses:  FP5_TO_S64, S64_To_FP5, FP5_SUB
; Clobbers: A,B,D,X,Y,U
; ================================================================
FP5_FLOOR:
      PULS  U                 ; pull return address
      STU   @Return+1         ; self-modify return target
;--------------------------------------------------------------
; Save original x and its sign
;--------------------------------------------------------------
      CopyStackToFP5 FP5_FLOOR_X ;  Copy 5 Byte FP5 from the stack to variable FP5_FLOOR_X
;--------------------------------------------------------------
; x -> signed 64-bit integer (truncate toward zero),
; then back to FP5 n = trunc(x) in the same 5 Byte slot.
;--------------------------------------------------------------
      JSR   FP5_TO_S64        ; 5 Byte slot at ,S now holds sign 8 byte integer @,S
      JSR   S64_To_FP5        ; signed 8 byte integer now holds 5 byte FP5 @ ,S
;
      LDA   FP5_FLOOR_X       ; Get the original sign value
      BPL   @Return           ; If it was positive then we are done
;
; Save n in FP5_FLOOR_N (as FP5)
      CopyStackToFP5 FP5_FLOOR_N ;  Copy 5 Byte FP5 from the stack to variable FP5_FLOOR_N
;
;--------------------------------------------------------------
; If original x >= 0, floor(x) = n
;--------------------------------------------------------------
      LDA   FP5_FLOOR_X
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
; New FP5_SUB expects: Value1 @,S and Value2 @3,S  -> Value1 - Value2
; Therefore push Value1 first (n), then Value2 (x)
;
      LEAS  5,S               ; drop current n from stack (we have it in FP5_FLOOR_N)
      PUSH_FP5 FP5_FLOOR_N    ; Value1 = n   goes to ,S
      PUSH_FP5 FP5_FLOOR_X    ; Value2 = x   goes to 5,S after next push
      JSR   FP5_SUB           ; d = n - x  (result at ,S), Subtract, do 5,S - ,S Then S=S+5 result @ ,S
;
    ; Test if d == 0  (all 5 Bytes zero?)
      LDD   1,S               ; Mantissa first
      BNE   @NegFraction
      LDD   3,S               ; Mantissa first
      BNE   @NegFraction
      LDA   ,S
      BEQ   @NegInteger       ; d == 0 => x was exact integer
;
;---------- Negative, fractional: floor(x) = n - 1.0 ----------
@NegFraction:
    ; Reload n into ,S
      LEAS  5,S
    ; Push +1.0 
      PUSH_FP5 FP5_FLOOR_N    ; PUSH FP5_FLOOR_N onto the stack
      PUSH_FP5 FP5_1          ; PUSH FP5_1 onto the stack
; FP5_SUB does n - 1.0
      JSR   FP5_SUB           ; (5,S - ,S) => n - 1.0 at ,S Subtract, do 5,S - ,S Then S=S+5 result @ ,S
      BRA   @Return
;
;---------- Negative, integer: floor(x) = n ----------
@NegInteger:
    ; Just reload n into ,S (overwrite d)
; *** Code below does the same thing
;    LEAS    5,S
;    PUSH_FP5 FP5_FLOOR_N      ; PUSH FP5_FLOOR_N onto the stack
;    BRA     @Return
;
;--------------------------------------------------------------
; Non-negative x: floor(x) = n (truncate)
;--------------------------------------------------------------
@NonNegative:
    ; Copy n into ,S in case anything modified it
      LEAS  5,S
      PUSH_FP5 FP5_FLOOR_N    ; PUSH FP5_FLOOR_N onto the stack
;
@Return:
      JMP   >$FFFF            ; patched by PULS U at entry
;
FP5_FLOOR_X      RMB 5 ; original x (5 Byte FP5)
FP5_FLOOR_N      RMB 5 ; trunc(x) as FP5

; FP5_EXP: Compute exp(x) for FP5-precision input
; Input:
;   ,S: x (5 bytes, FP5)
; Output:
;   ,S: exp(x) (3 bytes), S unchanged
; Clobbers: A, B, X, Y, U
;
; Strategy:
;   1) k = round(x * LOG2E)
;   2) r = x - k*LN2_hi - k*LN2_lo          (|r| ≤ ln2/2)
;   3) y = 1 + r * P(r^2) / Q(r^2)          (kernel via FP5_RATIONAL)
;   4) result = ldexp(y, k)                 (adjust exponent by k)
;
FP5_EXP:
      PULS  U
      STU   @Return+1
;
; === 0) handle special small/huge x quickly (optional: can skip initially) ===
; You can add early-outs here (e.g., if |x| is tiny -> 1+x, if x too large -> overflow to INF, etc.)
;
; === 1) Copy x to TEMP_X (we'll need it several times) ===
      CopyStackToFP5 FP5_Exp_TEMP_X ;  Copy 5 byte FP5 from the stack to variable FP5_Exp_TEMP_X
;
; === 2) k = round(x * LOG2E) ===
; x is already on the stack
; Push LOG2E, then multiply: x*LOG2E
      PUSH_FP5 FP5_LOG2E      ; PUSH LOG2E onto the stack
;
      JSR   FP5_MUL           ; -> x*LOG2E at ,S
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
;     u = x * LOG2E  at ,S   (because you already did PUSH_FP5 FP5_LOG2E / JSR FP5_MUL)
;
; If you want minimal disruption: do the multiply again here or
; move this block to immediately after your existing JSR FP5_MUL.
;
; I'm assuming right here that ,S = u (FP5, 5 bytes).
;
; ---- Multiply u by 16 (2^4) WITHOUT calling FP5_MUL ----
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
    STB     FP5_SIGN        ; reuse your sign temp if you want
    LDB     ,S
    LSLB
    ASRB                    ; B = signed exponent
    ADDB    #4              ; multiply by 16 => exponent += 4
;
; clamp u*16 into FP5 range before converting to int
    CMPB    #$3F
    BGT     @U16_TooBig
    CMPB    #$C1            ; -63
    BLT     @U16_TooSmall
;
    ANDB    #$7F
    ORB     FP5_SIGN
    STB     ,S
    BRA     @HaveU16FP5
;
@U16_Zero:
    ; u was 0 => u16 = 0
    ; leave ,S = 0
    BRA     @HaveU16FP5
;
@U16_TooBig:
    ; huge positive u => exp(x) overflows => +INF
    LEAS    5,S
    LDB     #%01000000      ; special exponent tag ($40)
    BRA     >
;
@U16_TooSmall:
    ; huge negative u => exp(x) underflows => +0
    LEAS    5,S
    CLRB
!   LDX     #$0000
    LDU     #$0000
    PSHS    B,X,U
    BRA     @Return
;
@Exp_Special:
    ; if something special sneaks in, just return it
    BRA     @Return
;
@HaveU16FP5:
; ---- Round to nearest integer: u16_int = floor(u16 + 0.5) ----
    PUSH_FP5 FP5_Half
    JSR     FP5_ADD
    JSR     FP5_FLOOR
@Exp_Skip
;
; ---- Convert integer FP5 -> signed 64, keep low 16 bits in U ----
    JSR     FP5_TO_S64              ; Convert 5 Byte FP5 @ ,S to Signed 64-bit Integer @ ,S
    PULS    D,X,Y,U                 ; Get 64 bit value off the stack
    STU     FP5_Exp_U16_Int         ; NEW temp: signed u16_int
;
; ---- Split u16_int into q and j ----
; q = arithmetic(u16_int >> 4), j = u16_int & 15
    LDD     FP5_Exp_U16_Int
    STD     FP5_Exp_TmpD         ; optional if you want, or skip
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
    STB     FP5_Exp_Q            ; q as signed 8-bit is enough
;
    ; compute j from original low byte
    LDB     FP5_Exp_U16_Int+1
    ANDB    #$0F                 ; j = 0..15
;
; ---- Load TAB[j] (3 bytes) into B,X ----
    LDX     #FP5_EXP2_TAB16
;    TFR     B,A                  ; Push j on the stack
      PSHS  B
    LSLB                         ; B=2j
      LSLB                          ; B = B * 4
    ADDB    ,S+                    ; B=5j
    ABX                          ; X += 5j
;
    LDB     ,X                   ; exponent/sign byte (0x00)
    LDU     3,X                  ; mantissa LSword
    LDX     1,X                  ; mantissa MSword
;
; ---- Apply 2^q by adjusting exponent of TAB[j] ----
    LDA     FP5_Exp_Q            ; q signed
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
    PSHS    B,X,U                ; push result
    BRA     @Return
;
@Out_Inf:
    LDB     #%01000000
      BRA   >
;
@Out_Zero:
    CLRB
!   LDX     #$0000
    LDU     #$0000
    PSHS    B,X,U
@Return:
      JMP   >$FFFF            ; return (self modified)
;
; ===== Data / temporaries =====
FP5_Exp_TEMP_X   RMB 5
FP5_Exp_U16_Int   RMB 2   ; signed u16_int = round(u*16)
FP5_Exp_Q         RMB 1   ; signed q = u16_int >> 4
FP5_Exp_TmpD      RMB 2
;
FP5_EXP2_TAB16:
      FCB $00,$80,$00,$00,$00 ; j=0  -> 1.000000
      FCB $00,$85,$AA,$BC,$D8 ; j=1  -> 1.044273
      FCB $00,$8B,$95,$C4,$22 ; j=2  -> 1.090508
      FCB $00,$91,$C3,$D6,$84 ; j=3  -> 1.138789
      FCB $00,$98,$37,$EF,$5B ; j=4  -> 1.189207
      FCB $00,$9E,$F5,$33,$F4 ; j=5  -> 1.241858
      FCB $00,$A5,$FE,$DA,$66 ; j=6  ->1.296840
      FCB $00,$AD,$58,$42,$B7 ; j=7  ->1.354256
      FCB $00,$B5,$04,$F6,$E0 ; j=8  ->1.414214
      FCB $00,$BD,$08,$A2,$66 ; j=9  -> 1.476826
      FCB $00,$C5,$67,$2B,$88 ; j=10  -> 1.542211
      FCB $00,$CE,$24,$89,$4C ; j=11  -> 1.610490
      FCB $00,$D7,$44,$FE,$37 ; j=12 -> 1.681793
      FCB $00,$E0,$CC,$DD,$94 ; j=13 -> 1.756252
      FCB $00,$EA,$C0,$C6,$2E ; j=14 -> 1.834008
      FCB $00,$F5,$25,$78,$60 ; j=15 -> 1.915206

; FP5_LOG: Compute natural logarithm ln(x)
; Input:
;   ,S: x (5 byte FP5)
; Output:
;   ,S: ln(x) (5 byte FP5), S unchanged
; Clobbers: A,B,X,Y,U
;
FP5_LOG:
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
!     LDU   #$0000            ; Mantissa = zero
      LDB   #$80+$40          ; Set the sign bit and exponent = $40 
      STB   ,S
      STX   1,S               ; Save -Infinity on the stack
      STU   3,S               ; Save -Infinity on the stack
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
; Copy x -> FP5_Log_TEMP_X
@DoLog:
      LDA   #3                ; Set the number of iterations for division accuracy
      STA   NewRap_Iterations ; Save it
      PULL_FP5    FP5_Log_TEMP_X    ; PULL Variable off the stack
;
; Get EXP and MANT and put mantissa into [1,2]
; FP5_Log_TEMP_X holds x
      LDA   FP5_Log_TEMP_X      ; sign/exp
      LSLA
      ASRA                     ; A = unbiased exponent (signed)
      STA   FP5_Log_E_SInt
; copy mantissa into m
      LDX   FP5_Log_TEMP_X+1
      LDU   FP5_Log_TEMP_X+3
;
      CLR   FP5_Log_M           ; make m positive, exponent=0
      STX   FP5_Log_M+1
      STU   FP5_Log_M+3
;
; Now m is in [1,2]. If m >= sqrt(2), divide by 2 and increase e by 1,
; so that final m ∈ [sqrt(1/2), sqrt(2)] as desired.
      PUSH_FP5 FP5_Log_M      ; PUSH m onto the stack
;
      PUSH_FP5 FP5_SQRT2      ; PUSH push sqrt(2) onto the stack
;
      JSR   FP5_CMP_Stack   ; Compare FP5 Value1 @ 5,S with Value2 @ ,S sets the 6809 flags Z, N, and C
;
;      JSR   FP5_SUB           ; m - sqrt(2), Subtract, do 5,S - ,S Then S=S+5 result @ ,S
;      LDA   ,S                ; A = the Sign of the result
      LEAS  10,S               ; Fix the stack
;      BMI   FP5_Log_M_OK      ; if m - sqrt(2) < 0, m < sqrt(2) => OK
      BLO   FP5_Log_M_OK
; else m >= sqrt(2): m = m/2, e = e + 1
      PUSH_FP5 FP5_Half       ; PUSH FP5_Half onto the stack
      PUSH_FP5 FP5_Log_M      ; PUSH m onto the stack
;
      JSR   FP5_MUL           ; m = m * 0.5
; Save stack at FP5_Log_M
      PULL_FP5 FP5_Log_M      ; PULL FP5_Log_M off the stack
;
      INC   FP5_Log_E_SInt    ; Increment FP5_Log_E_SInt
FP5_Log_M_OK:
; ========= z = (m - 1) / (m + 1) =========
; Compute numerator: m - 1
      PUSH_FP5 FP5_Log_M      ; PUSH m onto the stack
      PUSH_FP5 FP5_1          ; PUSH 1 onto the stack
;
      JSR   FP5_SUB           ; m - 1, Subtract, do 5,S - ,S Then S=S+5 result @ ,S
; Compute denominator: m + 1
      PUSH_FP5 FP5_1          ; PUSH 1 onto the stack
      PUSH_FP5 FP5_Log_M      ; PUSH m onto the stack
;
      JSR   FP5_ADD           ; m + 1
; Leave on the stack
; z = (m-1)/(m+1)
; both already on the stack in the correct order
      JSR   FP5_DIV           ; z
; Save z
      PULL_FP5 FP5_Log_Z      ; PULL z off the stack
;
; ========= R(t) = P(t) / Q(t),  t = z^2,  with P even / Q even =========
; Setup FP5_RATIONAL Q type=even, P type=even, counts = (n+1) = say 5 (deg 8 in t if you like)
      LDD   #FP5_LOG_COEFFS_P ; P coefficients pointer
      LDX   #$0500            ; MSB = P number of coefficients (n+1 = 4), LSB = P type: 0=even
      LDY   #FP5_LOG_COEFFS_Q ; Q coefficients pointer
      LDU   #$0500            ; MSB = Q number of coefficients (n+1 = 4), LSB = Q type: 0=even
      PSHS  D,X,Y,U 
; Push x=z (so Horner uses t=z^2 internally)
      PUSH_FP5 FP5_Log_Z      ; PUSH z onto the stack
;
      JSR   FP5_RATIONAL      ; -> R(t) = P/Q at ,S
;
; ========= ln(m) ≈ 2*z * R(t) =========
; Multiply R by z
      PUSH_FP5 FP5_Log_Z      ; PUSH z onto the stack
;    
      JSR   FP5_MUL           ; z * R
; Multiply by 2
      PUSH_FP5 FP5_2          ; PUSH 2 onto the stack
;
      JSR   FP5_MUL           ; ln(m) ≈ 2*z*R
;
; ========= ln(x) = e*ln2 + ln(m) =========
; Compute e as FP5 and scale ln2 by e, or scale via integer multiply/add.
; Here: form e as FP5 to reuse FP5_MUL/ADD.
;
; Build e as FP5 in @E_FP5
    ; For now we’ll multiply ln2 by integer e using repeated add if you prefer (or build E_FP5 once elsewhere).
;
; Multiply ln2 * e (FP5 e)
      PUSH_FP5 FP5_LN2        ; PUSH ln2 onto the stack
;
    ; Build e as FP5 quickly
;
      LDB   FP5_Log_E_SInt    ; Get the signed 8 bit number in B
      SEX                     ; Sign extend value into D
      JSR   S16_To_FP5        ; Convert Signed 16 bit integer in D to 5 Byte FP5 @ ,S
;
      JSR   FP5_MUL          ; e*ln2
;
; Add ln(m)
; ln(m) is already on the stack
      JSR   FP5_ADD          ; (e*ln2) + (2*z*R)
;
      LDA   #1                ; Set the number of iterations for division accuracy
      STA   NewRap_Iterations ; Set it to fast, for other division steps
@Return:
      JMP   >$FFFF
; ======= Data / temporaries =======
FP5_Log_TEMP_X   RMB 5
FP5_Log_M        RMB 5
FP5_Log_Z        RMB 5
FP5_Log_E_SInt   RMB 1            ; signed 8-bit exponent (unbiased)



; FP5_RATIONAL: Evaluate rational function P(x)/Q(x) using two Horner chains
; Input:
;   Stack:
;     ,S: x (5 bytes, FP5-precision)
;    5,S: P coefficient table pointer (2 bytes)
;    7,S: P number of coefficients (n+1, 1 byte)
;    8,S: P type (0=even, 1=odd, 1 byte)
;    9,S: Q coefficient table pointer (2 bytes)
;   11,S: Q number of coefficients (m+1, 1 byte)
;   12,S: Q type (0=even, 1=odd, 1 byte)
; Output:
;   RESULT: S=S+6 ,S = P(x)/Q(x) (3 bytes, FP5-precision)
; Clobbers: A, B, X, Y, U
FP5_RATIONAL:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; Evaluate P(x)
; Push params for P: x, P ptr, P num coeffs
      LEAU  5,S
      PULU  A,X
      PSHS  A,X         ; copy P coefficient table pointer (2 bytes) & P number of coefficients (n+1, 1 byte) on the stack
;
      LEAU  3,S         ; copy x (5 bytes, FP5-precision) on the stack
      PULU  A,X,Y       ; Get 5 bytes
      PSHS  A,X,Y       ; Push them on the stack
; P(x) is now ready to be evaluated
; Call appropriate Horner based on P type
      LDA   8+8,S       ; P type (0=even, 1=odd, 1 byte)
      BEQ   @CallEvenP
      JSR   FP5_HORNER_ODD ; Evaulate, S=S+5, result @ ,S
      BRA   @StoreP
@CallEvenP:
      JSR   FP5_HORNER_EVEN ; Evaulate, S=S+5, result @ ,S
@StoreP:
; Copy RESULT to TEMP_P
      PULL_FP5  FP5_Rational_TempP  ; PULL FP5_Rational_TempP off the stack
; Evaluate Q(x)
; Push params for Q: x, Q ptr, Q num coeffs
      LEAU  9,S
      PULU  A,X
      PSHS  A,X         ; copy Q coefficient table pointer (2 bytes) & Q number of coefficients (n+1, 1 byte) on the stack
;
      LEAU  3,S         ; copy x (5 bytes, FP5-precision) on the stack
      PULU  A,X,Y       ; Get 5 bytes
      PSHS  A,X,Y       ; Push them on the stack
; Q(x) is now ready to be evaluated
; Call appropriate Horner based on Q type
      LDA   12+8,S      ; Q type (1 byte: 0=even, 1=odd)
      BEQ   @CallEvenQ
      JSR   FP5_HORNER_ODD   ; Evaulate, S=S+5, result @ ,S
      BRA   @StoreQ
@CallEvenQ:
      JSR   FP5_HORNER_EVEN  ; Evaulate, S=S+5, result @ ,S
@StoreQ:
; Copy RESULT to TEMP_Q
      PULL_FP5  FP5_Rational_TempQ ; PULL FP5_Rational_TempQ off the stack
; Restore stack after Q eval
      LEAS  13,S        ; Clear all from the stack
; Divide P / Q
; Push TEMP_P
      PUSH_FP5 FP5_Rational_TempP ; PUSH FP5_Rational_TempP onto the stack
; Push TEMP_Q
      PUSH_FP5 FP5_Rational_TempQ ; PUSH FP5_Rational_TempQ onto the stack
;
      JSR   FP5_DIV     ; Divide P / Q, S=S+5, result at ,S
; Final Result is on the stack
@Return:
      JMP   >$FFFF      ; Return, self-modified
;
; Data section
FP5_Rational_TempP    RMB 5   ; Temporary for P(x)
FP5_Rational_TempQ    RMB 5   ; Temporary for Q(x)


; FP5_HORNER_EVEN: Evaluate an even-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (5 bytes, FP5-precision)
;     5,S: Pointer to coefficient table (2 bytes)
;     7,S: Number of coefficients (n+1, 1 byte, for degrees 0, 2, ..., 2n)
; Output:
;   RESULT: S=S+5, result @ ,S = Polynomial value (5 bytes, FP5-precision)
; Clobbers: A, B, X, Y, U
FP5_HORNER_EVEN:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self mod return address
; Put x on the stack again
      CopyStackOnStack  ; Copy value on the stack on the stack again
; Compute x^2
      JSR   FP5_MUL      ; RESULT * x^2, result at ,S, S=S+5      ; FD 91 8C 2F 04 ^ 2 = 7A A5 80 35 52 (7A A5 80 34 0C)
; Copy result to Temp
      PULL_FP5  FP5_HORE_Temp   ; PULL FP5_HORE_Temp off the stack
;
; Initialize result with highest-degree coefficient (a_2n)
      LDB   2,S         ; Load number of coefficients (n+1)
      DECB              ; Index of next coefficient
; Multiply by 3 for byte offset in B
      STB   @AddB+1     ; Save B below (self mod)
      LSLB              ; B = B * 2
      LSLB              ; B = B * 4
@AddB:
      ADDB  #$FF        ; B = B + orignal B
      LDX   ,S          ; X = coefficient table pointer
      ABX               ; X points to a_2n
; Copy a_2n to RESULT
      LEAU  ,X          ; point after a_2n
      PULU  B,X,Y       ; Get a_2n value
      PSHS  B,X,Y       ; Put a_2n on the stack
;
; Horner's method loop: RESULT = x^2 * RESULT + next_coefficient
@HORNER_LOOP:
      DEC   5+2,S       ; n, then n-1, ..., 0
      BEQ   @DONE       ; Exit if no more coefficients
; Push x^2 onto stack
      PUSH_FP5 FP5_HORE_Temp      ; PUSH FP5_HORE_Temp onto the stack
; Result is already on the stack
; Multiply: RESULT = RESULT * x^2
      JSR   FP5_MUL     ; RESULT * x^2, result at ,S, S=S+5
; Push next coefficient
      LDB   5+2,S       ; Load current index (n)
      DECB              ; Index of next coefficient
; Multiply by 5 for byte offset in B
      STB   @AddB1+1    ; Save B below (self mod)
      LSLB              ; B = B * 2
      LSLB              ; B = B * 4
@AddB1:
      ADDB  #$FF        ; B = B + orignal B
      LDX   5,S         ; X = coefficient table pointer
      ABX               ; X points to next coefficient
; Copy coefficient to stack
      LEAU  ,X          ; Point after the coefficient
      PULU  B,X,Y         ; Get coefficient
      PSHS  B,X,Y       ; Push it on the stack
;
; Add: RESULT = RESULT + coefficient
      JSR   FP5_ADD     ; RESULT + coefficient, result at ,S, S=S+5
; Leave RESULT on the stack
      BRA   @HORNER_LOOP
@DONE:
; clean up the stack, copy RESULT on the stack and return
      PULS  B,X,Y       ; Get the result
      LEAS  3,S         ; Move the stack past the table pointer and counter
      PSHS  B,X,Y       ; Save the result on the stack
@Return:
    JMP     >$FFFF      ; Return, self modified jump address
; Data section
FP5_HORE_Temp      RMB 5       ; Temporary storage for x^2

; FP5_HORNER_ODD: Evaluate an odd-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (5 bytes, FP5-precision)
;     5,S: Pointer to coefficient table (2 bytes)
;     7,S: Number of coefficients (n+1, 1 byte, for degrees 1, 3, ..., 2n+1)
; Output:
;   RESULT: S=S+5, result @ ,S = Polynomial value (5 bytes, FP5-precision)
; Clobbers: A, B, X, Y, U
FP5_HORNER_ODD:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; Copy x to TEMP_X for safekeeping
      CopyStackToFP5 FP5_Hor_TEMP_X ; Copy x to TEMP_X for safekeeping
; Put x on the stack again
      CopyStackOnStack  ; Put x on the stack again
; Compute x^2
      JSR   FP5_MUL     ; RESULT * x^2, result at ,S, S=S+3 RESULT with 76 DC 57 = 0.001681059599
; Copy result to Temp
      PULL_FP5  FP5_HORO_Temp ; PULL Temp off the stack
;
; Initialize result with highest-degree coefficient (a_2n+1)
      LDB   2,S         ; Load number of coefficients (n+1)
      DECB              ; Index of next coefficient
; Multiply by 3 for byte offset in B
      STB   @AddB+1     ; Save B below (self mod)
      LSLB              ; B = B * 2
      LSLB              ; B = B * 4
@AddB:
      ADDB  #$FF        ; B = B + orignal B (self modded)
      LDX   ,S          ; X = coefficient table pointer
      ABX               ; X points to a_2n
; Copy a_2n+1 to RESULT
      LEAU  ,X          ; point after a_2n+1
      PULU  B,X,Y       ; Get a_2n+1 value
      PSHS  B,X,Y       ; Put a_2n+1 on the stack
;
; Horner's method loop: RESULT = x^2 * RESULT + next_coefficient
@HORNER_LOOP:
      DEC   5+2,S       ; n, then n-1, ..., 0
      BEQ   @FINAL_MUL  ; Exit loop if no more coefficients
; Push x^2 onto stack
      PUSH_FP5 FP5_HORO_Temp ; PUSH Temp onto the stack
; RESULT on the stack
; Multiply: RESULT = RESULT * x^2
      JSR   FP5_MUL     ; RESULT * x^2, result at ,S, S=S+5. Result 6187E2 = 0.0000000004943387921
; Push next coefficient
      LDB   5+2,S       ; Load current index (n)
      DECB              ; Index of next coefficient
; Multiply by 5 for byte offset in B
      STB   @AddB1+1    ; Save B below (self mod)
      LSLB              ; B = B * 2
      LSLB              ; B = B * 4
@AddB1:
      ADDB  #$FF        ; B = B + orignal B
      LDX   5,S         ; X = coefficient table pointer
      ABX               ; X points to next coefficient
; Copy coefficient to stack
      LEAU  ,X          ; point after coefficient
      PULU  B,X,Y       ; Get coefficient value
      PSHS  B,X,Y       ; Put coefficient on the stack
;
; Add: RESULT = RESULT + coefficient
      JSR   FP5_ADD     ; RESULT + coefficient, result at ,S, S=S+5
; Leave RESULT on the stack
      BRA   @HORNER_LOOP
@FINAL_MUL:
; Multiply RESULT by x to account for odd-degree polynomial
      PUSH_FP5 FP5_Hor_TEMP_X ; PUSH variable onto the stack
; Leave RESULT on the stack
      JSR   FP5_MUL     ; RESULT * x, result at ,S, S=S+5
; clean up the stack, copy RESULT on the stack and return
      PULS  B,X,Y       ; Get the result
      LEAS  3,S         ; Move the stack past the table pointer and counter
      PSHS  B,X,Y       ; Save the result on the stack
@Return:
    JMP     >$FFFF      ; Return, self modified jump address
;
; Data section
FP5_HORO_Temp    RMB 5        ; Temporary storage for x^2
FP5_Hor_TEMP_X   RMB 5        ; Temporary storage for x


; FP5_COS: Compute cos(x) for FP5-precision input
; Input:
; ,S: x (5 bytes, FP5-precision)
; Output:
; ,S: cos(x) (5 bytes, FP5-precision), S unchanged
; Clobbers: A, B, D, X, Y, U
FP5_COS:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; check for 0 COS(0)=1
      LDD   ,S          ; Get Exponent LSB & Mantissa MSB, most likely to have something
      BNE   >
; We get here when we are given COS(0) = 1
      LEAS  5,S         ; Clear the stack
      PUSH_FP5 FP5_1    ; PUSH 1.0 onto the stack
      JMP   @Return     ; Cosine of 0 is 1
; Compute x' = x + π/2 to use cos(x) = sin(x + π/2)
!     PUSH_FP5 FP5_PI_2 ; PUSH π/2 onto the stack
;
      JSR   FP5_ADD     ; x + π/2, S=S+5, result at ,S
      BRA   @NotZero    ; Use the SINE function for the rest
;
; FP5_SIN: Compute sin(x) for FP5-precision input
; Input:
;   ,S: x (5 bytes, FP5-precision)
; Output:
;   ,S: sin(x) (5 bytes, FP5-precision), S unchanged
; Clobbers: A, B, X, Y, U
FP5_SIN:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; Check for zero, SIN(0)=0
      LDD   ,S          ; Get Exponent LSB & Mantissa MSB, most likely to have something
      LBEQ  @Return     ; SINE of zero is zero, leave it as it
; Save x
@NotZero:
      CopyStackToFP5 FP5_Sin_Temp_X ;  Copy 5 byte FP5 from the stack to variable FP5_Sin_Temp_X
; Range reduction: x' = x mod 2π
      PUSH_FP5 FP5_Sin_Temp_X       ; PUSH FP5_Sin_Temp_X onto the stack
      PUSH_FP5 FP5_2PI              ; PUSH 2π onto the stack
;
      JSR   FP5_DIV     ; x / 2π, result at ,S, S=S+5
; Floor division result
      JSR   FP5_FLOOR   ; Do INT(,S) keep it as a FP5 number
; x' = x - floor(x/2π) * 2π
      PUSH_FP5 FP5_2PI  ; PUSH 2π onto the stack
;
      JSR   FP5_MUL     ; floor(x/2π) * 2π, S=S+5
; x is already on the stack, so we just do a FP5_SUB to get our result of x - floor(x/2π) * 2π
;
      JSR   FP5_SUB     ; x - floor(x/2π) * 2π, S=S+5
; Store x' in TEMP_X, leave it on the stack
      CopyStackToFP5 FP5_Sin_Temp_X ;  Copy 5 byte FP5 from the stack to variable FP5_Sin_Temp_X
;
; Determine quadrant and adjust x' to [0, π/2]
; Compute x' - π
; Didn't pull it off the stack above, just copied it to TEMP_X
      PUSH_FP5 FP5_PI               ; PUSH π onto the stack
;
      JSR   FP5_SUB     ; π - x', S=S+5
; If π < x' , use π - x' or adjust sign
      LDA   ,S          ; Check sign bit (bit 7 of first byte) 
      LEAS  5,S         ; Fix the stack
      BPL   @Quadrant34 ; if x >= π then go decide between Quadrant 3 (≤ 3π/2) and Quadrant 4 (> 3π/2)
; if we get here then x' < π
; x' < π → Quadrant 1 or 2
; Test if x' - π/2 >= 0
; x' <= π, check if x' <= π/2
      PUSH_FP5 FP5_Sin_Temp_X       ; PUSH FP5_Sin_Temp_X onto the stack
      PUSH_FP5 FP5_PI_2             ; PUSH π/2 onto the stack
;
      JSR   FP5_SUB     ; x' - π/2, S=S+5
      LDA   ,S          ; Check sign
      LEAS  5,S         ; Fix the stack
      LBMI  @Quadrant1  ; Use 'x as it is
; x' >= π/2 → Quadrant 2: sin(x') = sin(π - x')
@Quadrant2:             ; sin(x') = sin(π - x')
      PUSH_FP5 FP5_PI               ; PUSH π onto the stack
      PUSH_FP5 FP5_Sin_Temp_X       ; PUSH FP5_Sin_Temp_X onto the stack
;
      JSR   FP5_SUB     ; π - x', S=S+5
      PULL_FP5  FP5_Sin_Temp_X      ; PULL FP5_Sin_Temp_X off the stack
      JMP   @EvalSin
@Quadrant34:
; Now decide between Quadrant 3 (≤ 3π/2) and Quadrant 4 (> 3π/2)
; Test if x' - 3π/2 >= 0
; x' > π, check if x' <= 3π/2
      PUSH_FP5 FP5_Sin_Temp_X       ; PUSH FP5_Sin_Temp_X onto the stack
      PUSH_FP5 FP5_3PI_2            ; PUSH 3π/2 onto the stack
;
      JSR   FP5_SUB     ; x' - 3π/2, S=S+5
      LDA   ,S          ; Check sign
      LEAS  5,S         ; Fix the stack
      BPL   @Quadrant4  ; x' >= 3π/2  → Quadrant 4: sin(x') = -sin(2π - x')
@Quadrant3:
; Quadrant 3: sin(x') = -sin(x' - π)
      PUSH_FP5 FP5_Sin_Temp_X       ; PUSH FP5_Sin_Temp_X onto the stack
      PUSH_FP5 FP5_PI               ; PUSH π onto the stack
;
      JSR   FP5_SUB     ; x' - π
      BRA   @Negate
@Quadrant4:    ; sin(x') = -sin(2π - x')
      PUSH_FP5 FP5_2PI              ; PUSH 2π onto the stack
      PUSH_FP5 FP5_Sin_Temp_X       ; PUSH FP5_Sin_Temp_X onto the stack
;
      JSR   FP5_SUB     ; 2π - x'
@Negate:
      PULL_FP5  FP5_Sin_Temp_X      ; PULL Variable off the stack
; Negate sign
      LDA   FP5_Sin_Temp_X
      EORA  #%10000000
      STA   FP5_Sin_Temp_X
@Quadrant1:
@EvalSin:
    ; Evaluate sin(x') using FP5_HORNER_ODD
      LDB   #4
      PSHS  B           ; Push n+1 = 4 (degrees 1, 3, 5, 7)
      LDD   #FP5_SIN_COEFFS
      PSHS  D           ; Push coefficient pointer
      PUSH_FP5 FP5_Sin_Temp_X       ; PUSH FP5_Sin_Temp_X onto the stack Push x'
;
; FP5_HORNER_ODD: Evaluate an odd-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (5 bytes, FP5-precision)
;     5,S: Pointer to coefficient table (2 bytes)
;     7,S: Number of coefficients (n+1, 1 byte, for degrees 1, 3, ..., 2n+1)
; Output:
;   RESULT: S=S+5, result @ ,S = Polynomial value (5 bytes, FP5-precision)
; Clobbers: A, B, X, Y, U
      JSR   FP5_HORNER_ODD    ; ,S = DB number, 3,S = coefficient table, 12,s = # of coefficients, S=S+3, DB result is @ ,S
;
@Return:
      JMP   >$FFFF      ; Return, self-modified
; Temporaries
FP5_Sin_Temp_X    RMB  5   ; Reduced x


; FP5_TAN: Compute tan(x) for FP5-precision input
; Input:
; ,S: x (5 bytes, FP5-precision)
; Output:
; ,S: tan(x) (5 bytes, FP5-precision), S unchanged
; Clobbers: A, B, X, Y, U
; tan(x) = sin(x) / cos(x)
FP5_TAN:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self-modify return address
; Save x
      CopyStackToFP5 FP5_Tan_Temp_X ;  Copy 5 byte FP5 from the stack to variable FP5_Tan_Temp_X
; Compute sin(x)
      JSR   FP5_SIN     ; Compute sin(x), result at ,S, S=S+3
      PUSH_FP5 FP5_Tan_Temp_X       ; PUSH FP5_Tan_Temp_X onto the stack
;
      JSR   FP5_COS     ; Compute cos(x), result at ,S
; Check if cos(x) is zero (singularity check)
      LDD   ,S          ; Get Exponent LSB & Mantissa MSB, most likely to have something
      BNE   @NotZero
; cos(x) = 0, tangent is undefined
      LEAS  5,S         ; Move stack pointer past result of cos(x)
      LDA   #$40        ; Return 754 NaN or large value
      STA   ,S
      LDD   #$0000
      STD   1,S
      STD   3,S
      BRA   @Return
@NotZero:
; Compute tan(x) = sin(x) / cos(x)
      JSR   FP5_DIV     ; sin(x) / cos(x), S=S+5, result at ,S
@Return:
      JMP   >$FFFF      ; Return, self-modified
; Temporaries
FP5_Tan_Temp_X     RMB 5       ; Temporary storage for x


; FP5_ATAN: Compute atan(x) for FP5-precision input
; Input:
; ,S: x (5 bytes, IEEE 754 FP5-precision)
; Output:
; ,S: atan(x) (5 bytes, FP5-precision), S unchanged
; Clobbers: A, B, D, X, Y, U
FP5_ATAN:
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
      ORA   3,S
      ORA   4,S
      BEQ   @Return       ; ±0 => return 0
@NotZero:
; Save sign and compute |x|
; Save x as FP5_ATan_TEMP_X
; Save sign bit of x (bit7 of first byte)
      LDA   ,S
      ANDA  #$80
      STA   FP5_ATAN_Sign
; Make x = |x| on stack by clearing sign bit
      LDA   ,S
      ANDA  #$7F
      STA   ,S
      CopyStackToFP5 FP5_ATan_TEMP_X ; Copy x to FP5_ATan_TEMP_X
; Compare |x| (already on the stack) with 1
      PUSH_FP5 FP5_1          ; PUSH 1.0 variable onto the stack
;
      JSR   FP5_SUB           ; |x| - 1, S=S+5
      LDA   ,S                ; Check sign
      LEAS  5,S               ; Fix stack
      BPL   @LargeX           ; If |x| > 1, use atan(x) = π/2 - atan(1/x)
; |x| ≤ 1, compute atan(|x|) using FP5_RATIONAL
@SmallX
      LDD   #FP5_ATAN_COEFFS_P ; P coefficients pointer
      LDX   #$0401            ; MSB = P number of coefficients (n+1 = 4), LSB = P type: 1=odd
      LDY   #FP5_ATAN_COEFFS_Q ; Q coefficients pointer
      LDU   #$0400            ; MSB = Q number of coefficients (n+1 = 4), LSB = Q type: 0=even
      PSHS  D,X,Y,U
;
      PUSH_FP5 FP5_ATan_TEMP_X ; PUSH |x| variable onto the stack
;
      JSR   FP5_RATIONAL      ; Evaluate P(x)/Q(x), S=S+3, result at ,S
      BRA   @ApplySign
; ---------------------------
; |x| >= 1: atan(x) = pi/2 - atan(1/x)
; ---------------------------
@LargeX:
; |x| > 1, compute 1/|x|
; Compute atan(1/|x|)
      LDD   #FP5_ATAN_COEFFS_P ; P coefficients pointer
      LDX   #$0401            ; MSB = P number of coefficients (n+1 = 4), LSB = P type: 1=odd
      LDY   #FP5_ATAN_COEFFS_Q ; Q coefficients pointer
      LDU   #$0400            ; MSB = Q number of coefficients (n+1 = 4), LSB = Q type: 0=even
      PSHS  D,X,Y,U
;
      PUSH_FP5 FP5_ATan_TEMP_X ; PUSH |x| variable onto the stack
;
      JSR   INVERT_FP5        ; Compute 1/|x|, result at ,S
      JSR   FP5_RATIONAL      ; Evaluate P(x)/Q(x), S=S+3, result at ,S
; Compute π/2 - atan(1/|x|)
; Leave atan(1/|x|) on the stack (flip the sign bit afterwards)
      PUSH_FP5 FP5_PI_2       ; PUSH π/2 onto the stack
;
      JSR   FP5_SUB           ; π/2 - atan(1/|x|), S=S+5
      LDA   ,S                ; Get the SIGN bit
      EORA  #%10000000        ; Flip bit 7
      STA   ,S                ; Save new value
@ApplySign:
      LDA   ,S
      ANDA  #%01111111        ; Clear sign bit
      ORA   FP5_ATAN_Sign     ; Copy original sign bit in result
      STA   ,S                ; Save updated sign
@Return:
      JMP   >$FFFF            ; Return, self-modified
; Temporaries
FP5_ATan_TEMP_X   RMB 5       ; Temporary storage for x
FP5_ATAN_Sign     RMB 1       ; Store sign of input

; Compute Power 5,S ^ ,S Then S=S+5 result @ ,S
FP5_POW:
      PULS  U
      STU   @Return+1
; Pull exponent (value2) from ,S to temp
      PULL_FP5  FP5_TempPOW      ; PULL Variable off the stack
; Now base (value1) is at ,S
; Check if base is zero (ignore sign)
      LDA   ,S          ; sign+exp of base
      ANDA  #$7F        ; mask sign
      BNE   @Not_zero_base
      LDX   1,S         ; mant of base
      BNE   @Not_zero_base
; base is zero (+0 or -0)
; Check if exponent is zero
      LDA   FP5_TempPOW
      ANDA  #$7F
      BNE   @Exp_not_zero
      LDX   FP5_TempPOW+1
      BNE   @Exp_not_zero
; 0^0: return +1.0
      LDD   #$0080
      STD   ,S
      CLRB
      STD   2,S
      STA   4,S
      BRA   @Return
@Exp_not_zero:
; Check if exponent is positive or negative
      LDA   FP5_TempPOW    ; load sign+exp
      BPL   @Exp_positive ; bit7=0: positive (or zero, but already checked)
; exponent < 0: return +inf
      LDD   #$4000
      STD   ,S
      CLRA
      STD   2,S
      STA   4,S
      BRA   @Done
@Exp_positive:
; exponent > 0: return +0
      LDD   #$0000
      STD   ,S
      STD   2,S
      STA   4,S
      BRA   @Done
@Not_zero_base:
; Normal case: proceed with log/mul/exp
      JSR   FP5_LOG     ; Compute ln(base), result at ,S
; Push exponent back on top of stack
      PUSH_FP5 FP5_TempPOW ; PUSH FP5_TempPOW onto the stack
      JSR   FP5_MUL     ; Compute exponent * ln(base), result at ,S
      JSR   FP5_EXP     ; Compute exp(of the product), result at ,S
@Done:
@Return:
      JMP   >$FFFF      ; Self-modifying return
FP5_TempPOW RMB 5



;      INCLUDE ./Math_Floating_Point5_Extra_Fix.asm

