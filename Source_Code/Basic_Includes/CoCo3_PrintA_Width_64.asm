; Commands to print to the relocatable width 64 screen
TextCols EQU 64
TextRows EQU 28
W_CURPOS    FDB   $0000 ; Cursor x & y position for the Width screen

PrintA_On_Screen:
* PUT CHARACTER ON THE SCREEN
LA30A:
      PSHS  D,X
      LDX   BEGGRP      ; Get the relocated screen start address
      LDA   W_CURPOS+1    ; Get the Y co-ordinate
      LDB   #TextCols*2
      MUL
      ADDB  W_CURPOS      ; Add the x co-ordinate
      BCC   >
      INCA
!     LEAX  D,X         ; X = screen location
      LDB   AttributeByte
      LDA   ,S          ; Get the character to print on screen
      CMPA  #$08        ; Is it a backspace?
      BNE   >           ; If not skip forward
      CMPX  BEGGRP      * Start of the screen?
      BEQ   LA35D       * Retore the registers and return
      LDA   W_CURPOS
      BNE   @BackspaceSameRow
      DEC   W_CURPOS+1
      LDA   #TextCols*2
      STA   W_CURPOS
@BackspaceSameRow:
      LDA   #' '        * Blank
      STD   ,--X
      DEC   W_CURPOS
      DEC   W_CURPOS
      BRA   LA344       ; update cursor and exit
!     CMPA  #$0D        ; Enter Key?
      BLO   LA35D       ; Special control character, EXIT
      BNE   LA32F       ; If not print normal character
!     LDA   #' '        * Blank
      STD   ,X++
      INC   W_CURPOS
      INC   W_CURPOS
      LDA   W_CURPOS
      CMPA  #TextCols*2
      BNE   <           ; If not then clear the rest of this line
@NextRow:
      CLR   W_CURPOS    ; X = 0
      INC   W_CURPOS+1  ; Move to the next line
      BRA   LA344       ; update cursor and exit
; Not the Enter Key
LA32F:
      STD   ,X++
      INC   W_CURPOS
      INC   W_CURPOS
      LDA   W_CURPOS
      CMPA  #TextCols*2
      BEQ   @NextRow    ; We just printed the last character of this row
LA344:
      LDA   W_CURPOS+1  ; Has the cursor moved below the last visible row?
      CMPA  #TextRows
      BLO   LA35D
      BSR   ScrollTextScreen       * Scroll the screen
LA35D:
      PULS    D,X,PC    ; Restore D & X and return

; Advance to the next 16-column PRINT zone. W_CURPOS stores its horizontal
; position as a byte offset because each wide-text cell is two bytes.
PrintComma:
      PSHS  D
      LDB   W_CURPOS
      ADDB  #16*2
      ANDB  #%11100000
      CMPB  #TextCols*2
      BLO   @StoreColumn
      CLRB
      INC   W_CURPOS+1
      LDA   W_CURPOS+1
      CMPA  #TextRows
      BLO   @StoreColumn
      BSR   ScrollTextScreen
      PULS  D,PC
@StoreColumn:
      STB   W_CURPOS
      PULS  D,PC

* Move rows 1-27 to rows 0-26 and blank the last row.
ScrollTextScreen:
      PSHS  D,X,Y,U
      LDX   BEGGRP
      LEAU  TextCols*2,X
      LDY   #TextCols*(TextRows-1) ; Number of words to copy
!     LDD   ,U++
      STD   ,X++
      LEAY  -1,Y
      BNE   <
      LDA   #' '
      LDB   AttributeByte
      LDY   #TextCols
!     STD   ,X++
      LEAY  -1,Y
      BNE   <
      LDD   #TextRows-1 ; X = 0, Y = last row
      STD   W_CURPOS
      PULS  D,X,Y,U,PC

; Do PRINT @ on the 64-character text screen
; Enter with D = the Print @ value
DoPrintAt:
      LDX   #0          ; y = 0
      LSLB
      ROLA              ; D = D * 2 (user doesn't have to worry about the attribute byte)
!     CMPD  #TextCols*2 ; Width ?
      BLO   @Done
      SUBD  #TextCols*2 ; Subtract the width
      LEAX  1,X         ; y++
      BRA   <
@Done:  
; Remainder is now in B which is the x co-ordinate
      PSHS  B           ; Save the x value on the stack
      TFR   X,D         ; B = Y value
      PULS  A           ; A = X value
      STD   W_CURPOS      ; Update the cursor position
      RTS

; Clear 29 rows: 28 logical text rows plus the extra row displayed by the GIME.
; Enter with:
; B = Text background colour to fill screen with
;
CLS_B: 
CLS_FixB:
      PSHS  Y
      LDA   #' '
      ANDB  #%00000111
      LDX   BEGGRP            ; Relocated screen start
      LDY   #TextCols*(TextRows+1)
!     STD   ,X++
      LEAY  -1,Y
      BNE   <
      LDD   #$0000
      STD   W_CURPOS          ; CLS always homes the cursor
      PULS  Y,PC
CLS_Default:
      CLRB
      BRA   CLS_B
