FIRQ_Jump_position_FEF4             EQU $FEF4	* Store $7E here which is the FIRQ JMP opcode
IRQ_Jump_position_FEF7              EQU $FEF7	* Store $7E here which is the IRQ JMP opcode

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