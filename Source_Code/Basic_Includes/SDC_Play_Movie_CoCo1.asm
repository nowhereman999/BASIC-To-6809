; Play Movie from the CoCoSDC - Glen Hewlett
; *****************************************************
; To convert any movie to the proper format for this video player use similar to this:
; ./MakeNTM106 -i=MovieName.mkv -name="Full Movie Name here (2026)" -o=MOVIE.NTM -g136 -s=.75 -f9 -a2 -p1 -c0
*****************************************************
;
;
; CoCo 1 RAM layout used by this player:
;   $0E00-$25FF  screen buffer 0
;   $2600-$3DFF  screen buffer 1
;   NTMovCacheEndframe-NTMovCacheEnd  32 byte runtime header cache
;   NTMovAudioBuffer-NTMovAudioBufferEnd  1K local audio/header buffer
;
NTMovCurFrameCount      EQU   Temp2                         ; 3 byte's to keep track of the currently played frame
;
; CoCo 1 audio timing:
; Each GMODE 16 frame buffer uses 14 sectors:
;   2 sectors = 1024 unsigned 8-bit DAC samples
;   12 sectors = 6144 bytes of stack-blasted GMODE 16 video
; Audio timing comes from playing the 1024 byte audio buffer at fixed
; points while loading the 6144 byte hidden video buffer.

SDCPLAYMOVIE:
; Disable any high speed options
      JSR   Speed_Normal      ; Backup the speed the CoCo is currently set at and set it to Normal speed

      PSHS  CC,DP             ; Save the CC & the DP on the stack
      ORCC  #$50              ; Turn off the interrupts
      LDA   #$FF              ; Set the DP to $FF
      TFR   A,DP              ; Set the DP to $FF
      JSR   NTMovSelectDACMux ; Force CoCo 1 audio mux to the internal DAC
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
; Lowercase m: which doesn't have a size length check
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

; For the CoCo 256x192x2 GMODE 16 screen size is 6144 bytes
; it will require 12 (512 byte) sectors

; Coco 1 will be setup so that:
; page 0 is at $E00 to $25FF
; page 1 is at $2600 to $3DFF

; Make both screen buffers black (all zeros)
      LDD   #$0000            ; Colour all zeros (black)
      TFR   D,X               ; X = D
      LEAY  ,X                ; Y = X
@BankLoop:
      LDU   #$3E00
!     PSHU  D,X,Y             ; Fill the two buffers with zeros
      CMPU  #$E00
      BNE   <

MovieSDCStack:
; Load the first sector so we can read the header info and start playback
; from the first audio-buffer frame sector.
!     LDA   <$48              ; Poll status byte for the next 512 byte sector
      ASRA                    ; Shift the BUSY bit to the carry
      LBCC  SDCMovieDone      ; Done if BUSY bit is cleared
      BEQ   <                 ; If A = 0 then keep waiting
      LDX   #NTMovAudioBuffer ; Temporarily load the full 512-byte header into the audio buffer
!     LDD   <$4A              ; [5] 2 bytes
      STD   ,X++
      CMPX  #NTMovAudioBuffer+512 ; Is it at the end yet?
      BNE   <
; Cache only the header bytes needed later by the player.  The audio buffer
; is reused for audio sectors as soon as frame loading starts.
      LDX   #NTMovAudioBuffer+NTMovEndframe
      LDY   #NTMovCacheEndframe
      LDB   #4
@CopyHeaderEndframeCache:
      LDA   ,X+
      STA   ,Y+
      DECB
      BNE   @CopyHeaderEndframeCache
      LDX   #NTMovAudioBuffer+NTMovFPS
      LDA   ,X
      STA   >NTMovCacheFPS
      LDX   #NTMovAudioBuffer+NTMovPercentLBN
      LDY   #NTMovCachePercentLBN
      LDB   #27
@CopyHeaderPercentCache:
      LDA   ,X+
      STA   ,Y+
      DECB
      BNE   @CopyHeaderPercentCache
; Check if SDC is ready for the first frame sector.
      LEAS  -2,S              ; Temp stack placement, just in case it exits below
!     LDA   <$48              ; Poll status byte for the next 512 byte sector
      ASRA                    ; Shift the BUSY bit to the carry
      LBCC  SDCMovieDone      ; Done if BUSY bit is cleared
      BEQ   <                 ; If A = 0 then keep waiting
      LEAS  2,S               ; Fix the stack

      LDA	#2		      ; Enable only keyboard interrupt
	STA	<$92

; Important info from the file header
; Bytes
NTMovVersion      EQU   0                 ; word - Version # only supports version 1 so far
NTMovGMode        EQU   NTMovVersion+2    ; byte - graphics mode value
NTMovEndframe     EQU   NTMovGMode+1      ; 32 bit value - Number of frames in this movie
NTMovWidth        EQU   NTMovEndframe+4   ; word - width
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
NTMovJumpSectorRateNum  EQU   NTMovAudSectors+1 ; word - to calc where to jump to for playback
NTMovPercentLBN   EQU   NTMovJumpSectorRateNum+2 ; 9 * 3 = 27 bytes the LBN value to jump to when a number is pressed

      LDD   #$0000                        ; Starting sector
      STA   >NTMovCurFrameCount
      STD   >NTMovCurFrameCount+1

; Setup graphics mode
; CoCo 1 will already be setup to display GMODE 16 page 0
; So we can load buffer page 1 first then keep flipping
   
; Continue from here after a jump in playback
NTMovContinueMovie:
      CLR   <$02                          ; $FF02 clear keyboard check
; page 0 is at $E00 to $25FF
; page 1 is at $2600 to $3DFF

!     LDA   <$48              ; Poll status byte for the next 512 byte sector
      ASRA                    ; Shift the BUSY bit to the carry
      LBCC  SDCMovieDone      ; Done if BUSY bit is cleared
      BEQ   <                 ; If A = 0 then keep waiting
      BRA   NTMovEnterHere

; Loop Start
NTMovMainLoop:
; Quick keyboard-any-key probe, CoCo 1/2/3 compatible
; DP = $FF
      LDA   #$00
      STA   <$02          ; select all keyboard columns
      LDA   <$00          ; read keyboard rows
      COMA                ; pressed keys become 1 bits
      ANDA  #%01111111    ; ignore joystick comparator / high bit if desired
      BEQ   >             ; no key pressed
      JSR   NTMovSomeKeyPressed
!
; Show Video buffer 0
      JSR   NTMovWaitVsyncShowBuffer0     ; 8
; 13 cycles since the last sample was played

NTMovEnterHere:
; load video buffer 1
      LDU   #$3E00                  ; 3 Point at the end of buffer 1
      JSR   NTMovLoadVideoBuff      ; 8 load a frame, U points at the end of the buffer

      BRN   *                       ; 3 Waste CPU cycles, two bytes
; Quick keyboard-any-key probe, CoCo 1/2/3 compatible
; DP = $FF
      LDA   #$00
      STA   <$02          ; select all keyboard columns
      LDA   <$00          ; read keyboard rows
      COMA                ; pressed keys become 1 bits
      ANDA  #%01111111    ; ignore joystick comparator / high bit if desired
      BEQ   >             ; no key pressed
      JSR   NTMovSomeKeyPressed
!
; show video buffer 1
      JSR   NTMovWaitVsyncShowBuffer1     ; 8
; load video buffer 0
      LDU   #$2600                        ; 3 Point at the end of buffer 0
      JSR   NTMovLoadVideoBuff            ; 8 load a frame, U points at the end of the buffer
      BRA   NTMovMainLoop                 ; 3
; Loop end

; Wait for VSYNC while consuming the last bytes of audio
NTMovWaitVsyncShowBuffer0:
      TST   <$02                          ; 6 Tickle the vsync interrupt
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
@Wait0:
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      NOP                                 ; 2 Waste CPU cycles, one byte
      TST   <$03                          ; 6 Check for vsync interrupt
      BPL   @NoVSYNC_Yet                  ; 3
      STA   <$C7                          ; 4 F0 set
      STA   <$C9                          ; 4 F1 set
      STA   <$CB                          ; 4 F2 set
      STA   <$CC                          ; 4 F3 clear
      STA   <$CE                          ; 4 F4 clear
      STA   <$D0                          ; 4 F5 clear
      STA   <$D2                          ; 4 F6 clear
@CheckY:
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4
      CMPY  #NTMovAudioBuffer+1           ; 5
      BNE   @Wait0                        ; 3
      RTS                                 ; 5
@NoVSYNC_Yet:
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
      NOP                                 ; 2 Waste CPU cycles, one byte
      BRA   @CheckY                       ; 3

NTMovWaitVsyncShowBuffer1:
      TST   <$02                          ; 6 Tickle the vsync interrupt
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
@Wait0:
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      NOP                                 ; 2 Waste CPU cycles, one byte
      TST   <$03                          ; 6 Check for vsync interrupt
      BPL   @NoVSYNC_Yet                  ; 3
      STA   <$C7                          ; 4 F0 set
      STA   <$C9                          ; 4 F1 set
      STA   <$CA                          ; 4 F2 clear
      STA   <$CC                          ; 4 F3 clear
      STA   <$CF                          ; 4 F4 set
      STA   <$D0                          ; 4 F5 clear
      STA   <$D2                          ; 4 F6 clear
@CheckY:
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4
      CMPY  #NTMovAudioBuffer+1           ; 5
      BNE   @Wait0                        ; 3
      RTS                                 ; 5
@NoVSYNC_Yet:
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
      NOP                                 ; 2 Waste CPU cycles, one byte
      BRA   @CheckY                       ; 3

; Load the video buffer
; U points 1 byte past the end of the buffer to fill
; 23 cycles on main loop before getting here
NTMovLoadVideoBuff:
      STS   NTMovRestoreStackCoCo1+2      ; 7 use S as the stack-blast pointer
      STU   NTMoveNewSetValueOfS+2        ; 6 hidden video buffer end
      LDS   #NTMovAudioBufferEnd          ; 4 fill audio buffer
      LDA   #12                           ; 2, 12 video sectors
      STA   NTMovNewFrameSectorCount      ; 5

@NewPollSector:
      LDA   <$48                          ; 4 Poll CoCoSDC status
      ASRA                                ; 2 Shift BUSY bit to carry
      LBCC  NTMovStreamDoneCoCo1          ; 5 not taken, 6 taken
      BEQ   @NewPollSector                ; 3 not ready, keep polling
; First audio word is stored normally (not in a stack blasted format)
      LDD   <$4A                          ; 5
      NOP                                 ; 2 Waste CPU cycles
      STA   <$20                          ; 4 DAC sample 1
      LDY   #NTMovAudioBufferEnd+1        ; 4 first audio sector fills the local audio buffer
      STB   -1,Y                          ; 5
;
      LDD   >NTMovCurFrameCount+1         ; 6
      ADDD  #$0001                        ; 7
      STD   >NTMovCurFrameCount+1         ; 6
      BEQ   >                             ; 3
      LEAU  ,U                            ; 4 Waste CPU cycles, two bytes
      BRA   @FrameIncDone                 ; 3
!     INC   >NTMovCurFrameCount           ; 7
@FrameIncDone:
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
      NOP                                 ; 2 Waste CPU cycles, one byte
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4 DAC sample 1
;
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      PSHS  #0                            ; 5 Waste CPU cycles, two bytes
;
; Enter with 29 cycles used
@AudioLoop:
      LDA   #42                           ; 2
      STA   <$42                          ; 4
@NewSectorBlockLoop:
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 6 bytes
      LDA   ,-Y                           ; 6
      NOP                                 ; 2
      STA   <$20                          ; 4 DAC sample 1
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 12 bytes
      DEC   <$42                          ; 6
      BNE   @NewSectorBlockLoop

; After 2 + 42 * 12 = 506 bytes read, we need another 6
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 6 bytes
; Done the first audio sector
      NOP                                 ; 2 Waste CPU cycles, one byte
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4 DAC sample 1
; Delay
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
; Play Sample
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4 DAC sample 1
; Delay
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      TFR   A,A                           ; 6 Waste CPU cycles, two bytes
; Loop
@NewPollSector:
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
      NOP                                 ; 2 Waste CPU cycles, one byte
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4 DAC sample 1
;
      LDA   <$48                          ; 4 Poll CoCoSDC status
      ASRA                                ; 2 Shift BUSY bit to carry
      LBCC  NTMovStreamDoneCoCo1          ; 5 not taken, 6 taken
      BEQ   @NewPollSector                ; 3 not ready, keep polling
; Delay
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes

; Ready to read the 2nd audio sector
; Enter with 29 cycles used
      LDA   #42                           ; 2
      STA   <$42                          ; 4
@NewSectorBlockLoop:
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 6 bytes
      LDA   ,-Y                           ; 6
      NOP                                 ; 2
      STA   <$20                          ; 4 DAC sample 1
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 12 bytes
      DEC   <$42                          ; 6
      BNE   @NewSectorBlockLoop

; After 42 * 12 = 504 bytes read, we need another 8
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 6 bytes
      NOP                                 ; 2
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4 DAC sample 1
      LDD   <$4A                          ; 5
      PSHS  D                             ; 7, final 2 bytes
      NOP                                 ; 2

@NewPollSector:
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
      NOP                                 ; 2 Waste CPU cycles, one byte
      LDA ,-Y                             ; 6
      STA <$20                            ; 4 DAC sample 1
      LDA   <$48                          ; 4 Poll CoCoSDC status
      ASRA                                ; 2 Shift BUSY bit to carry
      LBCC  NTMovStreamDoneCoCo1 ; 5 not taken, 6 taken
      BEQ   @NewPollSector ; 3 not ready, keep polling

      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      BRN   *                             ; 3 Waste CPU cycles, two bytes

; Load the video buffer
; Enter with 25 cycles used			
NTMoveNewSetValueOfS:
      LDS   #$FFFF                        ; 4 self-modified hidden video buffer end
NTMovVideoLoop:
      LDA   #42                           ; 2
      STA   <$42                          ; 4
@NewSectorBlockLoop:
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 6 bytes
      LDA   ,-Y                           ; 6
      NOP
      STA   <$20                          ; 4 DAC sample 1
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 12 bytes
      DEC   <$42                          ; 6
      BNE   @NewSectorBlockLoop

; After 42 * 12 = 504 bytes read, we need another 8
      LDD   <$4A                          ; 5
      LDX   <$4A                          ; 5
      LDU   <$4A                          ; 5
      PSHS  D,X,U                         ; 11, 6 bytes
      NOP                                 ; 2
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4 DAC sample 1
      LDD   <$4A                          ; 5
      PSHS  D                             ; 7, final 2 bytes
      NOP                                 ; 2
;
@NewPollSector:
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
      NOP                                 ; 2 Waste CPU cycles, one byte
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4 DAC sample 1
;
      LDA   <$48                          ; 4 Poll CoCoSDC status
      ASRA                                ; 2 Shift BUSY bit to carry
      LBCC  NTMovStreamDoneCoCo1          ; 5 not taken, 6 taken
      BEQ   @NewPollSector                ; 3 not ready, keep polling
;
      PSHS  #0                            ; 5 Waste CPU cycles, two bytes  (Thanks PenguinOfEvil and DarrenA)
      DEC   NTMovNewFrameSectorCount      ; 7
      BNE   NTMovVideoLoop                ; 3

NTMovRestoreStackCoCo1:
      LDS   #$FFFF                        ; 4
; delay
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      EXG   A,A                           ; 8 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
      LEAU  ,U++                          ; 7 Waste CPU cycles, two bytes
      LDA   ,-Y                           ; 6
      STA   <$20                          ; 4 DAC sample 1
      RTS                                 ; 5
;
NTMovNewFrameSectorCount:
      FCB   0
;
NTMovStreamDoneCoCo1:
      LDS   NTMovRestoreStackCoCo1+2
; S now points at NTMovLoadVideoBuff's return address.  SDCMovieDone's
; LEAS 2,S will discard that return address before restoring CC/DP.
      JMP   SDCMovieDone

; Select the internal 6-bit DAC on the CoCo audio mux and enable sound output.
; This is local to the CoCo 1 movie player because the shared mux helper only
; touches PIA0 side A; this player needs both SEL1 and SEL2 forced low.
NTMovSelectDACMux:
      LDA   <$01              ; PIA0 side A control, CA2 = mux SEL1
      ANDA  #%11000111        ; Keep CA1 control/status, set CA2 output low
      ORA   #%00110000
      STA   <$01
      LDA   <$03              ; PIA0 side B control, CB2 = mux SEL2
      ANDA  #%11000111        ; Keep CB1 control/status, set CB2 output low
      ORA   #%00110000
      STA   <$03
      LDA   <$23              ; PIA1 side B control, CB2 = sound enable
      ANDA  #%11000111        ; Keep CB1 control/status, set CB2 output high
      ORA   #%00111000
      STA   <$23
      RTS

; BREAK Key Pressed
NTMovBreakPressed:
      LDB   #$D0              ; Send abort I/O command..
      STB   <$48              ; ..to the controller
      LEAS  -2,S              ; Stack will get changed below
;
; Exit
SDCMovieDone:
      ORCC  #$50              ; Disable the Interrupts
      LEAS  2,S               ; Fix stack as it gets here only while reading bytes from the CoCoSDC and jumps out of the subroutine
      CLR   <$40              ; put SDC controller back in floppy mode

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
      PULS  CC,DP       ; Restore CC & DP
;
; To reset the CoCoSDC (put it in firmware upgrade mode then back to normal)
      LDA   #$1C              ; Send command $1C
      LDB   #$AA              ; First parameter $AA
      LDX   #$5500            ; Second parameter to $55
      LDU   #$FFFF            ; Signify we don't want to fill a 256 byte buffer
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
      LDU   #$FFFF            ; Signify we don't want to fill a 256 byte buffer
      JSR   CommSDC           ; Send to the CoCoSDC

      JSR   Speed_Restore     ; Restore the CPU Speed back to what the user set
      JMP   AnalogMuxOff      ; DISABLE ANA MUX AND RETURN

; A key was pressed, deal with it
NTMovSomeKeyPressed:
      PULS  U                 ; U = return address
      STU   NTMovResumePlayback+1 ; Keep return address safe; math helpers clobber Y
* Scan keyboard
* CoCo Keyboard mapping
* Read keyboard  CoCo Keyboard mapping
*Row                Data
*bits   7    6    5    4    3    2    1    0
*0      G    F    E    D    C    B    A    @
*1      O    N    M    L    K    J    I    H
*2      W    V    U    T    S    R    Q    P
*3     SPC  RGT  LFT   DN   UP   Z    Y    X
*4      '    &    %    $    #    "    !    0
*4      7    6    5    4    3    2    1
*5      ?    >    =    <    +    *    )    (
*5      /    .    _    ,    ;    :    9    8
*6   SHIFTS  F2   F1  CTRL ALT  BRK  CLR  ENT
***********************************************************
      LDA   #%11111011        ; Strobe keyboard columns 2, so we can catch BREAK key
      STA   <$02              ; $FF02 ..which contains the BREAK key
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%01000000        ; Test Row bit 6
      BNE   @NotBreak         ; Skip ahead and check for spacebar
; Otherwise Break key is pressed
      JMP   NTMovBreakPressed ; Exit playback
@NotBreak:
; check for Spacebar
      LDA   #%01111111        ; Strobe keyboard columns 7, so we can catch Space bar key
      STA   <$02              ; $FF02 ..which contains the SPACE bar key
      LDA   <$00              ; Read keyboard @ $FF00
;          bits 76543210
      BITA  #%00001000        ; Test Row bit 3
      BNE   @NotSpaceBar      ; Skip ahead not spacebar
; Otherwise Space bar key is pressed
      JMP   NTMovSpacePressed ; Go Pause playback and wait for another space bar press
@NotSpaceBar:
;
; Check for numbers pressed
; Key press jump to percent
; Check for 1 and 9
      LDA   #%11111101        ; Strobe keyboard columns 1, so we can catch 1 & 9
      STA   <$02              ; $FF02
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%00010000        ; Test Row bit 4 for a 1
      BNE   >                 ; Skip ahead if not
; 1 Key press jump to 10%
      LDB   #1*3              ; Point at 10% Value
      JMP   @GetLBN
;        bits 76543210
!     BITA  #%00100000        ; Test Row bit 5 for a 9
      BNE   >                 ; Skip ahead if not
; 9 Key press jump to 90%
      LDB   #9*3              ; Point at 90% Value
      JMP   @GetLBN
; Check for zero and 8 keys
!     LDA   #%11111110        ; Strobe keyboard columns 0, so we can catch zero & 8
      STA   <$02              ; $FF02
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%00010000        ; Test Row bit 4 for a zero
      BNE   >                 ; Skip ahead if not
; Zero pressed
      CLRA
      LDU   #$0001            ; Sector 1 (skip header sector)
      BRA   @GotAandUforLBN
;        bits 76543210
!     BITA  #%00100000        ; Test Row bit 5 for an 8
      BNE   >                 ; Skip ahead if not
; 8 Key press jump to 80%
      LDB   #8*3              ; Point at 80% Value
;
      BRA   @GetLBN
; Check for 2
!     LDA   #%11111011        ; Strobe keyboard columns 2, so we can catch 2
      STA   <$02              ; $FF02
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%00010000        ; Test Row bit 4 for a 2
      BNE   >                 ; Skip ahead if not
; 2 Key press jump to 20%
      LDB   #2*3              ; Point at 20% Value
      BRA   @GetLBN
; Check for 3
!     LDA   #%11110111        ; Strobe keyboard columns 3, so we can catch 3
      STA   <$02              ; $FF02
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%00010000        ; Test Row bit 4 for a 3
      BNE   >                 ; Skip ahead if not
; 3 Key press jump to 30%
      LDB   #3*3              ; Point at 30% Value
      BRA   @GetLBN
; Check for 4
!     LDA   #%11101111        ; Strobe keyboard columns 4, so we can catch 4
      STA   <$02              ; $FF02
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%00010000        ; Test Row bit 4 for a 4
      BNE   >                 ; Skip ahead if not
; 4 Key press jump to 40%
      LDB   #4*3              ; Point at 40% Value
      BRA   @GetLBN
; Check for 5
!     LDA   #%11011111        ; Strobe keyboard columns 5, so we can catch 5 or left arrow
      STA   <$02              ; $FF02
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%00010000        ; Test Row bit 4 for a 5
      BNE   >                 ; Skip ahead if not
; 5 Key press jump to 50%
      LDB   #5*3              ; Point at 50% Value
      BRA   @GetLBN
;        bits 76543210
!     BITA  #%00001000        ; Test Row bit 3 for a left arrow
      BNE   >                 ; Skip ahead if not
; Left arrow key
      BRA   NTMovSkipBackward ; Move playback location backwards
; Check for 6
!     LDA   #%10111111        ; Strobe keyboard columns 6, so we can catch 6 or right arrow
      STA   <$02              ; $FF02
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%00010000        ; Test Row bit 4 for a 6
      BNE   >                 ; Skip ahead if not
; 6 Key press jump to 60%
      LDB   #6*3              ; Point at 60% Value
      BRA   @GetLBN
;        bits 76543210
!     BITA  #%00001000        ; Test Row bit 3 for a right arrow
      BNE   >                 ; Skip ahead if not
; Right arrow key
      JMP   NTMovSkipForward  ; Advance playback location
; Check for 7
!     LDA   #%01111111        ; Strobe keyboard columns 7, so we can catch 7
      STA   <$02              ; $FF02
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%00010000        ; Test Row bit 4 for a 7
      BNE   >                 ; Skip ahead if not
; 7 Key press jump to 70%
      LDB   #7*3              ; Point at 70% Value
      BRA   @GetLBN
; Not a valid key 
!     CLR   <$02              ; $FF02 clear keyboard check
      JMP   NTMovResumePlayback ; Return
;
@GetLBN:
      LDX   #NTMovCachePercentLBN-3      ; Offset start of LBN locations by 3 so 1 is the first
      ABX
      LDA   ,X
      LDU   1,X
; Set LBN value is A & U
@GotAandUforLBN:
      STA   >NTMovJumpLBN
      STU   >NTMovJumpLBN+1
      JSR   NTMovLBNToFrame   ; Keep current frame correct after number-key jumps
      JMP   NTMovJupLBN

; Space Bar pressed during playback
NTMovSpacePressed:
      ORCC  #$50              ; Disable the Interrupts
; Space bar will still be detected at this point, loop until it's not detected
; check for Spacebar
!     LDA   #%01111111        ; Strobe keyboard columns 7, so we can catch Space bar key
      STA   <$02              ; $FF02 ..which contains the SPACE bar key
      LDA   <$00              ; Read keyboard @ $FF00
;          bits 76543210
      BITA  #%00001000        ; Test Row bit 3
      BEQ   <                 ; Keep looping until space bar is released

; Get here once Space bar is released, we can now scan for other keys

      LDB   #2                ; Short debounce wait; B is not valid coming out of the key scan
@CountVsyncs
      TST   <$02              ; [6] Tickle the vsync Interrupt
!     TST   <$03              ; [6] Check for vsync Interrupt
      BPL   <                 ; [3] If not yet then keep looping
      DECB
      BNE   @CountVsyncs
;
@PauseLoop:
      LDA   #%11111011        ; Strobe keyboard columns 2, so we can catch BREAK key
      STA   <$02              ; $FF02 ..which contains the BREAK key
      LDA   <$00              ; Read keyboard @ $FF00
;        bits 76543210
      BITA  #%01000000        ; Test Row bit 6
      BNE   @NotBreak         ; Skip ahead and check for spacebar
; Otherwise Break key is pressed
      JMP   NTMovBreakPressed ; Exit playback
@NotBreak:
; check for Spacebar
      LDA   #%01111111        ; Strobe keyboard columns 7, so we can catch Space bar key
      STA   <$02              ; $FF02 ..which contains the SPACE bar key
      LDA   <$00              ; Read keyboard @ $FF00
;          bits 76543210
      BITA  #%00001000        ; Test Row bit 3
      BNE   @NotSpaceBar      ; Skip ahead not spacebar
; Otherwise Space bar key is pressed
      CLR   <$02
      ORCC  #$50              ; Keep interrupts masked during stream playback
      JMP   NTMovResumePlayback ; Resume playback
@NotSpaceBar:
      BRA   @PauseLoop

NTMovResumePlayback:
      JMP   >$FFFF            ; Self-modified by NTMovSomeKeyPressed


NTMovSkipForwardSecs    EQU   10                      ; Amount of seconds to move forward when right arrow is pressed
NTMovSkipBackwardSecs   EQU   10                      ; Amount of seconds to move backwards when left arrow is pressed
;
; NTMovCurFrameCount = 24 bit value, current frame being played
; TargetFrame = CurrentFrame - BackSeconds * FPS
NTMovSkipBackward:
      JSR   NTMovCalcSkipFrames
      LDD   >NTMovCurFrameCount+1
      SUBD  >NTMovSkipFrames
      STD   >NTMovJumpFrame+1
      LDA   >NTMovCurFrameCount
      SBCA  #0
      BCC   >
; If skipping backward would go before frame 0, clamp to frame 0.
      CLR   >NTMovJumpFrame
      CLR   >NTMovJumpFrame+1
      CLR   >NTMovJumpFrame+2
      JSR   NTMovFrameToLBN
      JMP   NTMovJupLBN
!     STA   >NTMovJumpFrame
      JSR   NTMovFrameToLBN
      JMP   NTMovJupLBN
;
; NTMovCurFrameCount = 24 bit value, current frame being played
; TargetFrame = CurrentFrame + ForwardSeconds * FPS
NTMovSkipForward:
      JSR   NTMovCalcSkipFrames
      LDD   >NTMovCurFrameCount+1
      ADDD  >NTMovSkipFrames
      STD   >NTMovJumpFrame+1
      LDA   >NTMovCurFrameCount
      ADCA  #0
      STA   >NTMovJumpFrame
      JSR   NTMovClampJumpFrameToEnd
      JSR   NTMovFrameToLBN
      JMP   NTMovJupLBN
;
; Calculate 10 seconds of frames as a 16-bit value: FPS * 10.
; CoCo 1 movie playback uses small fixed FPS values, so 16 bits is enough.
NTMovCalcSkipFrames:
      CLRA
      LDB   >NTMovCacheFPS
      TFR   D,X
      ASLB
      ROLA
      STD   >NTMovSkipFrames              ; FPS * 2
      TFR   X,D
      ASLB
      ROLA
      ASLB
      ROLA
      ASLB
      ROLA                                ; FPS * 8
      ADDD  >NTMovSkipFrames              ; FPS * 10
      STD   >NTMovSkipFrames
      RTS
;
; Clamp NTMovJumpFrame to Endframe - 1 if needed. Endframe is 32-bit in
; the header cache, but the CoCo 1 player only tracks 24-bit frame numbers.
NTMovClampJumpFrameToEnd:
      LDA   >NTMovCacheEndframe
      BNE   @FrameOK
      LDA   >NTMovCacheEndframe+1
      CMPA  >NTMovJumpFrame
      BHI   @FrameOK
      BLO   @ClampFrame
      LDD   >NTMovCacheEndframe+2
      CMPD  >NTMovJumpFrame+1
      BHI   @FrameOK
@ClampFrame:
      LDA   >NTMovCacheEndframe+1
      LDX   >NTMovCacheEndframe+2
      STA   >NTMovJumpFrame
      STX   >NTMovJumpFrame+1
      LDD   >NTMovJumpFrame+1
      SUBD  #1
      STD   >NTMovJumpFrame+1
      BCC   @FrameOK
      DEC   >NTMovJumpFrame
@FrameOK:
      RTS
;
; CoCo 1 movie frames are always 14 sectors:
; JumpLBN = 1 + JumpFrame * 14
NTMovFrameToLBN:
      CLR   >NTMovJumpLBN
      CLR   >NTMovJumpLBN+1
      CLR   >NTMovJumpLBN+2
      LDB   #14
@FrameToLBNLoop:
      LDA   >NTMovJumpLBN+2
      ADDA  >NTMovJumpFrame+2
      STA   >NTMovJumpLBN+2
      LDA   >NTMovJumpLBN+1
      ADCA  >NTMovJumpFrame+1
      STA   >NTMovJumpLBN+1
      LDA   >NTMovJumpLBN
      ADCA  >NTMovJumpFrame
      STA   >NTMovJumpLBN
      DECB
      BNE   @FrameToLBNLoop
      INC   >NTMovJumpLBN+2               ; Add the header sector
      BNE   @FrameToLBNDone
      INC   >NTMovJumpLBN+1
      BNE   @FrameToLBNDone
      INC   >NTMovJumpLBN
@FrameToLBNDone:
      RTS
;
; Convert the current 24-bit JumpLBN back to a frame number:
; JumpFrame = (JumpLBN - 1) / 14
NTMovLBNToFrame:
      LDA   >NTMovJumpLBN
      LDX   >NTMovJumpLBN+1
      STA   >NTMovLBNWork
      STX   >NTMovLBNWork+1
      LDD   >NTMovLBNWork+1
      SUBD  #1
      STD   >NTMovLBNWork+1
      BCC   >
      DEC   >NTMovLBNWork
!     CLR   >NTMovJumpFrame
      CLR   >NTMovJumpFrame+1
      CLR   >NTMovJumpFrame+2
      CLR   >NTMovDivRemainder
      LDB   #24
@Div14Loop:
      ASL   >NTMovLBNWork+2
      ROL   >NTMovLBNWork+1
      ROL   >NTMovLBNWork
      ROL   >NTMovDivRemainder
      ASL   >NTMovJumpFrame+2
      ROL   >NTMovJumpFrame+1
      ROL   >NTMovJumpFrame
      LDA   >NTMovDivRemainder
      CMPA  #14
      BLO   @Div14Next
      SUBA  #14
      STA   >NTMovDivRemainder
      INC   >NTMovJumpFrame+2
@Div14Next:
      DECB
      BNE   @Div14Loop
      RTS
;
NTMovJupLBN:
; Stop the stream mode
      ORCC  #$50                    ; Disable the Interrupts
      STA   <$D8                    ; Set to normal speed
      LDA   #$D0                    ; Stop transferring early, send the abort stream
      LDU   #$FFFF                  ; Signify we don't want to fill a 256 byte buffer
      JSR   CommSDC                 ; Send to the CoCoSDC
;
; Save the new 24-bit frame value and open the stream at the 24-bit LBN.
      LDA   >NTMovJumpFrame
      LDX   >NTMovJumpFrame+1
      STA   >NTMovCurFrameCount
      STX   >NTMovCurFrameCount+1
      LDA   >NTMovJumpLBN
      LDU   >NTMovJumpLBN+1
      LDX   #_StrVar_PF00           ; X points at the filename in the buffer, ready to be used with "m:" at the beginning already
; Open a file for streaming starting at Logical Sector Number, each sector is 512 bytes.  The LSN is in A & U where
; the Logical Sector Block, 24 bit block where A=MSB (bits 23 to 16), U=Least significant Word (bits 15 to 0)
      STB   <$D8                    ; Put CoCo 3 in normal speed mode
      JSR   OpenSDC_File_X_At_AU
      JMP   NTMovContinueMovie      ; all set so Jump back to movie playback, it will put it back in double speed
;
; Small runtime cache copied from the 512-byte header before the audio buffer
; is reused for playback.
NTMovCacheEndframe:
      RMB   4
NTMovCacheFPS:
      RMB   1
NTMovCachePercentLBN:
      RMB   27
NTMovCacheEnd:
NTMovJumpFrame:
      RMB   3
NTMovJumpLBN:
      RMB   3
NTMovSkipFrames:
      RMB   2
NTMovLBNWork:
      RMB   3
NTMovDivRemainder:
      RMB   1
;
; Local 1K audio buffer. The 512-byte movie header is loaded here temporarily,
; then the buffer is reused for audio playback.
NTMovAudioBuffer:
      RMB   $400
NTMovAudioBufferEnd     EQU   NTMovAudioBuffer+$400-1
;
; Program requires code + 32 byte header cache + 12 byte jump math work area
; plus 1024 bytes for audio playback, total around 2.5k bytes
