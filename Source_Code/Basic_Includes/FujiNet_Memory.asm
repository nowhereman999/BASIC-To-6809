; Direct-memory network transfers for binary data larger than a BASIC string.
;
; Compiler-filled parameters:
;   FN_MemoryChannel  network channel 0-7
;   FN_MemoryAddress  first byte in CoCo address space
;   FN_MemoryCount    unsigned 16-bit byte count
; FN_ReadMemory returns D=the number of bytes copied (possibly zero). Any
; failure is reported through FN_LastError/FNERROR(). FN_WriteMemory returns
; A=0 on success or an error code on failure.

FN_MEM_OPCODE_NET       EQU     $E3
FN_MEM_CMD_RESPONSE     EQU     $01
FN_MEM_CMD_READ         EQU     $52     ; ASCII 'R'
FN_MEM_CMD_WRITE        EQU     $57     ; ASCII 'W'
FN_MEM_TIMEOUT_PASSES   EQU     12

FN_MemoryChannel        FCB     0
FN_MemoryAddress        FDB     0
FN_MemoryCount          FDB     0
FN_MemoryRemaining      FDB     0
FN_MemoryTransferred    FDB     0

FN_ReadMemory:
        CLR     FN_LastError
        CLR     FN_MemoryTransferred
        CLR     FN_MemoryTransferred+1
        JSR     FN_MemoryValidate
        LBCS    FN_ReadMemoryFailure

        ; A status transaction both triggers pending HTTP work and prevents a
        ; binary read from blocking when fewer bytes are currently available.
        LDB     FN_MemoryChannel
        JSR     FN_ChannelStatus
        LBCS    FN_ReadMemoryFailure
        LDA     FN_ChannelStatusError
        CMPA    #1                      ; normal status
        BEQ     FN_ReadMemorySize
        CMPA    #136                    ; EOF may still accompany final bytes
        LBNE    FN_ReadMemoryChannelError

FN_ReadMemorySize:
        LDD     FN_ChannelStatusBytes
        BEQ     FN_ReadMemorySuccess
        CMPD    FN_MemoryCount
        BLS     FN_ReadMemoryHaveSize
        LDD     FN_MemoryCount
FN_ReadMemoryHaveSize:
        STD     FN_MemoryTransferred
        STD     FN_MemoryRemaining
        JSR     FN_DrainInput
        LBCS    FN_ReadMemoryTransportError

        ; Request the binary block.
        LDA     #FN_MEM_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_MEM_CMD_READ
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryTransferred
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryTransferred+1
        STA     >FN_BECKER_DATA

        ; Ask FujiNet to place that response on the DriveWire bus.
        LDA     #FN_MEM_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_MEM_CMD_RESPONSE
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryTransferred
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryTransferred+1
        STA     >FN_BECKER_DATA

FN_ReadMemoryLoop:
        LDB     #FN_MEM_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        LBCS    FN_ReadMemoryTransportError
        LDX     FN_MemoryAddress         ; wait helper uses X as its timeout
        STA     ,X+
        STX     FN_MemoryAddress
        LDD     FN_MemoryRemaining
        SUBD    #1
        STD     FN_MemoryRemaining
        BNE     FN_ReadMemoryLoop

        LDA     FN_MemoryChannel
        STA     FN_IOChannel
        JSR     FN_NetworkGetError
        BEQ     FN_ReadMemorySuccess
        CMPA    #136                    ; an exact read at EOF is still valid
        BNE     FN_ReadMemoryFailure

FN_ReadMemorySuccess:
        CLR     FN_LastError
        LDD     FN_MemoryTransferred
        ANDCC   #$FE
        RTS

FN_ReadMemoryChannelError:
        STA     FN_LastError
        BRA     FN_ReadMemoryFailure
FN_ReadMemoryTransportError:
        STA     FN_LastError
FN_ReadMemoryFailure:
        CLRA
        CLRB
        ORCC    #$01
        RTS

FN_WriteMemory:
        CLR     FN_LastError
        JSR     FN_MemoryValidate
        BCS     FN_WriteMemoryFailure
        LDD     FN_MemoryCount
        STD     FN_MemoryRemaining
        JSR     FN_DrainInput
        BCS     FN_WriteMemoryTransportError

        LDA     #FN_MEM_OPCODE_NET
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryChannel
        STA     >FN_BECKER_DATA
        LDA     #FN_MEM_CMD_WRITE
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryCount
        STA     >FN_BECKER_DATA
        LDA     FN_MemoryCount+1
        STA     >FN_BECKER_DATA

        LDX     FN_MemoryAddress
FN_WriteMemoryLoop:
        LDA     ,X+
        STA     >FN_BECKER_DATA
        LDD     FN_MemoryRemaining
        SUBD    #1
        STD     FN_MemoryRemaining
        BNE     FN_WriteMemoryLoop

        LDA     FN_MemoryChannel
        STA     FN_IOChannel
        JMP     FN_NetworkGetError

FN_WriteMemoryTransportError:
        STA     FN_LastError
FN_WriteMemoryFailure:
        ORCC    #$01
        RTS

; Reject channel numbers outside 0-7, zero-byte transfers, and any range
; whose inclusive final address would wrap past $FFFF.
FN_MemoryValidate:
        LDB     FN_MemoryChannel
        CMPB    #8
        BHS     FN_MemoryBadArgument
        LDD     FN_MemoryCount
        BEQ     FN_MemoryBadArgument
        SUBD    #1
        ADDD    FN_MemoryAddress
        BCS     FN_MemoryBadArgument
        ANDCC   #$FE
        RTS
FN_MemoryBadArgument:
        LDA     #4
        STA     FN_LastError
        ORCC    #$01
        RTS
