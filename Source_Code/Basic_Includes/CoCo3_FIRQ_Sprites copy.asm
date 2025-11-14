
FIRQ_Jump_position_FEF4             EQU $FEF4	* Store $7E which is the JMP opcode
IRQ_Jump_position_FEF7              EQU $FEF7	* Store $7E which is the JMP opcode

PIA0SideADataRegister_FF00      EQU $FF00
; Bit 7 Joystick Comparison Input
; Bit 6 Keyboard Row 7
; Bit 5 Row 6
; Bit 4 Row 5
; Bit 3 Row 4 & Left Joystick Switch 2
; Bit 2 Row 3 & Right Joystick Switch 2
; Bit 1 Row 2 & Left Joystick Switch 1
; Bit 0 Row 1 & Right Joystick Switch 1

PIA0SideAControlRegister_FF01   EQU $FF01
;         PIA 0 Side A Control Register
;         ┌────────── Bit  7   - HSYNC Flag
;         │┌───────── Bit  6   - Unused
;         ││┌┬─────── Bits 5-4 - 11
;         ││││┌────── Bit  3   - Select Line LSB of MUX
;         │││││┌───── Bit  2   - Data Direction Toggle (0=$FF00 sets direction, 1=normal)
;         ││││││┌──── Bit  1   - IRQ Polarity (0=Flag set on falling edge, 1=set on rising edge)
;         │││││││┌─── Bit  0   - HSYNC IRQ (0=disabled, 1=enabled)

PIA0SideBDataRegister_FF02      EQU $FF02 
; Bit 7 KEYBOARD COLUMN 8
; Bit 6 KEYBOARD COLUMN 7 / RAM SIZE OUTPUT
; Bit 5 KEYBOARD COLUMN 6
; Bit 4 KEYBOARD COLUMN 5
; Bit 3 KEYBOARD COLUMN 4
; Bit 2 KEYBOARD COLUMN 3
; Bit 1 KEYBOARD COLUMN 2
; Bit 0 KEYBOARD COLUMN 1

PIA0SideBControlRegister_FF03   EQU $FF03
;         PIA 0 Side B Control Register
;         ┌────────── Bit  7   - VSYNC Flag
;         │┌───────── Bit  6   - N/A
;         ││┌┬─────── Bits 5-4 - 11
;         ││││┌────── Bit  3   - Select Line MSB of MUX
;         │││││┌───── Bit  2   - Data Direction Toggle (0=$FF02 sets direction, 1=normal)
;         ││││││┌──── Bit  1   - IRQ Polarity (0=Flag set on falling edge, 1=set on rising edge)
;         │││││││┌─── Bit  0   - VSYNC IRQ (0=disabled, 1=enabled)

PIA1SideADataRegister_FF20      EQU $FF20
;         PIA 1 Side A Control Data Register
;         ┌┬┬┬┬┬───── 6-Bit DAC
;         ││││││┌──── Bit  1   - RS-232C Data Output
;         │││││││┌─── Bit  0   - Cassette Data Input

PIA1SideAControlRegister_FF21   EQU $FF21
;         PIA 1 Side B Control Register
;         ┌────────── Bit  7   - CD FIRQ Flag
;         │┌───────── Bit  6   - N/A
;         ││┌┬─────── Bits 5-4 - 11
;         ││││┌────── Bit  3   - Cassette Motor Control (0=off, 1=on)
;         │││││┌───── Bit  2   - Data Direction Toggle (0=$FF20 sets direction, 1=normal)
;         ││││││┌──── Bit  1   - FIRQ Polarity (0=Flag set on falling edge, 1=set on rising edge)
;         │││││││┌─── Bit  0   - CD FIRQ (RS-232C) (0=disabled, 1=enabled)

PIA1SideBDataRegister_FF22      EQU $FF22
; Bit 7 VDG CONTROL A/G : Alphanum = 0, graphics =1
; Bit 6     "                GM2
; Bit 5     "                GM1 & invert
; Bit 4 VDG CONTROL          GM0 & shift toggle
; Bit 3 RGB Monitor sensing (INPUT) CSS - Color Set Select 0,1
; Bit 2 RAM SIZE INPUT
; Bit 1 SINGLE BIT SOUND OUTPUT
; Bit 0 RS-232C DATA INPUT

PIA1SideBControlRegister_FF23   EQU $FF23
;         PIA 1 Side B Control Register
;         ┌────────── Bit  7   - CART FIRQ Flag
;         │┌───────── Bit  6   - N/A
;         ││┌┬─────── Bits 5-4 - 11
;         ││││┌────── Bit  3   - Sound Enable
;         │││││┌───── Bit  2   - Data Direction Toggle (0=$FF22 sets direction, 1=normal)
;         ││││││┌──── Bit  1   - FIRQ Polarity (0=Flag set on falling edge, 1=set on rising edge)
;         │││││││┌─── Bit  0   - CART FIRQ (0=disabled, 1=enabled)

GIME_InitializeRegister0_FF90       EQU $FF90
;         Initialization Register 0 - INIT0 
;         ┌────────── Bit  7   - CoCo Bit (0 = CoCo 3 Mode, 1 = CoCo 1/2 Compatible)
;         │┌───────── Bit  6   - M/P (1 = MMU enabled, 0 = MMU disabled)
;         ││┌──────── Bit  5   - IEN (1 = GIME IRQ output enabled to CPU, 0 = disabled)
;         │││┌─────── Bit  4   - FEN (1 = GIME FIRQ output enabled to CPU, 0 = disabled)
;         ││││┌────── Bit  3   - MC3 (1 = Vector RAM at FEXX enabled, 0 = disabled)
;         │││││┌───── Bit  2   - MC2 (1 = Standard SCS (DISK) (0=expand 1=normal))
;         ││││││┌┬─── Bits 1-0 - MC1-0 (10 = ROM Map 32k Internal, 0x = 16K Internal/16K External, 11 = 32K External - Except Interrupt Vectors)

GIME_InitializeRegister1_FF91       EQU $FF91
;         Initialization Register 1 - INIT1
;         ┌────────── Bit  7   - Unused
;         │┌───────── Bit  6   - Memory type (1=256K, 0=64K chips)
;         ││┌──────── Bit  5   - Timer input clock source (1 = 0.279365 microseconds, 0 = 63.695 microseconds)
;         │││┌┬┬┬──── Bits 4-1 - Unused
;         │││││││┌─── Bits 0   - MMU Task Register select (0=enable $FFA0-$FFA7, 1=enable $FFA8-$FFAF)
GIME_InterruptReqEnable_FF92        EQU $FF92
;         Interrupt Request Enable Register - IRQENR
;         ┌┬───────── Bit  7-6 - Unused
;         ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
;         │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
;         ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
;         │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
;         ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
;         │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
GIME_FastInterruptReqEnable_FF93    EQU $FF93
;         Fast Interrupt Request Enable Register - FIRQENR
;         ┌┬───────── Bit  7-6 - Unused
;         ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
;         │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
;         ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
;         │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
;         ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
;         │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
GIME_TimerMSB_FF94                  EQU $FF94
GIME_TimerLSB_FF95                  EQU $FF95
GIME_VideoMode_FF98                 EQU $FF98
GIME_VideoResolution_FF99           EQU $FF99
GIME_BorderColor_FF9A               EQU $FF9A
GIME_VideoBankSelect_FF9B           EQU $FF9B
GIME_VerticalScroll_FF9C            EQU $FF9C
GIME_VerticalOffset1_FF9D           EQU $FF9D
GIME_VerticalOffset0_FF9E           EQU $FF9E
GIME_HorizontalOffset_FF9F          EQU $FF9F

MMU_BLOCK_REGISTERS_FFA0            EQU $FFA0
ColorPaletteFirstRegister_FFB0      EQU $FFB0
SAM_Video_Display_Registers_FFC0    EQU $FFC0
ClearClockSpeedR0_FFD6              EQU $FFD6
SetClockSpeedR0_FFD7                EQU $FFD7
ClearClockSpeedR1_FFD8              EQU $FFD8
SetClockSpeedR1_FFD9                EQU $FFD9
RomMode_FFDE                        EQU $FFDE
RamMode_FFDF                        EQU $FFDF


    BRA >
* Tested with MAME, 100 times the FIRQ was triggered between each VSYNC IRQ
* MAME scanline delay count before the scanline is really at 00 (I think??  From CoCo 3 Mame info...)
* Triggered 100 times between each IRQ, which delays it 18 times

FIRQ_Between_IRQs   EQU 99   	* Tested with MAME, 99 times the FIRQ was triggered between each VSYNC IRQ
IRQ_Delay_Count     EQU 59   	* MAME scanline delay count before the scanline should be in the middle of the screen (From CoCo 3 Mame info...)
FIRQ_Countdown      EQU $0254  	* $254=6005.950455 samples per second
FIRQCountDown       FCB 61     	* FIRQ counts this value down to keep track of where the scanline is being drawn
TestPointer         FDB $4000
TestPointerA        FCB 0

MaxMaps             EQU     6*12         ; 6 blocks per screen * 13-1 screens


FIRQ_Count          EQU 25
FIRQCount           RMB 1  * Keep track of counter for each 1/4 of the screen (this is used in the FIRQ) - $A0FE

VideoBeam  			FCB 0      * Where the current scanline is being drawn on screen
SoundBytes          FDB 0
DoSoundLoop         FCB 0       * 0 = No loop, <> 0 = Loop sound
SampleStart         FDB $7FFF
DoingSpritesFlag    FCB 0       * 1 if IRQ is in progress, 0 if not

ToggleTop           FCB 0
ToggleBot           FCB 0

VideoRamBlock                       FCB     %00000010   ; Set default to 1 Meg to 1.5 Meg location
VerticalPosition                    FDB     $0000       ; Offset
HorizontalPosition                  FCB     %10000000   ; Bit 7 set = Horizontal scrolling enabled
MapViewBlock                        FCB     $80         ; Map location in Memory to view

!   ORCC    #$50
* Setup and enable the FIRQ

; Good values for a screen with 192 rows
FIRQ_Delay0     EQU     46
FIRQ_Delay1     EQU     18
FIRQ_Delay2     EQU     18
FIRQ_Delay3     EQU     255
; Delay0 scanline is at 192 and ends at row  47  (bottom of the sprite is from 144 to 191)
; Delay1 scanline is at  48 and ends at row  95  (bottom of the sprite is from   0 to  47)
; Delat2 scanline is at  96 and ends at row 143  (bottom of the sprite is from  48 to  95)
; Delay3 scanline is at 144 and ends at row 191  (bottom of the sprite is from  96 to 143)
CheckSprite0    EQU     191     ; If lower than this value and hasn't been drawn then draw it
CheckSprite1    EQU     47      ; If lower than this value and hasn't been drawn then draw it
CheckSprite2    EQU     95      ; If lower than this value and hasn't been drawn then draw it
CheckSprite3    EQU     143     ; If lower than this value and hasn't been drawn then draw it

; Good values for a screen with 200 rows
;FIRQ_Delay0     EQU     45
;FIRQ_Delay1     EQU     20
;FIRQ_Delay2     EQU     18
;FIRQ_Delay3     EQU     255
; Delay0 scanline is at 200 and ends at row  49  (bottom of the sprite is from 150 to 199)
; Delay1 scanline is at  50 and ends at row  99  (bottom of the sprite is from   0 to  49)
; Delat2 scanline is at 100 and ends at row 149  (bottom of the sprite is from  50 to  99)
; Delay3 scanline is at 150 and ends at row 199  (bottom of the sprite is from 100 to 149)
;CheckSprite0    EQU     199     ; If lower than this value and hasn't been drawn then draw it
;CheckSprite1    EQU     49      ; If lower than this value and hasn't been drawn then draw it
;CheckSprite2    EQU     99      ; If lower than this value and hasn't been drawn then draw it
;CheckSprite3    EQU     149     ; If lower than this value and hasn't been drawn then draw it

; Good values for a screen with 225 rows
;FIRQ_Delay0     EQU     38
;FIRQ_Delay1     EQU     21
;FIRQ_Delay2     EQU     21
;FIRQ_Delay3     EQU     255
; Delay0 scanline is at 225 and ends at row  55  (bottom of the sprite is from 168 to 226)
; Delay1 scanline is at  56 and ends at row 111  (bottom of the sprite is from   0 to  55)
; Delat2 scanline is at 112 and ends at row 167  (bottom of the sprite is from  56 to 111)
; Delay3 scanline is at 168 and ends at row 224  (bottom of the sprite is from 112 to 167)
;CheckSprite0    EQU     226     ; If lower than this value and hasn't been drawn then draw it
;CheckSprite1    EQU     55      ; If lower than this value and hasn't been drawn then draw it
;CheckSprite2    EQU     111     ; If lower than this value and hasn't been drawn then draw it
;CheckSprite3    EQU     167     ; If lower than this value and hasn't been drawn then draw it

    JSR     SetupInterruptSources

    LDA     #$7E                                * Write the JMP instruction if it's possible to use Direct Page for the sample playback then use $0E = direct page JMP location, and 1 byte for address
    STA     FIRQ_Jump_position_FEF4     
    LDX     #DoFIRQ                             * Address for FIRQ
    STX     FIRQ_Jump_position_FEF4+1           * Update the FIRQ Jump address

* Setup and enable the IRQ
    LDA     #$7E                                * Write the JMP instruction
    STA     IRQ_Jump_position_FEF7              *
    LDX     #VSyncIRQ                           * Address for IRQ
    STX     IRQ_Jump_position_FEF7+1            * Point the IRQ to the VSyncIRQ address

;             Interrupt Request Enable Register - IRQENR
;             ┌┬───────── Bit  7-6 - Unused
;             ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
;             │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
;             ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
;             │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
;             ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
;             │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
    LDA     #%00001000                          *
    STA     GIME_InterruptReqEnable_FF92        * Enable only the Vertical Border Sync (VBORD) Interrupt
    LDD     #FIRQ_Countdown                     * This is the speed the audio samples will playback at
    STD     GIME_TimerMSB_FF94                  * Set countdown Timer to $0254 - good for 6005.95 Hz samples
                                                * This Frequency is tied to the FIRQ and scanline counter, it must be $0254 and samples must be 6005.95 Hz

;             Fast Interrupt Request Enable Register - FIRQENR
;             ┌┬───────── Bit  7-6 - Unused
;             ││┌──────── Bit  5   - TMR (1 = Enable timer IRQ, 0 = disable)
;             │││┌─────── Bit  4   - HBORD (1 = Enable Horizontal border Sync IRQ, 0 = disable)
;             ││││┌────── Bit  3   - VBORD (1 = Enable Vertical border Sync IRQ, 0 = disable)
;             │││││┌───── Bit  2   - EI2 (1 = Enable RS232 Serial data IRQ, 0 = disable)
;             ││││││┌──── Bit  1   - EI1 (1 = Enable Keyboard IRQ, 0 = disable)
;             │││││││┌─── Bits 0   - EI0 (1 = Enable Cartridge IRQ, 0 = disable)
    LDA     #%00100000                          *
    STA     GIME_FastInterruptReqEnable_FF93    * Enable TIMER

;             Initialization Register 0 - INIT0 
;             ┌────────── Bit  7   - CoCo Bit (0 = CoCo 3 Mode, 1 = CoCo 1/2 Compatible)
;             │┌───────── Bit  6   - M/P (1 = MMU enabled, 0 = MMU disabled)
;             ││┌──────── Bit  5   - IEN (1 = GIME IRQ output enabled to CPU, 0 = disabled)
;             │││┌─────── Bit  4   - FEN (1 = GIME FIRQ output enabled to CPU, 0 = disabled)
;             ││││┌────── Bit  3   - MC3 (1 = Vector RAM at FEXX enabled, 0 = disabled)
;             │││││┌───── Bit  2   - MC2 (1 = Standard SCS (DISK) (0=expand 1=normal))
;             ││││││┌┬─── Bits 1-0 - MC1-0 (10 = ROM Map 32k Internal, 0x = 16K Internal/16K External, 11 = 32K External - Except Interrupt Vectors)
    LDA     #%01111100                          *
    STA     GIME_InitializeRegister0_FF90       * CoCo 3 Mode, MMU Enabled, GIME IRQ Disabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext

        JSR     SetupBank_37
        JSR     SetupBank_0
        JSR     SetupBank_1
        JSR     SetupBank_2

        ANDCC   #%00001111                          * Enable the FIRQ & IRC
        BRA     *

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
