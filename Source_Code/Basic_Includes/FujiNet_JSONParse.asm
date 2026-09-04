; Optional FNJSONPARSE() support.
;
; Input:  B = open network channel (0-7)
; Output: A = 0/carry clear on success, or error/carry set on failure.
;         Failures are also recorded for FNERROR().
;
; FujiNet's JSON service first requires channel mode 1 ($FC), then command
; 'P' parses the body already fetched by FNOPEN().  The parsed document stays
; inside FujiNet, avoiding a large JSON buffer in CoCo RAM.
;
; HTTP GET is lazy in FujiNet: FNOPEN() creates the protocol object, while the
; first protocol-mode status request actually performs the transaction.  Do
; that status request before changing to JSON mode so connection/HTTP failures
; (for example error 200, NOT CONNECTED) are not hidden by the firmware's JSON
; parse command, whose immediate command result is success for compatibility.

FN_JSON_PARSE_DW_OPCODE_NET       EQU     $E3
FN_JSON_PARSE_CMD_SEND_ERROR      EQU     $02
FN_JSON_PARSE_CMD_SET_MODE        EQU     $FC
FN_JSON_PARSE_CMD_PARSE           EQU     $50     ; ASCII 'P'
FN_JSON_PARSE_MODE_JSON           EQU     1
FN_JSON_PARSE_MODE_PROTOCOL       EQU     0
FN_JSON_PARSE_REPLY_SUCCESS       EQU     $01
FN_JSON_PARSE_STATUS_EOF          EQU     136
FN_JSON_PARSE_TIMEOUT_PASSES      EQU     12
FN_JSON_PARSE_ERROR_BAD_ARGUMENT  EQU     4

FN_JSONParseChannel               FCB     0

FN_JSONParse:
        CLR     FN_LastError
        CMPB    #8
        LBHS    FN_JSONParseBadArgument
        STB     FN_JSONParseChannel

        JSR     FN_DrainInput
        LBCS    FN_JSONParseFailed

        ; Force protocol mode, then fetch full status.  For HTTP this starts
        ; the pending request and preserves its real channel error byte.
        LDA     #FN_JSON_PARSE_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_JSONParseChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_PARSE_CMD_SET_MODE
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_PARSE_MODE_PROTOCOL
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        LDB     FN_JSONParseChannel
        JSR     FN_ChannelStatus
        BCS     FN_JSONParseFailed
        LDA     FN_ChannelStatusError
        CMPA    #FN_JSON_PARSE_REPLY_SUCCESS
        BEQ     FN_JSONParseResponseReady

        ; EOF is normal only if a response body is still available to parse.
        ; A zero-length completed response cannot contain a JSON document.
        CMPA    #FN_JSON_PARSE_STATUS_EOF
        BNE     FN_JSONParseNetworkError
        LDD     FN_ChannelStatusBytes
        BNE     FN_JSONParseResponseReady
        LDA     #FN_JSON_PARSE_STATUS_EOF
        BRA     FN_JSONParseNetworkError

FN_JSONParseResponseReady:
        JSR     FN_DrainInput
        BCS     FN_JSONParseFailed

        ; E3, unit, SET_CHANNEL_MODE, JSON, 0.
        LDA     #FN_JSON_PARSE_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_JSONParseChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_PARSE_CMD_SET_MODE
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_PARSE_MODE_JSON
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        ; E3, unit, 'P', 0, 0 parses the current response body.
        LDA     #FN_JSON_PARSE_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_JSONParseChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_PARSE_CMD_PARSE
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        ; Retrieve the parse operation's network error byte.
        LDA     #FN_JSON_PARSE_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_JSONParseChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_JSON_PARSE_CMD_SEND_ERROR
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        LDB     #FN_JSON_PARSE_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_JSONParseFailed
        CMPA    #FN_JSON_PARSE_REPLY_SUCCESS
        BNE     FN_JSONParseNetworkError

        CLRA
        ANDCC   #$FE
        RTS

FN_JSONParseBadArgument:
        LDA     #FN_JSON_PARSE_ERROR_BAD_ARGUMENT
        BRA     FN_JSONParseFailed

FN_JSONParseNetworkError:
        ; A contains FujiNet's network error code.
FN_JSONParseFailed:
        STA     FN_LastError
        ORCC    #$01
        RTS
