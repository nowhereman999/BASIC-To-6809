MaxSprites              EQU     32
MaxSpritesToProcess     EQU     32

CC3SpriteBlocks EQU  0          ; Sprite block numbers
CC3ScreenBlck01 EQU  2          ; Screen block 0 & 1
CC3ScreenBlck23 EQU  4          ; Screen block 2 & 3
CC3SpriteLoc    EQU  6          ; Sprite X position
CC3SpriteJump   EQU  8          ; Sprite Jump address
CacheEntrySize  EQU  10         ; Size of a sprite cache entry
CC3SourceBlcks  EQU  2          ; Source blocks
CCSDestBlcks    EQU  4          ; Destination blocks

; Sprite Cache:
; capture and process sprite commands which will be processed when the WAIT VBL command is used
; byte 0 & 1  = Routine Address to Jump to (Draw/Erase/Backup)
; byte 2 & 3  = Memory location for screen 0
SpriteCache0:
        RMB     CacheEntrySize*MaxSpritesToProcess   ; Reserve space for the sprite cache
SpriteCacheEnd0:
SpriteCache1:
        RMB     CacheEntrySize*MaxSpritesToProcess   ; Reserve space for the sprite cache
SpriteCacheEnd1:
SpriteCachePointer0:
        FDB     SpriteCache0            ; Point at the current entry in the sprite cache, to be Blasted with a value
SpriteCachePointer1:
        FDB     SpriteCache1            ; Point at the current entry in the sprite cache, to be Blasted with a value

SpriteTable:
; Entry is the sprite #
; byte 0 -  0 = Off
;           1 = On
; byte 1      = Y co-ordniate
; byte 2 & 3  = X co-ordinate
; byte 4      = frame number
SpriteStatus    EQU     0
SpriteY         EQU     1
SpriteX         EQU     2       ; 2 & 3 it's a 16 bit value
SpriteFrame     EQU     4
        RMB     5*MaxSpritesToProcess

; Called by the Sprite SHOW command
; We will set the sprite frame on the Sprite list then treat it like a draw sprite
ShowSpriteFrame:
; Enter with
; ,S = Return Address
; 2,S = Frame #
; 3,S = Sprite Number

; Make it like this:
; Enter with B is Frame #
; ,S = Return Address
; 2,S = Frame #
; 3,S = y Position (row)
; 4,S & 5,S = x Position (pixel)
; 6,S = Sprite Number
; 7,S & 8,S = Sprite block numbers
; 9,S & 10,S = Screen block numbers 0 & 1
; 11,S & 12,S = Screen block numbers 2 & 3
        LDB     3,S                     ; Get the sprite #
        STB     6,S                     ; Save the sprite #
        LDX     #SpriteTable            ; Point at the start of the Sprite Restore table
        LDA     #5                      ; 5 bytes per sprite entry
        MUL                             ; Multiply by the sprite #
        ABX                             ; X points at the start of the sprite entry
        LDA     SpriteY,X               ; Get the Y position
        STA     3,S                     ; Save the Y position
        LDU     SpriteX,X               ; Get the X position
        STU     4,S                     ; Save the X position
        LDA     2,S                     ; Get the frame #
        STA     SpriteFrame,X           ; Save the frame #
        LDB     6,S     ; B = Sprite Number
        LDX     #CC3SpritesStartBLKTable ; Point at the Sprite Block # table
        LDA     B,X     ; A = The sprite starting block
        STA     7,S     ; Save the sprite starting block
        INCA            ; Point at the next block (always use a 16k size, just in case)
        STA     8,S     ; Save it on the stack
        LDA     CC3ScreenStart ; Get the starting screen block location for Screen 0
        STA     9,S     ; Save it
        INCA            ; Point at the next block
        STA     10,S    ; Save it
        INCA            ; Point at the next block
        STA     11,S    ; Save it
        INCA            ; Point at the next block
        STA     12,S    ; Save it

; Enter with Frame # to change in B
        LDY     SpriteCachePointer1      ; Get the next empty pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache0
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache0?
        BNE     >
        BSR     DoWaitVBL                ; go update screen which will empty the cache0 & cache1
        LDY     SpriteCachePointer1      ; Load the first pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache0
; Get the location of the sprite on screen
!       LDX     #SpriteTable            ; Point at the start of the Sprite Restore table
        LDA     #5                      ; 5 bytes per sprite entry
        LDB     6,S                     ; Get the sprite #
        MUL                             ; Multiply by the sprite #
        ABX                             ; X points at the start of the sprite entry
        LDB     2,S                     ; Get the frame #
        STB     SpriteFrame,X           ; Save the frame # for this sprite
        BRA     AddSpriteToSpriteCache  ; Add the sprite with the new frame # to the sprite cache

; Called by the Sprite LOCATE command
; Enter with y coordinate in B
SpriteLocate:
; 2,S = Y co-ordinate
; 3,S & 4,S = X co-ordinate
; 5,S = Sprite #
; Point at the y & X location of the sprite
        LDX     #SpriteTable             ; Point at the start of the Sprite Table
        LDB     5,S                     ; Get the sprite #
        LDA     #5                      ; 5 bytes per sprite entry
        MUL                             ; Multiply by the sprite #
        ABX                             ; X points at the start of the sprite table entry for sprite B
        LDB     2,S                     ; Get the y co-ordinate
        STB     SpriteY,X               ; Save the y co-ordinate
        LDD     3,S                     ; Get the x co-ordinate
        STD     SpriteX,X               ; Save the x co-ordinate
        RTS

;
; Prep stack pointers for the sprite handler
; Enter with:
; B=Sprite#
; U=JSR address
PrepSpriteJumpCC3:
        LEAS    -7,S    ; Move the stack pointer, so we can store value into it befoe the JSR
        STB     ,S      ; Save the Sprite #
        LDX     #CC3SpritesStartBLKTable ; Point at the Sprite Block # table
        LDA     B,X     ; A = The sprite starting block
        STA     1,S     ; Save the sprite starting block
        INCA            ; Point at the next block (always use a 16k size, just in case)
        STA     2,S     ; Save it on the stack
        LDA     CC3ScreenStart ; Get the starting screen block location for Screen 0
        STA     3,S     ; Save it
        INCA            ; Point at the next block
        STA     4,S     ; Save it
        INCA            ; Point at the next block
        STA     5,S     ; Save it
        INCA            ; Point at the next block
        STA     6,S     ; Save it
        JSR     ,U      ; JSR to the sprite handler
        PULS    B,X,Y,U,PC ; Restore the stack pointer & Return

; Called by the Sprite Off command
; Enter with sprite # to Erase in B
; 2,S = Sprite #
; 3,S & 4,S = Sprite block numbers
; 5,S & 6,S = Screen block numbers 0 & 1
; 7,S & 8,S = Screen block numbers 2 & 3
SpriteBOff:
        LDY     SpriteCachePointer1      ; Get the next empty pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache0
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache0?
        BNE     >
        BSR     DoWaitVBL                ; go update screen which will empty the cache0 & cache1
        LDY     SpriteCachePointer1      ; Load the first pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache0
; Get the location of the sprite on screen
!       LDX     #SpriteTable            ; Point at the start of the Sprite Restore table
        LDA     #5                      ; 5 bytes per sprite entry
        LDB     2,S                     ; Get the sprite #
        MUL                             ; Multiply by the sprite #
        ABX                             ; X points at the start of the sprite entry
        CLR     SpriteStatus,X          ; Clear the sprite status flag (Turn it off)
        LDB     2,S                     ; Get the sprite #
; Flow through the to EraseSpriteB routine

; Called by the Sprite ERASE command
; Enter with sprite # to Erase in B
; 2,S = Sprite #
; 3,S & 4,S = Sprite block numbers
; 5,S & 6,S = Screen block numbers 0 & 1
; 7,S & 8,S = Screen block numbers 2 & 3
EraseSpriteB:
        LDY     SpriteCachePointer1      ; Get the next empty pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache0
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache0?
        BNE     >
        BSR     DoWaitVBL                ; go update screen which will empty the cache0 & cache1
        LDB     2,S                      ; Restore the sprite #
        LDY     SpriteCachePointer1      ; Load the first pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache0
; Get the location of the sprite on screen
!       LDX     #SpriteRestoreTable     ; Point at the start of the Sprite Restore table
        LSLB                            ; * 2 (two erntrys, restore screen 0 & restore screen 1)
        LSLB                            ; * 4 (two bytes each entry
        STB     @RestoreB+1             ; self mod save B below
        ABX                             ; X points at the sprite Restore routine address
        LDD     ,X                      ; Get the address of the Restore routine screen 0
        STD     CC3SpriteJump,U         ; Save the address of the routine to Restore behind the sprite cache0
        LDD     2,X                     ; Get the address of the Restore routine for screen1
        STD     CC3SpriteJump,Y         ; Save the address of the routine to Restore for screen 1 in cache1
; Prepare more of the sprite cache entry        
        LDD     3,S                     ; Get the sprite block numbers off the stack =0607
        STD     CC3SpriteBlocks,U       ; Save the sprite block numbers Screen 0
        STD     CC3SpriteBlocks,Y       ; Save the sprite block numbers Screen 1
        LDD     5,S                     ; Get Screen block 0 & 1 off the stack
        STD     CC3ScreenBlck01,U       ; Save the sprite block numbers Screen 0
        LDD     7,S                     ; Get Screen block 2 & 3 off the stack
        STD     CC3ScreenBlck23,U       ; Save the sprite block numbers Screen 0
; Point at the y & X location of the sprite
        LDX     #SpriteTable            ; Point at the start of the Sprite Table
@RestoreB:
        LDB     #$FF                    ; self mod B = sprite # * 4
        ADDB    2,S                     ; B = Sprite # * 5 
        ABX                             ; X points at the start of the sprite table entry for sprite B
        LDA     #GmodeBytesPerRow       ; # of bytes per row
        LDB     SpriteY,X               ; Get the y co-ordinate
        MUL                             ; D = Number bytes per row * y co-ordinate which gives us the row offset
        ADDD    BEGGRP                  ; D=D+Screen start location add the screen start location
        PSHS    D                       ; Save the screen location on the stack
        LDD     SpriteX,X               ; D = the x position (pixel)
        LDX     ,S++                    ; X = the Row offset on screen 0, fix the stack
        BSR     CalculateSpriteLocation ; Go calculate the address of the sprite
        STX     CC3SpriteLoc,U          ; Save the location of the sprite on screen 0 in the cache0
; For screen 1 we will be copying the sprite from screen 0 in $6000 & $8000 to screen 1 in $A000 & $C000
;     For each sprite we need to restore for screen 1 do the following:
;     If X > $8000 then we LEAX -$2000,X and use screen then next 8k block at $6000 & $8000 and also for the destination blocks
        LDA     5,S                     ; Get the starting block for screen 0
        LDB     5,S                     ; B = the starting block for screen 0
        ADDB    #CC3ScreenBlockSize     ; B = B + # of $2000 blocks required per screen (Points at the screen 1 blocks)
!       CMPX    #$8000   ; Does the sprite start in the first 8k block?
        BLO     >        ; skip forward if so
        ADDD    #$0101   ; Increment the screen 0 and 1 blocks by 1
        LEAX    -$2000,X ; Keep the start block in the $6000-$7FFF range
        BRA     <        ; Keep looping
!       STA     CC3SourceBlcks,Y        ; Save the sprite block numbers Screen 1
        STB     CCSDestBlcks,Y          ; Save the sprite block numbers Screen 0
        ADDD    #$0101                  ; Increment the Source & Destination blocks by 1
        STA     CC3SourceBlcks+1,Y      ; Save the sprite block numbers Screen 1
        STB     CCSDestBlcks+1,Y        ; Save the sprite block numbers Screen 0
        STX     CC3SpriteLoc,Y          ; Save the location of the sprite on screen 0 in the cache1
        LEAU    CacheEntrySize,U        ; Point at the next empty pointer in the Sprite Cache0
        STU     SpriteCachePointer0     ; Save the next empty pointer in the Sprite Cache0
        LEAY    CacheEntrySize,Y        ; Point at the next empty pointer in the Sprite Cache1
        STY     SpriteCachePointer1     ; Save the next empty pointer in the Sprite Cache1
        RTS                

; Called by the Sprite BACK command
; Enter with sprite # to backup in B
; 2,S = Sprite #
; 3,S & 4,S = Sprite block numbers
; 4,S & 5,S = Screen block numbers 0 & 1
; 6,S & 7,S = Screen block numbers 2 & 3
BackupSpriteB:
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache0
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache0?
        BNE     >
        BSR     DoWaitVBL                ; go update screen which will empty the cache0 & cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache0
        LDB     2,S                      ; Get the sprite #
; Get the location of the sprite on screen
!       LDX     #SpriteBackupTable      ; Point at the start of the Sprite Backup table
        LSLB                            ; Sprite Number = sprite Number * 2
        ABX                             ; X points at the start of the sprite backup table
        LDX     ,X                      ; Get the address of the sprite backup routine
        STX     CC3SpriteJump,U         ; Save the address of the routine to backup the sprite Only in cache0
; Point at the y & X location of the sprite
        LDX     #SpriteTable            ; Point at the start of the Sprite Table
        LSLB                            ; Sprite Number = sprite Number * 4
        ADDB    2,S                     ; Sprite Number = sprite Number * 5
        ABX                             ; X points at the start of the sprite table entry for sprite B
; Prepare more of the sprite cache entry
        LDD     3,S                     ; Get the sprite block numbers off the stack
        STD     CC3SpriteBlocks,U       ; Save the sprite block numbers Screen 0
        LDD     5,S                     ; Get Screen block 0 & 1 off the stack
        STD     CC3ScreenBlck01,U       ; Save the sprite block numbers Screen 0
        LDD     7,S                     ; Get Screen block 2 & 3 off the stack
        STD     CC3ScreenBlck23,U       ; Save the sprite block numbers Screen 0

; Entry is the sprite #
; byte 0 -  0 = Off
;           1 = On
; byte 1      = Y co-ordniate
; byte 2 & 3  = X co-ordinate
; byte 4      = frame number
; Update only cache 0
CalcAddressOfSprite0:
        LDA     #GmodeBytesPerRow       ; # of bytes per row
        LDB     SpriteY,X               ; Get the y co-ordinate
        MUL                             ; D = Number bytes per row * y co-ordinate which gives us the row offset
        ADDD    BEGGRP                  ; D=D+Screen start location add the screen start location
        PSHS    D                       ; Save the screen location on the stack
        LDD     SpriteX,X               ; D = the x position (pixel)
        LDX     ,S++                    ; X = the Row offset on screen 0, fix the stack
        BSR     CalculateSpriteLocation ; Go calculate the address of the sprite
        STX     CC3SpriteLoc,U          ; Save the location of the sprite on screen 0 in the cache0
        LEAU    CacheEntrySize,U        ; Point at the next empty pointer in the Sprite Cache0
        STU     SpriteCachePointer0     ; Save the next empty pointer in the Sprite Cache0
        RTS                             ; Return

; update both caches 0 & 1
CalcAddressOfSprite0_and1:
        LDA     #GmodeBytesPerRow       ; # of bytes per row
        LDB     SpriteY,X               ; Get the y co-ordinate
        MUL                             ; D = Number bytes per row * y co-ordinate which gives us the row offset
        ADDD    BEGGRP                  ; D=D+Screen start location add the screen start location
        PSHS    D                       ; Save the screen location on the stack
        LDD     SpriteX,X               ; D = the x position (pixel)
        LDX     ,S++                    ; X = the Row offset on screen 0, fix the stack
        BSR     CalculateSpriteLocation ; Go calculate the address of the sprite
        STX     CC3SpriteLoc,U          ; Save the location of the sprite on screen 0 in the cache0
        LEAU    CacheEntrySize,U        ; Point at the next empty pointer in the Sprite Cache0
        STU     SpriteCachePointer0     ; Save the next empty pointer in the Sprite Cache0
        STX     CC3SpriteLoc,Y          ; Save the location of the sprite on screen 0 in the cache1
        LEAY    CacheEntrySize,Y        ; Point at the next empty pointer in the Sprite Cache1
        STY     SpriteCachePointer1     ; Save the next empty pointer in the Sprite Cache1
        RTS                

;--------------------------------------
; Called by the SPRITE command
AddSpriteToProcess:
; Enter with B is Frame #
; ,S = Return Address
; 2,S = Frame #
; 3,S = y Position (row)
; 4,S & 5,S = x Position (pixel)
; 6,S = Sprite Number
; 7,S & 8,S = Sprite block numbers
; 9,S & 10,S = Screen block numbers 0 & 1
; 11,S & 12,S = Screen block numbers 2 & 3

;SpriteTable:
; Entry is the sprite #
; byte 0 - Sprite Status
;           0 = Off
;           1 = On
; byte 1      = Y co-ordniate
; byte 2 & 3  = X co-ordinate
; byte 4      = frame number
        LDX     #SpriteTable            ; Point at the start of the table
        LDB     6,S                     ; Get the sprite number
        LSLB                            ; * 2
        LSLB                            ; * 4
        ADDB    6,S                     ; * 5 (5 bytes per entry in the sprite table)
        ABX                             ; X points at the sprite table entry
        LDB     SpriteStatus,X          ; Get the status of the sprite
        BNE     >                       ; If it is on check for changes
        LDA     #1                      ; Turn the sprite on & flag to update the cache
        STA     SpriteStatus,X          ; Save the new status
        BRA     @AddToCache             ; Update the entry in the cache
; Check to see if anything has changed
; If not then ignore this sprite command
!       CLRA                            ; This is our flag to see if there is a change
@AddToCache:
        LDB     3,S                     ; Get the Y co-ordinate, requested
        CMPB    SpriteY,X               ; Check if the Y co-ordinate has changed
        BEQ     >                       ; If it hasn't changed then don't change the flag
        INCA                            ; Flag that the sprite has changed
        STB     SpriteY,X               ; update the Y co-ordinate
!       LDB     4,S                     ; Get the X co-ordinate MSB, request
        CMPB    SpriteX,X               ; Check if the X co-ordinate MSB has changed
        BEQ     >                       ; If it hasn't changed then don't change the flag
        INCA                            ; Flag that the sprite has changed
        STB     SpriteX,X               ; update the X co-ordinate MSB
!       LDB     5,S                     ; Get the X co-ordinate LSB, request
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
        BNE     AddSpriteToSpriteCache  ; If there is a change then add the sprite to the SpriteCache
        RTS                             ; Nothing has changed return
; There was a change so add the sprite to the SpriteCache
AddSpriteToSpriteCache:
        LDY     SpriteCachePointer1     ; Get the first pointer in the Sprite Cache1
        LDU     SpriteCachePointer0     ; Get the next empty pointer in the Sprite Cache
        CMPU    #SpriteCacheEnd0        ; Have we reached the end of the cache?
        BNE     >
        BSR     DoWaitVBL               ; go update screen which will empty the cache
        LDY     SpriteCachePointer1     ; Get the first pointer in the Sprite Cache1
        LDU     SpriteCachePointer0     ; Load the first pointer in the Sprite Cache0
; Prepare more of the sprite cache entry        
!       LDD     7,S                     ; Get the sprite block numbers off the stack
        STD     CC3SpriteBlocks,U       ; Save the sprite block numbers Screen 0
        STD     CC3SpriteBlocks,Y       ; Save the sprite block numbers Screen 1
        LDD     9,S                     ; Get Screen block 0 & 1 off the stack
        STD     CC3ScreenBlck01,U       ; Save the sprite block numbers Screen 0
        STD     CC3ScreenBlck01,Y       ; Save the sprite block numbers Screen 1
        LDD     11,S                    ; Get Screen block 2 & 3 off the stack
        STD     CC3ScreenBlck23,U       ; Save the sprite block numbers Screen 0
        STD     CC3ScreenBlck23,Y       ; Save the sprite block numbers Screen 1
; Calculate and point at routine to draw the requested sprite
        LDX     #$2000                  ; Point at the start of the sprite draw routine table
        LDB     2,S     ; Get the frame number
; NumberOfColours & PixelsMaxX values will be set by the Tokenizer, these conditions allow it to work for 2, 4 or 16 colour modes
; Handle 2 colour mode
 IFEQ NumberOfColours-2
        LSLB            ; * 2
        LSLB            ; * 4
        LSLB            ; * 8 (8 shifted sprites) per frame
        ABX
        ABX             ; * 2 byte entries, this way it can handle 32 frames per sprite
        LDB     5,S     ; Get the x co-ordinate (LSB)
        ANDB    #$07    ; Get the pixel offset for 2 colour mode
 ENDIF
 ; Handle 4 colour mode
 IFEQ NumberOfColours-4
        LSLB            ; * 2
        LSLB            ; * 4 (4 shifted sprites) per frame
        LSLB            ; * 2 byte entries, this way it can handle 32 frames per sprite
        ABX             ; X = X + B
        LDB     5,S     ; Get the x co-ordinate (LSB)
        ANDB    #$03    ; Get the pixel offset for 4 colour mode
 ENDIF
 ; Handle 16 colour mode
 IFEQ NumberOfColours-16
        LSLB            ; * 2 (Each frame has a Left nibble and right nibble)
        ABX             ; X = X + B
        LDB     5,S     ; Get the x co-ordinate (LSB)
        ANDB    #$01    ; Get the pixel offset for 16 colour mode
 ENDIF
        LSLB            ; * 2 (two bytes per entry in the jump table)
        ABX             ; X = X + B
        LDB     6,S     ; Get the sprite number
        PSHS    X       ; Save X
        LDX     #CC3SpritesStartBLKTable  ; Point at the start of the table that holds the which Block # this sprite code is in
        LDA     B,X     ; Get the block number for this sprite
        STA     $FFA1   ; Change the block number to the one we want
        PULS    X       ; Restore X       
        LDX     ,X      ; Get routine to draw the sprite in X
        LDA     #$39
        STA     $FFA1   ; Set it back to normal
        STX     CC3SpriteJump,U ; Save the sprite/frame routine address in the SpriteCache0

; For Screen 1 we will use the copy sprite area from screen 0 to screen 1 routine
!       LDX     #SpriteRestoreTable+2   ; Point at the SpriteRestoreTable+2 so it points at screen1 routine
;        LDB     6,S                     ; Get the sprite number
        LSLB                            ; * 2 (two bytes per entry in the jump table)
        LSLB                            ; * 4 (Table has Screen 0 address & Screen 1 address)
        ABX             
        LDX     ,X
        STX     CC3SpriteJump,Y         ; Save the sprite copy routine which is faster than drawing again routine address in the SpriteCache1

; Calculate where to draw the sprite
        LDA     #GmodeBytesPerRow       ; # of bytes per row
        LDB     3,S                     ; Get the y co-ordinate
        MUL                             ; D = Number bytes per row * y co-ordinate which gives us the row offset
        ADDD    BEGGRP                  ; D=D+Screen start location add the screen start location
        TFR     D,X                     ; X now has the starting Row offset on screen 0
        LDD     4,S                     ; D = the x position (pixel)
        BSR     CalculateSpriteLocation
        STX     CC3SpriteLoc,U            ; Save the location of the sprite on screen 0 in the cache0
; For screen 1 we will be copying the sprite from screen 0 in $6000 & $8000 to screen 1 in $A000 & $C000
;     For each sprite we need to restore for screen 1 do the following:
;     If X > $8000 then we LEAX -$2000,X and use screen then next 8k block at $6000 & $8000 and also for the destination blocks
        LDA     9,S                     ; Get the starting block for screen 0
        LDB     9,S                     ; B = the starting block for screen 0
        ADDB    #CC3ScreenBlockSize     ; B = B + # of $2000 blocks required per screen (Points at the screen 1 blocks)
!       CMPX    #$8000   ; Does the sprite start in the first 8k block?
        BLO     >        ; skip forward if so
        ADDD    #$0101   ; Increment the screen 0 and 1 blocks by 1
        LEAX    -$2000,X ; Keep the start block in the $6000-$7FFF range
        BRA     <        ; Keep looping
!       STA     CC3SourceBlcks,Y        ; Save the sprite block numbers Screen 1  This will be used at $6000
        STB     CCSDestBlcks,Y          ; Save the sprite block numbers Screen 0  This will be used at $A000
        ADDD    #$0101                  ; Increment the Source & Destination blocks by 1
        STA     CC3SourceBlcks+1,Y      ; Save the sprite block numbers Screen 1  This will be used at $8000
        STB     CCSDestBlcks+1,Y        ; Save the sprite block numbers Screen 0  This will be used at $C000
        STX     CC3SpriteLoc,Y            ; Save the location of the sprite on screen 0 in the cache1
        LEAU    CacheEntrySize,U        ; Point at the next empty pointer in the Sprite Cache0
        STU     SpriteCachePointer0     ; Save the next empty pointer in the Sprite Cache0
        LEAY    CacheEntrySize,Y        ; Point at the next empty pointer in the Sprite Cache1
        STY     SpriteCachePointer1     ; Save the next empty pointer in the Sprite Cache1
        RTS                             ; Return

; Calculate the memory location of the sprite on screen 0
; Enter with:
; X = the Row on screen 0 in RAM
; D = the x position (pixel)
CalculateSpriteLocation:
; NumberOfColours & PixelsMaxX values will be set by the Tokenizer, these conditions optimize the code
; Handle 2 colour mode
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
        RTS             ; Return with X pointing at the starting byte location on screen 0

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
        LDA     #CC3ScreenBlockSize     ; A = # of $2000 blocks required per screen
        LDB     GModePage               ; Get the screen Page # showing
        INCB                            ; Point at the next one (screen 1)
        MUL                             ; B = Blocks required per screen * the Screen requested        
        TFR     B,A                     ; A = $2000 screen block location
        CLRB                            ; Clear B
        LSLA                            ; A=A*2
        LSLA                            ; A=A*4, D=B * $400 = the screen start location
        STD     $FF9D                   ; VidStart

; 2 - Update screen 0 with sprite cache commands
        LDU     #SpriteCache0           ; U = The Sprite Cache start for screen 0
!       CMPU    SpriteCachePointer0      ; Have we processed all the sprite commands?
        BEQ     >
        PULU    D,X                     ; D = blocks where the sprite code will be used, X= screen 0 blcks
        STD     $FFA1                   ; Set the correct blocks for the sprite code $2000-$5FFF
        STX     $FFA3                   ; Set the correct blocks for the screen 0 $6000,$8000
        PULU    D,X,PC                  ; D with the rest of screen 0 ($A000,$C000), Load X with screen position of the sprite and PC=JMP to address, and move U to the next sprite cache entry
CC3SpriteReturn0:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed

; 3 - Show screen 0
; Wait for VSYNC
!       LDB     $FF02                   ; Reset Vsync flag
!       LDB     $FF03                   ; See if Vsync has occurred yet
        BPL     <   
        LDA     #CC3ScreenBlockSize     ; A = # of $2000 blocks required per screen
        LDB     GModePage               ; Get the screen Page # for Screen 0
        MUL                             ; B = Blocks required per screen * the Screen requested        
        TFR     B,A                     ; A = $2000 screen block location
        CLRB                            ; Clear B
        LSLA                            ; A=A*2
        LSLA                            ; A=A*4, D=B * $400 = the screen start location
        STD     $FF9D                   ; VidStart

; 4 - Update screen 1 with sprite cache commands
        LDU     #SpriteCache1           ; U = The Sprite Cache start for screen 1
!       CMPU    SpriteCachePointer1     ; Have we processed all the sprite commands?
        BEQ     >
        PULU    D,X                     ; D = blocks where the sprite code will be used, X= screen 0 blcks
        STD     $FFA1                   ; Set the correct blocks for the sprite code $2000-$5FFF
        STX     $FFA3                   ; Set the correct blocks for the screen 0 $6000-$9FFF
        PULU    D,X,PC                  ; D with the destination Screen 1 blks, Load X with screen position of the sprite and PC=JMP address, and move U to the next sprite cache entry
CC3SpriteReturn1:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed

; 5 - reset sprite cache pointer to the beginning of the cache
!       LDD     #$393A                  ; Put memory back to normal
        STD     $FFA1
        LDD     #$3B3C
        STD     $FFA3
        LDD     #$3D3E
        STD     $FFA5
        INCB
        STB     $FFA7

        LDU     #SpriteCache0           ; U = The Sprite Cache0 start
        STU     SpriteCachePointer0     ; Reset the Sprite Cache0 Pointer
        LDU     #SpriteCache1           ; U = The Sprite Cache1 start
        STU     SpriteCachePointer1     ; Reset the Sprite Cache1 Pointer
        RTS                             ; Return
