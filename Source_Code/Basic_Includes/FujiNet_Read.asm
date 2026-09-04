; Optional FNREAD$() support. Incoming bytes use the compiler's existing
; _StrVar_PF00 scratch string and are then returned on the expression stack.
;
; Input: A = channel (0-7), B = byte count (0-255)
; Output: [length][characters] BASIC string on S; FN_LastError reports errors.

FN_READ_DW_OPCODE_NET       EQU     $E3
FN_READ_NET_CMD_RESPONSE    EQU     $01
FN_READ_NET_CMD_SEND_ERROR  EQU     $02
FN_READ_NET_CMD_READ        EQU     $52     ; ASCII 'R'
FN_READ_REPLY_SUCCESS       EQU     $01
FN_READ_TIMEOUT_PASSES      EQU     12
FN_READ_ERROR_BAD_ARGUMENT  EQU     4

FN_ReadChannel              FCB     0
FN_ReadCount                FCB     0
FN_ReadRemaining            FCB     0

FN_ReadString:
        PULS    Y                       ; Preserve return while result is pushed
        CLR     FN_LastError
        STA     FN_ReadChannel
        STB     FN_ReadCount
        STB     FN_ReadRemaining
        CLR     _StrVar_PF00

        CMPA    #8
        LBHS    FN_ReadBadArgument
        TSTB
        LBEQ    FN_ReadReturnString     ; Empty read is a successful no-op

        JSR     FN_DrainInput
        LBCS    FN_ReadFailed

        ; Request count bytes: E3, unit, 'R', count-hi, count-lo.
        LDA     #FN_READ_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_ReadChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_READ_NET_CMD_READ
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        LDA     FN_ReadCount
        STA     >FN_BECKER_DATA

        ; Ask FujiNet to return exactly count response bytes.
        LDA     #FN_READ_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_ReadChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_READ_NET_CMD_RESPONSE
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        LDA     FN_ReadCount
        STA     >FN_BECKER_DATA

        LDU     #_StrVar_PF00+1
FN_ReadReceiveLoop:
        LDB     #FN_READ_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_ReadFailed
        STA     ,U+
        DEC     FN_ReadRemaining
        BNE     FN_ReadReceiveLoop

        ; Query whether FujiNet supplied the complete requested read.
        LDA     #FN_READ_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_ReadChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_READ_NET_CMD_SEND_ERROR
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        LDB     #FN_READ_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_ReadFailed
        CMPA    #FN_READ_REPLY_SUCCESS
        BNE     FN_ReadNetworkError

        LDA     FN_ReadCount
        STA     _StrVar_PF00
        BRA     FN_ReadReturnString

FN_ReadBadArgument:
        LDA     #FN_READ_ERROR_BAD_ARGUMENT
        BRA     FN_ReadFailed

FN_ReadNetworkError:
        ; A contains the FujiNet network error.
FN_ReadFailed:
        STA     FN_LastError
        CLR     _StrVar_PF00             ; Never return padded/partial data

FN_ReadReturnString:
        LDB     _StrVar_PF00
        BEQ     FN_ReadPushLength
        LDX     #_StrVar_PF00+1
        ABX
FN_ReadPushLoop:
        LDA     ,-X
        PSHS    A
        DECB
        BNE     FN_ReadPushLoop
FN_ReadPushLength:
        LDB     _StrVar_PF00
        PSHS    B
        JMP     ,Y
