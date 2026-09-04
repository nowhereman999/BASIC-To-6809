; Optional FujiNet AppKey persistent-storage support.
;
; FNAPPKEYSET() keeps the creator/application IDs locally.  Each read/write
; then opens the requested key in the required mode.  Current DriveWire
; firmware accepts at most 64 bytes.  WRITE_APPKEY is unusual: its two-byte
; big-endian parameter is the real count, but the following payload is always
; the complete 64-byte block (zero padded here).

FN_APPKEY_CMD_WRITE         EQU     $DE
FN_APPKEY_CMD_READ          EQU     $DD
FN_APPKEY_CMD_OPEN          EQU     $DC
FN_APPKEY_CMD_CLOSE         EQU     $DB
FN_APPKEY_MAX_LENGTH        EQU     64

FN_AppKeyCreator            FDB     0
FN_AppKeyApp                FCB     0
FN_AppKeyKey                FCB     0
FN_AppKeyMode               FCB     0
FN_AppKeyLength             FCB     0

; D=creator ID. FN_AppKeyApp has already been set by the compiler.
FN_AppKeySet:
        STD     FN_AppKeyCreator
        TSTA
        BNE     FN_AppKeySetOK
        TSTB
        LBEQ    FN_FujiBadArgument       ; creator ID zero is invalid
FN_AppKeySetOK:
        CLR     FN_LastError
        CLRA
        ANDCC   #$FE
        RTS

; Open the cached creator/application and selected key/mode.
FN_AppKeyOpen:
        LDD     FN_AppKeyCreator
        TSTA
        BNE     FN_AppKeyOpenCreatorOK
        TSTB
        LBEQ    FN_FujiBadArgument
FN_AppKeyOpenCreatorOK:
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_APPKEY_CMD_OPEN
        STA     >FN_BECKER_DATA
        LDD     FN_AppKeyCreator
        STA     >FN_BECKER_DATA           ; creator, big endian
        STB     >FN_BECKER_DATA
        LDA     FN_AppKeyApp
        STA     >FN_BECKER_DATA
        LDA     FN_AppKeyKey
        STA     >FN_BECKER_DATA
        LDA     FN_AppKeyMode
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA           ; reserved
        JMP     FN_FujiGetError

; B=key ID, data is length-prefixed in PF00. Returns A=0/error.
FN_AppKeyWrite:
        STB     FN_AppKeyKey
        LDA     _StrVar_PF00
        CMPA    #FN_APPKEY_MAX_LENGTH+1
        LBHS    FN_FujiBadArgument
        STA     FN_AppKeyLength
        LDA     #1                        ; APPKEYMODE_WRITE
        STA     FN_AppKeyMode
        JSR     FN_AppKeyOpen
        BCS     FN_AppKeyWriteDone

        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_APPKEY_CMD_WRITE
        STA     >FN_BECKER_DATA
        CLR     >FN_BECKER_DATA           ; real count, big-endian high byte
        LDA     FN_AppKeyLength
        STA     >FN_BECKER_DATA

        LDX     #_StrVar_PF00+1
        LDB     FN_AppKeyLength
        BEQ     FN_AppKeyWritePad
FN_AppKeyWriteDataLoop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_AppKeyWriteDataLoop
FN_AppKeyWritePad:
        LDB     #FN_APPKEY_MAX_LENGTH
        SUBB    FN_AppKeyLength
        BEQ     FN_AppKeyWriteGetError
FN_AppKeyWritePadLoop:
        CLR     >FN_BECKER_DATA
        DECB
        BNE     FN_AppKeyWritePadLoop
FN_AppKeyWriteGetError:
        JSR     FN_FujiGetError
FN_AppKeyWriteDone:
        RTS

; B=key ID. Returns the 0..64 binary bytes as a BASIC string.
FN_AppKeyReadString:
        STB     FN_AppKeyKey
        CLR     FN_AppKeyMode              ; APPKEYMODE_READ
        JSR     FN_AppKeyOpen
        BCS     FN_AppKeyStringError
        LDA     #FN_APPKEY_CMD_READ
        JSR     FN_FujiSimpleCommand
        BCS     FN_AppKeyStringError

        ; CoCo DriveWire response is BE16 real count plus a fixed 64-byte body.
        LDX     #_StrVar_PF01
        LDD     #FN_APPKEY_MAX_LENGTH+2
        JSR     FN_FujiGetResponse
        BCS     FN_AppKeyStringError
        LDD     _StrVar_PF01
        CMPD    #FN_APPKEY_MAX_LENGTH
        BHI     FN_AppKeyStringBadLength
        STB     _StrVar_PF00
        LDX     #_StrVar_PF01+2
        LDU     #_StrVar_PF00+1
        TSTB
        BEQ     FN_AppKeyStringReturn
FN_AppKeyReadCopy:
        LDA     ,X+
        STA     ,U+
        DECB
        BNE     FN_AppKeyReadCopy
FN_AppKeyStringReturn:
        JMP     FN_ReturnScratchString

FN_AppKeyStringBadLength:
        JSR     FN_FujiBadArgument
FN_AppKeyStringError:
        CLR     _StrVar_PF00
        JMP     FN_ReturnScratchString

FN_AppKeyClose:
        LDA     #FN_APPKEY_CMD_CLOSE
        JSR     FN_FujiSimpleCommand
        BCS     FN_AppKeyCloseDone
        CLR     FN_AppKeyCreator
        CLR     FN_AppKeyCreator+1
FN_AppKeyCloseDone:
        RTS
