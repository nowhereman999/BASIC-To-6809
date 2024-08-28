PlaySound:
        CLRB
        BSR     Select_AnalogMuxer  ; CONNECT D/A SOUND INPUT TO OUTPUT OF SOUND MUX
        BSR     AnalogMuxOn   ; TURN ON AUDIO - ENABLE SOUND MUX

        BSR     LA985         ; STORE 2.5 VOLTS TO D/A AND WAIT
        LDA     #$FE          ; DATA TO MAKE D/A OUT = 5 VOLTS
        BSR     LA987         ; STORE IT TO D/A AND WAIT
        BSR     LA985         ; STORE 2.5 VOLTS TO D/A AND WAIT
        LDA     #$02          ; DATA TO MAKE D/A OUT = 0 VOLTS
        BSR     LA987         ; STORE IT TO D/A AND WAIT
        LDX     SoundDuration ; * IS SoundDuration = 0 - THE IRQ INTERRUPT SERVICING ROUTINE WILL DECREMENT SoundDuration
        BNE     PlaySound     ; NOT DONE YET
	RTS          	      ; RETURN

LA985   LDA     #$7E          ; DATA VALUE TO MAKE D/A OUTPUT = 2.5 VOLTS
LA987   STA     $FF20         ; STORE IT IN D/A
        LDA     SoundTone     ; GET FREQUENCY
LA98C   INCA                  ; INCREMENT IT
        BNE     LA98C         ; LOOP UNTIL DONE
        RTS		      ; RETURN         