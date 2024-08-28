; AUDIO Muxing Routines
; Used by JOYSTK() and AUDIO ON/OFF, maybe others in the future
; THESE ROUTINES WILL ENABLE/DISABLE THE ANALOG MUX
AnalogMuxOff:
                CLRA                        ; BIT 3 OF ACCA = 0, DISABLE ANALOG MUX
                FCB         $8C             ; SKIP TWO BYTES
AnalogMuxOn:
                LDA         #8              ; BIT 3 OF ACCA = 1, ENABLE ANALOG MUX
                STA         ,-S             ; SAVE ACCA ON STACK
                LDA         $FF23           ; GET CONTROL REGISTER OF PIA1, PORT B
                ANDA        #$F7            ; RESET BIT 3
                ORA         ,S+             ; OR IN BIT 3 OF ACCA (SAVED ON STACK)
                STA         $FF23           ; SET/RESET CB2 OF U4
                RTS

; THIS ROUTINE WILL TRANSFER BIT 0 OF ACCB TO SEL 1 OF
; THE ANALOG MULTIPLEXER AND BIT 1 OF ACCB TO SEL 2.
Select_AnalogMuxer:
                LDU         #$FF01          ; POINT U TO PIA0 CONTROL REG
                BSR         >               ; PROGRAM 1ST CONTROL REGISTER
!               LDA         ,U              ; GET PIA CONTROL REGISTER
                ANDA        #$F7            ; RESET CA2 (CB2) OUTPUT BIT
                ASRB                        ; SHIFT ACCB BIT 0 TO CARRY FLAG
                BCC         >               ; BRANCH IF CARRY = ZERO
                ORA         #$08            ; FORCE BIT 3=1; SET CA2(CB2)
!               STA         ,U++            ; PUT IT BACK IN THE PIA CONTROL REGISTER
                RTS
