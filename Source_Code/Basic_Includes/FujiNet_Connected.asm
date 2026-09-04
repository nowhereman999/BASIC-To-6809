; Optional FNCONNECTED() support.
;
; Input:  B = network channel (0-7)
; Output: A = channel connected flag (0 or 1).  A is zero on an argument or
;         Becker transport failure; FNERROR() then supplies the reason.

FN_Connected:
        JSR     FN_ChannelStatus
        BCS     FN_ConnectedFailed
        LDA     FN_ChannelStatusConnected
        ANDCC   #$FE
        RTS

FN_ConnectedFailed:
        CLRA
        ORCC    #$01
        RTS
