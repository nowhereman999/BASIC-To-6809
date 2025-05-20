; Duplicate the CoCo 3 background from buffer 0 to buffer 1
DuplicateBackground:
    PSHS    CC                  ; Save the condition codes
    ORCC    #$50                ; Disable the interrupts
    LDY     #$80C0              ; Source Start Block, Destination Start Block
@Loop1:
    STY     $FFA5               ; Set the source and destination 8k blocks
    LDX     #$A000              ; Start of source block
    LDU     #$C000              ; Start of destination block
@Loop2:
    LDD     ,X++                ; Get source bytes
    STD     ,U++                ; Save at destination address
    CMPX    #$C000              ; Are we at the end of the source block?
    BNE     @Loop2              ; If not keep looping
    LEAY    $0101,Y             ; Point at the next block
    CMPY    #$C100              ; Have we done all the blocks?
    BNE     @Loop1              ; Loop if not
    LDD     #$3D3E              ; Get the normal
    STD     $FFA5               ; Set back to normal
    PULS    CC,PC               ; Restore the condition codes & return
