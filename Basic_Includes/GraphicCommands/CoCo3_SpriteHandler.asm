; If the new draw is in a different zone then the erase, make them both the same zone.
; Make them both happen in the zone that the erase is going to be in. xxxx


MaxSprites              EQU     32
MaxSpritesToProcess     EQU     32

; Sprite Cache:
; Commands which will be processed when the WAIT VBL command is used
CC3SpriteBlck01 EQU  0          ; Sprite block 0 & 1  Will be setup in $2000 & $4000
CC3SpriteBlck23 EQU  2          ; Sprite block 2 & 3  Will be setup in $6000 & $8000
CC3ScreenBlck01 EQU  4          ; Screen blocks needed to draw/erase  Will be setup in $A000 & $C000
CC3SpriteLoc    EQU  6          ; Sprite X position
CC3SpriteJump   EQU  8          ; Sprite Jump address
CacheEntrySize  EQU  10         ; Size of a sprite cache entry

SpriteCache0:
        RMB     CacheEntrySize*MaxSpritesToProcess      ; Reserve space for the sprite cache for sprites that are in buffer 0
SpriteCacheEnd0:
SpriteCachePointer0:
        FDB     SpriteCache0                            ; Point at the current entry in the sprite cache, to be Blasted with a value
SpriteCache1:
        RMB     CacheEntrySize*MaxSpritesToProcess      ; Reserve space for the sprite cache for sprites that are in buffer 1
SpriteCacheEnd1:
SpriteCachePointer1:
        FDB     SpriteCache1                            ; Point at the current entry in the sprite cache, to be Blasted with a value

SpriteTable:
; Entry is the sprite #
; byte 0 -  0 = Off
;           1 = On
; byte 1 & 2  = Y co-ordniate
; byte 3 & 4  = X co-ordinate
; byte 5      = frame number
; byte 6      = Height of the sprite
; byte 7      = Unused (maybe store the width of the sprite here)
SpriteStatus    EQU     0
SpriteY         EQU     1       ; 1 & 2 it's 16 bit value
SpriteX         EQU     3       ; 3 & 4 it's a 16 bit value
SpriteFrame     EQU     5
SpriteFirstB    EQU     6       ; Height of the sprite
SpriteWidth     EQU     7       ; Y Zone it used for previous sprite, if negative then ignore it
SpriteTableEntries      EQU     SpriteWidth+1
        RMB     SpriteTableEntries*MaxSpritesToProcess

; Called by the Sprite SHOW command
; We will set the sprite frame on the Sprite list then treat it like a draw sprite
ShowSpriteFrame:
; Enter with
; ,S = Return Address
; 2,S = Frame #
; 3,S = Sprite Number
; Change the stack to:
; ,S = Return Address
; 2,S = Frame #
; 3,S & 4,S = y Position (row)
; 5,S & 6,S = x Position (pixel)
; 7,S = Sprite Number
; Then we can jump to the Draw SpriteX routine
        LDD     ,S              ; Get the return address
        LEAS    -4,S
        STD     ,S              ; Save return address
        LDD     6,S             ; A = Frame #, B = Sprite number
        STA     2,S             ; Save the Frame #
        STB     7,S             ; Save the Sprite number
        LDX     #SpriteTable    ; Point at the start of the table
        LSLB                    ; * 2
        LSLB                    ; * 4
        LSLB                    ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                     ; X points at the sprite entry
        STA     SpriteFrame,X   ; Update the frame #
        LDD     SpriteY,X
        STD     3,S             ; Save y Position (row)
        LDD     SpriteX,X
        STD     5,S             ; Save x Position (pixel)
        LDB     7,S             ; B = Sprite number
        JMP     DrawSpriteX     ; Go draw the sprite on screen, B must = Sprite # & X must point to the sprite entry

; Called by the Sprite BACK command (Backup the data behind the sprite)
; Enter with sprite # to backup in B
; 2,S = Sprite #
BackupSpriteB:
; Enter with B is Sprite # to erase
        PSHS    B,X                     ; save sprite #, X = scratch space
        LDX     #SpriteTable            ; Point at the start of the table
        LSLB                            ; * 2
        LSLB                            ; * 4
        LSLB                            ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                             ; X points at the sprite entry
        STX    1,S                      ; Save the sprite entry location
; There was a change so add the sprite to the SpriteCache
; Setup U & Y and set SpriteFirstB,X set to the block on screen the sprite will start being drawn on
        BSR     GetCacheSetupInUY       ; Setup U & Y to point to the correct cache entry to use
                                        ; set SpriteFirstB,X set to the block on screen the sprite will start being drawn on
                                        ; X points at the sprite entry in the sprite table
; U is now pointing at the correct cache entry point for this sprite
; X is pointing at the Sprite Entry
; Prepare more of the sprite cache entry
        LDB     ,S                      ; B = sprite #
        JSR     AddSpriteBlocksToCache  ; Add the sprite blocks to the cache where U is already setup
                                        ; Enter with: B = sprite # U points at the cache entry
                                        ; Kills A
        LDX     1,S                     ; X = The sprite entry location              
        LDD     SpriteY,X               ; D = y co-ordinate
        LDX     SpriteX,X               ; X = x co-ordinate
        JSR     CalcBlockToDraw         ; D = Sprite y co-ordinate, X = Sprite x co-ordinate, U & Y point at the cache entry
                                        ; Updates the U & Y cache pointers with the correct screen blocks

; Get the location of the sprite on screen
        LDX     #SpriteBackupTable      ; Point at the start of the Sprite Backup table
        LDB     ,S                      ; B = sprite #, Fix the stack
        LSLB                            ; * 2 (two byte entries)
        ABX                             ; X points at the sprite Restore routine address
        LDD     ,X                      ; Get the address of the Restore routine screen 0
        STD     CC3SpriteJump,U         ; Save the address of the routine to Restore behind the sprite
        PULS    B,X                     ; B = Sprite #, X = Sprite entry
        JSR     CalcSpriteLocation      ; Calculate the sprite position and
                                        ; update the sprite location in cache, and advance cache U & Y
        LEAY    -CacheEntrySize,Y       ; Y cache isn't needed, fix the update
        STY     SpriteCachePointer1     ; Save the next empty pointer in the Sprite Cache (self mod)
        RTS                             ; Return
; ***********************************************************************************


; ***********************************************************************************
; Called by the Sprite LOCATE command
; Enter with y coordinate in D
SpriteLocate:
; 2,S & 3,S = Y co-ordinate
; 4,S & 5,S = X co-ordinate
; 6,S = Sprite #
; Point at the y & X location of the sprite
        LDX     #SpriteTable            ; Point at the start of the Sprite Table
        LDB     6,S                     ; Get the sprite #
        LSLB                            ; * 2
        LSLB                            ; * 4
        LSLB                            ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                             ; X points at the start of the sprite entry
        LDD     2,S                     ; Get the y co-ordinate off the stack
        STD     SpriteY,X               ; Save the y co-ordinate, save it in the sprite entry
        LDD     4,S                     ; Get the x co-ordinate off the stack
        STD     SpriteX,X               ; Save the x co-ordinate, save it in the sprite entry
        RTS
; ***********************************************************************************
; Hide the sprite on screen (turn it off)
; If the sprite is already off then simply return, otherwise
; Restore behind the sprite, and mark the sprite as off
; Enter with sprite # to Erase in B
; 2,S = Sprite #
SpriteBOff:
        LDX     #SpriteTable            ; Point at the start of the table
        LSLB                            ; * 2
        LSLB                            ; * 4
        LSLB                            ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                             ; X points at the start of the sprite entry
        CLR     SpriteStatus,X          ; Clear the sprite status flag (Turn it off)
        LDB     2,S                     ; Get the sprite #
; Flow through to the EraseSpriteB routine
; ***********************************************************************************
EraseSpriteB:
; Enter with B is Sprite # to erase
        PSHS    B,X                     ; save sprite # & X as scratch space
        LDX     #SpriteTable            ; Point at the start of the table
        LSLB                            ; * 2
        LSLB                            ; * 4
        LSLB                            ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                             ; X points at the sprite entry
        STX     1,S                     ; Seve the sprite entry on the stack
; There was a change so add the sprite to the SpriteCache
; We have cahe 0,1,2 & 3 to be used depending on where the sprite is on screen
        BSR     GetCacheSetupInUY       ; Setup U & Y to point to the correct cache entry to use
                                        ; set SpriteFirstB,X set to the block on screen the sprite will start being drawn on
                                        ; X points at the sprite entry in the sprite table
; U & Y are now pointing at the correct cache entry point for this sprite
; X is pointing at the Sprite Entry
; Prepare more of the sprite cache entry
        LDB     ,S                      ; B = sprite #
        JSR     AddSpriteBlocksToCache  ; Add the sprite blocks to the cache where U & Y are already setup
                                        ; Enter with: B = sprite # U & Y point at the cache entry
                                        ; Kills A
        LDD     SpriteY,X
        LDX     SpriteX,X
        JSR     CalcBlockToDraw         ; D = Sprite y co-ordinate, X = Sprite x co-ordinate, U & Y point at the cache entry
                                        ; Updates the U & Y cache pointers with the correct screen blocks
; Fix blocks for Y, as the restoring will be copying the data from buffer 0 to buffer 1
        SUBA    #$40
        STA     1,Y
        INCA
        STA     2,Y
        INCA
        STA     3,Y

; Get the location of the sprite on screen
        LDX     #SpriteRestoreTable     ; Point at the start of the Sprite Restore table
        LDB     ,S                      ; B = sprite #
        LSLB                            ; * 2 (two byte entries)
        LSLB                            ; * 4 (4 byte entries / Buffer 0 and Buffer 1)
        ABX                             ; X points at the sprite Restore routine address
        LDD     ,X                      ; Get the address of the Restore routine screen 0
        STD     CC3SpriteJump,U         ; Save the address of the routine to Restore behind the sprite
        LDD     2,X                      ; Get the address of the Restore routine screen 1
        STD     CC3SpriteJump,Y         ; Save the address of the routine to Restore behind the sprite
        PULS    B,X                     ; X = Sprite Entry, fix the stack
        JMP     CalcSpriteLocation      ; Calculate the sprite position and
                                        ; update the sprite location in cache, and advance cache
; ***********************************************************************************
; ***********************************************************************************
; Called by the SPRITE # x,y[,f] command
AddSpriteToProcess:
; Enter with B is Frame #
; ,S = Return Address
; 2,S = Frame #
; 3,S & 4,S = y Position (row)
; 5,S & 6,S = x Position (pixel)
; 7,S = Sprite Number
        LDX     #SpriteTable            ; Point at the start of the table
        LDB     7,S                     ; Get the sprite number
        LSLB                            ; * 2
        LSLB                            ; * 4
        LSLB                            ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                             ; X points at the sprite table entry
        LDB     SpriteStatus,X          ; Get the status of the sprite
        BNE     >                       ; If it is on check for changes
        INCA                            ; Flag that the sprite has changed, A now = 1
        STA     SpriteStatus,X          ; Save the new status
        BRA     @AddToCache             ; Update the entry in the cache
; Check to see if anything has changed
; If not then ignore this sprite command
!       CLRA                            ; This is our flag to see if there is a change
@AddToCache:
!       LDB     3,S                     ; Get the Y co-ordinate MSB, request
        CMPB    SpriteY,X               ; Check if the Y co-ordinate MSB has changed
        BEQ     >                       ; If it hasn't changed then don't change the flag
        INCA                            ; Flag that the sprite has changed
        STB     SpriteY,X               ; update the Y co-ordinate MSB
!       LDB     4,S                     ; Get the Y co-ordinate LSB, request
        CMPB    SpriteY+1,X             ; Check if the Y co-ordinate LSB has changed
        BEQ     >                       ; If it hasn't changed then don't change the flag
        INCA                            ; Flag that the sprite has changed
        STB     SpriteY+1,X             ; update the Y co-ordinate LSB
!       LDB     5,S                     ; Get the X co-ordinate MSB, request
        CMPB    SpriteX,X               ; Check if the X co-ordinate MSB has changed
        BEQ     >                       ; If it hasn't changed then don't change the flag
        INCA                            ; Flag that the sprite has changed
        STB     SpriteX,X               ; update the X co-ordinate MSB
!       LDB     6,S                     ; Get the X co-ordinate LSB, request
        CMPB    SpriteX+1,X             ; Check if the X co-ordinate LSB has changed
        BEQ     >                       ; If it hasn't changed then don't change the flag
        INCA                            ; Flag that the sprite has changed
        STB     SpriteX+1,X             ; update the X co-ordinate LSB
!       LDB     2,S                     ; Get the frame number, requested
        CMPB    SpriteFrame,X           ; Check if the frame number has changed
        BEQ     >                       ; If it hasn't changed then don't change the flag
        INCA                            ; Flag that the sprite has changed
        STB     SpriteFrame,X           ; update the frame number
!       TSTA
        BNE     DrawSpriteX             ; If there is a change then add the sprite to the SpriteCache
        RTS                             ; Nothing has changed return

; ***********************************************************************************
; Draw sprite to buffer 0 and use different code to copy from Buffer 0 to buffer 1 
; setup both here
; Enter with:
; B = sprite #
; X points at the sprite entry
DrawSpriteX:
        PSHS    B,X
        BSR     GetCacheSetupInUY       ; Setup U & Y to point to the correct cache entry to use
                                        ; set SpriteFirstB,X set to the block on screen the sprite will start being drawn on
                                        ; X points at the sprite entry in the sprite table

; Prepare more of the sprite cache entry
        PULS    B                       ; Restore B = sprite #
        JSR     AddSpriteBlocksToCache  ; Add the sprite blocks to the cache where U is already setup
                                        ; Enter with: B = sprite # U points at the cache entry
                                        ; Kills A
        LDD     SpriteY,X
        LDX     SpriteX,X
        JSR     CalcBlockToDraw         ; D = Sprite y co-ordinate, X = Sprite x co-ordinate, U & Y point at the cache entry
                                        ; Updates the U & Y cache pointers with the correct screen blocks
; Calculate and point at routine to draw the requested sprite
        PULS    X                       ; Restore X = sprite Entry
        LDA     SpriteX+1,X             ; Get the x co-ordinate (LSB)
        LDB     SpriteFrame,X           ; Get the frame number)
        LDX     #$2000                  ; Point at the start of the sprite draw routine table
; NumberOfColours & PixelsMaxX values will be set by the Tokenizer, these conditions allow it to work for 2, 4 or 16 colour modes
; Handle 2 colour mode
 IFEQ NumberOfColours-2
        LSLB            ; * 2
        LSLB            ; * 4
        LSLB            ; * 8 (8 shifted sprites) per frame
        ABX
        ABX             ; * 2 byte entries, this way it can handle 32 frames per sprite
        ANDA    #$07    ; Get the pixel offset for 2 colour mode
 ENDIF
 ; Handle 4 colour mode
 IFEQ NumberOfColours-4
        LSLB            ; * 2
        LSLB            ; * 4 (4 shifted sprites) per frame
        LSLB            ; * 2 byte entries, this way it can handle 32 frames per sprite
        ABX             ; X = X + B
        ANDA    #$03    ; Get the pixel offset for 4 colour mode
 ENDIF
 ; Handle 16 colour mode
 IFEQ NumberOfColours-16
        LSLB            ; * 2 (Each frame has a Left nibble and right nibble)
        LSLB            ; * 2 (Each frame has a Even and odd drawing routine)
        ABX             ; X = X + B
        ANDA    #$01    ; Get the pixel offset for 16 colour mode
 ENDIF 
        LSLA            ; * 2 (two bytes per entry in the jump table)
        LEAX    A,X     ; X = X + A
        LDA     CC3SpriteBlck01,U      ; Get the block number for this sprite
        STA     $FFA1   ; Change the block number to the one we want
;        PSHS    U       ; Save U
;        LDU     2,X     ; Get routine to draw the sprite in U for buffer 1
        LDD     ,X      ; Get routine to draw the sprite in X for buffer 0
; Make sure the location to draw the sprite is in the 4 blocks we will load before drawing
        PSHS    D
        SUBA    #$20
        CLRB
        LSLA
        ROLB
        LSLA
        ROLB
        LSLA
        ROLB            ; B = A / 32 (B = 0 to 7)
        PSHS    B
        ADDB    CC3SpriteBlck01,U
        STB     CC3SpriteBlck01,U
        STB     CC3SpriteBlck01,Y
        INCB
        STB     CC3SpriteBlck01+1,U
        STB     CC3SpriteBlck01+1,Y
        INCB
        STB     CC3SpriteBlck23,U
        STB     CC3SpriteBlck23,Y
        INCB
        STB     CC3SpriteBlck23+1,U
        STB     CC3SpriteBlck23+1,Y
        PULS    B
        LSLB            ; B = B * 2 (0 to 14)
        LSLB            ; * 2
        LSLB            ; * 4
        LSLB            ; * 8
        LSLB            ; * 16
        PSHS    B
        LDD     1,S
        SUBA    ,S
        TFR     D,X
        LEAS    3,S     ; Fi the stack
        LDA     #$39    ; Normal Block#
        STA     $FFA1   ; Set it back to normal
;        STU     CC3SpriteJump,Y ; Save the sprite/frame routine address in the Sprite Cache - Buffer 1
;        PULS    U               ; Restore U
        STX     CC3SpriteJump,U ; Save the sprite/frame routine address in the Sprite Cache - Buffer 0
        STX     CC3SpriteJump,Y ; Save the sprite/frame routine address in the Sprite Cache - Buffer 1
        LDB     7,S     ; Get the sprite number
        LDX     #SpriteTable    ; Point at the start of the table
        LSLB                    ; * 2
        LSLB                    ; * 4
        LSLB                    ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                     ; X points at the sprite entry

        JSR     CalcSpriteLocation      ; Calculate the sprite position and
                                        ; update the sprite location in cache, and advance cache and return.


; Fix pointer for erasing buffer 1
        LDA     CC3SpriteLoc-CacheEntrySize,Y
        ADDA    #$60
        STA     CC3SpriteLoc-CacheEntrySize,Y
        RTS
; ***********************************************************************************

; ***********************************************************************************
; Find where sprite is on screen and set U & Y to point to the correct cache location to use
; Also set which Block the sprite will be drawn at in SpriteFirstB,X
; Enter with:
; X points at the sprite entry in the sprite table
GetCacheSetupInUY:
        LDD     SpriteY,X       ; Get the Y value of the top left corner of the sprite
        SUBD    ViewPortY       ; B = where on the screen the top of the sprite is

 IFEQ Scrolling                 ; If scrolling = 0 then
        LDA     #GmodeBytesPerRow
        MUL                     ; D = the location in RAM this sprite will be drawn
 ENDIF                          ; If scrolling = 1 then A already = the row * 256 
        CLRB
        LSLA
        ROLB
        LSLA
        ROLB
        LSLA
        ROLB                            ; B= A / $20 , we now know which $2000 byte block on screen the sprite will start drawing in
        STB     SpriteFirstB,X          ; Save the Starting block on screen the sprite is in
!       LDU     SpriteCachePointer0     ; U points at the entry in the sprite change cache
        CMPU    #SpriteCacheEnd0        ; Have we reached the end of the cache?
        BNE     >                       ; If not then return
        BSR     DoWaitVBL               ; Otherwise update screen which will empty the cache and return
        BRA     <                       ; Go update U properly
!       LDY     SpriteCachePointer1     ; Y points at the entry in the sprite change cache
        CMPY    #SpriteCacheEnd1        ; Have we reached the end of the cache?
        BNE     >                       ; If not then return
        BSR     DoWaitVBL               ; Otherwise update screen which will empty the cache and return
        BRA     <                       ; Go update Y properly
!       RTS                             ; Return

; Handle the WAIT VBL command
; 1 - We will show Screen 1
; 2 - Update screen 0 with sprite cache commands
; 3 - Show screen 0
; 4 - Update screen 1 with sprite cache commands
; 5 - reset sprite cache pointer to the beginning of the cache
DoWaitVBL:
; 1 - Show Screen 1
; Wait for VSYNC
        LDB     $FF02                   ; Reset Vsync flag
!       LDB     $FF03                   ; See if Vsync has occurred yet
        BPL     <                       ; If not then keep looping, until the Vsync occurs
; Show Screen 1
        LDA     #%00000011                      ; Show buffer 1 (1.5 Meg)
        STA     GIME_VideoBankSelect_FF9B       ; Update Video Bank block (0,512k,1Meg,1.5Meg) - GIME_VideoBankSelect_FF9B
;        LDD     VerticalPosition                ; Get the position in RAM to show at the top left corner of the screen
;        STD     GIME_VerticalOffset1_FF9D       ; GIME_VerticalOffsetMSB_FF9D      
;        LDA     HorizontalPosition              ; Get the x scroll value
;        STA     GIME_HorizontalOffset_FF9F      ; Set the scroll pointer - GIME_HorizontalOffset_FF9F 

; 2 - Update screen 0 with sprite cache commands
        LDU     #SpriteCache0           ; U = The Sprite Cache start for zone 0
!       CMPU    SpriteCachePointer0     ; Have we processed all the sprite commands?
        BEQ     >
        PULU    D,X                     ; Get the sprite blocks
        STD     $FFA1                   ; Sprite first two blocks
        STX     $FFA3                   ; Sprite 3rd and 4th blocks
        PULU    D,X,Y                   ; D = Blocks for Screen, X with screen position and Y with JSR address, and move U to the next sprite cache entry
        STD     $FFA5                   ; Screen Blocks 1 & 2
        INCB
        STB     $FFA7                   ; Screen block 3
        STU     @RestoreU+1             ; Self mod, save U
        JSR     ,Y                      ; Go do the routine
@RestoreU:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed
; Reset sprite cache pointer to the beginning of the cache
!       LDU     #SpriteCache0           ; U = The Sprite Cache0 start
        STU     SpriteCachePointer0     ; Reset the Sprite Cache0 Pointer

        LDB     $FF02                   ; Reset Vsync flag
!       LDB     $FF03                   ; See if Vsync has occurred yet
        BPL     <                       ; If not then keep looping, until the Vsync occurs

; 3 - Show screen 0
        LDA     #%00000010                      ; Show buffer 0 (1.0 Meg)
        STA     GIME_VideoBankSelect_FF9B       ; Update Video Bank block (0,512k,1Meg,1.5Meg) - GIME_VideoBankSelect_FF9B
        LDD     VerticalPosition                ; Get the position in RAM to show at the top left corner of the screen
        STD     GIME_VerticalOffset1_FF9D       ; GIME_VerticalOffsetMSB_FF9D      
        LDA     HorizontalPosition              ; Get the x scroll value
        STA     GIME_HorizontalOffset_FF9F      ; Set the scroll pointer - GIME_HorizontalOffset_FF9F 

; 4 - Update screen 1 with sprite cache commands
        LDU     #SpriteCache1           ; U = The Sprite Cache start for buffer 1
!       CMPU    SpriteCachePointer1     ; Have we processed all the sprite commands?
        BEQ     >
        PULU    D,X                     ; Get the sprite blocks
        STD     $FFA1                   ; Sprite first two blocks
        STX     $FFA3                   ; Sprite 3rd and 4th blocks
        PULU    D,X,Y                   ; D = Blocks for Screen, X with screen position and Y with JSR address, and move U to the next sprite cache entry
        STD     $FFA5                   ; Screen Blocks 1 & 2
        INCB
        STB     $FFA7                   ; Screen block 3
        STU     @RestoreU+1             ; Self mod, save U
        JSR     ,Y                      ; Go do the routine
@RestoreU:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed
; Reset sprite cache pointer to the beginning of the cache
!       LDU     #SpriteCache1           ; U = The Sprite Cache0 start
        STU     SpriteCachePointer1     ; Reset the Sprite Cache0 Pointer
; Restore RAM to normal
        LDD     #$393A
        STD     $FFA1
        LDD     #$3B3C
        STD     $FFA3
        LDD     #$3D3E
        STD     $FFA5
        INCB
        STB     $FFA7                   ; Return blocks to normal
        RTS                             ; Return                

; ***********************************************************************************
; Add the sprite blocks to the cache where U is already setup
; Enter with:
; B = sprite #
; U points at the cache entry
; Kills A
AddSpriteBlocksToCache:
        PSHS    X
        LDX     #CC3SpritesStartBLKTable ; Point at the table with the starting bank of each sprite
        LDA     B,X                     ; A = the sprite start block number
        STA     CC3SpriteBlck01,U
        STA     CC3SpriteBlck01,Y
        INCA
        STA     CC3SpriteBlck01+1,U     ; Save the sprite block numbers
        STA     CC3SpriteBlck01+1,Y     ; Save the sprite block numbers
        INCA
        STA     CC3SpriteBlck23,U
        STA     CC3SpriteBlck23,Y
        INCA
        STA     CC3SpriteBlck23+1,U     ; Sprite location blocks have been updated
        STA     CC3SpriteBlck23+1,Y     ; Sprite location blocks have been updated
        PULS    X,PC
; ***********************************************************************************
; Updates the U & Y cache pointer with the screen blocks to draw to
; Enter with:
; D = Sprite y co-ordinate
; X = Sprite x co-ordinate
; U = The Cache entry point already setup
; Calculate where to draw the sprite
CalcBlockToDraw:
;        LDD     ViewPortY
;        LDX     ViewPortX
;
 IFEQ PLAYFIELD                         ; If no scrolling
; A = block where the GMODE Page is in RAM
        CLRA            ; Need to calc this, but leave at zero for testing
 ENDIF
 ; Code to get the Block where the sprite starts:
 IFEQ PLAYFIELD-1
; Enter with D = Sprite y co-ordinate
        JSR     CalcBlocks256x7872      ; returns with block in A   
 ENDIF
 IFEQ PLAYFIELD-2
; Enter with D = Sprite y co-ordinate
        JSR     Calc512x3840            ; returns with block in A   
 ENDIF
 IFEQ PLAYFIELD-3
; Enter with:
; D = Sprite y co-ordinate
; X = Sprite x co-ordinate
        JSR     Calc1024x1024           ; returns with block in A   
 ENDIF
 IFEQ PLAYFIELD-4
; Enter with:
; D = Sprite y co-ordinate
; X = Sprite x co-ordinate
; Enter with D = Sprite y co-ordinate
        JSR     Calc4096x256            ; returns with block in A   
 ENDIF
 IFEQ PLAYFIELD-5
; Enter with:
; D = Sprite y co-ordinate
; X = Sprite x co-ordinate
; Enter with D = Sprite y co-ordinate
        JSR     Calc2560x192            ; returns with block in A   
 ENDIF
;
        STA     CC3ScreenBlck01,U       ; Save the screen block numbers
        INCA
        STA     CC3ScreenBlck01+1,U     ; Save the screen block numbers
        ADDA    #$40                    ; Draw on screen 1
        STA     CC3ScreenBlck01+1,Y     ; Save the screen block numbers
        DECA
        STA     CC3ScreenBlck01,Y       ; Save the screen block numbers
        RTS
; ***********************************************************************************

; ***********************************************************************************
; Calculate where to draw the sprite
; Calculate the sprite location in RAM and update the Sprite Location in the U cache + advance the U cache pointer
CalcSpriteLocation:       
        PSHS    Y
        LEAY    ,X
 IFEQ PLAYFIELD                         ; If no scrolling
        LDA     #GmodeBytesPerRow       ; # of bytes per row
        LDB     SpriteY+1,Y             ; Get the y co-ordinate LSB (self modded above)
        MUL                             ; D = Number bytes per row * y co-ordinate which gives us the row offset
        ADDD    BEGGRP                  ; D=D+Screen start location add the screen start location
        ADDD    #$4000                  ; D = D + $4000 to get it to $A000 Mem block $FFA6
 ENDIF

 IFEQ PLAYFIELD-1
; 128 bytes per row
        LDD     SpriteY,Y               ; D = the Y co-ordinate
;        SUBD    ViewPortY               ; B is the row to start on
;        ANDB    #%00111111              ; Make it from 0 to 63
        TFR     B,A                     ; D = B * 256
        CLRB
        LSRA
        RORB                            ; D = B * 128 (bytes per row)
        ANDA    #%00011111              ; Keep the value from 0 to $1FFF
        ADDD    #$A000                  ; D = D + $A000 Mem block $FFA5
 ENDIF
 IFEQ PLAYFIELD-2
; 256 bytes per row
;        LDD     SpriteY,Y               ; D = the Y co-ordinate
;        SUBD    ViewPortY               ; B is the row to start on
;        ANDB    #%00011111              ; Make it from 0 to 31
;        TFR     B,A                     ; D = B * 256
        LDA     SpriteY+1,Y              ; A = the Y co-ordinate (LSB)
        CLRB
        ANDA    #%00011111              ; Keep the value from 0 to $1FFF
        ADDD    #$A000                  ; D = D + $A000 Mem block $FFA5
 ENDIF
 IFEQ PLAYFIELD-3
; 256 bytes per row
        LDD     SpriteY,Y               ; D = the Y co-ordinate
        SUBD    ViewPortY               ; B is the row to start on
        ANDB    #%00011111              ; Make it from 0 to 31
        TFR     B,A                     ; D = B * 256
        ADDD    #$A000                  ; D = D + $A000 Mem block $FFA5
 ENDIF
 IFEQ PLAYFIELD-4
; 256 bytes per row
        LDD     SpriteY,Y               ; D = the Y co-ordinate
        SUBD    ViewPortY               ; B is the row to start on
        ANDB    #%00011111              ; Make it from 0 to 31
        TFR     B,A                     ; D = B * 256
        ADDD    #$A000                  ; D = D + $A000 Mem block $FFA5
 ENDIF
 IFEQ PLAYFIELD-5
; 256 bytes per row
;        LDD     SpriteY,Y               ; D = the Y co-ordinate
;        SUBD    ViewPortY               ; B is the row to start on
;        ANDB    #%00011111              ; Make it from 0 to 31
;        TFR     B,A                     ; D = B * 256
        LDA     SpriteY+1,Y             ; A = y co-ordinate * 256
        CLRB                            ; Clear B
        ANDA    #%00011111              ; Keep the value of D from 0 to $1FFF
        ADDA    #$A0                    ; D = D + $A000 Mem block $FFA5
 ENDIF
        TFR     D,X                     ; X now has the starting Row offset
        LDD     SpriteX,Y               ; D = the x position (pixel)
        PULS    Y                       ; Y = pointer to buffer 1 again
; Fall through to update the sprite location in cache, and advance cache and return.

; Calculate the sprite location in RAM and update the Sprite Location in the U cache + advance the U cache pointer
; D = the x position (pixel)
; X = the Row on screen
SaveSpriteLocationAtUY:
; NumberOfColours & PixelsMaxX values will be set by the Tokenizer, these conditions optimize the code
; Handle 2 colour mode
 IFEQ Scrolling-1       ; If scrolling = 1 then we have a 256 byte wide (512 pixel) screen with 16 colours
        LDA     MatchViewport
        LSRA
        RORB            ; / 2, Every byte holds two pixels
 ; B will be from 0 to 255 which is where on this row we need to draw the sprite
        LEAX    D,X             ; X now points at the starting byte location
 ELSE
 IFEQ NumberOfColours-2
 IFLT PixelsMaxX-256
        LSRB            ; / 2
        LSRB            ; / 4
        LSRB            ; / 8 = byte
        ABX             ; X now points at the starting byte location on screen 0
 ELSE
        LSRA
        RORB            ; / 2
        LSRA
        RORB            ; / 4
        LSRA
        RORB            ; / 8 = byte
        LEAX    D,X     ; X now points at the starting byte location on screen 0
 ENDIF
 ENDIF
; Handle 4 colour mode
 IFEQ NumberOfColours-4
 IFLT PixelsMaxX-256
        LSRB            ; / 2
        LSRB            ; / 4
        ABX             ; X now points at the starting byte location on screen 0
 ELSE
        LSRA
        RORB            ; / 2
        LSRA
        RORB            ; / 4
        LEAX    D,X     ; X now points at the starting byte location on screen 0
 ENDIF
 ENDIF
; Handle 16 colour mode
 IFEQ NumberOfColours-16
 IFLT PixelsMaxX-256
        LSRB            ; / 2
        ABX             ; X now points at the starting byte location on screen 0
 ELSE
        LSRA
        RORB            ; / 2
        LEAX    D,X     ; X now points at the starting byte location on screen 0
 ENDIF
 ENDIF
 ENDIF
        STX     CC3SpriteLoc,U          ; Save the location of the sprite on screen in the cache
        LEAU    CacheEntrySize,U        ; Point at the next empty pointer in the Sprite Cache
CC3_UpdateCache0:
        STU     SpriteCachePointer0     ; Save the next empty pointer in the Sprite Cache (self mod)

        LEAX    -$6000,X                ; Point X at the source buffer 0 screen
        STX     CC3SpriteLoc,Y          ; Save the location of the sprite on screen in the cache
        LEAY    CacheEntrySize,Y        ; Point at the next empty pointer in the Sprite Cache
CC3_UpdateCache1:
        STY     SpriteCachePointer1     ; Save the next empty pointer in the Sprite Cache (self mod)
        RTS                             ; Return
; ***********************************************************************************