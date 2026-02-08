; Commands to Print to the width 80 screen @ $0E00
TextCols EQU 80
TextRows EQU 28
W_CURPOS    FDB   $0000 ; Cursor x & y position for the Width screen

PrintA_On_Screen:
* PUT CHARACTER ON THE SCREEN
LA30A:
      PSHS  D,X
      LDX   #$E00       ; Get the screen start address
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
      BNE   LA31D
      CMPX  #$E00       * Start of the screen?
      BEQ   LA35D       * Retore the registers and return
      LDA   #' '        * Blank
      STD   ,--X
      DEC   W_CURPOS
      DEC   W_CURPOS
      BRA   LA344       ; update cursor and exit
LA31D:
      CMPA  #$0D        ; Enter Key?
      BNE   LA32F       ; Not print normal character
LA323:
      LDA   #' '        * Blank
      STD   ,X++
      INC   W_CURPOS
      INC   W_CURPOS
      LDA   W_CURPOS
      CMPA  #TextCols*2
      BNE   LA323       ; If not then clear the rest of this line
      CLR   W_CURPOS      ; X = 0
      INC   W_CURPOS+1    ; Move to the next line
      BRA   LA344       ; update cursor and exit
; Not the Enter Key
LA32F:
      STD   ,X++
      INC   W_CURPOS
      INC   W_CURPOS
LA344:  
      CMPX  #$0E00+TextCols*2*TextRows      * End of screen?
      BLO   LA35D
      BSR   ScrollTextScreen       * Scroll the screen
LA35D:
      PULS    D,X,PC    ; Restore D & X and return

* Otherwise scroll the screen (Fastest method I can think of for 6809)
ScrollTextScreen:
      PSHS  CC,DP,Y,U
      STS   @DoneScroll+2    * Save the Stack pointer (self mod below)
      ORCC  #$50
      LDS   #$E00+TextCols*2      ; Set S as the source as the line below
      LDA   #TextCols*2             ; bytes per line * 28 rows / 28 (7*4)
      STA   >Temp1                  ; Save as the counter
!     LEAU  -TextCols*2+7,S   ; Move U forward
      PULS  D,DP,X,Y  ; Get the source data
      PSHU  D,DP,X,Y  ; Write the destination data
      LEAU  -TextCols*2+7,S   ; Move U forward
      PULS  D,DP,X,Y  ; Get the source data
      PSHU  D,DP,X,Y  ; Write the destination data
      LEAU  -TextCols*2+7,S   ; Move U forward
      PULS  D,DP,X,Y  ; Get the source data
      PSHU  D,DP,X,Y  ; Write the destination data
      LEAU  -TextCols*2+7,S   ; Move U forward
      PULS  D,DP,X,Y  ; Get the source data
      PSHU  D,DP,X,Y  ; Write the destination data
      DEC   >Temp1
      BNE   <
      LDA   #' '
      LDB   AttributeByte
      TFR   D,X
      LEAY  ,X
      LEAU  ,X
!     PSHS  D,X,Y,U
      CMPS  #$0E00+TextCols*2*TextRows-TextCols*2 ; End of the screen - 1 row?
      BNE   <
      LDD   #27         ; X = 0, Y = 27 (last row)
      STD   W_CURPOS
@DoneScroll:
      LDS   #$FFFF    ; Restore the Stack
      PULS  CC,DP,Y,U,PC      ;  Restore all and return

; Do the PRINT @ on the 40 character text screen
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

; Clear the 64x28 text screen
; Enter with:
; B = Text background colour to fill screen with
;
CLS_B: 
CLS_FixB:
      LDA   #' '
      ANDB  #%00000111
      LDX   #$0E00            ; Screen start
!     STD   ,X++
      CMPX  #$0E00+TextCols*2*(TextRows+1) ; End of the screen + 1 row?
      BNE   <
      RTS                     ; Return
CLS_Default:
      CLRB
      BRA   CLS_B
