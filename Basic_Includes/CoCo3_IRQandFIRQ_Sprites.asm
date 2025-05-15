; VSYNC IRQ Main handler
; Handle sound timer
MainIRQ_Handler:
        LDA     GIME_InterruptReqEnable_FF92    ; Re enable the VSYNC IRQ
        LDX     >SoundDuration                  ; Get the new Sound duration value
        BEQ     >                               ; RETURN IF TIMER = 0
        LEAX    -1,X                            ; DECREMENT TIMER IF NOT = 0
        STX     >SoundDuration                  ; Save the new Sound duration value
; Handle TIMER
!       INC     >_Var_Timer+1                   ; Increment the LSB of the Timer Value
        BNE     >                               ; Skip ahead if not zero
        INC     >_Var_Timer                     ; Increment the MSB of the Timer Value
!       RTI

*****************************************
* FIRQ stuff
*****************************************
DoSoundLoop             FCB     0               ; 0 = No loop, <> 0 = Loop sound
SampleStart             FDB     $7FFF
*****************************************
* CoCo 3 Audio suport
* Code to handle sound functions when we just completed playing a sample
SampleIsDone:
        LDA     >DoSoundLoop                    ; If DoSoundLoop <> 0 then we loop forever
        BEQ     >                               ; If DoSoundLoop = 0 then we end sound
        LDA     >SampleStart
        STA     >GetSample+1
        LDA     >SampleStart+1
        STA     >GetSample+2                    ; Sample pointer is now pointing to the start
        BRA     GetSample                       ; Go play the sample from the beginning again
!
        LDA     #FIRQNoAudio/256
        STA     FIRQ_Jump_position_FEF4+1
        LDA     #FIRQNoAudio-(FIRQNoAudio/256*256)
        STA     FIRQ_Jump_position_FEF4+2       ; Change the Sample playback FIRQ to FIRQNoAudio

        CLRA
        BRA     SendAudio

DoFIRQ:
*****************************************
* Audio off - Just re-enable the FIRQ and return
FIRQNoAudio:
        STA     >FIRQ0Restore+1                 ; Save exit value of A
        LDA     GIME_FastInterruptReqEnable_FF93 ; Re enable the FIRQ and get FIRQ type
        CLRA
        BRA     SendAudio                       ; A = 0 so send it to audio out and continue
        opt     cd
        opt     cc                
FIRQ_Sound:
        STA     >FIRQ0Restore+1                 ; Save exit value of A
        LDA     GIME_FastInterruptReqEnable_FF93 ; Re enable the FIRQ
        LDA     #%00100001
        STA     GIME_InitializeRegister1_FF91   ; Mem Type 64k chips, 279.365 nsec timer, MMU Task 1 - $FFB0-$FFB7 - Audio sample banks
        INC     >GetSample+2                    ; LSB = LSB + 1
        BNE     GetSample                       ; If we didn't hit zero skip ahead
        INC     >GetSample+1                    ; MSB = MSB + 1
        BMI     SampleIsDone                    ; If we get to $8000 then we are done playing this sample
GetSample:
        LDA     >$FFFF
SendAudio:
        STA     PIA1SideADataRegister_FF20      ; Send audio to the DAC
        LDA     #%00100000        
        STA     GIME_InitializeRegister1_FF91   ; Mem Type 64k chips, 279.365 nsec timer, MMU Task 0 - $FFA0-$FFA7 - Normal
FIRQ0Restore:
        LDA     #$FF                            ; Self modified from above upon FIRQ entry
        RTI                                     ; Return from the FIRQ