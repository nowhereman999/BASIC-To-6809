; Print Command
; Print number in D to the graphics screen
PRINT_D_Graphics_Screen
        TSTA              ; See if the value is negative or positive
        BPL     >         ; Skip ahead if positive
        COMA
        COMB
        ADDD    #$0001    ; Make D a positive number
        PSHS    D         ; Save D on the stack
        LDA     #109-$40  ; 109 = minus sign
        BRA     PRINT_D1_Graphics_Screen  ; Skip ahead
!       PSHS    D         ; Save D on the stack
        LDA     #96-$40   ; 96 = space (blank)
PRINT_D1_Graphics_Screen:
        JSR     AtoGraphics_Screen
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
!
; We now have the ones
* Print the value on screen
        LDA     _Var_PF00
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen
        BRA     Print1000sGScreen
!       LDA     _Var_PF01
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen
        BRA     Print100sGScreen
!       LDA     _Var_PF02
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen
        BRA     Print10sGScreen
!       LDA     _Var_PF03
        BEQ     >
        ADDA    #$30
        BSR     AtoGraphics_Screen
        BRA     Print1sGScreen
!       LDA     _Var_PF04
        ADDA    #$30
        BSR     AtoGraphics_Screen
        LDA     #$20        ; Blank
        BRA     AtoGraphics_Screen ; Print A on the screen and return, Done
Print1000sGScreen:
        LDA     _Var_PF01
        ADDA    #$30
        BSR     AtoGraphics_Screen
Print100sGScreen:
        LDA     _Var_PF02
        ADDA    #$30
        BSR     AtoGraphics_Screen
Print10sGScreen:
        LDA     _Var_PF03
        ADDA    #$30
        BSR     AtoGraphics_Screen
Print1sGScreen:
        LDA     _Var_PF04
        ADDA    #$30
        BSR     AtoGraphics_Screen
        LDA     #$20        ; Blank
        BRA     AtoGraphics_Screen ; Print A on the screen and return

GraphicCURPOS   RMB     2       ; Reserve RAM for the Graphics Cursor
AtoGraphics_Screen:
* Put character of the graphics screen
        PSHS  D,X,Y,U
        LDX   GraphicCURPOS
        CMPA  #$08      ; Is it a backspace?
        BNE   >
        CMPX  #$0E00     ; Start of the screen?
        BEQ   DoneGraphicText   ; Retore the registers and return
        LDA   #$20      ; Blank
        LEAX  -1,X
        BSR   GraphicTextDrawAatX  ; Go Draw character A on screen at X
        BRA   GraphicsTextUpdateCursor  ; Update Cursor and exit
!       CMPX  #$2600-7*32
        BHS   GraphicsTextBottom
        CMPA  #$0D      ; Enter Key?
        BNE   GraphicsTextNotEnter
        LDX   GraphicCURPOS
!       LDA   #$20      ; Blank
        BSR   GraphicTextDrawAatX  ; Go Draw character A on screen at X
        LEAX  1,X
        TFR   X,D
        BITB  #$1F
        BNE   <
        LEAX  32*7,X    ; Point at the start of the next row
        CMPX  #$2600
        BLO   GraphicsTextUpdateCursor
GraphicsTextBottom:
        LDX   #$2600-32*8
        BRA   GraphicsTextUpdateCursor  ; Update Cursor and exit
GraphicsTextNotEnter:
        BSR   GraphicTextDrawAatX  ; Go Draw character A on screen at X
        LEAX    1,X
GraphicsTextUpdateCursor:
        STX   GraphicCURPOS
DoneGraphicText:
        PULS    D,X,Y,U,PC    ; Restore regsiters and return

* Draw character A on the graphics screen at position X
GraphicTextDrawAatX:
        PSHS    A,X
;        LDD     1,S
;        LSLB
;        ROLA
;        LSLB
;        ROLA
;        LSLB
;        ROLA                    ; A now has the Row
;        LDB     2,S
;        ANDB    #%00011111      ; Keep the Column value
;        ADDD    #$E00           ; Add the screen start location
;        TFR     D,U             ; U Now has the screen location to print the character on screen
        LDU     1,S
        LDB     ,S              ; Get the character in B
        SUBB    #32
        BPL     >
        CLRB
!       CMPB    #96
        BLO     >
        CLRB
!       LDX     #CharJumpTable
        ABX
        ABX
        JSR     [,X]
        PULS    A,X,PC
        