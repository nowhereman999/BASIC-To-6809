MaxSprites              EQU     32
MaxSpritesToProcess     EQU     32

; Sprite Cache:
; capture and process sprite commands which will be processed when the WAIT VBL command is used
; byte 0 & 1  = Routine Address to Jump to (Draw/Erase/Backup)
; byte 2 & 3  = Memory location for screen 0
SpriteCache0:
        RMB     4*MaxSpritesToProcess   ; Reserve space for the sprite cache
SpriteCacheEnd0:
SpriteCache1:
        RMB     4*MaxSpritesToProcess   ; Reserve space for the sprite cache
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
; 2,S = Frame #
; 3,S = Sprite #
; Enter with Frame # to change in B
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache0
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache0?
        BNE     >
        BSR     DoWaitVBL                ; go update screen which will empty the cache0 & cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache0
; Get the location of the sprite on screen
!       LDX     #SpriteTable            ; Point at the start of the Sprite Restore table
        LDA     #5                      ; 5 bytes per sprite entry
        LDB     3,S                     ; Get the sprite #
        MUL                             ; Multiply by the sprite #
        ABX                             ; X points at the start of the sprite entry
        LDB     2,S                     ; Get the frame #
        STB     SpriteFrame,X           ; Save the frame # for this sprite
        LDB     3,S                     ; Get the sprite #
        PSHS    B                       ; Save the sprite #
        LDD     SpriteX,X               ; Get the x co-ordinate
        PSHS    D                       ; Save the x co-ordinate
        LDB     SpriteY,X               ; Get the y co-ordinate
        PSHS    B                       ; Save the y co-ordinate
        LDB     SpriteFrame,X           ; Get the frame #
        PSHS    B                       ; Save the frame #
        JSR     AddSpriteToSpriteCache  ; Add the sprite with the new frame # to the sprite cache
        LEAS    5,S                     ; Fix the stack
        RTS


; ***********************************************************************************
; Called by the Sprite LOCATE command
; Enter with y coordinate in D
SpriteLocate:
; 2,S & 3,S = Y co-ordinate
; 4,S & 5,S = X co-ordinate
; 6,S = Sprite #
; Point at the y & X location of the sprite
        LDX     #SpriteTable             ; Point at the start of the Sprite Table
        LDB     6,S                     ; Get the sprite #
        LDA     #5                      ; 5 bytes per sprite entry
        MUL                             ; Multiply by the sprite #
        ABX                             ; X points at the start of the sprite table entry for sprite B
        LDB     3,S                     ; Get the y co-ordinate
        STB     SpriteY,X               ; Save the y co-ordinate
        LDD     4,S                     ; Get the x co-ordinate
        STD     SpriteX,X               ; Save the x co-ordinate
        RTS

; Called by the Sprite Off command
; Enter with Sprite # in B
SpriteBOff:
        STB     @RestoreSpriteNumber+1  ; (self mod) Save the sprite #
        LDY     SpriteCachePointer1      ; Get the next empty pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache0
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache0?
        BNE     >
        PSHS    B
        BSR     DoWaitVBL                ; go update screen which will empty the cache0 & cache1
        PULS    B
        LDY     SpriteCachePointer1      ; Load the first pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache0
; Get the location of the sprite on screen
!       LDX     #SpriteTable            ; Point at the start of the Sprite Restore table
        LDA     #5                      ; 5 bytes per sprite entry
        MUL                             ; Multiply by the sprite #
        ABX                             ; X points at the start of the sprite entry
        CLR     SpriteStatus,X          ; Clear the sprite status flag
@RestoreSpriteNumber:
        LDB     #$FF                    ; (Self Mod) Restore the sprite #
; Flow through to the EraseSpriteB routine

; Called by the Sprite ERASE command
; Enter with sprite # to Erase in B
EraseSpriteB:
        PSHS    B                        ; Save the sprite #
        LDY     SpriteCachePointer1      ; Get the next empty pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache0
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache0?
        BNE     >
        BSR     DoWaitVBL                ; go update screen which will empty the cache0 & cache1
        LDB     ,S                       ; Restore the sprite #
        LDY     SpriteCachePointer1      ; Load the first pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache0
; Get the location of the sprite on screen
!       LDX     #SpriteRestoreTable     ; Point at the start of the Sprite Restore table
        LSLB                            ; * 2 (two erntrys, restore screen 0 & restore screen 1)
        LSLB                            ; * 4 (two bytes each entry
        STB     @RestoreB+1             ; self mod save B below
        ABX                             ; X points at the sprite Restore routine address
        LDD     ,X                      ; Get the address of the Restore routine screen 0
        STD     2,U                     ; Save the address of the routine to Restore behind the sprite cache0
        LDD     2,X                     ; Get the address of the Restore routine for screen1
        STD     2,Y                     ; Save the address of the routine to Restore behind the sprite cache1
; Point at the y & X location of the sprite
        LDX     #SpriteTable            ; Point at the start of the Sprite Table
@RestoreB:
        LDB     #$FF                    ; self mod B = sprite # * 4
        ADDB    ,S+                     ; B = Sprite # * 5, fix the stack 
        ABX                             ; X points at the start of the sprite table entry for sprite B
        BRA     CalcAddressOfSprite0_and1 ; Calculate the address of the sprite and save it in the cache (same as the Sprite BACK routine)

; Called by the Sprite BACK command
; Enter with sprite # to backup in B
BackupSpriteB:
        PSHS    B                        ; Save the sprite #
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache0
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache0?
        BNE     >
        BSR     DoWaitVBL                ; go update screen which will empty the cache0 & cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache0
        LDB     ,S                       ; Get the sprite #
; Get the location of the sprite on screen
!       LDX     #SpriteBackupTable      ; Point at the start of the Sprite Backup table
        LSLB                            ; Sprite Number = sprite Number * 2
        ABX                             ; X points at the start of the sprite backup table
        LDX     ,X                      ; Get the address of the sprite backup routine
        STX     2,U                     ; Save the address of the routine to backup the sprite Only in cache0
; Point at the y & X location of the sprite
        LDX     #SpriteTable            ; Point at the start of the Sprite Table
        LSLB                            ; Sprite Number = sprite Number * 4
        ADDB    ,S+                     ; Sprite Number = sprite Number * 5, fix the stack
        ABX                             ; X points at the start of the sprite table entry for sprite B
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
        STX     ,U                      ; Save the location of the sprite on screen 0 in the cache0
        LEAU    4,U                     ; Point at the next empty pointer in the Sprite Cache0
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
        STX     ,U                      ; Save the location of the sprite on screen 0 in the cache0
        LEAU    4,U                     ; Point at the next empty pointer in the Sprite Cache0
        STU     SpriteCachePointer0     ; Save the next empty pointer in the Sprite Cache0
        STX     ,Y                      ; Save the location of the sprite on screen 0 in the cache1
        LEAY    4,Y                     ; Point at the next empty pointer in the Sprite Cache1
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
        LDY     SpriteCachePointer1      ; Get the next empty pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Get the next empty pointer in the Sprite Cache
        CMPU    #SpriteCacheEnd0         ; Have we reached the end of the cache?
        BNE     >
        BSR     DoWaitVBL               ; go update screen which will empty the cache
        LDY     SpriteCachePointer1      ; Get the next empty pointer in the Sprite Cache1
        LDU     SpriteCachePointer0      ; Load the first pointer in the Sprite Cache
; Calculate and point at routine to draw the requested sprite
!       LDX     #SpriteDrawTable  ; Point at the start of the table
        LDB     6,S     ; Get the sprite number
        LSLB            ; * 2 (two bytes per entry in the jump table)
        ABX
        LDX     ,X      ; X now points at the sprite drawing table
; NumberOfColours & PixelsMaxX values will be set by the Tokenizer, these conditions allow it to work for 2, 4 or 16 colour modes
; Handle 2 colour mode
 IFEQ NumberOfColours-2
  IFEQ Artifacting-1
; Handle special GMODE 18 which has anrtifacting and an extra byte in the table which
; describes whether or not this particular sprite is a walking/anim sprite
!       LDB     2,S     ; Get the frame number
        LDA     ,X+     ; Is this a special Walk/ANIM sprite?
        BNE     >       ; 1 means Special so jump forward special
        LSLB            ; * 2
        LSLB            ; * 4
        LSLB            ; * 8 (8 shifted sprites) per frame
        ABX
        BRA     @GotIt  ; * 2 byte entries, this way it can handle 32 frames per sprite
!       LSLB            ; * 2 byte entries, this way it can handle 32 frames per sprite
@GotIt  ABX             

        LDB     5,S     ; Get the x co-ordinate (LSB)
        ANDB    #$03    ; Get the pixel offset for 4 colour mode
        LSLB            ; * 2 (two bytes per entry in the jump table)
        ABX
        LDX     ,X      ; Get routine to draw the sprite in X
        STX     2,U     ; Save the sprite/frame routine address in the SpriteCache0
  ELSE
        LDB     2,S     ; Get the frame number
        LSLB            ; * 2
        LSLB            ; * 4
        LSLB            ; * 8 (8 shifted sprites) per frame
        ABX
        ABX             ; * 2 byte entries, this way it can handle 32 frames per sprite
        LDB     5,S     ; Get the x co-ordinate (LSB)
        ANDB    #$07    ; Get the pixel offset for 2 colour mode
        LSLB            ; * 2 (two bytes per entry in the jump table)
        ABX
        LDX     ,X      ; Get routine to draw the sprite in X
        STX     2,U     ; Save the sprite/frame routine address in the SpriteCache0
  ENDIF
 ENDIF
 ; Handle 4 colour mode
 IFEQ NumberOfColours-4
        LDB     2,S     ; Get the frame number
        LSLB            ; * 2
        LSLB            ; * 4 (4 shifted sprites) per frame
        LSLB            ; * 2 byte entries, this way it can handle 32 frames per sprite
        ABX             
        LDB     5,S     ; Get the x co-ordinate (LSB)
        ANDB    #$03    ; Get the pixel offset for 4 colour mode
        LSLB            ; * 2 (two bytes per entry in the jump table)
        ABX
        LDX     ,X      ; Get routine to draw the sprite in X
        STX     2,U     ; Save the sprite/frame routine address in the SpriteCache0
 ENDIF
 ; Handle 16 colour mode
 IFEQ NumberOfColours-16
        LDB     2,S     ; Get the frame number
        LSLB            ; * 2 (Each frame has a Left nibble and right nibble)
        ABX
        LDB     5,S     ; Get the x co-ordinate (LSB)
        ANDB    #$01    ; Get the pixel offset for 16 colour mode
        LSLB            ; * 2 (two bytes per entry in the jump table)
        ABX
        LDX     ,X      ; Get routine to draw the sprite in X
        STX     2,U     ; Save the sprite/frame routine address in the SpriteCache0
 ENDIF
 

; For Screen 1 we will use the copy sprite area from screen 0 to screen1 routine
!       LDX     #SpriteRestoreTable+2  ; Point at the SpriteRestoreTable+2 so it points at screen1 routine
        LDB     6,S     ; Get the sprite number
        LSLB            ; * 2 (two bytes per entry in the jump table)
        LSLB            ; * 4 (Table has Screen 0 address & Screen 1 address)
        ABX             
        LDX     ,X
        STX     2,Y     ; Save the sprite copy routine which is faster than drawing again routine address in the SpriteCache1
; Calculate where to draw the sprite
        LDA     #GmodeBytesPerRow ; # of bytes per row
        LDB     3,S     ; Get the y co-ordinate
        MUL             ; D = Number bytes per row * y co-ordinate which gives us the row offset
        ADDD    BEGGRP  ; D=D+Screen start location add the screen start location
        TFR     D,X     ; X now has the starting Row offset on screen 0
        LDD     4,S     ; D = the x position (pixel)
        BSR     CalculateSpriteLocation
        STX     ,U      ; Save the location of the sprite on screen 0 in the cache0
        LEAU    4,U     ; Point at the next empty pointer in the Sprite Cache0
        STU     SpriteCachePointer0      ; Save the next empty pointer in the Sprite Cache0
        STX     ,Y      ; Save the location of the sprite on screen 0 in the cache1
        LEAY    4,Y     ; Point at the next empty pointer in the Sprite Cache1
        STY     SpriteCachePointer1      ; Save the next empty pointer in the Sprite Cache1
        RTS             ; Return

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
;        LDB     $FF02                   ; Reset Vsync flag
;!       LDB     $FF03                   ; See if Vsync has occurred yet
;        BPL     <                       ; If not then keep looping, until the Vsync occurs
;; Show Screen 1
;        LDD     BEGGRP                  ; D = The screen starting address for Screen 0
;        ADDD    #ScreenSize             ; D points at Screen 1
;        LSRA                            ; Location in RAM to start the graphics screen / 2 as it must start in a 512 byte block
;        JSR     SetGraphicsStartA       ; Show Screen 1
; 2 - Update screen 0 with sprite cache commands
        LDU     #SpriteCache0           ; U = The Sprite Cache start for screen 0
!       CMPU    SpriteCachePointer0      ; Have we processed all the sprite commands?
        BEQ     >
        PULU    X,Y                     ; Load X with screen position and Y with JSR address, and move U to the next sprite cache entry
        STU     @RestoreU+1             ; Self mod, save U
        JSR     ,Y                      ; Go do the routine
@RestoreU:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed

; 3 - Show screen 0
; Wait for VSYNC
!       LDB     $FF02                   ; Reset Vsync flag
!       LDB     $FF03                   ; See if Vsync has occurred yet
        BPL     <   
        LDD     BEGGRP                  ; D = The screen starting address for Screen 0
        LSRA                            ; Location in RAM to start the graphics screen / 2 as it must start in a 512 byte block
        JSR     SetGraphicsStartA       ; Show Screen 0

; 4 - Update screen 1 with sprite cache commands
        LDU     #SpriteCache1           ; U = The Sprite Cache start for screen 1
!       CMPU    SpriteCachePointer1      ; Have we processed all the sprite commands?
        BEQ     >
        PULU    X,Y                     ; Load X with screen position and Y with JSR address, and move U to the next sprite cache entry
        STU     @RestoreU+1             ; Self mod, save U
        JSR     ,Y                      ; Go do the routine
@RestoreU:
        LDU     #$FFFF                  ; Self mod, restore U
        BRA     <                       ; Loop until all the sprite commands have been processed


; Show Screen 1
        LDD     BEGGRP                  ; D = The screen starting address for Screen 0
        ADDD    #ScreenSize             ; D points at Screen 1
        LSRA                            ; Location in RAM to start the graphics screen / 2 as it must start in a 512 byte block
        JSR     SetGraphicsStartA       ; Show Screen 1


; 5 - reset sprite cache pointer to the beginning of the cache
!       LDU     #SpriteCache0           ; U = The Sprite Cache0 start
        STU     SpriteCachePointer0     ; Reset the Sprite Cache0 Pointer
        LDU     #SpriteCache1           ; U = The Sprite Cache1 start
        STU     SpriteCachePointer1     ; Reset the Sprite Cache1 Pointer
        RTS                             ; Return                

