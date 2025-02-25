; Font Name: CoCoT1
; Description: Pixel match of the Motorola MC6847T1 VDG chip
;              Matches the font of newer CoCo 2's
;              Since the pixels are single dots, this font will produce artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     10
CharJumpTable_HIG156:
        FDB     Character_Blank         ; $20
        FDB     Character_Exclamation   ; $21 !
        FDB     Character_Quote         ; $22 "
        FDB     Character_Pound         ; $23 #
        FDB     Character_DollarSign    ; $24 $
        FDB     Character_Percent       ; $25 %
        FDB     Character_Ampersand     ; $26 &
        FDB     Character_Apostrophe    ; $27 '
        FDB     Character_OpenBracket   ; $28 (
        FDB     Character_CloseBracket  ; $29 )
        FDB     Character_Asterisk      ; $2A *
        FDB     Character_Plus          ; $2B +
        FDB     Character_Comma         ; $2C ,
        FDB     Character_Hyphen        ; $2D -
        FDB     Character_Decimal       ; $2E .
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
        FDB     Character_Semicolon     ; $3B ;
        FDB     Character_Less          ; $3C <
        FDB     Character_Equal         ; $3D =
        FDB     Character_Great         ; $3E >
        FDB     Character_QuestionMark  ; $3F ?
        FDB     Character_AtSign        ; $40 @
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
        FDB     Character_OpenSBracket  ; $5B [
        FDB     Character_Backslash     ; $5C \
        FDB     Character_CloseSBracket ; $5D ]
        FDB     Character_Caret         ; $5E ^
        FDB     Character_Underscore    ; $5F _
        FDB     Character_Backtick      ; $60 `
        FDB     Character_a             ; $61 a
        FDB     Character_b             ; $62 b
        FDB     Character_c             ; $63 c
        FDB     Character_d             ; $64 d
        FDB     Character_e             ; $65 e
        FDB     Character_f             ; $66 f
        FDB     Character_g             ; $67 g
        FDB     Character_h             ; $68 h
        FDB     Character_i             ; $69 i
        FDB     Character_j             ; $6A j
        FDB     Character_k             ; $6B k
        FDB     Character_l             ; $6C l
        FDB     Character_m             ; $6D m
        FDB     Character_n             ; $6E n
        FDB     Character_o             ; $6F o
        FDB     Character_p             ; $70 p
        FDB     Character_q             ; $71 q
        FDB     Character_r             ; $72 r
        FDB     Character_s             ; $73 s
        FDB     Character_t             ; $74 t
        FDB     Character_u             ; $75 u
        FDB     Character_v             ; $76 v
        FDB     Character_w             ; $77 w
        FDB     Character_x             ; $78 x
        FDB     Character_y             ; $79 y
        FDB     Character_z             ; $7A z
        FDB     Character_OpenCurlyBracket ; $7B {
        FDB     Character_Pipe          ; $7C |
        FDB     Character_CloseCurlyBracket ; $7D }
        FDB     Character_Tilde         ; $7E ~
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
;8 11111111
;9 11111111
Character_Blank:
        LDA     #%11111111
        STA     ,U                      * 0
        STA     BytesPerRow_HIG156,U      * 1
        STA     BytesPerRow_HIG156*2,U    * 2
        LEAU    BytesPerRow_HIG156*6,U
        STA     -BytesPerRow_HIG156*3,U   * 3
        STA     -BytesPerRow_HIG156*2,U   * 4
        STA     -BytesPerRow_HIG156,U     * 5
        STA     ,U                      * 6
        STA     BytesPerRow_HIG156,U      * 7
        STA     BytesPerRow_HIG156*2,U    * 8
        STA     BytesPerRow_HIG156*3,U    * 9
        RTS
; **************************************
; !
;0 11111111
;1 11110111
;2 11110111
;3 11110111
;4 11110111
;5 11110111
;6 11111111
;7 11110111
;8 11111111
;9 11111111
Character_Exclamation:
        LDA     #%11111111
        STA     ,U                      * 0
        LEAU    BytesPerRow_HIG156*5,U
        STA     BytesPerRow_HIG156,U      * 6
        STA     BytesPerRow_HIG156*3,U    * 8
        STA     BytesPerRow_HIG156*4,U    * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*4,U   * 1
        STA     -BytesPerRow_HIG156*3,U   * 2
        STA     -BytesPerRow_HIG156*2,U   * 3
        STA     -BytesPerRow_HIG156,U     * 4
        STA     ,U                      * 5
        STA     BytesPerRow_HIG156*2,U    * 7
        RTS
; **************************************
; "
;0 11111111
;1 11101011
;2 11101011
;3 11101011
;4 11111111
;5 11111111
;6 11111111
;7 11111111
;8 11111111
;9 11111111
Character_Quote:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11101011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        RTS
; **************************************
; #
;0 11111111
;1 11101011
;2 11101011
;3 11000001
;4 11111111
;5 11000001
;6 11101011
;7 11101011
;8 11111111
;9 11111111
Character_Pound:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11101011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11000001
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; $
;0 11111111
;1 11110111
;2 11100001
;3 11011111
;4 11100011
;5 11111101
;6 11000011
;7 11110111
;8 11111111
;9 11111111
Character_DollarSign:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11100001
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11011111
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11100011
        STA     ,U     * 4      U
        LDA     #%11111101
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11000011
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; %
;0 11111111
;1 11001111
;2 11001101
;3 11111011
;4 11110111
;5 11101111
;6 11011001
;7 11111001
;8 11111111
;9 11111111
Character_Percent:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11001111
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11001101
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11111011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11110111
        STA     ,U     * 4      U
        LDA     #%11101111
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011001
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11111001
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; &
;0 11111111
;1 11101111
;2 11010111
;3 11010111
;4 11101111
;5 11010101
;6 11011011
;7 11100101
;8 11111111
;9 11111111
Character_Ampersand:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11101111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     ,U     * 4      U
        LDA     #%11010111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11010101
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011011
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100101
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; '
;0 11111111
;1 11100111
;2 11100111
;3 11101111
;4 11011111
;5 11111111
;6 11111111
;7 11111111
;8 11111111
;9 11111111
Character_Apostrophe:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11101111
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11011111
        STA     ,U     * 4      U
        RTS
; **************************************
; (
;0 11111111
;1 11111011
;2 11110111
;3 11101111
;4 11101111
;5 11101111
;6 11110111
;7 11111011
;8 11111111
;9 11111111
Character_OpenBracket:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11111011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11101111
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; )
;0 11111111
;1 11101111
;2 11110111
;3 11111011
;4 11111011
;5 11111011
;6 11110111
;7 11101111
;8 11111111
;9 11111111
Character_CloseBracket:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11101111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11111011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; *
;0 11111111
;1 11111111
;2 11110111
;3 11010101
;4 11100011
;5 11100011
;6 11010101
;7 11110111
;8 11111111
;9 11111111
Character_Asterisk:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11010101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100011
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; +
;0 11111111
;1 11111111
;2 11110111
;3 11110111
;4 11000001
;5 11110111
;6 11110111
;7 11111111
;8 11111111
;9 11111111
Character_Plus:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11000001
        STA     ,U     * 4      U
        RTS
; **************************************
; ,
;0 11111111
;1 11111111
;2 11111111
;3 11111111
;4 11100111
;5 11100111
;6 11101111
;7 11011111
;8 11111111
;9 11111111
Character_Comma:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100111
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11101111
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11011111
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; -
;0 11111111
;1 11111111
;2 11111111
;3 11111111
;4 11000001
;5 11111111
;6 11111111
;7 11111111
;8 11111111
;9 11111111
Character_Hyphen:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     ,U     * 4      U
        RTS
; **************************************
; .
;0 11111111
;1 11111111
;2 11111111
;3 11111111
;4 11111111
;5 11111111
;6 11100111
;7 11100111
;8 11111111
;9 11111111
Character_Decimal:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100111
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; /
;0 11111111
;1 11111111
;2 11111101
;3 11111011
;4 11110111
;5 11101111
;6 11011111
;7 11111111
;8 11111111
;9 11111111
Character_Slash:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11111101
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11111011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11110111
        STA     ,U     * 4      U
        LDA     #%11101111
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011111
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; 0
;0 11111111
;1 11100011
;2 11011101
;3 11011001
;4 11010101
;5 11001101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_0:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11011001
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11010101
        STA     ,U     * 4      U
        LDA     #%11001101
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; 1
;0 11111111
;1 11110111
;2 11100111
;3 11110111
;4 11110111
;5 11110111
;6 11110111
;7 11100011
;8 11111111
;9 11111111
Character_1:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100111
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; 2
;0 11111111
;1 11100011
;2 11011101
;3 11111101
;4 11100011
;5 11011111
;6 11011111
;7 11000001
;8 11111111
;9 11111111
Character_2:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     ,U     * 4      U
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11111101
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11011111
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11000001
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; 3
;0 11111111
;1 11100011
;2 11011101
;3 11111101
;4 11110011
;5 11111101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_3:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11111101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11110011
        STA     ,U     * 4      U
        RTS
; **************************************
; 4
;0 11111111
;1 11111011
;2 11110011
;3 11101011
;4 11011011
;5 11000001
;6 11111011
;7 11111011
;8 11111111
;9 11111111
Character_4:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11111011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11110011
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11101011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11011011
        STA     ,U     * 4      U
        LDA     #%11000001
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; 5
;0 11111111
;1 11000001
;2 11011111
;3 11000011
;4 11111101
;5 11111101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_5:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11000011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11111101
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011101
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; 6
;0 11111111
;1 11110011
;2 11101111
;3 11011111
;4 11000011
;5 11011101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_6:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110011
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11101111
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11011111
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11000011
        STA     ,U     * 4      U
        LDA     #%11011101
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; 7
;0 11111111
;1 11000001
;2 11111101
;3 11111011
;4 11110111
;5 11101111
;6 11011111
;7 11011111
;8 11111111
;9 11111111
Character_7:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11111101
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11111011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11110111
        STA     ,U     * 4      U
        LDA     #%11101111
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011111
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; 8
;0 11111111
;1 11100011
;2 11011101
;3 11011101
;4 11100011
;5 11011101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_8:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; 9
;0 11111111
;1 11100011
;2 11011101
;3 11011101
;4 11100001
;5 11111101
;6 11111011
;7 11100111
;8 11111111
;9 11111111
Character_9:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11100001
        STA     ,U     * 4      U
        LDA     #%11111101
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11111011
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100111
        STA     BytesPerRow_HIG156*3,U   * 7
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
;8 11111111
;9 11111111
Character_Colon:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; ;
;0 11111111
;1 11100111
;2 11100111
;3 11111111
;4 11100111
;5 11100111
;6 11101111
;7 11011111
;8 11111111
;9 11111111
Character_Semicolon:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11101111
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11011111
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; <
;0 11111111
;1 11111011
;2 11110111
;3 11101111
;4 11011111
;5 11101111
;6 11110111
;7 11111011
;8 11111111
;9 11111111
Character_Less:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11111011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11101111
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011111
        STA     ,U     * 4      U
        RTS
; **************************************
; =
;0 11111111
;1 11111111
;2 11111111
;3 11000011
;4 11111111
;5 11000011
;6 11111111
;7 11111111
;8 11111111
;9 11111111
Character_Equal:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; >
;0 11111111
;1 11101111
;2 11110111
;3 11111011
;4 11111101
;5 11111011
;6 11110111
;7 11101111
;8 11111111
;9 11111111
Character_Great:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11101111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11111011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11111101
        STA     ,U     * 4      U
        RTS
; **************************************
; ?
;0 11111111
;1 11100011
;2 11011101
;3 11111101
;4 11111011
;5 11110111
;6 11111111
;7 11110111
;8 11111111
;9 11111111
Character_QuestionMark:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11111101
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11111011
        STA     ,U     * 4      U
        LDA     #%11110111
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; @
;0 11111111
;1 11100011
;2 11011101
;3 11111101
;4 11100101
;5 11011001
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_AtSign:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11111101
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11100101
        STA     ,U     * 4      U
        LDA     #%11011001
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; A
;0 11111111
;1 11110111
;2 11101011
;3 11011101
;4 11011101
;5 11000001
;6 11011101
;7 11011101
;8 11111111
;9 11111111
Character_A:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11101011
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11011101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11000001
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; B
;0 11111111
;1 11000011
;2 11101101
;3 11101101
;4 11100011
;5 11101101
;6 11101101
;7 11000011
;8 11111111
;9 11111111
Character_B:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11101101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100011
        STA     ,U     * 4      U
        RTS
; **************************************
; C
;0 11111111
;1 11100011
;2 11011101
;3 11011111
;4 11011111
;5 11011111
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_C:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11011111
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; D
;0 11111111
;1 11000011
;2 11101101
;3 11101101
;4 11101101
;5 11101101
;6 11101101
;7 11000011
;8 11111111
;9 11111111
Character_D:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11101101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; E
;0 11111111
;1 11000001
;2 11011111
;3 11011111
;4 11000111
;5 11011111
;6 11011111
;7 11000001
;8 11111111
;9 11111111
Character_E:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11000111
        STA     ,U     * 4      U
        RTS
; **************************************
; F
;0 11111111
;1 11000001
;2 11011111
;3 11011111
;4 11000111
;5 11011111
;6 11011111
;7 11011111
;8 11111111
;9 11111111
Character_F:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11000111
        STA     ,U     * 4      U
        RTS
; **************************************
; G
;0 11111111
;1 11100001
;2 11011111
;3 11011111
;4 11011001
;5 11011101
;6 11011101
;7 11100001
;8 11111111
;9 11111111
Character_G:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100001
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11011001
        STA     ,U     * 4      U
        LDA     #%11011101
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; H
;0 11111111
;1 11011101
;2 11011101
;3 11011101
;4 11000001
;5 11011101
;6 11011101
;7 11011101
;8 11111111
;9 11111111
Character_H:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11000001
        STA     ,U     * 4      U
        RTS
; **************************************
; I
;0 11111111
;1 11100011
;2 11110111
;3 11110111
;4 11110111
;5 11110111
;6 11110111
;7 11100011
;8 11111111
;9 11111111
Character_I:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; J
;0 11111111
;1 11111101
;2 11111101
;3 11111101
;4 11111101
;5 11111101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_J:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11111101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011101
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; K
;0 11111111
;1 11011101
;2 11011011
;3 11010111
;4 11001111
;5 11010111
;6 11011011
;7 11011101
;8 11111111
;9 11111111
Character_K:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011011
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11010111
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11001111
        STA     ,U     * 4      U
        RTS
; **************************************
; L
;0 11111111
;1 11011111
;2 11011111
;3 11011111
;4 11011111
;5 11011111
;6 11011111
;7 11000001
;8 11111111
;9 11111111
Character_L:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11000001
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; M
;0 11111111
;1 11011101
;2 11001001
;3 11010101
;4 11010101
;5 11011101
;6 11011101
;7 11011101
;8 11111111
;9 11111111
Character_M:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11001001
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11010101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        RTS
; **************************************
; N
;0 11111111
;1 11011101
;2 11011101
;3 11001101
;4 11010101
;5 11011001
;6 11011101
;7 11011101
;8 11111111
;9 11111111
Character_N:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11001101
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11010101
        STA     ,U     * 4      U
        LDA     #%11011001
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; O
;0 11111111
;1 11100011
;2 11011101
;3 11011101
;4 11011101
;5 11011101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_O:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; P
;0 11111111
;1 11000011
;2 11011101
;3 11011101
;4 11000011
;5 11011111
;6 11011111
;7 11011111
;8 11111111
;9 11111111
Character_P:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     ,U     * 4      U
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11011111
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; Q
;0 11111111
;1 11100011
;2 11011101
;3 11011101
;4 11011101
;5 11010101
;6 11011011
;7 11100101
;8 11111111
;9 11111111
Character_Q:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        LDA     #%11010101
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011011
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100101
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; R
;0 11111111
;1 11000011
;2 11011101
;3 11011101
;4 11000011
;5 11010111
;6 11011011
;7 11011101
;8 11111111
;9 11111111
Character_R:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     ,U     * 4      U
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11010111
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011011
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; S
;0 11111111
;1 11100011
;2 11011101
;3 11011111
;4 11100011
;5 11111101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_S:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11011111
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11111101
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; T
;0 11111111
;1 11000001
;2 11110111
;3 11110111
;4 11110111
;5 11110111
;6 11110111
;7 11110111
;8 11111111
;9 11111111
Character_T:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; U
;0 11111111
;1 11011101
;2 11011101
;3 11011101
;4 11011101
;5 11011101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_U:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; V
;0 11111111
;1 11011101
;2 11011101
;3 11011101
;4 11101011
;5 11101011
;6 11110111
;7 11110111
;8 11111111
;9 11111111
Character_V:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11101011
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11110111
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; W
;0 11111111
;1 11011101
;2 11011101
;3 11011101
;4 11011101
;5 11010101
;6 11001001
;7 11011101
;8 11111111
;9 11111111
Character_W:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11010101
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11001001
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; X
;0 11111111
;1 11011101
;2 11011101
;3 11101011
;4 11110111
;5 11101011
;6 11011101
;7 11011101
;8 11111111
;9 11111111
Character_X:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11101011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11110111
        STA     ,U     * 4      U
        RTS
; **************************************
; Y
;0 11111111
;1 11011101
;2 11011101
;3 11101011
;4 11110111
;5 11110111
;6 11110111
;7 11110111
;8 11111111
;9 11111111
Character_Y:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11101011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11110111
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; Z
;0 11111111
;1 11000001
;2 11111101
;3 11111011
;4 11110111
;5 11101111
;6 11011111
;7 11000001
;8 11111111
;9 11111111
Character_Z:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11111101
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11111011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11110111
        STA     ,U     * 4      U
        LDA     #%11101111
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011111
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; [
;0 11111111
;1 11100011
;2 11101111
;3 11101111
;4 11101111
;5 11101111
;6 11101111
;7 11100011
;8 11111111
;9 11111111
Character_OpenSBracket:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11101111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; \
;0 11111111
;1 11011111
;2 11101111
;3 11110111
;4 11111011
;5 11111101
;6 11111111
;7 11111111
;8 11111111
;9 11111111
Character_Backslash:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11101111
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11110111
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11111011
        STA     ,U     * 4      U
        LDA     #%11111101
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; ]
;0 11111111
;1 11100011
;2 11111011
;3 11111011
;4 11111011
;5 11111011
;6 11111011
;7 11100011
;8 11111111
;9 11111111
Character_CloseSBracket:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11111011
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; ^
;0 11111111
;1 11110111
;2 11101011
;3 11011101
;4 11111111
;5 11111111
;6 11111111
;7 11111111
;8 11111111
;9 11111111
Character_Caret:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11101011
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11011101
        STA     -BytesPerRow_HIG156,U  * 3
        RTS
; **************************************
; _
;0 11111111
;1 11111111
;2 11111111
;3 11111111
;4 11111111
;5 11111111
;6 11111111
;7 11000001
;8 11111111
;9 11111111
Character_Underscore:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; `
;0 11111111
;1 11100111
;2 11100111
;3 11110111
;4 11111011
;5 11111111
;6 11111111
;7 11111111
;8 11111111
;9 11111111
Character_Backtick:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11110111
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11111011
        STA     ,U     * 4      U
        RTS
; **************************************
; a
;0 11111111
;1 11111111
;2 11111111
;3 11100011
;4 11111101
;5 11100001
;6 11011101
;7 11100001
;8 11111111
;9 11111111
Character_a:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11111101
        STA     ,U     * 4      U
        LDA     #%11100001
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; b
;0 11111111
;1 11011111
;2 11011111
;3 11010011
;4 11001101
;5 11011101
;6 11001101
;7 11010011
;8 11111111
;9 11111111
Character_b:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11010011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11001101
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11011101
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; c
;0 11111111
;1 11111111
;2 11111111
;3 11100011
;4 11011101
;5 11011111
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_c:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11011111
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; d
;0 11111111
;1 11111101
;2 11111101
;3 11100101
;4 11011001
;5 11011101
;6 11011001
;7 11100101
;8 11111111
;9 11111111
Character_d:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11111101
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11100101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011001
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11011101
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; e
;0 11111111
;1 11111111
;2 11111111
;3 11100011
;4 11011101
;5 11000001
;6 11011111
;7 11100011
;8 11111111
;9 11111111
Character_e:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     ,U     * 4      U
        LDA     #%11000001
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011111
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; f
;0 11111111
;1 11110111
;2 11101011
;3 11101111
;4 11000111
;5 11101111
;6 11101111
;7 11101111
;8 11111111
;9 11111111
Character_f:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11101011
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11101111
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11000111
        STA     ,U     * 4      U
        RTS
; **************************************
; g
;0 11111111
;1 11111111
;2 11111111
;3 11100101
;4 11011001
;5 11011001
;6 11100101
;7 11111101
;8 11011101
;9 11100011
Character_g:
        LDA     #%11111111
        STA     ,U     * 0
        STA     BytesPerRow_HIG156,U   * 1
        STA     BytesPerRow_HIG156*2,U   * 2
        LEAU    BytesPerRow_HIG156*6,U
        LDA     #%11100101
        STA     -BytesPerRow_HIG156*3,U  * 3
        STA     ,U     * 6      U
        LDA     #%11011001
        STA     -BytesPerRow_HIG156*2,U  * 4
        STA     -BytesPerRow_HIG156,U  * 5
        LDA     #%11111101
        STA     BytesPerRow_HIG156,U   * 7
        LDA     #%11011101
        STA     BytesPerRow_HIG156*2,U   * 8
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 9
        RTS
; **************************************
; h
;0 11111111
;1 11011111
;2 11011111
;3 11010011
;4 11001101
;5 11011101
;6 11011101
;7 11011101
;8 11111111
;9 11111111
Character_h:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11010011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11001101
        STA     ,U     * 4      U
        LDA     #%11011101
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; i
;0 11111111
;1 11110111
;2 11111111
;3 11100111
;4 11110111
;5 11110111
;6 11110111
;7 11100011
;8 11111111
;9 11111111
Character_i:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100111
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; j
;0 11111111
;1 11111111
;2 11111111
;3 11111101
;4 11111111
;5 11111101
;6 11111101
;7 11111101
;8 11011101
;9 11100011
Character_j:
        LDA     #%11111111
        STA     ,U     * 0
        STA     BytesPerRow_HIG156,U   * 1
        STA     BytesPerRow_HIG156*2,U   * 2
        LEAU    BytesPerRow_HIG156*6,U
        STA     -BytesPerRow_HIG156*2,U  * 4
        LDA     #%11111101
        STA     -BytesPerRow_HIG156*3,U  * 3
        STA     -BytesPerRow_HIG156,U  * 5
        STA     ,U     * 6      U
        STA     BytesPerRow_HIG156,U   * 7
        LDA     #%11011101
        STA     BytesPerRow_HIG156*2,U   * 8
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 9
        RTS
; **************************************
; k
;0 11111111
;1 11011111
;2 11011111
;3 11011011
;4 11010111
;5 11001111
;6 11010111
;7 11011011
;8 11111111
;9 11111111
Character_k:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11011011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11010111
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11001111
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; l
;0 11111111
;1 11100111
;2 11110111
;3 11110111
;4 11110111
;5 11110111
;6 11110111
;7 11100011
;8 11111111
;9 11111111
Character_l:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100111
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; m
;0 11111111
;1 11111111
;2 11111111
;3 11001011
;4 11010101
;5 11010101
;6 11010101
;7 11010101
;8 11111111
;9 11111111
Character_m:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11001011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11010101
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; n
;0 11111111
;1 11111111
;2 11111111
;3 11010011
;4 11001101
;5 11011101
;6 11011101
;7 11011101
;8 11111111
;9 11111111
Character_n:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11010011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11001101
        STA     ,U     * 4      U
        LDA     #%11011101
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; o
;0 11111111
;1 11111111
;2 11111111
;3 11100011
;4 11011101
;5 11011101
;6 11011101
;7 11100011
;8 11111111
;9 11111111
Character_o:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100011
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11011101
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; p
;0 11111111
;1 11111111
;2 11111111
;3 11010011
;4 11001101
;5 11011101
;6 11001101
;7 11010011
;8 11011111
;9 11011111
Character_p:
        LDA     #%11111111
        STA     ,U     * 0
        STA     BytesPerRow_HIG156,U   * 1
        STA     BytesPerRow_HIG156*2,U   * 2
        LEAU    BytesPerRow_HIG156*6,U
        LDA     #%11010011
        STA     -BytesPerRow_HIG156*3,U  * 3
        STA     BytesPerRow_HIG156,U   * 7
        LDA     #%11001101
        STA     -BytesPerRow_HIG156*2,U  * 4
        STA     ,U     * 6      U
        LDA     #%11011101
        STA     -BytesPerRow_HIG156,U  * 5
        LDA     #%11011111
        STA     BytesPerRow_HIG156*2,U   * 8
        STA     BytesPerRow_HIG156*3,U   * 9
        RTS
; **************************************
; q
;0 11111111
;1 11111111
;2 11111111
;3 11100101
;4 11011001
;5 11011101
;6 11011001
;7 11100101
;8 11111101
;9 11111101
Character_q:
        LDA     #%11111111
        STA     ,U     * 0
        STA     BytesPerRow_HIG156,U   * 1
        STA     BytesPerRow_HIG156*2,U   * 2
        LEAU    BytesPerRow_HIG156*6,U
        LDA     #%11100101
        STA     -BytesPerRow_HIG156*3,U  * 3
        STA     BytesPerRow_HIG156,U   * 7
        LDA     #%11011001
        STA     -BytesPerRow_HIG156*2,U  * 4
        STA     ,U     * 6      U
        LDA     #%11011101
        STA     -BytesPerRow_HIG156,U  * 5
        LDA     #%11111101
        STA     BytesPerRow_HIG156*2,U   * 8
        STA     BytesPerRow_HIG156*3,U   * 9
        RTS
; **************************************
; r
;0 11111111
;1 11111111
;2 11111111
;3 11010011
;4 11001101
;5 11011111
;6 11011111
;7 11011111
;8 11111111
;9 11111111
Character_r:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11010011
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11001101
        STA     ,U     * 4      U
        LDA     #%11011111
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; s
;0 11111111
;1 11111111
;2 11111111
;3 11100001
;4 11011111
;5 11100011
;6 11111101
;7 11000011
;8 11111111
;9 11111111
Character_s:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11100001
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11011111
        STA     ,U     * 4      U
        LDA     #%11100011
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11111101
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11000011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; t
;0 11111111
;1 11110111
;2 11110111
;3 11000001
;4 11110111
;5 11110111
;6 11110101
;7 11111011
;8 11111111
;9 11111111
Character_t:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11000001
        STA     -BytesPerRow_HIG156,U  * 3
        LDA     #%11110101
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11111011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; u
;0 11111111
;1 11111111
;2 11111111
;3 11011101
;4 11011101
;5 11011101
;6 11011001
;7 11100101
;8 11111111
;9 11111111
Character_u:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11011001
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11100101
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; v
;0 11111111
;1 11111111
;2 11111111
;3 11011101
;4 11011101
;5 11011101
;6 11101011
;7 11110111
;8 11111111
;9 11111111
Character_v:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11101011
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11110111
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; w
;0 11111111
;1 11111111
;2 11111111
;3 11011101
;4 11011101
;5 11010101
;6 11010101
;7 11101011
;8 11111111
;9 11111111
Character_w:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     ,U     * 4      U
        LDA     #%11010101
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11101011
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; x
;0 11111111
;1 11111111
;2 11111111
;3 11011101
;4 11101011
;5 11110111
;6 11101011
;7 11011101
;8 11111111
;9 11111111
Character_x:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11011101
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11101011
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11110111
        STA     BytesPerRow_HIG156,U   * 5
        RTS
; **************************************
; y
;0 11111111
;1 11111111
;2 11111111
;3 11011101
;4 11011101
;5 11011101
;6 11100001
;7 11111101
;8 11011101
;9 11100011
Character_y:
        LDA     #%11111111
        STA     ,U     * 0
        STA     BytesPerRow_HIG156,U   * 1
        STA     BytesPerRow_HIG156*2,U   * 2
        LEAU    BytesPerRow_HIG156*6,U
        LDA     #%11011101
        STA     -BytesPerRow_HIG156*3,U  * 3
        STA     -BytesPerRow_HIG156*2,U  * 4
        STA     -BytesPerRow_HIG156,U  * 5
        STA     BytesPerRow_HIG156*2,U   * 8
        LDA     #%11100001
        STA     ,U     * 6      U
        LDA     #%11111101
        STA     BytesPerRow_HIG156,U   * 7
        LDA     #%11100011
        STA     BytesPerRow_HIG156*3,U   * 9
        RTS
; **************************************
; z
;0 11111111
;1 11111111
;2 11111111
;3 11000001
;4 11111011
;5 11110111
;6 11101111
;7 11000001
;8 11111111
;9 11111111
Character_z:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11000001
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11111011
        STA     ,U     * 4      U
        LDA     #%11110111
        STA     BytesPerRow_HIG156,U   * 5
        LDA     #%11101111
        STA     BytesPerRow_HIG156*2,U   * 6
        RTS
; **************************************
; {
;0 11111111
;1 11111011
;2 11110111
;3 11110111
;4 11101111
;5 11110111
;6 11110111
;7 11111011
;8 11111111
;9 11111111
Character_OpenCurlyBracket:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11111011
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11101111
        STA     ,U     * 4      U
        RTS
; **************************************
; |
;0 11111111
;1 11110111
;2 11110111
;3 11110111
;4 11111111
;5 11110111
;6 11110111
;7 11110111
;8 11111111
;9 11111111
Character_Pipe:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        RTS
; **************************************
; }
;0 11111111
;1 11101111
;2 11110111
;3 11110111
;4 11111011
;5 11110111
;6 11110111
;7 11101111
;8 11111111
;9 11111111
Character_CloseCurlyBracket:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11101111
        STA     -BytesPerRow_HIG156*3,U  * 1
        STA     BytesPerRow_HIG156*3,U   * 7
        LDA     #%11110111
        STA     -BytesPerRow_HIG156*2,U  * 2
        STA     -BytesPerRow_HIG156,U  * 3
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        LDA     #%11111011
        STA     ,U     * 4      U
        RTS
; **************************************
; ~
;0 11111111
;1 11101111
;2 11010101
;3 11111011
;4 11111111
;5 11111111
;6 11111111
;7 11111111
;8 11111111
;9 11111111
Character_Tilde:
        LDA     #%11111111
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG156*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG156,U   * 5
        STA     BytesPerRow_HIG156*2,U   * 6
        STA     BytesPerRow_HIG156*3,U   * 7
        STA     BytesPerRow_HIG156*4,U   * 8
        STA     BytesPerRow_HIG156*5,U   * 9
        LDA     #%11101111
        STA     -BytesPerRow_HIG156*3,U  * 1
        LDA     #%11010101
        STA     -BytesPerRow_HIG156*2,U  * 2
        LDA     #%11111011
        STA     -BytesPerRow_HIG156,U  * 3
        RTS