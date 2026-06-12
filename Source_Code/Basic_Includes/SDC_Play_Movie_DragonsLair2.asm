; Play Movie from the CoCoSDC
; Dragon's Lair specific version
; *****************************************************
; To convert any movie to the proper format for this video player use:
; ./MakeNTM106 -i=dls00.mkv -name="Dragon's Lair" -o=DRAGS210.NTM -g136 -s=.75 -f10 -a2 -k -p1 -c0 -sp1=36 -sp2=55 -sp3=12 -nopillar
*****************************************************

;
; Reserve space in 8K bank @ $E000 for audio buffers and palette buffer
SDCNTSAudioBuffer0      EQU   $E000                         ; Audio Buffer 0 starts here
SDCNTSAudioBuffer1      EQU   SDCNTSAudioBuffer0+512*4      ; Audio Buffer 1 starts here
NTMovPalette            EQU   SDCNTSAudioBuffer1+512*4      ; Palette buffer for 32 frames
NTMovHeader             EQU   NTMovPalette+512              ; Keep the header values in memory to refer to
;
NTMovAudioDone          EQU   Temp1                         ; Flag FIRQ is done playing this frame
NTMovCurFrameCount      EQU   Temp2                         ; 3 byte's to keep track of the currently played frame
;

SDCPLAYMOVIE:
; Clear all 16 palette slots
      LDD   #$000F      ; A = 0, B = 15
      LDX   #$FFB0      ; point at the Palette hardware registers
!     STA   B,X
      DECB
      BPL   <
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
      LDA   #$36
      STA   <$A7              ; Set up bank $E000 for audio buffers and Palette buffer
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

; Make both screen buffers colour Palette 2
      LDB   #$37              ; start with the last Mem bank
      STB   >Temp1            ; Save the bank counter
      LDA   #$22              ; Colour palette 2
      LDX   #$2222            ; Colour palette 2
      LEAY  ,X                ; Y = X
      LEAU  ,X                ; U = X
@BankLoop:
      LDB   >Temp1
      STB   <$A6              ; Configure $C000
      LDB   #$22              ; Colour palette 2
      LDS   #$E000
!     PSHS  D,X,Y,U           ; Fill the $2000 bytes with zeros
      CMPS  #$C000
      BNE   <                 ; loop until done
      DEC   >Temp1            ; Have we done all the screen banks?
      LDB   >Temp1
      CMPB  #$2F
      BNE   @BankLoop         ; Loop if not

MovieSDCStack:
      LDS   #$FFFF            ; Restore the Stack pointer (self mod)
;
      LDU   #$6000
      STU   >BEGGRP           ; Set the top left corner of the screen in RAM
; 32 characters per row, characters are at byte boundaries, can start on any row
      LDU   #$6000+4*25+3+256 ; Screen position for score
      STU   >GraphicCURPOS    ; Set where the text should be printed on the graphics screen
      JSR   DragPrint         ; Print text below on the graphics screen
      FCN   '000000'
;
; Load the first sector into audio buffer 0, so we can read the header info and figure out the correct playback method
; for this file
      LDX   #NTMovHeader      ; Point at the header space in RAM
!     LDD   <$4A              ; [5] 2 bytes
      STD   ,X++
      CMPX  #NTMovHeader+512  ; Is it at the end yet?
      BNE   <
; Check if SDC is ready
      LEAS  -2,S              ; Temp stack placement, just in case it exits below
!     LDA   <$48              ; [4] Poll status byte, required for the first byte of each 512 byte sector (get ready to read the next buffer)
      ASRA                    ; [2] Shift the BUSY bit to the carry
      LBCC  SDCMovieDone      ; [5] if not taken, [6] if it is taken] Done if BUSY bit is cleared (End of File) (jump to play the buffer and end)
      BEQ   <                 ; [3] If A = 0 then keep waiting
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

      LDX   #NTMovHeader                  ; Point at the Header table in RAM

      LDA   NTMovGMode,X
      STA   NTMovGraphicMode+1            ; Set the graphics mode
; Handle Video sectors to be read
      LDA   NTMovVidSectors,X
      STA   NTMovSetVidSectors+1          ; Set the number of video sectors to be loaded per frame
; Handle where to load the video data
      LDD   NTMovMemStart,X
      STD   NTMovVidBlast+1               ; Save where to start stack blasting video byte into the buffer

; Setup Audio playback:
      LDD   NTMovFIRQDelay,X              ; Get the FIRQ audio playback delay value
      STD   NTMovFIRQDelaySet+1           ; Set the FIRQ delay value
      LDA   NTMovAudSectors,X             ; Get the # of audio sectors needed to load for each frame
      STA   NTMovLoadAudioBuff+1          ; Save the number of audio sectors needed (1,2,3 or 4)
      LSLA                                ; A = A * 2, D = A * 512
      CLRB
      STA   NTMovCalcEndPalInitAudioBuff0+1 ; Get value to add so we know when the FIRQ reached the end of the Palette buffer0
      STA   NTMovCalcEndPalAudioBuff0+1   ; Get value to add so we know when the FIRQ reached the end of the Palette buffer0
      STA   NTMovCalcEndPalAudioBuff1+1   ; Get value to add so we know when the FIRQ reached the end of the Palette buffer1
;
      LDU   #SDCNTSAudioBuffer0           ; U = Buffer 0 start
      LEAU  D,U                           ; Point at the end of audio buffer 0
      STU   NTMovPalUpEndInitAudBuf0+1    ; Set the location to start blasting into audio buffer 0 - Palette updaing version - init
      STU   NTMovPalUpEndAudBuf0+1        ; Set the location to start blasting into audio buffer 0 - Palette updaing version
;
      LDU   #SDCNTSAudioBuffer1           ; U = Buffer 1 start
      LEAU  D,U                           ; Point at the end of audio buffer 1
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
      LDD   #777                          ; Audio sample delay value
      STD   <$94                          ; $FF94-$FF95 TIMER MSB/LSB

; Backup the current FIRQ values
      LDA   #$7E                          ; Write the JMP instruction if it's possible to use Direct Page for the sample playback then use $0E = direct page JMP location, and 1 byte for address
; Setup the jump to the FIRQ
      STA   FIRQ_Jump_position_FEF4       ; Write JMP instruction for the FIRQ
      LDU   #NTMovieFIRQ                  ; Address for FIRQ
      STU   FIRQ_Jump_position_FEF4+1     ; Update the FIRQ Jump address
   
; Setup the palette:
      LEAY  NTMovInitPalette,X
      LDU   #$FFB0                        ; U points at the palette register
      LDB   #15                           ; Load 16 colour values into the palette registers
!     LDA   B,Y
      STA   B,U
      DECB
      BPL   <                             ; Loop from 15 to 0

; Continue from here after a jump in playback
NTMovContinueMovie:
      STB   <$D9                          ; Put CoCo 3 in double speed mode
      CLR   <$02                          ; $FF02 clear keyboard check

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
      CLR   >NTMovAudioDone         ; Clear it so it's ready for next audio wait for audio to complete loop
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
      CLR   >NTMovAudioDone         ; Clear it so it's ready for next audio wait for audio to complete loop

; Scan keyboard for any keypress
      LDA   <$92
      BEQ   >
      JSR   NTMovSomeKeyPressed
!

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
      JSR   NTMovLoadAudioBuff
; load video buffer 1
      LDD   #$3334                  ; [3] Banks 3 & 4 & 5
      JSR   NTMovLoadVideoBuff      ; Set memory banks and load a frame
; Loop audio buffer 0 until end of buffer reached
!     LDA   >NTMovAudioDone         ; Get Value (FIRQ will clear it when it reaches the end of the buffer)
      BEQ   <                       ; Loop until we get the clear signal
; Set audio playback to the start of audio buffer 1
      LDD   #SDCNTSAudioBuffer1     ; Point the audio player start at Audio Buffer 1
      STD   NTMovGetSample+1        ; Set the value
NTMovCalcEndPalAudioBuff1:
      ADDA  #$FF                    ; Self mod the number of 256 byte blocks the audio buffer is
      STA   NTMovAudioCMP+1         ; Save value for FIRQ to test for to see if it's reached the end of the buffer
      CLR   >NTMovAudioDone         ; Clear it so it's ready for next audio wait for audio to complete loop

; Scan keyboard for any keypress
      LDA   <$92
      BEQ   >
      JSR   NTMovSomeKeyPressed
!

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
      JSR   NTMovLoadAudioBuff
; load video buffer 0
      LDD   #$3031                  ; [3] Banks 0 & 1 & 2
      BSR   NTMovLoadVideoBuff      ; Set memory banks and load a frame
; Loop audio buffer 1 until end of buffer reached
!     LDA   >NTMovAudioDone         ; Get Value (FIRQ will clear it when it reaches the end of the buffer)
      BEQ   <                       ; Loop until we get the clear signal
      JMP   NTMovMainLoopPalChang
; Loop end

; Load the palette buffer, reset pointer to the start of the buffer
NTMovLoadPaletteBuff:
      LDU   #NTMovPalette+512       ; Set the buffer end location
      LDD   #NTMovPalette           ; Get the Palette start value
      STD   NTMovPalettePointer+1   ; Save the pointer
      LDA   #1
      BRA   MovBlastSectorU         ; Stack blast to fill #A of 512 Byte sectors to software Stack location ,U then return

; Load the video buffer
NTMovLoadVideoBuff:
      STD   <$A4                    ; [5] Configure $8000 & $A000
      INCB                          ; [2] Bank 2
      STB   <$A6                    ; [4] Configure $C000
NTMovVidBlast:
      LDU   #$8000+128*167          ; Start drawing the image at row 167 fills bottom up
      LEAU  -32,U                   ; Move start location
      JMP   Blast192x144U


NTMovSetVidSectors:
      LDA   #36                     ; [2] Self mod, 36 sectors of 512 bytes each to be read, 512 * 36 = 18,432 bytes per frame
      STA   <$42                    ; [3] save the sector counter
      INC  >NTMovCurFrameCount+2
      BNE   @SectorLoop
      INC   >NTMovCurFrameCount+1
      BNE   @SectorLoop
      INC   >NTMovCurFrameCount
      BRA   @SectorLoop
;
; Load the audio, U points a the end of the buffer
NTMovLoadAudioBuff:
      LDA   #$FF                    ; [2] # of Audio sectors (Self mod)
;
; Stack blast to fill #A of 512 Bytes sectors to software Stack location ,U
MovBlastSectorU:
; 28 * 6 bytes so far = 168
; Do it 3 times to get us to 504 bytes
      STA   <$42                    ; [3] save the sector counter
@SectorLoop:
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
; 10
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
; 20
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
; 30
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
; 40
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
; 50
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
; 60
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
; 70
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
; 80
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
; copied 85 * 6 = 510 bytes saved at ,S
; We've read 510 bytes so far let's get the last 2
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
      DEC   <$42              ; [6] Decrement the counter (Special CoCoSDC byte that can be used as RAM)
      LBNE  @SectorLoop       ; [3] Keep looping until we've blasted all sectors into buffer ,U
      RTS                     ; [5] Return

; Blast the video into the buffer
Blast192x144U:
      LDA   #9
      STA   @MainLoopCount
@Loop0:
; -----------------------------
; Sector 1 = 5 rows + 32 bytes
; -----------------------------
      LDA   #5
      JSR   @BlastFullRows          ; 480 bytes normal
      JSR   @Blast30_NoRowAdvance   ; 510 bytes
      LDD   <$4A                    ; [5] 2 bytes
      PSHU  D                       ; [7] save 2 bytes on U stack
; Wait for the CoCoSDC to fill it's buffer and indicate it's ready
!     LDA   <$48
      ASRA
      LBCC  SDCMovieDone      ; Signify we've reached the end
      BEQ   <
; -----------------------------
; Sector 2 = 64 bytes + 4 rows + 64 bytes
; -----------------------------
; Blast 60
      JSR   @Blast60_NoRowAdvance
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  X,Y         ; final 4 bytes of the 64-byte partial row
      LEAU  96-128,U    ; Next row
; 1st byte of new row
      PSHU  D           ; Write 2 bytes, start of first row
; 1 row of 94 bytes
; Do the rest of this row 94
      LDA   #4          ; 4 * 96 = 384
      STA   @InLoopCount     
!     JSR   @Blast90_NoRowAdvance
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  X,Y         ; 4 bytes to finish current row
      LEAU  96-128,U    ; Next row
      PSHU  D           ; Write 2 bytes
      DEC   @InLoopCount
      BNE   <
;
      JSR   @Blast60_NoRowAdvance
      LDD   <$4A
      PSHU  D
; Wait for the CoCoSDC to fill it's buffer and indicate it's ready
!     LDA   <$48
      ASRA
      LBCC  SDCMovieDone      ; Signify we've reached the end
      BEQ   <
; -----------------------------
; Sector 3 = 36 + 4*96 + 92 = 512
; -----------------------------
      JSR   @Blast30_NoRowAdvance
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  Y           ; final 2 bytes of the 32-byte partial row
      LEAU  96-128,U    ; Next row
      PSHU  D,X         ; Write 4 bytes
; wrote 36 bytes
      LDA   #4          ; 4 rows using 90 + split 6 bytes each
      STA   @InLoopCount     
@InLoop1:
      BSR   @Blast90_NoRowAdvance
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  Y
      LEAU  96-128,U    ; Next row
      PSHU  D,X         ; 4 bytes carried into next row
      DEC   @InLoopCount
      BNE   @InLoop1
;
; Final row of this sector already has 4 bytes written.
; Need 92 more bytes: 90 + final 2.
; This keeps the last sector read as LDD / PSHU D.
      JSR   @Blast90_NoRowAdvance   ; 90 bytes
      LDD   <$4A                    ; final 2 bytes of sector
      PSHU  D
      LEAU  96-128,U                ; completed this row
;
; Wait for the CoCoSDC to fill it's buffer and indicate it's ready
!     LDA   <$48
      ASRA
      LBCC  SDCMovieDone      ; Signify we've reached the end
      BEQ   <
;
      DEC   @MainLoopCount
      LBNE  @Loop0
      RTS
@MainLoopCount    RMB   1
@InLoopCount      RMB   1
;
; This routine writes A full rows. Each row is 96 bytes.
@BlastFullRows:
      STA   <$42
@FullRowLoop:
      BSR   @Blast96_NoRowAdvance
      LEAU  96-128,U          ; move to right edge of row above
      DEC   <$42
      BNE   @FullRowLoop
      RTS
;
; 96 byte
@Blast96_NoRowAdvance:
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
@Blast90_NoRowAdvance:
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
; 60 bytes
@Blast60_NoRowAdvance:
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
; For 30 bytes
@Blast30_NoRowAdvance:
      ; five 6-byte blocks = 30 bytes
      ; inline this for speed
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
;
      LDD   <$4A
      LDX   <$4A
      NOP
      LDY   <$4A
      PSHU  D,X,Y
      RTS


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
      DEC   >NTMovAudioDone   ; signify we are done playing this buffer
@FIRQ0Restore:
      LDA   #$FF              ; Self modified from above upon FIRQ entry
      RTI                     ; Return from the FIRQ

; BREAK Key Pressed
NTMovBreakPressed:
      STB   <$D8              ; Set to Normal speed
      LDB   #$D0              ; Send abort I/O command..
      STB   <$48              ; ..to the controller
      LEAS  -2,S              ; Stack will get changed below
;
; Exit
SDCMovieDone:
      ORCC  #$50              ; Disable the Interrupts
      LEAS  2,S               ; Fix stack as it gets here only while reading bytes from the CoCoSDC and jumps out of the subroutine
      CLR   <$40              ; put SDC controller back in floppy mode
      LDD   #$3C3D            ; Put memory back to normal
      STD   <$A4
      LDD   #$3E3F
      STD   <$A6
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
      PULS  CC,DP       ; Restore CC & DP
;
; Make all colours black before exiting
      LDX   #$FFB0      ; Start of Palette hardware registers
      LDD   #15         ; A = 0, B = 15
!     STA   B,X         ; Set Palette value to zero (Black)
      DECB              ; Decrement the loop counter
      BPL   <           ; Loop until B = -1
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
      PULS  Y                 ; Y = return address
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
;      JMP   Debug            ; For debugging
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
      JMP   NTMovSkipBackward ; Move playback location backwards
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
      JMP   ,Y                ; Return
;
@GetLBN:
      LDX   #NTMovHeader+NTMovPercentLBN-3      ; Offset start of LBN locations by 3 so 1 is the first
      ABX
      LDA   ,X
      LDU   1,X
; Set LBN value is A & U
@GotAandUforLBN:
      PSHS  A,U               ; Save the LBN on the stack
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

; Let a little time pass
      LDB   #5                ; Wait for some vsyncs
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
      ANDCC #%00111111        ; Enable the FIRQ
      JMP   ,Y                ; Resume playback
@NotSpaceBar:
      BRA   @PauseLoop


NTMovSkipForwardSecs    EQU   120                     ; Amount of seconds to move forward when right arrow is pressed
NTMovSkipBackwardSecs   EQU   NTMovSkipForwardSecs/2  ; Amount of seconds to move backwards when left arrow is pressed
;
; NTMovCurFrameCount = 24 bit value, current frame being played
; TargetFrame = CurrentFrame - BackSeconds * FPS
NTMovSkipBackward:
; Get the amount of seconds to skip backwards as a 32 bit value
;
; Copy Current Frame count onto the stack
      CLRA
      LDB   >NTMovCurFrameCount
      LDX   >NTMovCurFrameCount+1
      PSHS  D,X                           ; Put the current frame count on the stack as a 32 bit value
;
      LDX   #NTMovSkipBackwardSecs/65536
      LDU   #NTMovSkipBackwardSecs
      PSHS  X,U                           ; Save 32 bit version of skip forward seconds, value on the stack
      CLRA
      LDB   >NTMovHeader+NTMovFPS         ; Get frames per second
      PSHS  D
      CLRB
      PSHS  D                             ; Save 32 bit version on the stack
      JSR   Mul_UnSigned_Both_32          ; ,S (4 bytes) * 4,S (4 bytes) result 4 byte (32 bit) value is at ,S also full 64 bit value is @ RESULT
;
; Stack is now 4,S = CurrentFrame and ,S = Backseconds * FPS
      JSR   Subtract_4ByteFrom4Byte       ; Value1 @ 4,S - Value2 @ ,S result (4 bytes) on the stack
; TargetFrame is now on the stack
      BPL   @EndFrameIsHigher             ; Go move player pointer and continue playback
      LEAS  4,S                           ; Otherwise (remove negative position), Fix the stack
      JMP   ,Y                            ; And return
;
; NTMovCurFrameCount = 24 bit value, current frame being played
; TargetFrame = CurrentFrame + 120 * FPS
NTMovSkipForward:
; Get the amount of seconds to skip forward as a 32 bit value
      LDX   #NTMovSkipForwardSecs/65536
      LDU   #NTMovSkipForwardSecs
      PSHS  X,U                           ; Save 32 bit version of skip forward seconds, value on the stack
      CLRA
      LDB   >NTMovHeader+NTMovFPS         ; Get frames per second
      PSHS  D
      CLRB
      PSHS  D                             ; Save 32 bit version on the stack
      JSR   Mul_UnSigned_Both_32          ; ,S (4 bytes) * 4,S (4 bytes) result 4 byte (32 bit) value is at ,S also full 64 bit value is @ RESULT
;
      CLRA
      LDB   >NTMovCurFrameCount
      LDX   >NTMovCurFrameCount+1
      PSHS  D,X                           ; Put the current frame count on the stack as a 32 bit value
;
      JSR   Add_4ByteTo4Byte              ; ,S (4 bytes) + 4,S (4 bytes) result 4 byte (32 bit) value is at ,S
; Stack now has the TargetFrame
; Make sure TargetFrame is not past the end of the Movie
      LDX   >NTMovHeader+NTMovEndframe    ; Get Endframe value = MSWord
      CMPX  ,S                            ; Compare it with TargetFrame
      BEQ   >                             ; If they are the same check the LSWords
      BHI   @EndFrameIsHigher             ; We are good to skip to this location in the movie
      BRA   @EndFrameIsLower              ; If it's lower then fix the stack and return
!     LDX   >NTMovHeader+NTMovEndframe+2  ; Get Endframe value = LSWord
      CMPX  2,S                           ; Compare it with TargetFrame
      BHI   @EndFrameIsHigher             ; We are good to skip to this location in the movie
;
@EndFrameIsLower:
; If we get here it wants to jump past the end of the movie
      LEAS  4,S                           ; remove TargetFrame off the stack
      JMP   ,Y                            ; Return/Resume playback
;
@EndFrameIsHigher:
; TargetFrame is now on the stack as a 32 bit number
      LDA   >NTMovHeader+NTMovPalMode     ; Get the Palette Changing flag 0 = not changing, 1 = changing
      BNE   NTMovPalMode1                 ; Playback mode will change the palette each frame
; PalMode 0
; StartSector = 1 + TargetFrame * (VidSectors + AudSectors)
      LDA   >NTMovHeader+NTMovVidSectors  ; A = VidSectors
      ADDA  >NTMovHeader+NTMovAudSectors  ; A = A + AudSectors
      PSHS  A
      LDD   #$0000
      PSHS  D
      PSHS  A
; (VidSectors + AudSectors) is now on the stack as a 32 bit number
; Multiply TargetFrame * (VidSectors + AudSectors)
      JSR   Mul_UnSigned_Both_32          ; ,S (4 bytes) * 4,S (4 bytes) result 4 byte (32 bit) value is at ,S also full 64 bit value is @ RESULT
; LBN is 24 bits, so move the stack
      LEAS  1,S
      BRA   @Add1_SetLBN                  ; Go add 1 to the 24 bit LBN value on the stack and update the LBN and play from that point
;
; GroupIndex = TargetFrame >> 5
; StartSector = 1 + GroupIndex * (1 + 32 * (VidSectors + AudSectors))
NTMovPalMode1:
; Divide by 32 bit number on the stack by 32
      LDB   #5                ; To divide by 32 we shift the value right 5 times
!     LSR   ,S
      ROR   1,S
      ROR   2,S
      ROR   3,S
      DECB
      BNE   <
; GroupIndex is now on the stack as a 32 bit number
      LDA   >NTMovHeader+NTMovVidSectors  ; A = VidSectors
      ADDA  >NTMovHeader+NTMovAudSectors  ; A = A + AudSectors
      PSHS  A
      CLRA                                ; B is already zero, now D = $0000
      PSHS  D
      PSHS  A
; (VidSectors + AudSectors) is now on the stack as a 32 bit number
      LDX   #$0020                        ; X = 32
      PSHS  D,X                           ; D = 0 
; 32 is now on the stack as a 32 bit number
      JSR   Mul_UnSigned_Both_32          ; ,S (4 bytes) * 4,S (4 bytes) result 4 byte (32 bit) value is at ,S also full 64 bit value is @ RESULT
; Add 1 to the 32 bit value on the stack
      INC   3,S
      BNE   >
      INC   2,S
      BNE   >
      INC   1,S
      BNE   >
      INC   ,S
; Multiply GroupIndex * (1 + 32 * (VidSectors + AudSectors))
!     JSR   Mul_UnSigned_Both_32          ; ,S (4 bytes) * 4,S (4 bytes) result 4 byte (32 bit) value is at ,S also full 64 bit value is @ RESULT
; LBN is 24 bits, so move the stack
      LEAS  1,S
;
; Go add 1 to the 24 bit LBN value on the stack and update the LBN and play from that point
@Add1_SetLBN                  
; Add 1
      INC   2,S
      BNE   NTMovJupLBN
      INC   1,S
      BNE   NTMovJupLBN
      INC   ,S
; We now have the sector to jump to (24 bit LBN) on the stack
NTMovJupLBN:
; Stop the stream mode
      ORCC  #$50                    ; Disable the Interrupts
      STA   <$D8                    ; Set to normal speed
      LDA   #$D0                    ; Stop transferring early, send the abort stream
      LDU   #$FFFF                  ; Signify we don't want to fill a 256 byte buffer
      JSR   CommSDC                 ; Send to the CoCoSDC
;
; Calculate the new CurrentFrame
      LDA   >NTMovHeader+NTMovPalMode     ; Get the Palette Changing flag 0 = not changing, 1 = changing
      BNE   @PalMode1                     ; Playback mode changes the palette
; Palmode 0
; CurrentFrame = (SectorNum - 1) \ (VideoSectors + AudioSectors)
      CLRA
      LDB   ,S
      LDU   1,S
      PSHS  D,U                     ; Backup SectorNum as a 32 bit number  
      CLRB
      LDU   #$001
      PSHS  D,U                     ; Save 32 bit version of # 1
      JSR   Subtract_4ByteFrom4Byte ; Value1 @ 4,S - Value2 @ ,S result (4 bytes) on the stack
; (VidSectors + AudSectors)
      LDA   >NTMovHeader+NTMovVidSectors  ; A = VidSectors
      ADDA  >NTMovHeader+NTMovAudSectors  ; A = A + AudSectors
      PSHS  A
      LDD   #$0000
      PSHS  D
      PSHS  A
; (VidSectors + AudSectors) is now on the stack as a 32 bit number
; Code does division of Value1/Value2 where:
; Value1 is stored at 4,S (Dividend)
; Value2 is stored at ,S  (Divisor)
; After Division the stack is moved forward 4 bytes and the result (Quotient) is stored at ,S
      JSR   Div_UnSigned_NoRounding_32
      BRA   @SaveNewFrame                 ; 32 bit frame number is on the stack
;
; Pal Mode = 1, cahning palette every frame
@PalMode1:
; GroupSize = 1 + 32 * (VideoSectors + AudioSectors)
; CurrentFrame = ((SectorNum - 1) / GroupSize) * 32
;
; Calculate (SectNum - 1)
      CLRA
      LDB   ,S                      ; Get the new Sector Number off the stack
      LDU   1,S                     ; Get the new Sector Number off the stack
      PSHS  D,U                     ; Save SectorNum as a 32 bit number  
      CLRB
      LDU   #$001
      PSHS  D,U                     ; Save 32 bit version of # 1
      JSR   Subtract_4ByteFrom4Byte ; Value1 @ 4,S - Value2 @ ,S result (4 bytes) on the stack
; (SectNum - 1) is now on the stack as a 32 bit number
; Get GroupSize on the stack newxt so they will be in the correct order on the stack do 32 bit division
;
; (VidSectors + AudSectors)
      LDA   >NTMovHeader+NTMovVidSectors  ; A = VidSectors
      ADDA  >NTMovHeader+NTMovAudSectors  ; A = A + AudSectors
      PSHS  A
      LDD   #$0000
      PSHS  D
      PSHS  A
; (VidSectors + AudSectors) is now on the stack as a 32 bit number
; * 32
; Multiply 32 bit number on the stack by 32
      LDB   #5                ; To multiply by 32 we shift the value left 5 times
!     LSL   3,S
      ROL   2,S
      ROL   1,S
      ROL   ,S
      DECB
      BNE   <
; + 1, Add 1 to the 32 bit value on the stack
      INC   3,S
      BNE   @GotGroupSize
      INC   2,S
      BNE   @GotGroupSize
      INC   1,S
      BNE   @GotGroupSize
      INC   ,S
; GroupSize is now on the stack as a 32 bit number
@GotGroupSize:
; Divide
      JSR   Div_UnSigned_NoRounding_32    ; Divide 4,S / ,S result (4 bytes) on the stack
; * 32
; Multiply 32 bit number on the stack by 32
      LDB   #5                ; To multiply by 32 we shift the value left 5 times
!     LSL   3,S
      ROL   2,S
      ROL   1,S
      ROL   ,S
      DECB
      BNE   <
;
; Save the new 32 bit frame value as 24 bit current frame value
@SaveNewFrame:
      PULS  D,X                           ; Get Current 32 bit value frame, off the stack
      STB   >NTMovCurFrameCount
      STX   >NTMovCurFrameCount+1         ; Save as 24 bit value as the current frame
;
      PULS  A,U                     ; A & U have the 24 bit LBN to send to the CoCoSDC to set where to continue playback from
      LDX   #_StrVar_PF00           ; X points at the filename in the buffer, ready to be used with "m:" at the beginning already
; Open a file for streaming starting at Logical Sector Number, each sector is 512 bytes.  The LSN is in A & U where
; the Logical Sector Block, 24 bit block where A=MSB (bits 23 to 16), U=Least significant Word (bits 15 to 0)
      STB   <$D8                    ; Put CoCo 3 in normal speed mode
      JSR   OpenSDC_File_X_At_AU
      JMP   NTMovContinueMovie      ; all set so Jump back to movie playback, it will put it back in double speed

Debug:
; Insert code below for debugging
      PSHS  A
      TFR   DP,A
      STA   >_Var_REGDP
      PULS  A
      JMP   ShowRegs
; Leave this here:

ShowRegs:
      ORCC  #$50
      PSHS  D   
      LDD   #$3C3D
      STD   $FFA4
      LDD   #$3E3F
      STD   $FFA6
      LDA   #$17
      TFR   A,DP
      PULS  D
      JMP   ShowValues

DragPrint:
      PULS  X                 ; X points at the text (null terminated)
!     LDA   ,X+
      BEQ   >
      BSR   DragText          ; Print A on screen
      BRA   <
!     JMP   ,X

; Put some text on screen
;
; Need to set CC3ScreenStart to the 8k block we want as the start of our screen
; Video Buffer0 = $30,$31,$32 - it will be loaded at $6000, so references for screen location must be from $6000
; Video Buffer1 = $33,$34,$35
;
; x0 and y0 are the text printing locations setup normally with LOCATE x0,y0
DragText:
      PSHS  DP
      LDB   #$17
      TFR   B,DP
;
      LDB   #$30                          ; Video Buffer0
      STB   CC3ScreenStart                ; Set it
      LDU   GraphicCURPOS                 ; Get where the text should be printed
      LDY   #AtoGraphics_Screen_HIG146    ; Y points at the routine to do, Go print A to graphic screen
      JSR   DoCC3Graphics                 ; Prep for CoCo 3 graphics and then JSR ,Y and restore & return
;
      LDB   #$34                          ; Video Buffer1
      STB   CC3ScreenStart                ; Set it
      STU   GraphicCURPOS                 ; Set where the text should be printed
      LDY   #AtoGraphics_Screen_HIG146    ; Y points at the routine to do, Go print A to graphic screen
      JSR   DoCC3Graphics                 ; Prep for CoCo 3 graphics and then JSR ,Y and restore & return
;
      PULS  DP,PC

