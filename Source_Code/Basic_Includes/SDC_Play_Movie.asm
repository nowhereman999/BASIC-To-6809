; Play Movie from the CoCoSDC
; *****************************************************
; To convert any movie to the proper format for the video converter 1st use ffmpeg:
; mkdir -p frames && \
; ffmpeg -i framecount_timecode_tone_plus_beep_bars.mp4 \
;  -map 0:v:0 \
;  -vf "fps=20,scale=256:144:force_original_aspect_ratio=decrease:flags=lanczos+accurate_rnd+full_chroma_int,pad=256:144:(ow-iw)/2:(oh-ih)/2:black,scale=128:144:flags=lanczos+accurate_rnd+full_chroma_int,setsar=1" \
;  -start_number 0 frames/frame%06d.png \
;  -map 0:a:0 -ac 1 -ar 11828 -c:a pcm_u8 -f u8 \
;  -af "aresample=11828:filter_size=256:cutoff=1.0" \
;  audio.u8
;
; 2nd step use the special MakeNTM program to convert the .png frames and audio.u8 into a format that this utility will play
;
; ./MakeNTM -d1 frames/frame%06d.png audio.u8 COCO3MOV.NTM
;
*****************************************************
      ALIGN $100                    ; Make the audio buffers start at an $00 value
SDCNTSAudioBuffer0      RMB   512*4 ; Make it 2048 max
SDCNTSAudioBuffer1      RMB   512*4 ; Make it 2048 max
NTMovPalette            RMB   512
SectorCount             FCB   $00
NTMovAudioDone          FCB   $00   ; Flag FIRQ is done playing this frame
NTMovDelay              EQU   777
; With audio buffer set at 2048
; 5 fps = 1000000/(AudioSample * 0.279365) = 1000000/(10240 * 0.279365) = 349.5650851  ok
; 6 fps = 1000000/(AudioSample * 0.279365) = 1000000/(12288 * 0.279365) = 291.3042376  ok
; 7 fps = 1000000/(AudioSample * 0.279365) = 1000000/(14336 * 0.279365) = 249.6893465  ok
; 8 fps = 1000000/(AudioSample * 0.279365) = 1000000/(16384 * 0.279365) = 218.4781782  Not ok, clicking
;
; With audio buffer set at 1024
; 8 fps = 1000000/(AudioSample * 0.279365) = 1000000/(8192 * 0.279365) = 436.9563564 ok
; 9 fps = 1000000/(AudioSample * 0.279365) = 1000000/(9216 * 0.279365) = 388.4056501 Not ok, clicking
;
; With audio buffer set at 512
; 9 fps = 1000000/(AudioSample * 0.279365) = 1000000/(4608 * 0.279365) = 776.8113002 ok
; 10 fps = 1000000/(AudioSample * 0.279365) = 1000000/(5120 * 0.279365) = 699.1301702 not ok, clicking

SDCPLAYMOVIE:
; Disable any high speed options
      JSR   Speed_Normal      ; Backup the speed the CoCo is currently set at and set it to Normal speed
* Lowercase m: which doesn't have a size length check
      CLRB                    ; B = 0 to set analog audio
      JSR   Select_AnalogMuxer ; SET UP DA TO PASS THROUGH ANA MUX
      JSR   AnalogMuxOn       ; ENABLE ANA MUX

      PSHS  CC,DP             ; Save the CC & the DP on the stack
      ORCC  #$50              ; Turn off the interrupts
      STS   MovieSDCStack+2   ; Save the Stack (Self mod)
      LDA   #$FF              ; Set the DP to $FF
      TFR   A,DP              ; Set the DP to $FF
;
; This code masks off the two low bits written to $FF20
; So you can send the PCM Unsigned 8 Bit sample as is, no masking needed
	LDA	<$21
	PSHS	A
	ANDA	#%00110011        ; FORCE BIT2 LOW
	STA	<$21            ; $FF20 NOW DATA DIRECTION REGISTER
	LDA	#%11111100        ; OUTPUT ON DAC, INPUT ON RS-232 & CDI
	STA	<$20
	PULS	A
	STA	<$21
; Put "m:" at the start of the filename
      LDX   #_StrVar_PF00+1   ; Get the start of the filename string
      LDB   -1,X              ; Get the length byte
      CLR   B,X               ; Ensure the filename ends with a zero
      ADDB  #02               ; Increment the length byte
      STB   -1,X              ; Set the length of the filename
      LEAY  2,X               ; Y = start of the filename
!     LDU   B,X
      STU   B,Y
      DECB
      BPL   <
      LDU   #'m'*$100+':'     ; U= "m:"
      STU   ,X
      JSR   OpenSDC_File_X_At_Start ; Open a file for streaming, at the beginning of the file

; At this point, we can begin reading the data bytes from the port as 16 bit data at $FF4A & $FF4B.
; We must always read 16 bit values at this point.
; The MCU will continue to feed data to the port until EOF is reached or an abort command is issued ($D0).
; The busy bit in status will remain set until that time.
; You will have to poll for the ready bit between 512 byte sectors, as the MCU has to fill a buffer.
; However, using 6809 style transfer, it is able to pretty much keep up with the CPU.
; There is also a small wait you need built into the polling routines in order to give the MCU
; time to reset/set the bit (20 microseconds or so is sufficient).

      STB   <$D9              ; Put CoCo 3 in double speed mode
; Make both screen buffers black (all zeros)
      LDB   #$35              ; start with the last Mem bank
      STB   SectorCount       ; Save the bank counter
      CLRA                    ; Colour all zeros (black)
      LDX   #$0000            ; Colour all zeros (black)
      LEAY  ,X                ; Y = X
      LEAU  ,X                ; U = X
@BankLoop:
      LDB   SectorCount
      STB   <$A6              ; Configure $C000
      CLRB
      LDS   #$E000
!     PSHS  D,X,Y,U           ; Fill the $2000 bytes with zeros
      CMPS  #$C000
      BNE   <                 ; loop until done
      DEC   SectorCount       ; Have we done all the screen banks?
      LDB   SectorCount
      CMPB  #$2F
      BNE   @BankLoop         ; Loop if not

MovieSDCStack:
      LDS   #$FFFF            ; Restore the Stack pointer (self mod)

; Load the first sector into audio buffer 0, so we can read the header info and figure out the correct playback method
; for this file
      LDX   #SDCNTSAudioBuffer0
!     LDD   <$4A              ; [5] 2 bytes
      STD   ,X++
      CMPX  #SDCNTSAudioBuffer0+512
      BNE   <
; Check if SDC is ready
      LEAS  -2,S              ; Temp stack placement, just in case it exits below
!     LDA   <$48              ; [4] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
      ASRA                    ; [2] Shift the BUSY bit to the carry
      LBCC  SDCMovieDone      ; [5] if not taken, [6] if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
      BEQ   <                 ; [3] If A = 0 then keep waiting
      LEAS  2,S               ; Fix the stack

; Important info from the header file
; Bytes
NTMovVersion      EQU   0                 ; word - Version # only supports version 1 so far
NTMovGMode        EQU   NTMovVersion+2    ; byte - graphics mode value
; Common values:
; %00011001 = 512x192x256 NTSC composite 
NTMovWidth        EQU   NTMovGMode+1      ; word - width
NTMovHeight       EQU   NTMovWidth+2      ; byte - height
NTMovFPS          EQU   NTMovHeight+1     ; byte - frame rate
NTMovVidSectors   EQU   NTMovFPS+1        ; byte - # of video sectors needed to load for each frame
NTMovMemStart     EQU   NTMovVidSectors+1 ; word - memory location where to start blasting video data on screen from (bottom of the picture)
NTMovPalMode      EQU   NTMovMemStart+2   ; byte - 0 = No Palette changing per frame, 1 = one extra sector will include palette info
NTMovInitPalette  EQU   NTMovPalMode+1    ; 16 bytes - bytes to load into the palette registers
; Audio info
NTMovSampleRate   EQU   NTMovInitPalette+16   ; word - audio sample rate
NTMovFIRQDelay    EQU   NTMovSampleRate+2 ; word - FIRQ delay value for audio playback
NTMovAudSectors   EQU   NTMovFIRQDelay+2  ; byte - # of audio sectors needed to load for each frame

      LDX   #SDCNTSAudioBuffer0
      LDD   NTMovVersion,X
      STD   $400
      LDA   NTMovGMode,X
      STA   $420
      LDD   NTMovWidth,X
      STD   $440
      LDA   NTMovHeight,X
      STA   $460
      LDA   NTMovFPS,X
      STA   $480
      LDA   NTMovVidSectors,X
      STA   $4A0
      LDD   NTMovMemStart,X
      STD   $4C0
      LDA   NTMovPalMode,X
      STA   $4E0
      LDD   NTMovSampleRate,X
      STD   $500
      LDD   NTMovFIRQDelay,X
      STD   $520
      LDA   NTMovAudSectors,X
      STA   $540

;      BRA   *

      LDA   NTMovGMode,X
      STA   NTMovGraphicMode+1            ; Set the graphics mode
; Handle Video sectors to be read
      LDA   NTMovVidSectors,X
      STA   NTMovSetVidSectors+1          ; Set the number of video sectors to be loaded per frame
; Handle where to load the video data
      LDD   NTMovMemStart,X
      STD   NTMovVidBlast+1               ; Save where to start stack blasting video byte into the buffer
; Setup the initial palette:
      LEAY  NTMovInitPalette,X
      LDU   #$FFB0                        ; U points at the palette register
      LDB   #15                           ; Load 16 colour values into the palette registers
!     LDA   B,Y
      STA   B,U
      DECB
      BPL   <                             ; Loop from 15 to 0
; Setup Audio playback:
      LDD   NTMovFIRQDelay,X              ; Get the FIRQ audio playback delay value
      STD   NTMovFIRQDelaySet+1           ; Set the FIRQ delay value
      LDA   NTMovAudSectors,X             ; Get the # of audio sectors needed to load for each frame
      STA   NTMovLoadAudioBuff+1          ; Save the number of audio sectors needed (1,2 or 4)
      LSLA                                ; A = A * 2, D = A * 512
      CLRB
      STA   NTMovCalcEndInitAudioBuff0+1  ; Get value to add so we know when the FIRQ reached the end of the buffer0
      STA   NTMovCalcEndAudioBuff0+1      ; Get value to add so we know when the FIRQ reached the end of the buffer0
      STA   NTMovCalcEndPalInitAudioBuff0+1 ; Get value to add so we know when the FIRQ reached the end of the Palette buffer0
      STA   NTMovCalcEndPalAudioBuff0+1   ; Get value to add so we know when the FIRQ reached the end of the Palette buffer0
      STA   NTMovCalcEndAudioBuff1+1      ; Get value to add so we know when the FIRQ reached the end of the buffer1
      STA   NTMovCalcEndPalAudioBuff1+1   ; Get value to add so we know when the FIRQ reached the end of the Palette buffer1
;
      LDU   #SDCNTSAudioBuffer0           ; U = Buffer 0 start
      LEAU  D,U                           ; Point at the end of audio buffer 0
      STU   NTMovEndInitAudBuf0+1         ; Set the location to start blasting into audio buffer 0 - init
      STU   NTMovEndAudBuf0+1             ; Set the location to start blasting into audio buffer 0
      STU   NTMovPalUpEndInitAudBuf0+1    ; Set the location to start blasting into audio buffer 0 - Palette updaing version - init
      STU   NTMovPalUpEndAudBuf0+1        ; Set the location to start blasting into audio buffer 0 - Palette updaing version
;
      LDU   #SDCNTSAudioBuffer1           ; U = Buffer 1 start
      LEAU  D,U                           ; Point at the end of audio buffer 1
      STU   NTMovEndAudBuf1+1             ; Set the location to start blasting into audio buffer 1
      STU   NTMovPalUpEndAudBuf1+1        ; Set the location to start blasting into audio buffer 1 - Palette updaing version

; Setup graphics mode
      LDA   #%01111100        ; CoCo 3 Mode, MMU Enabled, GIME IRQ Enabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext
      STA   <$90              ; Make the changes
      CLR   <$9F              ; Hor_Offset_Reg, Don't use a Horizontal offset
;
      LDA   #%10000000        ; Video_Mode_Register, Graphics mode, Colour output, 60 hz, max vertical res
      STA   <$98       
NTMovGraphicMode:
      LDA   #%00011001        ; Graphic mode requested = 512x192x256 NTSC composite 
      STA   <$99              ; Set the Vid_Res_Reg
;
; Prepare for BREAK key tests
      LDB   #$FB              ; strobe the keyboard column..
      STB   <$02              ; $FF02 ..which contains the BREAK key
;
; Setup Nt Movie FIRQ

;             Initialization Register 0 - INIT0 
;             ┌────────── Bit  7   - CoCo Bit (0 = CoCo 3 Mode, 1 = CoCo 1/2 Compatible)
;             │┌───────── Bit  6   - M/P (1 = MMU enabled, 0 = MMU disabled)
;             ││┌──────── Bit  5   - IEN (1 = GIME IRQ output enabled to CPU, 0 = disabled)
;             │││┌─────── Bit  4   - FEN (1 = GIME FIRQ output enabled to CPU, 0 = disabled)
;             ││││┌────── Bit  3   - MC3 (1 = Vector RAM at FEXX enabled, 0 = disabled)
;             │││││┌───── Bit  2   - MC2 (1 = Standard SCS (DISK) (0=expand 1=normal))
;             ││││││┌┬─── Bits 1-0 - MC1-0 (10 = ROM Map 32k Internal, 0x = 16K Internal/16K External, 11 = 32K External - Except Interrupt Vectors)
    LDA     #%01011100                          *
    STA     <$90       * CoCo 3 Mode, MMU Enabled, GIME IRQ Enabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext

    ;         Initialization Register 1 - INIT1
    ;         ┌────────── Bit  7   - Unused
    ;         │┌───────── Bit  6   - Memory type (1=256K, 0=64K chips)
    ;         ││┌──────── Bit  5   - Timer input clock source (1 = 0.279365 microseconds, 0 = 63.695 microseconds)
    ;         │││┌┬┬┬──── Bits 4-1 - Unused
    ;         │││││││┌─── Bits 0   - MMU Task Register select (0=enable $FFA0-$FFA7, 1=enable $FFA8-$FFAF)
    lda     #%00100000
    sta     <$91               ; Timer = 0.279365 microseconds; MMU $FFA0-$FFA7 task selected

;             Fast Interrupt Request Enable Register - FIRQENR
;             ┌┬───────── Bit  7-6 - Unused
;             ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
;             │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
;             ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
;             │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
;             ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
;             │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
    LDA     #%00100000                          *
    STA     <$93    * Enable TIMER FIRQ

; Backup the current FIRQ values
      LDD   <$94  ; $FF94-$FF95 TIMER MSB/LSB   I don't know if this is loadable
      STD   NTMovTimerRestore+1           ; Self mod save value
      LDA   FIRQ_Jump_position_FEF4       ; Get JMP instruction for the FIRQ
      STA   NTMovFIRQRestore+1            ; Self mod save value
      LDD   FIRQ_Jump_position_FEF4+1     ; Get FIRQ Jump address
      STD   NTMovFIRQRestoreB+1           ; Self mod save value

; Set the speed of the FIRQ Timer:
NTMovFIRQDelaySet:
      LDD   #NTMovDelay                   ; Audio sample delay value
      STD   <$94                          ; $FF94-$FF95 TIMER MSB/LSB

; Backup the current FIRQ values
      LDA   #$7E                          ; Write the JMP instruction if it's possible to use Direct Page for the sample playback then use $0E = direct page JMP location, and 1 byte for address
; Setup the jump to the FIRQ
      STA   FIRQ_Jump_position_FEF4       ; Write JMP instruction for the FIRQ
      LDU   #NTMovieFIRQ                  ; Address for FIRQ
      STU   FIRQ_Jump_position_FEF4+1     ; Update the FIRQ Jump address

      LDA   NTMovPalMode,X
      LBNE  PaletteChangingPlayback       ; Playback mode will change the palette each frame

; No palette changing:
; Setup Even frame (frame 0)
; Audio buffer 0 prep
; Load audio buffer 0
      LDD   #SDCNTSAudioBuffer0           ; Point the audio player start at Audio Buffer 0
      STD   NTMovGetSample+1              ; Set the value
NTMovCalcEndInitAudioBuff0:
      ADDA  #$FF                          ; Self mod the number of 256 byte blocks the audio buffer is
      STA   NTMovAudioCMP+1               ; Save value for FIRQ to test for to see if it's reached the end of the buffer
      CLR   NTMovAudioDone                ; Clear it so it's ready for next audio wait for audio to complete loop
;      
NTMovEndInitAudBuf0:
      LDU   #$FFFF                        ; Point at the end of the audio buffer (self mod)
      JSR   NTMovLoadAudioBuff
; load video buffer 0
      LDD   #$3031                        ; [3] Banks 0 & 1 & 2
      JSR   NTMovLoadVideoBuff            ; Set memory banks and load a frame
; turn on audio
      ANDCC #%00111111                    ; Start the FIRQ
      BRA   NTMovEnterHere

; Loop Start
NTMovMainLoop:
; Set audio playback to the start of audio buffer 0
      LDD   #SDCNTSAudioBuffer0     ; Point the audio player start at Audio Buffer 0
      STD   NTMovGetSample+1        ; Set the value
NTMovCalcEndAudioBuff0:
      ADDA  #$FF                    ; Self mod the number of 256 byte blocks the audio buffer is
      STA   NTMovAudioCMP+1         ; Save value for FIRQ to test for to see if it's reached the end of the buffer
      CLR   NTMovAudioDone          ; Clear it so it's ready for next audio wait for audio to complete loop
; Check for BREAK key pressed
      LDB   <$00                    ; [5] Use slower version here to make sure CoCoSDC buffer is loaded, get keyboard state
      BITB  #$40                    ; [2] Test row with the BREAK key
      LBEQ  SDCBreakPressed         ; [5 or 6] Exit if BREAK is pressed
;
NTMovEnterHere:
; Show Video buffer 0
      TST   <$02                    ; [6] Tickle the vsync Interrupt
!     TST   <$03                    ; [6] Check for vsync Interrupt
      BPL   <                       ; [3] If not yet then keep looping
      LDD   #$30*4*$100+00          ; [3] Bank $30 is the start of video Display, Clear B
      STD   <$9D                    ; [5] Update the VidStart pointer
; load audio buffer 1
NTMovEndAudBuf1:
      LDU   #$FFFF                  ; Point at the end of the audio buffer (self mod)
      JSR   NTMovLoadAudioBuff
; load video buffer 1
      LDD   #$3334                  ; [3] Banks 3 & 4 & 5
      JSR   NTMovLoadVideoBuff      ; Set memory banks and load a frame
; Loop audio buffer 0 until end of buffer reached
!     LDA   NTMovAudioDone          ; Get Value (FIRQ will clear it when it reaches the end of the buffer)
      BEQ   <                       ; Loop until we get the clear signal
; Set audio playback to the start of audio buffer 1
      LDD   #SDCNTSAudioBuffer1     ; Point the audio player start at Audio Buffer 1
      STD   NTMovGetSample+1        ; Set the value
NTMovCalcEndAudioBuff1:
      ADDA  #$FF                    ; Self mod the number of 256 byte blocks the audio buffer is
      STA   NTMovAudioCMP+1         ; Save value for FIRQ to test for to see if it's reached the end of the buffer
      CLR   NTMovAudioDone          ; Clear it so it's ready for next audio wait for audio to complete loop
; Check for BREAK key pressed
      LDB   <$00                    ; [5] Use slower version here to make sure CoCoSDC buffer is loaded, get keyboard state
      BITB  #$40                    ; [2] Test row with the BREAK key
      LBEQ  SDCBreakPressed         ; [5 or 6] Exit if BREAK is pressed
;
; show video buffer 1
      TST   <$02                    ; [6] Tickle the vsync Interrupt
!     TST   <$03                    ; [6] Check for vsync Interrupt
      BPL   <                       ; [3] If not yet then keep looping
      LDD   #$33*4*$100             ; [3] Bank $33 is the start of video Display, Clear B
      STD   <$9D                    ; [5] Update the VidStart pointer
; load audio buffer 0
NTMovEndAudBuf0:
      LDU   #$FFFF                  ; Point at the end of the audio buffer (self mod)
      JSR   NTMovLoadAudioBuff
; load video buffer 0
      LDD   #$3031                  ; [3] Banks 0 & 1 & 2
      JSR   NTMovLoadVideoBuff      ; Set memory banks and load a frame
; Loop audio buffer 1 until end of buffer reached
!     LDA   NTMovAudioDone          ; Get Value (FIRQ will clear it when it reaches the end of the buffer)
      BEQ   <                       ; Loop until we get the clear signal
      BRA   NTMovMainLoop
; Loop end








; Palette changing every frame:
; Each Sector will hold 512 / 16 = 32 frames of palette info
;
PaletteChangingPlayback:
; Load the palette buffer:
      JSR   NTMovLoadPaletteBuff    ; Load the palette buffer, reset pointer to the start of the buffer
; Setup Even frame (frame 0)
; Audio buffer 0 prep
; Load audio buffer 0
      LDD   #SDCNTSAudioBuffer0     ; Point the audio player start at Audio Buffer 0
      STD   NTMovGetSample+1        ; Set the value
NTMovCalcEndPalInitAudioBuff0:
      ADDA  #$FF                    ; Self mod the number of 256 byte blocks the audio buffer is
      STA   NTMovAudioCMP+1         ; Save value for FIRQ to test for to see if it's reached the end of the buffer
      CLR   NTMovAudioDone          ; Clear it so it's ready for next audio wait for audio to complete loop
;      
NTMovPalUpEndInitAudBuf0:
      LDU   #$FFFF                   Point at the end of the audio buffer (self mod)
      JSR   NTMovLoadAudioBuff
; load video buffer 0
      LDD   #$3031                  ; [3] Banks 0 & 1 & 2
      JSR   NTMovLoadVideoBuff      ; Set memory banks and load a frame
; turn on audio
      ANDCC #%00111111              ; Start the FIRQ
      BRA   NTMovEnterHerePalChang

; Loop Start
NTMovMainLoopPalChang:
; Set audio playback to the start of audio buffer 0
      LDD   #SDCNTSAudioBuffer0     ; Point the audio player start at Audio Buffer 0
      STD   NTMovGetSample+1        ; Set the value
NTMovCalcEndPalAudioBuff0:
      ADDA  #$FF                    ; Self mod the number of 256 byte blocks the audio buffer is
      STA   NTMovAudioCMP+1         ; Save value for FIRQ to test for to see if it's reached the end of the buffer
      CLR   NTMovAudioDone          ; Clear it so it's ready for next audio wait for audio to complete loop
; Check for BREAK key pressed
      LDB   <$00                    ; [5] Use slower version here to make sure CoCoSDC buffer is loaded, get keyboard state
      BITB  #$40                    ; [2] Test row with the BREAK key
      LBEQ  SDCBreakPressed         ; [5 or 6] Exit if BREAK is pressed
;
NTMovEnterHerePalChang:
; Show Video buffer 0
      TST   <$02                    ; [6] Tickle the vsync Interrupt
!     TST   <$03                    ; [6] Check for vsync Interrupt
      BPL   <                       ; [3] If not yet then keep looping
;
; Update the palette
      LDU   NTMovPalettePointer+1   ; U points at the Palette value for this frame
      PULU  D,X,Y
      STD   <$B0
      STX   <$B2
      STY   <$B4
      PULU  D,X,Y
      STD   <$B6
      STX   <$B8
      STY   <$BA
      PULU  D,X
      STD   <$BC
      STX   <$BE
      STU   NTMovPalettePointer+1   ; Save updated pointer for next frame
;
      LDD   #$30*4*$100+00          ; [3] Bank $30 is the start of video Display, Clear B
      STD   <$9D                    ; [5] Update the VidStart pointer

; load audio buffer 1
NTMovPalUpEndAudBuf1:
      LDU   #$FFFF                  ; Point at the end of the audio buffer (self mod)
      BSR   NTMovLoadAudioBuff
; load video buffer 1
      LDD   #$3334                  ; [3] Banks 3 & 4 & 5
      BSR   NTMovLoadVideoBuff      ; Set memory banks and load a frame
; Loop audio buffer 0 until end of buffer reached
!     LDA   NTMovAudioDone          ; Get Value (FIRQ will clear it when it reaches the end of the buffer)
      BEQ   <                       ; Loop until we get the clear signal
; Set audio playback to the start of audio buffer 1
      LDD   #SDCNTSAudioBuffer1     ; Point the audio player start at Audio Buffer 1
      STD   NTMovGetSample+1        ; Set the value
NTMovCalcEndPalAudioBuff1:
      ADDA  #$FF                    ; Self mod the number of 256 byte blocks the audio buffer is
      STA   NTMovAudioCMP+1         ; Save value for FIRQ to test for to see if it's reached the end of the buffer
      CLR   NTMovAudioDone          ; Clear it so it's ready for next audio wait for audio to complete loop
; Check for BREAK key pressed
      LDB   <$00                    ; [5] Use slower version here to make sure CoCoSDC buffer is loaded, get keyboard state
      BITB  #$40                    ; [2] Test row with the BREAK key
      LBEQ  SDCBreakPressed         ; [5 or 6] Exit if BREAK is pressed
;
; show video buffer 1
      TST   <$02                    ; [6] Tickle the vsync Interrupt
!     TST   <$03                    ; [6] Check for vsync Interrupt
      BPL   <                       ; [3] If not yet then keep looping
;
; Update the palette
NTMovPalettePointer:
      LDU   #$FFFF                  ; U points at the Palette value for this frame (self modded)
      PULU  D,X,Y
      STD   <$B0
      STX   <$B2
      STY   <$B4
      PULU  D,X,Y
      STD   <$B6
      STX   <$B8
      STY   <$BA
      PULU  D,X
      STD   <$BC
      STX   <$BE
      STU   NTMovPalettePointer+1   ; Save updated pointer for next frame
;
      LDD   #$33*4*$100             ; [3] Bank $33 is the start of video Display, Clear B
      STD   <$9D                    ; [5] Update the VidStart pointer
; Reload palette if we need to
      CMPU  #NTMovPalette+512
      LBNE  NTMovPalUpEndAudBuf0    ; Skip ahead if not at the end of the palette buffer
      BSR   NTMovLoadPaletteBuff    ; Load the palette buffer, reset pointer to the start of the buffer

; load audio buffer 0
NTMovPalUpEndAudBuf0:
      LDU   #$FFFF                  ; Point at the end of the audio buffer (self mod)
      BSR   NTMovLoadAudioBuff
; load video buffer 0
      LDD   #$3031                  ; [3] Banks 0 & 1 & 2
      BSR   NTMovLoadVideoBuff      ; Set memory banks and load a frame
; Loop audio buffer 1 until end of buffer reached
!     LDA   NTMovAudioDone          ; Get Value (FIRQ will clear it when it reaches the end of the buffer)
      BEQ   <                       ; Loop until we get the clear signal
      JMP   NTMovMainLoopPalChang
; Loop end

; Load the palette buffer, reset pointer to the start of the buffer
NTMovLoadPaletteBuff:
      LDU   #NTMovPalette+512
      LDD   #NTMovPalette           ; Get the Palette start value
      STD   NTMovPalettePointer+1   ; Save the pointer
      LDA   #1
      BRA   MovBlastSectorU         ; Stack blast to fill #A of 512 Bytes sectors to software Stack location ,U then return

; Load the audio, U points a the end of the buffer
NTMovLoadAudioBuff:
      LDA   #$FF                    ; [2] # of Audio sectors (Self mod)
      BRA   MovBlastSectorU         ; Stack blast to fill #A of 512 Bytes sectors to software Stack location ,U then return

; Load the video buffer
NTMovLoadVideoBuff:
      STD   <$A4                    ; [5] Configure $8000 & $A000
      INCB                          ; [2] Bank 2
      STB   <$A6                    ; [4] Configure $C000
NTMovVidBlast:
      LDU   #$8000+128*167          ; Start drawing the image at row 167 fills bottom up
NTMovSetVidSectors:
      LDA   #36                     ; [2] 36 sectors of 512 bytes each to be read, 512 * 36 = 18,432 bytes per frame
;
; Stack blast to fill #A of 512 Bytes sectors to software Stack location ,U
MovBlastSectorU:
; 12 * 6 bytes so far = 72
; Do it 7 times to get us to 504 bytes
      STA   SectorCount       ; [5] save thesector counter
@SectorLoop:
      LDA   #7                ; [2] 7 loops of (12 * 6 bytes) is 504
      STA   <$42              ; [3] Use for loop counter (Special CoCoSDC byte that can be used as RAM)
!     LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
; 64 bytes from file saved at ,S
      DEC   <$42              ; [6] Decrement the counter (Special CoCoSDC byte that can be used as RAM)
      BNE   <                 ; [3] Keep looping
; We've read 504 bytes so far let's get the last 8
      LDD   <$4A              ; [5] 2 bytes
      LDX   <$4A              ; [6] 4 bytes
      NOP                     ; [2] tiny delay
      LDY   <$4A              ; [5] 6 bytes
      PSHU  D,X,Y             ; [11] save 6 bytes on U stack
      LDD   <$4A              ; [5] 2 bytes
      PSHU  D                 ; [7] save 2 bytes on U stack
; Finished reading 512 bytes
; 20 microseconds is 1,789,772.5 * 0.000020 is almost 36 cycles
; Check if SDC is ready
!     LDA   <$48              ; [4] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
      ASRA                    ; [2] Shift the BUSY bit to the carry
      LBCC  SDCMovieDone      ; [5] if not taken, [6] if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
      BEQ   <                 ; [3] If A = 0 then keep waiting
;
      DEC   SectorCount       ; [7] Decrement the number of 512 byte sectors to load
      LBNE   @SectorLoop      ; [3] Keep looping until we've blasted them all into buffer ,U
      RTS                     ; [5] Return

; FIRQ for playing movie audio
NTMovieFIRQ:
      STA   @FIRQ0Restore+1   ; Save exit value of A
      LDA   <$93              ; Re enable the FIRQ - $FF93
NTMovGetSample:
      LDA   >$FFFF
@SendAudio:
      STA   <$20              ; Send audio to the DAC
      INC   NTMovGetSample+2  ; LSB = LSB + 1
      BNE   @FIRQ0Restore     ; IF we didn't hit zero skip ahead
      INC   NTMovGetSample+1  ; MSB = MSB + 1
      LDA   NTMovGetSample+1
NTMovAudioCMP:
      CMPA  #$FF              ; CMPA value will be self modified
      BNE   @FIRQ0Restore     ; 8 * 256 = 2048, If not 8 then we're not at the end skip ahead
      DEC   NTMovAudioDone    ; signify we are done playing this buffer
@FIRQ0Restore:
      LDA   #$FF              ; Self modified from above upon FIRQ entry
      RTI                     ; Return from the FIRQ

; BREAK Key Pressed
SDCBreakPressed:
      STB   <$D8              ; Set to Normal speed
      LDB   #$D0              ; Send abort I/O command..
      STB   <$48              ; ..to the controller
      LEAS  -2,S              ; Stack will get changed below
;
; Exit
SDCMovieDone:
      ORCC  #$50
      LEAS  2,S               ; Fix stack as it gets here only while reading bytes from the CoCoSDC and jumps out of the subroutine
      CLR   <$40              ; put SDC controller back in floppy mode
      LDD   #$3C3D            ; Put memory back to normal
      STD   <$A4
      INCB
      STB   <$A6
      STB   <$D8              ; Set to Normal speed

* Set the Printer port (RS232 serial) back to output
	LDA	<$21
	PSHS	A
	ANDA	#%00110011        ; FORCE BIT2 LOW
	STA	<$21              ; $FF20 NOW DATA DIRECTION REGISTER
	LDA	#%11111110        ; OUTPUT ON DAC, OUTPUT ON RS-232 & INPUT on CDI
	STA	<$20
	PULS	A
	STA	<$21
;

;             Initialization Register 0 - INIT0 
;             ┌────────── Bit  7   - CoCo Bit (0 = CoCo 3 Mode, 1 = CoCo 1/2 Compatible)
;             │┌───────── Bit  6   - M/P (1 = MMU enabled, 0 = MMU disabled)
;             ││┌──────── Bit  5   - IEN (1 = GIME IRQ output enabled to CPU, 0 = disabled)
;             │││┌─────── Bit  4   - FEN (1 = GIME FIRQ output enabled to CPU, 0 = disabled)
;             ││││┌────── Bit  3   - MC3 (1 = Vector RAM at FEXX enabled, 0 = disabled)
;             │││││┌───── Bit  2   - MC2 (1 = Standard SCS (DISK) (0=expand 1=normal))
;             ││││││┌┬─── Bits 1-0 - MC1-0 (10 = ROM Map 32k Internal, 0x = 16K Internal/16K External, 11 = 32K External - Except Interrupt Vectors)
    LDA     #%01001100                          *
    STA     <$90       * CoCo 3 Mode, MMU Enabled, GIME IRQ Enabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext

;             Fast Interrupt Request Enable Register - FIRQENR
;             ┌┬───────── Bit  7-6 - Unused
;             ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
;             │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
;             ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
;             │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
;             ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
;             │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
    LDA     #%00000000                          *
    STA     <$93    * Disable TIMER FIRQ

; Restore FIRQ settings:
NTMovTimerRestore:
      LDD   #$FFFF      ; Self mod value from above
      STD   <$94        ; $FF94-$FF95 TIMER MSB/LSB
NTMovFIRQRestore:
      LDA   #$FF        ; Self mod value from above
      STA   FIRQ_Jump_position_FEF4       ; Write JMP instruction for the FIRQ
NTMovFIRQRestoreB:
      LDD   #$FFFF      ; Self mod value from above
      STD   FIRQ_Jump_position_FEF4+1     ; Update the FIRQ Jump address
;
      PULS  CC,DP             ; Restore CC & DP
;
; To reset the CoCoSDC (put it in firmware upgrade mode then back to normal)
      LDA   #$1C              ; Send command $1C
      LDB   #$AA              ; First parameter $AA
      LDX   #$5500            ; Second parameter to $55
      JSR   CommSDC           ; Send to the CoCoSDC
;
!     LDA   >$FF48            ; [4] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
      ASRA                    ; [2] Shift the BUSY bit to the carry
      BCC   >                 ; [3] Done if BUSY bit is cleared
      BEQ   <                 ; [3] If A = 0 then keep waiting
;  A read of param registers 1 and 2 should return 'PM'
!     LDD   >$FF49            ; $FF49 param register 1, $FF4A param register 2
* D should now = "PM" you can do a test here if you want to make sure the controller is in the Program Mode
      LDA   #'G'              ; Write "G" to exit program mode and do a soft reset of the controller
      JSR   CommSDC           ; Send to the CoCoSDC

      JSR   Speed_Restore     ; Restore the CPU Speed back to what the user set
      JMP   AnalogMuxOff      ; DISABLE ANA MUX AND RETURN
