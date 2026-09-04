; Convenience helpers for FujiNet HTTP request modes.
;
; FN_HTTPHeader: channel in B, header string in PF00. Temporarily enters mode
; 3, writes "Header-Name: value", and restores body mode 0.
; FN_HTTPPost/FN_HTTPPut: channel in B, request data in PF00. Temporarily
; enter mode 4, write the data, and restore body mode 0. The HTTP method is
; selected by the channel's FNOPEN access mode (13 POST, 8 PUT).
; FN_HTTPDelete: FN_HTTPDeleteChannel/FN_HTTPDeleteTranslation and URL in
; PF00. Opens with access mode 5, then performs status once to execute it.
;
; All routines return A=0 on success or an error code and update FN_LastError.

FN_HTTPChannel             FCB     0
FN_HTTPFirstError          FCB     0
FN_HTTPDeleteChannel       FCB     0
FN_HTTPDeleteTranslation   FCB     0

FN_HTTPHeader:
        LDA     #3
        BRA     FN_HTTPModeWrite

FN_HTTPPost:
FN_HTTPPut:
        LDA     #4

FN_HTTPModeWrite:
        STB     FN_HTTPChannel
        CLR     FN_HTTPFirstError
        JSR     FN_SetChannelMode
        BCS     FN_HTTPReturn

        LDB     FN_HTTPChannel
        JSR     FN_Write
        STA     FN_HTTPFirstError

        ; Always restore ordinary body mode, even when the payload write
        ; reports an error. Preserve the first failure for the BASIC caller.
        CLRA
        LDB     FN_HTTPChannel
        JSR     FN_SetChannelMode
        LDB     FN_HTTPFirstError
        BEQ     FN_HTTPReturn
        TFR     B,A
        STA     FN_LastError
        ORCC    #$01
FN_HTTPReturn:
        RTS

FN_HTTPDelete:
        LDA     FN_HTTPDeleteChannel
        STA     FN_OpenChannel
        LDA     #5
        STA     FN_OpenAccess
        LDA     FN_HTTPDeleteTranslation
        STA     FN_OpenTranslation
        JSR     FN_Open
        BCS     FN_HTTPReturn

        ; DELETE has no write body. A status request is required to make the
        ; firmware execute the HTTP transaction rather than merely queue it.
        LDB     FN_HTTPDeleteChannel
        JSR     FN_ChannelStatus
        BCS     FN_HTTPReturn
        LDA     FN_ChannelStatusError
        CMPA    #1
        BEQ     FN_HTTPDeleteSuccess
        CMPA    #136                    ; bodyless successful DELETE ends EOF
        BEQ     FN_HTTPDeleteSuccess
        STA     FN_LastError
        ORCC    #$01
        RTS

FN_HTTPDeleteSuccess:
        CLR     FN_LastError
        CLRA
        ANDCC   #$FE
        RTS
