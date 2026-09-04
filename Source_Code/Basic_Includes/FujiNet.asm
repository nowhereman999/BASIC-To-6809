; FujiNet Becker-port byte transport for the CoCo.
;
; MAME's Becker interface exposes two memory-mapped registers:
;   $FF41 read       status; bit 1 set when a received byte is available
;   $FF42 read/write receive/send one byte
;
; Public entry points:
;   FN_Init          Probe the FujiNet DriveWire device through Becker.
;                    A=0/carry clear when ready; A=error/carry set otherwise.
;   FN_Error         Return the most recent FujiNet library error in A.
;   FN_WifiStatus    Return FujiNet's Wi-Fi status byte in A.
;                    Current values: 3=connected, 6=disconnected.
;                    On transport failure A=0/carry set; call FN_Error.
;   FN_ByteAvailable Return B=$02 when a byte is waiting, otherwise B=$00.
;                    Z reflects the result.
;   FN_SendByteA     Send the byte in A.  A is preserved.
;   FN_ReceiveByteA  Wait for and return one received byte in A.
;
; FN_Init sends the harmless DriveWire Fuji DEVICE_READY request ($E2,$00)
; and requires its $01 response.  Merely reading a valid-looking status value
; is not enough: MAME continues to expose $FF41/$FF42 after FujiNet-PC exits.

FN_BECKER_STATUS       EQU     $FF41
FN_BECKER_DATA         EQU     $FF42
FN_STATUS_RX_READY     EQU     $02

FN_DW_OPCODE_FUJI      EQU     $E2
FN_CMD_DEVICE_READY    EQU     $00
FN_CMD_SEND_RESPONSE   EQU     $01
FN_CMD_GET_WIFISTATUS  EQU     $FA
FN_REPLY_DEVICE_READY  EQU     $01

FN_INIT_DRAIN_LIMIT    EQU     64
FN_INIT_TIMEOUT        EQU     $FFFF

FN_ERROR_NONE          EQU     0
FN_ERROR_NO_RESPONSE   EQU     1
FN_ERROR_BAD_REPLY     EQU     2
FN_ERROR_BAD_STATUS    EQU     3

FN_Initialized         FCB     0
FN_LastError           FCB     FN_ERROR_NONE

FN_Init:
        CLR     FN_Initialized
        CLR     FN_LastError
        JSR     FN_DrainInput
        BCS     FN_InitFailed
        LDA     #FN_DW_OPCODE_FUJI
        STA     >FN_BECKER_DATA
        LDA     #FN_CMD_DEVICE_READY
        STA     >FN_BECKER_DATA
        JSR     FN_WaitByteA
        BCS     FN_InitFailed
        CMPA    #FN_REPLY_DEVICE_READY
        BNE     FN_InitBadReply
        INC     FN_Initialized          ; $01 = initialized
        CLRA                            ; FNINIT() status = success
        ANDCC   #$FE                    ; Carry clear = success
        RTS

FN_InitBadReply:
        LDA     #FN_ERROR_BAD_REPLY

FN_InitFailed:
        STA     FN_LastError
        ORCC    #$01                    ; Carry set = unavailable
        RTS

FN_Error:
        LDA     FN_LastError
        RTS

FN_WifiStatus:
        CLR     FN_LastError
        JSR     FN_DrainInput
        BCS     FN_WifiStatusFailed

        ; Queue GET_WIFISTATUS, then ask FujiNet to send its one-byte response.
        LDA     #FN_DW_OPCODE_FUJI
        STA     >FN_BECKER_DATA
        LDA     #FN_CMD_GET_WIFISTATUS
        STA     >FN_BECKER_DATA
        LDA     #FN_DW_OPCODE_FUJI
        STA     >FN_BECKER_DATA
        LDA     #FN_CMD_SEND_RESPONSE
        STA     >FN_BECKER_DATA
        JSR     FN_WaitByteA
        BCS     FN_WifiStatusFailed
        RTS

FN_WifiStatusFailed:
        STA     FN_LastError
        CLRA                            ; Zero is reserved for transport failure
        ORCC    #$01
        RTS

; Discard bounded stale input so it cannot be mistaken for the next response.
; Returns carry clear when idle, or carry set with an error code in A.
FN_DrainInput:
        LDB     #FN_INIT_DRAIN_LIMIT
FN_DrainInputLoop:
        LDA     >FN_BECKER_STATUS
        BEQ     FN_TransportOK
        CMPA    #FN_STATUS_RX_READY
        BNE     FN_TransportBadStatus
        LDA     >FN_BECKER_DATA
        DECB
        BNE     FN_DrainInputLoop
        BRA     FN_TransportBadStatus

; Wait about 0.6-1.3 seconds for one byte, depending on CoCo CPU speed.
; Returns the byte in A/carry clear, or an error code in A/carry set.
FN_WaitByteA:
        LDB     #1
FN_WaitBytePassesB:
        LDX     #FN_INIT_TIMEOUT
FN_WaitByteALoop:
        LDA     >FN_BECKER_STATUS
        CMPA    #FN_STATUS_RX_READY
        BEQ     FN_WaitByteAReady
        TSTA
        BNE     FN_TransportBadStatus
        LEAX    -1,X
        BNE     FN_WaitByteALoop
        DECB
        BNE     FN_WaitBytePassesB
        LDA     #FN_ERROR_NO_RESPONSE
        BRA     FN_TransportError

FN_WaitByteAReady:
        LDA     >FN_BECKER_DATA
FN_TransportOK:
        ANDCC   #$FE
        RTS

FN_TransportBadStatus:
        LDA     #FN_ERROR_BAD_STATUS
FN_TransportError:
        ORCC    #$01
        RTS

FN_ByteAvailable:
        LDB     >FN_BECKER_STATUS
        ANDB    #FN_STATUS_RX_READY
        RTS

FN_SendByteA:
        STA     >FN_BECKER_DATA
        RTS

FN_ReceiveByteA:
;        LDA     >FN_BECKER_STATUS
;        BITA    #FN_STATUS_RX_READY
;        BEQ     FN_ReceiveByteA
;
; A little more efficient/faster way
        LDA     #FN_STATUS_RX_READY
!       BITA    >FN_BECKER_STATUS
        BEQ     <                       ; Loop until status is ready
        LDA     >FN_BECKER_DATA         ; Return with Byte in A
        RTS
