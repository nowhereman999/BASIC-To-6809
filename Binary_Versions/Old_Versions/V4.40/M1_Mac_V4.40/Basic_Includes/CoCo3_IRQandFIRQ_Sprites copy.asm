; VSYNC IRQ Main handler
; Handle sound timer
MainIRQ_Handler:
        LDX     >SoundDuration                   ; Get the new Sound duration value
        BEQ     >                               ; RETURN IF TIMER = 0
        LEAX    -1,X                            ; DECREMENT TIMER IF NOT = 0
        STX     >SoundDuration                   ; Save the new Sound duration value
; Handle TIMER
!       INC     >_Var_Timer+1                    ; Increment the LSB of the Timer Value
        BNE     >                               ; Skip ahead if not zero
        INC     >_Var_Timer                      ; Increment the MSB of the Timer Value
; Handle sprites
!       CLR     VideoBeam                       ; Reset the videobeam position to the top of the screen
        LDA     #FIRQ_Delay0                    ; Get the delay
        STA     >FIRQCount                      ; Save the number of FIRQs to do until the we are ready to draw sprites in the next section of the screen
        LDA     DoingSpritesFlag                ; Test if it's ok to draw sprites
        BITA    #%10000001                      ; If bit zero is a 1 then we are already doing zone zero sprites
        BNE     >                               ; If not zero then don't draw, simply return
        ORA     #%00000001                      ; Flag bit two as a 1 we are still drawing sprites, just in case we're not finished
        STA     DoingSpritesFlag                ; Save it
        BSR     HandleSprites0                  ; Go draw sprites for zone zero
; Update the playfield
        LDA     VideoRamBlock                   ; Get the video Bank to show
        STA     GIME_VideoBankSelect_FF9B       ; Update Video Bank block  (0,512k,1Meg,1.5Meg) - GIME_VideoBankSelect_FF9B
        LDD     VerticalPosition                ; Get the position in RAM to show at the top left corner of the screen
        STD     GIME_VerticalOffset1_FF9D       ; GIME_VerticalOffsetMSB_FF9D      
        LDA     HorizontalPosition              ; Get the x scroll value
        STA     GIME_HorizontalOffset_FF9F      ; Set the scroll pointer - GIME_HorizontalOffset_FF9F  
!       RTI

*****************************************
; Draw sprites for zone zero
HandleSprites0:
        LDU     #SpriteCache0           ; U = The Sprite Cache start for zone 0
!       CMPU    SpriteCachePointer0     ; Have we processed all the sprite commands?
        BEQ     >
        PULU    D,X                     ; Get the sprite blocks
        STD     $FFA1                   ; Sprite first two blocks
        STX     $FFA3                   ; Sprite 3rd and 4th blocks
        PULU    D,X,Y                   ; D = Blocks for Screen, X with screen position and Y with JSR address, and move U to the next sprite cache entry
        STD     $FFA5                   ; Screen Blocks 1 & 2
        INCB
        STB     $FFA7                   ; Screen block 3
        STU     @RestoreU+1             ; Self mod, save U
        JSR     ,Y                      ; Go do the routine
@RestoreU:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed
; Reset sprite cache pointer to the beginning of the cache
!       LDU     #SpriteCache0           ; U = The Sprite Cache0 start
        STU     SpriteCachePointer0     ; Reset the Sprite Cache0 Pointer
        LDD     #$393A
        STD     $FFA1
        LDD     #$3B3C
        STD     $FFA3
        LDD     #$3D3E
        STD     $FFA5
        INCB
        STB     $FFA7                   ; Return blocks to normal
        RTS

*****************************************
; Draw all the sprites that are left to draw that haven't already been drawn
; CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
HandleSprites1:
        PSHS    B,X,Y,U                 ; Comes from the FIRQ, backup the registers
        LDU     #SpriteCache1           ; U = The Sprite Cache start for zone 1
!       CMPU    SpriteCachePointer1     ; Have we processed all the sprite commands?
        BEQ     >
        PULU    D,X                     ; Get the sprite blocks
        STD     $FFA1                   ; Sprite first two blocks
        STX     $FFA3                   ; Sprite 3rd and 4th blocks
        PULU    D,X,Y                   ; D = Blocks for Screen, X with screen position and Y with JSR address, and move U to the next sprite cache entry
        STD     $FFA5                   ; Screen Blocks 1 & 2
        INCB
        STB     $FFA7                   ; Screen block 3
        STU     @RestoreU+1             ; Self mod, save U
        JSR     ,Y                      ; Go do the routine
@RestoreU:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed
; Reset sprite cache pointer to the beginning of the cache
!       LDU     #SpriteCache1           ; U = The Sprite Cache1 start
        STU     SpriteCachePointer1     ; Reset the Sprite Cache1 Pointer
RestoreBlocksReturnFIRQ:
        LDD     #$393A
        STD     $FFA1
        LDD     #$3B3C
        STD     $FFA3
        LDD     #$3D3E
        STD     $FFA5
        INCB
        STB     $FFA7                   ; Return blocks to normal
        PULS    B,X,Y,U,PC              ; Restore and return

*****************************************
; Draw all the sprites that are left to draw that haven't already been drawn
; CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
HandleSprites2:
        PSHS    B,X,Y,U                 ; Comes from the FIRQ, backup the registers
        LDU     #SpriteCache2           ; U = The Sprite Cache start for zone 2
!       CMPU    SpriteCachePointer2     ; Have we processed all the sprite commands?
        BEQ     >
        PULU    D,X                     ; Get the sprite blocks
        STD     $FFA1                   ; Sprite first two blocks
        STX     $FFA3                   ; Sprite 3rd and 4th blocks
        PULU    D,X,Y                   ; D = Blocks for Screen, X with screen position and Y with JSR address, and move U to the next sprite cache entry
        STD     $FFA5                   ; Screen Blocks 1 & 2
        INCB
        STB     $FFA7                   ; Screen block 3
        STU     @RestoreU+1             ; Self mod, save U
        JSR     ,Y                      ; Go do the routine
@RestoreU:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed
; Reset sprite cache pointer to the beginning of the cache
!       LDU     #SpriteCache2           ; U = The Sprite Cache2 start
        STU     SpriteCachePointer2     ; Reset the Sprite Cache2 Pointer
        BRA     RestoreBlocksReturnFIRQ ; Restore the blocks to normal and return from the FIRQ

*****************************************
; Draw all the sprites that are left to draw that haven't already been drawn
; CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
HandleSprites3:
        PSHS    B,X,Y,U                 ; Comes from the FIRQ, backup the registers
        LDU     #SpriteCache3           ; U = The Sprite Cache start for zone 3
!       CMPU    SpriteCachePointer3     ; Have we processed all the sprite commands?
        BEQ     >
        PULU    D,X                     ; Get the sprite blocks
        STD     $FFA1                   ; Sprite first two blocks
        STX     $FFA3                   ; Sprite 3rd and 4th blocks
        PULU    D,X,Y                   ; D = Blocks for Screen, X with screen position and Y with JSR address, and move U to the next sprite cache entry
        STD     $FFA5                   ; Screen Blocks 1 & 2
        INCB
        STB     $FFA7                   ; Screen block 3
        STU     @RestoreU+1             ; Self mod, save U
        JSR     ,Y                      ; Go do the routine
@RestoreU:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed
; Reset sprite cache pointer to the beginning of the cache
!       LDU     #SpriteCache3           ; U = The Sprite Cache3 start
        STU     SpriteCachePointer3     ; Reset the Sprite Cache3 Pointer
        BRA     RestoreBlocksReturnFIRQ ; Restore the blocks to normal and return from the FIRQ

*****************************************
VideoBeam               FCB     0
DoingSpritesFlag        FCB     0               ; 1 if IRQ is in progress, 0 if not
DoSoundLoop             FCB     0               ; 0 = No loop, <> 0 = Loop sound
SampleStart             FDB     $7FFF
*****************************************
* FIRQ stuff
* Tested with MAME, 100 times the FIRQ was triggered between each VSYNC IRQ
* MAME scanline delay count before the scanline is really at 00 (I think??  From CoCo 3 Mame info...)
* Triggered 100 times between each IRQ, which delays it 18 times
*****************************************
* CoCo 3 Audio suport
* Code to handle sound functions when we just completed playing a sample
FIRQCount       FCB     40      ; FIRQ Count until scanline is in the next zone, keep it in the Direct Page area
SampleIsDone:
        LDA   DoSoundLoop       ; If DoSoundLoop <> 0 then we loop forever
        BEQ   >                 ; If DoSoundLoop = 0 then we end sound
        LDA   SampleStart
        STA   GetSample+1
        LDA   SampleStart+1
        STA   GetSample+2       ; Sample pointer is now pointing to the start
        BRA   GetSample         ; Go play the sample from the beginning again
!
        LDA   #FIRQNoAudio/256
        STA   FIRQ_Jump_position_FEF4+1
        LDA   #FIRQNoAudio-(FIRQNoAudio/256*256)
        STA   FIRQ_Jump_position_FEF4+2      ; Change the Sample playback FIRQ to FIRQNoAudio

        LDD     #FIRQ_Countdown                     ; This is the speed the audio samples will playback at
        STD     GIME_TimerMSB_FF94                  ; Set countdown Timer to $0254 - good for 6005.95 Hz samples

        CLRA
        BRA     SendAudio

DoFIRQ:
        STA     FIRQ0Restore+1    ; Save exit value of A
        LDA     GIME_FastInterruptReqEnable_FF93           ; Re enable the FIRQ and get FIRQ type
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
        LDA     >$FFFF
SendAudio:
        STA     PIA1SideADataRegister_FF20  ; Send audio to the DAC
        LDA     #%00100000        
        STA     GIME_InitializeRegister1_FF91   ; Mem Type 64k chips, 279.365 nsec timer, MMU Task 0 - $FFA0-$FFA7 - Normal
DecFIRQCount:
        DEC     >FIRQCount
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
; Do Zone 1
; We just finished the top part of the screen
;                 xxRGBrgb
;       LDA     #%00010010              ; Bright Green
;       STA     GIME_BorderColor_FF9A
        LDA     #FIRQ_Delay1
        STA     >FIRQCount                      ; 100 FIRQs per frame so each time we count down 25 we will be 1/4 further down the screen (66 rows on the CoCo 3 screen)  
        LDA     DoingSpritesFlag                ; Test if it's ok to draw sprites
        BITA    #%10000010                      ; If bit one is a 1 then we are already doing zone one sprites
        BNE     FIRQ0Restore                    ; If sprites are already being drawn then Restore A and Exit FIRQ
        ORA     #%00000010                      ; Flag bit one as a 1 we are still drawing sprites, just in case we're not finished
        STA     DoingSpritesFlag                ; Save it
        JSR     HandleSprites1                  ; Go draw sprites that haven't been drawn
        BRA     FIRQ0Restore                    ; Restore A and Exit FIRQ
!       DECA
        BNE     >
; Zone 2
        LDA     #FIRQ_Delay2
        STA     >FIRQCount                      ; 100 FIRQs per frame so each time we count down 25 we will be 1/4 further down the screen (66 rows on the CoCo 3 screen)  
        LDA     DoingSpritesFlag                ; Test if it's ok to draw sprites
        BITA    #%10000100                      ; If bit two is a 1 then we are already doing zone two sprites
        BNE     FIRQ0Restore                    ; If sprites are already being drawn then Restore A and Exit FIRQ
        ORA     #%00000100                      ; Flag bit two as a 1 we are still drawing sprites, just in case we're not finished
        STA     DoingSpritesFlag                ; Save it
        JSR     HandleSprites2                  ; Go draw sprites that haven't been drawn
        BRA     FIRQ0Restore                    ; Restore A and Exit FIRQ
; Zone 3
! 
        LDA     #FIRQ_Delay3
        STA     >FIRQCount                      ; 100 FIRQs per frame so each time we count down 25 we will be 1/4 further down the screen (66 rows on the CoCo 3 screen)  
        LDA     DoingSpritesFlag                ; Test if it's ok to draw sprites
        BITA    #%10001000                      ; If bit three is a 1 then we are already doing zone three sprites
        BNE     FIRQ0Restore                    ; If sprites are already being drawn then Restore A and Exit FIRQ
        ORA     #%00001000                      ; Flag bit three as a 1 we are still drawing sprites, just in case we're not finished
        STA     DoingSpritesFlag                ; Save it
        JSR     HandleSprites3                  ; Go draw sprites that haven't been drawn
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
