; Font Name: CoCoT1
; Description: Pixel match of the Motorola MC6847T1 VDG chip
;              Matches the font of newer CoCo 2's
;              Since the pixels are single dots, this font will produce artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     10
CharJumpTable_HIG119:
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
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011101 1101110111011101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Blank:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        RTS
; **************************************
; !
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1110110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Exclamation:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; "
;0 1101110111011101 1101110111011101
;1 1101110111011110 1101111011011101
;2 1101110111011110 1101111011011101
;3 1101110111011110 1101111011011101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Quote:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        RTS
; **************************************
; #
;0 1101110111011101 1101110111011101
;1 1101110111011110 1101111011011101
;2 1101110111011110 1101111011011101
;3 1101110111101110 1110111011101101
;4 1101110111011101 1101110111011101
;5 1101110111101110 1110111011101101
;6 1101110111011110 1101111011011101
;7 1101110111011110 1101111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Pound:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; $
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011110 1110111011101101
;3 1101110111101101 1101110111011101
;4 1101110111011110 1110111011011101
;5 1101110111011101 1101110111101101
;6 1101110111101110 1110111011011101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_DollarSign:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     ,U                         * 4A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1110111011011101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119*2,U     * 6A
        RTS
; **************************************
; %
;0 1101110111011101 1101110111011101
;1 1101110111101110 1101110111011101
;2 1101110111101110 1101110111101101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1110110111011101
;5 1101110111011110 1101110111011101
;6 1101110111101101 1101111011101101
;7 1101110111011101 1101111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Percent:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1101111011101101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; &
;0 1101110111011101 1101110111011101
;1 1101110111011110 1101110111011101
;2 1101110111101101 1110110111011101
;3 1101110111101101 1110110111011101
;4 1101110111011110 1101110111011101
;5 1101110111101101 1110110111101101
;6 1101110111101101 1101111011011101
;7 1101110111011110 1110110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Ampersand:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1110110111101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101111011011101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; '
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110110111011101
;2 1101110111011110 1110110111011101
;3 1101110111011110 1101110111011101
;4 1101110111101101 1101110111011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Apostrophe:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        RTS
; **************************************
; (
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101111011011101
;2 1101110111011101 1110110111011101
;3 1101110111011110 1101110111011101
;4 1101110111011110 1101110111011101
;5 1101110111011110 1101110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011101 1101111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_OpenBracket:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        RTS
; **************************************
; )
;0 1101110111011101 1101110111011101
;1 1101110111011110 1101110111011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1101111011011101
;5 1101110111011101 1101111011011101
;6 1101110111011101 1110110111011101
;7 1101110111011110 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_CloseBracket:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; *
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1110110111011101
;3 1101110111101101 1110110111101101
;4 1101110111011110 1110111011011101
;5 1101110111011110 1110111011011101
;6 1101110111101101 1110110111101101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Asterisk:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1110110111101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1110111011011101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; +
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111101110 1110111011101101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Plus:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        RTS
; **************************************
; ,
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011101 1101110111011101
;4 1101110111011110 1110110111011101
;5 1101110111011110 1110110111011101
;6 1101110111011110 1101110111011101
;7 1101110111101101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Comma:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111101101
        STD     BytesPerRow_HIG119*3,U     * 7A
        RTS
; **************************************
; -
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011101 1101110111011101
;4 1101110111101110 1110111011101101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Hyphen:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        RTS
; **************************************
; .
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011101 1101110111011101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1101110111011101
;6 1101110111011110 1110110111011101
;7 1101110111011110 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Decimal:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U

        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; /
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111101101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1110110111011101
;5 1101110111011110 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Slash:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119,U       * 5A
        RTS
; **************************************
; 0
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101111011101101
;4 1101110111101101 1110110111101101
;5 1101110111101110 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_0:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1110110111101101
        STD     2,U                        * 4B
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119,U       * 5A
        RTS
; **************************************
; 1
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011110 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1110110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_1:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; 2
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111011101 1101110111101101
;4 1101110111011110 1110111011011101
;5 1101110111101101 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111101110 1110111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_2:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; 3
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111011101 1101110111101101
;4 1101110111011101 1110111011011101
;5 1101110111011101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_3:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; 4
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101111011011101
;2 1101110111011101 1110111011011101
;3 1101110111011110 1101111011011101
;4 1101110111101101 1101111011011101
;5 1101110111101110 1110111011101101
;6 1101110111011101 1101111011011101
;7 1101110111011101 1101111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_4:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1110111011101101        
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; 5
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101110111101101 1101110111011101
;3 1101110111101110 1110111011011101
;4 1101110111011101 1101110111101101
;5 1101110111011101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_5:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119,U      * 3A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*3,U     * 7A
        RTS
; **************************************
; 6
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110111011011101
;2 1101110111011110 1101110111011101
;3 1101110111101101 1101110111011101
;4 1101110111101110 1110111011011101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_6:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        RTS
; **************************************
; 7
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101110111011101 1101110111101101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1110110111011101
;5 1101110111011110 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111101101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_7:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119,U       * 5A
        RTS
; **************************************
; 8
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111011110 1110111011011101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_8:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; 9
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111011110 1110111011101101
;5 1101110111011101 1101110111101101
;6 1101110111011101 1101111011011101
;7 1101110111011110 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_9:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        LDD     #%1101111011011101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; :
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011110 1110110111011101
;3 1101110111011110 1110110111011101
;4 1101110111011101 1101110111011101
;5 1101110111011110 1110110111011101
;6 1101110111011110 1110110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Colon:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; ;
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110110111011101
;2 1101110111011110 1110110111011101
;3 1101110111011101 1101110111011101
;4 1101110111011110 1110110111011101
;5 1101110111011110 1110110111011101
;6 1101110111011110 1101110111011101
;7 1101110111101101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Semicolon:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1110110111011101        
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111101101
        STD     BytesPerRow_HIG119*3,U     * 7A
        RTS
; **************************************
; <
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101111011011101
;2 1101110111011101 1110110111011101
;3 1101110111011110 1101110111011101
;4 1101110111101101 1101110111011101
;5 1101110111011110 1101110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011101 1101111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Less:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        RTS
; **************************************
; =
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101110 1110111011011101
;4 1101110111011101 1101110111011101
;5 1101110111101110 1110111011011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Equal:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; >
;0 1101110111011101 1101110111011101
;1 1101110111011110 1101110111011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1101110111101101
;5 1101110111011101 1101111011011101
;6 1101110111011101 1110110111011101
;7 1101110111011110 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Great:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111101101
        STD     2,U                        * 4B
        RTS
; **************************************
; ?
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111011101 1101110111101101
;4 1101110111011101 1101111011011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_QuestionMark:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101111011011101
        STD     2,U                        * 4B
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; @
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111011101 1101110111101101
;4 1101110111011110 1110110111101101
;5 1101110111101101 1101111011101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_AtSign:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110110111101101
        STD     2,U                        * 4B
        LDD     #%1101111011101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; A
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011110 1101111011011101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101110 1110111011101101
;6 1101110111101101 1101110111101101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_A:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; B
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011011101
;2 1101110111011110 1101110111101101
;3 1101110111011110 1101110111101101
;4 1101110111011110 1110111011011101
;5 1101110111011110 1101110111101101
;6 1101110111011110 1101110111101101
;7 1101110111101110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_B:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; C
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111011101
;4 1101110111101101 1101110111011101
;5 1101110111101101 1101110111011101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_C:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; D
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011011101
;2 1101110111011110 1101110111101101
;3 1101110111011110 1101110111101101
;4 1101110111011110 1101110111101101
;5 1101110111011110 1101110111101101
;6 1101110111011110 1101110111101101
;7 1101110111101110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_D:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; E
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101110111101101 1101110111011101
;3 1101110111101101 1101110111011101
;4 1101110111101110 1110110111011101
;5 1101110111101101 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111101110 1110111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_E:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        RTS
; **************************************
; F
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101110111101101 1101110111011101
;3 1101110111101101 1101110111011101
;4 1101110111101110 1110110111011101
;5 1101110111101101 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111101101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_F:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        RTS
; **************************************
; G
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011101101
;2 1101110111101101 1101110111011101
;3 1101110111101101 1101110111011101
;4 1101110111101101 1101111011101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_G:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101111011101101
        STD     2,U                        * 4B
        RTS
; **************************************
; H
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111101110 1110111011101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_H:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        RTS
; **************************************
; I
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1110110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_I:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; J
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111101101
;2 1101110111011101 1101110111101101
;3 1101110111011101 1101110111101101
;4 1101110111011101 1101110111101101
;5 1101110111011101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_J:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; K
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101101 1101111011011101
;3 1101110111101101 1110110111011101
;4 1101110111101110 1101110111011101
;5 1101110111101101 1110110111011101
;6 1101110111101101 1101111011011101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_K:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101

        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        RTS
; **************************************
; L
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111011101
;2 1101110111101101 1101110111011101
;3 1101110111101101 1101110111011101
;4 1101110111101101 1101110111011101
;5 1101110111101101 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111101110 1110111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_L:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; M
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101110 1101111011101101
;3 1101110111101101 1110110111101101
;4 1101110111101101 1110110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_M:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1110110111101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        RTS
; **************************************
; N
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101101 1101110111101101
;3 1101110111101110 1101110111101101
;4 1101110111101101 1110110111101101
;5 1101110111101101 1101111011101101
;6 1101110111101101 1101110111101101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_N:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119,U      * 3A
        LDD     #%1110110111101101
        STD     2,U                        * 4B
        LDD     #%1101111011101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; O
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_O:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; P
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111101110 1110111011011101
;5 1101110111101101 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111101101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_P:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        RTS
; **************************************
; Q
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1110110111101101
;6 1101110111101101 1101111011011101
;7 1101110111011110 1110110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Q:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1110110111101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101111011011101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; R
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111101110 1110111011011101
;5 1101110111101101 1110110111011101
;6 1101110111101101 1101111011011101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_R:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101111011011101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; S
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111011101
;4 1101110111011110 1110111011011101
;5 1101110111011101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_S:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; T
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1110110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_T:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; U
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_U:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101

        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; V
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111011110 1101111011011101
;5 1101110111011110 1101111011011101
;6 1101110111011101 1110110111011101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_V:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1101111011011101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; W
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101101 1101110111101101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1110110111101101
;6 1101110111101110 1101111011101101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_W:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110110111101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101111011101101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; X
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101101 1101110111101101
;3 1101110111011110 1101111011011101
;4 1101110111011101 1110110111011101
;5 1101110111011110 1101111011011101
;6 1101110111101101 1101110111101101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_X:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        RTS
; **************************************
; Y
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111101101
;2 1101110111101101 1101110111101101
;3 1101110111011110 1101111011011101
;4 1101110111011101 1110110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Y:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; Z
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101110111011101 1101110111101101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1110110111011101
;5 1101110111011110 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111101110 1110111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Z:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119,U       * 5A
        RTS
; **************************************
; [
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111011110 1101110111011101
;3 1101110111011110 1101110111011101
;4 1101110111011110 1101110111011101
;5 1101110111011110 1101110111011101
;6 1101110111011110 1101110111011101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_OpenSBracket:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; \
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111011101
;2 1101110111011110 1101110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1101111011011101
;5 1101110111011101 1101110111101101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Backslash:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101111011011101
        STD     2,U                        * 4B
        RTS
; **************************************
; ]
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111011101 1101111011011101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1101111011011101
;5 1101110111011101 1101111011011101
;6 1101110111011101 1101111011011101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_CloseSBracket:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; ^
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011110 1101111011011101
;3 1101110111101101 1101110111101101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Caret:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        RTS
; **************************************
; _
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011101 1101110111011101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111101110 1110111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Underscore:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; `
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110110111011101
;2 1101110111011110 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1101111011011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Backtick:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101111011011101
        STD     2,U                        * 4B
        RTS
; **************************************
; a
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011110 1110111011011101
;4 1101110111011101 1101110111101101
;5 1101110111011110 1110111011101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_a:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101110111101101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; b
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111011101
;2 1101110111101101 1101110111011101
;3 1101110111101101 1110111011011101
;4 1101110111101110 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101110 1101110111101101
;7 1101110111101101 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_b:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*2,U     * 6A
        RTS
; **************************************
; c
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011110 1110111011011101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1101110111011101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_c:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; d
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111101101
;2 1101110111011101 1101110111101101
;3 1101110111011110 1110110111101101
;4 1101110111101101 1101111011101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101111011101101
;7 1101110111011110 1110110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_d:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101111011101101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; e
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011110 1110111011011101
;4 1101110111101101 1101110111101101
;5 1101110111101110 1110111011101101
;6 1101110111101101 1101110111011101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_e:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; f
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011110 1101111011011101
;3 1101110111011110 1101110111011101
;4 1101110111101110 1110110111011101
;5 1101110111011110 1101110111011101
;6 1101110111011110 1101110111011101
;7 1101110111011110 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_f:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     2,U                        * 4B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        RTS
; **************************************
; g
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011110 1110110111101101
;4 1101110111101101 1101111011101101
;5 1101110111101101 1101111011101101
;6 1101110111011110 1110110111101101
;7 1101110111011101 1101110111101101
;8 1101110111101101 1101110111101101
;9 1101110111011110 1110111011011101
Character_g:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*5,U     * 9A
        LDD     #%1110110111101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        LDD     #%1101111011101101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        RTS
; **************************************
; h
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111011101
;2 1101110111101101 1101110111011101
;3 1101110111101101 1110111011011101
;4 1101110111101110 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_h:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        RTS
; **************************************
; i
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011110 1110110111011101
;4 1101110111011101 1110110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_i:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; j
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011101 1101110111101101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1101110111101101
;6 1101110111011101 1101110111101101
;7 1101110111011101 1101110111101101
;8 1101110111101101 1101110111101101
;9 1101110111011110 1110111011011101
Character_j:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     2,U                        * 4B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*5,U     * 9A
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        RTS
; **************************************
; k
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111011101
;2 1101110111101101 1101110111011101
;3 1101110111101101 1101111011011101
;4 1101110111101101 1110110111011101
;5 1101110111101110 1101110111011101
;6 1101110111101101 1110110111011101
;7 1101110111101101 1101111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_k:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119,U       * 5A
        RTS
; **************************************
; l
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110110111011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1110110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_l:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; m
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101110 1101111011011101
;4 1101110111101101 1110110111101101
;5 1101110111101101 1110110111101101
;6 1101110111101101 1110110111101101
;7 1101110111101101 1110110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_m:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119,U      * 3A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111101101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; n
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101101 1110111011011101
;4 1101110111101110 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_n:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        RTS
; **************************************
; o
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011110 1110111011011101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101110111101101
;7 1101110111011110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_o:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        RTS
; **************************************
; p
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101101 1110111011011101
;4 1101110111101110 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101110 1101110111101101
;7 1101110111101101 1110111011011101
;8 1101110111101101 1101110111011101
;9 1101110111101101 1101110111011101
Character_p:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*5,U     * 9A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*2,U     * 6A
        RTS
; **************************************
; q
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011110 1110110111101101
;4 1101110111101101 1101111011101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101111011101101
;7 1101110111011110 1110110111101101
;8 1101110111011101 1101110111101101
;9 1101110111011101 1101110111101101
Character_q:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*5,U     * 9A
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101111011101101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101111011101101
        RTS
; **************************************
; r
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101101 1110111011011101
;4 1101110111101110 1101110111101101
;5 1101110111101101 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101110111101101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_r:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        RTS
; **************************************
; s
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011110 1110111011101101
;4 1101110111101101 1101110111011101
;5 1101110111011110 1110111011011101
;6 1101110111011101 1101110111101101
;7 1101110111101110 1110111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_s:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119,U       * 5A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1101110111101101
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG119*3,U     * 7A
        RTS
; **************************************
; t
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011101 1110110111011101
;3 1101110111101110 1110111011101101
;4 1101110111011101 1110110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111101101
;7 1101110111011101 1101111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_t:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119,U      * 3A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        LDD     #%1110110111101101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101111011011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; u
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111101101 1101111011101101
;7 1101110111011110 1110110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_u:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101111011101101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111101101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; v
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111011110 1101111011011101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_v:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101111011011101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; w
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1110110111101101
;6 1101110111101101 1110110111101101
;7 1101110111011110 1101111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_w:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1110110111101101
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101111011011101
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; x
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101101 1101110111101101
;4 1101110111011110 1101111011011101
;5 1101110111011101 1110110111011101
;6 1101110111011110 1101111011011101
;7 1101110111101101 1101110111101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_x:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119*2,U     * 6A
        LDD     #%1101111011011101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG119+2,U     * 5B
        RTS
; **************************************
; y
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101101 1101110111101101
;4 1101110111101101 1101110111101101
;5 1101110111101101 1101110111101101
;6 1101110111011110 1110111011101101
;7 1101110111011101 1101110111101101
;8 1101110111101101 1101110111101101
;9 1101110111011110 1110111011011101
Character_y:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*5,U     * 9A
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        RTS
; **************************************
; z
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111101110 1110111011101101
;4 1101110111011101 1101111011011101
;5 1101110111011101 1110110111011101
;6 1101110111011110 1101110111011101
;7 1101110111101110 1110111011101101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_z:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1101111011011101
        STD     2,U                        * 4B
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG119+2,U     * 5B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG119*2,U     * 6A
        RTS
; **************************************
; {
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101111011011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011110 1101110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011101 1101111011011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_OpenCurlyBracket:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        RTS
; **************************************
; |
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011101 1110110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Pipe:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        RTS
; **************************************
; }
;0 1101110111011101 1101110111011101
;1 1101110111011110 1101110111011101
;2 1101110111011101 1110110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1101111011011101
;5 1101110111011101 1110110111011101
;6 1101110111011101 1110110111011101
;7 1101110111011110 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_CloseCurlyBracket:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119*2,U    * 2A
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        STD     BytesPerRow_HIG119*3,U     * 7A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        STD     -BytesPerRow_HIG119+2,U    * 3B
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        LDD     #%1101111011011101
        STD     2,U                        * 4B
        RTS
; **************************************
; ~
;0 1101110111011101 1101110111011101
;1 1101110111011110 1101110111011101
;2 1101110111101101 1110110111101101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
;8 1101110111011101 1101110111011101
;9 1101110111011101 1101110111011101
Character_Tilde:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG119*4,U
        STD     -BytesPerRow_HIG119*3+2,U  * 1B
        STD     -BytesPerRow_HIG119,U      * 3A
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG119,U       * 5A
        STD     BytesPerRow_HIG119+2,U     * 5B
        STD     BytesPerRow_HIG119*2,U     * 6A
        STD     BytesPerRow_HIG119*2+2,U   * 6B
        STD     BytesPerRow_HIG119*3,U     * 7A
        STD     BytesPerRow_HIG119*3+2,U   * 7B
        STD     BytesPerRow_HIG119*4,U     * 8A
        STD     BytesPerRow_HIG119*4+2,U   * 8B
        STD     BytesPerRow_HIG119*5,U     * 9A
        STD     BytesPerRow_HIG119*5+2,U   * 9B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG119*3,U    * 1A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG119*2,U    * 2A
        LDD     #%1110110111101101
        STD     -BytesPerRow_HIG119*2+2,U  * 2B
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG119+2,U    * 3B
        RTS