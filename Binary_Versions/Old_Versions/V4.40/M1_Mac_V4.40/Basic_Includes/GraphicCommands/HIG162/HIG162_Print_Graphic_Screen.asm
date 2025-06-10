; Print Command
; Print number in D to the graphics screen
BytesPerChar    EQU     8
G_Background    FCB     0
G_Foreground    FCB     255
PRINT_D_Graphics_Screen_HIG162:
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
        JSR     AtoGraphics_Screen_HIG162
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
        BSR     AtoGraphics_Screen_HIG162
        BRA     @Print1000sGScreen
!       LDA     _Var_PF01
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen_HIG162
        BRA     @Print100sGScreen
!       LDA     _Var_PF02
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen_HIG162
        BRA     @Print10sGScreen
!       LDA     _Var_PF03
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen_HIG162
        BRA     @Print1sGScreen
!       LDA     _Var_PF04
        ADDA    #$30
        BSR     AtoGraphics_Screen_HIG162
        LDA     #$20        ; Blank
        BRA     AtoGraphics_Screen_HIG162 ; Print A on the screen and return, Done
@Print1000sGScreen:
        LDA     _Var_PF01
        ADDA    #$30
        BSR     AtoGraphics_Screen_HIG162
@Print100sGScreen:
        LDA     _Var_PF02
        ADDA    #$30
        BSR     AtoGraphics_Screen_HIG162
@Print10sGScreen:
        LDA     _Var_PF03
        ADDA    #$30
        BSR     AtoGraphics_Screen_HIG162
@Print1sGScreen:
        LDA     _Var_PF04
        ADDA    #$30
        BSR     AtoGraphics_Screen_HIG162
        LDA     #$20        ; Blank
        BRA     AtoGraphics_Screen_HIG162 ; Print A on the screen and return

AtoGraphics_Screen_HIG162:
* Put character of the graphics screen
        PSHS  D,X,Y,U
        LDX   GraphicCURPOS
        CMPA  #$08      ; Is it a backspace?
        BNE   >
        CMPX  BEGGRP    ; Start of the screen?
        BEQ   @DoneGraphicText   ; Retore the registers and return
        LDA   #$20      ; Draw a Blank
        LEAX  -BytesPerChar,X ; Back up the position
        BSR   @GraphicTextDrawAatX  ; Go Draw character A on screen at X
        BRA   @GraphicsTextUpdateCursor  ; Update Cursor and exit
!       LDU   BEGGRP    ; U = screen start
        LEAU  Screen_Size_HIG162-(FontHeight-1)*BytesPerRow_HIG162,U      ; U = screen End - 7 rows
        PSHS  U         ; Save the value on the stack
        CMPX  ,S++      ; Compare X with the value on the stack, fix the stack
        BLO   >
        LDX   BEGGRP    ; X = Screen Start
        LEAX  Screen_Size_HIG162-BytesPerRow_HIG162*FontHeight,X  ; X = Screen Start + screen size - 1 row = bottom of the screen
        STX   GraphicCURPOS
!       BSR   @GraphicTextDrawAatX  ; Go Draw character A on screen at X
        LEAX  BytesPerChar,X       ; Move to the next position
;        TFR   X,D       ; D = X
;        BITB  #BytesPerRow_HIG162-1  ; Is it the start of a new row?
;        BNE   @GraphicsTextUpdateCursor ; No, update the cursor and exit
;        LEAX  (FontHeight-1)*BytesPerRow_HIG162,X    ; Point at the start of the next row
@GraphicsTextUpdateCursor:
        STX   GraphicCURPOS     ; Update the cursor
@DoneGraphicText:
        PULS    D,X,Y,U,PC    ; Restore regsiters and return
* Draw character A on the graphics screen at position X
@GraphicTextDrawAatX:
        PSHS    A,X             ; Save the registers
        LDU     1,S             ; Get the screen address in U
        LDB     ,S              ; Get the character in B
        SUBB    #32             ; Subtract 32 to get the offset in the font
        BPL     >               ; Skip ahead if good
        CLRB                    ; Otherwise, make it a space
!       CMPB    #96             ; Is it a printable character?
        BLO     >               ; Yes, skip ahead
        CLRB                    ; Otherwise, make it a space
!       LDX     #CharJumpTable_HIG162 ; Get the address of the character jump table
        ABX                     ; Add the offset to the jump table      
        ABX                     ; Add the offset to the jump table X now = X + B * 2
        JSR     [,X]            ; Jump to the routine to draw the character
        PULS    A,X,PC          ; Restore registers and return
