; Print Command
; Print number in D to serial device
PRINT_D_Serial:
        TSTA              ; See if the value is negative or positive
        BPL     >         ; Skip ahead if positive
        COMA
        COMB
        ADDD    #$0001    ; Make D a positive number
        PSHS    D         ; Save D on the stack
        LDA     #109-$40  ; 109 = minus sign
        BRA     PRINT_D1_Serial  ; Skip ahead
!       PSHS    D         ; Save D on the stack
        LDA     #96-$40   ; 96 = space (blank)
PRINT_D1_Serial:
        JSR     AtoSerialPort
        CLR     _Var_PF00 ; This will be the tenthousands
        CLR     _Var_PF01 ; This will be the thousands
        CLR     _Var_PF02 ; This will be the hundreds
        CLR     _Var_PF03 ; This will be the tens
        CLR     _Var_PF04 ; This will be the ones
        LDD     ,S++      ; D = value to convert to Decimal
!       SUBD    #10000
        BLO     >
        INC     _Var_PF00
        BRA     <
!       ADDD    #10000    ; We now have the ten thousands
!       SUBD    #1000
        BLO     >
        INC     _Var_PF01
        BRA     <
!       ADDD    #1000       ; We now have the thousands
!       SUBD    #100
        BLO     >
        INC     _Var_PF02
        BRA     <
!       ADDD    #100        ; We now have the hundreds
!       SUBD    #10
        BLO     >
        INC     _Var_PF03
        BRA     <
!       ADDD    #10         ; We now have the tens
!       SUBD    #1
        BLO     >
        INC     _Var_PF04
        BRA     <
!
; We now have the ones
* Print the value on screen
        LDA     _Var_PF00
        BEQ     >
        ADDA    #$30
        BSR     AtoSerialPort
        BRA     Print1000sSerial
!       LDA     _Var_PF01
        BEQ     >
        ADDA    #$30
        BSR     AtoSerialPort
        BRA     Print100sSerial
!       LDA     _Var_PF02
        BEQ     >
        ADDA    #$30
        BSR     AtoSerialPort
        BRA     Print10sSerial
!       LDA     _Var_PF03
        BEQ     >
        ADDA    #$30
        BSR     AtoSerialPort
        BRA     Print1sSerial
!       LDA     _Var_PF04
        ADDA    #$30
        BSR     AtoSerialPort
        LDA     #$20        ; Blank
        BRA     AtoSerialPort ; Print A on the screen and return, Done
Print1000sSerial:
        LDA     _Var_PF01
        ADDA    #$30
        BSR     AtoSerialPort
Print100sSerial:
        LDA     _Var_PF02
        ADDA    #$30
        BSR     AtoSerialPort
Print10sSerial:
        LDA     _Var_PF03
        ADDA    #$30
        BSR     AtoSerialPort
Print1sSerial:
        LDA     _Var_PF04
        ADDA    #$30
        BSR     AtoSerialPort
        LDA     #$20        ; Blank
        BRA     AtoSerialPort ; Print A on the screen and return

AtoSerialPort:
LA2BF           PSHS        X,B,A,CC        ; SAVE REGISTERS AND INTERRUPT STATUS
                ORCC        #$50            ; DISABLE IRQ,FIRQ
LA2C3           LDB         PIA1+2          ; GET RS 232 STATUS
                LSRB                        ; SHIFT RS 232 STATUS BIT INTO CARRY
                BCS         LA2C3           ; LOOP UNTIL READY
                BSR         LA2FB           ; SET OUTPUT TO MARKING
                CLRB                        ;
                BSR         LA2FD           ; TRANSMIT ONE START BIT
                LDB         #8              ; SEND 8 BITS
LA2D0           PSHS        B               ; SAVE BIT COUNTER
                CLRB                        ; CLEAR DA IMAGE I ZEROES TO DA WHEN SENDING RS 232 DATA
                LSRA                        ; ROTATE NEXT BIT OF OUTPUT CHARACTER TO CARRY FLAG
                ROLB                        ; ROTATE CARRY FLAG INTO BIT ONE
                ASLB                        ; AND ALL OTHER BITS SET TO ZERO
                BSR         LA2FD           ; TRANSMIT DATA BYTE
                PULS        B               ; GET BIT COUNTER
                DECB                        ; SENT ALL 8 BITS?
                BNE         LA2D0           ; NO
                BSR         LA2FB           ; SEND STOP BIT (ACCB:0)
                PULS        CC,A            ; RESTORE OUTPUT CHARACTER & INTERRUPT STATUS
                CMPA        #CR             ; IS IT CARRIAGE RETURN?
                BEQ         LA2ED           ; YES
                INC         LPTPOS          ; INCREMENT CHARACTER COUNTER ($9C)
                LDB         LPTPOS          ; CHECK FOR END OF LINE PRINTER LINE ($9C)
                CMPB        LPTWID          ; AT END OF LINE PRINTER LINE? ($9B)
                BLO         LA2F3           ; NO
LA2ED           CLR         LPTPOS          ; RESET CHARACTER COUNTER
                BSR         LA305
                BSR         LA305           ; DELAY FOR CARRIAGE RETURN
LA2F3           LDB         PIA1+2          ; WAIT FOR HANDSHAKE
                LSRB                        ; CHECK FOR R5232 STATUS?
                BCS         LA2F3           ; NOT YET READY
                PULS        B,X,PC          ; RESTORE REGISTERS
                
LA2FB           LDB         #2              ; SET RS232 OUTPUT HIGH (MARKING)
LA2FD           STB         DA              ; STORE TO THE D/A CONVERTER REGISTER
                BSR         LA302           ; GO WAIT A WHILE
LA302           LDX         LPTBTD          ; GET BAUD RATE ($95)
                BRA         >               ; Skip forward
LA305           LDX         LPTLND          ; PRINTER CARRIAGE RETURN DELAY ($97)
* DELAY WHILE DECREMENTING X TO ZERO
!               LEAX        -1,X            ; DECREMENT X
                BNE         <               ; BRANCH IF NOT ZERO
                RTS