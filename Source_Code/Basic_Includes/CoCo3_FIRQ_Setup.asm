* Setup and enable the IRQs for the CoCo 3
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

* This code masks off the two low bits written to $FF20 - we wont need this since we had to compress the audio but it is a neat feature
* So you can send the PCM Unsigned 8 Bit sample as is, no masking needed
        LDA     PIA1SideAControlRegister_FF21
        PSHS    A
        ANDA    #%00110011            	* FORCE BIT2 LOW
        STA     PIA1SideAControlRegister_FF21   ; $FF20 NOW DATA DIRECTION REGISTER
        LDA     #%11111100            	* OUTPUT ON DAC, INPUT ON RS-232 & CDI
        STA     PIA1SideADataRegister_FF20      ; PIA1_Byte_0_IRQ
        PULS    A
        STA     PIA1SideAControlRegister_FF21                   ; PIA1_Byte_1_IRQ

* Configure Audio settings
        LDA     PIA0SideAControlRegister_FF01       ; SELECT SOUND OUT
        ANDA    #$F7                  	* RESET LSB OF MUX BIT
        STA     PIA0SideAControlRegister_FF01       ; STORE
        LDA     PIA0SideBControlRegister_FF03       ; SELECT SOUND OUT
        ANDA    #$F7                  	* RESET MSB OF MUX BIT
        STA     PIA0SideBControlRegister_FF03       ; STORE
* Enable 6 Bit DAC output
        LDA     PIA1SideBControlRegister_FF23       ; GET PIA
        ORA     #%00001000              * SET 6-BIT SOUND ENABLE
        STA     PIA1SideBControlRegister_FF23       ; STORE

;             Initialization Register 0 - INIT0 
;             ┌────────── Bit  7   - CoCo Bit (0 = CoCo 3 Mode, 1 = CoCo 1/2 Compatible)
;             │┌───────── Bit  6   - M/P (1 = MMU enabled, 0 = MMU disabled)
;             ││┌──────── Bit  5   - IEN (1 = GIME IRQ output enabled to CPU, 0 = disabled)
;             │││┌─────── Bit  4   - FEN (1 = GIME FIRQ output enabled to CPU, 0 = disabled)
;             ││││┌────── Bit  3   - MC3 (1 = Vector RAM at FEXX enabled, 0 = disabled)
;             │││││┌───── Bit  2   - MC2 (1 = Standard SCS (DISK) (0=expand 1=normal))
;             ││││││┌┬─── Bits 1-0 - MC1-0 (10 = ROM Map 32k Internal, 0x = 16K Internal/16K External, 11 = 32K External - Except Interrupt Vectors)
    LDA     #%01111100                          *
    STA     GIME_InitializeRegister0_FF90       * CoCo 3 Mode, MMU Enabled, GIME IRQ Enabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext

; Set graphics mode to text
    LDX    #$0400        ; C$ = "Text screen starts here        ; GoSub AO
    STX    BEGGRP        ; C$ = "Update the Screen starting location        ; GoSub AO
    LDA    #$0F        ; C$ = "$0F Back to Text Mode for the CoCo 3        ; GoSub AO
    STA    $FF9C        ; C$ = "Neccesary for CoCo 3 GIME to use this mode        ; GoSub AO
; Go to CoCo 3 Text mode
    LDA    #$CC        ; GoSub AO
    STA    $FF90        ; GoSub AO
    LDD    #$0000        ; GoSub AO
    STD    $FF98        ; GoSub AO
    STD    $FF9A        ; GoSub AO
    STD    $FF9E        ; GoSub AO
    LDD    #$0FE0        ; GoSub AO
    STD    $FF9C        ; GoSub AO
    LDA    #Internal_Alphanumeric        ; C$ = "A = Text mode requested        ; GoSub AO
; Update the Graphic mode and the screen viewer location
    JSR    SetGraphicModeA        ; C$ = "Go setup the mode        ; GoSub AO
    LDA    BEGGRP        ; C$ = "Get the MSB of the Screen starting location        ; GoSub AO
    LSRA        ; C$ = "Divide by 2 - 512 bytes per start location        ; GoSub AO
    JSR    SetGraphicsStartA        ; C$ = "Go set the address of the screen        ; GoSub AO

    ;         Initialization Register 1 - INIT1
    ;         ┌────────── Bit  7   - Unused
    ;         │┌───────── Bit  6   - Memory type (1=256K, 0=64K chips)
    ;         ││┌──────── Bit  5   - Timer input clock source (1 = 0.279365 microseconds, 0 = 63.695 microseconds)
    ;         │││┌┬┬┬──── Bits 4-1 - Unused
    ;         │││││││┌─── Bits 0   - MMU Task Register select (0=enable $FFA0-$FFA7, 1=enable $FFA8-$FFAF)
    lda     #%00100000
    sta     GIME_InitializeRegister1_FF91               ; Timer 63.695 usec (*10^-6, low speed); MMU $FFA0-$FFA7 task selected

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

FIRQ_Countdown      EQU $0254  	* $254=6005.950455 samples per second, must not change or sprite draw timing will be out of sync
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

    LDA     #$7E                                ; Write the JMP instruction if it's possible to use Direct Page for the sample playback then use $0E = direct page JMP location, and 1 byte for address
; Setup the jump to the FIRQ
    STA     FIRQ_Jump_position_FEF4             ; Write JMP instruction for the FIRQ
    LDX     #DoFIRQ                             ; Address for FIRQ
    STX     FIRQ_Jump_position_FEF4+1           ; Update the FIRQ Jump address
; Setup the jump to the IRQ
    STA     IRQ_Jump_position_FEF7              ; Write JMP instruction for the IRQ
    LDX     #BASIC_IRQ                          ; Address for IRQ
    STX     IRQ_Jump_position_FEF7+1            ; Point the IRQ to the BASIC_IRQ address
