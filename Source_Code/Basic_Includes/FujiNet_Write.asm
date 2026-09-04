; Optional FNWRITE() support. The outgoing string is held in the compiler's
; existing _StrVar_PF00 scratch string; no channel-specific buffer is added.
;
; Input: B = channel (0-7), _StrVar_PF00 = [length][characters]
; Output: A = 0/carry clear on success, or error/carry set on failure.

FN_WRITE_DW_OPCODE_NET       EQU     $E3
FN_WRITE_NET_CMD_SEND_ERROR  EQU     $02
FN_WRITE_NET_CMD_WRITE       EQU     $57     ; ASCII 'W'
FN_WRITE_REPLY_SUCCESS       EQU     $01
FN_WRITE_TIMEOUT_PASSES      EQU     12
FN_WRITE_ERROR_BAD_ARGUMENT  EQU     4

FN_WriteChannel              FCB     0

FN_Write:
        CLR     FN_LastError
        CMPB    #8
        BHS     FN_WriteBadArgument
        STB     FN_WriteChannel
        TST     _StrVar_PF00
        BEQ     FN_WriteSuccess          ; Empty write is a successful no-op

        JSR     FN_DrainInput
        BCS     FN_WriteFailed

        ; E3, unit, 'W', length-hi, length-lo, followed by string bytes.
        LDA     #FN_WRITE_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_WriteChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_WRITE_NET_CMD_WRITE
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        LDA     _StrVar_PF00
        STA     >FN_BECKER_DATA

        LDX     #_StrVar_PF00+1
        LDB     _StrVar_PF00
FN_WriteSendLoop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_WriteSendLoop

        ; Query the write result.
        LDA     #FN_WRITE_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_WriteChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_WRITE_NET_CMD_SEND_ERROR
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        LDB     #FN_WRITE_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_WriteFailed
        CMPA    #FN_WRITE_REPLY_SUCCESS
        BNE     FN_WriteNetworkError

FN_WriteSuccess:
        CLRA
        ANDCC   #$FE
        RTS

FN_WriteBadArgument:
        LDA     #FN_WRITE_ERROR_BAD_ARGUMENT
        BRA     FN_WriteFailed

FN_WriteNetworkError:
        ; A contains the FujiNet network error.
FN_WriteFailed:
        STA     FN_LastError
        ORCC    #$01
        RTS
