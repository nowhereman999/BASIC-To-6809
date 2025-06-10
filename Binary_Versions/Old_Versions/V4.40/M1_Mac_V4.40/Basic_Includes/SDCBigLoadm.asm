; SDCBigLoadm
; File format:
; first 512 bytes consist of 256 words that represent which 8k Block of RAM to load from the file
; if one of the words is $FFFF then loading ends
; The resit of the file are a bunch of 8k blocks
;
SDCBankPointer  FDB     _StrVar_PF00
SDCByteCount    RMB     1               ; Counter for writing bytes
SDCBlockCount   RMB     1               ; Counter for number of 512 byte blocks to load
SDCBigLoadM:
* Check and disable any high speed options
        LDA     >CoCoHardware           ; Get the CoCo Hardware info byte
        BPL     >                       ; If bit 7 is clear then skip forward it's a 6809
        FCB     $11,$3D,%00000000       ; otherwise, put the 6309 in emulation mode.  This is LDMD  #%00000000
!       RORA                            ; Move bit 0 to the Carry bit
        BCC     >                       ; if the Carry bit is clear, then not a CoCo 3, skip ahead
        STA     >$FFD8                 ; Put CoCo 3 in Regular speed mode
!

* Lowercase m: which doesn't have a size length check
; Put "m:" at the start of the filename
        LDX     #_StrVar_PF00+1 ; Get the start of the filename string
        LDB     -1,X            ; Get the length byte
        CLR     B,X             ; Ensure the filename ends with a zero
        ADDB    #02             ; Increment the length byte
        STB     -1,X            ; Get the length of the filename
        LEAY    2,X             ; Y = start of the filename
!       LDU     B,X
        STU     B,Y
        DECB
        BPL     <
        LDU     #'m'*$100+':'   ; U= "m:"
        STU     ,X
        JSR     OpenSDC_File_X_At_Start ; Open a file for streaming, at the beginning of the file

        PSHS    CC,DP           ; Save the CC & the DP on the stack
        ORCC    #$50            ; Turn off the interrupts
        STS     BigLoadmSDCStack+2  ; Save the Stack (Self mod)

; At this point, you can begin reading the data bytes from the port as 16 bit data at $FF4A & $FF4B.
; The MCU will continue to feed data to the port until EOF is reached or an abort command is issued ($D0).
; The busy bit in status will remain set until that time.
; You will have to poll for the ready bit between 512 byte sectors, as the MCU has to fill a buffer.
; However, using 6809 style transfer, it is able to pretty much keep up with the CPU.
; There is also a small wait you need built into the polling routines in order to give the MCU
; time to reset/set the bit (20 microseconds or so is sufficient).
        LDA     #$FF            ; Set the DP to $FF
        TFR     A,DP            ; Set the DP to $FF
* Prepare for BREAK key tests
        LDB     #$FB            ; strobe the keyboard column..
        STB     <$02            ; $FF02 ..which contains the BREAK key

!       LDA     <$48            ; [4] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
        ASRA                    ; [2] Shift the BUSY bit to the carry
        LBCC    >SDCBigLoadmDone ;[5 if not taken, 6 if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
        BEQ     <

        LDX     #_StrVar_PF00   ; Use this and _StrVar_PF01 as a 512 byte buffer
        STX     SDCBankPointer  ; Point at the beginning of the bank list
        LEAS    8,X             ; Move S to the correct location
        LDU     #@ComBackHere
        STU     SDCJumpBack+1
        BRA     SDCGet512Bytes  ; Fill the block map buffer with info of where data is stored in memory
@ComBackHere:
!       LDA     <$48            ; [4] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
        ASRA                    ; [2] Shift the BUSY bit to the carry
        LBCC    >SDCBigLoadmDone ;[5 if not taken, 6 if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
        BEQ     <

        LDX     SDCBankPointer  ; Get the version number of the file
        LDD     ,X++            ; D = version # of the file and move to next pointer
        STX     SDCBankPointer  ; Update the pointer
        CMPD    #$0001          ; So far we can only handle version 1 file types
        BNE     SDCBigLoadmDone ; Just end the loading of this file

SDCGetNextBlock:
        LDX     SDCBankPointer  ; Get the bank pointer
        LDD     ,X++            ; D = value, move to next pointer
        STX     SDCBankPointer  ; Update the pointer
        CMPA    #$FF            ; Is it the flag for done?
        BNE     FillRAM         ; Not the EOF indicator
        CMPB    #$FF            ; Is it really done?
        LBEQ    SDCBigLoadmDone ; EOF, close file and return

FillRAM:
        STB     $FFA2           ; Setup Bank 2 = $4000
        LDA     #16
        STA     SDCBlockCount
        LDS     #$4008          ; Move S to the proper location to blast fill RAM
        LDU     #@ComBackHere
        STU     SDCJumpBack+1
        BRA     SDCGet512Bytes  ; Go read and write 512 bytes
; Return after writing 512 bytes to RAM
@ComBackHere:

; Wait for SDC to be ready
* Loop to read the file blocks
!       LDA     <$48            ; [4] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
        ASRA                    ; [2] Shift the BUSY bit to the carry
        LBCC    >SDCBigLoadmDone ;[5 if not taken, 6 if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
        BEQ     <
        DEC     SDCBlockCount   ; Decrement our 512 byte block counter
        BEQ     SDCGetNextBlock ; If we've finished filling $4000 to $5FFF then get the next block
; Keep writing to RAM

; Get 512 bytes from the SDC
; S is setup at the writing location
SDCGet512Bytes:
        LDB     #512/32
        STB     SDCByteCount
!       LDD     <$4A
        LDX     <$4A
        LDY     <$4A
        LDU     <$4A
        PSHS    D,X,Y,U         ; Write 8 bytes
        LEAS    16,S
        LDD     <$4A
        LDX     <$4A
        LDY     <$4A
        LDU     <$4A
        PSHS    D,X,Y,U         ; Write 16 bytes
        LEAS    16,S
        LDD     <$4A
        LDX     <$4A
        LDY     <$4A
        LDU     <$4A
        PSHS    D,X,Y,U         ; Write 24 bytes
        LEAS    16,S
        LDD     <$4A
        LDX     <$4A
        LDY     <$4A
        LDU     <$4A
        PSHS    D,X,Y,U         ; Write 32 bytes
        LEAS    16,S
        DEC     SDCByteCount
        BNE     <
SDCJumpBack:
        JMP     >$FFFF
        
* Exit
SDCBigLoadmDone:
        CLR     <$40            ; put SDC controller back in floppy mode

BigLoadmSDCStack:
        LDS     #$FFFF          ; Restore the Stack pointer (self mod)
        JSR     SetCPUSpeed     ; Set the CPU Speed back to what the user wants
        LDB     #$3A
        STB     $FFA2           ; Restore normal Bank 2 = $4000
        PULS    CC,DP,PC        ; Restore CC & DP & return

