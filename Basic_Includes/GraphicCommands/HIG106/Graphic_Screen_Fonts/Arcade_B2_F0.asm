; Font Name: Arcade
; Description: Bold font similar text to classic 80's arcade characters
;              Bold font, cuts down on CoCo artifact colours
;
; Font table that points to the compiled sprite code
; Only ASCII codes from $20 to $7F are supported
FontWidth       EQU     8
FontHeight      EQU     8
CharJumpTable_HIG106:
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
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000000000000
;4 0000000000000000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
Character_Blank:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
;  !
;0 0000000000000000
;1 0000000001010100
;2 0000000001010100
;3 0000000101010000
;4 0000000101000000
;5 0000000100000000
;6 0000000000000000
;7 0000010000000000
Character_Exclamation:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010101000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010100000001010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010100000101010
        STD     ,U     * 4
        LDD     #%1010100000101010
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010100010101010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
;  "
;0 0000000000000000
;1 0000010100010100
;2 0000010100010100
;3 0000000100000100
;4 0000010000010000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
Character_Quote:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010000010000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010100010100010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010001010001010
        STD     ,U     * 4
        RTS
; **************************************
; *
;0 0000000000000000
;1 0000000100000000
;2 0001000100010000
;3 0000010101000000
;4 0000000100000000
;5 0000010101000000
;6 0001000100010000
;7 0000000100000000
Character_Asterisk:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010100010101010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     ,U     * 4
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000100010001010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000101010
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        RTS
; **************************************
; Hyphen
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0000000000000000
;4 0000010101010000
;5 0000000000000000
;6 0000000000000000
;7 0000000000000000
Character_Hyphen:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010000000001010
        STD     ,U     * 4
        RTS
; **************************************
; Slash
;0 0000000000000000
;1 0000000000000001
;2 0000000000000100
;3 0000000000010000
;4 0000000001000000
;5 0000000100000000
;6 0000010000000000
;7 0001000000000000
Character_Slash:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010101010101000
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1010101010100010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010101010001010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010101000101010
        STD     ,U     * 4
        LDD     #%1010100010101010
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010001010101010
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1000101010101010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 0
;0 0000000000000000
;1 0000000101010000
;2 0000010000010100
;3 0001010000000101
;4 0001010000000101
;5 0001010000000101
;6 0000010100000100
;7 0000000101010000
Character_0:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010100000001010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1010001010000010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010000010100010
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010100000001010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 1
;0 0000000000000000
;1 0000000001010000
;2 0000000101010000
;3 0000000001010000
;4 0000000001010000
;5 0000000001010000
;6 0000000001010000
;7 0000010101010101
Character_1:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010101000001010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010100000001010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010000000000000
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 2
;0 0000000000000000
;1 0000010101010100
;2 0001010000000101
;3 0000000000010101
;4 0000000101010100
;5 0000010101010000
;6 0001010100000000
;7 0001010101010101
Character_2:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010101010000000
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010100000000010
        STD     ,U     * 4
        LDD     #%1010000000001010
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000000010101010
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1000000000000000
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 3
;0 0000000000000000
;1 0000010101010101
;2 0000000000010100
;3 0000000001010000
;4 0000000101010100
;5 0000000000000101
;6 0001010000000101
;7 0000010101010100
Character_3:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000000000
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1010101010000010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010101000001010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010100000000010
        STD     ,U     * 4
        LDD     #%1010101010100000
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001010100000
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 4
;0 0000000000000000
;1 0000000001010100
;2 0000000101010100
;3 0000010100010100
;4 0001010000010100
;5 0001010101010101
;6 0000000000010100
;7 0000000000010100
Character_4:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010101000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1010100000000010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010000010000010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000001010000010
        STD     ,U     * 4
        LDD     #%1000000000000000
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010101010000010
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 5
;0 0000000000000000
;1 0001010101010100
;2 0001010000000000
;3 0001010101010100
;4 0000000000000101
;5 0000000000000101
;6 0001010000000101
;7 0000010101010100
Character_5:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000000000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000001010101010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010101010100000
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001010100000
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 6
;0 0000000000000000
;1 0000000101010100
;2 0000010100000000
;3 0001010000000000
;4 0001010101010100
;5 0001010000000101
;6 0001010000000101
;7 0000010101010100
Character_6:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010100000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1010000010101010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000001010101010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000000000000010
        STD     ,U     * 4
        LDD     #%1000001010100000
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 7
;0 0000000000000000
;1 0001010101010101
;2 0001010000000101
;3 0000000000010100
;4 0000000001010000
;5 0000000101000000
;6 0000000101000000
;7 0000000101000000
Character_7:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000000000000000
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010101010000010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010101000001010
        STD     ,U     * 4
        LDD     #%1010100000101010
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 8
;0 0000000000000000
;1 0000010101010000
;2 0001010000000100
;3 0001010100000100
;4 0000010101010000
;5 0001000001010101
;6 0001000000000101
;7 0000010101010100
Character_8:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000001010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     ,U     * 4
        LDD     #%1000001010100010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000000010100010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000101000000000
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000101010100000
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; 9
;0 0000000000000000
;1 0000010101010100
;2 0001010000000101
;3 0001010000000101
;4 0000010101010101
;5 0000000000000101
;6 0000000000010100
;7 0000010101010000
Character_9:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010000000000000
        STD     ,U     * 4
        LDD     #%1010101010100000
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010101010000010
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000001010
        STD     BytesPerRow_HIG106*3,U   * 7
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
Character_Colon:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     ,U     * 4
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010100000101010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
; **************************************
; <
;0 0000000000000000
;1 0000000001000000
;2 0000000100000000
;3 0000010000000000
;4 0001000000000000
;5 0000010000000000
;6 0000000100000000
;7 0000000001000000
Character_Less:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010101000101010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010100010101010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010001010101010
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000101010101010
        STD     ,U     * 4
        RTS
; **************************************
; =
;0 0000000000000000
;1 0000000000000000
;2 0000000000000000
;3 0001010101010000
;4 0000000000000000
;5 0001010101010000
;6 0000000000000000
;7 0000000000000000
Character_Equal:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     ,U     * 4
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000000000001010
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        RTS
; **************************************
; >
;0 0000000000000000
;1 0000010000000000
;2 0000000100000000
;3 0000000001000000
;4 0000000000010000
;5 0000000001000000
;6 0000000100000000
;7 0000010000000000
Character_Great:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010001010101010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010100010101010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010101000101010
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010101010001010
        STD     ,U     * 4
        RTS
; **************************************
; A
;0 0000000000000000
;1 0000000101010000
;2 0000010100010100
;3 0001010000000101
;4 0001010000000101
;5 0001010101010101
;6 0001010000000101
;7 0001010000000101
Character_A:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010100000001010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1010000010000010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000000000000000
        STD     BytesPerRow_HIG106,U   * 5
        RTS
; **************************************
; B
;0 0000000000000000
;1 0001010101010100
;2 0001010000000101
;3 0001010000000101
;4 0001010101010100
;5 0001010000000101
;6 0001010000000101
;7 0001010101010100
Character_B:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000000000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     ,U     * 4
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
; **************************************
; C
;0 0000000000000000
;1 0000000101010100
;2 0000010100000101
;3 0001010000000000
;4 0001010000000000
;5 0001010000000000
;6 0000010100000101
;7 0000000101010100
Character_C:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010100000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010000010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1000001010101010
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        RTS
; **************************************
; D
;0 0000000000000000
;1 0001010101010000
;2 0001010000010100
;3 0001010000000101
;4 0001010000000101
;5 0001010000000101
;6 0001010000010100
;7 0001010101010000
Character_D:
        LDD     #%1010101010101010
        STD     ,U  * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000000000001010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000001010000010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        RTS
; **************************************
; E
;0 0000000000000000
;1 0000010101010101
;2 0000010100000000
;3 0000010100000000
;4 0000010101010100
;5 0000010100000000
;6 0000010100000000
;7 0000010101010101
Character_E:
        LDD     #%1010101010101010
        STD     ,U  * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000000000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010000010101010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000010
        STD     ,U     * 4
        RTS
; **************************************
; F
;0 0000000000000000
;1 0001010101010101
;2 0001010000000000
;3 0001010000000000
;4 0001010101010100
;5 0001010000000000
;6 0001010000000000
;7 0001010000000000
Character_F:
        LDD     #%1010101010101010
        STD     ,U  * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000000000000000
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1000001010101010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000000000000010
        STD     ,U     * 4
        RTS
; **************************************
; G
;0 0000000000000000
;1 0000000101010101
;2 0000010100000000
;3 0001010000000000
;4 0001010000010101
;5 0001010000000101
;6 0000010100000101
;7 0000000101010101
Character_G:
        LDD     #%1010101010101010
        STD     ,U  * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010100000000000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010000010101010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000001010101010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000001010000000
        STD     ,U     * 4
        LDD     #%1000001010100000
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010000010100000
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
; **************************************
; H
;0 0000000000000000
;1 0001010000000101
;2 0001010000000101
;3 0001010000000101
;4 0001010101010101
;5 0001010000000101
;6 0001010000000101
;7 0001010000000101
Character_H:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000000000000000
        STD     ,U     * 4
        RTS
; **************************************
; I
;0 0000000000000000
;1 0000010101010101
;2 0000000001010000
;3 0000000001010000
;4 0000000001010000
;5 0000000001010000
;6 0000000001010000
;7 0000010101010101
Character_I:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000000000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010101000001010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
; **************************************
; J
;0 0000000000000000
;1 0000000000000101
;2 0000000000000101
;3 0000000000000101
;4 0000000000000101
;5 0000000000000101
;6 0001010000000101
;7 0000010101010100
Character_J:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010101010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001010100000
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; K
;0 0000000000000000
;1 0001010000000101
;2 0001010000010100
;3 0001010001010000
;4 0001010101000000
;5 0001010101010000
;6 0001010001010100
;7 0001010000010101
Character_K:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1000001010000010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000001000001010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000000000101010
        STD     ,U     * 4
        LDD     #%1000000000001010
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001000000010
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1000001010000000
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; L
;0 0000000000000000
;1 0000010100000000
;2 0000010100000000
;3 0000010100000000
;4 0000010100000000
;5 0000010100000000
;6 0000010100000000
;7 0000010101010101
Character_L:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000010101010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000000
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; M
;0 0000000000000000
;1 0001010000000101
;2 0001010100010101
;3 0001010101010101
;4 0001010101010101
;5 0001010001000101
;6 0001010000000101
;7 0001010000000101
Character_M:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000000010000000
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000000000000000
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        LDD     #%1000001000100000
        STD     BytesPerRow_HIG106,U   * 5
        RTS
; **************************************
; N
;0 0000000000000000
;1 0001010000000101
;2 0001010100000101
;3 0001010101000101
;4 0001010101010101
;5 0001010001010101
;6 0001010000010101
;7 0001010000000101
Character_N:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000000010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000000000100000
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000000000000000
        STD     ,U     * 4
        LDD     #%1000001000000000
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001010000000
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
; **************************************
; O
;0 0000000000000000
;1 0000010101010100
;2 0001010000000101
;3 0001010000000101
;4 0001010000000101
;5 0001010000000101
;6 0001010000000101
;7 0000010101010100
Character_O:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
; **************************************
; P
;0 0000000000000000
;1 0001010101010100
;2 0001010000000101
;3 0001010000000101
;4 0001010000000101
;5 0001010101010100
;6 0001010000000000
;7 0001010000000000
Character_P:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000000000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        LDD     #%1000001010101010
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; Q
;0 0000000000000000
;1 0000010101010100
;2 0001010000000101
;3 0001010000000101
;4 0001010000000101
;5 0001010001010101
;6 0001010000010100
;7 0000010101010001
Character_Q:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        LDD     #%1000001000000000
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001010000010
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000001000
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; R
;0 0000000000000000
;1 0001010101010100
;2 0001010000000101
;3 0001010000000101
;4 0001010000010101
;5 0001010101010000
;6 0001010001010100
;7 0001010000010101
Character_R:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000000000000010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000001010000000
        STD     ,U     * 4
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000000000001010
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001000000010
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
; **************************************
; S
;0 0000000000000000
;1 0000010101010000
;2 0001010000010100
;3 0001010000000000
;4 0000010101010100
;5 0000000000000101
;6 0001010000000101
;7 0000010101010100
Character_S:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000001010
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1000001010000010
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1000001010101010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010000000000010
        STD     ,U     * 4
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010101010100000
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000001010100000
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
; **************************************
; T
;0 0000000000000000
;1 0000010101010101
;2 0000000001010000
;3 0000000001010000
;4 0000000001010000
;5 0000000001010000
;6 0000000001010000
;7 0000000001010000
Character_T:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000000000000
        STD     -BytesPerRow_HIG106*3,U  * 1
        LDD     #%1010101000001010
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; U
;0 0000000000000000
;1 0001010000000101
;2 0001010000000101
;3 0001010000000101
;4 0001010000000101
;5 0001010000000101
;6 0001010000000101
;7 0000010101010100
Character_U:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; V
;0 0000000000000000
;1 0001010000000101
;2 0001010000000101
;3 0001010000000101
;4 0001010100010101
;5 0000010101010100
;6 0000000101010000
;7 0000000001000000
Character_V:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000000010000000
        STD     ,U     * 4
        LDD     #%1010000000000010
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010100000001010
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010101000101010
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; W
;0 0000000000000000
;1 0001010000000101
;2 0001010000000101
;3 0001010001000101
;4 0001010101010101
;5 0001010101010101
;6 0001010100010101
;7 0001010000000101
Character_W:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1000000000000000
        STD     ,U     * 4
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000000010000000
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1000001010100000
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; X
;0 0000000000000000
;1 0001010000000101
;2 0001010100010101
;3 0000010101010100
;4 0000000101010000
;5 0000010101010100
;6 0001010100010101
;7 0001010000000101
Character_X:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000001010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1000000010000000
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     BytesPerRow_HIG106*2,U   * 6
        LDD     #%1010000000000010
        STD     -BytesPerRow_HIG106,U  * 3
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1010100000001010
        STD     ,U     * 4
        RTS
; **************************************
; Y
;0 0000000000000000
;1 0000010100000101
;2 0000010100000101
;3 0000010100000101
;4 0000000101010100
;5 0000000001010000
;6 0000000001010000
;7 0000000001010000
Character_Y:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1010000010100000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     -BytesPerRow_HIG106*2,U  * 2
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010100000000010
        STD     ,U     * 4
        LDD     #%1010101000001010
        STD     BytesPerRow_HIG106,U   * 5
        STD     BytesPerRow_HIG106*2,U   * 6
        STD     BytesPerRow_HIG106*3,U   * 7
        RTS
; **************************************
; Z
;0 0000000000000000
;1 0001010101010101
;2 0000000000010101
;3 0000000001010100
;4 0000000101010000
;5 0000010101000000
;6 0001010100000000
;7 0001010101010101
Character_Z:
        LDD     #%1010101010101010
        STD     ,U     * 0
        LEAU    BytesPerRow_HIG106*4,U
        LDD     #%1000000000000000
        STD     -BytesPerRow_HIG106*3,U  * 1
        STD     BytesPerRow_HIG106*3,U   * 7
        LDD     #%1010101010000000
        STD     -BytesPerRow_HIG106*2,U  * 2
        LDD     #%1010101000000010
        STD     -BytesPerRow_HIG106,U  * 3
        LDD     #%1010100000001010
        STD     ,U     * 4
        LDD     #%1010000000101010
        STD     BytesPerRow_HIG106,U   * 5
        LDD     #%1000000010101010
        STD     BytesPerRow_HIG106*2,U   * 6
        RTS
