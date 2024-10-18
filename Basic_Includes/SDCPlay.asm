; SDCPlay command - 44,750 khz sample rate
; Play a raw audio sample directly from the CoCoSDC
; filename is at _StrVar_PF00 and terminated with a zero
; Will use RAM from _StrVar_PF00 to _StrVar_IFRight+256 as two 512 byte RAM buffers
; Extra space (256 bytes) must be reserved after _StrVar_IFRight (which the compiler will take care of)
;
*****************************************************
* To convert audio to CoCo 1 & 2 SDCPLAY mode at 44750 hz use ffmpeg:
* ffmpeg -i source_audio.wav -acodec pcm_u8 -f u8 -ac 1 -ar 44750 -af aresample=44750:filter_size=256:cutoff=1.0 output.raw
* Batch conversion of .wav files to CoCo .raw:
* for f in *.wav ; do ffmpeg -i "$f"  -acodec pcm_u8 -f u8 -ac 1 -ar 44750 -af aresample=44750:filter_size=256:cutoff=1.0  "${f%.wav}.raw" ; done
*****************************************************

SDCBuffer0      EQU     _StrVar_PF00
SDCBuffer1      EQU     SDCBuffer0+512

SDCPLAY:
        PSHS    CC,DP           ; Save the CC & the DP on the stack
        ORCC    #$50            ; Turn off the interrupts
        STS     PlaySDCStack+2  ; Save the Stack (Self mod)
        JSR     Select_AnalogMuxer ; SET UP DA TO PASS THROUGH ANA MUX
        JSR     AnalogMuxOn     ; ENABLE ANA MUX

* This code masks off the two low bits written to $FF20
* So you can send the PCM Unsigned 8 Bit sample as is, no masking needed
	LDA	$FF21
	PSHS	A
	ANDA	#%00110011              * FORCE BIT2 LOW
	STA	$FF21                   * $FF20 NOW DATA DIRECTION REGISTER
	LDA	#%11111100              * OUTPUT ON DAC, INPUT ON RS-232 & CDI
	STA	$FF20
	PULS	A
	STA	$FF21
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
        LBCC    >SDCAudioPlayDone ;[5 if not taken, 6 if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
        BEQ     <

; Since we want to go backwards we will start with buffer 1
; Fill buffer 1
        LDB     #128            ; A = 0
        LDS     #SDCBuffer1+512 ; [4] S = the end of buffer 1+1
!       LDU     <$4A            ; Get two samples in U
        LDX     <$4A            ; Get two samples in X
        PSHS    X,U             ; Save the samples
        DECB                    ; decrement the counter
        BNE     <               ; Have we done 128 times yet? Keep looping if not
        LDY     #SDCBuffer1+512 ; [4] Y = end of Buffer 1+1
!       LDA     <$48            ; [4] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
        ASRA                    ; [2] Shift the BUSY bit to the carry
        LBCC    >SDCAudioPlayDone ;[5 if not taken, 6 if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
        BEQ     <

; Start playing audio from buffer 1, backwards
; B = 83, 83 * 2 = 166 samples
PlayAudioBuff1:
        LDB     #83             ; [2] Play 83*2 = 166 bytes before getting more data from the SDC to give it time to fill its buffer
!       LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LEAU    ,U              ; [4] Waste CPU cycles, two bytes
        LEAU    ,U++            ; [7] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LEAU    ,U              ; [4] Waste CPU cycles, two bytes      
        DECB                    ; [2] Dec counter, loop until we've played back 254 samples (almost half the buffer)
        BNE     <               ; [3] Loop if not zero
; done playing 166 samples
; Play 6 & Load 8 bytes
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        PSHS    #0              ; [5] Waste CPU cycles, two bytes
        PSHS    #0              ; [5] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

* done playing 172 samples, loaded 8 
        LDB     #42             ; [2] Play 42 x 8 = 336 samples, & Load 42 x 12 = 504 bytes into the buffer
        LEAU    ,U++            ; [7] Waste CPU cycles, two bytes
* Loop Plays 8 samples and loads 12 samples
!       LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        PSHS    #0              ; [5] Waste CPU cycles, two bytes
        PSHS    #0              ; [5] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20
      
        LEAU    ,U              ; [4] Waste CPU cycles, two bytes
        DECB                    ; [2] Dec counter, loop until we've played back 254 samples (almost half the buffer)
        BNE     <               ; [3] Loop if not zero + 11 Cycles
* Done playing 508 Samples, loaded 512
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDA     >$FF48          ; [5] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
        ASRA                    ; [2] Shift the BUSY bit to the carry
        BRN     *               ; [3] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20
* Done playing 510 Samples

        LBCC    >SDCPlaylastblock0 ;[5] if not taken, 6 if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
        LEAU    ,U              ; [4] Waste CPU cycles, two bytes
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDS    #SDCBuffer1+512  ; [4] S = end of Buffer1 1+1
        LEAU    ,U++            ; [7] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20
* Done playing 512 Samples

        LEAU    ,U++            ; [7] Waste CPU cycles, two bytes
        LDB     #83             ; [2] Play 83*2 = 166 bytes before getting more data from the SDC to give it time to fill its buffer
; B = 83, 83 * 2 = 166 samples
PlayAudioBuff0:
!       LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LEAU    ,U              ; [4] Waste CPU cycles, two bytes
        LEAU    ,U++            ; [7] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LEAU    ,U              ; [4] Waste CPU cycles, two bytes     
        DECB                    ; [2] Dec counter, loop until we've played back 254 samples (almost half the buffer)
        BNE     <               ; [3] Loop if not zero
; done playing 166 samples
; Play 6 & Load 8 bytes
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        PSHS    #0              ; [5] Waste CPU cycles, two bytes
        PSHS    #0              ; [5] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

* done playing 172 samples, loaded 8 
        LDB     #42             ; [2] Play 42 x 8 = 336 samples, & Load 42 x 12 = 504 bytes into the buffer
        LEAU    ,U++            ; [7] Waste CPU cycles, two bytes
* Loop Plays 8 samples and loads 12 samples
!       LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDU     <$4A            ; [5] Get two samples in U
        LDX     <$4A            ; [5] Get two samples in X
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20

        PSHS    X,U             ; [9] Save the samples
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        PSHS    #0              ; [5] Waste CPU cycles, two bytes
        PSHS    #0              ; [5] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20
      
        LEAU    ,U              ; [4] Waste CPU cycles, two bytes
        DECB                    ; [2] Dec counter, loop until we've played back 254 samples (almost half the buffer)
        BNE     <               ; [3] Loop if not zero + 11 Cycles
* Done playing 508 Samples, loaded 512
* Done playing 508 Samples, loaded 512
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LDA     >$FF48          ; [5] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
        ASRA                    ; [2] Shift the BUSY bit to the carry
        BRN     *               ; [3] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     >$FF20          ; [5] Send byte to the DAC $FF20
* Done playing 510 Samples

        BCC     <SDCPlaylastblock1 ;[3] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
        NOP                     ; [2] Waste CPU cycles, one byte 
        LDB     <$00            ; [4] Get keyboard state
        LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        BITB    #$40            ; [2] Test row with the BREAK key
        BEQ     <SDCBreak       ; [3] Exit if BREAK is pressed
        LDA     1,Y             ; [5] Get a byte from buffer
        NOP                     ; [2] Waste CPU cycles, one byte 
        LDY     #SDCBuffer1+512 ; [4] Y = end of Buffer 1+1
        STA     <$20            ; [4] Send byte to the DAC $FF20
* Done playing 512 Samples
        NOP                     ; [2] Waste CPU cycles, one byte 
        LBRA    >PlayAudioBuff1 ; [5] big loop again +13 above

SDCBreak:
        LDB     #$D0            ; Send abort I/O command..
        STB     <$48            ; ..to the controller
        ASRB                    ; will use CMDABORT for the status result
        BRA     SDCAudioPlayDone

SDCPlaylastblock1:
        LDY     #SDCBuffer1+512 ; [4] Y = end of Buffer 1+1
SDCPlaylastblock0:
        CLRB                    ; [2] Play 256*2 = 512 bytes before getting more data from the SDC to give it time to fill its buffer
!       LDA     ,--Y            ; [7] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LEAU    ,U              ; [4] Waste CPU cycles, two bytes
        LEAU    ,U++            ; [7] Waste CPU cycles, two bytes
        LDA     1,Y             ; [5] Get a byte from buffer
        STA     <$20            ; [4] Send byte to the DAC $FF20

        LEAU    ,U              ; [4] Waste CPU cycles, two bytes    
        DECB                    ; [2] Dec counter, loop until we've played back 254 samples (almost half the buffer)
        BNE     <               ; [3] Loop if not zero
        
* Exit
SDCAudioPlayDone:
        CLR     <$40            ; put controller back in floppy mode
        ASLB                    ; save controller status in..
        STB     >$00F0          ; ..the DSKCON status variable

* Set the Printer port (RS232 serial) back to output
	LDA	$FF21
	PSHS	A
	ANDA	#%00110011              * FORCE BIT2 LOW
	STA	$FF21                   * $FF20 NOW DATA DIRECTION REGISTER
	LDA	#%11111110              * OUTPUT ON DAC, OUTPUT ON RS-232 & INPUT on CDI
	STA	$FF20
	PULS	A
	STA	$FF21

PlaySDCStack:
        LDS     #$FFFF          ; Restore the Stack pointer (self mod)
        PULS    CC,DP           ; Restore CC & DP
        BRA     AnalogMuxOff    ; DISABLE ANA MUX AND RETURN
