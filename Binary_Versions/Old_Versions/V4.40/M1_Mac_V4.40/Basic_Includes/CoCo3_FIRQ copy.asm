*****************************************
VSyncIRQ:
        LDA     GIME_InterruptReqEnable_FF92    ; Re enable the VSYNC IRQ
;                 xxRGBrgb
        LDA     #%00100100 
        CLR     VideoBeam                       ; Reset the videobeam position to the top of the screen
        LDA     #FIRQ_Delay0                    ; Get the delay
        STA     FIRQCount                       ; Save the number of FIRQs to do until the we are ready to draw sprites in the next section of the screen
        LDA     DoingSpritesFlag                ; test if we are still drawing sprites
        BNE     >                               ; if so then simply return
        INC     DoingSpritesFlag                ; Flag that we are still drawing sprites, just in case we're not finished
        JSR     HandleSprites0                  ; Go draw sprites that haven't been drawn & also mark all sprites as not drawn
; Update the playfield
        STA     GIME_BorderColor_FF9A
        LDA     VideoRamBlock                   ; Get the video Bank to show
        STA     GIME_VideoBankSelect_FF9B       ; Update Video Bank block  (0,512k,1Meg,1.5Meg) - GIME_VideoBankSelect_FF9B
        LDD     VerticalPosition                ; Get the position in RAM to show at the top left corner of the screen
        STD     GIME_VerticalOffset1_FF9D       ; GIME_VerticalOffsetMSB_FF9D      
        LDA     HorizontalPosition              ; Get the x scroll value
        STA     GIME_HorizontalOffset_FF9F      ; Set the scroll pointer - GIME_HorizontalOffset_FF9F  
        CLR     DoingSpritesFlag                ; Flag that we are done drawing sprites
!       RTI
*****************************************
; Draw all the sprites that are left to draw that haven't already been drawn
; CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
HandleSprites0:




; Mark all the sprites as available to be drawn
MarkSpritesAsNotDrawn:


        RTS
*****************************************
; Draw all the sprites that are left to draw that haven't already been drawn
; CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
HandleSprites1:
        PSHS    B,X,Y,U                 ; Comes from the FIRQ, backup the registers


        PULS    B,X,Y,U,PC              ; Restore and return
*****************************************
; Draw all the sprites that are left to draw that haven't already been drawn
; CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
HandleSprites2:
        PSHS    B,X,Y,U                 ; Comes from the FIRQ, backup the registers


        PULS    B,X,Y,U,PC              ; Restore and return
*****************************************
; Draw all the sprites that are left to draw that haven't already been drawn
; CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
HandleSprites3:
        PSHS    B,X,Y,U                 ; Comes from the FIRQ, backup the registers


        PULS    B,X,Y,U,PC              ; Restore and return
*****************************************
* FIRQ stuff
* Tested with MAME, 100 times the FIRQ was triggered between each VSYNC IRQ
* MAME scanline delay count before the scanline is really at 00 (I think??  From CoCo 3 Mame info...)
* Triggered 100 times between each IRQ, which delays it 18 times
*****************************************
* CoCo 3 Audio suport
* Code to handle sound functions when we just completed playing a sample
SampleIsDone:
        LDA   DoSoundLoop    * If DoSoundLoop <> 0 then we loop forever
        BEQ   >              * If DoSoundLoop = 0 then we end sound
        LDA   SampleStart
        STA   GetSample+1
        LDA   SampleStart+1
        STA   GetSample+2   * Sample pointer is now pointing to the start
        BRA   GetSample     * Go play the sample from the beginning again
!
        LDA   #FIRQNoAudio/256
        STA   FIRQ_Jump_position_FEF4+1
        LDA   #FIRQNoAudio-(FIRQNoAudio/256*256)
        STA   FIRQ_Jump_position_FEF4+2      * Change the Sample playback FIRQ to FIRQNoAudio

        LDD     #FIRQ_Countdown                     * This is the speed the audio samples will playback at
        STD     GIME_TimerMSB_FF94                  * Set countdown Timer to $0254 - good for 6005.95 Hz samples

        CLRA
        BRA     SendAudio

DoFIRQ:
        STA     FIRQ0Restore+1    * Save exit value of A
        LDA     GIME_FastInterruptReqEnable_FF93           * Re enable the FIRQ and get FIRQ type
        BRA     FIRQNoAudio

*****************************************
* Audio off - Just re-enable the FIRQ and return
FIRQNoAudio:
;             Fast Interrupt Request Enable Register - FIRQENR
;                 ┌┬───────── Bit  7-6 - Unused
;                 ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
;                 │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
;                 ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
;                 │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
;                 ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
;                 │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
;        SUBA    #%00100000
;        BNE     DoVSync             ; If not zero then this was a VSYNC IRQ, go handle it
        CLRA
        BRA     SendAudio           ; A = 0 so send it to audio out and continue
        opt     cd
        opt     cc                
FIRQ_Sound:
        STA     FIRQ0Restore+1      ; Save exit value of A
        LDA     GIME_FastInterruptReqEnable_FF93    ; Re enable the FIRQ
        LDA     #%00100001
        STA     GIME_InitializeRegister1_FF91       ; Mem Type 64k chips, 279.365 nsec timer, MMU Task 1 - $FFB0-$FFB7 - Audio sample banks
        INC     GetSample+2         ; LSB = LSB + 1
        BNE     GetSample           ; IF we didn't hit zero skip ahead
        INC     GetSample+1         ; MSB = MSB + 1
        BMI     SampleIsDone        ; If we get to $8000 then we are done playing this sample
GetSample:
        LDA     SoundBytes
SendAudio:
        STA     PIA1SideADataRegister_FF20  ; Send audio to the DAC
        LDA     #%00100000        
        STA     GIME_InitializeRegister1_FF91   ; Mem Type 64k chips, 279.365 nsec timer, MMU Task 0 - $FFA0-$FFA7 - Normal
DecFIRQCount:
        DEC     FIRQCount
        BEQ     Do_VideoBeam_IRQ    ; We have counted down 25 FIRQs so the Video beam should be down another 1/4 of the screen so go act like an VideoBeam IRQ was triggered for Defender Hardware
FIRQ0Restore:
        LDA     #$FF                ; Self modified from above upon FIRQ entry
        RTI                         ; Return from the FIRQ
; Act like a Hardware VideoBeam IRQ has been triggered

        opt     c,ct,cc                 ; show cycle count, add the counts, clear the current count
Do_VideoBeam_IRQ:        
        INC     VideoBeam               ; Get the current Videobeam address
        LDA     VideoBeam

        DECA
        BNE     >                       ; Skip
; We just finished the top part of the screen
;                 xxRGBrgb
;       LDA     #%00010010              ; Bright Green
;       STA     GIME_BorderColor_FF9A
        LDA     #FIRQ_Delay1
        STA     FIRQCount                       ; 100 FIRQs per frame so each time we count down 25 we will be 1/4 further down the screen (66 rows on the CoCo 3 screen)  
        LDA     DoingSpritesFlag
        BNE     FIRQ0Restore                    ; If sprites are already being drawn then Restore A and Exit FIRQ
        INC     DoingSpritesFlag                ; Flag that we are still drawing sprites, just in case we're not finished
        JSR     HandleSprites1                  ; Go draw sprites that haven't been drawn
        CLR     DoingSpritesFlag                ; Flag that we are done drawing sprites
!       DECA
        BNE     >
; We just finished the 2nd part of the screen
;                 xxRGBrgb
;        LDA     #%00010000              ; Dark green
;        STA     GIME_BorderColor_FF9A
        LDA     #FIRQ_Delay2
        STA     FIRQCount                       ; 100 FIRQs per frame so each time we count down 25 we will be 1/4 further down the screen (66 rows on the CoCo 3 screen)  
        LDA     DoingSpritesFlag
        BNE     FIRQ0Restore                    ; If sprites are already being drawn then Restore A and Exit FIRQ
        INC     DoingSpritesFlag                ; Flag that we are still drawing sprites, just in case we're not finished
        JSR     HandleSprites2                  ; Go draw sprites that haven't been drawn
        CLR     DoingSpritesFlag                ; Flag that we are done drawing sprites
        BRA     FIRQ0Restore                    ; Restore A and Exit FIRQ

! 
;                 xxRGBrgb
;        LDA     #%00001001              ; Blue
;        STA     GIME_BorderColor_FF9A
        LDA     #FIRQ_Delay3
        STA     FIRQCount                       ; 100 FIRQs per frame so each time we count down 25 we will be 1/4 further down the screen (66 rows on the CoCo 3 screen)  
        LDA     DoingSpritesFlag
        BNE     FIRQ0Restore                    ; If sprites are already being drawn then Restore A and Exit FIRQ
        INC     DoingSpritesFlag                ; Flag that we are still drawing sprites, just in case we're not finished
        JSR     HandleSprites3                  ; Go draw sprites that haven't been drawn
        CLR     DoingSpritesFlag                ; Flag that we are done drawing sprites
        BRA     FIRQ0Restore                    ; Restore A and Exit FIRQ

SetupInterruptSources:
;***********************
    ;         PIA 0 Side A Control Register
    ;         ┌────────── Bit  7   - HSYNC Flag
    ;         │┌───────── Bit  6   - Unused
    ;         ││┌┬─────── Bits 5-4 - 11
    ;         ││││┌────── Bit  3   - Select Line LSB of MUX
    ;         │││││┌───── Bit  2   - Data Direction Toggle (0=$FF00 sets direction, 1=normal)
    ;         ││││││┌──── Bit  1   - IRQ Polarity (0=Flag set on falling edge, 1=set on rising edge)
    ;         │││││││┌─── Bit  0   - HSYNC IRQ (0=disabled, 1=enabled)
    LDA     #%11111110
    STA     PIA0SideAControlRegister_FF01    ; Disable HSYNC IRQ
    ;
    ;         PIA 0 Side A Control Register
    ;         ┌────────── Bit  7   - VSYNC Flag
    ;         │┌───────── Bit  6   - Unused
    ;         ││┌┬─────── Bits 5-4 - 11
    ;         ││││┌────── Bit  3   - Select Line MSB of MUX
    ;         │││││┌───── Bit  2   - Data Direction Toggle (0=$FF02 sets direction, 1=normal)
    ;         ││││││┌──── Bit  1   - IRQ Polarity (0=Flag set on falling edge, 1=set on rising edge)
    ;         │││││││┌─── Bit  0   - VSYNC IRQ (0=disabled, 1=enabled)
    LDA     #%11111110
    STA     PIA0SideBControlRegister_FF03    ; Disable VSYNC IRQ
    ;
    ;         PIA 1 Side B Control Register
    ;         ┌────────── Bit  7   - CD FIRQ Flag
    ;         │┌───────── Bit  6   - N/A
    ;         ││┌┬─────── Bits 5-4 - 11
    ;         ││││┌────── Bit  3   - Cassette Motor Control (0=off, 1=on)
    ;         │││││┌───── Bit  2   - Data Direction Toggle (0=$FF20 sets direction, 1=normal)
    ;         ││││││┌──── Bit  1   - FIRQ Polarity (0=Flag set on falling edge, 1=set on rising edge)
    ;         │││││││┌─── Bit  0   - CD FIRQ (RS-232C) (0=disabled, 1=enabled)
    LDA     #%11111110
    STA     PIA1SideAControlRegister_FF21    ; Disable Cassette Data FIRQ
    ;
    ;        PIA 1 Side B Control Register
    ;         ┌────────── Bit  7   - CART FIRQ Flag
    ;         │┌───────── Bit  6   - N/A
    ;         ││┌┬─────── Bits 5-4 - 11
    ;         ││││┌────── Bit  3   - Sound Enable
    ;         │││││┌───── Bit  2   - Data Direction Toggle (0=$FF22 sets direction, 1=normal)
    ;         ││││││┌──── Bit  1   - FIRQ Polarity (0=Flag set on falling edge, 1=set on rising edge)
    ;         │││││││┌─── Bit  0   - CART FIRQ (0=disabled, 1=enabled)
    LDA     #%11111110
    STA     PIA1SideBControlRegister_FF23    ; Disable Cartridge FIRQ
    ;
    ;         Initialization Register 0 - INIT0 
    ;         ┌────────── Bit  7   - CoCo Bit (0 = CoCo 3 Mode, 1 = CoCo 1/2 Compatible)
    ;         │┌───────── Bit  6   - M/P (1 = MMU enabled, 0 = MMU disabled)
    ;         ││┌──────── Bit  5   - IEN (1 = GIME IRQ output enabled to CPU, 0 = disabled)
    ;         │││┌─────── Bit  4   - FEN (1 = GIME FIRQ output enabled to CPU, 0 = disabled)
    ;         ││││┌────── Bit  3   - MC3 (1 = Vector RAM at FEXX enabled, 0 = disabled)
    ;         │││││┌───── Bit  2   - MC2 (1 = Standard SCS (DISK) (0=expand 1=normal))
    ;         ││││││┌┬─── Bits 1-0 - MC1-0 (10 = ROM Map 32k Internal, 0x = 16K Internal/16K External, 11 = 32K External - Except Interrupt Vectors)
    lda     #%01111110
    sta     GIME_InitializeRegister0_FF90               ; CoCo 3 Mode; Enable MMU, IRQ, FIRQ; Vector RAM at $FFEx; ROM 32k internal
    ;
    ;         Initialization Register 1 - INIT1
    ;         ┌────────── Bit  7   - Unused
    ;         │┌───────── Bit  6   - Memory type (1=256K, 0=64K chips)
    ;         ││┌──────── Bit  5   - Timer input clock source (1 = 0.279365 microseconds, 0 = 63.695 microseconds)
    ;         │││┌┬┬┬──── Bits 4-1 - Unused
    ;         │││││││┌─── Bits 0   - MMU Task Register select (0=enable $FFA0-$FFA7, 1=enable $FFA8-$FFAF)
    lda     #%00100000
    sta     GIME_InitializeRegister1_FF91               ; Timer 63.695 usec (*10^-6, low speed); MMU $FFA0-$FFA7 task selected
    ;
    ;         Interrupt Request Enable Register - IRQENR
    ;         ┌┬───────── Bit  7-6 - Unused
    ;         ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
    ;         │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
    ;         ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
    ;         │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
    ;         ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
    ;         │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
    lda     #%00000000
    sta     GIME_InterruptReqEnable_FF92        ; Enable IRQS: VSYNC
                                                ; Disable IRQs: Timer, HSYNC, RS232, Keyboard, Cartridge
    ;
    ;         Fast Interrupt Request Enable Register - FIRQENR
    ;         ┌┬───────── Bit  7-6 - Unused
    ;         ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
    ;         │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
    ;         ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
    ;         │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
    ;         ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
    ;         │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
    lda     #%00000000
    sta     GIME_FastInterruptReqEnable_FF93    ; Disable FIRQS: Timer, HSYNC, VSYNC, RS232, Keyboard, Cartridge
;    lbsr    SetupInterruptVectors
    rts


SetupBank_37:
        LDA     #$37
        STA     $FFA2
        LDX     #$4000
        LDD     #$4444
!       STD     ,X++
        CMPX    #$6000
        BNE     <
        LDA     #$3A
        STA     $FFA2   ; Back to normal
        RTS

SetupBank_0:
        LDA     #0
        STA     $FFA2
        LDX     #$4000
        LDD     #$0000
!       STD     ,X++
        CMPX    #$6000
        BNE     <
        LDA     #$3A
        STA     $FFA2   ; Back to normal
        RTS

SetupBank_1:
        LDA     #1
        STA     $FFA2
        LDX     #$4000
        LDD     #$1111
!       STD     ,X++
        CMPX    #$6000
        BNE     <
        LDA     #$3A
        STA     $FFA2   ; Back to normal
        RTS

SetupBank_2:
        LDA     #2
        STA     $FFA2
        LDX     #$4000
        LDD     #$2222
!       STD     ,X++
        CMPX    #$6000
        BNE     <
        LDA     #$3A
        STA     $FFA2   ; Back to normal
        RTS
