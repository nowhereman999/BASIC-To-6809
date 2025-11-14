; Getting a Random # in B where B is a number from 1 to 255 and return with value in D
Random:
        INC     RNDX
        LDA     Seed1
        EORA    RNDC
        EORA    RNDX
        STA     Seed1
        ADDA    Seed2
        STA     Seed2
        LSRA
        ADDA    RNDC
        EORA    Seed1
        STA     RNDC
        MUL                   ; A = (Random number of 0 to 255) * B
        INCA                  ; A now is a random number from 1 to B
        TFR     A,B           ; B = A
        CLRA                  ; D = RND(B)
        RTS

; B=Random(B) result will be a random number from zero to B
RandomZ:
        INC     RNDX
        LDA     Seed1
        EORA    RNDC
        EORA    RNDX
        STA     Seed1
        ADDA    Seed2
        STA     Seed2
        LSRA
        ADDA    RNDC
        EORA    Seed1
        STA     RNDC            * A = (Random number of 0 to 255)
        INCB                    * Check if B is 255
        BEQ     >               * If so use A as the random number no MUL needed
        MUL                   ; A = (Random number of 0 to 255) * B
!       TFR     A,B           ; B = A
        CLRA                  ; D = RND(B)
        RTS

; 16 bit random number generator
* D = RND(D) result will be a random number from 1 to D
* Input: D is an unisgned 16 bit integer with the max value for the random number
* Output: D is random number frm 1 to D
RandomD:
        PSHS    A       ; Save A
        LDA     Seed2   ; Load the low byte of the seed
        LSRA            ; Shift right
        ROR     Seed1   ; Rotate into the high byte
        LDA     Seed1   ; Load the high byte of the seed
        RORA            ; Rotate right, feedback bit to carry
        EORA    #$B8    ; XOR with the feedback polynomial for 16-bit LFSR
        STA     Seed1   ; Store back to the high byte of the seed
        LDA     Seed2   ; Load the low byte again
        RORA            ; Rotate the final carry into the low byte
        STA     Seed2   ; Store back to the low byte
        PULS    A       ; Restore A
        LDX     Seed1   ; Get the 16 bit random number in X
        PSHS    D,X     ; Save the value's on the Stack for the MUL16
        JSR     MUL16   ; Do 16bit Multiply results with X:D (X is the high 16 bits value and D is the low 16 bit value)
        LEAS	4,S     ; Fix stack pointer
        TFR     Y,D     ; X has the high 16 bits, transfer it to D, it now has the correct range the user wants
        ADDD    #$0001  ; Add 1 to return with the correct range
        RTS