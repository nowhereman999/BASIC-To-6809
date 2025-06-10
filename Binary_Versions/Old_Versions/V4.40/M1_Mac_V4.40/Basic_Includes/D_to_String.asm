* Convert value in D to a string value
* X points to the string variable location in RAM
* _String_AStr    FCB     $00     ; String Variable AStr length (0 to 255) initialized to 0
*         RMB     255           ; 255 bytes available for string variable AStr
D_to_String_at_X:
        CLR     ,X        ; Clear the string variable
        TSTA              ; See if the value is negative or positive
        BPL     >         ; Skip ahead if positive
        COMA
        COMB
        ADDD    #$0001    ; Make D a positive number
        PSHS    D         ; Save D on the stack
        LDA     #$2D      ; $2D = minus sign
        BRA     D2String1 ; Skip ahead
!
        PSHS    D         ; Save D on the stack
        LDA     #$20      ; $20 = space (blank)
D2String1:
        BSR     StoreA_in_String

        CLR     _Var_PF00 ; This will be the tenthousands
        CLR     _Var_PF01 ; This will be the thousands
        CLR     _Var_PF02 ; This will be the hundreds
        CLR     _Var_PF03 ; This will be the tens
        CLR     _Var_PF04 ; This will be the ones
        LDD     ,S++      ; D = value to convert to Decimal, fix the stack
!
        SUBD    #10000
        BLO     >
        INC     _Var_PF00
        BRA     <
!
        ADDD    #10000      ; We now have the ten thousands
!
        SUBD    #1000
        BLO     >
        INC     _Var_PF01
        BRA     <
!
        ADDD    #1000       ; We now have the thousands
!
        SUBD    #100
        BLO     >
        INC     _Var_PF02
        BRA     <
!
        ADDD    #100        ; We now have the hundreds
!
        SUBD    #10
        BLO     >
        INC     _Var_PF03
        BRA     <
!
        ADDD    #10         ; We now have the tens
!
        SUBD    #1
        BLO     >
        INC     _Var_PF04
        BRA     <
!
; We now have the ones
* Copy the value into the string
        LDA     _Var_PF00
        BEQ     >
        ADDA    #$30
        BSR     StoreA_in_String
        BRA     D2String1000s
!       LDA     _Var_PF01
        BEQ     >
        ADDA    #$30
        BSR     StoreA_in_String
        BRA     D2String100s
!       LDA     _Var_PF02
        BEQ     >
        ADDA    #$30
        BSR     StoreA_in_String
        BRA     D2String10s
!       LDA     _Var_PF03
        BEQ     >
        ADDA    #$30
        BSR     StoreA_in_String
        BRA     D2String1s
!       LDA     _Var_PF04
        ADDA    #$30
        BRA     StoreA_in_String ; Store A in the string and Return
D2String1000s:
        LDA     _Var_PF01
        ADDA    #$30
        BSR     StoreA_in_String
D2String100s:
        LDA     _Var_PF02
        ADDA    #$30
        BSR     StoreA_in_String
D2String10s:
        LDA     _Var_PF03
        ADDA    #$30
        BSR     StoreA_in_String
D2String1s:
        LDA     _Var_PF04
        ADDA    #$30
        BRA     StoreA_in_String ; Store A in the string and Return
StoreA_in_String:
        PSHS    X         ; Save X
        INC     ,X        ; Increase the length of the string by one
        LDB     ,X        ; get the new length of the string
        ABX               ; move x to the new end of string
        STA     ,X        ; save A at the end of the string
        PULS    X,PC      ; restore X and Return
