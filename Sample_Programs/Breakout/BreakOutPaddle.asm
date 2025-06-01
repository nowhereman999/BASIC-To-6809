; Sprite Name            : BreakOutPaddle
; Sprite Width in pixels : 15 
; Sprite Height in pixels: 4 
; # of Colours           : 4 
; # of Animation Frames  : 1 
BreakOutPaddle_Draw:
        FDB     BreakOutPaddle_0_0    ; Address to draw sprite
        FDB     BreakOutPaddle_0_1    ; Address to draw sprite
        FDB     BreakOutPaddle_0_2    ; Address to draw sprite
        FDB     BreakOutPaddle_0_3    ; Address to draw sprite
; Restore the background behind the sprite VSYNC 1
Restore_BreakOutPaddle_1:
        LEAY    6144,X              ; Point at the top left edge of the screen 1 sprite location
BreakOutPaddle__0:
; 000 1010101010101010
; 001 1010101010101010
; 002 1010101010101010
; 003 1010101010101010
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDA     2,X                 ; read the sprite data on screen 0
        STA     2,Y                 ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 1 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDA     2,X                 ; read the sprite data on screen 0
        STA     2,Y                 ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 2 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDA     2,X                 ; read the sprite data on screen 0
        STA     2,Y                 ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 3 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDA     2,X                 ; read the sprite data on screen 0
        STA     2,Y                 ; write the sprite data on screen 1
        RTS                         ; Done drawing the sprite, Return

; Restore the background behind the sprite VSYNC 0
Restore_BreakOutPaddle_0:
        PSHS    DP                  ; Save DP
        STS     @SaveSHere+2        ; Backup the stack pointer's value at the end of the backup routine (self mod)
        LDS     #BreakOutPaddle_BackupStart+32    ; Set S pointer to the end of the last row of the backup buffer + 32 extra space for stack during F/IRQ
        LEAU    99,X                ; Point at the bottom, right edge of the sprite backup location
; Restoring row 3 
        PULS    A,X                 ; Get Data to restore
        PSHU    A,X                 ; Write a Data to the screen
        LEAU    -29,U               ; Move to the correct position to write data on screen
; Restoring row 2 
        PULS    A,X                 ; Get Data to restore
        PSHU    A,X                 ; Write a Data to the screen
        LEAU    -29,U               ; Move to the correct position to write data on screen
; Restoring row 1 
        PULS    A,X                 ; Get Data to restore
        PSHU    A,X                 ; Write a Data to the screen
        LEAU    -29,U               ; Move to the correct position to write data on screen
; Restoring row 0 
        PULS    A,X                 ; Get Data to restore
        PSHU    A,X                 ; Write a Data to the screen
@SaveSHere
        LDS     #$FFFF              ; Self mod restore stack pointer
        PULS    DP,PC               ; Restore DP & Return

; Backup Sprite data for BreakOutPaddle
; Enter with X pointing at the memory location on screen to backup the data behind the sprite
; Sprite Width is: 3 Bytes, one extra byte to backup for shifted start location
; Height is: 4 Rows
BreakOutPaddle_BackupStart:
        RMB     3*4+32              ; Reserve space for sprite background, plus a little extra for the stack (If F/IRQ happens)
BreakOutPaddle_BackupEnd:
Backup_BreakOutPaddle:
        PSHS    DP                  ; Save Condition Codes & DP
        STS     @SaveSHere+2        ; Backup the stack pointer's value at the end of the backup routine (self mod)
        LDS     #BreakOutPaddle_BackupEnd    ; Set S pointer to the end of the backup buffer
        LEAU    ,X                  ; U = X
; Backup row 0 
        PULU    A,X                 ; Get three bytes from the screen
        PSHS    A,X                 ; Save three bytes from the screen
        LEAU    32-3,U              ; Move down to the start of the next row to copy
; Backup row 1 
        PULU    A,X                 ; Get three bytes from the screen
        PSHS    A,X                 ; Save three bytes from the screen
        LEAU    32-3,U              ; Move down to the start of the next row to copy
; Backup row 2 
        PULU    A,X                 ; Get three bytes from the screen
        PSHS    A,X                 ; Save three bytes from the screen
        LEAU    32-3,U              ; Move down to the start of the next row to copy
; Backup row 3 
        PULU    A,X                 ; Get three bytes from the screen
        PSHS    A,X                 ; Save three bytes from the screen
@SaveSHere
        LDS     #$FFFF              ; Self mod restore stack pointer
        PULS    DP,PC               ; Restore DP & Return

; Frame Number: 0 
BreakOutPaddle_0_0:
; 000 1010101010101010
; 001 1010101010101010
; 002 1010101010101010
; 003 1010101010101010
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDU     #%1010101010101010    ; Get the sprite data into U
        STU     ,X                  ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 1 
        LDU     #%1010101010101010    ; Get the sprite data into U
        STU     ,X                  ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 2 
        LDU     #%1010101010101010    ; Get the sprite data into U
        STU     ,X                  ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 3 
        LDU     #%1010101010101010    ; Get the sprite data into U
        STU     ,X                  ; write the sprite data on screen
        RTS                         ; Done drawing the sprite, Return
BreakOutPaddle_0_1:
; 000 ..1010101010101010......
; 001 ..1010101010101010......
; 002 ..1010101010101010......
; 003 ..1010101010101010......
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11000000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00101010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00111111          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10000000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 1 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11000000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00101010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00111111          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10000000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 2 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11000000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00101010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00111111          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10000000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 3 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11000000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00101010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00111111          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10000000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        RTS                         ; Done drawing the sprite, Return
BreakOutPaddle_0_2:
; 000 ....1010101010101010....
; 001 ....1010101010101010....
; 002 ....1010101010101010....
; 003 ....1010101010101010....
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11110000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00001010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00001111          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10100000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 1 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11110000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00001010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00001111          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10100000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 2 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11110000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00001010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00001111          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10100000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 3 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11110000          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00001010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00001111          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10100000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        RTS                         ; Done drawing the sprite, Return
BreakOutPaddle_0_3:
; 000 ......1010101010101010..
; 001 ......1010101010101010..
; 002 ......1010101010101010..
; 003 ......1010101010101010..
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11111100          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00000010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00000011          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10101000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 1 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11111100          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00000010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00000011          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10101000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 2 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11111100          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00000010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00000011          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10101000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        ABX                         ; Move down a row
; Row 3 
        LDA     #%10101010          ; Get the sprite data into A
        STA     1,X                 ; write the sprite data on screen
        LDA     #%11111100          ; Get the mask in A
        ANDA    ,X                  ; Get the background into transparent bits into A
        ORA     #%00000010          ; Get the non transparent bits into A
        STA     ,X                  ; write the sprite data on screen
        LDA     #%00000011          ; Get the mask in A
        ANDA    2,X                 ; Get the background into transparent bits into A
        ORA     #%10101000          ; Get the non transparent bits into A
        STA     2,X                 ; write the sprite data on screen
        RTS                         ; Done drawing the sprite, Return

