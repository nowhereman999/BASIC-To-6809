; Copy 8k blocks:
; Source block # is in _Var_PF00+1
; Destination block # is in _Var_PF01+1
; # of blocks to copy is in _Var_PF02+1
;
Copy8kBlocks:
    PSHS    CC,DP               ; Save the condition codes
    STS     @RestoreS+2         ; Save S value (self mod below)
    ORCC    #$50                ; Disable the interrupts
@Loop0:
    LDA     >_Var_PF00+1
    LDB     >_Var_PF01+1
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
    PULS    CC,DP,PC            ; Restore the condition codes & return
