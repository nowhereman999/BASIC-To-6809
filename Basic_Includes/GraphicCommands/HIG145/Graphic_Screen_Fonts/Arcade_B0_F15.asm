; Font Name: Arcade
; Description: Bold font similar text to classic 80's arcade characters
;              Bold font, cuts down on CoCo artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     8
CharJumpTable_HIG145:
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
;0 0000000000000000 0000000000000000
;1 0000000000000000 0000000000000000
;2 0000000000000000 0000000000000000
;3 0000000000000000 0000000000000000
;4 0000000000000000 0000000000000000
;5 0000000000000000 0000000000000000
;6 0000000000000000 0000000000000000
;7 0000000000000000 0000000000000000
Character_Blank:
        LDD     #%0000000000000000
        STD     ,U
        STD     2,U    * 0
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U
        STD     -BytesPerRow_HIG145*3+2,U  * 1
        STD     -BytesPerRow_HIG145*2,U
        STD     -BytesPerRow_HIG145*2+2,U  * 2
        STD     -BytesPerRow_HIG145,U
        STD     -BytesPerRow_HIG145+2,U  * 3
        STD     ,U
        STD     2,U    * 4
        STD     BytesPerRow_HIG145,U
        STD     BytesPerRow_HIG145+2,U   * 5
        STD     BytesPerRow_HIG145*2,U
        STD     BytesPerRow_HIG145*2+2,U   * 6
        STD     BytesPerRow_HIG145*3,U
        STD     BytesPerRow_HIG145*3+2,U   * 7
        RTS
; **************************************
; !
;0 0000000000000000 0000000000000000
;1 0000000000000000 1111111111110000
;2 0000000000000000 1111111111110000
;3 0000000000001111 1111111100000000
;4 0000000000001111 1111000000000000
;5 0000000000001111 0000000000000000
;6 0000000000000000 0000000000000000
;7 0000000011110000 0000000000000000
Character_Exclamation:

        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%1111000000000000
        STD     2,U                        * 4B
        LDD     #%0000000011110000
        STD     BytesPerRow_HIG145*3,U     * 7A
        RTS
; **************************************
; "
;0 0000000000000000 0000000000000000
;1 0000000011111111 0000111111110000
;2 0000000011111111 0000111111110000
;3 0000000000001111 0000000011110000
;4 0000000011110000 0000111100000000
;5 0000000000000000 0000000000000000
;6 0000000000000000 0000000000000000
;7 0000000000000000 0000000000000000
Character_Quote:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     BytesPerRow_HIG145,U    *5A
        STD     BytesPerRow_HIG145+2,U   * 5B
        STD     BytesPerRow_HIG145*2,U   * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U   * 7A
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000011111111
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U  * 1A
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2,U  * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145,U  * 3A
        LDD     #%0000000011110000
        STD     -BytesPerRow_HIG145+2,U  * 3B
        STD     ,U      * 4A
        LDD     #%0000111100000000
        STD     2,U    * 4B
        RTS
; **************************************
; *
;0 0000000000000000 0000000000000000
;1 0000000000001111 0000000000000000
;2 0000111100001111 0000111100000000
;3 0000000011111111 1111000000000000
;4 0000000000001111 0000000000000000
;5 0000000011111111 1111000000000000
;6 0000111100001111 0000111100000000
;7 0000000000001111 0000000000000000
Character_Asterisk:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000111100001111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000111100000000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%1111000000000000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        RTS
; **************************************
; Hyphen
;0 0000000000000000 0000000000000000
;1 0000000000000000 0000000000000000
;2 0000000000000000 0000000000000000
;3 0000000000000000 0000000000000000
;4 0000000011111111 1111111100000000
;5 0000000000000000 0000000000000000
;6 0000000000000000 0000000000000000
;7 0000000000000000 0000000000000000
Character_Hyphen:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000011111111
        STD     ,U                         * 4A
        LDD     #%1111111100000000
        STD     2,U                        * 4B
        RTS
; **************************************
; Slash
;0 0000000000000000 0000000000000000
;1 0000000000000000 0000000000001111
;2 0000000000000000 0000000011110000
;3 0000000000000000 0000111100000000
;4 0000000000000000 1111000000000000
;5 0000000000001111 0000000000000000
;6 0000000011110000 0000000000000000
;7 0000111100000000 0000000000000000
Character_Slash:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000000011110000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000111100000000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111000000000000
        STD     2,U                        * 4B
        RTS
; **************************************
; 0
;0 0000000000000000 0000000000000000
;1 0000000000001111 1111111100000000
;2 0000000011110000 0000111111110000
;3 0000111111110000 0000000011111111
;4 0000111111110000 0000000011111111
;5 0000111111110000 0000000011111111
;6 0000000011111111 0000000011110000
;7 0000000000001111 1111111100000000
Character_0:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000011110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2,U     * 6A
        RTS
; **************************************
; 1
;0 0000000000000000 0000000000000000
;1 0000000000000000 1111111100000000
;2 0000000000001111 1111111100000000
;3 0000000000000000 1111111100000000
;4 0000000000000000 1111111100000000
;5 0000000000000000 1111111100000000
;6 0000000000000000 1111111100000000
;7 0000000011111111 1111111111111111
Character_1:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        LDD     #%0000000011111111
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111111111
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; 2
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111111110000
;2 0000111111110000 0000000011111111
;3 0000000000000000 0000111111111111
;4 0000000000001111 1111111111110000
;5 0000000011111111 1111111100000000
;6 0000111111111111 0000000000000000
;7 0000111111111111 1111111111111111
Character_2:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     2,U                        * 4B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000000001111
        STD     ,U                         * 4A
        LDD     #%1111111100000000
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%1111111111111111
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; 3
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111111111111
;2 0000000000000000 0000111111110000
;3 0000000000000000 1111111100000000
;4 0000000000001111 1111111111110000
;5 0000000000000000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000000011111111 1111111111110000
Character_3:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%0000000000001111
        STD     ,U                         * 4A
        LDD     #%1111111111110000
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; 4
;0 0000000000000000 0000000000000000
;1 0000000000000000 1111111111110000
;2 0000000000001111 1111111111110000
;3 0000000011111111 0000111111110000
;4 0000111111110000 0000111111110000
;5 0000111111111111 1111111111111111
;6 0000000000000000 0000111111110000
;7 0000000000000000 0000111111110000
Character_4:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145,U      * 3A
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111111111
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%1111111111111111
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
; **************************************
; 5
;0 0000000000000000 0000000000000000
;1 0000111111111111 1111111111110000
;2 0000111111110000 0000000000000000
;3 0000111111111111 1111111111110000
;4 0000000000000000 0000000011111111
;5 0000000000000000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000000011111111 1111111111110000
Character_5:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145,U      * 3A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000000011111111
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        RTS
; **************************************
; 6
;0 0000000000000000 0000000000000000
;1 0000000000001111 1111111111110000
;2 0000000011111111 0000000000000000
;3 0000111111110000 0000000000000000
;4 0000111111111111 1111111111110000
;5 0000111111110000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000000011111111 1111111111110000
Character_6:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000111111111111
        STD     ,U                         * 4A
        RTS
; **************************************
; 7
;0 0000000000000000 0000000000000000
;1 0000111111111111 1111111111111111
;2 0000111111110000 0000000011111111
;3 0000000000000000 0000111111110000
;4 0000000000000000 1111111100000000
;5 0000000000001111 1111000000000000
;6 0000000000001111 1111000000000000
;7 0000000000001111 1111000000000000
Character_7:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        LDD     #%1111111100000000
        STD     2,U                        * 4B
        LDD     #%0000000000001111
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111000000000000
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; 8
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111100000000
;2 0000111111110000 0000000011110000
;3 0000111111111111 0000000011110000
;4 0000000011111111 1111111100000000
;5 0000111100000000 1111111111111111
;6 0000111100000000 0000000011111111
;7 0000000011111111 1111111111110000
Character_8:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     2,U                        * 4B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        LDD     #%0000000011110000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145,U      * 3A
        LDD     #%0000111100000000
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%1111111111111111
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%1111111111110000
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; 9
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111111110000
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000000011111111 1111111111111111
;5 0000000000000000 0000000011111111
;6 0000000000000000 0000111111110000
;7 0000000011111111 1111111100000000
Character_9:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%1111111111111111
        STD     2,U                        * 4B
        LDD     #%1111111100000000
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; :
;0 0000000000000000 0000000000000000
;1 0000000000000000 0000000000000000
;2 0000000000001111 1111000000000000
;3 0000000000001111 1111000000000000
;4 0000000000000000 0000000000000000
;5 0000000000001111 1111000000000000
;6 0000000000001111 1111000000000000
;7 0000000000000000 0000000000000000
Character_Colon:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*3,U     * 7A
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%1111000000000000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        RTS
; **************************************
; <
;0 0000000000000000 0000000000000000
;1 0000000000000000 1111000000000000
;2 0000000000001111 0000000000000000
;3 0000000011110000 0000000000000000
;4 0000111100000000 0000000000000000
;5 0000000011110000 0000000000000000
;6 0000000000001111 0000000000000000
;7 0000000000000000 1111000000000000
Character_Less:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111000000000000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000000011110000
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000111100000000
        STD     ,U                         * 4A
        RTS
; **************************************
; =
;0 0000000000000000 0000000000000000
;1 0000000000000000 0000000000000000
;2 0000000000000000 0000000000000000
;3 0000111111111111 1111111100000000
;4 0000000000000000 0000000000000000
;5 0000111111111111 1111111100000000
;6 0000000000000000 0000000000000000
;7 0000000000000000 0000000000000000
Character_Equal:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
; **************************************
; >
;0 0000000000000000 0000000000000000
;1 0000000011110000 0000000000000000
;2 0000000000001111 0000000000000000
;3 0000000000000000 1111000000000000
;4 0000000000000000 0000111100000000
;5 0000000000000000 1111000000000000
;6 0000000000001111 0000000000000000
;7 0000000011110000 0000000000000000
Character_Great:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000011110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%1111000000000000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%0000111100000000
        STD     2,U                        * 4B
        RTS
; **************************************
; A
;0 0000000000000000 0000000000000000
;1 0000000000001111 1111111100000000
;2 0000000011111111 0000111111110000
;3 0000111111110000 0000000011111111
;4 0000111111110000 0000000011111111
;5 0000111111111111 1111111111111111
;6 0000111111110000 0000000011111111
;7 0000111111110000 0000000011111111
Character_A:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000111111111111
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%1111111111111111
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
; **************************************
; B
;0 0000000000000000 0000000000000000
;1 0000111111111111 1111111111110000
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000111111111111 1111111111110000
;5 0000111111110000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000111111111111 1111111111110000
Character_B:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        RTS
; **************************************
; C
;0 0000000000000000 0000000000000000
;1 0000000000001111 1111111111110000
;2 0000000011111111 0000000011111111
;3 0000111111110000 0000000000000000
;4 0000111111110000 0000000000000000
;5 0000111111110000 0000000000000000
;6 0000000011111111 0000000011111111
;7 0000000000001111 1111111111110000
Character_C:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        RTS
; **************************************
; D
;0 0000000000000000 0000000000000000
;1 0000111111111111 1111111100000000
;2 0000111111110000 0000111111110000
;3 0000111111110000 0000000011111111
;4 0000111111110000 0000000011111111
;5 0000111111110000 0000000011111111
;6 0000111111110000 0000111111110000
;7 0000111111111111 1111111100000000
Character_D:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B 
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
; **************************************
; E
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111111111111
;2 0000000011111111 0000000000000000
;3 0000000011111111 0000000000000000
;4 0000000011111111 1111111111110000
;5 0000000011111111 0000000000000000
;6 0000000011111111 0000000000000000
;7 0000000011111111 1111111111111111
Character_E:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%1111111111110000
        STD     2,U                        * 4B
        RTS
; **************************************
; F
;0 0000000000000000 0000000000000000
;1 0000111111111111 1111111111111111
;2 0000111111110000 0000000000000000
;3 0000111111110000 0000000000000000
;4 0000111111111111 1111111111110000
;5 0000111111110000 0000000000000000
;6 0000111111110000 0000000000000000
;7 0000111111110000 0000000000000000
Character_F:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     ,U                         * 4A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111110000
        STD     2,U                        * 4B
        RTS
; **************************************
; G
;0 0000000000000000 0000000000000000
;1 0000000000001111 1111111111111111
;2 0000000011111111 0000000000000000
;3 0000111111110000 0000000000000000
;4 0000111111110000 0000111111111111
;5 0000111111110000 0000000011111111
;6 0000000011111111 0000000011111111
;7 0000000000001111 1111111111111111
Character_G:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%0000000000001111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000111111111111
        STD     2,U                        * 4B
        RTS
; **************************************
; H
;0 0000000000000000 0000000000000000
;1 0000111111110000 0000000011111111
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000111111111111 1111111111111111
;5 0000111111110000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000111111110000 0000000011111111
Character_H:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111111111
        STD     ,U                         * 4A
        LDD     #%1111111111111111
        STD     2,U                        * 4B
        RTS
; **************************************
; I
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111111111111
;2 0000000000000000 1111111100000000
;3 0000000000000000 1111111100000000
;4 0000000000000000 1111111100000000
;5 0000000000000000 1111111100000000
;6 0000000000000000 1111111100000000
;7 0000000011111111 1111111111111111
Character_I:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        RTS
; **************************************
; J
;0 0000000000000000 0000000000000000
;1 0000000000000000 0000000011111111
;2 0000000000000000 0000000011111111
;3 0000000000000000 0000000011111111
;4 0000000000000000 0000000011111111
;5 0000000000000000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000000011111111 1111111111110000
Character_J:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000111111110000
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%1111111111110000
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; K
;0 0000000000000000 0000000000000000
;1 0000111111110000 0000000011111111
;2 0000111111110000 0000111111110000
;3 0000111111110000 1111111100000000
;4 0000111111111111 1111000000000000
;5 0000111111111111 1111111100000000
;6 0000111111110000 1111111111110000
;7 0000111111110000 0000111111111111
Character_K:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%0000111111111111
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%1111000000000000
        STD     2,U                        * 4B
        LDD     #%1111111111110000
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        RTS
; **************************************
; L
;0 0000000000000000 0000000000000000
;1 0000000011111111 0000000000000000
;2 0000000011111111 0000000000000000
;3 0000000011111111 0000000000000000
;4 0000000011111111 0000000000000000
;5 0000000011111111 0000000000000000
;6 0000000011111111 0000000000000000
;7 0000000011111111 1111111111111111
Character_L:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111111111
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; M
;0 0000000000000000 0000000000000000
;1 0000111111110000 0000000011111111
;2 0000111111111111 0000111111111111
;3 0000111111111111 1111111111111111
;4 0000111111111111 1111111111111111
;5 0000111111110000 1111000011111111
;6 0000111111110000 0000000011111111
;7 0000111111110000 0000000011111111
Character_M:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        LDD     #%1111000011111111
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
; **************************************
; N
;0 0000000000000000 0000000000000000
;1 0000111111110000 0000000011111111
;2 0000111111111111 0000000011111111
;3 0000111111111111 1111000011111111
;4 0000111111111111 1111111111111111
;5 0000111111110000 1111111111111111
;6 0000111111110000 0000111111111111
;7 0000111111110000 0000000011111111
Character_N:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%1111000011111111
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%1111111111111111
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
; **************************************
; O
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111111110000
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000111111110000 0000000011111111
;5 0000111111110000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000000011111111 1111111111110000
Character_O:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        RTS
; **************************************
; P
;0 0000000000000000 0000000000000000
;1 0000111111111111 1111111111110000
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000111111110000 0000000011111111
;5 0000111111111111 1111111111110000
;6 0000111111110000 0000000000000000
;7 0000111111110000 0000000000000000
Character_P:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        RTS
; **************************************
; Q
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111111110000
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000111111110000 0000000011111111
;5 0000111111110000 1111111111111111
;6 0000111111110000 0000111111110000
;7 0000000011111111 1111111100001111
Character_Q:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%1111111111111111
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%1111111100001111
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; R
;0 0000000000000000 0000000000000000
;1 0000111111111111 1111111111110000
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000111111110000 0000111111111111
;5 0000111111111111 1111111100000000
;6 0000111111110000 1111111111110000
;7 0000111111110000 0000111111111111
Character_R:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%1111111100000000
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
; **************************************
; S
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111100000000
;2 0000111111110000 0000111111110000
;3 0000111111110000 0000000000000000
;4 0000000011111111 1111111111110000
;5 0000000000000000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000000011111111 1111111111110000
Character_S:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%1111111111110000
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; T
;0 0000000000000000 0000000000000000
;1 0000000011111111 1111111111111111
;2 0000000000000000 1111111100000000
;3 0000000000000000 1111111100000000
;4 0000000000000000 1111111100000000
;5 0000000000000000 1111111100000000
;6 0000000000000000 1111111100000000
;7 0000000000000000 1111111100000000
Character_T:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        LDD     #%1111111100000000
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; U
;0 0000000000000000 0000000000000000
;1 0000111111110000 0000000011111111
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000111111110000 0000000011111111
;5 0000111111110000 0000000011111111
;6 0000111111110000 0000000011111111
;7 0000000011111111 1111111111110000
Character_U:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111110000
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; V
;0 0000000000000000 0000000000000000
;1 0000111111110000 0000000011111111
;2 0000111111110000 0000000011111111
;3 0000111111110000 0000000011111111
;4 0000111111111111 0000111111111111
;5 0000000011111111 1111111111110000
;6 0000000000001111 1111111100000000
;7 0000000000000000 1111000000000000
Character_V:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%0000111111111111
        STD     ,U                         * 4A
        STD     2,U                        * 4B
        LDD     #%1111111111110000
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%0000000000001111
        STD     BytesPerRow_HIG145*2,U     * 6A
        LDD     #%1111111100000000
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%1111000000000000
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; W
;0 0000000000000000 0000000000000000
;1 0000111111110000 0000000011111111
;2 0000111111110000 0000000011111111
;3 0000111111110000 1111000011111111
;4 0000111111111111 1111111111111111
;5 0000111111111111 1111111111111111
;6 0000111111111111 0000111111111111
;7 0000111111110000 0000000011111111
Character_W:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%1111000011111111
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%0000111111111111
        STD     ,U                         * 4A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%1111111111111111
        STD     2,U                        * 4B
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
; **************************************
; X
;0 0000000000000000 0000000000000000
;1 0000111111110000 0000000011111111
;2 0000111111111111 0000111111111111
;3 0000000011111111 1111111111110000
;4 0000000000001111 1111111100000000
;5 0000000011111111 1111111111110000
;6 0000111111111111 0000111111111111
;7 0000111111110000 0000000011111111
Character_X:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        LDD     #%0000111111110000
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        STD     BytesPerRow_HIG145+2,U     * 5B
        LDD     #%0000000000001111
        STD     ,U                         * 4A
        LDD     #%1111111100000000
        STD     2,U                        * 4B
        RTS
; **************************************
; Y
;0 0000000000000000 0000000000000000
;1 0000000011111111 0000000011111111
;2 0000000011111111 0000000011111111
;3 0000000011111111 0000000011111111
;4 0000000000001111 1111111111110000
;5 0000000000000000 1111111100000000
;6 0000000000000000 1111111100000000
;7 0000000000000000 1111111100000000
Character_Y:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     BytesPerRow_HIG145,U       * 5A
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%0000000011111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%0000000000001111
        STD     ,U                         * 4A
        LDD     #%1111111111110000
        STD     2,U                        * 4B
        LDD     #%1111111100000000
        STD     BytesPerRow_HIG145+2,U     * 5B
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        RTS
; **************************************
; Z
;0 0000000000000000 0000000000000000
;1 0000111111111111 1111111111111111
;2 0000000000000000 0000111111111111
;3 0000000000000000 1111111111110000
;4 0000000000001111 1111111100000000
;5 0000000011111111 1111000000000000
;6 0000111111111111 0000000000000000
;7 0000111111111111 1111111111111111
Character_Z:
        LDD     #%0000000000000000
        STD     ,U     * 0A
        STD     2,U    * 0B
        LEAU    BytesPerRow_HIG145*4,U
        STD     -BytesPerRow_HIG145*2,U    * 2A
        STD     -BytesPerRow_HIG145,U      * 3A
        STD     BytesPerRow_HIG145*2+2,U   * 6B
        LDD     #%0000111111111111
        STD     -BytesPerRow_HIG145*3,U    * 1A
        STD     -BytesPerRow_HIG145*2+2,U  * 2B
        STD     BytesPerRow_HIG145*2,U     * 6A
        STD     BytesPerRow_HIG145*3,U     * 7A
        LDD     #%1111111111111111
        STD     -BytesPerRow_HIG145*3+2,U  * 1B
        STD     BytesPerRow_HIG145*3+2,U   * 7B
        LDD     #%1111111111110000
        STD     -BytesPerRow_HIG145+2,U    * 3B
        LDD     #%0000000000001111
        STD     ,U                         * 4A
        LDD     #%1111111100000000
        STD     2,U                        * 4B
        LDD     #%0000000011111111
        STD     BytesPerRow_HIG145,U       * 5A
        LDD     #%1111000000000000
        STD     BytesPerRow_HIG145+2,U     * 5B
        RTS
