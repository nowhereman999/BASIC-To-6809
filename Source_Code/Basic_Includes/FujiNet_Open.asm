; Optional FujiNet network-open support. Included only when FNOPEN() is used.
;
; FN_Open consumes the settings below and the length-prefixed device
; specification in _StrVar_PF00. It returns A=0/carry clear on success, or
; A=error/carry set on failure and also records the error for FNERROR().

FN_DW_OPCODE_NET       EQU     $E3
FN_NET_CMD_SEND_ERROR  EQU     $02
FN_NET_CMD_OPEN        EQU     $4F
FN_NET_REPLY_SUCCESS   EQU     $01
FN_OPEN_TIMEOUT_PASSES EQU     12
FN_ERROR_BAD_ARGUMENT  EQU     4

FN_OpenChannel         FCB     0
FN_OpenAccess          FCB     0
FN_OpenTranslation     FCB     0

FN_Open:
        CLR     FN_LastError

        LDB     FN_OpenChannel
        CMPB    #8
        LBHS    FN_OpenBadArgument

        LDA     FN_OpenAccess
        CMPA    #4
        BEQ     FN_OpenCheckTranslation
        CMPA    #5
        BEQ     FN_OpenCheckTranslation
        CMPA    #6
        BEQ     FN_OpenCheckTranslation
        CMPA    #7
        BEQ     FN_OpenCheckTranslation
        CMPA    #8
        BEQ     FN_OpenCheckTranslation
        CMPA    #9
        BEQ     FN_OpenCheckTranslation
        CMPA    #12
        BEQ     FN_OpenCheckTranslation
        CMPA    #13
        BEQ     FN_OpenCheckTranslation
        CMPA    #14
        LBNE    FN_OpenBadArgument

FN_OpenCheckTranslation:
        ; Regular network opens accept translation modes 0-4. Directory
        ; opens (access 6/7) additionally accept FujiNet's binary directory
        ; formats $80-$85.
        LDA     FN_OpenTranslation
        CMPA    #5
        BLO     FN_OpenArgumentsOK
        LDB     FN_OpenAccess
        CMPB    #6
        BEQ     FN_OpenCheckDirectoryFormat
        CMPB    #7
        LBNE    FN_OpenBadArgument
FN_OpenCheckDirectoryFormat:
        CMPA    #$80
        LBLO    FN_OpenBadArgument
        CMPA    #$86
        LBHS    FN_OpenBadArgument

FN_OpenArgumentsOK:
        JSR     FN_DrainInput
        LBCS    FN_OpenFailed

        ; E3, unit, 'O', access, translation, followed by exactly 256 bytes.
        LDA     #FN_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_OpenChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_NET_CMD_OPEN
        STA     >FN_BECKER_DATA
        LDA     FN_OpenAccess
        STA     >FN_BECKER_DATA
        LDA     FN_OpenTranslation
        STA     >FN_BECKER_DATA

        LDX     #_StrVar_PF00+1
        LDB     _StrVar_PF00
        BEQ     FN_OpenPadDeviceSpec
FN_OpenSendDeviceSpec:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_OpenSendDeviceSpec

FN_OpenPadDeviceSpec:
        LDB     _StrVar_PF00
        NEGB                            ; 0 represents 256 padding bytes
FN_OpenPadLoop:
        CLR     >FN_BECKER_DATA
        DECB
        BNE     FN_OpenPadLoop

        ; Query the network operation's result: E3, unit, SEND_ERROR, 0, 0.
        LDA     #FN_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_OpenChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_NET_CMD_SEND_ERROR
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        LDB     #FN_OPEN_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_OpenFailed
        CMPA    #FN_NET_REPLY_SUCCESS
        BNE     FN_OpenNetworkError

        CLRA                            ; BASIC convention: zero means success
        ANDCC   #$FE
        RTS

FN_OpenBadArgument:
        LDA     #FN_ERROR_BAD_ARGUMENT
        BRA     FN_OpenFailed

FN_OpenNetworkError:
        ; A already contains FujiNet's network error code.
FN_OpenFailed:
        STA     FN_LastError
        ORCC    #$01
        RTS
