; Compact DECB disk support for LOADM, SAVEM, _FILEEXISTS, sequential byte
; files, file information, deletion, and flat-directory enumeration.
;
; This module owns the disk-controller NMI for the lifetime of the compiled
; program. The compiler installs DNMISV at $0109 on a CoCo 1/2 or $FEFD on a
; CoCo 3. No Disk BASIC RAM between $0600 and $0DFF is used.
;
; All controller variables, stream state, allocation data, and the independent
; 256-byte input/output buffers are resident labels in this module. No disk
; workspace is placed under the compiler stack. The stand-alone CHAIN loaders
; may continue using lower RAM because they never return to an open stream.
;
; Compiler syntax (flat DECB filesystem, optional :0 through :3 drive suffix):
;   OPEN "NAME.EXT:drive","R|W",handle   handle is 0 or 1
;   CLOSE(handle)                         one reader and one writer may be open
;   PUTBYTE0 value / PUTBYTE1 value
;   value = GETBYTE(handle)               returns zero after EOF
;   SETPOS0(position) / SETPOS1(position) unsigned 32-bit byte position
;   length = LOF(handle)                   unsigned 32-bit file length
;   info$ = FILEINFO$(handle)             32 bytes, size at 29-32 LSB first
;   status = DELETE(filename$)
;   status = INITDIR(pattern$)             use *.* for every file
;   status = DIRPAGE(0)                    16 records in scratch page
;   entry$ = DIRLIST$(0-15)                16 bytes, size at 13-16 MSB first
;
; Read seeks restart the FAT chain. Forward write seeks zero-fill the gap;
; backward write seeks are rejected. Directory commands cannot run while a
; stream is open. Input and output have independent state and sector buffers.

DSKREG          EQU     $FF40
FDCREG          EQU     $FF48
SECLEN          EQU     256
GRANMX          EQU     68
DIRLEN          EQU     32
MAXSAVEGRAN     EQU     29

DIRTYP          EQU     11
DIRASC          EQU     12
DIRGRN          EQU     13

DEFDRV          EQU     DCDRV           ; compatibility name

; Clear all resident controller and stream state before the compiler enables
; its IRQ. Sector buffers need no initialization because reads fill them and
; the writer explicitly pads its final sector.
DiskInitialize:
        PSHS    D,X                     ; startup still needs its IRQ-vector X
        LDX     #DiskWorkspaceStart
        CLRA
!       STA     ,X+
        CMPX    #DiskInputBuffer
        BNE     <
        LDD     #$4446                  ; stream workspace signature "DF"
        STD     DiskStreamMagic
        PULS    D,X,PC

; Convert compiler string at ,S to DNAMBF. Missing extension defaults to BIN.
; A trailing :0 through :3 selects the floppy drive.
FixFileName:
        PULS    Y
        CLR     DCDRV
        LDX     #_StrVar_PF00
        LDB     ,S+
        STB     ,X+
!       LDA     ,S+
        STA     ,X+
        DECB
        BNE     <
        PSHS    Y
        LDX     #_StrVar_PF00+1
        LDU     #DNAMBF
        LDA     _StrVar_PF00
        PSHS    A                       ; remaining source length
        LDB     #8
DiskCopyFilename:
        TST     ,S
        BEQ     DiskPadNameDefaultExt
        LDA     ,X
        CMPA    #'.'
        BEQ     DiskPadNameCopyExt
        CMPA    #':'
        BEQ     DiskPadNameDefaultExt
        LDA     ,X+
        DEC     ,S
        STA     ,U+
        DECB
        BNE     DiskCopyFilename
DiskFindExtension:
        TST     ,S
        BEQ     DiskUseDefaultExt
        LDA     ,X
        CMPA    #'.'
        BEQ     DiskFoundExtension
        CMPA    #':'
        BEQ     DiskUseDefaultExt
        LEAX    1,X
        DEC     ,S
        BRA     DiskFindExtension
DiskFoundExtension:
        LEAX    1,X
        DEC     ,S
        BRA     DiskCopyExtension
DiskPadNameCopyExt:
        LDA     #' '
!       STA     ,U+
        DECB
        BNE     <
        LEAX    1,X
        DEC     ,S
        BRA     DiskCopyExtension
DiskPadNameDefaultExt:
        LDA     #' '
!       STA     ,U+
        DECB
        BNE     <
DiskUseDefaultExt:
        LDD     #'B'*256+'I'
        STD     ,U++
        LDA     #'N'
        STA     ,U+
        BRA     DiskCheckDriveSuffix
DiskCopyExtension:
        LDB     #3
DiskCopyExtensionLoop:
        TST     ,S
        BEQ     DiskPadExtension
        LDA     ,X
        CMPA    #':'
        BEQ     DiskPadExtension
        LDA     ,X+
        DEC     ,S
        STA     ,U+
        DECB
        BNE     DiskCopyExtensionLoop
        BRA     DiskCheckDriveSuffix
DiskPadExtension:
        LDA     #' '
!       STA     ,U+
        DECB
        BNE     <
DiskCheckDriveSuffix:
        TST     ,S
        BEQ     DiskFixNameDone
        LDA     ,X+
        DEC     ,S
        CMPA    #':'
        BNE     DiskCheckDriveSuffix
        TST     ,S
        BEQ     DiskFixNameDone
        LDA     ,X+
        SUBA    #'0'
        CMPA    #3
        BHI     DiskFixNameDone
        STA     DCDRV
DiskFixNameDone:
        LEAS    1,S
        RTS

; Put the controller in a known state without relying on Disk BASIC RAM.
DiskBegin:
        LDA     >CoCoHardware
        BPL     >
        FCB     $11,$3D,%00000000       ; LDMD #0: 6309 emulation mode
!       RORA
        BCC     >
        STA     >$FFD8                  ; CoCo 3 normal speed
!       CLR     DRGRAM
        CLR     NMIFLG
        CLR     DCSTA
        CLR     RDYTMR
        CLR     DCOPC
        JSR     DSKCON                  ; restore selected drive to track zero
        TST     DCSTA
        LBNE    DiskIOError
        RTS

; Search directory for the name at U. Remember first reusable slot for SAVEM.
; C clear/X=entry if found; C set if absent. FreeDirSec=$FF means full.
OpenFileU:
        LDX     #DiskInputBuffer
        BRA     OpenFileWithBuffer
OpenFileWriteU:
        LDX     #DiskOutputBuffer
OpenFileWithBuffer:
        STX     DiskWorkBuffer
        STU     DiskSearchName
        JSR     DiskBegin
        LDU     DiskSearchName
        LDA     #$FF
        STA     DiskFreeDirSec
        LDA     #3
        STA     DiskDirSector
DiskScanNextSector:
        LDA     #17
        LDB     DiskDirSector
        LDX     DiskWorkBuffer
        JSR     ReadSectorDtoX
        LDX     DiskWorkBuffer
        CLRA                            ; byte offset in directory sector
DiskScanNextEntry:
        LDB     ,X
        BEQ     DiskRememberFreeEntry
        CMPB    #$FF
        BEQ     DiskRememberLastFree
        PSHS    A,X,U
        LDB     #11
DiskCompareName:
        LDA     ,X+
        CMPA    ,U+
        BNE     DiskNameMismatch
        DECB
        BNE     DiskCompareName
        PULS    A,X,U
        ANDCC   #$FE
        RTS
DiskNameMismatch:
        PULS    A,X,U
        BRA     DiskAdvanceDirEntry
DiskRememberLastFree:
        BSR     DiskRememberFree
        LDB     #DiskErrorFileNotFound
        ORCC    #1
        RTS
DiskRememberFreeEntry:
        BSR     DiskRememberFree
DiskAdvanceDirEntry:
        LEAX    DIRLEN,X
        ADDA    #DIRLEN
        BNE     DiskScanNextEntry       ; wraps after eight entries
        INC     DiskDirSector
        LDA     DiskDirSector
        CMPA    #12
        BLO     DiskScanNextSector
        LDB     #DiskErrorFileNotFound
        ORCC    #1
        RTS
DiskRememberFree:
        PSHS    A
        LDA     DiskFreeDirSec
        CMPA    #$FF
        BNE     >
        LDA     DiskDirSector
        STA     DiskFreeDirSec
        PULS    A
        STA     DiskFreeDirOff
        RTS
!       PULS    A,PC

; Initialize found directory entry for sequential file reads.
InitFile:
        LDD     14,X
        CMPD    #SECLEN
        LBHI    DiskBadMLFile
        STD     DiskReadLastLen
        LDA     DIRASC,X
        ANDA    #$F0
        ORA     DIRTYP,X
        STA     DiskFileType
        LDA     DIRGRN,X
        STA     DiskCurrentGran
        STA     DiskFirstGran
        JSR     DiskLoadPrepareGranule
        LBCS    DiskBadMLFile
        RTS

; Reuse DiskBuffer for the FAT lookup, then load first data sector.
DiskLoadPrepareGranule:
        LDD     #17*$100+2
        LDX     #DiskBuffer
        JSR     ReadSectorDtoX
        LDA     DiskCurrentGran
        CMPA    #GRANMX
        BHS     DiskLoadBadChain
        LDB     A,X
        STB     DiskNextGran
        CLR     DiskLastGran
        CMPB    #$C0
        BLO     DiskLoadFullGranule
        COM     DiskLastGran
        ANDB    #$3F
        BEQ     DiskLoadBadChain
        CMPB    #9
        BHI     DiskLoadBadChain
        PSHS    B
        JSR     DiskMapCurrentGranule
        ADDB    ,S+
        STB     DiskGranuleEnd
        BRA     DiskLoadFirstSector
DiskLoadFullGranule:
        CMPB    #GRANMX
        BHS     DiskLoadBadChain
        JSR     DiskMapCurrentGranule
        ADDB    #9
        STB     DiskGranuleEnd
DiskLoadFirstSector:
        LDD     DCTRK
        LDX     #DiskBuffer
        JSR     ReadSectorDtoX
        STX     DiskBufferPtr
        BSR     DiskSetReadLimit
        ANDCC   #$FE
        RTS
DiskLoadBadChain:
        ORCC    #1
        RTS

DiskSetReadLimit:
        PSHS    D
        LDX     #DiskBuffer
        TST     DiskLastGran
        BEQ     DiskSetFullReadLimit
        LDA     DSEC
        INCA
        CMPA    DiskGranuleEnd
        BNE     DiskSetFullReadLimit
        LDD     DiskReadLastLen
        BNE     DiskAddReadLimit
DiskSetFullReadLimit:
        LDD     #SECLEN
DiskAddReadLimit:
        LEAX    D,X
DiskStoreReadLimit:
        STX     DiskReadLimit
        PULS    D,PC

; Map granule 0-67 to track/starting sector, skipping directory track 17.
DiskMapCurrentGranule:
        LDA     DiskCurrentGran
DiskMapGranuleA:
        LDB     #1
        BITA    #1
        BEQ     >
        LDB     #10
!       CMPA    #34
        BLO     >
        ADDA    #2
!       LSRA
        STA     DCTRK
        STB     DSEC
        RTS

; LOADM reader. _Var_PF10 is added to every load and EXEC address.
; There is deliberately no aggregate 16-bit file-length counter: every DECB
; segment has its own 16-bit length/address and parsing continues through the
; complete FAT chain until the postamble. This permits files larger than 64K,
; including CoCo 3 files which alternate a write to $FFA0-$FFA7 with an 8K
; data segment in the newly mapped logical window. Use offset zero for those
; bank-selector segments so the $FFAx destination is not relocated.
DiskLOADM:
        LDA     DiskFileType
        CMPA    #$02
        LBNE    DiskBadMLFile
DiskGetMLBlock:
        BSR     DiskReadByteA
        TSTA
        BEQ     DiskDoPreamble
        CMPA    #$FF
        LBNE    DiskBadMLFile
        BSR     DiskReadWordD
        CMPD    #0
        LBNE    DiskBadMLFile
        BSR     DiskReadWordD
        ADDD    _Var_PF10
        STD     EXECAddress
        JSR     SetCPUSpeed
        RTS
DiskDoPreamble:
        BSR     DiskReadWordD
        TFR     D,X
        BSR     DiskReadWordD
        ADDD    _Var_PF10
        TFR     D,U
        BSR     DiskCheckLoadWorkspace
!       BSR     DiskReadByteA
        STA     ,U+
        LEAX    -1,X
        BNE     <                       ; X=0 represents 65536 bytes
        BRA     DiskGetMLBlock

; Reject a LOADM segment which would overwrite the resident disk state or
; either sector buffer before the operation can finish. U=start, X=length;
; X=0 is the DECB encoding for a full 65536-byte segment.
DiskCheckLoadWorkspace:
        CMPX    #0
        BEQ     DiskLoadWorkspaceError
        STU     DiskLoadStart
        TFR     X,D
        ADDD    DiskLoadStart
        STD     DiskLoadEnd
        BCS     DiskLoadRangeWraps
        CMPU    #DiskWorkspaceEnd
        BHS     DiskLoadWorkspaceSafe
        CMPD    #DiskWorkspaceStart
        BLS     DiskLoadWorkspaceSafe
        BRA     DiskLoadWorkspaceError
DiskLoadRangeWraps:
        CMPD    #DiskWorkspaceStart
        BHI     DiskLoadWorkspaceError
        CMPU    #DiskWorkspaceEnd
        BLO     DiskLoadWorkspaceError
DiskLoadWorkspaceSafe:
        RTS
DiskLoadWorkspaceError:
        LBRA    DiskSaveWorkspaceError
DiskReadWordD:
        BSR     DiskReadByteA
        TFR     A,B
        BSR     DiskReadByteA
        EXG     A,B
        RTS
DiskReadByteA:
        PSHS    B,X,U
        LDX     DiskBufferPtr
        CMPX    DiskReadLimit
        BNE     DiskReadHaveByte
        INC     DSEC
        LDB     DSEC
        CMPB    DiskGranuleEnd
        BLO     DiskReadNextSector
        TST     DiskLastGran
        BNE     DiskReadPastEOF
        LDA     DiskNextGran
        STA     DiskCurrentGran
        JSR     DiskLoadPrepareGranule
        BCS     DiskReadPastEOF
        LDX     DiskBufferPtr
        BRA     DiskReadHaveByte
DiskReadNextSector:
        LDA     DCTRK
        LDX     #DiskBuffer
        JSR     ReadSectorDtoX
        STX     DiskBufferPtr
        LBSR    DiskSetReadLimit
        LDX     DiskBufferPtr
DiskReadHaveByte:
        LDA     ,X+
        STX     DiskBufferPtr
        ANDCC   #$FE                    ; carry clear means a byte was read
        PULS    B,X,U,PC
DiskReadPastEOF:
        PULS    B,X,U
        TST     DiskReadOpen
        BEQ     DiskBadMLFile
        ORCC    #1
        RTS
DiskBadMLFile:
        LDB     #DiskErrorNotMLFileType
        JMP     DiskError

************************************************************************
* Compiler-facing sequential DECB file API. Handles 0 and 1 are accepted so
* SDC source is easy to port. One reader and one writer may be open together.
************************************************************************
; A=0 read or 1 write, B=logical handle, DNAMBF/DCDRV already formatted.
DiskOpenFileAB:
        PSHS    D                       ; preserve A=mode and B=handle
        LBSR    DiskEnsureStreamInit
        PULS    D
        ANDB    #1
        PSHS    A
        TST     ,S+
        BNE     DiskOpenWrite
DiskOpenRead:
        TST     DiskReadOpen
        LBNE    DiskStreamBusyError
        TST     DiskWriteOpen
        BEQ     >
        CMPB    DiskWriteHandle
        LBEQ    DiskStreamBusyError
!       STB     DiskReadHandle
        LBSR    DiskSaveReadIdentity
        CLR     DiskFilePosition
        CLR     DiskFilePosition+1
        CLR     DiskFilePosition+2
        CLR     DiskFilePosition+3
        LDU     #DNAMBF
        JSR     OpenFileU
        LBCS    DiskOpenNotFound
        LDA     DIRGRN,X
        STA     DiskFirstGran
        LDD     14,X
        STD     DiskReadLastLen
        JSR     DiskCalculateFileSize
        LDU     #DNAMBF
        JSR     OpenFileU
        LBCS    DiskOpenNotFound
        JSR     InitFile
        LBSR    DiskSaveReadLocation
        COM     DiskReadOpen
        RTS
DiskOpenWrite:
        TST     DiskWriteOpen
        LBNE    DiskStreamBusyError
        TST     DiskReadOpen
        BEQ     >
        CMPB    DiskReadHandle
        LBEQ    DiskStreamBusyError
!       STB     DiskWriteHandle
        LBSR    DiskSaveWriteIdentity
        CLR     DiskWriteFilePosition
        CLR     DiskWriteFilePosition+1
        CLR     DiskWriteFilePosition+2
        CLR     DiskWriteFilePosition+3
        LDA     #1                      ; DECB data file
        STA     DiskOutputFileType
        CLR     DiskOutputASCII
        COM     DiskOverwriteAllowed    ; OPEN "W" creates or truncates
        JSR     DiskWriterBegin
        CLR     DiskOverwriteAllowed
        LBSR    DiskSaveWriteLocation
        COM     DiskWriteOpen
        RTS

DiskCloseFileB:
        ANDB    #1
        TST     DiskReadOpen
        BEQ     DiskCloseCheckWrite
        CMPB    DiskReadHandle
        BNE     DiskCloseCheckWrite
        LBSR    DiskActivateRead
        CLR     DiskReadOpen
        JSR     SetCPUSpeed
        RTS
DiskCloseCheckWrite:
        TST     DiskWriteOpen
        LBEQ    DiskStreamClosedError
        CMPB    DiskWriteHandle
        LBNE    DiskStreamClosedError
        LBSR    DiskActivateWrite
        TST     DiskWriteAny
        LBEQ    DiskEmptyStreamError
        JSR     DiskFinishWriteBuffer
        JSR     DiskWriterCommit
        CLR     DiskWriteOpen
        JSR     SetCPUSpeed
        RTS

DiskPutByteB0:
        PSHS    B
        CLRB
        BRA     DiskPutByteHandleReady
DiskPutByteB1:
        PSHS    B
        LDB     #1
DiskPutByteHandleReady:
        CMPB    DiskWriteHandle
        LBNE    DiskPutWrongHandle
        TST     DiskWriteOpen
        LBEQ    DiskPutWrongHandle
        LBSR    DiskActivateWrite
        PULS    B
        JSR     DiskWriteByteB
        BSR     DiskIncrementWritePosition
        LBSR    DiskSaveWriteLocation
        RTS
DiskPutWrongHandle:
        LEAS    1,S
        LBRA    DiskStreamClosedError

; B=handle, returns next byte in B. EOF returns zero.
DiskGetByteB:
        ANDB    #1
        CMPB    DiskReadHandle
        LBNE    DiskStreamClosedError
        TST     DiskReadOpen
        LBEQ    DiskStreamClosedError
        LBSR    DiskActivateRead
        JSR     DiskReadByteA
        BCS     DiskGetByteEOF
        LBSR    DiskSaveReadLocation
        TFR     A,B
        BSR     DiskIncrementPosition
        RTS
DiskGetByteEOF:
        LBSR    DiskSaveReadLocation
        CLRB
        RTS

DiskIncrementPosition:
        INC     DiskFilePosition+3
        BNE     >
        INC     DiskFilePosition+2
        BNE     >
        INC     DiskFilePosition+1
        BNE     >
        INC     DiskFilePosition
!       RTS

DiskIncrementWritePosition:
        INC     DiskWriteFilePosition+3
        BNE     >
        INC     DiskWriteFilePosition+2
        BNE     >
        INC     DiskWriteFilePosition+1
        BNE     >
        INC     DiskWriteFilePosition
!       RTS

; B=handle and X -> unsigned big-endian 32-bit byte offset.
DiskSetPosBX:
        ANDB    #1
        PSHS    B
        LDD     ,X
        STD     DiskSeekTarget
        LDD     2,X
        STD     DiskSeekTarget+2
        LDB     ,S+
        TST     DiskReadOpen
        BEQ     DiskSeekCheckWrite
        CMPB    DiskReadHandle
        BNE     DiskSeekCheckWrite
        LBSR    DiskActivateRead
        BRA     DiskSeekRead
DiskSeekCheckWrite:
        TST     DiskWriteOpen
        LBEQ    DiskStreamClosedError
        CMPB    DiskWriteHandle
        LBNE    DiskStreamClosedError
        LBSR    DiskActivateWrite
; Writes may seek forward by filling the gap with zeroes.
        LDX     #DiskSeekTarget
        LDU     #DiskWriteFilePosition
        LDB     #4
!       LDA     ,X+
        CMPA    ,U+
        LBLO    DiskBackwardWriteSeekError
        BHI     DiskSeekWriteForward
        DECB
        BNE     <
        BRA     DiskSeekWriteDone
DiskSeekWriteForward:
        LDD     DiskWriteFilePosition
        CMPD    DiskSeekTarget
        BNE     >
        LDD     DiskWriteFilePosition+2
        CMPD    DiskSeekTarget+2
        BEQ     DiskSeekWriteDone
!       CLRB
        JSR     DiskWriteByteB
        LBSR    DiskIncrementWritePosition
        BRA     DiskSeekWriteForward
DiskSeekWriteDone:
        LBSR    DiskSaveWriteLocation
        RTS
DiskSeekRead:
; Restart the FAT chain, then discard bytes to the requested position.
        LDU     #DNAMBF
        JSR     OpenFileU
        LBCS    DiskOpenNotFound
        JSR     InitFile
        CLR     DiskFilePosition
        CLR     DiskFilePosition+1
        CLR     DiskFilePosition+2
        CLR     DiskFilePosition+3
DiskSeekReadLoop:
        LDD     DiskFilePosition
        CMPD    DiskSeekTarget
        BNE     >
        LDD     DiskFilePosition+2
        CMPD    DiskSeekTarget+2
        BEQ     DiskSeekDone
!       JSR     DiskReadByteA
        BCS     DiskSeekDone             ; clamp a seek beyond EOF to EOF
        LBSR    DiskIncrementPosition
        BRA     DiskSeekReadLoop
DiskSeekDone:
        LBSR    DiskSaveReadLocation
        RTS

; Calculate exact size using DiskFirstGran/DiskReadLastLen. Result is the
; unsigned big-endian 32-bit value at DiskFileSize.
DiskCalculateFileSize:
        CLR     DiskFileSize
        CLR     DiskFileSize+1
        CLR     DiskFileSize+2
        CLR     DiskFileSize+3
        LDD     #17*$100+2
        LDX     #DiskBuffer
        JSR     ReadSectorDtoX
        LDA     DiskFirstGran
DiskSizeGranuleLoop:
        CMPA    #GRANMX
        LBHS    DiskBadMLFile
        LDB     A,X
        CMPB    #$C0
        BHS     DiskSizeLastGranule
        CMPB    #GRANMX
        LBHS    DiskBadMLFile
        PSHS    B
        LDD     DiskFileSize+2
        ADDD    #9*SECLEN
        STD     DiskFileSize+2
        BCC     >
        LDD     DiskFileSize
        ADDD    #1
        STD     DiskFileSize
!       PULS    A
        BRA     DiskSizeGranuleLoop
DiskSizeLastGranule:
        ANDB    #$3F
        LBEQ    DiskBadMLFile
        CMPB    #9
        LBHI    DiskBadMLFile
        DECB
        CLRA
        ADDB    DiskFileSize+2           ; add complete sectors * 256
        STB     DiskFileSize+2
        BCC     >
        INC     DiskFileSize+1
        BNE     >
        INC     DiskFileSize
!       LDD     DiskReadLastLen
        BNE     >
        LDD     #SECLEN
!       ADDD    DiskFileSize+2
        STD     DiskFileSize+2
        BCC     >
        LDD     DiskFileSize
        ADDD    #1
        STD     DiskFileSize
!       RTS

; B=handle. Build the SDC-compatible 32-byte record in _StrVar_IFRight.
DiskFileInfoB:
        ANDB    #1
        TST     DiskReadOpen
        BEQ     DiskFileInfoCheckWrite
        CMPB    DiskReadHandle
        BNE     DiskFileInfoCheckWrite
        LDX     #DiskReadName
        LDU     #DiskFileSize
        BRA     DiskFileInfoSelected
DiskFileInfoCheckWrite:
        TST     DiskWriteOpen
        LBEQ    DiskStreamClosedError
        CMPB    DiskWriteHandle
        LBNE    DiskStreamClosedError
        LDX     #DiskWriteName
        LDU     #DiskWriteFilePosition
DiskFileInfoSelected:
        STU     DiskInfoSizePtr
        PSHS    X
        LDX     #_StrVar_IFRight
        CLRA
        LDB     #32
!       STA     ,X+
        DECB
        BNE     <
        PULS    X
        LDU     #_StrVar_IFRight
        LDB     #11
!       LDA     ,X+
        STA     ,U+
        DECB
        BNE     <
        CLR     _StrVar_IFRight+11       ; no FAT32 attribute flags on DECB
        LDX     DiskInfoSizePtr
        LDD     ,X
        STA     _StrVar_IFRight+31
        STB     _StrVar_IFRight+30
        LDD     2,X
        STA     _StrVar_IFRight+29
        STB     _StrVar_IFRight+28
        RTS

; B=handle. Return the unsigned 32-bit length in D:X (MSW:LSW).
; An input stream returns its complete file length. An output stream returns
; the number of bytes written so far, including buffered bytes.
DiskLOFB:
        ANDB    #1
        TST     DiskReadOpen
        BEQ     DiskLOFCheckWrite
        CMPB    DiskReadHandle
        BNE     DiskLOFCheckWrite
        LDD     DiskFileSize
        LDX     DiskFileSize+2
        RTS
DiskLOFCheckWrite:
        TST     DiskWriteOpen
        LBEQ    DiskStreamClosedError
        CMPB    DiskWriteHandle
        LBNE    DiskStreamClosedError
        LDD     DiskWriteFilePosition
        LDX     DiskWriteFilePosition+2
        RTS

DiskEnsureStreamInit:
        LDD     DiskStreamMagic
        CMPD    #$4446                  ; "DF"
        BEQ     >
        CLR     DiskReadOpen
        CLR     DiskWriteOpen
        CLR     DiskDirNextEntry
        CLR     DiskDirInitialized
        LDD     #$4446
        STD     DiskStreamMagic
!       RTS

DiskRequireNoStreams:
        LBSR    DiskEnsureStreamInit
        TST     DiskReadOpen
        LBNE    DiskStreamBusyError
        TST     DiskWriteOpen
        LBNE    DiskStreamBusyError
        RTS

DiskSaveReadIdentity:
        LDA     DCDRV
        STA     DiskReadDrive
        LDX     #DNAMBF
        LDU     #DiskReadName
        BRA     DiskCopyIdentity
DiskSaveWriteIdentity:
        LDA     DCDRV
        STA     DiskWriteDrive
        LDX     #DNAMBF
        LDU     #DiskWriteName
DiskCopyIdentity:
        LDB     #11
!       LDA     ,X+
        STA     ,U+
        DECB
        BNE     <
        RTS

DiskActivateRead:
        LDA     DiskReadDrive
        STA     DCDRV
        LDX     #DiskReadName
        LDU     #DNAMBF
        BSR     DiskCopyIdentity
        LDD     DiskReadTrack
        STD     DCTRK
        RTS
DiskActivateWrite:
        LDA     DiskWriteDrive
        STA     DCDRV
        LDX     #DiskWriteName
        LDU     #DNAMBF
        BSR     DiskCopyIdentity
        LDD     DiskWriteTrack
        STD     DCTRK
        RTS

DiskSaveReadLocation:
        PSHS    D
        LDD     DCTRK
        STD     DiskReadTrack
        PULS    D,PC
DiskSaveWriteLocation:
        PSHS    D
        LDD     DCTRK
        STD     DiskWriteTrack
        PULS    D,PC

; Initialize a flat directory wildcard. DNAMBF is already formatted by
; FixFileName. '*' and '?' match any remaining/individual character.
DiskInitDirectory:
        LBSR    DiskEnsureStreamInit
        TST     DiskReadOpen
        LBNE    DiskStreamBusyError
        TST     DiskWriteOpen
        LBNE    DiskStreamBusyError
        LDX     #DNAMBF
        LDU     #DiskDirPattern
        LDB     #8
        BSR     DiskCopyPatternField
        LDB     #3
        BSR     DiskCopyPatternField
        CLR     DiskDirNextEntry
        COM     DiskDirInitialized
        CLRB
        RTS
DiskCopyPatternField:
        LDA     ,X+
        CMPA    #'?'
        BEQ     DiskPatternWildcardOne
        CMPA    #'*'
        BEQ     DiskPatternWildcardRest
        STA     ,U+
        DECB
        BNE     DiskCopyPatternField
        RTS
DiskPatternWildcardOne:
        LDA     #$FF
        STA     ,U+
        DECB
        BNE     DiskCopyPatternField
        RTS
DiskPatternWildcardRest:
        LEAX    -1,X                    ; LDA ,X+ already advanced past '*'
        LDA     #$FF
!       STA     ,U+
        LEAX    1,X
        DECB
        BNE     <
        RTS

; Return the next SDC-compatible page: 16 records x 16 bytes in _StrVar_PF01.
; B=0 success (including a final partial/zero page), B=4 after all 72 slots.
DiskDirectoryPage:
        LBSR    DiskEnsureStreamInit
        TST     DiskReadOpen
        LBNE    DiskStreamBusyError
        TST     DiskWriteOpen
        LBNE    DiskStreamBusyError
        TST     DiskDirInitialized
        LBEQ    DiskDirectoryAtEnd
        LDA     DiskDirNextEntry
        CMPA    #72
        BHS     DiskDirectoryAtEnd
        JSR     DiskBegin               ; restore/synchronize only when disk I/O is required
        LDX     #_StrVar_PF01
        CLRA
        LDB     #0                       ; wraps after clearing 256 bytes
!       STA     ,X+
        DECB
        BNE     <
        LDU     #_StrVar_PF01
        CLR     DiskDirPageCount
DiskDirectoryScan:
        LDA     DiskDirNextEntry
        CMPA    #72
        BHS     DiskDirectoryPageDone
        INC     DiskDirNextEntry
        BSR     DiskReadDirectoryEntryA
        LDA     ,X
        BEQ     DiskDirectoryScan
        CMPA    #$FF
        BEQ     DiskDirectoryScan
        PSHS    X,U
        LDY     #DiskDirPattern
        LDB     #11
DiskDirectoryMatch:
        LDA     ,Y+
        CMPA    #$FF
        BEQ     >
        CMPA    ,X
        BNE     DiskDirectoryNoMatch
!       LEAX    1,X
        DECB
        BNE     DiskDirectoryMatch
        PULS    X,U
; Copy name/ext and build the record before the size calculation reuses buffer.
        PSHS    U
        LDB     #11
!       LDA     ,X+
        STA     ,U+
        DECB
        BNE     <
        LDA     #$20                     ; regular file attribute
        STA     ,U+
        LDA     2,X                      ; first granule; X is entry+11
        STA     DiskFirstGran
        LDD     14-11,X
        STD     DiskReadLastLen
        JSR     DiskCalculateFileSize
        LDD     DiskFileSize
        STD     ,U++                     ; directory size is MSB first
        LDD     DiskFileSize+2
        STD     ,U
        PULS    U
        LEAU    16,U
        INC     DiskDirPageCount
        LDA     DiskDirPageCount
        CMPA    #16
        BLO     DiskDirectoryScan
DiskDirectoryPageDone:
        JSR     SetCPUSpeed
        CLRB
        RTS
DiskDirectoryNoMatch:
        PULS    X,U
        BRA     DiskDirectoryScan
DiskDirectoryAtEnd:
        JSR     SetCPUSpeed
        LDB     #4
        RTS

; A=directory slot 0-71. Return X pointing at its 32-byte entry.
DiskReadDirectoryEntryA:
        LDB     #3
!       CMPA    #8
        BLO     >
        SUBA    #8
        INCB
        BRA     <
!       PSHS    A
        LDA     #17
        LDX     #DiskBuffer
        JSR     ReadSectorDtoX
        PULS    B
        LSLB
        LSLB
        LSLB
        LSLB
        LSLB
        LDX     #DiskBuffer
        ABX
        RTS

; Delete DNAMBF. Return SDC-like status B=0 success or B=5 not found.
DiskDeleteFile:
        LBSR    DiskEnsureStreamInit
        TST     DiskReadOpen
        LBNE    DiskStreamBusyError
        TST     DiskWriteOpen
        LBNE    DiskStreamBusyError
        LDU     #DNAMBF
        JSR     OpenFileU
        LBCS    DiskDeleteNotFound
        LDA     DIRGRN,X
        STA     DiskFirstGran
; Validate the complete FAT chain before changing the directory.
        LDD     #17*$100+2
        LDX     #DiskBuffer
        JSR     ReadSectorDtoX
        LDA     DiskFirstGran
        LDB     #GRANMX
        PSHS    B
DiskDeleteValidate:
        CMPA    #GRANMX
        LBHS    DiskDeleteBadChain
        LDB     A,X
        CMPB    #$C0
        BLO     >
        ANDB    #$3F
        BEQ     DiskDeleteBadChain
        CMPB    #9
        BHI     DiskDeleteBadChain
        BRA     DiskDeleteValidated
!       CMPB    #GRANMX
        BHS     DiskDeleteBadChain
        TFR     B,A
        DEC     ,S
        BNE     DiskDeleteValidate
DiskDeleteBadChain:
        LEAS    1,S
        LBRA    DiskBadMLFile
DiskDeleteValidated:
        LEAS    1,S
; Publish deletion first, so no directory entry can reference freed granules.
        LDU     #DNAMBF
        JSR     OpenFileU
        LBCS    DiskDeleteNotFound
        LDA     #$FF
        STA     ,X
        LDA     #17
        LDB     DiskDirSector
        LDX     #DiskBuffer
        JSR     WriteSectorDFromX
; Free every granule in the FAT.
        LDD     #17*$100+2
        LDX     #DiskBuffer
        JSR     ReadSectorDtoX
        LDB     DiskFirstGran
DiskDeleteFreeLoop:
        LDA     B,X                     ; next link
        PSHS    A
        LDA     #$FF
        STA     B,X
        PULS    A
        CMPA    #$C0
        BHS     DiskDeleteWriteFAT
        TFR     A,B
        BRA     DiskDeleteFreeLoop
DiskDeleteWriteFAT:
        LDD     #17*$100+2
        LDX     #DiskBuffer
        JSR     WriteSectorDFromX
        JSR     SetCPUSpeed
        CLRB
        RTS
DiskDeleteNotFound:
        JSR     SetCPUSpeed
        LDB     #5
        RTS

; SAVEM "NAME.BIN[:drive]",start,end,exec
; Existing files are not overwritten, matching Disk BASIC's FE error.
DiskSAVEM:
        LBSR    DiskRequireNoStreams
        LDD     DiskSaveEnd
        CMPD    DiskSaveStart
        LBLO    DiskSaveRangeError
        CMPD    #DiskWorkspaceStart
        BLO     DiskSaveRangeIsSafe
        LDD     DiskSaveStart
        CMPD    #DiskWorkspaceEnd
        LBLO    DiskSaveWorkspaceError
DiskSaveRangeIsSafe:
        LDA     #2
        STA     DiskOutputFileType
        CLR     DiskOutputASCII
        CLR     DiskOverwriteAllowed    ; SAVEM retains FE-on-existing behavior
        JSR     DiskWriterBegin

; Preamble: 00, length, load address.
        CLRB
        JSR     DiskWriteByteB
        LDD     DiskSaveEnd
        SUBD    DiskSaveStart
        ADDD    #1
        JSR     DiskWriteWordD
        LDD     DiskSaveStart
        JSR     DiskWriteWordD

; Save inclusive range. Compare before increment so end=$FFFF works.
        LDU     DiskSaveStart
DiskSaveDataLoop:
        LDB     ,U
        JSR     DiskWriteByteB
        CMPU    DiskSaveEnd
        BEQ     DiskSaveDataDone
        LEAU    1,U
        BRA     DiskSaveDataLoop
DiskSaveDataDone:
        LDB     #$FF
        JSR     DiskWriteByteB
        CLRB
        JSR     DiskWriteByteB
        JSR     DiskWriteByteB
        LDD     DiskSaveExec
        JSR     DiskWriteWordD
        JSR     DiskFinishWriteBuffer
        JSR     DiskWriterCommit
        RTS

DiskWriterBegin:
        CLR     DiskReplaceExisting
        LDU     #DNAMBF
        JSR     OpenFileWriteU
        BCS     DiskWriterUseFreeSlot
        TST     DiskOverwriteAllowed
        LBEQ    DiskSaveFileExists
; Keep the existing entry and FAT chain intact until its replacement has been
; written and published successfully.
        STA     DiskWriteDirOff
        LDA     DiskDirSector
        STA     DiskWriteDirSec
        LDA     DIRGRN,X
        STA     DiskReplaceFirstGran
        COM     DiskReplaceExisting
        BRA     DiskWriterGatherFree
DiskWriterUseFreeSlot:
        LDA     DiskFreeDirSec
        CMPA    #$FF
        LBEQ    DiskSaveDirectoryFull
        STA     DiskWriteDirSec
        LDA     DiskFreeDirOff
        STA     DiskWriteDirOff

; Gather free granules without modifying the disk FAT.
DiskWriterGatherFree:
        LDD     #17*$100+2
        LDX     #DiskOutputBuffer
        JSR     ReadSectorDtoX
        LDX     #DiskOutputBuffer
        LDU     #DiskGranuleList
        CLR     DiskSaveListCnt
        CLRA
DiskSaveFindFree:
        LDB     ,X+
        CMPB    #$FF
        BNE     DiskSaveNotFree
        LDB     DiskSaveListCnt
        CMPB    #MAXSAVEGRAN
        BHS     DiskSaveFreeListDone
        STA     ,U+
        INC     DiskSaveListCnt
DiskSaveNotFree:
        INCA
        CMPA    #GRANMX
        BLO     DiskSaveFindFree
DiskSaveFreeListDone:
        TST     DiskSaveListCnt
        LBEQ    DiskSaveDiskFull
        CLR     DiskSaveListPos
        CLR     DiskSaveSectors
        LDD     #DiskOutputBuffer
        STD     DiskWriteBufferPtr
        LDA     DiskGranuleList
        STA     DiskWriteCurrentGran
        JSR     DiskMapGranuleA
        CLR     DiskWriteAny
        RTS

; Commit FAT after every data sector has succeeded.
DiskWriterCommit:
        LDD     #17*$100+2
        LDX     #DiskOutputBuffer
        JSR     ReadSectorDtoX
        LDU     #DiskOutputBuffer
        LDX     #DiskGranuleList
        LDB     DiskSaveListPos
        BEQ     DiskSaveMarkLastGranule
DiskSaveLinkGranules:
        LDA     ,X+
        PSHS    B
        LDB     ,X
        STB     A,U
        PULS    B
        DECB
        BNE     DiskSaveLinkGranules
DiskSaveMarkLastGranule:
        LDA     ,X
        LDB     DiskSaveSectors
        ORB     #$C0
        STB     A,U
        LDD     #17*$100+2
        LDX     #DiskOutputBuffer
        JSR     WriteSectorDFromX

; Publish directory entry last.
        LDA     #17
        LDB     DiskWriteDirSec
        LDX     #DiskOutputBuffer
        JSR     ReadSectorDtoX
        LDX     #DiskOutputBuffer
        LDB     DiskWriteDirOff
        ABX
        PSHS    X
        LDB     #DIRLEN
        CLRA
!       STA     ,X+
        DECB
        BNE     <
        PULS    X
        LDU     #DNAMBF
        LDB     #11
!       LDA     ,U+
        STA     ,X+
        DECB
        BNE     <
        LDA     DiskOutputFileType
        STA     ,X+
        LDA     DiskOutputASCII
        STA     ,X+
        LDA     DiskGranuleList
        STA     ,X+
        LDD     DiskSaveLastLen
        STD     ,X
        LDA     #17
        LDB     DiskWriteDirSec
        LDX     #DiskOutputBuffer
        JSR     WriteSectorDFromX
; The directory now points at the new chain. Release the old chain afterward;
; an error before this point leaves the old file usable, while an error during
; cleanup can only leak old granules.
        TST     DiskReplaceExisting
        BEQ     DiskWriterCommitDone
        LDD     #17*$100+2
        LDX     #DiskOutputBuffer
        JSR     ReadSectorDtoX
        LDB     DiskReplaceFirstGran
        LDA     #GRANMX
        PSHS    A
DiskWriterFreeOldChain:
        CMPB    #GRANMX
        BHS     DiskWriterOldChainDone
        LDA     B,X
        PSHS    A
        LDA     #$FF
        STA     B,X
        PULS    A
        CMPA    #$C0
        BHS     DiskWriterOldChainDone
        CMPA    #GRANMX
        BHS     DiskWriterOldChainDone
        TFR     A,B
        DEC     ,S
        BNE     DiskWriterFreeOldChain
DiskWriterOldChainDone:
        LEAS    1,S
        LDD     #17*$100+2
        LDX     #DiskOutputBuffer
        JSR     WriteSectorDFromX
DiskWriterCommitDone:
        JSR     SetCPUSpeed
        RTS

DiskWriteWordD:
        STD     DiskSaveWord
        LDB     DiskSaveWord
        BSR     DiskWriteByteB
        LDB     DiskSaveWord+1
        BRA     DiskWriteByteB

; Append B. Select another granule only when another byte is actually needed.
DiskWriteByteB:
        PSHS    A,X
        LDX     DiskWriteBufferPtr
        CMPX    #DiskOutputBuffer
        BNE     DiskWriteStoreByte
        LDA     DiskSaveSectors
        CMPA    #9
        BNE     DiskWriteStoreByte
        PSHS    B                       ; preserve pending data byte
        INC     DiskSaveListPos
        LDA     DiskSaveListPos
        CMPA    DiskSaveListCnt
        BHS     DiskWriteOutOfSpaceSavedB
        LDX     #DiskGranuleList
        LDA     A,X
        STA     DiskWriteCurrentGran
        CLR     DiskSaveSectors
        JSR     DiskMapGranuleA
        LDX     #DiskOutputBuffer
        PULS    B                       ; restore pending data byte
DiskWriteStoreByte:
        LDA     #$FF
        STA     DiskWriteAny
        STB     ,X+
        STX     DiskWriteBufferPtr
        CMPX    #DiskOutputBuffer+SECLEN
        BNE     DiskWriteByteDone
        BSR     DiskFlushWriteSector
DiskWriteByteDone:
        PULS    A,X,PC
DiskWriteOutOfSpace:
        PULS    A,X
        LBRA    DiskSaveDiskFull
DiskWriteOutOfSpaceSavedB:
        LEAS    1,S                     ; discard saved pending data byte
        BRA     DiskWriteOutOfSpace

DiskFlushWriteSector:
        PSHS    D,X
        LDD     DCTRK
        LDX     #DiskOutputBuffer
        JSR     WriteSectorDFromX
        INC     DSEC
        INC     DiskSaveSectors
        LDD     #DiskOutputBuffer
        STD     DiskWriteBufferPtr
        PULS    D,X,PC

DiskFinishWriteBuffer:
        LDX     DiskWriteBufferPtr
        CMPX    #DiskOutputBuffer
        BEQ     DiskLastSectorWasFull
        TFR     X,D
        SUBD    #DiskOutputBuffer
        STD     DiskSaveLastLen
        CLRA
!       STA     ,X+
        CMPX    #DiskOutputBuffer+SECLEN
        BNE     <
        BSR     DiskFlushWriteSector
        RTS
DiskLastSectorWasFull:
        LDD     #SECLEN
        STD     DiskSaveLastLen
        RTS

DiskSaveFileExists:
        LDB     #DiskErrorFileExists
        LBRA    DiskError
DiskSaveDiskFull:
        LDB     #DiskErrorDiskFull
        LBRA    DiskError
DiskSaveDirectoryFull:
        LDB     #DiskErrorDirectoryFull
        LBRA    DiskError
DiskSaveRangeError:
        LDB     #DiskErrorBadRange
        LBRA    DiskError
DiskSaveWorkspaceError:
        LDB     #DiskErrorWorkspaceOverlap
        LBRA    DiskError
DiskOpenNotFound:
        LDB     #DiskErrorFileNotFound
        LBRA    DiskError
DiskStreamClosedError:
        LDB     #DiskErrorStreamClosed
        LBRA    DiskError
DiskStreamBusyError:
        LDB     #DiskErrorStreamBusy
        LBRA    DiskError
DiskBackwardWriteSeekError:
        LDB     #DiskErrorBackwardSeek
        LBRA    DiskError
DiskEmptyStreamError:
        LDB     #DiskErrorEmptyFile
        LBRA    DiskError

; Sector I/O wrappers.
WriteSectorDFromX:
        PSHS    A
        LDA     #3
        STA     DCOPC
        PULS    A
        BRA     DiskUpdateLocation
ReadSectorDtoX:
        PSHS    A
        LDA     #2
        STA     DCOPC
        PULS    A
DiskUpdateLocation:
        STD     DCTRK
        STX     DCBPT
        BSR     DSKCON
        TST     DCSTA
        BEQ     >
        LDA     DCSTA
        LDB     #DiskErrorWriteProtected
        BITA    #$40
        LBNE    DiskError
DiskIOError:
        LDB     #DiskErrorIOError
        LBRA    DiskError
!       RTS

; Standalone WD17xx restore/read/write driver.
DSKCON:
        PSHS    U,Y,X,B,A
        LDA     #5
        PSHS    A
DiskCommandRetry:
        CLR     RDYTMR
        LDB     DCDRV
        LDX     #DiskDriveMasks
        LDA     DRGRAM
        ANDA    #$A8
        ORA     B,X
        ORA     #$20                    ; double density
        LDB     DCTRK
        CMPB    #22
        BLO     >
        ORA     #$10                    ; write precompensation
!       TFR     A,B
        ORA     #$08
        STA     DRGRAM
        STA     DSKREG
        BITB    #$08
        BNE     DiskMotorReady
        LDX     #0
!       LEAX    -1,X
        BNE     <
        LDX     #0
!       LEAX    -1,X
        BNE     <
DiskMotorReady:
        BSR     DiskWaitNotBusy
        BNE     DiskCommandResult
        CLR     DCSTA
        LDX     #DiskCommandVectors
        LDB     DCOPC
        ASLB
        JSR     [B,X]
DiskCommandResult:
        PULS    A
        LDB     DCSTA
        BEQ     DiskCommandDone
        DECA
        BEQ     DiskCommandDone
        PSHS    A
        BSR     DiskRestore
        BNE     DiskCommandResult
        BRA     DiskCommandRetry
DiskCommandDone:
        LDA     #120
        STA     RDYTMR
        PULS    A,B,X,Y,U,PC

DiskRestore:
        LDB     DCDRV
        LDX     #DiskTrackImages
        CLR     B,X                     ; each physical drive has its own head
        LDA     #$03
        STA     FDCREG
        EXG     A,A
        EXG     A,A
        BSR     DiskWaitNotBusy
        BSR     DiskMediumDelay
        ANDA    #$10
        STA     DCSTA
DiskNoOperation:
        RTS
DiskWaitNotBusy:
        LDX     #0
!       LEAX    -1,X
        BEQ     DiskForceInterrupt
        LDA     FDCREG
        BITA    #1
        BNE     <
        RTS
DiskForceInterrupt:
        LDA     #$D0
        STA     FDCREG
        EXG     A,A
        EXG     A,A
        LDA     FDCREG
        LDA     #$80
        STA     DCSTA
        RTS
DiskMediumDelay:
        LDX     #8750
!       LEAX    -1,X
        BNE     <
        RTS

DiskReadSectorCommand:
        LDA     #$80
        BRA     DiskStartSectorCommand
DiskWriteSectorCommand:
        LDA     #$A0
DiskStartSectorCommand:
        PSHS    A
        LDB     DCDRV
        LDX     #DiskTrackImages
        LDB     B,X
        STB     FDCREG+1
        CMPB    DCTRK
        BEQ     DiskHeadPositioned
        LDA     DCTRK
        STA     FDCREG+3
        LDB     DCDRV
        LDX     #DiskTrackImages
        STA     B,X
        LDA     #$17
        STA     FDCREG
        EXG     A,A
        EXG     A,A
        BSR     DiskWaitNotBusy
        BNE     DiskSeekFailed
        BSR     DiskMediumDelay
        ANDA    #$18
        BEQ     DiskHeadPositioned
        STA     DCSTA
DiskSeekFailed:
        PULS    A,PC
DiskHeadPositioned:
        LDA     DSEC
        STA     FDCREG+2
        LDX     #DiskSectorComplete
        STX     DNMIVC
        LDX     DCBPT
        LDA     FDCREG
        LDA     DRGRAM
        ORA     #$80
        PULS    B
        LDY     #0
        LDU     #FDCREG
        COM     NMIFLG
        ORCC    #$50
        STB     FDCREG
        EXG     A,A
        EXG     A,A
        CMPB    #$80
        BEQ     DiskWaitReadDRQ
        LDB     #2
DiskWaitWriteDRQ:
        BITB    ,U
        BNE     DiskWriteDataByte
        LEAY    -1,Y
        BNE     DiskWaitWriteDRQ
        BRA     DiskTransferTimeout
DiskWriteDataByte:
        LDB     ,X+
        STB     FDCREG+3
        STA     DSKREG
        BRA     DiskWriteDataByte
DiskWaitReadDRQ:
        LDB     #2
!       BITB    ,U
        BNE     DiskReadDataByte
        LEAY    -1,Y
        BNE     <
DiskTransferTimeout:
        CLR     NMIFLG
        ANDCC   #$AF
        JMP     DiskForceInterrupt
DiskReadDataByte:
        LDB     FDCREG+3
        STB     ,X+
        STA     DSKREG
        BRA     DiskReadDataByte

; DNMISV replaces the stacked return PC with this completion routine.
DiskSectorComplete:
        ANDCC   #$AF
        LDA     FDCREG
        ANDA    #$7C
        STA     DCSTA
        RTS

DiskCommandVectors:
        FDB     DiskRestore
        FDB     DiskNoOperation
        FDB     DiskReadSectorCommand
        FDB     DiskWriteSectorCommand
DiskDriveMasks:
        FCB     1,2,4,$40

; Fatal disk errors retain the compiler's existing print-and-stop behavior.
DiskError:
        JSR     PrintDiskErrorOnScreen
        BRA     *
PrintDiskErrorOnScreen:
        PSHS    B
        LDX     #DNAMBF
        LDB     #8
!       LDA     ,X+
        CMPA    #' '
        BEQ     >
        JSR     PrintA_On_Screen
        DECB
        BNE     <
!       LDA     #'.'
        JSR     PrintA_On_Screen
        LDB     #3
!       LDA     ,X+
        JSR     PrintA_On_Screen
        DECB
        BNE     <
        LDA     #' '
        JSR     PrintA_On_Screen
        PULS    B
        LDX     #DiskErrorTable
!       LDA     ,X+
        BNE     <
        DECB
        BNE     <
!       LDA     ,X+
        BEQ     >
        JSR     PrintA_On_Screen
        BRA     <
!       RTS

DiskErrorTable:
        FCB     0
DiskErrorFileNotFound   EQU     1
        FCN     /FILE NOT FOUND/
DiskErrorWriteProtected EQU     2
        FCN     /DISK IS WRITE PROTECTED/
DiskErrorIOError        EQU     3
        FCN     'INPUT/OUTPUT ERROR'
DiskErrorNotMLFileType  EQU     4
        FCN     /NOT A MACHINE LANGUAGE FILE/
DiskErrorFileExists     EQU     5
        FCN     /FILE ALREADY EXISTS/
DiskErrorDiskFull       EQU     6
        FCN     /DISK FULL/
DiskErrorDirectoryFull  EQU     7
        FCN     /DIRECTORY FULL/
DiskErrorBadRange       EQU     8
        FCN     /BAD SAVEM ADDRESS RANGE/
DiskErrorWorkspaceOverlap EQU   9
        FCN     /DISK DATA OVERLAPS DISK WORKSPACE/
DiskErrorStreamClosed EQU       10
        FCN     /DISK FILE IS NOT OPEN/
DiskErrorStreamBusy EQU         11
        FCN     /ANOTHER DISK FILE IS OPEN/
DiskErrorBackwardSeek EQU       12
        FCN     /CANNOT SEEK BACKWARD WHILE WRITING/
DiskErrorEmptyFile EQU          13
        FCN     /CANNOT CLOSE AN EMPTY DISK FILE/

************************************************************************
* Resident disk workspace. These labels are private to Disk_Commands.asm;
* no controller state or file buffer is placed in fixed lower RAM.
************************************************************************
DiskWorkspaceStart:
DCOPC           RMB     1               ; 0=restore, 2=read, 3=write
DCDRV           RMB     1               ; active physical drive 0-3
DCTRK           RMB     1
DSEC            RMB     1
DCBPT           RMB     2
DCSTA           RMB     1
NMIFLG          RMB     1
DNMIVC          RMB     2
RDYTMR          RMB     1               ; compiler IRQ motor-off timer
DRGRAM          RMB     1               ; image of $FF40
DiskTrackImages RMB     4               ; one physical head position per drive
DNAMBF          RMB     11              ; active formatted 8.3 filename
DiskSearchName  RMB     2
DiskWorkBuffer  RMB     2
DiskFreeDirSec  RMB     1
DiskFreeDirOff  RMB     1
DiskDirSector   RMB     1

; Input stream and LOADM state.
DiskFileType        RMB 1
DiskCurrentGran     RMB 1
DiskNextGran        RMB 1
DiskLastGran        RMB 1
DiskGranuleEnd      RMB 1
DiskBufferPtr       RMB 2
DiskReadLastLen     RMB 2
DiskReadLimit       RMB 2
DiskFilePosition    RMB 4
DiskFirstGran       RMB 1
DiskReadOpen        RMB 1
DiskReadHandle      RMB 1
DiskReadDrive       RMB 1
DiskReadTrack       RMB 2
DiskReadName        RMB 11

; Output stream and SAVEM state.
DiskWriteOpen           RMB 1
DiskWriteHandle         RMB 1
DiskWriteDrive          RMB 1
DiskWriteTrack          RMB 2
DiskWriteName           RMB 11
DiskWriteDirSec         RMB 1
DiskWriteDirOff         RMB 1
DiskWriteCurrentGran    RMB 1
DiskWriteBufferPtr      RMB 2
DiskWriteFilePosition   RMB 4
DiskWriteAny            RMB 1
DiskOutputFileType      RMB 1
DiskOutputASCII         RMB 1
DiskOverwriteAllowed    RMB 1
DiskReplaceExisting     RMB 1
DiskReplaceFirstGran    RMB 1
DiskSaveStart           RMB 2
DiskSaveEnd             RMB 2
DiskSaveExec            RMB 2
DiskSaveWord            RMB 2
DiskSaveLastLen         RMB 2
DiskSaveSectors         RMB 1
DiskSaveListPos         RMB 1
DiskSaveListCnt         RMB 1
DiskGranuleList         RMB MAXSAVEGRAN

; Directory, seeking, and information scratch.
DiskDirPattern      RMB 11
DiskDirNextEntry    RMB 1
DiskDirPageCount    RMB 1
DiskDirInitialized RMB 1
DiskSeekTarget      RMB 4
DiskFileSize        RMB 4
DiskInfoSizePtr     RMB 2
DiskLoadStart       RMB 2
DiskLoadEnd         RMB 2
DiskStreamMagic     RMB 2

DiskInputBuffer     RMB SECLEN
DiskOutputBuffer    RMB SECLEN
DiskWorkspaceEnd:

; Compatibility name used by the original reader/directory implementation.
DiskBuffer      EQU DiskInputBuffer
