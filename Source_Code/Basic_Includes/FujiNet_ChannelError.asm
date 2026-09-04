; Optional FNCHANNELERROR() support.
;
; Input:  B = network channel (0-7)
; Output: A = 0 for FujiNet's normal status byte ($01), otherwise the raw
;         channel error (for example 136=EOF or 200=not connected).  Becker
;         transport/argument failures are returned as their library error.

FN_CHANNEL_ERROR_REPLY_SUCCESS  EQU     $01

FN_ChannelError:
        JSR     FN_ChannelStatus
        BCS     FN_ChannelErrorReturn

        LDA     FN_ChannelStatusError
        CMPA    #FN_CHANNEL_ERROR_REPLY_SUCCESS
        BNE     FN_ChannelErrorRecord
        CLRA                            ; BASIC convention: zero means success

FN_ChannelErrorRecord:
        STA     FN_LastError
        ANDCC   #$FE

FN_ChannelErrorReturn:
        RTS
