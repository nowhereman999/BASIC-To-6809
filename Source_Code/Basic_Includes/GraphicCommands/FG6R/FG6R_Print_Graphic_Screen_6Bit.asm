; PRINT #-4/#-5 support for FG6R
; 42 columns x 24 rows using 6x8 one-bit characters on the 256x192 screen.

FG6R_6Bit_Columns     EQU     42
FG6R_6Bit_Rows        EQU     24
FG6R_6Bit_CellCount   EQU     FG6R_6Bit_Columns*FG6R_6Bit_Rows
FG6R_6Bit_LastRow     EQU     FG6R_6Bit_Columns*(FG6R_6Bit_Rows-1)

 IFNDEF LOCATE_FG6R_DEFINED
LOCATE_FG6R_DEFINED EQU 1
LOCATE_FG6R:
* LOCATE for PRINT #-4.  X is a character column from 0 to 41,
* and Y is a character row from 0 to 23.
        LDD     x0              ; Get the x value in D
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #41             ; Check if it's beyond the right side
        BLE     >               ; Skip ahead if good
        LDD     #41             ; Make it the right most 6 bit column
!       PSHS    D               ; Save the 42 column x cell

        LDD     y0              ; Get the y value in D
        BPL     >               ; Skip ahead if positive
        LDD     #$0000          ; Otherwise, make it zero
!       CMPD    #23             ; Check if it's beyond the bottom row
        BLE     >               ; Skip ahead if good
        LDD     #23             ; Make it the bottom 6 bit row
!       LDA     #42             ; A = 42 columns per row
        MUL                     ; D = 42 * B
        ADDD    ,S++            ; Add the x cell and fix the stack
        STD     GraphicCURPOS6  ; Update the 42 column graphics cursor
        RTS
 ENDIF

PRINT_D_Graphics_Screen_6Bit_FG6R:
        RTS

PRINT_D_Graphics_Screen_6Bit_Inverse_FG6R:
        RTS

AtoGraphics_Screen_6Bit_FG6R:
        CLR     FG6R_6Bit_Inverse
        BRA     FG6R6_AtoCommon

AtoGraphics_Screen_6Bit_Inverse_FG6R:
        PSHS    B
        LDB     #1
        STB     FG6R_6Bit_Inverse
        PULS    B

FG6R6_AtoCommon:
        PSHS    D,X,Y,U
        CMPA    #$08
        BNE     >
        LDD     GraphicCURPOS6
        BEQ     FG6R6_Done
        SUBD    #1
        STD     GraphicCURPOS6
        LDA     #$20
        BSR     FG6R6_DrawA
        BRA     FG6R6_Done
!       CMPA    #$0D
        BNE     >
        BSR     FG6R6_NextLine
        BRA     FG6R6_Done
!       BSR     FG6R6_DrawA
        LDD     GraphicCURPOS6
        ADDD    #1
        STD     GraphicCURPOS6
        BSR     FG6R6_ClampCursor
FG6R6_Done:
        PULS    D,X,Y,U,PC

FG6R6_NextLine:
        LDD     GraphicCURPOS6
!       CMPD    #FG6R_6Bit_Columns
        BLO     >
        SUBD    #FG6R_6Bit_Columns
        BRA     <
!       STD     FG6R_6Bit_Col
        LDD     #FG6R_6Bit_Columns
        SUBD    FG6R_6Bit_Col
        ADDD    GraphicCURPOS6
        STD     GraphicCURPOS6
        BRA     FG6R6_ClampCursor

FG6R6_ClampCursor:
        LDD     GraphicCURPOS6
        CMPD    #FG6R_6Bit_CellCount
        BLO     >
        LDD     #FG6R_6Bit_LastRow
        STD     GraphicCURPOS6
!       RTS

FG6R6_DrawA:
        CMPA    #$20
        BHS     >
        LDA     #$20
!       CMPA    #$80
        BLO     >
        LDA     #$20
!       SUBA    #$20
        LDB     #8
        MUL
        LDY     #FG6R_6Bit_Font
        LEAY    D,Y

        LDD     GraphicCURPOS6
        LDX     #0
!       CMPD    #FG6R_6Bit_Columns
        BLO     >
        SUBD    #FG6R_6Bit_Columns
        LEAX    1,X
        BRA     <
!       STD     FG6R_6Bit_Col
        LDU     BEGGRP
        TFR     X,D
        EXG     A,B
        LEAU    D,U

        LDB     FG6R_6Bit_Col+1
        LDA     #6
        MUL
        STD     FG6R_6Bit_PixelX
        LDB     FG6R_6Bit_PixelX+1
        ANDB    #7
        STB     FG6R_6Bit_BitOffset
        LDD     FG6R_6Bit_PixelX
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB
        LEAU    D,U

        LDA     #8
        STA     FG6R_6Bit_RowCount
FG6R6_RowLoop:
        LDA     ,Y+
        STA     FG6R_6Bit_RowBits
        CLR     FG6R_6Bit_Pixel
FG6R6_PixelLoop:
        LDB     FG6R_6Bit_BitOffset
        ADDB    FG6R_6Bit_Pixel
        CMPB    #8
        BLO     >
        SUBB    #8
        LDX     #PixelTable_FG6R
        LDB     B,X
        LDA     1,U
        PSHS    A,B
        LDB     FG6R_6Bit_Pixel
        LDX     #FG6R_6Bit_GlyphMasks
        LDA     FG6R_6Bit_RowBits
        BITA    B,X
        PULS    A,B
        BRA     FG6R6_SecondByte
!       LDX     #PixelTable_FG6R
        LDB     B,X
        LDA     ,U
        PSHS    A,B
        LDB     FG6R_6Bit_Pixel
        LDX     #FG6R_6Bit_GlyphMasks
        LDA     FG6R_6Bit_RowBits
        BITA    B,X
        PULS    A,B
        BEQ     FG6R6_GlyphOffFirst
        TST     FG6R_6Bit_Inverse
        BNE     FG6R6_ClearFirst
        PSHS    B
        ORA     ,S+
        STA     ,U
        BRA     FG6R6_NextPixel
FG6R6_GlyphOffFirst:
        TST     FG6R_6Bit_Inverse
        BNE     FG6R6_SetFirst
        BRA     FG6R6_ClearFirst
FG6R6_SetFirst:
        PSHS    B
        ORA     ,S+
        STA     ,U
        BRA     FG6R6_NextPixel
FG6R6_ClearFirst:
        LDX     #PixelTableClear_FG6R
        LDB     FG6R_6Bit_BitOffset
        ADDB    FG6R_6Bit_Pixel
        LDB     B,X
        PSHS    B
        ANDA    ,S+
        STA     ,U
        BRA     FG6R6_NextPixel
FG6R6_SecondByte:
        PSHS    A,B
        LDB     FG6R_6Bit_Pixel
        LDX     #FG6R_6Bit_GlyphMasks
        LDA     FG6R_6Bit_RowBits
        BITA    B,X
        PULS    A,B
        BEQ     FG6R6_GlyphOffSecond
        TST     FG6R_6Bit_Inverse
        BNE     FG6R6_ClearSecond
        PSHS    B
        ORA     ,S+
        STA     1,U
        BRA     FG6R6_NextPixel
FG6R6_GlyphOffSecond:
        TST     FG6R_6Bit_Inverse
        BNE     FG6R6_SetSecond
        BRA     FG6R6_ClearSecond
FG6R6_SetSecond:
        PSHS    B
        ORA     ,S+
        STA     1,U
        BRA     FG6R6_NextPixel
FG6R6_ClearSecond:
        LDX     #PixelTableClear_FG6R
        LDB     FG6R_6Bit_BitOffset
        ADDB    FG6R_6Bit_Pixel
        SUBB    #8
        LDB     B,X
        PSHS    B
        ANDA    ,S+
        STA     1,U
FG6R6_NextPixel:
        INC     FG6R_6Bit_Pixel
        LDB     FG6R_6Bit_Pixel
        CMPB    #6
        LBLO    FG6R6_PixelLoop
        LEAU    BytesPerRow_FG6R,U
        DEC     FG6R_6Bit_RowCount
        LBNE    FG6R6_RowLoop
        RTS

FG6R_6Bit_Col         FDB     0
FG6R_6Bit_PixelX      FDB     0
FG6R_6Bit_BitOffset   FCB     0
FG6R_6Bit_Pixel       FCB     0
FG6R_6Bit_RowBits     FCB     0
FG6R_6Bit_RowCount    FCB     0
FG6R_6Bit_Inverse     FCB     0

FG6R_6Bit_GlyphMasks:
        FCB     %00100000,%00010000,%00001000,%00000100,%00000010,%00000001

FG6R_6Bit_Font:
        FCB %000000,%000000,%000000,%000000,%000000,%000000,%000000,%000000 ; $20
        FCB %001000,%001000,%001000,%001000,%001000,%000000,%001000,%000000 ; $21 !
        FCB %010100,%010100,%010100,%000000,%000000,%000000,%000000,%000000 ; $22 "
        FCB %010100,%111110,%010100,%010100,%111110,%010100,%010100,%000000 ; $23 #
        FCB %001000,%011110,%101000,%011100,%001010,%111100,%001000,%000000 ; $24 $
        FCB %110010,%110100,%001000,%010000,%101100,%001100,%000000,%000000 ; $25 %
        FCB %011000,%100100,%101000,%010000,%101010,%100100,%011010,%000000 ; $26 &
        FCB %001000,%001000,%010000,%000000,%000000,%000000,%000000,%000000 ; $27 '
        FCB %000100,%001000,%010000,%010000,%010000,%001000,%000100,%000000 ; $28 (
        FCB %010000,%001000,%000100,%000100,%000100,%001000,%010000,%000000 ; $29 )
        FCB %000000,%101010,%011100,%111110,%011100,%101010,%000000,%000000 ; $2A *
        FCB %000000,%001000,%001000,%111110,%001000,%001000,%000000,%000000 ; $2B +
        FCB %000000,%000000,%000000,%000000,%000000,%001000,%001000,%010000 ; $2C ,
        FCB %000000,%000000,%000000,%111110,%000000,%000000,%000000,%000000 ; $2D -
        FCB %000000,%000000,%000000,%000000,%000000,%001100,%001100,%000000 ; $2E .
        FCB %000010,%000010,%000100,%001000,%010000,%100000,%100000,%000000 ; $2F /
        FCB %011100,%100010,%100110,%101010,%110010,%100010,%011100,%000000 ; $30 0
        FCB %001000,%011000,%001000,%001000,%001000,%001000,%011100,%000000 ; $31 1
        FCB %011100,%100010,%000010,%000100,%001000,%010000,%111110,%000000 ; $32 2
        FCB %111100,%000010,%000010,%011100,%000010,%000010,%111100,%000000 ; $33 3
        FCB %000100,%001100,%010100,%100100,%111110,%000100,%000100,%000000 ; $34 4
        FCB %111110,%100000,%100000,%111100,%000010,%000010,%111100,%000000 ; $35 5
        FCB %001100,%010000,%100000,%111100,%100010,%100010,%011100,%000000 ; $36 6
        FCB %111110,%000010,%000100,%001000,%010000,%010000,%010000,%000000 ; $37 7
        FCB %011100,%100010,%100010,%011100,%100010,%100010,%011100,%000000 ; $38 8
        FCB %011100,%100010,%100010,%011110,%000010,%000100,%011000,%000000 ; $39 9
        FCB %000000,%001100,%001100,%000000,%001100,%001100,%000000,%000000 ; $3A :
        FCB %000000,%001100,%001100,%000000,%001100,%001000,%010000,%000000 ; $3B ;
        FCB %000100,%001000,%010000,%100000,%010000,%001000,%000100,%000000 ; $3C <
        FCB %000000,%000000,%111110,%000000,%111110,%000000,%000000,%000000 ; $3D =
        FCB %010000,%001000,%000100,%000010,%000100,%001000,%010000,%000000 ; $3E >
        FCB %011100,%100010,%000010,%000100,%001000,%000000,%001000,%000000 ; $3F ?
        FCB %011100,%100010,%101110,%101010,%101110,%100000,%011100,%000000 ; $40 @
        FCB %011100,%100010,%100010,%111110,%100010,%100010,%100010,%000000 ; $41 A
        FCB %111100,%100010,%100010,%111100,%100010,%100010,%111100,%000000 ; $42 B
        FCB %011100,%100010,%100000,%100000,%100000,%100010,%011100,%000000 ; $43 C
        FCB %111100,%100010,%100010,%100010,%100010,%100010,%111100,%000000 ; $44 D
        FCB %111110,%100000,%100000,%111100,%100000,%100000,%111110,%000000 ; $45 E
        FCB %111110,%100000,%100000,%111100,%100000,%100000,%100000,%000000 ; $46 F
        FCB %011100,%100010,%100000,%101110,%100010,%100010,%011100,%000000 ; $47 G
        FCB %100010,%100010,%100010,%111110,%100010,%100010,%100010,%000000 ; $48 H
        FCB %011100,%001000,%001000,%001000,%001000,%001000,%011100,%000000 ; $49 I
        FCB %001110,%000100,%000100,%000100,%000100,%100100,%011000,%000000 ; $4A J
        FCB %100010,%100100,%101000,%110000,%101000,%100100,%100010,%000000 ; $4B K
        FCB %100000,%100000,%100000,%100000,%100000,%100000,%111110,%000000 ; $4C L
        FCB %100010,%110110,%101010,%101010,%100010,%100010,%100010,%000000 ; $4D M
        FCB %100010,%110010,%101010,%100110,%100010,%100010,%100010,%000000 ; $4E N
        FCB %011100,%100010,%100010,%100010,%100010,%100010,%011100,%000000 ; $4F O
        FCB %111100,%100010,%100010,%111100,%100000,%100000,%100000,%000000 ; $50 P
        FCB %011100,%100010,%100010,%100010,%101010,%100100,%011010,%000000 ; $51 Q
        FCB %111100,%100010,%100010,%111100,%101000,%100100,%100010,%000000 ; $52 R
        FCB %011110,%100000,%100000,%011100,%000010,%000010,%111100,%000000 ; $53 S
        FCB %111110,%001000,%001000,%001000,%001000,%001000,%001000,%000000 ; $54 T
        FCB %100010,%100010,%100010,%100010,%100010,%100010,%011100,%000000 ; $55 U
        FCB %100010,%100010,%100010,%100010,%100010,%010100,%001000,%000000 ; $56 V
        FCB %100010,%100010,%100010,%101010,%101010,%110110,%100010,%000000 ; $57 W
        FCB %100010,%100010,%010100,%001000,%010100,%100010,%100010,%000000 ; $58 X
        FCB %100010,%100010,%010100,%001000,%001000,%001000,%001000,%000000 ; $59 Y
        FCB %111110,%000010,%000100,%001000,%010000,%100000,%111110,%000000 ; $5A Z
        FCB %011100,%010000,%010000,%010000,%010000,%010000,%011100,%000000 ; $5B [
        FCB %100000,%100000,%010000,%001000,%000100,%000010,%000010,%000000 ; $5C \
        FCB %011100,%000100,%000100,%000100,%000100,%000100,%011100,%000000 ; $5D ]
        FCB %001000,%010100,%100010,%000000,%000000,%000000,%000000,%000000 ; $5E ^
        FCB %000000,%000000,%000000,%000000,%000000,%000000,%111110,%000000 ; $5F _
        FCB %010000,%001000,%000100,%000000,%000000,%000000,%000000,%000000 ; $60 `
        FCB %000000,%000000,%011100,%000010,%011110,%100010,%011110,%000000 ; $61 a
        FCB %100000,%100000,%101100,%110010,%100010,%100010,%111100,%000000 ; $62 b
        FCB %000000,%000000,%011100,%100010,%100000,%100010,%011100,%000000 ; $63 c
        FCB %000010,%000010,%011010,%100110,%100010,%100010,%011110,%000000 ; $64 d
        FCB %000000,%000000,%011100,%100010,%111110,%100000,%011100,%000000 ; $65 e
        FCB %001100,%010010,%010000,%111000,%010000,%010000,%010000,%000000 ; $66 f
        FCB %000000,%000000,%011110,%100010,%100010,%011110,%000010,%011100 ; $67 g
        FCB %100000,%100000,%101100,%110010,%100010,%100010,%100010,%000000 ; $68 h
        FCB %001000,%000000,%011000,%001000,%001000,%001000,%011100,%000000 ; $69 i
        FCB %000100,%000000,%001100,%000100,%000100,%000100,%100100,%011000 ; $6A j
        FCB %100000,%100000,%100100,%101000,%110000,%101000,%100100,%000000 ; $6B k
        FCB %011000,%001000,%001000,%001000,%001000,%001000,%011100,%000000 ; $6C l
        FCB %000000,%000000,%110100,%101010,%101010,%101010,%101010,%000000 ; $6D m
        FCB %000000,%000000,%101100,%110010,%100010,%100010,%100010,%000000 ; $6E n
        FCB %000000,%000000,%011100,%100010,%100010,%100010,%011100,%000000 ; $6F o
        FCB %000000,%000000,%111100,%100010,%100010,%111100,%100000,%100000 ; $70 p
        FCB %000000,%000000,%011010,%100110,%100010,%011110,%000010,%000010 ; $71 q
        FCB %000000,%000000,%101100,%110010,%100000,%100000,%100000,%000000 ; $72 r
        FCB %000000,%000000,%011110,%100000,%011100,%000010,%111100,%000000 ; $73 s
        FCB %010000,%010000,%111000,%010000,%010000,%010010,%001100,%000000 ; $74 t
        FCB %000000,%000000,%100010,%100010,%100010,%100110,%011010,%000000 ; $75 u
        FCB %000000,%000000,%100010,%100010,%100010,%010100,%001000,%000000 ; $76 v
        FCB %000000,%000000,%100010,%101010,%101010,%101010,%010100,%000000 ; $77 w
        FCB %000000,%000000,%100010,%010100,%001000,%010100,%100010,%000000 ; $78 x
        FCB %000000,%000000,%100010,%100010,%100010,%011110,%000010,%011100 ; $79 y
        FCB %000000,%000000,%111110,%000100,%001000,%010000,%111110,%000000 ; $7A z
        FCB %000100,%001000,%001000,%010000,%001000,%001000,%000100,%000000 ; $7B {
        FCB %001000,%001000,%001000,%000000,%001000,%001000,%001000,%000000 ; $7C |
        FCB %010000,%001000,%001000,%000100,%001000,%001000,%010000,%000000 ; $7D }
        FCB %000000,%010100,%101010,%000000,%000000,%000000,%000000,%000000 ; $7E ~
        FCB %000000,%000000,%000000,%000000,%000000,%000000,%000000,%000000 ; $7F DEL


