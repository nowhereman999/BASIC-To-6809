; Optional FujiNet hashing support. Algorithms follow the firmware enum:
; 0=MD5, 1=SHA-1, 2=SHA-256, 3=SHA-512. String functions request the
; hexadecimal form, whose maximum result is SHA-512's 128 bytes.

FN_HASH_CMD_INPUT           EQU     $C8
FN_HASH_CMD_COMPUTE         EQU     $C7
FN_HASH_CMD_OUTPUT          EQU     $C5
FN_HASH_CMD_COMPUTE_KEEP    EQU     $C3
FN_HASH_CMD_CLEAR           EQU     $C2
FN_HASH_MODE_HEX            EQU     1

FN_HashAlgorithm            FCB     0
FN_HashDiscard              FCB     0
FN_HashLength               FCB     0

FN_HashClear:
        LDA     #FN_HASH_CMD_CLEAR
        JMP     FN_FujiSimpleCommand

; Add the binary-safe length-prefixed PF00 string to FujiNet's hash buffer.
FN_HashAdd:
        LDA     _StrVar_PF00
        BEQ     FN_HashEmptyAdd
        STA     FN_HashLength
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_HASH_CMD_INPUT
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA           ; uint16 length, big endian
        LDA     FN_HashLength
        STA     >FN_BECKER_DATA
        LDX     #_StrVar_PF00+1
        LDB     FN_HashLength
FN_HashAddLoop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_HashAddLoop
        JMP     FN_FujiGetError
FN_HashEmptyAdd:
        CLR     FN_LastError               ; adding no bytes is a successful no-op
        CLRA
        ANDCC   #$FE
        RTS

; Send COMPUTE or COMPUTE_NO_CLEAR for FN_HashAlgorithm.
FN_HashCompute:
        LDA     FN_HashDiscard
        BEQ     FN_HashComputeKeep
        LDA     #FN_HASH_CMD_COMPUTE
        BRA     FN_HashComputeSend
FN_HashComputeKeep:
        LDA     #FN_HASH_CMD_COMPUTE_KEEP
FN_HashComputeSend:
        STA     FN_FujiSavedCommand
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     FN_FujiSavedCommand
        STA     >FN_BECKER_DATA
        LDA     FN_HashAlgorithm           ; one-byte Hash::Algorithm parameter
        STA     >FN_BECKER_DATA
        JMP     FN_FujiGetError

; Fetch the hexadecimal hash into PF00 and return it as a BASIC string.
FN_HashOutputString:
        LDB     FN_HashAlgorithm
        BEQ     FN_HashLengthMD5
        CMPB    #1
        BEQ     FN_HashLengthSHA1
        CMPB    #2
        BEQ     FN_HashLengthSHA256
        LDB     #128                       ; SHA-512 hex
        BRA     FN_HashLengthReady
FN_HashLengthMD5:
        LDB     #32
        BRA     FN_HashLengthReady
FN_HashLengthSHA1:
        LDB     #40
        BRA     FN_HashLengthReady
FN_HashLengthSHA256:
        LDB     #64
FN_HashLengthReady:
        STB     FN_HashLength

        JSR     FN_DrainInput
        LBCS    FN_HashStringError
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_HASH_CMD_OUTPUT
        STA     >FN_BECKER_DATA
        LDA     #FN_HASH_MODE_HEX
        STA     >FN_BECKER_DATA
        JSR     FN_FujiGetError
        BCS     FN_HashStringError
        LDB     FN_HashLength
        STB     _StrVar_PF00
        CLRA
        LDX     #_StrVar_PF00+1
        JSR     FN_FujiGetResponse
        BCS     FN_HashStringError
        JMP     FN_ReturnScratchString

; B=algorithm, PF00=data. Clear/add/compute/output convenience function.
FN_HashString:
        CMPB    #4
        BHS     FN_HashStringBadArgument
        STB     FN_HashAlgorithm
        LDA     #1
        STA     FN_HashDiscard
        JSR     FN_HashClear
        BCS     FN_HashStringError
        JSR     FN_HashAdd
        BCS     FN_HashStringError
        JSR     FN_HashCompute
        BCS     FN_HashStringError
        BRA     FN_HashOutputString

; B=algorithm, FN_HashDiscard=0 keeps accumulated input, nonzero discards it.
FN_HashCalcString:
        CMPB    #4
        BHS     FN_HashStringBadArgument
        STB     FN_HashAlgorithm
        JSR     FN_HashCompute
        BCS     FN_HashStringError
        BRA     FN_HashOutputString

FN_HashStringBadArgument:
        JSR     FN_FujiBadArgument
FN_HashStringError:
        CLR     _StrVar_PF00
        JMP     FN_ReturnScratchString
