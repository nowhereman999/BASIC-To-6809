; Optional FNJSONQUERY$() support.
;
; Input:  B = parsed JSON network channel (0-7)
;         _StrVar_PF00 = [length][FujiNet JSON path]
; Output: [length][characters] BASIC string on S.
;         FN_LastError is zero on success or contains the failure code.
;
; Command 'Q' selects one scalar from the document parsed by FNJSONPARSE().
; FujiNet reports the scalar length through channel status; the existing
; FN_ReadString routine then returns it without allocating another RAM buffer.

FN_JSON_QUERY_DW_OPCODE_NET       EQU     $E3
FN_JSON_QUERY_CMD_RESPONSE        EQU     $01
FN_JSON_QUERY_CMD_SEND_ERROR      EQU     $02
FN_JSON_QUERY_CMD_QUERY           EQU     $51     ; ASCII 'Q'
FN_JSON_QUERY_CMD_READ            EQU     $52     ; ASCII 'R'
FN_JSON_QUERY_REPLY_SUCCESS       EQU     $01
FN_JSON_QUERY_TIMEOUT_PASSES      EQU     12
FN_JSON_QUERY_ERROR_BAD_ARGUMENT  EQU     4
FN_JSON_QUERY_ERROR_TOO_LONG      EQU     4       ; Exceeds BASIC's result buffer

FN_JSONQueryChannel               FCB     0
FN_JSONQueryCount                 FCB     0
FN_JSONQueryRemaining             FCB     0

FN_JSONQueryString:
        CLR     FN_LastError
        CMPB    #8
        LBHS    FN_JSONQueryBadArgument
        STB     FN_JSONQueryChannel

        JSR     FN_DrainInput
        LBCS    FN_JSONQueryTransportFailed

        ; E3, unit, 'Q', 0, 0, followed by exactly 256 path bytes.
        LDA     #FN_JSON_QUERY_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_JSONQueryChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_QUERY_CMD_QUERY
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        LDX     #_StrVar_PF00+1
        LDB     _StrVar_PF00
        BEQ     FN_JSONQueryPadPath
FN_JSONQuerySendPath:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_JSONQuerySendPath

FN_JSONQueryPadPath:
        LDB     _StrVar_PF00
        NEGB                            ; Zero means 256 padding bytes
FN_JSONQueryPadLoop:
        CLR     >FN_BECKER_DATA
        DECB
        BNE     FN_JSONQueryPadLoop

        ; Query status supplies the selected scalar's two-byte length.
        LDB     FN_JSONQueryChannel
        JSR     FN_BytesWaiting
        LBCS    FN_JSONQueryReturnEmpty
        TSTA                            ; BASIC result buffer holds <=254 bytes
        LBNE    FN_JSONQueryTooLong
        CMPB    #255
        LBEQ    FN_JSONQueryTooLong
        TSTB
        LBEQ    FN_JSONQueryReturnEmpty

        STB     FN_JSONQueryCount
        STB     FN_JSONQueryRemaining
        CLR     _StrVar_PF00

        JSR     FN_DrainInput
        LBCS    FN_JSONQueryTransportFailed

        ; Read the complete scalar selected by Q.
        LDA     #FN_JSON_QUERY_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_JSONQueryChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_QUERY_CMD_READ
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        LDA     FN_JSONQueryCount
        STA     >FN_BECKER_DATA

        LDA     #FN_JSON_QUERY_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_JSONQueryChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_QUERY_CMD_RESPONSE
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        LDA     FN_JSONQueryCount
        STA     >FN_BECKER_DATA

        LDU     #_StrVar_PF00+1
FN_JSONQueryReceiveLoop:
        LDB     #FN_JSON_QUERY_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        LBCS    FN_JSONQueryTransportFailed
        STA     ,U+
        DEC     FN_JSONQueryRemaining
        BNE     FN_JSONQueryReceiveLoop

        ; Confirm that FujiNet supplied the complete query result.
        LDA     #FN_JSON_QUERY_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_JSONQueryChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_QUERY_CMD_SEND_ERROR
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        LDB     #FN_JSON_QUERY_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_JSONQueryTransportFailed
        CMPA    #FN_JSON_QUERY_REPLY_SUCCESS
        BNE     FN_JSONQueryNetworkError

        ; FujiNet JSON scalars may end in the platform line terminator. Match
        ; fujinet-lib by removing one Atari EOL, LF, or CR before returning.
        LDB     FN_JSONQueryCount
        LDX     #_StrVar_PF00
        ABX
        LDA     ,X
        CMPA    #$9B
        BEQ     FN_JSONQueryTrimEOL
        CMPA    #$0A
        BEQ     FN_JSONQueryTrimEOL
        CMPA    #$0D
        BNE     FN_JSONQueryStoreLength
FN_JSONQueryTrimEOL:
        DECB
FN_JSONQueryStoreLength:
        STB     _StrVar_PF00
        BRA     FN_JSONQueryReturnScratch

FN_JSONQueryBadArgument:
        LDA     #FN_JSON_QUERY_ERROR_BAD_ARGUMENT
        BRA     FN_JSONQuerySetError

FN_JSONQueryTooLong:
        LDA     #FN_JSON_QUERY_ERROR_TOO_LONG
        BRA     FN_JSONQuerySetError

FN_JSONQueryTransportFailed:
        ; A contains the Becker transport error.
FN_JSONQuerySetError:
        STA     FN_LastError
        ORCC    #$01

FN_JSONQueryReturnEmpty:
        CLR     _StrVar_PF00

FN_JSONQueryReturnScratch:
        PULS    Y                       ; Preserve return while result is pushed
        LDB     _StrVar_PF00
        BEQ     FN_JSONQueryPushLength
        LDX     #_StrVar_PF00+1
        ABX
FN_JSONQueryPushLoop:
        LDA     ,-X
        PSHS    A
        DECB
        BNE     FN_JSONQueryPushLoop
FN_JSONQueryPushLength:
        LDB     _StrVar_PF00
        PSHS    B
        JMP     ,Y

FN_JSONQueryNetworkError:
        ; A contains FujiNet's network error code.
        BRA     FN_JSONQuerySetError
