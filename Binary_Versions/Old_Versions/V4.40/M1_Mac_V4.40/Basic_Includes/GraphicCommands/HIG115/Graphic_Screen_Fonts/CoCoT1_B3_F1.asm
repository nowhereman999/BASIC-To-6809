; Font Name: CoCoT1
; Description: Pixel match of the Motorola MC6847T1 VDG chip
;              Matches the font of newer CoCo 2's
;              Since the pixels are single dots, this font will produce artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     10
CharJumpTable_HIG115:
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
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000000000000
;4 0000000000000000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Blank:
        LDD     #%1111111111111111
        STD     ,U                      * 0
        STD     BytesPerRow_HIG115,U      * 1
        STD     BytesPerRow_HIG115*2,U    * 2
        LEAU    BytesPerRow_HIG115*6,U
        STD     -BytesPerRow_HIG115*3,U   * 3
        STD     -BytesPerRow_HIG115*2,U   * 4
        STD     -BytesPerRow_HIG115,U     * 5
        STD     ,U                      * 6
        STD     BytesPerRow_HIG115,U      * 7
        STD     BytesPerRow_HIG115*2,U    * 8
        STD     BytesPerRow_HIG115*3,U    * 9
        RTS
; **************************************
; !
;0 0000000000000000
;1 0000000001000000
;2 0000000001000000
;3 0000000001000000
;4 0000000001000000
;5 0000000001000000
;6 0000000000000000
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_Exclamation:
        LDD     #%1111111111111111
        STD     ,U                      * 0
        LEAU    BytesPerRow_HIG115*5,U
        STD     BytesPerRow_HIG115,U      * 6
        STD     BytesPerRow_HIG115*3,U    * 8
        STD     BytesPerRow_HIG115*4,U    * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*4,U   * 1
        STD     -BytesPerRow_HIG115*3,U   * 2
        STD     -BytesPerRow_HIG115*2,U   * 3
        STD     -BytesPerRow_HIG115,U     * 4
        STD     ,U                      * 5
        STD     BytesPerRow_HIG115*2,U    * 7
        RTS
; **************************************
; "
;0 0000000000000000
;1 0000000100010000
;2 0000000100010000
;3 0000000100010000
;4 0000000000000000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Quote:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111011101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        RTS
; **************************************
; #
;0 0000000000000000
;1 0000000100010000
;2 0000000100010000
;3 0000010101010100
;4 0000000000000000
;5 0000010101010100
;6 0000000100010000
;7 0000000100010000
;8 0000000000000000
;9 0000000000000000
Character_Pound:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111011101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; $
;0 0000000000000000
;1 0000000001000000
;2 0000000101010100
;3 0000010000000000
;4 0000000101010000
;5 0000000000000100
;6 0000010101010000
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_DollarSign:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111010101011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111010101111111
        STD     ,U     * 4      U
        LDD     #%1111111111011111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101010101111111
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; %
;0 0000000000000000
;1 0000010100000000
;2 0000010100000100
;3 0000000000010000
;4 0000000001000000
;5 0000000100000000
;6 0000010000010100
;7 0000000000010100
;8 0000000000000000
;9 0000000000000000
Character_Percent:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101011111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1101011111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111110111111111
        STD     ,U     * 4      U
        LDD     #%1111011111111111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111101011111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111111101011111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; &
;0 0000000000000000
;1 0000000100000000
;2 0000010001000000
;3 0000010001000000
;4 0000000100000000
;5 0000010001000100
;6 0000010000010000
;7 0000000101000100
;8 0000000000000000
;9 0000000000000000
Character_Ampersand:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     ,U     * 4      U
        LDD     #%1101110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101110111111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101110111011111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111101111111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010111011111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; '
;0 0000000000000000
;1 0000000101000000
;2 0000000101000000
;3 0000000100000000
;4 0000010000000000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Apostrophe:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101111111111111
        STD     ,U     * 4      U
        RTS
; **************************************
; (
;0 0000000000000000
;1 0000000000010000
;2 0000000001000000
;3 0000000100000000
;4 0000000100000000
;5 0000000100000000
;6 0000000001000000
;7 0000000000010000
;8 0000000000000000
;9 0000000000000000
Character_OpenBracket:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; )
;0 0000000000000000
;1 0000000100000000
;2 0000000001000000
;3 0000000000010000
;4 0000000000010000
;5 0000000000010000
;6 0000000001000000
;7 0000000100000000
;8 0000000000000000
;9 0000000000000000
Character_CloseBracket:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; *
;0 0000000000000000
;1 0000000000000000
;2 0000000001000000
;3 0000010001000100
;4 0000000101010000
;5 0000000101010000
;6 0000010001000100
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_Asterisk:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101110111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010101111111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; +
;0 0000000000000000
;1 0000000000000000
;2 0000000001000000
;3 0000000001000000
;4 0000010101010100
;5 0000000001000000
;6 0000000001000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Plus:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101010101011111
        STD     ,U     * 4      U
        RTS
; **************************************
; ,
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000000000000
;4 0000000101000000
;5 0000000101000000
;6 0000000100000000
;7 0000010000000000
;8 0000000000000000
;9 0000000000000000
Character_Comma:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010111111111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111011111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; -
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000000000000
;4 0000010101010100
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Hyphen:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     ,U     * 4      U
        RTS
; **************************************
; .
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000000000000
;4 0000000000000000
;5 0000000000000000
;6 0000000101000000
;7 0000000101000000
;8 0000000000000000
;9 0000000000000000
Character_Decimal:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; /
;0 0000000000000000
;1 0000000000000000
;2 0000000000000100
;3 0000000000010000
;4 0000000001000000
;5 0000000100000000
;6 0000010000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Slash:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111110111111111
        STD     ,U     * 4      U
        LDD     #%1111011111111111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; 0
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000010000010100
;4 0000010001000100
;5 0000010100000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_0:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101111101011111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101110111011111
        STD     ,U     * 4      U
        LDD     #%1101011111011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; 1
;0 0000000000000000
;1 0000000001000000
;2 0000000101000000
;3 0000000001000000
;4 0000000001000000
;5 0000000001000000
;6 0000000001000000
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_1:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; 2
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000000000000100
;4 0000000101010000
;5 0000010000000000
;6 0000010000000000
;7 0000010101010100
;8 0000000000000000
;9 0000000000000000
Character_2:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     ,U     * 4      U
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101010101011111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; 3
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000000000000100
;4 0000000001010000
;5 0000000000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_3:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111110101111111
        STD     ,U     * 4      U
        RTS
; **************************************
; 4
;0 0000000000000000
;1 0000000000010000
;2 0000000001010000
;3 0000000100010000
;4 0000010000010000
;5 0000010101010100
;6 0000000000010000
;7 0000000000010000
;8 0000000000000000
;9 0000000000000000
Character_4:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111110101111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111011101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101111101111111
        STD     ,U     * 4      U
        LDD     #%1101010101011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; 5
;0 0000000000000000
;1 0000010101010100
;2 0000010000000000
;3 0000010101010000
;4 0000000000000100
;5 0000000000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_5:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101010101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111111111011111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; 6
;0 0000000000000000
;1 0000000001010000
;2 0000000100000000
;3 0000010000000000
;4 0000010101010000
;5 0000010000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_6:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101010101111111
        STD     ,U     * 4      U
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; 7
;0 0000000000000000
;1 0000010101010100
;2 0000000000000100
;3 0000000000010000
;4 0000000001000000
;5 0000000100000000
;6 0000010000000000
;7 0000010000000000
;8 0000000000000000
;9 0000000000000000
Character_7:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111110111111111
        STD     ,U     * 4      U
        LDD     #%1111011111111111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; 8
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000010000000100
;4 0000000101010000
;5 0000010000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_8:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; 9
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000010000000100
;4 0000000101010100
;5 0000000000000100
;6 0000000000010000
;7 0000000101000000
;8 0000000000000000
;9 0000000000000000
Character_9:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111010101011111
        STD     ,U     * 4      U
        LDD     #%1111111111011111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111111101111111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010111111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; :
;0 0000000000000000
;1 0000000000000000
;2 0000000101000000
;3 0000000101000000
;4 0000000000000000
;5 0000000101000000
;6 0000000101000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Colon:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; ;
;0 0000000000000000
;1 0000000101000000
;2 0000000101000000
;3 0000000000000000
;4 0000000101000000
;5 0000000101000000
;6 0000000100000000
;7 0000010000000000
;8 0000000000000000
;9 0000000000000000
Character_Semicolon:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111011111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; <
;0 0000000000000000
;1 0000000000010000
;2 0000000001000000
;3 0000000100000000
;4 0000010000000000
;5 0000000100000000
;6 0000000001000000
;7 0000000000010000
;8 0000000000000000
;9 0000000000000000
Character_Less:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111111111111
        STD     ,U     * 4      U
        RTS
; **************************************
; =
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010101010000
;4 0000000000000000
;5 0000010101010000
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Equal:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; >
;0 0000000000000000
;1 0000000100000000
;2 0000000001000000
;3 0000000000010000
;4 0000000000000100
;5 0000000000010000
;6 0000000001000000
;7 0000000100000000
;8 0000000000000000
;9 0000000000000000
Character_Great:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111111111011111
        STD     ,U     * 4      U
        RTS
; **************************************
; ?
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000000000000100
;4 0000000000010000
;5 0000000001000000
;6 0000000000000000
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_QuestionMark:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111111101111111
        STD     ,U     * 4      U
        LDD     #%1111110111111111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; @
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000000000000100
;4 0000000101000100
;5 0000010000010100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_AtSign:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111010111011111
        STD     ,U     * 4      U
        LDD     #%1101111101011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; A
;0 0000000000000000
;1 0000000001000000
;2 0000000100010000
;3 0000010000000100
;4 0000010000000100
;5 0000010101010100
;6 0000010000000100
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_A:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1111011101111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101010101011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; B
;0 0000000000000000
;1 0000010101010000
;2 0000000100000100
;3 0000000100000100
;4 0000000101010000
;5 0000000100000100
;6 0000000100000100
;7 0000010101010000
;8 0000000000000000
;9 0000000000000000
Character_B:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111011111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010101111111
        STD     ,U     * 4      U
        RTS
; **************************************
; C
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000010000000000
;4 0000010000000000
;5 0000010000000000
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_C:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; D
;0 0000000000000000
;1 0000010101010000
;2 0000000100000100
;3 0000000100000100
;4 0000000100000100
;5 0000000100000100
;6 0000000100000100
;7 0000010101010000
;8 0000000000000000
;9 0000000000000000
Character_D:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111011111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; E
;0 0000000000000000
;1 0000010101010100
;2 0000010000000000
;3 0000010000000000
;4 0000010101000000
;5 0000010000000000
;6 0000010000000000
;7 0000010101010100
;8 0000000000000000
;9 0000000000000000
Character_E:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101010111111111
        STD     ,U     * 4      U
        RTS
; **************************************
; F
;0 0000000000000000
;1 0000010101010100
;2 0000010000000000
;3 0000010000000000
;4 0000010101000000
;5 0000010000000000
;6 0000010000000000
;7 0000010000000000
;8 0000000000000000
;9 0000000000000000
Character_F:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101010111111111
        STD     ,U     * 4      U
        RTS
; **************************************
; G
;0 0000000000000000
;1 0000000101010100
;2 0000010000000000
;3 0000010000000000
;4 0000010000010100
;5 0000010000000100
;6 0000010000000100
;7 0000000101010100
;8 0000000000000000
;9 0000000000000000
Character_G:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101111101011111
        STD     ,U     * 4      U
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; H
;0 0000000000000000
;1 0000010000000100
;2 0000010000000100
;3 0000010000000100
;4 0000010101010100
;5 0000010000000100
;6 0000010000000100
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_H:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101010101011111
        STD     ,U     * 4      U
        RTS
; **************************************
; I
;0 0000000000000000
;1 0000000101010000
;2 0000000001000000
;3 0000000001000000
;4 0000000001000000
;5 0000000001000000
;6 0000000001000000
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_I:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; J
;0 0000000000000000
;1 0000000000000100
;2 0000000000000100
;3 0000000000000100
;4 0000000000000100
;5 0000000000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_J:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; K
;0 0000000000000000
;1 0000010000000100
;2 0000010000010000
;3 0000010001000000
;4 0000010100000000
;5 0000010001000000
;6 0000010000010000
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_K:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111101111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101110111111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101011111111111
        STD     ,U     * 4      U
        RTS
; **************************************
; L
;0 0000000000000000
;1 0000010000000000
;2 0000010000000000
;3 0000010000000000
;4 0000010000000000
;5 0000010000000000
;6 0000010000000000
;7 0000010101010100
;8 0000000000000000
;9 0000000000000000
Character_L:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101010101011111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; M
;0 0000000000000000
;1 0000010000000100
;2 0000010100010100
;3 0000010001000100
;4 0000010001000100
;5 0000010000000100
;6 0000010000000100
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_M:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101011101011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101110111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        RTS
; **************************************
; N
;0 0000000000000000
;1 0000010000000100
;2 0000010000000100
;3 0000010100000100
;4 0000010001000100
;5 0000010000010100
;6 0000010000000100
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_N:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101011111011111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101110111011111
        STD     ,U     * 4      U
        LDD     #%1101111101011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; O
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000010000000100
;4 0000010000000100
;5 0000010000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_O:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; P
;0 0000000000000000
;1 0000010101010000
;2 0000010000000100
;3 0000010000000100
;4 0000010101010000
;5 0000010000000000
;6 0000010000000000
;7 0000010000000000
;8 0000000000000000
;9 0000000000000000
Character_P:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     ,U     * 4      U
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; Q
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000010000000100
;4 0000010000000100
;5 0000010001000100
;6 0000010000010000
;7 0000000101000100
;8 0000000000000000
;9 0000000000000000
Character_Q:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        LDD     #%1101110111011111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111101111111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010111011111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; R
;0 0000000000000000
;1 0000010101010000
;2 0000010000000100
;3 0000010000000100
;4 0000010101010000
;5 0000010001000000
;6 0000010000010000
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_R:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     ,U     * 4      U
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101110111111111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111101111111
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; S
;0 0000000000000000
;1 0000000101010000
;2 0000010000000100
;3 0000010000000000
;4 0000000101010000
;5 0000000000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_S:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111111111011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; T
;0 0000000000000000
;1 0000010101010100
;2 0000000001000000
;3 0000000001000000
;4 0000000001000000
;5 0000000001000000
;6 0000000001000000
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_T:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; U
;0 0000000000000000
;1 0000010000000100
;2 0000010000000100
;3 0000010000000100
;4 0000010000000100
;5 0000010000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_U:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; V
;0 0000000000000000
;1 0000010000000100
;2 0000010000000100
;3 0000010000000100
;4 0000000100010000
;5 0000000100010000
;6 0000000001000000
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_V:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111011101111111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111110111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; W
;0 0000000000000000
;1 0000010000000100
;2 0000010000000100
;3 0000010000000100
;4 0000010000000100
;5 0000010001000100
;6 0000010100010100
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_W:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101110111011111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101011101011111
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; X
;0 0000000000000000
;1 0000010000000100
;2 0000010000000100
;3 0000000100010000
;4 0000000001000000
;5 0000000100010000
;6 0000010000000100
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_X:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111011101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111110111111111
        STD     ,U     * 4      U
        RTS
; **************************************
; Y
;0 0000000000000000
;1 0000010000000100
;2 0000010000000100
;3 0000000100010000
;4 0000000001000000
;5 0000000001000000
;6 0000000001000000
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_Y:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111011101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111110111111111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; Z
;0 0000000000000000
;1 0000010101010100
;2 0000000000000100
;3 0000000000010000
;4 0000000001000000
;5 0000000100000000
;6 0000010000000000
;7 0000010101010100
;8 0000000000000000
;9 0000000000000000
Character_Z:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111110111111111
        STD     ,U     * 4      U
        LDD     #%1111011111111111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; [
;0 0000000000000000
;1 0000000101010000
;2 0000000100000000
;3 0000000100000000
;4 0000000100000000
;5 0000000100000000
;6 0000000100000000
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_OpenSBracket:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; \
;0 0000000000000000
;1 0000010000000000
;2 0000000100000000
;3 0000000001000000
;4 0000000000010000
;5 0000000000000100
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Backslash:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111111101111111
        STD     ,U     * 4      U
        LDD     #%1111111111011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; ]
;0 0000000000000000
;1 0000000101010000
;2 0000000000010000
;3 0000000000010000
;4 0000000000010000
;5 0000000000010000
;6 0000000000010000
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_CloseSBracket:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; ^
;0 0000000000000000
;1 0000000001000000
;2 0000000100010000
;3 0000010000000100
;4 0000000000000000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Caret:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1111011101111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        RTS
; **************************************
; _
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000000000000
;4 0000000000000000
;5 0000000000000000
;6 0000000000000000
;7 0000010101010100
;8 0000000000000000
;9 0000000000000000
Character_Underscore:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; `
;0 0000000000000000
;1 0000000101000000
;2 0000000101000000
;3 0000000001000000
;4 0000000000010000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Backtick:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111111101111111
        STD     ,U     * 4      U
        RTS
; **************************************
; a
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000101010000
;4 0000000000000100
;5 0000000101010100
;6 0000010000000100
;7 0000000101010100
;8 0000000000000000
;9 0000000000000000
Character_a:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111111111011111
        STD     ,U     * 4      U
        LDD     #%1111010101011111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; b
;0 0000000000000000
;1 0000010000000000
;2 0000010000000000
;3 0000010001010000
;4 0000010100000100
;5 0000010000000100
;6 0000010100000100
;7 0000010001010000
;8 0000000000000000
;9 0000000000000000
Character_b:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101110101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101011111011111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; c
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000101010000
;4 0000010000000100
;5 0000010000000000
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_c:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; d
;0 0000000000000000
;1 0000000000000100
;2 0000000000000100
;3 0000000101000100
;4 0000010000010100
;5 0000010000000100
;6 0000010000010100
;7 0000000101000100
;8 0000000000000000
;9 0000000000000000
Character_d:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111010111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111101011111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; e
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000101010000
;4 0000010000000100
;5 0000010101010100
;6 0000010000000000
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_e:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     ,U     * 4      U
        LDD     #%1101010101011111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; f
;0 0000000000000000
;1 0000000001000000
;2 0000000100010000
;3 0000000100000000
;4 0000010101000000
;5 0000000100000000
;6 0000000100000000
;7 0000000100000000
;8 0000000000000000
;9 0000000000000000
Character_f:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1111011101111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101010111111111
        STD     ,U     * 4      U
        RTS
; **************************************
; g
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000101000100
;4 0000010000010100
;5 0000010000010100
;6 0000000101000100
;7 0000000000000100
;8 0000010000000100
;9 0000000101010000
Character_g:
        LDD     #%1111111111111111
        STD     ,U     * 0
        STD     BytesPerRow_HIG115,U   * 1
        STD     BytesPerRow_HIG115*2,U   * 2
        LEAU    BytesPerRow_HIG115*6,U
        LDD     #%1111010111011111
        STD     -BytesPerRow_HIG115*3,U  * 3
        STD     ,U     * 6      U
        LDD     #%1101111101011111
        STD     -BytesPerRow_HIG115*2,U  * 4
        STD     -BytesPerRow_HIG115,U  * 5
        LDD     #%1111111111011111
        STD     BytesPerRow_HIG115,U   * 7
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115*2,U   * 8
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 9
        RTS
; **************************************
; h
;0 0000000000000000
;1 0000010000000000
;2 0000010000000000
;3 0000010001010000
;4 0000010100000100
;5 0000010000000100
;6 0000010000000100
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_h:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101110101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101011111011111
        STD     ,U     * 4      U
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; i
;0 0000000000000000
;1 0000000001000000
;2 0000000000000000
;3 0000000101000000
;4 0000000001000000
;5 0000000001000000
;6 0000000001000000
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_i:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010111111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; j
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000000000100
;4 0000000000000000
;5 0000000000000100
;6 0000000000000100
;7 0000000000000100
;8 0000010000000100
;9 0000000101010000
Character_j:
        LDD     #%1111111111111111
        STD     ,U     * 0
        STD     BytesPerRow_HIG115,U   * 1
        STD     BytesPerRow_HIG115*2,U   * 2
        LEAU    BytesPerRow_HIG115*6,U
        STD     -BytesPerRow_HIG115*2,U  * 4
        LDD     #%1111111111011111
        STD     -BytesPerRow_HIG115*3,U  * 3
        STD     -BytesPerRow_HIG115,U  * 5
        STD     ,U     * 6      U
        STD     BytesPerRow_HIG115,U   * 7
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115*2,U   * 8
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 9
        RTS
; **************************************
; k
;0 0000000000000000
;1 0000010000000000
;2 0000010000000000
;3 0000010000010000
;4 0000010001000000
;5 0000010100000000
;6 0000010001000000
;7 0000010000010000
;8 0000000000000000
;9 0000000000000000
Character_k:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1101111101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101110111111111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101011111111111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; l
;0 0000000000000000
;1 0000000101000000
;2 0000000001000000
;3 0000000001000000
;4 0000000001000000
;5 0000000001000000
;6 0000000001000000
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_l:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; m
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010100010000
;4 0000010001000100
;5 0000010001000100
;6 0000010001000100
;7 0000010001000100
;8 0000000000000000
;9 0000000000000000
Character_m:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101011101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101110111011111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; n
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010001010000
;4 0000010100000100
;5 0000010000000100
;6 0000010000000100
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_n:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101110101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101011111011111
        STD     ,U     * 4      U
        LDD     #%1101111111011111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; o
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000101010000
;4 0000010000000100
;5 0000010000000100
;6 0000010000000100
;7 0000000101010000
;8 0000000000000000
;9 0000000000000000
Character_o:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101111111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1101111111011111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; p
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010001010000
;4 0000010100000100
;5 0000010000000100
;6 0000010100000100
;7 0000010001010000
;8 0000010000000000
;9 0000010000000000
Character_p:
        LDD     #%1111111111111111
        STD     ,U     * 0
        STD     BytesPerRow_HIG115,U   * 1
        STD     BytesPerRow_HIG115*2,U   * 2
        LEAU    BytesPerRow_HIG115*6,U
        LDD     #%1101110101111111
        STD     -BytesPerRow_HIG115*3,U  * 3
        STD     BytesPerRow_HIG115,U   * 7
        LDD     #%1101011111011111
        STD     -BytesPerRow_HIG115*2,U  * 4
        STD     ,U     * 6      U
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115,U  * 5
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115*2,U   * 8
        STD     BytesPerRow_HIG115*3,U   * 9
        RTS
; **************************************
; q
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000101000100
;4 0000010000010100
;5 0000010000000100
;6 0000010000010100
;7 0000000101000100
;8 0000000000000100
;9 0000000000000100
Character_q:
        LDD     #%1111111111111111
        STD     ,U     * 0
        STD     BytesPerRow_HIG115,U   * 1
        STD     BytesPerRow_HIG115*2,U   * 2
        LEAU    BytesPerRow_HIG115*6,U
        LDD     #%1111010111011111
        STD     -BytesPerRow_HIG115*3,U  * 3
        STD     BytesPerRow_HIG115,U   * 7
        LDD     #%1101111101011111
        STD     -BytesPerRow_HIG115*2,U  * 4
        STD     ,U     * 6      U
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115,U  * 5
        LDD     #%1111111111011111
        STD     BytesPerRow_HIG115*2,U   * 8
        STD     BytesPerRow_HIG115*3,U   * 9
        RTS
; **************************************
; r
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010001010000
;4 0000010100000100
;5 0000010000000000
;6 0000010000000000
;7 0000010000000000
;8 0000000000000000
;9 0000000000000000
Character_r:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101110101111111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101011111011111
        STD     ,U     * 4      U
        LDD     #%1101111111111111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; s
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000101010100
;4 0000010000000000
;5 0000000101010000
;6 0000000000000100
;7 0000010101010000
;8 0000000000000000
;9 0000000000000000
Character_s:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111010101011111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1101111111111111
        STD     ,U     * 4      U
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111111111011111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1101010101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; t
;0 0000000000000000
;1 0000000001000000
;2 0000000001000000
;3 0000010101010100
;4 0000000001000000
;5 0000000001000000
;6 0000000001000100
;7 0000000000010000
;8 0000000000000000
;9 0000000000000000
Character_t:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115,U  * 3
        LDD     #%1111110111011111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111111101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; u
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010000000100
;4 0000010000000100
;5 0000010000000100
;6 0000010000010100
;7 0000000101000100
;8 0000000000000000
;9 0000000000000000
Character_u:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1101111101011111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111010111011111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; v
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010000000100
;4 0000010000000100
;5 0000010000000100
;6 0000000100010000
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_v:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111011101111111
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111110111111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; w
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010000000100
;4 0000010000000100
;5 0000010001000100
;6 0000010001000100
;7 0000000100010000
;8 0000000000000000
;9 0000000000000000
Character_w:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     ,U     * 4      U
        LDD     #%1101110111011111
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111011101111111
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; x
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010000000100
;4 0000000100010000
;5 0000000001000000
;6 0000000100010000
;7 0000010000000100
;8 0000000000000000
;9 0000000000000000
Character_x:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111011101111111
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111110111111111
        STD     BytesPerRow_HIG115,U   * 5
        RTS
; **************************************
; y
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010000000100
;4 0000010000000100
;5 0000010000000100
;6 0000000101010100
;7 0000000000000100
;8 0000010000000100
;9 0000000101010000
Character_y:
        LDD     #%1111111111111111
        STD     ,U     * 0
        STD     BytesPerRow_HIG115,U   * 1
        STD     BytesPerRow_HIG115*2,U   * 2
        LEAU    BytesPerRow_HIG115*6,U
        LDD     #%1101111111011111
        STD     -BytesPerRow_HIG115*3,U  * 3
        STD     -BytesPerRow_HIG115*2,U  * 4
        STD     -BytesPerRow_HIG115,U  * 5
        STD     BytesPerRow_HIG115*2,U   * 8
        LDD     #%1111010101011111
        STD     ,U     * 6      U
        LDD     #%1111111111011111
        STD     BytesPerRow_HIG115,U   * 7
        LDD     #%1111010101111111
        STD     BytesPerRow_HIG115*3,U   * 9
        RTS
; **************************************
; z
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000010101010100
;4 0000000000010000
;5 0000000001000000
;6 0000000100000000
;7 0000010101010100
;8 0000000000000000
;9 0000000000000000
Character_z:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1101010101011111
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111111101111111
        STD     ,U     * 4      U
        LDD     #%1111110111111111
        STD     BytesPerRow_HIG115,U   * 5
        LDD     #%1111011111111111
        STD     BytesPerRow_HIG115*2,U   * 6
        RTS
; **************************************
; {
;0 0000000000000000
;1 0000000000010000
;2 0000000001000000
;3 0000000001000000
;4 0000000100000000
;5 0000000001000000
;6 0000000001000000
;7 0000000000010000
;8 0000000000000000
;9 0000000000000000
Character_OpenCurlyBracket:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111011111111111
        STD     ,U     * 4      U
        RTS
; **************************************
; |
;0 0000000000000000
;1 0000000001000000
;2 0000000001000000
;3 0000000001000000
;4 0000000000000000
;5 0000000001000000
;6 0000000001000000
;7 0000000001000000
;8 0000000000000000
;9 0000000000000000
Character_Pipe:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        RTS
; **************************************
; }
;0 0000000000000000
;1 0000000100000000
;2 0000000001000000
;3 0000000001000000
;4 0000000000010000
;5 0000000001000000
;6 0000000001000000
;7 0000000100000000
;8 0000000000000000
;9 0000000000000000
Character_CloseCurlyBracket:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        STD     BytesPerRow_HIG115*3,U   * 7
        LDD     #%1111110111111111
        STD     -BytesPerRow_HIG115*2,U  * 2
        STD     -BytesPerRow_HIG115,U  * 3
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        LDD     #%1111111101111111
        STD     ,U     * 4      U
        RTS
; **************************************
; ~
;0 0000000000000000
;1 0000000100000000
;2 0000010001000100
;3 0000000000010000
;4 0000000000000000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
;8 0000000000000000
;9 0000000000000000
Character_Tilde:
        LDD     #%1111111111111111
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG115*4,U
        STD     ,U     * 4      U
        STD     BytesPerRow_HIG115,U   * 5
        STD     BytesPerRow_HIG115*2,U   * 6
        STD     BytesPerRow_HIG115*3,U   * 7
        STD     BytesPerRow_HIG115*4,U   * 8
        STD     BytesPerRow_HIG115*5,U   * 9
        LDD     #%1111011111111111
        STD     -BytesPerRow_HIG115*3,U  * 1
        LDD     #%1101110111011111
        STD     -BytesPerRow_HIG115*2,U  * 2
        LDD     #%1111111101111111
        STD     -BytesPerRow_HIG115,U  * 3
        RTS