SpeedTest  			EQU  1  * 1 = show the border while drawing dots on screen then turn off when done, shows CPU usage

* Include CoCo 3 standard hardware pointers
        INCLUDE ./includes/CoCo3_Start.asm
;        INCLUDE ./includes/CommSDC.asm          * low level code to send and receive command blocks to the SDC

************************************************************************
* Filename format info:
* This can include a full path name to the file
* Filenames must be 8 characters + a 3 character extension (no dot before the extension)
* If the filename is not 8 characters long then it must be padded with spaces
*
* Examples of the filename format:
* Name on the SD card is "TEST.TXT" needs to be accessed with the name 'M:TEST    TXT'
* Name on the SD card is "CHECK123.BIN" needs to be accessed with the name 'M:CHECK123BIN'
* Name on the SD card is "HELLO.TXT" in a subfolder called "NEW" needs to be accessed with 'M:NEW/HELLO   TXT'
*
* Filename must be terminated with a zero.  The FCN command adds the zero when assembling
************************************************************************
* From talking with Ed snider, the files on the SD card don't have to be Disk images they can be any file type but they
* do have to be padded to 512 byte boundary.

* Start by putting the SDC in command mode by sending $43 (special magic code) to $FF40
* Basically you send an $E0 with "M:" to eject the current file being looked at
*
* Example code to load a file into RAM (Ed Snider's CSM code disassembled)


M0000   EQU     $0000
M4D3A   EQU     $4D3A
M6800   EQU     $6800

				ORG     $0E00

        INCLUDE ./StreamFile_Library.asm        * Include SDC Library for openning, streaming & closing big files on the SDC
************************************************************************
EjectImage:
        FCN     'M:'
MountFile:
        FCN     'M:HEY12345JNK'
************************************************************************

CoCo_START:
***********************************************************
        PSHS    CC,D,DP,X,Y,U              * Backup everything
        ORCC    #$50                    * Disable interrupts
;				CLRA
;				STA			$FF40										* Turn off drive motor
;        STA     High_Speed_Mode       	* High Speed mode enabled

* CoCo Prep
        SETDP   CoCo_START/256          						* Set the direct Page for the assembler
        LDA     #CoCo_START/256
        TFR     A,DP
        LDX     #MountFile
        JSR     OpenSDC_File_X_At_Start   * Open a file on the SDC for streaming, 512 bytes at a time


* Test reading two 512 byte sectors
        LDX     #$0400
!       LDD     $FF4A               * Read 2 bytes of data
        STD     ,X++                * store it on the screen
        CMPX    #$0600              * are we done?
        BNE     <

        JSR     Close_SD_File       * Put Controller back into Emulation Mode
        PULS    CC,D,DP,X,Y,U,PC       * restore and return

        END   CoCo_START
