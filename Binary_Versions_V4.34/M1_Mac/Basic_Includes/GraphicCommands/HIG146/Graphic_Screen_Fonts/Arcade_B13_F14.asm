; Font Name: Arcade
; Description: Bold font similar text to classic 80's arcade characters
;              Bold font, cuts down on CoCo artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     8
CharJumpTable_HIG146:
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
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011101 1101110111011101
;4 1101110111011101 1101110111011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
Character_Blank:
        LDD     #%1101110111011101
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U
        STD     -BytesPerRow_HIG146*3+2,U  * 1
        STD     -BytesPerRow_HIG146*2,U
        STD     -BytesPerRow_HIG146*2+2,U  * 2
        STD     -BytesPerRow_HIG146,U
        STD     -BytesPerRow_HIG146+2,U  * 3
        STD     ,U
        STD     2,U    * 4
        STD     BytesPerRow_HIG146,U
        STD     BytesPerRow_HIG146+2,U   * 5
        STD     BytesPerRow_HIG146*2,U
        STD     BytesPerRow_HIG146*2+2,U   * 6
        STD     BytesPerRow_HIG146*3,U
        STD     BytesPerRow_HIG146*3+2,U   * 7
        RTS
; **************************************
; !
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110111011101101
;2 1101110111011101 1110111011101101
;3 1101110111011110 1110111011011101
;4 1101110111011110 1110110111011101
;5 1101110111011110 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111101101 1101110111011101
Character_Exclamation:

        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        LDD     #%1101110111101101
        STD     BytesPerRow_HIG146*3,U     * 7A
        RTS
; **************************************
; "
;0 1101110111011101 1101110111011101
;1 1101110111101110 1101111011101101
;2 1101110111101110 1101111011101101
;3 1101110111011110 1101110111101101
;4 1101110111101101 1101111011011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
Character_Quote:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     BytesPerRow_HIG146,U    *5A
        STD     BytesPerRow_HIG146+2,U   * 5B
        STD     BytesPerRow_HIG146*2,U   * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U   * 7A
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111101110
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U  * 1A
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2,U  * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146,U  * 3A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG146+2,U  * 3B
        STD     ,U      * 4A
        LDD     #%1101111011011101
        STD     2,U    * 4B
        RTS
; **************************************
; *
;0 1101110111011101 1101110111011101
;1 1101110111011110 1101110111011101
;2 1101111011011110 1101111011011101
;3 1101110111101110 1110110111011101
;4 1101110111011110 1101110111011101
;5 1101110111101110 1110110111011101
;6 1101111011011110 1101111011011101
;7 1101110111011110 1101110111011101
Character_Asterisk:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101111011011110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        RTS
; **************************************
; Hyphen
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101110111011101 1101110111011101
;4 1101110111101110 1110111011011101
;5 1101110111011101 1101110111011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
Character_Hyphen:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     ,U                         * 4A
        LDD     #%1110111011011101
        STD     2,U                        * 4B
        RTS
; **************************************
; Slash
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011110
;2 1101110111011101 1101110111101101
;3 1101110111011101 1101111011011101
;4 1101110111011101 1110110111011101
;5 1101110111011110 1101110111011101
;6 1101110111101101 1101110111011101
;7 1101111011011101 1101110111011101
Character_Slash:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101111011011101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        RTS
; **************************************
; 0
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101101 1101111011101101
;3 1101111011101101 1101110111101110
;4 1101111011101101 1101110111101110
;5 1101111011101101 1101110111101110
;6 1101110111101110 1101110111101101
;7 1101110111011110 1110111011011101
Character_0:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2,U     * 6A
        RTS
; **************************************
; 1
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110111011011101
;2 1101110111011110 1110111011011101
;3 1101110111011101 1110111011011101
;4 1101110111011101 1110111011011101
;5 1101110111011101 1110111011011101
;6 1101110111011101 1110111011011101
;7 1101110111101110 1110111011101110
Character_1:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101110
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; 2
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101111011101101 1101110111101110
;3 1101110111011101 1101111011101110
;4 1101110111011110 1110111011101101
;5 1101110111101110 1110111011011101
;6 1101111011101110 1101110111011101
;7 1101111011101110 1110111011101110
Character_2:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     2,U                        * 4B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1110111011101110
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; 3
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101110
;2 1101110111011101 1101111011101101
;3 1101110111011101 1110111011011101
;4 1101110111011110 1110111011101101
;5 1101110111011101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101110111101110 1110111011101101
Character_3:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; 4
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110111011101101
;2 1101110111011110 1110111011101101
;3 1101110111101110 1101111011101101
;4 1101111011101101 1101111011101101
;5 1101111011101110 1110111011101110
;6 1101110111011101 1101111011101101
;7 1101110111011101 1101111011101101
Character_4:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146,U      * 3A
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101110
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1110111011101110
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
; **************************************
; 5
;0 1101110111011101 1101110111011101
;1 1101111011101110 1110111011101101
;2 1101111011101101 1101110111011101
;3 1101111011101110 1110111011101101
;4 1101110111011101 1101110111101110
;5 1101110111011101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101110111101110 1110111011101101
Character_5:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146,U      * 3A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101110111101110
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        RTS
; **************************************
; 6
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011101101
;2 1101110111101110 1101110111011101
;3 1101111011101101 1101110111011101
;4 1101111011101110 1110111011101101
;5 1101111011101101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101110111101110 1110111011101101
Character_6:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101111011101110
        STD     ,U                         * 4A
        RTS
; **************************************
; 7
;0 1101110111011101 1101110111011101
;1 1101111011101110 1110111011101110
;2 1101111011101101 1101110111101110
;3 1101110111011101 1101111011101101
;4 1101110111011101 1110111011011101
;5 1101110111011110 1110110111011101
;6 1101110111011110 1110110111011101
;7 1101110111011110 1110110111011101
Character_7:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        LDD     #%1110111011011101
        STD     2,U                        * 4B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; 8
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011011101
;2 1101111011101101 1101110111101101
;3 1101111011101110 1101110111101101
;4 1101110111101110 1110111011011101
;5 1101111011011101 1110111011101110
;6 1101111011011101 1101110111101110
;7 1101110111101110 1110111011101101
Character_8:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     2,U                        * 4B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146,U      * 3A
        LDD     #%1101111011011101
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1110111011101110
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; 9
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101110111101110 1110111011101110
;5 1101110111011101 1101110111101110
;6 1101110111011101 1101111011101101
;7 1101110111101110 1110111011011101
Character_9:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1110111011101110
        STD     2,U                        * 4B
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG146*3+2,U   * 7B
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
Character_Colon:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*3,U     * 7A
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        RTS
; **************************************
; <
;0 1101110111011101 1101110111011101
;1 1101110111011101 1110110111011101
;2 1101110111011110 1101110111011101
;3 1101110111101101 1101110111011101
;4 1101111011011101 1101110111011101
;5 1101110111101101 1101110111011101
;6 1101110111011110 1101110111011101
;7 1101110111011101 1110110111011101
Character_Less:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101111011011101
        STD     ,U                         * 4A
        RTS
; **************************************
; =
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111011101
;2 1101110111011101 1101110111011101
;3 1101111011101110 1110111011011101
;4 1101110111011101 1101110111011101
;5 1101111011101110 1110111011011101
;6 1101110111011101 1101110111011101
;7 1101110111011101 1101110111011101
Character_Equal:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
; **************************************
; >
;0 1101110111011101 1101110111011101
;1 1101110111101101 1101110111011101
;2 1101110111011110 1101110111011101
;3 1101110111011101 1110110111011101
;4 1101110111011101 1101111011011101
;5 1101110111011101 1110110111011101
;6 1101110111011110 1101110111011101
;7 1101110111101101 1101110111011101
Character_Great:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1110110111011101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1101111011011101
        STD     2,U                        * 4B
        RTS
; **************************************
; A
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011011101
;2 1101110111101110 1101111011101101
;3 1101111011101101 1101110111101110
;4 1101111011101101 1101110111101110
;5 1101111011101110 1110111011101110
;6 1101111011101101 1101110111101110
;7 1101111011101101 1101110111101110
Character_A:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101111011101110
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1110111011101110
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
; **************************************
; B
;0 1101110111011101 1101110111011101
;1 1101111011101110 1110111011101101
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101111011101110 1110111011101101
;5 1101111011101101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101111011101110 1110111011101101
Character_B:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        RTS
; **************************************
; C
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011101101
;2 1101110111101110 1101110111101110
;3 1101111011101101 1101110111011101
;4 1101111011101101 1101110111011101
;5 1101111011101101 1101110111011101
;6 1101110111101110 1101110111101110
;7 1101110111011110 1110111011101101
Character_C:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        RTS
; **************************************
; D
;0 1101110111011101 1101110111011101
;1 1101111011101110 1110111011011101
;2 1101111011101101 1101111011101101
;3 1101111011101101 1101110111101110
;4 1101111011101101 1101110111101110
;5 1101111011101101 1101110111101110
;6 1101111011101101 1101111011101101
;7 1101111011101110 1110111011011101
Character_D:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B 
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
; **************************************
; E
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101110
;2 1101110111101110 1101110111011101
;3 1101110111101110 1101110111011101
;4 1101110111101110 1110111011101101
;5 1101110111101110 1101110111011101
;6 1101110111101110 1101110111011101
;7 1101110111101110 1110111011101110
Character_E:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        RTS
; **************************************
; F
;0 1101110111011101 1101110111011101
;1 1101111011101110 1110111011101110
;2 1101111011101101 1101110111011101
;3 1101111011101101 1101110111011101
;4 1101111011101110 1110111011101101
;5 1101111011101101 1101110111011101
;6 1101111011101101 1101110111011101
;7 1101111011101101 1101110111011101
Character_F:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     ,U                         * 4A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        RTS
; **************************************
; G
;0 1101110111011101 1101110111011101
;1 1101110111011110 1110111011101110
;2 1101110111101110 1101110111011101
;3 1101111011101101 1101110111011101
;4 1101111011101101 1101111011101110
;5 1101111011101101 1101110111101110
;6 1101110111101110 1101110111101110
;7 1101110111011110 1110111011101110
Character_G:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1101110111011110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101111011101110
        STD     2,U                        * 4B
        RTS
; **************************************
; H
;0 1101110111011101 1101110111011101
;1 1101111011101101 1101110111101110
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101111011101110 1110111011101110
;5 1101111011101101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101111011101101 1101110111101110
Character_H:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101110
        STD     ,U                         * 4A
        LDD     #%1110111011101110
        STD     2,U                        * 4B
        RTS
; **************************************
; I
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101110
;2 1101110111011101 1110111011011101
;3 1101110111011101 1110111011011101
;4 1101110111011101 1110111011011101
;5 1101110111011101 1110111011011101
;6 1101110111011101 1110111011011101
;7 1101110111101110 1110111011101110
Character_I:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        RTS
; **************************************
; J
;0 1101110111011101 1101110111011101
;1 1101110111011101 1101110111101110
;2 1101110111011101 1101110111101110
;3 1101110111011101 1101110111101110
;4 1101110111011101 1101110111101110
;5 1101110111011101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101110111101110 1110111011101101
Character_J:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101111011101101
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; K
;0 1101110111011101 1101110111011101
;1 1101111011101101 1101110111101110
;2 1101111011101101 1101111011101101
;3 1101111011101101 1110111011011101
;4 1101111011101110 1110110111011101
;5 1101111011101110 1110111011011101
;6 1101111011101101 1110111011101101
;7 1101111011101101 1101111011101110
Character_K:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1101111011101110
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1110110111011101
        STD     2,U                        * 4B
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        RTS
; **************************************
; L
;0 1101110111011101 1101110111011101
;1 1101110111101110 1101110111011101
;2 1101110111101110 1101110111011101
;3 1101110111101110 1101110111011101
;4 1101110111101110 1101110111011101
;5 1101110111101110 1101110111011101
;6 1101110111101110 1101110111011101
;7 1101110111101110 1110111011101110
Character_L:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101110
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; M
;0 1101110111011101 1101110111011101
;1 1101111011101101 1101110111101110
;2 1101111011101110 1101111011101110
;3 1101111011101110 1110111011101110
;4 1101111011101110 1110111011101110
;5 1101111011101101 1110110111101110
;6 1101111011101101 1101110111101110
;7 1101111011101101 1101110111101110
Character_M:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        LDD     #%1110110111101110
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
; **************************************
; N
;0 1101110111011101 1101110111011101
;1 1101111011101101 1101110111101110
;2 1101111011101110 1101110111101110
;3 1101111011101110 1110110111101110
;4 1101111011101110 1110111011101110
;5 1101111011101101 1110111011101110
;6 1101111011101101 1101111011101110
;7 1101111011101101 1101110111101110
Character_N:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1110110111101110
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1110111011101110
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
; **************************************
; O
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101111011101101 1101110111101110
;5 1101111011101101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101110111101110 1110111011101101
Character_O:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        RTS
; **************************************
; P
;0 1101110111011101 1101110111011101
;1 1101111011101110 1110111011101101
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101111011101101 1101110111101110
;5 1101111011101110 1110111011101101
;6 1101111011101101 1101110111011101
;7 1101111011101101 1101110111011101
Character_P:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        RTS
; **************************************
; Q
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101101
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101111011101101 1101110111101110
;5 1101111011101101 1110111011101110
;6 1101111011101101 1101111011101101
;7 1101110111101110 1110111011011110
Character_Q:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1110111011101110
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1110111011011110
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; R
;0 1101110111011101 1101110111011101
;1 1101111011101110 1110111011101101
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101111011101101 1101111011101110
;5 1101111011101110 1110111011011101
;6 1101111011101101 1110111011101101
;7 1101111011101101 1101111011101110
Character_R:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
; **************************************
; S
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011011101
;2 1101111011101101 1101111011101101
;3 1101111011101101 1101110111011101
;4 1101110111101110 1110111011101101
;5 1101110111011101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101110111101110 1110111011101101
Character_S:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; T
;0 1101110111011101 1101110111011101
;1 1101110111101110 1110111011101110
;2 1101110111011101 1110111011011101
;3 1101110111011101 1110111011011101
;4 1101110111011101 1110111011011101
;5 1101110111011101 1110111011011101
;6 1101110111011101 1110111011011101
;7 1101110111011101 1110111011011101
Character_T:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        LDD     #%1110111011011101
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; U
;0 1101110111011101 1101110111011101
;1 1101111011101101 1101110111101110
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101111011101101 1101110111101110
;5 1101111011101101 1101110111101110
;6 1101111011101101 1101110111101110
;7 1101110111101110 1110111011101101
Character_U:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; V
;0 1101110111011101 1101110111011101
;1 1101111011101101 1101110111101110
;2 1101111011101101 1101110111101110
;3 1101111011101101 1101110111101110
;4 1101111011101110 1101111011101110
;5 1101110111101110 1110111011101101
;6 1101110111011110 1110111011011101
;7 1101110111011101 1110110111011101
Character_V:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1101111011101110
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        LDD     #%1110111011101101
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1101110111011110
        STD     BytesPerRow_HIG146*2,U     * 6A
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; W
;0 1101110111011101 1101110111011101
;1 1101111011101101 1101110111101110
;2 1101111011101101 1101110111101110
;3 1101111011101101 1110110111101110
;4 1101111011101110 1110111011101110
;5 1101111011101110 1110111011101110
;6 1101111011101110 1101111011101110
;7 1101111011101101 1101110111101110
Character_W:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1110110111101110
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1101111011101110
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1110111011101110
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
; **************************************
; X
;0 1101110111011101 1101110111011101
;1 1101111011101101 1101110111101110
;2 1101111011101110 1101111011101110
;3 1101110111101110 1110111011101101
;4 1101110111011110 1110111011011101
;5 1101110111101110 1110111011101101
;6 1101111011101110 1101111011101110
;7 1101111011101101 1101110111101110
Character_X:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        LDD     #%1101111011101101
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        STD     BytesPerRow_HIG146+2,U     * 5B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        LDD     #%1110111011011101
        STD     2,U                        * 4B
        RTS
; **************************************
; Y
;0 1101110111011101 1101110111011101
;1 1101110111101110 1101110111101110
;2 1101110111101110 1101110111101110
;3 1101110111101110 1101110111101110
;4 1101110111011110 1110111011101101
;5 1101110111011101 1110111011011101
;6 1101110111011101 1110111011011101
;7 1101110111011101 1110111011011101
Character_Y:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     BytesPerRow_HIG146,U       * 5A
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1101110111101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        LDD     #%1110111011101101
        STD     2,U                        * 4B
        LDD     #%1110111011011101
        STD     BytesPerRow_HIG146+2,U     * 5B
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        RTS
; **************************************
; Z
;0 1101110111011101 1101110111011101
;1 1101111011101110 1110111011101110
;2 1101110111011101 1101111011101110
;3 1101110111011101 1110111011101101
;4 1101110111011110 1110111011011101
;5 1101110111101110 1110110111011101
;6 1101111011101110 1101110111011101
;7 1101111011101110 1110111011101110
Character_Z:
        LDD     #%1101110111011101
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG146*4,U
        STD     -BytesPerRow_HIG146*2,U    * 2A
        STD     -BytesPerRow_HIG146,U      * 3A
        STD     BytesPerRow_HIG146*2+2,U   * 6B
        LDD     #%1101111011101110
        STD     -BytesPerRow_HIG146*3,U    * 1A
        STD     -BytesPerRow_HIG146*2+2,U  * 2B
        STD     BytesPerRow_HIG146*2,U     * 6A
        STD     BytesPerRow_HIG146*3,U     * 7A
        LDD     #%1110111011101110
        STD     -BytesPerRow_HIG146*3+2,U  * 1B
        STD     BytesPerRow_HIG146*3+2,U   * 7B
        LDD     #%1110111011101101
        STD     -BytesPerRow_HIG146+2,U    * 3B
        LDD     #%1101110111011110
        STD     ,U                         * 4A
        LDD     #%1110111011011101
        STD     2,U                        * 4B
        LDD     #%1101110111101110
        STD     BytesPerRow_HIG146,U       * 5A
        LDD     #%1110110111011101
        STD     BytesPerRow_HIG146+2,U     * 5B
        RTS
