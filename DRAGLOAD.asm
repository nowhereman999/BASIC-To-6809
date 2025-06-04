; Loader program for Dragon computers
; This program loads a DECB program called COMPILED.BIN into the Dragon and auto executes it
; it can handle programs that require 64k
;
;******************************************************************************;
; Validate filename and copy to current drive block:
; [$c008]	Validates filename and copies to 'current drive block'
; [DragonDOSValidFilename]
;
;	On entry:
;	  X points to filename e.g. '3:FILENAME.EXT'
;	  B length of filename e.g. 0x0e
;	  Y points to default extension to use if none is given e.g. 'DAT'.
;           Use '   ' for no default extension
;	
;	If no drive given default drive (DosDriveNo) is used.			
;		
;	On Return:
;	  Filename appears at $0650-$065a (DosCurFilename)
;	  Current drive (DosCurDriveNo) is set
;	  CC.Z clear on error
;	  B contains error code
;	  U $065b always (SuperDosE6)
;
; Filenames can be of the following formats :
; 	"d:filename.ext"
;	"filename.ext:d"
;	"d:filename"
;	"filename:d"
;	"filename"
;	"filename.ext"
;
; ******************************************************************************
; DragonDOSOpenFile
;[$c00a]	Open a file - copies directory entry to a file control block
;	  On entry:
;	    Filename at $0650 ??
;	  Returns:
;	    CC.Z clear on error
;	    A FCB number (0-9)
;	    B contains error code
;
; Open a file and copy dir entry into FCB.
;
; The name in DosCurFilename is searched for in the FIBs, if found then
; the FIB number is returned in A. If not found a FIB is created and the
; disk is searched for the filaname. If not file is found ErrNE is returned
; in B.
;
;  On entry:
;	    Filename at DosCurFilename
;	    Drive no at DosCurDriveNo	
;	  Returns:
;	    CC.Z clear on error
;	    A FIB number (0-9)
;	    B contains error code
;
; ******************************************************************************
; DragonDOSCloseAll
;[$c010] %CLOSAL% Closes	all open files on drive specified in $00eb
;	  On entry:
;	  Returns:
;	    CC.Z clear on error
;	    B contains error code
;
;
; Close All open files and clean up buffers for one drive.
;
; This should be called four times when basic returns to the "OK" 
; prompt.
;
; Note: only closes files on the current disk (in DosDriveNo).
;
; Entry:
;
;	DosDriveNo	= drive no to close files on.
;
; Returns:
;	B		= Error code.
;
; ******************************************************************************
; DragonDOSFRead
; [$c014]	Read data from file to memory
;
; Entry :
;	A = FCB no
;	X = pointer to buffer to receive data
;	Y = no of bytes to read
;	U = MSW of file offset (FSN sector no).
;	B = LSB of file offset (byte within sector).
;		U:B is effectivly the filepointer.
; Exit:
;       CC.Z clear on error
;	B = Error code
;	X = no of bytes *NOT* read if error = EOF
;
; Secondary entry points :
;	RWrite	called by DOSFWrite
;	Verify	called by DOSFWrite
;
;******************************************************************************
; DragonDOSGetFLen
; [$c00e]	%LENFIL% Reports length of file
; Get a file length.
;
; Entry :
;	A 	= FCB no.
;
; Exit :
; 	U:A 	= length of file 
;	B	= Error code
;
;******************************************************************************
DragonDOSValidFilename  EQU     $C008   ; Validates filename and copies to 'current drive block'
DragonDOSOpenFile       EQU     $C00A   ; Open a file - copies directory entry to a file control block
DragonDOSGetFLen        EQU     $C00E   ; Reports length of file
DragonDOSCloseAll       EQU     $C010   ; Closes all open files on drive specified in $00eb
DragonDOSFRead          EQU     $C014   ; Read data from file to memory
;*************************************************************************
DragonDOSCurFilename	EQU	$0650		; Current filename
DragonDOSCurDriveNo	EQU	$065B		; Current drive number
;*************************************************************************
;
;     Offset:  Type:   Value:
;        0       byte    $55     Constant
;        1       byte    FILETYPE
;        2:3     word    LOAD
;        4:5     word    LENGTH
;        6:7     word    EXEC
;        8       byte    $AA     Constant
;        9-xxx   byte[]  DATA
;
DragonBinaryHeader:
                FCB     $55
                FCB     $02             ; 1 for BASIC, 2 for BINARY file
                FDB     LOADAddress
                FDB     LoaderEnd-LOADAddress
                FDB     LOADCBFile
                FCB     $AA

                        ORG     $C00
LOADAddress:             *

DragonFilenameStart     EQU     *
DragonFilename          FCC     "COMPILED.BIN:1"        ; Filename the loader will use
DragonFilenameEnd:      EQU     *
DragonBufferStart       EQU     LOADAddress-$100
DragonLOF               RMB     3                       ; Length of file MSB,MidSB,LSB

; Load and execute the Compiled Binary file
LOADCBFile:
        LDS     #$E00                   ; Move the stack pointer
        JSR     [DragonDOSCloseAll] ; Closes all open files on drive specified in $00eb
; 1 - Copy Filename and drive # to proper location to be used with actual file open command
;
;	On entry:
;	  X points to filename e.g. '3:FILENAME.EXT'
;	  B length of filename e.g. 0x0e
;	  Y points to default extension to use if none is given e.g. 'DAT'.
;           Use '   ' for no default extension
;       On return:
;	  Filename appears at $0650-$065a (DosCurFilename)
;	  Current drive (DosCurDriveNo) is set
;	  CC.Z clear on error
;	  B contains error code
;	  U $065b always (SuperDosE6)
        LDX     #DragonFilename                         ; X points to filename
        LDB     #DragonFilenameEnd-DragonFilenameStart  ; B length of filename
        JSR     [DragonDOSValidFilename]                ; Validate filename and copy to current drive block
        BEQ     >                                       ; Skip ahead if no error
        JSR     DragonDOSHandleError                    ; Print error and halt
        FCN     /FILENAME FORMAT IS WRONG/
;
; 2 - Open the file
;
;	  On entry:
;	    Filename at $0650 ??
;	  Returns:
;	    CC.Z clear on error
;	    A FCB number (0-9)
;	    B contains error code
!       JSR     [DragonDOSOpenFile]                     ; Open a file - copies directory entry to a file control block
        BEQ     >                                       ; Skip ahead if no error
        JSR     DragonDOSHandleError                    ; Print error and halt
        FCC     /CAN/
        FCB     $67     ; '
        FCC     /T FIND FILE COMPILED/
        FCB     $6E     ; .
        FCN     /BIN/      
!       STA     DragonFIB+1                             ; Self mod below
;
; 3 - Get a file length.
;
; Entry :
;	A 	= FCB no.
;
; Exit :
; 	U:A 	= length of file 
;	B	= Error code
        CLRA                                            ; File Control Block 0
        JSR     [DragonDOSGetFLen]                      ; Get length of file
        TSTB
        BEQ     >                                       ; Skip ahead if no error
        JSR     DragonDOSHandleError                    ; Print error and halt
        FCN     'ERROR GETTING FILE LENGTH'  
!       STU     DragonLOF                               ; Save LOF
        STA     DragonLOF+2                             ; ""
;
; 4 - Read bytes from file
;
        BSR     DragonReadBlock         ; Read the first 256 bytes from the file

; File is setup to start reading from the disk using the following for an ML file
; BYTE        PREAMBLE                POSTAMBLE
; 0           ØØ Preamble flag        $FF Post-amble flag
; 1, 2        Length of data block    Two zero bytes
; 3, 4        Load address            EXEC address
GetMLBlock:
        BSR     DiskReadByteA   ; Get flag in A
        TSTA
        BEQ     DoPREAMBLE      ; Skip ahead if it's a PREAMBLE
; If we get here then we have reached the end of the file
; Postamble
        CMPA    #$FF            ; Make sure it's the post-amble flag
        BNE     DiskErrorBadMLFile     ; Bad file format if not
        BSR     DiskReadWordD   ; Read next two bytes into D
        CMPD    #$0000          ; Make sure it's two zero bytes
        BNE     DiskErrorBadMLFile     ; Bad file format if not
        BSR     DiskReadWordD   ; Read next two bytes into D - EXEC address in D
        PSHS    D               ; Save the Execute address on the stack
        STB     $FFDE           ; Got into ROM mode
        JSR     [DragonDOSCloseAll]     ; Closes all open files on drive specified in $00eb
        STB     $FFDF           ; Got into 64k RAM mode
        CLR     $FF40           ; Turn off the drive motor
        PULS    X               ; Copy EXEC address into X
        JMP     ,X              ; Jump to X = EXECute address

DoPREAMBLE:
        BSR     DiskReadWordD   ; Read next two bytes into D    
        TFR     D,Y             ; Y = Length of data block
        BSR     DiskReadWordD   ; Read next two bytes into D
        TFR     D,U             ; U = Load address
!       BSR     DiskReadByteA   ; Get a byte from the file in A
        STA     ,U+             ; Save the byte to memory
        LEAY    -1,Y            ; Decrement the counter
        BNE     <               ; Keep looping until we've copied all the bytes
        BRA     GetMLBlock      ; Go read the next block

; Read next two bytes from the open file into D
DiskReadWordD:
        BSR     DiskReadByteA   ; Get a byte from the file in A
        TFR     A,B             ; Save MSB in B
        BSR     DiskReadByteA   ; Get a byte from the file in A
        EXG     A,B             ; Swap LSB & MSB, D is now correct
        RTS

; Read a byte from the open file into A
DiskReadByteA:
        CMPX    #DragonBufferStart+$100 ; Have we reached the end of the buffer?
        BNE     >                       ; If not skip ahead
        BSR     DragonReadBlock         ; Read 256 bytes into buffer at $900
!       LDA     ,X+
        RTS


DragonReadBlock:
        LDX     #DragonBufferStart      ; Set the buffer start location
        PSHS    B,X,Y,U                 ; Save the registers
        LDY     #$0100                  ; Get 256 bytes at a time
DragonFilePos:
        LDU     #$0000                  ; Get file location (Self mod)
        CLRB                            ; byte zero of the file
DragonFIB:
        LDA     #$FF                    ; Self modded above
        STB     $FFDE                   ; Got into ROM mode
        JSR     [DragonDOSFRead]        ; Read data from file to memory
        STB     $FFDF                   ; Got into 64k RAM mode
        BEQ     >                       ; Skip ahead if B = 0 otherwise we have a read error
        BSR     DragonDOSHandleError    ; Print error and halt
        FCN     'ERROR READING FILE'  
!       INC     DragonFilePos+2         ; Save the next 256 byte location in the file (Self mod above)
        BNE     >                       ; skip ahead if we didn't reach 256 blocks
        INC     DragonFilePos+1         ; Incrment the MSB location in the file (Self mod above)
!       PULS    B,X,Y,U,PC              ; Restore and return

DiskErrorBadMLFile:
        BSR     DragonDOSHandleError    ; Print error and halt
        FCN     'BAD ML FILE STRUCTURE'  

; Handle DOS error
DragonDOSHandleError:
        LDX     #$602   ; point at the end of screen +2
        LDD     #$6060
!       STD     ,--X    ; Clear the screen loop
        CMPX    #$400   ; Are we at the top?
        BNE     <       ; Keep looping if not
        LDU     ,S++    ; Point at message text, fix the stack
!       LDA     ,U+     ; Get byte of error message
        BEQ     >       ; if it's zero then done
        CMPA    #$20
        BNE     @NotSpace
        LDA     #$60    ; Make it a space
@NotSpace:
        STA     ,X+     ; Show message byte on screen
        BRA     <       ; get next byte
!       BRA     *       ; Loop forever

LoaderEnd:      *