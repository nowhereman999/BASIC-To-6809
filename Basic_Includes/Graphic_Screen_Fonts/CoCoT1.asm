; Font Name: CoCoT1
; Description: Pixel match of the Motorola MC6847T1 VDG chip
;              Matches the font of newer CoCo 2's
;              Since the pixels are single dots, this font will produce artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
CharJumpTable:
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
Character_Blank:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_Exclamation:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     64,U   * 6      U+64
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     96,U   * 7      U+96
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
Character_Quote:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00010100
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
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
Character_Pound:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     ,U     * 4      U
        LDA     #%00010100
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00111110
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
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
Character_DollarSign:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00011110
        STA     -64,U  * 2      U-64
        LDA     #%00100000
        STA     -32,U  * 3      U-32
        LDA     #%00011100
        STA     ,U     * 4      U
        LDA     #%00000010
        STA     32,U   * 5      U+32
        LDA     #%00111100
        STA     64,U   * 6      U+64
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
Character_Percent:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00110000
        STA     -96,U  * 1      U-96
        LDA     #%00110010
        STA     -64,U  * 2      U-64
        LDA     #%00000100
        STA     -32,U  * 3      U-32
        LDA     #%00001000
        STA     ,U     * 4      U
        LDA     #%00010000
        STA     32,U   * 5      U+32
        LDA     #%00100110
        STA     64,U   * 6      U+64
        LDA     #%00000110
        STA     96,U   * 7      U+96
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
Character_Ampersand:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00010000
        STA     -96,U  * 1      U-96
        STA     ,U     * 4      U
        LDA     #%00101000
        STA     -64,U  * 2      U-64
        LDA     #%00101000
        STA     -32,U  * 3      U-32
        LDA     #%00101010
        STA     32,U   * 5      U+32
        LDA     #%00100100
        STA     64,U   * 6      U+64
        LDA     #%00011010
        STA     96,U   * 7      U+96
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
Character_Apostrophe:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00011000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00010000
        STA     -32,U  * 3      U-32
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
Character_OpenBracket:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00000100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00010000
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
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
Character_CloseBracket:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00010000
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00000100
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
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
Character_Asterisk:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     96,U   * 7      U+96
        LDA     #%00101010
        STA     -32,U  * 3      U-32
        STA     64,U   * 6      U+64
        LDA     #%00011100
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
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
Character_Plus:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_Comma:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        LDA     #%00011000
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00010000
        STA     64,U   * 6      U+64
        LDA     #%00100000
        STA     96,U   * 7      U+96
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
Character_Hyphen:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_Decimal:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00011000
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_Slash:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00000010
        STA     -64,U  * 2      U-64
        LDA     #%00000100
        STA     -32,U  * 3      U-32
        LDA     #%00001000
        STA     ,U     * 4      U
        LDA     #%00010000
        STA     32,U   * 5      U+32
        LDA     #%00100000
        STA     64,U   * 6      U+64
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
Character_0:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00100110
        STA     -32,U  * 3      U-32
        LDA     #%00101010
        STA     ,U     * 4      U
        LDA     #%00110010
        STA     32,U   * 5      U+32
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
Character_1:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00011000
        STA     -64,U  * 2      U-64
        LDA     #%00011100
        STA     96,U   * 7      U+96
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
Character_2:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        LDA     #%00000010
        STA     -32,U  * 3      U-32
        LDA     #%00100000
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00111110
        STA     96,U   * 7      U+96
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
Character_3:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00000010
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
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
Character_4:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00000100
        STA     -96,U  * 1      U-96
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00001100
        STA     -64,U  * 2      U-64
        LDA     #%00010100
        STA     -32,U  * 3      U-32
        LDA     #%00100100
        STA     ,U     * 4      U
        LDA     #%00111110
        STA     32,U   * 5      U+32
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
Character_5:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00111110
        STA     -96,U  * 1      U-96
        LDA     #%00100000
        STA     -64,U  * 2      U-64
        LDA     #%00111100
        STA     -32,U  * 3      U-32
        LDA     #%00000010
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00100010
        STA     64,U   * 6      U+64
        LDA     #%00011100
        STA     96,U   * 7      U+96
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
Character_6:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00001100
        STA     -96,U  * 1      U-96
        LDA     #%00010000
        STA     -64,U  * 2      U-64
        LDA     #%00100000
        STA     -32,U  * 3      U-32
        LDA     #%00111100
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00011100
        STA     96,U   * 7      U+96
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
Character_7:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00111110
        STA     -96,U  * 1      U-96
        LDA     #%00000010
        STA     -64,U  * 2      U-64
        LDA     #%00000100
        STA     -32,U  * 3      U-32
        LDA     #%00001000
        STA     ,U     * 4      U
        LDA     #%00010000
        STA     32,U   * 5      U+32
        LDA     #%00100000
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_8:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     ,U     * 4      U
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_9:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        LDA     #%00011110
        STA     ,U     * 4      U
        LDA     #%00000010
        STA     32,U   * 5      U+32
        LDA     #%00000100
        STA     64,U   * 6      U+64
        LDA     #%00011000
        STA     96,U   * 7      U+96
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
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     ,U     * 4      U
        STA     96,U   * 7      U+96
        LDA     #%00011000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_Semicolon:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -32,U  * 3      U-32
        LDA     #%00011000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00010000
        STA     64,U   * 6      U+64
        LDA     #%00100000
        STA     96,U   * 7      U+96
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
Character_Less:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00000100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00010000
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
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
Character_Equal:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     ,U     * 4      U
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00111100
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
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
Character_Great:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00010000
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00000100
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
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
Character_QuestionMark:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     64,U   * 6      U+64
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        LDA     #%00000010
        STA     -32,U  * 3      U-32
        LDA     #%00000100
        STA     ,U     * 4      U
        LDA     #%00001000
        STA     32,U   * 5      U+32
        STA     96,U   * 7      U+96
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
Character_AtSign:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00000010
        STA     -32,U  * 3      U-32
        LDA     #%00011010
        STA     ,U     * 4      U
        LDA     #%00100110
        STA     32,U   * 5      U+32
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
Character_A:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        LDA     #%00010100
        STA     -64,U  * 2      U-64
        LDA     #%00100010
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00111110
        STA     32,U   * 5      U+32
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
Character_B:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00111100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00010010
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_C:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00100000
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
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
Character_D:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U  * 0         U
        LEAU    128,U
        LDA     #%00111100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00010010
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_E:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U  * 0         U
        LEAU    128,U
        LDA     #%00111110
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00100000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_F:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U  * 0         U
        LEAU    128,U
        LDA     #%00111110
        STA     -96,U  * 1      U-96
        LDA     #%00100000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_G:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011110
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00100000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        LDA     #%00100110
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_H:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_I:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_J:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00000010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00100010
        STA     64,U   * 6      U+64
        LDA     #%00011100
        STA     96,U   * 7      U+96
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
Character_K:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00100100
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00101000
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
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
Character_L:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00111110
        STA     96,U   * 7      U+96
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
Character_M:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00110110
        STA     -64,U  * 2      U-64
        LDA     #%00101010
        STA     -32,U  * 3      U-32
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
Character_N:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00110010
        STA     -32,U  * 3      U-32
        LDA     #%00101010
        STA     ,U     * 4      U
        LDA     #%00100110
        STA     32,U   * 5      U+32
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
Character_O:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_P:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00111100
        STA     -96,U  * 1      U-96
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        LDA     #%00100000
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_Q:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        LDA     #%00101010
        STA     32,U   * 5      U+32
        LDA     #%00100100
        STA     64,U   * 6      U+64
        LDA     #%00011010
        STA     96,U   * 7      U+96
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
Character_R:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00111100
        STA     -96,U  * 1      U-96
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00101000
        STA     32,U   * 5      U+32
        LDA     #%00100100
        STA     64,U   * 6      U+64
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
Character_S:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     ,U     * 4      U
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        LDA     #%00100000
        STA     -32,U  * 3      U-32
        LDA     #%00000010
        STA     32,U   * 5      U+32
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
Character_T:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00111110
        STA     -96,U  * 1      U-96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_U:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00011100
        STA     96,U   * 7      U+96
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
Character_V:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        LDA     #%00010100
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00001000
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_W:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     96,U   * 7      U+96
        LDA     #%00101010
        STA     32,U   * 5      U+32
        LDA     #%00110110
        STA     64,U   * 6      U+64
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
Character_X:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00010100
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
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
Character_Y:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00010100
        STA     -32,U  * 3      U-32
        LDA     #%00001000
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_Z:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00111110
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00000010
        STA     -64,U  * 2      U-64
        LDA     #%00000100
        STA     -32,U  * 3      U-32
        LDA     #%00001000
        STA     ,U     * 4      U
        LDA     #%00010000
        STA     32,U   * 5      U+32
        LDA     #%00100000
        STA     64,U   * 6      U+64
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
Character_OpenSBracket:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00010000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_Backslash:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00100000
        STA     -96,U  * 1      U-96
        LDA     #%00010000
        STA     -64,U  * 2      U-64
        LDA     #%00001000
        STA     -32,U  * 3      U-32
        LDA     #%00000100
        STA     ,U     * 4      U
        LDA     #%00000010
        STA     32,U   * 5      U+32
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
Character_CloseSBracket:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00000100
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_Caret:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        LDA     #%00010100
        STA     -64,U  * 2      U-64
        LDA     #%00100010
        STA     -32,U  * 3      U-32
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
Character_Underscore:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00111110
        STA     96,U   * 7      U+96
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
Character_Backtick:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00011000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00001000
        STA     -32,U  * 3      U-32
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
Character_a:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00011100
        STA     -32,U  * 3      U-32
        LDA     #%00000010
        STA     ,U     * 4      U
        LDA     #%00011110
        STA     32,U   * 5      U+32
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     64,U   * 6      U+64
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
Character_b:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00101100
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00110010
        STA     ,U     * 4      U
        STA     64,U   * 6      U+64
        LDA     #%00100010
        STA     32,U   * 5      U+32
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
Character_c:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00011100
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     ,U     * 4      U
        STA     64,U   * 6      U+64
        LDA     #%00100000
        STA     32,U   * 5      U+32
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
Character_d:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U  * 0         U
        LEAU    128,U
        LDA     #%00000010
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00011010
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00100110
        STA     ,U     * 4      U
        STA     64,U   * 6      U+64
        LDA     #%00100010
        STA     32,U   * 5      U+32
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
Character_e:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00011100
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     ,U     * 4      U
        LDA     #%00111110
        STA     32,U   * 5      U+32
        LDA     #%00100000
        STA     64,U   * 6      U+64
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
Character_f:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U  * 0         U
        LEAU    128,U
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        LDA     #%00010100
        STA     -64,U  * 2      U-64
        LDA     #%00010000
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        STA     32,U   * 1
        STA     64,U   * 2
        LEAU    128+64,U
        LDA     #%00011010
        STA     -96,U  * 3      U-96
        STA     ,U     * 6      U
        LDA     #%00100110
        STA     -64,U  * 4      U-64
        STA     -32,U  * 5      U-32
        LDA     #%00000010
        STA     32,U   * 7      U+32
        LDA     #%00100010
        STA     64,U   * 8      U+64
        LDA     #%00011100
        STA     96,U   * 9      U+96
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
Character_h:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00101100
        STA     -32,U  * 3      U-32
        LDA     #%00110010
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_i:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -64,U  * 2      U-64
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00011000
        STA     -32,U  * 3      U-32
        LDA     #%00011100
        STA     96,U   * 7      U+96
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
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        STA     32,U   * 1
        STA     64,U   * 2
        LEAU    128+64,U
        STA     -64,U  * 4      U-64
        LDA     #%00000010
        STA     -96,U  * 3      U-96
        STA     -32,U  * 5      U-32
        STA     ,U     * 6      U
        STA     32,U   * 7      U+32
        LDA     #%00100010
        STA     64,U   * 8      U+64
        LDA     #%00011100
        STA     96,U   * 9      U+96
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
Character_k:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00100000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00100100
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00101000
        STA     ,U     * 4      U
        STA     64,U   * 6      U+64
        LDA     #%00110000
        STA     32,U   * 5      U+32
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
Character_l:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00011000
        STA     -96,U  * 1      U-96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00011100
        STA     96,U   * 7      U+96
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
Character_m:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00110100
        STA     -32,U  * 3      U-32
        LDA     #%00101010
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_n:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00101100
        STA     -32,U  * 3      U-32
        LDA     #%00110010
        STA     ,U     * 4      U
        LDA     #%00100010
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_o:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00011100
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00100010
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        STA     32,U   * 1
        STA     64,U   * 2
        LEAU    128+64,U
        LDA     #%00101100
        STA     -96,U  * 3      U-96
        STA     32,U   * 7      U+32
        LDA     #%00110010
        STA     -64,U  * 4      U-64
        STA     ,U     * 6      U
        LDA     #%00100010
        STA     -32,U  * 5      U-32
        LDA     #%00100000
        STA     64,U   * 8      U+64
        STA     96,U   * 9      U+96
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
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        STA     32,U   * 1
        STA     64,U   * 2
        LEAU    128+64,U
        LDA     #%00011010
        STA     -96,U  * 3      U-96
        STA     32,U   * 7      U+32
        LDA     #%00100110
        STA     -64,U  * 4      U-64
        STA     ,U     * 6      U
        LDA     #%00100010
        STA     -32,U  * 5      U-32
        LDA     #%00000010
        STA     64,U   * 8      U+64
        STA     96,U   * 9      U+96
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
Character_r:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00101100
        STA     -32,U  * 3      U-32
        LDA     #%00110010
        STA     ,U     * 4      U
        LDA     #%00100000
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_s:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00011110
        STA     -32,U  * 3      U-32
        LDA     #%00100000
        STA     ,U     * 4      U
        LDA     #%00011100
        STA     32,U   * 5      U+32
        LDA     #%00000010
        STA     64,U   * 6      U+64
        LDA     #%00111100
        STA     96,U   * 7      U+96
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
Character_t:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00111110
        STA     -32,U  * 3      U-32
        LDA     #%00001010
        STA     64,U   * 6      U+64
        LDA     #%00000100
        STA     96,U   * 7      U+96
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
Character_u:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00100010
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00100110
        STA     64,U   * 6      U+64
        LDA     #%00011010
        STA     96,U   * 7      U+96
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
Character_v:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00100010
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        LDA     #%00010100
        STA     64,U   * 6      U+64
        LDA     #%00001000
        STA     96,U   * 7      U+96
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
Character_w:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00100010
        STA     -32,U  * 3      U-32
        STA     ,U     * 4      U
        LDA     #%00101010
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        LDA     #%00010100
        STA     96,U   * 7      U+96
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
Character_x:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00100010
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00010100
        STA     ,U     * 4      U
        STA     64,U   * 6      U+64
        LDA     #%00001000
        STA     32,U   * 5      U+32
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
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        STA     32,U   * 1
        STA     64,U   * 2
        LEAU    128+64,U
        LDA     #%00100010
        STA     -96,U  * 3      U-96
        STA     -64,U  * 4      U-64
        STA     -32,U  * 5      U-32
        STA     64,U   * 8      U+64
        LDA     #%00011110
        STA     ,U     * 6      U
        LDA     #%00000010
        STA     32,U   * 7      U+32
        LDA     #%00011100
        STA     96,U   * 9      U+96
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
Character_z:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        LDA     #%00111110
        STA     -32,U  * 3      U-32
        STA     96,U   * 7      U+96
        LDA     #%00000100
        STA     ,U     * 4      U
        LDA     #%00001000
        STA     32,U   * 5      U+32
        LDA     #%00010000
        STA     64,U   * 6      U+64
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
Character_OpenCurlyBracket:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00000100
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_Pipe:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     ,U     * 4      U
        LDA     #%00001000
        STA     -96,U  * 1      U-96
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
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
Character_CloseCurlyBracket:
        opt     cd
        opt     cc
        opt     ct
        CLR     ,U     * 0      U
        LEAU    128,U
        LDA     #%00010000
        STA     -96,U  * 1      U-96
        STA     96,U   * 7      U+96
        LDA     #%00001000
        STA     -64,U  * 2      U-64
        STA     -32,U  * 3      U-32
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
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
Character_Tilde:
        opt     cd
        opt     cc
        opt     ct
        CLRA
        STA     ,U     * 0      U
        LEAU    128,U
        STA     ,U     * 4      U
        STA     32,U   * 5      U+32
        STA     64,U   * 6      U+64
        STA     96,U   * 7      U+96
        LDA     #%00010000
        STA     -96,U  * 1      U-96
        LDA     #%00101010
        STA     -64,U  * 2      U-64
        LDA     #%00000100
        STA     -32,U  * 3      U-32
        RTS