; Code for handling Scrolling
;
; Get these commands working in BASICto6809
;
; BACKGROUND_DIM SizeX,SizeY
; SizeX must be > 511 and be a multiple of 256
; SizeY must be > 191 and be a multiple of 64
;
; ChunkSizeMap = (SizeX * SizeY) / $2000
;
; Calculate the Skip pointer where the 1 Meg Video viewer must change to the 1.5 Meg viewer for scrolling
; Skip = Int(64 / ChunkSizeMap) * ChunkSizeMap
; Skip = Skip + BlkStart
;  
; ScrollX_Right & Scroll_left
; ScrollY_Up or Scroll_Down
; 
; Scroll X TO 700
; Scroll Y TO 32
;
;GIME_VideoBankSelect_FF9B           EQU $FF9B
;GIME_VerticalScroll_FF9C            EQU $FF9C
;GIME_VerticalOffsetMSB_FF9D         EQU $FF9D
;GIME_VerticalOffsetLSB_FF9E         EQU $FF9E
;GIME_HorizontalOffset_FF9F          EQU $FF9F
VideoRamBlock                       FCB     %00000010   ; Set default to 1 Meg to 1.5 Meg location
VerticalPosition                    FDB     $0000       ; Offset
HorizontalPosition                  FCB     $80         ; Bit 7 set = Horizontal scrolling enabled
MapViewBlock                        FCB     $80         ; Map location in Memory to view
UpDownAmount                        EQU     128         ; Amount to scroll Up or down
                                                        ; 32 = 1 row, 64 = 2 rows, 96 = 3 rows, 128 = 4 rows
                                                        ; Scrolling left and right always moves 2 bytes (4 pixels in 16 colour mode)

; Given the x & y co-ordinate of the top left corner of the window to view
; Set the values for 
; Calculate which chunk to view in RAM
; 2816 x 320
; Chunksize = (256 * BackHeight) / $2000
; Chunksize = 81920 / $2000
; Chunksize = $0A = 10
; 

    LDA     VideoRamBlock   ; Get the video Bank to show
    STA     $FF9B           ; Update Video Bank block  (0,512k,1Meg,1.5Meg) - GIME_VideoBankSelect_FF9B             
    LDD     VerticalPosition
    STD     $FF9D           ; GIME_VerticalOffsetMSB_FF9D      
    LDA     HorizontalPosition       ; Get the x scroll value
    STA     $FF9F           ; Set the scroll pointer - GIME_HorizontalOffset_FF9F   


; Scroll Left
ScrollUp:
    LDD     VerticalPosition
    BEQ     @NewMapUp
    SUBD    #UpDownAmount
    STD     VerticalPosition
    BRA     @Done
@NewMapUp:
    LDA     MapViewBlock        ;
    CMPA    #$80                ; Are we at the very first Bank?
    BEQ     @Done               ; can't go up anymore, Done
; Show the bottom of the previus map/chunk
    BRA     *                   ; Need to do this
; Scroll Left
ScrollDown:
    LDB     MapViewBlock        ; Get the $2000 block in the top left corner
    LSLB
    LSLB                        ; $2000 Block * 4
    STB     @SelfModA+1         ; Self mod position to minus
    LDD     VerticalPosition
@SelfModA
    SUBA    #$FF
    CMPD    #192   ; Are we at the last row to view?
    BEQ     @NewMapDown
    ADDD    #UpDownAmount
    STD     VerticalPosition
    BRA     @Done
@NewMapDown:
    LDA     MapViewBlock        ;
    CMPA    #MapEndBlockRight   ; Are we at the very last Bank?
    BEQ     @Done               ; can't go up anymore, Done
; Show the top of the next map/chunk
    BRA     *                   ; Need to do this
; Scroll Left
ScrollLeft:
    LDB     HorizontalPosition
    CMPB    #%10000000
    BEQ     @NewMapLeft
    DEC     HorizontalPosition
    BRA     @Done
;New Map Left
@NewMapLeft:
    LDA     MapViewBlock        ;
    CMPA    #$80                ; Are we at the very first Bank?
    BEQ     @Done               ; can't go left anymore, Done
; Show the previous chunk/map
    LDB     #%11000000-1        ; Point at the right edge of the previous map
    STB     HorizontalPosition  ; update the scroll position
    LDB     VerticalPosition    ; get the vertical position
    BNE     >                   ; skip ahead if it's not zero, we're still in the same 512k video block
; If we are at zero then we were just viewing the start of 1.5Megs
; We have to view the last map of the 1Meg video area
    DEC     VideoRamBlock       ; Show video at 1 Meg to 1.5 Meg area
    LDA     #MapSkipBlockX      ; A = the block we were to skip showing and jump forward
    LDB     #MapSkipBlockX      ; B = the block we were to skip showing and jump forward
    SUBB    #ChunkSizeMap       ; Backup one map
    ANDB    #$3F
    LSLB
    LSLB                        ; B=B*4
    BRA     @Update                
!   SUBB    #ChunkSizeMap*4     ; make it point at the start of the previous map
                                ; vertical position is $0000 for Bank 0, $0004 for bank 1
                                ; So we take the bank value and mulitply it by 4
                                ; Since ChunkSizeMap is the number of $2000 byte blocks this should work given
                                ; ChunkSizeMap is set correct
@Update                
    STB     VerticalPosition    ; Save the new vertical position
    SUBA    #ChunkSizeMap       ; Backup one map
    STA     MapViewBlock        ; Save it as the new location
    BRA     @Done
; Scroll Right
ScrollRight:
    INC     HorizontalPosition
    LDB     HorizontalPosition
    CMPB    #%11000000          ; Are we past the right edge?
    BNE     @Done               ; If not then exit
;New Map Right
    LDA     MapViewBlock
    CMPA    #MapEndBlockRight   ; Have we gone to the max right map?
    BNE     >                   ; If not go point at the start of the next right map
; = 0 then can't go right anymore
    DEC     HorizontalPosition  ; Don't move
    BRA     @Done               ; Don't move this time
; Next right screen
!   LDB     VerticalPosition    ; get the vertical position
    ADDB    #ChunkSizeMap*4     ; make it point at the start of the next map
                                ; vertical position is $0000 for Bank 0, $0004 for bank 1
                                ; So we take the bank value and mulitply it by 4
                                ; Since ChunkSizeMap is the number of $2000 byte blocks this should work given
                                ; ChunkSizeMap is set correct
    STB     VerticalPosition    ; Save the new vertical position
!   ADDA    #ChunkSizeMap
    CMPA    #MapSkipBlockX      ; Compare it with the calculated last viewable screen in this 512k block
    BNE     @UpdateMap
    INC     VideoRamBlock       ; Show video at 1.5 to 2 Meg area
    LDA     VerticalPosition    ; beginning of this vertical position
    ANDA    #%00000011          ; Clear the block pointer
    LDA     #192                ; We are right at the beginning of this new 1.5 Meg block
@UpdateMap:
    STA     MapViewBlock
    LDB     #%10000000          ; Point at the left of this new Map
    STB     HorizontalPosition
@Done:
;    RTS

ScreenLocationUpdate:
    LDB     $FF02
!   LDB     $FF03
    BPL     <

    LDA     VideoRamBlock   ; Get the video Bank to show
    STA     $FF9B           ; Update Video Bank block  (0,512k,1Meg,1.5Meg) - GIME_VideoBankSelect_FF9B             
    LDD     VerticalPosition
    STD     $FF9D           ; GIME_VerticalOffsetMSB_FF9D      
    LDA     HorizontalPosition       ; Get the x scroll value
    STA     $FF9F           ; Set the scroll pointer - GIME_HorizontalOffset_FF9F   
    RTS


; For a 1024 x 1024 scrolling map
; Show the window starting at the top left corner given x & y cor-ordinates
; Enter with:
; 2,S = X co-ordinate
; D = Y co-ordinate
View1024x1024:
        LSLB
        ROLA                    ; Y = Y * 2
        LSLB
        ROLA                    ; Y = Y * 4
        LSLB
        ROLA                    ; Y = Y * 8
        LSLB
        ROLA                    ; Y = Y * 16
        LSLB
        ROLA                    ; Y = Y * 32, 32 bytes per row for scrolling the 16 colour, 512 pixel scrolling screen
        STB     VerticalPosition+1 ; Save the LSB
        LDB     2,S             ; Get MSB of x co-ordinate
        ANDB    #%00000011      ; Get the bits
        LSRB                    ; Move which 256 pointer to the carry
        BCC     >               ; If the carry is clear then we are in the first half of 512k video RAM
        ORA     #%10000000     ; Y will be in the 2nd half of the 512k video block
!       STA     VerticalPosition        ; Update the MSB
        LDA     #%00000010      ; Set to use 1.0 to 1.5 Meg video block
        LSRB                    ; is it going to be in the next 512k Video block?
        BCC     >               ; Skip ahead if not
        INCA                    ; Use 1.5 Meg to 2 Meg video block
!       STA     VideoRamBlock   ; Record which Video Bank block to use
; At this point Y is pointing to the correct Row in the correct 512k Video block
; Set the amount to scroll right
        LDB     3,S             ; Get LSB of x co-ordinate
        LSRB
        LSRB                    ; Horizontal scroll always moves 2 byte (4 pixels), so they can be ignored
        ORB     #%10000000      ; Set the Flag for horiztonal scrolling
        STB     HorizontalPosition      ; Save the position

        BSR     ScreenLocationUpdate    ; Update the screen
        RTS


; Code for handling Scrolling
;
; Get these commands working in BASICto6809
;
; BACKGROUND_DIM SizeX,SizeY
; SizeX must be > 511 and be a multiple of 256
; SizeY must be > 191 and be a multiple of 64
;
VideoRamBlock                       FCB     %00000010   ; Set default to 1 Meg to 1.5 Meg location
VerticalPosition                    FDB     $0000       ; Offset
HorizontalPosition                  FCB     %10000000   ; Bit 7 set = Horizontal scrolling enabled
MapViewBlock                        FCB     $80         ; Map location in Memory to view
ScreenLocationUpdate:
    LDB     $FF02
!   LDB     $FF03
    BPL     <

    LDA     VideoRamBlock   ; Get the video Bank to show
    STA     $FF9B           ; Update Video Bank block  (0,512k,1Meg,1.5Meg) - GIME_VideoBankSelect_FF9B             
    LDD     VerticalPosition
    STD     $FF9D           ; GIME_VerticalOffsetMSB_FF9D      
    LDA     HorizontalPosition       ; Get the x scroll value
    STA     $FF9F           ; Set the scroll pointer - GIME_HorizontalOffset_FF9F   
    RTS


; Scrolling viewport for a playfield of 256 x 7872 (No Horizontal scrolling)
; Show the viewport where y co-ordinate given is the top row of the screen
; Enter with:
; D = y co-ordinate
View256x7872:
        STA     @RestoreA+1     ; Save A (self mod)
        CMPD    #3904           ; If we get here or higher then we need to show the 1.5 Meg to 2Meg video block
        BLO     >               ; If not use the 1 Meg to 1.5 Meg video block
        SUBD    #3904           ; Keep it in the 512k range after multiplying by 16 per row
        STA     @RestoreA+1     ; Save A (self mod)
        LDA     #%00000011      ; Set to use 1.5 to 2 Meg video block
        FCB     $8C             ; Skip the next two bytes (Fake CPMX instruction)
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

        BSR     ScreenLocationUpdate    ; Update the screen
        RTS                     ; return


; Scrolling viewport for a playfield of 256 x 3840 (No Horizontal scrolling)
; Show the viewport where y co-ordinate given is the top row of the screen
; Enter with:
; 2,S = x co-ordinate
; D = y co-ordinate
View512x3840:
        STA     @RestoreA+1     ; Save A (self mod)
        CMPD    #1856           ; If we get here or higher then we need to show the 1.5 Meg to 2Meg video block
        BLO     >               ; If not use the 1 Meg to 1.5 Meg video block
        SUBD    #1856           ; Keep it in the 512k range after multiplying by 16 per row
        STA     @RestoreA+1     ; Save A (self mod)
        LDA     #%00000011      ; Set to use 1.5 to 2 Meg video block
        FCB     $8C             ; Skip the next two bytes (Fake CPMX instruction)
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
        LDB     3,S             ; Get LSB of x co-ordinate
        LSRB
        LSRB                    ; Horizontal scroll always moves 2 byte (4 pixels), so they can be ignored
        ORB     #%10000000      ; Set the Flag for horiztonal scrolling
        STB     HorizontalPosition      ; Save the position

        BSR     ScreenLocationUpdate    ; Update the screen
        RTS

; Scrolling viewport for a playfield of 1024 x 1024
; Show the viewport where the top left corner given x & y co-ordinates
; Enter with:
; 2,S = x co-ordinate
; D = y co-ordinate
View1024x1024:
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
        LDB     2,S             ; Get MSB of x co-ordinate
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
        LDB     3,S             ; Get LSB of x co-ordinate
        LSRB
        LSRB                    ; Horizontal scroll always moves 2 byte (4 pixels), so they can be ignored
        ORB     #%10000000      ; Set the Flag for horiztonal scrolling
        STB     HorizontalPosition      ; Save the position

        BSR     ScreenLocationUpdate    ; Update the screen
        RTS


; Scrolling viewport for a playfield of 4096 x 256
; Show the viewport where the top left corner given x & y co-ordinates
; Enter with:
; 2,S = x co-ordinate
; D = y co-ordinate
View4096x256:
        LDA     #32             ; * 32
        MUL                     ; D = B * 32, 32 bytes per row for scrolling the 16 colour, 512 pixel scrolling screen
        STD     VerticalPosition ; Update the Vertical position to show on screen
        LDA     2,S             ; Get x co-ordinate MSB (value of 0 to 15) $2000 block #
        LSLA
        LSLA
        LSLA
        LSLA
        BPL     >               ; If bit 8 is 0 then we will use Video ram from 1 Meg to 1.5 Megs
        ORA     VerticalPosition
        STA     VerticalPosition ; Update the Vertical position to show on screen
        LDA     #%00000011      ; Get the bits for 1.5 Meg to 2Meg 512k video block
        STA     VideoRamBlock   ; Record which Video Bank block to use
        FCB     $8C             ; Skip the next two bytes (Fake CPMX instruction)
!       ORA     VerticalPosition
        STA     VerticalPosition ; Update the Vertical position to show on screen
        LDA     #%00000010      ; Get the bits for 1 Meg to 1.5 Meg 512k video block
        STA     VideoRamBlock   ; Record which Video Bank block to use
; At this point Y is pointing to the correct Row in the correct 512k Video block
; Set the amount to scroll right
        LDB     3,S             ; Get LSB of x co-ordinate
        LSRB
        LSRB                    ; Horizontal scroll always moves 2 byte (4 pixels), so they can be ignored
        ORB     #%10000000      ; Set the Flag for horiztonal scrolling
        STB     HorizontalPosition      ; Save the position

        BSR     ScreenLocationUpdate    ; Update the screen
        RTS

