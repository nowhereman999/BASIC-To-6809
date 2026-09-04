; Shared Fuji-device helpers for optional high-level FujiNet services.
;
; The CoCo DriveWire/Becker Fuji device uses opcode $E2.  A command is sent,
; command $02 retrieves its one-byte result ($01 means success), and command
; $01 retrieves any response body.  These helpers normalize successful calls
; to BASIC's zero-is-success convention and update FN_LastError on failure.

FN_FUJI_OPCODE             EQU     $E2
FN_FUJI_GET_RESPONSE       EQU     $01
FN_FUJI_GET_ERROR          EQU     $02
FN_FUJI_REPLY_SUCCESS      EQU     $01
FN_FUJI_TIMEOUT_PASSES     EQU     12

FN_FujiSavedCommand        FCB     0
FN_FujiResponseAddress     FDB     0
FN_FujiResponseLength      FDB     0

; Input: A = Fuji command byte.  Output: A=0 on success, error otherwise.
FN_FujiSimpleCommand:
        STA     FN_FujiSavedCommand
        CLR     FN_LastError
        JSR     FN_DrainInput
        BCS     FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     FN_FujiSavedCommand
        STA     >FN_BECKER_DATA
        BRA     FN_FujiGetError

; Retrieve and normalize the result of the command most recently sent.
FN_FujiGetError:
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_FUJI_GET_ERROR
        STA     >FN_BECKER_DATA
        LDB     #FN_FUJI_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_FujiFail
        CMPA    #FN_FUJI_REPLY_SUCCESS
        BNE     FN_FujiFail
FN_FujiSuccess:
        CLR     FN_LastError
        CLRA
        ANDCC   #$FE
        RTS

; Input: X = destination address, D = response byte count.
; The caller must first send its Fuji command and call FN_FujiGetError.
FN_FujiGetResponse:
        STX     FN_FujiResponseAddress
        STD     FN_FujiResponseLength
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_FUJI_GET_RESPONSE
        STA     >FN_BECKER_DATA

        LDD     FN_FujiResponseLength
        BEQ     FN_FujiSuccess
FN_FujiResponseLoop:
        LDB     #FN_FUJI_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        BCS     FN_FujiFail
        LDX     FN_FujiResponseAddress
        STA     ,X+
        STX     FN_FujiResponseAddress
        LDD     FN_FujiResponseLength
        SUBD    #1
        STD     FN_FujiResponseLength
        BNE     FN_FujiResponseLoop
        BRA     FN_FujiSuccess

FN_FujiBadArgument:
        LDA     #4
FN_FujiFail:
        STA     FN_LastError
        ORCC    #$01
        RTS
