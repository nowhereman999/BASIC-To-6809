************************************************************************
* SDC_CHAIN low-memory loader
*
* Permanent, stand-alone loader assembled at the compiler-selected layout
* base ($0400 with -notext, otherwise $0600). It replaces the current
* program with the requested binary and jumps to its postamble EXEC address.
* $0179-$0378 is a private 512-byte workspace; S is initialized to $0400.
************************************************************************

        IFNDEF  SDC_CHAIN_BASE
SDC_CHAIN_BASE          EQU     $0600
        ENDC
SDC_CHAIN_STACK         EQU     $0400
SDC_CHAIN_TEMP_BASE     EQU     $0179
SDC_CHAIN_TEMP_LIMIT    EQU     SDC_CHAIN_TEMP_BASE+$200
SDC_CHAIN_SLOT          EQU     SDC_CHAIN_TEMP_BASE
SDC_CHAIN_REMAINING     EQU     SDC_CHAIN_SLOT+1
SDC_CHAIN_HAVE_LOW      EQU     SDC_CHAIN_REMAINING+2
SDC_CHAIN_LOW_BYTE      EQU     SDC_CHAIN_HAVE_LOW+1
SDC_CHAIN_EXEC          EQU     SDC_CHAIN_LOW_BYTE+1
SDC_CHAIN_FILENAME      EQU     SDC_CHAIN_EXEC+2

        ORG     SDC_CHAIN_BASE

* Enter with B = CoCoSDC slot (0 or 1), and a counted filename in PF00.
SDCChainStart:
        ORCC    #$50                 * No IRQ/FIRQ while replacing program
        STB     SDC_CHAIN_SLOT
        LDS     #SDC_CHAIN_STACK

* Make the streaming filename "m:<name>", zero terminated.
        LDX     #_StrVar_PF00
        LDU     #SDC_CHAIN_FILENAME
        LDD     #'m'*256+':
        STD     ,U++
        LDB     ,X+
        LBEQ    SDCChainError         * An empty filename cannot be chained
        CMPB    #250                 * Leave room for m: and terminator
        BLS     >
        LDB     #250
!       LDA     ,X+
        STA     ,U+
        DECB
        BNE     <
        STB     ,U
        STB     $FFD8                * Normal CPU speed for SDC timing
        STB     $FFDF                * Force all-RAM mode before loading
************************************************************************
        LDA     SDC_CHAIN_SLOT
        CMPA    #1
        LBHI    SDCChainError         * Only CoCoSDC slots 0 and 1 are valid

* Enter CoCoSDC command mode and mount the file in the selected slot.
        LDA     #$43
        STA     $FF40
        LBSR    SDCChainPollBusy
        LDA     SDC_CHAIN_SLOT
        ADDA    #$E0
        STA     $FF48
        LBSR    SDCChainPollReady
        LDX     #SDC_CHAIN_FILENAME
        LBSR    SDCChainSendFilename
        LBSR    SDCChainPollBusy

* Start a 6809-style stream at logical sector zero.
        CLR     $FF49
        CLR     $FF4A
        CLR     $FF4B
        LDA     #$43
        STA     $FF40
        LBSR    SDCChainPollBusy
        LDA     SDC_CHAIN_SLOT
        ADDA    #$90
        STA     $FF48
        LBSR    SDCChainPollReady
        LDD     #512
        STD     SDC_CHAIN_REMAINING
        CLR     SDC_CHAIN_HAVE_LOW

* Parse DECB machine-language preambles and postamble.
SDCChainNextRecord:
        LBSR    SDCChainGetByte
        TSTB
        BEQ     SDCChainPreamble
        CMPB    #$FF
        LBNE    SDCChainError
        LBSR    SDCChainGetWord
        CMPD    #0
        LBNE    SDCChainError
        LBSR    SDCChainGetWord
        STD     SDC_CHAIN_EXEC
        LDA     #$D0                 * Abort/close the streaming command
        STA     $FF48
        LBSR    SDCChainPollBusy
        CLR     $FF40                * Restore SDC emulation mode
        LDX     SDC_CHAIN_EXEC
        JMP     ,X

SDCChainPreamble:
        LBSR    SDCChainGetWord
        TFR     D,X                  * X = block length
        LBEQ    SDCChainError
        LBSR    SDCChainGetWord
        TFR     D,U                  * U = destination

* A chained program may also use SDC_CHAIN and therefore contain the same
* loader block at SDC_CHAIN_BASE. Keep the resident copy instead of
* self-overwriting.
        CMPU    #SDC_CHAIN_BASE
        BNE     SDCChainCheckWorkspace
        CMPX    #SDCChainLoaderLength
        LBNE    SDCChainError
SDCChainDiscardResidentLoader:
        LBSR    SDCChainGetByte
        LEAX    -1,X
        BNE     SDCChainDiscardResidentLoader
        LBRA    SDCChainNextRecord

* Protect the $0179 workspace and the downward-growing stack below $0400.
SDCChainCheckWorkspace:
        CMPU    #SDC_CHAIN_STACK
        BHS     SDCChainCheckCode
        CMPU    #SDC_CHAIN_TEMP_BASE
        LBHS    SDCChainError
        PSHS    X
        TFR     U,D
        ADDD    ,S++                 * D = exclusive end address
        LBCS    SDCChainError         * Reject 16-bit address wraparound
        CMPD    #SDC_CHAIN_TEMP_BASE
        LBHI    SDCChainError

* Protect only the actual loader code. Memory immediately after it is free
* for persistent variables/data shared by chained programs.
SDCChainCheckCode:
        CMPU    #SDCChainLoaderEnd
        BHS     SDCChainCopyBlock
        CMPU    #SDC_CHAIN_BASE
        LBHS    SDCChainError
        PSHS    X
        TFR     U,D
        ADDD    ,S++
        LBCS    SDCChainError
        CMPD    #SDC_CHAIN_BASE
        LBHI    SDCChainError

SDCChainCopyBlock:
        LBSR    SDCChainGetByte
        STB     ,U+
        LEAX    -1,X
        BNE     SDCChainCopyBlock
        LBRA    SDCChainNextRecord

* Return the next big-endian word in D.
SDCChainGetWord:
        LBSR    SDCChainGetByte
        PSHS    B
        LBSR    SDCChainGetByte
        TFR     B,A
        PULS    B
        EXG     A,B
        RTS

* Return one byte in B. Hardware transfers are read as 16-bit pairs.
SDCChainGetByte:
        TST     SDC_CHAIN_HAVE_LOW
        BEQ     SDCChainReadPair
        CLR     SDC_CHAIN_HAVE_LOW
        LDB     SDC_CHAIN_LOW_BYTE
        BRA     SDCChainByteTaken
SDCChainReadPair:
        LDD     SDC_CHAIN_REMAINING
        BNE     >
        LBSR    SDCChainPollReady
        LDD     #512
        STD     SDC_CHAIN_REMAINING
!       LDD     $FF4A
        STB     SDC_CHAIN_LOW_BYTE
        LDB     #1
        STB     SDC_CHAIN_HAVE_LOW
        TFR     A,B
SDCChainByteTaken:
        PSHS    B                    * Preserve the byte being returned
        LDD     SDC_CHAIN_REMAINING
        SUBD    #1
        STD     SDC_CHAIN_REMAINING
        PULS    B,PC

SDCChainPollBusy:
        LDA     #1
!       BITA    $FF48
        BNE     <
        RTS

SDCChainPollReady:
        LBRN    $FFFF
        LBRN    $FFFF
        LBRN    $FFFF
        LBRN    $FFFF
        LDA     #2
!       BITA    $FF48
        BEQ     <
        RTS

* Send zero-terminated filename and pad the 256-byte command block.
SDCChainSendFilename:
        CLRA
!       DECA
        LDB     ,X+
        STB     $FF4A
        BEQ     SDCChainClearSecond
        DECA
        LDB     ,X+
        STB     $FF4B
        BNE     <
!       CLR     $FF4A
        DECA
SDCChainClearSecond:
        CLR     $FF4B
        DECA
        BNE     <
        RTS

* A visible, standalone failure state: red artifact/border and halt.
SDCChainError:
        LDA     #$D0
        STA     $FF48
        CLR     $FF40
        LDA     #$3F
        STA     $FF22
!       BRA     <

SDCChainLoaderEnd:

SDCChainLoaderLength    EQU     SDCChainLoaderEnd-SDCChainStart

        IFNE    SDCChainLoaderLength-$01A6
        FAIL    "SDC_CHAIN loader length changed; update the compiler memory-layout constant"
        ENDC

        IFDEF   PROGRAM_SAFE_START
        IFGT    SDCChainLoaderEnd-PROGRAM_SAFE_START
        FAIL    "SDC_CHAIN loader overlaps the calculated program area"
        ENDC
        ELSE
        IFGT    SDCChainLoaderEnd-$0E00
        FAIL    "SDC_CHAIN loader overlaps the default program area at $0E00"
        ENDC
        ENDC

* Resume the compiler's program segment after the isolated resident block.
        REORG
