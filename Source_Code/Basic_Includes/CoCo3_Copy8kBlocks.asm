; Copy 8k blocks:
; Source block # is in _Var_PF00+1
; Destination block # is in _Var_PF01+1
; # of blocks to copy is in _Var_PF02+1
;
Copy8kBlocks:
    LDB     >CoCoHardware       ; Get the CoCo Hardware info byte
    BPL     <Copy8kBlocks6809   ; If bit 7 is clear then skip forward it's a 6809
    
Copy8kBlocks6309:
    PSHS    CC                  ; Save the condition codes
    ORCC    #$50                ; Disable the interrupts
    LDA     >_Var_PF00+1        ; Get the soruce 8k block
    LDB     >_Var_PF01+1        ; Get the destination 8k block
@Loop0:
    STD     $FFA5               ; Set the source and destination 8k blocks
    LDX     #$A000              ; Start of source block
    LDU     #$C000              ; Start of destination block
    FCB     $10,$86,$20,$00     ; Binary code for LDW #$2000, so code will assemble in 6809 assembler mode
;    LDW     #$2000              ; $2000 bytes to copy
    FCB     $11,$38,$13         ; Binary code for TFM X+,U+, so code will assemble in 6809 assembler mode
;    TFM     X+,U+               ; Copy $2000 bytes from X to U
    ADDD    #$0101              ; increment the source and destination blocks
    DEC     >_Var_PF02+1        ; Decrement the # of 8k blocks to copy
    BNE     @Loop0
    LDD     #$3D3E              ; Set RAM blocks back to normal
    STD     $FFA5               ; Save the normal blocks
    PULS    CC,PC               ; Restore the condition codes & return

Copy8kBlocks6809:
    PSHS    CC,DP               ; Save the condition codes & DP
    ORCC    #$50                ; Disable the interrupts
    STS     @RestoreS+2         ; Save S value (self mod below)
@Loop0:
    LDA     >_Var_PF00+1        ; Get the soruce 8k block
    LDB     >_Var_PF01+1        ; Get the destination 8k block
    STD     $FFA5               ; Set the source and destination 8k blocks
    LDS     #$A000              ; Start of source block
    LDU     #$C000+7            ; Start of destination block+7 (D,DP,X,Y)
!   PULS    D,DP,X,Y            ; Get 7 bytes
    PSHU    D,DP,X,Y            ; Save 7 bytes
    LEAU    14,U                ; Move forward
    PULS    D,DP,X,Y            ; Get 14 bytes
    PSHU    D,DP,X,Y            ; Save 14 bytes
    LEAU    14,U                ; Move forward
    PULS    D,DP,X,Y            ; Get 21 bytes
    PSHU    D,DP,X,Y            ; Save 21 bytes
    LEAU    14,U                ; Move forward
    PULS    D,DP,X,Y            ; Get 28 bytes
    PSHU    D,DP,X,Y            ; Save 28 bytes
    LEAU    14,U                ; Move forward
    PULS    D,DP,X,Y            ; Get 35 bytes
    PSHU    D,DP,X,Y            ; Save 35 bytes
    LEAU    14,U                ; Move forward
    CMPS    #$BFFE              ;
    BNE     <
    LDD     ,S                  ; Get the last two bytes to finish off this 8k block
    STD     -7,U                ; Put the last two bytes to finish off this 8k block
    INC     >_Var_PF00+1        ; Point at the next source block
    INC     >_Var_PF01+1        ; Point at the next destiantion block
    DEC     >_Var_PF02+1        ; Decrement the # of 8k blocks to copy
    BNE     @Loop0
    LDD     #$3D3E              ; Set RAM blocks back to normal
    STD     $FFA5               ; Save the normal blocks
@RestoreS:
    LDS     #$FFFF              ; Self mod restore stack pointer
    PULS    CC,DP,PC            ; Restore the condition codes, DP & return
