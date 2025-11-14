; Font Name: Arcade
; Description: Bold font similar text to classic 80's arcade characters
;              Bold font, cuts down on CoCo artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     8
CharJumpTable_HIG112:
        FDB     Character_Blank         ; $20
        FDB     Character_Exclamation   ; $21 !
        FDB     Character_Quote         ; $22 "
        FDB     Character_Blank         ; $23 #
        FDB     Character_Blank         ; $24 $
        FDB     Character_Blank         ; $25 %
        FDB     Character_Blank         ; $26 &
        FDB     Character_Blank         ; $27 '
        FDB     Character_Blank         ; $28 (
        FDB     Character_Blank         ; $29 )
        FDB     Character_Asterisk      ; $2A *
        FDB     Character_Blank         ; $2B +
        FDB     Character_Blank         ; $2C ,
        FDB     Character_Hyphen        ; $2D -
        FDB     Character_Blank         ; $2E .
        FDB     Character_Slash         ; $2F /
        FDB     Character_0             ; $30 0
        FDB     Character_1             ; $31 1
        FDB     Character_2             ; $32 2
        FDB     Character_3             ; $33 3
        FDB     Character_4             ; $34 4
        FDB     Character_5             ; $35 5
        FDB     Character_6             ; $36 6
        FDB     Character_7             ; $37 7
        FDB     Character_8             ; $38 8
        FDB     Character_9             ; $39 9
        FDB     Character_Colon         ; $3A :
        FDB     Character_Blank         ; $3B ;
        FDB     Character_Less          ; $3C <
        FDB     Character_Equal         ; $3D =
        FDB     Character_Great         ; $3E >
        FDB     Character_Blank         ; $3F ?
        FDB     Character_Blank         ; $40 @
        FDB     Character_A             ; $41 A
        FDB     Character_B             ; $42 B
        FDB     Character_C             ; $43 C
        FDB     Character_D             ; $44 D
        FDB     Character_E             ; $45 E
        FDB     Character_F             ; $46 F
        FDB     Character_G             ; $47 G
        FDB     Character_H             ; $48 H
        FDB     Character_I             ; $49 I
        FDB     Character_J             ; $4A J
        FDB     Character_K             ; $4B K
        FDB     Character_L             ; $4C L
        FDB     Character_M             ; $4D M
        FDB     Character_N             ; $4E N
        FDB     Character_O             ; $4F O
        FDB     Character_P             ; $50 P
        FDB     Character_Q             ; $51 Q
        FDB     Character_R             ; $52 R
        FDB     Character_S             ; $53 S
        FDB     Character_T             ; $54 T
        FDB     Character_U             ; $55 U
        FDB     Character_V             ; $56 V
        FDB     Character_W             ; $57 W
        FDB     Character_X             ; $58 X
        FDB     Character_Y             ; $59 Y
        FDB     Character_Z             ; $5A Z
        FDB     Character_Blank         ; $5B [
        FDB     Character_Blank         ; $5C \
        FDB     Character_Blank         ; $5D ]
        FDB     Character_Blank         ; $5E
        FDB     Character_Blank         ; $5F _
        FDB     Character_Blank         ; $60 `
        FDB     Character_A             ; $61 a
        FDB     Character_B             ; $62 b
        FDB     Character_C             ; $63 c
        FDB     Character_D             ; $64 d
        FDB     Character_E             ; $65 e
        FDB     Character_F             ; $66 f
        FDB     Character_G             ; $67 g
        FDB     Character_H             ; $68 h
        FDB     Character_I             ; $69 i
        FDB     Character_J             ; $6A j
        FDB     Character_K             ; $6B k
        FDB     Character_L             ; $6C l
        FDB     Character_M             ; $6D m
        FDB     Character_N             ; $6E n
        FDB     Character_O             ; $6F o
        FDB     Character_P             ; $70 p
        FDB     Character_Q             ; $71 q
        FDB     Character_R             ; $72 r
        FDB     Character_S             ; $73 s
        FDB     Character_T             ; $74 t
        FDB     Character_U             ; $75 u
        FDB     Character_V             ; $76 v
        FDB     Character_W             ; $77 w
        FDB     Character_X             ; $78 x
        FDB     Character_Y             ; $79 y
        FDB     Character_Z             ; $7A z
        FDB     Character_Blank         ; $7B {
        FDB     Character_Blank         ; $7C
        FDB     Character_Blank         ; $7D }
        FDB     Character_Blank         ; $7E ~
        FDB     Character_Blank         ; $7F DEL
; Table end
; **************************************
;  Blank
;0 00000000
;1 00000000
;2 00000000
;3 00000000
;4 00000000
;5 00000000
;6 00000000
;7 00000000
Character_Blank:
        CLRA
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  !
;0 00000000
;1 00001110
;2 00001110
;3 00011100
;4 00011000
;5 00010000
;6 00000000
;7 00100000
Character_Exclamation:
        CLRA
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00001110
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00011100
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00011000
        STA     ,U                     * 4
        LDA     #%00010000
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00100000
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  "
;0 00000000
;1 00110110
;2 00110110
;3 00010010
;4 00100100
;5 00000000
;6 00000000
;7 00000000
Character_Quote:
        CLRA
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00110110
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00010010
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00100100
        STA     ,U                     * 4
        RTS
; **************************************
;  *
;0 00000000
;1 00010000
;2 01010100
;3 00111000
;4 00010000
;5 00111000
;6 01010100
;7 00010000
Character_Asterisk:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00010000
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01010100
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111000
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        RTS
; **************************************
;  Hyphen
;0 00000000
;1 00000000
;2 00000000
;3 00000000
;4 00111100
;5 00000000
;6 00000000
;7 00000000
Character_Hyphen:
        CLRA
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00111100
        STA     ,U                     * 4
        RTS
; **************************************
;  Slash
;0 00000000
;1 00000001
;2 00000010
;3 00000100
;4 00001000
;5 00010000
;6 00100000
;7 01000000
Character_Slash:
        CLRA
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00000001
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%00000010
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00000100
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00001000
        STA     ,U                     * 4
        LDA     #%00010000
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00100000
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%01000000
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  0
;0 00000000
;1 00011100
;2 00100110
;3 01100011
;4 01100011
;5 01100011
;6 00110010
;7 00011100
Character_0:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00011100
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%00100110
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01100011
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00110010
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00011100
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  1
;0 00000000
;1 00001100
;2 00011100
;3 00001100
;4 00001100
;5 00001100
;6 00001100
;7 00111111
Character_1:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00001100
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00011100
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00111111
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  2
;0 00000000
;1 00111110
;2 01100011
;3 00000111
;4 00011110
;5 00111100
;6 01110000
;7 01111111
Character_2:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111110
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00000111
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00011110
        STA     ,U                     * 4
        LDA     #%00111100
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01110000
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%01111111
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  3
;0 00000000
;1 00111111
;2 00000110
;3 00001100
;4 00011110
;5 00000011
;6 01100011
;7 00111110
Character_3:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111111
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%00000110
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00001100
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00011110
        STA     ,U                     * 4
        LDA     #%00000011
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01100011
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111110
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  4
;0 00000000
;1 00001110
;2 00011110
;3 00110110
;4 01100110
;5 01111111
;6 00000110
;7 00000110
Character_4:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00001110
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%00011110
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00110110
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01100110
        STA     ,U                     * 4
        LDA     #%01111111
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00000110
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  5
;0 00000000
;1 01111110
;2 01100000
;3 01111110
;4 00000011
;5 00000011
;6 01100011
;7 00111110
Character_5:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01111110
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100000
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01111110
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00000011
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01100011
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111110
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  6
;0 00000000
;1 00011110
;2 00110000
;3 01100000
;4 01111110
;5 01100011
;6 01100011
;7 00111110
Character_6:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00011110
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%00110000
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01100000
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01111110
        STA     ,U                     * 4
        LDA     #%01100011
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111110
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  7
;0 00000000
;1 01111111
;2 01100011
;3 00000110
;4 00001100
;5 00011000
;6 00011000
;7 00011000
Character_7:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01111111
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00000110
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00001100
        STA     ,U                     * 4
        LDA     #%00011000
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  8
;0 00000000
;1 00111100
;2 01100010
;3 01110010
;4 00111100
;5 01001111
;6 01000011
;7 00111110
Character_8:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111100
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     ,U                     * 4
        LDA     #%01100010
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01110010
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01001111
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01000011
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111110
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  9
;0 00000000
;1 00111110
;2 01100011
;3 01100011
;4 00111111
;5 00000011
;6 00000110
;7 00111100
Character_9:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111110
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00111111
        STA     ,U                     * 4
        LDA     #%00000011
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00000110
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111100
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  :
;0 00000000
;1 00000000
;2 00011000
;3 00011000
;4 00000000
;5 00011000
;6 00011000
;7 00000000
Character_Colon:
        CLRA
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00011000
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        RTS
; **************************************
;  <
;0 00000000
;1 00001000
;2 00010000
;3 00100000
;4 01000000
;5 00100000
;6 00010000
;7 00001000
Character_Less:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00001000
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00010000
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00100000
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01000000
        STA     ,U                     * 4
        RTS
; **************************************
;  =
;0 00000000
;1 00000000
;2 00000000
;3 01111100
;4 00000000
;5 01111100
;6 00000000
;7 00000000
Character_Equal:
        CLRA
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01111100
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        RTS
; **************************************
;  >
;0 00000000
;1 00100000
;2 00010000
;3 00001000
;4 00000100
;5 00001000
;6 00010000
;7 00100000
Character_Great:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00100000
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00010000
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00001000
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00000100
        STA     ,U                     * 4
        RTS
; **************************************
;  A
;0 00000000
;1 00011100
;2 00110110
;3 01100011
;4 01100011
;5 01111111
;6 01100011
;7 01100011
Character_A:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00011100
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%00110110
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01100011
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01111111
        STA     BytesPerRow_HIG112,U     * 5
        RTS
; **************************************
;  B
;0 00000000
;1 01111110
;2 01100011
;3 01100011
;4 01111110
;5 01100011
;6 01100011
;7 01111110
Character_B:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01111110
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        RTS
; **************************************
;  C
;0 00000000
;1 00011110
;2 00110011
;3 01100000
;4 01100000
;5 01100000
;6 00110011
;7 00011110
Character_C:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00011110
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00110011
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%01100000
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        RTS
; **************************************
;  D
;0 00000000
;1 01111100
;2 01100110
;3 01100011
;4 01100011
;5 01100011
;6 01100110
;7 01111100
Character_D:
        CLR     ,U  * 0   
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01111100
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01100110
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%01100011
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        RTS
; **************************************
;  E
;0 00000000
;1 00111111
;2 00110000
;3 00110000
;4 00111110
;5 00110000
;6 00110000
;7 00111111
Character_E:
        CLR     ,U  * 0   
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111111
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00110000
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111110
        STA     ,U                     * 4
        RTS
; **************************************
;  F
;0 00000000
;1 01111111
;2 01100000
;3 01100000
;4 01111110
;5 01100000
;6 01100000
;7 01100000
Character_F:
        CLR     ,U  * 0   
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01111111
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100000
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01111110
        STA     ,U                     * 4
        RTS
; **************************************
;  G
;0 00000000
;1 00011111
;2 00110000
;3 01100000
;4 01100111
;5 01100011
;6 00110011
;7 00011111
Character_G:
        CLR     ,U  * 0   
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00011111
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00110000
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01100000
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01100111
        STA     ,U                     * 4
        LDA     #%01100011
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00110011
        STA     BytesPerRow_HIG112*2,U   * 6
        RTS
; **************************************
;  H
;0 00000000
;1 01100011
;2 01100011
;3 01100011
;4 01111111
;5 01100011
;6 01100011
;7 01100011
Character_H:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01111111
        STA     ,U                     * 4
        RTS
; **************************************
;  I
;0 00000000
;1 00111111
;2 00001100
;3 00001100
;4 00001100
;5 00001100
;6 00001100
;7 00111111
Character_I:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111111
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00001100
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        RTS
; **************************************
;  J
;0 00000000
;1 00000011
;2 00000011
;3 00000011
;4 00000011
;5 00000011
;6 01100011
;7 00111110
Character_J:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00000011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01100011
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111110
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  K
;0 00000000
;1 01100011
;2 01100110
;3 01101100
;4 01111000
;5 01111100
;6 01101110
;7 01100111
Character_K:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100110
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01101100
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01111000
        STA     ,U                     * 4
        LDA     #%01111100
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01101110
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%01100111
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  L
;0 00000000
;1 00110000
;2 00110000
;3 00110000
;4 00110000
;5 00110000
;6 00110000
;7 00111111
Character_L:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00110000
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111111
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  M
;0 00000000
;1 01100011
;2 01110111
;3 01111111
;4 01111111
;5 01101011
;6 01100011
;7 01100011
Character_M:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01110111
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01111111
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        LDA     #%01101011
        STA     BytesPerRow_HIG112,U     * 5
        RTS
; **************************************
;  N
;0 00000000
;1 01100011
;2 01110011
;3 01111011
;4 01111111
;5 01101111
;6 01100111
;7 01100011
Character_N:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01110011
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01111011
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01111111
        STA     ,U                     * 4
        LDA     #%01101111
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01100111
        STA     BytesPerRow_HIG112*2,U   * 6
        RTS
; **************************************
;  O
;0 00000000
;1 00111110
;2 01100011
;3 01100011
;4 01100011
;5 01100011
;6 01100011
;7 00111110
Character_O:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111110
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        RTS
; **************************************
;  P
;0 00000000
;1 01111110
;2 01100011
;3 01100011
;4 01100011
;5 01111110
;6 01100000
;7 01100000
Character_P:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01111110
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        LDA     #%01100000
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  Q
;0 00000000
;1 00111110
;2 01100011
;3 01100011
;4 01100011
;5 01101111
;6 01100110
;7 00111101
Character_Q:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111110
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        LDA     #%01101111
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01100110
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111101
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  R
;0 00000000
;1 01111110
;2 01100011
;3 01100011
;4 01100111
;5 01111100
;6 01101110
;7 01100111
Character_R:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01111110
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01100111
        STA     ,U                     * 4
        LDA     #%01111100
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01101110
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%01100111
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  S
;0 00000000
;1 00111100
;2 01100110
;3 01100000
;4 00111110
;5 00000011
;6 01100011
;7 00111110
Character_S:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111100
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%01100110
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%01100000
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00111110
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00000011
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01100011
        STA     BytesPerRow_HIG112*2,U   * 6
        RTS
; **************************************
;  T
;0 00000000
;1 00111111
;2 00001100
;3 00001100
;4 00001100
;5 00001100
;6 00001100
;7 00001100
Character_T:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00111111
        STA     -BytesPerRow_HIG112*3,U  * 1
        LDA     #%00001100
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  U
;0 00000000
;1 01100011
;2 01100011
;3 01100011
;4 01100011
;5 01100011
;6 01100011
;7 00111110
Character_U:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111110
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  V
;0 00000000
;1 01100011
;2 01100011
;3 01100011
;4 01110111
;5 00111110
;6 00011100
;7 00001000
Character_V:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01110111
        STA     ,U                     * 4
        LDA     #%00111110
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00011100
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00001000
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  W
;0 00000000
;1 01100011
;2 01100011
;3 01101011
;4 01111111
;5 01111111
;6 01110111
;7 01100011
Character_W:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%01111111
        STA     ,U                     * 4
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01110111
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%01100011
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  X
;0 00000000
;1 01100011
;2 01110111
;3 00111110
;4 00011100
;5 00111110
;6 01110111
;7 01100011
Character_X:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01100011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%01110111
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     BytesPerRow_HIG112*2,U   * 6
        LDA     #%00111110
        STA     -BytesPerRow_HIG112,U    * 3
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%00011100
        STA     ,U                     * 4
        RTS
; **************************************
;  Y
;0 00000000
;1 00110011
;2 00110011
;3 00110011
;4 00011110
;5 00001100
;6 00001100
;7 00001100
Character_Y:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%00110011
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     -BytesPerRow_HIG112*2,U  * 2
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00011110
        STA     ,U                     * 4
        LDA     #%00001100
        STA     BytesPerRow_HIG112,U     * 5
        STA     BytesPerRow_HIG112*2,U   * 6
        STA     BytesPerRow_HIG112*3,U   * 7
        RTS
; **************************************
;  Z
;0 00000000
;1 01111111
;2 00000111
;3 00001110
;4 00011100
;5 00111000
;6 01110000
;7 01111111
Character_Z:
        CLR     ,U                     * 0
        LEAU    BytesPerRow_HIG112*4,U
        LDA     #%01111111
        STA     -BytesPerRow_HIG112*3,U  * 1
        STA     BytesPerRow_HIG112*3,U   * 7
        LDA     #%00000111
        STA     -BytesPerRow_HIG112*2,U  * 2
        LDA     #%00001110
        STA     -BytesPerRow_HIG112,U    * 3
        LDA     #%00011100
        STA     ,U                     * 4
        LDA     #%00111000
        STA     BytesPerRow_HIG112,U     * 5
        LDA     #%01110000
        STA     BytesPerRow_HIG112*2,U   * 6
        RTS
