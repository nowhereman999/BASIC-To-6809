; Code for handling Scrolling
;
; Get these commands working in BASICto6809
;
; BACKGROUND_DIM SizeX,SizeY
; SizeX must be > 511 and be a multiple of 256
; SizeY must be > 191 and be a multiple of 64
;
;VideoRamBlock                       FCB     %00000010   ; Set default to 1 Meg to 1.5 Meg location
;VerticalPosition                    FDB     $0000       ; Offset
;HorizontalPosition                  FCB     %10000000   ; Bit 7 set = Horizontal scrolling enabled
;MapViewBlock                        FCB     $80         ; Map location in Memory to view
;ViewPortX                       FDB     $0000           ; Viewport top left corner x co-ordinate
;ViewPortY                       FDB     $0000           ; Viewport top left corner y co-ordinate

; Scrolling viewport for a playfield of 256 x 7872 (No Horizontal scrolling)
; Show the viewport where ViewPortY is the top row of the screen
View256x7872:
        LDD     ViewPortY
        STA     @RestoreA+1     ; Save A (self mod)
        CMPD    #3904           ; If we get here or higher then we need to show the 1.5 Meg to 2Meg video block
        BLO     >               ; If not use the 1 Meg to 1.5 Meg video block
        SUBD    #3904           ; Keep it in the 512k range after multiplying by 16 per row
        STA     @RestoreA+1     ; Save A (self mod)
        LDA     #%00000011      ; Set to use 1.5 to 2 Meg video block
        FCB     $8C             ; Skip the next two bytes (Fake CMPX instruction)
!       LDA     #%00000010      ; Set to use 1.0 to 1.5 Meg video block
        STA     VideoRamBlock   ; Record which Video Bank block to use
@RestoreA:
        LDA     #$FF            ; Restore y co-ordiante to use (self modded above)
        LSLB
        ROLA                    ; y = y * 2
        LSLB
        ROLA                    ; y = y * 4
        LSLB
        ROLA                    ; y = y * 8
        LSLB
        ROLA                    ; y = y * 16, 16 bytes per row for scrolling the 16 colour, 256 pixel scrolling screen
        STD     VerticalPosition        ; Update the Viewport
        CLR     HorizontalPosition      ; No horizontal scrolling
        RTS                     ; return

; 64 rows per $2000 block
; Enter with:
; D = Sprite y co-ordinate
; Returns:
; A = Block to start drawing sprite in 
CalcBlocks256x7872:
        STA     @RestoreA+1     ; Save A (self mod)
        CMPD    #3904           ; If we get here or higher then we need to show the 1.5 Meg to 2Meg video block
        BLO     >               ; If not use the 1 Meg to 1.5 Meg video block
        SUBD    #3904           ; Keep it in the 512k range after multiplying by 16 per row
        STA     @RestoreA+1     ; Save A (self mod)
        LDA     #$C0            ; Set to use 1.5 to 2 Meg video block
        FCB     $8C             ; Skip the next two bytes (Fake CMPX instruction)
!       LDA     #$80            ; Set to use 1.0 to 1.5 Meg video block
        PSHS    A               ; Record which Video Bank block to use on the stack
; To get the Block the sprite is in we
; simply take the y value and divide by 64 (in this mode there are 64 blocks in each $2000 block)
; %11110000 / 64 = %00000011
@RestoreA:
        LDA     #$FF            ; Restore y co-ordiante to use (self modded above)
        LSLB
        ROLA
        LSLB
        ROLA                    ; A has the block for the top of the sprite
        ADDA    ,S+             ; A = A + 512k block to use, fix the stack
        RTS                     ; return

; Scrolling viewport for a playfield of 512 x 3840
View512x3840:
        LDD     ViewPortY
        STA     @RestoreA+1     ; Save A (self mod)
        CMPD    #1856           ; If we get here or higher then we need to show the 1.5 Meg to 2Meg video block
        BLO     >               ; If not use the 1 Meg to 1.5 Meg video block
        SUBD    #1856           ; Keep it in the 512k range after multiplying by 16 per row
        STA     @RestoreA+1     ; Save A (self mod)
        LDA     #%00000011      ; Set to use 1.5 to 2 Meg video block
        FCB     $8C             ; Skip the next two bytes (Fake CMPX instruction)
!       LDA     #%00000010      ; Set to use 1.0 to 1.5 Meg video block
        STA     VideoRamBlock   ; Record which Video Bank block to use
@RestoreA:
        LDA     #$FF            ; Restore y co-ordiante to use (self modded above)
        LSLB
        ROLA                    ; y = y * 2
        LSLB
        ROLA                    ; y = y * 4
        LSLB
        ROLA                    ; y = y * 8
        LSLB
        ROLA                    ; y = y * 16
        LSLB
        ROLA                    ; y = y * 32, 32 bytes per row for scrolling the 16 colour, 512 pixel scrolling screen
        STD     VerticalPosition        ; Update the Viewport
; Figure out Horizontal scrolling
; Set the amount to scroll right
        LDB     ViewPortX+1     ; Get LSB of x co-ordinate
        LSRB
        LSRB                    ; Horizontal scroll always moves 2 byte (4 pixels), so they can be ignored
        ORB     #%10000000      ; Set the Flag for horiztonal scrolling
        STB     HorizontalPosition      ; Save the position
        RTS

; Calc which block the sprite is in
; Enter with:
; D = Sprite y co-ordinate
; Returns:
; A = Block to start drawing sprite in 
Calc512x3840:
        STA     @RestoreA+1     ; Save A (self mod)
        CMPD    #1856           ; If we get here or higher then we need to show the 1.5 Meg to 2Meg video block
        BLO     >               ; If not use the 1 Meg to 1.5 Meg video block
        SUBD    #1856           ; Keep it in the 512k range after multiplying by 16 per row
        STA     @RestoreA+1     ; Save A (self mod)
        LDA     #$C0            ; Set to use 1.5 to 2 Meg video block
        FCB     $8C             ; Skip the next two bytes (Fake CMPX instruction)
!       LDA     #$80            ; Set to use 1.0 to 1.5 Meg video block
        PSHS    A               ; Record which Video Bank block to use on the stack
; To get the Block the sprite is in we
; simply take the y value and divide by 32 (in this mode there are 32 blocks in each $2000 block)
; %11110000 / 64 = %00000011
@RestoreA:
        LDA     #$FF            ; Restore y co-ordiante to use (self modded above)
        LSLB
        ROLA                    
        LSLB
        ROLA                    
        LSLB
        ROLA                    ; A = D / 32, A has the block for the top of the sprite
        ADDA    ,S+             ; A = A + 512k block to use, fix the stack
        RTS                     ; return

; Scrolling viewport for a playfield of 1024 x 1024
; Show the viewport where the top left corner given x & y co-ordinates
View1024x1024:
        LDD     ViewPortY
        LSLB
        ROLA                    ; y = y * 2
        LSLB
        ROLA                    ; y = y * 4
        LSLB
        ROLA                    ; y = y * 8
        LSLB
        ROLA                    ; y = y * 16
        LSLB
        ROLA                    ; y = y * 32, 32 bytes per row for scrolling the 16 colour, 512 pixel scrolling screen
        STB     VerticalPosition+1 ; Save the LSB
        LDB     ViewPortX       ; Get MSB of x co-ordinate
        ANDB    #%00000011      ; Get the bits
        LSRB                    ; Move which 256 pointer to the carry
        BCC     >               ; If the carry is clear then we are in the first half of 512k video RAM
        ORA     #%10000000      ; Y will be in the 2nd half of the 512k video block
!       STA     VerticalPosition ; Update the MSB
        LDA     #%00000010      ; Set to use 1.0 to 1.5 Meg video block
        LSRB                    ; is it going to be in the next 512k Video block?
        BCC     >               ; Skip ahead if not
        INCA                    ; Use 1.5 Meg to 2 Meg video block
!       STA     VideoRamBlock   ; Record which Video Bank block to use
; At this point Y is pointing to the correct Row in the correct 512k Video block
; Set the amount to scroll right
        LDB     ViewPortX+1     ; Get LSB of x co-ordinate
        LSRB
        LSRB                    ; Horizontal scroll always moves 2 byte (4 pixels), so they can be ignored
        ORB     #%10000000      ; Set the Flag for horiztonal scrolling
        STB     HorizontalPosition      ; Save the position
        RTS

; Calc which block the sprite is in
; Enter with:
; D = Sprite y co-ordinate
; X = Sprite x co-ordinate
; Returns:
; A = Block to start drawing sprite in 
Calc1024x1024:
; Each $2000 byte block is 32 bytes
; so to get which bank to start in we divide by 32
        LSLB
        ROLA                    
        LSLB
        ROLA                    
        LSLB
        ROLA                    ; A = D / 32, A has the block for the top of the sprite in the first 512 pixels
        PSHS    A               ; Save the block on the stack
        TFR     X,D             ; D = x co-ordinate, A = the x co-ordinate / 256, which is what we need * 32 to get the proper block
        LDB     #32
        MUL                     ; B = A * 32
        ADDB    ,S              ; B = B + Bank on vertical column 0
        ADDB    #$80            ; B=B+$80, Video Banks start at $80
        STB     ,S              ; Save it on the stack
        PULS    A,PC            ; Return with Bank in A

; Scrolling viewport for a playfield of 4096 x 256
; Show the viewport where the top left corner given x & y co-ordinates
View4096x256:
        LDB     ViewPortY+1     ; B = LSB of y co-ordinate (can only be 0 to 63)
        LDA     ViewPortX       ; Get x co-ordinate MSB (value of 0 to 15) $2000 block # %00001111
        LSLB
        ROLA                    ; y = y * 2
        LSLB
        ROLA                    ; y = y * 4
        LSLB
        ROLA                    ; y = y * 8
        LSLB
        ROLA                    ; y = y * 16
        LSLB
        ROLA                    ; y = y * 32, 32 bytes per row for scrolling the 16 colour, 512 pixel scrolling screen
        STD     VerticalPosition ; Update the Vertical position to show on screen
        LDA     #%00000001      ; Video Bank MSb = 1
        ROLA                    ; Shift it left and the carry will go to bit 0
        STA     VideoRamBlock   ; Record which Video Bank block to use
; At this point Y is pointing to the correct Row in the correct 512k Video block
; Set the amount to scroll right
        LDB     ViewPortX+1     ; Get LSB of x co-ordinate
        LSRB
        LSRB                    ; Horizontal scroll always moves 2 byte (4 pixels), so they can be ignored
        ORB     #%10000000      ; Set the Flag for horiztonal scrolling
        STB     HorizontalPosition      ; Save the position
        RTS

; Calc which block the sprite is in
; Enter with:
; D = Sprite y co-ordinate
; X = Sprite x co-ordinate
; Returns:
; A = Block to start drawing sprite in 
Calc4096x256:
; Each $2000 byte block is 32 bytes
; so to get which bank to start in we divide by 32
        LSLB
        ROLA                    
        LSLB
        ROLA                    
        LSLB
        ROLA                    ; A = D / 32, A has the block for the top of the sprite in the first 512 pixels
        PSHS    A               ; Save the block on the stack
        TFR     X,D             ; D = x co-ordinate
                                ; We need this value / 16 to get the vertical column
                                ; Then we'll need to do * 16 to point at the column
        ANDB    #%11110000
        LSRB
        ADDB    ,S              ; B = B + Bank on vertical column 0
        ADDB    #$80            ; B=B+$80, Video Banks start at $80
        STB     ,S              ; Save it on the stack
        PULS    A,PC            ; Return with Bank in A          

        
 ; Scrolling viewport for a playfield of 5120 x 192
; Show the viewport where the top left corner given x & y co-ordinates
; Enter with:
View2560x192:
        LDA     ViewPortX       ; A = Screen # (0 to 9)
        LDB     #$18            ; B = $18
        MUL                     ; D = block number where the top left corner starts
        EXG     A,B
        STD     VerticalPosition ; Update the Vertical position to show on screen
; At this point Y is pointing to the correct Row
; Set the amount to scroll right
        LDB     ViewPortX+1     ; Get LSB of x co-ordinate
        LSRB
        LSRB                    ; Horizontal scroll always moves 2 bytes (4 pixels), so they can be ignored
        ORB     #%10000000      ; Set the Flag for horiztonal scrolling
        STB     HorizontalPosition      ; Save the position
        RTS

; Calc which block the sprite is in
; Enter with:
; D = Sprite y co-ordinate
; X = Sprite x co-ordinate
; Returns:
; A = Block to start drawing sprite in 
Calc2560x192:
        CLR     MatchViewport
        CMPX    ViewPortX
        BLO     @NotViewable    ; return with A as block #252, draw nowhere
        PSHS    D,X             ; save the registers
        LDA     ViewPortX       ; Get the viewport (MSB) location
        INCA
        CMPA    2,S
        BLO     @AlsoNotviewable
; Sprite is in viewable range draw it to the same playfield as the viewport
        DECA                    ; D = Viewport address
        CMPA    2,S             ; compare with the sprite (which will always be larder that viewport address)
        BEQ     @Same2          ; If the MSB is the same then we are in the first half so we are good as we are
; Otherwise the viewport is 256 pixels lower than the sprite (they are not in the same map)
; We must make the sprite show up in the same map as the viewer
; We do this by decrementing the MSB of the sprite so it's drawn in the viewport map
; We must also add 256 to it's viewable location 
        LDA     2,S             ; Get sprite location
        DECA
        INC     MatchViewport
@Same2:
        LDB     #6              ; A = Screen # (0 to 9), B = 6 blocks per screen
        MUL                     ; B = block number where the top left corner starts
        ADDB    #$80            ; B = B + Bank start for this screen, top left corner
; As we go down 32 rows we add another bank
        PSHS    B               ; Save the bank for the top row
        LDD     1,S             ; D = Y co-ordinate
        LSLB
        ROLA                    
        LSLB
        ROLA                    
        LSLB
        ROLA                    ; A = D / 32, A has the block for the top of the sprite in the first 512 pixels
        ADDA    ,S              ; A = A + the block on top left of this screen, A now points at the block where the sprite starts
        LEAS    5,S
        RTS
@AlsoNotviewable:
        PULS    D,X             ; otheriwse fix stack and return with A as block 252
@NotViewable:
        LDA     #$7D            ; return with A as block #$7D, draw nowhere
        RTS
MatchViewport   FCB     $00