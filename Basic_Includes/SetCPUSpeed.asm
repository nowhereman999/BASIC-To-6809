; Set the CPU Speed
;
; Normal speed is 28.63636 divided by 32 = 0.89488625 Mhz
; Double speed is 28.63636 divided by 16 = 1.7897725 Mhz
;   High speed is 28.63636 divided by 10 = 2.863636 Mhz
;
; Enter with value in B
; If B=1 then set the CPU in Emulation mode and set the speed at .895 Mhz
; If B=2 then set the CPU in Emulation mode and set the speed at 1.79 Mhz
; If B=3 then set the CPU in Emulation mode and set the speed at 2.864 MHz
; If B is anything else then the CPU will be set in Native mode and run at it's max speed
;
SetCPUSpeedB:
        STB     CPUSpeed                ; Save the speed the user wants
; Enter here and it will set the CPU speed to tha last value the user wants the CPU to run at
SetCPUSpeed:
        LDA     >CoCoHardware           ; Get the CoCo Hardware info byte
        BPL     >                       ; If bit 7 is clear then skip forward it's a 6809
        FCB     $11,$3D,%00000000       ; otherwise, put the 6309 in emulation mode.  This is LDMD  #%00000000
!       LDB     CPUSpeed
        DECB
        BEQ     SetSpeed1               ; Set the CPU to .895 Mhz
        DECB
        BEQ     SetSpeed2               ; Set the CPU to 1.79 Mhz
        DECB
        BEQ     MaxCPUSpeed             ; Set the CPU to 2.864 Mhz
SetSpeedMax:
; If we get here, the user wants the computer to run at max speed for this hardware
        LDA     >CoCoHardware           ; Get the CoCo Hardware info byte
        BPL     >                       ; If bit 7 is clear then skip forward it's a 6809
        FCB     $11,$3D,%00000001       ; otherwise, put the 6309 in native mode.  This is LDMD  #%00000001
!       RORA                            ; Move bit 0 to the Carry bit
        BCC     >                       ; if the Carry bit is clear, then not a CoCo 3, skip ahead
MaxCPUSpeed:
        LDA     #$5A                    ; Command for GIME-X & GIME-Z for triple speed mode
        STA     >$FFD9                  ; Put CoCo 3 in doouble speed mode
SetSpeed2:
        STA     >$FFD9                  ; Try CoCo 3 in 2.89 speed mode
!       RTS
SetSpeed1:
        STA     >$FFD8                  ; Put CoCo 3 in Normal speed mode
        RTS
CPUSpeed        FCB     $00             ; current value the user wants the computer to run at (default = 0 Max speed)