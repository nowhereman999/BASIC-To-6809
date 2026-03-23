

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
      RORA              ; Move sign bit from the carry to MSbit of A
      STA   ,S          ; Save the Sign
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
      STD   3,S         ; Save mantissa bits
      LDD   #$0000
      STD   6,S
      STD   8,S
@Return:
      JMP   >$FFFF      ; Return, self modified jump address
@Special:
      LDA   #%10000000  ; Flag double value as special
!     CLRB
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
