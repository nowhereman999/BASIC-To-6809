; Print Command
; Print number in D on text screen
PRINT_D:
        TSTA              ; See if the value is negative or positive
        BPL     >         ; Skip ahead if positive
        COMA
        COMB
        ADDD    #$0001    ; Make D a positive number
        PSHS    D         ; Save D on the stack
        LDA     #109-$40  ; 109 = minus sign
        BRA     PRINT_D1  ; Skip ahead
!       PSHS    D         ; Save D on the stack
        LDA     #96-$40   ; 96 = space (blank)
PRINT_D1:
        JSR     PrintA_On_Screen
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
        BSR     PrintA_On_Screen
        BRA     Print1000s
!       LDA     _Var_PF01
        BEQ     >
        ADDA    #$30
        BSR     PrintA_On_Screen
        BRA     Print100s
!       LDA     _Var_PF02
        BEQ     >
        ADDA    #$30
        BSR     PrintA_On_Screen
        BRA     Print10s
!       LDA     _Var_PF03
        BEQ     >
        ADDA    #$30
        BSR     PrintA_On_Screen
        BRA     Print1s
!       LDA     _Var_PF04
        ADDA    #$30
        BSR     PrintA_On_Screen
        LDA     #$20        ; Blank
        BRA     PrintA_On_Screen ; Print A on the screen and return, Done
Print1000s:
        LDA     _Var_PF01
        ADDA    #$30
        BSR     PrintA_On_Screen
Print100s:
        LDA     _Var_PF02
        ADDA    #$30
        BSR     PrintA_On_Screen
Print10s:
        LDA     _Var_PF03
        ADDA    #$30
        BSR     PrintA_On_Screen
Print1s:
        LDA     _Var_PF04
        ADDA    #$30
        BSR     PrintA_On_Screen
        LDA     #$20        ; Blank
        BRA     PrintA_On_Screen ; Print A on the screen and return
UpdateCursor:
        PSHS  D,X
        BRA     LA344
        
PrintA_On_Screen:
* PUT CHARACTER ON THE SCREEN
LA30A:  PSHS  D,X
        LDX   CURPOS
        CMPA  #$08        * Is it a backspace?
        BNE   LA31D
        CMPX  #$400       * Start of the screen?
        BEQ   LA35D       * Retore the registers and return
        LDA   #$60        * Blank
        STA   ,-X
        BRA   LA344
LA31D:  CMPA  #$0D        * Enter Key?
        BNE   LA32F
        LDX   CURPOS
LA323:  LDA   #$60        * Blank
        STA   ,X+
        TFR   X,D
        BITB  #$1F
        BNE   LA323
        BRA   LA344
LA32F:  CMPA  #$20        * Is it a SPACE?
        BLO   LA35D       * If it's lower it's some kind of control character so restore the registers and return
        TSTA
        BMI   LA342       * If it's higher than 127 then print it as is
        CMPA  #$40        * Is it lower than $40?
        BLO   LA340       * If so then XOR it with %01000000, then print it
        CMPA  #$60        * Is it lower than $60?
        BLO   LA342       * If so then Print character as is
        ANDA  #%11011111  * otherwise Clear bit 5
LA340:  EORA  #%01000000  * XOR bit 6
LA342:  STA   ,X+
LA344:  STX   CURPOS
        CMPX  #$05FF      * End of screen
        BLS   LA35D       * Retore the registers and return
* Otherwise scroll the screen (Fastest method I can think of for 6809)
ScrollTextScreen:
        PSHS    CC,DP,Y,U
        STS     DoneScroll+2    * Save the Stack pointer (self mod below)
* 68 * 7 = 476 need to move an extra 4 bytes at the end to equal 480 bytes (15 rows of 32 bytes)
        ORCC    #$50
        LDU     #$400+4   ; Set U as the destination address of the top line on the screen
        LEAS    $20-4,U   ; Set S as the source as the line below $420
        PULS    D,X       ; Get the first 4 bytes
        PSHU    D,X       ; Save the first 4 bytes
!       LEAU    -32+7,S   ; Move U forward
        PULS    D,DP,X,Y  ; Get the source data
        PSHU    D,DP,X,Y  ; Write the destination data
        LEAU    -32+7,S   ; Move U forward
        PULS    D,DP,X,Y  ; Get the source data
        PSHU    D,DP,X,Y  ; Write the destination data
        LEAU    -32+7,S   ; Move U forward
        PULS    D,DP,X,Y  ; Get the source data
        PSHU    D,DP,X,Y  ; Write the destination data
        LEAU    -32+7,S   ; Move U forward
        PULS    D,DP,X,Y  ; Get the source data
        PSHU    D,DP,X,Y  ; Write the destination data
        CMPS    #$600     ; Is S past the end of the screen yet?
        BNE     <
        LDD     #$6060    ; make the bottom row blank
        LDX     #$6060    ; make the bottom row blank
        LEAY    ,X        ; make the bottom row blank
        PSHS    D,X,Y
        PSHS    D,X,Y
        PSHS    D,X,Y
        PSHS    D,X,Y
        PSHS    D,X,Y
        STD     -2,S      ; Clear the bottom row
DoneScroll:
        LDS     #$FFFF    ; Restore the Stack
        PULS    CC,DP,Y,U  * Restore all
        LDX     #$5E0
        STX     CURPOS    ; Make the CURPOS the bottom left corner of the screen+1
LA35D:  PULS    D,X,PC    ; Restore D & X and return
