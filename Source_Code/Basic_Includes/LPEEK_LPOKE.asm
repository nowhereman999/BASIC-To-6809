; LPEEK - Get the value in RAM of the long value on the stack and return the 8 bit value on the stack
; Enter with Unsigned 32 bit number on the stack
; Exit with the 8 bit contents of that location on the stack
;
LPEEK:
    PSHS    CC              ; Save IRQ values
    ORCC    #$50            ; Disabel the IRQs
    LDD     1+2+1,S         ; Stack is CC, Return Address, 32 bit number, Get the middle bytes of the 32 bit value
;                             (CoCo 3 value max will be 2 Megs)
    LSLB
    ROLA
    LSLB
    ROLA
    LSLB
    ROLA                    ; A = 32 bit number / $2000
	STA     $FFA3           ; Make $6000 to $7FFF show this block
    LDD     1+2+2,S         ; Stack is CC, Return address, 32 bit number , D = the least significant word of the address, fix the stack
    ANDA    #$1F            ; Range from 0 to $1FFF
    LDX     #$6000          ; X points at the block
    LDB     D,X             ; B = value at the address
    LDA     #$3B            ; Normal value for $6000 block
	STA     $FFA3           ; Make $6000 to $7FFF normal
    PULS    CC,X,Y,U        ; Enable the IRQs again, X = return address, fix the stack
    PSHS    B               ; Save value of the byte on the stack
    TFR     X,PC            ; PC = X, Return

; LPOKE 32bit,8bit - Poke the value in RAM of the long value on the stack and return the value on the stack
; Enter with an 8 bit value on the stack followed by an Unsigned 32 bit number on the stack
;
LPOKE:
    PSHS    CC              ; Save IRQ values
    ORCC    #$50            ; Disabel the IRQs
    LDD     1+2+1+1,S       ; Stack is CC, Return Address, Byte to store, 32 bit number
;                             Get the middle bytes of the 32 bit value (CoCo 3 value max will be 2 Megs)
    LSLB
    ROLA
    LSLB
    ROLA
    LSLB
    ROLA                    ; A = 32 bit number / $2000
	STA     $FFA3           ; Make $6000 to $7FFF show this block
    LDD     1+2+1+2,S       ; Stack is CC, Return address, byte to store, 32 bit number , D = the least significant word of the address, fix the stack
    ANDA    #$1F            ; Range from 0 to $1FFF
    ADDA    #$60            ; Make it in the range of $6000 to $7FFF
    TFR     D,X             ; X = address
    LDB     1+2,S           ; CC,Return address, byte to store
    STB     ,X              ; Save B in the address
    LDA     #$3B            ; Normal value for $6000 block
	STA     $FFA3           ; Make $6000 to $7FFF normal
    PULS    CC,X            ; Enable the IRQs again, X = return address
    LEAS    5,S             ; fix the stack (1 byte to store + 4 bytes for 32 bit number)
    TFR     X,PC            ; PC = X, Return
