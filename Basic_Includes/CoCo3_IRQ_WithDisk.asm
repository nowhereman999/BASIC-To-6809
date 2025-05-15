; Handle Disk Motor
        LDA     >RDYTMR        ; GET TIMER
        BEQ     >MainIRQ_Handler   ; BRANCH IF NOT ACTIVE
        DECA                  ; DECREMENT THE TIMER
        STA     >RDYTMR        ; SAVE IT
        BNE     MainIRQ_Handler      ; BRANCH IF NOT TIME TO TURN OFF DISK MOTORS
        LDA     >DRGRAM        ; GET DSKREG IMAGE
        ANDA    #$B0          ; TURN ALL MOTORS AND DRIVE SELECTS OFF
        STA     >DRGRAM        ; PUT IT BACK IN RAM IMAGE
        STA     >DSKREG        ; SEND TO CONTROL REGISTER (MOTORS OFF)