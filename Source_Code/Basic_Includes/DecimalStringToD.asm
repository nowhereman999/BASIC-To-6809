* Convert a decimal string of numbers to a signed integer in D
* Enter with Decimal # in location DecNumber last value is a zero
* If all is good U = 0, If there was a problem converting the characters in the KeyBuff to a number then U = -1
* Because of the condition of U on EXIT you could use
* JSR DecToD
* BNE  @NotANumber     ; This will jump if there was a problem converting the decimal string to a number

DecCounter      RMB   1         ; Count of decimal places
DecNumber       RMB   7         ; Decimal number , max 6 bytes + 1 for the zero terminator (ex. -31355+null)
DecToD: 
        PSHS    X,Y,U           ; Save X,Y & U
        LEAY    ,S              ; Y = S Save the stack pointer in Y
        CLRB
        LDU     #DecNumber      ; Point U to the decimal number buffer
!       INCB
        CMPB    #7              ; Check the number of decimal places
        LBHI     @NotANumber    ; If more than 7 then we have a problem
        LDA     ,U+             ; Get a character
        PSHS    A
        BNE     <               ; Copy string backwards onto the stack
        DECB                    ; Fix the counter
        LBEQ     @DisZero       ; Null string then number = 0
!       LEAS    1,S             ; Fix the stack pointer
        STB     DecCounter      ; Save the number of decimal places
        LDB     ,S+             ; Get the Ones value
        CMPB    #'-             ; Is it a minus?
        LBEQ     @DisZero       ; If it's just a - then number = 0
        CMPB    #'0           
        LBLO     @NotANumber      
        CMPB    #'9           
        LBHI     @NotANumber      
        SUBB    #'0             ; Make B a value from 0 to 9
        LDX     #$0000          ; Starting value
        ABX                     ; Add B to X
        DEC     DecCounter      ; Decrement the number of decimal places
        BEQ     @XtoD           ; If we have no more decimal places then go to the conversion
        LDB     ,S+             ; Get the Tens value
        CMPB    #'-             ; Is it a minus?
        BEQ     @DisNegative  
        CMPB    #'0           
        LBLO     @NotANumber      
        CMPB    #'9           
        BHI     @NotANumber      
        SUBB    #'0             ; Make B a value from 0 to 9
        LDA     #10           
        MUL                   
        LEAX    D,X             ; Add the Tens value
        DEC     DecCounter      ; Decrement the number of decimal places
        BEQ     @XtoD         
        LDB     ,S+             ; Get the Hundres value
        CMPB    #'-             ; Is it a minus?
        BEQ     @DisNegative  
        CMPB    #'0           
        BLO     @NotANumber      
        CMPB    #'9           
        BHI     @NotANumber      
        SUBB    #'0             ; Make B a value from 0 to 9
        LDA     #100          
        MUL                   
        LEAX    D,X             ; Add the 100's value
        DEC     DecCounter      ; Decrement the number of decimal places
        BEQ     @XtoD         
        LDB     ,S+             ; Get the 1000's value
        CMPB    #'-             ; Is it a minus?
        BEQ     @DisNegative  
        CMPB    #'0           
        BLO     @NotANumber      
        CMPB    #'9           
        BHI     @NotANumber      
        SUBB    #'0             ; Make B a value from 0 to 9
        LDA     #4              ; B * 4
        MUL                   
        LDA     #250            ; B * 250
        MUL                   
        LEAX    D,X             ; Add the 1000's value
        DEC     DecCounter      ; Decrement the number of decimal places
        BEQ     @XtoD         
        LDB     ,S+             ; Get the 10000's value
        CMPB    #'-             ; Is it a minus?
        BEQ     @DisNegative  
        CMPB    #'0           
        BLO     @NotANumber      
        CMPB    #'6           
        BHI     @NotANumber      
        SUBB    #'0             ; Make B a value from 0 to 6
        LDA     #40             ; B * 40
        MUL                   
        LDA     #250            ; B * 250
        MUL                   
        LEAX    D,X             ; Add the 10000's value  
        DEC     DecCounter      ; Decrement the number of decimal places
        BEQ     @XtoD            
        LDB     ,S+             ; See if the last value is a -
        CMPB    #'-             ; Is it a minus?
        BEQ     @DisNegative  
@XtoD   TFR     X,D             ; X = D
        BRA     @GotD    
@DisNegative
        PSHS    X               ; Make D a negative number
        LDD     #$0000          ; Clear D
        SUBD    ,S++            ; Going to use the negative verison of D, fix the stack
        BRA     @GotD         
@DisZero
        LDD     #$0000          ; D = zero
@GotD
        LEAS    ,Y              ; Restore the stack pointer
        LDU     #$0000          ; Set Z CC flag all is good
        PULS    X,Y,U,PC        ; Restore X,U and Return
@NotANumber:
        LEAS    ,Y              ; Restore the stack pointer
        LDU     #-1             ; Clear Z CC flag with an error
        PULS    X,Y,U,PC        ; Restore X,U and Return
