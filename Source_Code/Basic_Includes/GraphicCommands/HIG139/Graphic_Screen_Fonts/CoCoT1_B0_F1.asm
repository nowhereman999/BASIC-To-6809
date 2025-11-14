; Font Name: CoCoT1
; Description: Pixel match of the Motorola MC6847T1 VDG chip
;              Matches the font of newer CoCo 2's
;              Since the pixels are single dots, this font will produce artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     10
CharJumpTable_HIG139:
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
;  Blank
;0 00000000
;1 00000000
;2 00000000
;3 00000000
;4 00000000
;5 00000000
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Blank:
        CLRA
        STA     ,U                      * 0
        STA     BytesPerRow_HIG139,U      * 1
        STA     BytesPerRow_HIG139*2,U    * 2
        LEAU    BytesPerRow_HIG139*6,U
        STA     -BytesPerRow_HIG139*3,U   * 3
        STA     -BytesPerRow_HIG139*2,U   * 4
        STA     -BytesPerRow_HIG139,U     * 5
        STA     ,U                      * 6
        STA     BytesPerRow_HIG139,U      * 7
        STA     BytesPerRow_HIG139*2,U    * 8
        STA     BytesPerRow_HIG139*3,U    * 9
        RTS
; **************************************
;  !
;0 00000000
;1 00001000
;2 00001000
;3 00001000
;4 00001000
;5 00001000
;6 00000000
;7 00001000
;8 00000000
;9 00000000
Character_Exclamation:
        CLRA
        STA     ,U                      * 0
        LEAU    BytesPerRow_HIG139*5,U
        STA     BytesPerRow_HIG139,U      * 6
        STA     BytesPerRow_HIG139*3,U    * 8
        STA     BytesPerRow_HIG139*4,U    * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*4,U   * 1
        STA     -BytesPerRow_HIG139*3,U   * 2
        STA     -BytesPerRow_HIG139*2,U   * 3
        STA     -BytesPerRow_HIG139,U     * 4
        STA     ,U                      * 5
        STA     BytesPerRow_HIG139*2,U    * 7
        RTS
; **************************************
;  "
;0 00000000
;1 00010100
;2 00010100
;3 00010100
;4 00000000
;5 00000000
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Quote:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00010100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        RTS
; **************************************
;  #
;0 00000000
;1 00010100
;2 00010100
;3 00111110
;4 00000000
;5 00111110
;6 00010100
;7 00010100
;8 00000000
;9 00000000
Character_Pound:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00010100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00111110
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  $
;0 00000000
;1 00001000
;2 00011110
;3 00100000
;4 00011100
;5 00000010
;6 00111100
;7 00001000
;8 00000000
;9 00000000
Character_DollarSign:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00011110
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00100000
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00011100
        STA     ,U     * 4      U
        LDA     #%00000010
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00111100
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  %
;0 00000000
;1 00110000
;2 00110010
;3 00000100
;4 00001000
;5 00010000
;6 00100110
;7 00000110
;8 00000000
;9 00000000
Character_Percent:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00110000
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00110010
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00000100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00001000
        STA     ,U     * 4      U
        LDA     #%00010000
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100110
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00000110
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  &
;0 00000000
;1 00010000
;2 00101000
;3 00101000
;4 00010000
;5 00101010
;6 00100100
;7 00011010
;8 00000000
;9 00000000
Character_Ampersand:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00010000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     ,U     * 4      U
        LDA     #%00101000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00101010
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100100
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011010
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  '
;0 00000000
;1 00011000
;2 00011000
;3 00010000
;4 00100000
;5 00000000
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Apostrophe:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00010000
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00100000
        STA     ,U     * 4      U
        RTS
; **************************************
;  (
;0 00000000
;1 00000100
;2 00001000
;3 00010000
;4 00010000
;5 00010000
;6 00001000
;7 00000100
;8 00000000
;9 00000000
Character_OpenBracket:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00000100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00010000
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  )
;0 00000000
;1 00010000
;2 00001000
;3 00000100
;4 00000100
;5 00000100
;6 00001000
;7 00010000
;8 00000000
;9 00000000
Character_CloseBracket:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00010000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00000100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  *
;0 00000000
;1 00000000
;2 00001000
;3 00101010
;4 00011100
;5 00011100
;6 00101010
;7 00001000
;8 00000000
;9 00000000
Character_Asterisk:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00101010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011100
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  +
;0 00000000
;1 00000000
;2 00001000
;3 00001000
;4 00111110
;5 00001000
;6 00001000
;7 00000000
;8 00000000
;9 00000000
Character_Plus:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00111110
        STA     ,U     * 4      U
        RTS
; **************************************
;  ,
;0 00000000
;1 00000000
;2 00000000
;3 00000000
;4 00011000
;5 00011000
;6 00010000
;7 00100000
;8 00000000
;9 00000000
Character_Comma:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011000
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00010000
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00100000
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  -
;0 00000000
;1 00000000
;2 00000000
;3 00000000
;4 00111110
;5 00000000
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Hyphen:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     ,U     * 4      U
        RTS
; **************************************
;  .
;0 00000000
;1 00000000
;2 00000000
;3 00000000
;4 00000000
;5 00000000
;6 00011000
;7 00011000
;8 00000000
;9 00000000
Character_Decimal:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011000
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  /
;0 00000000
;1 00000000
;2 00000010
;3 00000100
;4 00001000
;5 00010000
;6 00100000
;7 00000000
;8 00000000
;9 00000000
Character_Slash:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00000010
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00000100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00001000
        STA     ,U     * 4      U
        LDA     #%00010000
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100000
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  0
;0 00000000
;1 00011100
;2 00100010
;3 00100110
;4 00101010
;5 00110010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_0:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00100110
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00101010
        STA     ,U     * 4      U
        LDA     #%00110010
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  1
;0 00000000
;1 00001000
;2 00011000
;3 00001000
;4 00001000
;5 00001000
;6 00001000
;7 00011100
;8 00000000
;9 00000000
Character_1:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011000
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  2
;0 00000000
;1 00011100
;2 00100010
;3 00000010
;4 00011100
;5 00100000
;6 00100000
;7 00111110
;8 00000000
;9 00000000
Character_2:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00000010
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00100000
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00111110
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  3
;0 00000000
;1 00011100
;2 00100010
;3 00000010
;4 00001100
;5 00000010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_3:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00000010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00001100
        STA     ,U     * 4      U
        RTS
; **************************************
;  4
;0 00000000
;1 00000100
;2 00001100
;3 00010100
;4 00100100
;5 00111110
;6 00000100
;7 00000100
;8 00000000
;9 00000000
Character_4:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00000100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00001100
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00010100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00100100
        STA     ,U     * 4      U
        LDA     #%00111110
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  5
;0 00000000
;1 00111110
;2 00100000
;3 00111100
;4 00000010
;5 00000010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_5:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00111100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00000010
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100010
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  6
;0 00000000
;1 00001100
;2 00010000
;3 00100000
;4 00111100
;5 00100010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_6:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001100
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00010000
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00100000
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00111100
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  7
;0 00000000
;1 00111110
;2 00000010
;3 00000100
;4 00001000
;5 00010000
;6 00100000
;7 00100000
;8 00000000
;9 00000000
Character_7:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00000010
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00000100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00001000
        STA     ,U     * 4      U
        LDA     #%00010000
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100000
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  8
;0 00000000
;1 00011100
;2 00100010
;3 00100010
;4 00011100
;5 00100010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_8:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  9
;0 00000000
;1 00011100
;2 00100010
;3 00100010
;4 00011110
;5 00000010
;6 00000100
;7 00011000
;8 00000000
;9 00000000
Character_9:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00011110
        STA     ,U     * 4      U
        LDA     #%00000010
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00000100
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011000
        STA     BytesPerRow_HIG139*3,U   * 7
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
;8 00000000
;9 00000000
Character_Colon:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  ;
;0 00000000
;1 00011000
;2 00011000
;3 00000000
;4 00011000
;5 00011000
;6 00010000
;7 00100000
;8 00000000
;9 00000000
Character_Semicolon:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00010000
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00100000
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  <
;0 00000000
;1 00000100
;2 00001000
;3 00010000
;4 00100000
;5 00010000
;6 00001000
;7 00000100
;8 00000000
;9 00000000
Character_Less:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00000100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00010000
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100000
        STA     ,U     * 4      U
        RTS
; **************************************
;  =
;0 00000000
;1 00000000
;2 00000000
;3 00111100
;4 00000000
;5 00111100
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Equal:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  >
;0 00000000
;1 00010000
;2 00001000
;3 00000100
;4 00000010
;5 00000100
;6 00001000
;7 00010000
;8 00000000
;9 00000000
Character_Great:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00010000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00000100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00000010
        STA     ,U     * 4      U
        RTS
; **************************************
;  ?
;0 00000000
;1 00011100
;2 00100010
;3 00000010
;4 00000100
;5 00001000
;6 00000000
;7 00001000
;8 00000000
;9 00000000
Character_QuestionMark:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00000010
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00000100
        STA     ,U     * 4      U
        LDA     #%00001000
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  @
;0 00000000
;1 00011100
;2 00100010
;3 00000010
;4 00011010
;5 00100110
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_AtSign:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00000010
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00011010
        STA     ,U     * 4      U
        LDA     #%00100110
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  A
;0 00000000
;1 00001000
;2 00010100
;3 00100010
;4 00100010
;5 00111110
;6 00100010
;7 00100010
;8 00000000
;9 00000000
Character_A:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00010100
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00100010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00111110
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  B
;0 00000000
;1 00111100
;2 00010010
;3 00010010
;4 00011100
;5 00010010
;6 00010010
;7 00111100
;8 00000000
;9 00000000
Character_B:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00010010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011100
        STA     ,U     * 4      U
        RTS
; **************************************
;  C
;0 00000000
;1 00011100
;2 00100010
;3 00100000
;4 00100000
;5 00100000
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_C:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00100000
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  D
;0 00000000
;1 00111100
;2 00010010
;3 00010010
;4 00010010
;5 00010010
;6 00010010
;7 00111100
;8 00000000
;9 00000000
Character_D:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00010010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  E
;0 00000000
;1 00111110
;2 00100000
;3 00100000
;4 00111000
;5 00100000
;6 00100000
;7 00111110
;8 00000000
;9 00000000
Character_E:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00111000
        STA     ,U     * 4      U
        RTS
; **************************************
;  F
;0 00000000
;1 00111110
;2 00100000
;3 00100000
;4 00111000
;5 00100000
;6 00100000
;7 00100000
;8 00000000
;9 00000000
Character_F:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00111000
        STA     ,U     * 4      U
        RTS
; **************************************
;  G
;0 00000000
;1 00011110
;2 00100000
;3 00100000
;4 00100110
;5 00100010
;6 00100010
;7 00011110
;8 00000000
;9 00000000
Character_G:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011110
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00100110
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  H
;0 00000000
;1 00100010
;2 00100010
;3 00100010
;4 00111110
;5 00100010
;6 00100010
;7 00100010
;8 00000000
;9 00000000
Character_H:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00111110
        STA     ,U     * 4      U
        RTS
; **************************************
;  I
;0 00000000
;1 00011100
;2 00001000
;3 00001000
;4 00001000
;5 00001000
;6 00001000
;7 00011100
;8 00000000
;9 00000000
Character_I:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  J
;0 00000000
;1 00000010
;2 00000010
;3 00000010
;4 00000010
;5 00000010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_J:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00000010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100010
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  K
;0 00000000
;1 00100010
;2 00100100
;3 00101000
;4 00110000
;5 00101000
;6 00100100
;7 00100010
;8 00000000
;9 00000000
Character_K:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100100
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00101000
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00110000
        STA     ,U     * 4      U
        RTS
; **************************************
;  L
;0 00000000
;1 00100000
;2 00100000
;3 00100000
;4 00100000
;5 00100000
;6 00100000
;7 00111110
;8 00000000
;9 00000000
Character_L:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00111110
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  M
;0 00000000
;1 00100010
;2 00110110
;3 00101010
;4 00101010
;5 00100010
;6 00100010
;7 00100010
;8 00000000
;9 00000000
Character_M:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00110110
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00101010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        RTS
; **************************************
;  N
;0 00000000
;1 00100010
;2 00100010
;3 00110010
;4 00101010
;5 00100110
;6 00100010
;7 00100010
;8 00000000
;9 00000000
Character_N:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00110010
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00101010
        STA     ,U     * 4      U
        LDA     #%00100110
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  O
;0 00000000
;1 00011100
;2 00100010
;3 00100010
;4 00100010
;5 00100010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_O:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  P
;0 00000000
;1 00111100
;2 00100010
;3 00100010
;4 00111100
;5 00100000
;6 00100000
;7 00100000
;8 00000000
;9 00000000
Character_P:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00100000
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  Q
;0 00000000
;1 00011100
;2 00100010
;3 00100010
;4 00100010
;5 00101010
;6 00100100
;7 00011010
;8 00000000
;9 00000000
Character_Q:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        LDA     #%00101010
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100100
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011010
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  R
;0 00000000
;1 00111100
;2 00100010
;3 00100010
;4 00111100
;5 00101000
;6 00100100
;7 00100010
;8 00000000
;9 00000000
Character_R:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00101000
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100100
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  S
;0 00000000
;1 00011100
;2 00100010
;3 00100000
;4 00011100
;5 00000010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_S:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00100000
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00000010
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  T
;0 00000000
;1 00111110
;2 00001000
;3 00001000
;4 00001000
;5 00001000
;6 00001000
;7 00001000
;8 00000000
;9 00000000
Character_T:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  U
;0 00000000
;1 00100010
;2 00100010
;3 00100010
;4 00100010
;5 00100010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_U:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  V
;0 00000000
;1 00100010
;2 00100010
;3 00100010
;4 00010100
;5 00010100
;6 00001000
;7 00001000
;8 00000000
;9 00000000
Character_V:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00010100
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00001000
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  W
;0 00000000
;1 00100010
;2 00100010
;3 00100010
;4 00100010
;5 00101010
;6 00110110
;7 00100010
;8 00000000
;9 00000000
Character_W:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00101010
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00110110
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  X
;0 00000000
;1 00100010
;2 00100010
;3 00010100
;4 00001000
;5 00010100
;6 00100010
;7 00100010
;8 00000000
;9 00000000
Character_X:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00010100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00001000
        STA     ,U     * 4      U
        RTS
; **************************************
;  Y
;0 00000000
;1 00100010
;2 00100010
;3 00010100
;4 00001000
;5 00001000
;6 00001000
;7 00001000
;8 00000000
;9 00000000
Character_Y:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00010100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00001000
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  Z
;0 00000000
;1 00111110
;2 00000010
;3 00000100
;4 00001000
;5 00010000
;6 00100000
;7 00111110
;8 00000000
;9 00000000
Character_Z:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00000010
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00000100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00001000
        STA     ,U     * 4      U
        LDA     #%00010000
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100000
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  [
;0 00000000
;1 00011100
;2 00010000
;3 00010000
;4 00010000
;5 00010000
;6 00010000
;7 00011100
;8 00000000
;9 00000000
Character_OpenSBracket:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00010000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  \
;0 00000000
;1 00100000
;2 00010000
;3 00001000
;4 00000100
;5 00000010
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Backslash:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00010000
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00001000
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00000100
        STA     ,U     * 4      U
        LDA     #%00000010
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  ]
;0 00000000
;1 00011100
;2 00000100
;3 00000100
;4 00000100
;5 00000100
;6 00000100
;7 00011100
;8 00000000
;9 00000000
Character_CloseSBracket:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00000100
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  ^
;0 00000000
;1 00001000
;2 00010100
;3 00100010
;4 00000000
;5 00000000
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Caret:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00010100
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00100010
        STA     -BytesPerRow_HIG139,U  * 3
        RTS
; **************************************
;  _
;0 00000000
;1 00000000
;2 00000000
;3 00000000
;4 00000000
;5 00000000
;6 00000000
;7 00111110
;8 00000000
;9 00000000
Character_Underscore:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  `
;0 00000000
;1 00011000
;2 00011000
;3 00001000
;4 00000100
;5 00000000
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Backtick:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00001000
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00000100
        STA     ,U     * 4      U
        RTS
; **************************************
;  a
;0 00000000
;1 00000000
;2 00000000
;3 00011100
;4 00000010
;5 00011110
;6 00100010
;7 00011110
;8 00000000
;9 00000000
Character_a:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00000010
        STA     ,U     * 4      U
        LDA     #%00011110
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  b
;0 00000000
;1 00100000
;2 00100000
;3 00101100
;4 00110010
;5 00100010
;6 00110010
;7 00101100
;8 00000000
;9 00000000
Character_b:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00101100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00110010
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00100010
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  c
;0 00000000
;1 00000000
;2 00000000
;3 00011100
;4 00100010
;5 00100000
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_c:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00100000
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  d
;0 00000000
;1 00000010
;2 00000010
;3 00011010
;4 00100110
;5 00100010
;6 00100110
;7 00011010
;8 00000000
;9 00000000
Character_d:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00000010
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00011010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100110
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00100010
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  e
;0 00000000
;1 00000000
;2 00000000
;3 00011100
;4 00100010
;5 00111110
;6 00100000
;7 00011100
;8 00000000
;9 00000000
Character_e:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     ,U     * 4      U
        LDA     #%00111110
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100000
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  f
;0 00000000
;1 00001000
;2 00010100
;3 00010000
;4 00111000
;5 00010000
;6 00010000
;7 00010000
;8 00000000
;9 00000000
Character_f:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00010100
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00010000
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00111000
        STA     ,U     * 4      U
        RTS
; **************************************
;  g
;0 00000000
;1 00000000
;2 00000000
;3 00011010
;4 00100110
;5 00100110
;6 00011010
;7 00000010
;8 00100010
;9 00011100
Character_g:
        CLRA
        STA     ,U     * 0
        STA     BytesPerRow_HIG139,U   * 1
        STA     BytesPerRow_HIG139*2,U   * 2
        LEAU    BytesPerRow_HIG139*6,U
        LDA     #%00011010
        STA     -BytesPerRow_HIG139*3,U  * 3
        STA     ,U     * 6      U
        LDA     #%00100110
        STA     -BytesPerRow_HIG139*2,U  * 4
        STA     -BytesPerRow_HIG139,U  * 5
        LDA     #%00000010
        STA     BytesPerRow_HIG139,U   * 7
        LDA     #%00100010
        STA     BytesPerRow_HIG139*2,U   * 8
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 9
        RTS
; **************************************
;  h
;0 00000000
;1 00100000
;2 00100000
;3 00101100
;4 00110010
;5 00100010
;6 00100010
;7 00100010
;8 00000000
;9 00000000
Character_h:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00101100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00110010
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  i
;0 00000000
;1 00001000
;2 00000000
;3 00011000
;4 00001000
;5 00001000
;6 00001000
;7 00011100
;8 00000000
;9 00000000
Character_i:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011000
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  j
;0 00000000
;1 00000000
;2 00000000
;3 00000010
;4 00000000
;5 00000010
;6 00000010
;7 00000010
;8 00100010
;9 00011100
Character_j:
        CLRA
        STA     ,U     * 0
        STA     BytesPerRow_HIG139,U   * 1
        STA     BytesPerRow_HIG139*2,U   * 2
        LEAU    BytesPerRow_HIG139*6,U
        STA     -BytesPerRow_HIG139*2,U  * 4
        LDA     #%00000010
        STA     -BytesPerRow_HIG139*3,U  * 3
        STA     -BytesPerRow_HIG139,U  * 5
        STA     ,U     * 6      U
        STA     BytesPerRow_HIG139,U   * 7
        LDA     #%00100010
        STA     BytesPerRow_HIG139*2,U   * 8
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 9
        RTS
; **************************************
;  k
;0 00000000
;1 00100000
;2 00100000
;3 00100100
;4 00101000
;5 00110000
;6 00101000
;7 00100100
;8 00000000
;9 00000000
Character_k:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00100100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00101000
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00110000
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  l
;0 00000000
;1 00011000
;2 00001000
;3 00001000
;4 00001000
;5 00001000
;6 00001000
;7 00011100
;8 00000000
;9 00000000
Character_l:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011000
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  m
;0 00000000
;1 00000000
;2 00000000
;3 00110100
;4 00101010
;5 00101010
;6 00101010
;7 00101010
;8 00000000
;9 00000000
Character_m:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00110100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00101010
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  n
;0 00000000
;1 00000000
;2 00000000
;3 00101100
;4 00110010
;5 00100010
;6 00100010
;7 00100010
;8 00000000
;9 00000000
Character_n:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00101100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00110010
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  o
;0 00000000
;1 00000000
;2 00000000
;3 00011100
;4 00100010
;5 00100010
;6 00100010
;7 00011100
;8 00000000
;9 00000000
Character_o:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011100
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00100010
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  p
;0 00000000
;1 00000000
;2 00000000
;3 00101100
;4 00110010
;5 00100010
;6 00110010
;7 00101100
;8 00100000
;9 00100000
Character_p:
        CLRA
        STA     ,U     * 0
        STA     BytesPerRow_HIG139,U   * 1
        STA     BytesPerRow_HIG139*2,U   * 2
        LEAU    BytesPerRow_HIG139*6,U
        LDA     #%00101100
        STA     -BytesPerRow_HIG139*3,U  * 3
        STA     BytesPerRow_HIG139,U   * 7
        LDA     #%00110010
        STA     -BytesPerRow_HIG139*2,U  * 4
        STA     ,U     * 6      U
        LDA     #%00100010
        STA     -BytesPerRow_HIG139,U  * 5
        LDA     #%00100000
        STA     BytesPerRow_HIG139*2,U   * 8
        STA     BytesPerRow_HIG139*3,U   * 9
        RTS
; **************************************
;  q
;0 00000000
;1 00000000
;2 00000000
;3 00011010
;4 00100110
;5 00100010
;6 00100110
;7 00011010
;8 00000010
;9 00000010
Character_q:
        CLRA
        STA     ,U     * 0
        STA     BytesPerRow_HIG139,U   * 1
        STA     BytesPerRow_HIG139*2,U   * 2
        LEAU    BytesPerRow_HIG139*6,U
        LDA     #%00011010
        STA     -BytesPerRow_HIG139*3,U  * 3
        STA     BytesPerRow_HIG139,U   * 7
        LDA     #%00100110
        STA     -BytesPerRow_HIG139*2,U  * 4
        STA     ,U     * 6      U
        LDA     #%00100010
        STA     -BytesPerRow_HIG139,U  * 5
        LDA     #%00000010
        STA     BytesPerRow_HIG139*2,U   * 8
        STA     BytesPerRow_HIG139*3,U   * 9
        RTS
; **************************************
;  r
;0 00000000
;1 00000000
;2 00000000
;3 00101100
;4 00110010
;5 00100000
;6 00100000
;7 00100000
;8 00000000
;9 00000000
Character_r:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00101100
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00110010
        STA     ,U     * 4      U
        LDA     #%00100000
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  s
;0 00000000
;1 00000000
;2 00000000
;3 00011110
;4 00100000
;5 00011100
;6 00000010
;7 00111100
;8 00000000
;9 00000000
Character_s:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00011110
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00100000
        STA     ,U     * 4      U
        LDA     #%00011100
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00000010
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00111100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  t
;0 00000000
;1 00001000
;2 00001000
;3 00111110
;4 00001000
;5 00001000
;6 00001010
;7 00000100
;8 00000000
;9 00000000
Character_t:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00111110
        STA     -BytesPerRow_HIG139,U  * 3
        LDA     #%00001010
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00000100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  u
;0 00000000
;1 00000000
;2 00000000
;3 00100010
;4 00100010
;5 00100010
;6 00100110
;7 00011010
;8 00000000
;9 00000000
Character_u:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00100110
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00011010
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  v
;0 00000000
;1 00000000
;2 00000000
;3 00100010
;4 00100010
;5 00100010
;6 00010100
;7 00001000
;8 00000000
;9 00000000
Character_v:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00010100
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00001000
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  w
;0 00000000
;1 00000000
;2 00000000
;3 00100010
;4 00100010
;5 00101010
;6 00101010
;7 00010100
;8 00000000
;9 00000000
Character_w:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     ,U     * 4      U
        LDA     #%00101010
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00010100
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  x
;0 00000000
;1 00000000
;2 00000000
;3 00100010
;4 00010100
;5 00001000
;6 00010100
;7 00100010
;8 00000000
;9 00000000
Character_x:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00100010
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00010100
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00001000
        STA     BytesPerRow_HIG139,U   * 5
        RTS
; **************************************
;  y
;0 00000000
;1 00000000
;2 00000000
;3 00100010
;4 00100010
;5 00100010
;6 00011110
;7 00000010
;8 00100010
;9 00011100
Character_y:
        CLRA
        STA     ,U     * 0
        STA     BytesPerRow_HIG139,U   * 1
        STA     BytesPerRow_HIG139*2,U   * 2
        LEAU    BytesPerRow_HIG139*6,U
        LDA     #%00100010
        STA     -BytesPerRow_HIG139*3,U  * 3
        STA     -BytesPerRow_HIG139*2,U  * 4
        STA     -BytesPerRow_HIG139,U  * 5
        STA     BytesPerRow_HIG139*2,U   * 8
        LDA     #%00011110
        STA     ,U     * 6      U
        LDA     #%00000010
        STA     BytesPerRow_HIG139,U   * 7
        LDA     #%00011100
        STA     BytesPerRow_HIG139*3,U   * 9
        RTS
; **************************************
;  z
;0 00000000
;1 00000000
;2 00000000
;3 00111110
;4 00000100
;5 00001000
;6 00010000
;7 00111110
;8 00000000
;9 00000000
Character_z:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00111110
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00000100
        STA     ,U     * 4      U
        LDA     #%00001000
        STA     BytesPerRow_HIG139,U   * 5
        LDA     #%00010000
        STA     BytesPerRow_HIG139*2,U   * 6
        RTS
; **************************************
;  {
;0 00000000
;1 00000100
;2 00001000
;3 00001000
;4 00010000
;5 00001000
;6 00001000
;7 00000100
;8 00000000
;9 00000000
Character_OpenCurlyBracket:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00000100
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00010000
        STA     ,U     * 4      U
        RTS
; **************************************
;  |
;0 00000000
;1 00001000
;2 00001000
;3 00001000
;4 00000000
;5 00001000
;6 00001000
;7 00001000
;8 00000000
;9 00000000
Character_Pipe:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        RTS
; **************************************
;  }
;0 00000000
;1 00010000
;2 00001000
;3 00001000
;4 00000100
;5 00001000
;6 00001000
;7 00010000
;8 00000000
;9 00000000
Character_CloseCurlyBracket:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00010000
        STA     -BytesPerRow_HIG139*3,U  * 1
        STA     BytesPerRow_HIG139*3,U   * 7
        LDA     #%00001000
        STA     -BytesPerRow_HIG139*2,U  * 2
        STA     -BytesPerRow_HIG139,U  * 3
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        LDA     #%00000100
        STA     ,U     * 4      U
        RTS
; **************************************
;  ~
;0 00000000
;1 00010000
;2 00101010
;3 00000100
;4 00000000
;5 00000000
;6 00000000
;7 00000000
;8 00000000
;9 00000000
Character_Tilde:
        CLRA
        STA     ,U     * 0
        LEAU    BytesPerRow_HIG139*4,U
        STA     ,U     * 4      U
        STA     BytesPerRow_HIG139,U   * 5
        STA     BytesPerRow_HIG139*2,U   * 6
        STA     BytesPerRow_HIG139*3,U   * 7
        STA     BytesPerRow_HIG139*4,U   * 8
        STA     BytesPerRow_HIG139*5,U   * 9
        LDA     #%00010000
        STA     -BytesPerRow_HIG139*3,U  * 1
        LDA     #%00101010
        STA     -BytesPerRow_HIG139*2,U  * 2
        LDA     #%00000100
        STA     -BytesPerRow_HIG139,U  * 3
        RTS