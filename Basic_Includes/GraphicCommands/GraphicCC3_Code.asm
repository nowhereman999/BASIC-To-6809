CC3ScreenStart  FCB     $00     ; Memory Block where the screen starts
; Graphics Prep code for the CoCo 3
DoCC3Graphics:
        PSHS    CC,D            ; Backup the Condition codes & D
        ORCC    #$50            ; Disable the Interrupts
        LDA     CC3ScreenStart
        STA     $FFA3           ; Graphics screen starts at $6000
        INCA
        STA     $FFA4
        INCA
        STA     $FFA5
        INCA
        STA     $FFA6
        INCA
        STA     $FFA7
        LDA     1,S             ; Restore A
        JSR     ,Y              ; Go handle graphics routine
        LDD     #$3B3C          ; Put memory back to normal
        STD     $FFA3
        ADDD    #$0202
        STD     $FFA5
        INCB
        STB     $FFA7
        PULS    CC,D,PC         ; Restore the Condition codes & D & return
; Graphics Prep code for the CoCo 3
DoCC3GraphicsReturnB:
        PSHS    CC,D            ; Backup the Condition codes & D
        ORCC    #$50            ; Disable the Interrupts
        LDA     CC3ScreenStart
        STA     $FFA3           ; Graphics screen starts at $6000
        INCA
        STA     $FFA4
        INCA
        STA     $FFA5
        INCA
        STA     $FFA6
        INCA
        STA     $FFA7
        LDA     1,S             ; Restore A
        JSR     ,Y              ; Go handle graphics routine
        STB     2,S             ; Save B
        LDD     #$3B3C          ; Put memory back to normal
        STD     $FFA3
        ADDD    #$0202
        STD     $FFA5
        INCB
        STB     $FFA7
        PULS    CC,D,PC         ; Restore the Condition codes & D & return

; Graphics Prep code for the CoCo 3 for screens with 320 pixels wide or more
DoCC3GraphicsBigX:
        PSHS    CC,A,X          ; Backup the Condition codes, A & X
        ORCC    #$50            ; Disable the Interrupts
        LDA     CC3ScreenStart
        STA     $FFA3           ; Graphics screen starts at $6000
        INCA
        STA     $FFA4
        INCA
        STA     $FFA5
        INCA
        STA     $FFA6
        INCA
        STA     $FFA7
        LDA     1,S             ; Restore A
        JSR     ,Y              ; Go handle graphics routine
        LDD     #$3B3C          ; Put memory back to normal
        STD     $FFA3
        ADDD    #$0202
        STD     $FFA5
        INCB
        STB     $FFA7
        PULS    CC,A,X,PC         ; Restore the Condition codes, A, X & return
; Graphics Prep code for the CoCo 3
DoCC3GraphicsBigXReturnB:
        PSHS    CC,A            ; Backup the Condition codes, & A
        ORCC    #$50            ; Disable the Interrupts
        LDA     CC3ScreenStart
        STA     $FFA3           ; Graphics screen starts at $6000
        INCA
        STA     $FFA4
        INCA
        STA     $FFA5
        INCA
        STA     $FFA6
        INCA
        STA     $FFA7
        LDA     1,S             ; Restore A
        JSR     ,Y              ; Go handle graphics routine
        LDX     #$3B3C          ; Put memory back to normal
        STX     $FFA3
        LDX     #$3D3E
        STX     $FFA5
        LDA     #$3F
        STA     $FFA7
        PULS    CC,A,PC         ; Restore the Condition codes, A & return

; CoCo 3 - GCopy - Graphics page copy
; Enter with:
; ,S  = return address
; 2,S = # of blocks to copy
; 3,S = Destination $2000 block
; 4,S = Source $2000 Block
GCopy_CoCo3:
        PSHS    CC              ; Backup the Condition codes on the stack
; 3,S = # of blocks to copy
; 4,S = Destination $2000 block
; 5,S = Source $2000 Block
        ORCC    #$50            ; Disable the Interrupts
        LDY     4,S             ; MSB = Destination $2000 Block, LSB = Source $2000 Block
@Gcopy_loop:
        STY     $FFA3           ; Destination is at $6000, Source is at $8000
        LDX     #$8000          ; X points at the source $2000 block
        LDU     #$6000          ; U points at the destination $2000 block
!       LDD     ,X++
        STD     ,U++
        CMPX    #$A000
        BNE     <               ; copy the $2000 bytes
        LEAY    $0101,Y         ; Increment the Destination and the Source blocks
        DEC     3,S             ; Decrement the number of blocks to copy
        BNE     @Gcopy_loop     ; if not zero copy another $2000 block
        
        LDD     #$3B3C          ; Put memory back to normal
        STD     $FFA3
        PULS    CC,PC           ; Restore the Condition codes return
