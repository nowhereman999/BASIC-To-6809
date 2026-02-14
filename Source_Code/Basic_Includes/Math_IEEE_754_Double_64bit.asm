; Routines for doing Double math - 64 bit, IEEE 754
;
; Math functions included in this library:
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
;
; Helper routines:
; DB_Round_X        ; Round Mantissa @ ,X where Mantissa is 7 bytes 0 to 6, extra bits are in byte 7 (eighth byte), EXP will be incremented if needed & mantissa will be divided by 2 
; PRINT_DOUBLE      ; Print Double value @,S
; DB_TO_DECSTR      ; Replaces Double # on the stack with a decimal ASCII string version where: ,S=len, 1,S=' ' or '-', 2,S..digits
; Double_CMP_Stack  ; Compare Double Value1 @ 10,S with Value2 @ ,S sets the 6809 flags Z, N, and C
;
; RandomDB_Zero     ; Generate a random number @,S in the range of > 0 and < 1
; RandomDB          ; Gets a random number where random # is 1 to X where X is the Double value on the stack, then S=S+10 result @,S
;
; FIND_MSB_64       ; Subroutine: Find position of highest set bit in 64-bit number at X, Returns: A = position (0-63, or 255 if zero)
;
; Shifting routines:
; SHIFT_RIGHT_1_64  ; SHIFT_RIGHT_1_64: Shift a 64-bit value right by 1 bit
; SHIFT_RIGHT_1_128 ; Shift a 128-bit value right by 1 bit
; SHIFT_RIGHT_64_B  ; Description: Shift the 64-bit number at X Right by B bits
; SHIFT_LEFT_64_B   ; Description: Shift the 64-bit number at X left by B bits
;
; IEEE 754 64 bit (Double) format - 8 bytes
; SEEEEEEE|EEEEMMMM|--7 Mantissa bytes|
;
; UnPacked Double format - 10 bytes
; Bytes     Function
; 0         (1 byte)  Sign - only bit 7 will be the actual sign the rest of the bits should always be zero
; 1  &  2   (2 bytes) Exponent - normalized 16 bit value
; 3  to 9   (7 bytes) Mantissa bytes (Includes implied bit at bit 52 always set) to keep it consistent with IEEE 754 Double format
;
; Special Formats:
; Zero (±0):
; +0    0       All 0s              All 0s
; -0    1       All 0s              All 0s
;
; Infinity (±∞):
; Value Sign    Exponent (unbiased) Mantissa
; +∞    0       $8000               All 0s
; -∞    1       $8000               All 0s
;
; Not a Number (NaN):
; Type  Sign    Exponent (unbiased) Mantissa
; NaN   Any     $8000               Non-zero
;


Div128Slow  EQU 1       ; set to 1 to use slower division routine, set to 0 to use much faster Knuth's Algorithm D for 128-bit / 64-bit Unsigned Division on Motorola 6809
                        ; faster Knuth's Algorithm D isn't working perfectly, can't handle 17/3
EXP         RMB 8
EXP1        RMB 8
EXP2        RMB 8
MANT        RMB 8
MANT1       RMB 8
BigMant1    RMB 8       ; Extra space for the Dividend to make it a 110 bit value (will be padded with zeros before division)
MANT2       RMB 8
BigQuotient RMB 16      ; Result of 110/52 bit division
TempBig17   RMB 17
SHIFT       RMB 2
SIGN        RMB 1
SIGN1       RMB 1
SIGN2       RMB 1
BIT_SHIFT   RMB 1
BYTE_SHIFT  RMB 1
DOUBLE_IN   RMB 8
INT64_OUT   RMB 8
MIN_S64     RMB 8
MAX_S64     RMB 8
MAX_U64     EQU $FFFF
TEMP_E      RMB 2

DIVIDEND    EQU MANT1       ; 16 bytes
DIVISOR     EQU MANT2       ; 8 bytes
QUOTIENT    EQU BigQuotient ; 16 bytes
REMAINDER   EQU INT64_OUT   ; 8 bytes: Output remainder
TEMP        EQU TempBig17   ; 17 bytes: Temp partial dividend (extra for overflow)
MULT_RES    EQU MIN_S64     ; 9 bytes temp
; Storage for shift
NORM_SHIFT  RMB 1       ; Bit shift count
Q_TEMP      RMB 1       ; Save A (q_hat)

; RandomDB_Zero: Generate a random number @,S in the range of > 0 and < 1
; output: Random FFP value >0 <1 at ,S (10 bytes)
RandomDB_Zero:
    PULS    Y           ; Get the return address off the stack
    LDA     #6          ; 6 lower bytes of the mantissa
@FillMant:
    JSR     RandomFast8Bit  ; B = Random number from 0 to 255
    PSHS    B           ; save mantissa bytes on the stack
    DECA
    BNE     @FillMant
;
; ---- force implied bit (bit52) to 1 ----
    JSR     RandomFast8Bit  ; B = Random number from 0 to 255 for the MS byte of the mantissa
    ANDB    #%00001111  ; Clear high bits of the mantissa
    ORB     #%00010000  ; and set bit 52
    PSHS    B           ; push mantissa MSB
;
; Ensure not exactly 1.0: make sure some fraction bit is nonzero.
; Easiest: if all fraction bits are zero besides implied, bump last byte.
; (Cheap check: OR all mantissa bytes except the implied bit position.)
    LDA     ,S
    ANDA    #%00001111
    BNE     >           ; already has some fractional bits set
    LDA     1,S
    BNE     >           ; already has some fractional bits set
    LDA     2,S
    BNE     >           ; already has some fractional bits set
    LDA     3,S
    BNE     >           ; already has some fractional bits set
    LDA     4,S
    BNE     >           ; already has some fractional bits set
    LDA     5,S
    BNE     >           ; already has some fractional bits set
    LDA     6,S
    BNE     >           ; already has some fractional bits set
    INC     6,S         ; force a tiny fraction so value > 2^(exp) * 1.0
; ----- Pick exponent with weighted probabilities -----
!   JSR     RandomFast8Bit  ; B = rand 0..255
;
        ; thresholds (cumulative):
        ; <129 => -1
        ; <194 => -2
        ; <226 => -3
        ; <242 => -4
        ; <250 => -5
        ; <254 => -6
        ; else => -7
        CMPB    #129
        BLO     @E_M1
        CMPB    #194
        BLO     @E_M2
        CMPB    #226
        BLO     @E_M3
        CMPB    #242
        BLO     @E_M4
        CMPB    #250
        BLO     @E_M5
        CMPB    #254
        BLO     @E_M6
@E_M7:  LDB     #-7          ; -7
        BRA     @PUSH_E
;
@E_M2:  LDB     #-2          ; -2
        BRA     @PUSH_E
@E_M3:  LDB     #-3          ; -3
        BRA     @PUSH_E
@E_M4:  LDB     #-4          ; -4
        BRA     @PUSH_E
@E_M5:  LDB     #-5          ; -5
        BRA     @PUSH_E
@E_M6:  LDB     #-6          ; -6
        BRA     @PUSH_E
@E_M1:  LDB     #-1          ; -1 in 7-bit signed exp field (sign=0)
@PUSH_E:
        LDA     #$FF        ; MS byte of exponent is negative
        PSHS    D           ; push exp bytes
    CLRB
    PSHS    B       ; Postive Sign byte
@Return:
    JMP     ,Y          ; Return

; RandomDB: Gets a random number where random # is 1 to X where X is the Double value on the stack, then S=S+10 result @,S
; output: randon Double number at ,S (10 bytes)
; clobbers: all
RandomDB:
      PULS  D                 ; Get the return address off the stack
      STD   @Return+1
      JSR   RandomDB_Zero     ; Get a Double Random number on the stack (>0 and <1)
      JSR   DB_MUL            ; Multiply 10,S * ,S Then S=S+10 result @ ,S
; Put 1.0 on the stack
      LDD   #$0000
      LDX   #$0010
      LDU   #$0000
      LEAY  ,U
      PSHS  D
      PSHS  D,X,Y,U           ; Put 1.0 on the stack
      JSR   DB_ADD            ; Add 10,S + ,S Then S=S+10 result @ ,S
@Return:
      JMP   >$FFFF            ; Return

; Subroutine: Find position of highest set bit in 64-bit number at X
; Returns: A = position (0-63, or 255 if zero)
FIND_MSB_64:
    CLRB
!   LDA     B,X
    BNE     FOUND_MSB
    INCB
    CMPB    #8
    BNE     <
FOUND_MSB:
    SUBB    #7
    NEGB
    PSHS    B           ; Save byte index
    LDB     #7          ; Bit position within byte
FIND_BIT_LOOP:
    TSTA
    BMI     MSB_FOUND
    ASLA
    DECB
    BPL     FIND_BIT_LOOP
MSB_FOUND:
    LDA     ,S          ; Get byte index
    ASLA                ; Multiply by 8
    ASLA
    ASLA
    PSHS    B
    ADDA    ,S++        ; Add bit position, Fix the stack
    RTS

; Subroutine to test if 64-bit number at X is zero
TEST_ZERO_64:
    LDB     #7
TEST_ZERO_LOOP:
    TST     B,X
    BNE     NOT_ZERO
    DECB
    BPL     TEST_ZERO_LOOP
    CLRA                ; (Clear Carry flag)
    RTS
NOT_ZERO:
    COMA                ; (Set carry flag)
    RTS

; Ouput all zeros @ ,X
DoubleZero_at_X_minus2:
    LEAX    -2,X
    LDD     #$000A      ; Clear A and make B = 10
!   STA     ,X+         ; make all bytes zero
    DECB
    BNE     <
    RTS

; Convert Unsigned 64 bit integer @,S to 10 byte Double @ ,S
; Input: Unsigned 64 bit number at ,S
; Ouput: IEEE 754 Double number at ,S
U64_To_Double:
    LDU     ,S              ; Get return address, keep stack where it is, leave room for 10 byte double
    STU     @Return+1       ; Self mod return address
;
    LEAX    2,S              ; X = S+2 (still)
    JSR     TEST_ZERO_64
    BCS     >               ; If carry is set, then it's not zero
    BSR     DoubleZero_at_X_minus2 ; Ouput DOUBLE_OUT as all zeros @ -2,X
    JMP     @Return
!   CLR     SIGN_TEMP       ; Sign will be positive
    BRA     S64_POS_Double
;
; Convert signed 64 bit integer @,S to 10 byte Double @ ,S
; Input: Signed 64 bit number at ,S
; Ouput: IEEE 754 Double number at ,S
S64_To_Double:
    LDU     ,S              ; Get return address, keep stack where it is
    STU     @Return+1       ; Self mod return address
;
    LEAX    2,S              ; X = S+2 (still)
    JSR     TEST_ZERO_64
    BCS     >               ; If carry is set, then it's not zero
    BSR     DoubleZero_at_X_minus2 ; Ouput DOUBLE_OUT as all zeros @ -2,X
    JMP     @Return
!   LDA     ,X              ; Check sign
    ANDA    #%10000000      ; Keep only the sign bit
    STA     SIGN_TEMP
    BPL     S64_POS_Double  ; If positive then skip negating it
; Negate number
    LDB     #7
    CLRA    ; Clear the initial carry
S64_NEGATE:
    LDA     #0
    SBCA    B,X
    STA     B,X
    DECB
    BPL     S64_NEGATE
;
S64_POS_Double:
; Figure out how much to move the 64 bit integer to get it to bit position 52
    JSR     FIND_MSB_64     ; Find position of highest set bit in 64-bit number at X, returns A = position (0-63, or 255 if zero)
    STA     SHIFT_COUNT     ; Save the MSbit position
    SUBA    #52             ; 
    BEQ     S64_NO_SHIFT    ; If position is already 52 then we don't have to shift it at all
    BMI     S64_Shift_Left  ; If it's lower than 52 then we shift it left until the first signed bit is in bit 52
; If it's greater that 52 then we shift it right and round up the portion we will crop (LSbits)
;  To make it IEEE 754 compliant when cropping we should:
; G is the MSbit we drop, R is the 2nd MSbit we drop, S is OR'ed with the other bits we dropped (0 or 1)
;   •	If G = 0, you’re less than halfway to the next representable mantissa, so you leave M unchanged.
;	•	If G = 1 and (R or S = 1) — i.e. you’re strictly more than halfway — you add 1 to M.
;	•	If G = 1, R = 0, S = 0 — i.e. you’re exactly halfway (the bit pattern is ...xyz1000…0) — you add 1 to M only if 
;                the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
;
; A = number of bits to shift right
    CLRB
!   LSR     ,X
    ROR     1,X
    ROR     2,X
    ROR     3,X
    ROR     4,X
    ROR     5,X
    ROR     6,X
    ROR     7,X
    RORB                ; Save bits for rounding
    ADCB    #$00        ; Count the carry bits
    ANDB    #%11011111  ; Keep the high bits and the count 
    DECA
    BNE     <
; Bit's are shifted so Mantissa is now in the correct spot
;
; If it's greater that 52 then we shift it right and round up the portion we will crop (LSbits)
;  To make it IEEE 754 compliant when cropping we should:
; G is the MSbit we drop, R is the 2nd MSbit we drop, S is OR'ed with the other bits we dropped (0 or 1)
;   •	If G = 0, you’re less than halfway to the next representable mantissa, so you leave M unchanged.
;	•	If G = 1 and (R or S = 1) — i.e. you’re strictly more than halfway — you add 1 to M.
;	•	If G = 1, R = 0, S = 0 — i.e. you’re exactly halfway (the bit pattern is ...xyz1000…0) — you add 1 to M only if 
;                the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
;
    LSLB                    ; Move G into the Carry
    BCC     S64_NO_SHIFT    ; G = 0, so no rounding
    LSLB                    ; G = 1, So move R into the Carry
    BCS     S64_Add_One     ; G = 1 & R = 1 Add one to Mantissa
    TSTB                    ; The rest of B is the count of 1 bits
    BNE     S64_Add_One     ; G = 1 & S = 1 Add one to Mantissa
; G = 1, R & S both = 0
; Add 1 to M only if the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
    LDB     7,X
    BITB    #%00000001      ; Check LSBit
    BEQ     S64_NO_SHIFT    ; Lowest bit of mantissa is 0 so no adding
S64_Add_One:
    LDD     6,X
    ADDD    #$0001
    STD     6,X
    BCC     >
    LDD     4,X
    ADDD    #$0001
    STD     4,X                 
    BCC     >                   
    LDD     2,X                          
    ADDD    #$0001              
    STD     2,X                
    BCC     >                  
    LDB     1,X                
    ANDB    #%00001111         
    SUBB    #15
    BEQ     S64_WillOverflow
    INC     1,X
!   BRA     S64_NO_SHIFT
;
S64_WillOverflow:
    STB     1,X             ; B always = 0 so this clears 1,X
    INC     SHIFT_COUNT     ; Mantissa overflow add one
    BRA     S64_NO_SHIFT
;
S64_Shift_Left:
; A = Negative number of number of bits to shift left
    NEGA                ; now positive
    TFR     A,B
    JSR     SHIFT_LEFT_64_B   ; Shift the 64-bit number at X left by B bits, X unchanged, clobbers Y & U
;
S64_NO_SHIFT:
; Clear the highest bit of the new mantisa and the sign & Exponent location
;    LDB     1,X
;    ANDB    #%00001111
;    STB     1,X
;
; exp = 1023 + 2 = 1025 = 0x401
    LDB     SHIFT_COUNT
    CLRA
;    ADDD    #1023   ; D = 1023 + Shift count = Exponent value which is an 11 bit number
;; D has the 11 bit exponent, shift it left 5 bits
;    LSLB
;    ROLA
;    LSLB
;    ROLA
;    LSLB
;    ROLA
;    LSLB
;    ROLA
;    LSLB
;    ROLA
    STD     -1,X
;Place the 11-bit exponent (0x401) into bits 62:52.
;    LSL     SIGN_TEMP   ; Move the sign bit into the carry
;    RORA            
;    RORB                ; Move th sign bit into MSB of D, shift D right
; Merge all the bits together
;    ORB     1,X         ; Get highest bits of the mantisa in B
;    STD     ,S          ; Save the Sign bit, 11 bit Exponent & High bits of the mantisa
    LDB     SIGN_TEMP
    STB     -2,X
@Return:
    JMP     >$FFFF      ; Return, self modified jump address

**** Using exising 64 bit integer math routines
;
; IEEE 754 Double-Precision Floating-Point Operations for 6809
; Uses 64-bit integer routines from Math_Integer64.asm

; Entry for all operations:
;   ,S = return address
;   2,S to 9,S = First double (Value1)
;   10,S to 17,S = Second double (Value2)
; Exit:
;   ,S = resulting double after return
; Carry flag: 0 = addition, 1 = subtraction (for DB_ADD_SUB only)

; Subtract 10,S - ,S Then S=S+10 result @ ,S
DB_SUB:
DoFPDouble_Subtract_ForCompiler:
    PULS    D                   ; Get return address off the stack and position ,S as the numbers to subtract
    STD     @Done_DB_ADD_SUB+1  ; Self mod return JMP adress below
    LDA     #$FF
    STA     @TestForSUB+1       ; Setting bits indicates we want to do subtraction
    BRA     DB_ADD_SUB
; Add 10,S - ,S Then S=S+10 result @ ,S
DB_ADD:
DoFPDouble_Add_ForCompiler:
    PULS    D                   ; Get return address off the stack and position ,S as the numbers to add
    STD     @Done_DB_ADD_SUB+1  ; Self mod return JMP adress below
    CLR     @TestForSUB+1       ; Clearing the bits indicates we want to do an add
; Flow through to Add two double numbers @ ,S & 8,S return with Result at ,S to 7,S
;
; --- Addition/Subtraction ---
DB_ADD_SUB:
;
; Get Value2
; Pull Double off the stack, saved in SIGN, EXP & MANT (as 8 byte mantissa)
    PULS    B,X         ; Get the sign and exponent off the stack
    STB     SIGN2       ; Save the SIGN
    STX     EXP2        ; Save the EXPonent
    PULS    B,X,Y,U     ; Copy the 7 byte mantissa off the stack
    CLRA                ; First byte of mantissa is zero
    STU     MANT2+6     ; Save U at destination address + 6
    LDU     #MANT2+6    ; U points at the start of the destination location 
    PSHU    D,X,Y       ; Save the 6 bytes of data at the start of destination
;
; Get Value1
; Pull Double off the stack, saved in SIGN, EXP & MANT (as 8 byte mantissa)
    PULS    B,X         ; Get the sign and exponent off the stack
    STB     SIGN1       ; Save the SIGN
    STX     EXP1        ; Save the EXPonent
    PULS    B,X,Y,U     ; Copy the 7 byte mantissa off the stack
    CLRA                ; First byte of mantissa is zero
    STU     MANT1+6     ; Save U at destination address + 6
    LDU     #MANT1+6    ; U points at the start of the destination location 
    PSHU    D,X,Y       ; Save the 6 bytes of data at the start of destination
;
; Adjust for subtraction
@TestForSUB
    LDA     #$FF
    BEQ     @NO_SUB         ; If the bits are clear then add the values as they are
    LDA     SIGN2           ; Otherwise make sign2 a negative and add them
    EORA    #$80
    STA     SIGN2
; Align Exponents:
; Adjust the mantissa of the number with the smaller exponent by shifting it right until the exponents match.
@NO_SUB:
; Align mantissas
    LDD     EXP2
    SUBD    EXP1
    BGE     EXP2_BIG
; EXP1 > EXP2, shift MANT2 right
    LDD     EXP1
    SUBD    EXP2
    STB     SHIFT+1         ; Save amount to shift
    LDX     #MANT2
    JSR     SHIFT_RIGHT_64_B ; Shift the 64-bit number at X Right by B bits, X unchanged, clobbers Y & U
    LDD     EXP1
    STD     EXP             ; Exponent is the largest one
    LDA     SIGN1
    STA     SIGN            ; Sign is taken from the largest exponent
    BRA     DO_OP
; EXP2 => EXP1, shift MANT1 right
EXP2_BIG:
    STB     SHIFT+1         ; Save amount to shift
    LDX     #MANT1
    JSR     SHIFT_RIGHT_64_B ; Shift the 64-bit number at X Right by B bits, X unchanged, clobbers Y & U
    LDD     EXP2
    STD     EXP             ; Exponent is the largest one
    LDA     SIGN2   
    STA     SIGN            ; Sign is taken from the largest exponent
DO_OP:
; At this point both mantissa's are lined up properly
; EXP is set proper
; SIGN is set proper
;
; Add or Subtract Mantissas:
; If the signs are the same, add the mantissas
    LDA     SIGN1
    CMPA    SIGN2
    LBEQ    ADD_MANT        ; If the signs are the same then we do an add
;
;    PULS    CC              ; Get the Carry flag
;    BCC     ADD_MANT        ; If the carry is clear then add the values as they are
;
; If different, subtract the smaller mantissa from the larger one, determining the result’s sign based on magnitudes.
; If MANT2 is smaller:
; Figure out which is is larger:
    LDD     MANT1+1
    CMPD    MANT2+1
    BHI     >
    BLO     @MANT2_is_Big
    LDD     MANT1+3
    CMPD    MANT2+3
    BHI     >
    BLO     @MANT2_is_Big
    LDD     MANT1+5
    CMPD    MANT2+5
    BHI     >
    BLO     @MANT2_is_Big
    LDA     MANT1+7
    CMPA    MANT2+7
    BHS     >
; MANT2 = MANT2 - MANT1
@MANT2_is_Big
    LDA     SIGN2
    STA     SIGN
    LDX     #MANT2
    LDU     #MANT1
	LDD 	6,X         ; Load Value1 bytes 1 and 0 (least significant 16 bits) into D (A:B)
	SUBD 	6,U         ; Subtract Value2 bytes 1 and 0 from D, sets carry if borrow
	STD 	6,X         ; Store result to Value1 bytes 1 and 0
	LDD 	4,X         ; Load Value1 bytes 3 and 2 into D (A:B)
	SBCB 	5,U         ; Subtract Value2 byte 2 from B with borrow
	SBCA 	4,U         ; Subtract Value2 byte 3 from A with borrow
	STD 	4,X         ; Store result to Value1 bytes 3 and 2
	LDD 	2,X         ; Load Value1 bytes 5 and 4 into D (A:B)
	SBCB 	3,U         ; Subtract Value2 byte 4 from B with borrow
	SBCA 	2,U         ; Subtract Value2 byte 5 from A with borrow
	STD 	2,X         ; Store result to Value1 bytes 5 and 4
	LDD 	,X          ; Load Value1 bytes 7 and 6 (most significant 16 bits) into D (A:B)
	SBCB 	1,U         ; Subtract Value2 byte 6 from B with borrow
	SBCA 	,U          ; Subtract Value2 byte 7 from A with borrow
	STD 	,X          ; Store result to Value1 bytes 7 and 6
    BRA     NORM_SUB    ; Normalize MANT1 after subtraction
; Subtract: MANT1 = MANT1 - MANT2
!   LDA     SIGN1
    STA     SIGN
    LDX     #MANT1
    LDU     #MANT2
	LDD 	6,X         ; Load Value1 bytes 1 and 0 (least significant 16 bits) into D (A:B)
	SUBD 	6,U         ; Subtract Value2 bytes 1 and 0 from D, sets carry if borrow
	STD 	6,X         ; Store result to Value1 bytes 1 and 0
	LDD 	4,X         ; Load Value1 bytes 3 and 2 into D (A:B)
	SBCB 	5,U         ; Subtract Value2 byte 2 from B with borrow
	SBCA 	4,U         ; Subtract Value2 byte 3 from A with borrow
	STD 	4,X         ; Store result to Value1 bytes 3 and 2
	LDD 	2,X         ; Load Value1 bytes 5 and 4 into D (A:B)
	SBCB 	3,U         ; Subtract Value2 byte 4 from B with borrow
	SBCA 	2,U         ; Subtract Value2 byte 5 from A with borrow
	STD 	2,X         ; Store result to Value1 bytes 5 and 4
	LDD 	,X          ; Load Value1 bytes 7 and 6 (most significant 16 bits) into D (A:B)
	SBCB 	1,U         ; Subtract Value2 byte 6 from B with borrow
	SBCA 	,U          ; Subtract Value2 byte 7 from A with borrow
	STD 	,X          ; Store result to Value1 bytes 7 and 6
NORM_SUB:
; Description: Shift the 64-bit mantissa left until bit 52 is 1, adjusting the exponent
    LDD     1,X
    BNE     >
    LDD     3,X
    BNE     >
    LDD     5,X
    BNE     >
    LDA     7,X
    BNE     >
    STD     EXP     ; Leave with +0
    STA     SIGN
    LBEQ    @Skip1
!   LDU     EXP
!   LDA     1,X
    BITA    #%00010000
    BNE     >      ; Bit 52 is a 1 we are done shifting
    ASL     7,X
    ROL     6,X
    ROL     5,X
    ROL     4,X
    ROL     3,X
    ROL     2,X
    ROL     1,X
    LEAU    -1,U    ; EXP=EXP-1
    BRA     <
!   STU     EXP
    BRA     @Skip1
ADD_MANT:
; Add: MANT1 = MANT1 + MANT2
    LDX     #MANT1
    LDU     #MANT2
	LDD 	6,X   	; Load Value1 bytes 1 and 0 (least significant 16 bits) into D (A:B)
	ADDD 	6,U   	; Add Value2 bytes 1 and 0 to D, sets carry if overflow
	STD 	6,X   	; Store result to Value1 bytes 1 and 0
	LDD 	4,X   	; Load Value1 bytes 3 and 2 into D (A:B)
	ADCB 	5,U   	; Add Value2 byte 2 to B with carry
	ADCA 	4,U   	; Add Value2 byte 3 to A with carry
	STD 	4,X   	; Store result to Value1 bytes 3 and 2
	LDD 	2,X   	; Load Value1 bytes 5 and 4 into D (A:B)
	ADCB 	3,U   	; Add Value2 byte 4 to B with carry
	ADCA 	2,U   	; Add Value2 byte 5 to A with carry
	STD 	2,X   	; Store result to Value1 bytes 5 and 4
	LDD 	,X    	; Load Value1 bytes 7 and 6 (most significant 16 bits) into D (A:B)
	ADCB 	1,U   	; Add Value2 byte 6 to B with carry
	ADCA 	,U   	; Add Value2 byte 7 to A with carry
	STD 	,X    	; Store result to Value1 bytes 7 and 6
;
;' Normalize (simplified: shift right if overflow)
;If mantRes >= &H20 00 00 00 00 00 00 Then
; 0010 0000
;mantRes = mantRes \ 2
;expRes = expRes + 1
;End If
NORM:
; Normalize & round
    LDX     #MANT1
    LDA     1,X
    CMPA    #$20
    BLO     @Skip1
; Carry: shift right 1, increment exponent
    JSR     SHIFT_RIGHT_1_64    ; X points to the 64-bit value
    BCC     @NoRounding     ; G = 0, so no rounding
; Otherwise check LSB
; G = 1, R & S both = 0
; Add 1 to M only if the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
    LDB     7,X
    BITB    #%00000001      ; Check LSBit
    BEQ     @NoRounding     ; Lowest bit of mantissa is 0 so no adding
    LDD     6,X
    ADDD    #$0001
    STD     6,X
    BCC     >
    LDD     4,X
    ADDD    #$0001
    STD     4,X                 
    BCC     >                   
    LDD     2,X                          
    ADDD    #$0001              
    STD     2,X                
    BCC     >                  
    LDB     1,X                
    ANDB    #%00001111         
    SUBB    #15
    BEQ     @WillOverflow
    INC     1,X
!   BRA     @NoRounding
@WillOverflow:
    STB     1,X             ; B always = 0 so this clears 1,X
    LDD     EXP
    ADDD    #2
    BRA     @GotNewEXP
@NoRounding:
    LDD     EXP
    ADDD    #1
@GotNewEXP
    STD     EXP
@Skip1
    LEAU    1,X         ; Point at mantissa + 1
; Copy mantissa bytes to the stack
    PULU    B,X,Y
    LDU     ,U
    PSHS    B,X,Y,U
    LDA     SIGN        ; Gett the SIGN in A
    LDX     EXP         ; Get the EXPonent in X
    PSHS    A,X         ; Save the Sign & Exponent on the stack
;
;
@Done_DB_ADD_SUB
    JMP >$FFFF      ; Return (Self modified address above)
    
; --- Multiplication ---
; Multiply Double @ ,S with Double @ 10,S
; Result: S=S+10, result is @ ,S
DB_MUL:
    PULS    D               ; Get return address off the stack
    STD     @Return+1       ; Self mod return JMP adress below
;
; Check for zeros
    LDX     2,S             ; Check Mantissa bits first for zero
    BNE     @NotZero
    LDB     1,S             ; Ignore the sign bit
    BNE     @NotZero
    LDD     4,S
    BNE     @NotZero
    LDU     6,S
    BNE     @NotZero
    LDY     8,S
    BNE     @NotZero
; Get here with a value of zero
    LEAS    20,S            ; Move the stack forward
    PSHS    D,X,Y,U         ; Save zero as the result
    PSHS    D               ; Save zero as the result
    JMP     @Return         ; RTS
@NotZero:
    LDX     12,S            ; Check Mantissa bits first for zero
    BNE     >    
    LDB     11,S            ; Ignore the sign bit
    BNE     >
    LDD     14,S
    BNE     >
    LDU     16,S
    BNE     >
    LDY     18,S
    BNE     >
; Get here with a value of zero
    LEAS    10,S            ; Move the stack forward, leave zero as the final result
    JMP     @Return         ; RTS
; SIGN = SIGN1 XOR SIGN2
!   LDA     10,S        ; A = SIGN Value 1
    EORA    ,S          ; EORA with SIGN Value 2
    STA     SIGN        ; Save the new SIGN
;
; Exponent = EXP1 + EXP
    LDD     11,S        ; D = EXP Value 1
    ADDD    1,S         ; D = D + EXP Value 2
    STD     EXP         ; Save the new EXP
;
; Multiply mantissas (128-bit result)
; We will multiply Value 2 * Value 1
; Move Mantissa 2 & keep Mantissa 1 on the stack
; then call the Unsigned 64 bit integer multiply function
;
    LEAS    3,S             ; Point to 64 bit integer Mantissa for Value 2
    PULS    B,X,Y,U         ; Get 7 mantissa bytes for value 2
    LEAS    2,S             ; Move past value 1 SIGN & EXP to just before Mantissa Value 1
    CLRA                    ; First byte is zero
    STA     ,S              ; Make first byte of Value 1 a zero
    PSHS    D,X,Y,U         ; Store 8 Mantissa Value 2 bytes on the stack
; We now have Value 2 mantissa then Value 1 Mantissa on the stack
;
; Keep the top 53 bits (0 to 52 will be ignored)
; Move bits from bit 53 to bit 56 (Shift left 3 is better than shifting right 5 to get to bit 48)
; Shift the mantissa's so the result will be lined up and ready to use as the result
; Rotate Value 2 mantissa
    LSL     7,S
    ROL     6,S
    ROL     5,S
    ROL     4,S
    ROL     3,S
    ROL     2,S
    ROL     1,S             ; Left 1 bit, ignore first byte as it's always zero
    LSL     7,S
    ROL     6,S
    ROL     5,S
    ROL     4,S
    ROL     3,S
    ROL     2,S
    ROL     1,S             ; Left 2 bit, ignore first byte as it's always zero
; Rotate Value 1 mantissa
    LSL     7+8,S
    ROL     6+8,S
    ROL     5+8,S
    ROL     4+8,S
    ROL     3+8,S
    ROL     2+8,S
    ROL     1+8,S           ; Left 1 bit, ignore first byte as it's always zero
    LSL     7+8,S
    ROL     6+8,S
    ROL     5+8,S
    ROL     4+8,S
    ROL     3+8,S
    ROL     2+8,S
    ROL     1+8,S           ; Left 2 bits, ignore first byte as it's always zero
; Bits are now where they need to be
;
    JSR     Mul_UnSigned_Both_64    ; Multiply two unsigned 64bit numbers @,S & 8,S (S=S+8 64 bit Product = ,S 128 bit Product @ RESULT)
; Fix the stack
    LEAS    8,S             ; Fix the stack, don't need Double numbers on the stack anymore & we use full 128 bit value @ RESULT below
;
; Test for over flow
    LDA     RESULT+2        ; Get the value of RESULT+2
;             11111111
;             11100000
;             21098765
    BITA    #%11100000      ; If it didn't extend past bit 109
    BEQ     @DoRound        ; then leave the value as it is
    LDX     #RESULT         ; Otheriwse shift the value right (divide by 2), but no need to do rounding
    JSR     SHIFT_RIGHT_1_128  ; (Implement 128-bit shift) of value @ X
    INC     EXP+1           ; Increment the EXPONENT LSB
    BNE     @DoRound        ; If we didn't just make it zero then we are good
    INC     EXP             ; otherwise increment the MSB
; Keep 64 bit value from bit 110 to 56
;
; Let's round
@DoRound 
    LDX     #RESULT+2       ; Round bits from RESULT+2 to RESULT+9
    JSR     DB_Round_X      ; Round Mantissa @ ,X where Mantissa is 7 bytes 0 to 6, extra bits are in byte 7 (eighth byte), EXP will be incremented if needed & mantissa will be divided by 2 
;
; Take top 52 bits are from RESULT+2 to RESULT+9
    LDU     #RESULT+2       ; Point at result
; Copy mantissa bytes to the stack
    PULU    B,X,Y
    LDU     ,U
    PSHS    B,X,Y,U
    LDA     SIGN        ; Gett the SIGN in A
    LDX     EXP         ; Get the EXPonent in X
    PSHS    A,X         ; Save the Sign & Exponent on the stack
@Return:
    JMP     >$FFFF      ; Return (Self modified address above)

; --- Division ---
; Divide 10,S by ,S
; Result S=S+10
; Result value is at ,S
DB_DIV:
    PULS    D               ; Get return address off the stack
    STD     @Return+1       ; Self mod return JMP adress below
;
; ------------------------------------------------------------
; Check for zero Value1 (Dividend)  <-- NEW: Value1 is at 10,S
; ------------------------------------------------------------
    LDX     12,S             ; Check Mantissa bits first for zero
    BNE     @V1_NotZero
    LDD     10,S
    BNE     @V1_NotZero
    LDY     14,S
    BNE     @V1_NotZero
    LDU     16,S
    BNE     @V1_NotZero
    LDU     18,S
    BNE     @V1_NotZero
; Value1 is zero -> return zero (keeps your old behavior even for 0/0)
    LEAS    20,S            ; drop both operands (Value1 + Value2)
    LEAS    -10,S           ; make room for result
    LDD     #$0000
    STD     ,S
    STD     2,S
    STD     4,S
    STD     6,S
    STD     8,S
    JMP     @Return
@V1_NotZero:
; ------------------------------------------------------------
; Check for zero Value2 (Divisor)  <-- NEW: Value2 is at ,S
; ------------------------------------------------------------
    LDD     2,S            ; Check Mantissa bits first for zero
    BNE     @AlsoNotZero
    LDD     ,S
    BNE     @AlsoNotZero
    LDY     4,S
    BNE     @AlsoNotZero
    LDU     6,S
    BNE     @AlsoNotZero
    LDU     8,S
    BNE     @AlsoNotZero
; Divisor is zero -> return your illegal value 00 FF FF FF FF FF FF FF FF FF
    LEAS    20,S
    LEAS    -10,S
    LDD     #$00FF
    STD     ,S
    LDX     #$FFFF
    STX     2,S
    STX     4,S
    STX     6,S
    STX     8,S
    JMP     @Return
; Get here if Dividend and Divisor are good
@AlsoNotZero:
; ------------------------------------------------------------
; Setup Value2 (Divisor)   <-- NEW: Value2 is now on top
; ------------------------------------------------------------
    PULS    B,X
    STB     SIGN2
    STX     EXP2
    PULS    B,X,Y,U
    STU     MANT2+5
    LDU     #MANT2+5
    PSHU    B,X,Y
;
; ------------------------------------------------------------
; Setup Value1 (Dividend)  <-- NEW: Value1 is on top
; ------------------------------------------------------------
    PULS    B,X
    STB     SIGN1
    STX     EXP1
    PULS    B,X,Y,U
    STU     MANT1+5
    LDU     #MANT1+5
    PSHU    B,X,Y
;
;
; Sign = SIGN1 XOR SIGN2
    LDA     SIGN1
    EORA    SIGN2
    STA     SIGN
; Exponent = EXP1 - EXP2
    LDD     EXP1
    SUBD    EXP2
    STD     EXP
;
    LDX     #DIVIDEND+7   ; Dividend pointer
    LDU     #DIVISOR+7    ; Divisor pointer
    LDD     #$0000
    STA     ,X
    STA     ,U
; Clear the low bits of the dividend
    STD     1,X
    STD     3,X
    STD     5,X
    STD     7,X
 ;
; Divide mantissas
    JSR     DIV128_64   ; 128-bit Dividend / 64-bit Divisor Division, Knuth's Algorithm D
; Output: QUOTIENT 16 byte value (only need the highest 64 bits), Remainder in REMAINDER
;
; Shift Quotient right 12 bits to normalize it and use the right 12 bits for Rounding (guard/round/sticky)
; With 12 tail bits you have plenty for IEEE rounding:
;	•	guard = (tail >> 11) & 1
;	•	round = (tail >> 10) & 1
;	•	sticky = (tail & 0x3FF) != 0  (or OR in a nonzero remainder from the divide)
;	•	Round-to-nearest-even:
;	•	If guard && (round || sticky || (mant53 & 1)) then mant53++
;	•	If that increment overflows to 54 bits, shift right 1 and bump exponent by 1
;
;
  IF Div128Slow
 ; Use this code with DIV128_by_64 using 128 bit shifting type division
; Shift it left by 4 bits so that the g starts at byte 8
    LDX #QUOTIENT+6
    LDB #4
    LDA QUOTIENT+7
    BNE >
    LDD     EXP
    SUBD    #1            ; Decrement exponent
    STD     EXP
    LDB #5
!   LSL 9,X
    ROL 8,X
    ROL 7,X
    ROL 6,X
    ROL 5,X
    ROL 4,X
    ROL 3,X
    ROL 2,X
    ROL 1,X
    ROL ,X
    DECB
    BNE <
;
; Use this code with the fast division method
 ELSE
; Shift it right by 4 bits so that the g starts at byte 8
;    LDD     EXP
;    SUBD    #1            ; Increment exponent
;    STD     EXP
    LDX #QUOTIENT
    LDB #4
!   LSR ,X
    ROR 1,X
    ROR 2,X
    ROR 3,X
    ROR 4,X
    ROR 5,X
    ROR 6,X
    ROR 7,X
    ROR 8,X
    ROR 9,X
    DECB
    BNE <
;
  ENDIF
;
; G is the MSbit we drop, R is the 2nd MSbit we drop, S is OR'ed with the other bits we dropped (0 or 1)
;   •	If G = 0, you’re less than halfway to the next representable mantissa, so you leave M unchanged.
;	•	If G = 1 and (R or S = 1) — i.e. you’re strictly more than halfway — you add 1 to M.
;	•	If G = 1, R = 0, S = 0 — i.e. you’re exactly halfway (the bit pattern is ...xyz1000…0) — you add 1 to M only if 
;                the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
; G starts at byte 8
    LDA     8,X         ; Look at G
    BPL     NoMantInc   ; if G=0 then leave Mantissa unchanged
; G = 1, look at R
    BITA    #%01000000  
    BNE     MantInc     ; if R = 1 then add 1 to Mantissa
; R = 0, look at S
    ANDA    #%00111111
    BNE     MantInc     ; if S = 1 then add 1 to Mantissa
; check more Sticky bits
    LDB     9,X
    ANDB    #%11110000  ; Only the 4 MSbits are valid
    BNE     MantInc     ; if S = 1 then add 1 to Mantissa
; R & S = 0, so check LSbit of Mantissa
    LDA     7,X         ; Get LSB
    RORA                ; move low order bit to the carry
    BCC     NoMantInc   ; If LSBit of Mantissa = 0 then skip adding 1 to the Mantissa
; Add one to the mantissa value
MantInc:
    INC 7,X
    BNE >
    INC 6,X
    BNE >
    INC 5,X
    BNE >
    INC 4,X
    BNE >
    INC 3,X
    BNE >
    INC 2,X
    BNE >
    INC 1,X
;   If that increment overflows to bit 53, shift right 1 and bump exponent by 1
    LDA 1,X ; 54321098
    BITA    #%00100000
    BEQ >
; We over flowed into bit 53 (54th bit)
    LSR 1,X
    ROR 2,X
    ROR 3,X
    ROR 4,X
    ROR 5,X
    ROR 6,X
    ROR 7,X
    LDD     EXP
    ADDD    #1            ; Increment exponent
    STD     EXP
!
NoMantInc:   
;
; Copy tweaked QUOTIENT to MANT1
  IF Div128Slow
    LDU     #QUOTIENT+6+1         ; *** Slow method
  ELSE
    LDU     #QUOTIENT+1          ; *** Fast method
  ENDIF
; Copy Quotient bytes to the stack
EXIT_DIV:
    PULU    B,X,Y
    LDU     ,U
    PSHS    B,X,Y,U
    LDA     SIGN        ; Gett the SIGN in A
    LDX     EXP         ; Get the EXPonent in X
    PSHS    A,X         ; Save the Sign & Exponent on the stack
@Return:
    JMP     >$FFFF      ; Return (Self modified address above)

; --- Shift routines ---
; SHIFT_RIGHT_1_64: Shift a 64-bit value right by 1 bit
; Input: X points to the 64-bit value (e.g., MANT1)
SHIFT_RIGHT_1_64:
    LSR     ,X
    ROR     1,X
    ROR     2,X
    ROR     3,X
    ROR     4,X
    ROR     5,X
    ROR     6,X
    ROR     7,X
    RTS                 ; Return

; SHIFT_RIGHT_1_128: Shift a 128-bit value right by 1 bit
; Input: X points to the 128-bit value (e.g., RESULT)
SHIFT_RIGHT_1_128:
    BSR     SHIFT_RIGHT_1_64    ; Shift 64 bits right 1 bit
    ROR     8,X                 ; Shift through the other 64 bits
    ROR     9,X
    ROR     10,X
    ROR     11,X
    ROR     12,X
    ROR     13,X
    ROR     14,X
    ROR     15,X
    RTS                     ; Return

; SHIFT_RIGHT_64_B:
; Description: Shift the 64-bit number at X Right by B bits
; Input: X points to the 64-bit number (big-endian), B = shift count (0 to 63)
; Output: The 64-bit number at X is shifted Right by B bits, X unchanged
; Clobbers Y & U
SHIFT_RIGHT_64_B:
    TSTB                    ; Test if shift count is zero
    BEQ     NO_SHIFT        ; If zero, no shift needed
    CMPB    #53             ; Compare shift count with 53
    BHS     ZERO_MANT       ; If >= 53, set mantissa to zero and return
    STB     SHIFT+1         ; Save the shift count
; Calculate byte_shift = B / 8
    LSRB                    ; Divide D by 8 (shift right 3 times)
    LSRB
    LSRB
    STB     BYTE_SHIFT
    BEQ     NO_BYTE_SHIFT
; Perform byte shift
    NEGB                    ; B = -B
    LEAY    8,X             ; Y = source (byte 7 - byte_shift+1)
    LEAY    B,Y             ; Adjust Y to MANT1 + (7 - byte_shift)
    ADDB    #8              ; Amount of bytes to move = B + 8
    LEAU    8,X             ; U = destination (byte 7+1)
!   LDA     ,-Y             ; Dec pointer then Load from source
    STA     ,-U             ; Dec pointer then Store to destination
    DECB                    ; Decrement counter
    BNE     <
    LDB     BYTE_SHIFT      ; Number of bytes to zero
    LEAU    ,X              ; U = X
!   CLR     ,U+             ; Zero high bytes
    DECB
    BNE     <
NO_ZERO:
NO_BYTE_SHIFT:
; Calculate bit_shift = total_shift % 8
    LDB     SHIFT+1         ; Reload shift count
    ANDB    #7              ; B = bit_shift (0-7)
; Store bit_shift to preserve it
    BEQ     NO_BIT_SHIFT
BIT_SHIFT_LOOP:
    JSR     SHIFT_RIGHT_1_64    ; Shift right by 1 bit
    DECB
    BNE     BIT_SHIFT_LOOP
NO_BIT_SHIFT:
NO_SHIFT:
    RTS
ZERO_MANT:
    LDD     #$0000
    STD     ,X
    STD     2,X
    STD     4,X
    STD     6,X
    RTS

; Convert 10 Byte Double @ ,S to Signed 64-bit Integer @ ,S
DB_TO_S64:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
; Copy Double off the stack, saved in SIGN, EXP & MANT (as 8 byte mantissa)
    PULS    B,X         ; Get the sign and exponent off the stack
    STB     SIGN        ; Save the SIGN
    STX     EXP         ; Save the EXPonent
    PULS    B,X,Y,U     ; Copy the 7 byte mantissa off the stack
    CLRA                ; First byte of mantissa is zero
    STU     MANT+6      ; Save U at destination address + 6
    LDU     #MANT+6     ; U points at the start of the destination location 
    PSHU    D,X,Y       ; Save the 6 bytes of data at the start of destination
;
    LDD     EXP             ; Get the exponent value
    BNE     @NotZero        ; If it's not zero then it could be Infinity or NAN
; If it is zero, check Mantissa MSbit
    LDA     MANT+1          ; Get the mantissa
    BITA    #%00010000      ; If Most Significant bit is zero then this is zero
    BEQ     @SET_ZERO_S64   ; Bit must normally be set, if it's not then this is a zero
    BRA     @NumberIsGood
; Check for Infinity or NAN
@NotZero:
    CMPD    #$8000
    BNE     @NumberIsGood
; It is Infinity or NAN
    LDA     MANT+1          ; Get the mantissa
    BITA    #%00010000      ; If Most Significant bit is zero then this is zero
    BNE     @NotANumber     ; Bit is 1 then it's Not a Number
; Bit is clear then it's infinity
@SET_MAX_MIN_S64
    LDA     SIGN
    BNE     @SET_MIN_S64
@SET_MAX_S64:
    LDU     #@MAX_S64
    BRA     >
@SET_MIN_S64:
    LDU     #@MIN_S64   ; Point at min value
    LDA     SIGN
    BEQ     >
    LEAU    8,U         ; Point at Max value
!   PULU    D,X,Y
    LDU     ,U
    PSHS    D,X,Y,U
    BRA     @Return
@MIN_S64    FCB $80,$00,$00,$00,$00,$00,$00,$00
@MAX_S64    FCB $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
; We set Not a Number to zero
@NotANumber:
@SET_ZERO_S64:
    LDD     #$0000
    LDX     #$0000
    PSHS    D,X
    PSHS    D,X
    BRA     @Return
@NumberIsGood:
; Check the Exponent value
    LDD     EXP
    BMI     @SET_ZERO_S64
    CMPD    #63
    BGT     @SET_MAX_MIN_S64
    STD     TEMP_E
    LDD     #52             ; High bit
    SUBD    TEMP_E
    STD     SHIFT
    LDU     #MANT           ; Point U at the start of source data
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    STU     INT64_OUT+6     ; Save U at destination address + 6
    LDU     #INT64_OUT+6    ; U points at the start of the destination location 
    PSHU    D,X,Y           ; Save the 6 bytes of data at the start of destination
    LDX     #INT64_OUT
;
    LDB     SHIFT+1
    BMI     @SHIFT_LEFT_S64
    JSR     SHIFT_RIGHT_64_B ; Shift the 64-bit number at X Right by D bits, X unchanged, clobbers Y & U
    BRA     @APPLY_SIGN_S64
;
@SHIFT_LEFT_S64:
    LDB     SHIFT+1
; Negate A (16-bit two's complement negation)
    NEGB                    ; Negate B (8-bit two's complement: -B = ~B + 1)
    JSR     SHIFT_LEFT_64_B ; Shift the 64-bit number at X left by B bits, X unchanged, clobbers Y & U
@APPLY_SIGN_S64:
    LDA     SIGN
    BEQ     @COPY_S64_OUT
    JSR     Negate_64       ; NEGATE_64
@COPY_S64_OUT:
    LDU     #INT64_OUT
    PULU    D,X,Y
    LDU     ,U
    PSHS    D,X,Y,U
@Return:
    JMP     >$FFFF          ; return (self modified)

; Convert 10 byte Double @ ,S to Unsigned 64-bit Integer @ ,S
DB_TO_U64:
    PULS    U               ; Get return address off the stack
    STU     @Return+1       ; Self modify the return location below
; Copy Double off the stack, saved in SIGN, EXP & MANT (as 8 byte mantissa)
    PULS    B,X         ; Get the sign and exponent off the stack
    STB     SIGN        ; Save the SIGN
    STX     EXP         ; Save the EXPonent
    PULS    B,X,Y,U     ; Copy the 7 byte mantissa off the stack
    CLRA                ; First byte of mantissa is zero
    STU     MANT+6      ; Save U at destination address + 6
    LDU     #MANT+6     ; U points at the start of the destination location 
    PSHU    D,X,Y       ; Save the 6 bytes of data at the start of destination
;
    LDD     EXP             ; Get the exponent value
    BNE     @NotZero        ; If it's not zero then it could be Infinity or NAN
; If it is zero, check Mantissa MSbit
    LDA     MANT+1          ; Get the mantissa
    BITA    #%00010000      ; If Most Significant bit is zero then this is zero
    BEQ     @SET_ZERO_U64   ; Bit must normally be set, if it's not then this is a zero
    BRA     @NumberIsGood
; Check for Infinity or NAN
@NotZero:
    CMPD    #$8000
    BNE     @NumberIsGood
; It is Infinity or NAN
    LDA     MANT+1          ; Get the mantissa
    BITA    #%00010000      ; If Most Significant bit is zero then this is zero
    BNE     @NotANumber     ; Bit is 1 then it's Not a Number
; Bit is clear then it's infinity
@SET_MAX_MIN_S64
    LDA     SIGN
    BNE     @SET_MIN_U64
@SET_MAX_U64:
    LDU     #@MAX_U64
    BRA     >
@SET_MIN_U64:
    LDU     #@MIN_U64   ; Point at min value
    LDA     SIGN
    BEQ     >
    LEAU    8,U         ; Point at Max value
!   PULU    D,X,Y
    LDU     ,U
    PSHS    D,X,Y,U
    BRA     @Return
@MIN_U64    FCB $00,$00,$00,$00,$00,$00,$00,$00
@MAX_U64    FCB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
; We set Not a Number to zero
@NotANumber:
@SET_ZERO_U64:
    LDD     #$0000
    LDX     #$0000
    PSHS    D,X
    PSHS    D,X
    BRA     @Return
@NumberIsGood:
    LDD     EXP
    BMI     @SET_ZERO_U64
    CMPD    #63
    BGT     @SET_MAX_U64
    STD     TEMP_E
    LDD     #52
    SUBD    TEMP_E
    STD     SHIFT
    LDU     #MANT
    LDX     #INT64_OUT
    LDD     ,U
    STD     ,X
    LDD     2,U
    STD     2,X
    LDD     4,U
    STD     4,X
    LDD     6,U
    STD     6,X
    LDD     SHIFT
    BMI     @SHIFT_LEFT_U64
    JSR     SHIFT_RIGHT_64_B ; Shift the 64-bit number at X Right by D bits, X unchanged, clobbers Y & U
    BRA     @COPY_U64_OUT
;    
@SHIFT_LEFT_U64:
; Negate B
    NEGB                ; Negate B (8-bit two's complement: -B = ~B + 1)
    JSR     SHIFT_LEFT_64_B ; Shift the 64-bit number at X left by B bits, X unchanged, clobbers Y & U
@COPY_U64_OUT:
    LDU     #INT64_OUT
    PULU    D,X,Y
    LDU     ,U
    PSHS    D,X,Y,U
@Return:
    JMP     >$FFFF          ; return (self modified)

; Convert 10 Byte Double at ,S to 32-bit signed integer at ,S
DB_TO_S32:
    PULS    U               ; Get return address off the stack
    STU     @Return+1       ; Self modify the return location below
    JSR     DB_TO_S64       ; Convert 10 Byte Double @ ,S to Signed 64-bit Integer @ ,S
    PULS    D,X             ; Pull two high signed words off the 64 bit number on the stack, Save only the two low words
@Return:
    JMP     >$FFFF          ; return (self modified)

; Convert 10 Byte Double at ,S to 32-bit unsigned integer at ,S
DB_TO_U32:
    PULS    U               ; Get return address off the stack
    STU     @Return+1       ; Self modify the return location below
    JSR     DB_TO_U64       ; Convert 10 byte Double @ ,S to Unsigned 64-bit Integer @ ,S
    PULS    D,X             ; Pull two high unsigned words off the 64 bit number on the stack, Save only the two low words
@Return:
    JMP     >$FFFF          ; return (self modified)

; Convert 10 Byte Doublee at ,S to 16-bit signed integer at ,S
DB_TO_S16:
    PULS    U               ; Get return address off the stack
    STU     @Return+1       ; Self modify the return location below
    JSR     DB_TO_S64       ; Convert 10 Byte Double @ ,S to Signed 64-bit Integer @ ,S
    PULS    D,X,Y           ; Pull three high signed words off the 64 bit number on the stack, Save only the low word
@Return:
    JMP     >$FFFF          ; return (self modified)

; Convert 10 Byte Double at ,S to 16-bit unsigned integer at ,S
DB_TO_U16:
    PULS    U               ; Get return address off the stack
    STU     @Return+1       ; Self modify the return location below
    JSR     DB_TO_U64       ; Convert 10 byte Double @ ,S to Unsigned 64-bit Integer @ ,S
    PULS    D,X,Y           ; Pull three high unsigned words off the 64 bit number on the stack, Save only the low word
@Return:
    JMP     >$FFFF          ; return (self modified)

; Subroutine: SHIFT_LEFT_64_B
; Description: Shift the 64-bit number at X left by B bits
; Input: X points to the 64-bit number (big-endian), B = shift count (0 to 63)
; Output: The 64-bit number at X is shifted left by B bits, X unchanged
; Clobbers Y & U
SHIFT_LEFT_64_B:
; Check if D >= 64, if so, set the number to zero
    CMPB    #64
    BLO     DO_SHIFT_Left
; Set to zero
    LDD     #$0000
    STD     ,X
    STD     2,X
    STD     4,X
    STD     6,X
    RTS

DO_SHIFT_Left:
; Compute byte_shift = B / 8
    TFR     B,A
; Compute bit_shift = B % 8
    ANDA    #7
    STA     BIT_SHIFT
    LSRB
    LSRB
    LSRB
    STB     BYTE_SHIFT
    BEQ     NO_BYTE_SHIFT_Left
; If byte_shift > 0, perform byte shift
    LEAU    ,X     ; U = X
    LDB     BYTE_SHIFT
    LEAY    B,X    ; Y = X + BYTE_SHIFT
; Compute number of bytes to copy = 8 - BYTE_SHIFT
    LDB     #8
    SUBB    BYTE_SHIFT
; Copy B bytes from Y to X
COPY_LOOP:
    LDA     ,Y+
    STA     ,U+
    DECB
    BNE     COPY_LOOP
; Set the remaining BYTE_SHIFT bytes to zero
    LDB     BYTE_SHIFT
    BEQ     NO_ZERO_Left
ZERO_LOOP_Left:
    CLR     ,U+
    DECB
    BNE     ZERO_LOOP_Left
NO_ZERO_Left:
NO_BYTE_SHIFT_Left:
; Perform bit shift if bit_shift > 0
    LDB     BIT_SHIFT
    BEQ     NO_BIT_SHIFT_Left
Shift_Left_B_Bits:
!   ASL     7,X
    ROL     6,X
    ROL     5,X
    ROL     4,X
    ROL     3,X
    ROL     2,X
    ROL     1,X
    ROL     ,X
    DECB
    BNE     <
NO_BIT_SHIFT_Left:
    RTS

; Convert Unsigned 32bit integer @,S to 10 byte Double @ ,S
U32_To_Double:
    PULS    U               ; Get return address
    STU     @Return+1       ; Self mod return address
    LDD     ,S
    BNE     >               ; Not zero skip ahead
    LDU     2,S         
    BEQ     @D64_ZERO       ; If zero then return with double value as zero
!   CLR     SIGN
    BRA     @Convert        ; Reuse the conversion code below
; Convert signed 32bit integer @,S to 10 byte Double @ ,S
S32_To_Double:
    PULS    U               ; Get return address
    STU     @Return+1       ; Self mod return address
    LDD     ,S
    BNE     >               ; Not zero skip ahead
    LDU     2,S         
    BEQ     @D64_ZERO       ; If zero then return with double value as zero
!   CLR     SIGN          
    TSTA
    BPL     @Convert        ; Skip forward if positive
    LDA     #%10000000      ; Move sign bit to the carry
    STA     SIGN            ; Set the sign into bit 7 of SIGN
; Negate value to make it positive
; Invert each byte
    COM     ,S
    COM     1,S
    COM     2,S
    COM     3,S
; + 1
; Propagate if needed
    INC     3,S
    BNE     @Convert        ; If <> zero, don't propagate carry, done
    INC     2,S
    BNE     @Convert        ; If <> zero, don't propagate carry, done
    INC     1,S
    BNE     @Convert        ; If <> zero, don't propagate carry, done
    INC     ,S
@Convert:
    LDX     #U64_IN
    PULS    D,U             ; Get 32 bit integer off the stack
    STD     ,X
    STU     2,X
    LDD     #$0000
    STD     4,X
    STD     6,X
    JSR     FIND_MSB_64_For_Single  ; Find position of highest set bit in 64-bit number at X, returns A = position (0-63, or 255 if zero)
    PSHS    A
    TFR     A,B
    SUBB    #32
    CLRA
    STD     EXP                     ; Save biased exponent
    PULS    B
    SUBB    #63                     ; move it to bit 63
    NEGB                            ; Make it positive
    JSR     SHIFT_LEFT_64_B ; Shift the 64-bit number at X left by B bits, X unchanged, clobbers Y & U
    LDB     #3+8            ; Shift right 3+8 bits
    JSR     SHIFT_RIGHT_64_B ; Shift the 64-bit number at X Right by B bits, X unchanged, clobbers Y & U
    LDU     #U64_IN+1       ; Point at result
; Copy mantissa bytes to the stack
    PULU    B,X,Y
    LDU     ,U
    PSHS    B,X,Y,U
    LDA     SIGN        ; Gett the SIGN in A
    LDX     EXP         ; Get the EXPonent in X
    PSHS    A,X         ; Save the Sign & Exponent on the stack
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
;
; Ouput DOUBLE as all zeros
@D64_ZERO:
    LEAX    ,U              ; X = U = 0
    PSHS    D,X,U           ; Push 6 more zero's on the stack
    BRA     @Return         ; Return

; Convert unsigned 16bit integer in D to 10 byte Double @ ,S
UnInt2Double:
    PULS    U               ; Get return address
    STU     @Return+1       ; Self mod return address
    CLR     SIGN            ; Clear Sign bit
    CMPD    #$0000
    BEQ     @D64_ZERO       ; Ouput DOUBLE_OUT as all zeros
    BRA     >               ; Skip ahead and reuse the rest of Int2Double code
; Convert signed 16bit integer in D to 10 byte Double @ ,S
Int2Double:
    PULS    U               ; Get return address
    STU     @Return+1       ; Self mod return address
    CLR     SIGN            ; Clear Sign bit
    CMPD    #$0000
    BEQ     @D64_ZERO       ; Ouput DOUBLE_OUT as all zeros
    BPL     >               ; Skip forward if positive
    PSHS    A
    LDA     #%10000000      ; Move sign bit
    STA     SIGN            ; Set the sign into bit 7 of SIGN
    PULS    A
; Negate D to make it positive
    NEGA                    ; Negate A (8-bit two's complement: -A = ~A + 1)
    NEGB                    ; Negate B (8-bit two's complement: -B = ~B + 1)
    SBCA    #0              ; Subtract 0 from A with borrow (propagate carry from NEGB)
!   LDX     #U64_IN
    STD     ,X
    LDD     #$0000
    STD     2,X
    STD     4,X
    STD     6,X
    JSR     FIND_MSB_64_For_Single  ; Find position of highest set bit in 64-bit number at X, returns A = position (0-63, or 255 if zero)
    PSHS    A
    TFR     A,B
    SUBB    #48
    CLRA
    STD     EXP             ; Save biased exponent
    PULS    B
    SUBB    #63             ; move it to bit 63
    NEGB                    ; Make it positive
    JSR     SHIFT_LEFT_64_B ; Shift the 64-bit number at X left by B bits, X unchanged, clobbers Y & U
    LDB     #3+8            ; Shift right 3+8 bits
    JSR     SHIFT_RIGHT_64_B ; Shift the 64-bit number at X Right by B bits, X unchanged, clobbers Y & U
    LDU     #U64_IN+1       ; Point at result
; Copy mantissa bytes to the stack
    PULU    B,X,Y
    LDU     ,U
    PSHS    B,X,Y,U
    LDA     SIGN        ; Gett the SIGN in A
    LDX     EXP         ; Get the EXPonent in X
    PSHS    A,X         ; Save the Sign & Exponent on the stack
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
;
; Ouput DOUBLE as all zeros
@D64_ZERO:
    TFR     D,X
    PSHS    D,X             ; Store Double Zero value on the stack
    PSHS    D,X             ; Store Double Zero value on the stack
    STD     ,--S            ; Store zero on the stack
    BRA     @Return         ; Return

; 
; 3 byte Fast Floating Point (FFP) format
; SEEEEEEE|MMMMMMMM|MMMMMMMM
;
; Convert 3 byte FFP at ,S to 10 byte Double at ,S
FFP_To_Double:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self mod return address
;
      CLRA
      LDB   ,S          ; B = Sign & Exponent byte
      LEAS  -7,S        ; Make room for a 10 byte Double number on the stack
      LSLB              ; Carry = sign bit
      BCC   >
      LDA   #$80
!     STA   ,S          ; Save the Sign
      CMPB  #$80        ; See if we were $40 (special)
      BEQ   @Special    ; save Double as a special
      ASRB              ; Make Exponent 8 bit
      SEX               ; Sign Extend B to 16 bit value in D
      STD   1,S         ; Save exponent
      LDD   8,S         ; Get Mantissa
      CLR   5,S
      LSRA
      RORB
      ROR   5,S
      LSRA
      RORB
      ROR   5,S
      LSRA
      RORB
      ROR   5,S
!     STD   3,S         ; Save mantissa bits
      LDD   #$0000
      STD   6,S
      STD   8,S
@Return:
      JMP   >$FFFF      ; Return, self modified jump address
@Special:
      LDD   #$8000      ; Flag double value as special
      STD   1,S         ; Signify Double is Special
      STB   5,S         ; Clear this part of the Mantissa
      LDA   8,S         ; Get the MSB of mantissa
      BMI   @NaN        ; If MSbit is 1 then it's NaN
; We get here with infinity
      CLRA              ; B is already zero
      BRA   <           ; Save the rest of the mantissa and exit
; Not a Number
@NaN:
      LDA   #%00010000  ; Double Mantissa MSbit is set, B is already zero
      BRA   <           ; Save the rest of the mantissa and exit

; Convert 10 byte Double at ,S to 3 Byte FFP at ,S
Double_To_FFP:
    PULS    U               ; Get return address
    STU     @Return+1       ; Self mod return address
;
; Figure out if exponent is too low or too big
    LDD     1,S
    CMPD    #$003F
    BGT     @ExpTooBig
    CMPD    #-$3F
    BLT     @ExpTooSmall
; If we get here then it's a number we can use, just need to round it
@GoodNumber
;
; If it's greater that 24 then we shift it right and round up the portion we will crop (LSbits)
; To make it IEEE 754 compliant when cropping we should:
; G is the MSbit we drop, R is the 2nd MSbit we drop, S is OR'ed with the other bits we dropped (0 or 1)
;   •	If G = 0, you’re less than halfway to the next representable mantissa, so you leave M unchanged.
;	•	If G = 1 and (R or S = 1) — i.e. you’re strictly more than halfway — you add 1 to M.
;	•	If G = 1, R = 0, S = 0 — i.e. you’re exactly halfway (the bit pattern is ...xyz1000…0) — you add 1 to M only if 
;                the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
;
; Shift the 3 MS bytes of the mantissa, so we can round and copy to FFP easier
    LSL     5,S
    ROL     4,S
    ROL     3,S
    LSL     5,S
    ROL     4,S
    ROL     3,S
    LSL     5,S
    ROL     4,S
    ROL     3,S
    LDA     5,S                 ; Get the bits to figure out rounding
    LSLA
    BCC     @SkipRound          ; G = 0, so no rounding
    LSLA                        ; G = 1, So move R into the Carry
    BCS     @Add_One            ; G = 1 & R = 1 Add one to Mantissa
    TSTA                        ; A is the rest of the sticky bits we now have the Stickey value
    BNE     @Add_One            ; G = 1 & S = 1 Add one to Mantissa
; G = 1, R & S both = 0
; Add 1 to M only if the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
    LDB     4,S
    BITB    #%00000001          ; Check LSBit
    BEQ     @SkipRound          ; Lowest bit of mantissa is 0 so no adding
@Add_One:
    INC     4,S
    BNE     @SkipRound
    INC     3,S
    BNE     @SkipRound
; Get here if the value will Overflow
    LDD     1,S
    CMPD    #$40
    BGE     @ExpTooBig
    ADDD    #$0001             ; Mantissa overflow so add one
    STD     1,S
@SkipRound:
    LDB     2,S             ; Get the exponent
    ANDB    #%01111111      ; Strip off bit 7
    ORB     ,S              ; OR in the sign bit
    LDX     3,S
    LEAS    10,S            ; Fix the stack
    PSHS    B,X             ; Save FFP value
@Return:
    JMP     >$FFFF          ; Self mod return address
;
@ExpTooBig:
    LDB     #%01000000      ; +Infinity
    LDX     #$0000
    PSHS    B,X
    BRA     @Return
@ExpTooSmall:               
    LDB     #%11000000      ; -Infinity
    LDX     #$0000
    PSHS    B,X
    BRA     @Return
;

;******************************************************************************
; Print 10 byte double at address in U to CoCo screen
; Output in decimal format, using scientific notation for large/small numbers
;
; Byte 0 bit 7 is the sign, the rest of the bits are zero's
; Byte 1 & 2 are the exponent, exp -1023 = normalized exponent value

; Constants
;DB_ONE      FCB     $3F,$F0,$00,$00,$00,$00,$00,$00 ; IEEE-754 double for 1.0
DB_ONE      FCB     $00,$00,$00,$10,$00,$00,$00,$00,$00,$00 ; Unpacked 10 byte double for 1.0
;DB_TEN      FCB     $40,$24,$00,$00,$00,$00,$00,$00 ; IEEE-754 double for 10.0
DB_TEN      FCB     $00,$00,$03,$14,$00,$00,$00,$00,$00,$00 ; Unpacked 10 byte double for 10.0
;DB_TENPOW15 FCB     $43,$0C,$6B,$F5,$26,$34,$00,$00 ; IEEE-754 double for 10^15
DB_TENPOW15 FCB     $00,$00,$31,$1C,$6B,$F5,$26,$34,$00,$00 ; Unpacked 10 byte double for 10^15
Double_Inv10    FCB $00,$FF,$FC,$19,$99,$99,$99,$99,$99,$9A ; value of 0.1

; Variables
DB_Exponent EQU   Short1_04     ; Decimal exponent (signed)
STRBUF      EQU   _StrVar_PF01  ; String buffer for output (max 32 chars)

; Print Double value @,S
PRINT_DOUBLE:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
; Check for special Exponent
    LDD     1,S
    CMPD    #$8000
    BNE     >
; We get here when it's either Infinity or Not A Number
    LDA     #' '            ; Space before the dot
    JSR     PrintA_On_Screen
    LDA     #'.'
    JSR     PrintA_On_Screen
    LEAS    10,S            ; Fix the stack
    JMP     @Return         ; Return
; Check if number is zero   ; Check for zero
!   CMPD    #$0000          ; Is the exponent zero?
    BNE     @NotZero        ; If Exponent is anything else than we are not zero
    LDD     3,S             ; Check Mantissa bits first for zero
    BNE     @NotZero
    LDD     5,S
    BNE     @NotZero
    LDY     7,S
    BNE     @NotZero
    LDA     9,S
    BNE     @NotZero
    JSR     DB_PRINT_ZERO   ; If zero, print "0"
    LEAS    10,S            ; Fix the stack
    JMP     @Return         ; Return
;
; Not zero print the number
; Get sign and make number positive
; A = 0 (positive) or $80 (negative)
@NotZero:
    LDA     ,S              ; Load first byte
    STA     SIGN_TEMP       ; Save the original sign value
    CLR     ,S              ; Clear sign bit, make it positive
;
; Scale the Number:
; Initialize a decimal exponent DB_Exponent to 0.
; Loop to divide by 10 while the number is ≥ 10, incrementing DB_Exponent
; Loop to multiply by 10 while the number is < 1, decrementing DB_Exponent
; This scales the number to the range [1, 10).
;
; Initialize decimal exponent
    CLR   DB_Exponent       ; Exponent = 0
;
; Scale number: while x >= 10.0, divide by 10, increment Exponent
SCALE_GE_10:
; Pushing 10 bytes onto the stack
    LDU     #DB_TEN+2       ; Point at Double value of 10 + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_TEN          ; Get the first 2 bytes of data
    PSHS    D               ; Double Value of 10 is now @ ,S
;
    JSR     Double_CMP_Stack     ; Compare Double Value1 @ 10,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
    LEAS    10,S            ; Move the stack forward,
    BLO     SCALE_LT_1      ; If x < 10, proceed to next check
;
; --- Divide Double by 10, fastest way is to multiply by 0.1 --- (,S = ,S * 0.1)
    LDU     #Double_Inv10+2 ; U = &Double_Inv10 + 2
    PULU    D,X,Y           ; gets 6 bytes from Double_Inv10, U advanced
    LDU     ,U              ; get last 2 bytes into U (mantissa tail low)
    PSHS    D,X,Y,U         ; push mantissa tail (8 bytes)
    LDD     Double_Inv10    ; sign byte + high exponent byte
    PSHS    D               ; push them
;
    JSR     DB_MUL            ; x * 0.1  -> result at ,S
    INC     DB_Exponent     ; Exponent = Exponent + 1
    BRA     SCALE_GE_10     ; Repeat
;
; While x < 1.0, multiply by 10, decrement Exponent
SCALE_LT_1:
; Point to Double value of 1.0
!   LDU     #DB_ONE+2       ; Point U at the start of source data + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_ONE          ; Get the first 2 bytes of data
    PSHS    D               ; Double Value of 1 is now @ ,S  
;
    JSR     Double_CMP_Stack     ; Compare Double Value1 @ 10,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
    LEAS    10,S        ; Move the stack forward, so it can be filled with the Double value of Ten
    BHS     >           ; If x >= 1, proceed to digit extraction
;
    LDU     #DB_TEN+2       ; Point U at the start of source data + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_TEN          ; Get the first 2 bytes of data
    PSHS    D               ; Double Value of 10 is now @ ,S  
;
    JSR     DB_MUL          ; Multiply 10,S * ,S Then S=S+10 result @ ,S
    DEC     DB_Exponent     ; Exponent = Exponent - 1
    BRA     <               ; Keep looping
;
; Multiply x by 10^15 to get integer part
!   LDU     #DB_TENPOW15+2  ; Point U at the start of source data + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_TENPOW15     ; Get the first 2 bytes of data
    PSHS    D               ; Double Value of 10^15 is now @ ,S
;
    JSR     DB_MUL          ; Multiply 10,S * ,S Then S=S+10 result @ ,S
    JSR     DB_TO_U64       ; Convert 10 byte Double @ ,S to Unsigned 64-bit Integer @ ,S
    LEAU    ,S
    JSR     INT64_TO_STR_DB ; Convert 64-bit integer at ,U to decimal string in STRBUF, Return length in B
;
; Check notation based on DB_Exponent
    LDA     #' '
    LDB     SIGN_TEMP
    BPL     >
    LDA     #'-'    ; Print minus sign if negative
!   JSR     PrintA_On_Screen
    LDA     DB_Exponent
    CMPA    #-4
    BGE     >
    BSR     DB_SCIENTIFIC
    BRA     @Done           ; Fix the stack & Return
!   CMPA    #10
    BLE     >
    BSR     DB_SCIENTIFIC
    BRA     @Done           ; Fix the stack & Return
!   BSR     DB_DECIMAL
@Done:
    LEAS    8,S             ; Fix the stack
@Return:
    JMP     >$FFFF          ; Return, self modified jump address

DB_SCIENTIFIC:
    LDA     STRBUF         ; First digit
    JSR     PrintA_On_Screen
    LDA     #'.'           ; Decimal point
    JSR     PrintA_On_Screen
    LDU     #STRBUF+1      ; Point to remaining digits
    LDB     #14            ; Print up to 14 more digits
PRINT_DIGITS:
    LDA     ,U+
    BEQ     PAD_ZERO       ; If string ends early, pad with zeros
    JSR     PrintA_On_Screen
    DECB
    BNE     PRINT_DIGITS
    BRA     PRINT_EXP
PAD_ZERO:
    LDA     #'0'
    JSR     PrintA_On_Screen
    DECB
    BNE     PAD_ZERO
;
PRINT_EXP:
    LDA     #'E'
    JSR     PrintA_On_Screen
    LDB     DB_Exponent
    BPL     EXP_POS
    LDA     #'-'
    JSR     PrintA_On_Screen
    LDB     DB_Exponent
    NEGB                 ; Absolute value of E
    BRA     EXP_NUM
EXP_POS:
    LDA     #'+'
    JSR     PrintA_On_Screen
    LDB     DB_Exponent
EXP_NUM:
    CLRA
    JMP     PRINT_D_No_Space  ; Jump & Return
;
DB_DECIMAL:
    LDA     DB_Exponent
    BGE     DEC_POS_EXP
; DB_Exponent < 0
    LDA     #'0'
    JSR     PrintA_On_Screen
    LDA     #'.'
    JSR     PrintA_On_Screen
    LDB     DB_Exponent
    CMPB    #-1
    BEQ     NO_ZEROS      ; No extra zeros for E = -1
    NEGB                ; A = -DB_Exponent
    SUBB    #1            ; Number of leading zeros
    BLE     NO_ZEROS
    LDA     #'0'
!   JSR     PrintA_On_Screen
    DECB
    BNE     <
NO_ZEROS:
    LDU     #STRBUF-1
    LDB     #16     
!   DECB                ; Print up to 15 digits (16 -1)
    BEQ     >
    LDA     B,U         ; Check and skip any trailing zeros
    CMPA    #'0'
    BEQ     <
    INCB
DIGIT_LOOP_NEG:
    LDA     ,U+
    JSR     PrintA_On_Screen
    DECB
    BNE     DIGIT_LOOP_NEG
!   RTS
;
; DB_Exponent > 0
DEC_POS_EXP:
    LDB     DB_Exponent
    INCB                    ; B = DB_Exponent + 1 (digits before decimal)
    LDU     #STRBUF
INT_PART:
    LDA     ,U+
    JSR     PrintA_On_Screen
    DECB
    BNE     INT_PART
    LDB     #14
    SUBB    DB_Exponent     ; B = 15 - (DB_Exponent + 1)
    BEQ     DEC_DONE        ; No fractional part if B = 0
; Check if the rest is zeros if so stop printing any trailing zeros
; ----- Trim trailing zeros from the right (safe) -----
; U = U + (B - 1)  -> points to last fractional digit
    DECB                    ; B = B - 1 (last index)
    BMI     DEC_DONE        ; (shouldn’t happen; guards BEQ above)
@TrimTail:
    LDA     B,U             ; load digit at U + B
    CMPA    #$30            ; '0' ?
    BNE     @HaveFracCount  ; stop trimming when non-zero digit
    DECB                    ; drop one trailing zero
    BPL     @TrimTail
    ; All fractional digits were zeros → don't print decimal point
    BRA     DEC_DONE
@HaveFracCount:
    INCB                    ; restore count of fractional digits
    BEQ     DEC_DONE        ; none left? (paranoia)
    LDA     #'.'
    JSR     PrintA_On_Screen
; print exactly B digits from U
FRAC_LOOP:
    LDA     ,U+
    JSR     PrintA_On_Screen
    DECB
    BNE     FRAC_LOOP
DEC_DONE:
    RTS

DB_PRINT_ZERO:
    LDA     #' '            ; Space before the zero
    JSR     PrintA_On_Screen
    LDA     #'0'
    JSR     PrintA_On_Screen
    RTS

; Compare Double Value1 @ 12,S with Value 2 @ 2,S sets the 6809 flags Z, N, and C
; On entry (CALLER view):
;   Value1: 10,S..19,S
;   Value2: ,S..9,S
; Sets CC like CMP for "Value1 ? Value2" such that:
;   BLO => Value1 < Value2
;   BHI => Value1 > Value2
;   BEQ => Value1 = Value2
Double_CMP_Stack:
; 80FFFD199900 Value 2, 00FFFD199900 Value 1
; 000000000000 Value 2, 00FFFD199900 Value 1
    ; Offsets inside routine (because return address is at ,S / 1,S)
    ; Value1 base = 12,S
    ; Value2 base = 2,S
    ; ---- Sign handling (must be explicit, since sign byte is 00 or 80) ----
    LDA     12,S            ; sign1
    CMPA    2,S             ; sign2
;    BNE     @Done           ; if different, we're done (flags set)
      LBLO   @SetGT            ; value2 < value1
      LBHI   @SetLT            ; Value2 > Value1
    TSTA
    BPL     @PosCompare     ; if sign is positive, do normal compare
; -------------------------
; Both NEGATIVE: reverse compare for exponent/mantissa
; -------------------------
    LDA     2+10+1+2,S      ; Check if Value1 is zero
    BNE     @NegV1NotZero
; zero, copy exp value1 to exp value2 and compare mantissa (zero will have a mantissa of zero)
    LDD     2+0+1,S         ; Get as Value2 exp
    STD     2+10+1,S        ; Save Value1 exp
    BRA     @NegCompMantissas
@NegV1NotZero:
    LDA     2+0+1+2,S       ; Check if Value2 is zero
    BNE     @NegNormalCheck
; zero, copy exp value1 to exp value2 and compare mantissa (zero will have a mantissa of zero)
    LDD     2+10+1,S        ; Get Value1 exp
    STD     2+0+1,S         ; Save as Value2 exp
    BRA     @NegCompMantissas
@NegNormalCheck:
    LDD     2+10+1,S        ; Value1 exp
    ADDD    #$2000
    PSHS    D               ; save exp1'
;
    LDD     2+0+1+2,S       ; Value2 exp, extra 2 becuase of the stack usage above
    ADDD    #$2000
    CMPD    ,S++            ; compare exp2' vs exp1'  (reversed), fix the stack
;    BNE     @Done
      BLO   @SetLT          ; value2 < value1
      BHI   @SetGT          ; Value2 > Value1
;
; Compare mantissas reversed: Value2 vs Value1
@NegCompMantissas:
    LDU     2+3,S           ; Value2 mantissa
    CMPU    2+13,S          ; Value1 mantissa
    BNE     @Done
    LDU     2+5,S           ; Value2 mantissa
    CMPU    2+15,S          ; Value1 mantissa
    BNE     @Done
    LDU     2+7,S           ; Value2 mantissa
    CMPU    2+17,S          ; Value1 mantissa
    BNE     @Done
    LDA     2+9,S           ; Value2 mantissa
    CMPA    2+19,S          ; Value1 mantissa
@Done:
      BLO   @SetLT            ; value2 < value1
      BHI   @SetGT            ; Value2 > Value1
      BRA   @SetEQ            ; Value2 = Value1
; -------------------------
; POSITIVE (or both same sign and not negative): normal compare
; -------------------------
; 000000000000 Value 2 = 0, 00FFFD199900 Value 1 = .2
; we know both are positive numbers, but looking at the exponent alone will not work if one of them is zero
; and the other is < 1 (negative exponent)
;
@PosCompare:
    LDA     2+0+1+2,S       ; Check if Value2 is zero
    BNE     @PosV2NotZero
; zero, copy exp value1 to exp value2 and compare mantissa (zero will have a mantissa of zero)
    LDD     2+10+1,S        ; Get Value1 exp
    STD     2+0+1,S         ; save as Value2 exp
    BRA     @PosCompMantissas
@PosV2NotZero:
    LDA     2+10+1+2,S      ; Check if Value1 is zero
    BNE     @PosNormalCheck
; zero, copy exp value1 to exp value2 and compare mantissa (zero will have a mantissa of zero)
    LDD     2+0+1,S         ; Get as Value2 exp
    STD     2+10+1,S        ; Save Value1 exp
    BRA     @PosCompMantissas
@PosNormalCheck:
    LDD     2+0+1,S         ; Value2 exp
    ADDD    #$2000
    PSHS    D               ; save exp2'
;
    LDD     2+10+1+2,S        ; Value1 exp, extra 2 becuase of the stack usage above
    ADDD    #$2000
    CMPD    ,S++            ; compare exp1' vs exp2' (normal), fix the stack
;    BNE     @Done1
      BLO   @SetLT            ; value2 < value1
      BHI   @SetGT            ; Value2 > Value1
;
; Compare mantissas normal: Value1 vs Value2
@PosCompMantissas
    LDU     2+13,S          ; Value1 mantissa
    CMPU    2+3,S           ; Value2 mantissa
    BNE     @Done1
    LDU     2+15,S          ; Value1 mantissa
    CMPU    2+5,S           ; Value2 mantissa
    BNE     @Done1
    LDU     2+17,S          ; Value1 mantissa
    CMPU    2+7,S           ; Value2 mantissa
    BNE     @Done1
    LDA     2+19,S          ; Value1 mantissa
    CMPA    2+9,S           ; Value2 mantissa
@Done1:
      BLO   @SetLT            ; value1 < value2
      BHI   @SetGT            ; Value1 > Value2
; If Equal follow through
; --- canonical flag setters for signed branches ---
; Equal: N=0 Z=1 V=0 C=0 - N Z V C
@SetEQ: 
      ANDCC #%11110000
      ORCC  #%00000100      
@Done2:
      RTS
; Less:   N=1 Z=0 V=0 C=1 - CC.N ≠ CC.V
@SetLT:
      ANDCC #%11110000
      ORCC  #%00001001
      RTS
; Greater: N=0 Z=0 V=0 C=0 - (CC.N = CC.V) AND (CC.Z = 0)
@SetGT:
      ANDCC #%11110000
      RTS

; Convert 64-bit integer at ,U to decimal string in STRBUF
; Return length in A
; Main routine
INT64_TO_STR_DB:
    LDY     #STRBUF         ; Point Y to string buffer        
; Copy 64-bit integer to Big8_01
    LDD     ,U              ; Load first 16 bits
    STD     Big8_01         ; Store in Big8_01
    LDD     2,U             ; Load next 16 bits
    STD     Big8_01+2
    LDD     4,U             ; Load next 16 bits
    STD     Big8_01+4
    LDD     6,U             ; Load last 16 bits
    STD     Big8_01+6
; Check if the number is zero
    LDD     ,U
    BNE     >               ; If non-zero, proceed
    LDD     2,U
    BNE     >               ; If non-zero, proceed
    LDD     4,U
    BNE     >               ; If non-zero, proceed
    LDD     6,U
    BNE     >               ; If non-zero, proceed
; Number is zero
    LDA     #'0'            ; Load ASCII '0'
    STA     ,X              ; Store in STRBUF
    LDA     #1              ; Length = 1
    RTS                     ; Return

DB_DigitCount   RMB 1
; NOT_ZERO
; Initialize digit counter
!   CLR     DB_DigitCount   ; A will hold the digit count

; Division loop: divide Big8_01 by 10, collect remainders
DIV_LOOP:
    JSR     DIV64_BY_10     ; Divide Big8_01 by 10, remainder in B
    ADDB    #'0'            ; Convert remainder to ASCII
    PSHS    B               ; Push digit onto stack
    INC     DB_DigitCount   ; Increment digit count
; Check if Big8_01 is zero
    LDU     Big8_01
    BNE     DIV_LOOP        ; If non-zero, proceed
    LDU     Big8_01+2
    BNE     DIV_LOOP        ; If non-zero, proceed
    LDU     Big8_01+4
    BNE     DIV_LOOP        ; If non-zero, proceed
    LDU     Big8_01+6
    BNE     DIV_LOOP        ; If non-zero, proceed
; Number is zero
; Pop digits from stack and store in STRBUF
!   PULS    B               ; Pop digit from stack
    STB     ,Y+             ; Store in STRBUF
    DEC     DB_DigitCount   ; Decrement counter
    BNE     <               ; Continue until all digits are popped
; Return length in B
    TFR     Y,D             ; D = Y
    SUBD    #STRBUF         ; B = String buffer length used
    RTS

; Subroutine to divide 64-bit INT by 10
; Input: Big8_01 (64-bit number)
; Output: Big8_01 updated with quotient, remainder in B
DIV64_BY_10:
    LDX     #Big8_01        ; Point to MSB of Big8_01
    LDD     #$0800          ; A = Counter for 8 bytes
    PSHS    D               ; ,S =  8 & 1,S = 0    
BYTE_LOOP:
    LDA     1,S             ; Load current remainder into A
    LDB     ,X              ; Load current byte into B (D = A*256 + B)
; Loop to divide 16-bit number by 10
; U = quotient, B = remainder
    LDU     #$FFFF          ; Initialize quotient counter to -1
!   LEAU    1,U             ; Increment quotient
    SUBD    #10             ; Subtract 10 from D, Compare D with 10
    BHS     <               ; If D >= 10, Keep looping
    ADDD    #10             ; Fix value in D
    STB     1,S             ; Save remainder for next iteration
    TFR     U,D             ; D = U, B = LSB of U
    STB     ,X+             ; Store quotient back into current byte, move to next byte (towards LSB)
    DEC     ,S              ; Decrement byte counter
    BNE     BYTE_LOOP       ; Continue until all bytes processed
    PULS    A,B,PC          ; Fix stack, A=0, B = Final Remainder & return

; Round Mantissa @ ,X where Mantissa is 7 bytes 0 to 6, extra bits are in byte 7 (eighth byte)
; EXP will be incremented if needed & mantissa will be divided by 2 
; G is the MSbit we drop, R is the 2nd MSbit we drop, S is OR'ed with the other bits we dropped (0 or 1)
;   •	If G = 0, you’re less than halfway to the next representable mantissa, so you leave M unchanged.
;	•	If G = 1 and (R or S = 1) — i.e. you’re strictly more than halfway — you add 1 to M.
;	•	If G = 1, R = 0, S = 0 — i.e. you’re exactly halfway (the bit pattern is ...xyz1000…0) — you add 1 to M only if 
;                the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
DB_Round_X:
; G starts at byte 8
    LDA     7,X         ; Look at G
    BPL     @Done       ; if G=0 then leave Mantissa unchanged
; G = 1, look at R
    BITA    #%01000000  
    BNE     @MantInc    ; if R = 1 then add 1 to Mantissa
; R = 0, look at S
    ANDA    #%00111111
    BNE     @MantInc    ; if S = 1 then add 1 to Mantissa
; R & S = 0, so check LSbit of Mantissa
    LDA     6,X         ; Get LSB
    RORA                ; move low order bit to the carry
    BCC     @Done   ; If LSBit of Mantissa = 0 then skip adding 1 to the Mantissa
; Add one to the mantissa value
@MantInc:
    INC     6,X
    BNE     @Done
    INC     5,X
    BNE     @Done
    INC     4,X
    BNE     @Done
    INC     3,X
    BNE     @Done
    INC     2,X
    BNE     @Done
    INC     1,X
    BNE     @Done
    INC     ,X
    BNE     @Done
; Otherwise it was $FF
; We over flowed into bit 56 (57th bit)
    LDA     #$FF
    STA     ,X      ; Make it $FF again
    STA     1,X
    STA     2,X
    STA     3,X
    STA     4,X
    STA     5,X
    STA     6,X         ; Divide it by two
    INC     EXP+1       ; Increment the EXPONENT LSB
    BNE     @Done       ; If we didn't just make it zero then return
    INC     EXP         ; otherwise increment the MSB
@Done:
    RTS

; Divide 128 bit dividend @ DIVIDEND by 64 bit Divisor @ DIVISOR
; Result @ QUOTIENT & REMAINDER
  IF Div128Slow
DIV128_64:
        ; 1) Copy dividend to DividendTemp storage
        LDX     #DIVIDEND
	    LDY	    #TEMP
	    LDB	    #8
!	    LDU	    ,X++
	    STU	    ,Y++
	    DECB
	    BNE	    <
	    CLRA

        ; 2) Initialize quotient to zero
        LDX     #QUOTIENT
        STD     ,X
        STD     2,X
        STD     4,X
        STD     6,X
        STD     8,X
        STD     10,X
        STD     12,X
        STD     14,X

        ; 3) Initialize remainder to zero
        LDX     #REMAINDER
        STD     ,X
        STD     2,X
        STD     4,X
        STD     6,X   

        ; 4) Loop over 128 bits
        LDY     #128                 ; bit-count
Div128_Loop_64:
        ; 4a) Shift dividend = TEMP left by 1
	    LDX     #TEMP      ; 
        ASL     15,X      	; clear carry & shift left, low byte, to high byte
        ROL     14,X
        ROL     13,X
        ROL     12,X
        ROL     11,X
        ROL     10,X
        ROL     9,X
        ROL     8,X
        ROL     7,X
        ROL     6,X
        ROL     5,X
        ROL     4,X
        ROL     3,X
        ROL     2,X
        ROL     1,X
        ROL     ,X

        ; 4b) Shift remainder left by 1, bring in carry
        LDX     #REMAINDER      ; 
        ROL     7,X      	; Shift remainder left by 1, bring in carry
        ROL     6,X
        ROL     5,X
        ROL     4,X
        ROL     3,X
        ROL     2,X
        ROL     1,X
        ROL     ,X

        ; 4c) Shift quotient left by 1
        LDX     #QUOTIENT 	; 
        ASL     15,X      	; clear carry & shift left, low byte, to high byte
        ROL     14,X
        ROL     13,X
        ROL     12,X
        ROL     11,X
        ROL     10,X
        ROL     9,X
        ROL     8,X
        ROL     7,X
        ROL     6,X
        ROL     5,X
        ROL     4,X
        ROL     3,X
        ROL     2,X
        ROL     1,X
        ROL     ,X

        ; 4d) Compare remainder vs divisor
	    LDX	    #REMAINDER
	    LDU	    #DIVISOR
	    LDD	    ,X
	    CMPD	,U
        BHI     Do_Subtract_128        ; remainder.H > divisor.H
        BNE     No_Subtract_128        ; remainder.H < divisor.H
	    LDD	    2,X
	    CMPD	2,U
        BHI     Do_Subtract_128        ; remainder.H > divisor.H
        BNE     No_Subtract_128        ; remainder.H < divisor.H
	    LDD	    4,X
	    CMPD	4,U
        BHI     Do_Subtract_128        ; remainder.H > divisor.H
        BNE     No_Subtract_128        ; remainder.H < divisor.H
	    LDD	    6,X
	    CMPD	6,U
        BLO     No_Subtract_128        ; remainder.L < divisor.L

Do_Subtract_128:
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
    	INC	    QUOTIENT+15

No_Subtract_128:
        ; 4e) Loop
        LEAY    -1,Y
        LBNE    Div128_Loop_64
        RTS

  ELSE

; Knuth's Algorithm D for 128-bit / 64-bit Unsigned Division on Motorola 6809
; Adapted for 8-bit CPU with hardware MUL (A * B -> D)
;
; Overview:
; This implements Donald Knuth's Algorithm D from "The Art of Computer Programming, Vol. 2".
; It performs unsigned division of a 128-bit (16-byte) dividend by a 64-bit (8-byte) divisor.
; - Base b = 256 (treat bytes as digits, big-endian: high byte first).
; - Normalizes divisor so leading byte >= 128 (for accurate quotient estimation).
; - Estimates one quotient byte per iteration (up to 9 iterations).
; - Uses schoolbook multiplication and subtraction, leveraging MUL for efficiency.
; - Handles adjustment for overestimate (rare, 0-2 times).
; - Outputs: Quotient (up to 9 bytes), Remainder (8 bytes).
;
; Assumptions:
; - Buffers are big-endian (MSB first).
; - Divisor != 0 (caller must check; else infinite loop or error).
; - Dividend >= 0, Divisor > 0 (unsigned).
; - If Dividend < Divisor, Quotient = 0, Remainder = Dividend.
; - Temporary buffers: TEMP (17 bytes for partial dividend + extra).
; - Registers: Uses A, B, D, X, Y, U extensively.
; - Stack usage: Minimal, for subroutines.
;
; Performance Estimate:
; - ~9 main iterations.
; - Each: ~8 MULs for multiply, byte-wise add/sub.
; - Total ~1,000-2,000 cycles on 6809 (faster than bit-serial's 10k+).
;
; Edge Cases Handled:
; - Leading zeros in divisor/dividend.
; - Quotient exactly 0 or max.
; - Remainder after unnormalization.
;
; Usage:
; - Define buffers in memory (e.g., via FCB or RMB).
; - Call DIV128_64.
; - Results in QUOTIENT and REMAINDER.

; Buffer Definitions (allocate in RAM)
;DIVIDEND    EQU $1000   ; 16 bytes: Input dividend (modified during process)
;DIVISOR     EQU $1010   ; 8 bytes: Input divisor (modified for normalization)
;QUOTIENT    EQU $1018   ; 9 bytes: Output quotient (cleared initially)
;REMAINDER   EQU $1021   ; 8 bytes: Output remainder
;TEMP        EQU $1029   ; 17 bytes: Temp partial dividend (extra for overflow)
;MULT_RES                ; 9 bytes temp storage

    opt     c,ct,cc       * show cycle count, add the counts, clear the current count

; Main Routine
DIV128_64:
    ; Step 0: Initialization
    ; Clear quotient (9 bytes to 0)
    LDX     #QUOTIENT       ; X points to quotient start
    LDD     #$0000          ; D=0 for clearing
    STD     ,X              ; Clear bytes 0-1
    STD     2,X             ; 2-3
    STD     4,X             ; 4-5
    STD     6,X             ; 6-7
    STA     8,X             ; Byte 8 (last)

    ; Handle trivial cases (optional optimization)
;    JSR CMP_DIVIDEND_DIVISOR ; Compare dividend >= divisor?
;    BCC DONE_ZERO       ; If dividend < divisor, quotient=0, remainder=dividend
;    BEQ DONE_ONE        ; If equal, quotient=1, remainder=0 (but full algo handles)

    ; Step 1: Normalization
    ; Compute shift = number of leading zero bits in divisor's high byte
    CLRB                ; B = shift count
    LDA     DIVISOR     ; Load high byte of divisor
@NORM_LOOP:
    TSTA                ; Is MSB set (>=128)?
    BMI     @NORM_DONE  ; Already normalized
@NORM_SHIFT:
    ASLA                ; Shift A left (test bit)
    INCB                ; Increment shift
    CMPB    #8          ; Max 7 shifts (since 8 would mean divisor=0, but assume !=0)
    BNE     @NORM_LOOP
    ; Error: Divisor=0, but assume checked
;
@NORM_DONE:
    STB NORM_SHIFT          ; Save shift count for unnormalization
    JSR SHIFT_LEFT_DIVISOR  ; Normalize divisor: shift left by B bits
    JSR SHIFT_LEFT_DIVIDEND ; Normalize dividend: same shift

    ; Prepare TEMP as extended dividend (17 bytes: 0 + dividend)
    CLR TEMP            ; High byte 0 (for overflow)
    LDX #DIVIDEND
    LDU #TEMP+1
    LDB #16             ; Copy 16 bytes
COPY_TEMP:
    LDA ,X+
    STA ,U+
    DECB
    BNE COPY_TEMP

    ; Step 2: Main Division Loop
    ; Number of quotient digits: m - n + 1 = 16 - 8 + 1 = 9
    LDY     #QUOTIENT   ; Y points to quotient (fill from high to low)
    LDB     #9          ; B = iteration count
    PSHS    B           ; Save iteration count on the stack
MAIN_LOOP:

    ; Estimate quotient digit q (0-255)
    ; q_hat = (TEMP[0]*256^2 + TEMP[1]*256 + TEMP[2]) / DIVISOR[0]
    ; Use small division routine for estimate
    JSR ESTIMATE_Q      ; Returns q in A
    STA Q_TEMP          ; Save initial q_hat

    ; Multiply divisor * q into MULT_RES (9 bytes temp, can reuse space)
    JSR MULT_DIVISOR_Q  ; MULT_RES = DIVISOR * A (q)

    ; Subtract MULT_RES from TEMP (17 bytes, but align to 9 bytes of MULT_RES)
    JSR SUB_TEMP_MULT   ; TEMP -= MULT_RES (aligned to TEMP[0..8]), carry bit set if there was a borrow

    ; Check for borrow (overestimate)
    BCC NO_ADJUST       ; No adjustment needed

    LDB     #2          ; Max adjustments (safety; Knuth max 2)
    PSHS    B           ; Save on the stack
ADJUST_LOOP:
    JSR ADD_TEMP_DIVISOR ; Add divisor back to TEMP[1..8], may carry to TEMP[0]
    DEC Q_TEMP          ; Decrement q_hat in RAM
    LDA TEMP            ; Recheck high byte
    BEQ ADJUST_DONE     ; Now 0? Done
    DEC ,S              ; Decrement safety counter
    BNE ADJUST_LOOP     ; Continue if not max
    ; If here, error (rare, but possible overflow); assume handled

ADJUST_DONE:
    LEAS    1,S         ; Fix the stack

NO_ADJUST:
    LDA     Q_TEMP      ; Load final q_hat
    STA     ,Y+         ; Store to quotient
     
    opt     cc
; Shift TEMP left by 1 byte (slide window: TEMP[0..15] = TEMP[1..16], TEMP[16]=0)
    PSHS    Y           ; Sve Y on the stack
    LDU     #TEMP+1
    PULU    D,X,Y
    LDU     #TEMP+6
    PSHU    D,X,Y
    LDU     #TEMP+7
    PULU    D,X,Y
    LDU     #TEMP+12
    PSHU    D,X,Y
    PULS    Y           ; restore Y
    LDD     TEMP+13
    STD     TEMP+12
    LDD     TEMP+15
    STD     TEMP+14
    CLR     TEMP+16

    DEC     ,S          ; decrement the iteration counter
    BNE     MAIN_LOOP
    LEAS    1,S         ; Fix the stack (iteration counter)

    ; Step 3: Unnormalization
    ; Remainder is in TEMP[1..8], shift right by NORM_SHIFT bits
    LDU     #TEMP
    PULU    D,X,Y
    LDU     ,U
    STU     REMAINDER+6
    LDU     #REMAINDER+6
    PSHU    D,X,Y

    LDB NORM_SHIFT      ; Load shift
    BEQ DONE            ; No shift if 0
;    JSR SHIFT_RIGHT_REM ; Shift remainder right by A bits
    LDX #REMAINDER
;    ADDB    #16
    JSR SHIFT_RIGHT_64_B ; Shift the 64-bit number at X Right by B bits, X unchanged, clobbers Y & U

DONE:
    RTS                 ; Return

DONE_ZERO:
    ; Quotient=0, remainder=dividend
    LDX #DIVIDEND
    LDY #REMAINDER
    LDB #8              ; Copy high 8 bytes? Wait, for 128/64, remainder < divisor (8 bytes)
    ; Actually, if dividend < divisor, copy all but since remainder=dividend, pad low bytes 0? No, remainder is dividend truncated to 8 bytes? Wait, adjust
    ; For simplicity, assume caller handles or copy 8 high bytes, but since dividend 16 bytes, compare properly
    ; Skip for now, full algo handles
    RTS

DONE_ONE:
    ; Similar
    RTS

; Helper: Compare Dividend >= Divisor (sets flags)
CMP_DIVIDEND_DIVISOR:
    LDX #DIVIDEND
    LDU #DIVISOR
    LDB #8              ; Compare high 8 bytes of dividend to divisor
CMP_LOOP:
    LDA ,X+
    CMPA ,U+
    BNE CMP_EXIT
    DECB
    BNE CMP_LOOP
CMP_EXIT:
    RTS                 ; Flags set: C for <, EQ for =

; Helper: Shift Left Multi-Byte (general, call with params)
; X = pointer, B = byte count, A = bit shift (0-7)
SHIFT_LEFT_XAB:
    PSHS    A,B,X          ; Save
    TSTA
    BEQ     SL_DONE
SL_BIT_LOOP:
    CLRB                ; Clear carry, and set index pointer to zero
    LDB     1,S         ; Get the byte count
SL_BYTE:
    ROL     B,X         ; Rotate left thru carry
    DECB
    BPL     SL_BYTE
    DECA
    BNE     SL_BIT_LOOP
SL_DONE:
    PULS    A,B,X,PC

; Wrapper for Divisor Shift Left
SHIFT_LEFT_DIVISOR:
    LDX #DIVISOR
    LDB #8-1              ; Bytes
    LDA NORM_SHIFT      ; Bits
    JSR SHIFT_LEFT_XAB
    RTS

; Wrapper for Dividend
SHIFT_LEFT_DIVIDEND:
    LDX #DIVIDEND
    LDB #16-1
    LDA NORM_SHIFT
    JSR SHIFT_LEFT_XAB
    RTS

; Helper: Shift Right for Remainder (similar, but ROR from high to low)
;SHIFT_RIGHT_REM:
;    PSHS    A,B,X
;    TSTA
;    BEQ     SR_DONE
;    LDX     #REMAINDER
;    LDB     #8
;SR_BIT_LOOP:
;    CLRB                ; Clear carry, High byte first
;SR_BYTE:
;    ROR     B,X         ; Rotate right thru carry
;    INCB
;    CMPB    #8
;    BNE     SR_BYTE
;    DECA
;    BNE     SR_BIT_LOOP
;SR_DONE:
;    PULS    A,B,X,PC

;Dividend16  RMB 2
;Divisor8    RMB 1
; Helper: Estimate Q (returns A = q_hat, 0-255)
ESTIMATE_Q:
    ; Load initial dividend part: D = TEMP[0]:TEMP[1] (u0:u1)
;    LDA TEMP            ; High: u0
;    LDB TEMP+1          ; Low: u1
    ; Divisor v1 = DIVISOR[0]
;    LDY #DIVISOR        ; Y points to divisor
;    LDA ,Y              ; v1

    ; Compute initial q_hat = floor( (u0*256 + u1) / v1 )

; Do division 
;Div16_8:
;    LDA TEMP            ; High: u0
;    LDB TEMP+1          ; Low: u1

        ; 1) Copy dividend to Temp_Dividend storage
        LDD     TEMP
        STD     Temp_Dividend

        ; 2) Initialize quotient to zero
        LDD     #$0000
        STD     Quotient

        ; 3) Initialize remainder to zero
        STD     Remainder

        LDB     DIVISOR             ; v1 = MSB of the DIVISOR
        STD     Temp_Divisor        ; Save the Divisor, A already = zero

        ; 4) Loop over 16 bits
        LDA     #16                 ; bit-count
        PSHS    A                   ; Save it on the stack
@Div64_Loop_64:
        ; 4a) Shift dividend = DIVTMP left by 1
        ROL     Temp_Dividend+1      ; clear carry & shift left, low byte, to high byte
        ROL     Temp_Dividend
;
        ; 4b) Shift remainder left by 1, bring in carry
        ROL     Remainder+1      	    ; Shift remainder left by 1, bring in carry
        ROL     Remainder
;
        ; 4c) Shift quotient left by 1
        ASL     Quotient+1      	    ; clear carry & shift left, low byte, to high byte
        ROL     Quotient
;
        ; 4d) Compare remainder vs divisor
	    LDD	    Remainder
	    CMPD	Temp_Divisor
        BLO     @No_Subtract_64  ; remainder.L < divisor.L
;
        ; Subtract divisor from remainder
	    LDD	    Remainder
	    SUBD	Temp_Divisor
	    STD	    Remainder
    	INC	    Quotient+1
@No_Subtract_64:
        ; 4e) Loop
        DEC     ,S
        LBNE    @Div64_Loop_64
        LEAS    1,S             ; Fix the stack
        LDA     Remainder+1
        LDB     Quotient+1      ; Get the LSB of the result in B

; Cap at 255
        TST     Quotient        ; If MSB is > 0 then make B = 255, else keep B as is
        BEQ     NO_CAP
        LDB     #$FF
NO_CAP:

; A = remainder
; B = q_hat
    PSHS    D           ; Save the remainder and q_hat on the stack

; Adjustment loop (max 2 iterations)
    LDA     #2          ; Max adjustments
    PSHS    A           ; Save on the stack
ADJUST_Q:
; Compute left: q_hat * v2 (v2 = DIVISOR[1])
; B already has the value of q_hat
    LDA     DIVISOR+1   ; v2 = DIVISOR[1]
    MUL                 ; D = (left: q*v2)
    TFR     D,X         ; Save it in X
;
; Compute right: (r * 256 + u2) where r = remainder from div
    LDA     1,S         ; A = remainder
    LDB     TEMP+2      ; u2
    PSHS    D           ; Save right on the stack
    ; Compare X (left: q*v2) > D (right: r*256 + u2)?
    CMPX    ,S++        ; Compare the left with the right, fix the stack
    BLS     NO_DECR     ; If left low <= right low, good
;
DECR_Q:
    SUBA    TEMP        ; remainder = remainder - v1
    STA     1,S         ; save as new remainder
    DEC     2,S         ; q_hat--
    LDB     2,S
    DEC     ,S          ; Decrement counter
    BNE     ADJUST_Q    ; Retry if not max
NO_DECR:
    LDA     2,S         ; A = final q_hat
    PULS    B,X,PC      ; Fix the stack and return (kills B & X)

; Helper: Multiply Divisor * Q (8 bytes * 1 byte -> 9 bytes)
; Fast 6809 Assembly Routine: Multiply 8-Byte by 1-Byte Using MUL
MULT_DIVISOR_Q:
; Input: A = q
; Output: MULT_RES (9 bytes)
    STA     @MULT_LOOP+1    ; Save the multiplier (self modified)
    LDX     #DIVISOR+7+1    ; X points to LSB of DIVISOR, +1 as the decrement happens first for ,-X
    LDU     #MULT_RES+8+1   ; U points to LSB of MULT_RES, +1 as the decrement happens first for ,-U
    CLR     @Carry+1    ; Initial carry = 0 (self modify)
    LDA     #8          ; Loop counter: 8 bytes
    STA     ,-S         ; Put it on the stack
@MULT_LOOP:
    LDA     #$FF        ; load the multiplier (self modified)
    LDB     ,-X         ; Decrement X, Load next multiplicand byte (LSB to MSB)
    MUL                 ; D = multiplier * byte (A=high_prod, B=low_prod)
@Carry
    ADDB    #$00        ; add prior carry to low byte (self modified)
    ADCA    #$00        ; propagate carry into high byte
    STA     @Carry+1    ; new carry for next iteration (self modify)
    STB     ,-U         ; Decrement U, store product low byte at current result pos
;
    DEC     ,S          ; Decrement counter
    BNE     @MULT_LOOP  ; Loop until all 8 bytes processed
;
; A = final carry
    STA     MULT_RES    ; Store to MSB of MULT_RES (to MULT_RES[0])
    PULS    B,PC        ; Fix stack, kill B & Return

; Note: This is sketchy; full schoolbook for 8x1:
; Start from low divisor byte, multiply by q, add carry, store low, carry high

; Helper: Subtract TEMP - MULT_RES (9 bytes from TEMP[0..8])
; carry flag set after last subtract
SUB_TEMP_MULT:
    LDX     #TEMP           ; Low byte, +1 as the decrement happens first for ,-X
    LDU     #MULT_RES       ; Low byte, +1 as the decrement happens first for ,-U
    LDB     #8              ; Counter
    CLRA                    ; Carry/borrow = 0
@SUB_LOOP:
    LDA     B,X             ; A = LSB of TEMP
    SBCA    B,U             ; A = LSB of TEMP - (Carry + LSB of MULT_RES)
    STA     B,X             ; Save LSB of TEMP
    DECB                    ; Decrement the counter
    BPL     @SUB_LOOP       ; Keep looping if not -1
    RTS

; Helper: Add TEMP + DIVISOR (for adjustment, TEMP[1..8] + DIVISOR[0..7])
ADD_TEMP_DIVISOR:
    LDX     #TEMP+8+1
    LDU     #DIVISOR+7+1
    LDB     #8              ; Counter
    CLRA                    ; Carry/borrow = 0
@ADD_LOOP:
    LDA     ,-X
    ADCA    ,-U
    STA     ,X
    DECB
    BNE     @ADD_LOOP
    ; Add to TEMP[0] if carry
    BCC     NO_CAR_ADD
    INC     TEMP
NO_CAR_ADD:
    RTS

; End of routine

  ENDIF


; ------------------------------------------------------------
; DB_TO_DECSTR
; Input : FFP ,S..2,S
; Output: replaces it with: ,S=len, 1,S=' ' or '-', 2,S..digits
; ------------------------------------------------------------
DB_OutBuff EQU   _StrVar_PF00  ; String buffer for output (max 32 chars)
; Print Double value @,S
DB_TO_DECSTR:
    PULS    D               ; Get the return address off the stack
    STD     @ReturnFinal+1       ; Self mod the return address below
      CLR   DB_OutBuff       ; Start with empty buffer
      BSR   @FillOutBuff      ; Copy decimal # to ascii text @ DB_OutBuff
; Put buffer on the stack
      LDX   #DB_OutBuff      ; Pint at the string
      LDB   ,X+                ; Get the size of the string
      ABX                     ; Point at the end of the string
!     LDA   ,-X               ; X=X-1, get A @ X
      PSHS  A                 ; Put it on the stack
      DECB                    ; dec the counter
      BPL   <                 ; loop
@ReturnFinal:
      JMP   >$FFFF           ; Return
@SaveAToBuffer:
      PSHS  B,X
      INC   DB_OutBuff
      LDX   #DB_OutBuff      ; Pint at the string
      LDB   ,X                ; Get the size of the string
      ABX                     ; Point at the end of the string
      STA   ,X
      PULS  B,X,PC
@FillOutBuff:
      PULS  D
      STD   @Return+1
; Check for special Exponent
    LDD     1,S
    CMPD    #$8000
    BNE     >
; We get here when it's either Infinity or Not A Number
    LDA     #' '            ; Space before the dot
    BSR     @SaveAToBuffer
    LDA     #'.'
    BSR     @SaveAToBuffer
    LEAS    10,S            ; Fix the stack
    JMP     @Return         ; Return
; Check if number is zero   ; Check for zero
!   CMPD    #$0000          ; Is the exponent zero?
    BNE     @NotZero        ; If Exponent is anything else than we are not zero
    LDD     3,S             ; Check Mantissa bits first for zero
    BNE     @NotZero
    LDD     5,S
    BNE     @NotZero
    LDY     7,S
    BNE     @NotZero
    LDA     9,S
    BNE     @NotZero
    JSR     DB_PRINT_ZERO   ; If zero, print "0"
    LEAS    10,S            ; Fix the stack
    JMP     @Return         ; Return
;
; Not zero print the number
; Get sign and make number positive
; A = 0 (positive) or $80 (negative)
@NotZero:
    LDA     ,S              ; Load first byte
    STA     SIGN_TEMP       ; Save the original sign value
    CLR     ,S              ; Clear sign bit, make it positive
;
; Scale the Number:
; Initialize a decimal exponent DB_Exponent to 0.
; Loop to divide by 10 while the number is ≥ 10, incrementing DB_Exponent
; Loop to multiply by 10 while the number is < 1, decrementing DB_Exponent
; This scales the number to the range [1, 10).
;
; Initialize decimal exponent
    CLR   DB_Exponent       ; Exponent = 0
;
; Scale number: while x >= 10.0, divide by 10, increment Exponent
@SCALE_GE_10:
; Pushing 10 bytes onto the stack
    LDU     #DB_TEN+2       ; Point at Double value of 10 + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_TEN          ; Get the first 2 bytes of data
    PSHS    D               ; Double Value of 10 is now @ ,S
;
    JSR     Double_CMP_Stack     ; Compare Double Value1 @ 10,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
    LEAS    10,S            ; Move the stack forward,
    BLO     @SCALE_LT_1      ; If x < 10, proceed to next check
;
; --- Divide Double by 10, fastest way is to multiply by 0.1 --- (,S = ,S * 0.1)
    LDU     #Double_Inv10+2 ; U = &Double_Inv10 + 2
    PULU    D,X,Y           ; gets 6 bytes from Double_Inv10, U advanced
    LDU     ,U              ; get last 2 bytes into U (mantissa tail low)
    PSHS    D,X,Y,U         ; push mantissa tail (8 bytes)
    LDD     Double_Inv10    ; sign byte + high exponent byte
    PSHS    D               ; push them
;
    JSR     DB_MUL            ; x * 0.1  -> result at ,S
    INC     DB_Exponent     ; Exponent = Exponent + 1
    BRA     @SCALE_GE_10     ; Repeat
;
; While x < 1.0, multiply by 10, decrement Exponent
@SCALE_LT_1:
; Point to Double value of 1.0
!   LDU     #DB_ONE+2       ; Point U at the start of source data + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_ONE          ; Get the first 2 bytes of data
    PSHS    D               ; Double Value of 1 is now @ ,S  
;
    JSR     Double_CMP_Stack     ; Compare Double Value1 @ 10,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
    LEAS    10,S        ; Move the stack forward, so it can be filled with the Double value of Ten
    BHS     >           ; If x >= 1, proceed to digit extraction
;
    LDU     #DB_TEN+2       ; Point U at the start of source data + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_TEN          ; Get the first 2 bytes of data
    PSHS    D               ; Double Value of 10 is now @ ,S  
;
    JSR     DB_MUL          ; Multiply 10,S * ,S Then S=S+10 result @ ,S
    DEC     DB_Exponent     ; Exponent = Exponent - 1
    BRA     <               ; Keep looping
;
; Multiply x by 10^15 to get integer part
!   LDU     #DB_TENPOW15+2  ; Point U at the start of source data + 2
    PULU    D,X,Y           ; Get the first 6 bytes of data, move U past the data
    LDU     ,U              ; Load U with the last two bytes of data
    PSHS    D,X,Y,U         ; Push them on the stack
    LDD     DB_TENPOW15     ; Get the first 2 bytes of data
    PSHS    D               ; Double Value of 10^15 is now @ ,S
;
    JSR     DB_MUL          ; Multiply 10,S * ,S Then S=S+10 result @ ,S
    JSR     DB_TO_U64       ; Convert 10 byte Double @ ,S to Unsigned 64-bit Integer @ ,S
    LEAU    ,S
    JSR     INT64_TO_STR_DB ; Convert 64-bit integer at ,U to decimal string in STRBUF, Return length in B
;
; Check notation based on DB_Exponent
    LDA     #' '
    LDB     SIGN_TEMP
    BPL     >
    LDA     #'-'    ; Print minus sign if negative
!   JSR     @SaveAToBuffer
    LDA     DB_Exponent
    CMPA    #-4
    BGE     >
    BSR     @DB_SCIENTIFIC
    BRA     @Done           ; Fix the stack & Return
!   CMPA    #10
    BLE     >
    BSR     @DB_SCIENTIFIC
    BRA     @Done           ; Fix the stack & Return
!   BSR     @DB_DECIMAL
@Done:
    LEAS    8,S             ; Fix the stack
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
;
@DB_SCIENTIFIC:
    LDA     STRBUF         ; First digit
    JSR     @SaveAToBuffer
    LDA     #'.'           ; Decimal point
    JSR     @SaveAToBuffer
    LDU     #STRBUF+1      ; Point to remaining digits
    LDB     #14            ; Print up to 14 more digits
!   LDA     ,U+
    BEQ     @PAD_ZERO       ; If string ends early, pad with zeros
    JSR     @SaveAToBuffer
    DECB
    BNE     <
    BRA     @PRINT_EXP
@PAD_ZERO:
    LDA     #'0'
    JSR     @SaveAToBuffer
    DECB
    BNE     @PAD_ZERO
;
@PRINT_EXP:
    LDA     #'E'
    JSR     @SaveAToBuffer
    LDB     DB_Exponent
    BPL     @EXP_POS
    LDA     #'-'
    JSR     @SaveAToBuffer
    LDB     DB_Exponent
    NEGB                 ; Absolute value of E
    BRA     @EXP_NUM
@EXP_POS:
    LDA     #'+'
    JSR     @SaveAToBuffer
    LDB     DB_Exponent
@EXP_NUM:
    TFR     B,A
    JMP     @SaveAToBuffer
;
@DB_DECIMAL:
    LDA     DB_Exponent
    BGE     @DEC_POS_EXP
; DB_Exponent < 0
    LDA     #'0'
    JSR     @SaveAToBuffer
    LDA     #'.'
    JSR     @SaveAToBuffer
    LDB     DB_Exponent
    CMPB    #-1
    BEQ     @NO_ZEROS      ; No extra zeros for E = -1
    NEGB                ; A = -DB_Exponent
    SUBB    #1            ; Number of leading zeros
    BLE     @NO_ZEROS
    LDA     #'0'
!   JSR     @SaveAToBuffer
    DECB
    BNE     <
@NO_ZEROS:
    LDU     #STRBUF-1
    LDB     #16     
!   DECB                ; Print up to 15 digits (16 -1)
    BEQ     >
    LDA     B,U         ; Check and skip any trailing zeros
    CMPA    #'0'
    BEQ     <
    INCB
@DIGIT_LOOP_NEG:
    LDA     ,U+
    JSR     @SaveAToBuffer
    DECB
    BNE     @DIGIT_LOOP_NEG
!   RTS
;
; DB_Exponent > 0
@DEC_POS_EXP:
    LDB     DB_Exponent
    INCB                    ; B = DB_Exponent + 1 (digits before decimal)
    LDU     #STRBUF
!   LDA     ,U+
    JSR     @SaveAToBuffer
    DECB
    BNE     <
    LDB     #14
    SUBB    DB_Exponent     ; B = 15 - (DB_Exponent + 1)
    BEQ     @DEC_DONE        ; No fractional part if B = 0
; Check if the rest is zeros if so stop printing any trailing zeros
; ----- Trim trailing zeros from the right (safe) -----
; U = U + (B - 1)  -> points to last fractional digit
    DECB                    ; B = B - 1 (last index)
    BMI     @DEC_DONE        ; (shouldn’t happen; guards BEQ above)
@TrimTail:
    LDA     B,U             ; load digit at U + B
    CMPA    #$30            ; '0' ?
    BNE     @HaveFracCount  ; stop trimming when non-zero digit
    DECB                    ; drop one trailing zero
    BPL     @TrimTail
    ; All fractional digits were zeros → don't print decimal point
    BRA     @DEC_DONE
@HaveFracCount:
    INCB                    ; restore count of fractional digits
    BEQ     @DEC_DONE        ; none left? (paranoia)
    LDA     #'.'
    JSR     @SaveAToBuffer
; print exactly B digits from U
!   LDA     ,U+
    JSR     @SaveAToBuffer
    DECB
    BNE     <
@DEC_DONE:
    RTS
@DB_PRINT_ZERO:
    LDA     #' '            ; Space before the zero
    JSR     @SaveAToBuffer
    LDA     #'0'
    JMP     @SaveAToBuffer  ; Write zero and return

    INCLUDE ./Math_IEEE_754_Double_Extra.asm
