************************************************************************
* CHAIN floppy-disk loader
*
* Permanent, stand-alone, read-only loader assembled immediately after any
* SDC_CHAIN loader (or at the selected layout base when used alone). It finds a
* DECB machine-language file, loads its records, and jumps to its EXEC address.
* It deliberately has no dependencies on the program it replaces.
*
* $0179-$01FF contains controller/file state.
* $0200-$02FF is the shared 256-byte input buffer.
* $0300-$03FF is left free for the stack, which starts at $0400.
*
* The compiler supplies packed base addresses, so both loaders may be present.
************************************************************************

        IFNDEF  DISK_CHAIN_BASE
DISK_CHAIN_BASE        EQU     $0800
        ENDC
DISK_CHAIN_STACK       EQU     $0400
DISK_CHAIN_TEMP_BASE   EQU     $0179
DISK_CHAIN_TEMP_LIMIT  EQU     $0400
DISK_CHAIN_BUFFER      EQU     $0200
DISK_CHAIN_BUFFER_END  EQU     $0300
DISK_CHAIN_DSKREG      EQU     $FF40
DISK_CHAIN_FDCREG      EQU     $FF48
DISK_CHAIN_GRANULES    EQU     68

* Fixed low-memory workspace. These aliases intentionally overlap the
* temporary workspace used by SDC_CHAIN; the loaders cannot run concurrently.
DiskChainOp            EQU     DISK_CHAIN_TEMP_BASE
DiskChainDrive         EQU     DiskChainOp+1
DiskChainTrack         EQU     DiskChainDrive+1
DiskChainSector        EQU     DiskChainTrack+1
DiskChainBufferPtr     EQU     DiskChainSector+1
DiskChainStatus        EQU     DiskChainBufferPtr+2
DiskChainNMIFlag       EQU     DiskChainStatus+1
DiskChainNMIReturn     EQU     DiskChainNMIFlag+1
DiskChainDriveImage    EQU     DiskChainNMIReturn+2
DiskChainTrackImage    EQU     DiskChainDriveImage+1
DiskChainCurrentGran   EQU     DiskChainTrackImage+1
DiskChainNextGran      EQU     DiskChainCurrentGran+1
DiskChainLastGran      EQU     DiskChainNextGran+1
DiskChainGranuleEnd    EQU     DiskChainLastGran+1
DiskChainNameRemain    EQU     DiskChainGranuleEnd+1
DiskChainBlockEnd      EQU     DiskChainNameRemain+1
DiskChainExec          EQU     DiskChainBlockEnd+2
DiskChainFilename      EQU     DiskChainExec+2       * Eleven-byte DECB 8.3 name

        ORG     DISK_CHAIN_BASE

* Enter with a counted compiler string immediately above the JSR return.
DiskChainStart:
        ORCC    #$50                    * No IRQ/FIRQ while replacing program
        PULS    Y                       * Discard return; CHAIN never returns
        CLR     DiskChainDrive
        LDB     ,S+
        STB     DiskChainNameRemain
        TFR     S,X
        LDU     #DiskChainFilename
        LDA     #' '
        LDB     #11
!       STA     ,U+
        DECB
        BNE     <

        LDU     #DiskChainFilename
        LDB     #8
DiskChainCopyBase:
        TST     DiskChainNameRemain
        BEQ     DiskChainUseDefaultExtension
        LDA     ,X
        CMPA    #'.'
        BEQ     DiskChainFoundExtension
        CMPA    #':'
        BEQ     DiskChainUseDefaultExtension
        LDA     ,X+
        DEC     DiskChainNameRemain
        STA     ,U+
        DECB
        BNE     DiskChainCopyBase
DiskChainFindExtension:
        TST     DiskChainNameRemain
        BEQ     DiskChainUseDefaultExtension
        LDA     ,X
        CMPA    #'.'
        BEQ     DiskChainFoundExtension
        CMPA    #':'
        BEQ     DiskChainUseDefaultExtension
        LEAX    1,X
        DEC     DiskChainNameRemain
        BRA     DiskChainFindExtension

DiskChainFoundExtension:
        LEAX    1,X
        DEC     DiskChainNameRemain
        LDU     #DiskChainFilename+8
        LDB     #3
DiskChainCopyExtension:
        TST     DiskChainNameRemain
        BEQ     DiskChainCheckDriveSuffix
        LDA     ,X
        CMPA    #':'
        BEQ     DiskChainCheckDriveSuffix
        LDA     ,X+
        DEC     DiskChainNameRemain
        STA     ,U+
        DECB
        BNE     DiskChainCopyExtension
        BRA     DiskChainCheckDriveSuffix

DiskChainUseDefaultExtension:
        LDD     #'B'*256+'I'
        STD     DiskChainFilename+8
        LDA     #'N'
        STA     DiskChainFilename+10

DiskChainCheckDriveSuffix:
        TST     DiskChainNameRemain
        BEQ     DiskChainNameReady
        LDA     ,X+
        DEC     DiskChainNameRemain
        CMPA    #':'
        BNE     DiskChainCheckDriveSuffix
        TST     DiskChainNameRemain
        BEQ     DiskChainNameReady
        LDA     ,X
        SUBA    #'0'
        CMPA    #3
        BHI     DiskChainNameReady
        STA     DiskChainDrive

DiskChainNameReady:
        LDS     #DISK_CHAIN_STACK
        CLR     >$FFD8                  * Normal speed for floppy timing
        LBSR    DiskChainInstallNMI
        STA     >$FFDF                  * Force all-RAM mode before loading
        LBSR    DiskChainOpenFile
        LBSR    DiskChainInitFile

* Parse DECB machine-language preambles and the final postamble.
DiskChainNextRecord:
        LBSR    DiskChainReadByteA
        TSTA
        BEQ     DiskChainPreamble
        CMPA    #$FF
        LBNE    DiskChainError
        LBSR    DiskChainReadWordD
        CMPD    #0
        LBNE    DiskChainError
        LBSR    DiskChainReadWordD
        STD     DiskChainExec
        LDA     #$D0                    * Stop controller and motor
        STA     DISK_CHAIN_FDCREG
        LDA     DiskChainDriveImage
        ANDA    #$B0
        STA     DiskChainDriveImage
        STA     DISK_CHAIN_DSKREG
        LDX     DiskChainExec
        JMP     ,X

DiskChainPreamble:
        LBSR    DiskChainReadWordD
        TFR     D,X                     * X = block length
        LBEQ    DiskChainError          * Cannot safely accept a 64K block
        LBSR    DiskChainReadWordD
        TFR     D,U                     * U = destination

* Consume an identical incoming loader block without self-overwriting.
        CMPU    #DISK_CHAIN_BASE
        BNE     DiskChainCheckProtectedRAM
        CMPX    #DiskChainLoaderLength
        LBNE    DiskChainError
DiskChainDiscardResidentLoader:
        LBSR    DiskChainReadByteA
        LEAX    -1,X
        BNE     DiskChainDiscardResidentLoader
        BRA     DiskChainNextRecord

* Calculate exclusive block end and reject address wraparound.
DiskChainCheckProtectedRAM:
        PSHS    X
        TFR     U,D
        ADDD    ,S++
        LBCS    DiskChainError
        STD     DiskChainBlockEnd

* Do not overwrite the CoCo 1/2 NMI vector while floppy NMIs are active.
        CMPU    #$010C
        BHS     DiskChainCheckWorkspace
        CMPD    #$0109
        LBHI    DiskChainError

* Protect state, input buffer, and the downward-growing stack.
DiskChainCheckWorkspace:
        CMPU    #DISK_CHAIN_TEMP_LIMIT
        BHS     DiskChainCheckLoader
        CMPD    #DISK_CHAIN_TEMP_BASE
        LBHI    DiskChainError

* Protect only the actual resident loader code.
DiskChainCheckLoader:
        CMPU    #DiskChainLoaderEnd
        BHS     DiskChainCopyBlock
        CMPD    #DISK_CHAIN_BASE
        LBHI    DiskChainError

DiskChainCopyBlock:
        LBSR    DiskChainReadByteA
        STA     ,U+
        LEAX    -1,X
        BNE     DiskChainCopyBlock
        LBRA    DiskChainNextRecord

* Install a resident NMI handler for either CoCo 1/2 or CoCo 3.
DiskChainInstallNMI:
        LDX     >$FFFE
        LDY     #$0109
        CMPX    #$8C1B
        BNE     DiskChainWriteNMI
        LDY     #$FEFD
DiskChainWriteNMI:
        LDA     #$7E
        STA     ,Y
        LDX     #DiskChainNMI
        STX     1,Y
        RTS

DiskChainNMI:
        LDA     DiskChainNMIFlag
        BEQ     DiskChainNMIReturnNow
        LDX     DiskChainNMIReturn
        STX     10,S
        CLR     DiskChainNMIFlag
DiskChainNMIReturnNow:
        RTI

* Locate the formatted filename in the DECB directory.
DiskChainOpenFile:
        LBSR    DiskChainBegin
        LDA     #3
        STA     DiskChainSector
DiskChainDirectorySector:
        LDA     #17
        LDB     DiskChainSector
        LDX     #DISK_CHAIN_BUFFER
        LBSR    DiskChainReadSectorDtoX
        LDX     #DISK_CHAIN_BUFFER
        LDA     #8
DiskChainDirectoryEntry:
        LDB     ,X
        LBEQ    DiskChainError
        CMPB    #$FF
        BEQ     DiskChainNextDirectoryEntry
        PSHS    A,X
        LDU     #DiskChainFilename
        LDB     #11
DiskChainCompareName:
        LDA     ,X+
        CMPA    ,U+
        BNE     DiskChainNameMismatch
        DECB
        BNE     DiskChainCompareName
        PULS    A,X
        RTS
DiskChainNameMismatch:
        PULS    A,X
DiskChainNextDirectoryEntry:
        LEAX    32,X
        DECA
        BNE     DiskChainDirectoryEntry
        INC     DiskChainSector
        LDA     DiskChainSector
        CMPA    #12
        BLO     DiskChainDirectorySector
        LBRA    DiskChainError

DiskChainInitFile:
        LDA     12,X                    * ASCII flag and file type
        ANDA    #$F0
        ORA     11,X
        CMPA    #2
        LBNE    DiskChainError
        LDA     13,X
        STA     DiskChainCurrentGran
                                        * Fall through to prepare granule

* Read current FAT entry, map track/sectors, then load its first sector.
DiskChainPrepareGranule:
        LDD     #17*$100+2
        LDX     #DISK_CHAIN_BUFFER
        LBSR    DiskChainReadSectorDtoX
        LDA     DiskChainCurrentGran
        CMPA    #DISK_CHAIN_GRANULES
        LBHS    DiskChainError
        LDB     A,X
        STB     DiskChainNextGran
        CLR     DiskChainLastGran
        CMPB    #$C0
        BLO     DiskChainFullGranule
        COM     DiskChainLastGran
        ANDB    #$3F
        LBEQ    DiskChainError
        CMPB    #9
        LBHI    DiskChainError
        PSHS    B
        BSR     DiskChainMapGranule
        ADDB    ,S+
        STB     DiskChainGranuleEnd
        BRA     DiskChainLoadFirstSector
DiskChainFullGranule:
        CMPB    #DISK_CHAIN_GRANULES
        LBHS    DiskChainError
        BSR     DiskChainMapGranule
        ADDB    #9
        STB     DiskChainGranuleEnd
DiskChainLoadFirstSector:
        LDD     DiskChainTrack
        LDX     #DISK_CHAIN_BUFFER
        LBSR    DiskChainReadSectorDtoX
        STX     DiskChainBufferPtr
        RTS

DiskChainMapGranule:
        LDA     DiskChainCurrentGran
        LDB     #1
        BITA    #1
        BEQ     >
        LDB     #10
!       CMPA    #34
        BLO     >
        ADDA    #2                      * Skip directory track 17
!       LSRA
        STA     DiskChainTrack
        STB     DiskChainSector
        RTS

DiskChainReadWordD:
        BSR     DiskChainReadByteA
        TFR     A,B
        LBSR    DiskChainReadByteA
        EXG     A,B
        RTS

DiskChainReadByteA:
        PSHS    B,X,U
        LDX     DiskChainBufferPtr
        CMPX    #DISK_CHAIN_BUFFER_END
        BNE     DiskChainHaveByte
        INC     DiskChainSector
        LDB     DiskChainSector
        CMPB    DiskChainGranuleEnd
        BLO     DiskChainReadNextSector
        TST     DiskChainLastGran
        LBNE    DiskChainReadPastEOF
        LDA     DiskChainNextGran
        STA     DiskChainCurrentGran
        LBSR    DiskChainPrepareGranule
        LDX     DiskChainBufferPtr
        BRA     DiskChainHaveByte
DiskChainReadNextSector:
        LDA     DiskChainTrack
        LDX     #DISK_CHAIN_BUFFER
        LBSR    DiskChainReadSectorDtoX
DiskChainHaveByte:
        LDA     ,X+
        STX     DiskChainBufferPtr
        PULS    B,X,U,PC
DiskChainReadPastEOF:
        PULS    B,X,U
        LBRA    DiskChainError

DiskChainBegin:
        CLR     DiskChainNMIFlag
        CLR     DiskChainStatus
        CLR     DiskChainDriveImage
        CLR     DiskChainTrackImage
        CLR     DiskChainOp
        LBSR    DiskChainDSKCON         * Restore selected drive to track zero
        TST     DiskChainStatus
        LBNE    DiskChainError
        RTS

DiskChainReadSectorDtoX:
        STD     DiskChainTrack
        STX     DiskChainBufferPtr
        LDA     #2
        STA     DiskChainOp
        LBSR    DiskChainDSKCON
        TST     DiskChainStatus
        LBNE    DiskChainError
        RTS

* Compact, read-only WD17xx controller driver.
DiskChainDSKCON:
        STA     >$FFDE                  * ROM mode supplies the hardware NMI path
        PSHS    U,Y,X,B,A
        LDA     #5
        PSHS    A
DiskChainCommandRetry:
        LDB     DiskChainDrive
        LDX     #DiskChainDriveMasks
        LDA     DiskChainDriveImage
        ANDA    #$A8
        ORA     B,X
        ORA     #$20                    * Double density
        LDB     DiskChainTrack
        CMPB    #22
        BLO     >
        ORA     #$10
!       TFR     A,B
        ORA     #$08
        STA     DiskChainDriveImage
        STA     DISK_CHAIN_DSKREG
        BITB    #$08
        BNE     DiskChainMotorReady
        LDX     #0
!       LEAX    -1,X
        BNE     <
        LDX     #0
!       LEAX    -1,X
        BNE     <
DiskChainMotorReady:
        LBSR    DiskChainWaitNotBusy
        BNE     DiskChainCommandResult
        CLR     DiskChainStatus
        TST     DiskChainOp
        BNE     DiskChainDoRead
        LBSR    DiskChainRestore
        BRA     DiskChainCommandResult
DiskChainDoRead:
        LBSR    DiskChainReadSectorCommand
DiskChainCommandResult:
        PULS    A
        LDB     DiskChainStatus
        BEQ     DiskChainCommandDone
        DECA
        BEQ     DiskChainCommandDone
        PSHS    A
        LBSR    DiskChainRestore
        BNE     DiskChainCommandResult
        BRA     DiskChainCommandRetry
DiskChainCommandDone:
        STA     >$FFDF                  * Return to all-RAM mode after disk I/O
        PULS    A,B,X,Y,U,PC

DiskChainRestore:
        CLR     DiskChainTrackImage
        LDA     #$03
        STA     DISK_CHAIN_FDCREG
        EXG     A,A
        EXG     A,A
        LBSR    DiskChainWaitNotBusy
        LBSR    DiskChainMediumDelay
        ANDA    #$10
        STA     DiskChainStatus
        RTS

DiskChainWaitNotBusy:
        LDX     #0
!       LEAX    -1,X
        BEQ     DiskChainForceInterrupt
        LDA     DISK_CHAIN_FDCREG
        BITA    #1
        BNE     <
        RTS
DiskChainForceInterrupt:
        LDA     #$D0
        STA     DISK_CHAIN_FDCREG
        EXG     A,A
        EXG     A,A
        LDA     DISK_CHAIN_FDCREG
        LDA     #$80
        STA     DiskChainStatus
        RTS

DiskChainMediumDelay:
        LDX     #8750
!       LEAX    -1,X
        BNE     <
        RTS

DiskChainReadSectorCommand:
        LDB     DiskChainTrackImage
        STB     DISK_CHAIN_FDCREG+1
        CMPB    DiskChainTrack
        BEQ     DiskChainHeadPositioned
        LDA     DiskChainTrack
        STA     DISK_CHAIN_FDCREG+3
        STA     DiskChainTrackImage
        LDA     #$17
        STA     DISK_CHAIN_FDCREG
        EXG     A,A
        EXG     A,A
        LBSR    DiskChainWaitNotBusy
        BNE     DiskChainSeekFailed
        LBSR    DiskChainMediumDelay
        ANDA    #$18
        BEQ     DiskChainHeadPositioned
        STA     DiskChainStatus
DiskChainSeekFailed:
        RTS
DiskChainHeadPositioned:
        LDA     DiskChainSector
        STA     DISK_CHAIN_FDCREG+2
        LDX     #DiskChainSectorComplete
        STX     DiskChainNMIReturn
        LDX     DiskChainBufferPtr
        LDA     DISK_CHAIN_FDCREG
        LDA     DiskChainDriveImage
        ORA     #$80
        LDY     #0
        LDU     #DISK_CHAIN_FDCREG
        COM     DiskChainNMIFlag
        ORCC    #$50
        LDB     #$80
        STB     DISK_CHAIN_FDCREG
        EXG     A,A
        EXG     A,A
        LDB     #2
!       BITB    ,U
        BNE     DiskChainReadDataByte
        LEAY    -1,Y
        BNE     <
        CLR     DiskChainNMIFlag
        ORCC    #$50                    * Keep IRQ/FIRQ masked during CHAIN
        LBRA    DiskChainForceInterrupt
DiskChainReadDataByte:
        LDB     DISK_CHAIN_FDCREG+3
        STB     ,X+
        STA     DISK_CHAIN_DSKREG
        BRA     DiskChainReadDataByte

DiskChainSectorComplete:
        ORCC    #$50                    * Replaced program IRQ code is not safe
        LDA     DISK_CHAIN_FDCREG
        ANDA    #$7C
        STA     DiskChainStatus
        RTS

DiskChainDriveMasks:
        FCB     1,2,4,$40

* Stand-alone visible failure state: stop controller, show red, and halt.
DiskChainError:
        ORCC    #$50
        LDA     #$D0
        STA     DISK_CHAIN_FDCREG
        LDA     DiskChainDriveImage
        ANDA    #$B0
        STA     DISK_CHAIN_DSKREG
        LDA     #$3F
        STA     $FF22
!       BRA     <

DiskChainLoaderEnd:
DiskChainLoaderLength  EQU     DiskChainLoaderEnd-DiskChainStart

        IFNE    DiskChainLoaderLength-$03F0
        FAIL    "Disk CHAIN loader length changed; update the compiler memory-layout constant"
        ENDC

        IFDEF   PROGRAM_SAFE_START
        IFGT    DiskChainLoaderEnd-PROGRAM_SAFE_START
        FAIL    "Disk CHAIN loader overlaps the calculated program area"
        ENDC
        ELSE
        IFGT    DiskChainLoaderEnd-$0E00
        FAIL    "Disk CHAIN loader overlaps the default program area at $0E00"
        ENDC
        ENDC

        REORG
