; SDC Version Number - Command
; Returns the firmware’s version number as a 16-bit BCD value. Versions prior to 113 did not support this
; command and will fail with status bit 7 set. This is useful for determining if a particular command or feature is
; available. 
;
; Version History table:
; 113 Added the VERSION command.
; 115 Added the DELETE, RENAME and QUERY DISK SIZE commands as well as the ability to recognize
;     Dragon VDK images (but only with a 12-byte header).
; 116 Fixed the recognition of Dragon VDK headers to include headers up to 256 bytes in length.
; 117 Added the STREAM command.
; 120 Added the MOUNT NEXT DISK command. It also fixed the QUERY DISK SIZE command. Prior
;     versions only returned a 16-bit value rather than a 24-bit value (FF49 was always returning 0).
; 124 Introduced the MOUNT DISK # command and the 8-bit option for WRITE SECTOR.
; 127 Added ability to stream small files using the m: command
;
; Put controller in Command mode:
; This changes the mode the CoCo SDC work in.  It is now ready for direct communication
CheckSDCFirmwareVersion:
        LDA     #$43            ; control latch value to enable SDC command mode
        STA     >$FF40          ; Send the command to the SDC
        JSR     POLLBUSY        ; Wait for the SDC to signify it is not busy - Busy signal is low
*
        LDA     #$56            ; Additional parameters manual says none but shows $56 (V)
        STA     >$FF49          ; save as additional parameter
        LDA     #$C0            ; Version number control code
        STA     >$FF48          ; Send the command to the SDC
        JSR     POLLBUSY        ; Wait for the SDC to signify it is not busy - Busy signal is low

        LDA     >$FF48          ; Get the value of the status register
        BMI     SDCNeedsUpdate  ; If bit 7 is set then this command is not supported which means it's a very old firmware version
        CLR     >$FF40          ; put SDC controller back in floppy mode
        LDD     >$FF4A          ; Get the 16 bit BCD value       
        CMPD    #$0127          ; Get 16 bit BCD number (we need version 127 or > to stream with command 'm:')
        BLO     SDCNeedsUpdate ; If we are < 127 then upgrade firmware message
* Good firmware version, continue as normal
SDCGoodFirmware:
        RTS
* Show upgrade needed message and infinate loop
SDCNeedsUpdate:
!       LDB     #83             ; Length of this string
        LDU     #SDCUpdateMessage   ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+             ; Get the string data
        JSR     PrintA_On_Screen ; Go print A on screen
        DECB                    ; decrement the string length counter
        BNE     <               ; If not counted down to zero then loop
        CLR     >$FF40          ; put SDC controller back in floppy mode
        BRA     *               ; Infinate loop
SDCUpdateMessage:
        FCN     'SDC FIRMWARE NEEDS TO BE UPDATEDTO ATLEAST VERSION 127 TO USE   THE SDCPLAY COMMAND'
