; Commands to Print to the width 40 screen @ $0E00

PrintA_On_Screen:
* PUT CHARACTER ON THE SCREEN
LA30A:  PSHS  D,X
        LDX   CURPOS
        CMPA  #$08        * Is it a backspace?
        BNE   LA31D
        CMPX  #$400       * Start of the screen?
        LBEQ   LA35D       * Retore the registers and return
        LDA   #$60        * Blank
        STA   ,-X
        BRA   LA344
LA31D:  CMPA  #$0D        * Enter Key?
        BNE   LA32F
        LDX   CURPOS
LA323:  LDA   #$60        * Blank
        STA   ,X+
        TFR   X,D
        BITB  #$1F
        BNE   LA323
        BRA   LA344
LA32F:  CMPA  #$20        * Is it a SPACE?
        BLO   LA35D       * If it's lower it's some kind of control character so restore the registers and return
        TSTA
        BMI   LA342       * If it's higher than 127 then print it as is
        CMPA  #$40        * Is it lower than $40?
        BLO   LA340       * If so then XOR it with %01000000, then print it
        CMPA  #$60        * Is it lower than $60?
        BLO   LA342       * If so then Print character as is
        ANDA  #%11011111  * otherwise Clear bit 5
LA340:  EORA  #%01000000  * XOR bit 6
LA342:  STA   ,X+
LA344:  STX   CURPOS
        CMPX  #$05FF      * End of screen
        BHI   ScrollTextScreen       * Scroll the screen
LA35D:
        PULS  D,X,PC    ; Restore D & X and return

* Otherwise scroll the screen (Fastest method I can think of for 6809)
ScrollTextScreen:
        PSHS    CC,DP,Y,U
        STS     DoneScroll+2    * Save the Stack pointer (self mod below)
* 68 * 7 = 476 need to move an extra 4 bytes at the end to equal 480 bytes (15 rows of 32 bytes)
        ORCC    #$50
        LDU     #$400+4   ; Set U as the destination address of the top line on the screen
        LEAS    $20-4,U   ; Set S as the source as the line below $420
        PULS    D,X       ; Get the first 4 bytes
        PSHU    D,X       ; Save the first 4 bytes
!       LEAU    -32+7,S   ; Move U forward
        PULS    D,DP,X,Y  ; Get the source data
        PSHU    D,DP,X,Y  ; Write the destination data
        LEAU    -32+7,S   ; Move U forward
        PULS    D,DP,X,Y  ; Get the source data
        PSHU    D,DP,X,Y  ; Write the destination data
        LEAU    -32+7,S   ; Move U forward
        PULS    D,DP,X,Y  ; Get the source data
        PSHU    D,DP,X,Y  ; Write the destination data
        LEAU    -32+7,S   ; Move U forward
        PULS    D,DP,X,Y  ; Get the source data
        PSHU    D,DP,X,Y  ; Write the destination data
        CMPS    #$600     ; Is S past the end of the screen yet?
        BNE     <
        LDD     #$6060    ; make the bottom row blank
        LDX     #$6060    ; make the bottom row blank
        LEAY    ,X        ; make the bottom row blank
        PSHS    D,X,Y
        PSHS    D,X,Y
        PSHS    D,X,Y
        PSHS    D,X,Y
        PSHS    D,X,Y
        STD     -2,S      ; Clear the bottom row
DoneScroll:
        LDS     #$FFFF    ; Restore the Stack
        PULS    CC,DP,Y,U  * Restore all
        LDX     #$5E0
        STX     CURPOS    ; Make the CURPOS the bottom left corner of the screen+1
        PULS    D,X,PC    ; Restore D & X and return

CLS_FixB:
        CMPB    #9      ; Compare value with 9
        BLO     >       ; If value is lower than 9 then skip ahead
        LDB     #$60    ; Otherwise make B = Default background colour
        BRA     CLS_B   ; Fill the screen with colour B
!       TSTB            ; Compare value with 0
        BNE     >       ; If value is 1 to 8 we're good, go show it
        LDB     #$80    ; Otherwise make B = $80 as Black colour
        BRA     CLS_B   ; Fill the screen with colour B
!       DECB            ; B = 0 to 7
        LSLB
        LSLB
        LSLB
        LSLB            ; B = B * 16
        ORB     #%10001111      ; Set bits 7,3,2,1,0

; Clear the 32x16 normal boot up screen
; Enter with:
; B = value to fill screen with
; Clobbers all the registers
;
; Why not stack blast :)
CLS_B:  TFR     B,A           ; A = B
        TFR     D,X           ; X = D
        LEAY    ,X            ; Y = X
        LDU     #$0600        ; Set User stack to the Starting point
!       PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        CMPU    #$420         ; Are we just about done?
        BNE     <             ; Keep looping if not
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D,X,Y         ; Push D,X,Y on screen
        PSHU    D             ; Push D on screen
        STU     CURPOS        ; Save U which is now $400 in the CURSOR position
        RTS                   ; Return
        
CLS_Default:
        LDB     #$60
        BRA     CLS_B

; Handle Print @ command
; Enter with D = the Print @ value
DoPrintAt:
        ADDD    #$400         ; D=D+$400, start of the screen in RAM
        CMPD    #$600         ; Compare D with $600
        BLO     >             ; Skip ahead if lower than $600
        LDD     #$5FF         ; Make D = $5FF (max)
        BRA     @StoreD       ; Update the location to print
!       CMPD    #$400         ; Compare D with $600
        BHS     @StoreD       ; Skip ahead if higher than $600
        LDD     #$400         ; Make D = $400 (min)
@StoreD STD     CURPOS        ; Update the location of the cursor
        RTS                   ; Return