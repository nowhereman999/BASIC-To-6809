; Optional FNBYTESWAITING() support.  The shared four-byte transaction is in
; FujiNet_ChannelStatus.asm so other status functions do not duplicate it.
;
; Input:  B = network channel (0-7)
; Output: D = available byte count (0-65535). FN_LastError is zero on
;         success, or contains the transport/FujiNet status error.

FN_BW_REPLY_SUCCESS       EQU     $01
FN_BW_STATUS_END_OF_FILE  EQU     136

FN_BytesWaiting:
        JSR     FN_ChannelStatus
        BCS     FN_BytesWaitingFailed
        LDA     FN_ChannelStatusError
        CMPA    #FN_BW_REPLY_SUCCESS
        BEQ     FN_BytesWaitingSuccess

        ; TCP can report EOF immediately after its peer closes even though
        ; received bytes remain buffered. Let BASIC consume those bytes first.
        CMPA    #FN_BW_STATUS_END_OF_FILE
        BNE     FN_BytesWaitingNetworkError
        LDD     FN_ChannelStatusBytes
        BEQ     FN_BytesWaitingEndOfFile
        CLR     FN_LastError
        ANDCC   #$FE
        RTS

FN_BytesWaitingSuccess:
        LDD     FN_ChannelStatusBytes
        ANDCC   #$FE
        RTS

FN_BytesWaitingEndOfFile:
        LDA     #FN_BW_STATUS_END_OF_FILE
        BRA     FN_BytesWaitingNetworkError

FN_BytesWaitingNetworkError:
        ; A contains the channel status error.
        STA     FN_LastError
FN_BytesWaitingFailed:
        CLRA
        CLRB
        ORCC    #$01
        RTS
