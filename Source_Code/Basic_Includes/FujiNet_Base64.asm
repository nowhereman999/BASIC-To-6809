; Optional FujiNet Base64 encode/decode support.
;
; The current DriveWire protocol uses a BE16 byte count on INPUT and OUTPUT.
; LENGTH returns a four-byte big-endian native CoCo value. BASIC strings hold
; at most 254 bytes, so encoding rejects input longer than 189 bytes (190
; would produce 256 Base64 characters), and decoding caps encoded input at
; the largest complete four-character group that fits, 252 bytes.

FN_BASE64_CMD_ENCODE_INPUT      EQU     $D0
FN_BASE64_CMD_ENCODE_COMPUTE    EQU     $CF
FN_BASE64_CMD_ENCODE_LENGTH     EQU     $CE
FN_BASE64_CMD_ENCODE_OUTPUT     EQU     $CD
FN_BASE64_CMD_DECODE_INPUT      EQU     $CC
FN_BASE64_CMD_DECODE_COMPUTE    EQU     $CB
FN_BASE64_CMD_DECODE_LENGTH     EQU     $CA
FN_BASE64_CMD_DECODE_OUTPUT     EQU     $C9

FN_Base64InputCommand           FCB     0
FN_Base64ComputeCommand         FCB     0
FN_Base64LengthCommand          FCB     0
FN_Base64OutputCommand          FCB     0
FN_Base64InputLength            FCB     0
FN_Base64OutputLength           FCB     0

FN_Base64EncodeString:
        LDA     _StrVar_PF00
        CMPA    #190
        LBHS    FN_Base64StringBadArgument
        LDA     #FN_BASE64_CMD_ENCODE_INPUT
        STA     FN_Base64InputCommand
        LDA     #FN_BASE64_CMD_ENCODE_COMPUTE
        STA     FN_Base64ComputeCommand
        LDA     #FN_BASE64_CMD_ENCODE_LENGTH
        STA     FN_Base64LengthCommand
        LDA     #FN_BASE64_CMD_ENCODE_OUTPUT
        STA     FN_Base64OutputCommand
        BRA     FN_Base64Transform

FN_Base64DecodeString:
        LDA     _StrVar_PF00
        CMPA    #253
        LBHS    FN_Base64StringBadArgument ; longest BASIC-safe Base64 text is 252
        LDA     #FN_BASE64_CMD_DECODE_INPUT
        STA     FN_Base64InputCommand
        LDA     #FN_BASE64_CMD_DECODE_COMPUTE
        STA     FN_Base64ComputeCommand
        LDA     #FN_BASE64_CMD_DECODE_LENGTH
        STA     FN_Base64LengthCommand
        LDA     #FN_BASE64_CMD_DECODE_OUTPUT
        STA     FN_Base64OutputCommand

FN_Base64Transform:
        LDA     _StrVar_PF00
        LBEQ    FN_Base64EmptyString
        STA     FN_Base64InputLength
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_Base64StringError
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     FN_Base64InputCommand
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA           ; input length, big endian
        LDA     FN_Base64InputLength
        STA     >FN_BECKER_DATA
        LDX     #_StrVar_PF00+1
        LDB     FN_Base64InputLength
FN_Base64InputLoop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_Base64InputLoop
        JSR     FN_FujiGetError
        LBCS    FN_Base64StringError

        LDA     FN_Base64ComputeCommand
        JSR     FN_FujiSimpleCommand
        LBCS    FN_Base64StringError
        LDA     FN_Base64LengthCommand
        JSR     FN_FujiSimpleCommand
        LBCS    FN_Base64StringError

        ; u32ne_t is big endian for BUILD_COCO, hence [00 00 00 length].
        LDX     #_StrVar_IFRight
        LDD     #4
        JSR     FN_FujiGetResponse
        LBCS    FN_Base64StringError
        LDA     _StrVar_IFRight
        ORA     _StrVar_IFRight+1
        ORA     _StrVar_IFRight+2
        LBNE    FN_Base64StringBadArgument
        LDB     _StrVar_IFRight+3
        CMPB    #255
        LBEQ    FN_Base64StringBadArgument
        STB     FN_Base64OutputLength
        BEQ     FN_Base64EmptyString

        JSR     FN_DrainInput
        LBCS    FN_Base64StringError
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     FN_Base64OutputCommand
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA           ; requested output count, big endian
        LDA     FN_Base64OutputLength
        STA     >FN_BECKER_DATA
        JSR     FN_FujiGetError
        BCS     FN_Base64StringError
        LDB     FN_Base64OutputLength
        STB     _StrVar_PF00
        CLRA
        LDX     #_StrVar_PF00+1
        JSR     FN_FujiGetResponse
        BCS     FN_Base64StringError
        JMP     FN_ReturnScratchString

FN_Base64EmptyString:
        CLR     FN_LastError
        CLR     _StrVar_PF00
        JMP     FN_ReturnScratchString

FN_Base64StringBadArgument:
        JSR     FN_FujiBadArgument
FN_Base64StringError:
        CLR     _StrVar_PF00
        JMP     FN_ReturnScratchString
