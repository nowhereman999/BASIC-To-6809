

; 
; 5 byte Fast Floating Point (FP5) format
; SEEEEEEE|MMMMMMMM|MMMMMMMM|MMMMMMMM|MMMMMMMM
;
; Convert 5 byte FP5 at ,S to 10 byte Double at ,S
FP5_To_Double:
      PULS  U           ; Get return address
      STU   @Return+1   ; Self mod return address
;
      CLRA              ; Clear the sign
      LDB   ,S          ; B = Sign & Exponent byte
      LEAS  -5,S        ; Make room for a 10 byte Double number on the stack
      LSLB              ; Carry = sign bit
      RORA              ; Move sign bit from the carry to MSbit of A
      STA   ,S          ; Save the Sign
      CMPB  #$80        ; See if we were $40 (special)
      BEQ   @Special    ; save Double as a special
      ASRB              ; Make Exponent 8 bit
      SEX               ; Sign Extend B to 16 bit value in D
      STD   1,S         ; Save exponent
      LDD   6,S         ; Get Mantissa MS Word
      LDX   8,S         ; Get Mantissa LS Word
      CLR   7,S
      STX   5,S         ; Save Mantissa LW Word so we can shift it right
      LSRA
      RORB
      ROR   5,S
      ROR   6,S
      ROR   7,S
      LSRA
      RORB
      ROR   5,S
      ROR   6,S
      ROR   7,S
      LSRA
      RORB
      ROR   5,S
      ROR   6,S
      ROR   7,S
      STD   3,S         ; Save mantissa bits
      LDD   #$0000
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

; Convert 10 byte Double at ,S to 5 Byte FP5 at ,S
; In :  ,S..9,S = Double (your 10-byte format)
; Out:  ,S..4,S = FP5 (B,X,U)  where:
;       byte0 = sign|exp (sign in bit7, exp in bits6..0 as signed 7-bit)
;       bytes1..4 = 32-bit mantissa (MSB always 1 for normal numbers)
;
Double_To_FP5:
    PULS    U
    STU     @Return+1
;
; ---- exponent range check (same style as your FFP routine) ----
    LDD     1,S
    CMPD    #$003F
    LBGT     @ExpTooBig
    CMPD    #-$003F
    LBLT     @ExpTooSmall
;
; ==============================================================
; Align mantissa so we can take the TOP 32 bits for FP5 and round
; You previously shifted only 3..5; for FP5 we shift across 3..9.
; Do the same 3-bit left alignment you were doing before:
;   shift left 3 bits across bytes 3..9
; ==============================================================
@GoodNumber:
    ; Shift left 1 across 3..9  (repeat 3 times)
    LSL     9,S
    ROL     8,S
    ROL     7,S
    ROL     6,S
    ROL     5,S
    ROL     4,S
    ROL     3,S
;
    LSL     9,S
    ROL     8,S
    ROL     7,S
    ROL     6,S
    ROL     5,S
    ROL     4,S
    ROL     3,S
;
    LSL     9,S
    ROL     8,S
    ROL     7,S
    ROL     6,S
    ROL     5,S
    ROL     4,S
    ROL     3,S
;
; ==============================================================
; Now bytes 3..6 are the candidate 32-bit mantissa to keep.
; byte 7 is the "next" byte (contains guard/round/sticky bits).
; bytes 8..9 contribute to sticky.
;
; Rounding (ties-to-even) on the 32-bit mantissa:
;   guard  = bit7 of 7,S
;   round  = bit6 of 7,S
;   sticky = OR(bits5..0 of 7,S, 8,S, 9,S)
; If guard=1 and (round|sticky|LSB_kept)=1 => increment mantissa.
; If mantissa overflows => normalize and bump exponent.
; ==============================================================
;
    ; Build sticky in A (we’ll keep A as "hasSticky" flag in bit0)
    LDA     7,S                 ; guard/round/sticky byte
    ANDA    #%00111111          ; bits5..0 -> sticky sources
    ORA     8,S
    ORA     9,S
    BEQ     @StickyZero
    LDA     #$01                ; sticky flag
    BRA     @HaveSticky
@StickyZero:
;    CLRA
@HaveSticky:
    ; At this point:
    ;   A = 0 if sticky=0, A=1 if sticky=1
;
    ; Test guard bit (bit7 of 7,S)
    LDB     7,S
;    BITB    #%10000000
;    BEQ     @SkipRound          ; guard=0 => no rounding
      BPL   @SkipRound          ; guard=0 => no rounding
    ; guard=1, now check round or sticky or LSB-kept
    ; round bit = bit6 of 7,S
    BITB    #%01000000
    BNE     @DoInc              ; round=1 => increment
;
    ; round=0, check sticky flag in A
    TSTA
    BNE     @DoInc              ; sticky=1 => increment
;
    ; sticky=0 too => exactly halfway
    ; ties-to-even: increment only if LSB of mantissa is 1
    LDB     6,S                 ; low byte of kept mantissa
    BITB    #%00000001
    BEQ     @SkipRound
@DoInc:
    ; Increment 32-bit mantissa at 3..6
    INC     6,S
    BNE     @SkipRound
    INC     5,S
    BNE     @SkipRound
    INC     4,S
    BNE     @SkipRound
    INC     3,S
    BNE     @SkipRound
;
    ; Mantissa overflowed from FFFFFFFF -> 00000000
    ; Normalize: mant = 80000000 and exponent++
    LDA     #$80
    STA     3,S
    CLR     4,S
    CLR     5,S
    CLR     6,S
;
    LDD     1,S
    ADDD    #$0001
    CMPD    #$0040
    BGE     @ExpTooBig
    STD     1,S
;
@SkipRound:
;
; ==============================================================
; Pack FP5: exponent is in your double at 1,S (signed).
; FP5 byte0 format you’ve been using elsewhere:
;   B = exp (signed 8-bit), then LSLB, then merge sign via RORB trick.
; We'll load exp into B (8-bit), then pack with sign bit from ,S.
; ==============================================================
    ; Take exponent low byte (your exp appears small and fits)
    LDB     2,S                 ; exponent byte (same as your old routine)
    ANDB    #%01111111          ; strip sign bit if present (matching your style)
;
      LSLB
    ; Merge sign bit from ,S into bit7 of packed byte0
      ROL   ,S                ; Move sign bit to the carry
      RORB                    ; Fix B and shift sign bit into bit 7
;
    ; Load mantissa 32-bit from 3..6 into X,U (big-endian)
    LDX     3,S                 ; mantissa high 16
    LDU     5,S                 ; mantissa low  16
;
    ; Drop Double (10 bytes) and push FP5 (5 bytes)
    LEAS    10,S
    PSHS    B,X,U
@Return:
    JMP     >$FFFF
;
; ==============================================================
; Specials: keep your existing meanings but emit 5-byte FP5
; Infinity: "special flag" in bit6 (like your other code), mantissa=0
; NaN: special flag + mantissa MSB set
; ==============================================================
@ExpTooBig:
    ; +Infinity
    LDB     #%01000000          ; special + positive
!   LDX     #$0000
    LDU     #$0000
    LEAS    10,S
    PSHS    B,X,U
    BRA     @Return
;
@ExpTooSmall:
    ; -Infinity (your old routine did this)
    LDB     #%11000000          ; special + negative
    BRA     <