; Font Name: Arcade
; Description: Bold font similar text to classic 80's arcade characters
;              Bold font, cuts down on CoCo artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     8
CharJumpTable_HIG155:
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
; Blank
;0 11111111
;1 11111111
;2 11111111
;3 11111111
;4 11111111
;5 11111111
;6 11111111
;7 11111111
Character_Blank:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; !
;0 11111111
;1 11110001
;2 11110001
;3 11100011
;4 11100111
;5 11101111
;6 11111111
;7 11011111
Character_Exclamation:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11110001
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11100011
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11100111
        STA     ,U                     * 4
        LDA     #%11101111
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11011111
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; "
;0 11111111
;1 11001001
;2 11001001
;3 11101101
;4 11011011
;5 11111111
;6 11111111
;7 11111111
Character_Quote:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11001001
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11101101
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11011011
        STA     ,U                     * 4
        RTS
; **************************************
; *
;0 11111111
;1 11101111
;2 10101011
;3 11000111
;4 11101111
;5 11000111
;6 10101011
;7 11101111
Character_Asterisk:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11101111
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10101011
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000111
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        RTS
; **************************************
; Hyphen
;0 11111111
;1 11111111
;2 11111111
;3 11111111
;4 11000011
;5 11111111
;6 11111111
;7 11111111
Character_Hyphen:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11000011
        STA     ,U                     * 4
        RTS
; **************************************
; Slash
;0 11111111
;1 11111110
;2 11111101
;3 11111011
;4 11110111
;5 11101111
;6 11011111
;7 10111111
Character_Slash:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11111110
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%11111101
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11111011
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11110111
        STA     ,U                     * 4
        LDA     #%11101111
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11011111
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%10111111
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 0
;0 11111111
;1 11100011
;2 11011001
;3 10011100
;4 10011100
;5 10011100
;6 11001101
;7 11100011
Character_0:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11100011
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%11011001
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10011100
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11001101
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11100011
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 1
;0 11111111
;1 11110011
;2 11100011
;3 11110011
;4 11110011
;5 11110011
;6 11110011
;7 11000000
Character_1:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11110011
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11100011
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11000000
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 2
;0 11111111
;1 11000001
;2 10011100
;3 11111000
;4 11100001
;5 11000011
;6 10001111
;7 10000000
Character_2:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000001
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11111000
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11100001
        STA     ,U                     * 4
        LDA     #%11000011
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10001111
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%10000000
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 3
;0 11111111
;1 11000000
;2 11111001
;3 11110011
;4 11100001
;5 11111100
;6 10011100
;7 11000001
Character_3:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000000
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%11111001
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11110011
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11100001
        STA     ,U                     * 4
        LDA     #%11111100
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10011100
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000001
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 4
;0 11111111
;1 11110001
;2 11100001
;3 11001001
;4 10011001
;5 10000000
;6 11111001
;7 11111001
Character_4:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11110001
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%11100001
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11001001
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10011001
        STA     ,U                     * 4
        LDA     #%10000000
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11111001
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 5
;0 11111111
;1 10000001
;2 10011111
;3 10000001
;4 11111100
;5 11111100
;6 10011100
;7 11000001
Character_5:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10000001
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011111
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10000001
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11111100
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10011100
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000001
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 6
;0 11111111
;1 11100001
;2 11001111
;3 10011111
;4 10000001
;5 10011100
;6 10011100
;7 11000001
Character_6:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11100001
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%11001111
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10011111
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10000001
        STA     ,U                     * 4
        LDA     #%10011100
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000001
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 7
;0 11111111
;1 10000000
;2 10011100
;3 11111001
;4 11110011
;5 11100111
;6 11100111
;7 11100111
Character_7:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10000000
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11111001
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11110011
        STA     ,U                     * 4
        LDA     #%11100111
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 8
;0 11111111
;1 11000011
;2 10011101
;3 10001101
;4 11000011
;5 10110000
;6 10111100
;7 11000001
Character_8:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000011
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     ,U                     * 4
        LDA     #%10011101
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10001101
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10110000
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10111100
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000001
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; 9
;0 11111111
;1 11000001
;2 10011100
;3 10011100
;4 11000000
;5 11111100
;6 11111001
;7 11000011
Character_9:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000001
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11000000
        STA     ,U                     * 4
        LDA     #%11111100
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11111001
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000011
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; :
;0 11111111
;1 11111111
;2 11100111
;3 11100111
;4 11111111
;5 11100111
;6 11100111
;7 11111111
Character_Colon:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11100111
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        RTS
; **************************************
; <
;0 11111111
;1 11110111
;2 11101111
;3 11011111
;4 10111111
;5 11011111
;6 11101111
;7 11110111
Character_Less:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11110111
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11101111
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11011111
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10111111
        STA     ,U                     * 4
        RTS
; **************************************
; =
;0 11111111
;1 11111111
;2 11111111
;3 10000011
;4 11111111
;5 10000011
;6 11111111
;7 11111111
Character_Equal:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10000011
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        RTS
; **************************************
; >
;0 11111111
;1 11011111
;2 11101111
;3 11110111
;4 11111011
;5 11110111
;6 11101111
;7 11011111
Character_Great:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11011111
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11101111
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11110111
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11111011
        STA     ,U                     * 4
        RTS
; **************************************
; A
;0 11111111
;1 11100011
;2 11001001
;3 10011100
;4 10011100
;5 10000000
;6 10011100
;7 10011100
Character_A:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11100011
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%11001001
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10011100
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10000000
        STA     BytesPerRow_HIG155,U     * 5
        RTS
; **************************************
; B
;0 11111111
;1 10000001
;2 10011100
;3 10011100
;4 10000001
;5 10011100
;6 10011100
;7 10000001
Character_B:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10000001
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        RTS
; **************************************
; C
;0 11111111
;1 11100001
;2 11001100
;3 10011111
;4 10011111
;5 10011111
;6 11001100
;7 11100001
Character_C:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11100001
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11001100
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%10011111
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        RTS
; **************************************
; D
;0 11111111
;1 10000011
;2 10011001
;3 10011100
;4 10011100
;5 10011100
;6 10011001
;7 10000011
Character_D:
        LDA     #%11111111
        STA     ,U  * 0   
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10000011
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10011001
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%10011100
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        RTS
; **************************************
; E
;0 11111111
;1 11000000
;2 11001111
;3 11001111
;4 11000001
;5 11001111
;6 11001111
;7 11000000
Character_E:
        LDA     #%11111111
        STA     ,U  * 0   
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000000
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11001111
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000001
        STA     ,U                     * 4
        RTS
; **************************************
; F
;0 11111111
;1 10000000
;2 10011111
;3 10011111
;4 10000001
;5 10011111
;6 10011111
;7 10011111
Character_F:
        LDA     #%11111111
        STA     ,U  * 0   
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10000000
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011111
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10000001
        STA     ,U                     * 4
        RTS
; **************************************
; G
;0 11111111
;1 11100000
;2 11001111
;3 10011111
;4 10011000
;5 10011100
;6 11001100
;7 11100000
Character_G:
        LDA     #%11111111
        STA     ,U  * 0   
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11100000
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11001111
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10011111
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10011000
        STA     ,U                     * 4
        LDA     #%10011100
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11001100
        STA     BytesPerRow_HIG155*2,U   * 6
        RTS
; **************************************
; H
;0 11111111
;1 10011100
;2 10011100
;3 10011100
;4 10000000
;5 10011100
;6 10011100
;7 10011100
Character_H:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10000000
        STA     ,U                     * 4
        RTS
; **************************************
; I
;0 11111111
;1 11000000
;2 11110011
;3 11110011
;4 11110011
;5 11110011
;6 11110011
;7 11000000
Character_I:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000000
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11110011
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        RTS
; **************************************
; J
;0 11111111
;1 11111100
;2 11111100
;3 11111100
;4 11111100
;5 11111100
;6 10011100
;7 11000001
Character_J:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11111100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10011100
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000001
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; K
;0 11111111
;1 10011100
;2 10011001
;3 10010011
;4 10000111
;5 10000011
;6 10010001
;7 10011000
Character_K:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011001
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10010011
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10000111
        STA     ,U                     * 4
        LDA     #%10000011
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10010001
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%10011000
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; L
;0 11111111
;1 11001111
;2 11001111
;3 11001111
;4 11001111
;5 11001111
;6 11001111
;7 11000000
Character_L:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11001111
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000000
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; M
;0 11111111
;1 10011100
;2 10001000
;3 10000000
;4 10000000
;5 10010100
;6 10011100
;7 10011100
Character_M:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10001000
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10000000
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        LDA     #%10010100
        STA     BytesPerRow_HIG155,U     * 5
        RTS
; **************************************
; N
;0 11111111
;1 10011100
;2 10001100
;3 10000100
;4 10000000
;5 10010000
;6 10011000
;7 10011100
Character_N:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10001100
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10000100
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10000000
        STA     ,U                     * 4
        LDA     #%10010000
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10011000
        STA     BytesPerRow_HIG155*2,U   * 6
        RTS
; **************************************
; O
;0 11111111
;1 11000001
;2 10011100
;3 10011100
;4 10011100
;5 10011100
;6 10011100
;7 11000001
Character_O:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000001
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        RTS
; **************************************
; P
;0 11111111
;1 10000001
;2 10011100
;3 10011100
;4 10011100
;5 10000001
;6 10011111
;7 10011111
Character_P:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10000001
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        LDA     #%10011111
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; Q
;0 11111111
;1 11000001
;2 10011100
;3 10011100
;4 10011100
;5 10010000
;6 10011001
;7 11000010
Character_Q:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000001
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        LDA     #%10010000
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10011001
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000010
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; R
;0 11111111
;1 10000001
;2 10011100
;3 10011100
;4 10011000
;5 10000011
;6 10010001
;7 10011000
Character_R:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10000001
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10011000
        STA     ,U                     * 4
        LDA     #%10000011
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10010001
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%10011000
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; S
;0 11111111
;1 11000011
;2 10011001
;3 10011111
;4 11000001
;5 11111100
;6 10011100
;7 11000001
Character_S:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000011
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%10011001
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%10011111
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11000001
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11111100
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10011100
        STA     BytesPerRow_HIG155*2,U   * 6
        RTS
; **************************************
; T
;0 11111111
;1 11000000
;2 11110011
;3 11110011
;4 11110011
;5 11110011
;6 11110011
;7 11110011
Character_T:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11000000
        STA     -BytesPerRow_HIG155*3,U  * 1
        LDA     #%11110011
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; U
;0 11111111
;1 10011100
;2 10011100
;3 10011100
;4 10011100
;5 10011100
;6 10011100
;7 11000001
Character_U:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000001
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; V
;0 11111111
;1 10011100
;2 10011100
;3 10011100
;4 10001000
;5 11000001
;6 11100011
;7 11110111
Character_V:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10001000
        STA     ,U                     * 4
        LDA     #%11000001
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11100011
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11110111
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; W
;0 11111111
;1 10011100
;2 10011100
;3 10010100
;4 10000000
;5 10000000
;6 10001000
;7 10011100
Character_W:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%10000000
        STA     ,U                     * 4
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10001000
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%10011100
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; X
;0 11111111
;1 10011100
;2 10001000
;3 11000001
;4 11100011
;5 11000001
;6 10001000
;7 10011100
Character_X:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10011100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%10001000
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     BytesPerRow_HIG155*2,U   * 6
        LDA     #%11000001
        STA     -BytesPerRow_HIG155,U.   * 3
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%11100011
        STA     ,U                     * 4
        RTS
; **************************************
; Y
;0 11111111
;1 11001100
;2 11001100
;3 11001100
;4 11100001
;5 11110011
;6 11110011
;7 11110011
Character_Y:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%11001100
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     -BytesPerRow_HIG155*2,U  * 2
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11100001
        STA     ,U                     * 4
        LDA     #%11110011
        STA     BytesPerRow_HIG155,U     * 5
        STA     BytesPerRow_HIG155*2,U   * 6
        STA     BytesPerRow_HIG155*3,U   * 7
        RTS
; **************************************
; Z
;0 11111111
;1 10000000
;2 11111000
;3 11110001
;4 11100011
;5 11000111
;6 10001111
;7 10000000
Character_Z:
        LDA     #%11111111
        STA     ,U                     * 0
        LEAU    BytesPerRow_HIG155*4,U
        LDA     #%10000000
        STA     -BytesPerRow_HIG155*3,U  * 1
        STA     BytesPerRow_HIG155*3,U   * 7
        LDA     #%11111000
        STA     -BytesPerRow_HIG155*2,U  * 2
        LDA     #%11110001
        STA     -BytesPerRow_HIG155,U.   * 3
        LDA     #%11100011
        STA     ,U                     * 4
        LDA     #%11000111
        STA     BytesPerRow_HIG155,U     * 5
        LDA     #%10001111
        STA     BytesPerRow_HIG155*2,U   * 6
        RTS
