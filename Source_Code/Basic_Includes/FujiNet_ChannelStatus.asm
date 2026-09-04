; Shared FujiNet network-channel status transaction.
;
; Included only by functions that inspect a channel's status.  Keeping the
; DriveWire transaction here lets FNBYTESWAITING(), FNCONNECTED(),
; FNCHANNELERROR(), and FNJSONPARSE() share one implementation without each
; carrying another four-byte status reader.
;
; Input:  B = network channel (0-7)
; Output: carry clear when all four status bytes were received:
;           FN_ChannelStatusBytes     = available byte count (big endian)
;           FN_ChannelStatusConnected = connected flag (0 or 1)
;           FN_ChannelStatusError     = raw FujiNet status (1=OK, 136=EOF)
;         carry set on argument/Becker transport failure, with A and
;         FN_LastError containing the library error.

FN_CHANNEL_STATUS_DW_OPCODE_NET       EQU     $E3
FN_CHANNEL_STATUS_CMD_RESPONSE        EQU     $01
FN_CHANNEL_STATUS_CMD_STATUS          EQU     $53     ; ASCII 'S'
FN_CHANNEL_STATUS_TIMEOUT_PASSES      EQU     12
FN_CHANNEL_STATUS_ERROR_BAD_ARGUMENT  EQU     4

FN_ChannelStatusBytes                 RMB     2
FN_ChannelStatusConnected             FCB     0
FN_ChannelStatusError                 FCB     0
FN_ChannelStatusChannel               FCB     0

FN_ChannelStatus:
        CLR     FN_LastError
        CLR     FN_ChannelStatusBytes
        CLR     FN_ChannelStatusBytes+1
        CLR     FN_ChannelStatusConnected
        CLR     FN_ChannelStatusError
        CMPB    #8
        BHS     FN_ChannelStatusBadArgument
        STB     FN_ChannelStatusChannel

        JSR     FN_DrainInput
        BCS     FN_ChannelStatusFailed

        ; Ask for channel status: E3, unit, 'S', 0, 0.
        LDA     #FN_CHANNEL_STATUS_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_ChannelStatusChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_CHANNEL_STATUS_CMD_STATUS
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA

        ; Retrieve NDeviceStatus: available-hi, available-lo, connected, error.
        LDA     #FN_CHANNEL_STATUS_DW_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_ChannelStatusChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_CHANNEL_STATUS_CMD_RESPONSE
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        LDA     #4
        STA     >FN_BECKER_DATA

        LDB     #FN_CHANNEL_STATUS_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_ChannelStatusFailed
        STA     FN_ChannelStatusBytes

        LDB     #FN_CHANNEL_STATUS_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_ChannelStatusFailed
        STA     FN_ChannelStatusBytes+1

        LDB     #FN_CHANNEL_STATUS_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_ChannelStatusFailed
        STA     FN_ChannelStatusConnected

        LDB     #FN_CHANNEL_STATUS_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_ChannelStatusFailed
        STA     FN_ChannelStatusError

        ANDCC   #$FE
        RTS

FN_ChannelStatusBadArgument:
        LDA     #FN_CHANNEL_STATUS_ERROR_BAD_ARGUMENT

FN_ChannelStatusFailed:
        STA     FN_LastError
        ORCC    #$01
        RTS
