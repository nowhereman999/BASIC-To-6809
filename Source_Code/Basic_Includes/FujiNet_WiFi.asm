; Wi-Fi discovery/configuration and adapter information.
;
; Public entry points:
;   FN_WifiEnabled             A=0/1 (FNERROR distinguishes disabled/error)
;   FN_WifiScan                A=number of scan results
;   FN_WifiScanNameString      B=index, returns SSID as BASIC string
;   FN_WifiScanRSSI            B=index, returns signed RSSI in D
;   FN_SetWifi                 SSID in PF00, password in PF01; A=status
;   FN_AdapterString           B=field (0-8), returns BASIC string
;
; FNADAPTER$(field): 0 SSID, 1 hostname, 2 IP, 3 gateway, 4 netmask,
; 5 DNS, 6 MAC, 7 BSSID, 8 firmware version.

FN_WIFI_CMD_SCAN             EQU     $FD
FN_WIFI_CMD_SCAN_RESULT      EQU     $FC
FN_WIFI_CMD_SET_SSID         EQU     $FB
FN_WIFI_CMD_ENABLED          EQU     $EA
FN_WIFI_CMD_ADAPTER_EXT      EQU     $C4

FN_WifiIndex                 FCB     0
FN_WifiValue                 FCB     0
FN_AdapterField              FCB     0
FN_AdapterSource             FDB     0
FN_AdapterMaxLength          FCB     0

FN_WifiEnabled:
        LDA     #FN_WIFI_CMD_ENABLED
        JSR     FN_FujiSimpleCommand
        BCS     FN_WifiScalarError
        LDX     #FN_WifiValue
        LDD     #1
        JSR     FN_FujiGetResponse
        BCS     FN_WifiScalarError
        LDA     FN_WifiValue
        ANDCC   #$FE
        RTS

FN_WifiScan:
        LDA     #FN_WIFI_CMD_SCAN
        JSR     FN_FujiSimpleCommand
        BCS     FN_WifiScalarError
        LDX     #FN_WifiValue
        LDD     #1
        JSR     FN_FujiGetResponse
        BCS     FN_WifiScalarError
        LDA     FN_WifiValue
        ANDCC   #$FE
        RTS

FN_WifiScalarError:
        CLRA
        ORCC    #$01
        RTS

; Issue GET_SCAN_RESULT and receive the 33-byte SSID plus signed RSSI.
; Input B=index; output is placed at PF01[0..33].
FN_WifiGetScanResult:
        STB     FN_WifiIndex
        CLR     FN_LastError
        JSR     FN_DrainInput
        BCS     FN_WifiGetScanFailed
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_WIFI_CMD_SCAN_RESULT
        STA     >FN_BECKER_DATA
        LDA     FN_WifiIndex
        STA     >FN_BECKER_DATA
        JSR     FN_FujiGetError
        BCS     FN_WifiGetScanFailed
        LDX     #_StrVar_PF01
        LDD     #34
        JMP     FN_FujiGetResponse
FN_WifiGetScanFailed:
        STA     FN_LastError
        ORCC    #$01
        RTS

FN_WifiScanNameString:
        JSR     FN_WifiGetScanResult
        LBCS    FN_WifiStringError
        LDX     #_StrVar_PF01
        LDU     #_StrVar_PF00+1
        CLRB
FN_WifiNameCopy:
        CMPB    #32
        BHS     FN_WifiNameDone
        LDA     ,X+
        BEQ     FN_WifiNameDone
        STA     ,U+
        INCB
        BRA     FN_WifiNameCopy
FN_WifiNameDone:
        STB     _StrVar_PF00
        JMP     FN_ReturnScratchString

FN_WifiScanRSSI:
        JSR     FN_WifiGetScanResult
        BCS     FN_WifiRSSIError
        LDB     _StrVar_PF01+33
        SEX
        ANDCC   #$FE
        RTS
FN_WifiRSSIError:
        CLRA
        CLRB
        ORCC    #$01
        RTS

FN_SetWifi:
        LDA     _StrVar_PF00
        CMPA    #33
        LBHS    FN_FujiBadArgument       ; SSID is at most 32 characters
        LDA     _StrVar_PF01
        CMPA    #64
        LBHS    FN_FujiBadArgument       ; password is at most 63 characters
        CLR     FN_LastError
        JSR     FN_DrainInput
        BCS     FN_SetWifiFailed

        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_WIFI_CMD_SET_SSID
        STA     >FN_BECKER_DATA

        LDX     #_StrVar_PF00+1
        LDB     _StrVar_PF00
        BEQ     FN_SetWifiSSIDPad
FN_SetWifiSSIDSend:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_SetWifiSSIDSend
FN_SetWifiSSIDPad:
        LDB     #33
        SUBB    _StrVar_PF00
FN_SetWifiSSIDPadLoop:
        CLR     >FN_BECKER_DATA
        DECB
        BNE     FN_SetWifiSSIDPadLoop

        LDX     #_StrVar_PF01+1
        LDB     _StrVar_PF01
        BEQ     FN_SetWifiPasswordPad
FN_SetWifiPasswordSend:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_SetWifiPasswordSend
FN_SetWifiPasswordPad:
        LDB     #64
        SUBB    _StrVar_PF01
FN_SetWifiPasswordPadLoop:
        CLR     >FN_BECKER_DATA
        DECB
        BNE     FN_SetWifiPasswordPadLoop
        JMP     FN_FujiGetError
FN_SetWifiFailed:
        STA     FN_LastError
        ORCC    #$01
        RTS

FN_AdapterString:
        CMPB    #9
        LBHS    FN_WifiStringBadArgument
        STB     FN_AdapterField
        LDA     #FN_WIFI_CMD_ADAPTER_EXT
        JSR     FN_FujiSimpleCommand
        LBCS    FN_WifiStringError
        LDX     #_StrVar_PF00
        LDD     #240
        JSR     FN_FujiGetResponse
        LBCS    FN_WifiStringError

        ; Select the requested NUL-terminated member of AdapterConfigExtended.
        LDB     FN_AdapterField
        BEQ     FN_AdapterSSID
        CMPB    #1
        BEQ     FN_AdapterHostname
        CMPB    #2
        BEQ     FN_AdapterIP
        CMPB    #3
        BEQ     FN_AdapterGateway
        CMPB    #4
        BEQ     FN_AdapterNetmask
        CMPB    #5
        BEQ     FN_AdapterDNS
        CMPB    #6
        BEQ     FN_AdapterMAC
        CMPB    #7
        BEQ     FN_AdapterBSSID
        LDX     #_StrVar_PF00+125        ; firmware version
        LDB     #15
        BRA     FN_AdapterCopySelected
FN_AdapterSSID:
        LDX     #_StrVar_PF00
        LDB     #33
        BRA     FN_AdapterCopySelected
FN_AdapterHostname:
        LDX     #_StrVar_PF00+33
        LDB     #64
        BRA     FN_AdapterCopySelected
FN_AdapterIP:
        LDX     #_StrVar_PF00+140
        LDB     #16
        BRA     FN_AdapterCopySelected
FN_AdapterGateway:
        LDX     #_StrVar_PF00+156
        LDB     #16
        BRA     FN_AdapterCopySelected
FN_AdapterNetmask:
        LDX     #_StrVar_PF00+172
        LDB     #16
        BRA     FN_AdapterCopySelected
FN_AdapterDNS:
        LDX     #_StrVar_PF00+188
        LDB     #16
        BRA     FN_AdapterCopySelected
FN_AdapterMAC:
        LDX     #_StrVar_PF00+204
        LDB     #18
        BRA     FN_AdapterCopySelected
FN_AdapterBSSID:
        LDX     #_StrVar_PF00+222
        LDB     #18

FN_AdapterCopySelected:
        STX     FN_AdapterSource
        STB     FN_AdapterMaxLength
        LDU     #_StrVar_PF01
        CLRB
FN_AdapterCopyLoop:
        CMPB    FN_AdapterMaxLength
        BHS     FN_AdapterCopyDone
        LDX     FN_AdapterSource
        LDA     ,X+
        STX     FN_AdapterSource
        BEQ     FN_AdapterCopyDone
        STA     ,U+
        INCB
        BRA     FN_AdapterCopyLoop
FN_AdapterCopyDone:
        STB     _StrVar_PF00
        LDX     #_StrVar_PF01
        LDU     #_StrVar_PF00+1
        TSTB
        BEQ     FN_AdapterReturn
FN_AdapterMoveLoop:
        LDA     ,X+
        STA     ,U+
        DECB
        BNE     FN_AdapterMoveLoop
FN_AdapterReturn:
        JMP     FN_ReturnScratchString

FN_WifiStringBadArgument:
        LDA     #4
        STA     FN_LastError
FN_WifiStringError:
        CLR     _StrVar_PF00
        JMP     FN_ReturnScratchString
