* Convert value in D to a Hex string value
* X points to the string variable location in RAM
* If it's a new string then you should do a CLR   ,X   before jumping to this routine
DHex_Flag RMB   1         ; Flag whether we have printed a digit yet
DHex_to_String_at_X:
        PSHS    D         ; Save D on the stack
        CLR     DHex_Flag ; Clear the flag, we haven't printed a value yet
        LSRA
        LSRA
        LSRA
        LSRA              ; move left nibble to the right
        BEQ     DHex_2nd_digit  ; if the first digit is a zero we skip it, to act like BASIC
        CMPA    #10
        BLO     >
        ADDA    #-10+$11  ; if it's 10 or more then we need to show 10 as A, 11 as B, etc
!       ADDA    #$30      ; make it the ASCII value
        BSR     DHex_StoreA_in_String
        INC     DHex_Flag ; make the value non zero since we have now printed a character
DHex_2nd_digit:
        LDA     ,S+       ; Get A again, move stack pointer to the next byte
        TST     DHex_Flag ; check if we have printed a value if so we must print everything from now on
        BNE     >
        ANDA    #%00001111 ; save the LS nibble
        BEQ     DHex_3rd_digit  ; if the first digit is a zero we skip it, to act like BASIC
!       ANDA    #%00001111 ; save the LS nibble
        CMPA    #10
        BLO     >
        ADDA    #-10+$11    ; if it's 10 or more then we need to show 10 as A, 11 as B, etc
!       ADDA    #$30      ; make it the ASCII value
        BSR     DHex_StoreA_in_String
        INC     DHex_Flag ; make the value non zero since we have now printed a character
DHex_3rd_digit:
        LDA     ,S       ; get the 2nd byte in D
        TST     DHex_Flag ; check if we have printed a value if so we must print everything from now on
        BNE     >
        ANDA    #%11110000
        BEQ     DHex_4th_digit  ; if the first digit is a zero we skip it, to act like BASIC
!       LSRA
        LSRA
        LSRA
        LSRA              ; move left nibble to the right
        CMPA    #10
        BLO     >
      ADDA    #-10+$11      ; if it's 10 or more then we need to show 10 as A, 11 as B, etc
!       ADDA    #$30      ; make it the ASCII value
        BSR     DHex_StoreA_in_String
        INC     DHex_Flag ; make the value non zero since we have now printed a character
DHex_4th_digit:
        LDA     ,S+       ; get the 2nd byte in D and fix stack pointer
!       ANDA    #%00001111 ; save the LS nibble
        CMPA    #10
        BLO     >
      ADDA    #-10+$11     ; if it's 10 or more then we need to show 10 as A, 11 as B, etc
!       ADDA    #$30      ; make it the ASCII value
DHex_StoreA_in_String:
        PSHS    X         ; Save X = length of the string
        INC     ,X        ; increase the length of the string by one
        LDB     ,X        ; get the new length of the string
        ABX               ; move X to the new end of string
        STA     ,X        ; save A at the end of the string
        PULS    X,PC      ; restore X and Return
