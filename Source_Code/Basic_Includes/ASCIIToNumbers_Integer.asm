; Integer-only ASCII conversion used by INPUT and READ/DATA builds compiled
; with -i. This deliberately has no references to any floating-point library.
;
; X points at comma-terminated ASCII text. The selected entry point pushes a
; 1, 2, 4, or 8-byte two's-complement result on S. Decimal overflow retains
; the compiler's normal wraparound behavior for the destination width.

ASCII_To_S8_Stack:
        LDB     #1
        BRA     ASCII_To_SIntN_Stack
ASCII_To_S16_Stack:
        LDB     #2
        BRA     ASCII_To_SIntN_Stack
ASCII_To_S32_Stack:
        LDB     #4
        BRA     ASCII_To_SIntN_Stack
ASCII_To_S64_Stack:
        LDB     #8

ASCII_To_SIntN_Stack:
        PULS    U                       ; preserve return outside result area
        STU     ASCIIIntReturn+1
        LDY     #0                      ; nonzero marks a negative value
ASCIIIntSkipSpaces:
        LDA     ,X
        CMPA    #' '
        BNE     ASCIIIntCheckSign
        LEAX    1,X
        BRA     ASCIIIntSkipSpaces
ASCIIIntCheckSign:
        LDA     ,X
        CMPA    #'-'
        BNE     ASCIIIntCheckPlus
        LDY     #$0080
        LEAX    1,X
        BRA     ASCIIIntAllocate
ASCIIIntCheckPlus:
        CMPA    #'+'
        BNE     ASCIIIntAllocate
        LEAX    1,X

; Allocate and clear a big-endian accumulator of B bytes on the stack.
ASCIIIntAllocate:
        TFR     B,A
ASCIIIntClear:
        CLR     ,-S
        DECA
        BNE     ASCIIIntClear
        TFR     S,U

ASCIIIntParse:
        LDA     ,X
        CMPA    #','
        BEQ     ASCIIIntParsed
        CMPA    #'.'                    ; integer INPUT truncates at decimal
        BEQ     ASCIIIntParsed
        CMPA    #'0'
        BLO     ASCIIIntParsed
        CMPA    #'9'
        BHI     ASCIIIntParsed
        SUBA    #'0'
        JSR     ASCIIIntegerMul10Add
        LEAX    1,X
        BRA     ASCIIIntParse

; INPUTCode always terminates each field with a comma. Advance to the next
; field even when parsing stopped at a decimal point or invalid character.
ASCIIIntParsed:
!       LDA     ,X+
        CMPA    #','
        BNE     <
        STX     Temp3
        CMPY    #0
        BEQ     ASCIIIntReturn

; Negate the width-byte accumulator in place.
        TFR     B,A
        TFR     U,X
ASCIIIntInvert:
        COM     ,X+
        DECA
        BNE     ASCIIIntInvert
        TFR     B,A
ASCIIIntAddOne:
        LEAX    -1,X
        INC     ,X
        BNE     ASCIIIntReturn
        DECA
        BNE     ASCIIIntAddOne
ASCIIIntReturn:
        JMP     >$FFFF

; U -> big-endian B-byte accumulator, A=digit. Compute acc=acc*10+digit.
; Overflow wraps modulo the selected integer width.
ASCIIIntegerMul10Add:
        PSHS    D,X,Y,U                 ; saved A=digit, B=width
        CLR     ,-S                     ; byte carry
        LDB     2,S
        TFR     U,X
        DECB
        BEQ     ASCIIIntAtLSB
ASCIIIntFindLSB:
        LEAX    1,X
        DECB
        BNE     ASCIIIntFindLSB
ASCIIIntAtLSB:
        TFR     X,Y
ASCIIIntMultiply:
        LDA     ,X
        LDB     #10
        MUL
        ADDB    ,S
        ADCA    #0
        STB     ,X
        STA     ,S
        LEAX    -1,X
        CMPX    7,S                     ; saved U is accumulator base
        BHS     ASCIIIntMultiply

        TFR     Y,X
        LDA     ,X
        ADDA    1,S                     ; saved digit
        STA     ,X
        BCC     ASCIIIntDone
ASCIIIntCarry:
        CMPX    7,S
        BEQ     ASCIIIntDone            ; discard carry past the MSB
        LEAX    -1,X
        INC     ,X
        BEQ     ASCIIIntCarry
ASCIIIntDone:
        LEAS    1,S
        PULS    D,X,Y,U,PC
