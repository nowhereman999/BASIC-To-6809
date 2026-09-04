; Optional FujiNet network-close support. Included only when FNCLOSE() is used.
;
; Input:  B = network channel (0-7)
; Output: A = 0/carry clear on success, or A = error/carry set on failure.
;         Failures are also recorded for FNERROR().
; RAM:    one byte of temporary 6809 stack space while sending the request;
;         no permanent data buffer.

FN_CLOSE_DW_OPCODE_NET       EQU     $E3
FN_CLOSE_NET_CMD_SEND_ERROR  EQU     $02
FN_CLOSE_NET_CMD_CLOSE       EQU     $43     ; ASCII 'C'
FN_CLOSE_NET_REPLY_SUCCESS   EQU     $01
FN_CLOSE_TIMEOUT_PASSES      EQU     12
FN_CLOSE_ERROR_BAD_ARGUMENT  EQU     4

FN_Close:
        CLR     FN_LastError
        CMPB    #8
        BHS     FN_CloseBadArgument

        PSHS    B                       ; Preserve channel; FN_DrainInput uses B
        JSR     FN_DrainInput
        BCS     FN_CloseDrainFailed

        ; E3, unit, 'C', 0, 0.
        LDA     #FN_CLOSE_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     ,S
        STA     >FN_BECKER_DATA
        LDA     #FN_CLOSE_NET_CMD_CLOSE
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        ; Query the close operation's result: E3, unit, SEND_ERROR, 0, 0.
        LDA     #FN_CLOSE_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     ,S
        STA     >FN_BECKER_DATA
        LDA     #FN_CLOSE_NET_CMD_SEND_ERROR
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        LEAS    1,S                     ; Discard saved channel

        LDB     #FN_CLOSE_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_CloseFailed
        CMPA    #FN_CLOSE_NET_REPLY_SUCCESS
        BNE     FN_CloseFailed

        CLRA                            ; BASIC convention: zero means success
        ANDCC   #$FE
        RTS

FN_CloseDrainFailed:
        LEAS    1,S                     ; Discard saved channel, preserve A error
        BRA     FN_CloseFailed

FN_CloseBadArgument:
        LDA     #FN_CLOSE_ERROR_BAD_ARGUMENT

FN_CloseFailed:
        STA     FN_LastError
        ORCC    #$01
        RTS
