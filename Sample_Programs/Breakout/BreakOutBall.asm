; Sprite Name            : BreakOutBall
; Sprite Width in pixels : 7 
; Sprite Height in pixels: 2 
; # of Colours           : 4 
; # of Animation Frames  : 1 
BreakOutBall_Draw:
        FDB     BreakOutBall_0_0    ; Address to draw sprite
        FDB     BreakOutBall_0_1    ; Address to draw sprite
        FDB     BreakOutBall_0_2    ; Address to draw sprite
        FDB     BreakOutBall_0_3    ; Address to draw sprite
; Restore the background behind the sprite VSYNC 1
Restore_BreakOutBall_1:
        LEAY    6144,X              ; Point at the top left edge of the screen 1 sprite location
BreakOutBall__0:
; 000 1111....
; 001 1111....
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 1 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        RTS                         ; Done drawing the sprite, Return

; Restore the background behind the sprite VSYNC 0
Restore_BreakOutBall_0:
        PSHS    DP                  ; Save DP
        STS     @SaveSHere+2        ; Backup the stack pointer's value at the end of the backup routine (self mod)
        LDS     #BreakOutBall_BackupStart+32    ; Set S pointer to the end of the last row of the backup buffer + 32 extra space for stack during F/IRQ
        LEAU    34,X                ; Point at the bottom, right edge of the sprite backup location
; Restoring row 1 
        PULS    D                   ; Get Data to restore
        PSHU    D                   ; Write a Data to the screen
        LEAU    -30,U               ; Move to the correct position to write data on screen
; Restoring row 0 
        PULS    D                   ; Get Data to restore
        PSHU    D                   ; Write a Data to the screen
@SaveSHere
        LDS     #$FFFF              ; Self mod restore stack pointer
        PULS    DP,PC               ; Restore DP & Return

; Backup Sprite data for BreakOutBall
; Enter with X pointing at the memory location on screen to backup the data behind the sprite
; Sprite Width is: 2 Bytes, one extra byte to backup for shifted start location
; Height is: 2 Rows
BreakOutBall_BackupStart:
        RMB     2*2+32              ; Reserve space for sprite background, plus a little extra for the stack (If F/IRQ happens)
BreakOutBall_BackupEnd:
Backup_BreakOutBall:
        PSHS    DP                  ; Save Condition Codes & DP
        STS     @SaveSHere+2        ; Backup the stack pointer's value at the end of the backup routine (self mod)
        LDS     #BreakOutBall_BackupEnd    ; Set S pointer to the end of the backup buffer
        LEAU    ,X                  ; U = X
; Backup row 0 
        PULU    D                   ; Get two bytes from the screen
        PSHS    D                   ; Save two bytes from the screen
        LEAU    32-2,U              ; Move down to the start of the next row to copy
; Backup row 1 
        PULU    D                   ; Get two bytes from the screen
        PSHS    D                   ; Save two bytes from the screen
@SaveSHere
        LDS     #$FFFF              ; Self mod restore stack pointer
        PULS    DP,PC               ; Restore DP & Return

; Frame Number: 0 
BreakOutBall_0_0:
; 000 1111....
; 001 1111....
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDA     #%00001111          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%11110000          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 1 
        LDA     #%00001111          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%11110000          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        RTS                         ; Done drawing the sprite, Return
BreakOutBall_0_1:
; 000 ..1111..
; 001 ..1111..
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDA     #%11000011          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00111100          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 1 
        LDA     #%11000011          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00111100          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        RTS                         ; Done drawing the sprite, Return
BreakOutBall_0_2:
; 000 ....1111
; 001 ....1111
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDA     #%11110000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00001111          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 1 
        LDA     #%11110000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00001111          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        RTS                         ; Done drawing the sprite, Return
BreakOutBall_0_3:
; 000 ......1111......
; 001 ......1111......
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDA     #%11111100          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00000011          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00111111          ; Get the mask in A
        ANDA    1,X                 ; Get the background into transparent bits into A
        ORA     #%11000000          ; Get the non transparent bits into A
        STA     1,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 1 
        LDA     #%11111100          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00000011          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00111111          ; Get the mask in A
        ANDA    1,X                 ; Get the background into transparent bits into A
        ORA     #%11000000          ; Get the non transparent bits into A
        STA     1,X                 ; write the sprite data on screen
        RTS                         ; Done drawing the sprite, Return

