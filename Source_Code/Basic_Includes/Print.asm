
; Do 16 bit division by 10
; Max value of D can be 2559
; A = D / 10, B = remainder
DIV16_BY_10:
    CLR     ACount@+1       ; Self mod A = 0, quotient
DIV_LOOP_16@:
    INC     ACount@+1	; Incrment the quotient value
    SUBD    #10             ; D -= 10
    BHS     DIV_LOOP_16@
    ADDD    #10             ; restore the last subtraction → remainder in D
ACount@:
    LDA     #$00		; Self mod, clears this and then keeps track of the count
    DECA
    RTS

; Print a 16 bit signed number @ 2,S
PRINT_16Bit:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
    LDD     ,S++            ; Get value and fix stack
    BEQ     @PrintZero      ; Go print 0 and exit
    BPL     >               ; Print unsigned 16 bit number in D
    NEGA                    ; Make D a neagative
    NEGB                    ; Make D a neagative
    SBCA    #$00            ; Make D a neagative
    PSHS    A               ; Save A
    LDA	    #'-'
    BRA     @GotSign        ; Skip ahead
; Print an 16 bit number unsigned number @ 2,S
PRINT_Un16Bit:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
    LDD     ,S++            ; Get value and fix stack
    BEQ     @PrintZero      ; Go print 0 and exit
!   PSHS    A               ; Save A
    LDA     #' '
@GotSign:
    JSR     PrintA_On_Screen
    PULS    A               ; Restore A
; At this point D is a positive number
    LDX     #DividendTemp   ; X points to DividendTemp
    STD     6,X             ; Store B at LSB of DividendTemp
    LDD     #$0000          ; D = 0
    STD     ,X              ; Clear bytes from [X] to [X+5]
    STD     2,X
    STD     4,X
    JSR     PrintDecAt_DividendTemp ; Print the 64 bit number stored at DividendTemp
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
@PrintZero:
    BSR     PrintZero       ; Go print 0 and exit
    BRA     @Return         ; Exit

PrintZero:
    LDA     #' '
    JSR     PrintA_On_Screen
    LDA     #'0             ; ASCII '0'
    JMP     PrintA_On_Screen ; Print A and return

; Print an 8 bit signed number @ 2,S
PRINT_8Bit:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
;
    LDB     ,S+             ; Get value and fix the stack
    BEQ     @PrintZero      ; Go print 0 and exit
!   BPL     >               ; Print unsigned 8 bit number in B
    NEGB                    ; Make B a positive
    LDA	    #'-'
    BRA     @GotSign
; Print an 8 bit signed number @ 2,S
PRINT_Un8Bit:
    PULS    D               ; Get the return address off the stack
    STD     @Return+1       ; Self mod the return address below
;
    LDB     ,S+             ; Get value and fix the stack
    BEQ     @PrintZero      ; Go print 0 and exit
!   LDA     #' '
@GotSign:
    JSR     PrintA_On_Screen
; At this point B is a positive number
    LDX     #DividendTemp   ; X points to DividendTemp
    CLRA
    STD     6,X             ; Store B at LSB of DividendTemp
    CLRB
    STD     ,X
    STD     2,X
    STD     4,X
    JSR     PrintDecAt_DividendTemp ; Print the 64 bit number stored at DividendTemp
@Return:
    JMP     >$FFFF          ; Return, self modified jump address
@PrintZero:
    BSR     PrintZero       ; Go print 0 and exit
    BRA     @Return         ; Exit


; Print the 64 bit number stored at DividendTemp
PrintDecAt_DividendTemp:
    LDY     #0              ; Y = digit count
CONVERT_LOOP@:
; Check if DividendTemp is zero
    LDX     #DividendTemp
    LDB     #8
    CLRA
CHECK_ZERO@:
    ORA     ,X+
    DECB
    BNE     CHECK_ZERO@
    TSTA
    BEQ     >               ; If all bytes zero, conversion done
    JSR     DIVIDE_64_BY_10	; DividendTemp updated (quotient), B = remainder (0-9)
    ADDB    #$30            ; Convert remainder to ASCII
    PSHS    B               ; Push digit onto stack
    LEAY    1,Y             ; Increment digit count
    CMPY    #20             ; 20 digit max for a 64 bit number
    BEQ	    POP_LOOP
    BRA     CONVERT_LOOP@
!   CMPY	#$0000
    BNE     POP_LOOP  
; If = 0 then no digits, print '0'
    JMP     PrintZero       ; Print zero and return

POP_LOOP:
    PULS    A               ; Pop digit from stack
    JSR     PrintA_On_Screen
    LEAY    -1,Y            ; Decrement digit count
    BNE     POP_LOOP
    RTS	                ; Return


; Subroutine: Divide 64-bit number at DividendTemp by 10
; Input: DividendTemp (8 bytes, big-endian)
; Output: DividendTemp updated (quotient), B = remainder (0-9)
; Clobbers: A, B, U, X
DIVIDE_64_BY_10:
    LDU     #DividendTemp   ; U points to DividendTemp
    LDB     #8              ; 8 bytes
    PSHS    B               ; Push counter
    CLR     ,-S             ; Push remainder (0)
DIV_LOOP@:
    LDA     ,S              ; Load remainder
    LDB     ,U              ; Load current byte
; D = remainder:byte
    JSR     DIV16_BY_10     ; Divide D by 10, A = D / 10, B = remainder
    STA     ,U+             ; Store quotient byte
    STB     ,S              ; Update remainder
    DEC     1,S             ; Decrement counter
    BNE     DIV_LOOP@
    PULS	U,PC	        ; Fix the stack and return
    
    ; Print Command
; Print number in D on text screen
PRINT_D_No_Space:
        PSHS    D         ; Save D on the stack
        BRA     PRINT_D2
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
PRINT_D2:
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
* Print the value
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
        