* Set the width and height of the SG4 screen
ScreenWidth_SG4     EQU 64
ScreenHeight_SG4    EQU 32
BytesPerRow_SG4     EQU ScreenWidth_SG4/2
Screen_Size_SG4     EQU $200
;
; Do the Set function
;
; Enter with:
; A = y coordinate
; B = x coordinate
; LineColour = the colour to set the pixel
; Semi graphic 4 Pixel location in a screen byte
; -----
; |8|4|
; -----
; |2|1|
; -----
; 
SET_SG4:
DoSet_SG4:
        PSHS    D               ; Save CC as a temp byte for the graphic character x & y coordinate on the stack
        CLR     ,-S             ; Clear Pixel value on the stack
        INC     ,S              ; Pixel value is bottom right
        ANDA    #%00011111      ; Make sure y value is 31 or less
        LSRA                    ; Make it 0 to 15
        BCS     >               ; skip if it's an odd row
        LSL     ,S
        LSL     ,S              ; Make it the top row, right pixel
!       ANDB    #%00111111      ; Make sure it's 63 or less
        LSRB                    ; Make sure it's 0 to 31
        BCS     >               ; skip if it's an odd column (right pixel is ready)
        LSL     ,S              ; Make it the to left pixel
!       PSHS    B               ; Save scaled version
        LDB     #32
        MUL
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the row of the pixel to draw
        LDB     ,S+             ; Get the x co-ordinate, fix the stack
        ABX                     ; X has the screen location

        LDB     LineColour      ; B = colour value of 0 to 8
        DECB                    ; Change the colour from 0 to 8 to (-1 to 7)
        BMI    ClearPixel_SG4   ; Branch if SET (X,Y,0)
        LDA    #$10             ; Offset between different colours
        MUL                     ; B = 0 to 7 * 16
        BRA    @Skip            ; Go save the colour
        LDB     ,X              ; Get the current screen value
        BPL     >               ; If text (non- graphic) then make it black
        ANDB    #%01110000      ; Save the colour info
        FCB     $21             ; Skip the CLRB
!       CLRB
@Skip   PSHS    B               ; Save the colour on the stack
        LDA    ,X               ; GET CURRENT CHARACTER FROM SCREEN
        BMI    >                ; BRANCH IF GRAPHIC
        CLRA                    ; RESET ASCII CHARACTER TO ALL PIXELS OFF
!       ANDA   #$0F             ; SAVE ONLY PIXEL ON/OFF INFO
        ORA    1,S              ; OR WITH WHICH PIXEL TO TURN ON
        ORA    ,S++             ; OR IN THE COLOR, fix the stack
!       ORA    #$80             ; FORCE GRAPHIC
        STA    ,X               ; DISPLAY IT ON THE SCREEN
        PULS    D,PC

ClearPixel_SG4:
        LDB     ,X              ; Get the current screen value
        BPL     >               ; If text (non- graphic) then make it black
        ANDB    #%01110000      ; Save the colour info
        FCB     $21             ; Skip the CLRB
!       CLRB
@Skip   PSHS    B               ; Save the colour on the stack
        LDA    ,X               ; GET CURRENT CHARACTER FROM SCREEN
        BMI    >                ; BRANCH IF GRAPHIC
        CLRA                    ; RESET ASCII CHARACTER TO ALL PIXELS OFF
!       LDB     1,S             ; Get pixel to turn on 1,2,4 or 8
        LSRB                    ; make it 0,1,2,4
        LDU     #PixelOffTable_SG4  ; point at the pixel off table
        ANDA    B,U             ; Turn off the pixel
        ORA    ,S++             ; OR IN THE COLOR, fix the stack
!       ORA    #$80             ; FORCE GRAPHIC
        STA    ,X               ; DISPLAY IT ON THE SCREEN
        PULS    D,PC
PixelOffTable_SG4:
        FCB     %00001110       ; 0000 0001
        FCB     %00001101       ; 0000 0010
        FCB     %00001011       ; 0000 0100
        FCB     %00001011       ; 0000 0100 not used
        FCB     %00000111       ; 0000 1000

; Do the Point function
; Enter with:
; A = y coordinate
; B = x coordinate
; Exit with B = the pixel colour, or -1 if a text character
POINT_SG4:
        CLR     ,-S             ; Clear Pixel value on the stack
        INC     ,S              ; Pixel value is bottom right
        ANDA    #%00011111      ; Make sure it's 31 or less
        LSRA                    ; Make it 0 to 15
        BCS     >               ; skip if it's an odd row
        LSL     ,S
        LSL     ,S              ; Make it the top row, right pixel
!       ANDB    #%00111111      ; Make sure it's 63 or less
        LSRB                    ; Make sure it's 0 to 31
        BCS     >               ; skip if it's an odd column (right pixel is ready)
        LSL     ,S              ; Make it the to left pixel
!       PSHS    B
        LDB     #32
        MUL
        ADDD    BEGGRP          ; Add the Video Start Address
        TFR     D,X             ; X now has the location of the pixel to draw
        LDB     ,S+             ; Get the x co-ordinate, fix the stack
        ABX                     ; X has the screen location
        LDB    #$FF           INITIAL VALUE OF ON/OFF FLAG = OFF (FALSE)
        LDA    ,X             GET CURRENT GRAPHIC CHARACTER
        BPL    PNonGraphic    BRANCH IF NON-GRAPHIC (ALWAYS FALSE)
        ANDA   ,S+            AND CURR CHAR WITH THE PIXEL IN QUESTION, and fix the stack
        BEQ    >              BRANCH IF THE ELEMENT IS OFF
        LDB    ,X             GET CURRENT CHARACTER
        LSRB                  * SHIFT RIGHT
        LSRB                  * SHIFT RIGHT
        LSRB                  * SHIFT RIGHT
        LSRB                  * SHIFT RIGHT - NOW THE HIGH NIBBLE IS IN THE LOW NIBBLE
        ANDB   #7             KEEP ONLY THE COLOR INFO
!       INCB                  ACCB=0 FOR NO COLOR, =1 TO 8 OTHERWISE
PNonGraphic:
        RTS

; Colour the screen Colour B
GCLS_SG4:
        LDX     #SG4_ColourTable
        LDA     B,X
        LDB     B,X
        LDX     BEGGRP
        LEAU    Screen_Size_SG4,X ; Screen Size
        STU     GCLSComp_SG4+1 ; Self mod end address
!       STD     ,X++
GCLSComp_SG4:
        CMPX    #$FFFF  ; Self modded end address
        BNE     <
        RTS
SG4_ColourTable:
        FCB     $80     ; 0
        FCB     $8F     ; 1
        FCB     $9F     ; 2
        FCB     $AF     ; 3
        FCB     $BF     ; 4
        FCB     $CF     ; 5
        FCB     $DF     ; 6
        FCB     $EF     ; 7
        FCB     $FF     ; 8
