; Disk Controller Reference
;
; $FF40 (65344) Disk Controller DSKREG
DSKREG      EQU $FF40   ; Disk Controller Command Register - DSKREG
; ---------------------------------------
; Bit 7: halt flag 0 = disabled 1 = enabled
; Bit 6: drive select 3
; Bit 5: density flag 0 = single 1 = double
; Bit 4: write precompensation 0 = no precomp 1 = precomp
; Bit 3: drive motor enable 0 = motors off 1 = motors on
; Bit 2: drive select 2
; Bit 1: drive select 1
; Bit 0: drive select 0
;
; 1. Write precomp should be on for tracks over 22
; 2. Disk communication is done through $FF48-$FF4B as follows:
;
;     Reg      | Read Operation | Write Operation
;     -----------------------------------------
;     $FF48    | Status          | Command
;     $FF49    | Track           | Track
;     $FF4A    | Sector          | Sector
;     $FF4B    | Data            | Data
; ---------------------------------------
; Status/Command ($FF48)
FDCREG      EQU $FF48  ; Floppy Disk Controller STATUS/COMMAND REGISTER FDCREG
; ---------------------------------------
; $FF48 (65352) Floppy Disk Controller
;
; (1) Write sends a command, then read to get status
;
;     Commands          Type    Code
;     - RESTORE          I      $03
;     - SEEK             I      $17
;     - STEP             I      $23
;     - STEP IN          I      $43
;     - STEP OUT         I      $53
;     - READ SECTOR      II     $80
;     - WRITE SECTOR     II     $A0
;     - READ ADDRESS     III    $C0
;     - READ TRACK       III    $E4
;     - WRITE TRACK      III    $F4
;     - FORCE INTERRUPT  IV     $D0
;
; (2) Read obtains status resulting from a command.
;
; (3) Commands:
;  Bit: 7 6 5 4 3 2 1 0  Command
;     - 0 0 0 x x x x x  Restore to track 0
;     - 0 0 0 1 x x x x  Seek
;     - 0 0 1 x x x x x  Step
;     - 0 1 0 x x x x x  Step in
;     - 0 1 1 x x x x x  Step out
;
;     Bits:
;     4: 0 = No update of track reg, 1 = Update track register
;     3: 0 = Unload head at start, 1 = Load head at start
;     2: 0 = No verify of track no, 1 = Verify track no. on disc
;
;     Read as 2-bit stepping rate:
;     - 00 = 6ms
;     - 01 = 12ms
;     - 10 = 20ms
;     - 11 = 30ms
;
;     - 1 0 0 x x x x 0  Read sector
;     - 1 0 1 x x x x x  Write sector
;     - 1 1 0 0 x x x 0  Read address
;     - 1 1 1 0 0 x x 0  Read track
;     - 1 1 1 1 0 x x x  Write track
;
;     Bits:
;     4: 0 = Read/write 1 sector, 1 = Read all sectors till end of a track
;     3: Interpretation of 2-bit sector length field in sector header:
;         00 = 256 bytes/sector
;         01 = 512 bytes/sector
;         10 = 1024 bytes/sector
;         11 = 128 bytes/sector
;     2: 0 = No head loading delay, 1 = Head loading delay of 30ms prior to read/writes.
;     1: 0 = Set side select o/p to 0, 1 = Set side select o/p to 1
;     0: 0 = Write Data Address Mark, 1 = Write Deleted Data
;
;     Address Mark:
;     - 1 1 0 1 x x x x  Force Interrupt
;     Generate an interrupt & terminate the current operation on:
;
;     Bits set:
;     0 - Drive status transition Not-Ready to Ready
;     1 - Drive status transition Ready to Not-Ready
;     2 - Index pulse
;     3 - Immediate interrupt
;     Bits clear: No interrupt occurs, all operations terminated ($D0)
;
; ---------------------------------------
; Status (read) when set:
;
;     Status bits may have different meanings depending on the command being performed.
;
;     0 - Drive busy
;     1 - Data Request (Data Read/Data Written) OR Index Pulse
;     2 - Lost Data/Track 00
;     3 - CRC error
;     4 - Record Not Found/Seek Err
;     5 - Data Address Mark:
;         0: Data Address Mark read
;         1: Deleted Data Address Mark read OR Head Loaded
;     6 - Write Protect
;     7 - Not Ready
;
; ---------------------------------------
; Track $FF49
FDC_TRACK    EQU $FF49  ; Track register
; ---------------------------------------
; $FF49 (65353) FDC Track Register
;
;     Bits 7 - 0  Disk Controller Track Register
;
;     (1) Track is 0-34 decimal
;     (2) Do not write directly, but use SEEK command
; ---------------------------------------
; Sector $FF4A
FDC_SECTOR   EQU $FF4A  ; Sector register
; ---------------------------------------
; $FF4A (65354) FDC Sector Register
;
;     Bits 7 - 0  Disk Controller Sector Register
;
;     (1) Sector is 1-18 decimal
;     (2) Can write directly
; ---------------------------------------
; Data $FF4B
FDC_DATA     EQU $FF4B  ; Data register
; ---------------------------------------
; $FF4B (65355) FDC Data Register
;
;     Bits 7 - 0  Disk Controller Data Register
;
;     (1) Read or write data bytes from/to the disk controller
;     (2) Must do so at the exact needed rate or there will be errors
; ---------------------------------------

DOSBUF  EQU $2600       ; RAM LOAD LOCATION FOR THE DOS COMMAND
FATCON  EQU 6           ; NUMBER OF CONTROL BYTES BEFORE FAT
FCBCON  EQU 25          ; NUMBER OF CONTROL BYTES BEFORE FCB
DIRLEN  EQU 32          ; NUMBER OF BYTES IN DIRECTORY ENTRY
SECLEN  EQU 256         ; LENGTH OF SECTOR IN BYTES
SECMAX  EQU 18          ; MAXIMUM NUMBER OF SECTORS PER TRACK
TRKLEN  EQU SECMAX*SECLEN   ; LENGTH OF TRACK IN BYTES
TRKMAX  EQU 35              ; MAX NUMBER OF TRACKS
FATLEN  EQU 6+(TRKMAX-1)*2  ; FILE ALLOCATION TABLE LENGTH
GRANMX  EQU (TRKMAX-1)*2    ; MAXIMUM NUMBER OF GRANULES
FCBLEN  EQU SECLEN+25       ; FILE CONTROL BLOCK LENGTH
INPFIL  EQU $10         ; INPUT FILE TYPE
OUTFIL  EQU $20         ; OUTPUT FILE TYPE
RANFIL  EQU $40         ; RANDOM/DIRECT FILE TYPE

* OFFSETS TO FAT CONTROL BYTES
FAT0    EQU 0           ; ACTIVE FILE COUNTER: DISK TO RAM FAT IMAGE DISABLE
FAT1    EQU 1           ; VALID DATA FLAG: 0=DISK DATA VALID, <> 0 = NEW FAT
*                       ; DATA - DISK DATA INVALID
*       2 TO 5          ; NOT USED
;FATCON  EQU 6           ; OFFSET TO START OF FAT DATA (68 BYTES)

*
**
**** DIRECTORY ENTRY FORMAT
**
*
* THE DIRECTORY IS USED TO KEEP TRACK OF HOW MANY FILES ARE STORED ON A DISKETTE
* AND WHERE THE FILE IS STORED ON THE DISK. THE FIRST GRANULE USED BY THE FILE WILL
* ALLOW THE FAT TO TRACK DOWN ALL OF THE GRANULES USED BY THE FILE. IF THE FIRST
* BYTE OF THE DIRECTORY ENTRY IS ZERO, THE FILE HAS BEEN KILLED;
* IF THE FIRST BYTE IS $FF THEN THE DIRECTORY ENTRY HAS NEVER BEEN USED.
*
*       BYTE            ; DESCRIPTION
DIRNAM  EQU 0           ; FILE NAME
DIREXT  EQU 8           ; FILE EXTENSION
DIRTYP  EQU 11          ; FILE TYPE
DIRASC  EQU 12          ; ASCII FLAG
DIRGRN  EQU 13          ; FIRST GRANULE IN FILE
DIRLST  EQU 14          ; NUMBER OF BYTES IN LAST SECTOR
*           16 TO 31    ; UNUSED

* DSKCON VARIABLES
DCOPC   EQU $00EA           ; PV DSKCON OPERATION CODE 0-3
DCDRV   EQU DCOPC+1         ; PV DSKCON DRIVE NUMBER 0 3
DCTRK   EQU DCDRV+1         ; PV DSKCON TRACK NUMBER 0 34
DSEC    EQU DCTRK+1         ; PV DSKCON SECTOR NUMBER 1-18
DCBPT   EQU DSEC+1          ; PV DSKCON DATA POINTER
DCSTA   EQU DCBPT+2         ; PV DSKCON STATUS BYTE

*START OF ADDITIONAL RAM VARIABLE STORAGE (DISK BASIC ONLY)
DBUF0   EQU $0600           ; I/O BUFFER #0
DBUF1   EQU DBUF0+SECLEN    ; I/O BUFFER #1
FATBL0  EQU DBUF1+SECLEN    ; FILE ALLOCATION TABLE - DRIVE 0
FATBL1  EQU FATBL0+FATLEN   ; FILE ALLOCATION TABLE - DRIVE 1
FATBL2  EQU FATBL1+FATLEN   ; FILE ALLOCATION TABLE - DRIVE 2
FATBL3  EQU FATBL2+FATLEN   ; FILE ALLOCATION TABLE - DRIVE 3
FBV1    EQU FATBL3+FATLEN   ; FILE BUFFER VECTORS (15 USER, 1 SYSTEM)
RNBFAD  EQU FBV1+16*2       ; START OF FREE RANDOM FILE BUFFER AREA
FCBAD   EQU RNBFAD+2        ; START OF FILE CONTROL BLOCKS

DNAMBF  EQU FCBAD+2         ; DISK FILE NAME BUFFER
DEXTBF  EQU DNAMBF+8        ; DISK FILE EXTENSION NAME BUFFER
DFLTFP  EQU DEXTBF+3        ; *+DV* DISK FILE TYPE: 0=BASIC, 1=DATA, 2=MACHINE
                            ; * LANGUAGE, 3=TEXT EDITOR SOURCE FILE
DASCFIL EQU DFLTFP+1        ; *+DV* ASCII FLAG: 0=CRUNCHED OR BINARY, $FF=ASCII
DRUNFL  EQU DASCFIL+1       ; RUN FLAG: (IF BIT 1=1 THEN RUN, IF BIT 0=1, THEN CLOSE
                            ; ALL FILES BEFORE RUNNING)
DEFDRV  EQU DRUNFL+1        ; DEFAULT DRIVE NUMBER
FCBACT  EQU DEFDRV+1        ; NUMBER OF FCBS ACTIVE
DRESFL  EQU FCBACT+1        ; RESET FLAG: <>0 WILL CAUSE A 'NEW' & SHUT DOWN ALL FCBS
DLADOLF EQU DRESFL+1        ; LOAD FLAG: CAUSE A 'NEW' FOLLOWING A LOAD ERROR
DMRGFL  EQU DLADOLF+1       ; MERGE FLAG: 0=N0 MERGE, $FF=MERGE
DUSRVC  EQU DMRGFL+1        ; DISK BASIC USR COMMAND VECTORS

*** DISK FILE WORK AREA FOR DIRECTORY SEARCH
* EXISTING FILE
V973    EQU DUSRVC+20       ; SECTOR NUMBER
V974    EQU V973+1          ; RAM DIRECTORY IMAGE ADDRESS
V976    EQU V974+2          ; FIRST GRANULE NUMBER

* UNUSED FILE
V977    EQU V976+1          ; SECTOR NUMBER
V978    EQU V977+1          ; RAM DIRECTORY IMAGE ADDRESS

WFATVL  EQU V978+2          ; WRITE FAT VALUE: NUMBER OF FREE GRANULES WHICH MUST BE TAKEN
                            ; FROM THE FAT TO TRIGGER A WRITE FAT TO DISK SEQUENCE
DFFLEN  EQU WFATVL+2        ; DIRECT ACCESS FILE RECORD LENGTH
DR0TRK  EQU DFFLEN+2        ; CURRENT TRACK NUMBER, DRIVES 0,1,2,3
NMIFLG  EQU DR0TRK+4        ; NMI FLAG: 0=DON'T VECTOR <>0=VECTOR OUT
DNMIVC  EQU NMIFLG+1        ; NMI VECTOR: WHERE TO JUMP FOLLOWING AN NMI
* INTERRUPT IF THE NMI FLAG IS SET
RDYTMR  EQU DNMIVC+2        ; MOTOR TURN OFF TIMER
DRGRAM  EQU RDYTMR+1        ; RAM IMAGE OF DISKREG ($FF40)
DVERFL  EQU DRGRAM+1        ; VERIFY FLAG: 0=OFF, $FF=ON
ATTCTR  EQU DVERFL+1        ; READ/WRITE ATTEMPT COUNTER: NUMBER OF TIMES THE DISK WILL ATTEMPT TO RETRIEVE OR WRITE DATA
                            ; BEFORE IT GIVES UP AND ISSUES AN ERROR.
DFLBUF  EQU ATTCTR+1        ; INITIALIZED TO SECLEN BY DISKBAS    
; Reserve SECLEN space here
;
; Disk commands and operations start here:
;
; Format _StrVar_PF00 to proper disk filename in DNAMBF (Disk name buffer)
FixFileName:
        LDX     #_StrVar_PF00+1
        LDU     #DNAMBF
        LDB     #8
!       LDA     ,X+
        CMPA    #'.'
        BEQ     PadFilename
        STA     ,U+
        DECB
        BNE     <
        LDA     ,X+     ; Skip the dot before the extension
CopyExtension:
        LDB     #3      ; Copy the extension
!       LDA     ,X+
        STA     ,U+
        DECB
        BNE     <
; Check For a Disk number
        LDA     ,X+
        CMPA    #':'    ; if we have a colon then the next value should be the drive number
        BNE     >       ; if not a colon then there is no drive number, just return
        LDA     ,X+     ; A = ascii drive number
        SUBA    #48     ; A = A - 48, turn it into a number from zero to 3
        STA     DCDRV   ; save as the current drive number
!       RTS
PadFilename:
        LDA     #' '
!       STA     ,U+
        DECB
        BNE     <
        BRA     CopyExtension

DiskError:
        JSR     PrintDiskErrorOnScreen
        BRA     *

; Open the the File pointed at by U
; Enter with U pointing at the properly formatted filename (8 character filename padded with spaces) and a 3 character extension
; Exits with X pointing at the filename entry in the disk directory
; Carry flag will be set if it couldn't find the filename, cleared otherwise
OpenFileU:
* Check and disable any high speed options
        LDA     CoCoHardware            ; Get the CoCo Hardware info byte
        BPL     >                       ; If bit 7 is clear then skip forward it's a 6809
        FCB     $11,$3D,%00000000       ; otherwise, put the 6309 in emulation mode.  This is LDMD  #%00000000
!       RORA                            ; Move bit 0 to the Carry bit
        BCC     >                       ; if the Carry bit is clear, then not a CoCo 3, skip ahead
        STA     $FFD8                   ; Put CoCo 3 in Regular speed mode
!

; Track 17, Sector 3 to 11 contain directory entries
        LDD     #17*$100+3              ; A=Track 17, B=Sector 3
        LDX     #DBUF0                   ; X points at the directory buffer
DiskCheckNextSector:
        JSR     ReadSectorDtoX          ; Go read the sector D to RAM at X
        PSHS    D,X             
DiskFindFilename:
        LDA     ,X
        BEQ     DiskCheckNextFilename   ; If first character of filename is $00 then this file was killed, check next
        CMPA    #$FF
        BEQ     DiskFileNotFound        ; Go error out with file not found
; Test if filename matches
        LDB     #10                     ; 11 characters to check for filename, 0 to 10
!       LDA     B,X                     ; Get filename in the buffer
        CMPA    B,U                     ; Compare it with the Filename user wants
        BNE     DiskCheckNextFilename   ; No match check next filename entry
        DECB
        BNE     <
; If we get here then we found the file to open
; X points at the filename to open
        CLRA                            ; Clear carry flag, signify no error
        PULS    D,U,PC                  ; Fix the stack and return with X pointing at the filename entry
DiskCheckNextFilename:
        LEAX    32,X
        CMPX    #DBUF0+$100
        BNE     DiskFindFilename
        PULS    D,X
        INCB
        CMPB    #12                     ; Have we reached sector 12 yet?
        BNE     DiskCheckNextSector     ; If not keep checking
; If we get here then the file wasn't found in the directory
DiskFileNotFound:
        COMB                            ; Set carry flag, signify an error
        LEAS    4,S                     ; Fix the stack
        LDB     #DiskErrorFileNotFound  ; B = Message DiskErrorFileNotFound
        RTS

; Initialize File for reading:
; *** Enter with: X points at the filename to open
; Copy the file info to the file control block
; Copy Granule table for the file on the correct drive
; setup the end sector to compare with for this granule
; setup the track to read from
; copy the first 256 bytes of the file into the file buffer
; set the buffer pointer to the beginning of the buffer
; Load the first sector of the file into the file buffer
; At this point the file is ready to be read from by calling either DiskReadByteA or DiskReadWordD
; *** Exit with: Y pointing at the FATBLx associated with the drive DCDRV (preserve Y until file has been closed)
InitFile:
; FATBL0 format
; 0     - Current granule #
; 1 & 2 - Number of bytes in the last sector
; 3 & 4 - Current buffer pointer
; 5     - ASCII Code (MS nibble) & File type (LS nibble)
;         ASCII Code 0x=CRUNCHED $Fx=ASCII
;         File type x0=BASIC, x1=DATA, x2=MACHINE LANGUAGE, x3=TEXT EDITOR SOURCE FILE
; 6     - Granule table for the disk in this drive
        LDA     DCDRV           ; A = Drive number 0 to 3
        LDB     #FATLEN         ; FILE ALLOCATION TABLE LENGTH
        MUL                     ; D = A * B
        ADDD    #FATBL0         ; D = D + FATBL0
        TFR     D,Y             ; Y = D which points to the FATBlock for the disk in the current drive
!       LDA     DIRGRN,X        ; Get the First granule pointer of this file
        STA     ,Y              ; Save the first granule pointer
        LDD     DIRLST,X        ; Get the number of bytes in the last sector
        STD     1,Y             ; Save the number of bytes in the last sector
        LDD     #DBUF0          ; Set the input buffer pointer to the beginning
        STD     3,Y             ; Save buffer pointer
        LDA     DIRASC,X        ; A = the ASCII Flag (0=CRUNCHED OR BINARY, $FF=ASCII)
        LSLA
        LSLA
        LSLA
        LSLA                    ; Move value to the Most significant nibble)
        ADDA    DIRTYP,X        ; Make th Least significant nibble the File type (0=BASIC, 1=DATA, 2=MACHINE LANGUAGE, 3=TEXT EDITOR SOURCE FILE)
        STA     5,Y             ; Save ASCII Code and File Type
; Copy the granule table for this drive
; Track 17, Sector 2 is the Granule table
        LDD     #17*$100+2      ; A=Track 17, B=Sector 2
        LDX     #DBUF0          ; X points at the 1st directory buffer
        JSR     ReadSectorDtoX  ; Go read the Track/Sector D to RAM at X - DBUF0 now has a copy of the granule table
        LEAU    6,Y             ; U points at the granule table Image Start
        LDB     #GRANMX         ; # of granules in the granule table
!       LDA     ,X+             ; Get the granule number
        STA     ,U+             ; Save the granule number
        DECB                    ; Decrement the counter
        BNE     <               ; Keep looping until we've copied all the granules
; 0     - Current granule #
; 1 & 2 - Number of bytes in the last sector
; 3 & 4 - Current buffer pointer
; 5     - ASCII Code (MS nibble) & File type (LS nibble)
;         ASCII Code 0x=CRUNCHED $Fx=ASCII
;         File type x0=BASIC, x1=DATA, x2=MACHINE LANGUAGE, x3=TEXT EDITOR SOURCE FILE
; 6     - Granule table for the disk in this drive
GetNextGranule:
; Setup which sector to end reading until we reach the end of the granule
        LDA     ,Y              ; A = current granule # for the file
        LEAU    6,Y             ; U points at the granule table Image Start        
        LDB     A,U             ; B = granule table entry for the current granule
        BITB    #%11000000      ; Is this flagged as the last granule?
        BEQ     NotLastGranule  ; Skip ahead if the granule is not the last granule associated with the file
; If we get here then the granule is the last granule associated with the file
        ANDB    #%00111111      ; Clear the last granule flags, B now is the last sector number
        INCB                    ; Increment the last sector number
        PSHS    B               ; Save the last sector number
        CMPA    #34             ; See if track is the directory track or higher (17 * 2 = 34)
        BLO     >               ; if not leave value as it is
        ADDA    #2              ; otherwise skip over the directory track
!       LSRA                    ; Divide by 2 to get the track and sector starting location on disk
        STA     DCTRK           ; Save the starting track
        LDA     #10             ; Start Sector of the granule if Carry is set
        BCS     >               ; Skip ahead if carry flag is set
        LDA     #1              ; Starting Sector of the granule if Carry is clear
!       STA     DSEC            ; Save the starting sector
        ADDA    ,S+             ; A = A + last sector number, fix the stack
        STB     GranuleEnd+1    ; Save the compare value for the last sector of this granule (self mod)
        BRA     LoadFirstSector ; Go read the first sector of the granule
; Normal Granule (not the last granule)
NotLastGranule
        LDB     #10             ; Start Sector of the granule if Carry is set
        CMPA    #34             ; See if track is the directory track or higher (17 * 2 = 34)
        BLO     >               ; if not leave value as it is
        ADDA    #2              ; otherwise skip over the directory track
!       LSRA                    ; Divide by 2 to get the track and sector starting location on disk
        STA     DCTRK           ; Save the starting track
        LDA     #19             ; End sector + 1, if Carry is set
        BCS     >               ; Skip ahead if carry flag is set
        LDD     #10*$100+1      ; A = Sector compare value of 10 and Set the sector start number to 1, Carry is not set
!       STA     GranuleEnd+1    ; Save the compare value for the last sector of this granule (self mod)
        STB     DSEC            ; Save the start sector
; Read the first sector of the new granule
LoadFirstSector:
        LDD     DCTRK           ; Get the current track and sector
        LDX     #DBUF0          ; X points at the 1st directory buffer
        JSR     ReadSectorDtoX  ; Go read the Track/Sector D to RAM at X - DBUF0 now has a copy of the granule table
        LDA     ,Y              ; A = current granule # for the file
        LDA     A,U             ; A = granule table entry for the current granule
        STA     ,Y              ; Save the new granule number
        STX     3,Y             ; Save the buffer pointer
        RTS

; Do a LOADM command
; File must already be Initialized
; *** Enter with: Y pointing at the FATBLx associated with the drive DCDRV
; * Loads a Machine Language file from the disk
; Adds the 16 bit value stored in _Var_PF10 to the Load Address and the EXEC address
DiskLOADM:
        LDA     5,Y             ; Get the filetype and ASCII flag
        CMPA    #$02            ; ASCII flag must be 0 = BINARY & File type must be 2 = Machine Code program and 
        BNE     DiskErrorBadMLFile  ; Not an ML file
       
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
        BSR     DiskReadWordD   ; Read next two bytes into D
        ADDD    _Var_PF10       ; D = D + LOADM Offset amount    
        STD     EXECAddress     ; Save the EXEC address

* Check and re-enable any high speed options
        LDA     CoCoHardware            ; Get the CoCo Hardware info byte
        BPL     >                       ; If bit 7 is clear then skip forward it's a 6809
        FCB     $11,$3D,%00000001       ; otherwise, put the 6309 in native mode.  This is LDMD  #%00000001
!       RORA                            ; Move bit 0 to the Carry bit
        BCC     >                       ; if the Carry bit is clear, then not a CoCo 3, skip ahead
        STA     $FFD9                   ; Put CoCo 3 in High speed mode
!
        RTS                     ; File has been LOADMed into memory, Return

DoPREAMBLE:
        BSR     DiskReadWordD   ; Read next two bytes into D    
        TFR     D,X             ; X = Length of data block
        BSR     DiskReadWordD   ; Read next two bytes into D
        ADDD    _Var_PF10       ; D = D + LOADM Offset amount    
        TFR     D,U             ; U = Load address
!       BSR     DiskReadByteA   ; Get a byte from the file in A
        STA     ,U+             ; Save the byte to memory
        LEAX    -1,X            ; Decrement the counter
        BNE     <               ; Keep looping until we've copied all the bytes
        BRA     GetMLBlock      ; Go read the next block

; Read next two bytes from the open file into D
DiskReadWordD:
        BSR     DiskReadByteA   ; Get a byte from the file in A
        TFR     A,B             ; Save MSB of the EXEC address in B
        BSR     DiskReadByteA   ; Get a byte from the file in A
        EXG     A,B             ; MOVE LSB of the EXEC address To B and move the MSB to A
        RTS
DiskErrorBadMLFile:
        LDB     #DiskErrorNotMLFileType ; B = Message DiskErrorNotMLFileType
        JMP     DiskError       ; Go handle disk error

; Read a byte from the open file into A
DiskReadByteA:
        PSHS    B,X,U           ; Save B,X & U
        LDX     3,Y             ; Get the buffer pointer
        CMPX    #DBUF0+$0100    ; Have we reached the end of the buffer?
        BNE     >               ; Skip ahead if not
        LDD     DCTRK           ; Get the Current Tracke & sector
        INCB                    ; Increment the sector number
        STB     DSEC            ; Save the new sector number
GranuleEnd:
        CMPB    #$FF            ; Have we reached end of a granule? (Value will be self modded to value of last sector)
        BNE     GetSector       ; Skip ahead if not
        BSR     GetNextGranule  ; If so get the next granule and load the buffer
        LDD     DCTRK           ; Get the current track and sector
GetSector:
        LDX     #DBUF0          ; Point to the start of the buffer
        JSR     ReadSectorDtoX  ; Go read the sector D to RAM at X
!       LDA     ,X+             ; Get a byte from the buffer
        STX     3,Y             ; Save the new buffer pointer
        PULS    B,X,U,PC        ; Restore B,X & U and return

; Write 256 bytes from RAM pointed at from X to sector to disk
; Enter with:
; A = Track
; B = Sector
; X = Buffer start location in RAM to save to the disks sector
; No registers are changed on exit
WriteSectorDFromX:
        PSHS    A           ; Save A
        LDA     #$03        ; A equals the Disk Write opcode
        STA     DCOPC       ; Save the operation code
        PULS    A           ; Restore A
        BRA     UpdateDiskLocation  ; Go save Track, Sector and Buffer pointer and return

; Read 256 byte sector into X
; Enter with:
; A = Track
; B = Sector
; X = Buffer start location in RAM to save the disks sector data
; No registers are changed on exit
ReadSectorDtoX:
        PSHS    A           ; Save A
        LDA     #$02        ; A equals the Disk Read opcode
        STA     DCOPC       ; Save the operation code
        PULS    A           ; Restore A
UpdateDiskLocation:
        STD     DCTRK       ; Save Track pointer & DSEC = Save Sector pointer
        STX     DCBPT       ; Save the buffer pointer
; -----------------------------------------------------------------------------
; Read or write a sector based on the value of DCOPC
; If DCOPC = $02 then it will read a sector
; If DCOPC = $03 then it will write a sector
; DCTRK = Track #
; DSEC  = Sector #
; DCBPT = 256 byte buffer start pointer
ReadWriteSector:
LD6F2           PSHS        B               ; SAVE ACCB
                LDB         #$05            ; 5 RETRIES
                STB         ATTCTR          ; SAVE RETRY COUNT
                PULS        B               ; RESTORE ACCB
LD6FB           BSR         DSKCON          ; GO EXECUTE COMMAND
                TST         DCSTA           ; CHECK STATUS
                BEQ         LD70E           ; BRANCH IF NO ERRORS
LD701           LDA         DCSTA           ; GET DSKCON ERROR STATUS
                LDB         #DiskErrorWriteProtected     ;  LDB  #2*30 ; 'WRITE PROTECTED' ERROR
                BITA        #$40            ; CHECK BIT 6 OF STATUS
                BNE         LD70B           ; BRANCH IF WRITE PROTECT ERROR
LD709           LDB         #DiskErrorIOError     ;  LDB         #2*20           ; 'I/O ERROR'
LD70B           ; JMP         >LAC46          ; JUMP TO ERROR DRIVER
                JMP         DiskError       ; Go handle disk error

LD70E           PSHS        A               ; SAVE ACCA
                LDA         DCOPC           ; GET OPERATION CODE
                CMPA        #$03            ; CHECK FOR WRITE SECTOR COMMAND
                PULS        A               ; RESTORE ACCA
                BNE         LD742           ; RETURN IF NOT WRITE SECTOR
                TST         DVERFL          ; CHECK VERIFY FLAG
                BEQ         LD742           ; RETURN IF NO VERIFY
                PSHS        U,X,B,A         ; SAVE REGISTERS
                LDA         #$02            ; READ OPERATION CODE
                STA         DCOPC           ; STORE TO DSKCON PARAMETER
                LDU         DCBPT           ; POINT U TO WRITE BUFFER ADDRESS
                LDX         #DBUF1          ; ADDRESS OF VERIFY BUFFER
                STX         DCBPT           ; TO DSKCON VARIABLE
                BSR         DSKCON          ; GO READ SECTOR
                STU         DCBPT           ; RESTORE WRITE BUFFER
                LDA         #$03            ; WRITE OP CODE
                STA         DCOPC           ; SAVE IN DSKCON VARIABLE
                LDA         DCSTA           ; CHECK STATUS FOR THE READ OPERATION
                BNE         LD743           ; BRANCH IF ERROR
                CLRB                        ; CHECK 256 BYTES
LD737           LDA         ,X+             ; GET BYTE FROM WRITE BUFFER
                CMPA        ,U+             ; COMPARE TO READ BUFFER
                BNE         LD743           ; BRANCH IF NOT EQUAL
                DECB                        ; DECREMENT BYTE COUNTER AND
                BNE         LD737           ; BRANCH IF NOT DONE
                PULS        A,B,X,U         ; RESTORE REGISTERS
LD742           RTS
LD743           PULS        A,B,X,U         ; RESTORE REGISTERS
                DEC         ATTCTR          ; DECREMENT THE VERIFY COUNTER
                BNE         LD6FB           ; BRANCH IF MORE TRIES LEFT
                LDB         #DiskErrorVerifyError     ;LDB         #2*36           ; 'VERIFY ERROR'
                BRA         LD70B           ; JUMP TO ERROR HANDLER
; VERIFY COMMAND
;VERIFY          CLRB                        ;  OFF FLAG = 0
;                CMPA        #$AA            ; OFF TOKEN ?
;                BEQ         LD75A           ; YES
;                COMB                        ;  ON FLAG = $FF
;                CMPA        #$88            ; ON TOKEN
;                LBNE        LB277           ; BRANCH TO 'SYNTAX ERROR' IF NOT ON OR OFF
;LD75A           STB         DVERFL          ; SET VERIFY FLAG
;                JMP         GETNCH          ; GET NEXT CHARACTER FROM BASIC
; DSKCON ROUTINE
DSKCON          PSHS        U,Y,X,B,A       ; SAVE REGISTERS
                LDA         #$05            ; GET RETRY COUNT AND
                PSHS        A               ; SAVE IT ON THE STACK
LD765           CLR         RDYTMR          ; RESET DRIVE NOT READY TIMER
                LDB         DCDRV           ; GET DRIVE NUMBER
                LDX         #LD89D          ; POINT X TO DRIVE ENABLE MASKS
                LDA         DRGRAM          ; GET DSKREG IMAGE
                ANDA        #$A8            ; KEEP MOTOR STATUS, DOUBLE DENSITY. HALT ENABLE
                ORA         B,X             ; 'OR' IN DRIVE SELECT DATA
                ORA         #$20            ; 'OR' IN DOUBLE DENSITY
                LDB         DCTRK           ; GET TRACK NUMBER
                CMPB        #22             ; PRECOMPENSATION STARTS AT TRACK 22
                BLO         LD77E           ; BRANCH IF LESS THAN 22
                ORA         #$10            ; TURN ON WRITE PRECOMPENSATION IF >= 22
LD77E           TFR         A,B             ; SAVE PARTIAL IMAGE IN ACCB
                ORA         #$08            ; 'OR' IN MOTOR ON CONTROL BIT
                STA         DRGRAM          ; SAVE IMAGE IN RAM
                STA         DSKREG          ; PROGRAM THE 1793 CONTROL REGISTER
                BITB        #$08            ; WERE MOTORS ALREADY ON?
                BNE         LD792           ; DON'T WAIT FOR IT TO COME UP TO SPEED IF ALREADY ON
; WAIT A WHILE
                LDX    #$0000      GET READY TO WAIT A WHILE
!               LEAX   -1,X        DECREMENT X
                BNE    <           BRANCH IF NOT ZERO
; WAIT SOME MORE FOR MOTOR TO COME UP TO SPEED
                LDX    #$0000      GET READY TO WAIT A WHILE
!               LEAX   -1,X        DECREMENT X
                BNE    <           BRANCH IF NOT ZERO
LD792           BSR         LD7D1           ; WAIT UNTIL NOT BUSY OR TIME OUT
                BNE         LD7A0           ; BRANCH IF TIMED OUT (DOOR OPEN. NO DISK, NO POWER. ETC.)
                CLR         DCSTA           ; CLEAR STATUS REGISTER
                LDX         #LD895          ; POINT TO COMMAND JUMP VECTORS
                LDB         DCOPC           ; GET COMMAND
                ASLB                        ;  2 BYTES PER COMMAND JUMP ADDRESS
                JSR         [B,X]           ; GO DO IT
LD7A0           PULS        A               ; GET RETRY COUNT
                LDB         DCSTA           ; GET STATUS
                BEQ         LD7B1           ; BRANCH IF NO ERRORS
                DECA                        ; DECREMENT RETRIES COUNTER
                BEQ         LD7B1           ; BRANCH IF NO RETRIES LEFT
                PSHS        A               ; SAVE RETRY COUNT ON STACK
                BSR         LD7B8           ; RESTORE HEAD TO TRACK 0
                BNE         LD7A0           ; BRANCH IF SEEK ERROR
                BRA         LD765           ; GO TRY COMMAND AGAIN IF NO ERROR
LD7B1           LDA         #120            ; 120*1/60 = 2 SECONDS (1/60 SECOND FOR EACH IRQ INTERRUPT)
                STA         RDYTMR          ; WAIT 2 SECONDS BEFORE TURNING OFF MOTOR
                PULS        A,B,X,Y,U,PC    ; RESTORE REGISTERS - EXIT DSKCON
; RESTORE HEAD TO TRACK 0
LD7B8           LDX         #DR0TRK         ; POINT TO TRACK TABLE
                LDB         DCDRV           ; GET DRIVE NUMBER
                CLR         B,X             ; ZERO TRACK NUMBER
                LDA         #$03            ; RESTORE HEAD TO TRACK 0, UNLOAD THE HEAD
                STA         FDCREG          ; AT START, 30 MS STEPPING RATE
                EXG         A,A             ;
                EXG         A,A             ; WAIT FOR 1793 TO RESPOND TO COMMAND
                BSR         LD7D1           ; WAIT TILL DRIVE NOT BUSY
                BSR         LD7F0           ; WAIT SOME MORE
                ANDA        #$10            ; 1793 STATUS : KEEP ONLY SEEK ERROR
                STA         DCSTA           ; SAVE IN DSKCON STATUS
LD7D0           RTS
; WAIT FOR THE 1793 TO BECOME UNBUSY. IF IT DOES NOT BECOME UNBUSY,
; FORCE AN INTERRUPT AND ISSUE A DRIVE NOT READY 1793 ERROR.
LD7D1           LDX         #$0000          ; GET ZERO TO X REGISTER - LONG WAIT
LD7D3           LEAX        -1,X            ; DECREMENT LONG WAIT COUNTER
                BEQ         LD7DF           ; lF NOT READY BY NOW, FORCE INTERRUPT
                LDA         FDCREG          ; GET 1793 STATUS AND TEST
                BITA        #$01            ; BUSY STATUS BIT
                BNE         LD7D3           ; BRANCH IF BUSY
                RTS
LD7DF           LDA         #$D0            ; FORCE INTERRUPT COMMAND - TERMINATE ANY COMMAND
                STA         FDCREG          ; IN PROCESS. DO NOT GENERATE A 1793 INTERRUPT REQUEST
                EXG         A,A             ; WAIT BEFORE READING 1793
                EXG         A,A             ;
                LDA         FDCREG          ; RESET INTRQ (FDC INTERRUPT REQUEST)
                LDA         #$80            ; RETURN DRIVE NOT READY STATUS IF THE DRIVE DID NOT BECOME UNBUSY
                STA         DCSTA           ; SAVE DSKCON STATUS BYTE
                RTS
; MEDIUM DELAY
LD7F0           LDX         #8750           ; DELAY FOR A WHILE
LD7F3           LEAX        -1,X            ; DECREMENT DELAY COUNTER AND
                BNE         LD7F3           ; BRANCH IF NOT DONE
                RTS
; READ ONE SECTOR
LD7F8           LDA         #$80            ; $80 IS READ FLAG (1793 READ SECTOR)
LD7FA           FCB         $8C             ; SKIP TWO BYTES (THROWN AWAY CMPX INSTRUCTION)
; WRITE ONE SECTOR
LD7FB           LDA         #$A0            ; $A0 IS WRITE FLAG (1793 WRITE SECTOR)
                PSHS        A               ; SAVE READ/WRITE FLAG ON STACK
                LDX         #DR0TRK         ; POINT X TO TRACK NUMBER TABLE IN RAM
                LDB         DCDRV           ; GET DRIVE NUMBER
                ABX                         ; POINT X TO CORRECT DRIVE'S TRACK BYTE
                LDB         ,X              ; GET TRACK NUMBER OF CURRENT HEAD POSITION
                STB         FDCREG+1        ; SEND TO 1793 TRACK REGISTER
                CMPB        DCTRK           ; COMPARE TO DESIRED TRACK
                BEQ         LD82C           ; BRANCH IF ON CORRECT TRACK
                LDA         DCTRK           ; GET TRACK DESIRED
                STA         FDCREG+3        ; SEND TO 1793 DATA REGiSTER
                STA         ,X              ; SAVE IN RAM TRACK IMAGE
                LDA         #$17            ; SEEK COMMAND FOR 1793: DO NOT LOAD THE
                STA         FDCREG          ; HEAD AT START, VERIFY DESTINATION TRACK,
                EXG         A,A             ; 30 MS STEPPING RATE - WAIT FOR
                EXG         A,A             ; VALID STATUS FROM 1793
                BSR         LD7D1           ; WAIT TILL NOT BUSY
                BNE         LD82A           ; RETURN IF TIMED OUT
                BSR         LD7F0           ; WAIT SOME MORE
                ANDA        #$18            ; KEEP ONLY SEEK ERROR OR CRC ERROR IN ID FIELD
                BEQ         LD82C           ; BRANCH IF NO ERRORS - HEAD ON CORRECT TRACK
                STA         DCSTA           ; SAVE IN DSKCON STATUS
LD82A           PULS        A,PC
; HEAD POSITIONED ON CORRECT TRACK
LD82C           LDA         DSEC            ; GET SECTOR NUMBER DESIRED
                STA         FDCREG+2        ; SEND TO 1793 SECTOR REGISTER
                LDX         #LD88B          ; POINT X TO ROUTINE TO BE VECTORED
                STX         DNMIVC          ; TO BY NMI UPON COMPLETION OF DISK I/O AND SAVE VECTOR
                LDX         DCBPT           ; POINT X TO I/O BUFFER
                LDA         FDCREG          ; RESET INTRQ (FDC INTERRUPT REQUEST)
                LDA         DRGRAM          ; GET DSKREG IMAGE
                ORA         #$80            ; SET FLAG TO ENABLE 1793 TO HALT 6809
                PULS        B               ; GET READ/WRITE COMMAND FROM STACK
                LDY         #$0000          ; ZERO OUT Y - TIMEOUT INITIAL VALUE
                LDU         #FDCREG         ; U POINTS TO 1793 INTERFACE REGISTERS
                COM         NMIFLG          ; NMI FLAG = $FF: ENABLE NMI VECTOR
                ORCC        #$50            ; DISABLE FIRQ,IRQ
                STB         FDCREG          ; SEND READ/WRITE COMMAND TO 1793: SINGLE RECORD, COMPARE
                EXG         A,A             ; FOR SIDE 0, NO 15 MS DELAY, DISABLE SIDE SELECT
                EXG         A,A             ; COMPARE, WRITE DATA ADDRESS MARK (FB) - WAIT FOR STATUS
                CMPB        #$80            ; WAS THIS A READ?
                BEQ         LD875           ; IF SO, GO LOOK FOR DATA
; WAIT FOR THE 1793 TO ACKNOWLEDGE READY TO WRITE DATA
                LDB         #$02            ; DRQ MASK BIT
LD85B           BITB        ,U              ; IS 1793 READY FOR A BYTE? (DRQ SET IN STATUS BYTE)
                BNE         LD86B           ; BRANCH IF SO
                LEAY        -1,Y            ; DECREMENT WAIT TIMER
                BNE         LD85B           ; KEEP WAITING FOR THE 1793 DRQ
LD863           CLR         NMIFLG          ; RESET NMI FLAG
                ANDCC       #$AF            ; ENABLE FIRQ,IRQ
                JMP         >LD7DF          ; FORCE INTERRUPT, SET DRIVE NOT READY ERROR
; WRITE A SECTOR
LD86B           LDB         ,X+             ; GET A BYTE FROM RAM
                STB         FDCREG+3        ; SEND IT TO 1793 DATA REGISTER
                STA         DSKREG          ; REPROGRAM FDC CONTROL REGISTER
                BRA         LD86B           ; SEND MORE DATA
; WAIT FOR THE 17933 TO ACKNOWLEDGE READY TO READ DATA
LD875           LDB         #$02            ; DRQ MASK BIT
LD877           BITB        ,U              ; DOES THE 1793 HAVE A BYTE? (DRQ SET IN STATUS BYTE)
                BNE         LD881           ; YES, GO READ A SECTOR
                LEAY        -1,Y            ; DECREMENT WAIT TIMER
                BNE         LD877           ; KEEP WAITING FOR 1793 DRQ
                BRA         LD863           ; GENERATE DRIVE NOT READY ERROR
; READ A SECTOR
LD881           LDB         FDCREG+3        ; GET DATA BYTE FROM 1793 DATA REGISTER
                STB         ,X+             ; PUT IT IN RAM
                STA         DSKREG          ; REPROGRAM FDC CONTROL REGISTER
                BRA         LD881           ; KEEP GETTING DATA
; BRANCH HERE ON COMPLETION OF SECTOR READ/WRITE
LD88B           ANDCC       #$AF            ; ENABLE IRQ, FIRO
                LDA         FDCREG          ; GET STATUS & KEEP WRITE PROTECT, RECORD TYPE/WRITE
                ANDA        #$7C            ; FAULT, RECORD NOT FOUND, CRC ERROR OR LOST DATA
                STA         DCSTA           ; SAVE IN DSKCON STATUS
                RTS
; DSKCON OPERATION CODE JUMP VECTORS
LD895           FDB         LD7B8           ; RESTORE HEAD TO TRACK ZERO
                FDB         LD7D0           ; NO OP - RETURN
                FDB         LD7F8           ; READ SECTOR
                FDB         LD7FB           ; WRITE SECTOR
; DSKREG MASKS FOR DISK DRIVE SELECT
LD89D           FCB         1               ; DRIVE SEL 0
                FCB         2               ; DRIVE SEL 1
                FCB         4               ; DRIVE SEL 2
                FCB         $40             ; DRIVE SEL 3
; NMI SERVICE
;DNMISV          LDA         NMIFLG          ; GET NMI FLAG
;                BEQ         LD8AE           ; RETURN IF NOT ACTIVE
;                LDX         DNMIVC          ; GET NEW RETURN VECTOR
;                STX         10,S            ; STORE AT STACKED PC SLOT ON STACK
;                CLR         NMIFLG          ; RESET NMI FLAG
;LD8AE           RTI
; IRQ SERVICE
;DIRQSV          LDA         $FF03           ; 63.5 MICRO SECOND OR 60 HZ INTERRUPT?
;                BPL         LD8AE           ; RETURN IF 63.5 MICROSECOND
;                LDA         $FF02           ; RESET 60 HZ PIA INTERRUPT FLAG
;                LDA         RDYTMR          ; GET TIMER
;                BEQ         LD8CD           ; BRANCH IF NOT ACTIVE
;                DECA                        ; DECREMENT THE TIMER
;                STA         RDYTMR          ; SAVE IT
;                BNE         LD8CD           ; BRANCH IF NOT TIME TO TURN OFF DISK MOTORS
;                LDA         DRGRAM          ; GET DSKREG IMAGE
;                ANDA        #$B0            ; TURN ALL MOTORS AND DRIVE SELECTS OFF
;                STA         DRGRAM          ; PUT IT BACK IN RAM IMAGE
;                STA         DSKREG          ; SEND TO CONTROL REGISTER (MOTORS OFF)
;LD8CD           RTI                         ;         >L8955          ; JUMP TO EXTENDED BASIC'S IRQ HANDLER


PrintDiskErrorOnScreen:
        PSHS    B
        LDX     #_StrVar_PF00
        LDB     ,X+
!       LDA     ,X+
        JSR     PrintA_On_Screen
        DECB
        BNE     <
        LDA     #' '
        JSR     PrintA_On_Screen
        PULS    B
; Print Error code in B
        LDX     #DiskErrorTable
!       LDA     ,X+
        BNE     <
        DECB
        BNE     <
; X now points at the message to print
!       LDA     ,X+         ; get byte of message to print on screen
        BEQ     >
        JSR     PrintA_On_Screen
        BRA     <
!       RTS

DiskErrorTable:
        FCB     $00
DiskErrorFileNotFound   EQU 01
        FCN     /FILE NOT FOUND/
DiskErrorWriteProtected EQU 02
        FCN     /DISK IS WRITE PROTECTED/
DiskErrorIOError        EQU 03
        FCN     'INPUT/OUTPUT ERROR'
DiskErrorVerifyError EQU 04
        FCN     /VERIFY ERROR/
DiskErrorNotMLFileType EQU 05
        FCN     /NOT A MACHINE LANGUAGE FILE/
