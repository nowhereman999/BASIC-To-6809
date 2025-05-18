* Div 16bit by 16bit
; D = X / D
; X = Remainder (X MOD D) 
DIV16:
        STA     Temp1         ; Save the minus flag for D
        STD     Denominator   ; Save the Denominator & set the flags
        BEQ     DivError      ; we are dividing by zero which can't be done so exit with D=$FFFF
        BPL     >             ; If D>0 then skip ahead we are good with a Positive number
        LDD     #$0000        ; Clear D
        SUBD    Denominator   ; D = 0 - Denominator
        STD     Denominator   ; Save the positive version of the Denominator
!       CLRA                  ; Default flag for the Numerator sign is positive
        STX     Numerator     ; Save the Numerator
        BPL     >
        LDD     #$0000        ; Clear D
        SUBD    Numerator     ; D = 0 - Numerator
        STD     Numerator     ; Save the positive version of the Numerator
        LDA     #$FF          ; Flag D as a negative number
!       STA     Temp2         ; Save the minus flag for D, if it's a negative then it was negative before
        LDX     #16           ; 16 bits to go through
        LDD     #$0000        ; Clear D
Div_Again:
        LSL     Numerator+1   ; Shift Bits in Numerator Left
        ROL     Numerator     ; Shift Bits in Numerator Left (pushing MSb bit to carry bit)
        ROLB                  ; Rotate A left and put carry bit in bit zero
        ROLA                  ; Rotate A left and put carry bit in bit zero
        CMPD    Denominator   ; See if A = Denominator
        BLO     >             ; If carry is set then skip ahead (BLO)
        INC     Numerator+1   ; Set bit zero of Numerator
        SUBD    Denominator   ; A = A - Denominator
!       LEAX    -1,X          ; Countdown bit counter
        BNE     Div_Again     ; If we're not at zero then loop again
; D now has the remainder, Result of the division is in the Numerator
        PSHS    D             ; Save the Remiander on the stack
        
DivDone:
        CLRB
        LDA     Temp1         ; Get the minus flag for Denominator
        BPL     >
        INCB
!       LDA     Temp2         ; Get the minus flag for Numerator
        BPL     >
        INCB
!       ANDB    #$01          ; Check if B is an odd number
        BEQ     >             ; If B is even then leave the flags alone
        LDD     #$0000        ; Clear D
        SUBD    Numerator     ; D = 0 - Result (make it negative)
        FCB     $8C           ; Skip the next two bytes
!       LDD     Numerator     ; Get the result in D
DivGoodD:
        PULS    X,PC          ; X now has the remainder, then return
DivError:
        LDD     #$FFFF        ; we are dividing by zero which can't be done so exit with D=$FFFF
        RTS                   ; EXIT

* Div 16bit by 16bit (with Rounding)
; D = X / D
DIV16Rounding:
        STD     Denominator   ; Save the Denominator & set the flags
        BEQ     DivError      ; If D=0 then exit with D=$FFFF, can't divide by zero
        STX     Numerator     ; Save the Numerator
        LDX     #16           ; 16 bits to go through
        LDD     #$0000        ; Clear D
Div_AgainR:
        LSL     Numerator+1   ; Shift Bits in Numerator Left
        ROL     Numerator     ; Shift Bits in Numerator Left (pushing MSb bit to carry bit)
        ROLB                  ; Rotate A left and put carry bit in bit zero
        ROLA                  ; Rotate A left and put carry bit in bit zero
        CMPD    Denominator   ; See if A = Denominator
        BLO     >             ; If carry is set then skip ahead (BLO)
        INC     Numerator+1   ; Set bit zero of Numerator
        SUBD    Denominator   ; A = A - Denominator
!       LEAX    -1,X          ; Countdown bit counter
        BNE     Div_AgainR    ; If we're not at zero then loop again
* Let's round the result
        LDX     Numerator     ; Get the result in X
	ASLB
	ROLA		      ; Remainder =Remainder * 2
	BCS	@IncX	      ; If the carry bit is set then we're over 16 bit value range so it must be rounded up
        CMPD    Denominator   ; Is Remainder * 2 < the Denominator?
        BLO     >             ; If so then skip ahead
@IncX:
	LEAX	1,X           ; X = X + 1
!       TFR     X,D           ; D now has the result
DivDoneR:
	RTS

