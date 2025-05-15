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
        RMB     CacheEntrySize*MaxSpritesToProcess      ; Reserve space for the sprite cache for sprites that are in zone 1
SpriteCacheEnd0:
SpriteCachePointer0:
        FDB     SpriteCache0                            ; Point at the current entry in the sprite cache, to be Blasted with a value
SpriteCache1:
        RMB     CacheEntrySize*MaxSpritesToProcess      ; Reserve space for the sprite cache for sprites that are in zone 1
SpriteCacheEnd1:
SpriteCachePointer1:
        FDB     SpriteCache1                            ; Point at the current entry in the sprite cache, to be Blasted with a value
SpriteCache2:
        RMB     CacheEntrySize*MaxSpritesToProcess      ; Reserve space for the sprite cache for sprites that are in zone 1
SpriteCacheEnd2:
SpriteCachePointer2:
        FDB     SpriteCache2                            ; Point at the current entry in the sprite cache, to be Blasted with a value
SpriteCache3:
        RMB     CacheEntrySize*MaxSpritesToProcess      ; Reserve space for the sprite cache for sprites that are in zone 1
SpriteCacheEnd3:
SpriteCachePointer3:
        FDB     SpriteCache3                            ; Point at the current entry in the sprite cache, to be Blasted with a value

; Table to figure out which U to really use if draw zone is different than the previous erase zone
ZoneCacheTable:
        FDB     SpriteCachePointer0,SpriteCache0
        FDB     SpriteCachePointer1,SpriteCache1
        FDB     SpriteCachePointer2,SpriteCache2
        FDB     SpriteCachePointer3,SpriteCache3

SpriteTable:
; Entry is the sprite #
; byte 0 -  0 = Off
;           1 = On
; byte 1 & 2  = Y co-ordniate
; byte 3 & 4  = X co-ordinate
; byte 5      = frame number
; byte 6      = Height of the sprite
; byte 7      = flag if sprite has been drawn during FIRQ
SpriteStatus    EQU     0
SpriteY         EQU     1       ; 1 & 2 it's 16 bit value
SpriteX         EQU     3       ; 3 & 4 it's a 16 bit value
SpriteFrame     EQU     5
SpriteHeight    EQU     6       ; Height of the sprite
SpriteLastB     EQU     7       ; Y Zone it used for previous sprite, if negative then ignore it
SpriteTableEntries      EQU     SpriteLastB+1
        RMB     SpriteTableEntries*MaxSpritesToProcess

; drawing 1
; erasing old in 2
; erasing 1
;
; We need to either erase old in 1 before drawing 1 or
; draw 1 in 2 after the old in 2 ***
; erasing old in 2 is already in the cache for zone 2, so we need to add draw in zone 1 be in zone 2 instead
; How do we know where the previous erase zone was.

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

; Called by the Sprite BACK command
; Enter with sprite # to backup in B
; 2,S = Sprite #
BackupSpriteB:
; Enter with B is Sprite # to erase
        PSHS    B                       ; save sprite #
        LDX     #SpriteTable            ; Point at the start of the table
        LSLB                            ; * 2
        LSLB                            ; * 4
        LSLB                            ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                             ; X points at the sprite entry
        LEAY    ,X                      ; Y = X = the sprite entry
; There was a change so add the sprite to the SpriteCache
; We have cahe 0,1,2 & 3 to be used depending on where the sprite is on screen
        LDB     SpriteLastB,Y
        BMI     @ignore         ; If the last one was flagged as a negative number then ther was no erase command previous
        PSHS    B
        BSR     GetCacheZoneInU ; Setup U to point to the correct cache zone entry to use
                                ; X points at the sprite entry in the sprite table
        LDB     ,S+             ; Get the old erase zone,  fix the stack
        CMPB    SpriteLastB,Y   ; is it the same as the new zone block?
        BEQ     @UpdateB        ; if they are the same we are good skip ahead
        STB     SpriteLastB,Y   ; Save it for the draw compare
; Get here when the draw is going to be in a different zone then the previous erase for this sprite
; We need to change U (zone) to match the U (zone) of the previous erase command
; 
        LDX     #ZoneCacheTable ; Point at the table of U pointers
        LSLB                    ; B=B*2
        LSLB                    ; B=B*4 (four bytes per entry)
        ABX
        LDU     ,X
        STU     CC3_UpdateCache+1       ; Save the address of the cache (self mod)
        LDU     [,X]                    ; U now points at the new and correct entry
        CMPU    ,X                      ; Check if we are at the end of the cache?
        BNE     @UpdateB                ; carry on with U pointing at the location
        JSR     DoWaitVBL               ; Go update screen which will empty the cache
!       LDU     2,X                     ; Get the address of the SpriteCachePointer0
        LDU     ,U                      ; U points at the next entry is the sprite change cache
        BRA     @UpdateB
@ignore
        BSR     GetCacheZoneInU ; Setup U to point to the correct cache zone entry to use
                                ; X points at the sprite entry in the sprite table
; U is now pointing at the correct cache entry point for this sprite
; Y is pointing at the Sprite Entry
; Prepare more of the sprite cache entry
@UpdateB:
        LDB     ,S                      ; B = sprite #
        JSR     AddSpriteBlocksToCache  ; Add the sprite blocks to the cache where U is already setup
                                        ; Enter with: B = sprite # U points at the cache entry
                                        ; Kills A & X
        LDD     SpriteY,Y
        LDX     SpriteX,Y
        JSR     CalcBlockToDraw         ; D = Sprite y co-ordinate, X = Sprite x co-ordinate, U points at the cache entry
                                        ; Updates the U cache pointer with the correct screen blocks

; Get the location of the sprite on screen
        LDX     #SpriteBackupTable      ; Point at the start of the Sprite Backup table
        LDB     ,S+                     ; B = sprite #, Fix the stack
        LSLB                            ; * 2 (two byte entries)
        ABX                             ; X points at the sprite Restore routine address
        LDD     ,X                      ; Get the address of the Restore routine screen 0
        STD     CC3SpriteJump,U         ; Save the address of the routine to Restore behind the sprite
        JMP     CalcSpriteLocation      ; Calculate the sprite position and
                                        ; update the sprite location in cache, and advance cache and return.
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
        PSHS    B                       ; save sprite #
        LDX     #SpriteTable            ; Point at the start of the table
        LSLB                            ; * 2
        LSLB                            ; * 4
        LSLB                            ; B = B * 8, 8 Entries per sprite in the sprite table
        ABX                             ; X points at the sprite entry
        LEAY    ,X                      ; Y = X = the sprite entry
; There was a change so add the sprite to the SpriteCache
; We have cahe 0,1,2 & 3 to be used depending on where the sprite is on screen
        BSR     GetCacheZoneInU ; Setup U to point to the correct cache zone entry to use
                                ; X points at the sprite entry in the sprite table
; U is now pointing at the correct cache entry point for this sprite
; Y is pointing at the Sprite Entry
; Prepare more of the sprite cache entry
        LDB     ,S                      ; B = sprite #
        JSR     AddSpriteBlocksToCache  ; Add the sprite blocks to the cache where U is already setup
                                        ; Enter with: B = sprite # U points at the cache entry
                                        ; Kills A & X
        LDD     SpriteY,Y
        LDX     SpriteX,Y
        JSR     CalcBlockToDraw         ; D = Sprite y co-ordinate, X = Sprite x co-ordinate, U points at the cache entry
                                        ; Updates the U cache pointer with the correct screen blocks

; Get the location of the sprite on screen
        LDX     #SpriteRestoreTable     ; Point at the start of the Sprite Restore table
        LDB     ,S+                     ; B = sprite #, Fix the stack
        LSLB                            ; * 2 (two byte entries)
        ABX                             ; X points at the sprite Restore routine address
        LDD     ,X                      ; Get the address of the Restore routine screen 0
        STD     CC3SpriteJump,U         ; Save the address of the routine to Restore behind the sprite
        JMP     CalcSpriteLocation      ; Calculate the sprite position and
                                        ; update the sprite location in cache, and advance cache and return.
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
; Draw sprite (add it to the proper cache)
; Wnter with:
; B = sprite #
; X points at the sprite entry
DrawSpriteX:
        STB     @UpdateB+1              ; save sprite # (self modded below)
        LEAY    ,X                      ; Y = X = the sprite entry
; There was a change so add the sprite to the SpriteCache
; We have cahe 0,1,2 & 3 to be used depending on where the sprite is on screen
        LDB     SpriteLastB,Y
        BMI     @ignore         ; If the last one was flagged as a negative number then ther was no erase command previous
        PSHS    B
        BSR     GetCacheZoneInU ; Setup U to point to the correct cache zone entry to use
                                ; X points at the sprite entry in the sprite table
        LDB     ,S+             ; Get the old erase zone,  fix the stack
        CMPB    SpriteLastB,Y   ; is it the same as the new zone block?
        BEQ     @UpdateB        ; if they are the same we are good skip ahead
        STB     SpriteLastB,Y   ; Save it for the draw compare
; Get here when the draw is going to be in a different zone then the previous erase for this sprite
; We need to change U (zone) to match the U (zone) of the previous erase command
; 
        LDX     #ZoneCacheTable ; Point at the table of U pointers
        LSLB                    ; B=B*2
        LSLB                    ; B=B*4 (four bytes per entry)
        ABX
        LDU     ,X
        STU     CC3_UpdateCache+1       ; Save the address of the cache (self mod)
        LDU     [,X]                    ; U now points at the new and correct entry
        CMPU    ,X                      ; Check if we are at the end of the cache?
        BNE     @UpdateB                ; carry on with U pointing at the location
        JSR     DoWaitVBL               ; Go update screen which will empty the cache
!       LDU     2,X                     ; Get the address of the SpriteCachePointer0
        LDU     ,U                      ; U points at the next entry is the sprite change cache
        BRA     @UpdateB
@ignore
        BSR     GetCacheZoneInU ; Setup U to point to the correct cache zone entry to use
                                ; X points at the sprite entry in the sprite table
; Prepare more of the sprite cache entry       
@UpdateB:
        LDB     #$FF                    ; B = sprite # (self modded above)
        JSR     AddSpriteBlocksToCache  ; Add the sprite blocks to the cache where U is already setup
                                        ; Enter with: B = sprite # U points at the cache entry
                                        ; Kills A & X
        LDD     SpriteY,Y
        LDX     SpriteX,Y
        JSR     CalcBlockToDraw         ; D = Sprite y co-ordinate, X = Sprite x co-ordinate, U points at the cache entry
                                        ; Updates the U cache pointer with the screen blocks
; Calculate and point at routine to draw the requested sprite
        LDX     #$2000                  ; Point at the start of the sprite draw routine table
        LDB     SpriteFrame,Y           ; Get the frame number
; NumberOfColours & PixelsMaxX values will be set by the Tokenizer, these conditions allow it to work for 2, 4 or 16 colour modes
; Handle 2 colour mode
 IFEQ NumberOfColours-2
        LSLB            ; * 2
        LSLB            ; * 4
        LSLB            ; * 8 (8 shifted sprites) per frame
        ABX
        ABX             ; * 2 byte entries, this way it can handle 32 frames per sprite
        LDB     SpriteX+1,Y     ; Get the x co-ordinate (LSB)
        ANDB    #$07    ; Get the pixel offset for 2 colour mode
 ENDIF
 ; Handle 4 colour mode
 IFEQ NumberOfColours-4
        LSLB            ; * 2
        LSLB            ; * 4 (4 shifted sprites) per frame
        LSLB            ; * 2 byte entries, this way it can handle 32 frames per sprite
        ABX             ; X = X + B
        LDB     SpriteX+1,Y     ; Get the x co-ordinate (LSB)
        ANDB    #$03    ; Get the pixel offset for 4 colour mode
 ENDIF
 ; Handle 16 colour mode
 IFEQ NumberOfColours-16
        LSLB            ; * 2 (Each frame has a Left nibble and right nibble)
        ABX             ; X = X + B
        LDB     SpriteX+1,Y     ; Get the x co-ordinate (LSB)
        ANDB    #$01    ; Get the pixel offset for 16 colour mode
 ENDIF
        LSLB            ; * 2 (two bytes per entry in the jump table)
        ABX             ; X = X + B
        LDB     7,S     ; Get the sprite number
        LDA     CC3SpriteBlck01,U      ; Get the block number for this sprite
        STA     $FFA1   ; Change the block number to the one we want
        LDX     ,X      ; Get routine to draw the sprite in X
        LDA     #$39
        STA     $FFA1   ; Set it back to normal
        STX     CC3SpriteJump,U ; Save the sprite/frame routine address in the Sprite Cache
        JMP     CalcSpriteLocation      ; Calculate the sprite position and
                                        ; update the sprite location in cache, and advance cache and return.
; ***********************************************************************************

; ***********************************************************************************
; Find where sprite is on screen and set U to point to the correct cache zone to use
; Enter with:
; X points at the sprite entry in the sprite table
GetCacheZoneInU:
        LDD     SpriteY,X       ; Get the Y value of the top left corner of the sprite
        SUBD    ViewPortY       ; B = where on the screen the top of the sprite is
        ADDB    SpriteHeight,X  ; Point at the bottom of the sprite
; It is in zone 1
        CMPB    #CheckSprite1           ; is it in zone 1?
        BHI     @CheckZone2             ; if not check zone 2
        LDB     #1
        STB     SpriteLastB,X           ; Save the zone we are in
!       LDU     #SpriteCachePointer1    ; Get the address of the SpriteCachePointer1
        STU     CC3_UpdateCache+1       ; Save the address of the cache (self mod)
        LDU     ,U                      ; U points at the next entry is the sprite change cache
        CMPU    #SpriteCacheEnd1        ; Have we reached the end of the cache?
        BNE     >                       ; If not then return
        BSR     DoWaitVBL               ; Otherwise update screen which will empty the cache and return
        BRA     <                       ; Go update U properly
!       RTS                             ; Return
; It is in zone 2
@CheckZone2:
        CMPB    #CheckSprite2           ; is it in zone 2?
        BHI     @CheckZone3             ; if not check zone 3
        LDB     #2
        STB     SpriteLastB,X           ; Save the zone we are in
!       LDU     #SpriteCachePointer2    ; Get the address of the SpriteCachePointer2
        STU     CC3_UpdateCache+1       ; Save the address of the cache (self mod)
        LDU     ,U                      ; U points at the next entry is the sprite change cache
        CMPU    #SpriteCacheEnd2        ; Have we reached the end of the cache?
        BNE     >                       ; If not then return
        BSR     DoWaitVBL               ; Otherwise update screen which will empty the cache and return
        BRA     <                       ; Go update U properly
!       RTS                             ; Return
; It is in zone 3
@CheckZone3:
        CMPB    #CheckSprite3           ; is it in zone 3?
        BHI     @CheckZone0             ; if not it's in zone 0
        LDB     #3
        STB     SpriteLastB,X           ; Save the zone we are in
!       LDU     #SpriteCachePointer3    ; Get the address of the SpriteCachePointer3
        STU     CC3_UpdateCache+1       ; Save the address of the cache (self mod)
        LDU     ,U                      ; U points at the next entry is the sprite change cache
        CMPU    #SpriteCacheEnd3        ; Have we reached the end of the cache?
        BNE     >                       ; If not then return
        BSR     DoWaitVBL               ; Otherwise update screen which will empty the cache and return
        BRA     <                       ; Go update U properly
!       RTS                             ; Return
; It is in zone 0
@CheckZone0:
        CLRB
        STB     SpriteLastB,X           ; Save the zone we are in
!       LDU     #SpriteCachePointer0    ; Get the address of the SpriteCachePointer0
        STU     CC3_UpdateCache+1       ; Save the address of the cache (self mod)
        LDU     ,U                      ; U points at the next entry is the sprite change cache
        CMPU    #SpriteCacheEnd0        ; Have we reached the end of the cache?
        BNE     >                       ; If not then return
        BSR     DoWaitVBL               ; Otherwise update screen which will empty the cache and return
        BRA     <                       ; Go update U properly
!       RTS                             ; Return

; Handle the WAIT VBL command
; Process all the sprites in all four caches, Caches will be cleared/reset when complete
DoWaitVBL:
        CLR     DoingSpritesFlag        ; This allows the FIRQ & IRQ to update the sprites in their zone
!       LDA     DoingSpritesFlag        ; Each zone will have there bit set when they have drawn all the sprites in that section
        CMPA    #%00001111              ; Have each zone completed drawing/handling the sprites in their area?
        BNE     <                       ; If not keep checking until they are complete
        LDA     #%10001111              ; Set bit 7 so no sprite updates will occur
        STA     DoingSpritesFlag        ; Save it
        RTS                             ; Return

; ***********************************************************************************
; Add the sprite blocks to the cache where U is already setup
; Enter with:
; B = sprite #
; U points at the cache entry
; Kills A
AddSpriteBlocksToCache:
        LDX     #CC3SpritesStartBLKTable ; Point at the table with the starting bank of each sprite
        LDA     B,X                     ; A = the sprite start block number
        STA     CC3SpriteBlck01,U
        INCA
        STA     CC3SpriteBlck01+1,U     ; Save the sprite block numbers
        INCA
        STA     CC3SpriteBlck23,U
        INCA
        STA     CC3SpriteBlck23+1,U     ; Sprite location blocks have been updated
        RTS
; ***********************************************************************************
; Updates the U cache pointer with the screen blocks to draw to
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
        JSR     Calc5120x192            ; returns with block in A   
 ENDIF
;
        STA     CC3ScreenBlck01,U       ; Save the screen block numbers
        INCA
        STA     CC3ScreenBlck01+1,U     ; Save the screen block numbers
        RTS
; ***********************************************************************************

; ***********************************************************************************
; Calculate where to draw the sprite
CalcSpriteLocation:
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
        ADDD    #$A000                  ; D = D + $A000 Mem block $FFA5
 ENDIF
        TFR     D,X                     ; X now has the starting Row offset
        LDD     SpriteX,Y               ; D = the x position (pixel)
; Fall through to update the sprite location in cache, and advance cache and return.

; Calculate the sprite location in RAM and update the Sprite Location in the U cache + advance the U cache pointer
; D = the x position (pixel)
; X = the Row on screen
SaveSpriteLocationAtU:
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
CC3_UpdateCache:
        STU     >$FFFF                  ; Save the next empty pointer in the Sprite Cache (self mod)
        RTS                             ; Return
; ***********************************************************************************
ShowNextPlayField       FDB     $0000