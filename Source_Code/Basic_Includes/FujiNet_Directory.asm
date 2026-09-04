; FujiNet host-directory services for the CoCo DriveWire Fuji device.
;
; Public entry points:
;   FN_OpenDirectory       B=host, PF00=path, PF01=filter, A=status
;   FN_CloseDirectory      A=status
;   FN_ReadDirectoryString FN_DirMaxLength/FN_DirDetails set, pushes string
;   FN_GetDirectoryPosition returns D=position
;   FN_SetDirectoryPosition D=position, returns A=status
;
; FNREADDIR$(maxLen,details) accepts maxLen 1..254. A zero details value
; returns a normal NUL-trimmed filename. Any nonzero value requests the
; DriveWire additional-details record (firmware aux2 bit $80) and returns
; exactly maxLen binary bytes so embedded zeroes are preserved. The CoCo
; details prefix is 13 bytes: year/month/day/hour/minute/second, big-endian
; size (4), is-directory, was-truncated, and media type.

FN_DIR_CMD_OPEN               EQU     $F7
FN_DIR_CMD_READ               EQU     $F6
FN_DIR_CMD_CLOSE              EQU     $F5
FN_DIR_CMD_GET_POSITION       EQU     $E5
FN_DIR_CMD_SET_POSITION       EQU     $E4
FN_DIR_DETAILS_FLAG           EQU     $80

FN_DirHost                    FCB     0
FN_DirMaxLength               FCB     0
FN_DirDetails                 FCB     0
FN_DirPositionBytes           RMB     2

; B=host slot, PF00=[len][path], PF01=[len][filter].
FN_OpenDirectory:
        CMPB    #8
        LBHS    FN_FujiBadArgument
        STB     FN_DirHost

        ; The fixed payload is path, NUL, filter, NUL, then zero padding.
        ; Both terminators must fit: path length + filter length <= 254.
        CLRA
        LDB     _StrVar_PF00
        ADDD    #0                      ; make the 8-bit length explicit in D
        ADDB    _StrVar_PF01
        ADCA    #0
        CMPD    #254
        LBHI    FN_FujiBadArgument

        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_DIR_CMD_OPEN
        STA     >FN_BECKER_DATA
        LDA     FN_DirHost
        STA     >FN_BECKER_DATA

        LDX     #_StrVar_PF00+1
        LDB     _StrVar_PF00
        BEQ     FN_DirOpenPathDone
FN_DirOpenPathLoop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_DirOpenPathLoop
FN_DirOpenPathDone:
        CLR     >FN_BECKER_DATA

        LDX     #_StrVar_PF01+1
        LDB     _StrVar_PF01
        BEQ     FN_DirOpenFilterDone
FN_DirOpenFilterLoop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_DirOpenFilterLoop
FN_DirOpenFilterDone:
        CLR     >FN_BECKER_DATA

        LDB     #254
        SUBB    _StrVar_PF00
        SUBB    _StrVar_PF01
        BEQ     FN_DirOpenPayloadDone
FN_DirOpenPadLoop:
        CLR     >FN_BECKER_DATA
        DECB
        BNE     FN_DirOpenPadLoop
FN_DirOpenPayloadDone:
        JMP     FN_FujiGetError

FN_CloseDirectory:
        LDA     #FN_DIR_CMD_CLOSE
        JMP     FN_FujiSimpleCommand

; FN_DirMaxLength=1..254, FN_DirDetails=0 filename or nonzero binary details.
FN_ReadDirectoryString:
        LDA     FN_DirMaxLength
        BEQ     FN_DirStringBadArgument
        CMPA    #255
        BHS     FN_DirStringBadArgument

        CLR     FN_LastError
        JSR     FN_DrainInput
        BCS     FN_DirStringTransportError
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_DIR_CMD_READ
        STA     >FN_BECKER_DATA
        LDA     FN_DirMaxLength
        STA     >FN_BECKER_DATA
        LDA     FN_DirDetails
        BEQ     FN_DirReadFilenameOnly
        LDA     #FN_DIR_DETAILS_FLAG
FN_DirReadFilenameOnly:
        STA     >FN_BECKER_DATA
        JSR     FN_FujiGetError
        BCS     FN_DirStringError

        LDX     #_StrVar_PF00+1
        CLRA
        LDB     FN_DirMaxLength
        JSR     FN_FujiGetResponse
        BCS     FN_DirStringError

        LDB     FN_DirMaxLength
        TST     FN_DirDetails
        BNE     FN_DirStringLengthReady
        LDX     #_StrVar_PF00+1
        CLRB
FN_DirTrimFilenameLoop:
        CMPB    FN_DirMaxLength
        BHS     FN_DirStringLengthReady
        TST     ,X+
        BEQ     FN_DirStringLengthReady
        INCB
        BRA     FN_DirTrimFilenameLoop
FN_DirStringLengthReady:
        STB     _StrVar_PF00
        JMP     FN_ReturnScratchString

FN_DirStringBadArgument:
        LDA     #4
FN_DirStringTransportError:
        STA     FN_LastError
FN_DirStringError:
        CLR     _StrVar_PF00
        ORCC    #$01
        JMP     FN_ReturnScratchString

; Firmware sends the uint16_t response in its native little-endian order.
; Convert the two response bytes into the 6809's big-endian D register.
FN_GetDirectoryPosition:
        LDA     #FN_DIR_CMD_GET_POSITION
        JSR     FN_FujiSimpleCommand
        BCS     FN_DirPositionError
        LDX     #FN_DirPositionBytes
        LDD     #2
        JSR     FN_FujiGetResponse
        BCS     FN_DirPositionError
        LDB     FN_DirPositionBytes
        LDA     FN_DirPositionBytes+1
        ANDCC   #$FE
        RTS
FN_DirPositionError:
        CLRA
        CLRB
        ORCC    #$01
        RTS

; D=position. DriveWire multi-byte parameters are big-endian on the wire.
FN_SetDirectoryPosition:
        STD     FN_DirPositionBytes
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_DIR_CMD_SET_POSITION
        STA     >FN_BECKER_DATA
        LDA     FN_DirPositionBytes
        STA     >FN_BECKER_DATA
        LDA     FN_DirPositionBytes+1
        STA     >FN_BECKER_DATA
        JMP     FN_FujiGetError
