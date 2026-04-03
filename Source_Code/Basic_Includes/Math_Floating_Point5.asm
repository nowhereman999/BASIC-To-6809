; Floating Point 5 byte version
; Routines for doing FP5 math - 5 Byte Floating Point
;
; Math functions included in this library:
; FP5_SUB         ; Subtract 5,S - ,S Then S=S+5 result @ ,S
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

    opt     c
    opt     ct
    opt     cc       * show cycle count, add the counts, clear the current count

; 5 byte Fast Floating Point (FP5) format
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

;----------------------------------------------------------------------
;  MACRO: PUSH_FP5 <label>
;  Push 5-byte FP5 at <label> onto the 6809 stack
;----------------------------------------------------------------------
PUSH_FP5  MACRO  \1
      LDU   #\1         ; U -> addr+5
      PULU  B,X,Y       ; Get bytes
      PSHS  B,X,Y       ; push 5 bytes
      ENDM

;----------------------------------------------------------------------
;  MACRO: PULL_FP5 <label>
;  PULL 5-byte FP5 from the 6809 stack
;----------------------------------------------------------------------
PULL_FP5   MACRO  \1
      PULS  B,X,Y       ; pull 5 bytes off the stack
      LDU   #\1+5       ; U points to bytes +5
      PSHU  B,X,Y       ; store B,X,Y
      ENDM

; Copying 5 bytes off the stack into a Temp location
CopyStackToFP5 MACRO \1
      LEAU  ,S          ; Point U at the start of source data
      PULU  B,X,Y       ; Get the 5 bytes of data
      LDU   #\1+5       ; U points at the end of the destination location 
      PSHU  B,X,Y       ; Save the 6 bytes of data at the start of destination
      ENDM

; Put value at the end of the stack on the stack again
CopyStackOnStack MACRO
      LEAU  ,S
      PULU  B,X,Y
      PSHS  B,X,Y             ; Copy value on the stack
      ENDM

; Equates to memory in Math_Variables.asm
;
; Locally used
FP5_EXPonent1    EQU   Short1_01    ; signed exp1
FP5_EXPonent2    EQU   Short1_02    ; signed exp2
FP5_EXPonent     EQU   Short1_03    ; exp diff (unsigned)
;
FP5_SIGN1   EQU   Short1_04         ; sign1 (&H00 or &H80)
FP5_SIGN2   EQU   Short1_05         ; sign2
FP5_SIGN    EQU   Short1_06         ; result sign
FP5_Temp1   EQU   Short1_07         ; 1 byte temp storage
FP5_Temp2   EQU   Short1_08         ; 1 byte temp storage
;
FP5_MANT1   EQU   Big8_03           ; 8 bytes for extended mant1:
FP5_MANT2   EQU   Big8_04           ; 8 bytes for extended mant2
FP5_MANT    EQU   Big8_05           ; 8 bytes for the Final resulting Mantissa storage


FP5_Shift_Right32_AtU_B:
      TSTB                  ; Check if shift amount is 0
      BEQ   @rts            ; If so, done
@loop:
      LSR   ,U              ; Shift byte 0 (MSB)
      ROR   1,U             ; Shift byte 1
      ROR   2,U             ; Shift byte 2
      ROR   3,U             ; Shift byte 3 (LSB)
      DECB                  ; Decrement shift count
      BNE   @loop           ; Loop if more shifts needed
@rts:
      RTS

FP5_Shift_Right40_AtU_B:
      TSTB                  ; Check if shift amount is 0
      BEQ   @rts            ; If so, done
@loop:
      LSR   ,U              ; Shift byte 0 (MSB)
      ROR   1,U             ; Shift byte 1
      ROR   2,U             ; Shift byte 2
      ROR   3,U             ; Shift byte 3 (LSB)
      ROR   4,U             ; Shift byte 3 (LSB)
      DECB                  ; Decrement shift count
      BNE   @loop           ; Loop if more shifts needed
@rts:
      RTS

;------------------------------------------------------------
; FP5_Shift_Right64_AtU_B
; Logical right-shift 64-bit value at U by B bits (B >= 0).
; Destroys: A & B
;------------------------------------------------------------
FP5_Shift_Right64_AtU_B:
      STB   ,-S   ; Save B on the stack
      BEQ   @FP5_SR64_DONE
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
@FP5_SR64_DONE:
      PULS  B,PC

;------------------------------------------------------------
; FP5_Shift_Left64_AtU_B
; Left-shift 64-bit value at U by B bits (B >= 0).
; Destroys: A & B
;------------------------------------------------------------
FP5_Shift_Left64_AtU_B:
      STB   ,-S   ; Save B on the stack
      BEQ   @FP5_SL64_DONE
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
@FP5_SL64_DONE:
      PULS  B,PC

;******************************************************************************
; Output in decimal format, using scientific notation for large/small numbers
;
; Constants
FP5_ONE           FCB   $00,$80,$00,$00,$00 ; 1.0
FP5_TEN           FCB   $03,$A0,$00,$00,$00 ; 10.0
FP5_TENPOW15      FCB   $31,$E3,$5F,$A9,$32 ; 10^15 ≈ 1000000000098304  (error +98,304)
;FP5_TENPOW10      FCB   $24,$BA,$43,$B7,$40 ; 100000000000
FP5_Inv10         FCB   $7C,$CC,$CC,$CC,$CD ; 0.1

; Variables
FP5_STRBUF        EQU   _StrVar_PF01  ; String buffer for output (max 32 chars)
FP5_PrintSign     FCB   1                 ; Local Sign value
FP5_EXPonent_New  FCB   1                 ; Local Exponent value
;
; Print FP5 value @,S
Print_FP5:
      PULS  D                 ; Get the return address off the stack
      STD   @Return+1         ; Self mod the return address below
; Check for special Exponent
      LDA   ,S                ; Get Sign and Exponent byte
      CLRB                    ; Clear the Sign byte
      LSLA                    ; Shift sign into the carry
      RORB                    ; Shift the carry into bit 7 of sign byte
      STB   FP5_PrintSign     ; Save the original sign value
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
      LEAS  5,S               ; Fix the stack
      JMP   @Return           ; Return
; Check if number is zero     ; Check for zero
@MaybeZero:
      LDA   1,S               ; Check Mantissa bits first for zero
      BNE   @NotZero
@PrintZeroFast:
      JSR   @FP5_PRINT_ZERO   ; If zero, print "0"
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
; Initialize a decimal exponent FP5_EXPonent_Newto 0.
; Loop to divide by 10 while the number is ≥ 10, incrementing FP5_EXPonent_New
; Loop to multiply by 10 while the number is < 1, decrementing FP5_EXPonent_New
; This scales the number to the range [1, 10).
;
; Initialize decimal exponent
      CLR   FP5_EXPonent_New     ; Exponent = 0
;
; Scale number: while x >= 10.0, divide by 10, increment Exponent
@SCALE_GE_10:
; Push 5 bytes onto the stack
      PUSH_FP5    FP5_TEN     ; FP5 Value of 10 is now @ ,S
;
      JSR   FP5_CMP_Stack     ; Compare FP5 Value1 @ 5,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
      LEAS  5,S               ; Move the stack forward,
      BLO   @SCALE_LT_1       ; If x < 10, proceed to next check
;
; --- Divide FP5 by 10, fastest way is to multiply by 0.1 --- (,S = ,S * 0.1)
      PUSH_FP5    FP5_Inv10   ; FP5 Value of 0.1 (inverse of 10) is now @ ,S
;
      JSR   FP5_MUL           ; Multiply 5,S * ,S Then S=S+5 result @ ,S
      INC   FP5_EXPonent_New  ; Exponent = Exponent + 1
      BRA   @SCALE_GE_10      ; Repeat
;
; While x < 1.0, multiply by 10, decrement Exponent
@SCALE_LT_1:
; Point to FP5 value of 1.0   
!     PUSH_FP5    FP5_ONE     ; FP5 Value of 1.0 is now @ ,S
;
HERE:
      JSR   FP5_CMP_Stack     ; Compare FP5 Value1 @ 5,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
      LEAS  5,S               ; Move the stack forward, so it can be filled with the FP5 value of Ten
      BHS   >                 ; If x >= 1, proceed to digit extraction
;
      PUSH_FP5    FP5_TEN     ; FP5 Value of 10 is now @ ,S
;
      JSR   FP5_MUL           ; Multiply 5,S * ,S Then S=S+5 result @ ,S
      DEC   FP5_EXPonent_New  ; Exponent = Exponent - 1
      BRA   <                 ; Keep looping
;
; Multiply x by 10^15 to get integer part
!     PUSH_FP5    FP5_TENPOW15 ; FP5 Value of 10^15 is now @ ,S
;
      JSR   FP5_MUL           ; Multiply 5,S * ,S Then S=S+5 result @ ,S
      JSR   FP5_TO_U64        ; Convert 5 byte FP5 @ ,S to Unsigned 64-bit Integer @ ,S
      LEAU  ,S
      JSR   INT64_TO_STR      ; Convert 64-bit integer at ,U to decimal string in FP5_STRBUF, Return length in B
;
; Check notation based on FP5_EXPonent_New
      LDA   #' '
      LDB   FP5_PrintSign
      BPL   >
      LDA   #'-'              ; Print minus sign if negative
!     JSR   PrintA_On_Screen
      LDA   FP5_EXPonent_New
      CMPA  #-6               ; We can print out six decimal (0.123456) digits of accuaracy directly, otherwise use exponents
      BLT   >                 ; Print in scientific notation
      CMPA  #10               ; Are we printing more than 10 digits?
      BGT   >                 ; If it's > 10 then print in scientific notation
      BSR   @FP5_DECIMAL      ; Print the decimal number directly
      BRA   @Done1            ; Fix the stack & Return
!     BSR   @FP5_SCIENTIFIC   ; print with exponent
@Done1:
      LEAS  8,S               ; Fix the stack (64 bit integer)
@Return:
      JMP   >$FFFF            ; Return, self modified jump address
;
@FP5_SCIENTIFIC:
      LDA   FP5_STRBUF        ; First digit
      JSR   PrintA_On_Screen
      LDA   #'.'              ; Decimal point
      JSR   PrintA_On_Screen
      LDU   #FP5_STRBUF+1     ; Point to remaining digits
      LDB   #8                ; Print up to 8 more digits
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
      LDB   FP5_EXPonent_New
      BPL   @EXP_POS
      LDA   #'-'
      JSR   PrintA_On_Screen
      LDB   FP5_EXPonent_New
      NEGB                 ; Absolute value of E
      BRA   @EXP_NUM
@EXP_POS:
      LDA   #'+'
      JSR   PrintA_On_Screen
      LDB   FP5_EXPonent_New
@EXP_NUM:
      CLRA
      JMP   PRINT_D_No_Space  ; Jump & Return
;
@FP5_DECIMAL:
      TSTA                    ; Test the FP5_EXPonent value
      BGE   @DEC_POS_EXP      ; if it's >=0 then it's a positive value no "0.000" Then the number needed 
; FP5_EXPonent_New < 0
      LDA   #'0'
      JSR   PrintA_On_Screen
      LDA   #'.'
      JSR   PrintA_On_Screen
      LDB   FP5_EXPonent_New
      CMPB  #-1
      BEQ   @NO_ZEROS   ; No extra zeros for E = -1
      NEGB              ; A = -FP5_EXPonent_New
      SUBB  #1          ; Number of leading zeros
      BLE   @NO_ZEROS
      LDA   #'0'
!     JSR   PrintA_On_Screen
      DECB
      BNE   <
@NO_ZEROS:
      LDU   #FP5_STRBUF-1
      LDB   #8
!     DECB              ; Print up to 7 digits (8 -1)
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
; FP5_EXPonent_New > 0
@DEC_POS_EXP:
      LDB   FP5_EXPonent_New
      INCB                    ; B = FP5_EXPonent_New+ 1 (digits before decimal)
      LDU   #FP5_STRBUF
@INT_PART:
      LDA   ,U+               ; Get a number to print
      JSR   PrintA_On_Screen  ; Print on screen
      DECB                    ; decb
      BNE   @INT_PART         ; Have we printed all the numbers? If not loop
      LDB   #7                ; 
      SUBB  FP5_EXPonent_New  ; B = 8 - (FP5_EXPonent_New+ 1)
      BEQ   @DEC_DONE         ; No fractional part if B = 0
; Check if the rest is zeros if so stop printing any trailing zeros
; ----- Trim trailing zeros from the right (safe) -----
; U = U + (B - 1)  -> points to last fractional digit
      DECB                      ; B = B - 1 (last index)
      BMI   @DEC_DONE         ; (shouldn’t happen; guards BEQ above)
      PSHS  B,U               ; Save B = count, U = string pointer
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
      CMPA  #8                ; If it's >8 then don't print (FP5 isn't that accurate)
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
@FP5_PRINT_ZERO:
      LDA   #' '              ; Space before the zero
      JSR   PrintA_On_Screen
      LDA   #'0'
      JMP   PrintA_On_Screen  ; Print and return





; Convert 64-bit integer at ,U to decimal string in FP5_STRBUF
; Return length in B
; Main routine
INT64_TO_STR:
      LDY   #FP5_STRBUF ; Point Y to string buffer        
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
      STA   ,Y          ; Store in FP5_STRBUF
      LDB   #1          ; Length = 1
      RTS               ; Return
;
FP5_DigitCount   RMB 1
; NOT_ZERO
; Initialize digit counter
!     CLR   FP5_DigitCount ; A will hold the digit count
;
; Division loop: divide Big8_01 by 10, collect remainders
@DIV_LOOP:
      JSR   @DIV64_BY_10 ; Divide Big8_01 by 10, remainder in B
      ADDB  #'0'        ; Convert remainder to ASCII
      PSHS  B           ; Push digit onto stack
      INC   FP5_DigitCount ; Increment digit count
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
; Pop digits from stack and store in FP5_STRBUF
!     PULS  B           ; Pop digit from stack
      STB   ,Y+         ; Store in FP5_STRBUF
      DEC   FP5_DigitCount ; Decrement counter
      BNE   <           ; Continue until all digits are popped
; Return length in B
      TFR   Y,D         ; D = Y
      SUBD  #FP5_STRBUF ; B = String buffer length used
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
; FP5_TO_DECSTR
; Input : FP5 ,S..4,S
; Output: replaces it with: ,S=len, 1,S=' ' or '-', 2,S..digits
; ------------------------------------------------------------
FP5_OutBuff EQU   _StrVar_PF00  ; String buffer for output (max 32 chars)
FP5_TO_DECSTR:
      PULS  D                 ; Get the return address off the stack
      STD   @ReturnFinal+1    ; Self mod the return address below
      CLR   FP5_OutBuff       ; Start with empty buffer
      BSR   @FillOutBuff      ; Copy decimal # to ascii text @ FP5_OutBuff
; Put buffer on the stack
      LDX   #FP5_OutBuff      ; Pint at the string
      LDB   ,X+               ; Get the size of the string
      ABX                     ; Point at the end of the string
!     LDA   ,-X               ; X=X-1, get A @ X
      PSHS  A                 ; Put it on the stack
      DECB                    ; dec the counter
      BPL   <                 ; loop
@ReturnFinal:
      JMP   >$FFFF           ; Return
@SaveAToBuffer:
      PSHS  B,X
      INC   FP5_OutBuff
      LDX   #FP5_OutBuff      ; Pint at the string
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
      STB   FP5_PrintSign     ; Save the original sign value
      CMPA  #$80              ; Is it special?
      BEQ   >
; ---- NEW: any mantissa==0 is zero (catches 7C0000 and other underflow zeros) ----
      LDA   1,S               ; mantissa MS byte
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
      LEAS  5,S               ; Fix the stack
      JMP   @Return           ; Return
; Check if number is zero     ; Check for zero
@MaybeZero:
      LDA   1,S               ; Check Mantissa bits first for zero
      BNE   @NotZero
@PrintZeroFast:
      JSR   @FP5_PRINT_ZERO   ; If zero, print "0"
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
; Initialize a decimal exponent FP5_EXPonent_Newto 0.
; Loop to divide by 10 while the number is ≥ 10, incrementing FP5_EXPonent_New
; Loop to multiply by 10 while the number is < 1, decrementing FP5_EXPonent_New
; This scales the number to the range [1, 10).
;
; Initialize decimal exponent
      CLR   FP5_EXPonent_New     ; Exponent = 0
;
; Scale number: while x >= 10.0, divide by 10, increment Exponent
@SCALE_GE_10:
; Push 5 bytes onto the stack
      PUSH_FP5    FP5_TEN     ; FP5 Value of 10 is now @ ,S
;
      JSR   FP5_CMP_Stack     ; Compare FP5 Value1 @ 5,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
      LEAS  5,S               ; Move the stack forward,
      BLO   @SCALE_LT_1       ; If x < 10, proceed to next check
;
; --- Divide FP5 by 10, fastest way is to multiply by 0.1 --- (,S = ,S * 0.1)
      PUSH_FP5    FP5_Inv10   ; FP5 Value of 0.1 (inverse of 10) is now @ ,S
;
      JSR   FP5_MUL           ; Multiply 5,S * ,S Then S=S+5 result @ ,S
      INC   FP5_EXPonent_New  ; Exponent = Exponent + 1
      BRA   @SCALE_GE_10      ; Repeat
;
; While x < 1.0, multiply by 10, decrement Exponent
@SCALE_LT_1:
; Point to FP5 value of 1.0   
!     PUSH_FP5    FP5_ONE     ; FP5 Value of 1.0 is now @ ,S
;
      JSR   FP5_CMP_Stack     ; Compare FP5 Value1 @ 5,S with Value 2 @ ,S sets the 6809 flags Z, N, and C
      LEAS  5,S               ; Move the stack forward, so it can be filled with the FP5 value of Ten
      BHS   >                 ; If x >= 1, proceed to digit extraction
;
      PUSH_FP5    FP5_TEN     ; FP5 Value of 10 is now @ ,S
;
      JSR   FP5_MUL           ; Multiply 5,S * ,S Then S=S+5 result @ ,S
      DEC   FP5_EXPonent_New  ; Exponent = Exponent - 1
      BRA   <                 ; Keep looping
;
; Multiply x by 10^15 to get integer part
!     PUSH_FP5    FP5_TENPOW15 ; FP5 Value of 10^15 is now @ ,S
;
      JSR   FP5_MUL           ; Multiply 5,S * ,S Then S=S+5 result @ ,S
      JSR   FP5_TO_U64        ; Convert 5 byte FP5 @ ,S to Unsigned 64-bit Integer @ ,S
      LEAU  ,S
      JSR   INT64_TO_STR      ; Convert 64-bit integer at ,U to decimal string in FP5_STRBUF, Return length in B
;
; Check notation based on FP5_EXPonent_New
      LDA   #' '
      LDB   FP5_PrintSign
      BPL   >
      LDA   #'-'              ; Print minus sign if negative
!     JSR   @SaveAToBuffer
      LDA   FP5_EXPonent_New
      CMPA  #-6               ; We can print out six decimal (0.123456) digits of accuaracy directly, otherwise use exponents
      BLT   >                 ; Print in scientific notation
      CMPA  #10               ; Are we printing more than 10 digits?
      BGT   >                 ; If it's > 10 then print in scientific notation
      BSR   @FP5_DECIMAL      ; Print the decimal number directly
      BRA   @Done1            ; Fix the stack & Return
!     BSR   @FP5_SCIENTIFIC   ; print with exponent
@Done1:
      LEAS  8,S               ; Fix the stack (64 bit integer)
@Return:
      JMP   >$FFFF            ; Return, self modified jump address
;
@FP5_SCIENTIFIC:
      LDA   FP5_STRBUF        ; First digit
      JSR   @SaveAToBuffer
      LDA   #'.'              ; Decimal point
      JSR   @SaveAToBuffer
      LDU   #FP5_STRBUF+1     ; Point to remaining digits
      LDB   #14               ; Print up to 14 more digits
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
      LDB   FP5_EXPonent_New
      BPL   @EXP_POS
      LDA   #'-'
      JSR   @SaveAToBuffer
      LDB   FP5_EXPonent_New
      NEGB                 ; Absolute value of E
      BRA   @EXP_NUM
@EXP_POS:
      LDA   #'+'
      JSR   @SaveAToBuffer
      LDB   FP5_EXPonent_New
@EXP_NUM:
      TFR   B,A
      JMP   @SaveAToBuffer
;
@FP5_DECIMAL:
      TSTA                    ; Test the FP5_EXPonent value
      BGE   @DEC_POS_EXP      ; if it's >=0 then it's a positive value no "0.000" Then the number needed 
; FP5_EXPonent_New< 0
      LDA   #'0'
      JSR   @SaveAToBuffer
      LDA   #'.'
      JSR   @SaveAToBuffer
      LDB   FP5_EXPonent_New
      CMPB  #-1
      BEQ   @NO_ZEROS   ; No extra zeros for E = -1
      NEGB              ; A = -FP5_EXPonent_New
      SUBB  #1          ; Number of leading zeros
      BLE   @NO_ZEROS
      LDA   #'0'
!     JSR   @SaveAToBuffer
      DECB
      BNE   <
@NO_ZEROS:
      LDU   #FP5_STRBUF-1
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
; FP5_EXPonent_New > 0
@DEC_POS_EXP:
      LDB   FP5_EXPonent_New
      INCB                    ; B = FP5_EXPonent_New+ 1 (digits before decimal)
      LDU   #FP5_STRBUF
@INT_PART:
      LDA   ,U+               ; Get a number to print
      JSR   @SaveAToBuffer    ; Print on screen
      DECB                    ; decb
      BNE   @INT_PART         ; Have we printed all the numbers? If not loop
      LDB   #14               ; 
      SUBB  FP5_EXPonent_New  ; B = 15 - (FP5_EXPonent_New+ 1)
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
      CMPA  #8                ; If it's >8 then don't print (FP5 isn't that accurate)
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
@FP5_PRINT_ZERO:
      LDA   #' '              ; Space before the zero
      JSR   @SaveAToBuffer
      LDA   #'0'
      JMP   @SaveAToBuffer     ; Jump and return

; ============================================================
; NumericString_To_FP5
;   Convert numeric ASCII string on stack to 5-byte FP5.
;
;   In (on stack):
;     ,S   = length (0..255)
;     1,S..len,S = ASCII bytes (e.g. "3.5712", "-0.005", "+12")
;
;   Out (on stack):
;     ,S..4,S = 5-byte FP5 result
;     (input string bytes removed)
;
;   Supported:
;     optional leading spaces
;     optional '+' or '-'
;     digits and optional single '.'
;     stops at end of length (ignores trailing junk if present)
;
;   Clobbers: A,B,D,X,Y,U,CC
;   Calls: FP5_MUL, FP5_ADD, FP5_DIV
; ============================================================

A2F_SIGN      RMB 1        ; $80 if negative else 0
A2F_FRACCNT   RMB 1        ; number of fractional digits used (0..8)
A2F_SEENDOT   RMB 1        ; 0/1

A2F_INTFP5    RMB 5
A2F_FRACFP5   RMB 5
A2F_POWFP5    RMB 5        ; 10^n as FP5
A2F_StrSize   RMB 1        ; Length of the string value

; ---- constants you should already have (examples) ----
; FP5_ZERO:  FCB $00,$00,$00
; FP5_ONE:   ...
; FP5_TEN:   ...
; (and you can build pow10 by repeated MUL by 10)

NumericString_To_FP5:
      PULS  U                 ; return address
      STU   @RET+1
; intFP5 = 0, fracFP5 = 0
      LDD   #0
      STA   A2F_INTFP5
      STD   A2F_INTFP5+1
      STD   A2F_INTFP5+3
      STA   A2F_FRACFP5
      STD   A2F_FRACFP5+1
      STD   A2F_FRACFP5+3
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
; Convert hex number to FP5
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
; push intFP5
      PUSH_FP5 A2F_INTFP5     ; Put A2F_INTFP5 on the stack
; multiply by 16
      PUSH_FP5 FP5_SIXTEEN
      JSR   FP5_MUL           ; (int * 16)
; add digit (as FP5)
; We'll use a tiny FP5 digit table:
; DigitFP5_Table: 10 entries of 3 bytes each (0..9)
; ---- SIMPLE APPROACH: use table with digit in A2F_TMPDIG ----
      LDA   A2F_TMPDIG
      LSLA                    ; A = digit*2
      ADDA  A2F_TMPDIG        ; A = digit*3
      LDU   #DigitFP5_Table
      LEAU  A,U               ; U -> digit FP5 (5 bytes)
      PULU  A,X               ; Get value in the table in A & X
      LDU   #$0000            ; Mantissa LSWord always zero
      PSHS  A,X,U             ; push digits FP5
      JSR   FP5_ADD           ; (int*16) + digit
      PULL_FP5 A2F_INTFP5     ; PULL A2F_INTFP5 off the stack
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
      LBHI  @StopEarly
      SUBA  #'0'              ; A = digit 0..9
      STA   A2F_TMPDIG
; if dot not seen -> intFP5 = intFP5*10 + digit
      LDA   A2F_SEENDOT
      BNE   @FracDigit
; Deal with a normal digits (before a decimal)
      PSHS  X                 ; Save X (string pointer)
; push intFP5
      PUSH_FP5 A2F_INTFP5     ; Put A2F_INTFP5 on the stack
; multiply by 10
      PUSH_FP5 FP5_TEN
      JSR   FP5_MUL           ; (int * 10)
; add digit (as FP5)
; We'll use a tiny FP5 digit table:
; DigitFP5_Table: 10 entries of 3 bytes each (0..9)
; ---- SIMPLE APPROACH: use table with digit in A2F_TMPDIG ----
      LDA   A2F_TMPDIG
      LSLA                    ; A = digit*2
      ADDA  A2F_TMPDIG        ; A = digit*3
      LDU   #DigitFP5_Table
      LEAU  A,U               ; U -> digit FP5 (5 bytes)
      PULU  A,X               ; Get value in the table in A & X
      LDU   #$0000            ; Mantissa LSWord always zero
      PSHS  A,X,U             ; push digits FP5
      JSR   FP5_ADD           ; (int*10) + digit
      PULL_FP5 A2F_INTFP5     ; PULL A2F_INTFP5 off the stack
      BRA   @NextChar
@FracDigit:
; limit fractional digits for speed/precision
      LDA   A2F_FRACCNT
      CMPA  #8
      BHS   @NextCharConsume    ; ignore extra frac digits but still consume
      INC   A2F_FRACCNT
      PSHS  X                 ; Save X (string pointer)
; fracFP5 = fracFP5*10 + digit
      PUSH_FP5 A2F_FRACFP5    ; Put A2F_FRACFP5 on the stack
      PUSH_FP5 FP5_TEN
      JSR   FP5_MUL
; add digit from table
      LDA   A2F_TMPDIG
      LSLA                    ; A = digit*2
      ADDA  A2F_TMPDIG        ; A = digit*3
      LDU   #DigitFP5_Table
      LEAU  A,U
      PULU  A,X
      LDU   #$0000            ; Mantissa LSWord always zero
      PSHS  A,X,U             ; push digits FP5
      JSR   FP5_ADD
      PULL_FP5 A2F_FRACFP5     ; PULL A2F_FRACFP5 off the stack
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
; if fraccnt==0 => result = intFP5
      LDA   A2F_FRACCNT
      BEQ   @ResultIsInt
; build pow10 = 10^fraccnt in FP5 by repeated multiply
; powFP5 = 1
      LDA   FP5_ONE
      LDX   FP5_ONE+1
      LDU   FP5_ONE+3
      STA   A2F_POWFP5
      STX   A2F_POWFP5+1
      STU   A2F_POWFP5+3
@PowLoop:
      LDA   A2F_POWFP5
      LDX   A2F_POWFP5+1
      LDU   A2F_POWFP5+3
      PSHS  A,X,U
      PUSH_FP5 FP5_TEN        ; Put FP5_TEN on the stack
      JSR   FP5_MUL
      PULL_FP5 A2F_POWFP5     ; PULL A2F_POWFP5 off the stack      
      DEC   A2F_FRACCNT
      BNE   @PowLoop
; frac = fracFP5 / powFP5
      PUSH_FP5 A2F_FRACFP5    ; Put A2F_FRACFP5 on the stack
      PUSH_FP5 A2F_POWFP5     ; Put A2F_POWFP5 on the stack
      JSR   FP5_DIV
      PULL_FP5 A2F_FRACFP5    ; PULL A2F_FRACFP5 off the stack 
; result = int + frac
      PUSH_FP5 A2F_INTFP5     ; Put A2F_INTFP5 on the stack
      PUSH_FP5 A2F_FRACFP5    ; Put A2F_FRACFP5 on the stack
      JSR   FP5_ADD
      BRA   @ApplySign
@ResultIsInt:
      PUSH_FP5 A2F_INTFP5     ; Put A2F_INTFP5 on the stack
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

; DigitFP5_Table: 0..9, First 3 bytes of the 5-byte FP5 format, the LSWord is always $0000
DigitFP5_Table:
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
FP5_SIXTEEN FCB   $04,$80,$00 ; 16


      

; Helper routines:
; RandomFP5_Zero: Generate a random number in the range of > 0 and < 1
; output: Random FP5 value >0 <1 at ,S (5 bytes, but only MSWord is random)
; clobbers: B,Y
RandomFP5_Zero:
      PULS    U               ; return address
      STU   @Return+1
      CLR   ,-S
      CLR   ,-S               ; Clear the LSWord
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

; RandomFP5: Gets a random number where random # is 1 to X where X is the FP5 value on the stack
; output: randon FP5 number at ,S (5 bytes)
; clobbers: all
RandomFP5:
      PULS  D                 ; Get the return address off the stack
      STD   @Return+1
      BSR   RandomFP5_Zero    ; Get a FP5 Random number on the stack (>0 and <1)
      JSR   FP5_MUL           ; Multiply 5,S * ,S Then S=S+5 result @ ,S
      CLRB
      LDX   #$8000            ; +1.0
      LDU   #$0000
      PSHS  B,X,U             ; Push FP5 value of 1.0 on the stack
      JSR   FP5_ADD   	      ; Add 5,S + ,S Then S=S+5 result @ ,S
@Return:
      JMP   >$FFFF            ; Return

; Compare FP5 Value1 @ 5,S with Value2 @ ,S sets the 6809 flags Z, N, and C
; Sets the 6809 flags (from CMPA/CMPD) for use by branches.
FP5_CMP_Stack:
; v2=0   v1=2
; 000000 018000
; Compare sign, 8 bits (sign bit only)
      LDA   2+5,S             ; Get value1 sign/exp byte
      CMPA  #$7C
      BNE   >
      LDD   2+5+1,S           ; Get value1 mantissa MSWord
      BNE   >
      STA   2+5,S             ; Make it real zero
!     LDA   2,S               ; Value2 sign/exp byte
      CMPA  #$7C
      BNE   >
      LDX   2+1,S             ; Check for zero in the mantissa
      BNE   >
      CLR   2,S               ; make it real zero
!     ANDA  #%10000000
      PSHS  A                 ; save sign2
;
      LDA   2+5+1,S           ; Value1 sign/exp byte (offset +1 because PSHS above)
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
      LDA   2+6,S             ; Check if Value1 is zero
      BNE   @NegV1NotZero     ; Skip ahead if <> 0
; Value2 is zero, check Value 1
      LDA   2+1,S             ; Check if Value2 is also zero
      BEQ   @SetEQ            ; If both are zero, then return as Equal        ; 
      BRA   @SetLT            ; value1 < value2
@NegV1NotZero:
      LDA   2+1,S             ; Check if Value2 is zero
      BEQ   @SetLT            ; if value2 is zero, we already know value1 is negative and not zero so value1 < value2
@NegNormalCheck:
      LDA   2+5,S             ; Value1 sign/exp
      LSLA
      ASRA
      PSHS  A                 ; save signed exponent1'
;
      LDA   2+1,S             ; Value2 sign/exp (3,S -> +1 from PSHS => 4,S, plus +1 internal = 2+4,S)
      LSLA
      ASRA
      CMPA  ,S+               ; compare signed exp2' vs signed exp1'  (reversed), fix the stack
      BLT   @SetLT            ; value2 < value1
      BGT   @SetGT            ; Value2 > Value1
;
; Compare mantissas reversed: Value2 vs Value1
@NegCompMantissas:
      LDD   2+1,S             ; Value2 mantissa
      CMPD  2+6,S             ; Value1 mantissa
      BLO   @SetLT            ; value2 < value1
      BHI   @SetGT            ; Value2 > Value1
      LDD   2+3,S             ; Value2 mantissa
      CMPD  2+8,S             ; Value1 mantissa
      BLO   @SetLT            ; value2 < value1
      BHI   @SetGT            ; Value2 > Value1
      BRA   @SetEQ            ; Value2 = Value1
; -------------------------
; Both values are POSITIVE: normal compare
; -------------------------
; v2=0   v1=2
; 000000 018000
@PosCompare:
      LDA   2+1,S             ; Check if Value2 is zero
      BNE   @PosV2NotZero     ; Skip ahead if <> 0
; Value2 is zero, check Value 1
      LDA   2+6,S             ; Check if Value1 is also zero
      BEQ   @SetEQ            ; If both are zero, then return as Equal        ; 
      BRA   @SetGT            ; Value1 > Value2
@PosV2NotZero:
      LDA   2+6,S             ; Check if Value1 is zero
      BEQ   @SetLT            ; if value 1 is zero, we already know value2 is positive and not zero so value1 < value2
@PosNormalCheck:
      LDA   2,S               ; Value2 sign/exp
      LSLA
      ASRA
      PSHS  A                 ; save signed exponent2'
;
      LDA   2+5+1,S             ; Value1 sign/exp
      LSLA
      ASRA
      CMPA  ,S+               ; compare signed exp1' vs signed exp2' (normal), fix the stack
      BLT   @SetLT            ; value2 < value1
      BGT   @SetGT            ; Value2 > Value1
;
; Compare mantissas normal: Value1 vs Value2
@PosCompMantissas:
      LDD   2+6,S             ; Value1 mantissa
      CMPD  2+1,S             ; Compare Value 1 mantissa with Value2 mantissa
      BLO   @SetLT            ; value1 < value2
      BHI   @SetGT            ; Value1 > Value2
; Check LSWord of Mantissa
      LDD   2+8,S             ; Value1 mantissa
      CMPD  2+3,S             ; Compare Value 1 mantissa with Value2 mantissa
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

;-----------------------------------------------------------
; U64_To_FP5
; Convert unsigned 64-bit integer (two's complement) at ,S into 5-byte FP5 at ,S.
U64_To_FP5:
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
      LEAS  3,S   ; Keep 5 zero bytes and return (5 zero bytes = 0 for FP5 format)
      JMP   @Return
;-------------------------------
; 1) Sign is always positive
;-------------------------------
!     CLR   FP5_SIGN          ; unsigned → sign = + (0)
      BRA   @Convert
;
;-----------------------------------------------------------
; S64_To_FP5
; Convert signed 64-bit integer (two's complement) at ,S into 5-byte FP5 at ,S.
S64_To_FP5:
      PULS    D           ; Get return address off the stack
      STD     @Return+1   ; Self modify the return location below
; CheckZero:
      LDD   6,S
      BNE   Int64_FP5_NonZero
      LDD   4,S
      BNE   Int64_FP5_NonZero
      LDD   2,S
      BNE   Int64_FP5_NonZero
      LDD   ,S
      BNE   Int64_FP5_NonZero
; value is exactly 0  
      LEAS  3,S   ; Keep 5 zero bytes and return (5 zero bytes = 0 for FP5 format)
      JMP   @Return
;
Int64_FP5_NonZero:
;-------------------------------
; 1) Extract sign and copy to scratch
;-------------------------------
      LDA   ,S            ; MSB of 64-bit integer
      ANDA  #$80          ; isolate sign bit
      STA   FP5_SIGN      ; 0 or $80
;
;-------------------------------
; 2) If negative, take two's complement to get magnitude
;-------------------------------
      BEQ   @Convert   ; positive → already magnitude
;
; negate 64-bit value at FP5_MANT1..+7: mag = -mag
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
; 3) Shift left until bit MSbit is set, counting each shift
;-------------------------------
@Convert:
      CLR   ,-S         ; clear the shift counter on the stack
      LDD   1,S         ; Get the highest Word
      BMI   @Done
!     INC   ,S
      LSL   8,S
      ROL   7,S
      ROL   6,S
      ROL   5,S
      ROL   4,S
      ROL   3,S
      ROLB
      ROLA
      BPL   <
@Done:
      STD   5,S         ; Save mantissa MS Word
      LDD   3,S
      STD   7,S         ; Save mantissa LS Word
      LDB   #63
      SUBB  ,S          ; Subtract the # of shifts
      ORB   FP5_SIGN    ; Get the sign bit
      LEAS  4,S         ; Fix stack
      STB   ,S          ; Save sign and exponent
@Return:
      JMP   >$FFFF          ; Return, self modified jump address

; Convert Unsigned 32bit integer @,S to 5 byte FP5 @ ,S
U32_To_FP5:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self mod return address
    LDD     2,S
    BNE     >           ; Not zero skip ahead
    LDU     ,S         
    LBEQ    @FP5_ZERO   ; If zero then return with FP5 value as zero
!   CLR     FP5_SIGN
    BRA     @Convert    ; Reuse the conversion code below
; Convert signed 32bit integer @,S to 5 byte FP5 @ ,S
S32_To_FP5:
    PULS    U           ; Get return address
    STU     @Return+1   ; Self mod return address
    LDD     ,S
    BNE     >           ; Not zero skip ahead
    LDU     2,S         
    LBEQ    @FP5_ZERO   ; If zero then return with FP5 value as zero
!   CLR     FP5_SIGN          
    TSTA
    BPL     @Convert    ; Skip forward if positive
    LDA     #%10000000  ; Set the sign bit (it is negative)
    STA     FP5_SIGN    ; Set the sign into bit 7 of SIGN
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
      CLR   ,-S         ; Make room for the Sign and exponent and clear the count
      LDD   1,S         ; Get the highest Word
      BMI   @Done
!     INC   ,S
      LSL   4,S
      ROL   3,S
      ROLB
      ROLA
      BPL   <
@Done:
      STD   1,S
      LDB   #31
      SUBB  ,S
      ORB   FP5_SIGN
      STB   ,S
@Return:
      JMP   >$FFFF          ; Return, self modified jump address
;
; Ouput FP5 as all zeros
@FP5_ZERO:
      CLR   ,-S         ; Keep 5 zeros
      BRA   @Return     ; Return

; Convert Unsigned 16bit integer in D to 5 Byte FP5 @ ,S
U16_To_FP5:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self mod return address
      CMPD  #$0000
      BEQ   @FP5_ZERO   ; If zero then skip
      CLR   FP5_SIGN
      BRA   @Convert    ; Reuse the conversion code below
; Convert Signed 16bit integer in D to 5 Byte FP5 @ ,S
S16_To_FP5:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self mod return address
      CMPD  #$0000
      BEQ   @FP5_ZERO   ; If zero then skip
      CLR   FP5_SIGN          
      TSTA
      BPL   @Convert    ; Skip forward if positive
      PSHS  A
      LDA   #%10000000  ; Move sign bit to the carry
      STA   FP5_SIGN
      PULS  A   
; Negate value to make it positive
      NEGA              ; Negate A (8-bit two's complement: -A = ~A + 1)
      NEGB              ; Negate B (8-bit two's complement: -B = ~B + 1)
      SBCA  #$00        ; Subtract 0 from A with borrow (propagate carry from NEGB)
@Convert:
      LEAS  -5,S        ; Make room for the Sign/Exponent byte
      CLR   ,S          ; Clear sign and exponent
      TSTA
      BMI   @Done
!     INC   ,S
      LSLB
      ROLA
      BPL   <
@Done
      STD   1,S
      CLR   3,S
      CLR   4,S
      LDB   #15
      SUBB  ,S
      ORB   FP5_SIGN
      STB   ,S
@Return:
      JMP   >$FFFF          ; Return, self modified jump address
;
; Ouput FP5 as all zeros
@FP5_ZERO:
      LDX   #$0000
      LDU   #$0000
      PSHS  B,X,U       ; Save 5 zero bytes on the stack
      BRA   @Return     ; Return

; Convert 5 Byte FP5 at ,S to 32-bit signed integer at ,S
FP5_TO_S32:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
    JSR     FP5_TO_S64  ; Convert 5 Byte FP5 @ ,S to Signed 64-bit Integer @ ,S
    LEAS    4,S         ; Pull two high signed words off the 64 bit number on the stack, Save only the two low words
@Return:
    JMP     >$FFFF      ; return (self modified)

; Convert 5 Byte FP5 at ,S to 32-bit unsigned integer at ,S
FP5_TO_U32:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
    JSR     FP5_TO_U64  ; Convert 5 Byte FP5 @ ,S to Unsigned 64-bit Integer @ ,S
    LEAS    4,S         ; Pull two high unsigned words off the 64 bit number on the stack, Save only the two low words
@Return:
    JMP     >$FFFF      ; return (self modified)

; Convert 5 Byte FP5 at ,S to 16-bit signed integer at ,S
FP5_TO_S16:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
    JSR     FP5_TO_S64  ; Convert 5 Byte FP5 @ ,S to Signed 64-bit Integer @ ,S
    LEAS    6,S         ; Pull three high signed words off the 64 bit number on the stack, Save only the low word
@Return:
    JMP     >$FFFF      ; return (self modified)

; Convert 5 Byte FP5 at ,S to 16-bit unsigned integer at ,S
FP5_TO_U16:
    PULS    U           ; Get return address off the stack
    STU     @Return+1   ; Self modify the return location below
    JSR     FP5_TO_U64  ; Convert 5 Byte FP5 @ ,S to Unsigned 64-bit Integer @ ,S
    LEAS    6,S         ; Pull three high unsigned words off the 64 bit number on the stack, Save only the low word
@Return:
    JMP     >$FFFF      ; return (self modified)


; Convert 5 Byte FP5 @ ,S to Unsigned 64-bit Integer @ ,S
FP5_TO_U64:
      PULS  Y           ; get the return address in U
      STY   @Return+1   ; Self modify the return location below
      JSR   Validate_FP5 ; Go validate FP5 number at ,S and return with FP5_SIGN, FP5_EXPonent & MANT1 setup
                        ; Will not return if number is not valid, but will return with proper value or zero
; Returns with:
; U pointing at the stored 64 bit number and
; B is the Exponent value
; ----------------------------
; 0) If value is negative → clamp to 0
; ----------------------------
      LDA   FP5_SIGN
      BEQ   @FP5_U64_Positive    ; if sign == 0, go do normal conversion
; Negative → return 0 (unsigned clamp)
@ReturnZero:
      LDD   #$0000
      LDX   #$0000
      PSHS  D,X
      PSHS  D,X
      BRA   @Return
;
@FP5_U64_Positive:
; Compute shift count = exp - 31
; B = exp (signed)
      SUBB  #31               ; B = exp - 31
      BEQ   @FP5_U64_ShiftDone ; no shift needed
      BPL   @FP5_U64_DoLeft   ; if B > 0 → left shift
; ---- Right shift by -B bits (exp - 15 < 0) ----
      NEGB                    ; B = -(exp - 15)  (number of right-shift bits)
; If shifting right by >= 64 bits, result is zero.
      CMPB  #32               ; If we shift all 16 bits out of the mantissa
      BHS   @ReturnZero       ; it will be zero
@FP5_U64_DoRight:
      JSR   FP5_Shift_Right64_AtU_B ; Logical right-shift 64-bit value at U by B bits (B >= 0)
      BRA   @FP5_U64_ShiftDone
;
@FP5_U64_DoLeft:
; ---- Left shift by B bits (exp - 15 > 0) ----
; With your 7-bit signed exponent range, this safely fits in 64 bits.
      JSR   FP5_Shift_Left64_AtU_B ; Left-shift 64-bit value at U by B bits (B >= 0)
;
@FP5_U64_ShiftDone:
; FP5_MANT1..+7 now hold the unsigned 64-bit integer, truncated.
      PULU  D,X,Y
      LDU   ,U
      PSHS  D,X,Y,U
@Return:
      JMP   >$FFFF          ; return (self modified)

; Convert 5 Byte FP5 @ ,S to Signed 64-bit Integer @ ,S
FP5_TO_S64:
      PULS  Y           ; get the return address in U
      STY   @Return+1   ; Self modify the return location below
      BSR   Validate_FP5 ; Go validate FP5 number at ,S and return with FP5_SIGN, FP5_EXPonent & MANT1 setup
                        ; Will not return if number is not valid, but will return with proper value or zero
; Returns with:
; U pointing at the stored 64 bit number and
; B is the Exponent value
; ---- Compute net shift = exponent - 31 (because mantissa is Q1.31) ----
;
      SUBB  #31           ; shift = exponent - 31
      BEQ   @FP5_SHIFT_DONE
      BPL   @FP5_DO_LSHIFT ; shift > 0 -> left shift
; shift < 0 -> right shift by -shift
      NEGB                 ; B = -shift
      JSR   FP5_Shift_Right64_AtU_B ; Logical right-shift 64-bit value at U by B bits (B >= 0)
      BRA   @FP5_SHIFT_DONE
@FP5_DO_LSHIFT:
; A = positive shift count
      JSR   FP5_Shift_Left64_AtU_B ; Left-shift 64-bit value at U by B bits (B >= 0)
;
@FP5_SHIFT_DONE:
; ---- Apply sign: if negative, two's complement of 64-bit magnitude ----
      LDA   FP5_SIGN
      BEQ   @FP5_SIGN_DONE     ; positive
; Negate_64:
      COM   ,U
      COM   1,U
      COM   2,U
      COM   3,U
      COM   4,U
      COM   5,U
      COM   6,U
      COM   7,U
; + 1
; Propagate if needed
      INC   7,U
      BNE   @FP5_SIGN_DONE     ; If <> zero, don't propagate carry, done
      INC   6,U
      BNE   @FP5_SIGN_DONE     ; If <> zero, don't propagate carry, done
      INC   5,U
      BNE   @FP5_SIGN_DONE     ; If <> zero, don't propagate carry, done
      INC   4,U
      BNE   @FP5_SIGN_DONE     ; If <> zero, don't propagate carry, done
      INC   3,U
      BNE   @FP5_SIGN_DONE     ; If <> zero, don't propagate carry, done
      INC   2,U
      BNE   @FP5_SIGN_DONE     ; If <> zero, don't propagate carry, done
      INC   1,U
      BNE   @FP5_SIGN_DONE     ; If <> zero, don't propagate carry, done
      INC   ,U
@FP5_SIGN_DONE:
      PULU  D,X,Y
      LDU   ,U
      PSHS  D,X,Y,U
@Return:
      JMP     >$FFFF          ; return (self modified)

; Validate FP5 number at ,S and return with FP5_SIGN, FP5_EXPonent & MANT1 setup
; Returns with:
; U pointing at the stored 64 bit number and
; B is the Exponent value
Validate_FP5:
      PULS  D
      STD   @AllGood+1  ; Self modify the return location below
      LDA   ,S
      ANDA  #%10000000  ; Save only the SIGN bit
      STA   FP5_SIGN    ; Save the SIGN
      PULS  B,X,U       ; Get the sign, exponent and mantissa off the stack
      LSLB
      BNE   @NotZero
; If we get here it could be zero
      CMPX  #$0000
      BNE   @NotZero
      CMPU  #$0000
      BEQ   @OutZero    ; Return with zero
@NotZero
      CMPB  #$80
      BNE   @Valid   
      CMPX  #$0000      ; Check Mantissa
      BNE   @NaN
; We get here with infinity
      LDD   #%0111111111111111 ; Max value
      ORA   FP5_SIGN    ; Add the sign bit
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
; Place mantissa in low 32 bits of the 64-bit area
      STX   FP5_MANT1+4 ; Save the MSWord
      STU   FP5_MANT1+6 ; Save the LSWord
; Fix up exponent value
      ASRB              ; B = signed exponent
      STB   FP5_EXPonent ; Save the EXPonent
;
; FP5_EXPonent range is -63 to 63 which will always fit in a 64bit range so no clamp limit is neccessary
;
; Clear result area (4 bytes)
      LDX   #$0000
      LDU   #FP5_MANT1  ; FP5_MANT1 & MANT2 is 64 bits of space we can use
      STX   ,U
      STX   2,U
@AllGood:
      JMP   >$FFFF          ; return (self modified
@Return:
      JMP   ,Y          ; return not valid

; FP5_SUB - Subtract 5 byte float @ 5,S from ,S does S=S+5 with result @ ,S
FP5_SUB:
      PULS  D               ; Get return address off the stack
      STD   @Return+1       ; Self mod return JMP adress below
; Check if they are the same, if so return zero
      LDX   ,S          ; Sign Exp Val2
      CMPX  5,S         ; Sign Exp Val1
      BNE   @NotSame
      LDX   2,S         ; MidbitsMant Val2
      CMPX  7,S         ; MidbitSMant Val1
      BNE   @NotSame
      LDA   4,S         ; LSMant Val2
      CMPA  9,S         ; LSMant Val1
      BNE   @NotSame
; Get here if they are the same, x - x = 0
      LEAS  10,S               ; Fix the stack
      CLRB
      LDX   #$0000
      LDU   #$0000
      PSHS  B,X,U
      JMP   @Return
@NotSame:
      LDA   #$FF
      STA   @TestForSUB+1       ; Setting bits indicates we want to do subtraction
      BRA   FP5_ADD_SUB
;
; FP5_ADD - Adds 5 byte Float @ ,S with 5 byte Float @ 5,S does S=S+5 with result @ ,S
FP5_ADD:
      PULS  D               ; Get return address off the stack
      STD   @Return+1       ; Self mod return JMP adress below
      CLR   @TestForSUB+1       ; Clearing the bits indicates we want to do an add
; Flow through to Add two FP numbers @ ,S & 4,S return with Result at ,S
;
FP5_ADD_SUB:
; Check for NaN or Infinity (If either value 1 or value 2 is NaN return with a value of NaN)
      LDA   ,S          ; Get the Sign and Exponent Value 2
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial2 ; Fix stack and return with Special result
      LDA   5,S         ; Get the Sign and Exponent Value 1
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial1  ; Fix stack and return with Special result
; Check for zeros, Start with Value 2
      LDA   1,S
      BNE   @NotZero
; Get here with a value of zero
      LEAS  5,S         ; Move the stack forward, keep Value 1 as the result
      JMP   @Return     ; RTS
; Check Value 1 for zero
@NotZero:
      LDA   6,S
      BNE   @GoodValues
; Get here with a value of zero
; If we are doing subtraction then value2's sign needs to be flipped
      LDA   @TestForSUB+1
      BEQ   >           ; Will be zero if adding, so skip forward, keep value 2 as the result
      LDA   ,S          ; Get the SIGN & Exponent
      EORA  #%10000000  ; flip sign bit
      STA   ,S          ; Save it
!     PULS  A,X,U       ; Get Value 2 off the stack
      LEAS  5,S         ; Move the stack
      PSHS  A,X,U       ; Save Value 2 as the result
      JMP   @Return     ; RTS
; We get here when we have two good values to Add
; Get Sign, Exponent & Mantissa for Value 2
@GoodValues:
      PULS  A,X,U       ; A = Sign & Exponent, X & U = Mantissa
      CLRB
      LSLA
      BCC   >
      LDB   #%10000000
!     STB   FP5_SIGN2   ; Save Sign
      ASRA              ; Shift Exponent back to normal keeping
      STA   FP5_EXPonent2 ; Save Exponent
      STX   FP5_MANT2   ; Save Mantissa
      STU   FP5_MANT2+2 ; Save Mantissa
; Get Sign, Exponent & Mantissa for Value 1
      PULS  A,X,U       ; A = Sign & Exponent, X & U = Mantissa
      CLRB
      LSLA
      BCC   >
      LDB   #%10000000
!     STB   FP5_SIGN1   ; Save Sign
      ASRA              ; Shift Exponent back to normal keeping
      STA   FP5_EXPonent1 ; Save Exponent
      STX   FP5_MANT1   ; Save Mantissa
      STU   FP5_MANT1+2 ; Save Mantissa
; Make the lower 16 bits of the Mantissa space empty
      LDX   #$0000
      STX   FP5_MANT1+4
      STX   FP5_MANT2+4
      STX   FP5_MANT+4  ; Clear the rounding byte
;
; Adjust for subtraction
@TestForSUB
      LDA   #$FF
      BEQ   @NO_SUB     ; If the bits are clear then add the values as they are
      LDA   FP5_SIGN2   ; Otherwise make sign2 a negative and add them
      EORA  #$80
      STA   FP5_SIGN2
; Align Exponents:
; Adjust the mantissa of the number with the smaller exponent by shifting it right until the exponents match.
@NO_SUB:
; Compare the sizes of the numbers
; Align mantissas
      LDB   FP5_EXPonent2
      SUBB  FP5_EXPonent1
      BGT   @EXP2_Big
      BLT   @EXP1_Big
; exp equal, compare mant to decide which larger
      LDX   FP5_MANT2
      CMPX  FP5_MANT1
      LBGT  @EXP2_NoShift
      BLT   @EXP1_NoShift
;
      LDD   FP5_MANT2+2
      CMPD  FP5_MANT1+2
      LBHS  @EXP2_NoShift
      BRA   @EXP1_NoShift
; Fall through to swap
; EXP1 > EXP2, shift MANT2 right
@EXP1_Big:
      NEGB
; Shift B bits at U
      LDU   #FP5_MANT2
      JSR   FP5_Shift_Right40_AtU_B  ;Shift the 40-bit number at U Right by B bits, U is unchanged
@EXP1_NoShift:
      LDA   FP5_EXPonent1
      STA   FP5_EXPonent      ; Exponent is the largest one
      LDA   FP5_SIGN1
      STA   FP5_SIGN          ; Sign is taken from the largest exponent
      BRA   @Go_Ready
; EXP2 => EXP1, shift MANT1 right
@EXP2_Big:
; Shift B bits at X
      LDU   #FP5_MANT1
      JSR   FP5_Shift_Right40_AtU_B  ;Shift the 40-bit number at U Right by B bits, U is unchanged
@EXP2_NoShift:
      LDA   FP5_EXPonent2
      STA   FP5_EXPonent      ; Exponent is the largest one
      LDA   FP5_SIGN2
      STA   FP5_SIGN          ; Sign is taken from the largest exponent
@Go_Ready:
; At this point both mantissa's are lined up properly
; EXP is set proper
; SIGN is set proper
;
; Add or Subtract Mantissas:
; If the signs are the same, add the mantissas
      LDA   FP5_SIGN1
      CMPA  FP5_SIGN2
      BEQ   @Do_Add           ; If the signs are the same then add the Manitssa's
@Do_Sub:
; If different, subtract the smaller mantissa from the larger one, determining the result’s sign based on magnitudes.
; Figure out which is is larger:
; Decide which mantissa is larger: compare (hi,lo) as a 32-bit unsigned
      LDD   FP5_MANT1          ; hi1
      CMPD  FP5_MANT2          ; hi2
      BHI   @M1_Big
      BLO   @M2_Big            ; if hi1 < hi2, mant2 is bigger
;
      LDD   FP5_MANT1+2        ; lo1
      CMPD  FP5_MANT2+2        ; lo2
      BHI   @M1_Big
      BLO   @M2_Big
      LDA   FP5_MANT1+4
      CMPA  FP5_MANT2+4
      BHI   @M1_Big
      ; else lo1 <= lo2 => mant2 bigger (also covers exact equality)
@M2_Big:
      LDA   FP5_SIGN2
      STA   FP5_SIGN
      LDX   #FP5_MANT2
      LDU   #FP5_MANT1
      BRA   @Do_Sub1
;
@M1_Big:
      LDA   FP5_SIGN1
      STA   FP5_SIGN
      LDX   #FP5_MANT1
      LDU   #FP5_MANT2
      ; fall into @Do_Sub1
@Do_Sub1:
	LDD 	3,X         ; Load Value1 bytes 3 and 4 (least significant 16 bits) into D (A:B)
	SUBD 	3,U         ; Subtract Value2 bytes 3 and 4 from D, sets carry if borrow
	STD 	3,X         ; Store result to Value1 bytes 3 and 4
	LDD 	1,X         ; Load Value1 bytes 1 and 2 into D (A:B)
	SBCB 	2,U         ; Subtract Value2 byte 2 from B with borrow
	SBCA 	1,U          ; Subtract Value2 byte 1 from A with borrow
	STD 	1,X          ; Store result to Value1 bytes 1 and 2
      LDB   ,X          ; Load Value1 byte 0
      SBCB  ,U          ; Subtract Value 2 byte 0 from B with borrow
      STB   ,X          ; Store result to Value1
; Shift the 32-bit mantissa left until bit 31 is 1, adjusting the exponent
      LDD   ,X
      BNE   >
      LDD   2,X
      BNE   >
      LDA   4,X
      BEQ   @Skip0      ; Skip if there is no Value
!     LDB   FP5_EXPonent
!     LDA   ,X
      BMI   >           ; Bit 31 is a 1 we are done shifting
      ASL   4,X
      ROL   3,X
      ROL   2,X
      ROL   1,X
      ROL   ,X
      DECB              ; EXP=EXP-1
      BRA   <
!     STB   FP5_EXPonent
@Skip0:
      LEAU  ,X
      PULU  B,X,Y
      LDU   #FP5_MANT+5
      PSHU  B,X,Y         ; Save the Mantissa in FP5_MANT
      BRA   @Skip1
;
@Do_Add:
; Add the two 40-bit aligned mantissas (correct offsets)
    LDD FP5_MANT1+2
    ADDD FP5_MANT2+2
    STD FP5_MANT+2
;
    LDD FP5_MANT1
    ADCB FP5_MANT2+1
    ADCA FP5_MANT2
    STD FP5_MANT
;
    BCC @Skip1                  ; no carry from high word
;
    ; Carry overflow – normalize
    ROR FP5_MANT
    ROR FP5_MANT+1
    ROR FP5_MANT+2
    ROR FP5_MANT+3
    ROR FP5_MANT+4
    INC FP5_EXPonent
    LDA FP5_EXPonent
    CMPA #$40
    BGE @PosInfinity
@Skip1:
      LDU   #FP5_MANT
      BSR   FP5_Round_U       ; Round 40 bit value at U down to 32 bits and bump FP5_EXPonent if needed
      LDB   FP5_EXPonent      ; Get Exponent in B
      LSLB                    ; Shift exponent left (exponent is 7 bit signed value)
      LDA   FP5_SIGN          ; Get the sign in A
      LSLA                    ; Shift Sign bit into the carry
      RORB                    ; Fix exponent and copy carry (sign bit) into bit 7 of B
      LDX   FP5_MANT          ; Get the MS word mantissa in X
      LDU   FP5_MANT+2        ; Get the LS word mantissa in U
      PSHS  B,X,U             ; Save Result on the stack
@Return:
      JMP   >$FFFF            ; Return (Self modified address above)
; Value 1 is special, Value 2 is not special
; Return with Value 1
@ReturnSpecial1
      LEAS  5,S               ; Move past Value 2, so value 1 is the result
      BRA   @Return
;
; Value 2 is special, Value 1 has not been checked
@ReturnSpecial2
      LDA   5,S               ; Get sign & exponent of Value 1
      LSLA
      CMPA  #$80              ; Is it special
      BNE   @CopySpecial2
; Value 2 and Value 1 are both special, if one is +infinity and the other is -infinity then result in NaN
; check for NaN's first
      LDA   1,S
      BMI   @NaN2Exit         ; Value 2 is a NaN
      LDA   6,S
      BMI   @NaN1Exit         ; Value 1 is a NaN
; We get here when they are both infinity, if one is -infinity and the other is positve infinty then return with NaN
; Otherwise return with Value1 (they are the same)
      LDA   ,S
      BMI   @Value2Neg
; value 2 is positive
      LDA   5,S               ; Check Value 1
      BMI   @ResultNaN        ; It is negative return with NaN
      BRA   @ReturnVal1       ; They are the same, return with Value 1
; Value 2 is negative
@Value2Neg:
      LDA   5,S               ; Check Value 1
      BPL   @ResultNaN        ; It is positive return with NaN
@ReturnVal1:
      LEAS  5,S
      BRA   @Return
; Value 1 is a NaN
@NaN1Exit
; Value 2 is a NaN
@NaN2Exit
@ResultNaN:
      LDA   #%01000000        ; Flag as special
      LDX   #$8000            ; Set MSbit
@ClearLowWord:
      LDU   #$0000            ; Clear LS Word
      LEAS  10,S
!     PSHS  A,X,U             ; Store the result
      BRA   @Return           ; RTS
; Value 1 is not special, value 2 is special, so return with Value 2
@CopySpecial2:
      PULS  A,X,U             ; get special Value 2
      LEAS  5,S               ; Move the stack
      BRA   <                 ; Store and return
@PosInfinity:
      LDA   #%01000000        ; Flag as special
      LDX   #$0000            ; Clear MSbit
      BRA   @ClearLowWord     ; Store and return

; Round 40 bit value at U down to 32 bits and bump FP5_EXPonent if needed
; G is the MSbit we drop, R is the 2nd MSbit we drop, S is OR'ed with the other bits we dropped (0 or 1)
;   •	If G = 0, you’re less than halfway to the next representable mantissa, so you leave M unchanged.
;	•	If G = 1 and (R or S = 1) — i.e. you’re strictly more than halfway — you add 1 to M.
;	•	If G = 1, R = 0, S = 0 — i.e. you’re exactly halfway (the bit pattern is ...xyz1000…0) — you add 1 to M only if 
;                the low-order bit of the current M is 1 (making it “even” ties-to-even), otherwise you leave it alone.
;
FP5_Round_U:
      LDD   ,U          ; Make sure we don't get stuck in an endless shift if mantissa is zero
      BNE   >
      LDX   2,U
      BEQ   @Round
      TSTA
!     BMI   @Round      ; Normalize the manitssa
      LSL   4,U
      ROL   3,U
      ROL   2,U
      ROL   1,U
      ROL   ,U
      DEC   FP5_EXPonent
      LDA   FP5_EXPonent
      CMPA  #-$40       ; Have we underflowed
      BLE   @UnderflowToZero   ; We have underflowed
      BRA   FP5_Round_U
@Round:
      LDA   4,U         ; Get bits for rounding (G,R,S)
      BPL   @Done
; G is 1 so check if R or S are 1
      BITA  #%01111111  ; Check R & S
      BNE   @AddOne     ; if they're 1 then add to the mantissa
; If we get here we have to check LSbit of our mantissa as ties to even means if it's an even number skip adding one
      LDA   3,U         ; Get low byte of our 32 bit mantissa
      BITA  #%00000001  ; Is it odd?
      BEQ   @Done       ; if not we are done
@AddOne
      INC   3,U
      BNE   @Done
      INC   2,U
      BNE   @Done
      INC   1,U
      BNE   @Done
      INC   ,U
      BNE   @Done
; If we get here then we just overflowed (the mantissa is now $010000)
      LDA   #%10000000
      STA   ,U          ; Set the high bit of the mantissa
@IncreaseExponent:
      INC   FP5_EXPonent
      LDA   FP5_EXPonent
      CMPA  #$40        ; Have we overflowed?
      BLT   @Done       ; If not we are done
; Otherwise we hit +Infinity
      CLR   ,U          ; Make mantissa +Infinity
      CLR   1,U
      CLR   2,U
      CLR   3,U
@Done:
      RTS
@UnderflowToZero:
      CLR   FP5_SIGN
      CLR   FP5_EXPonent
      CLR   ,U
      CLR   1,U
      CLR   2,U
      CLR   3,U
      CLR   4,U
      RTS


; 
; FP5_MUL - Multiply 5,S * ,S then S=S+5 result is @ ,S
FP5_MUL:
      PULS  D               ; Get return address off the stack
      STD   @Return+1       ; Self mod return JMP adress below
; Check for NaN or Infinity (If either value 1 or value 2 is NaN return with a value of NaN)
      LDA   ,S          ; Get the Sign and Exponent Value 2
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial2 ; Fix stack and return with Special result
      LDA   5,S         ; Get the Sign and Exponent Value 1
      LSLA              ; Ignore the sign
      CMPA  #$80        ; Is it NaN?
      LBEQ  @ReturnSpecial1  ; Fix stack and return with Special result
; Check for zeros, Start with Value 2
      LDD   1,S
      BNE   @NotZero
      LDD   3,S
      BEQ   @ReturnZero
; Check Value 1 for zero
@NotZero:
      LDD   6,S
      BNE   @GoodValues
      LDD   8,S
      BNE   @GoodValues
@ReturnZero:
; Get here with a value of zero, return with +0
      CLRB
      LEAS  10,S         ; Move the stack forward
      LDX   #$0000
      LDU   #$0000
      PSHS  B,X,U
      JMP   @Return     ; RTS
; We get here when we have two good values to Multiply
@GoodValues:
; SIGN = SIGN1 XOR SIGN2
!     LDA   5,S         ; A = SIGN Value 1
      EORA  ,S         ; EORA with SIGN Value 2
      ANDA  #%10000000  ; Save only the sign bit
      STA   FP5_SIGN    ; Save the new SIGN
;
; Exponent = EXP1 + EXP2
      LDA   5,S         ; D = EXP Value 1
      LSLA              ; Strip off the sign bit
      ASRA              ; A = 8 bit signed version of Exponent Value 1
      PSHS  A           ; Save it on the stack
      LDA   1,S         ; A = EXP Value 2
      LSLA              ; Strip off the sign bit
      ASRA              ; A = 8 bit signed version of Exponent Value 2
      ADDA  ,S+         ; A = A + EXP Value 1, fix the stack
      INCA
      CMPA  #$40        ; Have we overflowed?
      LBGE   @PosInfinity ; Otherwise we hit +Infinity
      STA   FP5_EXPonent ; Save the new EXP
;
; Multiply mantissas (32-bit result)
; We will multiply Value 2 * Value 1
; Move Mantissa 2 & keep Mantissa 1 on the stack
; then call the Unsigned 16 bit integer multiply function
;
      PULS  B,X,U       ; Get value 2 Manitssa in X & U, move stack
      LEAS  1,S         ; Stack now has Value 1 mantissa @ ,S
      PSHS  X,U         ; Save value 2 Manitssa
; We now have Value 2 mantissa then Value 1 Mantissa on the stack
      JSR   Mul_UnSigned_Both_32    ; Multiply ,S * 4,S result @ ,S and 64 bit result at RESULT
; Minimal value will be: $4000 0000 0000 0000
; Maximum value will be: $FFFF FFFE 0000 0001
;
;
      LEAS  4,S                  ; discard 32-bit copy on stack (your routine behavior)
;
; Build a proper 40-bit rounding buffer in FP5_MANT from 64-bit RESULT
      LDX   RESULT               ; high 16
      STX   FP5_MANT
      LDX   RESULT+2             ; next 16
      STX   FP5_MANT+2
;
      LDA   RESULT+4             ; guard/round byte (next 8 bits after top32)
      LDB   RESULT+5             ; sticky sources
      ORB   RESULT+6
      ORB   RESULT+7
      BEQ   >
      ORA   #$01                 ; fold sticky into bit0 (any low bits were nonzero)
!
      STA   FP5_MANT+4
;
; Now round/normalize using the *correct* 40-bit layout
      LDU   #FP5_MANT
      JSR   FP5_Round_U
;
; Pack result
      LDB   FP5_EXPonent
      LSLB
      LDA   FP5_SIGN
      LSLA
      RORB
      LDX   FP5_MANT
      LDU   FP5_MANT+2
      PSHS  B,X,U
@Return:
      JMP   >$FFFF      ; Return (Self modified address above)
;
;
;      LEAS  4,S         ; Ignore the 32 bit result on the stack
;      LDU   #RESULT
;      JSR   FP5_Round_U ; Round 40 bit value at U down to 32 bits and bump FP5_EXPonent if needed
;; Keep the top 32 bits and the mantissa result
;      LDB   FP5_EXPonent      ; Get Exponent in B
;      LSLB                    ; Shift exponent left (exponent is 7 bit signed value)
;      LDA   FP5_SIGN          ; Get the sign in A
;      LSLA                    ; Shift Sign bit into the carry
;      RORB                    ; Fix exponent and copy carry (sign bit) into bit 7 of B
;      LDX   RESULT            ; Get the MS word mantissa in X
;      LDU   RESULT+2          ; Get the LS word mantissa in U
;      PSHS  B,X,U             ; Save Result on the stack
;@Return:
;      JMP   >$FFFF      ; Return (Self modified address above)
;
; Value 1 is special, Value 2 is not special
; Return with Value 1
@ReturnSpecial1
      LEAS  5,S         ; Move past Value 2, so value 1 is the result
      BRA   @Return
;
; Value 2 is special, Value 1 has not been checked
@ReturnSpecial2
      LDA   5,S         ; Get sign & exponent of Value 1
      LSLA
      CMPA  #$80        ; Is it special
      BNE   @CopySpecial2
; Value 2 and Value 1 are both special, if one is +infinity and the other is -infinity then result in NaN
; check for NaN's first
      LDA   1,S
      BMI   @NaN2Exit   ; Value 2 is a NaN
      LDA   6,S
      BMI   @NaN1Exit   ; Value 1 is a NaN
; We get here when they are both infinity, if one is -infinity and the other is positve infinty then return with NaN
; Otherwise return with Value1 (they are the same)
      LDA   ,S
      BMI   @Value2Neg
; value 2 is positive
      LDA   5,S         ; Check Value 1
      BMI   @ResultNaN  ; It is negative return with NaN
      BRA   @ReturnVal1 ; They are the same, return with Value 1
; Value 2 is negative
@Value2Neg:
      LDA   5,S         ; Check Value 1
      BPL   @ResultNaN  ; It is positive return with NaN
@ReturnVal1:
      LEAS  5,S
      BRA   @Return
; Value 1 is a NaN
@NaN1Exit
; Value 2 is a NaN
@NaN2Exit
@ResultNaN:
      LDA   #%01000000  ; Flag as special
      LDX   #$8000      ; Set MSbit
@ClearLowWord:
      LDU   #$0000      ; Clear low word of mantissa
      LEAS  10,S
!     PSHS  A,X,U       ; Store the result
      BRA   @Return     ; RTS
; Value 1 is not special, value 2 is special, so return with Value 2
@CopySpecial2:
      PULS  A,X,U       ; get special Value 2
      LEAS  5,S         ; Move the stack
      BRA   <           ; Store and return
@PosInfinity:
      LDA   #%01000000  ; Flag as special
      LDX   #$0000      ; Clear MSbit
      BRA   @ClearLowWord     ; Clear low word of mantissa, Store and return



; ------------------------------------------------------------
; FP5_DIV - Divide 5,S / ,S then S=S+5 result is @ ,S
; ------------------------------------------------------------
FP5_DIV:
      PULS  D               ; Get return address off the stack
      STD   @Return+1       ; Self mod return JMP address below
; ------------------------------------------------------------
; Check for NaN / Infinity
; ------------------------------------------------------------
      LDA   ,S              ; Value2 sign/exponent
      LSLA                  ; Ignore sign
      CMPA  #$80            ; NaN?
      LBEQ  @ReturnSpecial2
      LDA   5,S             ; Value1 sign/exponent
      LSLA
      CMPA  #$80            ; NaN?
      LBEQ  @ReturnSpecial1
; ------------------------------------------------------------
; Check divisor (Value2) for zero
; ------------------------------------------------------------
      LDA   1,S             ; Value2 mantissa MSB
      BNE   @CheckValue1Zero
; Value2 = 0
      LDA   6,S             ; Value1 mantissa MSB
      LBEQ  @ReturnNaN      ; 0 / 0 = NaN
; Nonzero / 0 = signed infinity, sign = sign1 XOR sign2
      LDA   5,S
      EORA  ,S
      ANDA  #%10000000
      ORA   #%01000000      ; Special exponent, mantissa MSB clear = infinity
      LDX   #$0000
      LDU   #$0000
      LEAS  10,S
      PSHS  A,X,U
      JMP   @Return
; ------------------------------------------------------------
; Check dividend (Value1) for zero
; ------------------------------------------------------------
@CheckValue1Zero:
      LDA   6,S             ; Value1 mantissa MSB
      BNE   @GoodValues
; 0 / nonzero = signed zero, sign = sign1 XOR sign2
      LDB   5,S
      EORB  ,S
      ANDB  #%10000000
@OutPutZero_B:
      LDX   #$0000
      LDU   #$0000
      LEAS  10,S
      PSHS  B,X,U
      JMP   @Return
; ------------------------------------------------------------
; Two normal nonzero values
; ------------------------------------------------------------
@GoodValues:
; SIGN = SIGN1 XOR SIGN2
      LDA   5,S
      EORA  ,S
      ANDA  #%10000000
      STA   FP5_SIGN
; EXP = EXP1 - EXP2
      LDB   ,S              ; Value2 exponent/sign
      LSLB                  ; Strip sign bit
      ASRB                  ; Signed 7-bit exponent -> signed 8-bit
      PSHS  B
      LDB   6,S             ; Value1 exponent/sign
      LSLB
      ASRB
      SUBB  ,S+             ; EXP1 - EXP2
      STB   FP5_EXPonent
; Early underflow check
      CMPB  #-$3F
      LBLT  @UnderflowToZero
; ------------------------------------------------------------
; Load mantissas into DIV32_U / DIV32_V
; ------------------------------------------------------------
; divisor mantissa (Value2) at 0..4,S
      LDX   1,S
      STX   DIV32_V
      LDX   3,S
      STX   DIV32_V+2
; dividend mantissa (Value1) at 5..9,S
      LDX   6,S
      STX   DIV32_U
      LDX   8,S
      STX   DIV32_U+2
; ------------------------------------------------------------
; Compute mantissa quotient into FP5_MANT[0..4]
; ------------------------------------------------------------
      JSR   FP5_DivMant_Using_IntDiv
; ------------------------------------------------------------
; Drop both inputs
; ------------------------------------------------------------
      LEAS  10,S
; ------------------------------------------------------------
; Round mantissa
; ------------------------------------------------------------
      LDU   #FP5_MANT
      JSR   FP5_Round_U
; ------------------------------------------------------------
; Check exponent after mantissa divide/rounding
; ------------------------------------------------------------
      LDB   FP5_EXPonent
      CMPB  #-$3F
      LBLT  @UnderflowToZero_NoDrop
      CMPB  #$40
      LBGE  @OverflowToInfinity_NoDrop
; ------------------------------------------------------------
; Pack sign/exponent and push result
; ------------------------------------------------------------
      LSLB                  ; Shift exponent left
      LDA   FP5_SIGN
      LSLA                  ; Move sign into carry
      RORB                  ; Pack sign into exponent byte
      LDX   FP5_MANT
      LDU   FP5_MANT+2
      PSHS  B,X,U
@Return:
      JMP   >$FFFF
; ------------------------------------------------------------
; Special return paths
; ------------------------------------------------------------
; Value1 is special, Value2 is not special
@ReturnSpecial1:
      LEAS  5,S             ; Skip Value2, return Value1 as-is
      BRA   @Return
; Value2 is special
@ReturnSpecial2:
      LDA   1,S             ; Value2 mantissa MSB
      BMI   @CopySpecial2   ; NaN -> return Value2 NaN
; Value2 is infinity
      LDA   5,S
      ANDA  #%01111111      ; Value1 exponent
      CMPA  #$40
      BEQ   @BothSpecialCheckValue1
; finite / infinity = signed zero, sign = sign1 XOR sign2
      LDB   5,S
      EORB  ,S
      ANDB  #%10000000
      LDX   #$0000
      LDU   #$0000
      LEAS  10,S
      PSHS  B,X,U
      BRA   @Return
@BothSpecialCheckValue1:
      LDA   6,S             ; Value1 mantissa MSB
      BMI   @ReturnSpecial1 ; Value1 is NaN -> return Value1 NaN
; infinity / infinity = NaN
@ReturnNaN:
      LDA   #%01000000      ; Special
      LDX   #$8000          ; Mantissa MSB set = NaN
@ClearLowWord:
      LDU   #$0000
      LEAS  10,S
      PSHS  A,X,U
      BRA   @Return
; Value1 is not special, Value2 is NaN
@CopySpecial2:
      PULS  A,X,U           ; Pull Value2
      LEAS  5,S             ; Drop Value1 still on stack
      PSHS  A,X,U
      BRA   @Return
; ------------------------------------------------------------
; Local underflow/overflow handlers
; ------------------------------------------------------------
@UnderflowToZero:
; still have both operands on stack
      LDB   FP5_SIGN
      ANDB  #%10000000
      LDX   #$0000
      LDU   #$0000
      LEAS  10,S
      PSHS  B,X,U
      BRA   @Return
@UnderflowToZero_NoDrop:
; operands already dropped
      LDB   FP5_SIGN
      ANDB  #%10000000
      LDX   #$0000
      LDU   #$0000
      PSHS  B,X,U
      BRA   @Return
@OverflowToInfinity_NoDrop:
      LDA   FP5_SIGN
      ANDA  #%10000000
      ORA   #%01000000      ; infinity
      LDX   #$0000
      LDU   #$0000
      PSHS  A,X,U
      BRA   @Return


; ------------------------------------------------------------
; Workspace
; ------------------------------------------------------------
DIV64_N        RMB 8     ; 64-bit numerator
DIV32_Q        RMB 4     ; 32-bit quotient
DIV32_REM      RMB 4     ; 32-bit remainder
FP5_DIVSHIFT   RMB 1

; ------------------------------------------------------------
; FP5_DivMant_Using_IntDiv
;
; In:
;   DIV32_U = dividend mantissa (32-bit normalized)
;   DIV32_V = divisor  mantissa (32-bit normalized)
;   FP5_EXPonent = EXP1 - EXP2 already computed
;
; Out:
;   FP5_MANT[0..3] = mantissa
;   FP5_MANT[4]    = round byte with sticky in bit0
; ------------------------------------------------------------
FP5_DivMant_Using_IntDiv:
; If U < V, quotient is in [0.5,1), so use (U << 32)/V and EXP--
; Else quotient is in [1,2), so use (U << 31)/V
      LDD   DIV32_U
      CMPD  DIV32_V
      BHI   @Use31
      BLO   @Use32
      LDD   DIV32_U+2
      CMPD  DIV32_V+2
      BHS   @Use31
@Use32:
      DEC   FP5_EXPonent
      LDA   #32
      STA   FP5_DIVSHIFT
      BRA   @BuildNumerator
@Use31:
      LDA   #31
      STA   FP5_DIVSHIFT
@BuildNumerator:
; --------------------------------------------------
; First divide: mant32 = floor((U << shift) / V)
; --------------------------------------------------
      LDX   #$0000
      STX   DIV64_N
      STX   DIV64_N+2
      STX   DIV64_N+4
      STX   DIV64_N+6
; Put U into low 32 bits
      LDX   DIV32_U
      STX   DIV64_N+4
      LDX   DIV32_U+2
      STX   DIV64_N+6
; Shift left by 31 or 32
      LDU   #DIV64_N
      LDB   FP5_DIVSHIFT
      JSR   FP5_Shift_Left64_AtU_B
; Divide DIV64_N by DIV32_V
      JSR   Div_U64_By_U32_NoRounding
; Save quotient as mantissa
      LDX   DIV32_Q
      STX   FP5_MANT
      LDX   DIV32_Q+2
      STX   FP5_MANT+2
; --------------------------------------------------
; Second divide: round8 = floor((remainder << 8) / V)
; --------------------------------------------------
      LDX   #$0000
      STX   DIV64_N
      STX   DIV64_N+2
      STX   DIV64_N+4
      STX   DIV64_N+6
; Put first remainder into low 32 bits
      LDX   DIV32_REM
      STX   DIV64_N+4
      LDX   DIV32_REM+2
      STX   DIV64_N+6
; Shift left by 8
      LDU   #DIV64_N
      LDB   #8
      JSR   FP5_Shift_Left64_AtU_B
; Divide again
      JSR   Div_U64_By_U32_NoRounding
; low byte of quotient = round byte
      LDA   DIV32_Q+3
; sticky = any nonzero second remainder
      LDB   DIV32_REM
      ORB   DIV32_REM+1
      ORB   DIV32_REM+2
      ORB   DIV32_REM+3
      BEQ   @StoreRound
      ORA   #$01
@StoreRound:
      STA   FP5_MANT+4
      RTS


; ------------------------------------------------------------
; Div_U64_By_U32_NoRounding
;
; Input:
;   DIV64_N[0..7]   = 64-bit dividend, MSB..LSB
;   DIV32_V[0..3]   = 32-bit divisor,  MSB..LSB
;
; Output:
;   DIV32_Q[0..3]   = 32-bit quotient, MSB..LSB
;   DIV32_REM[0..3] = 32-bit remainder, MSB..LSB
; ------------------------------------------------------------
Div_U64_By_U32_NoRounding:
; divide by zero guard (unchanged)
      LDD   DIV32_V
      BNE   @DivNotZero
      LDD   DIV32_V+2
      BNE   @DivNotZero
      LDD   #$FFFF
      STD   DIV32_Q
      STD   DIV32_Q+2
      STD   DIV32_REM
      STD   DIV32_REM+2
      RTS
@DivNotZero:
      LDD   DIV64_N
      STD   DIV32_REM
      LDD   DIV64_N+2
      STD   DIV32_REM+2
      LDD   DIV64_N+4
      STD   DIV32_Q
      LDD   DIV64_N+6
      STD   DIV32_Q+2
      LDY   #32
@Loop32:
; Shift combined [REM:QUO] left by 1  (unchanged)
      LDX   #DIV32_Q
      ASL   3,X
      ROL   2,X
      ROL   1,X
      ROL   ,X
      LDX   #DIV32_REM
      ROL   3,X
      ROL   2,X
      ROL   1,X
      ROL   ,X
; === FIXED COMPARE (handles the lost carry) ===
      LDX   #DIV32_REM
      LDU   #DIV32_V
      BCS   @DoSubtract          ; ←←← NEW: carry from ROL = 33rd bit → always >= V
      LDD   ,X
      CMPD  ,U
      BHI   @DoSubtract
      BLO   @NoSubtract
      LDD   2,X
      CMPD  2,U
      BLO   @NoSubtract
@DoSubtract:
; remainder -= divisor  (unchanged)
      LDD   2,X
      SUBD  2,U
      STD   2,X
      LDB   1,X
      SBCB  1,U
      LDA   ,X
      SBCA  ,U
      STD   ,X
; set quotient bit
      LDA   DIV32_Q+3
      ORA   #$01
      STA   DIV32_Q+3
@NoSubtract:
      LEAY  -1,Y
      BNE   @Loop32
      RTS











; ----- Temps for DivFast32 -----
DIV32_V      RMB 4     ; divisor mantissa (32-bit, Q1.31)
DIV32_U      RMB 4     ; dividend mantissa (32-bit, Q1.31)
DIV32_R      RMB 4     ; reciprocal r (Q0.32)
DIV32_T      RMB 4     ; temp t (Q1.31)
DIV32_A      RMB 4     ; temp a = (0 - t) (Q1.31)
DIV32_SP     RMB 2     ; saved stack pointer

; RESULT[0..7] must be produced by Mul_UnSigned_Both_32 (MSB..LSB)
; RESULT      RMB 8

; FP5_MANT is 5 bytes: 4 mantissa bytes + 1 rounding byte
; FP5_MANT    RMB 5


; ------------------------------------------------------------
; DivFast32_To_FP5MANT
; In:
;   DIV32_U = dividend mantissa (32-bit, Q1.31)
;   DIV32_V = divisor  mantissa (32-bit, Q1.31)
; Out:
;   FP5_MANT[0..3] = top 32 bits of quotient (Q1.31)
;   FP5_MANT[4]    = rounding byte (next 8 bits) with sticky ORed into bit0
; Clobbers: A,B,X,Y,U,CC
; ------------------------------------------------------------
; ---- Newton-Raphson iterations ----
NewRap_Iterations FCB   1     ; Default to 1 (fast), change it to 3 or more for accurate LOG/TAN/EXP values 
DivFast32_To_FP5MANT:

; ---- Seed r0 from divisor mantissa top bits ----
; mantissa is Q1.31, so value in [0x80000000..0xFFFFFFFF] => [1,2)
; Use next 5 bits after leading 1 => bits 30..26
; Index = (DIV32_V[0] & %01111100) >> 2
      LDB   DIV32_V           ; We need to ignore bit 7 which is always high
      LSLB                    ; 128 entries and two bytes each
      LDX   #recip128_q016+128      ; Offset into the table so that signed values point to the proper position in the table
      LDD   B,X
      STD   DIV32_R         ; put into high 16 of Q0.32
      CLR   DIV32_R+2
      CLR   DIV32_R+3
; ---- Newton-Raphson iterations ----
;      LDA   NewRap_Iterations
;      PSHS  A
     JSR   @NRStep32     ; 1 iteration, pretty good, very fast
;     JSR   @NRStep32     ; 1 iteration, pretty good, very fast
;     JSR   @NRStep32     ; 1 iteration, pretty good, very fast
;      DEC   ,S
;      BNE   <
;      LEAS  1,S
;
; ---- q = dividend * r  (Q1.31 * Q0.32 => Q1.63 in RESULT) ----
;
    LDX   DIV32_U
    LDU   DIV32_U+2
    PSHS  X,U             ; op1 = dividend
;
    LDX   DIV32_R
    LDU   DIV32_R+2
    PSHS  X,U             ; op2 = r
;
    JSR   Mul_UnSigned_Both_32    ; Multiply ,S * 4,S result @ ,S and 64 bit result at RESULT
      LEAS  4,S         ; restore stack no matter what Mul does
;
; RESULT = 64-bit product (MSB..LSB)
; Take top 32 bits as mantissa candidate
    LDX   RESULT
    STX   FP5_MANT
    LDX   RESULT+2
    STX   FP5_MANT+2
;
; rounding byte = next 8 bits
    LDA   RESULT+4
; sticky = OR of remaining bytes RESULT+5..7 into bit0
    LDB   RESULT+5
    ORB   RESULT+6
    ORB   RESULT+7
    BEQ   >
    ORA   #$01
!
    STA   FP5_MANT+4
    RTS
;
; ------------------------------------------------------------
; @NRStep32: r = r * (2 - v*r)
; v = DIV32_V (Q1.31)
; r = DIV32_R (Q0.32)
; Uses:
;   t = (v*r)>>32  (Q1.31) stored in DIV32_T
;   a = (0 - t)    (Q1.31) stored in DIV32_A    [because 2.0 wraps to 0 in mod 32-bit]
;   r = (r*a)>>31  (Q0.32) updated in DIV32_R
; ------------------------------------------------------------
@NRStep32:
; ---- t = (v * r) >> 32  (take top 32 of 64-bit product) ----
;
    LDX   DIV32_V
    LDU   DIV32_V+2
    PSHS  X,U             ; op1 = v
;
    LDX   DIV32_R
    LDU   DIV32_R+2
    PSHS  X,U             ; op2 = r
;
    JSR   Mul_UnSigned_Both_32    ; Multiply ,S * 4,S result @ ,S and 64 bit result at RESULT
      LEAS  4,S         ; restore stack no matter what Mul does
;
    LDX   RESULT
    STX   DIV32_T
    LDX   RESULT+2
    STX   DIV32_T+2
;
; ---- a = (0 - t)  (32-bit two's complement) ----
    ; high word
    LDD   DIV32_T
    COMA
    COMB
    STD   DIV32_A
    ; low word
    LDD   DIV32_T+2
    COMA
    COMB
    STD   DIV32_A+2
      INC   DIV32_A+3
      BNE   >
      INC   DIV32_A+2
      BNE   >
      INC   DIV32_A+1
      BNE   >
      INC   DIV32_A
!
;
; ---- r = (r * a) >> 31  (Q0.32) ----
; Compute 64-bit product in RESULT, then do a true <<1 and take top 32.
;
    LDX   DIV32_R
    LDU   DIV32_R+2
    PSHS  X,U             ; op1 = r
;
    LDX   DIV32_A
    LDU   DIV32_A+2
    PSHS  X,U             ; op2 = a
;
    JSR   Mul_UnSigned_Both_32    ; Multiply ,S * 4,S result @ ,S and 64 bit result at RESULT
      LEAS  4,S         ; restore stack no matter what Mul does
;
; Shift RESULT left by 1 bit (64-bit) so that taking top32 equals >>31
    LSL   RESULT+7
    ROL   RESULT+6
    ROL   RESULT+5
    ROL   RESULT+4
    ROL   RESULT+3
    ROL   RESULT+2
    ROL   RESULT+1
    ROL   RESULT+0
;
; New r = top32
    LDX   RESULT
    STX   DIV32_R
    LDX   RESULT+2
    STX   DIV32_R+2
    RTS

; recip128_q016[i] ~= round((1/x)*65536), x in [1,2)
; index i = (mantissa_msb_byte & $7F)   ; bits30..24

recip128_q016:
; 64 to 127
    FCB $A8,$19,$A7,$09,$A5,$FA,$A4,$EC,$A3,$DE,$A2,$D1,$A1,$C4,$A0,$B8 ; 064-071
    FCB $9F,$AC,$9E,$A1,$9D,$96,$9C,$8B,$9B,$81,$9A,$77,$99,$6D,$98,$64 ; 072-079
    FCB $97,$5B,$96,$52,$95,$49,$94,$41,$93,$39,$92,$31,$91,$29,$90,$22 ; 080-087
    FCB $8F,$1A,$8E,$13,$8D,$0C,$8C,$05,$8B,$FE,$8A,$F8,$89,$F1,$88,$EB ; 088-095
    FCB $87,$E5,$86,$DF,$85,$D9,$84,$D3,$83,$CD,$82,$C7,$81,$C1,$80,$BC ; 096-103
    FCB $7F,$B6,$7E,$B1,$7D,$AC,$7C,$A7,$7B,$A2,$7A,$9D,$79,$99,$78,$94 ; 104-111
    FCB $77,$90,$76,$8C,$75,$88,$74,$84,$73,$80,$72,$7C,$71,$79,$70,$75 ; 112-119
    FCB $83,$DD,$83,$56,$82,$CF,$82,$4A,$81,$C6,$81,$43,$80,$C1,$80,$40 ; 120-127
; 0 to 63
    FCB $FF,$01,$FD,$09,$FB,$19,$F9,$30,$F7,$4E,$F5,$74,$F3,$A1,$F1,$D5 ; 000-007
    FCB $F0,$10,$EE,$52,$EC,$9B,$EA,$EB,$E9,$41,$E7,$9E,$E6,$01,$E4,$6A ; 008-015
    FCB $E2,$D9,$E1,$4E,$DF,$C8,$DE,$48,$DC,$CE,$DB,$5A,$D9,$EB,$D8,$81 ; 016-023
    FCB $D7,$1C,$D5,$BB,$D4,$5F,$D3,$07,$D1,$B3,$D0,$63,$CF,$17,$CD,$CE ; 024-031
    FCB $CC,$89,$CB,$47,$CA,$08,$C8,$CC,$C7,$93,$C6,$5C,$C5,$28,$C3,$F6 ; 032-039
    FCB $C2,$C6,$C1,$98,$C0,$6C,$BF,$42,$BE,$1A,$BC,$F3,$BB,$CF,$BA,$AC ; 040-047
    FCB $B9,$8B,$B8,$6B,$B7,$4C,$B6,$2F,$B5,$13,$B3,$F8,$B2,$DF,$B1,$C7 ; 048-055
    FCB $B0,$B0,$AF,$9A,$AE,$85,$AD,$71,$AC,$5E,$AB,$4C,$AA,$3A,$A9,$29 ; 056-063







      INCLUDE ./Math_Floating_Point5_Extra.asm