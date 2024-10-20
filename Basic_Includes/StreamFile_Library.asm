********************************************************************
* Open a file on the CoCoSDC and stream it using 512 bytes sectors
********************************************************************
controller_latch          EQU     $FF40
stat_or_cmnd_register     EQU     $FF48
param_register_1          EQU     $FF49
param_register_2          EQU     $FF4A
param_register_3          EQU     $FF4B
*
        opt     c
        opt     ct
        opt     cd
        opt     cc
************************************************************************
* Filename format info:
* This can include a full path name to the file
* You can use either a space-padded 11 character name or a traditional dot-separated name without padding

* Filenames must be 8 characters + a 3 character extension (no dot before the extension)
* If the filename is not 8 characters long then it must be padded with spaces
*
* Examples of the filename format:
* Name on the SD card is "TEST.TXT" needs to be accessed with the name 'm:TEST    TXT' or 'm:TEST.TXT'
* Name on the SD card is "CHECK123.BIN" needs to be accessed with the name 'm:CHECK123BIN'
* Name on the SD card is "HELLO.TXT" in a subfolder called "NEW" needs to be accessed with 'm:NEW/HELLO   TXT'
*
* Filename must be terminated with a zero.  The FCN command adds the zero when assembling
************************************************************************
* Open a file for streaming:
* Filename must be given with the full path on the SDC card
* The SDC calls the home directory m:
* X = location in memory for the full filename with a zero terminating the name (use FCN to add the trailing Zero), for example:
*
*  MountFile  FCN     'm:HEY12345JNK'
*
* Example code to use this library:
*
*  Code:
*       LDX     #MountFile                  * Point X at filename to stream
*       JSR     OpenSDC_File_X_At_Start     * Open a file on the SDC for streaming, 512 bytes at a time
*
*
OpenSDC_File_X_At_Start:
        PSHS    A,U                 * Save the registers
        CLRA                        * Set High LSN byte value to zero
        LDU     #$0000              * Set Mid LSN byte value & Low LSN byte Value to zero
        BSR     OpenSDC_File_X_At_AU    * Open a file at Logical Sector Block (24 bit block where A=MSB (bits 23 to 16), U=Least significant Word (bits 15 to 0)
        PULS    A,U,PC              * File is open, restore and return

* Open a file for streaming starting at Logical Sector Number, each sector is 256 bytes.  The LSN is in A & U where
* the Logical Sector Block, 24 bit block where A=MSB (bits 23 to 16), U=Least significant Word (bits 15 to 0)
*
OpenSDC_File_X_At_AU:
        PSHS    D,U                 * Save the registers

* Put controller in Command mode
* This changes the mode the CoCo SDC work in.  It is now ready for direct communication
        LDA     #$43            ; control latch value to enable SDC command mode
        STA     $FF40           ; Send the command to the SDC
        JSR     POLLBUSY        ; Wait for the SDC to signify it is not busy - Busy signal is low

* Mount a file
* Mounting a file auto ejects any previous file that was mounted
* If you want to eject a file manually you can do so by using 'm:' by itself for the name
        LDA     #$E0                * Mount Image in drive 0, use $E1 for drive 1
        STA     $FF48               * Send to the command register
        JSR     POLLREADY           * Delay 20 microseconds and wait for the SDC to signify the ready signal is on
        BSR     SendDataBlock       * Write filename to SDC
        JSR     POLLBUSY            * Wait for the SDC to signify it is not busy - Busy signal is low

* Our file is now mounted in drive 0 and is ready to use the read command
* Set the LSN (Logical Sector Number) to A,U
        LDA     ,S                  * Get original A which is the
        STA     $FF49               * High LSN byte value A=MSB (bits 23 to 16)
        STU     $FF4A               * U = Mid LSN byte value & Low LSN byte Value

        LDA     #$43                * control latch value to enable SDC command mode
        STA     $FF40               *
        JSR     POLLBUSY            * Wait for the SDC to signify it is not busy - Busy signal is low

* Send the Read Logical Sector $90 is a 512 byte sector read
* Can use $91 for virtual drive 1 if you used $E1 when mounting the file above
        LDA     #$90                * STREAM FROM SDC USING 6809 STYLE TRANSFER (DRIVE 0)
        STA     $FF48               * SEND TO COMMAND REGISTER ($FF48)
                                    * FILE SECTOR READ READY
                                    * DATA PORT AT $FF4A, 512 BYTE SECTORS
        JSR     POLLREADY           * Delay 20 microseconds and wait for the SDC to signify the ready signal is on
        PULS    D,U,PC              * File is open, restore and return

* At this point, you can begin reading the data bytes from the port as 16 bit data at $FF4A & $FF4B.
* The MCU will continue to feed data to the port until EOF is reached or an abort command is issued ($D0).
* The busy bit in status will remain set until that time.
* You will have to poll for the ready bit between 512 byte sectors, as the MCU has to fill a buffer.
* However, using 6809 style transfer, it is able to pretty much keep up with the CPU.
* There is also a small wait you need built into the polling routines in order to give the MCU
* time to reset/set the bit (20 microseconds or so is sufficient).


Close_SD_File:
        CLR     $FF40               * Put Controller back into Emulation Mode
        RTS                         * Done, Return

************************************************************************
* Wait for the SDC to signify it is not busy - Busy signal is low
* If bit 0 of $FF48 is high then the SDC is busy, loop until it is low
* When bit 0 of $FF48 is low then the SDC is not busy, carry on and return
************************************************************************
POLLBUSY:                           ;   POLLING LOOP HERE - FOR BUSY
        LDA     #%00000001          ;   BUSY STATUS MASK
!       BITA    $FF48               ;   STATUS REGISTER
        BNE     <                   ;   LOOP IF BUSY
        RTS                         ;   RETURN FROM POLLBUSY

************************************************************************
* Delay 20 microseconds and wait for the SDC to signify the ready signal is on
* If bit 1 of $FF48 is low then the SDC is not ready yet, loop until bit 1 is high
* When bit 1 of $FF48 is high then the SDC is in ready state, carry on and return
************************************************************************
POLLREADY:                          ;   POLLING LOOP HERE - FOR READY - INCLUDES...
                                    ;   20+ MICROSECOND WAIT, if CPU is in normal speed (not high speed mode)
        LBRN    $FFFF               ;   5 CYCLES
        LBRN    $FFFF               ;   5 CYCLES
        LBRN    $FFFF               ;   5 CYCLES
        LBRN    $FFFF               ;   5 CYCLES
        LDA     #%00000010          ;   READY STATUS MASK
!       BITA    $FF48               ;   STATUS REGISTER
        BEQ     <                   ;   LOOP IF NOT READY
        RTS                         ;   RETURN FROM POLLREADY

************************************************************************
* Copy command string to the SDC and Pad the rest of the 256 byte block with zeros
*
* X = pointer to the command string
* A and B are clobbered
************************************************************************
SendDataBlock:
        CLRA
!       DECA
        LDB     ,X+
        STB     $FF4A
        BEQ     ClearFF4B
        DECA
        LDB     ,X+
        STB     $FF4B
        BNE     <
* Add Zero padding for the rest of the 256 byte buffer
!       CLR     $FF4A
        DECA
ClearFF4B:
        CLR     $FF4B
        DECA
        BNE     <
        RTS
