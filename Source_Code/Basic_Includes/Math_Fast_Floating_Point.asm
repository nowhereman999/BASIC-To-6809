; Routines for doing FFP math - 3 Byte Floating Point
;
; Math functions included in this library:
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
; Print_FFP       ; Print FFP value @,S
; FFP_TO_DECSTR   ; Replaces FFP # on the stack with a decimal ASCII string version where: ,S=len, 1,S=' ' or '-', 2,S..digits
; FFP_CMP_Stack   ; Compare FFP Value1 @ 3,S with Value2 @ ,S sets the 6809 flags Z, N, and C
;
; RandomFFP_Zero  ; Generate a random number @,S in the range of > 0 and < 1
; RandomFFP       ; Gets a random number where random # is 1 to X where X is the FFP value on the stack, then S=S+3 result @,S
;
; Shifting routines:
; FFP_Shift_Right64_AtU_B  ; Right-shift 64-bit value at U by B bits (B >= 0)
; FFP_Shift_Left64_AtU_B   ; Left-shift 64-bit value at U by B bits (B >= 0)

    opt     c
    opt     ct
    opt     cc       * show cycle count, add the counts, clear the current count

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

;----------------------------------------------------------------------
;  MACRO: PUSH_FFP <label>
;  Push 3-byte FFP at <label> onto the 6809 stack
;----------------------------------------------------------------------
PUSH_FFP  MACRO  \1
      LDU   #\1         ; U -> addr+3
      PULU  B,X         ; D=addr+2..3,
      PSHS  B,X         ; push 3 bytes
      ENDM

;----------------------------------------------------------------------
;  MACRO: PULL_FFP <label>
;  PULL 3-byte FFP from the 6809 stack
;----------------------------------------------------------------------
PULL_FFP   MACRO  \1
      PULS  B,X         ; pull 3 bytes off the stack
      LDU   #\1+3       ; U points to bytes +3
      PSHU  B,X         ; store B,X
      ENDM

; Copying 3 bytes off the stack into a Temp location
CopyStackToFFP MACRO \1
      LEAU  ,S          ; Point U at the start of source data
      PULU  B,X         ; Get the 3 bytes of data
      LDU   #\1+3       ; U points at the end of the destination location 
      PSHU  B,X         ; Save the 6 bytes of data at the start of destination
      ENDM

; Put value at the end of the stack on the stack again
CopyStackOnStack MACRO
      LEAU  ,S
      PULU  B,X
      PSHS  B,X               ; Copy x value on the stack
      ENDM

; Equates to memroy in Math_Variables.asm

FFP_Big8_03     EQU   Big8_03
FFP_Big8_04     EQU   Big8_04
FFP_Big8_05     EQU   Big8_05
FFP_Medium4_01  EQU   Medium4_01
FFP_Medium4_02  EQU   Medium4_02
FFP_Medium4_03  EQU   Big8_06
FFP_Medium4_04  EQU   Big8_06+4
FFP_Word2_01    EQU   Big8_07
FFP_Word2_02    EQU   Big8_07+2
FFP_Word2_03    EQU   Big8_07+4
FFP_Word2_04    EQU   Big8_07+6
FFP_Short1_01   EQU   Short1_01
FFP_Short1_02   EQU   Short1_02
FFP_Short1_03   EQU   Short1_03
FFP_Short1_04   EQU   Short1_04
FFP_Short1_05   EQU   Short1_05
FFP_Short1_06   EQU   Big8_08
FFP_Short1_07   EQU   Big8_08+1
FFP_Short1_08   EQU   Big8_08+2
FFP_Short1_09   EQU   Big8_08+3
FFP_Short1_10   EQU   Big8_08+4
FFP_Short1_11   EQU   Big8_08+5
FFP_Short1_12   EQU   Big8_08+6
FFP_Short1_13   EQU   Big8_08+7
;
; Locally used
FFP_EXPonent1    EQU   FFP_Short1_01     ; signed exp1
FFP_EXPonent2    EQU   FFP_Short1_02     ; signed exp2
FFP_EXPonent     EQU   FFP_Short1_03     ; exp diff (unsigned)
;
FFP_SIGN1   EQU   FFP_Short1_04     ; sign1 (&H00 or &H80)
FFP_SIGN2   EQU   FFP_Short1_05     ; sign2
FFP_SIGN    EQU   FFP_Short1_06     ; result sign
FFP_Temp1   EQU   FFP_Short1_07     ; 1 byte temp storage
FFP_Temp2   EQU   FFP_Short1_08     ; 1 byte temp storage
;
FFP_MANT1   EQU   FFP_Medium4_01    ; extended mant1: 32 bits for shift/round (high3 low, but 16+3+sticky)
FFP_MANT2   EQU   FFP_Medium4_02    ; extended mant2
FFP_MANT    EQU   FFP_Medium4_03    ; Final resulting Mantissa storage

; RandomFFP_Zero: Generate a random number in the range of > 0 and < 1
; output: Random FFP value >0 <1 at ,S (3 bytes)
; clobbers: B,Y
RandomFFP_Zero:
      PULS    U               ; return address
      STU   @Return+1
      ; ----- Mantissa LSB -----
      JSR     RandomFast8Bit  ; B = rand
      TFR     B,A
; ----- Mantissa MSB (normalized) -----
      JSR     RandomFast8Bit  ; B = rand
      CMPD  #$0000
      BNE   >
      INCB                          ; Make sure Value can't be zero
!     ORA   #$80                    ; force mantissa MSB bit7 = 1 (1.xxx)
      PSHS  D                       ; push mantissa MSB & LSB
        ; ----- Pick exponent with weighted probabilities -----
      JSR     RandomFast8Bit  ; B = rand 0..255
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
@E_M7:  LDA     #$79          ; -7
        BRA     @PUSH_E 
;
@E_M2:  LDA     #$7E          ; -2
        BRA     @PUSH_E
@E_M3:  LDA     #$7D          ; -3
        BRA     @PUSH_E
@E_M4:  LDA     #$7C          ; -4
        BRA     @PUSH_E
@E_M5:  LDA     #$7B          ; -5
        BRA     @PUSH_E
@E_M6:  LDA     #$7A          ; -6  
        BRA     @PUSH_E
@E_M1:  LDA     #$7F          ; -1 in 7-bit signed exp field (sign=0)
@PUSH_E:
        PSHS    A             ; push sign/exp byte last so final layout is:
                              ; ,S=exp  1,S=mantMSB  2,S=mantLSB
@Return:
      JMP   >$FFFF            ; Return, self modified jump address

; RandomFFP: Gets a random number where random # is 1 to X where X is the FFP value on the stack
; output: randon FFP number at ,S (3 bytes)
; clobbers: all
RandomFFP:
      PULS  D                 ; Get the return address off the stack
      STD   @Return+1
      BSR   RandomFFP_Zero    ; Get a FFP Random number on the stack (>0 and <1)
      JSR   FFP_MUL           ; Multiply 3,S * ,S Then S=S+3 result @ ,S
      CLRB
      LDX   #$8000            ; +1.0
      PSHS  B,X               ; Push FFP value of 1.0 on the stack
      JSR   FFP_ADD   	      ; Add 3,S + ,S Then S=S+3 result @ ,S
@Return:
      JMP   >$FFFF            ; Return

; FFP_SUB - Subtract 3 byte float @ 3,S from ,S does S=S+3 with result @ ,S
FFP_SUB:
      PULS  D               ; Get return address off the stack
      STD   @Return+1       ; Self mod return JMP adress below
; Check if they are the same, if so return zero
      LDD   ,S
      CMPD  3,S
      BNE   @NotSame
      LDA   2,S
      CMPA  5,S
      BNE   @NotSame
      LEAS  6,S               ; Fix the stack
      CLRA
      LDX   #$0000
      PSHS  A,X
      JMP   @Return
@NotSame:
      LDA   #$FF
      STA   @TestForSUB+1       ; Setting bits indicates we want to do subtraction
      BRA   FFP_ADD_SUB
;
; FFP_ADD - Adds 3 byte Float @ ,S with 3 byte Float @ 3,S does S=S+3 with result @ ,S
FFP_ADD:
      PULS  D               ; Get return address off the stack
      STD   @Return+1       ; Self mod return JMP adress below
      CLR   @TestForSUB+1       ; Clearing the bits indicates we want to do an add
; Flow through to Add two FFP numbers @ ,S & 3,S return with Result at ,S
;
FFP_ADD_SUB:
; Check for NaN or Infinity (If either value 1 or value 2 is NaN return with a value of NaN)
      LDA   ,S          ; Get the Sign and Exponent Value 2
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial2 ; Fix stack and return with Special result
      LDA   3,S         ; Get the Sign and Exponent Value 1
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial1  ; Fix stack and return with Special result
; Check for zeros, Start with Value 2
      LDD   1,S
      BNE   @NotZero
; Get here with a value of zero
      LEAS  3,S         ; Move the stack forward, keep Value 1 as the result
      JMP   @Return     ; RTS
; Check Value 1 for zero
@NotZero:
      LDD   4,S
      BNE   @GoodValues
; Get here with a value of zero
; If we are doing subtraction then value2's sign needs to be flipped
      LDA   @TestForSUB+1
      BEQ   >           ; Will be zero if adding, so skip forward, keep value 2 as the result
      LDA   ,S          ; Get the SIGN & Exponent
      EORA  #%10000000  ; flip sign bit
      STA   ,S          ;Save it
!     PULS  A,X         ; Get Value 2 off the stack
      LEAS  3,S         ; Move the stack
      PSHS  A,X         ; Save Value 2 as the result
      JMP   @Return     ; RTS
; We get here when we have two good values to Add
; Get Sign, Exponent & Mantissa for Value 2
@GoodValues:
      PULS  A,X         ; A = Sign & Exponent, X = Mantissa
      CLRB
      LSLA
      BCC   >
      LDB   #%10000000
!     STB   FFP_SIGN2   ; Save Sign
      ASRA              ; Shift Exponent back to normal keeping
      STA   FFP_EXPonent2 ; Save Exponent
      STX   FFP_MANT2   ; Save Mantissa
; Get Sign, Exponent & Mantissa for Value 1
      PULS  A,X         ; A = Sign & Exponent, X = Mantissa
      CLRB
      LSLA
      BCC   >
      LDB   #%10000000
!     STB   FFP_SIGN1   ; Save Sign
      ASRA              ; Shift Exponent back to normal keeping
      STA   FFP_EXPonent1 ; Save Exponent
      STX   FFP_MANT1   ; Save Mantissa
; Make the lower 16 bits of the Mantissa space empty
      LDX   #$0000
      STX   FFP_MANT1+2
      STX   FFP_MANT2+2
;
; Adjust for subtraction
@TestForSUB
      LDA   #$FF
      BEQ   @NO_SUB     ; If the bits are clear then add the values as they are
      LDA   FFP_SIGN2   ; Otherwise make sign2 a negative and add them
      EORA  #$80
      STA   FFP_SIGN2
; Align Exponents:
; Adjust the mantissa of the number with the smaller exponent by shifting it right until the exponents match.
@NO_SUB:
; Compare the sizes of the numbers
; Align mantissas
      LDB   FFP_EXPonent2
      SUBB  FFP_EXPonent1
      BGT   @EXP2_Big
      BLT   @EXP1_Big
; exp equal, compare mant to decide which larger
      LDD   FFP_MANT2
      CMPD  FFP_MANT1
      LBGE  @EXP2_NoShift
      BRA   @EXP1_NoShift
; Fall through to swap
; EXP1 > EXP2, shift MANT2 right
@EXP1_Big:
      NEGB
      CMPB  #16
      BLS   >
; Shifting right past the rounding info, just clear MANT2
      LDD   #$0000
      STD   FFP_MANT2
      STD   FFP_MANT2+2
      BRA   @FFP_MANT2_Ready
!     CMPB  #8
      BLO   @ShiftMANT2
; Shift MANT2 8 bits
      LDX   FFP_MANT2
      CLR   FFP_MANT2
      STX   FFP_MANT2+1
      SUBB  #8
      BEQ   @FFP_MANT2_Ready  ; MANT2 is ready to be used where it is
      CMPB  #8
      BLO   @ShiftMANT2
; Shift MANT2 another 8 bits
      LDX   FFP_MANT2+1
      CLR   FFP_MANT2+1
      STX   FFP_MANT2+2
      BRA   @FFP_MANT2_Ready  ; MANT2 is ready to be used where it is
@ShiftMANT2
      CLRA
      TFR   D,Y
      LDD   FFP_MANT2
!     LSRA
      RORB
      ROR   FFP_MANT2+2
      ROR   FFP_MANT2+3
      LEAY  -1,Y
      BNE   <
      STD   FFP_MANT2
@FFP_MANT2_Ready:
@EXP1_NoShift:
      LDA   FFP_EXPonent1
      STA   FFP_EXPonent      ; Exponent is the largest one
      LDA   FFP_SIGN1
      STA   FFP_SIGN          ; Sign is taken from the largest exponent
      BRA   @Go_Ready
; EXP2 => EXP1, shift MANT1 right
@EXP2_Big:
      CMPB  #16
      BLS   >
; Shifting right past the rounding info, just clear MANT1
      LDD   #$0000
      STD   FFP_MANT1
      STD   FFP_MANT1+2
      BRA   @FFP_MANT1_Ready
!     CMPB  #8
      BLO   @ShiftMANT1
; Shift MANT1 8 bits
      LDX   FFP_MANT1
      CLR   FFP_MANT1
      STX   FFP_MANT1+1
      SUBB  #8
      BEQ   @FFP_MANT1_Ready  ; MANT2 is ready to be used where it is
      CMPB  #8
      BLO   @ShiftMANT1
; Shift MANT1 another 8 bits
      LDX   FFP_MANT1+1
      CLR   FFP_MANT1+1
      STX   FFP_MANT1+2
      BRA   @FFP_MANT1_Ready  ; MANT2 is ready to be used where it is
@ShiftMANT1
      CLRA
      TFR   D,Y
      LDD   FFP_MANT1
!     LSRA
      RORB
      ROR   FFP_MANT1+2
      ROR   FFP_MANT1+3
      LEAY  -1,Y
      BNE   <
      STD   FFP_MANT1
@FFP_MANT1_Ready:
@EXP2_NoShift:
      LDA   FFP_EXPonent2
      STA   FFP_EXPonent      ; Exponent is the largest one
      LDA   FFP_SIGN2
      STA   FFP_SIGN          ; Sign is taken from the largest exponent
@Go_Ready:
; At this point both mantissa's are lined up properly
; EXP is set proper
; SIGN is set proper
;
; Add or Subtract Mantissas:
; If the signs are the same, add the mantissas
      LDA   FFP_SIGN1
      CMPA  FFP_SIGN2
      BEQ   @Do_Add           ; If the signs are the same then add the Manitssa's
@Do_Sub:
;
; If different, subtract the smaller mantissa from the larger one, determining the result’s sign based on magnitudes.
; Figure out which is is larger:
      LDX   FFP_MANT1
      CMPX  FFP_MANT2
      BHI   >
; FFP_MANT2 = FFP_MANT2 - FFP_MANT1
@MANT2_is_Big
      LDA   FFP_SIGN2
      STA   FFP_SIGN
      LDX   #FFP_MANT2
      LDU   #FFP_MANT1
      BRA   @Do_Sub1
; Subtract: MANT1 = MANT1 - MANT2
; FFP_MANT1 is big
!     LDA   FFP_SIGN1
      STA   FFP_SIGN
      LDX   #FFP_MANT1
      LDU   #FFP_MANT2
@Do_Sub1:
	LDD 	2,X         ; Load Value1 bytes 1 and 0 (least significant 16 bits) into D (A:B)
	SUBD 	2,U         ; Subtract Value2 bytes 1 and 0 from D, sets carry if borrow
	STD 	2,X         ; Store result to Value1 bytes 1 and 0
	LDD 	,X          ; Load Value1 bytes 3 and 2 into D (A:B)
	SBCB 	1,U         ; Subtract Value2 byte 2 from B with borrow
	SBCA 	,U          ; Subtract Value2 byte 3 from A with borrow
	STD 	,X          ; Store result to Value1 bytes 7 and 6
; Shift the 32-bit mantissa left until bit 31 is 1, adjusting the exponent
      LDD   ,X
      BNE   >
      LDD   2,X
      BEQ   @Skip0      ; Skip if there is no Value
!     LDB   FFP_EXPonent
!     LDA   ,X
      BITA  #%10000000
      BNE   >           ; Bit 31 is a 1 we are done shifting
      ASL   3,X
      ROL   2,X
      ROL   1,X
      ROL   ,X
      DECB              ; EXP=EXP-1
      BRA   <
!     STB   FFP_EXPonent
@Skip0:
      LDD   ,X
      LDX   2,X
      LDU   #FFP_MANT+4
      PSHU  D,X         ; Save the Mantissa in FFP_MANT
      BRA   @Skip1
@Do_Add:
      LDD   FFP_MANT1+2
      ADDD  FFP_MANT2+2
      STD   FFP_MANT+2        ; Save extra bits for rounding
; Since MSbit is always 1 for Value 1 & value 2, we always need to rotate the result right 1 into byte 3 so
      LDD   FFP_MANT1
      BCC   >                 ; If no carry above then skip adding 1 to D
      INCB                    ; Add the carry bit
      BNE   >                 ; If we didn't just become zero skip ahead
      INCA
!     ADDD  FFP_MANT2
      STD   FFP_MANT          ; Save main result
; Increase the exponent
      BCC   @Skip1
; Increment the Exponent and right shift FFP_MANT
      ROR   FFP_MANT
      ROR   FFP_MANT+1
      ROR   FFP_MANT+2
      INC   FFP_EXPonent
      LDA   FFP_EXPonent
      CMPA  #$40              ; Have we overflowed?
      BGE   @PosInfinity      ; Otherwise we hit +Infinity
@Skip1:
      LDU   #FFP_MANT
      BSR   FFP_Round_U ; Normalize mantissa and round 32 bit value at U, EXP will be handled along with overflow checking
      LDB   FFP_EXPonent      ; Get Exponent in B
      LSLB                    ; Shift exponent left (exponent is 7 bit signed value)
      LDA   FFP_SIGN          ; Get the sign in A
      LSLA                    ; Shift Sign bit into the carry
      RORB                    ; Fix exponent and copy carry (sign bit) into bit 7 of B
      LDX   FFP_MANT          ; Get the 16 bit mantissa in X
      PSHS  B,X               ; Save Result on the stack
@Return:
      JMP   >$FFFF            ; Return (Self modified address above)
; Value 1 is special, Value 2 is not special
; Return with Value 1
@ReturnSpecial1
      LEAS  3,S               ; Move past Value 2, so value 1 is the result
      BRA   @Return
;
; Value 2 is special, Value 1 has not been checked
@ReturnSpecial2
      LDA   3,S               ; Get sign & exponent of Value 1
      LSLA
      CMPA  #$80              ; Is it special
      BNE   @CopySpecial2
; Value 2 and Value 1 are both special, if one is +infinity and the other is -infinity then result in NaN
; check for NaN's first
      LDA   1,S
      BMI   @NaN2Exit         ; Value 2 is a NaN
      LDA   4,S
      BMI   @NaN1Exit         ; Value 1 is a NaN
; We get here when they are both infinity, if one is -infinity and the other is positve infinty then return with NaN
; Otherwise return with Value1 (they are the same)
      LDA   ,S
      BMI   @Value2Neg
; value 2 is positive
      LDA   3,S               ; Check Value 1
      BMI   @ResultNaN        ; It is negative return with NaN
      BRA   @ReturnVal1       ; They are the same, return with Value 1
; Value 2 is negative
@Value2Neg:
      LDA   3,S               ; Check Value 1
      BPL   @ResultNaN        ; It is positive return with NaN
@ReturnVal1:
      LEAS  3,S
      BRA   @Return
; Value 1 is a NaN
@NaN1Exit
; Value 2 is a NaN
@NaN2Exit
@ResultNaN:
      LEAS  6,S
      LDA   #%01000000        ; Flag as special
      LDX   #$8000            ; Set MSbit
!     PSHS  A,X               ; Store the result
      BRA   @Return           ; RTS
; Value 1 is not special, value 2 is special, so return with Value 2
@CopySpecial2:
      PULS  A,X               ; get special Value 2
      LEAS  3,S               ; Move the stack
      BRA   <                 ; Store and return
@PosInfinity:
      LDA   #%01000000        ; Flag as special
      LDX   #$0000            ; Clear MSbit
      BRA   <                 ; Store and return

; Round 32 bit value at U and bump FFP_EXPonent if needed
; G is the MSbit we drop, R is the 2nd MSbit we drop, S is OR'ed with the other bits we dropped (0 or 1)
;   •	If G = 0, you’re less than halfway to the next representable mantissa, so you leave M unchanged.
;	•	If G = 1 and (R or S = 1) — i.e. you’re strictly more than halfway — you add 1 to M.
;	•	If G = 1, R = 0, S = 0 — i.e. you’re exactly halfway (the bit pattern is ...xyz1000…0) — you add 1 to M only if 
;                the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
;
FFP_Round_U:
      LDD   ,U          ; Make sure we don't get stuck in an endless shift if mantissa is zero
      BEQ   @Round
!     BMI   @Round      ; Normalize the manitssa
      LSL   2,U
      ROL   1,U
      ROL   ,U
      DEC   FFP_EXPonent
      LDA   FFP_EXPonent
      CMPA  #-$40       ; Have we underflowed
      BLE   @UnderflowToZero   ; We have underflowed
      BRA   FFP_Round_U
@Round:
      LDA   2,U         ; Get bits for rounding
      BPL   @Done
; Otherwise check if R or S are 1
      BITA  #%01111111  ; Check R & S
      BNE   @AddOne     ; if they're 1 then add to the mantissa
      LDA   3,U         ; get extra sticky bits
      BNE   @AddOne
; If we get here we have to check LSbit of our mantissa as ties to even means if it's an even number skip adding one
      LDA   1,U         ; Get low byte of our 16 bit mantissa
      BITA  #%00000001  ; Is it odd?
      BEQ   @Done       ; if not we are done
@AddOne
      INC   1,U
      BNE   @Done
      INC   ,U
      BNE   @Done
; If we get here then we just overflowed (the mantissa is now $010000)
      LDA   #%10000000
      STA   ,U          ; Set the high bit of the mantissa
@IncreaseExponent:
      INC   FFP_EXPonent
      LDA   FFP_EXPonent
      CMPA  #$40        ; Have we overflowed?
      BLO   @Done       ; If not we are done
; Otherwise we hit +Infinity
      CLR   ,U          ; Make mantissa +Infinity
      CLR   1,U
@Done:
      RTS
@UnderflowToZero:
      CLR   FFP_SIGN
      CLR   FFP_EXPonent
      CLR   ,U
      CLR   1,U
      CLR   2,U
      CLR   3,U
      RTS

; FFP_MUL - Multiply 3,S * ,S then S=S+3 result is @ ,S
FFP_MUL:
      PULS  D               ; Get return address off the stack
      STD   @Return+1       ; Self mod return JMP adress below
; Check for NaN or Infinity (If either value 1 or value 2 is NaN return with a value of NaN)
      LDA   ,S          ; Get the Sign and Exponent Value 2
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial2 ; Fix stack and return with Special result
      LDA   3,S         ; Get the Sign and Exponent Value 1
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial1  ; Fix stack and return with Special result
; Check for zeros, Start with Value 2
      LDD   1,S
      BEQ   @ReturnZero
; Check Value 1 for zero
@NotZero:
      LDD   4,S
      BNE   @GoodValues
@ReturnZero:
; Get here with a value of zero, return with +0
      CLRB
      LEAS  6,S         ; Move the stack forward
      LDX   #$0000
      PSHS  B,X
      JMP   @Return     ; RTS
; We get here when we have two good values to Multiply
@GoodValues:
; SIGN = SIGN1 XOR SIGN2
!     LDA   3,S         ; A = SIGN Value 1
      EORA  ,S         ; EORA with SIGN Value 2
      ANDA  #%10000000  ; Save only the sign bit
      STA   FFP_SIGN    ; Save the new SIGN
;
; Exponent = EXP1 + EXP2
      LDA   3,S         ; D = EXP Value 1
      LSLA              ; Strip off the sign bit
      ASRA              ; A = 8 bit signed version of Exponent Value 1
      PSHS  A           ; Save it on the stack
      LDA   1,S         ; A = EXP Value 2
      LSLA              ; Strip off the sign bit
      ASRA              ; A = 8 bit signed version of Exponent Value 2
      ADDA  ,S+         ; A = A + EXP Value 1, fix the stack
      INCA
      CMPA  #$40        ; Have we overflowed?
      BGE   @PosInfinity ; Otherwise we hit +Infinity
      STA   FFP_EXPonent ; Save the new EXP
;
; Multiply mantissas (32-bit result)
; We will multiply Value 2 * Value 1
; Move Mantissa 2 & keep Mantissa 1 on the stack
; then call the Unsigned 16 bit integer multiply function
;
      LDD   1,S         ; Get value 2 Mantissa
      LEAS  2,S         ; Move the stack
      STD   ,S          ; Save Value 2 Mantissa (we now have 16 bit value and 16 bit value on the stack)
; We now have Value 2 mantissa then Value 1 Mantissa on the stack
      JSR   MUL16       ; Unsigned 16 bit multiply, 2,S * ,S then S=S+2, Low 16 bits are on the stack, D = high 16 bits
      LDU   #FFP_MANT+4 ; Save the 32 bit result in FFP_MANT
; Minimal value will be: $4000 0000
; Maximum value will be: $FFFE 0001
      PULS  X           ; Get X and fix the stack
      PSHU  D,X         ; Save full 32 bit value @ FFP_MANT
      JSR   FFP_Round_U ; Normalize mantissa and round 32 bit value at U, EXP will be handled along with overflow checking
      LDB   FFP_EXPonent ; Get Exponent in B
      LSLB              ; Shift exponent left (exponent is 7 bit signed value)
      LDA   FFP_SIGN    ; Get the sign in A
      LSLA              ; Shift Sign bit into the carry
      RORB              ; Fix exponent and copy carry (sign bit) into bit 7 of B
      LDX   FFP_MANT    ; Get the 16 bit mantissa in X
      PSHS  B,X         ; Save Result on the stack
@Return:
      JMP   >$FFFF      ; Return (Self modified address above)
;
; Value 1 is special, Value 2 is not special
; Return with Value 1
@ReturnSpecial1
      LEAS  3,S         ; Move past Value 2, so value 1 is the result
      BRA   @Return
;
; Value 2 is special, Value 1 has not been checked
@ReturnSpecial2
      LDA   3,S         ; Get sign & exponent of Value 1
      LSLA
      CMPA  #$80        ; Is it special
      BNE   @CopySpecial2
; Value 2 and Value 1 are both special, if one is +infinity and the other is -infinity then result in NaN
; check for NaN's first
      LDA   1,S
      BMI   @NaN2Exit   ; Value 2 is a NaN
      LDA   4,S
      BMI   @NaN1Exit   ; Value 1 is a NaN
; We get here when they are both infinity, if one is -infinity and the other is positve infinty then return with NaN
; Otherwise return with Value1 (they are the same)
      LDA   ,S
      BMI   @Value2Neg
; value 2 is positive
      LDA   3,S         ; Check Value 1
      BMI   @ResultNaN  ; It is negative return with NaN
      BRA   @ReturnVal1 ; They are the same, return with Value 1
; Value 2 is negative
@Value2Neg:
      LDA   3,S         ; Check Value 1
      BPL   @ResultNaN  ; It is positive return with NaN
@ReturnVal1:
      LEAS  3,S
      BRA   @Return
; Value 1 is a NaN
@NaN1Exit
; Value 2 is a NaN
@NaN2Exit
@ResultNaN:
      LEAS  6,S
      LDA   #%01000000  ; Flag as special
      LDX   #$8000      ; Set MSbit
!     PSHS  A,X         ; Store the result
      BRA   @Return     ; RTS
; Value 1 is not special, value 2 is special, so return with Value 2
@CopySpecial2:
      PULS  A,X         ; get special Value 2
      LEAS  3,S         ; Move the stack
      BRA   <           ; Store and return
@PosInfinity:
      LDA   #%01000000  ; Flag as special
      LDX   #$0000      ; Clear MSbit
      BRA   <           ; Store and return

; FFP_DIV - Divide 3,S / ,S then S=S+3 result is @ ,S
FFP_DIV:
      PULS  D               ; Get return address off the stack
      STD   @Return+1       ; Self mod return JMP adress below
; Check for NaN or Infinity (If either value 1 or value 2 is NaN return with a value of NaN)
      LDA   ,S          ; Get the Sign and Exponent Value 2
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial2 ; Fix stack and return with Special result
      LDA   3,S         ; Get the Sign and Exponent Value 1
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial1  ; Fix stack and return with Special result
; Check for zeros, Start with Value 2
      LDD   1,S
      BNE   @NotZero
; Get here with a value of zero
      LDD   4,S         ; Get Value 1 Mantissa
      LBEQ  @ReturnNaN  ; Value 1 is zero, return with NaN
; Return with infinte sign of Value 1
      LDA   3,S         ; Get sign and Exponent of Value 1
      LDB   #$80
      ROLA              ; Put Value 1 sign on carry
      RORB              ; B has our Special Value with the correct sign
      LDX   #$0000
      LEAS  6,S         ; Move the stack forward
      PSHS  B,X
      JMP   @Return     ; RTS
; Check Value 1 for zero, Value 2 is not zero
@NotZero:
      LDD   4,S
      BNE   @GoodValues
; Get here with value 1 = zero, Value 2 is not zero, return with a value of zero
      LDB   3,S
@OutPutZero:
      ANDB  #%10000000  ; Keep the sign bit
      LDX   #$0000
      LEAS  6,S         ; Move the stack forward
      PSHS  B,X
      JMP   @Return     ; RTS
; We get here when we have two good values to Divide
@GoodValues:
; SIGN = SIGN1 XOR SIGN2
      LDA   3,S         ; A = SIGN Value 1
      EORA  ,S         ; EORA with SIGN Value 2
      ANDA  #%10000000  ; Save only the sign bit
      STA   FFP_SIGN    ; Save the new SIGN
;
; Exponent = EXP1 - EXP2
      LDA   ,S          ; A = EXP Value 2
      LSLA              ; Strip off the sign bit
      ASRA              ; A = 8 bit signed version of Exponent Value 2
      PSHS  A           ; Save it on the stack
      LDA   4,S         ; A = EXP Value 1
      LSLA              ; Strip off the sign bit
      ASRA              ; A = 8 bit signed version of Exponent Value 1
      SUBA  ,S+         ; A = EXP1 - EXP2
      CMPA  #-$3F
      LBLT   @NegInfinity ; If the exponent is too low, return with -infinity
      STA   FFP_EXPonent  ; Save the new EXP
;
; Divide mantissas (16 bit result and 16 bit remainder)
; We will divide Value 1 / Value 2
;
Do_Slow_Div EQU 1       ; 0 here = Fast using Newton-Raphson method
 IF Do_Slow_Div
Slow_Div:
;
      LDD   1,S         ; Get value 2 Mantissa
      LEAS  2,S         ; Move the stack
      STD   ,S          ; Save Value 2 Mantissa (we now have 16 bit value 2 and 16 bit value 1 on the stack)
;
; Needed for the good 32 bit rotate division
      PULS  D,X         ; D = Value 2, X = Value 1
      LDU   #$0000
      PSHS  X,U         ; Save a 32 bit Dividend
      LSR   ,S
      ROR   1,S
      ROR   2,S
      PSHS  D           ; Save a 16 bit Divisor
;
; We now have Value 2 mantissa then Value 1 Mantissa on the stack
      JSR   DIV_U32_U16  ; Divide a 32 bit unsigned number @ 2,S with an unsigned 16 bit number at ,S
                         ; Result as 16 bit quotient at ,S & remainder as 16 bit represents the fractional part × 2¹⁶ at 2,S
;
; Since we do division where the 16 bit MSbit of the dividend and the divisor are set the quotient will always be 1
; Therefor we always need to shift left 15 bits, faster to shift right 1
; Shift value 1 and save proper format
      PULS  D,X
 ELSE
;
      PULS  A,Y         ; Y = Divisor
      LDU   1,S         ; D = Dividend
      LEAS  3,S         ; fix the stack
;
;   U = dividend mantissa (Q1.15),MSB=1
;   Y = divisor  mantissa (Q1.15),MSB=1
;
      JSR   DivFast     ; Div fast using multiply 16 bit result in D
 ENDIF
;
; Now D:X = Full 32-bit fixed-point result
      LDU   #FFP_MANT+4   ; Save the 32 bit result in FFP_MANT
      PSHU  D,X
;
      JSR   FFP_Round_U ; Normalize mantissa and round 32 bit value at U, EXP will be handled along with overflow checking
      LDB   FFP_EXPonent ; Get Exponent in B
      LSLB              ; Shift exponent left (exponent is 7 bit signed value)
      LDA   FFP_SIGN    ; Get the sign in A
      LSLA              ; Shift Sign bit into the carry
      RORB              ; Fix exponent and copy carry (sign bit) into bit 7 of B
      LDX   FFP_MANT    ; Get the 16 bit mantissa in X
      PSHS  B,X         ; Save Result on the stack
@Return:
      JMP   >$FFFF      ; Return (Self modified address above)
;
; Value 1 is special, Value 2 is not special
; Return with special Value 1
@ReturnSpecial1:
      LEAS  3,S         ; Move past Value 2, so value 1 is the result
      BRA   @Return     ; Return with NaN
;
; Value 2 is special, Value 1 has not been checked
@ReturnSpecial2:
      LDA   1,S         ; Get Mantissa MSB
      BMI   @CopySpecial2  ; If MSbit = 1 then it's NaN return with that value
; Value 2 is infinity
      LDA   3,S         ; A = Sign & Exponent value 1
      ANDA  #%01111111  ; A = Exponent
      CMPA  #$40
      BEQ   >
; Output Zero with sign of Value 1
      LDB   3,S
      ANDB  #%10000000
      LDX   #$0000
      LEAS  6,S
      PSHS  B,X
      BRA   @Return
; We get here when Value 1 is special
!     LDA   4,S         ; A = MSB of Mantissa value 1
      BMI   @ReturnSpecial1 ; If MSbit =1 then int's NaN return with that value
; We get here when both are Infinity, Return with NaN
; Return with NaN
@ReturnNaN:
      LEAS  6,S
      LDA   #%01000000  ; Flag as special
      LDX   #$8000      ; Set MSbit
!     PSHS  A,X         ; Store the result
      BRA   @Return     ; RTS
; Value 1 is not special, value 2 is special, so return with Value 2
@CopySpecial2:
      PULS  A,X         ; get special Value 2
      LEAS  3,S         ; Move the stack
      BRA   <           ; Store and return
@PosInfinity:
      LDA   #%01000000  ; Flag as special
!     LDX   #$0000      ; Clear MSbit
      BRA   <           ; Store and return
@NegInfinity:
      LDA   #%11000000  ; Flag as negative special
      BRA   <

 IF Do_Slow_Div
; ============================================================
; DIV_U32_U16 - Unsigned 32-bit / 16-bit divide routine for Motorola 6809
; Optimized 32-bit ÷ 16-bit → 16-bit quotient + full rounding bits
;FFP_DIVIDEND EQU FFP_MANT1 ; 32-bit dividend (high 16 = mant1, low 16 = 0)
;FFP_DIVISOR EQU FFP_MANT2 ; 16-bit divisor
;FFP_QUOT EQU FFP_MANT ; 32-bit quotient
;
; Divide a 32 bit unsigned number @ 2,S with an unsigned 16 bit number at ,S
FFP_DIVIDEND EQU FFP_MANT1 ; 32-bit dividend (high 16 = mant1, low 16 = 0)
FFP_DIVISOR EQU FFP_MANT2 ; 16-bit divisor
FFP_QUOT EQU FFP_MANT ; 32-bit quotient
FFP_Remainder     EQU   FFP_Medium4_03
;
; Divide a 32 bit unsigned number @ 2,S with an unsigned 16 bit number at ,S
DIV_U32_U16:
	PULS  D		      ; Get return address
	STD   @Return+1	      ; Self mod return address
	PULS  D,X,U	            ; D = Value 2 (Divisor), X:U = Value 1 (Dividend)
	STX   FFP_DIVIDEND	; Value 1 MSWord
	STU   FFP_DIVIDEND+2	; Value 1 LSWord
      PSHS  D                 ; Save the divisor on the stack (never changes)
;
	LDX   #FFP_DIVIDEND     ;
      LDY   #Remainder        ; 
      LDU   #FFP_QUOT 	      ; 
; 2) Initialize quotient to zero
;      STD   ,U
;      STD   2,U
; 3) Initialize remainder to zero
	LDD   #$0000	      ; D = remainder = 0
      STD   ,Y
      STD   2,Y   
;
; 4) Loop over 64 bits          
      LDA   #32               ; bit-count
      STA   FFP_Temp1
;
DIV_U32_U16_Loop:
; 4a) Shift dividend left by 1
      LSL   3,X      	; clear carry & shift left, low byte, to high byte
      ROL   2,X
      ROL   1,X
      ROL   ,X
;
; 4b) Shift remainder left by 1, bring in carry
      ROL   3,Y      	; Shift remainder left by 1, bring in carry
      ROL   2,Y
      ROL   1,Y
      ROL   ,Y
;
; 4c) Shift quotient left by 1
      LSL   3,U      	; clear carry & shift left, low byte, to high byte
      ROL   2,U
      ROL   1,U
      ROL   ,U
;
; 4d) Compare remainder vs divisor
	LDD   ,Y
      CMPD  #$0000
      BHI   Do_Subtract_DIV_U32_U16       ; remainder.H > divisor.H
      BNE   No_Subtract_DIV_U32_U16       ; remainder.H < divisor.H
	LDD   2,Y
	CMPD	,S                            ; Compare the remainder with the divisor
      BLO   No_Subtract_DIV_U32_U16       ; remainder.L < divisor.L
;
Do_Subtract_DIV_U32_U16:
; Subtract divisor from remainder
	LDD   2,Y
	SUBD	,S
	STD   2,Y
    	LDD   ,Y
      SBCB  #$00
      SBCA  #$00
	STD   ,Y
; Set quotient LSB to 1
    	INC   3,U
;
No_Subtract_DIV_U32_U16:
; 4e) Loop
      DEC   FFP_Temp1
      LBNE  DIV_U32_U16_Loop
      LEAS  2,S         ; Fix stack
      LDD   2,U         ; D = 16 bit quotient
      LDX   ,Y          ; X = MSWord of Remainder
      PSHS  D,X         ; Save it on the stack
@Return:
      JMP   >$FFFF      ; Return, self modified jump address

 ELSE

; Fast FFP Mantissa Division using Newton-Raphson Reciprocal on 6809
; In:
; U = dividend mantissa (Q1.15)
; Y = divisor mantissa (Q1.15)
; Out:
; D = approx quotient mantissa (Q1.15)
DivFast:
;-----------------------------------
; 1) Build index from divisor high bits
;-----------------------------------
      TFR   Y,D   ; D = divisor mant
      LSRA
      LSRA
      LSRA
      LSRA
      LSRA
;      ANDA  #$07
      LDX   #recip_table
      LDA   A,X   ; table value
      CLRB
      TFR   D,X   ; X = table_value << 8 (Q0.16)
;
;-----------------------------------
; 2) Initial reciprocal approximation (r0 from table)
;-----------------------------------
; (No additional operations needed here beyond lookup)
;-----------------------------------
; 3) t = v * r0 (Q1.15)
;-----------------------------------
      PSHS  X     ; op2 = r0
      PSHS  Y     ; op1 = v
      JSR   MUL16       ; Unsigned 16 bit multiply, 2,S * ,S then S=S+2, Low 16 bits are on the stack, D = high 16 bits
; Minimum D can be after MUL is $4000, Max is $FFFE
      TSTA
      BMI   >     ; If bit 15 is already set then don't normalize it
      LSL   1,S
      ROL   ,S
      ROLB
      ROLA
!     LDX   ,S++  ; Check value for rounding and fix the stack
      BPL   >     ; If MSbit is clear then don't increment D skip ahead
      INCB
      BNE   >
      INCA
      BNE   >
      LDD   #$FFFF ; Keep $FFFF as max value
; D = t
;
;-----------------------------------
; 4) r1 = r0 * (2 - t)
;-----------------------------------
!     PSHS  D
      LDD   #$0000
      SUBD  ,S++  ; D = 2 - t (unsigned)
      PSHS  X     ; op2 = r0
      PSHS  D     ; op1 = 2 - t
      JSR   MUL16       ; Unsigned 16 bit multiply, 2,S * ,S then S=S+2, Low 16 bits are on the stack, D = high 16 bits
; Minimum D can be after MUL is $4000, Max is $FFFE
      TSTA
      BMI   >     ; If bit 15 is already set then don't normalize it
      LSL   1,S
      ROL   ,S
      ROLB
      ROLA
!     LDX   ,S++  ; Check value for rounding and fix the stack
      BPL   >     ; If MSbit is clear then don't increment D skip ahead
      INCB
      BNE   >
      INCA
      BNE   >
      LDD   #$FFFF ; Keep $FFFF as max value
; 2nd iteration not needed for 3 Byte Fast Float 
;-----------------------------------
; Second iteration for better accuracy
;-----------------------------------
;      TFR   Y,D   ; D = v
;      PSHS  X     ; op2 = r1
;      PSHS  Y     ; op1 = v
;      JSR   MUL16
;      LEAS  2,S   ; drop low
;; D = t
;      PSHS  D
;      LDD   #0
;      SUBD  ,S++  ; D = 2 - t
;      PSHS  X     ; op2 = r1
;      PSHS  D     ; op1 = 2 - t
;      JSR   MUL16
;      LEAS  2,S   ; drop low
;      LSLB
;      ROLA        ; <<1
;; D = r2 (refined reciprocal)
;      TFR   D,X   ; X = r2 (save before overwrite)
;;
;-----------------------------------
; 5) q = MulHi(U, r2) (the actual division)
;-----------------------------------
!     PSHS  U     ; op1 = U
      PSHS  X     ; op2 = r2
      JSR   MUL16 ; Unsigned 16 bit multiply, 2,S * ,S then S=S+2, Low 16 bits are on the stack, D = high 16 bits
; Minimum D can be after MUL is $4000, Max is $FFFE
      TSTA
      BMI   >     ; If bit 15 is already set then don't normalize it
      LSL   1,S
      ROL   ,S
      ROLB
      ROLA
; If we shift the final result left 1 bit, we need to decrement the FFP exponent
      DEC   FFP_EXPonent      ; exp -=1
!     LDX   ,S++  ; Check value for rounding and fix the stack
      BPL   >     ; If MSbit is clear then don't increment D skip ahead
      INCB
      BNE   >
      INCA
      BNE   >
      LDD   #$FFFF ; Keep $FFFF as max value
; D = q ≈ U / Y in Q1.15
!     RTS
;
recip_table:
      fcb $FF,$E3,$CC,$BA,$AA,$9D,$92,$88
 ENDIF

; Convert 3 Byte FFP at ,S to 32-bit signed integer at ,S
FFP_TO_S32:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
    JSR     FFP_TO_S64  ; Convert 3 Byte FFP @ ,S to Signed 64-bit Integer @ ,S
    LEAS    4,S         ; Pull two high signed words off the 64 bit number on the stack, Save only the two low words
@Return:
    JMP     >$FFFF      ; return (self modified)

; Convert 3 Byte FFP at ,S to 32-bit unsigned integer at ,S
FFP_TO_U32:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
    JSR     FFP_TO_U64  ; Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S
    LEAS    4,S         ; Pull two high unsigned words off the 64 bit number on the stack, Save only the two low words
@Return:
    JMP     >$FFFF      ; return (self modified)

; Convert 3 Byte FFPe at ,S to 16-bit signed integer at ,S
FFP_TO_S16:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
    JSR     FFP_TO_S64  ; Convert 3 Byte FFP @ ,S to Signed 64-bit Integer @ ,S
    LEAS    6,S         ; Pull three high signed words off the 64 bit number on the stack, Save only the low word
@Return:
    JMP     >$FFFF      ; return (self modified)

; Convert 3 Byte FFP at ,S to 16-bit unsigned integer at ,S
FFP_TO_U16:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
    JSR     FFP_TO_U64  ; Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S
    LEAS    6,S         ; Pull three high unsigned words off the 64 bit number on the stack, Save only the low word
@Return:
    JMP     >$FFFF      ; return (self modified)

; Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S
FFP_TO_U64:
      PULS  U           ; get the return address in U
      STU   @Return+1   ; Self modify the return location below
      JSR   Validate_FFP ; Go validate FFP number at ,S and return with FFP_SIGN, FFP_EXPonent & MANT1 setup
                        ; Will not return if number is not valid, but will return with proper invalid value or zero
; Returns with:
; X pointing at the stored 64 bit number and
; B is the Exponent value
      TFR   X,U         ; Move pointer to U
; ----------------------------
; 0) If value is negative → clamp to 0
; ----------------------------
      LDA   FFP_SIGN
      BEQ   FFP_U64_Positive    ; if sign == 0, go do normal conversion
; Negative → return 0 (unsigned clamp)
@ReturnZero:
      LDD   #$0000
      LDX   #$0000
      PSHS  D,X
      PSHS  D,X
      BRA   @Return
;
FFP_U64_Positive:
; Compute shift count = exp - 15
; B = exp (signed)
      SUBB  #15               ; B = exp - 15
      BEQ   FFP_U64_ShiftDone ; no shift needed
      BPL   FFP_U64_DoLeft    ; if B > 0 → left shift
; ---- Right shift by -B bits (exp - 15 < 0) ----
      NEGB                    ; B = -(exp - 15)  (number of right-shift bits)
; If shifting right by >= 64 bits, result is zero.
      CMPB  #16               ; If we shift all 16 bits out of the mantissa
      BHS   @ReturnZero       ;  it will be zero
FFP_U64_DoRight:
      JSR   FFP_Shift_Right64_AtU_B  ; Logical right-shift 64-bit value at U by B bits (B >= 0)
      BRA   FFP_U64_ShiftDone
;
FFP_U64_DoLeft:
; ---- Left shift by B bits (exp - 15 > 0) ----
; With your 7-bit signed exponent range, this safely fits in 64 bits.
      JSR   FFP_Shift_Left64_AtU_B ; Left-shift 64-bit value at U by B bits (B >= 0)
;
FFP_U64_ShiftDone:
; FFP_MANT1..+7 now hold the unsigned 64-bit integer, truncated.
    PULU  D,X,Y
    LDU   ,U
    PSHS  D,X,Y,U
@Return:
      JMP   >$FFFF          ; return (self modified)

; Convert 3 Byte FFP @ ,S to Signed 64-bit Integer @ ,S
FFP_TO_S64:
      PULS  U           ; get the return address in U
      STU   @Return+1   ; Self modify the return location below
      BSR   Validate_FFP ; Go validate FFP number at ,S and return with FFP_SIGN, FFP_EXPonent & MANT1 setup
                        ; Will not return if number is not valid, but will return with proper invalid value or zero
; Returns with:
; X pointing at the stored 64 bit number and
; B is the Exponent value
      TFR   X,U         ; Move pointer to U
; ---- Compute net shift = exponent - 15 (because mantissa is Q1.15) ----
      SUBB  #15           ; shift = exponent - 15
      BEQ   FFP_SHIFT_DONE
      BPL   FFP_DO_LSHIFT ; shift > 0 -> left shift
; shift < 0 -> right shift by -shift
      NEGB                 ; B = -shift
      JSR   FFP_Shift_Right64_AtU_B ; Logical right-shift 64-bit value at U by B bits (B >= 0)
      BRA   FFP_SHIFT_DONE
FFP_DO_LSHIFT:
; A = positive shift count
      JSR   FFP_Shift_Left64_AtU_B ; Left-shift 64-bit value at U by B bits (B >= 0)
;
FFP_SHIFT_DONE:
; ---- Apply sign: if negative, two's complement of 64-bit magnitude ----
      LDA   FFP_SIGN
      BEQ   FFP_SIGN_DONE     ; positive
; Negate_64:
    COM     ,U
    COM     1,U
    COM     2,U
    COM     3,U
    COM     4,U
    COM     5,U
    COM     6,U
    COM     7,U
; + 1
; Propagate if needed
    INC     7,U
    BNE     FFP_SIGN_DONE     ; If <> zero, don't propagate carry, done
    INC     6,U
    BNE     FFP_SIGN_DONE     ; If <> zero, don't propagate carry, done
    INC     5,U
    BNE     FFP_SIGN_DONE     ; If <> zero, don't propagate carry, done
    INC     4,U
    BNE     FFP_SIGN_DONE     ; If <> zero, don't propagate carry, done
    INC     3,U
    BNE     FFP_SIGN_DONE     ; If <> zero, don't propagate carry, done
    INC     2,U
    BNE     FFP_SIGN_DONE     ; If <> zero, don't propagate carry, done
    INC     1,U
    BNE     FFP_SIGN_DONE     ; If <> zero, don't propagate carry, done
    INC     ,U
FFP_SIGN_DONE:
    PULU  D,X,Y
    LDU   ,U
    PSHS  D,X,Y,U
@Return:
    JMP     >$FFFF          ; return (self modified)

; Validate FFP number at ,S and return with FFP_SIGN, FFP_EXPonent & MANT1 setup
; Will not return to U if number is not valid, but will return with proper invalid value or zero
; Returns with:
; X pointing at the stored 64 bit number and
; B is the Exponent value
Validate_FFP:
      PULS  D
      STD   @AllGood+1  ; Self modify the return location below
      LDA   ,S
      ANDA  #%10000000  ; Save only the SIGN bit
      STA   FFP_SIGN    ; Save the SIGN
      PULS  B,X         ; Get the sign, exponent and mantissa off the stack
      LSLB
      BNE   @NotZero
; If we get here it could be zero
      CMPX  #$0000
      BEQ   @OutZero    ; Return with zero
@NotZero
      CMPB  #$80
      BNE   @Valid   
      CMPX  #$0000      ; Check Mantissa
      BNE   @NaN
; We get here with infinity
      LDD   #%0111111111111111 ; Max value
      ORA   FFP_SIGN    ; Add the sign bit
      LDX   #$FFFF
      PSHS  D,X
      TFR   X,D
!     PSHS  D,X         ; Save result on the stack
      BRA   @Return     ; Return
@NaN:
      LDX   #$0000
@OutZero:
      LDD   #$0000
      PSHS  D,X
      BRA   <           ; Save on the stack & Return
; We get here with a valid number to convert
@Valid
; Place mantissa in low 16 bits of the 64-bit area
      STX   FFP_MANT1+6 ; Save the LSWord
; Fix up exponent value
      ASRB              ; B = signed exponent
      STB   FFP_EXPonent ; Save the EXPonent
;
; FFP_EXPonent range is -63 to 63 which will always fit in a 64bit range so no clamp limit is neccessary
;
; Clear result area (6 bytes)
      LDU   #$0000
      LDX   #FFP_MANT1  ; FFP_MANT1 & MANT2 is 64 bits of space we can use
      STU   ,X
      STU   2,X
      STU   4,X
@AllGood:
      JMP   >$FFFF          ; return (self modified
@Return:
      JMP   ,U          ; return not valid (self modified)

;------------------------------------------------------------
; FFP_Shift_Right64_AtU_B
; Logical right-shift 64-bit value at U by B bits (B >= 0).
; Destroys: A & B
;------------------------------------------------------------
FFP_Shift_Right64_AtU_B:
      STB   ,-S   ; Save B on the stack
      BEQ   FFP_SR64_DONE
      LDD   6,U
!     LSR   ,U
      ROR   1,U
      ROR   2,U
      ROR   3,U
      ROR   4,U
      ROR   5,U
      RORA
      RORB
      DEC   ,S
      BNE   <
      STD   6,U
FFP_SR64_DONE:
      PULS  B,PC

;------------------------------------------------------------
; FFP_Shift_Left64_AtU_B
; Left-shift 64-bit value at U by B bits (B >= 0).
; Destroys: A & B
;------------------------------------------------------------
FFP_Shift_Left64_AtU_B:
      STB   ,-S   ; Save B on the stack
      BEQ   FFP_SL64_DONE
      LDD   6,U
!     LSLB
      ROLA
      ROL   5,U
      ROL   4,U
      ROL   3,U
      ROL   2,U
      ROL   1,U
      ROL   ,U
      DEC   ,S
      BNE   <
      STD   6,U
FFP_SL64_DONE:
      PULS  B,PC

;-----------------------------------------------------------
; U64_To_FFP
; Convert unsigned 64-bit integer (two's complement) at ,S into 3-byte FFP at ,S.
U64_To_FFP:
      PULS    D           ; Get return address off the stack
      STD     @Return+1   ; Self modify the return location below
; CheckZero:
      LDD   6,S
      BNE   >
      LDD   4,S
      BNE   >
      LDD   2,S
      BNE   >
      LDD   ,S
      BNE   >
; value is exactly 0  
      LEAS  5,S   ; Keep 3 zero bytes and return (3 zero bytes = 0 for FFP format)
      JMP   @Return
;-------------------------------
; 1) Sign is always positive
;-------------------------------
!     CLR   FFP_SIGN          ; unsigned → sign = + (0)
      BRA   @Convert
;
;-----------------------------------------------------------
; S64_To_FFP
; Convert signed 64-bit integer (two's complement) at ,S into 3-byte FFP at ,S.
S64_To_FFP:
      PULS    D           ; Get return address off the stack
      STD     @Return+1   ; Self modify the return location below
; CheckZero:
      LDD   6,S
      BNE   Int64_FFP_NonZero
      LDD   4,S
      BNE   Int64_FFP_NonZero
      LDD   2,S
      BNE   Int64_FFP_NonZero
      LDD   ,S
      BNE   Int64_FFP_NonZero
; value is exactly 0  
      LEAS  5,S   ; Keep 3 zero bytes and return (3 zero bytes = 0 for FFP format)
      JMP   @Return
;
Int64_FFP_NonZero:
;-------------------------------
; 1) Extract sign and copy to scratch
;-------------------------------
      LDA   ,S            ; MSB of 64-bit integer
      ANDA  #$80          ; isolate sign bit
      STA   FFP_SIGN      ; 0 or $80
;
;-------------------------------
; 2) If negative, take two's complement to get magnitude
;-------------------------------
      BEQ   @Convert   ; positive → already magnitude
;
; negate 64-bit value at FFP_MANT1..+7: mag = -mag
; Negate_64:
    COM     ,S
    COM     1,S
    COM     2,S
    COM     3,S
    COM     4,S
    COM     5,S
    COM     6,S
    COM     7,S
; + 1
; Propagate if needed
    INC     7,S
    BNE     @Convert     ; If <> zero, don't propagate carry, done
    INC     6,S
    BNE     @Convert     ; If <> zero, don't propagate carry, done
    INC     5,S
    BNE     @Convert     ; If <> zero, don't propagate carry, done
    INC     4,S
    BNE     @Convert     ; If <> zero, don't propagate carry, done
    INC     3,S
    BNE     @Convert     ; If <> zero, don't propagate carry, done
    INC     2,S
    BNE     @Convert     ; If <> zero, don't propagate carry, done
    INC     1,S
    BNE     @Convert     ; If <> zero, don't propagate carry, done
    INC     ,S
;
;-------------------------------
; 3) Shift left until bit 13 is set, counting each shift
;-------------------------------
@Convert:
      LDD   ,S          ; Test Word 1 (MS word)
      BEQ   @TestWord2  ; Go Test Word 2
      TSTA
      BEQ   @Do2ndByte
; We get here when the MS byte has bits
      LDB   #63
      TSTA
      BMI   >
@Loop1:
      DECB
      LSL   7,S
      ROL   6,S
      ROL   5,S
      ROL   4,S
      ROL   3,S
      ROL   2,S
      ROL   1,S
      ROLA
      BPL   @Loop1
!     STA   ,S
      LDX   ,S
      JMP   @DoneMantissa
; We get here when the 2nd MS byte has bits
@Do2ndByte:
      LDB   #63-8
      LDA   1,S
      BMI   >
@Loop2:
      DECB
      LSL   7,S
      ROL   6,S
      ROL   5,S
      ROL   4,S
      ROL   3,S
      ROL   2,S
      ROLA
      BPL   @Loop2
!     STA   1,S
      LDX   1,S
      JMP   @DoneMantissa
; We get here to check if 2nd word has bits
@TestWord2:
      LDD   2,S
      BEQ   @TestWord3  ; Test Word 3
      TSTA
      BEQ   @Do4thByte
; We get here when Word 2 has bits
      LDB   #63-16
      TSTA
      BMI   >
@Loop3:
      DECB
      LSL   7,S
      ROL   6,S
      ROL   5,S
      ROL   4,S
      ROL   3,S
      ROLA
      BPL   @Loop3
!     STA   2,S
      LDX   2,S
      BRA   @DoneMantissa
; We get here when the 2nd MS byte has bits
@Do4thByte:
      LDB   #63-16-8
      LDA   3,S
      BMI   >
@Loop4:
      DECB
      LSL   7,S
      ROL   6,S
      ROL   5,S
      ROL   4,S
      ROLA
      BPL   @Loop4
!     STA   3,S
      LDX   3,S
      BRA   @DoneMantissa
; We get here to check if 3rd word has bits
@TestWord3:
      LDD   4,S
      BEQ   @TestWord4  ; Test Word 4
      TSTA
      BEQ   @Do6thByte
; We get here when Word 3 has bits
      LDB   #63-16-16
      TSTA
      BMI   >
@Loop5:
      DECB
      LSL   7,S
      ROL   6,S
      ROL   5,S
      ROLA
      BPL   @Loop5
!     STA   4,S
      LDX   4,S
      BRA   @DoneMantissa
; We get here when the 2nd MS byte has bits
@Do6thByte:
      LDB   #63-16-16-8
      LDA   5,S
      BMI   >
@Loop6:
      DECB
      LSL   7,S
      ROL   6,S
      ROLA
      BPL   @Loop6
!     STA   5,S
      LDX   5,S
      BRA   @DoneMantissa
; We get here to get the 4th word bits
@TestWord4:
      LDD   6,S
      TSTA
      BEQ   @Do8thByte
; We get here when Word 4 has bits
      LDB   #63-16-16-16
      TSTA
      BMI   >
@Loop7:
      DECB
      LSL   7,S
      ROLA
      BPL   @Loop7
!     STA   6,S
      LDX   6,S
      BRA   @DoneMantissa
; We get here when the 2nd MS byte has bits
@Do8thByte:
      LDB   #63-16-16-16-8
      LDA   7,S
      BMI   >
@Loop8:
      DECB
      LSLA
      BPL   @Loop8
!     STB   FFP_EXPonent
      CLRB
      TFR   D,X         ;  Now has the Mantissa
      LDB   FFP_EXPonent
; B already has the exponent value
@DoneMantissa:
      ORB   FFP_SIGN    ; add sign in bit7
      LEAS  8,S         ; Fix the stack
      PSHS  B,X         ; Save the FFP value on the stack
@Return:
      JMP   >$FFFF      ; return (self modified

; Convert Unsigned 32bit integer @,S to 3 byte FFP @ ,S
U32_To_FFP:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self mod return address
    LDD     2,S
    BNE     >           ; Not zero skip ahead
    LDU     ,S         
    LBEQ    @FFP_ZERO   ; If zero then return with FFP value as zero
!   CLR     FFP_SIGN
    BRA     @Convert    ; Reuse the conversion code below
; Convert signed 32bit integer @,S to 3 byte FFP @ ,S
S32_To_FFP:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self mod return address
    LDD     ,S
    BNE     >           ; Not zero skip ahead
    LDU     2,S         
    LBEQ    @FFP_ZERO   ; If zero then return with FFP value as zero
!   CLR     FFP_SIGN          
    TSTA
    BPL     @Convert    ; Skip forward if positive
    LDA     #%10000000  ; Set the sign bit (it is negative)
    STA     FFP_SIGN    ; Set the sign into bit 7 of SIGN
; Negate value to make it positive
; Invert each byte
    COM     ,S
    COM     1,S
    COM     2,S
    COM     3,S
; + 1
; Propagate if needed
    INC     3,S
    BNE     @Convert    ; If <> zero, don't propagate carry, done
    INC     2,S
    BNE     @Convert    ; If <> zero, don't propagate carry, done
    INC     1,S
    BNE     @Convert    ; If <> zero, don't propagate carry, done
    INC     ,S
@Convert:
;
;-------------------------------
; 3) Shift left until bit 13 is set, counting each shift
;-------------------------------
      LDD   ,S          ; Look at the highest Word
      BEQ   @DoLSWord
      TSTA
      BEQ   @_Bit24
; We get here when we have bits in MSbyte
      LDB   #31
      TSTA
      BMI   >
@Loop1:
      DECB
      LSL   3,S
      ROL   2,S
      ROL   1,S
      ROLA
      BPL   @Loop1
!     STA   ,S
      LDX   ,S
      BRA   @GotEXP_B
; We get here when we have bits in 2nd highest byte
@_Bit24:
      LDB   #31-8
      LDA   1,S
      BMI   >
@Loop2:
      DECB
      LSL   3,S
      ROL   2,S
      ROLA
      BPL   @Loop2
!     STA   1,S
      LDX   1,S
      BRA   @GotEXP_B
; We get there when bits are only in the lowest Word
@DoLSWord:
      LDD   2,S
      TSTA              ; Look at the highest byte
      BNE   @_16BitUsed ; If any bits are set then use the MSByte as the first
; We get here when it's only using 8 bits 
      LDA   #15-8       ; Counter/bit position for EXP value
      TSTB
      BMI   @Got8bit    ; If bit 7 is set then we are done
@Loop3:
      DECA
      LSLB
      BPL   @Loop3
@Got8bit:
      STB   1,S         ; Save the properly formed mantissa
      CLR   2,S
      LDX   1,S
      TFR   A,B
      BRA   @GotEXP_B
@_16BitUsed:
      PSHS  A
      LDA   #15
      PSHS  A
      LDA   1,S
      BMI   @Got16bit    ; If bit 7 is set then we are done
@Loop4:
      DEC   ,S
      LSLB
      ROLA
      BPL   @Loop4
@Got16bit:
      TFR   D,X
      PULS  D
      TFR   A,B         ; Copy Exponent to B
@GotEXP_B:
      ORB   FFP_SIGN
      LEAS  4,S
      PSHS  B,X
@Return:
      JMP   >$FFFF      ; Return, self modified jump address
;
; Ouput FFP as all zeros
@FFP_ZERO:
      LEAS  1,S         ; Keep three of the four zeros
      BRA   @Return     ; Return

; Convert Unsigned 16bit integer in D to 3 Byte FFP @ ,S
U16_To_FFP:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self mod return address
      CMPD  #$0000
      BEQ   @FFP_ZERO   ; If zero then skip
      CLR   FFP_SIGN
      BRA   @Convert    ; Reuse the conversion code below
; Convert Signed 16bit integer in D to 3 Byte FFP @ ,S
S16_To_FFP:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self mod return address
      CMPD  #$0000
      BEQ   @FFP_ZERO   ; If zero then skip
      CLR   FFP_SIGN          
      TSTA
      BPL   @Convert    ; Skip forward if positive
      PSHS  A
      LDA   #%10000000  ; Move sign bit to the carry
      STA   FFP_SIGN
      PULS  A   
; Negate value to make it positive
      NEGA              ; Negate A (8-bit two's complement: -A = ~A + 1)
      NEGB              ; Negate B (8-bit two's complement: -B = ~B + 1)
      SBCA  #$00        ; Subtract 0 from A with borrow (propagate carry from NEGB)
@Convert:
      PSHS  D           ; Save D on the stack
      LEAS  -1,S        ; Make room for the Sign/Exponent byte 
;
;-------------------------------
; 3) Shift left until bit 15 is set, counting each shift
;-------------------------------
      TSTA              ; Look at the highest byte
      BNE   @_16BitUsed ; If any bits are set then use the MSByte as the first
; We get here when it's only using 8 bits 
      LDA   #15-8       ; Counter/bit position for EXP value
      TSTB
      BMI   @Got8bit    ; If bit 7 is set then we are done
@Loop1:
      DECA
      LSLB
      BPL   @Loop1
@Got8bit:
      STB   1,S         ; Save the properly formed mantissa
      CLR   2,S
      BRA   @SaveEXP
@_16BitUsed:
      LDA   #15
      PSHS  A
      LDA   2,S
      BMI   @Got16bit    ; If bit 7 is set then we are done
@Loop2:
      DEC   ,S
      LSLB
      ROLA
      BPL   @Loop2
@Got16bit:
      STD   2,S
      PULS  A
@SaveEXP:
      ORA   FFP_SIGN
      STA   ,S
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
;
; Ouput FFP as all zeros
@FFP_ZERO:
      LDX   #$0000
      PSHS  B,X         ; Save 3 zero bytes on the stack
      BRA   @Return     ; Return


;******************************************************************************
; Print 10 byte double at address in U to CoCo screen
; Output in decimal format, using scientific notation for large/small numbers
;
; Byte 0 bit 7 is the sign, the rest of the bits are zero's
; Byte 1 & 2 are the exponent, exp -1023 = normalized exponent value
; Constants
FFP_ONE           FCB   $00,$80,$00 ; 1.0
FFP_TEN           FCB   $03,$A0,$00 ; 10.0
FFP_TENPOW15      FCB   $31,$E3,$60 ; 10^15
FFP_Inv10         FCB   $7C,$CC,$CD ; 0.1

; Variables
FFP_STRBUF        EQU   _StrVar_PF01  ; String buffer for output (max 32 chars)
FFP_PrintSign        FCB   1                 ; Local Sign value
FFP_EXPonent_New    FCB   1                 ; Local Exponent value
;
; Print FFP value @,S
Print_FFP:
      PULS  D                 ; Get the return address off the stack
      STD   @Return+1         ; Self mod the return address below
; Check for special Exponent
      LDA   ,S                ; Get Sign and Exponent byte
      CLRB                    ; Clear the Sign byte
      LSLA                    ; Shift sign into the carry
      RORB                    ; Shift the carry into bit 7 of sign byte
      STB   FFP_PrintSign        ; Save the original sign value
      CMPA  #$80              ; Is it special?
      BEQ   >
; ---- NEW: any mantissa==0 is zero (catches 7C0000 and other underflow zeros) ----
      LDD   1,S               ; mantissa word
      BEQ   @PrintZeroFast    ; treat as 0 no matter what exponent was
      ASRA
      BEQ   @MaybeZero   
      BRA   @NotZero 
; We get here when it's either Infinity or Not A Number
!     LDA   #' '              ; Space before the dot
      JSR   PrintA_On_Screen
      LDA   #'.'
      JSR   PrintA_On_Screen
@FixStackExit:
      LEAS  3,S               ; Fix the stack
      JMP   @Return           ; Return
; Check if number is zero     ; Check for zero
@MaybeZero:
      LDD   1,S               ; Check Mantissa bits first for zero
      BNE   @NotZero
@PrintZeroFast:
      JSR   @FFP_PRINT_ZERO   ; If zero, print "0"
      BRA   @FixStackExit     ; Fix the stack & return
;
; Not zero print the number
; Get sign and make number positive
; A = 0 (positive) or $80 (negative)
@NotZero:
      LDA   ,S
      ANDA  #%01111111
      STA   ,S                ; Clear sign bit, make it positive
;
; Scale the Number:
; Initialize a decimal exponent FFP_EXPonent_Newto 0.
; Loop to divide by 10 while the number is ≥ 10, incrementing FFP_EXPonent_New
; Loop to multiply by 10 while the number is < 1, decrementing FFP_EXPonent_New
; This scales the number to the range [1, 10).
;
; Initialize decimal exponent
      CLR   FFP_EXPonent_New     ; Exponent = 0
;
; Scale number: while x >= 10.0, divide by 10, increment Exponent
@SCALE_GE_10:
; Push 3 bytes onto the stack
      PUSH_FFP    FFP_TEN     ; FFP Value of 10 is now @ ,S
;
      JSR   FFP_CMP_Stack     ; Compare FFP Value1 @ 3,S with Value2 @ ,S sets the 6809 flags Z, N, and C
      LEAS  3,S               ; Move the stack forward,
      BLO   @SCALE_LT_1       ; If x < 10, proceed to next check
;
; --- Divide FFP by 10, fastest way is to multiply by 0.1 --- (,S = ,S * 0.1)
      PUSH_FFP    FFP_Inv10   ; FFP Value of 0.1 (inverse of 10) is now @ ,S
;
      JSR   FFP_MUL           ; x * 0.1  -> result at ,S
      INC   FFP_EXPonent_New    ; Exponent = Exponent + 1
      BRA   @SCALE_GE_10      ; Repeat
;
; While x < 1.0, multiply by 10, decrement Exponent
@SCALE_LT_1:
; Point to FFP value of 1.0   
!     PUSH_FFP    FFP_ONE     ; FFP Value of 1.0 is now @ ,S
;
      JSR   FFP_CMP_Stack     ; Compare FFP Value1 @ 3,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
      LEAS  3,S               ; Move the stack forward, so it can be filled with the FFP value of Ten
      BHS   >                 ; If x >= 1, proceed to digit extraction
;
      PUSH_FFP    FFP_TEN     ; FFP Value of 10 is now @ ,S
;
      JSR   FFP_MUL           ; Multiply 3,S * ,S Then S=S+10 result @ ,S
      DEC   FFP_EXPonent_New    ; Exponent = Exponent - 1
      BRA   <                 ; Keep looping
;
; Multiply x by 10^15 to get integer part
!     PUSH_FFP    FFP_TENPOW15 ; FFP Value of 10^15 is now @ ,S
;
      JSR   FFP_MUL           ; Multiply 3,S * ,S Then S=S+10 result @ ,S
      JSR   FFP_TO_U64        ; Convert 3 byte FFP @ ,S to Unsigned 64-bit Integer @ ,S
      LEAU  ,S
      JSR   INT64_TO_STR      ; Convert 64-bit integer at ,U to decimal string in FFP_STRBUF, Return length in B
;
; Check notation based on FFP_EXPonent_New
      LDA   #' '
      LDB   FFP_PrintSign
      BPL   >
      LDA   #'-'              ; Print minus sign if negative
!     JSR   PrintA_On_Screen
      LDA   FFP_EXPonent_New
      CMPA  #-4               ; We can print out four decimal (0.1234) digits of accuaracy directly, otherwise use exponents
      BLT   >                 ; Print in scientific notation
      CMPA  #10               ; Are we printing more than 10 digits?
      BGT   >                 ; If it's > 10 then print in scientific notation
      BSR   @FFP_DECIMAL      ; Print the decimal number directly
      BRA   @Done1            ; Fix the stack & Return
!     BSR   @FFP_SCIENTIFIC   ; print with exponent
@Done1:
      LEAS  8,S               ; Fix the stack (64 bit integer)
@Return:
      JMP   >$FFFF            ; Return, self modified jump address
;
@FFP_SCIENTIFIC:
      LDA   FFP_STRBUF        ; First digit
      JSR   PrintA_On_Screen
      LDA   #'.'              ; Decimal point
      JSR   PrintA_On_Screen
      LDU   #FFP_STRBUF+1     ; Point to remaining digits
      LDB   #14                ; Print up to 14 more digits
@PRINT_DIGITS:
      LDA   ,U+
      BEQ   @PAD_ZERO         ; If string ends early, pad with zeros
      JSR   PrintA_On_Screen
      DECB
      BNE   @PRINT_DIGITS
      BRA   @PRINT_EXP
@PAD_ZERO:
      LDA   #'0'
      JSR   PrintA_On_Screen
      DECB
      BNE   @PAD_ZERO
;
@PRINT_EXP:
      LDA   #'E'
      JSR   PrintA_On_Screen
      LDB   FFP_EXPonent_New
      BPL   @EXP_POS
      LDA   #'-'
      JSR   PrintA_On_Screen
      LDB   FFP_EXPonent_New
      NEGB                 ; Absolute value of E
      BRA   @EXP_NUM
@EXP_POS:
      LDA   #'+'
      JSR   PrintA_On_Screen
      LDB   FFP_EXPonent_New
@EXP_NUM:
      CLRA
      JMP   PRINT_D_No_Space  ; Jump & Return
;
@FFP_DECIMAL:
      TSTA                    ; Test the FFP_EXPonent value
      BGE   @DEC_POS_EXP      ; if it's >=0 then it's a positive value no "0.000" Then the number needed 
; FFP_EXPonent_New< 0
      LDA   #'0'
      JSR   PrintA_On_Screen
      LDA   #'.'
      JSR   PrintA_On_Screen
      LDB   FFP_EXPonent_New
      CMPB  #-1
      BEQ   @NO_ZEROS   ; No extra zeros for E = -1
      NEGB              ; A = -FFP_EXPonent_New
      SUBB  #1          ; Number of leading zeros
      BLE   @NO_ZEROS
      LDA   #'0'
!     JSR   PrintA_On_Screen
      DECB
      BNE   <
@NO_ZEROS:
      LDU   #FFP_STRBUF-1
      LDB   #16     
!     DECB              ; Print up to 15 digits (16 -1)
      BEQ   >
      LDA   B,U         ; Check and skip any trailing zeros
      CMPA  #'0'
      BEQ   <
      INCB
@DIGIT_LOOP_NEG:
      LDA   ,U+
      JSR   PrintA_On_Screen
      DECB
      BNE   @DIGIT_LOOP_NEG
!     RTS
;
; FFP_EXPonent_New> 0
@DEC_POS_EXP:
      LDB   FFP_EXPonent_New
      INCB                    ; B = FFP_EXPonent_New+ 1 (digits before decimal)
      LDU   #FFP_STRBUF
@INT_PART:
      LDA   ,U+               ; Get a number to print
      JSR   PrintA_On_Screen  ; Print on screen
      DECB                    ; decb
      BNE   @INT_PART         ; Have we printed all the numbers? If not loop
      LDB   #14               ; 
      SUBB  FFP_EXPonent_New    ; B = 15 - (FFP_EXPonent_New+ 1)
      BEQ   @DEC_DONE         ; No fractional part if B = 0
; Check if the rest is zeros if so stop printing any trailing zeros
; ----- Trim trailing zeros from the right (safe) -----
; U = U + (B - 1)  -> points to last fractional digit
      DECB                      ; B = B - 1 (last index)
      BMI   @DEC_DONE         ; (shouldn’t happen; guards BEQ above)
      PSHS  B,U
      CLRA                    ; Counter for zeros after the decimal
@TrimTail:
      LDB   ,U+               ; load digit
      CMPB  #$30              ; '0' ?
      BNE   @HaveFracCount    ; stop trimming when non-zero digit
      INCA                    ; If we got a zero increment the counter
      DEC   ,S                ; decrement counter
      BPL   @TrimTail         ; Loop
      PULS  B,U               ; Restore
    ; All fractional digits were zeros → don't print decimal point
      BRA   @DEC_DONE         ; Return
@HaveFracCount:
      PULS  B,U               ; Get B & Restore U
      CMPA  #3                ; If it's >3 then don't print (FFP isn't that accurate)
      BGT   @DEC_DONE         ; Skip printing zeros as it's not accurate at this point
      INCB                    ; restore count of fractional digits
      BEQ   @DEC_DONE         ; none left? (paranoia)
      LDA   #'.'
      JSR   PrintA_On_Screen
; print exactly B digits from U
@FRAC_LOOP:
      LDA   ,U+
      JSR   PrintA_On_Screen
      DECB
      BNE   @FRAC_LOOP
@DEC_DONE:
      RTS
;
@FFP_PRINT_ZERO:
      LDA   #' '              ; Space before the zero
      JSR   PrintA_On_Screen
      LDA   #'0'
      JMP   PrintA_On_Screen  ; Print and return

; Convert 64-bit integer at ,U to decimal string in FFP_STRBUF
; Return length in B
; Main routine
INT64_TO_STR:
      LDY   #FFP_STRBUF ; Point Y to string buffer        
; Copy 64-bit integer to Big8_01
      LDD   ,U          ; Load first 16 bits
      STD   Big8_01     ; Store in Big8_01
      LDD   2,U         ; Load next 16 bits
      STD   Big8_01+2
      LDD   4,U         ; Load next 16 bits
      STD   Big8_01+4
      LDD   6,U         ; Load last 16 bits
      STD   Big8_01+6
; Check if the number is zero
      LDD   ,U
      BNE   >           ; If non-zero, proceed
      LDD   2,U
      BNE   >           ; If non-zero, proceed
      LDD   4,U
      BNE   >           ; If non-zero, proceed
      LDD   6,U
      BNE   >           ; If non-zero, proceed
; Number is zero
      LDA   #'0'        ; Load ASCII '0'
      STA   ,Y          ; Store in FFP_STRBUF
      LDB   #1          ; Length = 1
      RTS               ; Return
;
FFP_DigitCount   RMB 1
; NOT_ZERO
; Initialize digit counter
!     CLR   FFP_DigitCount ; A will hold the digit count
;
; Division loop: divide Big8_01 by 10, collect remainders
@DIV_LOOP:
      JSR   @DIV64_BY_10 ; Divide Big8_01 by 10, remainder in B
      ADDB  #'0'        ; Convert remainder to ASCII
      PSHS  B           ; Push digit onto stack
      INC   FFP_DigitCount ; Increment digit count
; Check if Big8_01 is zero
      LDU   Big8_01
      BNE   @DIV_LOOP   ; If non-zero, proceed
      LDU   Big8_01+2
      BNE   @DIV_LOOP   ; If non-zero, proceed
      LDU   Big8_01+4
      BNE   @DIV_LOOP   ; If non-zero, proceed
      LDU   Big8_01+6
      BNE   @DIV_LOOP   ; If non-zero, proceed
; Number is zero
; Pop digits from stack and store in FFP_STRBUF
!     PULS  B           ; Pop digit from stack
      STB   ,Y+         ; Store in FFP_STRBUF
      DEC   FFP_DigitCount ; Decrement counter
      BNE   <           ; Continue until all digits are popped
; Return length in B
      TFR   Y,D         ; D = Y
      SUBD  #FFP_STRBUF ; B = String buffer length used
      RTS
;
; Subroutine to divide 64-bit INT by 10
; Input: Big8_01 (64-bit number)
; Output: Big8_01 updated with quotient, remainder in B
@DIV64_BY_10:
      LDX   #Big8_01    ; Point to MSB of Big8_01
      LDD   #$0800      ; A = Counter for 8 bytes, B =0
      PSHS  D           ; ,S =  8 & 1,S = 0    
@BYTE_LOOP:
      LDA   1,S         ; Load current remainder into A
      LDB   ,X          ; Load current byte into B (D = A*256 + B)
; Loop to divide 16-bit number by 10
; U = quotient, B = remainder
      LDU   #$FFFF      ; Initialize quotient counter to -1
!     LEAU  1,U         ; Increment quotient
      SUBD  #10         ; Subtract 10 from D, Compare D with 10
      BHS   <           ; If D >= 10, Keep looping
      ADDD  #10         ; Fix value in D
      STB   1,S         ; Save remainder for next iteration
      TFR   U,D         ; D = U, B = LSB of U
      STB   ,X+         ; Store quotient back into current byte, move to next byte (towards LSB)
      DEC   ,S          ; Decrement byte counter
      BNE   @BYTE_LOOP  ; Continue until all bytes processed
      PULS  A,B,PC      ; Fix stack, A=0, B = Final Remainder & return

; ------------------------------------------------------------
; FFP_TO_DECSTR
; Input : FFP ,S..2,S
; Output: replaces it with: ,S=len, 1,S=' ' or '-', 2,S..digits
; ------------------------------------------------------------
FFP_OutBuff EQU   _StrVar_PF00  ; String buffer for output (max 32 chars)
FFP_TO_DECSTR:
      PULS  D                 ; Get the return address off the stack
      STD   @ReturnFinal+1         ; Self mod the return address below
      CLR   FFP_OutBuff       ; Start with empty buffer
      BSR   @FillOutBuff      ; Copy decimal # to ascii text @ FFP_OutBuff
; Put buffer on the stack
      LDX   #FFP_OutBuff      ; Pint at the string
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
      INC   FFP_OutBuff
      LDX   #FFP_OutBuff      ; Pint at the string
      LDB   ,X                ; Get the size of the string
      ABX                     ; Point at the end of the string
      STA   ,X
      PULS  B,X,PC
@FillOutBuff:
      PULS  D
      STD   @Return+1
; Check for special Exponent
      LDA   ,S                ; Get Sign and Exponent byte
      CLRB                    ; Clear the Sign byte
      LSLA                    ; Shift sign into the carry
      RORB                    ; Shift the carry into bit 7 of sign byte
      STB   FFP_PrintSign        ; Save the original sign value
      CMPA  #$80              ; Is it special?
      BEQ   >
; ---- NEW: any mantissa==0 is zero (catches 7C0000 and other underflow zeros) ----
      LDD   1,S               ; mantissa word
      BEQ   @PrintZeroFast    ; treat as 0 no matter what exponent was
      ASRA
      BEQ   @MaybeZero   
      BRA   @NotZero 
; We get here when it's either Infinity or Not A Number
!     LDA   #' '              ; Space before the dot
      BSR   @SaveAToBuffer
      LDA   #'.'
      BSR   @SaveAToBuffer
@FixStackExit:
      LEAS  3,S               ; Fix the stack
      JMP   @Return           ; Return
; Check if number is zero     ; Check for zero
@MaybeZero:
      LDD   1,S               ; Check Mantissa bits first for zero
      BNE   @NotZero
@PrintZeroFast:
      JSR   @FFP_PRINT_ZERO   ; If zero, print "0"
      BRA   @FixStackExit     ; Fix the stack & return
;
; Not zero print the number
; Get sign and make number positive
; A = 0 (positive) or $80 (negative)
@NotZero:
      LDA   ,S
      ANDA  #%01111111
      STA   ,S                ; Clear sign bit, make it positive
;
; Scale the Number:
; Initialize a decimal exponent FFP_EXPonent_Newto 0.
; Loop to divide by 10 while the number is ≥ 10, incrementing FFP_EXPonent_New
; Loop to multiply by 10 while the number is < 1, decrementing FFP_EXPonent_New
; This scales the number to the range [1, 10).
;
; Initialize decimal exponent
      CLR   FFP_EXPonent_New     ; Exponent = 0
;
; Scale number: while x >= 10.0, divide by 10, increment Exponent
@SCALE_GE_10:
; Push 3 bytes onto the stack
      PUSH_FFP    FFP_TEN     ; FFP Value of 10 is now @ ,S
;
      JSR   FFP_CMP_Stack     ; Compare FFP Value1 @ 3,S with Value2 @ ,S sets the 6809 flags Z, N, and C
      LEAS  3,S               ; Move the stack forward,
      BLO   @SCALE_LT_1       ; If x < 10, proceed to next check
;
; --- Divide FFP by 10, fastest way is to multiply by 0.1 --- (,S = ,S * 0.1)
      PUSH_FFP    FFP_Inv10   ; FFP Value of 0.1 (inverse of 10) is now @ ,S
;
      JSR   FFP_MUL           ; x * 0.1  -> result at ,S
      INC   FFP_EXPonent_New    ; Exponent = Exponent + 1
      BRA   @SCALE_GE_10      ; Repeat
;
; While x < 1.0, multiply by 10, decrement Exponent
@SCALE_LT_1:
; Point to FFP value of 1.0   
!     PUSH_FFP    FFP_ONE     ; FFP Value of 1.0 is now @ ,S
;
      JSR   FFP_CMP_Stack     ; Compare FFP Value1 @ 3,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
      LEAS  3,S               ; Move the stack forward, so it can be filled with the FFP value of Ten
      BHS   >                 ; If x >= 1, proceed to digit extraction
;
      PUSH_FFP    FFP_TEN     ; FFP Value of 10 is now @ ,S
;
      JSR   FFP_MUL           ; Multiply 3,S * ,S Then S=S+10 result @ ,S
      DEC   FFP_EXPonent_New    ; Exponent = Exponent - 1
      BRA   <                 ; Keep looping
;
; Multiply x by 10^15 to get integer part
!     PUSH_FFP    FFP_TENPOW15 ; FFP Value of 10^15 is now @ ,S
;
      JSR   FFP_MUL           ; Multiply 3,S * ,S Then S=S+10 result @ ,S
      JSR   FFP_TO_U64        ; Convert 3 byte FFP @ ,S to Unsigned 64-bit Integer @ ,S
      LEAU  ,S
      JSR   INT64_TO_STR      ; Convert 64-bit integer at ,U to decimal string in FFP_STRBUF, Return length in B
;
; Check notation based on FFP_EXPonent_New
      LDA   #' '
      LDB   FFP_PrintSign
      BPL   >
      LDA   #'-'              ; Print minus sign if negative
!     JSR   @SaveAToBuffer
      LDA   FFP_EXPonent_New
      CMPA  #-4               ; We can print out four decimal (0.1234) digits of accuaracy directly, otherwise use exponents
      BLT   >                 ; Print in scientific notation
      CMPA  #10               ; Are we printing more than 10 digits?
      BGT   >                 ; If it's > 10 then print in scientific notation
      BSR   @FFP_DECIMAL      ; Print the decimal number directly
      BRA   @Done1            ; Fix the stack & Return
!     BSR   @FFP_SCIENTIFIC   ; print with exponent
@Done1:
      LEAS  8,S               ; Fix the stack (64 bit integer)
@Return:
      JMP   >$FFFF            ; Return, self modified jump address
;
@FFP_SCIENTIFIC:
      LDA   FFP_STRBUF        ; First digit
      JSR   @SaveAToBuffer
      LDA   #'.'              ; Decimal point
      JSR   @SaveAToBuffer
      LDU   #FFP_STRBUF+1     ; Point to remaining digits
      LDB   #14                ; Print up to 14 more digits
@PRINT_DIGITS:
      LDA   ,U+
      BEQ   @PAD_ZERO         ; If string ends early, pad with zeros
      JSR   @SaveAToBuffer
      DECB
      BNE   @PRINT_DIGITS
      BRA   @PRINT_EXP
@PAD_ZERO:
      LDA   #'0'
      JSR   @SaveAToBuffer
      DECB
      BNE   @PAD_ZERO
;
@PRINT_EXP:
      LDA   #'E'
      JSR   @SaveAToBuffer
      LDB   FFP_EXPonent_New
      BPL   @EXP_POS
      LDA   #'-'
      JSR   @SaveAToBuffer
      LDB   FFP_EXPonent_New
      NEGB                 ; Absolute value of E
      BRA   @EXP_NUM
@EXP_POS:
      LDA   #'+'
      JSR   @SaveAToBuffer
      LDB   FFP_EXPonent_New
@EXP_NUM:
      TFR   B,A
      JMP   @SaveAToBuffer
;
@FFP_DECIMAL:
      TSTA                    ; Test the FFP_EXPonent value
      BGE   @DEC_POS_EXP      ; if it's >=0 then it's a positive value no "0.000" Then the number needed 
; FFP_EXPonent_New< 0
      LDA   #'0'
      JSR   @SaveAToBuffer
      LDA   #'.'
      JSR   @SaveAToBuffer
      LDB   FFP_EXPonent_New
      CMPB  #-1
      BEQ   @NO_ZEROS   ; No extra zeros for E = -1
      NEGB              ; A = -FFP_EXPonent_New
      SUBB  #1          ; Number of leading zeros
      BLE   @NO_ZEROS
      LDA   #'0'
!     JSR   @SaveAToBuffer
      DECB
      BNE   <
@NO_ZEROS:
      LDU   #FFP_STRBUF-1
      LDB   #16     
!     DECB              ; Print up to 15 digits (16 -1)
      BEQ   >
      LDA   B,U         ; Check and skip any trailing zeros
      CMPA  #'0'
      BEQ   <
      INCB
@DIGIT_LOOP_NEG:
      LDA   ,U+
      JSR   @SaveAToBuffer
      DECB
      BNE   @DIGIT_LOOP_NEG
!     RTS
;
; FFP_EXPonent_New> 0
@DEC_POS_EXP:
      LDB   FFP_EXPonent_New
      INCB                    ; B = FFP_EXPonent_New+ 1 (digits before decimal)
      LDU   #FFP_STRBUF
@INT_PART:
      LDA   ,U+               ; Get a number to print
      JSR   @SaveAToBuffer  ; Print on screen
      DECB                    ; decb
      BNE   @INT_PART         ; Have we printed all the numbers? If not loop
      LDB   #14               ; 
      SUBB  FFP_EXPonent_New    ; B = 15 - (FFP_EXPonent_New+ 1)
      BEQ   @DEC_DONE         ; No fractional part if B = 0
; Check if the rest is zeros if so stop printing any trailing zeros
; ----- Trim trailing zeros from the right (safe) -----
; U = U + (B - 1)  -> points to last fractional digit
      DECB                      ; B = B - 1 (last index)
      BMI   @DEC_DONE         ; (shouldn’t happen; guards BEQ above)
      PSHS  B,U
      CLRA                    ; Counter for zeros after the decimal
@TrimTail:
      LDB   ,U+               ; load digit
      CMPB  #$30              ; '0' ?
      BNE   @HaveFracCount    ; stop trimming when non-zero digit
      INCA                    ; If we got a zero increment the counter
      DEC   ,S                ; decrement counter
      BPL   @TrimTail         ; Loop
      PULS  B,U               ; Restore
    ; All fractional digits were zeros → don't print decimal point
      BRA   @DEC_DONE         ; Return
@HaveFracCount:
      PULS  B,U               ; Get B & Restore U
      CMPA  #3                ; If it's >3 then don't print (FFP isn't that accurate)
      BGT   @DEC_DONE         ; Skip printing zeros as it's not accurate at this point
      INCB                    ; restore count of fractional digits
      BEQ   @DEC_DONE         ; none left? (paranoia)
      LDA   #'.'
      JSR   @SaveAToBuffer
; print exactly B digits from U
@FRAC_LOOP:
      LDA   ,U+
      JSR   @SaveAToBuffer
      DECB
      BNE   @FRAC_LOOP
@DEC_DONE:
      RTS
;
@FFP_PRINT_ZERO:
      LDA   #' '              ; Space before the zero
      JSR   @SaveAToBuffer
      LDA   #'0'
      JMP   @SaveAToBuffer     ; Jump and return

; Compare FFP Value1 @ 3,S with Value2 @ ,S sets the 6809 flags Z, N, and C
; Sets the 6809 flags (from CMPA/CMPD) for use by branches.
FFP_CMP_Stack:
; v2=0   v1=2
; 000000 018000
; Compare sign, 8 bits (sign bit only)
      LDA   2+3,S             ; Get value1 sign/exp byte
      CMPA  #$7C
      BNE   >
      LDD   2+3+1,S
      BNE   >
      STA   2+3,S             ; Make it real zero
!     LDA   2,S               ; Value2 sign/exp byte
      CMPA  #$7C
      BNE   >
      LDX   2+1,S             ; Check for zero in the mantissa
      BNE   >
      CLR   2,S               ; make it real zero
;!     LDA   2,S               ; Value2 sign/exp byte
!      ANDA  #%10000000
      PSHS  A                 ; save sign2
;
      LDA   2+3+1,S           ; Value1 sign/exp byte (offset +1 because PSHS above)
      ANDA  #%10000000
      CMPA  ,S+               ; compare sign1 vs sign2, fix the stack
      BLO   @SetGT            ; value2 < value1
      BHI   @SetLT            ; Value2 > Value1
;
; If same sign and negative, flip comparison order for exponent/mantissa
      TSTA
      BPL   @PosCompare       ; if sign is positive, do normal compare
;
; -------------------------
; Both NEGATIVE: reverse compare for exponent/mantissa
; -------------------------
@NegCompare:
    LDA     2+1+3,S           ; Check if Value1 is zero
    BNE     @NegV1NotZero
; zero, copy exp value1 to exp value2 and compare mantissa (zero will have a mantissa of zero)
    LDA     2,S               ; Get as Value2 exp
    STA     2+3,S             ; Save Value1 exp
    BEQ     @NegCompMantissas
@NegV1NotZero:
    LDA     2+1,S             ; Check if Value2 is zero
    BNE     @NegNormalCheck
; zero, copy exp value1 to exp value2 and compare mantissa (zero will have a mantissa of zero)
    LDA     2+3,S             ; Get Value1 exp
    STA     2,S               ; save as Value2 exp
    BEQ     @NegCompMantissas
@NegNormalCheck:
      LDA   2+3,S             ; Value1 sign/exp
      LSLA
      ASRA
      ADDA  #$40
      PSHS  A                 ; save exp1'
;
      LDA   2+1,S             ; Value2 sign/exp (3,S -> +1 from PSHS => 4,S, plus +1 internal = 2+4,S)
      LSLA
      ASRA
      ADDA  #$40
      CMPA  ,S+               ; compare exp2' vs exp1'  (reversed), fix the stack
      BLO   @SetLT            ; value2 < value1
      BHI   @SetGT            ; Value2 > Value1
;
; Compare mantissas reversed: Value2 vs Value1
@NegCompMantissas:
      LDD   2+1,S             ; Value2 mantissa
      CMPD  2+4,S             ; Value1 mantissa
      BLO   @SetLT            ; value2 < value1
      BHI   @SetGT            ; Value2 > Value1
      BRA   @SetEQ            ; Value2 = Value1
; -------------------------
; POSITIVE (or both same sign and not negative): normal compare
; -------------------------
; v2=0   v1=2
; 000000 018000
@PosCompare:
    LDA     2+1,S             ; Check if Value2 is zero
    BNE     @PosV2NotZero
; zero, copy exp value1 to exp value2 and compare mantissa (zero will have a mantissa of zero)
    LDA     2+3,S             ; Get Value1 exp
    STA     2,S               ; save as Value2 exp
    BRA     @PosCompMantissas
@PosV2NotZero:
    LDA     2+1+3,S           ; Check if Value1 is zero
    BNE     @PosNormalCheck
; zero, copy exp value1 to exp value2 and compare mantissa (zero will have a mantissa of zero)
    LDA     2,S               ; Get as Value2 exp
    STA     2+3,S             ; Save Value1 exp
    BRA     @PosCompMantissas
@PosNormalCheck:
      LDA   2,S               ; Value2 sign/exp
      LSLA
      ASRA
      ADDA  #$40
      PSHS  A                 ; save exp2'
;
      LDA   2+3+1,S           ; Value1 sign/exp
      LSLA
      ASRA
      ADDA  #$40
      CMPA  ,S+               ; compare exp1' vs exp2' (normal), fix the stack
      BLO   @SetLT            ; value2 < value1
      BHI   @SetGT            ; Value2 > Value1
;
; Compare mantissas normal: Value1 vs Value2
@PosCompMantissas:
      LDD   2+4,S             ; Value1 mantissa
      CMPD  2+1,S             ; Compare Value 1 mantissa with Value2 mantissa
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

; ============================================================
; NumericString_To_FFP
;   Convert numeric ASCII string on stack to 3-byte FFP.
;
;   In (on stack):
;     ,S   = length (0..255)
;     1,S..len,S = ASCII bytes (e.g. "3.5712", "-0.005", "+12")
;
;   Out (on stack):
;     ,S..2,S = 3-byte FFP result
;     (input string bytes removed)
;
;   Supported:
;     optional leading spaces
;     optional '+' or '-'
;     digits and optional single '.'
;     stops at end of length (ignores trailing junk if present)
;
;   Clobbers: A,B,D,X,Y,U,CC
;   Calls: FFP_MUL, FFP_ADD, FFP_DIV
; ============================================================

A2F_SIGN      RMB 1        ; $80 if negative else 0
A2F_FRACCNT   RMB 1        ; number of fractional digits used (0..8)
A2F_SEENDOT   RMB 1        ; 0/1

A2F_INTFFP    RMB 3
A2F_FRACFFP   RMB 3
A2F_POWFFP    RMB 3        ; 10^n as FFP
A2F_StrSize   RMB 1     ; Length of the string value

; ---- constants you should already have (examples) ----
; FFP_ZERO:  FCB $00,$00,$00
; FFP_ONE:   ...
; FFP_TEN:   ...
; (and you can build pow10 by repeated MUL by 10)

NumericString_To_FFP:
      PULS  U                 ; return address
      STU   @RET+1
; intFFP = 0, fracFFP = 0
      LDD   #0
      STA   A2F_INTFFP
      STD   A2F_INTFFP+1
      STA   A2F_FRACFFP
      STD   A2F_FRACFFP+1
; init flags
      STA   A2F_SIGN
      STA   A2F_FRACCNT
      STA   A2F_SEENDOT
; ---- load length into B, point X to first char (on stack) ----
      LEAX  1,S               ; X = ptr to first ASCII char on stack
; ---- skip leading spaces ----
      LDB   ,S                ; B = length
@SkipSp:
      LBEQ  @FinishParse
      LDA   ,X
      CMPA  #' '
      BNE   @SignChk
      LEAX  1,X
      DECB
      BRA   @SkipSp
; ---- optional sign ----
@SignChk:
      TSTB
      LBEQ   @FinishParse
      LDA   ,X
      CMPA  #'-'
      BNE   @PlusChk
      LDA   #$80
      STA   A2F_SIGN
      LEAX  1,X
      DECB
      BRA   >
@PlusChk:
      CMPA  #'+'
      BNE   >
      LEAX  1,X
      DECB
!     LDA   ,X
      CMPA  #'&'  ; Maybe it's "&H" where we need to convert the number from hexidecimal
      BNE   @RegularNumber    ; probably a regular number
      LEAX  1,X
      DECB
      LDA   ,X
      CMPA  #'H'  ; Check for H
      LBNE  @FinishParse      ; Weird value, exit
      LEAX  1,X
      DECB
      STB   A2F_StrSize
; Convert hex number to FFP
@ParseHexLoop:
      TST   A2F_StrSize
      LBEQ  @FinishParse
      LDA   ,X
@HexDigitChk:
      CMPA  #'9'
      BLS   @TryDigit         ; <= '9' might be '0'..'9'
      CMPA  #'A'
      LBLO  @FinishParse      ; ':'..'@' not hex
      CMPA  #'F'
      LBHI  @FinishParse      ; beyond 'F' not hex
      SUBA  #'A'-10           ; 'A'->10 ... 'F'->15
      BRA   @GoodHex
@TryDigit:
      CMPA  #'0'
      LBLO  @FinishParse      ; below '0' not hex
      SUBA  #'0'              ; '0'->0 ... '9'->9
@GoodHex:
      STA   A2F_TMPDIG
      PSHS  X                 ; Save X (string pointer)
; push intFFP
      PUSH_FFP A2F_INTFFP     ; Put A2F_INTFFP on the stack
; multiply by 16
      PUSH_FFP FFP_SIXTEEN
      JSR   FFP_MUL           ; (int * 16)
; add digit (as FFP)
; We'll use a tiny FFP digit table:
; DigitFFP_Table: 10 entries of 3 bytes each (0..9)
; A currently doesn't hold digit anymore, so reload digit from ,X-?? easiest:
; Instead, preserve digit in a temp register before we clobber. Use B? We'll do:
; (Simpler: store digit in A2F_TMPDIG before calls. Add that if you want.)
; ---- SIMPLE APPROACH: use table with digit in A2F_TMPDIG ----
      LDA   A2F_TMPDIG
      LSLA                    ; A = digit*2
      ADDA  A2F_TMPDIG        ; A = digit*3
      LDU   #DigitFFP_Table
      LEAU  A,U               ; U -> digit ffp (3 bytes)
      PULU  A,X               ; Get value in the table in A & X
      PSHS  A,X               ; push digit ffp
      JSR   FFP_ADD           ; (int*16) + digit
      PULL_FFP A2F_INTFFP     ; PULL A2F_INTFFP off the stack
      PULS  X                 ; Restore X
      LEAX  1,X
      DEC   A2F_StrSize
      JMP   @ParseHexLoop
@RegularNumber:
      STB   A2F_StrSize
; ---- main parse loop ----
@Parse:
      TST   A2F_StrSize
      LBEQ  @FinishParse
      LDA   ,X
; dot?
      CMPA  #'.'
      BNE   @DigitChk
      LDA   A2F_SEENDOT
      LBNE  @StopEarly          ; second '.' => stop
      INC   A2F_SEENDOT
      LEAX  1,X
      DEC   A2F_StrSize
      BRA   @Parse
@DigitChk:
      CMPA  #'0'
      LBLO  @StopEarly
      CMPA  #'9'
      BHI   @StopEarly
      SUBA  #'0'              ; A = digit 0..9
      STA   A2F_TMPDIG
; if dot not seen -> intFFP = intFFP*10 + digit
      LDA   A2F_SEENDOT
      BNE   @FracDigit
; Deal with a normal digits (before a decimal)
      PSHS  X                 ; Save X (string pointer)
; push intFFP
      PUSH_FFP A2F_INTFFP     ; Put A2F_INTFFP on the stack
; multiply by 10
      PUSH_FFP FFP_TEN
      JSR   FFP_MUL           ; (int * 10)
; add digit (as FFP)
; We'll use a tiny FFP digit table:
; DigitFFP_Table: 10 entries of 3 bytes each (0..9)
; A currently doesn't hold digit anymore, so reload digit from ,X-?? easiest:
; Instead, preserve digit in a temp register before we clobber. Use B? We'll do:
; (Simpler: store digit in A2F_TMPDIG before calls. Add that if you want.)
; ---- SIMPLE APPROACH: use table with digit in A2F_TMPDIG ----
      LDA   A2F_TMPDIG
      LSLA                    ; A = digit*2
      ADDA  A2F_TMPDIG        ; A = digit*3
      LDU   #DigitFFP_Table
      LEAU  A,U               ; U -> digit ffp (3 bytes)
      PULU  A,X               ; Get value in the table in A & X
      PSHS  A,X               ; push digit ffp
      JSR   FFP_ADD           ; (int*10) + digit
      PULL_FFP A2F_INTFFP     ; PULL A2F_INTFFP off the stack
      BRA   @NextChar
@FracDigit:
; limit fractional digits for speed/precision
      LDA   A2F_FRACCNT
      CMPA  #8
      BHS   @NextCharConsume    ; ignore extra frac digits but still consume
      INC   A2F_FRACCNT
      PSHS  X                 ; Save X (string pointer)
; fracFFP = fracFFP*10 + digit
      PUSH_FFP A2F_FRACFFP    ; Put A2F_FRACFFP on the stack
      PUSH_FFP FFP_TEN
      JSR   FFP_MUL
; add digit from table
      LDA   A2F_TMPDIG
      LSLA                    ; A = digit*2
      ADDA  A2F_TMPDIG        ; A = digit*3
      LDU   #DigitFFP_Table
      LEAU  A,U
      PULU  A,X
      PSHS  A,X
      JSR   FFP_ADD
      PULS  A,X
      STA   A2F_FRACFFP
      STX   A2F_FRACFFP+1
;      BRA   @NextChar
@NextCharConsume:
; ignored frac digit, just move on
@NextChar:
      PULS  X                 ; Restore X
      LEAX  1,X
      DEC   A2F_StrSize
      JMP   @Parse
@StopEarly:
; stop parsing at first non-digit (but do NOT remove remaining chars yet)
@FinishParse:
; ---- drop the original string (len + bytes) from stack ----
      LDB   ,S+               ; original length
      CLRA
      LEAS  D,S               ; drop len bytes
; ---- compute result ----
; if fraccnt==0 => result = intFFP
      LDA   A2F_FRACCNT
      BEQ   @ResultIsInt
; build pow10 = 10^fraccnt in FFP by repeated multiply
; powFFP = 1
      LDA   FFP_ONE
      LDX   FFP_ONE+1
      STA   A2F_POWFFP
      STX   A2F_POWFFP+1
@PowLoop:
      LDA   A2F_POWFFP
      LDX   A2F_POWFFP+1
      PSHS  A,X
      PUSH_FFP FFP_TEN
      JSR   FFP_MUL
      PULS  A,X
      STA   A2F_POWFFP
      STX   A2F_POWFFP+1
      DEC   A2F_FRACCNT
      BNE   @PowLoop
; frac = fracFFP / powFFP
      LDA   A2F_FRACFFP
      LDX   A2F_FRACFFP+1
      PSHS  A,X
      LDA   A2F_POWFFP
      LDX   A2F_POWFFP+1
      PSHS  A,X
      JSR   FFP_DIV
      PULS  A,X
      STA   A2F_FRACFFP
      STX   A2F_FRACFFP+1
; result = int + frac
      LDA   A2F_INTFFP
      LDX   A2F_INTFFP+1
      PSHS  A,X
      LDA   A2F_FRACFFP
      LDX   A2F_FRACFFP+1
      PSHS  A,X
      JSR   FFP_ADD
      BRA   @ApplySign
@ResultIsInt:
      PUSH_FFP A2F_INTFFP     ; Put A2F_INTFFP on the stack
@ApplySign:
; if result is zero mantissa => force +0
      LDD   1,S
      BEQ   @CanonZero
      LDA   A2F_SIGN
      BEQ   @RET
      LDA   ,S
      EORA  #$80
      STA   ,S
      BRA   @RET
@CanonZero:
      CLR   ,S
      CLR   1,S
      CLR   2,S
@RET:
      JMP   >$FFFF

; --- add these small items somewhere ---
A2F_TMPDIG   RMB 1

; DigitFFP_Table: 0..9 in your 3-byte FFP format.
DigitFFP_Table:
        FCB $00,$00,$00   ; 0*
        FCB $00,$80,$00   ; 1*
        FCB $01,$80,$00   ; 2*
        FCB $01,$C0,$00   ; 3*
        FCB $02,$80,$00   ; 4*
        FCB $02,$A0,$00   ; 5*
        FCB $02,$C0,$00   ; 6*
        FCB $02,$E0,$00   ; 7*
        FCB $03,$80,$00   ; 8*
        FCB $03,$90,$00   ; 9*
        FCB $03,$A0,$00   ; 10 = $0A*  (Used for Hex conversion)
        FCB $03,$B0,$00   ; 11 = $0B*
        FCB $03,$C0,$00   ; 12 = $0C*
        FCB $03,$D0,$00   ; 13 = $0D*
        FCB $03,$E0,$00   ; 14 = $0E*
        FCB $03,$F0,$00   ; 15 = $0F*
FFP_SIXTEEN FCB   $04,$80,$00 ; 16

      INCLUDE ./Math_Fast_Floating_Point_Extra.asm