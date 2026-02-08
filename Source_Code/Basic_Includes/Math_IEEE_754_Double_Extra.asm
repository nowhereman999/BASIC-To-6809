; IEEE_754 Double Extra commands
; Requires Math_IEEE_754_Double_64bit.asm
; Which includes routines for:
; DB_ADD            ; Add 10,S + ,S Then S=S+10 result @ ,S
; DB_SUB            ; Subtract 10,S - ,S Then S=S+10 result @ ,S
; DB_MUL            ; Multiply 10,S * ,S Then S=S+10 result @ ,S
; DB_DIV            ; Divide 10,S / ,S Then S=S+10 result @ ,S
;
; Conversion routines:
; U64_To_Double     ; Convert Unsigned 64 bit integer @,S to 10 byte Double @ ,S  Input: U64 bit number at ,S Output: Unpacked Double number at ,S 
; S64_To_Double     ; Convert Signed 64 bit integer @,S to 10 byte Double @ ,S Input: S64 bit number at ,S Ouput: Unpacked Double number at ,S
; DB_TO_S64         ; Convert 10 byte Double @ ,S to Signed 64-bit Integer @ ,S
; DB_TO_U64         ; Convert 10 byte Double @ ,S to Unsigned 64-bit Integer @ ,S
; DB_TO_S32         ; Convert 10 Byte Double at ,S to 32-bit signed integer at ,S
; DB_TO_U32         ; Convert 10 Byte Double at ,S to 32-bit unsigned integer at ,S
; DB_TO_S16         ; Convert 10 Byte Double at ,S to 16-bit signed integer at ,S
; DB_TO_U16         ; Convert 10 Byte Double at ,S to 16-bit unsigned integer at ,S
; U32_To_Double     ; Convert Unsigned 32bit integer @,S to 10 byte Double @ ,S
; S32_To_Double     ; Convert signed 32bit integer @,S to 10 byte Double @ ,S
; UnInt2Double      ; Convert unsigned 16bit integer in D to 10 byte Double @ ,S
; Int2Double        ; Convert signed 16bit integer in D to 10 byte Double @ ,S
; FFP_To_Double     ; Convert 3 byte Fast Floating Point at ,S to 10 byte Double at ,S
; Double_To_FFP     ; Convert IEEE-754 Double at S to FFP at ,S

; New Advanced routines in this library are:
;+INVERT_DOUBLE     ; Do 1/x where x is at ,S (value to invert), Result: 1/x at ,S
;*DB_SQRT           ; Compute Square Root of a Double number @ ,S result @ ,S
;+DB_HORNER_EVEN    ; Evaluate an even-degree polynomial using Horner's method, then S=S+3, result @ ,S
;+DB_HORNER_ODD     ; Evaluate an odd-degree polynomial using Horner's method, then S=S+3, result @ ,S
;+DB_RATIONAL       ; Evaluate rational function P(x)/Q(x) using two Horner chains
;+DB_MOD            ; Compute the remainder of division using dividend is @ 10,S and the divisor is @ ,S then S=S+10 result is @ ,S
;+DB_FLOOR          ; Compute floor(x) x is @ ,S return with Double value @,S which is the INTeger vale of ,S
;*DB_EXP            ; Compute exponential number, exp(x), x is @,S result @ ,S
;*DB_LOG            ; Compute natural logarithm ln(x), x is @,S result @ ,S
;*DB_SIN            ; Compute sine, sin(x), x is @,S result @ ,S
;*DB_COS            ; Compute cosine, cos(x), x is @,S result @ ,S
;*DB_TAN            ; Compute tangent, tan(x), x is @,S result @ ,S
;*DB_ATAN           ; Compute arctangent, atn(x), x is @,S result @ ,S
;*DB_POW            ; Compute Power ,S ^ 10,S Then S=S+10 result @ ,S

; UnPacked Double format - 10 bytes
; Bytes     Function
; 0         (1 byte)  Sign - only bit 7 will be the actual sign the rest of the bits should always be zero
; 1  &  2   (2 bytes) Exponent - normalized 16 bit value
; 3  to 9   (7 bytes) Mantissa bytes (Includes implied bit at bit 52 always set) to keep it consistent with IEEE 754 Double format
 
; Special Formats:
; Zero (±0):
; Value Sign    Exponent (unbiased) Mantissa
; +0    0       All 0s              Most Significant bit is 0
; -0    1       All 0s              Most Significant bit is 0
;
; Infinity (±∞):
; Value Sign    Exponent (unbiased) Mantissa
; +∞    0       $8000               Most Significant bit is 0
; -∞    1       $8000               Most Significant bit is 0
;
; Not a Number (NaN):
; Type  Sign    Exponent (unbiased) Mantissa
; NaN   Any     $8000               Most Significant bit is 1

;----------------------------------------------------------------------
;  MACRO: PUSH_DBL <label>
;  Push 10-byte double at <label> onto the 6809 stack for DB_* routines
;  (Use the same pattern you already use before calling DB_MUL/DB_DIV.)
;----------------------------------------------------------------------
PUSH_DBL  MACRO  \1
    LDU     #\1+2       ; U -> addr+2
    PULU    D,X,Y          ; D=addr+2..3, X=+4..5, Y=+6..7, U=+8
    LDU     ,U             ; U = addr+8..9
    PSHS    D,X,Y,U        ; push 8 bytes
    LDD     \1          ; first 2 bytes
    PSHS    D              ; push -> total 10 bytes
    ENDM

;----------------------------------------------------------------------
;  MACRO: PULL_DBL <label>
;  Pull 10-byte double from the 6809 stack into <label>.
;----------------------------------------------------------------------
PULL_DBL   MACRO  \1
    PULS    D,X,Y,U     ; pull 8 bytes
    STU     \1+6        ; last word -> bytes 6..7
    LDU     #\1+6       ; U points to bytes 6..7
    PSHU    D,X,Y       ; store D,X,Y into bytes 0..5 via PSHU trick
    PULS    D           ; pull last word
    STD     8,U         ; store into bytes 8..9
    ENDM

; Copying 10 bytes off the stack
CopyStackToDBL MACRO \1
    LEAU    ,S          ; Point U at the start of source data
    PULU    D,X,Y       ; Get the first 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    STU     \1+6        ; Save U at destination address + 6
    LDU     #\1+6       ; U points at the start of the destination location 
    PSHU    D,X,Y       ; Save the 6 bytes of data at the start of destination
    LDD     8,S         ; Get the last 2 bytes from the stack
    STD     8,U         ; Save the last bytes at the destination
    ENDM

DB_X_CUR               RMB 10
DB_Y_CUR               RMB 10
DB_T1                  RMB 10
;DB_T2                  RMB 10

; Constants
;DB_ZERO      FCB     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 0.0
Double_Half     FCB     $00,$FF,$FF,$10,$00,$00,$00,$00,$00,$00 ; 0.5
Double_Two      FCB     $00,$00,$01,$10,$00,$00,$00,$00,$00,$00 ; 2.0 (Used for fast 1/x calc)

; Do not rearrange the order of the SIN_COEFFS section below
Double_SIN_COEFFS
Double_1        FCB     $00,$00,$00,$10,$00,$00,$00,$00,$00,$00 ; 1.0 (a_1), Double Value of 1 ready to be used as is
                FCB     $80,$FF,$FD,$15,$55,$55,$55,$55,$55,$55 ; -1/6
                FCB     $00,$FF,$F9,$11,$11,$11,$11,$11,$11,$11 ; 1/120
                FCB     $80,$FF,$F3,$1A,$01,$A0,$19,$FA,$7A,$11 ; -1/5040
Double_OnePointFive FCB $00,$00,$00,$18,$00,$00,$00,$00,$00,$00 ; 1.5
Double_2        FCB     $00,$00,$01,$10,$00,$00,$00,$00,$00,$00 ; Double Value of 2 ready to be used as is
Double_PInf     FCB     $00,$FF,$FF,$00,$00,$00,$00,$00,$00,$00 ; +∞ (exponent all 1s, fraction 0)
Double_QNaN     FCB     $00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$01 ; canonical quiet NaN (exp=all 1s, MSB of fraction=1, payload=1)
Double_InvSqrt2 FCB     $00,$FF,$FF,$16,$A0,$9E,$66,$7F,$3B,$CD ; ≈ 0.7071067811865476 (1/√2)

DB_2PI          FCB     $00,$00,$02,$19,$21,$FB,$54,$44,$2D,$18 ; 6.283185307179586
DB_PI           FCB     $00,$00,$01,$19,$21,$FB,$54,$44,$2D,$18 ; 3.141592653589793
DB_PI_2         FCB     $00,$00,$00,$19,$21,$FB,$54,$44,$2D,$18 ; 1.5707963267948966
DB_3PI_2        FCB     $00,$00,$02,$12,$D9,$7C,$7F,$33,$21,$D2 ; 4.71238898038469
DB_NEG1         FCB     $80,$00,$00,$10,$00,$00,$00,$00,$00,$00 ; -1.0
DB_SQRT2:       FCB     $00,$00,$00,$16,$A0,$9E,$66,$7F,$3B,$CD ; 1.4142135623730951

; ===== Constants =====
; Split ln2 = LN2_HI + LN2_LO to keep r tiny after subtraction
DB_LN2:         FCB     $00,$FF,$FF,$16,$2E,$42,$FE,$FA,$39,$EE ; 0.693147180559945216

DB_LOG2E:       FCB     $00,$00,$00,$17,$15,$47,$65,$2B,$82,$FE   ; 1.4426950408889634
; (optional hi/lo split for tight range reduction)
DB_LN2_HI:      FCB     $00,$FF,$FF,$16,$2E,$42,$FE,$F1,$FC,$CC   ; 0.6931471805000000
DB_LN2_LO:      FCB     $00,$FF,$DE,$10,$7A,$46,$AF,$62,$B7,$4D   ; 0.000000000059945309... (ln2 - hi)

; ======= Coefficients for ln(m) via z=(m-1)/(m+1)
; ln(m) ≈ 2*z * [ P(t)/Q(t) ],  t=z^2,  P even, Q even
; Use n=m=4 to start (excellent accuracy); plug in fitted doubles below.

DB_LOG_COEFFS_P:  ; P(t) = p0 + p1 t + p2 t^2 + p3 t^3 + p4 t^4 + p5 t^5
                FCB     $00,$00,$00,$10,$00,$00,$00,$00,$00,$00   ; p0 = +1
                FCB     $80,$00,$01,$12,$5E,$3B,$23,$16,$03,$D4   ; p1 = -2.2960112324803763073
                FCB     $00,$00,$00,$1D,$39,$C7,$37,$5F,$05,$D4   ; p2 = +1.8266060030876944964
                FCB     $80,$FF,$FF,$12,$BD,$CF,$52,$19,$18,$50   ; p3 = -0.58567014727374022698
                FCB     $00,$FF,$FC,$10,$8D,$66,$91,$FC,$BA,$37   ; p4 = +0.064657602921877152524
                FCB     $80,$FF,$F6,$12,$4E,$59,$DB,$C3,$CA,$9A   ; p5 = -0.0011173131488787847211

DB_LOG_COEFFS_Q:  ; Q(t) = q0 + q1 t + q2 t^2 + q3 t^3 + q4 t^4 + q5 t^5
                FCB     $00,$00,$00,$10,$00,$00,$00,$00,$00,$00   ; q0 = +1
                FCB     $80,$00,$01,$15,$08,$E5,$CD,$C0,$AE,$7F   ; q1 = -2.6293445658137097887
                FCB     $00,$00,$01,$14,$06,$41,$46,$AB,$78,$D0   ; q2 = +2.5030541916922643964
                FCB     $80,$00,$00,$10,$97,$97,$8F,$9D,$10,$CE   ; q3 = -1.0370097741988959505
                FCB     $00,$FF,$FD,$16,$4D,$0B,$8C,$F9,$95,$5B   ; q4 = +0.17422623046437987759
                FCB     $80,$FF,$F9,$10,$A6,$44,$ED,$1B,$0F,$D2   ; q5 = -0.0081296334132118543148

; ===== Kernel coefficients =====
; Even
; P_e(t) = Pe0 + Pe1*t + Pe2*t^2 + Pe3*t^3 + Pe4*t^4
DB_EXP_Pe:
    FCB $00,$FF,$FF,$10,$00,$00,$00,$00,$00,$00 ; Pe0 = +0.5
    FCB $00,$FF,$FB,$11,$17,$5D,$9B,$EA,$73,$C7   ; Pe1 ≈ +0.0333813908411922308
    FCB $00,$FF,$F5,$19,$0D,$4C,$BE,$5B,$71,$FE   ; Pe2 ≈ +0.000764524910404740026
    FCB $00,$FF,$EE,$1D,$4A,$04,$B8,$C3,$DD,$5F   ; Pe3 ≈ +6.98307384205203057e-06
    FCB $00,$FF,$E6,$18,$BE,$F5,$DD,$CC,$B4,$7A   ; Pe4 ≈ +2.30464517358768747e-08

; Q_e(t) = 1 + Qe1*t + Qe2*t^2 + Qe3*t^3 + Qe4*t^4
DB_EXP_Qe:
    FCB $00,$00,$00,$10,$00,$00,$00,$00,$00,$00 ; Qe0 = +1.00
    FCB $80,$FF,$FA,$10,$F7,$DE,$E5,$AB,$86,$3B   ; Qe1 ≈ −0.0165705516509488775
    FCB $00,$FF,$F3,$11,$52,$43,$6D,$EA,$66,$55   ; Qe2 ≈ +0.000132151347277442238
    FCB $80,$FF,$EB,$14,$D0,$96,$02,$2D,$A8,$39   ; Qe3 ≈ −6.2032905066606525e-07
    FCB $00,$FF,$E2,$19,$DD,$3F,$98,$9B,$2A,$89   ; Qe4 ≈ +1.50549758980891077e-09

; Odd
; P_o(t) = Po0 + Po1*t + Po2*t^2 + Po3*t^3 + Po4*t^4
DB_EXP_Po:
    FCB $00,$00,$00,$10,$00,$00,$00,$00,$00,$00 ; Po0 = +1.0
    FCB $00,$FF,$FD,$12,$E5,$76,$31,$5B,$E5,$17   ; Po1 ≈ +0.147627615071350887
    FCB $00,$FF,$F8,$15,$DC,$E0,$5C,$EF,$33,$86   ; Po2 ≈ +0.00533759729200944909
    FCB $00,$FF,$F2,$11,$E9,$BE,$A4,$82,$A5,$81   ; Po3 ≈ +6.8332920934685237e-05
    FCB $00,$FF,$EA,$13,$BB,$E8,$40,$DF,$4B,$09   ; Po4 ≈ +2.94059703584749151e-07

; Q_o(t) = 1 + Qo1*t + Qo2*t^2 + Qo3*t^3 + Qo4*t^4
DB_EXP_Qo:
    FCB $00,$00,$00,$10,$00,$00,$00,$00,$00,$00 ; Qo0 = +1.0
    FCB $80,$FF,$FA,$13,$7E,$F9,$1F,$CB,$81,$F3   ; Qo1 ≈ −0.0190390515953157806
    FCB $00,$FF,$F3,$17,$41,$DF,$55,$42,$56,$21   ; Qo2 ≈ +0.000177439224562079618
    FCB $80,$FF,$EC,$10,$AE,$22,$8E,$79,$9C,$A2   ; Qo3 ≈ −9.94218277394929391e-07
    FCB $00,$FF,$E3,$19,$6D,$9A,$83,$B7,$A5,$99   ; Qo4 ≈ +2.96022497984612227e-09

; Coefficients for atan(x) rational approximation (odd polynomials, degree 7/6)
DB_ATAN_COEFFS_P: ; P(x) = c1*x + c3*x^3 + c5*x^5 + c7*x^7
    FCB $00,$FF,$FF,$1F,$FF,$FF,$FF,$41,$D5,$41   ; p0 ≈ +0.9999999986163531
    FCB $00,$00,$00,$11,$F8,$FA,$EA,$29,$E1,$4D   ; p1 ≈ +1.1232861659064668
    FCB $00,$FF,$FE,$12,$13,$9F,$54,$E9,$9F,$EA   ; p2 ≈ +0.2824476556038450
    FCB $00,$FF,$F9,$11,$C4,$4F,$A5,$D4,$2E,$11   ; p3 ≈ +0.0086752150041525
DB_ATAN_COEFFS_Q: ; Q(x) = d0 + d2*x^2 + d4*x^4 + d6*x^6
    FCB $00,$00,$00,$10,$00,$00,$00,$00,$00,$00 ; q0 = +1.0  (fixed)
    FCB $00,$00,$00,$17,$4E,$50,$10,$AF,$32,$66   ; q1 ≈ +1.4566193248494072
    FCB $00,$FF,$FF,$12,$2C,$FB,$5E,$05,$29,$A5   ; q2 ≈ +0.5679909550029164
    FCB $00,$FF,$FB,$19,$59,$7A,$14,$42,$14,$5D   ; q3 ≈ +0.04951077935496848

    opt     c
    opt     ct
    opt     cc       * show cycle count, add the counts, clear the current count
    
DO_FAST_INVERT_DOUBLE EQU 0
 IF DO_FAST_INVERT_DOUBLE
;     sign: sign(1/x) = sign(x)
; exponent: exponent(1/x) = − exponent(x)
; mantissa: mantissa(1/x) ≈ reciprocal of mantissa(x)
INVERT_DOUBLE:
    PULS    U
    STU     @Return+1
; 1) Get a fast low-precision reciprocal seed
    LDA     ,S          ; get the sign
    STA     @YVAL       ; Save the sign
    LDD     1,S         ; Get the original exponent
; Negate D (16-bit two's complement negation)
    NEGA                ; Negate A (8-bit two's complement: -A = ~A + 1)
    NEGB                ; Negate B (8-bit two's complement: -B = ~B + 1)
    SBCA    #0          ; Subtract 0 from A with borrow (propagate carry from NEGB)
    STD     @YVAL+1     ; Save the negative exponent
    LDD     3,S         ; high word of mantissa (implied 1.mmmmmmmm)
    LSLB
    ROLA
    LSLB
    ROLA
    LSLB
    ROLA                ; Keep the most significant bits after the impiled 1 bit)
    ANDA    #%01111111
    LDU     #DB_RecipTable
    LDB     A,U             ; 8-bit reciprocal
    CLRA
    LSLB
    ROLA
    LSLB
    ROLA
    LSLB
    ROLA
    LSLB
    ROLA                ; D has the most significant bits of the mantissa
    STD     @YVAL+3
    LDD     #$0000
    STD     @YVAL+5
    STD     @YVAL+7
    STA     @YVAL+9
;
; Copying 10 bytes off the stack
    LEAU    ,S          ; Point U at the start of source data
    PULU    D,X,Y       ; Get the first 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    STU     @XVAL+6      ; Save U at destination address + 6
    LDU     #@XVAL+6     ; U points at the start of the destination location 
    PSHU    D,X,Y       ; Save the 6 bytes of data at the start of destination
    LDD     8,S         ; Get the last 2 bytes from the stack
    STD     8,U         ; Save the last bytes at the destination
;
; Copying 10 bytes onto the stack
    LDU     #@YVAL+2    ; Point U at the start of source data + 2
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
    LDD     @YVAL       ; Get the first 2 bytes of data
    PSHS    D           ; Push them on the stack
;
; 2) First Newton iteration:   y1 = y0*(2 – x*y0)
    JSR     DB_MUL              ; ,S = x * y0          (10,S * ,S)
    LDU     #Double_2+2
    PULU    D,X,Y
    LDU     ,U
    PSHS    D,X,Y,U         ; push 2.0
    LDD     Double_2
    PSHS    D
    JSR     DB_SUB          ; 2 – z  (10,S – ,S)
    LDA     ,S
    EORA    #$80            ; flip sign
    STA     ,S              ; now = 2.0 - t
; Copying 10 bytes onto the stack
    LDU     #@YVAL+2    ; Point U at the start of source data + 2
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
    LDD     @YVAL       ; Get the first 2 bytes of data
    PSHS    D           ; Push them on the stack
;
    JSR     DB_MUL      ; ,S = y0 * (2 – x*y0)   → y1  (≈ 16–18 bit accurate)
;
@Return:
    JMP     >$FFFF      ; Self mod Return address above
;
@XVAL   RMB 10
@YVAL   RMB 10
;
DB_RecipTable:
    FCB $FF,$FE,$FC,$FA,$F8,$F6,$F4,$F2  ; i=0 to 7
    FCB $F0,$EF,$ED,$EB,$EA,$E8,$E6,$E5  ; 8-15
    FCB $E3,$E1,$E0,$DE,$DD,$DB,$DA,$D9  ; 16-23
    FCB $D7,$D6,$D4,$D3,$D2,$D0,$CF,$CE  ; 24-31
    FCB $CC,$CB,$CA,$C9,$C7,$C6,$C5,$C4  ; 32-39
    FCB $C3,$C1,$C0,$BF,$BE,$BD,$BC,$BB  ; 40-47
    FCB $BA,$B9,$B8,$B7,$B6,$B5,$B4,$B3  ; 48-55
    FCB $B2,$B1,$B0,$AF,$AE,$AD,$AC,$AB  ; 56-63
    FCB $AA,$A9,$A8,$A8,$A7,$A6,$A5,$A4  ; 64-71
    FCB $A3,$A3,$A2,$A1,$A0,$9F,$9F,$9E  ; 72-79
    FCB $9D,$9C,$9C,$9B,$9A,$99,$99,$98  ; 80-87
    FCB $97,$97,$96,$95,$94,$94,$93,$92  ; 88-95
    FCB $92,$91,$90,$90,$8F,$8F,$8E,$8D  ; 96-103
    FCB $8D,$8C,$8C,$8B,$8A,$8A,$89,$89  ; 104-111
    FCB $88,$87,$87,$86,$86,$85,$85,$84  ; 112-119
    FCB $84,$83,$83,$82,$82,$81,$81,$80  ; 120-127

 ELSE
; Assume x is at ,S (value to invert)
; Result: 1/x at ,S
INVERT_DOUBLE:
    PULS    U               ; Get return address
    STU     @Return+1       ; Self mod return address
    PULL_DBL    DB_T1       ; Get x off the stack
; Copy double value of one at ,S
    PUSH_DBL    Double_1    ; PUSH Double Value of one onto the stack
    PUSH_DBL    DB_T1       ; Put x on the stack
    JSR     DB_DIV          ; Divide 10,S / ,S then S=S+10, result is @ ,S
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
 ENDIF

; ------------------------------------------------------------
; DB_SQRT  --  Compute sqrt(x) for IEEE-754 double
; In : x @ ,S
; Out: sqrt(x) @ ,S
; Uses: DB_MUL, DB_ADD, DB_SUB, DB_DIV
; Scratch: DB_Y_CUR, DB_T1, (10 bytes each)
; ------------------------------------------------------------
DB_SQRT:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
; Check for a valid number
    LDB     ,S          ; Get the SIGN
    LBMI    @NotANumber ; Can't get square root of a negative number
    LDX     1,S         ; Get the EXPonent
    BNE     >           ; If it's not zero then number is not a zero, check if it's special
; Check Mantissa MSbit, could be a zero
    LDA     3,S         ; Get the mantissa MSB
    BITA    #%00010000  ; If Most Significant bit is zero then this is zero
    LBEQ    @Return     ; Bit must normally be set, if it's not then this is a zero
!   CMPX    #$8000
    LBEQ    @Return     ; If it's not zero then it could be Infinity or NAN
; ============================================================
;  x is a finite, non-NaN, non-zero IEEE double at ,S (10 bytes)
;  We will:
;    - convert x -> internal format DB_X_CUR
;    - set y0 = x (initial guess)
;    - iterate y = 0.5 * (y + x/y) a few times
;    - return sqrt(x) as IEEE double @ ,S
; ============================================================
;
;---------- Convert IEEE x on stack into internal DB_X_CUR ----------
;  or in a known place; adapt to your own calling convention.
;
;  Initial guess y0 = x  (good enough; NR will converge quickly)
    CopyStackToDBL DB_Y_CUR
    PULL_DBL DB_X_CUR        ; internal x -> DB_X_CUR[]
;
    LDD     DB_Y_CUR+1      ; D = e (unbiased exponent, signed)
    ASRA                    ; k = e / 2 (arithmetic right shift)
    RORB                    ; (floor for negative e too)
    STD     DB_Y_CUR+1
;
;---------- Newton-Raphson iterations y = 0.5*(y + x/y) ----------
;  Choose 3 iterations: usually enough for good precision.
    LDA     #3
    PSHS    A
;
@NR_Loop:
; t1 = x / y
    PUSH_DBL DB_X_CUR           ; push x
    PUSH_DBL DB_Y_CUR           ; push y
    JSR     DB_DIV           ; (10,S) / (S) -> result @ ,S
    PULL_DBL DB_T1               ; t1 = x / y
;
; y = 0.5 * (y + t1)
; First: y = y + t1  (result -> DB_Y_CUR)
    PUSH_DBL DB_Y_CUR           ; push y
    PUSH_DBL DB_T1              ; push t1
    JSR     DB_ADD           ; (10,S) + (S) -> result @ ,S
    PULL_DBL DB_Y_CUR            ; y = y + t1
;
; Then: y = y * 0.5
    PUSH_DBL DB_Y_CUR
    PUSH_DBL Double_Half     ; constant 0.5 in internal format
    JSR     DB_MUL           ; y * 0.5
    PULL_DBL DB_Y_CUR            ; y = 0.5 * (y + t1)
;
; loop
    DEC     ,S
    LBNE    @NR_Loop
    LEAS    1,S               ; Fix the stack
;
;---------- Convert final y back to IEEE and return ----------
; Put y back on stack in internal format
    PUSH_DBL DB_Y_CUR
;
@Return:
    JMP     >$FFFF           ; self-modified return (set at entry)
;
; We set Not a Number to zero
@NotANumber:
    LEAS    10,S
    LDD     #$0000
    LDX     #$0000
    LEAY    ,X
    PSHS    D,X,Y
    LDD     #$0080
    PSHS    D,X
    JMP     @Return

; DB_HORNER_EVEN: Evaluate an even-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (10 bytes, double-precision)
;     10,S: Pointer to coefficient table (2 bytes)
;     12,S: Number of coefficients (n+1, 1 byte, for degrees 0, 2, ..., 2n)
; Output:
;   RESULT: S=S+3, result @ ,S = Polynomial value (10 bytes, double-precision)
; Clobbers: A, B, X, Y, U
DB_HORNER_EVEN:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self mod return address
; Put x on the stack again
    LEAU    2,S         ; U points to x+2
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
    LDD     8,S         ; Get the first 2 bytes of data
    PSHS    D           ; push x on the stack
; Compute x^2
    JSR     DB_MUL      ; RESULT * x^2, result at ,S, S=S+10
; Copy result to Temp
    PULL_DBL  DB_HORE_Temp     ; PULL DB_HORE_Temp off the stack
;
; Initialize result with highest-degree coefficient (a_2n)
    LDB     2,S         ; Load number of coefficients (n+1)
    DECB                ; Index of next coefficient
    LDA     #10
    MUL                 ; Multiply by 10 for byte offset in B
    LDX     ,S          ; X = coefficient table pointer
    ABX                 ; X points to a_2n
; Copy a_2n to RESULT
    STX     @SefMod1+1  ; Self mod the source address start
    LEAU    2,X         ; U=X, U points to a_2n
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
@SefMod1:
    LDD     >$FFFF      ; (self mod) Get the first 2 bytes of data
    PSHS    D           ; Push them on the stack
;
; Horner's method loop: RESULT = x^2 * RESULT + next_coefficient
@HORNER_LOOP:
    DEC     12,S        ; n, then n-1, ..., 0
    BEQ     @DONE       ; Exit if no more coefficients
; Push x^2 onto stack
    PUSH_DBL DB_HORE_Temp      ; PUSH DB_HORE_Temp onto the stack
; Result is already on the stack
; Multiply: RESULT = RESULT * x^2
    JSR     DB_MUL      ; RESULT * x^2, result at ,S, S=S+10
; Push next coefficient
    LDB     12,S        ; Load current index (n)
    DECB                ; Index of next coefficient
    LDA     #10
    MUL                 ; Multiply by 10 for byte offset in B
    LDX     10,S        ; X = coefficient table pointer
    ABX                 ; X points to next coefficient
; Copy coefficient to stack
    STX     @SefMod2+1  ; Self mod the source address start
    LEAU    2,X         ; U=X, U points to a_2n
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
@SefMod2:
    LDD     >$FFFF      ; (self mod) Get the first 2 bytes of data
    PSHS    D           ; Push them on the stack
;
; Add: RESULT = RESULT + coefficient
    JSR     DB_ADD       ; RESULT + coefficient, result at ,S, S=S+10
; Leave RESULT on the stack
    BRA     @HORNER_LOOP
@DONE:
; clean up the stack, copy RESULT on the stack and return
    LDD     8,S
    STD     8+3,S
    PULS    D,X,Y,U     ; Get the result
    LEAS    3,S         ; clean up the stack pointer
    PSHS    D,X,Y,U     ; Save the result on the Stack
@Return:
    JMP     >$FFFF      ; Return, self modified jump address
; Data section
DB_HORE_Temp      RMB 10       ; Temporary storage for x^2

; DB_HORNER_ODD: Evaluate an odd-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (10 bytes, double-precision)
;     10,S: Pointer to coefficient table (2 bytes)
;     12,S: Number of coefficients (n+1, 1 byte, for degrees 1, 3, ..., 2n+1)
; Output:
;   RESULT: S=S+3, result @ ,S = Polynomial value (10 bytes, double-precision)
; Clobbers: A, B, X, Y, U
DB_HORNER_ODD:
    PULS    U           ; Get return address
    STU     @Return+1    ; Self-modify return address
; Copy x to TEMP_X for safekeeping
    LEAU    ,S          ; Point U at the start of source data
    PULU    D,X,Y       ; Get the first 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    STU     DB_Hor_TEMP_X+6      ; Save U at destination address + 6
    LDU     #DB_Hor_TEMP_X+6     ; U points at the start of the destination location 
    PSHU    D,X,Y       ; Save the 6 bytes of data at the start of destination
    LDD     8,S         ; Get the last 2 bytes from the stack
    STD     8,U         ; Save the last bytes at the destination
; Put x on the stack again
    LEAU    2,S         ; U points to x+2
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
    LDD     8,S         ; Get the first 2 bytes of data
    PSHS    D           ; push x on the stack
; Compute x^2
    JSR     DB_MUL      ; RESULT * x^2, result at ,S, S=S+10 Result = 00 FF F6 1B 8A A0 01 92 A7 1B
; Copy result to Temp
    PULL_DBL  DB_HORO_Temp     ; PULL Temp off the stack
;
; Initialize result with highest-degree coefficient (a_2n+1)
    LDB     2,S         ; Load number of coefficients (n+1)
    DECB                ; Index of next coefficient
    LDA     #10
    MUL                 ; Multiply by 10 for byte offset
    LDX     ,S          ; X = coefficient table pointer
    ABX                 ; X points to a_2n+1
; Copy a_2n+1 to RESULT
    STX     @SefMod1+1  ; Self mod the source address start
    LEAU    2,X         ; U=X, U points to a_2n
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
@SefMod1:
    LDD     >$FFFF      ; (self mod) Get the first 2 bytes of data
    PSHS    D           ; Save value as the RESULT on the stack
;
; Horner's method loop: RESULT = x^2 * RESULT + next_coefficient
@HORNER_LOOP:
    DEC     12,S         ; n, then n-1, ..., 0
    BEQ     @FINAL_MUL  ; Exit loop if no more coefficients
; Push x^2 onto stack
    PUSH_DBL DB_HORO_Temp      ; PUSH Temp onto the stack
; RESULT on the stack
; Multiply: RESULT = RESULT * x^2
    JSR     DB_MUL      ; RESULT * x^2, result at ,S, S=S+10 result = 00 FF E1 10 FC 08 FC D5 BE 43
;
; Push next coefficient
    LDB     12,S        ; Load current index (n)
    DECB                ; Index of next coefficient
    LDA     #10
    MUL                 ; Multiply by 8 for byte offset
    LDX     10,S         ; X = coefficient table pointer
    ABX                 ; X points to next coefficient
; Copy coefficient to stack
    STX     @SefMod2+1  ; Self mod the source address start
    LEAU    2,X         ; U=X, U points to a_2n
    PULU    D,X,Y       ; Get the 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
@SefMod2:
    LDD     >$FFFF      ; (self mod) Get the first 2 bytes of data
    PSHS    D           ; Push them on the stack
;
; Add: RESULT = RESULT + coefficient
    JSR     DB_ADD      ; RESULT + coefficient, result at ,S, S=S+10
; Leave RESULT on the stack
    BRA     @HORNER_LOOP
@FINAL_MUL:
; Multiply RESULT by x to account for odd-degree polynomial
    PUSH_DBL DB_Hor_TEMP_X      ; PUSH variable onto the stack
; Leave RESULT on the stack
    JSR     DB_MUL      ; RESULT * x, result at ,S, S=S+10
; clean up the stack, copy RESULT on the stack and return
    LDD     8,S
    STD     8+3,S
    PULS    D,X,Y,U     ; Get the result
    LEAS    3,S         ; clean up the stack pointer
    PSHS    D,X,Y,U     ; Save the result on the Stack
@Return:
    JMP     >$FFFF      ; Return, self modified jump address
;
; Data section
DB_HORO_Temp    RMB 10       ; Temporary storage for x^2
DB_Hor_TEMP_X   RMB 10       ; Temporary storage for x

; DB_RATIONAL: Evaluate rational function P(x)/Q(x) using two Horner chains
; Input:
;   Stack:
;     ,S: x (10 bytes, 10 byte double-precision)
;     10,S: P coefficient table pointer (2 bytes)
;     12,S: P number of coefficients (n+1, 1 byte)
;     13,S: P type (0=even, 1=odd, 1 byte)
;     14,S: Q coefficient table pointer (2 bytes)
;     16,S: Q number of coefficients (m+1, 1 byte)
;     17,S: Q type (0=even, 1=odd, 1 byte)
; Output:
;   RESULT: S=S+6 ,S = P(x)/Q(x) (10 bytes, double-precision)
; Clobbers: A, B, X, Y, U
DB_RATIONAL:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self-modify return address
; Evaluate P(x)
; Push params for P: x, P ptr, P num coeffs
    LEAU    10,S
    PULU    A,X
    PSHS    A,X         ; copy P coefficient table pointer (2 bytes) & P number of coefficients (n+1, 1 byte) on the stack
;
    LEAU    3+2,S       ; copy x (10 bytes, double-precision) on the stack
    PULU    D,X,Y       ; Get 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
    LDD     3+8,S       ; Get the first 2 bytes of data
    PSHS    D           ; Push them on the stack
; P(x) is now ready to be evaluated
; Call appropriate Horner based on P type
    LDA     13+13,S     ; P type (1 byte: 0=even, 1=odd)
    BEQ     @CallEvenP
    JSR     DB_HORNER_ODD   ; Evaulate, S=S+3, result @ ,S
    BRA     @StoreP
@CallEvenP:
    JSR     DB_HORNER_EVEN  ; Evaulate, S=S+3, result @ ,S
@StoreP:
; Copy RESULT to TEMP_P
    PULL_DBL  DB_Rational_TempP     ; PULL DB_Rational_TempP off the stack
; Evaluate Q(x)
; Push params for Q: x, Q ptr, Q num coeffs
    LEAU    14,S
    PULU    A,X
    PSHS    A,X         ; copy P coefficient table pointer (2 bytes) & P number of coefficients (n+1, 1 byte) on the stack
;
    LEAU    3+2,S       ; copy x (10 bytes, double-precision) on the stack
    PULU    D,X,Y       ; Get 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    PSHS    D,X,Y,U     ; Push them on the stack
    LDD     3+8,S       ; Get the first 2 bytes of data
    PSHS    D           ; Push them on the stack
; Q(x) is now ready to be evaluated
; Call appropriate Horner based on Q type
    LDA     17+13,S     ; Q type (1 byte: 0=even, 1=odd)
    BEQ     @CallEvenQ
    JSR     DB_HORNER_ODD   ; Evaulate, S=S+3, result @ ,S
    BRA     @StoreQ
@CallEvenQ:
    JSR     DB_HORNER_EVEN  ; Evaulate, S=S+3, result @ ,S
@StoreQ:
; Copy RESULT to TEMP_Q
    PULL_DBL  DB_Rational_TempQ     ; PULL DB_Rational_TempQ off the stack
; Restore stack after Q eval
    LEAS    18,S        ; Clear all from the stack
; Divide P / Q
; Push TEMP_P
    PUSH_DBL DB_Rational_TempP      ; PUSH DB_Rational_TempP onto the stack
; Push TEMP_Q
    PUSH_DBL DB_Rational_TempQ      ; PUSH DB_Rational_TempQ onto the stack
    JSR     DB_DIV      ; Divide P / Q, S=S+10, result at ,S
; Final Result is on the stack
@Return:
    JMP >$FFFF       ; Return, self-modified
;
; Data section
DB_Rational_TempP    RMB 10      ; Temporary for P(x)
DB_Rational_TempQ    RMB 10     ; Temporary for Q(x)

; ================================================================
; DB_MOD -- Calculate the remainder of division using:
; remainder = dividend - (floor(dividend / divisor) * divisor)
; Entry: dividend is @ 10,S and the divisor is @ ,S then S=S+10 result is @ ,S
; Clobbers: A,B,D,X,Y,U
; ================================================================
DB_MOD:
    PULS  U             ; pull return address
    STU   @Return+1     ; self-modify return target
; Backup the Dividend and the divisor
; Copying 20 bytes from the stack back onto the stack
    LDB     #10
!   LDX     18,S
    PSHS    X
    DECB
    BNE     <
    JSR     DB_DIV      ; Divide 10,S / ,S Then S=S+10 result @ ,S
    JSR     DB_FLOOR    ; Compute floor(x) x is @ ,S return with Double value @,S which is the INTeger vale of ,S
    JSR     DB_MUL      ; Multiply 10,S * ,S Then S=S+10 result @ ,S
    JSR     DB_SUB      ; Subtract 10,S - ,S Then S=S+10 result @ ,S
@Return:
    JMP     >$FFFF      ; patched by PULS U at entry
;--------------------------------------------------------------


; ================================================================
; DB_FLOOR  --  Return greatest integer ≤ x  (floor)
; Entry: 10-byte unpacked double x at ,S   (after PULS U)
; Exit:  10-byte unpacked double floor(x) at ,S
; Uses:  DB_TO_S64, S64_To_Double, DB_SUB
; Clobbers: A,B,D,X,Y,U
; ================================================================
DB_FLOOR:
    PULS    U                   ; pull return address
    STU     @Return+1           ; self-modify return target
;--------------------------------------------------------------
; Save original x and its sign
;--------------------------------------------------------------
    CopyStackToDBL DB_Floor_X ;  Copy 10 Byte double from the stack to variable DB_Floor_X
;--------------------------------------------------------------
; x -> signed 64-bit integer (truncate toward zero),
; then back to double n = trunc(x) in the same 10-byte slot.
;--------------------------------------------------------------
    JSR     DB_TO_S64           ; 10-byte slot at ,S now holds S64
    JSR     S64_To_Double       ; 10-byte slot at ,S now holds double n
;
    LDA     DB_Floor_X          ; Get the original sign value
    BPL     @Return             ; If it was positive then we are done
;
; Save n in DB_Floor_N (as double)
    CopyStackToDBL DB_Floor_N ;  Copy 10 Byte double from the stack to variable DB_Floor_N
;
;--------------------------------------------------------------
; If original x >= 0, floor(x) = n
;--------------------------------------------------------------
    LDA     DB_Floor_X
    BPL     @NonNegative        ; sign bit clear => x >= 0
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
    LEAS  10,S              ; drop current n from stack (we have it in FFP_FLOOR_N)
    PUSH_DBL DB_Floor_X     ; Value2 = x   goes to 3,S after next push
    PUSH_DBL DB_Floor_N     ; Value1 = n   goes to ,S
    JSR     DB_SUB          ; d = n - x  (result at ,S)
;
    ; Test if d == 0  (all 10 bytes zero?)
    LDD     2,S                 ; Exponent LSB & Mantissa MSB, first
    BNE     @NegFraction
    LDD     0,S
    BNE     @NegFraction
    LDD     4,S
    BNE     @NegFraction
    LDD     6,S
    BNE     @NegFraction
    LDD     8,S
    BEQ     @NegInteger         ; d == 0 => x was exact integer
;
;---------- Negative, fractional: floor(x) = n - 1.0 ----------
@NegFraction:
    ; Reload n into ,S
    LEAS    10,S
    ; Push +1.0 so DB_SUB does n - 1.0
    PUSH_DBL DB_Floor_N      ; PUSH DB_Floor_N onto the stack
    PUSH_DBL Double_1      ; PUSH Double_1 onto the stack
;
;
    JSR     DB_SUB              ; (10,S - ,S) => n - 1.0 at ,S
    BRA     @Return
;
;---------- Negative, integer: floor(x) = n ----------
@NegInteger:
    ; Just reload n into ,S (overwrite d)
; *** Code below does the same thing
;    LEAS    10,S
;    PUSH_DBL DB_Floor_N      ; PUSH DB_Floor_N onto the stack
;    BRA     @Return
;
;--------------------------------------------------------------
; Non-negative x: floor(x) = n (truncate)
;--------------------------------------------------------------
@NonNegative:
    ; Copy n into ,S in case anything modified it
    LEAS    10,S
    PUSH_DBL DB_Floor_N      ; PUSH DB_Floor_N onto the stack
;
@Return:
    JMP     >$FFFF              ; patched by PULS U at entry
;
DB_Floor_X      RMB 10      ; original x (10-byte double)
DB_Floor_N      RMB 10      ; trunc(x) as double
;DB_Floor_Sign   RMB 1       ; original sign byte (from x[0])

; DB_EXP: Compute exp(x) for double-precision input
; Input:
;   ,S: x (10 bytes, double)
; Output:
;   ,S: exp(x) (10 bytes), S unchanged
; Clobbers: A, B, X, Y, U
;
; Strategy:
;   1) k = round(x * LOG2E)
;   2) r = x - k*LN2_hi - k*LN2_lo          (|r| ≤ ln2/2)
;   3) y = 1 + r * P(r^2) / Q(r^2)          (kernel via DB_RATIONAL)
;   4) result = ldexp(y, k)                 (adjust exponent by k)
;
DB_EXP:
    PULS    U
    STU     @Return+1
;
; === 0) handle special small/huge x quickly (optional: can skip initially) ===
; You can add early-outs here (e.g., if |x| is tiny -> 1+x, if x too large -> overflow to INF, etc.)
;
; === 1) Copy x to TEMP_X (we'll need it several times) ===
    CopyStackToDBL DB_Exp_TEMP_X ;  Copy 10 Byte double from the stack to variable DB_Exp_TEMP_X
;
; === 2) k = round(x * LOG2E) ===
; x is already on the stack
; Push LOG2E, then multiply: x*LOG2E
    PUSH_DBL DB_LOG2E ; PUSH LOG2E onto the stack
;
    JSR     DB_MUL       ; -> x*LOG2E at ,S
; Round to nearest integer: k = floor(x*LOG2E + 0.5)
; Push .5 onto the stack
    PUSH_DBL Double_Half ; PUSH 0.5 onto the stack
;    
    JSR     DB_ADD       ; x*LOG2E + 0.5
;
    JSR     DB_FLOOR     ; integer double at ,S (k as double)
; Save k (double) into DB_Exp_K
    CopyStackToDBL DB_Exp_K ;  Copy 10 Byte double from the stack to variable DB_Exp_K
;
; Also store k as signed 16-bit (for exponent adjust)
    JSR     DB_TO_S64   ; Convert 10 byte Double @ ,S to Signed 64-bit Integer @ ,S
    PULS    D,X,Y,U     ; Pull signed 64 bit number off the stack
    STU     DB_Exp_K_Int      ; Save Least Significant 16-bit value to K_INT
;
; === 3) r = x - k*LN2_hi - k*LN2_lo  (compensated split) ===
; r0 = x - k*LN2_hi
; tmp = k * LN2_hi
    PUSH_DBL DB_Exp_K     ; PUSH k onto the stack
    PUSH_DBL DB_LN2_HI ; PUSH LN2_hi onto the stack
;
    JSR     DB_MUL      ; k*LN2_hi
; r0 = x - tmp
    PUSH_DBL DB_Exp_TEMP_X ; PUSH x onto the stack
;
    JSR     DB_SUB           ; x - k*LN2_hi
; Subtract was in the wrong order so flip the sign
      LDA   ,S
      EORA  #%10000000
      STA   ,S
; stack: r0 at ,S
;
; r = r0 - k*LN2_lo
    ; tmp2 = k * LN2_lo
    PUSH_DBL DB_LN2_LO ; PUSH LN2_lo onto the stack
    PUSH_DBL DB_Exp_K     ; PUSH DB_Exp_K onto the stack
;    
    JSR     DB_MUL      ; k*LN2_lo
; stack now: ,S=tmp2, 10,S=r0
; r = r0 - tmp2
      JSR   DB_SUB           ; (r0) - (k*LN2_lo) -> r at ,S
;
; Save r (double) into DB_Exp_TEMP_R
    CopyStackToDBL DB_Exp_TEMP_R ;  Copy 10 Byte double from the stack to variable DB_Exp_TEMP_R
;
; === 4) Kernel: y = 1 + r * P(t)/Q(t), t = r^2 ===
; We’ll compute t=r^2 inside the Horner routines automatically:
; Your DB_HORNER_* do t=x^2 internally; so we pass r as "x" to DB_RATIONAL.
;
; Push DB_RATIONAL params: Q even (m+1=5), P odd (n+1=5)
; ---------- Odd term:  r * (Po/Qo) ----------
    LDB     #0              ; Q type = even
    PSHS    B
    LDB     #5              ; Q count (q0..q4)
    PSHS    B
    LDD     #DB_EXP_Qo
    PSHS    D
    LDB     #1              ; P type = odd
    PSHS    B
    LDB     #5              ; P count (p0..p4)
    PSHS    B
    LDD     #DB_EXP_Po
    PSHS    D
; r saved here
    PUSH_DBL DB_Exp_TEMP_R        ; PUSH r onto the stack
;
    JSR     DB_RATIONAL     ; -> odd_term = r * (Po/Qo) at ,S
; Leave Odd_term is on the stack
;
; ---------- Even term: 1 + t * (Pe/Qe) ----------
    LDB  #0              ; Q type = even
    PSHS B
    LDB  #5              ; Q count = 5
    PSHS B
    LDD  #DB_EXP_Qe
    PSHS D
    LDB  #0              ; P type = even
    PSHS B
    LDB  #5              ; P count = 5
    PSHS B
    LDD  #DB_EXP_Pe
    PSHS D
; push r as "x" (DB_HORNER_EVEN uses t=x^2 internally)
    PUSH_DBL DB_Exp_TEMP_R        ; PUSH r onto the stack
;
    JSR     DB_RATIONAL     ; -> Ce = Pe/Qe at ,S
;
; multiply by t = r^2
; Leave Ce on the stack
;
; form t = r * r
    PUSH_DBL DB_Exp_TEMP_R        ; PUSH r onto the stack
    PUSH_DBL DB_Exp_TEMP_R        ; PUSH r onto the stack
;
    JSR     DB_MUL      ; -> t at ,S
;
; multiply Ce * t
; Ce is already on the stack
    JSR     DB_MUL      ; -> t*Ce at ,S
;
; add 1.0 to get even_term
    PUSH_DBL Double_1       ; PUSH 1.0 onto the stack
;
    JSR     DB_ADD          ; even_term at ,S
;
; ---------- Sum even + odd ----------
; push odd_term ; push even_term ; ADD
; odd-term is already on the stack
    JSR      DB_ADD          ; y ≈ exp(r) at ,S
;
; === 5) Scale by 2^k: result = ldexp(y, k) ===
; Unpack y, add k to exponent, repack
    LDD     DB_Exp_K_Int          ; Get the K value
    ADDD    1,S             ; add it to the exponent
    STD     1,S             ; save the new exponent
;
    LDD     ,S
    STD     10,S
    LDD     2,S
    STD     12,S
    LDD     4,S
    STD     14,S
    LDD     6,S
    STD     16,S
    LDD     8,S
    STD     18,S
    LEAS    10,S
;
@Return:
    JMP     >$FFFF      ; return (self modified)
;
; ===== Data / temporaries =====
DB_Exp_TEMP_X   RMB 10
DB_Exp_TEMP_R   RMB 10
DB_Exp_K        RMB 10
DB_Exp_K_Int    RMB 2

; DB_LOG: Compute natural logarithm ln(x)
; Input:
;   ,S: x (10 byte double)
; Output:
;   ,S: ln(x) (double), S unchanged
; Clobbers: A,B,X,Y,U
;
DB_LOG:
    PULS    U
    STU     @Return+1
; ========= Special cases (optional but recommended) =========
; If x <= 0: handle domain
;   x = 0  ->  -INF
;   x < 0  ->  NaN  (or choose to signal/return 0)
; You can skip these to start if you prefer.
    LDD     ,S
    BNE     @CheckNeg
    LDD     2,S
    BNE     @CheckNeg
    LDD     4,S
    BNE     @CheckNeg
    LDD     6,S
    BNE     @CheckNeg
    LDD     8,S
    BNE     @CheckNeg
; We get here if it is zero, return with a -INF
; Value Sign    Exponent (unbiased) Mantissa
; -∞    1       $8000               Most Significant bit is 0
    CLRA
!   LDX     #$0000
    LEAY    ,X
    LEAU    ,U
    LEAS    10,S        Fix the stack so we can blast it
    PSHS    A,X,Y,U
    LDA     #$80
    LDX     #$8000
    PSHS    A,X
    JMP     @Return
@CheckNeg:
    LDA     ,S
    BPL     @DoLog      ; If positive we are good
; We get here when it is a negative number, return with NaN
; NaN   Any     All 1s              Non-zero
    LDA     #$FF        ; Mantissa first (MS) byte
    BRA     <
; ========= Normalize: x = m * 2^e, m in [sqrt(1/2), sqrt(2)) =========
; Copy x -> DB_Log_TEMP_X
@DoLog:
    PULL_DBL  DB_Log_TEMP_X     ; PULL Variable off the stack@DoLog:
;
; Get EXP and MANT and put mantissa into [1,2]
    PULU    A,X                 ; Get the sign & Exponent
    STA     SIGN
; Save unbiased exponent e in DB_Log_E_SInt (signed 16-bit).
    STX     EXP
    STX     DB_Log_E_SInt       ; store EXP (or convert to signed)
;
    PULU    A,X,Y
    LDU     DB_Log_TEMP_X+8
    STU     MANT+5
    STU     RESULT+8
    LDU     #MANT+5
    PSHU    A,X,Y               ; Save it @MANT, U=MANT
    LDU     #RESULT+8
    PSHU    A,X,Y               ; Save it @MANT, U=MANT
    LDA     SIGN
; Force mantissa m into [1,2] by setting EXP to "1.0" exponent when packing
    LDX     #$0000
    STX     EXP
    PSHU    A,X             ; RESULT has the new 10 byte double value, RESULT at @U, U points there
;
; Copy it to DB_Log_M
    PULU    D,X,Y       ; Get the first 6 bytes of data, move U past the data
    LDU     ,U          ; Load U with the last two bytes of data
    STU     DB_Log_M+6        ; Save U at destination address + 6
    LDU     #DB_Log_M+6       ; U points at the start of the destination location 
    PSHU    D,X,Y       ; Save the 6 bytes of data at the start of destination
    LDD     RESULT+8    ; Get the last 2 bytes from the source
    STD     8,U         ; Save the last bytes at the destination
;
; Now m is in [1,2]. If m >= sqrt(2), divide by 2 and increase e by 1,
; so that final m ∈ [sqrt(1/2), sqrt(2)] as desired.
    PUSH_DBL DB_Log_M       ; PUSH m onto the stack
    PUSH_DBL DB_SQRT2       ; PUSH push sqrt(2) onto the stack
    JSR     DB_SUB          ; m - sqrt(2)
    LDA     ,S              ; A = the Sign of the result
    LEAS    10,S            ; Fix the stack
    BMI     DB_Log_M_OK           ; if m - sqrt(2) < 0, m < sqrt(2) => OK
; else m >= sqrt(2): m = m/2, e = e + 1
    PUSH_DBL Double_Half    ; PUSH Double_Half onto the stack
    PUSH_DBL DB_Log_M             ; PUSH m onto the stack
;
    JSR     DB_MUL          ; m = m * 0.5
; Save stack at DB_Log_M
    PULL_DBL  DB_Log_M         ; PULL DB_Log_M off the stack
;
    INC     DB_Log_E_SInt+1        ; Increment DB_Log_E_SInt
    BNE     DB_Log_M_OK
    INC     DB_Log_E_SInt
DB_Log_M_OK:
; ========= z = (m - 1) / (m + 1) =========
; ---- build denominator first and leave it under numerator ----
; numer = (m - 1) while keeping denom below
    PUSH_DBL DB_Log_M
    PUSH_DBL Double_1
    JSR     DB_SUB          ; numer at ,S, denom at 10,S
;
; denom = (m + 1)
    PUSH_DBL DB_Log_M
    PUSH_DBL Double_1
    JSR     DB_ADD          ; denom at ,S
;
; z = numer / denom
    JSR     DB_DIV          ; z at ,S
;
; Save z
    PULL_DBL  DB_Log_Z
;
; ========= R(t) = P(t) / Q(t),  t = z^2,  with P even / Q even =========
; Setup DB_RATIONAL Q type=even, P type=even, counts = (n+1) = say 5 (deg 8 in t if you like)
    LDB     #0              ; Q type = even
    PSHS    B
    LDB     #5              ; Q count (q0..q4)
    PSHS    B
    LDD     #DB_LOG_COEFFS_Q
    PSHS    D
    LDB     #0              ; P type = even
    PSHS    B
    LDB     #5              ; P count (p0..p4)
    PSHS    B
    LDD     #DB_LOG_COEFFS_P
    PSHS    D
; Push x=z (so Horner uses t=z^2 internally)
    PUSH_DBL DB_Log_Z             ; PUSH z onto the stack
;
    JSR     DB_RATIONAL     ; -> R(t) = P/Q at ,S
;
; ========= ln(m) ≈ 2*z * R(t) =========
; Multiply R by z
    LDU     #DB_Log_Z+2           ; Point U at the start of source data + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_Log_Z              ; Get the first 2 bytes of data
    PSHS    D               ; z
;    
    JSR     DB_MUL          ; z * R
; Multiply by 2
    PUSH_DBL Double_2       ; PUSH 2 onto the stack
;
    JSR     DB_MUL          ; ln(m) ≈ 2*z*R
;
; ========= ln(x) = e*ln2 + ln(m) =========
; Compute e as double and scale ln2 by e, or scale via integer multiply/add.
; Here: form e as double to reuse DB_MUL/ADD.
;
; Build e as double in @E_DBL
    ; For now we’ll multiply ln2 by integer e using repeated add if you prefer (or build E_DBL once elsewhere).
;
; Multiply ln2 * e (double e)
    PUSH_DBL DB_LN2      ; PUSH ln2 onto the stack
;
    ; Build e as double quickly
;
    LDD     DB_Log_E_SInt  ; Get the signed 16 bit number in D
    STD     ,--S    ; Write the LSB on the stack
    TFR     A,B     ; move A to B
    SEX             ; Sign extend 16 bit value into A
    STA     ,-S     ; Save top 16 bits
    STA     ,-S     ; Save top 16 bits on the stack
    JSR     S32_To_Double   ; Convert signed 32bit integer @,S to 10 byte Double @ ,S
;
    JSR     DB_MUL          ; e*ln2
;
; Add ln(m)
; ln(m) is already on the stack
    JSR     DB_ADD          ; (e*ln2) + (2*z*R)
;
@Return:
    JMP     >$FFFF
; ======= Data / temporaries =======
DB_Log_TEMP_X   RMB 10
DB_Log_M        RMB 10
DB_Log_Z        RMB 10
DB_Log_E_SInt   RMB 2            ; signed 16-bit exponent (unbiased)

; DB_COS: Compute cos(x) for double-precision input
; Input:
; ,S: x (10 bytes, double-precision)
; Output:
; ,S: cos(x) (10 bytes, double-precision), S unchanged
; Clobbers: A, B, D, X, Y, U
DB_COS:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self-modify return address
; check for 0 COS(0)=1
    LDD     2,S         ; Get Exponent LSB & Mantissa MSB, most likely to have something
    BNE     >
    LDD     ,S
    BNE     >
    LDD     4,S
    BNE     >
    LDD     6,S
    BNE     >
    LDD     8,S
    BNE     >
; We get here when we are given COS(0) = 1
    LEAS    10,S        ; Clear the stack
    PUSH_DBL Double_1   ; PUSH Double_1 onto the stack
    JMP     @Return     ; Cosine of 0 is 1
; Compute x' = x + π/2 to use cos(x) = sin(x + π/2)
!   PUSH_DBL DB_PI_2 ; PUSH π/2 onto the stack
;
    JSR     DB_ADD      ; x + π/2, S=S+10, result at ,S
    BRA     @NotZero    ; Use the SINE function for the rest
;
; DB_SIN: Compute sin(x) for double-precision input
; Input:
;   ,S: x (10 bytes, double-precision)
; Output:
;   ,S: sin(x) (10 bytes, double-precision), S unchanged
; Clobbers: A, B, X, Y, U
DB_SIN:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self-modify return address
; Check for zero, SIN(0)=0
    LDD     2,S         ; Get Exponent LSB & Mantissa MSB, most likely to have something
    BNE     @NotZero
    LDD     ,S
    BNE     @NotZero
    LDD     4,S
    BNE     @NotZero
    LDD     6,S
    BNE     @NotZero
    LDD     8,S
    LBEQ    @Return     ; SINE of zero is zero
; Save x
@NotZero:
    CopyStackToDBL DB_Sin_Temp_X ;  Copy 10 Byte double from the stack to variable DB_Sin_Temp_X
; Range reduction: x' = x mod 2π
    PUSH_DBL DB_Sin_Temp_X      ; PUSH DB_Sin_Temp_X onto the stack
    PUSH_DBL DB_2PI  ; PUSH 2π onto the stack
;
    JSR     DB_DIV      ; x / 2π, result at ,S, S=S+10
; Floor division result
    JSR     DB_FLOOR     ; Do INT(,S) keep it as a DB number
; x' = x - floor(x/2π) * 2π
    PUSH_DBL DB_2PI  ; PUSH 2π onto the stack
;
    JSR     DB_MUL      ; floor(x/2π) * 2π, S=S+10
; x is already on the stack, so we just do a DB_SUB to get our result of x - floor(x/2π) * 2π
    JSR     DB_SUB      ; x - floor(x/2π) * 2π, S=S+10
; Store x' in TEMP_X, pull it off the stack
    CopyStackToDBL DB_Sin_Temp_X ;  Copy 10 Byte double from the stack to variable DB_Sin_Temp_X
;
; Determine quadrant and adjust x' to [0, π/2]
; Compute x' - π
; Didn't pull it off the stack above, just copied it to TEMP_X
    PUSH_DBL DB_PI      ; PUSH π onto the stack
;
    JSR     DB_SUB      ; π - x', S=S+10 result should be C01248FDD4E06C4B
; If π < x' , use π - x' or adjust sign
    LDA     ,S          ; Check sign bit (bit 7 of first byte) 
    LEAS    10,S        ; Fix the stack
    BPL     @Quadrant34 ; if x >= π then go decide between Quadrant 3 (≤ 3π/2) and Quadrant 4 (> 3π/2)
; if we get here then x' < π
; x' < π → Quadrant 1 or 2
; Test if x' - π/2 >= 0
; x' <= π, check if x' <= π/2
    PUSH_DBL DB_Sin_Temp_X      ; PUSH DB_Sin_Temp_X onto the stack
    PUSH_DBL DB_PI_2            ; PUSH π/2 onto the stack
;
    JSR     DB_SUB      ; x' - π/2, S=S+10   *** 3FEBC9F9E3C70E76
    LDA     ,S          ; Check sign
    LEAS    10,S        ; Fix the stack
    LBMI    @Quadrant1  ; Use 'x as it is
; x' >= π/2 → Quadrant 2: sin(x') = sin(π - x')
@Quadrant2:     ; sin(x') = sin(π - x')
    PUSH_DBL DB_PI   ; PUSH π onto the stack
    PUSH_DBL DB_Sin_Temp_X    ; PUSH DB_Sin_Temp_X onto the stack
;
    JSR     DB_SUB       ; π - x', S=S+10 ; 3FF248FDD4E06C4B
    PULL_DBL  DB_Sin_Temp_X  ; PULL DB_Sin_Temp_X off the stack
    JMP     @EvalSin
@Quadrant34:
; Now decide between Quadrant 3 (≤ 3π/2) and Quadrant 4 (> 3π/2)
; Test if x' - 3π/2 >= 0
; x' > π, check if x' <= 3π/2
    PUSH_DBL DB_Sin_Temp_X    ; PUSH DB_Sin_Temp_X onto the stack
    PUSH_DBL DB_3PI_2    ; PUSH 3π/2 onto the stack
;
    JSR     DB_SUB       ; x' - 3π/2, S=S+10
    LDA     ,S          ; Check sign
    LEAS    10,S        ; Fix the stack
    BPL     @Quadrant4  ; x' >= 3π/2  → Quadrant 4: sin(x') = -sin(2π - x')
@Quadrant3:
; Quadrant 3: sin(x') = -sin(x' - π)
    PUSH_DBL DB_Sin_Temp_X    ; PUSH DB_Sin_Temp_X onto the stack
    PUSH_DBL DB_PI   ; PUSH π onto the stack
;
    JSR     DB_SUB       ; x' - π
    BRA     @Negate
@Quadrant4:    ; sin(x') = -sin(2π - x')
    PUSH_DBL DB_2PI  ; PUSH 2π onto the stack
    PUSH_DBL DB_Sin_Temp_X    ; PUSH DB_Sin_Temp_X onto the stack
;
    JSR     DB_SUB      ; 2π - x'
@Negate:
    PULL_DBL  DB_Sin_Temp_X    ; PULL Variable off the stack
; Negate sign
    LDA     DB_Sin_Temp_X
    EORA    #%10000000
    STA     DB_Sin_Temp_X
@Quadrant1:
@EvalSin:
    ; Evaluate sin(x') using DB_HORNER_ODD
    LDB     #4
    PSHS    B           ; Push n+1 = 4 (degrees 1, 3, 5, 7)
    LDD     #Double_SIN_COEFFS
    PSHS    D           ; Push coefficient pointer
    PUSH_DBL DB_Sin_Temp_X    ; PUSH DB_Sin_Temp_X onto the stack Push x'
;
; DB_HORNER_ODD Evaluate an odd-degree polynomial using Horner's method
; Input:
;   Stack:
;     ,S: x (10 bytes, IEEE 754 double-precision)
;     8,S: Pointer to coefficient table (2 bytes)
;     10,S: Number of coefficients (n+1, 1 byte, for degrees 1, 3, ..., 2n+1)
    JSR     DB_HORNER_ODD   ; ,S = DB number, 10,S = coefficient table, 12,s = # of coefficients, S=S+3, DB result is @ ,S
;
@Return:
    JMP     >$FFFF      ; Return, self-modified
; Temporaries
DB_Sin_Temp_X    RMB  10   ; Reduced x

; DB_TAN: Compute tan(x) for double-precision input
; Input:
; ,S: x (10 bytes, double-precision)
; Output:
; ,S: tan(x) (10 bytes, double-precision), S unchanged
; Clobbers: A, B, X, Y, U
; tan(x) = sin(x) / cos(x)
DB_TAN:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self-modify return address
; Save x
    CopyStackToDBL DB_Tan_Temp_X ;  Copy 10 Byte double from the stack to variable DB_Tan_Temp_X
; Compute sin(x)
    JSR     DB_SIN      ; Compute sin(x), result at ,S, S=S+10
    PUSH_DBL DB_Tan_Temp_X      ; PUSH DB_Tan_Temp_X onto the stack
; Compute cos(x)
    JSR     DB_COS      ; Compute cos(x), result at ,S
; Check if cos(x) is zero (singularity check)
    LDD     2,S         ; Get Exponent LSB & Mantissa MSB, most likely to have something
    BNE     @NotZero
    LDD     ,S
    BNE     @NotZero
    LDD     4,S
    BNE     @NotZero
    LDD     6,S
    BNE     @NotZero
    LDD     8,S
    BNE     @NotZero
; cos(x) = 0, tangent is undefined
    LEAS    10,S         ; Move stack pointer past result of cos(x)
    LDD     #$8000      ; Return IEEE 754 NaN or large value
    STD     1,S
    STD     3,S         ; Manitssa MSB bit is a 1
    CLRA
    STD     5,S
    STD     7,S
    STA     9,S
    BRA     @Return
@NotZero:
;
; Compute tan(x) = sin(x) / cos(x)
    JSR     DB_DIV      ; sin(x) / cos(x), S=S+10, result at ,S
@Return:
    JMP     >$FFFF      ; Return, self-modified
; Temporaries
DB_Tan_Temp_X     RMB 10       ; Temporary storage for x

; DB_ATAN: Compute atan(x) for double-precision input
; Input:
; ,S: x (10 bytes, IEEE 754 double-precision)
; Output:
; ,S: atan(x) (10 bytes, double-precision), S unchanged
; Clobbers: A, B, D, X, Y, U
DB_ATAN:
    PULS    U               ; Get return address
    STU     @Return+1       ; Self-modify return address
; check for zero
; Zero (±0):
; +0    0       All 0s              All 0s
; -0    1       All 0s              All 0s
    LDD     2,S             ; Normal number will have a value here
    BNE     @NotZero
    LDA     1,S             ; check MSB of exponent
    BNE     @NotZero
    LDD     4,S             ; The rest of the mantissa
    BNE     @NotZero
    LDD     6,S
    BNE     @NotZero
    LDD     8,S
    LBEQ    @Return         ; Return 0 if x = 0
@NotZero:
; ---- save sign and make |x| in temp ----
    PULS    D,X,Y,U             ; Get the first 8 bytes of data
    STA     DB_ATAN_Sign        ; Store sign
    CLRA                        ; Clear sign bit, Make positive
    STU     DB_ATan_TEMP_X+6    ; Save U at destination address + 6
    LDU     #DB_ATan_TEMP_X+6   ; U points at the start of the destination location 
    PSHU    D,X,Y               ; Save the 6 bytes of data at the start of destination
    PULS    D                   ; Get the last 2 bytes from the stack
    STD     DB_ATan_TEMP_X+8    ; Save the last bytes at the destination
    PUSH_DBL DB_ATan_TEMP_X
; Compare |x| (already on the stack) with 1
    PUSH_DBL Double_1
    JSR     DB_SUB              ; |x| - 1
    LDA     ,S
    LEAS    10,S
    BPL     @LargeX             ; |x| >= 1
; else abs(x) < 1 -> small range
; ---------------------------
; |x| < 1: atan(x) ≈ x * P(t)/Q(t)  via your FFP_RATIONAL setup
; ---------------------------
@SmallX:
; |x| ≤ 1, compute atan(|x|) using DB_RATIONAL
    LDD     #DB_ATAN_COEFFS_P   ; P coefficients pointer
    LDX     #$0401              ; MSB = P number of coefficients (n+1 = 4), LSB = P type: 1=odd
    LDY     #DB_ATAN_COEFFS_Q   ; Q coefficients pointer
    LDU     #$0400              ; MSB = Q number of coefficients (n+1 = 4), LSB = Q type: 0=even
    PSHS    D,X,Y,U
    PUSH_DBL DB_ATan_TEMP_X     ; PUSH |x| variable onto the stack
    JSR     DB_RATIONAL         ; Evaluate P(x)/Q(x), S=S+10, result at ,S
    BRA     @ApplySign
; ---------------------------
; |x| >= 1: atan(x) = pi/2 - atan(1/x)
; ---------------------------
@LargeX:
; |x| > 1, compute 1/|x|
; Compute atan(1/|x|)
; atan(inv)
    LDD     #DB_ATAN_COEFFS_P   ; P coefficients pointer
    LDX     #$0401              ; MSB = P number of coefficients (n+1 = 4), LSB = P type: 1=odd
    LDY     #DB_ATAN_COEFFS_Q   ; Q coefficients pointer
    LDU     #$0400              ; MSB = Q number of coefficients (n+1 = 4), LSB = Q type: 0=even
    PSHS    D,X,Y,U
    PUSH_DBL DB_ATan_TEMP_X
    JSR     INVERT_DOUBLE       ; Compute 1/|x|, result at ,S
    JSR     DB_RATIONAL         ; Evaluate P(x)/Q(x), S=S+10, result at ,S
; Compute π/2 - atan(1/|x|)
; Leave atan(1/|x|) on the stack (flip the sign bit afterwards)
    PUSH_DBL DB_PI_2            ; PUSH π/2 onto the stack
;
    JSR     DB_SUB              ; π/2 - atan(1/|x|), S=S+10
    LDA     ,S                  ; Get the SIGN bit
    EORA    #%10000000          ; Flip bit 7
    STA     ,S                  ; Save new value
@ApplySign:
; Apply sign: if x < 0, negate result
    LDA     ,S
    ANDA    #%01111111          ; Clear sign bit
    LDA     DB_ATAN_Sign
    STA     ,S                  ; Save new value
@Return:
    JMP     >$FFFF              ; Return, self-modified
; Temporaries
DB_ATan_TEMP_X      RMB 10      ; Temporary storage for x
DB_ATan_TEMP_Inv    RMB 10
DB_ATAN_Sign        RMB 1       ; Store sign of input

DB_POW:
      PULS  U
      STU   @Return+1
; ---- Check if base is zero (ignore sign) ----
    LDD     1,S             ; exp of base
    BNE     @NotZeroBase
    LDX     3,S             ; mant of base
    BNE     @NotZeroBase
    LDX     5,S             ; mant of base
    BNE     @NotZeroBase
    LDX     7,S             ; mant of base
    BNE     @NotZeroBase
    LDA     9,S             ; mant of base
    BNE     @NotZeroBase
; base is 0 (+0 or -0)
; ---- Check if exponent is zero (ignore sign) ----
    LDD     11,S
    BNE     @Exp_not_zero
    LDX     13,S
    BNE     @Exp_not_zero
    LDX     15,S
    BNE     @Exp_not_zero
    LDX     17,S
    BNE     @Exp_not_zero
    LDA     19,S
    BNE     @Exp_not_zero
; 0^0: return +1.0
    LEAS    20,S
    PUSH_DBL Double_1           ; PUSH Double_1 onto the stack
    BRA     @Return
@Exp_not_zero:
; exponent < 0 => +Infinity, exponent > 0 => +0
    LDD     11,S                ; load sign+exp
    BPL     @Exp_positive       ; bit7=0: positive (or zero, but already checked)
; exponent < 0: return +inf
    LEAS    20,S
    CLRA
    LDX     #$0000
    LEAY    ,X
    LDU     ,X
    PSHS    A,X,Y,U     ; Save mantissa (all zeros)
    LDX     #$8000
    PSHS    A,X         ; Save the sign and the exponent
    BRA     @Return
@Exp_positive:
; exponent > 0: return +0
    LEAS    20,S
    LDD     #$0000
    LDX     #$0000
    LEAY    ,X
    LDU     ,X
    PSHS    A,X,Y,U ; Save mantissa (all zeros)
    PSHS    A,X         ; Save the sign and the exponent
    BRA     @Return
; ---- Normal case: pow(x,y) = exp( y * ln(x) ) ----
@NotZeroBase:
    PULL_DBL    DB_POW_TEMP_X   ; PULL Variable2 off the stack
    JSR     DB_LOG          ; ln(base) -> result at ,S (exponent still at 10,S)
; Push exponent back on top of stack
    PUSH_DBL DB_POW_TEMP_X ; PUSH DB_POW_TEMP_X onto the stack
    JSR     DB_MUL          ; (Value1 @10,S) * (Value2 @,S) -> result at ,S (consumes both)
    JSR     DB_EXP          ; exp(product) -> result at ,S
@Return:
    JMP     >$FFFF
DB_POW_TEMP_X RMB 10
