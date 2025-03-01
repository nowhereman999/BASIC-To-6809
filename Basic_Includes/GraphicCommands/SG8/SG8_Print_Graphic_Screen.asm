; Print Command
; Print number in D to the graphics screen
BytesPerChar    EQU     1
PRINT_D_Graphics_Screen_SG8:
        TSTA              ; See if the value is negative or positive
        BPL     >         ; Skip ahead if positive
        COMA
        COMB
        ADDD    #$0001    ; Make D a positive number
        PSHS    D         ; Save D on the stack
        LDA     #109-$40  ; 109 = minus sign
        BRA     @PRINT_D1_Graphics_Screen  ; Skip ahead
!       PSHS    D         ; Save D on the stack
        LDA     #96-$40   ; 96 = space (blank)
@PRINT_D1_Graphics_Screen:
        JSR     AtoGraphics_Screen_SG8
        CLR     _Var_PF00 ; This will be the tenthousands
        CLR     _Var_PF01 ; This will be the thousands
        CLR     _Var_PF02 ; This will be the hundreds
        CLR     _Var_PF03 ; This will be the tens
        CLR     _Var_PF04 ; This will be the ones
        LDD     ,S++      ; D = value to convert to Decimal
!       SUBD    #10000
        BLO     >
        INC     _Var_PF00
        BRA     <
!       ADDD    #10000    ; We now have the ten thousands
!       SUBD    #1000
        BLO     >
        INC     _Var_PF01
        BRA     <
!       ADDD    #1000       ; We now have the thousands
!       SUBD    #100
        BLO     >
        INC     _Var_PF02
        BRA     <
!       ADDD    #100        ; We now have the hundreds
!       SUBD    #10
        BLO     >
        INC     _Var_PF03
        BRA     <
!       ADDD    #10         ; We now have the tens
!       SUBD    #1
        BLO     >
        INC     _Var_PF04
        BRA     <
; We now have the ones
* Print the value on screen
!       LDA     _Var_PF00
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
        BRA     @Print1000sGScreen
!       LDA     _Var_PF01
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
        BRA     @Print100sGScreen
!       LDA     _Var_PF02
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
        BRA     @Print10sGScreen
!       LDA     _Var_PF03
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
        BRA     @Print1sGScreen
!       LDA     _Var_PF04
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
        LDA     #$20        ; Blank
        BRA     AtoGraphics_Screen_SG8 ; Print A on the screen and return, Done
@Print1000sGScreen:
        LDA     _Var_PF01
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
@Print100sGScreen:
        LDA     _Var_PF02
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
@Print10sGScreen:
        LDA     _Var_PF03
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
@Print1sGScreen:
        LDA     _Var_PF04
        ADDA    #$30
        BSR     AtoGraphics_Screen_SG8
        LDA     #$20        ; Blank
        BRA     AtoGraphics_Screen_SG8 ; Print A on the screen and return

AtoGraphics_Screen_SG8:
* Put character on the graphics screen
        PSHS  D,X,Y,U
        LDX   GraphicCURPOS
        CMPA  #$08      ; Is it a backspace?
        BNE   >
        CMPX  BEGGRP    ; Start of the screen?
        BEQ   @DoneGraphicText   ; Retore the registers and return
        LDA   #$80      ; Draw a Blank
        LEAX  -BytesPerChar,X ; Back up the position
        BSR   @GraphicTextDrawAatX  ; Go Draw character A on screen at X
        BRA   @GraphicsTextUpdateCursor  ; Update Cursor and exit
!       LDU   BEGGRP    ; U = screen start
        LEAU  Screen_Size_SG8-(FontHeight-1)*BytesPerRow_SG8,U      ; U = screen End - 7 rows
        PSHS  U         ; Save the value on the stack
        CMPX  ,S++      ; Compare X with the value on the stack, fix the stack
        BLO   >
        LDX   BEGGRP    ; X = Screen Start
        LEAX  Screen_Size_SG8-BytesPerRow_SG8*FontHeight,X  ; X = Screen Start + screen size - 1 row = bottom of the screen
        STX   GraphicCURPOS
!       CMPA  #$0D      ; Enter Key?
        BNE   @GraphicsTextNotEnter
        LDX   GraphicCURPOS
        LDD   GraphicCURPOS ; Load cursor address
        SUBD  BEGGRP        ; Compute offset from start of screen
; Compute Row using repeated subtraction
!       CMPD  #BytesPerRow_SG8          ; Is D less than BytesPerRow_SG8?
        BLO   >             ; If yes, we're done
        SUBD  #BytesPerRow_SG8          ; Subtract one full row
        BRA   <             ; Repeat until D < BytesPerRow_SG8
; B now contains the column number
!       SUBB   #BytesPerRow_SG8      ; B = B - ByttesPerRow_SG8
        LDA   #$80      ; Blank
!       BSR   @GraphicTextDrawAatX  ; Go Draw character A on screen at X
        LEAX  BytesPerChar,X       ; Move to the next position
        INCB
        BNE   <         ; if not keep printing a blank
        LEAX  (FontHeight-1)*BytesPerRow_SG8,X    ; Point at the start of the next row
        LEAU  (FontHeight-1)*BytesPerRow_SG8,U    ; U = screen End
        PSHS  U         ; Save the value on the stack
        CMPX  ,S++      ; Compare X with the value on the stack, fix the stack
        BLO   @GraphicsTextUpdateCursor
        LDX   BEGGRP                  ; X = Screen Start
        LEAX  Screen_Size_SG8-BytesPerRow_SG8*FontHeight,X  ; X = Screen Start + screen size - 1 row = bottom of the screen
        BRA   @GraphicsTextUpdateCursor  ; Update Cursor and exit
@GraphicsTextNotEnter:
        BSR   @GraphicTextDrawAatX  ; Go Draw character A on screen at X
        LEAX  BytesPerChar,X       ; Move to the next position
@GraphicsTextUpdateCursor:
        STX   GraphicCURPOS     ; Update the cursor
@DoneGraphicText:
        PULS    D,X,Y,U,PC    ; Restore regsiters and return
* Draw character A on the graphics screen at position X
@GraphicTextDrawAatX:
        STA     ,X              ; Draw the character
        STA     BytesPerRow_SG8,X ; Draw the character
        STA     BytesPerRow_SG8*2,X ; Draw the character
        STA     BytesPerRow_SG8*3,X ; Draw the character
        RTS                     ; Return
