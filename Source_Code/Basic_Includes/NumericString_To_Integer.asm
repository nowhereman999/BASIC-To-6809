VALI_Flags      RMB     1   ; bit0 = overflow/saturated, bit7 = negative sign seen
VALI_Len        RMB     1   ; remaining chars
VALI_Digit      RMB     1   ; current digit 0..9

VALI_Mag0       RMB     1   ; 32-bit magnitude MSB
VALI_Mag1       RMB     1
VALI_Mag2       RMB     1
VALI_Mag3       RMB     1   ; 32-bit magnitude LSB

VALI_Tmp0       RMB     1   ; temp copy for *10
VALI_Tmp1       RMB     1
VALI_Tmp2       RMB     1
VALI_Tmp3       RMB     1

; ------------------------------------------------------------
; Integer-targeted numeric string parsers for VAL() context
;
; Input string format on stack:
;   ,S     = length byte
;   1,S... = characters
;
; Public entry points:
;   NumericString_To_U8_Stack
;   NumericString_To_S8_Stack
;   NumericString_To_U16_Stack
;   NumericString_To_S16_Stack
;   NumericString_To_U32_Stack
;   NumericString_To_S32_Stack
;
; Behaviour:
;   - skips leading spaces / tabs
;   - optional + or -
;   - parses decimal digits, or hex digits if prefixed with &H / &h
;   - stops at first non-digit / non-hex-digit
;   - empty / invalid => 0
;
; Returned stack result:
;   U8/S8   =>  8-bit at ,S
;   U16/S16 => 16-bit at ,S
;   U32/S32 => 32-bit using PSHS D,X convention
; ------------------------------------------------------------

; ============================================================
; NumericString_To_U8_Stack
; ============================================================
NumericString_To_U8_Stack:
NumericString_To_S8_Stack:
        PULS    U
        BSR     ParseIntegerPrefixToU32
        ; Drop original string from stack
        LDB     ,S
        CLRA
        ADDD    #1
        LEAS    D,S
        ; If negative, convert magnitude to 32-bit two's complement
        LDA     VALI_Flags
        BPL     @PushLow8
        BSR     NegateMag32
@PushLow8
        ; Return low 8 bits exactly
        LDB     VALI_Mag3
        PSHS    B
        JMP     ,U

; ============================================================
; NumericString_To_U16_Stack
; ============================================================
NumericString_To_U16_Stack:
NumericString_To_S16_Stack:
        PULS    U
        BSR     ParseIntegerPrefixToU32
        ; Drop original string from stack
        LDB     ,S
        CLRA
        ADDD    #1
        LEAS    D,S
        ; If negative, convert magnitude to 32-bit two's complement
        LDA     VALI_Flags
        BPL     @PushLow16
        BSR     NegateMag32
@PushLow16
        ; Return low 16 bits exactly
        LDD     VALI_Mag2
        PSHS    D
        JMP     ,U

; ============================================================
; NumericString_To_U32_Stack
; ============================================================
NumericString_To_U32_Stack:
NumericString_To_S32_Stack:
        PULS    U                   ; save return address
        BSR     ParseIntegerPrefixToU32
        ; Drop original string from stack
        LDB     ,S
        CLRA
        ADDD    #1
        LEAS    D,S
        ; If negative: return two's complement modulo 32-bit
        LDA     VALI_Flags
        BPL     @Push32
        BSR     NegateMag32
@Push32
        LDD     VALI_Mag0           ; MSW
        LDX     VALI_Mag2           ; LSW
        PSHS    D,X
        JMP     ,U


; ============================================================
; NegateMag32
;
; VALI_Mag = two's complement of VALI_Mag
;
; Input:
;   VALI_Mag0..3 = 32-bit magnitude
;
; Output:
;   VALI_Mag0..3 = negated 32-bit value
;
; Notes:
;   This does:
;     1) bitwise invert all 4 bytes
;     2) add 1 to the 32-bit value
; ============================================================
NegateMag32:
        COM     VALI_Mag0     ; Invert MSB
        COM     VALI_Mag1
        COM     VALI_Mag2
        COM     VALI_Mag3     ; Invert LSB
        INC     VALI_Mag3     ; Add 1 to low byte
        BNE     @Done         ; If no carry, finished
        INC     VALI_Mag2     ; Carry into next byte
        BNE     @Done         ; If no carry, finished
        INC     VALI_Mag1     ; Carry into next byte
        BNE     @Done         ; If no carry, finished
        INC     VALI_Mag0     ; Carry into top byte
@Done
        RTS
; ============================================================
; ParseIntegerPrefixToU32
;
; Input:
;   string at ,S
;   Format expected on stack:
;     ,S   = length byte
;     1,S  = first character
;     2,S  = second character
;     ...
;
; Output:
;   VALI_Mag0..3 = parsed unsigned 32-bit magnitude
;                  Mag0 = MSB, Mag3 = LSB
;   VALI_Flags bit7 = negative sign was seen
;   VALI_Flags bit0 = overflow/saturated to $FFFFFFFF
;
; Notes:
;   - parses the integer decimal prefix, or hexadecimal if prefixed by &H / &h
;   - ignores leading spaces/tabs
;   - accepts optional + or -
;   - stops at first non-digit / non-hex-digit
; ============================================================
ParseIntegerPrefixToU32:
      CLRB
      STB     VALI_Flags
      STB     VALI_Digit
      STB     VALI_Mag0
      STB     VALI_Mag1
      STB     VALI_Mag2
      STB     VALI_Mag3
      LDB     2,S
      STB     VALI_Len
      LEAX    3,S
@SkipLead
      LDB     VALI_Len
      BEQ     @Done
      LDA     ,X
      CMPA    #' '
      BEQ     @ConsumeLead
      CMPA    #9
      BEQ     @ConsumeLead
      BRA     @CheckSign
@ConsumeLead
      LEAX    1,X
      DEC     VALI_Len
      BRA     @SkipLead
@CheckSign
      LDB     VALI_Len
      BEQ     @Done
      LDA     ,X
      CMPA    #'+'
      BEQ     @ConsumeSign
      CMPA    #'-'
      BNE     @CheckHexPrefix
      LDA     VALI_Flags
      ORA     #%10000000
      STA     VALI_Flags
@ConsumeSign
      LEAX    1,X
      DEC     VALI_Len
@CheckHexPrefix
      LDB     VALI_Len
      CMPB    #2
      BLO     @DigitLoopStart
      LDA     ,X
      CMPA    #'&'
      BNE     @DigitLoopStart
      LDA     1,X
      CMPA    #'H'
      BEQ     @ConsumeHexPrefix
      CMPA    #'h'
      BNE     @DigitLoopStart
@ConsumeHexPrefix
      LEAX    2,X
      LDB     VALI_Len
      SUBB    #2
      STB     VALI_Len
      BRA     @HexLoopStart
@DigitLoopStart
      LDB     VALI_Len
      BEQ     @Done
@DigitLoop
      LDB     VALI_Len
      BEQ     @Done
      LDA     ,X
      CMPA    #'0'
      BLO     @Done
      CMPA    #'9'
      BHI     @Done
      SUBA    #'0'
      STA     VALI_Digit
      BSR     Mul10AddDigit_U32
      LEAX    1,X
      DEC     VALI_Len
      BRA     @DigitLoop
@HexLoopStart
      LDB     VALI_Len
      BEQ     @Done
@HexLoop
      LDB     VALI_Len
      BEQ     @Done
      LDA     ,X
      CMPA    #'0'
      BLO     @Done
      CMPA    #'9'
      BLS     @HexIs09
      CMPA    #'A'
      BLO     @HexCheckLower
      CMPA    #'F'
      BLS     @HexIsAF
@HexCheckLower
      CMPA    #'a'
      BLO     @Done
      CMPA    #'f'
      BHI     @Done
      SUBA    #('a' - 10)
      BRA     @HexHaveDigit
@HexIsAF
      SUBA    #('A' - 10)
      BRA     @HexHaveDigit
@HexIs09
      SUBA    #'0'
@HexHaveDigit
      STA     VALI_Digit
      BSR     Mul16AddDigit_U32
      LEAX    1,X
      DEC     VALI_Len
      BRA     @HexLoop
@Done
      RTS

; ============================================================
; Mul10AddDigit_U32
;
; VALI_Mag = VALI_Mag * 10 + VALI_Digit
;
; Input:
;   VALI_Mag0..3 = current unsigned 32-bit value
;   VALI_Digit   = new decimal digit (0..9)
;
; Output:
;   VALI_Mag0..3 updated
;
; Behavior on overflow:
;   Saturates result to $FFFFFFFF
;   Sets bit0 in VALI_Flags
;
; Internal idea:
;   x * 10 = x * 2 + x * 8
; ============================================================
Mul10AddDigit_U32:
        ; If overflow already happened earlier, keep value saturated
        LDA     VALI_Flags
        BITA    #%00000001
;        LBNE    @SatReturn    ; Already overflowed -> do nothing more
        BEQ     >
        RTS
        ; Copy current magnitude to temp
        ; tmp = mag
!       LDD     VALI_Mag0
        STD     VALI_Tmp0
        LDD     VALI_Mag2
        STD     VALI_Tmp2
        ; mag = mag * 2
        ; Shift left low->high with carry propagation
        LSL     VALI_Mag3
        ROL     VALI_Mag2
        ROL     VALI_Mag1
        ROL     VALI_Mag0
        BCS     @Saturate     ; Carry out of top bit -> overflow
        ; tmp = tmp * 8
        ; Do three left shifts
        LSL     VALI_Tmp3
        ROL     VALI_Tmp2
        ROL     VALI_Tmp1
        ROL     VALI_Tmp0
        BCS     @Saturate
        LSL     VALI_Tmp3
        ROL     VALI_Tmp2
        ROL     VALI_Tmp1
        ROL     VALI_Tmp0
        BCS     @Saturate
        LSL     VALI_Tmp3
        ROL     VALI_Tmp2
        ROL     VALI_Tmp1
        ROL     VALI_Tmp0
        BCS     @Saturate
        ; mag = mag + tmp
        ; Now mag = x*2 + x*8 = x*10
        LDD     VALI_Mag2
        ADDD    VALI_Tmp2
        STD     VALI_Mag2
        LDA     VALI_Mag1
        ADCA    VALI_Tmp1
        STA     VALI_Mag1
        LDA     VALI_Mag0
        ADCA    VALI_Tmp0
        STA     VALI_Mag0
        BCS     @Saturate     ; Carry out -> overflow
        ; mag = mag + digit
        ; Add digit into low byte, propagate carry upward
        LDA     VALI_Mag3
        ADDA    VALI_Digit
        STA     VALI_Mag3
        BCC       >           ; Success, no overflow
        INC     VALI_Mag2
        BNE       >           ; Success, no overflow
        INC     VALI_Mag1
        BNE       >           ; Success, no overflow
        INC     VALI_Mag0
        BNE       >           ; Success, no overflow
; Fall through if we saturated
@Saturate
        ; Clamp parsed value to max unsigned 32-bit
        LDA     #$FF
        STA     VALI_Mag0
        STA     VALI_Mag1
        STA     VALI_Mag2
        STA     VALI_Mag3
        ; Remember overflow happened
        LDA     VALI_Flags
        ORA     #%00000001    ; Set overflow flag bit0
        STA     VALI_Flags
!       RTS                   ; Success, no overflow

; ============================================================
; Mul16AddDigit_U32
;
; VALI_Mag = VALI_Mag * 16 + VALI_Digit
;
; Input:
;   VALI_Mag0..3 = current unsigned 32-bit value
;   VALI_Digit   = new hex digit (0..15)
;
; Output:
;   VALI_Mag0..3 updated
;
; Behavior on overflow:
;   Saturates result to $FFFFFFFF
;   Sets bit0 in VALI_Flags
; ============================================================
Mul16AddDigit_U32:
        ; If overflow already happened earlier, keep value saturated
        LDA     VALI_Flags
        BITA    #%00000001
        BEQ     >
        RTS
        ; mag = mag * 16  (4 left shifts)
!       LSL     VALI_Mag3
        ROL     VALI_Mag2
        ROL     VALI_Mag1
        ROL     VALI_Mag0
        BCS     @Saturate
        LSL     VALI_Mag3
        ROL     VALI_Mag2
        ROL     VALI_Mag1
        ROL     VALI_Mag0
        BCS     @Saturate
        LSL     VALI_Mag3
        ROL     VALI_Mag2
        ROL     VALI_Mag1
        ROL     VALI_Mag0
        BCS     @Saturate
        LSL     VALI_Mag3
        ROL     VALI_Mag2
        ROL     VALI_Mag1
        ROL     VALI_Mag0
        BCS     @Saturate
        ; mag = mag + digit
        LDA     VALI_Mag3
        ADDA    VALI_Digit
        STA     VALI_Mag3
        BCC     @Done
        INC     VALI_Mag2
        BNE     @Done
        INC     VALI_Mag1
        BNE     @Done
        INC     VALI_Mag0
        BNE     @Done
@Saturate
        LDA     #$FF
        STA     VALI_Mag0
        STA     VALI_Mag1
        STA     VALI_Mag2
        STA     VALI_Mag3
        LDA     VALI_Flags
        ORA     #%00000001
        STA     VALI_Flags
@Done
        RTS

; Fake doing U64 versions
NumericString_To_S64_Stack:
      PULS  Y
      JSR   NumericString_To_U32_Stack    ; do 32 bit version
      LDB   ,S                ; Get the 32 bit number sign
      SEX                     ; extended it to 64 bit
      TFR   A,B
!     PSHS  D
      PSHS  D
      JMP   ,Y

NumericString_To_U64_Stack:
      PULS  Y
      JSR   NumericString_To_U32_Stack    ; do 32 bit version
      LDD   #$0000
      BRA   <