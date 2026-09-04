; FujiNet host/device slot configuration and mounting for CoCo DriveWire.
; Host slots: 8 records x 32 bytes.  CoCo device slots: 4 records x 38
; bytes (host, mode, filename[36]).  Scratch buffers are reused so this
; optional module reserves only its small scalar state.
;
; Disk access constants from firmware lib/device/disk.h:
;   0 = invalid/unconfigured, 1 = read, 2 = write, $40 = mounted flag.
; FNSETDEVICE() and FNMOUNTIMAGE() accept only 1 or 2. FNDEVICEMODE()
; returns the firmware's raw byte, so a mounted slot can return $41/$42.

FN_DISK_MODE_READ               EQU     1
FN_DISK_MODE_WRITE              EQU     2
FN_DISK_MODE_MOUNTED            EQU     $40

FN_MOUNT_CMD_MOUNT_HOST       EQU     $F9
FN_MOUNT_CMD_MOUNT_IMAGE      EQU     $F8
FN_MOUNT_CMD_READ_HOSTS       EQU     $F4
FN_MOUNT_CMD_WRITE_HOSTS      EQU     $F3
FN_MOUNT_CMD_READ_DEVICES     EQU     $F2
FN_MOUNT_CMD_UNMOUNT_IMAGE    EQU     $E9
FN_MOUNT_CMD_UNMOUNT_HOST     EQU     $E6
FN_MOUNT_CMD_SET_DEVICE_FILE  EQU     $E2
FN_MOUNT_CMD_SET_HOST_PREFIX  EQU     $E1
FN_MOUNT_CMD_GET_HOST_PREFIX  EQU     $E0
FN_MOUNT_CMD_GET_DEVICE_FILE  EQU     $DA
FN_MOUNT_CMD_MOUNT_ALL        EQU     $D7

FN_MountSlot                  FCB     0
FN_MountMode                  FCB     0
FN_MountHost                  FCB     0
FN_MountField                 FCB     0

; B=host slot, return its configured hostname as a BASIC string.
FN_HostSlotString:
        CMPB    #8
        LBHS    FN_MountStringBadArgument
        STB     FN_MountSlot
        LDA     #FN_MOUNT_CMD_READ_HOSTS
        JSR     FN_FujiSimpleCommand
        LBCS    FN_MountStringError
        LDX     #_StrVar_PF00
        LDD     #256
        JSR     FN_FujiGetResponse
        LBCS    FN_MountStringError

        LDA     #32
        LDB     FN_MountSlot
        MUL
        LDX     #_StrVar_PF00
        LEAX    D,X
        LDU     #_StrVar_PF01
        CLRB
FN_HostSlotCopy:
        CMPB    #31
        LBHS    FN_MountFinishString
        LDA     ,X+
        LBEQ    FN_MountFinishString
        STA     ,U+
        INCB
        BRA     FN_HostSlotCopy

; B=host slot, new hostname is length-prefixed in PF01.
FN_SetHostSlot:
        CMPB    #8
        LBHS    FN_FujiBadArgument
        STB     FN_MountSlot
        LDA     _StrVar_PF01
        CMPA    #32
        LBHS    FN_FujiBadArgument

        ; Preserve the new name in PF01 while the complete current table is
        ; fetched into PF00, then replace exactly one 32-byte record.
        LDA     #FN_MOUNT_CMD_READ_HOSTS
        JSR     FN_FujiSimpleCommand
        BCS     FN_SetHostSlotFailed
        LDX     #_StrVar_PF00
        LDD     #256
        JSR     FN_FujiGetResponse
        BCS     FN_SetHostSlotFailed
        LDA     #32
        LDB     FN_MountSlot
        MUL
        LDX     #_StrVar_PF00
        LEAX    D,X
        PSHS    X
        LDB     #32
FN_SetHostClear:
        CLR     ,X+
        DECB
        BNE     FN_SetHostClear
        PULS    X
        LDU     #_StrVar_PF01+1
        LDB     _StrVar_PF01
        BEQ     FN_SetHostSend
FN_SetHostCopy:
        LDA     ,U+
        STA     ,X+
        DECB
        BNE     FN_SetHostCopy
FN_SetHostSend:
        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_MOUNT_CMD_WRITE_HOSTS
        STA     >FN_BECKER_DATA
        LDX     #_StrVar_PF00
        CLRB                            ; 0 decrements through all 256 bytes
FN_SetHostSendLoop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_SetHostSendLoop
        JMP     FN_FujiGetError
FN_SetHostSlotFailed:
        RTS

; B=device slot, return its configured full path (up to 254 bytes).
FN_DeviceFileString:
        CMPB    #4
        LBHS    FN_MountStringBadArgument
        STB     FN_MountSlot
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_MountStringTransportError
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_MOUNT_CMD_GET_DEVICE_FILE
        STA     >FN_BECKER_DATA
        LDA     FN_MountSlot
        STA     >FN_BECKER_DATA
        JSR     FN_FujiGetError
        LBCS    FN_MountStringError
        LDX     #_StrVar_PF00
        LDD     #256
        JSR     FN_FujiGetResponse
        LBCS    FN_MountStringError
        LDX     #_StrVar_PF00
        LDU     #_StrVar_PF01
        CLRB
FN_DeviceFileCopy:
        CMPB    #254
        LBHS    FN_MountFinishString
        LDA     ,X+
        LBEQ    FN_MountFinishString
        STA     ,U+
        INCB
        BRA     FN_DeviceFileCopy

; Compiler fills device/host/mode and puts filename in PF00.
FN_SetDeviceFile:
        LDA     FN_MountSlot
        CMPA    #4
        LBHS    FN_FujiBadArgument
        LDA     FN_MountHost
        CMPA    #8
        LBHS    FN_FujiBadArgument
        LDA     FN_MountMode
        CMPA    #FN_DISK_MODE_READ
        BEQ     FN_SetDeviceModeOK
        CMPA    #FN_DISK_MODE_WRITE
        LBNE    FN_FujiBadArgument
FN_SetDeviceModeOK:
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_MOUNT_CMD_SET_DEVICE_FILE
        STA     >FN_BECKER_DATA
        LDA     FN_MountSlot
        STA     >FN_BECKER_DATA
        LDA     FN_MountHost
        STA     >FN_BECKER_DATA
        LDA     FN_MountMode
        STA     >FN_BECKER_DATA
        JSR     FN_MountSendPF00Fixed256
        JMP     FN_FujiGetError

; B=device slot. FN_MountField=0 returns host; 1 returns mode, in A.
FN_DeviceSlotField:
        CMPB    #4
        LBHS    FN_FujiBadArgument
        STB     FN_MountSlot
        LDA     #FN_MOUNT_CMD_READ_DEVICES
        JSR     FN_FujiSimpleCommand
        BCS     FN_DeviceSlotFieldError
        LDX     #_StrVar_PF00
        LDD     #152
        JSR     FN_FujiGetResponse
        BCS     FN_DeviceSlotFieldError
        LDA     #38
        LDB     FN_MountSlot
        MUL
        LDX     #_StrVar_PF00
        LEAX    D,X
        LDB     FN_MountField
        ABX
        LDA     ,X
        ANDCC   #$FE
        RTS
FN_DeviceSlotFieldError:
        CLRA
        ORCC    #$01
        RTS

; B=slot for the one-parameter mount/unmount operation selected in A.
FN_MountOneParameter:
        STA     FN_FujiSavedCommand
        STB     FN_MountSlot
        CMPA    #FN_MOUNT_CMD_MOUNT_HOST
        BEQ     FN_MountValidateHost
        CMPA    #FN_MOUNT_CMD_UNMOUNT_HOST
        BEQ     FN_MountValidateHost
        CMPB    #4
        LBHS    FN_MountBadArgument
        BRA     FN_MountOneSend
FN_MountValidateHost:
        CMPB    #8
        LBHS    FN_MountBadArgument
FN_MountOneSend:
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_MountTransportError
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     FN_FujiSavedCommand
        STA     >FN_BECKER_DATA
        LDA     FN_MountSlot
        STA     >FN_BECKER_DATA
        JMP     FN_FujiGetError

; FN_MountSlot=device slot and FN_MountMode=1 read-only/2 read-write.
FN_MountDisk:
        LDB     FN_MountSlot
        CMPB    #4
        LBHS    FN_MountBadArgument
        LDA     FN_MountMode
        CMPA    #FN_DISK_MODE_READ
        BEQ     FN_MountDiskModeOK
        CMPA    #FN_DISK_MODE_WRITE
        LBNE    FN_MountBadArgument
FN_MountDiskModeOK:
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_MountTransportError
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_MOUNT_CMD_MOUNT_IMAGE
        STA     >FN_BECKER_DATA
        LDA     FN_MountSlot
        STA     >FN_BECKER_DATA
        LDA     FN_MountMode
        STA     >FN_BECKER_DATA
        JMP     FN_FujiGetError

FN_MountAll:
        LDA     #FN_MOUNT_CMD_MOUNT_ALL
        JMP     FN_FujiSimpleCommand

; B=host slot, return its current prefix as a BASIC string.
FN_HostPrefixString:
        CMPB    #8
        LBHS    FN_MountStringBadArgument
        STB     FN_MountSlot
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_MountStringTransportError
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_MOUNT_CMD_GET_HOST_PREFIX
        STA     >FN_BECKER_DATA
        LDA     FN_MountSlot
        STA     >FN_BECKER_DATA
        JSR     FN_FujiGetError
        LBCS    FN_MountStringError
        LDX     #_StrVar_PF00
        LDD     #256
        JSR     FN_FujiGetResponse
        BCS     FN_MountStringError
        LDX     #_StrVar_PF00
        LDU     #_StrVar_PF01
        CLRB
FN_HostPrefixCopy:
        CMPB    #254
        BHS     FN_MountFinishString
        LDA     ,X+
        BEQ     FN_MountFinishString
        STA     ,U+
        INCB
        BRA     FN_HostPrefixCopy

; B=host slot, prefix in PF00.
FN_SetHostPrefix:
        CMPB    #8
        LBHS    FN_FujiBadArgument
        STB     FN_MountSlot
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_FujiFail
        LDA     #FN_FUJI_OPCODE
        STA     >FN_BECKER_DATA
        LDA     #FN_MOUNT_CMD_SET_HOST_PREFIX
        STA     >FN_BECKER_DATA
        LDA     FN_MountSlot
        STA     >FN_BECKER_DATA
        JSR     FN_MountSendPF00Fixed256
        JMP     FN_FujiGetError

FN_MountSendPF00Fixed256:
        LDX     #_StrVar_PF00+1
        LDB     _StrVar_PF00
        BEQ     FN_MountPadPF00
FN_MountSendPF00Loop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        DECB
        BNE     FN_MountSendPF00Loop
FN_MountPadPF00:
        LDB     _StrVar_PF00
        NEGB
FN_MountPadPF00Loop:
        CLR     >FN_BECKER_DATA
        DECB
        BNE     FN_MountPadPF00Loop
        RTS

FN_MountFinishString:
        STB     _StrVar_PF00
        LDX     #_StrVar_PF01
        LDU     #_StrVar_PF00+1
        TSTB
        BEQ     FN_MountReturnString
FN_MountMoveString:
        LDA     ,X+
        STA     ,U+
        DECB
        BNE     FN_MountMoveString
FN_MountReturnString:
        JMP     FN_ReturnScratchString

FN_MountBadArgument:
        LDA     #4
FN_MountTransportError:
        STA     FN_LastError
        ORCC    #$01
        RTS

FN_MountStringBadArgument:
        LDA     #4
FN_MountStringTransportError:
        STA     FN_LastError
FN_MountStringError:
        CLR     _StrVar_PF00
        ORCC    #$01
        JMP     FN_ReturnScratchString
