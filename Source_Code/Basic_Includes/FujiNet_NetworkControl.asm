; Shared control operations for FujiNet network channels ($E3).
;
; Public entry points:
;   FN_SetChannelMode  A=mode (0-4), B=channel
;   FN_NetworkIOCtl    uses FN_IO* variables and PF00 devicespec
; All routines return A=0 on success or an error code and update FN_LastError.

FN_NC_OPCODE_NET          EQU     $E3
FN_NC_CMD_GET_ERROR       EQU     $02
FN_NC_CMD_RENAME          EQU     $20
FN_NC_CMD_DELETE          EQU     $21
FN_NC_CMD_LOCK            EQU     $23
FN_NC_CMD_UNLOCK          EQU     $24
FN_NC_CMD_MKDIR           EQU     $2A
FN_NC_CMD_RMDIR           EQU     $2B
FN_NC_CMD_CHDIR           EQU     $2C
FN_NC_CMD_CHANNEL_MODE    EQU     $4D     ; ASCII 'M'
FN_NC_CMD_USERNAME        EQU     $FD
FN_NC_CMD_PASSWORD        EQU     $FE
FN_NC_REPLY_SUCCESS       EQU     $01
FN_NC_TIMEOUT_PASSES      EQU     12

FN_IOChannel              FCB     0
FN_IOCommand              FCB     0
FN_IOAux1                 FCB     0
FN_IOAux2                 FCB     0
FN_ChannelModeValue       FCB     0

FN_SetChannelMode:
        CLR     FN_LastError
        CMPB    #8
        LBHS    FN_NCBadArgument
        CMPA    #5
        LBHS    FN_NCBadArgument
        STB     FN_IOChannel
        STA     FN_ChannelModeValue
        JSR     FN_DrainInput
        LBCS    FN_NCFail

        LDA     #FN_NC_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_IOChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_NC_CMD_CHANNEL_MODE
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA          ; aux1 unused
        LDA     FN_ChannelModeValue
        STA     >FN_BECKER_DATA          ; aux2 selects mode
        BRA     FN_NetworkGetError

FN_NetworkIOCtl:
        CLR     FN_LastError
        LDB     FN_IOChannel
        CMPB    #8
        BHS     FN_NCBadArgument
        JSR     FN_DrainInput
        BCS     FN_NCFail

        LDA     #FN_NC_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_IOChannel
        STA     >FN_BECKER_DATA
        LDA     FN_IOCommand
        STA     >FN_BECKER_DATA
        LDA     FN_IOAux1
        STA     >FN_BECKER_DATA
        LDA     FN_IOAux2
        STA     >FN_BECKER_DATA

        ; Every network ioctl carries a fixed 256-byte devicespec field.
        LDX     #_StrVar_PF00+1
        LDB     _StrVar_PF00
        BEQ     FN_NCIOPad
FN_NCIOSend:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_NCIOSend
FN_NCIOPad:
        LDB     _StrVar_PF00
        NEGB                            ; zero means all 256 bytes are padding
FN_NCIOPadLoop:
        CLR     >FN_BECKER_DATA
        DECB
        BNE     FN_NCIOPadLoop
        BRA     FN_NetworkGetError

; Retrieve the result of the most recent network-channel operation.
FN_NetworkGetError:
        LDA     #FN_NC_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_IOChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_NC_CMD_GET_ERROR
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA
        LDB     #FN_NC_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_NCFail
        CMPA    #FN_NC_REPLY_SUCCESS
        BNE     FN_NCFail
FN_NCSuccess:
        CLR     FN_LastError
        CLRA
        ANDCC   #$FE
        RTS

FN_NCBadArgument:
        LDA     #4
FN_NCFail:
        STA     FN_LastError
        ORCC    #$01
        RTS
