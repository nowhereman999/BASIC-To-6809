; SDC file access commands
; Open a file for writing to or reading from the CoCoSDC
; filename is at _StrVar_PF00 and terminated with a zero
*****************************************************
        ALIGN   $100
SDC_Buffer0     RMB     256     ; reserve 256 bytes for the buffer
SDC_Buffer1     RMB     256     ; reserve 256 bytes for the buffer
SDC_LBN0        RMB     3       ; reserve 3 bytes to keep track of the Logical Block Number of file 0
SDC_BufferPointer0 RMB  2       ; pointer to keep track of the location in the 256 byte buffer0
SDC_LBN1        RMB     3       ; reserve 3 bytes to keep track of the Logical Block Number of file 1
SDC_BufferPointer1 RMB  2       ; pointer to keep track of the location in the 256 byte buffer1
SDC_WriteMode0  RMB     1       ; 0 = read mode, 1 = write mode
SDC_WriteMode1  RMB     1       ; 0 = read mode, 1 = write mode

; We are setting up for writing to the CoCoSDC
; Put "m:" at the start of the filename this sets the CoCoSDC to write/read a file
; If writing, it will create a new file (not a disk image file)
; If reading, it will get the file ready to be read with Logical block reads (not as a disk image file)
; A = File read mode (0) or write mode (1)
; B = File number (0 or 1)

SDCOpenFile:
        PSHS    D               ; Save A & B
        LDX     #SDC_WriteMode0 ; Get the address of the write mode flags
        STA     B,X             ; Set the Read/write mode flags
        LDA     #'m'            ; m is for reading from a file
        TST     ,S              ; Test if A is zero (read mode)
        BEQ     >               ; If A is zero, skip forward
        LDA     #'n'            ; n is for writing to a file
!       JSR     SDCSetName      ; Add letter in A & ":" to the beginning of the name in _StrVar_PF00 final version 
                                ; will be stored at _StrVar_PF01 and will be null terminted and U pointing at the start

* Check and disable any high speed options
        LDA     >CoCoHardware           ; Get the CoCo Hardware info byte
        BPL     >                       ; If bit 7 is clear then skip forward it's a 6809
        FCB     $11,$3D,%00000000       ; otherwise, put the 6309 in emulation mode.  This is LDMD  #%00000000
!       RORA                            ; Move bit 0 to the Carry bit
        BCC     >                       ; if the Carry bit is clear, then not a CoCo 3, skip ahead
        STA     >$FFD8                 ; Put CoCo 3 in Regular speed mode
!

        LDX     #$0000
        LDA     1,S             ; Get the file number
        BNE     >               ; if it is <> 0 then we are opening file 1
        LDD     #SDC_Buffer0    ; Get buffer start address for file 0 (aligned to $100 so B=0)
        STD     SDC_BufferPointer0 ; Save the buffer pointer for file 0
        LDA     #$E0            ; Command Code ($E0 for drive slot 0/file 0) for Mounting a New Image
        STB     SDC_LBN0
        STX     SDC_LBN0+1      ; Clear the LBN for file 0
        BRA     SDCSetFilenameOpen

!       LDD     #SDC_Buffer1    ; Get buffer start address for file 1 (aligned to $100 so B=0)
        STD     SDC_BufferPointer1 ; Save the buffer pointer for file 1
        LDA     #$E1            ; Command Code ($E1 for drive slot 1/file 1) for Mounting a New Image
        STB     SDC_LBN1
        STX     SDC_LBN1+1      ; Clear the LBN for file 1
SDCSetFilenameOpen:
        JSR     CommSDC         ; Send the command to the SDC
        LBCS    SDCError        ; SDC Error, go show the error and halt program
        LDA     ,S              ; See if the user wants to Read or Write this file (A=0 for Read, A=1 for Write)
        BNE     SDCOpenDone     ; If A<>0 then we are writing to the file, we are done
; Setup read mode by loading the input buffer
        LDB     1,S             ; Get the file number
        BNE     >               ; if it is <> 0 then we are opening file 1
; Open file 0 for reading:
        JSR     SDC_ReadBuffer0 ; Read the first 256 bytes of the file into the buffer
        BRA     SDCOpenDone     ; We are done
!       JSR     SDC_ReadBuffer1 ; Read the first 256 bytes of the file into the buffer
SDCOpenDone
        PULS    D,PC            ; Restore and return

; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
SDCPutByteB0:
        PSHS    D,X,U              ; Save everything
        STB     [SDC_BufferPointer0] ; Store the byte in the buffer
        INC     SDC_BufferPointer0+1 ; Increment the buffer pointer LSB
        BNE     >                  ; If the buffer pointer is 256 bytes, write the buffer to the SDC
        BSR     SDC_WriteBuffer0   ; Write the buffer to the SDC
!       PULS    D,X,U,PC           ; Restore everything and return

; Write a buffer to the SDC file 0, this is called when the buffer is full
SDC_WriteBuffer0:
        PSHS    D,X,U           ; Save everything
        LDA     #$A0            ; Command Code ($A0 for drive 0) for Write Logical Block
        LDB     SDC_LBN0        ; Get the High order byte of the LBN for file 0
        LDX     SDC_LBN0+1      ; Get the Wow order word of the LBN for file 0
        LDU     #SDC_Buffer0    ; Get the buffer start address
        JSR     CommSDC         ; Send the command to the SDC
        LBCS    SDCError        ; SDC Error, go show the error and halt program
        INC     SDC_LBN0+2      ; Increment the LBN LSB for file 0
        BNE     SDC_WriteBuffer_Done ; If the LBN LSB is not 256, Done writing
        INC     SDC_LBN0+1      ; Increment the LBN MidSB for file 0
        BNE     SDC_WriteBuffer_Done ; If the LBN MidSB is not 256, Done writing
        INC     SDC_LBN0        ; Increment the LBN MSB for file 0
        BNE     SDC_WriteBuffer_Done ; If the LBN MSB is not 256, Done writing
; Reached filesize max of 256x256x256x256 = 4 Gig filesize
SDCReachedMaxFilesize:
        JSR     SDC_CloseFile0  ; Close the file
        BSR     >               ; Skip over string value
        FCC     "SDC ERROR: MAX FILESIZE REACHED"
        FCB     $0D,00          ; CR and end string
!       LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
        JMP     SDCShowError    ; Show Error message and halt program

; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
SDCPutByteB1:
        PSHS    D,X,U              ; Save everything
        STB     [SDC_BufferPointer1] ; Store the byte in the buffer
        INC     SDC_BufferPointer1+1 ; Increment the buffer pointer LSB
        BNE     >                  ; If the buffer pointer is 256 bytes, write the buffer to the SDC
        BSR     SDC_WriteBuffer1   ; Write the buffer to the SDC
!       PULS    D,X,U,PC           ; Restore everything and return

; Write a buffer to the SDC file 1, this is called when the buffer is full
SDC_WriteBuffer1:
        PSHS    D,X,U           ; Save everything
        LDA     #$A1            ; Command Code ($A1 for drive 1) for Write Logical Block
        LDB     SDC_LBN1        ; Get the High order byte of the LBN for file 0
        LDX     SDC_LBN1+1      ; Get the Low order word of the LBN for file 0
        LDU     #SDC_Buffer1    ; Get the buffer start address
        JSR     CommSDC         ; Send the command to the SDC
        LBCS    SDCError        ; SDC Error, go show the error and halt program
        INC     SDC_LBN1+2      ; Increment the LBN LSB for file 0
        BNE     SDC_WriteBuffer_Done ; If the LBN LSB is not 256, Done writing
        INC     SDC_LBN1+1      ; Increment the LBN MidSB for file 0
        BNE     SDC_WriteBuffer_Done ; If the LBN MidSB is not 256, Done writing
        INC     SDC_LBN1        ; Increment the LBN MSB for file 0
        BNE     SDC_WriteBuffer_Done ; If the LBN MSB is not 256, Done writing
; Reached filesize max of 256x256x256x256 = 4 Gig filesize
        JSR     SDC_CloseFile1  ; Close the file 1
        BRA     SDCReachedMaxFilesize ; File 1 is too big, show error and halt program
SDC_WriteBuffer_Done:
        PULS    D,X,U,PC        ; Restore everything and return

* Get the next available byte from the SDC file B and return with the value in B
* B must be 0 or 1
SDCGetByte:
        TSTB                    ; Test if B is 0 or 1
        BNE     SDCGetByteB1    ; Get the next byte from file 1
; Get the next byte in file 0 and return with it in B
SDCGetByteB0:
        LDB     [SDC_BufferPointer0] ; Get the byte in the buffer
        INC     SDC_BufferPointer0+1 ; Increment the buffer pointer LSB
        BNE     >                  ; If the buffer pointer is 256 bytes, write the buffer to the SDC
        BSR     SDC_ReadBuffer0    ; Load the buffer from the the SDC
!       RTS                  
; Fill buffer 0 from the the SDC file 0
SDC_ReadBuffer0:
        PSHS    D,X,U           ; Save everything
        LDA     #$80            ; Command Code ($80 for drive 0) for Read Logical Block
        LDB     SDC_LBN0        ; Get the High order byte of the LBN for file 0
        LDX     SDC_LBN0+1      ; Get the Wow order word of the LBN for file 0
        LDU     #SDC_Buffer0    ; Get the buffer start address
        JSR     CommSDC         ; Send the command to the SDC
        LBCS    SDCError        ; SDC Error, go show the error and halt program
        INC     SDC_LBN0+2      ; Increment the LBN LSB for file 0
        BNE     SDC_ReadBuffer_Done ; If the LBN LSB is not 256, Done reading
        INC     SDC_LBN0+1      ; Increment the LBN MidSB for file 0
        BNE     SDC_ReadBuffer_Done ; If the LBN LSB is not 256, Done reading
        INC     SDC_LBN0        ; Increment the LBN MSB for file 0
        BRA     SDC_ReadBuffer_Done

; Get the next byte in file 1 and return with it in B
SDCGetByteB1:
        LDB     [SDC_BufferPointer1] ; Load byte from the buffer
        INC     SDC_BufferPointer1+1 ; Increment the buffer pointer LSB
        BNE     >                  ; If the buffer pointer is 256 bytes, write the buffer to the SDC
        BSR     SDC_ReadBuffer1    ; Load the buffer from the the SDC
!       RTS
; Fill buffer 1 from the the SDC file 1
SDC_ReadBuffer1:
        PSHS    D,X,U           ; Save everything
        LDA     #$81            ; Command Code ($81 for drive 1) for Read Logical Block
        LDB     SDC_LBN1        ; Get the High order byte of the LBN for file 1
        LDX     SDC_LBN1+1      ; Get the Wow order word of the LBN for file 1
        LDU     #SDC_Buffer1    ; Get the buffer start address
        JSR     CommSDC         ; Send the command to the SDC
        LBCS    SDCError        ; SDC Error, go show the error and halt program
        INC     SDC_LBN1+2      ; Increment the LBN LSB for file 1
        BNE     SDC_ReadBuffer_Done ; If the LBN LSB is not 256, Done reading
        INC     SDC_LBN1+1      ; Increment the LBN MidSB for file 1
        BNE     SDC_ReadBuffer_Done ; If the LBN LSB is not 256, Done reading
        INC     SDC_LBN1        ; Increment the LBN MSB for file 1
SDC_ReadBuffer_Done:
        PULS    D,X,U,PC        ; Restore everything and return

* Close open file B
SDC_CloseFileB:
        TSTB                    ; Test if B is 0 or 1
        BNE     SDC_CloseFile1  ; Close the file 1
; Sending just "M:" will close/eject the open file/image
; Close file 0
SDC_CloseFile0:
        PSHS    D,X,U           ; Save everything
        LDA     #$E0            ; Command Code ($E0 for drive 0) for Write Logical Block
        LDB     SDC_WriteMode0  ; 0 = read mode, 1 = write mode
        BEQ     SDC_CloseFile   ; If the write mode is 0, we are only reading so close the file
        LDX     #SDC_Buffer0    ; Get to the start of the buffer
        LDB     SDC_BufferPointer0+1 ; get the current buffer pointer
        BEQ     SDC_CloseFile   ; If the buffer pointer is 0, the buffer is empty, so close the file
        ABX
!       CLR     ,X+             ; Clear the rest of the buffer
        INCB
        BNE     <
        JSR     SDC_WriteBuffer0   ; Write the end of the buffer to the SDC
SDC_CloseFile:
        LDU     #_StrVar_PF00   ; Get the filename location
        LDX     #'M'*$100+':'   ; X= "M:" - the Mount command by itself will close/eject the open file/image
        STX     ,U              ; Store the Mount command in the filename location
        CLR     2,U             ; Null terminate the filename - just "M:"
        JSR     CommSDC         ; Send the command to the SDC
        LBCS    SDCError        ; SDC Error, go show the error and halt program
        JSR     SetCPUSpeed     ; Set the CPU Speed back to what the user wants
        PULS    D,X,U,PC        ; Restore everything and return

; Close file 1
SDC_CloseFile1:        
        PSHS    D,X,U           ; Save everything
        LDA     #$E1            ; Command Code ($E1 for drive 1) for Write Logical Block
        LDB     SDC_WriteMode1  ; 0 = read mode, 1 = write mode
        BEQ     SDC_CloseFile   ; If the write mode is 0, we are only reading so close the file
        LDX     #SDC_Buffer1    ; Get to the start of the buffer
        LDB     SDC_BufferPointer1+1 ; get the current buffer pointer
        BEQ     SDC_CloseFile   ; If the buffer pointer is 0, close the file
        ABX
!       CLR     ,X+             ; Clear the rest of the buffer
        INCB
        BNE     <
        JSR     SDC_WriteBuffer1   ; Write the end of the buffer to the SDC
        BRA     SDC_CloseFile   ; Close the file

; Use SDC Get Info for Mounted Image
; Command code: $C0 or $C1 (drive number in bit 0)
; A = Command code
; B = $49  (I)
; U = Buffer address to retrieve info to
;
; Buffer info that is retreived:
; 0-7   File Name
; 8-10  Extension
; 11    Attribute bits: $10=Directory, $04=SDF Format, $02=Hidden, $01=Locked
; 28-31 File Size in bytes (LSB first)
;
; FileInfo(B)
; Get the length of the open file in B
; Enter with file number in B (0 or 1)
SDC_FileInfo:
        ADDB    #$C0            ; Add $C0 and the file number
        TFR     B,A             ; Move the command to A
        LDB     #$49            ; Command to get
        LDU     #_StrVar_IFRight  ; Temp buffer where the SDC will store the info it gets
        JSR     CommSDC         ; Send the command to the SDC
        LBCS    SDCError        ; SDC Error, go show the error and halt program
        RTS

; Initiate a directory listing
;
; Command code: $E0
; A = Command code
; U = Buffer address where the directory is stored
; Path must start with L:
; Only the leaf directory will be created from the given path, the parent directory must already exist
;
; Enter with Source string in _StrVar_PF00 (first byte is the string length)
SDC_InitDirectory:
        LDA     #'L'            ; Path must start with L:
        BSR     SDCSetName      ; Add letter in A & ":" to the beginning of the name in _StrVar_PF00 final version 
                                ; will be stored at _StrVar_PF01 and will be null terminted and U pointing at the start
        LDA     #$E0            ; Directory command
        JSR     CommSDC         ; Send the command to the SDC
        BCS     SDC_ReturnErrorNumber  ; SDC Error, get error number in B and return
        LDD     #$0000          ; Clear the Error Number
        RTS                     ; Return with carry clear to indicate success

; Start showing the directory listing based on the format specified with the SDC_InnitDirectory command
;
; Command code: $C0
; A = Command code
; U = Buffer address where the 256 byte directory will be stored
; Path must start with D:
; Only the leaf directory will be created from the given path, the parent directory must already exist
;
; Enter with Source string in _StrVar_PF00 (first byte is the string length)
SDC_DirectoryPage:
        LDA     #$C0            ; Get current Directory command
        LDB     #$3E            ; Additional parameters
        JSR     CommSDC         ; Send the command to the SDC
        BCS     SDC_ReturnErrorNumber  ; SDC Error, get error number in B and return
        LDD     #$0000          ; Clear the Error Number
        RTS                     ; Return with carry clear to indicate success

; Get the current working directory
; Shows which directory you are looking at, only retrieves the leaf name of the directory, not the full path
;
; Command code: $C0
; A = Command code
; B = $43
; U = Buffer address where the directory is stored
; Path must start with D:
; Only the leaf directory will be created from the given path, the parent directory must already exist
;
; Enter with Source string in _StrVar_PF00 (first byte is the string length)
SDC_GetCurrentDirectory:
        LDA     #$C0            ; Get current Directory command
        LDB     #$43            ; Additional parameters
        JSR     CommSDC         ; Send the command to the SDC
        BCS     SDC_ReturnErrorNumber  ; SDC Error, get error number in B and return
        LDD     #$0000          ; Clear the Error Number
        RTS                     ; Return with carry clear to indicate success

; Delete a file or an empty directory from the SDC
;
; Command code: $E0
; A = Command code
; U = Buffer address where the directory is stored
; Path must start with X:
; Only the leaf directory will be created from the given path, the parent directory must already exist
;
; Enter with Source string in _StrVar_PF00 (first byte is the string length)
SDC_Delete:
        LDA     #'X'            ; Path must start with X:
        BSR     SDCSetName      ; Add letter in A & ":" to the beginning of the name in _StrVar_PF00 final version 
                                ; will be stored at _StrVar_PF01 and will be null terminted and U pointing at the start
        LDA     #$E0            ; Directory command
        JSR     CommSDC         ; Send the command to the SDC
        BCS     SDC_ReturnErrorNumber  ; SDC Error, get error number in B and return
        LDD     #$0000          ; Clear the Error Number
        RTS                     ; Return with carry clear to indicate success

; Set the current working directory to the one specified in the buffer
;
; Command code: $E0
; A = Command code
; U = Buffer address where the directory is stored
; Path must start with D:
; Only the leaf directory will be created from the given path, the parent directory must already exist
;
; Enter with Source string in _StrVar_PF00 (first byte is the string length)
SDC_SetCurrrentDirectory:
        LDA     #'D'            ; Path must start with D:
        BSR     SDCSetName      ; Add letter in A & ":" to the beginning of the name in _StrVar_PF00 final version 
                                ; will be stored at _StrVar_PF01 and will be null terminted and U pointing at the start
        LDA     #$E0            ; Directory command
        JSR     CommSDC         ; Send the command to the SDC
        BCS     SDC_ReturnErrorNumber  ; SDC Error, get error number in B and return
        LDD     #$0000          ; Clear the Error Number
        RTS                     ; Return with carry clear to indicate success

; Create a new directory
;
; Command code: $E0
; A = Command code
; U = Buffer address where the directory is stored
; Path must start with K:
; Only the leaf directory will be created from the given path, the parent directory must already exist
;
; Enter with Source string in _StrVar_PF00 (first byte is the string length)
SDC_CreateDirectory:
        LDA     #'K'            ; Path must start with K:
        BSR     SDCSetName      ; Add letter in A & ":" to the beginning of the name in _StrVar_PF00 final version 
                                ; will be stored at _StrVar_PF01 and will be null terminted and U pointing at the start
        LDA     #$E0            ; Directory command
        JSR     CommSDC         ; Send the command to the SDC
        BCS     SDC_ReturnErrorNumber  ; SDC Error, get error number in B and return
        LDD     #$0000          ; Clear the Error Number
        RTS                     ; Return with carry clear to indicate success

SDC_ReturnErrorNumber:
        TFR     B,A             ; Move error flags into A
        CLRB                    ; Clear the Error Number
!       INCB                    ; increment the error number
        RORA                    ; Rotate the error flag bit through A
        BCC     <               ; If the bit is clear, keep going
        CLRA                    ; Clear the MSB of D, so only B has the error number
        RTS                     ; Return with carry set to indicate an error

; Add letter in A the beginning of the file/directory name in _StrVar_PF00 final version will be in _StrVar_PF01
; Fix filename/directory name to start with D
; Exter with A set to the Letter wanted
; Exit with U pointing at the new file/directory name _StrVar_PF01
SDCSetName:
; Fix the filename to include "x:" at the beginning
        LDU     #_StrVar_PF01   ; Get the start of the destination filename string
        PSHS    U               ; save the pointer to the destination
        LDB     #':'            ; 2nd character is a colon
        STD     ,U++            ; Set the first bytes to the "x:"    
        LDX     #_StrVar_PF00+1 ; Point at the source filename string
        LDB     -1,X            ; Get the length byte    
!       LDA     ,X+             ; Get a byte from the source
        STA     ,U+             ; Save the byte to the destination
        DECB                    ; Decrement the length counter
        BNE     <               ; if it is not zero then keep copying
        STB     ,U              ; Set the last byte to zero (null terminator "I'll be back!")
        PULS    U,PC            ; Restore the destination pointer and return

; SDC Version Number - Command
;
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
; A = $C0
; B = $56  (V)
; U = Buffer address to retrieve info to
;
; Put controller in Command mode:
; This changes the mode the CoCo SDC work in.  It is now ready for direct communication
CheckSDCFirmwareVersion:
        LDA    #$C0            ; Add $C0 and the file number
        LDB     #$56            ; Command to get
        JSR     CommSDC         ; Send the command to the SDC
        BCS     SDCError        ; SDC Error, go show the error and halt program
        LDD     >$FF4A          ; Get the 16 bit BCD value       
        CMPD    #$0127          ; Get 16 bit BCD number (we need version 127 or > to stream with command 'm:')
        BLO     SDCNeedsUpdate ; If we are < 127 then upgrade firmware message
* Good firmware version, continue as normal
        RTS

* Show upgrade needed message and infinate loop
SDCNeedsUpdate:
        LDU     #SDCUpdateMessage   ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+             ; Get the string data
        BEQ     >               ; if it is zero then we are done
        JSR     PrintA_On_Screen ; Go print A on screen
        BRA     <               ; If not counted down to zero then loop
!       CLR     >$FF40          ; put SDC controller back in floppy mode
        BRA     *               ; Infinate loop
SDCUpdateMessage:
        FCN     'SDC FIRMWARE NEEDS TO BE UPDATEDTO ATLEAST VERSION 127'


; SDC Error handling
SDCError:
        BITB    #%00100000      ; Test if target file is already in use
        BNE     SDCFileInUse    ; If the target file is already in use then exit
        BITB    #%00010000      ; Test if target file is not found
        BNE     SDCFileNotFound ; If the target file is not found then exit
        BITB    #%00001000      ; Miscellaneous hadrware error
        BNE     SDCMisceError   ; If the target file is already in use then exit
        BITB    #%00000100      ; Test if path name is valid
        LBNE    InvalidPath     ; If the path name is invalid then exit
        BITB    #%00000001      ; Test if the SDC is busy
        LBNE    SDCStillBusy    ; If the SDC is still busy then exit
SDCErrorOther:
        BSR     >               ; Skip over string value
        FCC     "SDC ERROR: UNKNOWN"
        FCB     $0D,00          ; CR and end string
!       LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
SDCShowError:
        LDA     ,U+             ; Get the string data
        BEQ     >               ; If the character is zero then done
        JSR     PrintA_On_Screen   ; Go print A on screen
        BRA     SDCShowError    ; If not counted down to zero then loop
!       BRA     *               ; Loop forever
; File already in use
SDCFileInUse:
        BSR     >               ; Skip over string value
        FCC     "SDC ERROR: FILE IN USE"
        FCB     $0D,00          ; CR and end string
!       LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
        BRA     SDCShowError    ; Show Error message and halt program
; File not found
SDCFileNotFound:
        BSR     >               ; Skip over string value
        FCC     "SDC ERROR: FILE NOT FOUND"
        FCB     $0D,00          ; CR and end string
!       LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
        BRA     SDCShowError    ; Show Error message and halt program
; Miscellaneous error
SDCMisceError:
        BSR     >               ; Skip over string value
        FCC     "SDC ERROR: MISCELLANEOUS"
        FCB     $0D
        FCC     "HARDWARE ERROR"
        FCB     $0D,00          ; CR and end string
!       LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
        BRA     SDCShowError    ; Show Error message and halt program
; Invalid path name
InvalidPath:
        BSR     >               ; Skip over string value
        FCC     "SDC ERROR: INVALID FILE PATH"
        FCB     $0D,00          ; CR and end string
!       LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
        JMP     SDCShowError    ; Show Error message and halt program
; SDC still busy - too long to respond
SDCStillBusy:
        BSR     >               ; Skip over string value
        FCC     "SDC ERROR: SDC STILL BUSY"
        FCB     $0D,00          ; CR and end string
!       LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
        JMP     SDCShowError    ; Show Error message and halt program


* To reset the CoCoSDC (put it in firmware upgrade mode then back to normal)
SDCReset:
    LDA   #$1C      * Send command $1C
    LDB   #$AA      * First parameter $AA
    LDX   #$5500    * Second parameter to $55
    JSR   CommSDC   * Send to the CoCoSDC
    LDY   #5000     * Loop is 8 cycles, at double speed on a CoCo3 each cycle is 0.0000005586592179 seconds, * 8 cycles = 0.000004469273743, 20msec = 3580 loops
!   LEAY  -1,Y      * countdown of 5000, to give us a little extra time (just in case)
    BNE   <         * Loop until Y is zero
*  A read of param registers 1 and 2 should return 'PM'
    LDD   PREG1     * $FF49 param register 1, $FF4A param register 2
* D should now = "PM" you can do a test here if you want to make sure the controller is in the Program Mode
    LDA   #'G'      * Write "G" to exit program mode and do a soft reset of the controller
    STA   STATREG   * Send directly to $FF48
    RTS

